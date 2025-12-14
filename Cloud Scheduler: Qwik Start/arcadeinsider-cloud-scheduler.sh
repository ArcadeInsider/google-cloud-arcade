#!/bin/bash
set -e

# ---------------- COLORS ----------------
BLACK=$(tput setaf 0)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
RESET=$(tput sgr0)
BG_CYAN=$(tput setab 6)
BG_GREEN=$(tput setab 2)
BG_BLUE=$(tput setab 4)

clear

echo "${BG_CYAN}${BLACK}${BOLD}  Welcome to Arcade Insider - Google Cloud Arcade  ${RESET}"
echo
echo "${CYAN}${BOLD}Lab Name:${RESET} Cloud Scheduler: Qwik Start"
echo

# ---------------- VARIABLES ----------------
TOPIC_NAME="arcade-topic"
SUB_NAME="arcade-sub"
JOB_NAME="arcade-job"
MESSAGE="hello from arcade insider"
SCHEDULE="* * * * *"
TIMEZONE="Etc/UTC"

# ---------------- FUNCTIONS ----------------
log() {
  echo
  echo "${YELLOW}${BOLD}>>> $1${RESET}"
}

# ---------------- STEP 1 ----------------
log "Enabling required APIs"
gcloud services enable pubsub.googleapis.com cloudscheduler.googleapis.com

# ---------------- STEP 2 ----------------
log "Creating Pub/Sub topic"
gcloud pubsub topics create $TOPIC_NAME || true

log "Creating Pub/Sub subscription"
gcloud pubsub subscriptions create $SUB_NAME \
  --topic=$TOPIC_NAME || true

# ---------------- STEP 3 ----------------
echo
read -p "Enter Cloud Scheduler location (example: us-central1): " LOCATION

# ---------------- STEP 4 ----------------
log "Creating Cloud Scheduler job"
gcloud scheduler jobs create pubsub $JOB_NAME \
  --schedule="$SCHEDULE" \
  --time-zone="$TIMEZONE" \
  --topic="$TOPIC_NAME" \
  --message-body="$MESSAGE" \
  --location="$LOCATION" || true

# ---------------- STEP 5 ----------------
log "Waiting for scheduler to run..."
sleep 65

log "Pulling Pub/Sub messages"
gcloud pubsub subscriptions pull $SUB_NAME --limit=5 --auto-ack || true

# ---------------- DONE ----------------
echo
echo "${BG_GREEN}${BLACK}${BOLD} 🎉 LAB COMPLETED SUCCESSFULLY 🎉 ${RESET}"
echo
echo "${BG_BLUE}${WHITE}${BOLD} Arcade Insider | Google Cloud Arcade ${RESET}"
echo "${CYAN}${BOLD}YouTube:${RESET} https://www.youtube.com/@ArcadeInsider"
echo
