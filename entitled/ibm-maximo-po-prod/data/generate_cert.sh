# Licensed Materials - Property of IBM
# IBM Maximo Production Optimization SaaS
# IBM Maximo Production Optimization On-premises
# ©Copyright IBM Corp. 2018, 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.

#!/bin/bash
echo "Create PO SSL self-signed certificate"
echo $USER
echo $UID

mkdir -p /tmp/po-certs
cd /tmp/po-certs
pwd
ls -lha
ls -lha /

export RANDFILE=/tmp/po-certs/.rnd


HMCERT=
{{- if .Values.ingress.hostname -}}
{{ .Values.ingress.hostname }}
{{- else -}}
ibm-maximo-po.icp.hostname.com
{{- end }}

DNS1=
{{- if .Values.ingress.hostname -}}
{{ .Values.ingress.hostname }}
{{- else -}}
ibm-maximo-po.icp.hostname.com
{{- end }}
DNS3={{ include "couchdb.fullname" . }}

openssl req -x509 -nodes -sha256 -subj "/CN=$HMCERT" \
  -days 36500 -newkey rsa:2048 -keyout cert.key -out cert.crt \
  -reqexts SAN -extensions SAN \
  -config <(printf  "[req]\nreq_extensions = v3_req\ndistinguished_name = req_distinguished_name\n[req_distinguished_name]\n[v3_req]\nsubjectAltName=@alt_names\n[alt_names]\nDNS.1=$DNS1\nDNS.2=$DNS3\n[SAN]\nsubjectAltName=DNS:$DNS1,DNS:$DNS3")

# Helm InstallOrder: https://github.com/kubernetes/helm/blob/master/pkg/tiller/kind_sorter.go#L26
# key=$(kubectl -n {{ .Release.Namespace }} get secret {{ template "ingress.cert.name" . }} -o jsonpath="{.data.tls\.key}")
# [[ "$key" != "aWNw" ]] && exit 0
# kubectl -n {{ .Release.Namespace }} create secret tls {{ template "ingress.cert.name" . }} --cert=cert.crt --key=cert.key
ls -lha
echo "create secret to contain the ssl cert and private key"
cat <<EOF | sed -e "s/^[ \t]*=//" | kubectl apply -f -
=apiVersion: v1
=kind: Secret
=type: kubernetes.io/tls
=metadata:
=  name: {{ template "ingress.cert.name" . }}
=  annotations:
=    "helm.sh/hook": pre-install
=    "helm.sh/hook-delete-policy": before-hook-creation
=    "helm.sh/hook-weight": "2"
=data:
=  tls.crt: $(cat cert.crt | base64 | tr -d '\n')
=  tls.key: $(cat cert.key | base64 | tr -d '\n')
EOF
