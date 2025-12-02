#!/usr/bin/env bash
# Lightweight wrapper around mcrcon so non-interactive shells (cron/scripts) have a stable command.
set -euo pipefail
IFS=$'\n\t'

mcron_bin="${MCRON_BIN:-/opt/mcron/mcrcon/mcrcon}"
mcron_host="${MCRON_HOST:-localhost}"
mcron_port="${MCRON_PORT:-25575}"
mcron_pass="${MCRON_PASS:-}"

if [[ -z "${mcron_pass}" ]]; then
  echo "Error: set MCRON_PASS to your RCON password before running mcron." >&2
  exit 1
fi

if [[ ! -x "${mcron_bin}" ]]; then
  echo "Error: mcrcon binary not found or not executable at ${mcron_bin}" >&2
  exit 1
fi

exec "${mcron_bin}" -H "${mcron_host}" -P "${mcron_port}" -p "${mcron_pass}" "$@"
