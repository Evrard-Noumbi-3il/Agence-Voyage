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
