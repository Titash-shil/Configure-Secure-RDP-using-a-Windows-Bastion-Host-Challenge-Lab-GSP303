export REGION=${ZONE%-*}

gcloud compute networks create securenetwork --subnet-mode custom

gcloud compute networks subnets create securenetwork-subnet --network=securenetwork --region $REGION --range=192.168.16.0/20

gcloud compute firewall-rules create rdp-ingress-fw-rule --allow=tcp:3389 --source-ranges 0.0.0.0/0 --target-tags allow-rdp-traffic --network securenetwork

gcloud compute instances create vm-bastionhost --zone=$ZONE --machine-type=e2-medium --network-interface=subnet=securenetwork-subnet --network-interface=subnet=default,no-address --tags=allow-rdp-traffic --image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220513

gcloud compute instances create vm-securehost --zone=$ZONE --machine-type=e2-medium --network-interface=subnet=securenetwork-subnet,no-address --network-interface=subnet=default,no-address --tags=allow-rdp-traffic --image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220513

sleep 300

echo "${CYAN}${BOLD}Resetting ${RESET}""${RED}${BOLD}password${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}vm-bastionhost${RESET}"

gcloud compute reset-windows-password vm-bastionhost --user app_admin --zone $ZONE --quiet

echo "${CYAN}${BOLD}Resetting ${RESET}""${RED}${BOLD}password${RESET}" "${WHITE}${BOLD}for${RESET}" "${BLUE}${BOLD}vm-securehost${RESET}"

gcloud compute reset-windows-password vm-securehost --user app_admin --zone $ZONE --quiet
