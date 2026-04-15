#!/bin/bash
# =============================================================================
# init_project.sh
# Projet : General Express Voyages — Plateforme de réservation
# Auteur  : Evrard NOUMBI — Avril 2026
# Usage   : bash init_project.sh
# =============================================================================

set -e  # Arrête le script si une commande échoue

PROJECT_NAME="Agence-Voyage"
echo "Initialisation du projet $PROJECT_NAME..."

# 1. Création de la racine
# mkdir -p "$PROJECT_NAME" && cd "$PROJECT_NAME"

# =============================================================================
# INFRA — Docker Compose + configs des 9 services
# =============================================================================
mkdir -p infra/keycloak/config        # realm-export.json, themes
mkdir -p infra/vault/config           # vault.hcl, policies/
mkdir -p infra/vault/policies         # backend-policy.hcl
mkdir -p infra/nginx/certs            # certificats TLS (gitignorés)
mkdir -p infra/nginx/conf.d           # fichiers de config par domaine
mkdir -p infra/postgres/init          # scripts SQL d'init si besoin
mkdir -p infra/redis                  # redis.conf (AOF activé)
mkdir -p infra/minio                  # config bucket
mkdir -p infra/monitoring/prometheus  # prometheus.yml, alert rules
mkdir -p infra/monitoring/grafana/dashboards  # JSON dashboards
mkdir -p infra/monitoring/alertmanager        # alertmanager.yml

# Fichiers de config principaux
touch infra/docker-compose.yml
touch infra/docker-compose.staging.yml
touch infra/.env.example              # TOUTES les variables, sans valeurs
touch infra/nginx/nginx.conf
touch infra/nginx/conf.d/api.conf
touch infra/redis/redis.conf
touch infra/vault/config/vault.hcl
touch infra/vault/policies/backend-policy.hcl
touch infra/monitoring/prometheus/prometheus.yml
touch infra/monitoring/prometheus/alert.rules.yml
touch infra/monitoring/alertmanager/alertmanager.yml

# =============================================================================
# BACKEND — Spring Boot 3 (structure Maven modulaire)
# =============================================================================
BASE="backend/src/main/java/com/gev"

# Modules métier (un dossier = un module Spring)
mkdir -p "$BASE/modules/iam"          # auth, KYC, rôles, profil
mkdir -p "$BASE/modules/travel"       # trajets, voyages, escales
mkdir -p "$BASE/modules/booking"      # réservations, billets, sièges, verrous Redis
mkdir -p "$BASE/modules/payment"      # paiements PayUnit, idempotence, webhooks
mkdir -p "$BASE/modules/notification" # push FCM, email, rappels
mkdir -p "$BASE/modules/fleet"        # véhicules, chauffeurs, maintenance
mkdir -p "$BASE/modules/logistics"    # colis, locations
mkdir -p "$BASE/modules/admin"        # back-office, stats, tableau de bord

# Infrastructure transverse
mkdir -p "$BASE/config"               # SecurityConfig, RedisConfig, VaultConfig, etc.
mkdir -p "$BASE/common/exception"     # GlobalExceptionHandler, exceptions métier
mkdir -p "$BASE/common/dto"           # DTOs partagés (ApiResponse, PageResponse, etc.)
mkdir -p "$BASE/common/audit"         # AuditLog entity + listener JPA

# Tests
mkdir -p backend/src/test/java/com/gev/modules/iam
mkdir -p backend/src/test/java/com/gev/modules/booking
mkdir -p backend/src/test/java/com/gev/modules/payment
mkdir -p backend/src/test/resources/wiremock  # stubs WireMock pour PayUnit

# Ressources
mkdir -p backend/src/main/resources/db/migration
mkdir -p backend/src/main/resources/templates  # templates email (Thymeleaf)

# Fichiers de config Spring Boot
touch backend/src/main/resources/application.yml
touch backend/src/main/resources/application-dev.yml
touch backend/src/main/resources/application-staging.yml

# Migrations Flyway (noms EXACTS — respecter la casse)
touch backend/src/main/resources/db/migration/V1__init_schema.sql
touch backend/src/main/resources/db/migration/V2__add_indexes.sql
touch backend/src/main/resources/db/migration/V3__seed_data.sql

touch backend/pom.xml
touch backend/.env.example            # variables backend (pointe vers Vault en prod)
touch backend/Dockerfile

# =============================================================================
# MOBILE — React Native CLI
# =============================================================================
mkdir -p mobile/src/api               # clients RTK Query par domaine
mkdir -p mobile/src/assets/images
mkdir -p mobile/src/assets/fonts
mkdir -p mobile/src/components/common # composants réutilisables (Button, Input, etc.)
mkdir -p mobile/src/components/seats  # plan de sièges SVG
mkdir -p mobile/src/features/auth     # écrans : Login, Register, KYC
mkdir -p mobile/src/features/search   # écrans : Recherche, Résultats, Détail trajet
mkdir -p mobile/src/features/booking  # écrans : Plan sièges, Confirmation
mkdir -p mobile/src/features/payment  # écrans : Choix méthode, Attente MoMo, Résultat
mkdir -p mobile/src/features/tickets  # écrans : Mes billets, QR Code
mkdir -p mobile/src/features/profile  # écrans : Profil, Paramètres
mkdir -p mobile/src/navigation        # Stack, Tab navigators
mkdir -p mobile/src/store             # Redux store, slices, RTK Query
mkdir -p mobile/src/theme             # couleurs, typographie, espacements
mkdir -p mobile/src/utils             # helpers, formatters, validators
mkdir -p mobile/__tests__             # tests Jest

touch mobile/.env.example
touch mobile/Dockerfile               # pour build CI de l'APK

# =============================================================================
# CI/CD — GitHub Actions
# =============================================================================
mkdir -p .github/workflows
mkdir -p .github/ISSUE_TEMPLATE       # templates d'issues pour les US

touch .github/workflows/ci-backend.yml    # lint + tests + SAST + SCA + build + Docker + Trivy
touch .github/workflows/ci-mobile.yml     # lint + tests + build APK
touch .github/workflows/cd-staging.yml   # déploiement staging (manuel)

# =============================================================================
# DOCS — livrables et documentation
# =============================================================================
mkdir -p docs/conception              # CDC, User Stories, schéma DB
mkdir -p docs/architecture            # diagrammes C4, séquences
mkdir -p docs/securite                # rapports Snyk, SonarQube, ZAP
mkdir -p docs/api                     # exports Postman, specs OpenAPI
mkdir -p docs/maquettes               # exports Figma (PNG)

# Copier les fichiers Flyway déjà générés si présents
# cp /chemin/vers/V1__init_schema.sql backend/src/main/resources/db/migration/
# cp /chemin/vers/V2__add_indexes.sql backend/src/main/resources/db/migration/
# cp /chemin/vers/V3__seed_data.sql   backend/src/main/resources/db/migration/

# =============================================================================
# FICHIERS RACINE
# =============================================================================
touch README.md
touch .gitignore
touch .env.example                    # variables globales du monorepo

# =============================================================================
# .gitignore — complet pour ce projet
# =============================================================================
cat > .gitignore << 'EOF'
# Secrets — jamais dans Git
.env
*.env
!.env.example
infra/nginx/certs/
infra/vault/data/

# Java / Maven
backend/target/
backend/*.class
*.jar
*.war

# React Native
mobile/node_modules/
mobile/.expo/
mobile/android/app/build/
mobile/ios/build/
mobile/ios/Pods/
mobile/*.keystore
mobile/android/local.properties

# IDE
.idea/
*.iml
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Docker volumes locaux
infra/postgres/data/
infra/redis/data/
infra/minio/data/
infra/vault/data/
EOF

# =============================================================================
# README racine
# =============================================================================
cat > README.md << 'EOF'
# GEV Platform — General Express Voyages

Plateforme de réservation de billets de bus en temps réel.
Projet de fin d'études — Full-Stack & DevSecOps — Evrard NOUMBI — 2026

## Prérequis
- Docker Desktop 24+
- Java 21 (JDK)
- Node.js 20 LTS
- React Native CLI

## Lancement rapide (environnement dev)
```bash
cd infra
cp .env.example .env       # remplir les valeurs
docker compose up -d       # démarre les 9 services
cd ../backend
mvn spring-boot:run        # démarre l'API (migrations Flyway auto)
cd ../mobile
npm install && npx react-native start
```

## Structure
- `infra/`    — Docker Compose, configs Nginx/Keycloak/Vault/Redis/MinIO/Monitoring
- `backend/`  — API Spring Boot 3 (Java 21)
- `mobile/`   — Application React Native CLI
- `docs/`     — CDC, User Stories, schéma DB, rapports sécurité
- `.github/`  — Pipelines CI/CD GitHub Actions

## Documentation
Voir `docs/conception/` pour le CDC complet et les User Stories.
EOF

echo ""
echo "Structure $PROJECT_NAME créée avec succès."
echo ""
echo "Prochaines étapes :"
echo "  1. cd $PROJECT_NAME/backend  → spring initializr ou mvn archetype"
echo "  2. cd $PROJECT_NAME/mobile   → npx react-native init GevMobile --directory ."
echo "  3. Copier V1/V2/V3 SQL dans backend/src/main/resources/db/migration/"
echo "  4. Remplir infra/.env.example avec les noms de variables réels"
echo "  5. git init && git add . && git commit -m 'chore: init project structure'"
echo ""
echo "Arborescence finale :"
find . -type d | sort | head -60
