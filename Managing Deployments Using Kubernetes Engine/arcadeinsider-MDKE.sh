#!/bin/bash
set -e

# ================= FIX LINE ENDINGS =================
sed -i 's/\r$//' "$0"

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

# ================= WELCOME =================
echo "${CYAN}${BOLD}==============================================================${RESET}"
echo "${CYAN}${BOLD}  CAMPUSPERKS 🚀 | Managing Deployments Using Kubernetes Engine ${RESET}"
echo "${CYAN}${BOLD}==============================================================${RESET}"
echo "${GREEN}${BOLD}Easy • Direct • One-Click Arcade Commands${RESET}"
echo

# ================= INPUT =================
echo "${YELLOW}${BOLD}Enter ZONE (example: us-central1-a): ${RESET}"
read ZONE

# ================= START =================
echo
echo "${YELLOW}${BOLD}Starting${RESET} ${GREEN}${BOLD}Execution...${RESET}"
echo

gcloud config set compute/zone "$ZONE"

# ================= LAB STEPS =================
gsutil -m cp -r gs://spls/gsp053/orchestrate-with-kubernetes .

cd orchestrate-with-kubernetes/kubernetes

gcloud container clusters create bootcamp \
--machine-type e2-small \
--num-nodes 3 \
--scopes https://www.googleapis.com/auth/projecthosting,storage-rw

sed -i 's|image: "kelseyhightower/auth:2.0.0"|image: "kelseyhightower/auth:1.0.0"|' deployments/auth.yaml

kubectl create -f deployments/auth.yaml
kubectl get deployments
kubectl get pods

kubectl create -f services/auth.yaml
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml

kubectl create secret generic tls-certs --from-file=tls/
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf

kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml

kubectl get services frontend

sleep 10

kubectl scale deployment hello --replicas=5
kubectl get pods | grep hello- | wc -l

kubectl scale deployment hello --replicas=3
kubectl get pods | grep hello- | wc -l

sed -i 's|image: "kelseyhightower/auth:1.0.0"|image: "kelseyhightower/auth:2.0.0"|' deployments/hello.yaml

kubectl get replicaset
kubectl rollout history deployment/hello

kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

kubectl rollout resume deployment/hello
kubectl rollout status deployment/hello
kubectl rollout undo deployment/hello
kubectl rollout history deployment/hello

kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

kubectl create -f deployments/hello-canary.yaml
kubectl get deployments

# ================= DONE =================
echo
echo "${GREEN}${BOLD}==============================================================${RESET}"
echo "${GREEN}${BOLD} 🎉 LAB COMPLETED SUCCESSFULLY – CAMPUSPERKS 🎉 ${RESET}"
echo "${GREEN}${BOLD}==============================================================${RESET}"
echo
echo "${RED}${BOLD}YouTube:${RESET} ${WHITE}${BOLD}https://www.youtube.com/@CampusPerkss${RESET}"
echo "${GREEN}${BOLD}Like 👍 | Share 🔁 | Subscribe 🔔${RESET}"

