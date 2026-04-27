# =============================================================================
# Initialisation Vault ADV via CLI dans le conteneur Docker (PowerShell)
# =============================================================================

$ErrorActionPreference = "Stop"

# =============================================================================
# CONFIGURATION
# =============================================================================
$VAULT_CONTAINER_NAME = "adv-vault"
$ENV_PATH = "./.env"

# =============================================================================
# Fonction pour exécuter vault dans le conteneur
# =============================================================================
function Invoke-Vault {
    param(
        [string[]]$CommandArgs,
        [string]$InputText
    )

    # On définit l'adresse ici
    $addr = "http://127.0.0.1:8200"
    
    # Boucle d'attente simplifiée
    $ready = $false
    for ($i=1; $i -le 5; $i++) {
        # On teste le status directement
        docker exec $VAULT_CONTAINER_NAME vault status -address=$addr > $null 2>&1
        if ($LASTEXITCODE -ne $null -and ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 2)) {
            $ready = $true
            break
        }
        Start-Sleep -Seconds 2
    }

    # Exécution de la commande
    if ($InputText) {
        $InputText | docker exec -i `
            -e VAULT_TOKEN=$env:VAULT_TOKEN_VAL `
            -e VAULT_ADDR=$addr `
            $VAULT_CONTAINER_NAME vault @CommandArgs
    } else {
        docker exec -i `
            -e VAULT_TOKEN=$env:VAULT_TOKEN_VAL `
            -e VAULT_ADDR=$addr `
            $VAULT_CONTAINER_NAME vault @CommandArgs
    }
}

# =============================================================================
# CHARGEMENT DU TOKEN ROOT
# =============================================================================
if (Test-Path $ENV_PATH) {
    $envContent = Get-Content $ENV_PATH

    $VAULT_TOKEN_VAL = ($envContent | Where-Object { $_ -match "^VAULT_ROOT_TOKEN=" }) `
        -replace "^VAULT_ROOT_TOKEN=", "" `
        -replace "`r", "" `
        | ForEach-Object { $_.Trim() }

    $env:VAULT_TOKEN_VAL = $VAULT_TOKEN_VAL
} else {
    Write-Host "Erreur : Fichier $ENV_PATH introuvable."
    exit 1
}

if (-not $VAULT_TOKEN_VAL) {
    Write-Host "Erreur : VAULT_ROOT_TOKEN est vide dans le fichier .env."
    exit 1
}

Write-Host "=== Initialisation Vault ADV entamee ==="

# =============================================================================
# 1. Moteur KV v2
# =============================================================================
Write-Host "[1/6] Activation moteur KV v2..."
try {
    Invoke-Vault secrets enable -path=secret kv-v2 2>$null
} catch {
    Write-Host " → KV v2 deja active"
}

# =============================================================================
# 2. Audit log
# =============================================================================
Write-Host "[2/6] Activation audit log..."
try {
    Invoke-Vault audit enable file file_path=/vault/data/audit.log 2>$null
} catch {
    Write-Host " → Audit log deja active"
}

# =============================================================================
# 3. AppRole
# =============================================================================
Write-Host "[3/6] Activation AppRole..."
try {
    Invoke-Vault auth enable approle 2>$null
} catch {
    Write-Host " → AppRole deja active"
}

# =============================================================================
# 4. Policy Backend
# =============================================================================
Write-Host "[4/6] Creation policy 'adv-backend'..."

$policy = @"
path "secret/data/adv/*" { capabilities = ["read"] }
path "secret/metadata/adv" { capabilities = ["list"] }
path "auth/token/renew" { capabilities = ["update"] }
path "auth/token/lookup-self" { capabilities = ["read"] }
"@

# Correction ici : on passe les arguments explicitement
Invoke-Vault -CommandArgs @("policy", "write", "adv-backend", "-") -InputText $policy

# =============================================================================
# 5. Configuration AppRole
# =============================================================================
Write-Host "[5/6] Configuration AppRole..."
$addr = "http://127.0.0.1:8200"

Invoke-Vault -CommandArgs @("write", "auth/approle/role/adv-backend", "token_policies=adv-backend", "token_ttl=1h", "token_max_ttl=4h", "secret_id_ttl=0")

# Utilisation de guillemets doubles pour forcer l'évaluation de la variable $addr
$ROLE_ID_JSON = docker exec -i -e VAULT_TOKEN=$env:VAULT_TOKEN_VAL -e VAULT_ADDR=$addr $VAULT_CONTAINER_NAME vault read -format=json auth/approle/role/adv-backend/role-id
$ROLE_ID = ($ROLE_ID_JSON | ConvertFrom-Json).data.role_id

$SECRET_ID_JSON = docker exec -i -e VAULT_TOKEN=$env:VAULT_TOKEN_VAL -e VAULT_ADDR=$addr $VAULT_CONTAINER_NAME vault write -f -format=json auth/approle/role/adv-backend/secret-id
$SECRET_ID = ($SECRET_ID_JSON | ConvertFrom-Json).data.secret_id

# =============================================================================
# 6. Injection des secrets
# =============================================================================
Write-Host "[6/6] Injection des secrets..."

# =============================================================================
# CHARGEMENT DES VALEURS POUR LES SECRETS
# =============================================================================
function Get-EnvValue($key) {
    return ($envContent | Where-Object { $_ -match "^$key=" }) -replace "^$key=", "" -replace "`r", "" | ForEach-Object { $_.Trim() }
}

$DB_NAME     = Get-EnvValue "DB_NAME"
$DB_USER     = Get-EnvValue "DB_USER"
$DB_PASS     = Get-EnvValue "DB_PASSWORD"
$REDIS_PASS  = Get-EnvValue "REDIS_PASSWORD"
$MINIO_USER  = Get-EnvValue "MINIO_ROOT_USER"
$MINIO_PASS  = Get-EnvValue "MINIO_ROOT_PASSWORD"
$QR_SECRET   = Get-EnvValue "QR_HMAC_SECRET"

# On construit les arguments pour éviter les soucis de guillemets
$kvArgs = @(
    "kv", "put", "secret/adv",
    "database.password=$DB_PASS",
    "database.user=$DB_USER",
    "database.name=$DB_NAME",
    "redis.password=$REDIS_PASS",
    "minio.access_key=$MINIO_USER",
    "minio.secret_key=$MINIO_PASS",
    "security.qr_hmac_secret=$QR_SECRET"
)

Invoke-Vault -CommandArgs $kvArgs

Write-Host ""
Write-Host "=== Initialisation terminee avec succes ==="
Write-Host ""
Write-Host "  VAULT_ROLE_ID=$ROLE_ID"
Write-Host "  VAULT_SECRET_ID=$SECRET_ID"
Write-Host ""
Write-Host "Le fichier .env a ete mis a jour."
Write-Host "Interface : http://localhost:8200"

# =============================================================================
# Instructions manuelles
# =============================================================================
Write-Host ""
Write-Host "Secrets a charger manuellement :"
Write-Host ""
Write-Host "Invoke-Vault kv put secret/adv/keycloak client_secret=VOTRE_CLIENT_SECRET_KEYCLOAK"
Write-Host ""
Write-Host "Invoke-Vault kv put secret/adv/payunit api_key=VOTRE_CLE_API_PAYUNIT hmac_secret=VOTRE_SECRET_HMAC_WEBHOOK"
Write-Host ""
Write-Host "Invoke-Vault kv put secret/adv/notifications smtp_password=VOTRE_MOT_DE_PASSE_SMTP firebase_sa_json=`$(Get-Content chemin/vers/firebase-sa.json -Raw)"
Write-Host ""
Write-Host "=== Initialisation Vault terminee ==="