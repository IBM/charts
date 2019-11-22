#!/bin/sh

SECRET_NAME=hyc-sp-pullsecret

echo "Enter a few details to set up the Kuberneres secrets."

read -p "Namespace: " namespace
read -p "Docker registry server: " docker_server
read -p "Email: " docker_email
read -p "User: " docker_user
read -s -p "Password: " docker_password

kubectl -n ${namespace} create secret docker-registry ${SECRET_NAME} \
  --docker-server=${docker_server} \
  --docker-email=${docker_email} \
  --docker-username=${docker_user} \
  --docker-password=${docker_password}

echo "Done. Secret '${SECRET_NAME}' has been created"
