#!/bin/bash

echo "===== START ====="

# ✅ DNS FIX (Google error fix)
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# ✅ Internet test
curl -I https://google.com || echo "Google blocked fix applied"

# Run install
bash /install.sh

# Keep alive
tail -f /dev/null