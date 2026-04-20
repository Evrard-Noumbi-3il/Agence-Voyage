# Architecture Technique — Projet ADV
Ce dossier centralise la vision structurelle de la plateforme ADV (Gestion d'Agence de Voyage). 
L'architecture a été pensée pour répondre à des contraintes de haute disponibilité, de sécurité (DevSecOps) et de scalabilité.

## Pile Technologique (Tech Stack)

| Composant | Technologie | Justification |
|---------|-------------|--------|
| Backend | Java 21 / Spring Boot 3.4.2 | LTS, performance du JIT, virtual threads, sécurité native. |
| Mobile | React Native 0.74+ | Cross-platform (Android/iOS), performance native. |
| Base de données | PostgreSQL 16 | Fiabilité relationnelle (ACID), support JSONB. |
| Cache / Locks | Redis 7 | Verrous distribués pour éviter le ""double booking"" des sièges. |
| Sécurité/IAM | Keycloak (OIDC) | Gestion centralisée des identités et du RBAC. |
| Secrets | HashiCorp Vault | Évite le stockage de secrets en clair dans les fichiers de config. |
| Storage | MinIO (S3) | Stockage d'objets pour les documents KYC et factures. |

## Modèle C4 — Niveau 2 (Containers)
Le diagramme ci-dessous illustre l'interaction entre les services internes et les fournisseurs tiers (Paiement, SMS, Cloud).

#### Extrait de code
@startuml C4_Container_ADV

!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

LAYOUT_WITH_LEGEND()

Person(voyageur, "Voyageur", "Consulte les trajets et réserve des billets")

Person(agent, "Agent d'agence", "Vérifie les billets (Scan QR)")

Person(admin, "Administrateur", "Supervise le système et le KYC")

System_Boundary(gev, "GEV Platform") {
    
    Container(mobile, "App Mobile", "React Native", "Interface utilisateur finale")
    
    Container(backend, "API Core", "Spring Boot 3.4", "Logique métier & Orchestration")
    
    ContainerDb(postgres, "DB Principal", "PostgreSQL 16", "Persistance des données")
    
    ContainerDb(redis, "Cache & Locks", "Redis 7", "Gestion des sessions et conflits")
    
    Container(keycloak, "IAM", "Keycloak", "Auth OAuth2 / RBAC")
    
    Container(vault, "Secrets", "Vault", "Stockage certs/clés API")
    
    Container(minio, "S3 Storage", "MinIO", "Stockage KYC & PDFs")
}

System_Ext(payunit, "PayUnit", "Mobile Money API")

System_Ext(firebase, "Firebase", "Push Notifications")

Rel(voyageur, mobile, "Utilise")

Rel(agent, mobile, "Scanne les billets")

Rel(mobile, backend, "Appels API REST", "HTTPS/JWT")

Rel(backend, keycloak, "Vérifie Token", "OIDC")

Rel(backend, postgres, "JDBC", "SQL")

Rel(backend, redis, "Verrous", "Jedis/Lettuce")

Rel(backend, payunit, "Traitement Paiement", "HTTPS")

@enduml



# Choix d'Architecture Sécurisée
1. Architecture Multi-couches : Le backend suit une structure stricte Controller > Service > Repository > Entity pour isoler la logique métier.

2. Stateless API : L'authentification est gérée par des tokens JWT (JSON Web Tokens) signés par Keycloak, permettant une scalabilité horizontale.

3. Optimisation Docker :
 - Utilisation de Multi-stage builds pour réduire la taille des images.
 - Images basées sur Alpine Linux pour minimiser la surface d'attaque.
 - Exécution via un utilisateur non-root (advuser) pour le principe du moindre privilège.
 
4. Database Migrations : Utilisation de Flyway/Liquibase pour garantir que tous les environnements (dev, staging, prod) ont le même schéma SQL.

# Liste des Diagrammes Complémentaires
| Fichier | Statut | Description |
|---------|-------------|--------|
| C4_context.png | ⏳ À faire | Vue macro du système dans son écosystème. |
| reseau_docker.png | ✅ Validé | Isolation des réseaux (backend, db, monitoring). |
| sequence_paiement.png | ⏳ À faire | Orchestration entre le Backend et PayUnit. |
| Agence de voyage.sql | ✅ Terminé | Modèle Physique de Données (MPD). |


# Outils & Méthodologie
- Conception : C4 Model pour la clarté des niveaux d'abstraction.

- Modélisation : draw.io pour les schémas statiques et PlantUML pour les diagrammes vivants (as code).

- Validation : Chaque changement d'architecture impactant le code est vérifié par le pipeline CI/CD (SonarCloud/Snyk).


## Ressources

- draw.io (gratuit) : https://app.diagrams.net
- PlantUML online : https://www.plantuml.com/plantuml
- C4 Model : https://c4model.com