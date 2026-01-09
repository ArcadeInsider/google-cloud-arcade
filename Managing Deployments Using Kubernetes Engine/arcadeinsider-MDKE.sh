#!/bin/bash

# Color codes for formatting
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
NC='\e[0m' # No Color

# Function to display spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to print section header
print_header() {
    echo -e "\n${MAGENTA}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC} ${CYAN}$1${NC} ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════╝${NC}"
}

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error()   { echo -e "${RED}❌ $1${NC}"; }
print_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# Welcome banner
echo -e "${CYAN}"
cat << "EOF"
   _____          __  __ ____  _   _ ____  _____ ____  _  __
  / ____|   /\   |  \/  |  _ \| | | |  _ \| ____|  _ \| |/ /
 | |       /  \  | \  / | |_) | | | | |_) |  _| | |_) | ' / 
 | |___   / /\ \ | |\/| |  __/| |_| |  _ <| |___|  _ <| . \ 
  \_____| /_/  \_\|_|  |_|_|    \___/|_| \_\_____|_| \_\_|\_\
EOF
echo -e "${NC}"

echo -e "${YELLOW}📘 Lab:${NC} ${CYAN}Managing Deployments Using Kubernetes Engine${NC}"
echo -e "${MAGENTA}🚀 Powered by:${NC} ${CYAN}CAMPUSPERKS${NC}"
echo -e "${CYAN}🔗 YouTube:${NC} ${WHITE}https://www.youtube.com/@CampusPerkss${NC}"
echo -ne "${GREEN}Initializing Lab Execution:${NC} "
(sleep 3) & spinner $!
echo -e "${GREEN}✅ Ready!${NC}"

# Fetch zone and region
print_header "Fetching Google Cloud Configuration"
ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
PROJECT_ID=$(gcloud config get-value project)

gcloud config set compute/zone $ZONE

# Copy Kubernetes files
print_header "Setting up Kubernetes Resources"
gcloud storage cp -r gs://spls/gsp053/kubernetes .
cd kubernetes

# Create GKE cluster
print_header "Creating GKE Cluster"
gcloud container clusters create bootcamp \
  --machine-type e2-small \
  --num-nodes 3 \
  --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"

# TASK 2
print_header "TASK 2: Fortune App Deployment"
kubectl create -f deployments/fortune-app-blue.yaml
kubectl create -f services/fortune-app.yaml

kubectl scale deployment fortune-app-blue --replicas=5
kubectl get pods | grep fortune-app-blue | wc -l

kubectl scale deployment fortune-app-blue --replicas=3
kubectl get pods | grep fortune-app-blue | wc -l

# TASK 3
print_header "TASK 3: Canary Deployment"
read -p "Proceed with Task 3? (Y/N): " CONFIRM
[[ "$CONFIRM" != "Y" && "$CONFIRM" != "y" ]] && exit 0

kubectl set image deployment/fortune-app-blue fortune-app=$REGION-docker.pkg.dev/qwiklabs-resources/spl-lab-apps/fortune-service:2.0.0
kubectl set env deployment/fortune-app-blue APP_VERSION=2.0.0
kubectl create -f deployments/fortune-app-canary.yaml

# TASK 5
print_header "TASK 5: Blue-Green Deployment"
kubectl apply -f services/fortune-app-blue-service.yaml
kubectl create -f deployments/fortune-app-green.yaml
kubectl apply -f services/fortune-app-green-service.yaml
kubectl apply -f services/fortune-app-blue-service.yaml

# Completion
print_header "LAB COMPLETED SUCCESSFULLY 🎉"
kubectl get deployments
kubectl get services
kubectl get pods

echo -e "${GREEN}🔥 Lab Completed – CAMPUSPERKS${NC}"
echo -e "${CYAN}📺 Subscribe:${NC} ${WHITE}https://www.youtube.com/@CampusPerkss${NC}"
