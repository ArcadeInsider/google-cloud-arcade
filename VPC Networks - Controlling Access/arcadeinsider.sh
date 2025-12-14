#!/bin/bash

# ---------- COLORS ----------
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
CYAN_TEXT=$'\033[0;96m'

BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
RESET_FORMAT=$'\033[0m'

clear

# ---------- WELCOME ----------
echo "${CYAN_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}  VPC NETWORKS – CONTROLLING ACCESS | TECH & CODE EXECUTION   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo

# ---------- ZONE ----------
echo "${YELLOW_TEXT}${BOLD_TEXT}Enter zone (example: us-central1-a):${RESET_FORMAT}"
read ZONE
export ZONE

# ---------- CREATE BLUE VM (TAGGED) ----------
echo "${CYAN_TEXT}${BOLD_TEXT}Creating BLUE VM (with web-server tag)...${RESET_FORMAT}"

gcloud compute instances create blue \
  --zone=$ZONE \
  --machine-type=e2-micro \
  --tags=web-server \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --quiet

# ---------- CREATE GREEN VM (NO TAG) ----------
echo "${CYAN_TEXT}${BOLD_TEXT}Creating GREEN VM (no tag)...${RESET_FORMAT}"

gcloud compute instances create green \
  --zone=$ZONE \
  --machine-type=e2-micro \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --quiet

echo "${GREEN_TEXT}${BOLD_TEXT}VMs created successfully!${RESET_FORMAT}"

# ---------- FIREWALL RULE ----------
echo "${CYAN_TEXT}${BOLD_TEXT}Creating firewall rule for HTTP access...${RESET_FORMAT}"

gcloud compute firewall-rules create allow-http-web-server \
  --allow=tcp:80,icmp \
  --target-tags=web-server \
  --source-ranges=0.0.0.0/0 \
  --quiet

echo "${GREEN_TEXT}${BOLD_TEXT}Firewall rule created successfully!${RESET_FORMAT}"

# ---------- TEST VM ----------
echo "${CYAN_TEXT}${BOLD_TEXT}Creating test-vm...${RESET_FORMAT}"

gcloud compute instances create test-vm \
  --zone=$ZONE \
  --machine-type=e2-micro \
  --quiet

# ---------- BLUE SERVER SETUP ----------
echo "${CYAN_TEXT}${BOLD_TEXT}Configuring BLUE server...${RESET_FORMAT}"

cat > blue.sh <<'EOF'
sudo apt-get update -y
sudo apt-get install nginx-light -y
sudo sed -i '14c\<h1>Welcome to the BLUE server</h1>' /var/www/html/index.nginx-debian.html
sudo systemctl restart nginx
EOF

gcloud compute scp blue.sh blue:/tmp --zone=$ZONE --quiet
gcloud compute ssh blue --zone=$ZONE --quiet --command="bash /tmp/blue.sh"

# ---------- GREEN SERVER SETUP ----------
echo "${CYAN_TEXT}${BOLD_TEXT}Configuring GREEN server...${RESET_FORMAT}"

cat > green.sh <<'EOF'
sudo apt-get update -y
sudo apt-get install nginx-light -y
sudo sed -i '14c\<h1>Welcome to the GREEN server</h1>' /var/www/html/index.nginx-debian.html
sudo systemctl restart nginx
EOF

gcloud compute scp green.sh green:/tmp --zone=$ZONE --quiet
gcloud compute ssh green --zone=$ZONE --quiet --command="bash /tmp/green.sh"

# ---------- FINAL ----------
echo
echo "${GREEN_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}        LAB COMPLETED SUCCESSFULLY 🎉                         ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}==============================================================${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@TechCode9${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Like • Share • Subscribe for more Arcade Labs${RESET_FORMAT}"

# ---------- CLEANUP ----------
rm -f blue.sh green.sh
