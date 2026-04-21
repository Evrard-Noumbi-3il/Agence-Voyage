#!/bin/bash
# =============================================================================
# À exécuter après le premier démarrage de MinIO
#
# Usage :
#   1. docker compose up -d minio
#   2. Attendre que MinIO soit healthy
#   3. bash infra/minio/init-minio.sh
#
# =============================================================================

set -e

# Charger les variables depuis .env
if [ -f "./infra/.env" ]; then
  MINIO_USER=$(grep MINIO_ROOT_USER ./infra/.env | cut -d= -f2 | tr -d '\r')
  MINIO_PASS=$(grep MINIO_ROOT_PASSWORD ./infra/.env | cut -d= -f2 | tr -d '\r')
else
  echo "Fichier ./infra/.env introuvable."
  exit 1
fi

MINIO_URL="http://localhost:9000"

echo "=== Initialisation MinIO ADV via Docker MC ==="

# Fonction pour exécuter mc via un conteneur temporaire sur le même réseau que MinIO
mc-docker() {
  docker run --rm --network infra_backend-net \
    -e "MC_HOST_adv=http://$MINIO_USER:$MINIO_PASS@minio:9000" \
    minio/mc:latest \
    $*
}

# ─────────────────────────────────────────────────────────────────────────────
# Bucket KYC — documents d'identité (accès privé strict)
# ─────────────────────────────────────────────────────────────────────────────
echo "[1/3] Création bucket kyc-documents..."
mc-docker mb adv/kyc-documents --ignore-existing

# Politique d'accès : PRIVÉ (aucun accès public)
mc-docker anonymous set none adv/kyc-documents
echo "  → Bucket kyc-documents créé (accès privé)"

# ─────────────────────────────────────────────────────────────────────────────
# Bucket Avatars — photos de profil (lecture publique OK)
# ─────────────────────────────────────────────────────────────────────────────
echo "[2/3] Création bucket avatars..."
mc-docker mb adv/avatars --ignore-existing
mc-docker anonymous set download adv/avatars
echo "  → Bucket avatars créé (lecture publique)"

# ─────────────────────────────────────────────────────────────────────────────
# Bucket E-billets — PDFs des billets (accès privé)
# ─────────────────────────────────────────────────────────────────────────────
echo "[3/3] Création bucket ebillets..."
mc-docker mb adv/ebillets --ignore-existing
mc-docker anonymous set none adv/ebillets
echo "  → Bucket ebillets créé (accès privé)"

echo ""
echo "=== Buckets MinIO configurés ==="
mc-docker ls adv
echo ""
echo "Console MinIO : http://localhost:9001"
echo "  User : $MINIO_USER"
echo "  Pass : (voir .env)"