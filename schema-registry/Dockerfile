FROM confluentinc/cp-schema-registry:1.0.0

# Banking application metadata
LABEL maintainer="banking-dev-team"
LABEL description="Self-Contained Schema Registry for Banking Application"

# Core configurations for banking application
ENV SCHEMA_REGISTRY_HOST_NAME=schema-registry \
    SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS=PLAINTEXT://kafka:29092 \
    SCHEMA_REGISTRY_LISTENERS=http://0.0.0.0:8081 \
    \
    SCHEMA_REGISTRY_KAFKASTORE_TOPIC_REPLICATION_FACTOR=1 \
    SCHEMA_REGISTRY_DEBUG=false \
    SCHEMA_REGISTRY_KAFKASTORE_TOPIC=_schemas \
    \
    SCHEMA_REGISTRY_SCHEMA_COMPATIBILITY_LEVEL=BACKWARD

# Create data volume for persistence
VOLUME /var/lib/schema-registry/data

# Health check for banking reliability
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=45s \
    CMD curl -f http://localhost:8081/subjects || exit 1

# Expose port
EXPOSE 8081
