# Conception & Spécifications — Projet ADV
Ce dossier regroupe l'ensemble des livrables de la Phase de Conception (Phase 0). Il sert de référentiel pour aligner le développement technique sur les besoins métiers de l'agence de voyage.

# État d'avancement des Livrables
| Fichier | Description | Priorité | Statut |
|-------|----------|--------|--------|
| CAHIER-DES-CHARGES-PROJET.docx | Document de cadrage : objectifs, périmètre, contraintes techniques. | Haute | ✅ Validé |
| users stories.docx | Backlog produit : 27 US détaillées avec Personas et Critères d'Acceptation. | Haute | ✅ Validé |
| Matrice_Flux_GEV_v1.0.docx | Analyse détaillée des flux critiques (Paiement, KYC, QR Code). | Moyenne | ✅ Validé |
| schema_db.png | Représentation visuelle du Modèle Logique de Données (MLD). | Haute | ⬜ À exporter |
| checklist_devsecops.md | Suivi de la conformité Sécurité et Qualité par phase. | Moyenne | 🔄 En cours |

# 🗺️ Zoom sur le Backlog (User Stories)
Le projet est piloté par la valeur métier. Les US sont classées en 4 grands épiques (Epics) :

1. Epic IAM & Sécurité : Inscription, Connexion (Keycloak), Profils rôles.

2. Epic Booking : Recherche, réservation de siège en temps réel (Redis Locks), paiement.

3. Epic KYC & Billet : Upload documents, génération de e-billet PDF, scan QR Code.

4. Epic Administration : Gestion de la flotte de bus, planification des trajets.

### Note Méthodologique : Chaque US est associée à un test d'acceptation automatisé (Newman/Postman) pour garantir la "Definition of Done" (DoD).


# Modélisation de la Base de Données
Le schéma de données est conçu pour la performance (indexation PostgreSQL) et la traçabilité.

- Fichier SQL : Retrouvez le script de création actuel dans docs/architecture/Agence de voyage.sql.

- dbdiagram.io : [Insérer le lien vers ton projet dbdiagram si public].

Règles de gestion implémentées :

- Un voyageur ne peut pas réserver un siège déjà verrouillé dans Redis.

- Les documents KYC sont liés de manière sécurisée à l'ID utilisateur (MinIO).

- Historisation complète des transactions de paiement.

# Processus de mise à jour
Pour garantir que la documentation reste le reflet fidèle du code :

1. Schéma DB : À chaque modification de V1__init_schema.sql (Flyway), mettre à jour l'export schema_db.png.

2. User Stories : Une US est marquée comme "Terminée" uniquement après le passage au vert du pipeline CI/CD correspondant.
