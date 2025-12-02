#!/usr/bin/env bash
# Back up a running Minecraft server directory, retaining the latest five archives.
set -euo pipefail

mc_path="${1:-}"

if [[ -z "${mc_path}" ]]; then
  echo "Usage: $0 <mc_path>" >&2
  exit 1
fi

if [[ ! -d "${mc_path}" ]]; then
  echo "Error: path does not exist: ${mc_path}" >&2
  exit 1
fi

backups_dir="${mc_path%/}/backups"
timestamp="$(date +%Y%m%d_%H%M%S)"
backup_file="${backups_dir}/minecraft_backup_${timestamp}.tar.gz"

mkdir -p "${backups_dir}"

# Create a compressed archive; exclude the backups directory to avoid recursion.
tar -C "${mc_path}" \
  --exclude "backups" \
  -czf "${backup_file}" .

# Keep only the five newest backups; delete older ones.
find "${backups_dir}" -maxdepth 1 -type f -name "minecraft_backup_*.tar.gz" \
  -printf "%T@ %p\n" \
  | sort -nr \
  | awk 'NR>5 {print $2}' \
  | xargs -r rm -f

echo "Backup written to ${backup_file}"

# Suggested cron entry (runs daily at midnight):
# 0 0 * * * /path/to/backup-minecraft.sh /opt/minecraft >> /var/log/mc_backup.log 2>&1
