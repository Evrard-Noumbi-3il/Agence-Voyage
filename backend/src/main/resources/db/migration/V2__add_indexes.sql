-- =============================================================================
-- V2__add_indexes.sql
-- Projet : General Express Voyages
-- Auteur  : Evrard NOUMBI — Avril 2026
-- Objectif : Index de performance sur les requêtes critiques
-- =============================================================================
-- RÈGLE : Un index = une justification. Chaque index ici a été mesuré nécessaire.
-- Trop d'index ralentit les INSERT/UPDATE — on n'indexe pas par précaution.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- BILLETS — scan QR Code à l'embarquement (requête la plus fréquente en prod)
-- Requête : SELECT * FROM billets WHERE qr_code_token = ?
-- Fréquence : à chaque embarquement de passager
-- -----------------------------------------------------------------------------
CREATE UNIQUE INDEX idx_billets_qr_token
    ON billets(qr_code_token);

-- -----------------------------------------------------------------------------
-- BILLETS — consultation des billets d'une réservation
-- Requête : SELECT * FROM billets WHERE reservation_id = ?
-- Fréquence : à chaque affichage du détail d'une réservation
-- -----------------------------------------------------------------------------
CREATE INDEX idx_billets_reservation
    ON billets(reservation_id);

-- -----------------------------------------------------------------------------
-- BILLETS — plan de bus et gestion des sièges
-- Requête : SELECT * FROM billets WHERE siege_id = ?
-- Fréquence : à chaque affichage du plan de bus, validation de siège
-- -----------------------------------------------------------------------------
CREATE INDEX idx_billets_siege
    ON billets(siege_id);

-- -----------------------------------------------------------------------------
-- VOYAGES — recherche de trajets (requête la plus fréquente côté voyageur)
-- Requête : SELECT * FROM voyages
--           WHERE trajet_id = ? AND date_heure_depart >= ? AND statut_voyage = 'PLANIFIE'
-- Fréquence : très haute — chaque recherche de trajet
-- Index composé : l'ordre des colonnes correspond à l'ordre des filtres dans la requête
-- -----------------------------------------------------------------------------
CREATE INDEX idx_voyages_recherche
    ON voyages(trajet_id, statut_voyage, date_heure_depart);

-- -----------------------------------------------------------------------------
-- VOYAGES — recherche par véhicule (gestion des conflits d'affectation)
-- Requête : SELECT * FROM voyages WHERE vehicule_id = ? AND statut_voyage != 'TERMINE'
-- Fréquence : à chaque planification d'un nouveau voyage
-- -----------------------------------------------------------------------------
CREATE INDEX idx_voyages_vehicule_actif
    ON voyages(vehicule_id)
    WHERE statut_voyage != 'TERMINE'::statut_voyage_enum;

-- -----------------------------------------------------------------------------
-- VOYAGES — recherche par chauffeur
-- Requête : SELECT * FROM voyages WHERE chauffeur_id = ? AND statut_voyage = ?
-- Fréquence : consultation planning chauffeur
-- -----------------------------------------------------------------------------
CREATE INDEX idx_voyages_chauffeur
    ON voyages(chauffeur_id, statut_voyage);

-- -----------------------------------------------------------------------------
-- VOYAGES — tableau de bord admin des voyages planifiés
-- Requête : SELECT * FROM voyages WHERE statut_voyage = 'PLANIFIE' ORDER BY date_heure_depart
-- Fréquence : consultation du planning global des voyages à venir
-- Index partiel : uniquement les voyages PLANIFIE, les autres sont moins consultés
-- -----------------------------------------------------------------------------
CREATE INDEX idx_voyages_planifies
    ON voyages(trajet_id, date_heure_depart)
    WHERE statut_voyage = 'PLANIFIE'::statut_voyage_enum;

-- -----------------------------------------------------------------------------
-- RESERVATIONS — tableau de bord et statistiques admin
-- Requête : SELECT * FROM reservations WHERE voyage_id = ? AND statut_paiement = 'PAYE'
-- Fréquence : calcul du taux de remplissage, validation embarquement
-- -----------------------------------------------------------------------------
CREATE INDEX idx_reservations_voyage_statut
    ON reservations(voyage_id, statut_paiement);

-- -----------------------------------------------------------------------------
-- RESERVATIONS — historique d'un voyageur
-- Requête : SELECT * FROM reservations WHERE utilisateur_id = ? ORDER BY date_reservation DESC
-- Fréquence : consultation du profil voyageur
-- -----------------------------------------------------------------------------
CREATE INDEX idx_reservations_utilisateur
    ON reservations(utilisateur_id, date_reservation DESC);

-- ----------------------------------------------------------------------------- 
-- RESERVATIONS — validation d'embarquement (recherche par voyage + statut)
-- Requête : SELECT * FROM reservations WHERE voyage_id = ? AND statut_paiement = 'PAYE'
-- Fréquence : à chaque embarquement de passager
-- -----------------------------------------------------------------------------
CREATE INDEX idx_reservations_voyage
    ON reservations(voyage_id);

-- -----------------------------------------------------------------------------
-- PAIEMENTS — réconciliation avec PayUnit
-- Requête : SELECT * FROM paiements WHERE reference_payunit = ?
-- Fréquence : à chaque webhook PayUnit reçu
-- -----------------------------------------------------------------------------
CREATE INDEX idx_paiements_payunit
    ON paiements(reference_payunit)
    WHERE reference_payunit IS NOT NULL;  -- index partiel : exclut les paiements non initiés

-- -----------------------------------------------------------------------------
-- JOURNAUX — audit et recherche par utilisateur
-- Requête : SELECT * FROM journaux_activite WHERE utilisateur_id = ? ORDER BY date_action DESC
-- Fréquence : consultation des logs admin, détection d'anomalies
-- -----------------------------------------------------------------------------
CREATE INDEX idx_journaux_utilisateur_date
    ON journaux_activite(utilisateur_id, date_action DESC);

-- -----------------------------------------------------------------------------
-- JOURNAUX — recherche par action (détection d'intrusion, reporting)
-- Requête : SELECT * FROM journaux_activite WHERE action = ? AND date_action > ?
-- Fréquence : rapports de sécurité, alertes
-- -----------------------------------------------------------------------------
CREATE INDEX idx_journaux_action_date
    ON journaux_activite(action, date_action DESC);

-- -----------------------------------------------------------------------------
-- VERIFICATIONS_IDENTITE — file d'attente KYC pour les admins
-- Requête : SELECT * FROM verifications_identite WHERE statut = 'EN_ATTENTE' ORDER BY date_soumission
-- Fréquence : à chaque connexion admin sur l'interface KYC
-- Index partiel : uniquement les dossiers EN_ATTENTE (les autres ne sont plus consultés souvent)
-- -----------------------------------------------------------------------------
CREATE INDEX idx_kyc_en_attente
    ON verifications_identite(date_soumission)
    WHERE statut = 'EN_ATTENTE';

-- -----------------------------------------------------------------------------
-- SIEGES — rendu du plan de bus
-- Requête : SELECT * FROM sieges WHERE vehicule_id = ? ORDER BY pos_y, pos_x
-- Fréquence : à chaque affichage du plan de sièges
-- -----------------------------------------------------------------------------
CREATE INDEX idx_sieges_vehicule_plan
    ON sieges(vehicule_id, pos_y, pos_x);

-- -----------------------------------------------------------------------------
-- TRAJETS — recherche par agences (départ + arrivée)
-- Requête : SELECT * FROM trajets WHERE agence_depart_id = ? AND agence_arrivee_id = ?
-- Fréquence : à chaque recherche de trajet
-- -----------------------------------------------------------------------------
CREATE INDEX idx_trajets_agences
    ON trajets(agence_depart_id, agence_arrivee_id);

-- -----------------------------------------------------------------------------
-- COLIS — suivi par expéditeur
-- Requête : SELECT * FROM colis WHERE expediteur_id = ? ORDER BY date_depot DESC
-- Fréquence : consultation de l'historique colis
-- -----------------------------------------------------------------------------
CREATE INDEX idx_colis_expediteur
    ON colis(expediteur_id, date_depot DESC);

-- -----------------------------------------------------------------------------
-- COLIS — suivi des colis actifs (en transit ou déposés)
-- Requête : SELECT * FROM colis WHERE statut_colis IN ('DEPOSE', 'EN_TRANSIT') ORDER BY date_depot DESC
-- Fréquence : tableau de bord logistique admin
-- Index partiel : uniquement les colis actifs, les autres sont archivés et moins consultés
-- -----------------------------------------------------------------------------
CREATE INDEX idx_colis_actifs
    ON colis(date_depot DESC)
    WHERE statut_colis IN ('DEPOSE'::statut_colis_enum, 'EN_TRANSIT'::statut_colis_enum)

-- -----------------------------------------------------------------------------
-- AVIS_VOYAGES — affichage des avis d'un voyage
-- Requête : SELECT * FROM avis_voyages WHERE voyage_id = ? ORDER BY date_avis DESC
-- Fréquence : à chaque affichage des détails d'un voyage
-- -----------------------------------------------------------------------------
CREATE INDEX idx_avis_voyage
    ON avis_voyages(voyage_id);

-- -----------------------------------------------------------------------------
-- AVIS_VOYAGES — historique d'avis d'un utilisateur
-- Requête : SELECT * FROM avis_voyages WHERE utilisateur_id = ? ORDER BY date_avis DESC
-- Fréquence : consultation du profil voyageur, modération
-- -----------------------------------------------------------------------------
CREATE INDEX idx_avis_utilisateur
    ON avis_voyages(utilisateur_id);