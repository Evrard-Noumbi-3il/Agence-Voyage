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


1. Configuration du Realm (adv-dev)
Création du Realm : Mise en place d'un espace isolé nommé adv-dev pour ne pas utiliser le realm master.

Login Settings : Activation du login par Email (en plus du nom d'utilisateur) et activation de l'option User Registration.

2. Configuration du Client (adv-mobile)
C'est le cœur de la communication avec ton application Expo.

Client ID : Défini sur adv-mobile.

Access Type / Capability Config :

Standard Flow activé (pour le code d'authentification).

Direct Access Grants activé (utile pour les tests API).

Redirect URIs : Ajout de com.adv.app://callback pour permettre le retour automatique vers ton application mobile.

Post Logout Redirect URIs : Configuration de la même URI (com.adv.app://callback) pour que le navigateur se ferme après la déconnexion.

Web Origins : Configuré sur * (ou l'IP de ton mobile) pour éviter les erreurs CORS lors des échanges de tokens.

3. Gestion des Rôles (Roles)
Création des Rôles de Realm : Ajout des rôles métier qui correspondent à ton énumération SQL :

VOYAGEUR (attribué par défaut).

CHAUFFEUR.

AGENT_AGENCE.

ADMIN.

Default Roles : Configuration pour que tout nouvel utilisateur inscrit reçoive automatiquement le rôle VOYAGEUR.

4. Mappers de Jetons (Client Scopes)
Pour que ton backend puisse lire les rôles, nous avons vérifié ou configuré :

Audience Mapper : Ajout d'un mapper pour s'assurer que le champ aud (audience) du JWT inclut bien le nom du client ou du backend, évitant les erreurs 401/403.

Roles Mapper : Vérification que les rôles sont bien inclus dans le claim realm_access du jeton d'accès (Access Token).

5. Gestion des Utilisateurs (Users)
Attributs personnalisés : (Si applicable) Ajout de champs comme le téléphone pour qu'ils soient récupérables via le JWT.

Credentials : Configuration des mots de passe pour tes utilisateurs de test (ex: a@a.com).

6. Sécurité & Tokens
Validité du Token : Ajustement (si nécessaire) de la durée de vie de l'Access Token (souvent 5 minutes par défaut) et activation du Refresh Token (Offline Access) pour permettre à l'utilisateur de rester connecté sans ressaisir son mot de passe tous les jours.