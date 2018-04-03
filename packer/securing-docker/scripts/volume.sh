#!/bin/bash

sudo mkfs -t ext4 /dev/xvdf
sudo mkdir -p /var/lib/docker

echo "/dev/xvdf /var/lib/docker ext4 defaults,nofail 0 0" | sudo tee -a /etc/fstab

mount -a
