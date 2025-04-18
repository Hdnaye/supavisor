#!/usr/bin/env sh
set -e

# 1) Lancement de Supavisor en arrière‑plan
/app/bin/server &

# 2) Attente de la mise en route de l'API HTTP
until curl -s http://localhost:8080/healthz >/dev/null; do
  echo "Waiting for Supavisor API…"
  sleep 1
done

# 3) Création du tenant “default” (ou “prod”, à ton choix)
curl -sS -X PUT http://localhost:8080/api/tenants/default \
  -H "Authorization: Bearer ${API_JWT_SECRET}" \
  -H "Content-Type: application/json" \
  -d '{
    "tenant": {
      "ip_version": "auto",
      "db_host":    "'${POSTGRES_HOST}'",
      "db_port":    '${POSTGRES_PORT}',
      "db_database":"postgres",
      "users": [
        {
          "db_user":      "'${POSTGRES_USER}'",
          "db_password":  "'${POSTGRES_PASSWORD}'",
          "mode_type":    "transaction",
          "pool_size":    20,
          "is_manager":   true
        }
      ]
    }
  }'

# 4) Passer en avant‑plan pour ne pas laisser le container s’éteindre
wait
