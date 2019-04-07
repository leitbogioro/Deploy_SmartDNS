#!/bin/bash

flag=$(ps aux | grep /usr/sbin/smartdns | grep -v "grep" | wc -l)

if [ $flag = "0" ]; then
    /etc/init.d/smartdns start
fi

if ! grep -Eqi "127.0.0.1" /etc/resolv.conf; then
    rm -rf /etc/resolv.conf
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
fi
