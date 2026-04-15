-- =============================================================================
-- V1__init_schema.sql
-- Projet : General Express Voyages — Plateforme de réservation
-- Auteur  : Evrard NOUMBI
-- Date    : Avril 2026
-- SGBD    : PostgreSQL 16
-- =============================================================================
-- ORDRE DE CRÉATION (respecte les dépendances FK) :
--   1. Extension pgcrypto
--   2. villes → agences → services
--   3. types_vehicule → vehicules → sieges → maintenance_vehicule
--   4. utilisateurs → verifications_identite → chauffeurs
--   5. trajets → escales
--   6. voyages (dépend : trajets + vehicules + chauffeurs)
--   7. incidents (dépend : voyages)
--   8. reservations (dépend : voyages + utilisateurs)
--   9. billets (dépend : reservations + sieges + utilisateurs)
--  10. paiements (dépend : reservations)
--  11. bagages (dépend : reservations)
--  12. colis (dépend : utilisateurs + vehicules + agences)
--  13. locations (dépend : utilisateurs + vehicules + chauffeurs)
--  14. journaux_activite (dépend : utilisateurs)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. EXTENSIONS
-- -----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE EXTENSION IF NOT EXISTS "citext";

-- -----------------------------------------------------------------------------
-- TYPES ENUM (pour garantir l'intégrité des statuts et rôles, éviter les erreurs de saisie)
-- -----------------------------------------------------------------------------

CREATE TYPE statut_voyage_enum AS ENUM ('PLANIFIE', 'EN_COURS', 'TERMINE', 'ANNULE');

CREATE TYPE statut_paiement_enum AS ENUM ('EN_ATTENTE', 'PAYE', 'ECHEC', 'REMBOURSE', 'ANNULE');

CREATE TYPE statut_billet_enum AS ENUM ('VALIDE', 'UTILISE', 'ANNULE');

CREATE TYPE statut_transaction_enum AS ENUM ('INITIE', 'EN_CONFIRMATION', 'SUCCES', 'ECHEC', 'REMBOURSE');

CREATE TYPE role_utilisateur_enum AS ENUM ('VOYAGEUR', 'CHAUFFEUR', 'AGENT_AGENCE', 'ADMIN');

CREATE TYPE type_service_enum AS ENUM ('CAFETERIA', 'RESTO', 'HOTEL', 'COLIS', 'VIP_LOUNGE');

CREATE TYPE categorie_vehicule_enum AS ENUM ('CLASSIQUE', 'MOYEN', 'VIP');

CREATE TYPE statut_vehicule_enum AS ENUM ('AU_GARAGE', 'AU_LAVAGE', 'EN_MAINTENANCE', 'EN_SERVICE', 'AU_DEPART');

CREATE TYPE statut_location_enum AS ENUM ('DEVIS', 'CONFIRME', 'EN_COURS', 'TERMINE', 'ANNULE');

CREATE TYPE statut_resolution_enum AS ENUM ('EN_COURS', 'RESOLU');

CREATE TYPE verification_statut_enum AS ENUM ('EN_ATTENTE', 'VALIDE', 'REJETE', 'EXPIRE');

CREATE TYPE statut_colis_enum AS ENUM ('DEPOSE', 'EN_TRANSIT', 'ARRIVE', 'RECUPERE');

CREATE TYPE statut_chauffeur_enum AS ENUM ('DISPONIBLE', 'EN_VOYAGE', 'EN_CONGE');

-- =============================================================================
-- PÔLE GÉOGRAPHIE & AGENCES
-- =============================================================================

CREATE TABLE villes (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    nom         VARCHAR(100) NOT NULL,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE TABLE agences (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    ville_id    UUID         NOT NULL REFERENCES villes(id) DEFERRABLE INITIALLY IMMEDIATE,
    nom_agence  VARCHAR(150) NOT NULL,
    quartier    VARCHAR(100),
    description TEXT,
    photos      JSONB,   -- JSON array d'URLs
    gps_lat     DOUBLE PRECISION,
    gps_long    DOUBLE PRECISION,
    created_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE TABLE services (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    agence_id    UUID         NOT NULL REFERENCES agences(id) DEFERRABLE INITIALLY IMMEDIATE,
    nom_service  type_service_enum  NOT NULL, -- CAFETERIA, RESTO, HOTEL, COLIS, VIP_LOUNGE
    description  TEXT,
    photos       JSONB,
    created_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- PÔLE FLOTTE & MAINTENANCE
-- =============================================================================

CREATE TABLE types_vehicule (
    id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    categorie     categorie_vehicule_enum  NOT NULL,  -- CLASSIQUE, MOYEN, VIP
    description   TEXT,
    modele_3d_url VARCHAR(500),
    created_at    TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE TABLE vehicules (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    type_vehicule_id UUID        NOT NULL REFERENCES types_vehicule(id) DEFERRABLE INITIALLY IMMEDIATE,
    immatriculation  VARCHAR(20) NOT NULL UNIQUE,
    nombre_sieges    INT         NOT NULL CHECK (nombre_sieges > 0),
    statut_stock     statut_vehicule_enum NOT NULL DEFAULT 'AU_GARAGE',
    -- Valeurs : AU_GARAGE, AU_LAVAGE, EN_MAINTENANCE, EN_SERVICE, AU_DEPART
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE TABLE sieges (
    id               UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicule_id      UUID         NOT NULL REFERENCES vehicules(id) DEFERRABLE INITIALLY IMMEDIATE,
    numero_siege     VARCHAR(5)   NOT NULL,
    type_siege       VARCHAR(20)  NOT NULL DEFAULT 'STANDARD', -- FENETRE, COULOIR, VIP
    supplement_prix  DECIMAL(10,2) NOT NULL DEFAULT 0,
    pos_x            FLOAT,
    pos_y            FLOAT,
    pos_z            FLOAT,
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    UNIQUE (vehicule_id, numero_siege)  -- un numéro de siège unique par véhicule
);

CREATE TABLE maintenance_vehicule (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicule_id      UUID        NOT NULL REFERENCES vehicules(id) DEFERRABLE INITIALLY IMMEDIATE,
    type_travaux     VARCHAR(200) NOT NULL,
    date_debut       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    date_fin_prevue  TIMESTAMPTZ,
    created_at       TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- PÔLE IDENTITÉ & SÉCURITÉ (IAM / KYC)
-- =============================================================================

CREATE TABLE utilisateurs (
    id              UUID         PRIMARY KEY,
    -- NOTE : id synchronisé avec le claim 'sub' du JWT Keycloak.
    -- Pas de DEFAULT gen_random_uuid() ici : c'est Keycloak qui génère l'UUID.
    -- Ce champ est renseigné lors du premier appel authentifié de l'utilisateur.
    nom             VARCHAR(100) NOT NULL,
    prenom          VARCHAR(100) NOT NULL,
    email           CITEXT NOT NULL UNIQUE,
    telephone       VARCHAR(20)  UNIQUE,
    photo_profil_url VARCHAR(500),
    est_verifie     BOOLEAN      NOT NULL DEFAULT FALSE,
    est_banni       BOOLEAN      NOT NULL DEFAULT FALSE,
    role  role_utilisateur_enum  NOT NULL DEFAULT 'VOYAGEUR',
    -- NOTE : Ce champ est un CACHE LECTURE SEULE depuis le JWT Keycloak.
    -- La source de vérité est Keycloak. Ne jamais modifier ce champ directement.
    -- Il est mis à jour uniquement par le service IAM lors de la synchro token.
    -- Valeurs : VOYAGEUR, CHAUFFEUR, AGENT_AGENCE, ADMIN
    points_fidelite INT          NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

CREATE TABLE verifications_identite (
    id                       UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    utilisateur_id           UUID         NOT NULL REFERENCES utilisateurs(id) DEFERRABLE INITIALLY IMMEDIATE,
    type_document            VARCHAR(20)  NOT NULL, -- CNI, PASSEPORT, RECEPISSE
    numero_document          VARCHAR(50),
    photo_recto_url          VARCHAR(500) NOT NULL,
    photo_verso_url          VARCHAR(500),
    photo_selfie_url         VARCHAR(500) NOT NULL,
    date_expiration_document DATE,
    statut                   verification_statut_enum  NOT NULL DEFAULT 'EN_ATTENTE',
    -- Valeurs : EN_ATTENTE, VALIDE, REJETE, EXPIRE
    motif_rejet              TEXT,        -- renseigné si statut = REJETE
    date_soumission          TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    date_traitement          TIMESTAMPTZ,   -- date de validation/rejet par l'admin
    traite_par_admin_id      UUID         REFERENCES utilisateurs(id)
);

CREATE TABLE chauffeurs (
    id               UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    utilisateur_id   UUID         NOT NULL UNIQUE REFERENCES utilisateurs(id) DEFERRABLE INITIALLY IMMEDIATE,
    numero_permis    VARCHAR(50)  NOT NULL UNIQUE,
    photo_recto_url  VARCHAR(500),
    photo_verso_url  VARCHAR(500),
    statut_activite  statut_chauffeur_enum  NOT NULL DEFAULT 'DISPONIBLE',
    -- Valeurs : DISPONIBLE, EN_VOYAGE, EN_CONGE
    created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- PÔLE VOYAGES, ESCALES & INCIDENTS
-- =============================================================================

CREATE TABLE trajets (
    id               UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    agence_depart_id UUID    NOT NULL REFERENCES agences(id) DEFERRABLE INITIALLY IMMEDIATE,
    agence_arrivee_id UUID   NOT NULL REFERENCES agences(id) DEFERRABLE INITIALLY IMMEDIATE,
    distance_km      INT     CHECK (distance_km > 0),
    est_direct       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_trajet_different CHECK (agence_depart_id <> agence_arrivee_id)
);

CREATE TABLE escales (
    id                   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    trajet_id            UUID         NOT NULL REFERENCES trajets(id) DEFERRABLE INITIALLY IMMEDIATE,
    nom_lieu             VARCHAR(150) NOT NULL,
    ordre_passage        INT          NOT NULL CHECK (ordre_passage > 0),
    description_activite TEXT,
    photos            JSONB,   -- JSON array d'URLs
    gps_lat              DOUBLE PRECISION,
    gps_long             DOUBLE PRECISION,
    created_at           TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    UNIQUE (trajet_id, ordre_passage) -- ordre unique par trajet
);

CREATE TABLE voyages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    trajet_id UUID NOT NULL REFERENCES trajets(id),
    vehicule_id UUID NOT NULL REFERENCES vehicules(id),
    chauffeur_id UUID NOT NULL REFERENCES chauffeurs(id),

    date_heure_depart TIMESTAMPTZ NOT NULL,
    date_heure_arrivee_estime TIMESTAMPTZ,

    prix_base DECIMAL(10,2) NOT NULL CHECK (prix_base >= 0),
    nbr_voyageurs_max INT NOT NULL CHECK (nbr_voyageurs_max > 0),

    statut_voyage statut_voyage_enum NOT NULL DEFAULT 'PLANIFIE',

    note_moyenne DECIMAL(3,2) DEFAULT 0,

    nombre_avis INT DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_dates_voyage 
        CHECK (date_heure_arrivee_estime IS NULL OR date_heure_arrivee_estime > date_heure_depart)
);

CREATE TABLE incidents (
    id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    voyage_id         UUID         NOT NULL REFERENCES voyages(id) DEFERRABLE INITIALLY IMMEDIATE,
    type_incident      VARCHAR(30)  NOT NULL, -- PANNE, ACCIDENT, BLOCAGE_ROUTE
    description       TEXT         NOT NULL,
    heure_incident    TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    statut_resolution statut_resolution_enum  NOT NULL DEFAULT 'EN_COURS',
    -- Valeurs : EN_COURS, RESOLU
    declare_par_id    UUID         REFERENCES utilisateurs(id),
    created_at        TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- PÔLE RÉSERVATIONS & BILLETS
-- =============================================================================

CREATE TABLE reservations (
    id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    utilisateur_id   UUID          NOT NULL REFERENCES utilisateurs(id) DEFERRABLE INITIALLY IMMEDIATE,
    voyage_id        UUID          NOT NULL REFERENCES voyages(id) DEFERRABLE INITIALLY IMMEDIATE,
    date_reservation TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    montant_total    DECIMAL(10,2) NOT NULL CHECK (montant_total >= 0),
    statut_paiement  statut_paiement_enum   NOT NULL DEFAULT 'EN_ATTENTE',
    -- Valeurs : EN_ATTENTE, PAYE, ECHEC, REMBOURSE, ANNULE
    created_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE billets (
    id                    UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id        UUID         NOT NULL REFERENCES reservations(id) DEFERRABLE INITIALLY IMMEDIATE,
    siege_id              UUID         NOT NULL REFERENCES sieges(id) DEFERRABLE INITIALLY IMMEDIATE,
    nom_passager          VARCHAR(200) NOT NULL,
    qr_code_token         VARCHAR(128) NOT NULL UNIQUE,
    -- NOTE : token = HMAC-SHA256(id_billet + TIMESTAMPTZ + secret Vault)
    -- Indexé explicitement dans V2__add_indexes.sql pour les scans rapides
    statut_billet         statut_billet_enum  NOT NULL DEFAULT 'VALIDE',
    -- Valeurs : VALIDE, UTILISE, ANNULE
    date_validation       TIMESTAMPTZ,   -- renseigné au moment du scan agent
    valide_par_agent_id   UUID         REFERENCES utilisateurs(id),
    -- IMPORTANT : vérifier côté applicatif que cet utilisateur a le rôle AGENT_AGENCE
    -- La FK ne contrôle pas le rôle — c'est la responsabilité du service de validation
    created_at            TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    UNIQUE (reservation_id, siege_id)  -- un siège ne peut être attribué qu'une fois par réservation
);

CREATE TABLE paiements (
    id                 UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id     UUID          NOT NULL REFERENCES reservations(id) DEFERRABLE INITIALLY IMMEDIATE,
    reference_payunit  VARCHAR(100)  UNIQUE,  -- nullable jusqu'à confirmation PayUnit
    cle_idempotence    VARCHAR(36)   NOT NULL UNIQUE,
    -- NOTE : UUID v4 généré côté client AVANT l'appel PayUnit, stocké en DB AVANT
    -- toute tentative de paiement. Garantit l'anti-double-débit.
    methode_paiement   VARCHAR(10)   NOT NULL, -- OM, MOMO, CARTE
    montant            DECIMAL(10,2) NOT NULL CHECK (montant > 0),
    devise             VARCHAR(3)    NOT NULL DEFAULT 'XAF',
    statut_transaction statut_transaction_enum   NOT NULL DEFAULT 'INITIE',
    -- Valeurs : INITIE, EN_CONFIRMATION, SUCCES, ECHEC, REMBOURSE
    webhook_payload    JSONB,  -- payload brut du webhook PayUnit pour audit
    date_transaction   TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    created_at         TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE TABLE bagages (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id  UUID         NOT NULL REFERENCES reservations(id) DEFERRABLE INITIALLY IMMEDIATE,
    poids_kg        FLOAT        NOT NULL CHECK (poids_kg > 0),
    etiquette_code  VARCHAR(50)  NOT NULL UNIQUE,
    created_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- PÔLE LOGISTIQUE (COLIS) & LOCATION
-- =============================================================================

CREATE TABLE colis (
    id                      UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    expediteur_id           UUID          NOT NULL REFERENCES utilisateurs(id) DEFERRABLE INITIALLY IMMEDIATE,
    vehicule_id             UUID          REFERENCES vehicules(id),
    agence_depart_id        UUID          NOT NULL REFERENCES agences(id) DEFERRABLE INITIALLY IMMEDIATE,
    agence_destination_id   UUID          NOT NULL REFERENCES agences(id) DEFERRABLE INITIALLY IMMEDIATE,
    destinataire_id         UUID          REFERENCES utilisateurs(id),  -- nullable si destinataire non inscrit
    nom_destinataire        VARCHAR(200)  NOT NULL,
    tel_destinataire        VARCHAR(20)   NOT NULL,
    description_contenu     TEXT,
    poids_kg                FLOAT         NOT NULL CHECK (poids_kg > 0),
    prix_envoi              DECIMAL(10,2) NOT NULL CHECK (prix_envoi >= 0),
    code_retrait_hash       VARCHAR(255)  NOT NULL UNIQUE,
    -- NOTE : hash du code de retrait, jamais le code en clair
    statut_colis            statut_colis_enum   NOT NULL DEFAULT 'DEPOSE',
    -- Valeurs : DEPOSE, EN_TRANSIT, ARRIVE, RECUPERE
    photo_reception_url     VARCHAR(500),
    cni_destinataire_verifiee BOOLEAN     NOT NULL DEFAULT FALSE,
    date_depot              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    date_retrait_effective  TIMESTAMPTZ,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_colis_agences_diff CHECK (agence_depart_id <> agence_destination_id)
);

CREATE TABLE locations (
    id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    utilisateur_id   UUID          NOT NULL REFERENCES utilisateurs(id) DEFERRABLE INITIALLY IMMEDIATE,
    vehicule_id      UUID          NOT NULL REFERENCES vehicules(id) DEFERRABLE INITIALLY IMMEDIATE,
    chauffeur_id     UUID          REFERENCES chauffeurs(id),  -- nullable si sans chauffeur
    date_debut       TIMESTAMPTZ     NOT NULL,
    date_fin         TIMESTAMPTZ     NOT NULL,
    itineraire_prevu TEXT,
    montant_total    DECIMAL(10,2) NOT NULL CHECK (montant_total >= 0),
    avec_chauffeur   BOOLEAN       NOT NULL DEFAULT TRUE,
    statut_location  statut_location_enum   NOT NULL DEFAULT 'DEVIS',
    -- Valeurs : DEVIS, CONFIRME, EN_COURS, TERMINE, ANNULE
    created_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_location_dates CHECK (date_fin > date_debut)
);

-- =============================================================================
-- PÔLE AUDIT (TRAÇABILITÉ)
-- =============================================================================

CREATE TABLE journaux_activite (
    id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    utilisateur_id UUID         REFERENCES utilisateurs(id),
    -- nullable : certaines actions système peuvent ne pas avoir d'utilisateur
    action         VARCHAR(50)  NOT NULL,
    -- Ex : CONNEXION, DECONNEXION, RESERVATION, PAIEMENT, VALIDATION_KYC,
    --      SCAN_BILLET, ANNULATION, MODIFICATION_PROFIL, TENTATIVE_ACCES_REFUSE
    details        TEXT,
    adresse_ip     VARCHAR(45)  NOT NULL,  -- IPv4 (15) ou IPv6 (39) — 45 pour sécurité
    date_action    TIMESTAMPTZ    NOT NULL DEFAULT NOW()
    -- NOTE : pas de created_at séparé, date_action est la date de création
);

-- =============================================================================
-- PÔLE AVIS & NOTATIONS
-- =============================================================================

CREATE TABLE avis_voyages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    utilisateur_id UUID NOT NULL REFERENCES utilisateurs(id),
    voyage_id UUID NOT NULL REFERENCES voyages(id),

    note INT NOT NULL CHECK (note BETWEEN 1 AND 5),

    commentaire TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (utilisateur_id, voyage_id)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- NOTE : protection "avis sans voyage" — côté applicatif (Java), pas SQL
-- ─────────────────────────────────────────────────────────────────────────────
-- Dans AvisService.java, avant tout INSERT dans avis_voyages, vérifier :
--
-- boolean aDejaVoyage = reservationRepository.existsByUtilisateurIdAndVoyageIdAndStatutPaiement(
--     utilisateurId, voyageId, StatutPaiement.PAYE
-- );
-- if (!aDejaVoyage) throw new BusinessException("Vous ne pouvez noter que les voyages effectués.");
-- ────────────────────────────────────────────────────────────────────────────