#!/bin/bash
echo "Automatic create ema certificate"

mkdir -p /tmp/ema-certs
# cp san.conf /tmp/ema-certs
# cp sanExternal.conf /tmp/ema-certs
cd /tmp/ema-certs

cat>san.conf<<EOF
[ req ]
prompt = no
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = req_ext
[ req_distinguished_name ]
countryName       = US
organizationName  = IBM
commonName        = *.*.svc.cluster.local
[ req_ext ]
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = ema-landing-page-service
DNS.2 = ema-studio-service
DNS.3 = ema-sample-app-service
DNS.4 = ema-admin-console-service
DNS.5 = ema-api-service
DNS.6 = ema-multi-tenant-service
DNS.7 = ema-multi-tenant-service.${EMA_NAMESPACE}
DNS.8 = ema-monitor-service
DNS.9 = ema-maximo-integration-service
DNS.10 = ema-crawler-service
DNS.11 = ema-provision-service
DNS.12 = ema-diagnosis-service
DNS.13 = ema-diagnosis-dataloader-service
DNS.14 = ema-addon.${ICP4D_NAMESPACE}
DNS.15 = ema-service-provider.${ICP4D_NAMESPACE}
DNS.16 = ema-auth-service.${ICP4D_NAMESPACE}
EOF

cat>sanExternal.conf<<EOF
[ req ]
prompt = no
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = req_ext
[ req_distinguished_name ]
countryName       = US
organizationName  = IBM
commonName        = ema.mycluster.icp
[ req_ext ]
subjectAltName = @alt_names
[ alt_names ]
DNS.1 = ema.mycluster.icp
EOF

echo "internal tls"
echo "generate ea-dev-internal.key"
openssl genrsa -out ea-dev-internal.key 2048

echo "generate ea-dev-internal.csr"
openssl req -new -sha256 -key ea-dev-internal.key -out ea-dev-internal.csr -config san.conf

echo "apply ea-dev-internal.csr"
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: ea-dev-internal-csr
spec:
  groups:
  - system:authenticated
  request: $(cat ea-dev-internal.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF

echo "approve ea-dev-internal-csr"
kubectl certificate approve ea-dev-internal-csr

kubectl describe csr ea-dev-internal-csr

kubectl get csr ea-dev-internal-csr -o jsonpath='{.status.certificate}' | base64 --decode > ea-dev-internal.crt

openssl x509 -text -in ea-dev-internal.crt

echo "apply ema-tls"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ema-tls
type: Opaque
data:
  tls.key: $(cat ea-dev-internal.key | base64 | tr -d '\n')
  tls.crt: $(cat ea-dev-internal.crt | base64 | tr -d '\n')
EOF

echo "apply ema-tls"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ema-tls
  namespace: ${ICP4D_NAMESPACE}
type: Opaque
data:
  tls.key: $(cat ea-dev-internal.key | base64 | tr -d '\n')
  tls.crt: $(cat ea-dev-internal.crt | base64 | tr -d '\n')
EOF

echo "external tls"
echo "generate ea-dev-external.key"
openssl genrsa -out ea-dev-external.key 2048

echo "generate ea-dev-external.csr"
openssl req -new -sha256 -key ea-dev-external.key -out ea-dev-external.csr -config sanExternal.conf

echo "apply ea-dev-external.csr"
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: ea-dev-external-csr
spec:
  groups:
  - system:authenticated
  request: $(cat ea-dev-external.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF

echo "approve ea-dev-external-csr"
kubectl certificate approve ea-dev-external-csr

kubectl describe csr ea-dev-external-csr

kubectl get csr ea-dev-external-csr -o jsonpath='{.status.certificate}' | base64 --decode > ea-dev-external.crt

openssl x509 -text -in ea-dev-external.crt

echo "apply mycluster-tls"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: mycluster-tls
type: Opaque
data:
  tls.key: $(cat ea-dev-external.key | base64 | tr -d '\n')
  tls.crt: $(cat ea-dev-external.crt | base64 | tr -d '\n')
EOF

rm -rf /tmp/ema-certs

kubectl delete CertificateSigningRequest ea-dev-internal-csr

kubectl delete CertificateSigningRequest ea-dev-external-csr

echo "complete"