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

# ─────────────────────────────────────────────────────────────────────────────
# Créer les buckets via l'interface console MinIO (http://localhost:9001)
# Les étapes ci-dessous sont les actions à faire MANUELLEMENT dans l'UI
# ─────────────────────────────────────────────────────────────────────────────
 
echo "ÉTAPES MANUELLES dans la console MinIO (http://localhost:9001) :" 
echo ""
echo "Connexion : $MINIO_USER / (voir .env MINIO_ROOT_PASSWORD)" 
echo ""
echo "1. Bucket kyc-documents (PRIVE) :" 
echo "   -> Buckets -> Create Bucket" 
echo "   -> Bucket Name : kyc-documents"   
echo "   -> Versioning : ON" 
echo "   -> Object Locking : OFF" 
echo "   -> Create Bucket" 
echo "   -> Cliquer sur kyc-documents -> Access Policy -> PRIVATE" 
echo ""
echo "2. Bucket avatars (LECTURE PUBLIQUE) :" 
echo "   -> Create Bucket : avatars" 
echo "   -> Access Policy -> PUBLIC (download only)" 
echo ""
echo "3. Bucket ebillets (PRIVE) :" 
echo "   -> Create Bucket : ebillets" 
echo "   -> Access Policy -> PRIVATE" 
echo ""
echo "4. Créer un utilisateur de service pour l'API Spring Boot :" 
echo "   -> Identity -> Users -> Create User" 
echo "   -> Username : adv-api-service" 
echo "   -> Attach policy : readwrite" 
echo "   -> Copier Access Key et Secret Key generees" 
echo "   -> Charger dans Vault :" 
echo "      docker exec adv-vault vault kv put secret/adv/minio " 
echo "        access_key=ADV_ACCESS_KEY_ICI " 
echo "        secret_key=ADV_SECRET_KEY_ICI " 
echo "        endpoint=http://minio:9000" 
echo ""
echo "Note sur le chiffrement at-rest :" 
echo "  MinIO Community Edition ne supporte pas le chiffrement at-rest natif." 
echo "  Solution pour le MVP : chiffrer les fichiers AVANT upload (côté Spring Boot)." 
echo "  Utiliser AES-256 via javax.crypto avant d'envoyer à MinIO." 
echo "  En prod : utiliser MinIO KES (Key Encryption Service) ou S3 AWS avec SSE." 