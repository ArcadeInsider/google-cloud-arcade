#!/bin/bash

# ==========================================================
#  Google Cloud Arcade Lab: Building a High-throughput VPN
#  Crafted for CampusPerks (Arcade Labs Simplified)
# ==========================================================

# Define color variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
ORANGE_TEXT=$'\033[38;5;214m'  

RESET_FORMAT=$'\033[0m'

# Define text formatting variables
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}   CAMPUSPERKS | BUILDING A HIGH-THROUGHPUT VPN LAB   ${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

# =============================
# REGION INPUT
# =============================
read -p "${ORANGE_TEXT}${BOLD_TEXT}Enter REGION_1 (example: us-east1): ${RESET_FORMAT}" REGION_1
read -p "${ORANGE_TEXT}${BOLD_TEXT}Enter REGION_2 (example: us-central1): ${RESET_FORMAT}" REGION

export REGION_1
export REGION

echo "${ORANGE_TEXT}${BOLD_TEXT}Automatically selecting zones...${RESET_FORMAT}"

export ZONE_1=$(gcloud compute zones list \
  --filter="region:($REGION_1)" \
  --format="value(name)" | head -n 1)

export ZONE_2=$(gcloud compute zones list \
  --filter="region:($REGION)" \
  --format="value(name)" | head -n 1)

if [[ -z "$ZONE_1" || -z "$ZONE_2" ]]; then
  echo "${RED_TEXT}❌ Invalid region entered.${RESET_FORMAT}"
  exit 1
fi

echo "${GREEN_TEXT}Using:${RESET_FORMAT}"
echo "${GREEN_TEXT} REGION_1=$REGION_1 → ZONE_1=$ZONE_1${RESET_FORMAT}"
echo "${GREEN_TEXT} REGION_2=$REGION → ZONE_2=$ZONE_2${RESET_FORMAT}"
echo

# =============================
# NETWORK SETUP
# =============================
echo "${ORANGE_TEXT}${BOLD_TEXT}Creating cloud network...${RESET_FORMAT}"
gcloud compute networks create cloud --subnet-mode custom

echo "${ORANGE_TEXT}${BOLD_TEXT}Creating cloud firewall...${RESET_FORMAT}"
gcloud compute firewall-rules create cloud-fw --network cloud --allow tcp:22,tcp:5001,udp:5001,icmp

echo "${ORANGE_TEXT}${BOLD_TEXT}Creating cloud subnet...${RESET_FORMAT}"
gcloud compute networks subnets create cloud-east --network cloud \
  --range 10.0.1.0/24 --region $REGION_1

echo "${ORANGE_TEXT}${BOLD_TEXT}Creating on-prem network...${RESET_FORMAT}"
gcloud compute networks create on-prem --subnet-mode custom

echo "${ORANGE_TEXT}${BOLD_TEXT}Creating on-prem firewall...${RESET_FORMAT}"
gcloud compute firewall-rules create on-prem-fw --network on-prem --allow tcp:22,tcp:5001,udp:5001,icmp

echo "${ORANGE_TEXT}${BOLD_TEXT}Creating on-prem subnet...${RESET_FORMAT}"
gcloud compute networks subnets create on-prem-central \
  --network on-prem --range 192.168.1.0/24 --region $REGION

# =============================
# VPN CONFIGURATION
# =============================
echo "${ORANGE_TEXT}${BOLD_TEXT}Creating VPN gateways...${RESET_FORMAT}"
gcloud compute target-vpn-gateways create on-prem-gw1 --network on-prem --region $REGION
gcloud compute target-vpn-gateways create cloud-gw1 --network cloud --region $REGION_1

echo "${ORANGE_TEXT}${BOLD_TEXT}Allocating IPs...${RESET_FORMAT}"
gcloud compute addresses create cloud-gw1 --region $REGION_1
gcloud compute addresses create on-prem-gw1 --region $REGION

cloud_gw1_ip=$(gcloud compute addresses describe cloud-gw1 --region $REGION_1 --format='value(address)')
on_prem_gw_ip=$(gcloud compute addresses describe on-prem-gw1 --region $REGION --format='value(address)')

echo "${ORANGE_TEXT}${BOLD_TEXT}Creating VPN tunnels...${RESET_FORMAT}"
gcloud compute vpn-tunnels create on-prem-tunnel1 \
  --peer-address $cloud_gw1_ip \
  --target-vpn-gateway on-prem
