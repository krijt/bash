#!/usr/bin/env bash
# Back up a running Minecraft server directory, retaining a configurable number of archives (default: 5).
set -euo pipefail

mcron_cmd="${MCRON_CMD:-mcron}"
saves_disabled=0

mc_rcon() {
  local rcon_cmd="${1:?}"
  "${mcron_cmd}" "${rcon_cmd}"
}

ensure_mcron_available() {
  if ! command -v "${mcron_cmd}" >/dev/null 2>&1; then
    echo "Error: required command not found: ${mcron_cmd}" >&2
    exit 1
  fi
}

restore_saves() {
  if [[ "${saves_disabled}" -eq 1 ]]; then
    if ! mc_rcon "save-on"; then
      echo "Warning: failed to re-enable saves via ${mcron_cmd}" >&2
    fi
    saves_disabled=0
  fi
}

trap restore_saves EXIT

mc_path="${1:-}"
keep_count="${2:-5}"

if [[ -z "${mc_path}" ]]; then
  echo "Usage: $0 <mc_path> [keep_count=5]" >&2
  exit 1
fi

if [[ ! -d "${mc_path}" ]]; then
  echo "Error: path does not exist: ${mc_path}" >&2
  exit 1
fi

if [[ ! "${keep_count}" =~ ^[0-9]+$ || "${keep_count}" -lt 1 ]]; then
  echo "Error: keep_count must be a positive integer (received: ${keep_count})" >&2
  exit 1
fi

ensure_mcron_available

mc_rcon "say Starting backup; saving world to disk..." || true
mc_rcon "save-off"
saves_disabled=1
mc_rcon "save-all"
# Allow a short buffer for the save to flush before archiving.
sleep 2

backups_dir="${mc_path%/}/backups"
timestamp="$(date +%Y%m%d_%H%M%S)"
backup_file="${backups_dir}/minecraft_backup_${timestamp}.tar.gz"

mkdir -p "${backups_dir}"

# Create a compressed archive; exclude the backups directory to avoid recursion.
tar -C "${mc_path}" \
  --exclude "backups" \
  -czf "${backup_file}" .

# Keep only the newest backups according to keep_count; delete older ones.
find "${backups_dir}" -maxdepth 1 -type f -name "minecraft_backup_*.tar.gz" \
  -printf "%T@ %p\n" \
  | sort -nr \
  | awk -v keep="${keep_count}" 'NR>keep {print $2}' \
  | xargs -r rm -f

echo "Backup written to ${backup_file}"

restore_saves

mc_rcon "say Backup completed; saves re-enabled." || true

# Suggested cron entry (runs daily at midnight):
# 0 0 * * * /path/to/backup-minecraft.sh /opt/minecraft >> /var/log/mc_backup.log 2>&1
