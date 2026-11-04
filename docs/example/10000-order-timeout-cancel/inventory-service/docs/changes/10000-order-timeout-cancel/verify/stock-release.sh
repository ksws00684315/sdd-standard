#!/usr/bin/env bash
# Degraded verification for R2 and R4 (inventory-service has no runnable tests).
#
# Prerequisites:
#   - inventory-service running locally on ${BASE_URL} with the test database
#   - order ${ORDER_NO} has locked stock (see the seed SQL in the service README)
# Run:   bash verify/stock-release.sh
# Pass:  prints "PASS" and exits 0; any assertion failure exits 1.
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8082}"
ORDER_NO="${ORDER_NO:-VERIFY-0001}"

release() {
  curl -sf -X POST "${BASE_URL}/stock/release" \
    -H 'Content-Type: application/json' \
    -d "{\"orderNo\":\"${ORDER_NO}\",\"reason\":\"TIMEOUT\"}"
}

# R2: the first call releases the locked stock
first="$(release)"
echo "${first}" | grep -q '"released":true' || { echo "FAIL R2: ${first}"; exit 1; }

# R4: a repeated call does not release again
second="$(release)"
echo "${second}" | grep -q '"released":false' || { echo "FAIL R4: ${second}"; exit 1; }

echo "PASS"
