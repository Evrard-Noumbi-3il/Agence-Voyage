#!/bin/bash
# =============================================================================
# Initialisation Vault ADV via CLI dans le conteneur Docker
# Configuration des moteurs, policies, AppRole et injection des secrets.
# =============================================================================

set -e

# ==============================================================================
# CONFIGURATION ET FONCTIONS
# ==============================================================================
VAULT_CONTAINER_NAME="adv-vault"
ENV_PATH="./infra/.env"

# ==============================================================================
# Fonction pour exécuter vault à l'intérieur du conteneur
# ==============================================================================
v-exec() {
  docker exec -i -e VAULT_TOKEN="$VAULT_TOKEN_VAL" "$VAULT_CONTAINER_NAME" vault "$@"
}

# ==============================================================================
# CHARGEMENT DU TOKEN ROOT
# ==============================================================================
if [ -f "$ENV_PATH" ]; then
  VAULT_TOKEN_VAL=$(grep '^VAULT_ROOT_TOKEN=' "$ENV_PATH" | cut -d'=' -f2- | tr -d '\r' | xargs)
else
  echo " Erreur : Fichier $ENV_PATH introuvable."
  exit 1
fi

if [ -z "$VAULT_TOKEN_VAL" ]; then
  echo " Erreur : VAULT_ROOT_TOKEN est vide dans le fichier .env."
  exit 1
fi

echo " === Initialisation Vault ADV entamée ==="

# ==============================================================================
# 1. Moteur de secrets KV v2
# ==============================================================================
echo "[1/6] Activation moteur KV v2..."
v-exec secrets enable -path=secret kv-v2 2>/dev/null || echo "  → KV v2 déjà activé"

# ==============================================================================
# 2. Audit log (pour la traçabilité PFE)
# ==============================================================================
echo "[2/6] Activation audit log..."
v-exec audit enable file file_path=/vault/data/audit.log 2>/dev/null || echo "  → Audit log déjà activé"

# ==============================================================================
# 3. AppRole
# ==============================================================================
echo "[3/6] Activation AppRole..."
v-exec auth enable approle 2>/dev/null || echo "  → AppRole déjà activé"

# ==============================================================================
# 4. Policy Backend
# ==============================================================================
echo "[4/6] Création policy 'adv-backend'..."
v-exec policy write adv-backend - << 'EOF'
path "secret/data/adv" {
  capabilities = ["read"]
}
path "secret/metadata/adv" {
  capabilities = ["list"]
}
path "auth/token/renew" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
EOF

# ==============================================================================
# 5. Configuration AppRole et récupération des IDs
# ==============================================================================
echo "[5/6] Configuration AppRole..."
v-exec write auth/approle/role/adv-backend \
    token_policies="adv-backend" \
    token_ttl=1h \
    token_max_ttl=4h \
    secret_id_ttl=0

ROLE_ID=$(v-exec read -field=role_id auth/approle/role/adv-backend/role-id)
SECRET_ID=$(v-exec write -field=secret_id -f auth/approle/role/adv-backend/secret-id)

# Mise à jour automatique du .env
sed -i "s/^VAULT_ROLE_ID=.*/VAULT_ROLE_ID=$ROLE_ID/" "$ENV_PATH"
sed -i "s/^VAULT_SECRET_ID=.*/VAULT_SECRET_ID=$SECRET_ID/" "$ENV_PATH"

# ==============================================================================
# 6. Injection des secrets depuis le .env
# ==============================================================================
echo "[6/6] Injection des secrets dans secret/adv..."

# ==============================================================================
# Extraction des variables
# ==============================================================================
DB_NAME=$(grep '^DB_NAME=' "$ENV_PATH" | cut -d'=' -f2- | tr -d '\r' | xargs)
DB_USER=$(grep '^DB_USER=' "$ENV_PATH" | cut -d'=' -f2- | tr -d '\r' | xargs)
DB_PASS=$(grep '^DB_PASSWORD=' "$ENV_PATH" | cut -d'=' -f2- | tr -d '\r' | xargs)
REDIS_PASS=$(grep '^REDIS_PASSWORD=' "$ENV_PATH" | cut -d'=' -f2- | tr -d '\r' | xargs)
MINIO_USER=$(grep '^MINIO_ROOT_USER=' "$ENV_PATH" | cut -d'=' -f2- | tr -d '\r' | xargs)
MINIO_PASS=$(grep '^MINIO_ROOT_PASSWORD=' "$ENV_PATH" | cut -d'=' -f2- | tr -d '\r' | xargs)
QR_SECRET=$(grep '^QR_HMAC_SECRET=' "$ENV_PATH" | cut -d'=' -f2- | tr -d '\r' | xargs)

v-exec kv put secret/adv \
    database.password="$DB_PASS" \
    database.user="$DB_USER" \
    database.name="$DB_NAME" \
    redis.password="$REDIS_PASS" \
    minio.access_key="$MINIO_USER" \
    minio.secret_key="$MINIO_PASS" \
    security.qr_hmac_secret="$QR_SECRET"

echo ""
echo " === Initialisation terminée avec succès ==="
echo ""
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║  COPIER CES VALEURS DANS infra/.env                      ║"
echo "  ╠══════════════════════════════════════════════════════════╣"
echo "  ║  VAULT_ROLE_ID=$ROLE_ID                                  ║"                                 
echo "  ║  VAULT_SECRET_ID=$SECRET_ID                              ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo ""
echo " Le fichier .env a été mis à jour."
echo " Interface : http://localhost:8200"


# ==============================================================================
# Secrets à renseigner manuellement (non présents dans .env)
# ==============================================================================
echo ""
echo "  Secrets à charger manuellement avec les vraies valeurs :"
echo ""
echo "  v-exec kv put secret/adv/keycloak \\"
echo "    client_secret=VOTRE_CLIENT_SECRET_KEYCLOAK"
echo ""
echo "  v-exec kv put secret/adv/payunit \\"
echo "    api_key=VOTRE_CLE_API_PAYUNIT \\"
echo "    hmac_secret=VOTRE_SECRET_HMAC_WEBHOOK"
echo ""
echo "  v-exec kv put secret/adv/notifications \\"
echo "    smtp_password=VOTRE_MOT_DE_PASSE_SMTP \\"
echo "    firebase_sa_json='\$(cat chemin/vers/firebase-sa.json)'"
echo ""
echo "=== Initialisation Vault terminée ==="