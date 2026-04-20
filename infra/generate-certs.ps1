$certsDir = ".\nginx\certs"

$possiblePaths = @(
    "C:\Program Files\Git\usr\bin\openssl.exe",
    "C:\Program Files\Git\mingw64\bin\openssl.exe",
    "C:\Program Files\Git\bin\openssl.exe"
)

$openssl = $possiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $openssl) {
    Write-Host '❌ OpenSSL introuvable.' -ForegroundColor Red
    exit 1
}

if (-Not (Test-Path $certsDir)) {
    New-Item -ItemType Directory -Path $certsDir | Out-Null
}

Write-Host "Generation du certificat TLS auto-signe..." -ForegroundColor Cyan

& $openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
    -keyout (Join-Path $certsDir "dev.key") `
    -out    (Join-Path $certsDir "dev.crt") `
    -subj "/CN=localhost" `
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Certificat genere :" -ForegroundColor Green
    Write-Host ("  " + (Join-Path $certsDir "dev.crt")) -ForegroundColor Green
    Write-Host ("  " + (Join-Path $certsDir "dev.key")) -ForegroundColor Green
} else {
    Write-Host '❌ Erreur lors de la generation.' -ForegroundColor Red
}