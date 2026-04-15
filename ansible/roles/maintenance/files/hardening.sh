#!/bin/bash
TOKEN="{{ vault_telegram_token }}"
ID="{{ vault_telegram_chat_id }}"
LOG_FILE="/var/log/hardening.log"

# Sử dụng flock để tránh chạy chồng chéo
exec 200>/tmp/hardening.lock
flock -n 200 || exit 1

echo "=== Check Security: $(date) ===" >> $LOG_FILE

SERVICES="promtail node_exporter"
for service in $SERVICES; do
    if ! systemctl is-active --quiet $service; then
        sudo systemctl restart $service
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d chat_id=$ID -d text="Service $service was down and restarted on VM: $(hostname)"
        echo "$(date): Restarted $service" >> $LOG_FILE
    fi
done

# 2. Check failed logins (Hardening)
lastb | grep -v "127.0.0.1" | awk '{print $3}' | sort | uniq -c | while read count ip; do
    if [ "$count" -gt 5 ] && [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        if ! iptables -L INPUT -v -n | grep -q "$ip"; then
            iptables -A INPUT -s "$ip" -j DROP
            echo "Blocked IP: $ip" >> $LOG_FILE
            curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" -d chat_id=$ID -d text="Blocked IP $ip due to brute force."
        fi
    fi
done
