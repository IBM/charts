#!/bin/bash
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018, 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################

#### NOTE : 
#### ==========================================================================
#### This script is deprecated and may be removed in a future release
#### ==========================================================================

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin; export PATH

set -e
#set -x

trap '/bin/rm -f ext.cfg' EXIT


if [ -z "$SHA" ]; then
  if [ -z "$RSA" ]; then
    SHA=384
    EC=secp"$SHA"r1
  else
    SHA=256
  fi
fi

USAGE()
{
  echo ''
  echo "$0"
  echo ''
  echo 'This comand creates a Kubernetes secret containing a chain of certificates used to identify both the IBM Cloud App Management server and agents.'
  echo ''
  echo 'Find more information at: http://ibm.biz/app-mgmt-kc'
  echo ''
  echo "Usage: $0 <hostname> [release] [namespace]"
  echo ''
  echo '      hostname: The host name of the IBM Cloud App Management server.'
  echo '       release: The helm release name used to install the IBM Cloud App Management server. (default: ibmcloudappmgmt)'
  echo '     namespace: The kubernetes namespace for the IBM Cloud App Management server. (default: default)'
  echo ' server_secret: The kubernetes secret for the IBM Cloud App Management server (default: <release>-ingress-server).'
  echo ' client_secret: The kubernetes secret for the IBM Cloud App Management agents and data collectors (default: <release>-ingress-client).'
  echo '       archive: The kubernetes secret for archiving all generated IBM Cloud App Management certificates (default: <release>-ingress-archive).'
  echo ''
}

GENERATE_SECRET() {
    echo `cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
}

CN="$1"
if [ -z "$CN" ]; then
  echo 'ERROR: No hostname specified'
  USAGE
  exit 1
fi

release="$2"
if [ -z "$release" ]; then
  release="ibmcloudappmgmt"
fi


kube_ns="$3"
if [ -z "$kube_ns" ]; then
  kube_ns="default"
fi

server_secret="$4"
if [ -z "$server_secret" ] ; then
  server_secret=${release}-ingress-tls
fi

client_secret="$5"
if [ -z "$client_secret" ]; then
  client_secret=${release}-ingress-client
fi

archive="$6"
if [ -z "$archive" ]; then
  archive=${release}-ingress-artifacts
fi

DN='/C=US/ST=New York/L=Armonk/O=International Business Machines Corporation/OU=IBM Cloud App Management/CN='
days=10951
pfx=integration


#Root CA
subject="$pfx"ca
if [ -z "$RSA" ]; then
  openssl ecparam -name $EC -genkey -noout -out "$subject".key
else
  openssl genrsa $RSA >"$subject".key
fi
cat > ext.cfg <<EOF
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always, issuer
basicConstraints = critical, CA:true
keyUsage = digitalSignature, keyCertSign, cRLSign
EOF

openssl req -new -x509 -sha$SHA -days $days -key "$subject".key -out "$subject".crt -subj "$DN""Root CA"


#Signer CA
issuer=$subject
subject="$pfx"signer

if [ -z "$RSA" ]; then
  openssl ecparam -name $EC -genkey -noout -out "$subject".key
else
  openssl genrsa $RSA >"$subject".key
fi

cat > ext.cfg <<EOF
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always, issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = digitalSignature, keyCertSign, cRLSign
EOF

openssl req -sha$SHA -new -key "$subject".key -subj "$DN""Signer CA" -out "$subject".csr
sn=0x`head -c 8 /dev/urandom | od -A n -v -t x1 | tr -d ' \n'`
openssl x509 -req -days $days -sha$SHA -in "$subject".csr -CA "$issuer".crt\
        -CAkey "$issuer".key -set_serial $sn -extfile ext.cfg \
        -out "$subject".crt


#Server certificate
issuer=$subject
subject="$pfx"server

if [ -z "$RSA" ]; then
  openssl ecparam -name $EC -genkey -noout -out "$subject".key
else
  openssl genrsa $RSA >"$subject".key
fi

cat > ext.cfg <<EOF
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always, issuer
basicConstraints = critical, CA:false
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName = DNS:$CN
EOF

openssl req -sha$SHA -new -key "$subject".key -subj "$DN""`echo $CN | head -c64`" -out "$subject".csr
sn=0x`head -c 8 /dev/urandom | od -A n -v -t x1 | tr -d ' \n'`
openssl x509 -req -days $days -sha$SHA -in "$subject".csr -CA "$issuer".crt\
        -CAkey "$issuer".key -set_serial $sn -extfile ext.cfg \
        -out "$subject".crt


#Client Certificate
subject="$pfx"client

if [ -z "$RSA" ]; then
  openssl ecparam -name $EC -genkey -noout -out "$subject".key
else
  openssl genrsa $RSA >"$subject".key
fi

cat > ext.cfg <<EOF
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always, issuer
basicConstraints = critical, CA:false
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage=clientAuth
EOF

openssl req -sha$SHA -new -key "$subject".key -subj "$DN""Integration Client" -out "$subject".csr
sn=0x`head -c 8 /dev/urandom | od -A n -v -t x1 | tr -d ' \n'`
openssl x509 -req -days $days -sha$SHA -in "$subject".csr -CA "$issuer".crt\
        -CAkey "$issuer".key -set_serial $sn -extfile ext.cfg \
        -out "$subject".crt

#Create PEMs
openssl x509 -in "$pfx"signer.crt -subject -issuer >  "$pfx"cas.pem
openssl x509 -in "$pfx"ca.crt     -subject -issuer >> "$pfx"cas.pem

echo "$(GENERATE_SECRET)" > "$pfx"client.password

#Create secret artifacts required by kube-ingress
kubectl create secret generic "${server_secret}" --namespace="${kube_ns}" \
  --from-file=tls.crt="${pfx}server.crt" --from-file=tls.key="${pfx}server.key" \
  --from-file=ca.crt="${pfx}cas.pem"

kubectl create secret generic "${client_secret}" --namespace="${kube_ns}" \
  --from-file=client.crt="${pfx}client.crt" --from-file=client.key="${pfx}client.key" \
  --from-file=client.password="${pfx}client.password"  --from-file=ca.crt="${pfx}cas.pem"

#Save all certificates and keys
kubectl create secret generic "${archive}" \
  --namespace="${kube_ns}" \
  --from-file=ca.crt="${pfx}ca.crt" --from-file=ca.key="${pfx}ca.key" \
  --from-file=signer.crt="${pfx}signer.crt" --from-file=signer.key="${pfx}signer.key" \
  --from-file=server.crt="${pfx}server.crt" --from-file=server.key="${pfx}server.key" \
  --from-file=client.crt="${pfx}client.crt" --from-file=client.key="${pfx}client.key" \
  --from-file=client.password="${pfx}client.password"

patch_str='{"metadata":{"labels":{"release":"'${release}'"}}}'

kubectl patch secret "${server_secret}" --namespace="${kube_ns}"  -p "${patch_str}"
kubectl patch secret "${client_secret}" --namespace="${kube_ns}"  -p "${patch_str}"
kubectl patch secret "${archive}"       --namespace="${kube_ns}"  -p "${patch_str}"

#Cleanup - don't leave potentially sensitive files laying around
rm -f ${pfx}server.pem ${pfx}cas.pem
for i in ca signer server client; do
  rm -f "${pfx}${i}.crt" "${pfx}${i}.key" "${pfx}${i}.csr" "${pfx}${i}.password"
done
exit
