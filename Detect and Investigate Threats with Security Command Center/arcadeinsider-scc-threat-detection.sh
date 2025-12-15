#!/bin/bash

# ================== COLOR SETUP ==================
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
RESET_FORMAT=$'\033[0m'

clear

# ================== WELCOME ==================
echo "${CYAN_TEXT}${BOLD_TEXT}========================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}  ARCADEINSIDER | SECURITY COMMAND CENTER LAB STARTED   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}========================================================${RESET_FORMAT}"
echo

set -e

PROJECT_ID=$(gcloud config get-value project)

# ================== GET ZONE & REGION ==================
echo "${YELLOW_TEXT}${BOLD_TEXT}Fetching default zone & region...${RESET_FORMAT}"

ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo "${GREEN_TEXT}Zone: $ZONE | Region: $REGION${RESET_FORMAT}"

# ================== IAM AUDIT CONFIG ==================
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Updating IAM audit configuration...${RESET_FORMAT}"

gcloud projects get-iam-policy "$PROJECT_ID" --format=json > policy.json

jq '.auditConfigs += [{
  "service": "cloudresourcemanager.googleapis.com",
  "auditLogConfigs": [{ "logType": "ADMIN_READ" }]
}]' policy.json > updated_policy.json

gcloud projects set-iam-policy "$PROJECT_ID" updated_policy.json

# ================== ENABLE SCC API ==================
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Enabling Security Command Center API...${RESET_FORMAT}"
gcloud services enable securitycenter.googleapis.com

echo "Waiting for API to activate..."
sleep 20

# ================== TEMP IAM ROLE ==================
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Granting BigQuery Admin role temporarily...${RESET_FORMAT}"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="user:demouser1@gmail.com" \
  --role="roles/bigquery.admin" --quiet

echo "${YELLOW_TEXT}${BOLD_TEXT}Revoking BigQuery Admin role...${RESET_FORMAT}"

gcloud projects remove-iam-policy-binding "$PROJECT_ID" \
  --member="user:demouser1@gmail.com" \
  --role="roles/bigquery.admin" --quiet

# ================== CREATE VM ==================
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating VM instance...${RESET_FORMAT}"

gcloud compute instances create instance-1 \
  --zone="$ZONE" \
  --machine-type=e2-medium \
  --subnet=default \
  --quiet

# ================== DNS POLICY ==================
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating DNS policy...${RESET_FORMAT}"

gcloud dns policies create scc-dns-policy \
  --networks="default" \
  --enable-logging \
  --quiet || true

sleep 20

# ================== TRIGGER FINDING ==================
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Triggering Security Command Center finding...${RESET_FORMAT}"

gcloud compute ssh instance-1 \
  --zone="$ZONE" \
  --quiet \
  --command="curl etd-malware-trigger.goog" || true

# ================== CLEANUP ==================
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Cleaning up resources...${RESET_FORMAT}"

gcloud compute instances delete instance-1 --zone="$ZONE" --quiet || true

# ================== FINAL MESSAGE ==================
echo
echo "${GREEN_TEXT}${BOLD_TEXT}========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}   LAB COMPLETED: Detect & Investigate Threats (SCC)   ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}========================================================${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}YouTube: https://www.youtube.com/@ArcadeInsider${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Like • Share • Subscribe for more Arcade scripts${RESET_FORMAT}"
