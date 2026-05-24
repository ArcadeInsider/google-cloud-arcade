#!/bin/bash

clear

echo "=========================================="
echo "     🚀 PERKVERSE AUTO LAB SCRIPT 🚀"
echo "=========================================="

read -p "Enter Zone: " ZONE

REGION=${ZONE%-*}

gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

echo "Creating VM..."

gcloud compute instances create gcelab \
--machine-type=n1-standard-1 \
--zone=$ZONE

echo "Creating Disk..."

gcloud compute disks create mydisk \
--size=200GB \
--zone=$ZONE

echo "Attaching Disk..."

gcloud compute instances attach-disk gcelab \
--disk=mydisk \
--zone=$ZONE

sleep 15

echo "Formatting and Mounting Disk..."

gcloud compute ssh gcelab --zone=$ZONE --command='
DEVICE=$(lsblk -dpno NAME | grep -v sda | head -n 1)

sudo mkfs.ext4 -F $DEVICE

sudo mkdir -p /mnt/mydisk

sudo mount $DEVICE /mnt/mydisk

echo "$DEVICE /mnt/mydisk ext4 defaults 0 2" | sudo tee -a /etc/fstab

df -h
'

echo "=========================================="
echo "        ✅ LAB FINISHED SUCCESSFULLY"
echo "=========================================="
