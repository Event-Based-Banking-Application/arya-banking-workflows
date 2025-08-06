FROM quay.io/keycloak/keycloak:23.0.4

# Banking application metadata
LABEL maintainer="banking-dev-team"
LABEL description="Self-Contained Keycloak for Banking Application"

# Switch to root for setup
USER root

# Create directories and set permissions
RUN mkdir -p /opt/keycloak/data/import && \
    chown -R keycloak:keycloak /opt/keycloak/data/import

# Switch back to keycloak user
USER keycloak

# Build with PostgreSQL support
RUN /opt/keycloak/bin/kc.sh build --db=postgres

# ===== ALL CONFIGURATIONS BUILT-IN =====
ENV KC_DB=postgres \
    KC_DB_URL=jdbc:postgresql://postgres:5432/keycloak \
    KC_DB_USERNAME=keycloak \
    KC_DB_PASSWORD=keycloak_password_2024 \
    KC_DB_SCHEMA=public \
    \
    KEYCLOAK_ADMIN=admin \
    KEYCLOAK_ADMIN_PASSWORD=admin_secure_password_2024 \
    \
    KC_HOSTNAME=localhost \
    KC_HOSTNAME_PORT=8080 \
    KC_HOSTNAME_STRICT=false \
    KC_HOSTNAME_STRICT_HTTPS=false \
    KC_HTTP_ENABLED=true \
    \
    KC_FEATURES=authorization,account-api,admin-fine-grained-authz \
    KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true \
    \
    KC_LOG_LEVEL=INFO \
    KC_LOG=console \
    \
    JAVA_OPTS_APPEND="-Xms512m -Xmx1024m"

# Create data volume
VOLUME /opt/keycloak/data

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=60s \
    CMD curl -f http://localhost:8080/health/ready || exit 1

# Expose port
EXPOSE 8080

# Start command
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--import-realm"]
