#!/bin/bash
set -e

# ================= COLORS =================
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

clear

# ================= BANNER =================
echo
echo -e "${CYAN}${BOLD}========================================================${RESET}"
echo -e "${YELLOW}${BOLD}   CAMPUSPERKS 🚀 | ARCADE LAB: Multiple VPC Networks   ${RESET}"
echo -e "${CYAN}${BOLD}========================================================${RESET}"
echo
echo -e "${GREEN}${BOLD}Easy • Direct • One-Click Execution${RESET}"
echo

# ================= INPUT =================
read -p "${MAGENTA}${BOLD}Enter ZONE (ex: us-central1-a): ${RESET}" ZONE
read -p "${MAGENTA}${BOLD}Enter SECOND REGION (ex: us-east1): ${RESET}" REGION_2

export ZONE REGION_2
export REGION="${ZONE%-*}"
export PROJECT_ID=$(gcloud config get-value project)

echo
echo -e "${YELLOW}${BOLD}Project ID:${RESET} $PROJECT_ID"
echo -e "${YELLOW}${BOLD}Region 1:${RESET} $REGION"
echo -e "${YELLOW}${BOLD}Region 2:${RESET} $REGION_2"
echo

# ================= NETWORK SETUP =================
gcloud compute networks create managementnet \
  --subnet-mode=custom || true

gcloud compute networks subnets create managementsubnet-1 \
  --network=managementnet \
  --region=$REGION \
  --range=10.130.0.0/20 || true

gcloud compute networks create privatenet \
  --subnet-mode=custom || true

gcloud compute networks subnets create privatesubnet-1 \
  --network=privatenet \
  --region=$REGION \
  --range=172.16.0.0/24 || true

gcloud compute networks subnets create privatesubnet-2 \
  --network=privatenet \
  --region=$REGION_2 \
  --range=172.20.0.0/20 || true

# ================= FIREWALL RULES =================
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
  --network=managementnet \
  --allow=icmp,tcp:22,tcp:3389 \
  --source-ranges=0.0.0.0/0 || true

gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
  --network=privatenet \
  --allow=icmp,tcp:22,tcp:3389 \
  --source-ranges=0.0.0.0/0 || true

# ================= VM CREATION =================
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

# ================= FINAL MESSAGE =================
echo
echo -e "${GREEN}${BOLD}========================================================${RESET}"
echo -e "${GREEN}${BOLD} 🎉 LAB COMPLETED SUCCESSFULLY – Multiple VPC Networks 🎉${RESET}"
echo -e "${GREEN}${BOLD}========================================================${RESET}"
echo
echo -e "${RED}${BOLD}Subscribe: https://www.youtube.com/@CampusPerkss${RESET}"
echo -e "${CYAN}${BOLD}Like • Share • Support CAMPUSPERKS 🚀${RESET}"
echo
