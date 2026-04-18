## Étape 1 — Premier démarrage

docker compose up -d keycloak
# Attendre que Keycloak soit healthy (~60s)
# Accéder à : http://localhost:8081
# Connexion : KC_ADMIN_USER / KC_ADMIN_PASSWORD (voir .env)

## Étape 2 — Créer le Realm "adv-dev"

1. Cliquer sur "Create realm" (menu déroulant en haut à gauche)
2. Realm name : adv-dev
3. Enabled : ON
4. Cliquer "Create"

## Étape 3 — Créer le client MOBILE (public + PKCE)

1. Clients → Create client
2. Client ID : adv-mobile
3. Client type : OpenID Connect
4. Client authentication : OFF (public)
5. Valid redirect URIs : adv://callback, http://localhost:*
6. Web origins : *
7. Advanced → Proof Key for Code Exchange (PKCE) → S256

## Étape 4 — Créer le client BACKEND (confidentiel)

1. Clients → Create client
2. Client ID : adv-backend
3. Client type : OpenID Connect
4. Client authentication : ON (confidential)
5. Service accounts roles : ON
6. Valid redirect URIs : http://localhost:8080/*
7. Après création : Credentials → copier le Client Secret → charger dans Vault :
   vault kv put secret/adv/keycloak client_secret=VALEUR_ICI

## Étape 5 — Créer les rôles du realm

Realm roles → Create role :
- VOYAGEUR
- CHAUFFEUR
- AGENT_AGENCE
- ADMIN

## Étape 6 — Politique de mot de passe

Authentication → Policies → Password policy :
- Minimum length : 8
- Uppercase characters : 1
- Digits : 1
- Special characters : 1

## Étape 7 — Protection brute force

Realm Settings → Security defenses → Brute Force Detection :
- Enabled : ON
- Max login failures : 5
- Wait increment : 30 seconds
- Max wait : 900 seconds (15 min)

## Étape 8 — Exporter la config (IMPORTANT)

Une fois configuré, exporter le realm pour le versionner dans Git :

docker exec adv-keycloak /opt/keycloak/bin/kc.sh export \
  --dir /opt/keycloak/data/import \
  --realm adv-dev \
  --users realm_file

# Copier le fichier généré dans infra/keycloak/config/
docker cp adv-keycloak:/opt/keycloak/data/import/adv-dev-realm.json \
  infra/keycloak/config/adv-dev-realm.json

# Ce fichier est chargé automatiquement au prochain démarrage via :
# volumes:
#   - ./keycloak/config:/opt/keycloak/data/import:ro

## Note sur le schéma PostgreSQL

Keycloak crée automatiquement son propre schéma "keycloak" dans PostgreSQL.
Ne jamais modifier ce schéma manuellement.
Les tables Flyway ADV sont dans le schéma "public".