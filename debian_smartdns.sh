#!/bin/bash

flag=$(ps aux | grep /usr/sbin/smartdns | grep -v "grep" | wc -l)

if [ $flag = "0" ]; then
    /etc/init.d/smartdns start
fi
