Write-Host "📂 Chargement des variables d'environnement..." -ForegroundColor Cyan

# 1. Localisation du fichier .env (on cherche dans ../infra ou ./infra)
$envPath = if (Test-Path "..\infra\.env") { "..\infra\.env" } else { ".\infra\.env" }

if (-not (Test-Path $envPath)) {
    Write-Host ("Fichier .env introuvable à l’emplacement " + $envPath) -ForegroundColor Red
    exit 1
}

# 2. Lecture et injection des variables dans la session actuelle
$envVars = Get-Content $envPath | ConvertFrom-StringData
foreach ($key in $envVars.Keys) {
    [System.Environment]::SetEnvironmentVariable($key, $envVars[$key])
    if ($key -like "VAULT*") { Write-Host "   -> Variable $key injectée" -ForegroundColor Gray }
}

# 3. Lancement de Maven
Write-Host ('Lancement de Spring Boot (Profil: dev)...') -ForegroundColor Green
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev