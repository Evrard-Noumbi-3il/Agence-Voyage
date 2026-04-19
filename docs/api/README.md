# docs/api/README.md
# Dossier : Documentation API

Ce dossier contient les collections Postman et les specs OpenAPI.

## Fichiers attendus

| Fichier | Description | Généré par |
|---------|-------------|-----------|
| GEV_API.postman_collection.json | Collection Postman complète (tous les endpoints) | Postman |
| GEV_API.postman_environment.json | Variables d'environnement Postman (dev / staging) | Postman |
| openapi.yml | Spec OpenAPI 3.0 auto-générée | Spring Boot (Swagger) |

## Accès Swagger en dev

Une fois le backend démarré :
http://localhost:8080/swagger-ui/index.html

## Organisation de la collection Postman

La collection doit être organisée en dossiers par épopée :

```
GEV API
├── 01 - Auth (IAM)
│   ├── Login (obtenir JWT)
│   ├── Refresh token
│   ├── Soumettre KYC
│   └── Valider KYC (admin)
├── 02 - Recherche
│   ├── Rechercher trajets
│   ├── Détail voyage
│   └── Disponibilité sièges
├── 03 - Réservation
│   ├── Initier réservation
│   ├── Annuler réservation
│   └── Mes réservations
├── 04 - Paiement
│   ├── Initier paiement MoMo
│   ├── Statut paiement
│   └── Historique paiements
├── 05 - Billets
│   ├── Mes billets
│   ├── Télécharger PDF
│   └── Valider billet (agent)
└── 06 - Admin
    ├── Gestion flotte
    ├── Gestion trajets
    └── Tableau de bord
```

## Exporter la collection

Postman → Collections → ⋯ → Export → Collection v2.1
Placer le fichier JSON dans ce dossier.

## Utiliser avec Newman (CI/CD)

```bash
newman run docs/api/GEV_API.postman_collection.json \
  -e docs/api/GEV_API.postman_environment.json \
  --reporters cli,htmlextra \
  --reporter-htmlextra-export docs/api/newman-report.html
```