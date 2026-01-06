#!/bin/bash
set -e

# ================== COLORS ==================
CYAN='\033[0;96m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
RED='\033[0;91m'
BOLD='\033[1m'
RESET='\033[0m'

clear

# ================== WELCOME ==================
echo -e "${CYAN}${BOLD}==================================================${RESET}"
echo -e "${CYAN}${BOLD}     CAMPUSPERKS 🚀 ARCADE LAB AUTO EXECUTION     ${RESET}"
echo -e "${CYAN}${BOLD}==================================================${RESET}"
echo -e "${GREEN}${BOLD}   Easy • Direct • One-Click Commands${RESET}"
echo

# ================== INPUT ==================
read -p "$(echo -e ${YELLOW}${BOLD}Enter ZONE (example: us-central1-a): ${RESET})" ZONE
read -p "$(echo -e ${YELLOW}${BOLD}Enter SECOND REGION (example: us-east1): ${RESET})" REGION_2

REGION="${ZONE%-*}"
PROJECT_ID=$(gcloud config get-value project)

export PROJECT_ID ZONE REGION REGION_2

echo
echo -e "${GREEN}${BOLD}Project ID:${RESET} $PROJECT_ID"
echo -e "${GREEN}${BOLD}Region:${RESET} $REGION"
echo -e "${GREEN}${BOLD}Zone:${RESET} $ZONE"
echo

# ================== NETWORK SETUP ==================
gcloud compute networks create managementnet --subnet-mode=custom || true

gcloud compute networks subnets create managementsubnet-1 \
--network=managementnet \
--region=$REGION \
--range=10.130.0.0/20 || true

gcloud compute networks create privatenet --subnet-mode=custom || true

gcloud compute networks subnets create privatesubnet-1 \
--network=privatenet \
--region=$REGION \
--range=172.16.0.0/24 || true

gcloud compute networks subnets create privatesubnet-2 \
--network=privatenet \
--region=$REGION_2 \
--range=172.20.0.0/20 || true

# ================== FIREWALL RULES ==================
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
--network=managementnet \
--allow=icmp,tcp:22,tcp:3389 \
--source-ranges=0.0.0.0/0 || true

gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
--network=privatenet \
--allow=icmp,tcp:22,tcp:3389 \
--source-ranges=0.0.0.0/0 || true

# ================== VM CREATION ==================
gcloud compute instances create managementnet-vm-1 \
--zone=$ZONE \
--machine-type=e2-micro \
--subnet=managementsubnet-1 || true

gcloud compute instances create privatenet-vm-1 \
--zone=$ZONE \
--machine-type=e2-micro \
--subnet=privatesubnet-1 || true

gcloud compute instances create vm-appliance \
--zone=$ZONE \
--machine-type=e2-standard-4 \
--network-interface=subnet=privatesubnet-1 \
--network-interface=subnet=managementsubnet-1 || true

# ================== COMPLETED ==================
echo
echo -e "${CYAN}${BOLD}==================================================${RESET}"
echo -e "${GREEN}${BOLD}   🎉 LAB COMPLETED SUCCESSFULLY – CAMPUSPERKS 🎉 ${RESET}"
echo -e "${CYAN}${BOLD}==================================================${RESET}"
echo
echo -e "${RED}${BOLD}🔗 https://www.youtube.com/@CampusPerkss${RESET}"
echo -e "${GREEN}${BOLD}Like 👍 | Share 🔁 | Subscribe 🔔${RESET}"

