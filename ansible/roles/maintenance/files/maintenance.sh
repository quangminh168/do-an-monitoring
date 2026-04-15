#!/bin/bash
BACKUP_DIR="/backup/config_$(date +%F)"
LOG_FILE="/var/log/maintenance.log"

echo "=== Maintenance Start: $(date) ===" >> $LOG_FILE
# 1. Dọn dẹp
apt-get clean -y && apt-get autoremove -y
journalctl --vacuum-time=7d >> $LOG_FILE 2>&1
# 2. Backup
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/system_configs.tar.gz" /etc/ssh /etc/mysql /home/quangminh/do-an-monitoring 2>/dev/null
# 3. Xóa backup cũ > 5 ngày
find /backup -type d -mtime +5 -exec rm -rf {} +
echo "=== Maintenance Done ===" >> $LOG_FILE
