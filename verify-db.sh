#!/bin/bash
# Verifies Keycloak can reach the external SQL Server database.
# Usage: ./verify-db.sh

set -euo pipefail

# Load .env
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "=== SSO-Vault DB Connectivity Check ==="
echo ""
echo "Target: ${MSSQL_HOST}:${MSSQL_PORT} (DB: ${MSSQL_DB})"
echo ""

# 1. TCP connectivity test from host
echo "[1/3] Testing TCP connectivity from host..."
if timeout 5 bash -c "echo >/dev/tcp/${MSSQL_HOST}/${MSSQL_PORT}" 2>/dev/null; then
  echo "  OK - Port ${MSSQL_PORT} is reachable on ${MSSQL_HOST}"
else
  echo "  FAIL - Cannot reach ${MSSQL_HOST}:${MSSQL_PORT}"
  echo "  Check that SQL Server is running and the firewall allows connections."
  exit 1
fi

# 2. TCP connectivity test from inside the Keycloak container
echo "[2/3] Testing TCP connectivity from Keycloak container..."
if docker exec keycloak bash -c "echo >/dev/tcp/${MSSQL_HOST}/${MSSQL_PORT}" 2>/dev/null; then
  echo "  OK - Keycloak container can reach SQL Server"
else
  echo "  FAIL - Keycloak container cannot reach ${MSSQL_HOST}:${MSSQL_PORT}"
  echo "  Check Docker networking and extra_hosts configuration."
  exit 1
fi

# 3. Keycloak health check
echo "[3/3] Checking Keycloak health endpoint..."
KC_HEALTH=$(docker exec keycloak curl -sf http://localhost:8080/health/ready 2>/dev/null || true)
if echo "$KC_HEALTH" | grep -qi "UP"; then
  echo "  OK - Keycloak is healthy and connected to the database"
else
  echo "  WARN - Keycloak health check not yet passing."
  echo "  It may still be starting. Check logs: docker logs keycloak"
fi

echo ""
echo "=== Verification Complete ==="
