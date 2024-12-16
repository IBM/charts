# IBM DevOps Automation

## Introduction

IBM DevOps Automation is a cloud-based continuous integration platform built on modern, cloud-native technologies that enables product teams to plan, code, test, and deploy the applications and also provides a holistic view of the progress in the DevOps cycle. Automation is built to install on IBM® Red Hat OpenShift.

## Prerequisites

1. OpenShift, OpenShift CLI (oc), and Helm 3.

    * [RedHat OpenShift Container Platform](https://docs.openshift.com/container-platform/4.15/release_notes/ocp-4-15-release-notes.html) v4.15 or later (x86_64)

    * [Install and setup OpenShift CLI](https://docs.openshift.com/container-platform/4.14/cli_reference/openshift_cli/getting-started-cli.html)

    * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Image and Helm Chart - The DevOps Plan images, and helm chart can be accessed via the Entitled Registry and public Helm repository.

    * The public Helm chart repository can be accessed at <https://github.com/IBM/charts/tree/master/repo/ibm-helm> and directions for accessing the DevOps Plan chart will be discussed later in this README.
    * Get a key to the entitled registry
      * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
      * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
      * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  Note: Secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Plan into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

      ```bash
      oc create secret docker-registry ibm-entitlement-key \
        --namespace [namespace_name] \
        --docker-username=cp \
        --docker-password=<EntitlementKey> \
        --docker-server=cp.icr.io
      ```

## Red Hat OpenShift Sysdig Requirements

IBM Cloud deploys Sysdig into Red Hat OpenShift. The default configuration causes many warnings in the RabbitMQ pod that eventually causes pod restarts.

```text
2023-02-23 01:55:01.045358+00:00 [warning] <0.710.0> HTTP access denied: user 'guest' - invalid credentials
2023-02-23 01:55:02.050662+00:00 [warning] <0.711.0> HTTP access denied: user 'guest' - invalid credentials
```

Fix this by filtering out RabbitMQ:

```bash
oc edit configmap sysdig-agent -n ibm-observe
```

Append to dragent.yaml

```text
    use_container_filter: true
    container_filter:
      - exclude:
          kubernetes.pod.label.app.kubernetes.io/name: rabbitmq
      - exclude:
          kubernetes.pod.label.service: velocity-rabbitmq
```

This change propagates after a couple of minutes. [Further reading](https://cloud.ibm.com/docs/monitoring?topic=monitoring-change_kube_agent)

### Storage

If the cluster default StorageClass does not support the ReadWriteMany (RWX) accessMode, an alternative class must be specified using the following additional helm value: global.persistence.rwxStorageClass  For example, ibmc-file-gold.

ReadWriteOnce (RWO) access mode storage can be configured with the following helm value: global.persistence.rwoStorageClass  For example, ibmc-block-gold.

### Licensing

DevOps Automation requires an installed IBM Rational License Key Server (RLKS).  You must specify this RLKS server during installation.

See IBM Rational License Key Server documenation for more details.

## Install

This installation includes locally deployed databases.  This includes a sample install of MongoDB.

See Additional Documentation for advanced configuration and requisite support.

Fetch chart for install:

```bash
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
helm pull --untar ibm-helm/ibm-devops-automation --version 1.0.0
```

```bash
#Required 
#External fully qualified domain name the cluster
#
#Note: The default configuration inherits the default domain when you created your Openshift cluster.
#You may also choose to further customize the domain such as adding a prefix, 
#for instance devops-automation.$(oc get....), using an altnernative ingress controller, or 
#directly specifying a fully qualified associated with your cluster.
DOMAIN=$(oc get -n openshift-ingress-operator ingresscontroller default -o jsonpath='{.status.domain}')

#Required
#Set value to 'true' to accept the license. 
ACCEPT_LICENSE=

#Required 
#Hostname of IBM RLKS license server
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

#Alternative RWX storage class
#See Storage
#For example: ibmc-file-gold
RWX_STORAGE_CLASS=

#Alternative RWX storage class
#See Storage
#For example: ibmc-block-gold
RWO_STORAGE_CLASS=

#Required
NAMESPACE=devops-automation
HELM_NAME=devops-automation

#Optional Additional Helm options
ADDITIONAL_HELM_OPTIONS=""

run_install() { 

  CHART_DIR="${CHART_DIR:-./ibm-devops-automation}"

  if [ ! -d "${CHART_DIR}" ]; then
    echo "Error: Chart directory '${CHART_DIR}' does not exist. Please ensure you are running this script relative to the chart directory."
    return 1
  fi

  if ! oc get namespace ${NAMESPACE} > /dev/null 2>&1; then
    oc create namespace ${NAMESPACE} || { echo "Failed to create namespace"; return 1; }
  fi


  if ! oc get secret mongodb-url-secret --namespace ${NAMESPACE} > /dev/null 2>&1; then

    MONGO_CHART_VERSION="${MONGO_CHART_VERSION:-14.13.0}"
    MONGO_IMAGE_TAG="${MONGO_IMAGE_TAG:-6.0}"
    MONGO_IMAGE_REPO="${MONGO_IMAGE_REPO:-bitnami/mongodb}" 
    MONGO_HELM_RELEASE_NAME="${MONGO_HELM_RELEASE_NAME:-devops-automation-mongo}"
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
    
    if [ -n "${MONGO_ADDITIONAL_INSTALL_OPTIONS}" ]; then
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

  #Creates an empty secret because TLS certificates are provided by OpenShift
  if ! oc get secret empty-secret --namespace ${NAMESPACE} > /dev/null 2>&1; then
    oc create secret generic empty-secret  \
        --from-literal=tls.crt="" \
        --from-literal=tls.key="" \
        --namespace ${NAMESPACE} || { echo "Failed to create TLS secret"; return 1; }
  fi

  HELM_OPTIONS="${HELM_OPTIONS:-} \
--set global.domain=${DOMAIN} \
--set ibm-ucv-prod.url.domain=${DOMAIN} \
--set-literal global.passwordSeed=${PASSWORD_SEED} \
--set global.platform.smtp.sender=${EMAIL_FROM_ADDRESS} \
--set global.platform.smtp.host=${EMAIL_SERVER_HOST} \
--set global.platform.smtp.port=${EMAIL_SERVER_PORT} \
--set global.platform.smtp.username=${EMAIL_SERVER_USERNAME} \
--set global.platform.smtp.password=${EMAIL_SERVER_PASSWORD} \
--set global.platform.smtp.startTLS=${EMAIL_SERVER_STARTTLS} \
--set global.platform.smtp.smtps=${EMAIL_SERVER_SMTPS} \
--set license=${ACCEPT_LICENSE}
"

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

  helm upgrade --install ${HELM_NAME} ${CHART_DIR} ${HELM_OPTIONS} \
    -n ${NAMESPACE} \
    -f ${CHART_DIR}/values-openshift.yaml || return 1

}

run_install
```

## Backup

See Solution Documentation for information on backup.

## Uninstall

Delete the product:

```bash
NAMESPACE=devops-automation
HELM_NAME=devops-automation
helm uninstall $HELM_NAME -n $NAMESPACE
```

The claims and persistent volumes that contain user data are not automatically be deleted. If you re-install the product these resources will be re-used if present.

To delete _EVERYTHING_, including user data contained in claims and persistent volumes

```bash
NAMESPACE=devops-automation
oc delete project $NAMESPACE
```

Note: This will hang if the namespace contains workload which has not terminated.

### Configuration

| Parameter                                      | Description | Default |
|------------------------------------------------|-------------|---------|
| `license`                                      | Confirmation that the EULA has been accepted. For example `true` | REQUIRED |
| `global.domain`                                | The web address to expose the product on. For example `devops.example.com` | REQUIRED |
| `ibm-ucv-prod.url.domain`                      | Same as global.domain for the Velocity solution. | REQUIRED |
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
* **Velocity**: `ibm-ucv-prod`

For example, to configure a property in the Plan solution, use the following:

```bash
--set ibm-devopsplan-prod.property=value
```

### Solution Documentation

[Plan](https://github.com/IBM/charts/blob/master/repo/ibm-helm/ibm-devopsplan-prod.md)

[Test](https://github.com/IBM/charts/blob/master/repo/ibm-helm/ibm-devops-prod.md)

[Deploy](https://github.com/IBM/charts/blob/master/repo/ibm-helm/ibm-ucd-prod.md)

[Velocity](https://github.com/IBM/charts/blob/master/repo/ibm-helm/ibm-ucv-prod.md)
