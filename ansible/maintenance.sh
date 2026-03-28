#!/bin/bash

# Thư mục backup
BACKUP_DIR="/backup"
mkdir -p $BACKUP_DIR

# Tên file backup
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%F).tar.gz"

# Tạo backup
tar -czf $BACKUP_FILE /etc /home

# Nếu backup thành công, xóa log cũ
if [ -f "$BACKUP_FILE" ]; then
    find /var/log -type f -mtime +7 -delete
fi

# Xóa backup cũ >5 ngày để tránh đầy disk
find $BACKUP_DIR -type f -mtime +5 -delete
