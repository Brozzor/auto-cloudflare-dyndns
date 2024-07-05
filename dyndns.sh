#!/bin/bash

# Configuration
set -a
source .env
set +a

# Obtenir l'adresse IP publique actuelle
IP=$(curl -s http://checkip.amazonaws.com)

# Obtenir le ZONE_ID
ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${ZONE_NAME}" \
     -H "Authorization: Bearer ${CF_API_TOKEN}" \
     -H "Content-Type: application/json" | jq -r '.result[0].id')

# Obtenir le RECORD_ID
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${RECORD_NAME}" \
     -H "Authorization: Bearer ${CF_API_TOKEN}" \
     -H "Content-Type: application/json" | jq -r '.result[0].id')

# Mettre à jour l'enregistrement DNS avec la nouvelle adresse IP
RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
     -H "Authorization: Bearer ${CF_API_TOKEN}" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"A\",\"name\":\"${RECORD_NAME}\",\"content\":\"${IP}\",\"ttl\":120,\"proxied\":false}")

# Vérifier si la mise à jour a réussi
if [[ $(echo "$RESPONSE" | jq -r '.success') == "true" ]]; then
  echo "DNS record updated successfully."
else
  echo "Failed to update DNS record."
  echo "$RESPONSE"
fi
