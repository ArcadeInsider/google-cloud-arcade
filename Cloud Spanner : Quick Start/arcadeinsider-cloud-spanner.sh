#!/bin/bash

# ================= COLORS =================
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

# ================= WELCOME =================
echo "${CYAN_TEXT}${BOLD_TEXT}============================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}   ARCADEINSIDER | CLOUD SPANNER : QWIK START LAB EXECUTION   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}============================================================${RESET_FORMAT}"
echo

# ================= ASK FOR REGION =================
echo "${YELLOW_TEXT}${BOLD_TEXT}Enter REGION (example: us-central1):${RESET_FORMAT}"
read REGION
export REGION

# ================= ENABLE API =================
echo "${CYAN_TEXT}${BOLD_TEXT}Enabling Cloud Spanner API...${RESET_FORMAT}"
gcloud services enable spanner.googleapis.com --quiet

# ================= CREATE INSTANCE =================
echo "${CYAN_TEXT}${BOLD_TEXT}Creating Spanner Instance...${RESET_FORMAT}"

gcloud spanner instances create test-instance \
  --config=regional-$REGION \
  --description="Test Instance" \
  --nodes=1 \
  --quiet

# ================= CREATE DATABASE =================
echo "${CYAN_TEXT}${BOLD_TEXT}Creating Database...${RESET_FORMAT}"

gcloud spanner databases create example-db \
  --instance=test-instance \
  --quiet

# ================= CREATE TABLE =================
echo "${CYAN_TEXT}${BOLD_TEXT}Creating Singers Table...${RESET_FORMAT}"

gcloud spanner databases ddl update example-db \
  --instance=test-instance \
  --ddl="CREATE TABLE Singers (
    SingerId INT64 NOT NULL,
    FirstName STRING(1024),
    LastName STRING(1024),
    SingerInfo BYTES(MAX),
    BirthDate DATE
  ) PRIMARY KEY (SingerId)" \
  --quiet

# ================= FINAL MESSAGE =================
echo
echo "${GREEN_TEXT}${BOLD_TEXT}============================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}        LAB COMPLETED SUCCESSFULLY 🎉                        ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}============================================================${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@ArcadeInsider${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Like 👍 | Share 🔁 | Subscribe 🔔${RESET_FORMAT}"
echo
