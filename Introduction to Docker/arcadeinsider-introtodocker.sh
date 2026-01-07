#!/bin/bash
set -e

# ================= COLORS =================
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
CYAN_TEXT=$'\033[0;96m'
RESET=$'\033[0m'
BOLD=$'\033[1m'

clear

# ================= WELCOME =================
echo
echo "${CYAN_TEXT}${BOLD}==============================================================${RESET}"
echo "${CYAN_TEXT}${BOLD}   CAMPUSPERKS 🚀 | Arcade Lab – Introduction to Docker        ${RESET}"
echo "${CYAN_TEXT}${BOLD}==============================================================${RESET}"
echo "${GREEN_TEXT}${BOLD}Easy • Direct • One-Click Commands${RESET}"
echo
echo "${YELLOW_TEXT}${BOLD}YouTube:${RESET} https://www.youtube.com/@CampusPerkss"
echo

# ================= INPUT =================
read -p "${YELLOW_TEXT}${BOLD}Enter REGION (example: us-central1): ${RESET}" REGION
echo

# ================= STEP 1 =================
echo "${CYAN_TEXT}${BOLD}Step 1: Creating working directory${RESET}"
mkdir -p campusperks-docker
cd campusperks-docker

# ================= STEP 2 =================
echo "${CYAN_TEXT}${BOLD}Step 2: Creating Dockerfile${RESET}"
cat > Dockerfile <<EOF
FROM node:lts
WORKDIR /app
ADD . /app
EXPOSE 80
CMD ["node", "app.js"]
EOF

# ================= STEP 3 =================
echo "${CYAN_TEXT}${BOLD}Step 3: Creating app.js${RESET}"
cat > app.js <<EOF
const http = require("http");
const server = http.createServer((req, res) => {
  res.writeHead(200, {"Content-Type": "text/plain"});
  res.end("Welcome to CampusPerks – Introduction to Docker\\n");
});
server.listen(80);
EOF

# ================= STEP 4 =================
echo "${CYAN_TEXT}${BOLD}Step 4: Build Docker Image${RESET}"
docker build -t node-app:0.2 .

# ================= STEP 5 =================
echo "${CYAN_TEXT}${BOLD}Step 5: Run Docker Container${RESET}"
docker run -d -p 8080:80 --name campusperks-container node-app:0.2

docker ps
echo

# ================= STEP 6 =================
echo "${CYAN_TEXT}${BOLD}Step 6: Create Artifact Registry${RESET}"
PROJECT_ID=$(gcloud config get-value project)

gcloud artifacts repositories create campusperks-repo \
  --repository-format=docker \
  --location="$REGION" \
  --description="CampusPerks Docker Repo" || true

# ================= STEP 7 =================
echo "${CYAN_TEXT}${BOLD}Step 7: Configure Docker Auth${RESET}"
gcloud auth configure-docker "$REGION-docker.pkg.dev" --quiet

# ================= STEP 8 =================
echo "${CYAN_TEXT}${BOLD}Step 8: Tag & Push Image${RESET}"
docker tag node-app:0.2 \
$REGION-docker.pkg.dev/$PROJECT_ID/campusperks-repo/node-app:0.2

docker push \
$REGION-docker.pkg.dev/$PROJECT_ID/campusperks-repo/node-app:0.2

# ================= CLEANUP =================
echo "${CYAN_TEXT}${BOLD}Step 9: Cleanup${RESET}"
docker stop $(docker ps -q) || true
docker rm $(docker ps -aq) || true
docker rmi $(docker images -aq) || true

# ================= DONE =================
echo
echo "${GREEN_TEXT}${BOLD}==============================================================${RESET}"
echo "${GREEN_TEXT}${BOLD} 🎉 LAB COMPLETED SUCCESSFULLY – CAMPUSPERKS 🎉 ${RESET}"
echo "${GREEN_TEXT}${BOLD}==============================================================${RESET}"
echo
echo "${RED_TEXT}${BOLD}Subscribe:${RESET} https://www.youtube.com/@CampusPerkss"
echo "${GREEN_TEXT}${BOLD}Like 👍 | Share 🔁 | Subscribe 🔔${RESET}"

