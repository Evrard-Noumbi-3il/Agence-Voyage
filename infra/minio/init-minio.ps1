# =============================================================================
# Initialisation MinIO ADV via Docker MC (PowerShell)
# =============================================================================

$ErrorActionPreference = "Stop"

# =============================================================================
# Chargement du .env
# =============================================================================
$ENV_PATH = "./.env"

if (Test-Path $ENV_PATH) {
    $envContent = Get-Content $ENV_PATH

    function Get-EnvValue($key) {
        ($envContent | Where-Object { $_ -match "^$key=" }) `
            -replace "^$key=", "" `
            -replace "`r", "" `
            | ForEach-Object { $_.Trim() }
    }

    $MINIO_USER = Get-EnvValue "MINIO_ROOT_USER"
    $MINIO_PASS = Get-EnvValue "MINIO_ROOT_PASSWORD"
} else {
    Write-Host "Fichier ./.env introuvable."
    exit 1
}

$MINIO_URL = "http://localhost:9000"

Write-Host "=== Initialisation MinIO ADV via Docker MC ==="

# =============================================================================
# Fonction mc via Docker
# =============================================================================
function Invoke-McDocker {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )

    docker run --rm --network infra_backend-net `
        -e "MC_HOST_adv=http://${MINIO_USER}:${MINIO_PASS}@minio:9000" `
        minio/mc:latest `
        @Args
}

# ─────────────────────────────────────────────────────────────────────────────
# 1. Bucket KYC (privé)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "[1/3] Creation bucket kyc-documents..."
Invoke-McDocker mb adv/kyc-documents --ignore-existing
Invoke-McDocker anonymous set none adv/kyc-documents
Write-Host " → Bucket kyc-documents cree (acces prive)"

# ─────────────────────────────────────────────────────────────────────────────
# 2. Bucket Avatars (public read)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "[2/3] Creation bucket avatars..."
Invoke-McDocker mb adv/avatars --ignore-existing
Invoke-McDocker anonymous set download adv/avatars
Write-Host " → Bucket avatars cree (lecture publique)"

# ─────────────────────────────────────────────────────────────────────────────
# 3. Bucket E-billets (privé)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "[3/3] Creation bucket ebillets..."
Invoke-McDocker mb adv/ebillets --ignore-existing
Invoke-McDocker anonymous set none adv/ebillets
Write-Host " → Bucket ebillets cree (acces prive)"

Write-Host ""
Write-Host "=== Buckets MinIO configures ==="
Invoke-McDocker ls adv
Write-Host ""

Write-Host "Console MinIO : http://localhost:9001"
Write-Host "User : $MINIO_USER"
Write-Host "Pass : (voir .env)"

# =============================================================================
# Instructions manuelles
# =============================================================================
Write-Host ""
Write-Host "ETAPES MANUELLES dans la console MinIO (http://localhost:9001) :"
Write-Host ""
Write-Host "Connexion : $MINIO_USER / (voir .env MINIO_ROOT_PASSWORD)"
Write-Host ""

Write-Host "1. Bucket kyc-documents (PRIVE) :"
Write-Host "   -> Buckets -> Create Bucket"
Write-Host "   -> Bucket Name : kyc-documents"
Write-Host "   -> Versioning : ON"
Write-Host "   -> Object Locking : OFF"
Write-Host "   -> Create Bucket"
Write-Host "   -> Access Policy -> PRIVATE"
Write-Host ""

Write-Host "2. Bucket avatars (LECTURE PUBLIQUE) :"
Write-Host "   -> Create Bucket : avatars"
Write-Host "   -> Access Policy -> PUBLIC (download only)"
Write-Host ""

Write-Host "3. Bucket ebillets (PRIVE) :"
Write-Host "   -> Create Bucket : ebillets"
Write-Host "   -> Access Policy -> PRIVATE"
Write-Host ""

Write-Host "4. Créer un utilisateur de service :"
Write-Host "   -> Identity -> Users -> Create User"
Write-Host "   -> Username : adv-api-service"
Write-Host "   -> Policy : readwrite"
Write-Host "   -> Copier Access Key / Secret Key"
Write-Host "   -> Charger dans Vault :"
Write-Host "      docker exec adv-vault vault kv put secret/adv/minio "
Write-Host "        access_key=ADV_ACCESS_KEY_ICI "
Write-Host "        secret_key=ADV_SECRET_KEY_ICI "
Write-Host "        endpoint=http://minio:9000"
Write-Host ""

Write-Host "Note chiffrement :"
Write-Host "MinIO CE ne supporte pas le chiffrement at-rest natif."
Write-Host "Solution MVP : chiffrer côté application (AES-256)."
Write-Host "Production : utiliser MinIO KES ou AWS S3 SSE."
Write-Host ""
Write-Host "=== Initialisation MinIO terminee ==="
Write-Host ""