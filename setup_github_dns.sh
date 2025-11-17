#!/usr/bin/env bash
set -euo pipefail

########################################
# Config / env
########################################

# Path to env file (default: .env in current dir)
ENV_FILE="${ENV_FILE:-.env}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
else
  echo "ERROR: Env file '$ENV_FILE' not found."
  echo "Create it and put: CF_API_TOKEN=your_token_here"
  exit 1
fi

CF_API_TOKEN="${CF_API_TOKEN:-}"

DOMAIN="justin-napolitano.com"
GITHUB_USER="justin-napolitano"

if [[ -z "$CF_API_TOKEN" ]]; then
  echo "ERROR: CF_API_TOKEN is not set in '$ENV_FILE'."
  exit 1
fi

CF_API_BASE="https://api.cloudflare.com/client/v4"

########################################
# Find Zone ID
########################################

echo "Looking up Zone ID for ${DOMAIN}..."

ZONE_ID=$(
  curl -s -X GET "${CF_API_BASE}/zones?name=${DOMAIN}&status=active" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
  | jq -r '.result[0].id'
)

if [[ "$ZONE_ID" == "null" || -z "$ZONE_ID" ]]; then
  echo "ERROR: Could not find active zone for ${DOMAIN}."
  exit 1
fi

echo "Found Zone ID: ${ZONE_ID}"
echo

########################################
# Helper: delete DNS records
########################################

delete_records() {
  local type="$1"
  local name="$2"

  echo "Looking for existing ${type} records for ${name}..."

  # Fetch up to 100 records matching type + name
  local ids
  ids=$(
    curl -s -X GET "${CF_API_BASE}/zones/${ZONE_ID}/dns_records?type=${type}&name=${name}&per_page=100" \
      -H "Authorization: Bearer ${CF_API_TOKEN}" \
      -H "Content-Type: application/json" \
    | jq -r '.result[].id'
  )

  if [[ -z "$ids" ]]; then
    echo "  None found."
    echo
    return
  fi

  echo "  Found records: ${ids}"
  for id in $ids; do
    echo "  Deleting record id=${id}..."
    curl -s -X DELETE "${CF_API_BASE}/zones/${ZONE_ID}/dns_records/${id}" \
      -H "Authorization: Bearer ${CF_API_TOKEN}" \
      -H "Content-Type: application/json" \
    | jq -r '.success' >/dev/null
  done

  echo "  Done deleting ${type} records for ${name}."
  echo
}

########################################
# Helper: create DNS record
########################################

create_record() {
  local type="$1"
  local name="$2"
  local content="$3"
  local proxied="${4:-false}"

  echo "Creating ${type} record: ${name} -> ${content} (proxied=${proxied})"

  curl -s -X POST "${CF_API_BASE}/zones/${ZONE_ID}/dns_records" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data @- <<EOF | jq .
{
  "type": "${type}",
  "name": "${name}",
  "content": "${content}",
  "ttl": 3600,
  "proxied": ${proxied}
}
EOF

  echo
}

########################################
# GitHub Pages IPs
########################################

A_IPS=(
  "185.199.108.153"
  "185.199.109.153"
  "185.199.110.153"
  "185.199.111.153"
)

AAAA_IPS=(
  "2606:50c0:8000::153"
  "2606:50c0:8001::153"
  "2606:50c0:8002::153"
  "2606:50c0:8003::153"
)

########################################
# Delete existing records
########################################

echo "Cleaning up existing records for ${DOMAIN} and www.${DOMAIN}..."

# Apex
delete_records "A"    "${DOMAIN}"
delete_records "AAAA" "${DOMAIN}"

# www – could be A or CNAME from old configs
delete_records "A"     "www.${DOMAIN}"
delete_records "CNAME" "www.${DOMAIN}"

########################################
# Create records
########################################

echo "Creating A records for ${DOMAIN} (apex)..."
for ip in "${A_IPS[@]}"; do
  create_record "A" "${DOMAIN}" "${ip}" "false"
done

echo "Creating AAAA records for ${DOMAIN} (IPv6)..."
for ip in "${AAAA_IPS[@]}"; do
  create_record "AAAA" "${DOMAIN}" "${ip}" "false"
done

echo "Creating CNAME for www.${DOMAIN} -> ${GITHUB_USER}.github.io ..."
create_record "CNAME" "www.${DOMAIN}" "${GITHUB_USER}.github.io" "false"

echo "Done. DNS records created."
echo "Verify with:"
echo "  dig A ${DOMAIN} +short"
echo "  dig AAAA ${DOMAIN} +short"
echo "  dig CNAME www.${DOMAIN} +short"

