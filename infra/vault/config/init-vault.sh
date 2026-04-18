#!/bin/bash
# =============================================================================
# À exécuter UNE SEULE FOIS après le premier démarrage de Vault
#
# Usage :
#   1. docker compose up -d vault
#   2. Attendre que Vault soit healthy
#   3. bash infra/vault/config/init-vault.sh
# =============================================================================

set -e

# Configuration
VAULT_CONTAINER_NAME="adv-vault"
VAULT_ADDR="http://127.0.0.1:8200"

# Fonction pour exécuter vault à l'intérieur du conteneur
v-exec() {
  docker exec -i -e VAULT_TOKEN="$VAULT_TOKEN_VAL" "$VAULT_CONTAINER_NAME" vault "$@"
}

# Charger le token depuis .env
if [ -f "../infra/.env" ]; then
  export VAULT_TOKEN_VAL=$(grep VAULT_ROOT_TOKEN ../infra/.env | cut -d= -f2 | tr -d '\r')
else
  echo "Fichier ../infra/.env introuvable. Exporter VAULT_TOKEN manuellement."
  exit 1
fi

echo "=== Initialisation Vault ADV ==="
echo "Vault addr : $VAULT_ADDR"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# 1. Activer le moteur de secrets KV v2
# ─────────────────────────────────────────────────────────────────────────────
echo "[1/5] Activation moteur KV v2..."
v-exec secrets enable -path=secret kv-v2 2>/dev/null || echo "  → KV v2 déjà activé"

# ─────────────────────────────────────────────────────────────────────────────
# 2. Activer l'audit log
# ─────────────────────────────────────────────────────────────────────────────
echo "[2/5] Activation audit log..."
v-exec audit enable file file_path=/vault/data/audit.log 2>/dev/null || echo "  → Audit log déjà activé"

# ─────────────────────────────────────────────────────────────────────────────
# 3. Activer AppRole (pour le backend Spring Boot)
# ─────────────────────────────────────────────────────────────────────────────
echo "[3/5] Activation AppRole..."
v-exec auth enable approle 2>/dev/null || echo "  → AppRole déjà activé"

# ─────────────────────────────────────────────────────────────────────────────
# 4. Créer la policy pour le backend (lecture seule sur secret/adv/*)
# ─────────────────────────────────────────────────────────────────────────────
echo "[4/5] Création policy backend..."
v-exec policy write adv-backend - << 'EOF'
# Policy ADV Backend — lecture seule sur les secrets de l'application
path "secret/data/adv/*" {
  capabilities = ["read"]
}
path "secret/metadata/adv/*" {
  capabilities = ["list"]
}
EOF

# Créer le rôle AppRole pour le backend
v-exec write auth/approle/role/adv-backend \
  token_policies="adv-backend" \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_ttl=0   # Pas d'expiration du secret_id en dev (mettre 720h en prod)

# Récupérer role_id et secret_id
ROLE_ID=$(v-exec read -field=role_id auth/approle/role/adv-backend/role-id)
SECRET_ID=$(v-exec write -field=secret_id -f auth/approle/role/adv-backend/secret-id)

echo ""
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║  COPIER CES VALEURS DANS infra/.env                      ║"
echo "  ╠══════════════════════════════════════════════════════════╣"
echo "  ║  VAULT_ROLE_ID=$ROLE_ID"                                 
echo "  ║  VAULT_SECRET_ID=$SECRET_ID"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# 5. Charger les secrets de l'application
# ─────────────────────────────────────────────────────────────────────────────
echo "[5/5] Chargement des secrets ADV..."
echo "  → Entrez les valeurs quand demandé (ou Ctrl+C pour le faire manuellement)"
echo ""

# Charger les valeurs depuis .env pour les secrets déjà connus
DB_PASSWORD=$(grep DB_PASSWORD ../infra/.env | cut -d= -f2 | tr -d '\r')
MINIO_ACCESS=$(grep MINIO_ROOT_USER ../infra/.env | cut -d= -f2 | tr -d '\r')
MINIO_SECRET=$(grep MINIO_ROOT_PASSWORD ../infra/.env | cut -d= -f2 | tr -d '\r')

v-exec kv put secret/adv/database password="$DB_PASSWORD"

v-exec kv put secret/adv/minio \
  access_key="$MINIO_ACCESS" \
  secret_key="$MINIO_SECRET"

# Secrets à renseigner manuellement (non présents dans .env)
echo ""
echo "  Secrets à charger manuellement avec les vraies valeurs :"
echo ""
echo "  vault kv put secret/adv/keycloak \\"
echo "    client_secret=VOTRE_CLIENT_SECRET_KEYCLOAK"
echo ""
echo "  vault kv put secret/adv/payunit \\"
echo "    api_key=VOTRE_CLE_API_PAYUNIT \\"
echo "    hmac_secret=VOTRE_SECRET_HMAC_WEBHOOK"
echo ""
echo "  vault kv put secret/adv/notifications \\"
echo "    smtp_password=VOTRE_MOT_DE_PASSE_SMTP \\"
echo "    firebase_sa_json='\$(cat chemin/vers/firebase-sa.json)'"
echo ""
echo "=== Initialisation Vault terminée ==="