# Stage 1: Download MSSQL JDBC driver using an image that has curl
FROM alpine:3.20 AS downloader
RUN apk add --no-cache curl && \
    curl -L -o /mssql-jdbc.jar \
    https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/12.4.2.jre11/mssql-jdbc-12.4.2.jre11.jar

# Stage 2: Build optimized Keycloak with MSSQL support
FROM quay.io/keycloak/keycloak:24.0 AS builder

COPY --from=downloader /mssql-jdbc.jar /opt/keycloak/providers/mssql-jdbc-12.4.2.jre11.jar

RUN /opt/keycloak/bin/kc.sh build --db=mssql

# Stage 3: Final image
FROM quay.io/keycloak/keycloak:24.0

COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
