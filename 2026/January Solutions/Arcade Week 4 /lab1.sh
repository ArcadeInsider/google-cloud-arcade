## Configuring IAM Permissions with gcloud

#!/bin/bash

# Define text formatting variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Welcome Banner
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}              CAMPUSPERKS CLOUD IAM LAB                  ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}This lab demonstrates IAM role management and VM creation${RESET_FORMAT}"
echo "${WHITE_TEXT}in Google Cloud Platform (Arcade Friendly)${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}=== INITIATING CLOUD CONFIGURATION ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🔑 Authenticating your Google Cloud account...${RESET_FORMAT}"
gcloud auth login --quiet

echo "${BLUE_TEXT}${BOLD_TEXT}📍 Determining default Compute Zone & Region...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo "${GREEN_TEXT}${BOLD_TEXT}✅ Default Zone: ${ZONE}${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Default Region: ${REGION}${RESET_FORMAT}"

echo "${MAGENTA_TEXT}${BOLD_TEXT}⚙️ Configuring gcloud compute settings...${RESET_FORMAT}"
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

echo "${YELLOW_TEXT}${BOLD_TEXT}💻 Creating VM instance 'lab-1'...${RESET_FORMAT}"
gcloud compute instances create lab-1 --zone $ZONE --machine-type=e2-standard-2

echo "${GREEN_TEXT}${BOLD_TEXT}🗺️ Selecting alternative zone in ${REGION}...${RESET_FORMAT}"
export NEWZONE=$(gcloud compute zones list --filter="name~'^$REGION'" \
  --format="value(name)" | grep -v "^$ZONE$" | head -n 1)

echo "${GREEN_TEXT}${BOLD_TEXT}✅ New Zone: ${NEWZONE}${RESET_FORMAT}"

echo "${RED_TEXT}${BOLD_TEXT}🔄 Updating to new zone (${NEWZONE})...${RESET_FORMAT}"
gcloud config set compute/zone $NEWZONE

function check_progress {
    while true; do
        echo
        echo -n "${YELLOW_TEXT}${BOLD_TEXT}🤔 Have you checked Task 1 progress? (Y/N): ${RESET_FORMAT}"
        read -r user_input
        case $user_input in
            [Yy]* )
                echo
                echo "${GREEN_TEXT}${BOLD_TEXT}👍 Continuing with next steps...${RESET_FORMAT}"
                break ;;
            [Nn]* )
                echo
                echo "${RED_TEXT}${BOLD_TEXT}✋ Please check Task 1 first${RESET_FORMAT}" ;;
            * )
                echo
                echo "${MAGENTA_TEXT}${BOLD_TEXT}❓ Please enter Y or N${RESET_FORMAT}" ;;
        esac
    done
}

echo
echo "${CYAN_TEXT}${BOLD_TEXT}*****************************************${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}📊        TASK 1 PROGRESS CHECK        📊${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}*****************************************${RESET_FORMAT}"
echo

check_progress

echo "${BLUE_TEXT}${BOLD_TEXT}👤 Creating 'user2' configuration...${RESET_FORMAT}"
gcloud config configurations create user2 --quiet

echo "${YELLOW_TEXT}${BOLD_TEXT}🔑 Authenticating as 'user2'...${RESET_FORMAT}"
gcloud auth login --no-launch-browser --quiet

echo "${MAGENTA_TEXT}${BOLD_TEXT}⚙️ Configuring 'user2' settings...${RESET_FORMAT}"
gcloud config set project $(gcloud config get-value project --configuration=default) --configuration=user2
gcloud config set compute/zone $(gcloud config get-value compute/zone --configuration=default) --configuration=user2
gcloud config set compute/region $(gcloud config get-value compute/region --configuration=default) --configuration=user2

echo "${GREEN_TEXT}${BOLD_TEXT}🔄 Switching to 'default' configuration...${RESET_FORMAT}"
gcloud config configurations activate default

sudo yum -y install epel-release
sudo yum -y install jq

get_and_export_values() {
    read -p "Enter PROJECTID2: " PROJECTID2
    read -p "Enter USERID2: " USERID2
    read -p "Enter ZONE2: " ZONE2

    export PROJECTID2 USERID2 ZONE2
    echo "export PROJECTID2=$PROJECTID2" >> ~/.bashrc
    echo "export USERID2=$USERID2" >> ~/.bashrc
    echo "export ZONE2=$ZONE2" >> ~/.bashrc
}

get_and_export_values

. ~/.bashrc
gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=roles/viewer

gcloud config configurations activate user2
gcloud config set project $PROJECTID2

gcloud config configurations activate default

gcloud iam roles create devops --project $PROJECTID2 \
--permissions "compute.instances.create,compute.instances.delete,compute.instances.start,compute.instances.stop,compute.instances.update,compute.disks.create,compute.subnetworks.use,compute.subnetworks.useExternalIp,compute.instances.setMetadata,compute.instances.setServiceAccount"

gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=roles/iam.serviceAccountUser
gcloud projects add-iam-policy-binding $PROJECTID2 --member user:$USERID2 --role=projects/$PROJECTID2/roles/devops

gcloud config configurations activate user2
gcloud compute instances create lab-2 --zone $ZONE2 --machine-type=e2-standard-2

gcloud config configurations activate default
gcloud config set project $PROJECTID2

gcloud iam service-accounts create devops --display-name devops
SA=$(gcloud iam service-accounts list --format="value(email)" --filter "displayName=devops")

gcloud projects add-iam-policy-binding $PROJECTID2 --member serviceAccount:$SA --role=roles/iam.serviceAccountUser
gcloud projects add-iam-policy-binding $PROJECTID2 --member serviceAccount:$SA --role=roles/compute.instanceAdmin

gcloud compute instances create lab-3 --zone $ZONE2 --machine-type=e2-standard-2 \
--service-account $SA --scopes "https://www.googleapis.com/auth/compute"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}         LAB COMPLETED SUCCESSFULLY – CAMPUSPERKS        ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}📺 Learn more Cloud Arcade Labs at:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@CampusPerkss${RESET_FORMAT}"
