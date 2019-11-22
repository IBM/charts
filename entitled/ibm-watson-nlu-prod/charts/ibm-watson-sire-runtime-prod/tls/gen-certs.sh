#!/bin/bash

if [ -z "$1" -o -z "$2" ]; then
  echo "Usage: $0 <svc name> <namespace> [<cluster domain>]"
  exit 1
fi

SVC_NAME=$1
NAMESPACE=$2
CLUSTER_DOMAIN="svc.cluster.local"
if [ -n "$3" ]; then
  CLUSTER_DOMAIN=$3
fi
CN="${SVC_NAME}"
ALT1="${SVC_NAME}.${NAMESPACE}"
ALT2="${SVC_NAME}.${NAMESPACE}.${CLUSTER_DOMAIN}"
# wildcards for distributed mode
ALT3="*.${SVC_NAME}"
ALT4="*.${SVC_NAME}.${NAMESPACE}"
ALT5="*.${SVC_NAME}.${NAMESPACE}.${CLUSTER_DOMAIN}"
SUBJ="/C=US/ST=New York/L=New York/O=IBM Watson/CN=$CN"

cat << EOF > openssl.cnf
[req]
default_bits = 2048
default_keyfile = public.crt
distinguished_name  = req_distinguished_name
req_extensions     = req_ext
x509_extensions = x509_ext
string_mask = utf8only

[req_distinguished_name]
countryName           = Country Name (2 letter code)
countryName_default   = US
stateOrProvinceName   = State or Province Name (full name)
stateOrProvinceName_default = New York
localityName          = Locality Name (eg, city)
localityName_default  = New York
organizationName          = Organization Name (eg, company)
organizationName_default  = IBM Watson
commonName            = Common Name (eg, YOUR name)
commonName_default    = ibm
commonName_max        = 64

[x509_ext]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints = CA:FALSE
subjectAltName = @alt_names

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $CN
DNS.2 = $ALT1
DNS.3 = $ALT2
DNS.4 = $ALT3
DNS.5 = $ALT4
DNS.6 = $ALT5
DNS.7 = localhost
IP.1 = "127.0.0.1"
EOF

openssl genrsa -out private.key 2048
openssl req -new -x509 -days 3650 -key private.key -out public.crt -config openssl.cnf -subj "/C=US/ST=NY/L=NY/O=IBM/CN=$CN"
cp public.crt ca.crt
