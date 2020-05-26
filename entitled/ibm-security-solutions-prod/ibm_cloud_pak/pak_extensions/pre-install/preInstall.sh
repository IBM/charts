#!/bin/bash
# 
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
#



usage() {
cat << "EOF"
Usage: preInstall.sh [options]
where options are one or more of the following options
-n NAMESPACE              - to use provided namespace instead of current
-force                    - to replace existing secrets  
-cluster username:password - to create secret with ICP cluster credentials
-cert certfile -key keyfile - to associate cp4s ingress with 
                              provided set of SSL keys
-ca certfile                - to provide certificate of CA if not well known
EOF
}

setsecret() {
  secret="$1"
  fields="$2"
  creds="$3"
  type="$4"

  sn=$(kubectl get secret $secret -n $NAMESPACE -o name 2>/dev/null)
  if [ "X$sn" != "X" ]; then
    if [ $FORCE -eq 0 ]; then
      echo "ERROR: Secret $secret already exists"
      exit 1
    fi
    echo "Existing secret $secret would be deleted"
    kubectl delete secret $secret -n $NAMESPACE
  fi

  args=""
  for iteration in 1 2 3 4 5 6 7 8 9 10
  do
    if [ "X$fields" == "X" ]; then
       break
    fi
    if [ "X$creds" == "X" ]; then
       echo "ERROR: Invalid number of credentials for the $type secret"
       exit 1
    fi
    cs="${creds%%:*}"
    fn="${fields%%:*}"
    args="$args "\""--from-literal=$fn=$cs"\"
    f=$(echo "$fields" | sed -e 's/^[^:]*://')
    creds=$(echo "$creds" | sed -e 's/^[^:]*://')
    if [ "X$f" == "X$fields" ]; then
      break
    fi
    fields="$f"
  done

  if [ "X$args" == "X" ]; then
    echo "ERROR: No arguments for the $type provided"
    exit 1
  fi

  str="kubectl create secret generic --namespace $NAMESPACE $secret $args"
  eval $str
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create secret $secret"
    exit 1
  fi
  echo "$secret has been created"
  kubectl patch secret $secret --type merge --patch '{"metadata":{"labels":{"app.kubernetes.io/instance":"'"$secret"'","app.kubernetes.io/managed-by":"ibm-security-solutions-prod","app.kubernetes.io/name":"'"$secret"'"}}}'
}

createTLSSecret() {
  SECRET_NAME="isc-ingress-default-secret"
  KEY_FILE="$1"
  CERT_FILE="$2"

  if [ "X$KEY_FILE" == "X" ]; then
    echo "ERROR: -key parameter not set"
    exit 1
  fi

  if [ "X$CERT_FILE" == "X" ]; then
    echo "ERROR: -cert parameter not set"
    exit 1
  fi

  if [ ! -f $KEY_FILE ]; then
    echo "ERROR: $KEY_FILE not found"
    exit 1
  fi

  if [ ! -f $CERT_FILE ]; then
    echo "ERROR: $CERT_FILE not found"
    exit 1
  fi

  sn=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o name 2>/dev/null)
  if [ "X$sn" != "X" ]; then
    if [ $FORCE -eq 0 ]; then
      echo "ERROR: Secret $SECRET_NAME already exists"
      exit 1
    fi
    echo "Existing secret $SECRET_NAME would be deleted"
    kubectl delete secret $SECRET_NAME -n $NAMESPACE
  fi

  echo "Creating tls secret ${SECRET_NAME}"
  kubectl create secret tls  -n ${NAMESPACE} ${SECRET_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
  kubectl patch secret ${SECRET_NAME} --type merge --patch '{"metadata":{"labels":{"app.kubernetes.io/instance":"isc-ingress-default-secret","app.kubernetes.io/managed-by":"ibm-security-solutions-prod","app.kubernetes.io/name":"isc-ingress-default-secret"}}}'
}


generate_cert() {
  domain="$1"
  subj="/CN=$1"
  caSubj="/CN=CP4SLocalCA"  

  rm -f ca.key ca.crt tls.crt tls.key tls.csr ca.serial openssl.cfg
  openssl genrsa -out ca.key 4096
  if [ $? -ne 0 ]; then
    echo "ERROR: Failed to execute openssl"
    exit 1
  fi
  cat > openssl.cfg <<EOF
[req]
req_extensions = req_ext
x509_extensions = usr_cert
distinguished_name      = req_name

[ req_name ]
commonName = $domain

[ usr_cert ]
basicConstraints=CA:FALSE
nsCertType                      = server
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
subjectAltName = DNS:$domain
[ req_ext ]
subjectAltName = DNS:$domain

EOF

  openssl req -x509 -new -nodes -key ca.key -sha256 -days 825 \
     -subj "$caSubj" -out ca.crt 
  openssl req -nodes -newkey rsa:2048 -keyout tls.key -outform PEM \
     -out tls.csr -subj "$subj" -config openssl.cfg
  openssl x509 -req -sha256 -in tls.csr \
    -out tls.crt \
    -CA ca.crt -CAkey ca.key \
    -CAcreateserial -CAserial ca.serial \
    -days 825 -extensions usr_cert -extfile openssl.cfg

  cat ca.crt >> tls.crt
  createTLSSecret tls.key tls.crt
  provision_CA ca.crt
  rm -f ca.key ca.crt tls.crt tls.key tls.csr ca.serial openssl.cfg
}

set_namespace()
{
  NAMESPACE="$1"
  ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null) 
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
}

provision_CA() {
  data=$1
  secret="isc-custom-ca"

  sn=$(kubectl get secret $secret -n $NAMESPACE -o name 2>/dev/null)
  if [ "X$sn" != "X" ]; then
    if [ $FORCE -eq 0 ]; then
      echo "ERROR: Secret $secret already exists"
      exit 1
    fi
    echo "Existing secret $secret would be deleted"
    kubectl delete secret $secret -n $NAMESPACE
  fi

  kubectl create secret generic $secret -n $NAMESPACE \
    --from-file=ca.crt=$data
}

keyfile_path=""
certfile_path=""
cafile_path=""
cluster_params=""
domain=""
FORCE=0
NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')

while true
do
  arg="$1"
  if [ "X$1" == "X" ]; then
    break
  fi
  shift
  case $arg in
    -n)
      set_namespace "$1"
      shift
      ;;
    -force)
      FORCE=1
      ;;
    -cluster)
      cluster_params="$1"
      shift
      ;;
    -key)
      keyfile_path="$1"
      shift
      ;;
    -cert)
      certfile_path="$1"
      shift
      ;; 
    -ca)
      cafile_path="$1"
      if [ ! -f $cafile_path ]; then 
         echo "File $cafile_path not found"
         exit 1
      fi
      shift
      ;;
    -selfsigned)
      domain="$1"
      shift
      ;;
    *)
      echo "Invalid argument: $arg"
      usage
      exit 1
  esac
done

if [ "X$cluster_params" != "X" ]; then
      sname="platform-secret-default"
      fnames="admin:key"
      setsecret $sname $fnames "$cluster_params" "-cluster"
fi

if [ "X${keyfile_path}${certfile_path}" != "X" ]; then
      createTLSSecret $keyfile_path $certfile_path
fi

if [ "X$cafile_path" != "X" ]; then
    provision_CA $cafile_path
fi 

if [ "X$domain" != "X" ]; then
    generate_cert "$domain"
fi

exit 0
