Write-Host "=== ADV Platform - Demarrage infrastructure ===" -ForegroundColor Cyan
Write-Host ""

# 1. Vérifier que .env existe
if (-Not (Test-Path ".\.env")) {
    Write-Host "[ERREUR] Fichier .env introuvable." -ForegroundColor Red
    Write-Host "         Copier .env.example en .env et remplir les valeurs." -ForegroundColor Yellow
    exit 1
}

# 2. Vérifier que les certificats TLS existent
if (-Not (Test-Path ".\nginx\certs\dev.crt")) {
    Write-Host "[INFO] Certificats TLS absents. Generation en cours..." -ForegroundColor Yellow
    .\generate-certs.ps1
}

# 3. Démarrer les services dans l'ordre
Write-Host "[1/3] Demarrage des services de base (PostgreSQL, Redis, Vault)..." -ForegroundColor White
docker compose --env-file .env up -d postgres redis vault
Start-Sleep -Seconds 15

Write-Host "[2/3] Demarrage Keycloak et MinIO..." -ForegroundColor White
docker compose --env-file .env up -d keycloak minio
Start-Sleep -Seconds 30

Write-Host "[3/3] Demarrage Nginx, Monitoring et Backend..." -ForegroundColor White
docker compose --env-file .env up -d prometheus grafana alertmanager nginx

Write-Host ""
Write-Host "=== Verification des services ===" -ForegroundColor Cyan

# 4. Attendre et vérifier
Start-Sleep -Seconds 20

$services = @("bd-postgres", "adv-redis", "adv-vault", "adv-keycloak", "adv-minio", "adv-nginx", "adv-prometheus", "adv-grafana", "adv-alertmanager")

foreach ($service in $services) {
    $status = docker inspect --format='{{.State.Health.Status}}' $service 2>$null
    if ($status -eq "healthy") {
        Write-Host "  [OK] $service" -ForegroundColor Green
    } elseif ($status -eq "starting") {
        Write-Host "  [..] $service (en cours de demarrage)" -ForegroundColor Yellow
    } else {
        Write-Host "  [KO] $service - statut: $status" -ForegroundColor Red
        Write-Host "       Voir les logs : docker logs $service" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== Acces aux services ===" -ForegroundColor Cyan
Write-Host "  API Backend     : https://localhost/api/" -ForegroundColor White
Write-Host "  Keycloak Admin  : http://localhost:8081 (admin / voir .env)" -ForegroundColor White
Write-Host "  Grafana         : http://localhost:3000 (admin / voir .env)" -ForegroundColor White
Write-Host "  MinIO Console   : http://localhost:9001" -ForegroundColor White
Write-Host "  Vault UI        : http://localhost:8200" -ForegroundColor White
Write-Host "  Prometheus      : (interne - pas d'exposition directe)" -ForegroundColor Gray
Write-Host ""
Write-Host "Pour voir tous les logs : docker compose logs -f" -ForegroundColor Gray
Write-Host "Pour arreter : docker compose down" -ForegroundColor Gray