# Minecraft Backup Script

## Prerequisites
- Bash 4+, `tar`, and enough disk space for five compressed backups.
- Optional: `cron` to schedule the job.

## Usage
```bash
# Run a one-off backup
bin/backup-minecraft.sh /path/to/minecraft/server
```
- The script validates the path, writes a timestamped archive to `/path/to/minecraft/server/backups`, excludes the backups directory itself, and keeps only the five newest archives.
- Output shows the path to the new archive.

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
