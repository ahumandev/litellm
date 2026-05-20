#!/usr/bin/env bash
# Source this file, then run `litellm`.
# The alias always launches from this repository root without changing your shell directory.

_bmw_litellm_alias_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
_bmw_litellm_repo_root="$(cd -- "${_bmw_litellm_alias_script_dir}/.." && pwd -P)"
_bmw_litellm_proxy_extras_root="${_bmw_litellm_repo_root}/litellm-proxy-extras"
_bmw_litellm_enterprise_root="${_bmw_litellm_repo_root}/enterprise"
_bmw_litellm_auto_root="${_bmw_litellm_repo_root}/_auto/bmw-litellm"
_bmw_litellm_pg_root="${_bmw_litellm_auto_root}/postgres"
_bmw_litellm_pg_data_dir="${_bmw_litellm_pg_root}/data"
_bmw_litellm_pg_socket_dir="${_bmw_litellm_pg_root}/socket"
_bmw_litellm_pg_log="${_bmw_litellm_pg_root}/postgres.log"
_bmw_litellm_pg_port="55432"
_bmw_litellm_proxy_port="4333"
_bmw_litellm_pg_user="llmproxy"
_bmw_litellm_pg_db="litellm"
_bmw_litellm_db_url="postgresql://${_bmw_litellm_pg_user}@127.0.0.1:${_bmw_litellm_pg_port}/${_bmw_litellm_pg_db}"
_bmw_litellm_prisma_schema="litellm/proxy/schema.prisma"

export GITHUB_COPILOT_API_BASE="https://copilot-api.bmw.ghe.com"
export GITHUB_COPILOT_DEVICE_CODE_URL="https://bmw.ghe.com/login/device/code"
export GITHUB_COPILOT_ACCESS_TOKEN_URL="https://bmw.ghe.com/login/oauth/access_token"
export GITHUB_COPILOT_API_KEY_URL="https://api.bmw.ghe.com/copilot_internal/v2/token"

export HTTP_PROXY="http://127.0.0.1:1234"
export HTTPS_PROXY="http://127.0.0.1:1234"
export http_proxy="http://127.0.0.1:1234"
export https_proxy="http://127.0.0.1:1234"
export AIOHTTP_TRUST_ENV="True"
export STORE_MODEL_IN_DB="True"

unalias litellm 2>/dev/null || true

_bmw_litellm_uv_run() {
  command uv --no-config run \
    --with-editable '.[proxy]' \
    --with 'prisma==0.11.0' \
    --with "litellm-proxy-extras @ file://${_bmw_litellm_proxy_extras_root}" \
    --with "litellm-enterprise @ file://${_bmw_litellm_enterprise_root}" \
    "$@"
}

_bmw_litellm_ensure_local_postgres() {
  if [ -n "${DATABASE_URL:-}" ]; then
    return 0
  fi

  mkdir -p -- "${_bmw_litellm_pg_root}" "${_bmw_litellm_pg_socket_dir}"

  if [ ! -f "${_bmw_litellm_pg_data_dir}/PG_VERSION" ]; then
    "/usr/lib/postgresql/16/bin/initdb" \
      -D "${_bmw_litellm_pg_data_dir}" \
      -A trust \
      -U "${_bmw_litellm_pg_user}" >/dev/null || return
  fi

  if ! pg_isready -h 127.0.0.1 -p "${_bmw_litellm_pg_port}" >/dev/null 2>&1; then
    "/usr/lib/postgresql/16/bin/pg_ctl" \
      -D "${_bmw_litellm_pg_data_dir}" \
      -l "${_bmw_litellm_pg_log}" \
      -o "-p ${_bmw_litellm_pg_port} -h 127.0.0.1 -k ${_bmw_litellm_pg_socket_dir}" \
      start >/dev/null || return
  fi

  if ! psql \
    -h 127.0.0.1 \
    -p "${_bmw_litellm_pg_port}" \
    -U "${_bmw_litellm_pg_user}" \
    -d postgres \
    -tAc "select 1 from pg_database where datname='${_bmw_litellm_pg_db}'" | grep -q '^1$'; then
    createdb \
      -h 127.0.0.1 \
      -p "${_bmw_litellm_pg_port}" \
      -U "${_bmw_litellm_pg_user}" \
      "${_bmw_litellm_pg_db}" || return
  fi

  export DATABASE_URL="${_bmw_litellm_db_url}"
}

_bmw_litellm_prepare_runtime() {
  _bmw_litellm_ensure_local_postgres || return
  _bmw_litellm_uv_run prisma generate --schema "${_bmw_litellm_prisma_schema}" >/dev/null || return

  if ! psql \
    -h 127.0.0.1 \
    -p "${_bmw_litellm_pg_port}" \
    -U "${_bmw_litellm_pg_user}" \
    -d "${_bmw_litellm_pg_db}" \
    -tAc "select 1 from information_schema.tables where table_schema='public' and table_name='LiteLLM_VerificationToken'" | grep -q '^1$'; then
    _bmw_litellm_uv_run litellm --config bmw.yaml --port "${_bmw_litellm_proxy_port}" --skip_server_startup >/dev/null || return
  fi
}

_bmw_litellm_start_proxy() {
  (
    cd -- "${_bmw_litellm_repo_root}" || return
    _bmw_litellm_prepare_runtime || return
    _bmw_litellm_uv_run \
      litellm --config bmw.yaml --port "${_bmw_litellm_proxy_port}" "$@"
  )
}

alias litellm='_bmw_litellm_start_proxy'
