#!/bin/bash

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "${CYAN}${BOLD}Welcome to Arcade Insider - Google Cloud Arcade Lab${RESET}"

echo "${YELLOW}${BOLD}Enter Zone (example: us-central1-a):${RESET}"
read ZONE
export ZONE

echo "${BLUE}${BOLD}Creating VM instances...${RESET}"

gcloud compute instances create blue \
--zone=$ZONE \
--machine-type=e2-medium \
--tags=web-server

gcloud compute instances create green \
--zone=$ZONE \
--machine-type=e2-medium

echo "${BLUE}${BOLD}Creating firewall rule...${RESET}"

gcloud compute firewall-rules create allow-http \
--allow tcp:80 \
--target-tags=web-server \
--source-ranges=0.0.0.0/0

echo "${GREEN}${BOLD}Lab completed successfully 🎉${RESET}"

echo "${CYAN}${BOLD}Subscribe: https://youtube.com/@ArcadeInsider${RESET}"