# Stratégie de Sécurité & Rapports (DevSecOps)
Ce dossier centralise la gouvernance de sécurité du projet GEV. Nous appliquons le principe du "Shift Left Security" : la sécurité est testée dès les premières lignes de code via notre pipeline CI/CD.

# Arsenal d'Analyse (Security Stack)

| Outil | Type | Périmètre | Objectif |
|-------|---------|---------|----------|
| Snyk | SCA | Dépendances Maven & NPM | Détecter les bibliothèques vulnérables (CVE). |
| SonarCloud | SAST | Code Source (Java) | Identifier les "Security Hotspots" et la dette technique. |
| Trivy | Scanner | Image Docker | Analyser les vulnérabilités de l'OS (Alpine) et des couches JRE. |
| OWASP ZAP | DAST | API Staging (Runtime) | Simuler des attaques (Injection, XSS) sur l'application lancée. |
| Checkstyle | Linting |Qualité de code | Garantir le respect des standards de codage (Google Java Style). |

# Seuils d'Acceptation & Quality Gate
Le pipeline GitHub Actions est configuré pour échouer (fail-fast) si les critères suivants ne sont pas respectés :

1. Snyk (SCA) : Aucun vulnérabilité de niveau CRITICAL ou HIGH.

2. SonarCloud :

   - Statut global : Passed.

   - Security Rating : A.

   - Coverage : > 70% sur la logique métier.

3. Trivy : Blocage du push vers GHCR si une faille CRITICAL est détectée dans l'image.

# Rapports Générés

| Fichier | Source | Fréquence |
|---------|-----------|-------|
| snyk-backend-report.txt | Snyk | À chaque push sur develop |
| trivy-backend-report.txt | Trivy | À chaque build d'image Docker |
| newman-report.html | Newman | Validation des contrats d'API post-déploiement |
| checkstyle-result.xml | Checkstyle | Vérification du style de code |

# Registre des Dérogations (Acceptation du Risque)
Dans le monde réel, 100% de sécurité est impossible. Si une vulnérabilité est détectée mais ne peut être corrigée (absence de patch ou faux positif), elle est documentée ici :

| Composant | CVE / Finding | Sévérité | Justification Technique | Date |
|---------|-----------|-------|-------|-------|
| backend | fast-xml-parser | HIGH | Fausse alerte (SDoS) non applicable à notre usage de l'API. | 2026-04 |
| image | alpine:3.23 | MEDIUM | Vulnérabilité système en attente de patch par la communauté Alpine. | 2026-04 |

# Bonnes Pratiques Implémentées
Secrets Management : Aucun mot de passe en clair. Utilisation des secrets GitHub Actions et de HashiCorp Vault.

- Least Privilege : Le conteneur Docker s'exécute avec l'utilisateur advuser (UID 10001), sans droits root.

- Dependency Management : Mise à jour automatique de Spring Boot (v3.4.2) pour bénéficier des derniers patchs de sécurité.

- Container Security : Utilisation d'images JRE-alpine pour réduire la surface d'attaque (pas de shell inutile, pas d'outils de build en production).

# Commandes de Sécurité Locales
Pour tester la sécurité sur votre poste avant de push :
```bash
# Scanner les dépendances Maven

mvn snyk:test -DskipTests

# Lancer Sonar en local (nécessite un token)

mvn sonar:sonar -Dsonar.token=${SONAR_TOKEN}

# Scanner l'image Docker locale

trivy image adv-backend:latest
```
- Isolation Réseau : "Les endpoints Actuator ne sont pas exposés sur Internet, ils sont accessibles uniquement via le réseau interne du cluster (Docker/Kubernetes)."

- Sécurité Applicative : "L'accès à /actuator/** est protégé par Spring Security et nécessite un rôle ADMIN valide via Keycloak."

- Filtrage : "Seuls les endpoints nécessaires (health, info) sont activés, les endpoints sensibles (env, heapdump, shutdown) sont désactivés dans le application.properties."

L'intégration de Trivy et Snyk directement dans le workflow permet de garantir que l'image stockée sur GitHub Container Registry (GHCR) est saine au moment de sa création. C'est un gage de confiance pour le déploiement continu (CD).

