#!/bin/bash -e

# Set the root password to 'root'
echo root:root | chpasswd

# Create a user 'miner' and set
# the password to 'gentoo'
useradd -m miner
echo miner:gentoo | chpasswd

# Make user 'miner' a power user
gpasswd -a miner disk
gpasswd -a miner audio
gpasswd -a miner video
gpasswd -a miner usb

gpasswd -a portage wheel

# For the grsec groups. Make sure these
# match whats in kernel-config!
groupadd -g 9995 graudit
groupadd -g 9996 grslink
groupadd -g 9997 grasock
groupadd -g 9998 grcsock
groupadd -g 9999 grssock
