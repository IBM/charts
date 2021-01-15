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

dir="$(cd $(dirname $0) && pwd)/../../.."
cwd="$(pwd)"

usage() {
cat << "EOF"
Usage: preInstall.sh [options]
where options are one or more of the following options
-n NAMESPACE               - to use provided namespace instead of current
-resources                 - apply resources 
-force                     - to replace existing secrets  
-cert certfile -key keyfile [-ca cacert] - to associate cp4s ingress with 
                              provided set of SSL keys
EOF
}

runSubcharts() {
  if [ ! -d $dir/charts ]; then
     echo "INFO: no $dir/chars: subchart execution is skipped"
     return
  fi
  rm -rf /tmp/install.$$
  mkdir /tmp/install.$$
  for dirp in $dir/charts/*
  do
    if [ ! -d $dirp ]; then
      continue
    fi
    chart="$(basename $dirp)"
    script="$dirp/ibm_cloud_pak/pak_extensions/pre-install/preInstall.sh"
    if [ ! -f "$script" ]; then
      continue
    fi
    mkdir -p /tmp/install.$$/$chart
    cp -r $dirp/ibm_cloud_pak /tmp/install.$$/$chart
  done
  for tar in $dir/charts/*.tgz
  do
    chart=$(basename $tar | sed -e 's/-[\.0-9]*.tgz//')
      if [ -d "$root/charts/$chart" ]; then
         continue
      fi
      if [ "X$chart" == "X*.tgz" ]; then
        continue
      fi
      mkdir -p /tmp/install.$$/$chart
      tar -C /tmp/install.$$ -xzf $tar $chart/ibm_cloud_pak 2>/dev/null
  done
  cd /tmp/install.$$
  for script in $(find . -name preInstall.sh)
  do
    script=$(echo $script | sed -e 's!^./!!')
    echo "INFO: Running preInstall for ${script%%/*}"
    bash $script
    rc=$?
    if [ $rc -ne 0 ]; then
      echo "ERROR: preInstall for ${script%%/*} has failed"
      exit 1
    fi
  done
  rm -rf /tmp/install.$$
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
  CA_FILE="$3"

  cd $cwd
  
  if [ "X$KEY_FILE" == "X" ]; then
    echo "ERROR: -key parameter not set"
    exit 1
  fi

  if [ "X$CERT_FILE" == "X" ]; then
    echo "ERROR: -cert parameter not set"
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
  if [ "X$CA_FILE" == "X" ]; then
    kubectl create secret tls  -n ${NAMESPACE} ${SECRET_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
  else
    kubectl create secret generic ${SECRET_NAME} --type=kubernetes.io/tls -n ${NAMESPACE} \
     --from-file=ca.crt=${CA_FILE} \
     --from-file=tls.crt=${CERT_FILE} \
     --from-file=tls.key=${KEY_FILE}
  fi
  kubectl patch secret ${SECRET_NAME} --type merge --patch '{"metadata":{"labels":{"app.kubernetes.io/instance":"isc-ingress-default-secret","app.kubernetes.io/managed-by":"ibm-security-solutions-prod","app.kubernetes.io/name":"isc-ingress-default-secret"}}}'

  kubectl delete isctrust.isc.ibm.com -lapp.kubernetes.io/instance=isc-ingress-default-secret --wait=false 2>/dev/null
  if [ "X$CA_FILE" != "X" ]; then
    cat << EOF | kubectl apply -f -
apiVersion: isc.ibm.com/v1
kind: ISCTrust
metadata:
  name: ${SECRET_NAME}-$$
  labels:
    sort: isc-custom-ca
    app.kubernetes.io/instance: isc-ingress-default-secret
    app.kubernetes.io/managed-by: ibm-security-solutions-prod
    app.kubernetes.io/name: isc-ingress-default-secret
spec:
  field: ca.crt
  secret: isc-ingress-default-secret
EOF
  fi
}


generate_cert() {
  domain="$1"
  subj="/CN=$1"
  caSubj="/CN=CP4SLocalCA"  
  
  cd $cwd

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
  createTLSSecret tls.key tls.crt ca.crt
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

applyDir() {
  adir="$1"
  for file in $(find $adir -type f -name '*.yaml')
  do
     sed -e "s/namespace: NAMESPACE/namespace: $NAMESPACE/" $file |\
      kubectl apply -f -
  done
  if [ $? -ne 0 ]; then
    echo "ERROR: $file update failed"
    exit 1
  fi
}

applyResources() {
  if [ -d "$root/resources" ]; then
     applyDir "$root/resources"
  fi
  if [ ! -d $root/charts ]; then 
    echo "ERROR: Directory $root/charts not found"
    exit 1
  fi
  for tar in $root/charts/*.tgz
  do
      base=$(basename $tar | sed -e 's/-[\.0-9]*.tgz//')
      if [ -d "$root/charts/$base" ]; then
         continue
      fi
      if [ "X$base" == "X*.tgz" ]; then
        continue
      fi
      
      mkdir /tmp/resources.$$
      tar -C /tmp/resources.$$ -xzf $tar $base/resources 2>/dev/null
      if [ -d /tmp/resources.$$/$base/resources ]; then
        applyDir "/tmp/resources.$$/$base/resources"
      fi
      rm -rf /tmp/resources.$$
  done
  
  for dirp in $root/charts/*
  do
      if [ ! -d "$dirp" ]; then
        continue
      fi
      
      if [ -d "$dirp/resources" ]; then
           applyDir "$dirp/resources"
      fi
  done
}

couchResources(){

  csv=$(kubectl get csv -o name | grep couchdb-operator | tail -1) 
  echo "$csv"

  if [ -z $csv ]; then 
    echo "CouchDB Operator not installed"
    echo "Skipping CouchDB Operator pod spec changes"
    return 
  fi 
  cpu=$(kubectl get $csv -o jsonpath='{.spec.install.spec.deployments[0].spec.template.spec.containers[0].resources.limits.cpu}')
  if [ "X$cpu" != "X250m" ]; then 
    echo "----Reducing  CPU limits on CouchDB Operator----"
    kubectl patch $csv --type json -p '[{"op":"replace", "path":"/spec/install/spec/deployments/0/spec/template/spec/containers/0/resources/limits/cpu", "value": "250m"}]'
    return
  else
    echo "CouchDB Operator CPU limits have already been adjusted to $cpu"
  fi
}


root="$(dirname $0)/../../.."
keyfile_path=""
certfile_path=""
cafile_path=""
domain=""
FORCE=0
NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
RESOURCES=0

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
    -resources)
      RESOURCES=1
      ;;
    -force)
      FORCE=1
      ;;
    -key)
      keyfile_path="$1"
      if [ ! -f $keyfile_path ]; then 
         echo "File $keyfile_path not found"
         exit 1
      fi
      shift
      ;;
    -cert)
      certfile_path="$1"
      if [ ! -f $certfile_path ]; then 
         echo "File $certfile_path not found"
         exit 1
      fi
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
    -root)
      root="$1"
      shift
      if [ ! -d $root/resources ]; then
        echo "ERROR: Resource directory not found for root $root"
        exit 1
      fi
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

if [ "X$cafile_path" != "X" ]; then
  if [ "X$certfile_path" == "X" ]; then
    echo "ERROR: parameter -ca requires parameters -cert and -key"
    exit 1
  fi
fi

if [ "X$certfile_path" != "X" ]; then
  if [ "X$keyfile_path" == "X" ]; then
    echo "ERROR: parameter -cert requires parameter -key"
    exit 1
  fi
fi

if [ $RESOURCES -eq 1 ]; then
      applyResources
      runSubcharts
fi

if [ "X${keyfile_path}${certfile_path}" != "X" ]; then
      createTLSSecret $keyfile_path $certfile_path $cafile_path
fi

if [ "X$domain" != "X" ]; then
    generate_cert "$domain"
fi

couchResources

exit 0

