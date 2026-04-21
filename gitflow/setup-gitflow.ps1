# =============================================================================
# gitflow/setup-gitflow.ps1
# Initialisation GitFlow et configuration Git pour GEV
# Usage : cd gev-platform && .\gitflow\setup-gitflow.ps1
# =============================================================================

Write-Host "=== Setup GitFlow GEV ===" -ForegroundColor Cyan
Write-Host ""

# ─────────────────────────────────────────────────────────────────────────────
# 1. Vérifications préalables
# ─────────────────────────────────────────────────────────────────────────────
if (-not (Test-Path ".git")) {
    Write-Host "[ERREUR] Ce dossier n'est pas un repo Git." -ForegroundColor Red
    Write-Host "         Lancer d'abord : git init && git remote add origin URL" -ForegroundColor Yellow
    exit 1
}

# ─────────────────────────────────────────────────────────────────────────────
# 2. Configuration Git locale
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "[1/5] Configuration Git..." -ForegroundColor Yellow

git config core.autocrlf false          # Éviter les problèmes CRLF Windows/Linux
git config core.eol lf                  # Forcer LF pour Docker
git config pull.rebase false            # Merge par défaut sur pull
git config push.default current         # Push sur la branche courante

Write-Host "  -> Git configure" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────────────────────
# 3. Créer les branches GitFlow
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "[2/5] Creation branches GitFlow..." -ForegroundColor Yellow

# Commit initial si vide
$hasCommits = git log --oneline -1 2>$null
if (-not $hasCommits) {
    git add .
    git commit -m "chore: init project structure" --allow-empty
    Write-Host "  -> Commit initial cree" -ForegroundColor Green
}

# Créer develop depuis main
$branches = git branch --list "develop"
if (-not $branches) {
    git checkout -b develop
    git checkout main
    Write-Host "  -> Branche develop creee" -ForegroundColor Green
} else {
    Write-Host "  -> Branche develop deja existante" -ForegroundColor Gray
}

# ─────────────────────────────────────────────────────────────────────────────
# 4. Créer le hook commit-msg (validation convention de commit)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "[3/5] Installation hook commit-msg..." -ForegroundColor Yellow

$hookContent = @'
#!/bin/sh
# Hook Git — Validation convention de commit GEV
# Format attendu : <type>(<scope>?): <description>
# Types valides : feat, fix, sec, docs, test, chore, refactor, perf, ci

commit_msg=$(cat "$1")
pattern="^(feat|fix|sec|docs|test|chore|refactor|perf|ci)(\([a-z0-9-]+\))?: .{3,72}$"

if ! echo "$commit_msg" | grep -qE "$pattern"; then
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║  COMMIT REJETÉ — Convention non respectée            ║"
    echo "╠══════════════════════════════════════════════════════╣"
    echo "║  Format attendu : <type>: <description>              ║"
    echo "║                                                      ║"
    echo "║  Types valides :                                     ║"
    echo "║    feat     Nouvelle fonctionnalité                  ║"
    echo "║    fix      Correction de bug                        ║"
    echo "║    sec      Correctif sécurité                       ║"
    echo "║    docs     Documentation                            ║"
    echo "║    test     Ajout/modification de tests              ║"
    echo "║    chore    Tâche technique (CI, config, deps)       ║"
    echo "║    refactor Refactoring sans changement fonctionnel  ║"
    echo "║    perf     Optimisation performance                 ║"
    echo "║    ci       Pipeline CI/CD                           ║"
    echo "║                                                      ║"
    echo "║  Exemples :                                          ║"
    echo "║    feat(booking): add seat locking with Redis        ║"
    echo "║    fix(payment): handle PayUnit timeout              ║"
    echo "║    sec(kyc): validate document expiration            ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""
    echo "  Votre message : $commit_msg"
    echo ""
    exit 1
fi
'@

$hookPath = ".git/hooks/commit-msg"
$hookContent | Set-Content $hookPath -Encoding UTF8

# Rendre exécutable (nécessaire pour WSL2/Git Bash)
if (Get-Command "chmod" -ErrorAction SilentlyContinue) {
    chmod +x $hookPath
}

Write-Host "  -> Hook commit-msg installe" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────────────────────
# 5. Créer le hook pre-push (bloquer push direct sur main)
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "[4/5] Installation hook pre-push (protection main)..." -ForegroundColor Yellow

$prePushContent = @'
#!/bin/sh
# Hook Git — Bloquer les push directs sur main et develop
# Les merges sur main/develop doivent passer par PR GitHub

protected_branch="main"
current_branch=$(git rev-parse --abbrev-ref HEAD)

if [ "$current_branch" = "$protected_branch" ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║  PUSH BLOQUÉ — Branche protégée                     ║"
    echo "║                                                      ║"
    echo "║  Les commits sur 'main' se font uniquement via PR.  ║"
    echo "║  Créer une branche : git checkout -b feature/...    ║"
    echo "╚══════════════════════════════════════════════════════╝"
    exit 1
fi
'@

$prePushPath = ".git/hooks/pre-push"
$prePushContent | Set-Content $prePushPath -Encoding UTF8

if (Get-Command "chmod" -ErrorAction SilentlyContinue) {
    chmod +x $prePushPath
}

Write-Host "  -> Hook pre-push installe" -ForegroundColor Green

# ─────────────────────────────────────────────────────────────────────────────
# 6. Créer le .gitattributes
# ─────────────────────────────────────────────────────────────────────────────
Write-Host "[5/5] Creation .gitattributes..." -ForegroundColor Yellow

@"
# .gitattributes — General Express Voyages
# Forcer LF pour tous les fichiers texte (Windows → Linux Docker)
* text=auto eol=lf

# Fichiers binaires — pas de conversion
*.png binary
*.jpg binary
*.jpeg binary
*.pdf binary
*.jar binary
*.keystore binary
*.p12 binary

# Scripts Shell — toujours LF
*.sh text eol=lf
*.ps1 text eol=crlf

# Fichiers SQL — LF
*.sql text eol=lf

# YAML — LF
*.yml text eol=lf
*.yaml text eol=lf
"@ | Set-Content ".gitattributes" -Encoding UTF8

Write-Host "  -> .gitattributes cree" -ForegroundColor Green

Write-Host ""
Write-Host "=== GitFlow configure ===" -ForegroundColor Green
Write-Host ""
Write-Host "Branches disponibles :" -ForegroundColor Cyan
git branch --list
Write-Host ""
Write-Host "Workflow à suivre :" -ForegroundColor Cyan
Write-Host "  git checkout develop" -ForegroundColor White
Write-Host "  git checkout -b feature/US-7-seat-selection" -ForegroundColor White
Write-Host "  # ... coder ..." -ForegroundColor Gray
Write-Host "  git add . && git commit -m 'feat(booking): add interactive seat plan'" -ForegroundColor White
Write-Host "  git push origin feature/US-7-seat-selection" -ForegroundColor White
Write-Host "  # Créer une PR vers develop sur GitHub" -ForegroundColor Gray