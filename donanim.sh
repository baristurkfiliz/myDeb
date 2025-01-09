#!/bin/bash
lspci | while read -r device; do
    apt install -y $(apt-cache search firmware | grep -i "$(echo $device | awk '{print $1}')" | awk '{print $1}') >/dev/null 2>&1
done

lsusb | while read -r device; do
    apt install -y $(apt-cache search firmware | grep -i "$(echo $device | awk '{print $1}')" | awk '{print $1}') >/dev/null 2>&1
done
