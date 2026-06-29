# IBM DevOps Loop

## Introduction

IBM DevOps Loop is a cloud-based continuous integration platform built on modern, cloud-native technologies that enables product teams to plan, code, test, and deploy the applications and also provides a holistic view of the progress in the DevOps cycle. Loop is built to install on IBM® Red Hat OpenShift & K8s platforms.

## K8s Installation Instructions

## Prerequisites

  1. An available K8s cluster.  
  
  2. [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).
  
  3. A valid public certificates issued by trusted Certificate Authorities (CAs).

  4. For installation instructions and requisite requirements, see Installation of DevOps Loop at <https://www.ibm.com/docs/en/devops-loop/2.0.2?topic=administration-installation-devops-loop>
  
  5. Image and Helm Chart - The DevOps Loop images and helm chart can be accessed via the Entitled Registry and public Helm repository.

    * The public Helm chart repository can be accessed at <https://github.com/IBM/charts/tree/master/repo/ibm-helm> and directions for accessing the DevOps Loop chart will be discussed later in this README.
    * Get a key to the entitled registry
      * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
      * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
      * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  Note: Secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Loop into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

      ```bash
      kubectl create secret docker-registry ibm-entitlement-key \
        --namespace [namespace_name] \
        --docker-username=cp \
        --docker-password=<EntitlementKey> \
        --docker-server=cp.icr.io
      ```
  
## Storage

If the cluster default StorageClass does not support the ReadWriteMany (RWX) accessMode, an alternative class must be specified using the following additional helm value: global.persistence.rwxStorageClass  For example, ibmc-file-gold-gid.

ReadWriteOnce (RWO) access mode storage can be configured with the following helm value: global.persistence.rwoStorageClass  For example, ibmc-block-gold.

### Licensing

DevOps Loop requires an installed IBM Rational License Key Server (RLKS).  You must specify this RLKS server during installation.

See IBM Rational License Key Server documentation for more details.

### Optional Harbor integration

Harbor is optional and disabled by default. To install DevOps Loop with Harbor
enabled, set the following value in the installation script:

```sh
HARBOR_ENABLED=true
```

Harbor requires S3-compatible object storage. Set these values before running
the installer:

```sh
HARBOR_S3_BUCKET=<bucket-name>
HARBOR_S3_REGION=<region>
HARBOR_S3_ENDPOINT=<s3-compatible-endpoint>
```

Create the Harbor S3 credential secret in the DevOps Loop namespace before
enabling Harbor. The secret must be named `harbor-s3-secret` and must contain
the keys `accesskey` and `secretkey`.

```sh
kubectl create secret generic harbor-s3-secret \
  --namespace <namespace> \
  --from-literal=accesskey='<ACCESS_KEY>' \
  --from-literal=secretkey='<SECRET_KEY>'
```

Harbor Trivy requires a storage class for its cache. Set:

```sh
HARBOR_TRIVY_STORAGE_CLASS=<rwx-storage-class>
```

Optionally set the Harbor OIDC administrator group:

```sh
HARBOR_OIDC_ADMIN_GROUP=<keycloak-group-name>
```

If this value is not set, the installer uses the chart default. Users in this
Keycloak group become Harbor administrators.

After installation, Harbor is available from the DevOps Loop app
launcher/switcher and from the configured Harbor external URL.

To import images into Harbor, update:

```text
scripts/harbor/bootstrap-images.txt
```

Each line uses this format:

```text
source_image target_project target_repo target_tag
```

Example:

```text
registry.example.com/team/application:1.0.0 library application 1.0.0
```

Then run:

```sh
DOMAIN=<domain> NAMESPACE=<namespace> RELEASE=<helm-release> scripts/harbor/bootstrap-images.sh
```

### Optional Harbor on OpenShift

Before enabling Harbor on OpenShift, a cluster administrator must first apply a
dedicated, narrowly scoped Security Context Constraints (SCC) for Harbor.

Harbor upstream images run with UID/GID `10000`. The DevOps Loop chart creates
and uses a dedicated Harbor ServiceAccount on OpenShift, and the custom SCC must
be bound only to that ServiceAccount.

The SCC manifest is provided at:

```text
scripts/harbor/openshift/harbor-scc.yaml
```

A helper script is provided for a cluster administrator to apply the SCC and bind
it to the dedicated Harbor ServiceAccount:

```sh
scripts/harbor/openshift/apply-harbor-scc.sh \
  --namespace devops-loop \
  --service-account harbor \
  --scc-name harbor-uid-10000-devops-loop
```

The SCC is not automatically rendered by Helm because it is stored under
`scripts/harbor/openshift/`, not under `templates/`. The OpenShift installer
checks that the SCC exists and is bound correctly before enabling Harbor, but it
does not silently create or modify the SCC.

If `https://harbor.${DOMAIN}` is not resolvable in your OpenShift environment,
set `HARBOR_EXTERNAL_URL` to a DNS-resolvable OpenShift router-wildcard URL for
Harbor before running the installer.

## Install

This installation includes locally deployed databases.  This includes a sample install of MongoDB.

Before you begin, follow requisite steps and configuration at Installation of DevOps Loop:  <https://www.ibm.com/docs/en/devops-loop/2.0.2?topic=administration-installation-devops-loop>

Fetch chart for install:

```bash
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
```

```bash
#Required
#External fully qualified domain name of the cluster
#
#See Installation of DevOps Loop documentation for more details:
#https://www.ibm.com/docs/en/devops-loop/2.0.2?topic=administration-installation-devops-loop
DOMAIN=

#Required
#Set value to 'true' to accept the license.
ACCEPT_LICENSE=

#Required
#Hostname of IBM Rational license server
LICENSE_SERVER=

#Required
#SMTP Server configuration
EMAIL_SERVER_HOST=
EMAIL_SERVER_PORT=
EMAIL_FROM_ADDRESS=

#Optional
#Additional SMTP Server configuration
EMAIL_SERVER_USERNAME=""
EMAIL_SERVER_PASSWORD=""
EMAIL_SERVER_STARTTLS=false
EMAIL_SERVER_SMTPS=false

#Required
#Secure seed required to generate passwords
#A random string
#Unrecoverable so keep it safe
PASSWORD_SEED=

#Specify the TLS secret name in your namespace as necessary.
#
#See Installation of DevOps Loop documentation for more details:
#https://www.ibm.com/docs/en/devops-loop/2.0.2?topic=administration-installation-devops-loop
TLS_CERT_SECRET_NAME=

#Set SELF_SIGNED=true to generate and use a self-signed certificate for the
#installation of DevOps Loop
SELF_SIGNED=

#Alternative RWX storage class
#See Storage
#For example: ibmc-file-gold-gid
RWX_STORAGE_CLASS=

#Alternative RWO storage class
#See Storage
#For example: ibmc-block-gold
RWO_STORAGE_CLASS=

# optional Appscan integration
APP_SCAN_ENABLED=false

# Required only when APP_SCAN_ENABLED=true
# External URL for AppScan (e.g. https://cloud.appscan.com)
APPSCAN_EXTERNAL_URL=

# Optional Harbor integration
HARBOR_ENABLED=false

# Required only when HARBOR_ENABLED=true
HARBOR_S3_BUCKET=
HARBOR_S3_REGION=
HARBOR_S3_ENDPOINT=

# Harbor Trivy cache uses RWX
#See Storage
#For example: ibmc-file-gold-gid
HARBOR_TRIVY_STORAGE_CLASS=

# Harbor OIDC admin group in Keycloak
# Users in this group become Harbor system administrators.
HARBOR_OIDC_ADMIN_GROUP=

#Required
NAMESPACE=devops-loop
HELM_NAME=devops-loop
LOOP_CHART_VERSION=2.0.200

#Optional Additional Helm options
ADDITIONAL_HELM_OPTIONS=""

wait_for_secret() {
  local secret_name="$1"
  local timeout_seconds="${2:-900}"
  local waited=0

  echo "Waiting for secret ${secret_name} in namespace ${NAMESPACE}..."

  until kubectl get secret "${secret_name}" -n "${NAMESPACE}" >/dev/null 2>&1; do
    if [ "${waited}" -ge "${timeout_seconds}" ]; then
      echo "Timed out waiting for secret ${secret_name}"
      return 1
    fi
    sleep 10
    waited=$((waited + 10))
  done

  echo "Secret ${secret_name} is available."
}

run_install() {

  if ! kubectl get namespace ${NAMESPACE} > /dev/null 2>&1; then
    kubectl  create namespace ${NAMESPACE} || { echo "Failed to create namespace"; return 1; }
  fi

  if ! kubectl get secret mongodb-url-secret --namespace ${NAMESPACE} > /dev/null 2>&1; then

    MONGO_CHART_VERSION="${MONGO_CHART_VERSION:-14.13.0}"
    MONGO_IMAGE_TAG="${MONGO_IMAGE_TAG:-6.0}"
    MONGO_IMAGE_REPO="${MONGO_IMAGE_REPO:-bitnamilegacy/mongodb}"
    MONGO_HELM_RELEASE_NAME="${MONGO_HELM_RELEASE_NAME:-devops-loop-mongo}"
    MONGO_NAMESPACE="${MONGO_NAMESPACE:-${NAMESPACE}}"
    MONGO_PVC_SIZE=${MONGO_PVC_SIZE:-20Gi}

    helm repo add bitnami https://charts.bitnami.com/bitnami --force-update 1> /dev/null

    MONGO_INSTALL_OPTIONS="\
      --set image.repository=${MONGO_IMAGE_REPO} \
      --set image.tag=${MONGO_IMAGE_TAG} \
      --set persistence.size=${MONGO_PVC_SIZE}
    "

    if [ -n "${RWO_STORAGE_CLASS}" ]; then
      MONGO_INSTALL_OPTIONS="${MONGO_INSTALL_OPTIONS} --set persistence.storageClass=${RWO_STORAGE_CLASS}"
    fi

    if [ -n "${MONGO_ADDITIONAL_INSTALL_OPTIONS}" ]; then
      MONGO_INSTALL_OPTIONS="${MONGO_INSTALL_OPTIONS} ${MONGO_ADDITIONAL_INSTALL_OPTIONS}"
    fi

    helm upgrade --install ${MONGO_HELM_RELEASE_NAME} \
      --version ${MONGO_CHART_VERSION} \
      ${MONGO_INSTALL_OPTIONS} \
      --namespace=${MONGO_NAMESPACE} \
      --create-namespace \
      bitnami/mongodb 1> /dev/null || { echo "Failed to install MongoDB"; return 1; }

    MONGODB_ROOT_PASSWORD=$(kubectl  get secret --namespace ${NAMESPACE} ${MONGO_HELM_RELEASE_NAME}-mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 -d)

    MONGO_URL="mongodb://root:${MONGODB_ROOT_PASSWORD}@${MONGO_HELM_RELEASE_NAME}-mongodb:27017/admin"

    kubectl create secret generic mongodb-url-secret --namespace ${NAMESPACE} --from-literal=password="${MONGO_URL}" 1> /dev/null || { echo "Failed to create MongoDB secret"; return 1; }

  fi

  if [ "${SELF_SIGNED}" = "true" ]; then
    export TLS_CERT_SECRET_NAME=devops-loop-tls-secret
    openssl genrsa -out key.pem 2048
    openssl req -new -x509 -key key.pem -out cert.pem -days 365 \
            -subj "/CN=${DOMAIN}" -addext "subjectAltName = DNS:${DOMAIN},DNS:*.${DOMAIN}" \
            -addext "certificatePolicies = 1.2.3.4"

    kubectl create secret generic ${TLS_CERT_SECRET_NAME} \
      --type=kubernetes.io/tls \
      --from-file=ca.crt=./cert.pem \
      --from-file=tls.crt=./cert.pem \
      --from-file=tls.key=./key.pem \
      --namespace ${NAMESPACE}
  fi

  HELM_OPTIONS="${HELM_OPTIONS:-} \
--set global.domain=${DOMAIN} \
--set-literal global.passwordSeed=${PASSWORD_SEED} \
--set global.platform.smtp.sender=${EMAIL_FROM_ADDRESS} \
--set global.platform.smtp.host=${EMAIL_SERVER_HOST} \
--set global.platform.smtp.port=${EMAIL_SERVER_PORT} \
--set global.platform.smtp.username=${EMAIL_SERVER_USERNAME} \
--set global.platform.smtp.password=${EMAIL_SERVER_PASSWORD} \
--set global.platform.smtp.startTLS=${EMAIL_SERVER_STARTTLS} \
--set global.platform.smtp.smtps=${EMAIL_SERVER_SMTPS} \
--set global.ibmCertSecretName=${TLS_CERT_SECRET_NAME} \
--set license=${ACCEPT_LICENSE} \
--set platform.appscan.enabled=${APP_SCAN_ENABLED}
"

  if [ "${APP_SCAN_ENABLED}" = "true" ] && [ -n "${APPSCAN_EXTERNAL_URL}" ]; then
    HELM_OPTIONS="${HELM_OPTIONS} --set-string platform.appscan.externalURL=${APPSCAN_EXTERNAL_URL}"
  fi

  if [ "${SELF_SIGNED}" = "true" ]; then
     HELM_OPTIONS="${HELM_OPTIONS} --set global.privateCaBundleSecretName=${TLS_CERT_SECRET_NAME}"
     HELM_OPTIONS="${HELM_OPTIONS} --set ibm-devops-prod.ingress.cert.selfSigned=true"
  fi

  if [ -n "${LICENSE_SERVER}" ]; then
    HELM_OPTIONS="${HELM_OPTIONS} --set global.rationalLicenseKeyServer=@${LICENSE_SERVER}"
  fi

  if [ -n "${RWX_STORAGE_CLASS}" ]; then
    HELM_OPTIONS="${HELM_OPTIONS} --set global.persistence.rwxStorageClass=${RWX_STORAGE_CLASS}"
  fi

  if [ -n "${RWO_STORAGE_CLASS}" ]; then
    HELM_OPTIONS="${HELM_OPTIONS} --set global.persistence.rwoStorageClass=${RWO_STORAGE_CLASS}"
  fi

  HELM_OPTIONS="${HELM_OPTIONS} ${ADDITIONAL_HELM_OPTIONS}"

  helm upgrade --install ${HELM_NAME} ibm-helm/ibm-devops-loop --version ${LOOP_CHART_VERSION} ${HELM_OPTIONS} \
    --set harbor.enabled=false \
    -n ${NAMESPACE} || return 1

  if [ "${HARBOR_ENABLED}" != "true" ]; then
    echo "Harbor is disabled. DevOps Loop installation completed."
    return 0
  fi

  echo "Validating Harbor prerequisites..."

  if [ -z "${HARBOR_S3_BUCKET}" ]; then
    echo "HARBOR_S3_BUCKET is required when HARBOR_ENABLED=true"
    return 1
  fi

  if [ -z "${HARBOR_S3_REGION}" ]; then
    echo "HARBOR_S3_REGION is required when HARBOR_ENABLED=true"
    return 1
  fi

  if [ -z "${HARBOR_S3_ENDPOINT}" ]; then
    echo "HARBOR_S3_ENDPOINT is required when HARBOR_ENABLED=true"
    return 1
  fi

  if ! kubectl get secret harbor-s3-secret -n "${NAMESPACE}" >/dev/null 2>&1; then
    echo "harbor-s3-secret is required when HARBOR_ENABLED=true"
    echo "Create it before install:"
    echo "kubectl create secret generic harbor-s3-secret -n ${NAMESPACE} --from-literal=accesskey='<ACCESS_KEY>' --from-literal=secretkey='<SECRET_KEY>'"
    return 1
  fi

  if [ -z "${HARBOR_TRIVY_STORAGE_CLASS}" ] && [ -z "${RWX_STORAGE_CLASS}" ]; then
    echo "Either HARBOR_TRIVY_STORAGE_CLASS or RWX_STORAGE_CLASS is required when HARBOR_ENABLED=true"
    return 1
  fi

  echo "Waiting for Harbor dependency secrets"
											  
  for secret in devops-loop-valkey devops-loop-postgresql; do
    if ! wait_for_secret "${secret}" 1200; then
      echo "WARNING: Required Harbor dependency secret ${secret} was not available within timeout period."
      echo "Skipping Harbor installation/upgrade. DevOps Loop base installation completed successfully."
      echo "After ${secret} is available, rerun this script to enable Harbor."
      return 0
    fi
  done

  REDIS_PASSWORD=$(kubectl get secret devops-loop-valkey \
  -n "${NAMESPACE}" \
  -o jsonpath="{.data.valkey-password}" | base64 -d)

  S3_ACCESS_KEY=$(kubectl get secret harbor-s3-secret \
    -n "${NAMESPACE}" \
    -o jsonpath="{.data.accesskey}" | base64 -d)

  S3_SECRET_KEY=$(kubectl get secret harbor-s3-secret \
    -n "${NAMESPACE}" \
    -o jsonpath="{.data.secretkey}" | base64 -d)
  if [ -z "${HARBOR_OIDC_ADMIN_GROUP}" ]; then
    HARBOR_OIDC_ADMIN_GROUP=harbor-admins
  fi

  echo "Using Harbor OIDC admin group: ${HARBOR_OIDC_ADMIN_GROUP}"
  HARBOR_URL="https://harbor.${DOMAIN}"

  HARBOR_HELM_OPTIONS="${HELM_OPTIONS} \
--set harbor.enabled=true \
--set platform.harbor.enabled=true \									
--set-string harbor.externalURL=${HARBOR_URL} \
--set-string harbor.oidc.adminGroup=${HARBOR_OIDC_ADMIN_GROUP} \
--set-string harbor.redis.external.password=${REDIS_PASSWORD} \
--set-string harbor.trivy.externalRedis.password=${REDIS_PASSWORD} \
--set-string harbor.persistence.imageChartStorage.s3.bucket=${HARBOR_S3_BUCKET} \
--set-string harbor.persistence.imageChartStorage.s3.region=${HARBOR_S3_REGION} \
--set-string harbor.persistence.imageChartStorage.s3.regionendpoint=${HARBOR_S3_ENDPOINT} \
--set-string harbor.persistence.imageChartStorage.s3.accesskey=${S3_ACCESS_KEY} \
--set-string harbor.persistence.imageChartStorage.s3.secretkey=${S3_SECRET_KEY}
"

  if [ -n "${HARBOR_TRIVY_STORAGE_CLASS}" ]; then
    HARBOR_HELM_OPTIONS="${HARBOR_HELM_OPTIONS} --set-string harbor.trivy.persistence.storageClass=${HARBOR_TRIVY_STORAGE_CLASS}"
  else
    HARBOR_HELM_OPTIONS="${HARBOR_HELM_OPTIONS} --set-string harbor.trivy.persistence.storageClass=${RWX_STORAGE_CLASS}"
  fi

  echo "Installing optional Harbor integration..."

  HARBOR_HELM_OPTIONS="${HARBOR_HELM_OPTIONS} ${ADDITIONAL_HELM_OPTIONS}"

  helm upgrade --install ${HELM_NAME} ibm-helm/ibm-devops-loop --version ${LOOP_CHART_VERSION} ${HARBOR_HELM_OPTIONS} \
    --hide-notes \
	  --timeout 30m \		   
    -n ${NAMESPACE} || return 1

  echo "DevOps Loop + Harbor installation completed."
  echo ""
  echo "Harbor URL:"
  echo "  https://harbor.${DOMAIN}"
  echo ""
  echo "Monitor Harbor pods:"
  echo "  kubectl get pods -n ${NAMESPACE} | grep harbor"
  echo ""
  echo "Bootstrap Harbor images:"
  echo "  1. Update scripts/harbor/bootstrap-images.txt"
  echo "  2. Run:"
  echo "     DOMAIN=${DOMAIN} NAMESPACE=${NAMESPACE} RELEASE=${HELM_NAME} scripts/harbor/bootstrap-images.sh"
}

run_install
```

## Backup

See Solution Documentation for information on backup.

## Uninstall

Delete the product:

```bash
NAMESPACE=devops-loop
HELM_NAME=devops-loop
helm uninstall $HELM_NAME -n $NAMESPACE
```

The claims and persistent volumes that contain user data are not automatically be deleted. If you re-install the product these resources will be re-used if present.

To delete _EVERYTHING_, including user data contained in claims and persistent volumes

```bash
NAMESPACE=devops-loop
kubectl delete namespace $NAMESPACE
```

Note: This will hang if the namespace contains workload which has not terminated.

### Configuration

| Parameter                                      | Description | Default |
|------------------------------------------------|-------------|---------|
| `license`                                      | Confirmation that the EULA has been accepted. For example `true` | REQUIRED |
| `global.passwordSeed`                          | The seed used to generate all passwords. | REQUIRED |
| `global.platform.smtp.host`                    | SMTP server host  | REQUIRED |
| `global.platform.smtp.port`                    | SMTP server port number | REQUIRED |
| `global.rationalLicenseKeyServer`              | Where floating licenses are hosted to entitle use of the product. For example `@ip-address` | REQUIRED |
| `global.platform.smtp.sender`                  | The SMTP sender email address has to delivered from on-boarding process | REQUIRED |
| `global.platform.smtp.username`                | SMTP server username | "" |
| `global.platform.smtp.password`                | SMTP server password | "" |
| `global.platform.smtp.startTLS`                | This parameter sets the mail server to secure protocol using TLS or SSL. Accepted values are:<br>- _true_ to set secure protocol using TLS or SSL.<br>- _false_ to set unsecure protocol | false |
| `global.platform.smtp.smtps`                   | This parameter sets the mail server protocol. Accepted values are:<br>- _true_ to set smtps protocol.<br>- _false_ to set smtp protocol. | false |
| `global.persistence.rwoStorageClass`           | The RWO storageClass to use if the cluster default is not appropriate. | '' |
| `global.persistence.rwxStorageClass`           | The RWX storageClass to use if the cluster default is not appropriate. | '' |

#### Solution Configuration

Additional configuration for solutions is managed via helm parameters. See Solution Documentation for details.

Each helm parameter specific to a solution will be prefixed by its helm chart name.

* **Plan**: `ibm-devopsplan-prod`
* **Test**: `ibm-devops-prod`
* **Deploy**: `ibm-ucd-prod`
* **Measure**: `ibm-ucv-prod`

For example, to configure a property in the Plan solution, use the following:

```bash
--set ibm-devopsplan-prod.property=value
```

## OpenShift Installation Instructions

## Prerequisites

1. OpenShift, OpenShift CLI (oc), and Helm 3.

    * [RedHat OpenShift Container Platform](https://docs.openshift.com/container-platform/4.15/release_notes/ocp-4-15-release-notes.html) v4.15 or later (x86_64)

    * [Install and setup OpenShift CLI](https://docs.openshift.com/container-platform/4.14/cli_reference/openshift_cli/getting-started-cli.html)

    * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Image and Helm Chart - The DevOps Loop images, and helm chart can be accessed via the Entitled Registry and public Helm repository.

    * The public Helm chart repository can be accessed at <https://github.com/IBM/charts/tree/master/repo/ibm-helm> and directions for accessing the DevOps Loop chart will be discussed later in this README.
    * Get a key to the entitled registry
      * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
      * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
      * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  Note: Secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Loop into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

      ```bash
      oc create secret docker-registry ibm-entitlement-key \
        --namespace [namespace_name] \
        --docker-username=cp \
        --docker-password=<EntitlementKey> \
        --docker-server=cp.icr.io
      ```

### Storage

If the cluster default StorageClass does not support the ReadWriteMany (RWX) accessMode, an alternative class must be specified using the following additional helm value: global.persistence.rwxStorageClass  For example, ibmc-file-gold-gid.

ReadWriteOnce (RWO) access mode storage can be configured with the following helm value: global.persistence.rwoStorageClass  For example, ibmc-block-gold.

### Licensing

DevOps Loop requires an installed IBM Rational License Key Server (RLKS).  You must specify this RLKS server during installation.

See IBM Rational License Key Server documentation for more details.

## Install

This installation includes locally deployed databases.  This includes a sample install of MongoDB.

Before you begin, follow requisite steps and configuration at Installation of DevOps Loop: https://www.ibm.com/docs/en/devops-loop/2.0.2?topic=administration-installation-devops-loop

Fetch chart for install:

```bash
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
helm pull --untar ibm-helm/ibm-devops-loop --version 2.0.200
```

```bash
#Pull ibm helm charts
LOOP_CHART_VERSION=2.0.200
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
helm pull --untar ibm-helm/ibm-devops-loop --version ${LOOP_CHART_VERSION}
#
#Required
#External fully qualified domain name of the cluster
#
# Note: The default configuration inherits the default domain when you created
# your Openshift cluster.  You may also choose to further customize the
# domain such as adding a prefix, for instance devops-loop.$(oc get....),
# using an altnernative ingress controller, or directly specifying a fully
# qualified name associated with your cluster.
#
#See Installation of DevOps Loop documentation for more details:
#https://www.ibm.com/docs/en/devops-loop/2.0.2?topic=administration-installation-devops-loop
DOMAIN=$(oc get -n openshift-ingress-operator ingresscontroller default -o jsonpath='{.status.domain}')

#Required
#Set value to 'true' to accept the license.
ACCEPT_LICENSE=

#Required
#Hostname of IBM Rational license server
LICENSE_SERVER=

#Required
#SMTP Server configuration
EMAIL_SERVER_HOST=
EMAIL_SERVER_PORT=
EMAIL_FROM_ADDRESS=

#Optional
#Additional SMTP Server configuration
EMAIL_SERVER_USERNAME=""
EMAIL_SERVER_PASSWORD=""
EMAIL_SERVER_STARTTLS=false
EMAIL_SERVER_SMTPS=false

#Required
#Secure seed required to generate passwords
#A random string
#Unrecoverable so keep it safe
PASSWORD_SEED=

#Specify the TLS secret name in your namespace as necessary.
#
#See Installation of DevOps Loop documentation for more details:
#https://www.ibm.com/docs/en/devops-loop/2.0.2?topic=administration-installation-devops-loop
TLS_CERT_SECRET_NAME=

#Set SELF_SIGNED=true to generate and use a self-signed certificate for the
#installation of DevOps Loop
SELF_SIGNED=

#Alternative RWX storage class
#See Storage
#For example: ibmc-file-gold-gid
RWX_STORAGE_CLASS=

#Alternative RWO storage class
#See Storage
#For example: ibmc-block-gold
RWO_STORAGE_CLASS=

#Required
NAMESPACE=devops-loop
HELM_NAME=devops-loop

#Optional Additional Helm options
ADDITIONAL_HELM_OPTIONS=""

# Optional Appscan integration
APP_SCAN_ENABLED=false
# Required only when APP_SCAN_ENABLED=true
# External URL for AppScan (e.g. https://cloud.appscan.com)
APPSCAN_EXTERNAL_URL=

# Optional Harbor integration
HARBOR_ENABLED=false

# Required only when HARBOR_ENABLED=true
HARBOR_S3_BUCKET=
HARBOR_S3_REGION=
HARBOR_S3_ENDPOINT=

# Harbor Trivy cache storage class
#See Storage
#For example: ibmc-file-gold-gid
HARBOR_TRIVY_STORAGE_CLASS=

# Harbor OIDC admin group in Keycloak
# Users in this group become Harbor system administrators.
HARBOR_OIDC_ADMIN_GROUP=

# Optional Harbor external URL. Set this when the default harbor.${DOMAIN}
# hostname is not resolvable by cluster DNS.
HARBOR_EXTERNAL_URL=

# OpenShift SCC preflight values for optional Harbor integration.
# The SCC is intentionally not created by this installer.
HARBOR_SERVICE_ACCOUNT="${HARBOR_SERVICE_ACCOUNT:-harbor}"
HARBOR_SCC_NAME="${HARBOR_SCC_NAME:-harbor-uid-10000-${NAMESPACE}}"

ROOT_DIR=./ibm-devops-loop
# Patch DevOps Deploy agent helm chart role.yaml for Loop v2.0.200
ROLE_FILE=${ROOT_DIR}/charts/ibm-ucda-prod/templates/role.yaml
sed -i.bak -e '/resources: \["routes"\]/s/resources: \["routes"\]/resources: \["routes", "routes\/custom-host"\]/' ${ROLE_FILE}
rm -f ${ROLE_FILE}.bak

wait_for_secret() {
  local secret_name="$1"
  local timeout_seconds="${2:-900}"
  local waited=0

  echo "Waiting for secret ${secret_name} in namespace ${NAMESPACE}..."

  until oc get secret "${secret_name}" -n "${NAMESPACE}" >/dev/null 2>&1; do
    if [ "${waited}" -ge "${timeout_seconds}" ]; then
      echo "Timed out waiting for secret ${secret_name}"
      return 1
    fi
    sleep 10
    waited=$((waited + 10))
  done

  echo "Secret ${secret_name} is available."
}

validate_harbor_openshift_scc() {
  local service_account_subject="system:serviceaccount:${NAMESPACE}:${HARBOR_SERVICE_ACCOUNT}"
  local scc_users
  local run_as_user_type
  local run_as_user_uid
  local fs_group_type
  local fs_group_min
  local fs_group_max
  local supplemental_groups_type
  local supplemental_groups_min
  local supplemental_groups_max

  echo "Validating Harbor OpenShift SCC ${HARBOR_SCC_NAME}..."

  if ! oc get scc "${HARBOR_SCC_NAME}" >/dev/null 2>&1; then
    echo "Required SCC ${HARBOR_SCC_NAME} was not found."
    echo "Ask a cluster administrator to apply scripts/harbor/openshift/harbor-scc.yaml using:"
    echo "  NAMESPACE=${NAMESPACE} HARBOR_SERVICE_ACCOUNT=${HARBOR_SERVICE_ACCOUNT} HARBOR_SCC_NAME=${HARBOR_SCC_NAME} scripts/harbor/openshift/apply-harbor-scc.sh --yes"
    return 1
  fi

  scc_users=$(oc get scc "${HARBOR_SCC_NAME}" -o jsonpath='{.users[*]}')
  if ! printf '%s\n' "${scc_users}" | tr ' ' '\n' | grep -Fx "${service_account_subject}" >/dev/null 2>&1; then
    echo "Required SCC ${HARBOR_SCC_NAME} is not bound to ${service_account_subject}."
    echo "Ask a cluster administrator to bind only this dedicated Harbor ServiceAccount using:"
    echo "  NAMESPACE=${NAMESPACE} HARBOR_SERVICE_ACCOUNT=${HARBOR_SERVICE_ACCOUNT} HARBOR_SCC_NAME=${HARBOR_SCC_NAME} scripts/harbor/openshift/apply-harbor-scc.sh --yes"
    return 1
  fi

  run_as_user_type=$(oc get scc "${HARBOR_SCC_NAME}" -o jsonpath='{.runAsUser.type}')
  run_as_user_uid=$(oc get scc "${HARBOR_SCC_NAME}" -o jsonpath='{.runAsUser.uid}')
  fs_group_type=$(oc get scc "${HARBOR_SCC_NAME}" -o jsonpath='{.fsGroup.type}')
  fs_group_min=$(oc get scc "${HARBOR_SCC_NAME}" -o jsonpath='{.fsGroup.ranges[0].min}')
  fs_group_max=$(oc get scc "${HARBOR_SCC_NAME}" -o jsonpath='{.fsGroup.ranges[0].max}')
  supplemental_groups_type=$(oc get scc "${HARBOR_SCC_NAME}" -o jsonpath='{.supplementalGroups.type}')
  supplemental_groups_min=$(oc get scc "${HARBOR_SCC_NAME}" -o jsonpath='{.supplementalGroups.ranges[0].min}')
  supplemental_groups_max=$(oc get scc "${HARBOR_SCC_NAME}" -o jsonpath='{.supplementalGroups.ranges[0].max}')

  if [ "${run_as_user_type}" != "MustRunAs" ] || [ "${run_as_user_uid}" != "10000" ]; then
    echo "SCC ${HARBOR_SCC_NAME} must set runAsUser.type=MustRunAs and runAsUser.uid=10000."
    return 1
  fi

  if [ "${fs_group_type}" != "MustRunAs" ] || [ "${fs_group_min}" != "10000" ] || [ "${fs_group_max}" != "10000" ]; then
    echo "SCC ${HARBOR_SCC_NAME} must set fsGroup.type=MustRunAs with range 10000-10000."
    return 1
  fi

  if [ "${supplemental_groups_type}" != "MustRunAs" ] || [ "${supplemental_groups_min}" != "10000" ] || [ "${supplemental_groups_max}" != "10000" ]; then
    echo "SCC ${HARBOR_SCC_NAME} must set supplementalGroups.type=MustRunAs with range 10000-10000."
    return 1
  fi

  echo "Harbor OpenShift SCC preflight passed for ${service_account_subject}."
}

run_install() {

  if ! oc get namespace ${NAMESPACE} > /dev/null 2>&1; then
    oc create namespace ${NAMESPACE} || { echo "Failed to create namespace"; return 1; }
  fi

  if ! oc get secret mongodb-url-secret --namespace ${NAMESPACE} > /dev/null 2>&1; then

    MONGO_CHART_VERSION="${MONGO_CHART_VERSION:-14.13.0}"
    MONGO_IMAGE_TAG="${MONGO_IMAGE_TAG:-6.0}"
    MONGO_IMAGE_REPO="${MONGO_IMAGE_REPO:-bitnamilegacy/mongodb}"
    MONGO_HELM_RELEASE_NAME="${MONGO_HELM_RELEASE_NAME:-devops-loop-mongo}"
    MONGO_NAMESPACE="${MONGO_NAMESPACE:-${NAMESPACE}}"
    MONGO_PVC_SIZE=${MONGO_PVC_SIZE:-20Gi}

    helm repo add bitnami https://charts.bitnami.com/bitnami --force-update 1> /dev/null

    MONGO_INSTALL_OPTIONS="\
      --set image.repository=${MONGO_IMAGE_REPO} \
      --set image.tag=${MONGO_IMAGE_TAG} \
      --set persistence.size=${MONGO_PVC_SIZE} \
      --set global.compatibility.openshift.adaptSecurityContext=auto
    "

    if [ -n "${RWO_STORAGE_CLASS}" ]; then
      MONGO_INSTALL_OPTIONS="${MONGO_INSTALL_OPTIONS} --set persistence.storageClass=${RWO_STORAGE_CLASS}"
    fi

    if [ -n "${MONGO_ADDITIONAL_INSTALL_OPTIONS:-}" ]; then
      MONGO_INSTALL_OPTIONS="${MONGO_INSTALL_OPTIONS} ${MONGO_ADDITIONAL_INSTALL_OPTIONS}"
    fi

    helm upgrade --install ${MONGO_HELM_RELEASE_NAME} \
      --version ${MONGO_CHART_VERSION} \
      ${MONGO_INSTALL_OPTIONS} \
      --namespace=${MONGO_NAMESPACE} \
      --create-namespace \
      bitnami/mongodb 1> /dev/null || { echo "Failed to install MongoDB"; return 1; }

    MONGODB_ROOT_PASSWORD=$(oc get secret --namespace ${NAMESPACE} ${MONGO_HELM_RELEASE_NAME}-mongodb -o jsonpath="{.data.mongodb-root-password}" | base64 -d)

    MONGO_URL="mongodb://root:${MONGODB_ROOT_PASSWORD}@${MONGO_HELM_RELEASE_NAME}-mongodb:27017/admin"

    oc create secret generic mongodb-url-secret --namespace ${NAMESPACE} --from-literal=password="${MONGO_URL}" 1> /dev/null || { echo "Failed to create MongoDB secret"; return 1; }

  fi

  if [ "${SELF_SIGNED}" = "true" ]; then
    export TLS_CERT_SECRET_NAME=devops-loop-tls-secret
    openssl genrsa -out key.pem 2048
    openssl req -new -x509 -key key.pem -out cert.pem -days 365 \
            -subj "/CN=${DOMAIN}" -addext "subjectAltName = DNS:${DOMAIN},DNS:*.${DOMAIN}" \
            -addext "certificatePolicies = 1.2.3.4"

    oc create secret generic ${TLS_CERT_SECRET_NAME} \
      --type=kubernetes.io/tls \
      --from-file=ca.crt=./cert.pem \
      --from-file=tls.crt=./cert.pem \
      --from-file=tls.key=./key.pem \
      --namespace ${NAMESPACE}
  fi

  HELM_OPTIONS="${HELM_OPTIONS:-} \
--set global.domain=${DOMAIN} \
--set-literal global.passwordSeed=${PASSWORD_SEED} \
--set global.platform.smtp.sender=${EMAIL_FROM_ADDRESS} \
--set global.platform.smtp.host=${EMAIL_SERVER_HOST} \
--set global.platform.smtp.port=${EMAIL_SERVER_PORT} \
--set global.platform.smtp.username=${EMAIL_SERVER_USERNAME} \
--set global.platform.smtp.password=${EMAIL_SERVER_PASSWORD} \
--set global.platform.smtp.startTLS=${EMAIL_SERVER_STARTTLS} \
--set global.platform.smtp.smtps=${EMAIL_SERVER_SMTPS} \
--set global.ibmCertSecretName=${TLS_CERT_SECRET_NAME} \
--set license=${ACCEPT_LICENSE} \
--set platform.appscan.enabled=${APP_SCAN_ENABLED}
"
  if [ "${APP_SCAN_ENABLED}" = "true" ] && [ -n "${APPSCAN_EXTERNAL_URL}" ]; then
    HELM_OPTIONS="${HELM_OPTIONS} --set-string platform.appscan.externalURL=${APPSCAN_EXTERNAL_URL}"
  fi																	 

  if [ "${SELF_SIGNED}" = "true" ]; then
     HELM_OPTIONS="${HELM_OPTIONS} --set global.privateCaBundleSecretName=${TLS_CERT_SECRET_NAME}"
     HELM_OPTIONS="${HELM_OPTIONS} --set ibm-devops-prod.ingress.cert.selfSigned=true"
  fi

  if [ -n "${LICENSE_SERVER}" ]; then
    HELM_OPTIONS="${HELM_OPTIONS} --set global.rationalLicenseKeyServer=@${LICENSE_SERVER}"
  fi

  if [ -n "${RWX_STORAGE_CLASS}" ]; then
    HELM_OPTIONS="${HELM_OPTIONS} --set global.persistence.rwxStorageClass=${RWX_STORAGE_CLASS}"
  fi

  if [ -n "${RWO_STORAGE_CLASS}" ]; then
    HELM_OPTIONS="${HELM_OPTIONS} --set global.persistence.rwoStorageClass=${RWO_STORAGE_CLASS}"
  fi

  HELM_OPTIONS="${HELM_OPTIONS} ${ADDITIONAL_HELM_OPTIONS}"

  echo "Installing DevOps Loop..."

  helm upgrade --install ${HELM_NAME} ${ROOT_DIR} ${HELM_OPTIONS} \
    --set harbor.enabled=false \
    -n ${NAMESPACE} -f ${ROOT_DIR}/values-openshift.yaml || return 1

  if [ "${HARBOR_ENABLED}" != "true" ]; then
    echo "Harbor is disabled. DevOps Loop installation completed."
    return 0
  fi

  echo "Validating Harbor prerequisites..."

  if [ -z "${HARBOR_S3_BUCKET}" ]; then
    echo "HARBOR_S3_BUCKET is required when HARBOR_ENABLED=true"
    return 1
  fi

  if [ -z "${HARBOR_S3_REGION}" ]; then
    echo "HARBOR_S3_REGION is required when HARBOR_ENABLED=true"
    return 1
  fi

  if [ -z "${HARBOR_S3_ENDPOINT}" ]; then
    echo "HARBOR_S3_ENDPOINT is required when HARBOR_ENABLED=true"
    return 1
  fi

  if ! oc get secret harbor-s3-secret -n "${NAMESPACE}" >/dev/null 2>&1; then
    echo "harbor-s3-secret is required when HARBOR_ENABLED=true"
    echo "Create it before install:"
    echo "oc create secret generic harbor-s3-secret -n ${NAMESPACE} --from-literal=accesskey='<ACCESS_KEY>' --from-literal=secretkey='<SECRET_KEY>'"
    return 1
  fi

  if [ -z "${HARBOR_TRIVY_STORAGE_CLASS}" ] && [ -z "${RWX_STORAGE_CLASS}" ]; then
    echo "Either HARBOR_TRIVY_STORAGE_CLASS or RWX_STORAGE_CLASS is required when HARBOR_ENABLED=true"
    return 1
  fi

  HARBOR_EFFECTIVE_TRIVY_STORAGE_CLASS="${HARBOR_TRIVY_STORAGE_CLASS:-${RWX_STORAGE_CLASS}}"

  if ! oc get storageclass "${HARBOR_EFFECTIVE_TRIVY_STORAGE_CLASS}" >/dev/null 2>&1; then
    echo "StorageClass ${HARBOR_EFFECTIVE_TRIVY_STORAGE_CLASS} does not exist"
    return 1
  fi

  echo "Using Harbor Trivy storage class: ${HARBOR_EFFECTIVE_TRIVY_STORAGE_CLASS}"

  validate_harbor_openshift_scc || return 1

  echo "Waiting for Harbor dependency secrets"

  for secret in devops-loop-valkey devops-loop-postgresql; do
    if ! wait_for_secret "${secret}" 1200; then
      echo "WARNING: Required Harbor dependency secret ${secret} was not available within timeout period."
      echo "Skipping Harbor installation/upgrade. DevOps Loop base installation completed successfully."
      echo "After ${secret} is available, rerun this script to enable Harbor."
      return 0
    fi
  done

  REDIS_PASSWORD=$(oc get secret devops-loop-valkey \
    -n "${NAMESPACE}" \
    -o jsonpath="{.data.valkey-password}" | base64 -d)

  S3_ACCESS_KEY=$(oc get secret harbor-s3-secret \
    -n "${NAMESPACE}" \
    -o jsonpath="{.data.accesskey}" | base64 -d)

  S3_SECRET_KEY=$(oc get secret harbor-s3-secret \
    -n "${NAMESPACE}" \
    -o jsonpath="{.data.secretkey}" | base64 -d)

  if [ -z "${HARBOR_OIDC_ADMIN_GROUP}" ]; then
    HARBOR_OIDC_ADMIN_GROUP=harbor-admins
  fi

  echo "Using Harbor OIDC admin group: ${HARBOR_OIDC_ADMIN_GROUP}"
  HARBOR_URL="${HARBOR_EXTERNAL_URL:-https://harbor.${DOMAIN}}"

  HARBOR_HELM_OPTIONS="${HELM_OPTIONS} \
--set harbor.enabled=true \
--set platform.harbor.enabled=true \
--set-string harbor.serviceAccountName=${HARBOR_SERVICE_ACCOUNT} \
--set-string harbor.nginx.serviceAccountName=${HARBOR_SERVICE_ACCOUNT} \
--set-string harbor.portal.serviceAccountName=${HARBOR_SERVICE_ACCOUNT} \
--set-string harbor.core.serviceAccountName=${HARBOR_SERVICE_ACCOUNT} \
--set-string harbor.jobservice.serviceAccountName=${HARBOR_SERVICE_ACCOUNT} \
--set-string harbor.registry.serviceAccountName=${HARBOR_SERVICE_ACCOUNT} \
--set-string harbor.trivy.serviceAccountName=${HARBOR_SERVICE_ACCOUNT} \
--set-string harbor.exporter.serviceAccountName=${HARBOR_SERVICE_ACCOUNT} \
--set-string harbor.externalURL=${HARBOR_URL} \
--set-string harbor.oidc.adminGroup=${HARBOR_OIDC_ADMIN_GROUP} \
--set-string harbor.redis.external.password=${REDIS_PASSWORD} \
--set-string harbor.trivy.externalRedis.password=${REDIS_PASSWORD} \
--set-string harbor.persistence.imageChartStorage.s3.bucket=${HARBOR_S3_BUCKET} \
--set-string harbor.persistence.imageChartStorage.s3.region=${HARBOR_S3_REGION} \
--set-string harbor.persistence.imageChartStorage.s3.regionendpoint=${HARBOR_S3_ENDPOINT} \
--set-string harbor.persistence.imageChartStorage.s3.accesskey=${S3_ACCESS_KEY} \
--set-string harbor.persistence.imageChartStorage.s3.secretkey=${S3_SECRET_KEY} \
--set-string harbor.trivy.persistence.storageClass=${HARBOR_EFFECTIVE_TRIVY_STORAGE_CLASS}
"

  echo "Installing optional Harbor integration..."
  
  HARBOR_HELM_OPTIONS="${HARBOR_HELM_OPTIONS} ${ADDITIONAL_HELM_OPTIONS}"
  helm upgrade --install "${HELM_NAME}" "${ROOT_DIR}" ${HARBOR_HELM_OPTIONS} \
  --hide-notes \
  --timeout 30m \
  -n "${NAMESPACE}" -f "${ROOT_DIR}/values-openshift.yaml" || return 1

  echo "DevOps Loop + Harbor installation completed."
  echo ""
  echo "Harbor URL:"
  echo "  https://harbor.${DOMAIN}"
  echo ""
  echo "Monitor Harbor pods:"
  echo "  oc get pods -n ${NAMESPACE} | grep harbor"
  echo ""
  echo "Bootstrap Harbor images:"
  echo "  1. Update scripts/harbor/bootstrap-images.txt"
  echo "  2. Run:"
  echo "     DOMAIN=${DOMAIN} NAMESPACE=${NAMESPACE} RELEASE=${HELM_NAME} scripts/harbor/bootstrap-images.sh"

}

run_install
```

## Backup

See Solution Documentation for information on backup.

## Uninstall

Delete the product:

```bash
NAMESPACE=devops-loop
HELM_NAME=devops-loop
helm uninstall $HELM_NAME -n $NAMESPACE
```

The claims and persistent volumes that contain user data are not automatically be deleted. If you re-install the product these resources will be re-used if present.

To delete _EVERYTHING_, including user data contained in claims and persistent volumes

```bash
NAMESPACE=devops-loop
oc delete project $NAMESPACE
```

Note: This will hang if the namespace contains workload which has not terminated.

### Configuration

| Parameter                                      | Description | Default |
|------------------------------------------------|-------------|---------|
| `license`                                      | Confirmation that the EULA has been accepted. For example `true` | REQUIRED |
| `global.passwordSeed`                          | The seed used to generate all passwords. | REQUIRED |
| `global.platform.smtp.host`                    | SMTP server host  | REQUIRED |
| `global.platform.smtp.port`                    | SMTP server port number | REQUIRED |
| `global.rationalLicenseKeyServer`              | Where floating licenses are hosted to entitle use of the product. For example `@ip-address` | REQUIRED |
| `global.platform.smtp.sender`                  | The SMTP sender email address has to delivered from on-boarding process | REQUIRED |
| `global.platform.smtp.username`                | SMTP server username | "" |
| `global.platform.smtp.password`                | SMTP server password | "" |
| `global.platform.smtp.startTLS`                | This parameter sets the mail server to secure protocol using TLS or SSL. Accepted values are:<br>- _true_ to set secure protocol using TLS or SSL.<br>- _false_ to set unsecure protocol | false |
| `global.platform.smtp.smtps`                   | This parameter sets the mail server protocol. Accepted values are:<br>- _true_ to set smtps protocol.<br>- _false_ to set smtp protocol. | false |
| `global.persistence.rwoStorageClass`           | The RWO storageClass to use if the cluster default is not appropriate. | '' |
| `global.persistence.rwxStorageClass`           | The RWX storageClass to use if the cluster default is not appropriate. | '' |

#### Solution Configuration

Additional configuration for solutions is managed via helm parameters. See Solution Documentation for details.

Each helm parameter specific to a solution will be prefixed by its helm chart name.

* **Plan**: `ibm-devopsplan-prod`
* **Test**: `ibm-devops-prod`
* **Deploy**: `ibm-ucd-prod`
* **Measure**: `ibm-ucv-prod`

For example, to configure a property in the Plan solution, use the following:

```bash
--set ibm-devopsplan-prod.property=value
```

### Solution Documentation

[Plan](https://github.com/IBM/charts/blob/master/repo/ibm-helm/ibm-devopsplan-prod.md)

[Test](https://github.com/IBM/charts/blob/master/repo/ibm-helm/ibm-devops-prod.md)

[Deploy](https://github.com/IBM/charts/blob/master/repo/ibm-helm/ibm-ucd-prod.md)

[Measure](https://github.com/IBM/charts/blob/master/repo/ibm-helm/ibm-ucv-prod.md)
