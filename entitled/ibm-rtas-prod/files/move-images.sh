#!/usr/bin/env bash
set -e

to=${1:-localhost:32000}
from=${2:-cp.icr.io/cp}

while read i
do
  if command -v docker > /dev/null; then
    docker pull "$from/$i"
    docker tag "$from/$i" "$to/${i%@sha*}"
    docker rmi "$from/$i"
    docker push "$to/${i%@sha*}"
    docker rmi "$to/${i%@sha*}"
  elif command -v k3s > /dev/null; then
    k3s ctr images pull $PULL_ARGUMENTS "$from/$i"
    k3s ctr images push "$to/${i%@sha*}" "$from/$i"
    k3s ctr images remove "$from/$i"
  fi
done <<EOF
ibm-rpta:10.1.2
ibm-rtas-base-jdk8:10.1.2
ibm-rtas-busybox:1.31
ibm-rtas-datasets:07aed00@sha256:91e7b95c3b30ee46b0aba72f1383457295ae3bb858ddcf5c1ee1d88d9ad841d4
ibm-rtas-execution:07aed00@sha256:8c343e1502e77e535a4bae1fb66e3e0b73847ed6b1aee699e85e7a0663ca459e
ibm-rtas-frontend:07aed00@sha256:d294ff82def07748510a7da362095b73a8f1c48eaf8a3d077d52ba7e67ff193c
ibm-rtas-gateway:07aed00@sha256:aaa92a0574d1bf5dc9bdddc507f3733c19873749e9e55040b78bc6dbb169a51b
ibm-rtas-keycloak:9.0.2
ibm-rtas-keycloak-theme:07aed00@sha256:945bdaeceb9f98ae7c14709dd270454a7106521f9c8342cc4868593055d447cf
ibm-rtas-postgresql:11.7.0-debian-10-r90
ibm-rtas-rabbitmq:3.8.9-debian-10-r0
ibm-rtas-results:07aed00@sha256:9ba912bca55100fb6b3a7efadbfc510cb6eac7b444782cbc0c103fb621549a96
ibm-rtas-rm:07aed00@sha256:aa978c43a48e9c261e80aaf3ac1d1a6a4d5db135f598323639c1ac2a718a48de
ibm-rtas-tam:07aed00@sha256:050694a381ec81f24d3974a944e34b770f0ef2f18ceb9af59cfdf990900dd0c3
ibm-rtvs:10.1.2
ibm-rtw:10.1.2
EOF

echo "Product images have been copied to $to. You can use these by adding this helm value:"
echo "  --set global.ibmRtasRegistry=$to"
