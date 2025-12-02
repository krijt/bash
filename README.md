# Minecraft Backup Script

`bin/backup-minecraft.sh` creates timestamped archives of a running Minecraft server directory and rotates them so only the five newest backups are kept.

## Prerequisites
- Bash 4+, `tar`, and enough disk space for at least five compressed backups.
- Optional: `cron` to schedule automated runs.
- `mcron` CLI available on `PATH` (or set `MCRON_CMD=/path/to/mcron`). The script uses it to send RCON commands: `save-off`, `save-all`, and `save-on`.

## Usage
```bash
# Run a one-off backup
bin/backup-minecraft.sh /path/to/minecraft/server
```
- Archives are written to `/path/to/minecraft/server/backups/minecraft_backup_YYYYMMDD_HHMMSS.tar.gz`.
- The `backups/` folder itself is excluded from the archive to avoid recursion.
- Rotation deletes older archives, keeping the newest five.
- While backing up, the script: announces start via `say`, disables auto-saves, flushes world data, then re-enables saves after the archive is built (all via `mcron`).

## Verify a backup
- List the newest archives: `ls -1t /path/to/minecraft/server/backups | head`
- Spot-check extraction into a temp directory (without touching the live server):
  ```bash
  tmpdir="$(mktemp -d)"
  tar -C "${tmpdir}" -xzf /path/to/minecraft/server/backups/minecraft_backup_YYYYMMDD_HHMMSS.tar.gz
  ls "${tmpdir}"
  rm -rf "${tmpdir}"
  ```

## Scheduling (midnight daily)
Add a cron entry (adjust paths as needed):
```
0 0 * * * /opt/code/bash/bin/backup-minecraft.sh /opt/minecraft >> /var/log/mc_backup.log 2>&1
```
- Cron runs in a minimal environment; use absolute paths.
- Ensure the user running cron can read the server directory and write to the backups folder/log.

## Restore (manual)
```bash
tar -C /path/to/restore/target -xzf /path/to/minecraft/server/backups/minecraft_backup_YYYYMMDD_HHMMSS.tar.gz
```
- Stop the server before restoring to avoid data races; start it again after extraction.
- Restoring into a fresh directory lets you diff against the live world before replacing files.
