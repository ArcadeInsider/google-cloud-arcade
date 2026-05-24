#!/bin/bash

clear

echo "=========================================="
echo "     🚀 PERKVERSE AUTO LAB FIX SCRIPT 🚀"
echo "=========================================="

ZONE="us-east1-c"

echo "Setting zone..."
gcloud config set compute/zone $ZONE

echo "Cleaning old resources..."

gcloud compute instances delete gcelab \
--zone=$ZONE -q 2>/dev/null

gcloud compute instances delete tempvm \
--zone=$ZONE -q 2>/dev/null

gcloud compute disks delete mydisk \
--zone=$ZONE -q 2>/dev/null

sleep 5

echo "Creating warmup VM..."

gcloud compute instances create tempvm \
--machine-type=e2-micro \
--zone=$ZONE

if [ $? -ne 0 ]; then
    echo "❌ Zone completely exhausted."
    echo "👉 End Lab and Start Again."
    exit 1
fi

echo "Deleting warmup VM..."

gcloud compute instances delete tempvm \
--zone=$ZONE -q

sleep 5

echo "Creating required VM..."

gcloud compute instances create gcelab \
--machine-type=n1-standard-1 \
--zone=$ZONE

if [ $? -ne 0 ]; then
    echo "❌ n1-standard-1 unavailable in this zone."
    echo "👉 Restart lab or retry later."
    exit 1
fi

echo "Creating disk..."

gcloud compute disks create mydisk \
--size=200GB \
--zone=$ZONE

echo "Attaching disk..."

gcloud compute instances attach-disk gcelab \
--disk=mydisk \
--zone=$ZONE

sleep 15

echo "Formatting and mounting disk..."

gcloud compute ssh gcelab \
--zone=$ZONE \
--command='
sudo mkfs.ext4 -F /dev/sdb
sudo mkdir -p /mnt/mydisk
sudo mount /dev/sdb /mnt/mydisk
echo "/dev/sdb /mnt/mydisk ext4 defaults 0 2" | sudo tee -a /etc/fstab
df -h
'

echo "=========================================="
echo "        ✅ LAB FINISHED SUCCESSFULLY"
echo "=========================================="
