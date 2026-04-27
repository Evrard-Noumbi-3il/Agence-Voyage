# ADV Platform — Agence de Voyages
ADV Platform est une solution logicielle industrielle de réservation de billets de bus en temps réel, conçue pour moderniser l'expérience de voyage.


# Points Forts du Projet
  - Temps Réel : Verrouillage distribué des sièges via Redis pour éviter le surbooking.

  - Security by Design : Authentification OAuth2/OIDC avec Keycloak, gestion des secrets via HashiCorp Vault.

  - Pipeline DevSecOps : Analyse automatisée du code (Sonar), des dépendances (Snyk) et des conteneurs (Trivy).

  - Infrastructure as Code : Pile complète virtualisée sous Docker incluant monitoring et stockage objet (MinIO).

# Stack Technique
### Backend (API REST)
 - Core : Java 21 LTS / Spring Boot 3.4.2

 - Data : PostgreSQL 16 (Persistance), Redis 7 (Cache/Locks), Flyway (Migrations)

 - Tests : JUnit 5, Mockito, Newman (Postman)

### Mobile (Frontend)
 - Framework : React Native CLI 0.74+

 - Auth : AppAuth-JS (OIDC / JWT)

### Infrastructure & SecOps
  - Orchestration : Docker Compose (9 services)

  - Observabilité : Prometheus & Grafana

  - CI/CD : GitHub Actions (Build, Test, Scan, Push to GHCR.io)

# Organisation du Dépôt
```bash
├── .github/          # Workflows CI/CD (Automation)
├── backend/          # Micro-service Spring Boot (Logiciel)
├── mobile/           # Application Mobile (Interface)
├── infra/            # Infrastructure (Docker Compose, Monitoring, Vault)
├── docs/             # Documentation complète
│   ├── api/          # Collections Postman & Environnements
│   ├── architecture/ # Diagrammes C4 & Schémas réseau
│   ├── conception/   # CDC, User Stories & Schéma DB
│   └── securite/     # Rapports Snyk/Trivy & Registre de risques
└── README.md         # Ce document
```
# Installation & Lancement Rapide
### 1. Cloner et configurer l'infrastructure
```bash
git clone https://github.com/Evrard-Noumbi-3il/Agence-Voyage.git
cd Agence-Voyage/infra
cp .env.example .env
docker compose up -d
# Depuis la racine du projet
./infra/minio/init-minio.sh
./infra/vault/config/init-vault.sh
```
### 2. Démarrer le Backend
```bash
cd ../backend
./mvnw spring-boot:run
```
### 3. Démarrer le Mobile
```bash
cd ../mobile
npm install && npx react-native run-android
```

# Gouvernance Sécurité
Le projet suit une démarche de Shift-Left Security. Chaque modification de code subit les tests suivants :

1. Linter : Respect du Google Java Style (Checkstyle).

2. SCA (Snyk) : Vérification des CVE dans les librairies tierces.

3. SAST (SonarCloud) : Analyse de la qualité et des failles logiques.

4. Container Scan (Trivy) : Analyse de l'image Docker finale.

# Stratégie de tests
### Structure des packages de test (backend)
 backend/src/test/java/com/gev/
 ```bash
  modules/
    iam/
      KeycloakIntegrationTest.java     ← TestContainers
    booking/
      SeatLockServiceTest.java         ← JUnit + Mockito
      BookingServiceTest.java          ← JUnit + Mockito
    payment/
      PaymentServiceTest.java          ← WireMock (mock PayUnit)
      PaymentIntegrationTest.java      ← TestContainers
  common/
    BaseIntegrationTest.java           ← Classe mère avec TestContainers
```
Configuration WireMock (mock PayUnit)
```bash
{
  java// src/test/resources/wiremock/mappings/payunit-success.json
  {
    "request": { "method": "POST", "url": "/api/payments" },
    "response": {
      "status": 200,
      "jsonBody": { "status": "SUCCES", "reference": "PAY-TEST-001" }
  }
}
```
# Documentation de Référence
docs/conception/README.md

docs/architecture/README.md

docs/securite/README.md