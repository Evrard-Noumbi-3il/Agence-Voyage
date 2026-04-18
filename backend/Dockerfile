# =============================================================================
# backend/Dockerfile — Multi-stage build Spring Boot 3 / Java 21
# =============================================================================

# ─────────────────────────────────────────────────────────────────────────────
# STAGE 1 — BUILD (Maven + JDK complet)
# Cette image ne sera PAS dans l'image finale
# ─────────────────────────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /build

# Copier pom.xml d'abord pour bénéficier du cache Docker sur les dépendances
COPY pom.xml .
COPY .mvn/ .mvn/
COPY mvnw mvnw

# Télécharger les dépendances (couche cachée si pom.xml ne change pas)
RUN ./mvnw dependency:go-offline -q

# Copier le source et builder
COPY src/ src/
RUN ./mvnw package -DskipTests -q

# Extraire les layers JAR pour un démarrage Spring Boot plus rapide
RUN java -Djarmode=layertools \
    -jar target/*.jar extract --destination target/extracted

# ─────────────────────────────────────────────────────────────────────────────
# STAGE 2 — RUNTIME (JRE minimal — image légère)
# ─────────────────────────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine AS runtime

# Métadonnées
ARG BUILD_DATE
ARG GIT_SHA
LABEL org.opencontainers.image.title="ADV Backend API" \
      org.opencontainers.image.description="Agence de Voyages — Spring Boot 3 API" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${GIT_SHA}" \
      org.opencontainers.image.vendor="Evrard NOUMBI"

# Sécurité : utilisateur non-root
RUN addgroup -S advgroup && adduser -S advuser -G advgroup
USER advuser

WORKDIR /app

# Copier uniquement les layers nécessaires depuis le stage builder
# (dependencies, spring-boot-loader, snapshot-dependencies, application)
COPY --from=builder --chown=advuser:advgroup /build/target/extracted/dependencies/ ./
COPY --from=builder --chown=advuser:advgroup /build/target/extracted/spring-boot-loader/ ./
COPY --from=builder --chown=advuser:advgroup /build/target/extracted/snapshot-dependencies/ ./
COPY --from=builder --chown=advuser:advgroup /build/target/extracted/application/ ./

# Port exposé
EXPOSE 8080

# Health check interne Docker
HEALTHCHECK --interval=15s --timeout=5s --start-period=45s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Lancement via JarLauncher (Spring Boot layers)
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "org.springframework.boot.loader.launch.JarLauncher"]