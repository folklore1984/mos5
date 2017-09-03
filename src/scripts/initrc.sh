#!/bin/bash -e

# We default to classicial interface naming.
ln -sf /etc/init.d/net.lo /etc/init.d/net.eth0
touch /etc/udev/rules.d/80-net-name-slot.rules

rc-update add fcron default
rc-update add net.eth0 default
rc-update add sshd default
rc-update add dbus default
rc-update add syslog-ng default
