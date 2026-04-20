# =============================================================================
# backend/Dockerfile — Multi-stage build Spring Boot 3 / Java 21
# =============================================================================

# ─────────────────────────────────────────────────────────────────────────────
# STAGE 1 — EXTRACTION (Légère)
# ─────────────────────────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine AS extractor
WORKDIR /build

# On récupère le JAR que la CI a déjà construit dans le dossier target/
COPY target/*.jar app.jar

# On extrait les couches
RUN java -Djarmode=layertools -jar app.jar extract --destination extracted

# ─────────────────────────────────────────────────────────────────────────────
# STAGE 2 — RUNTIME (Sécurisé)
# ─────────────────────────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine

ARG BUILD_DATE
ARG GIT_SHA

RUN addgroup -S advgroup && adduser -S advuser -G advgroup
USER advuser
WORKDIR /app

# Copie des couches extraites
COPY --from=extractor --chown=advuser:advgroup /build/extracted/dependencies/ ./
COPY --from=extractor --chown=advuser:advgroup /build/extracted/spring-boot-loader/ ./
COPY --from=extractor --chown=advuser:advgroup /build/extracted/snapshot-dependencies/ ./
COPY --from=extractor --chown=advuser:advgroup /build/extracted/application/ ./

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=5s --start-period=45s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "org.springframework.boot.loader.launch.JarLauncher"]