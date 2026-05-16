#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
export DBT_PROFILES_DIR="${ROOT}/dbt"
if [[ -f "${ROOT}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${ROOT}/.env"
  set +a
fi
# Use Python entrypoint so OAuth refresh tokens are cached (see dbt_snowflake_oauth_patch.py).
exec "${ROOT}/.venv/bin/python" "${ROOT}/scripts/run_dbt.py" "$@"
