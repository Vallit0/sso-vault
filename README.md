# SSO-Vault

Infraestructura dockerizada que integra **Keycloak** (Single Sign-On), **HashiCorp Vault** (gestion de secretos) y **Traefik** (reverse proxy) en un solo stack.

## Arquitectura

```
                    +------------------+
                    |     Traefik      |
                    |  (Reverse Proxy) |
                    |  :9080 / :9443   |
                    +--------+---------+
                             |
              +--------------+--------------+
              |                             |
    +---------+----------+     +------------+---------+
    |     Keycloak       |     |    HashiCorp Vault   |
    |   (SSO / IdP)      |     | (Secrets Management) |
    | sso.localhost:9080  |     | vault.localhost:9080 |
    +---------+----------+     +----------------------+
              |
    +---------+----------+
    |   SQL Server (ext)  |
    |  host.docker.internal|
    |       :1433          |
    +---------------------+
```

## Servicios

| Servicio  | URL                              | Descripcion                          |
|-----------|----------------------------------|--------------------------------------|
| Keycloak  | http://sso.localhost:9080         | Consola de administracion SSO        |
| Vault     | http://vault.localhost:9080       | UI de gestion de secretos            |
| Traefik   | http://traefik.localhost:9090     | Dashboard del reverse proxy          |

## Requisitos previos

- [Docker](https://docs.docker.com/get-docker/) y Docker Compose v2+
- **SQL Server** corriendo en el host (puerto 1433) con una base de datos para Keycloak

## Inicio rapido

1. **Clonar el repositorio**

   ```bash
   git clone https://github.com/Vallit0/sso-vault.git
   cd sso-vault
   ```

2. **Configurar variables de entorno**

   ```bash
   cp .env.example .env
   ```

   Edita `.env` con tus credenciales reales (SQL Server, Keycloak admin, Vault token).

3. **Levantar los servicios**

   ```bash
   docker compose up -d --build
   ```

4. **Verificar conectividad a la base de datos**

   ```bash
   ./verify-db.sh
   ```

## Estructura del proyecto

```
sso-vault/
├── docker-compose.yml      # Orquestacion de servicios
├── .env.example             # Plantilla de variables de entorno
├── .gitignore
├── verify-db.sh             # Script de verificacion de conectividad DB
├── keycloak/
│   └── Dockerfile           # Build multi-stage con driver MSSQL JDBC
├── traefik/
│   └── traefik.yml          # Configuracion del reverse proxy
└── vault/
    └── config/
        └── vault.hcl        # Configuracion de Vault
```

## Configuracion

Todas las variables se definen en `.env` (ver `.env.example`):

| Variable                   | Descripcion                              |
|----------------------------|------------------------------------------|
| `KEYCLOAK_ADMIN`           | Usuario admin de Keycloak                |
| `KEYCLOAK_ADMIN_PASSWORD`  | Password del admin de Keycloak           |
| `KC_HOSTNAME`              | Hostname para Keycloak (ej. sso.localhost)|
| `MSSQL_HOST`               | Host de SQL Server                       |
| `MSSQL_PORT`               | Puerto de SQL Server (default: 1433)     |
| `MSSQL_DB`                 | Nombre de la base de datos               |
| `MSSQL_USER`               | Usuario de SQL Server                    |
| `MSSQL_PASSWORD`           | Password de SQL Server                   |
| `VAULT_DEV_ROOT_TOKEN_ID`  | Token root para Vault (modo dev)         |
| `VAULT_HOSTNAME`           | Hostname para Vault (ej. vault.localhost)|
| `TRAEFIK_DASHBOARD_HOSTNAME`| Hostname del dashboard de Traefik       |

## Red

Todos los servicios se comunican a traves de la red bridge `sso-vault-net`. Keycloak alcanza SQL Server en el host via `host.docker.internal`.

## Notas

- Esta configuracion es para **desarrollo**. Para produccion, deshabilitar el modo `start-dev` de Keycloak, habilitar TLS, y no usar Vault en modo dev.
- El archivo `.env` esta en `.gitignore` para evitar exponer credenciales.
