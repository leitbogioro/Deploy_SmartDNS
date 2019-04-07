#!/bin/bash

flag=$(ps aux | grep /usr/sbin/smartdns | grep -v "grep" | wc -l)

if [ $flag = "0" ]; then
    /etc/init.d/smartdns start
fi

if ! grep -Eqi "127.0.0.1" /etc/resolv.conf; then
    rm -rf /etc/resolv.conf
    cat > /etc/resolv.conf<<-EOF
nameserver 127.0.0.1
nameserver 8.8.8.8
EOF
fi
