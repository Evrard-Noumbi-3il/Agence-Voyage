-- =============================================================================
-- IMPORTANT : Ce script ne s'exécute QUE si le volume postgres_data est vide
-- Les migrations de tables sont gérées par Flyway (pas ici)
-- =============================================================================

-- Créer le schéma Keycloak (Keycloak le crée aussi mais mieux de l'anticiper)
CREATE SCHEMA IF NOT EXISTS keycloak;

-- Créer le schéma public ADV (par défaut, mais explicite)
CREATE SCHEMA IF NOT EXISTS public;

-- Donner tous les droits à l'utilisateur ADV sur son schéma
GRANT ALL PRIVILEGES ON SCHEMA public TO current_user;
GRANT ALL PRIVILEGES ON SCHEMA keycloak TO current_user;

-- Extensions nécessaires (Flyway les crée aussi, mais ici pour robustesse)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "citext";

-- Log de confirmation
DO $$
BEGIN
  RAISE NOTICE 'PostgreSQL ADV initialisé avec succès. Schémas : public, keycloak.';
END $$;