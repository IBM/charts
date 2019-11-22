# Licensed Materials - Property of IBM
# IBM Maximo Production Optimization SaaS
# IBM Maximo Production Optimization On-premises
# ©Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.


# The sample code for creating the self-signed certificate related Kubernetes secret. 
# Refer to the below shell script to create the certificate and corresponding private key. 
# Please note that "YOUR-INGRESS-HOSTNAME" should repleased by the hostname of the ingress planned to deploy,
# and "YOUR-RELEASENAME" in the "COUCHDB_HOSTNAME" should be replaced by the exact release name of the installing PO, 
# and "YOUR-RELEASENAME-po-couchdb" is the name of the Counchdb service.

#!/bin/bash
INGRESS_HOSTNAME=YOUR-INGRESS-HOSTNAME
COUCHDB_HOSTNAME=YOUR-RELEASENAME-po-couchdb
(printf  "[req]\nreq_extensions = v3_req\ndistinguished_name = req_distinguished_name\n[req_distinguished_name]\n[v3_req]\nsubjectAltName=@alt_names\n[alt_names]\nDNS.1=$INGRESS_HOSTNAME\nDNS.2=$COUCHDB_HOSTNAME\n[SAN]\nsubjectAltName=DNS:$INGRESS_HOSTNAME,DNS:$COUCHDB_HOSTNAME")

openssl req -x509 -nodes -sha256 -subj "/CN=$INGRESS_HOSTNAME" \
  -days 36500 -newkey rsa:2048 -keyout cert.key -out cert.crt \
  -reqexts SAN -extensions SAN \
  -config <(printf  "[req]\nreq_extensions = v3_req\ndistinguished_name = req_distinguished_name\n[req_distinguished_name]\n[v3_req]\nsubjectAltName=@alt_names\n[alt_names]\nDNS.1=$INGRESS_HOSTNAME\nDNS.2=$COUCHDB_HOSTNAME\n[SAN]\nsubjectAltName=DNS:$INGRESS_HOSTNAME,DNS:$COUCHDB_HOSTNAME")
  
# Then, use base64 to encode the content of the certificate and the private key
cat cert.crt | base64
cat cert.key | base64

#Make a record of the output of the two above commands, to update the po-cert.yaml