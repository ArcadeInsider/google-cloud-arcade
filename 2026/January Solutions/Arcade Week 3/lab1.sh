#!/bin/bash

# ===================== CAMPUSPERKS CLOUD LAB =====================
# YouTube: https://www.youtube.com/@CampusPerkss
# Lab: Global HTTP Load Balancer with Unmanaged Instance Groups
# ================================================================

echo ""
echo ""
echo "🚀 CAMPUSPERKS LAB STARTING..."
echo "Please export the values."
echo ""

# Prompt user to input zones
read -p "Enter ZONE_1 (e.g. us-central1-a): " ZONE_1
read -p "Enter ZONE_2 (e.g. us-east1-b): " ZONE_2

export REGION_1="${ZONE_1%-*}"
export REGION_2="${ZONE_2%-*}"

# -------------------- CREATE VM INSTANCES --------------------

gcloud compute instances create www-1 \
  --image-family debian-11 \
  --image-project debian-cloud \
  --zone $ZONE_1 \
  --tags http-tag \
  --metadata startup-script="#!/bin/bash
apt-get update
apt-get install apache2 -y
systemctl start apache2
systemctl enable apache2
echo '<h1>www-1</h1>' > /var/www/html/index.html"

gcloud compute instances create www-2 \
  --image-family debian-11 \
  --image-project debian-cloud \
  --zone $ZONE_1 \
  --tags http-tag \
  --metadata startup-script="#!/bin/bash
apt-get update
apt-get install apache2 -y
systemctl start apache2
systemctl enable apache2
echo '<h1>www-2</h1>' > /var/www/html/index.html"

gcloud compute instances create www-3 \
  --image-family debian-11 \
  --image-project debian-cloud \
  --zone $ZONE_2 \
  --tags http-tag \
  --metadata startup-script="#!/bin/bash
apt-get update
apt-get install apache2 -y
systemctl start apache2
systemctl enable apache2
echo '<h1>www-3</h1>' > /var/www/html/index.html"

gcloud compute instances create www-4 \
  --image-family debian-11 \
  --image-project debian-cloud \
  --zone $ZONE_2 \
  --tags http-tag \
  --metadata startup-script="#!/bin/bash
apt-get update
apt-get install apache2 -y
systemctl start apache2
systemctl enable apache2
echo '<h1>www-4</h1>' > /var/www/html/index.html"

# -------------------- FIREWALL RULE --------------------

gcloud compute firewall-rules create www-firewall \
  --target-tags http-tag \
  --allow tcp:80

# -------------------- STATIC IP --------------------

gcloud compute addresses create lb-ip-cr \
  --ip-version=IPV4 \
  --global

# -------------------- INSTANCE GROUPS --------------------

gcloud compute instance-groups unmanaged create ${REGION_1}-resources-w \
  --zone $ZONE_1

gcloud compute instance-groups unmanaged create ${REGION_2}-resources-w \
  --zone $ZONE_2

gcloud compute instance-groups unmanaged add-instances ${REGION_1}-resources-w \
  --instances www-1,www-2 \
  --zone $ZONE_1

gcloud compute instance-groups unmanaged add-instances ${REGION_2}-resources-w \
  --instances www-3,www-4 \
  --zone $ZONE_2

# -------------------- HEALTH CHECK --------------------

gcloud compute health-checks create http http-basic-check

gcloud compute instance-groups unmanaged set-named-ports ${REGION_1}-resources-w \
  --named-ports http:80 \
  --zone $ZONE_1

gcloud compute instance-groups unmanaged set-named-ports ${REGION_2}-resources-w \
  --named-ports http:80 \
  --zone $ZONE_2

# -------------------- BACKEND SERVICE --------------------

gcloud compute backend-services create web-map-backend-service \
  --protocol HTTP \
  --health-checks http-basic-check \
  --global

gcloud compute backend-services add-backend web-map-backend-service \
  --balancing-mode UTILIZATION \
  --max-utilization 0.8 \
  --capacity-scaler 1 \
  --instance-group ${REGION_1}-resources-w \
  --instance-group-zone $ZONE_1 \
  --global

gcloud compute backend-services add-backend web-map-backend-service \
  --balancing-mode UTILIZATION \
  --max-utilization 0.8 \
  --capacity-scaler 1 \
  --instance-group ${REGION_2}-resources-w \
  --instance-group-zone $ZONE_2 \
  --global

# -------------------- URL MAP & PROXY --------------------

gcloud compute url-maps create web-map \
  --default-service web-map-backend-service

gcloud compute target-http-proxies create http-lb-proxy \
  --url-map web-map

# -------------------- FORWARDING RULE --------------------

EXTERNAL_IP=$(gcloud compute addresses list --global --format="get(ADDRESS)")

gcloud compute forwarding-rules create http-cr-rule \
  --address $EXTERNAL_IP \
  --global \
  --target-http-proxy http-lb-proxy \
  --ports 80

echo ""
echo "🎉 CAMPUSPERKS LAB COMPLETED SUCCESSFULLY 🎉"
echo "🌍 Load Balancer IP: $EXTERNAL_IP"
echo "📺 Subscribe: https://www.youtube.com/@CampusPerkss"
echo ""
