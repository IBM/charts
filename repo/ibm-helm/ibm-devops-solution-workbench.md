# IBM DevOps Solution Workbench

## Introduction

IBM DevOps Solution Workbench helps you to accelerate design and development of enterprise-grade cloud solutions.

IBM DevOps Solution Workbench provides access to a specialized collection of tools and project stacks to automate and 
streamline recurring solution patterns using industry best practices and modern architecture principles. It enables the 
quick initiation of development projects with tools tailored for various services and allows customization to meet 
specific solution needs. Users can leverage a consistent foundation of platform services and standards across all 
projects, enhancing efficiency and reusability.

IBM DevOps Solution Workbench offers a collaborative design environment that brings together domain experts, developers, 
architects, and operations teams to work efficiently. It allows teams to capture requirements iteratively and transform 
them into machine-readable design models, ensuring standardization across projects with specialized design tools. This 
shared environment enhances collaboration and streamlines the design process.

IBM DevOps Solution Workbench accelerates development by automatically generating up to 70% of the required code, 
seamlessly transforming design models into cloud-native microservices. It allows developers to concentrate on business 
logic while adhering to best practices, thus maximizing creativity and productivity.

## K8s Installation Instructions

## Prerequisites

  1. An available K8s cluster.  
  
  2. [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).
  
  3. A valid public certificates issued by trusted Certificate Authorities (CAs).

  4. For installation instructions and requisite requirements, see Installation of DevOps Solution Workbench at <https://docs-devops-solution-workbench.knowis.net/5.1/docs/installing-upgrading/>
  
  5. Image and Helm Chart - The DevOps Solution Workbench images and helm chart can be accessed via the Entitled Registry and public Helm repository.

    * The public Helm chart repository can be accessed at <https://github.com/IBM/charts/tree/master/repo/ibm-helm> and directions for accessing the DevOps Solution Workbench chart will be discussed later in this README.
    * Get a key to the entitled registry
      * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
      * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
      * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  Note: Secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Solution Workbench into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

      ```bash
      kubectl create secret docker-registry ibm-entitlement-key \
        --namespace [namespace_name] \
        --docker-username=iamapikey \
        --docker-password=<EntitlementKey> \
        --docker-server=cp.icr.io
      ```

### Licensing

DevOps Solution Workbench requires an installed IBM Rational License Key Server (RLKS).  You must specify this RLKS server during installation.

See IBM Rational License Key Server documentation for more details.

## Install

Before you begin, follow requisite steps and configuration at Installation of DevOps Solution Workbench:  <https://docs-devops-solution-workbench.knowis.net/5.1/docs/installing-upgrading/>

Fetch chart for install:

```bash
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
```

Create Admin resources (crds and cluster roles):
```bash
oc apply -f lib/aggregate-roles.yaml
oc apply -f lib/crds.yaml
```

```bash

#Required
#External fully qualified domain name of the cluster
#
#See Installation of DevOps Solution Workbench documentation for more details:
#https://www.ibm.com/docs/en/devops-solution-workbench/1.0.3?topic=administration-installation-devops-solution-workbench
DOMAIN=

#Required
#Set value to 'true' to accept the license.
ACCEPT_LICENSE=

#Required
#Hostname of IBM Rational license server
#E.g.: "27000@license.domain"
LICENSE_SERVER=

#Required
NAMESPACE=devops-solution-workbench
HELM_NAME=devops-solution-workbench
CHART_VERSION=5.1.0

#Required
#E.g.: "mongodb://admin:password@mongodb.namespace.svc.cluster.local:27017/admin"
MONGODB_CONNECTION_STRING=

#Required
#Keycloak Config
KEYCLOAK_HOSTNAME=
KEYCLOAK_REALM=
KEYCLOAK_ADMIN_USERNAME=
KEYCLOAK_ADMIN_PW=

#Optional Additional Helm options
ADDITIONAL_HELM_OPTIONS=""

ROOT_DIR=./ibm-devops-solution-workbench

run_install() {

  if ! kubectl get namespace ${NAMESPACE} > /dev/null 2>&1; then
    kubectl  create namespace ${NAMESPACE} || { echo "Failed to create namespace"; return 1; }
  fi

  if ! kubectl get secret k5-designer-mongodb --namespace ${NAMESPACE} > /dev/null 2>&1; then
    kubectl create secret generic k5-designer-mongodb --namespace ${NAMESPACE} --from-literal=connectionString="${MONGODB_CONNECTION_STRING}" 1> /dev/null || { echo "Failed to create MongoDB secret"; return 1; }
  fi
  
  if ! kubectl get secret k5-iam-secret --namespace ${NAMESPACE} > /dev/null 2>&1; then
    kubectl create secret generic k5-iam-secret --namespace ${NAMESPACE} --from-literal=adminUsername="${KEYCLOAK_ADMIN_USERNAME}" --from-literal=adminPassword="${KEYCLOAK_ADMIN_PW}" 1> /dev/null || { echo "Failed to create MongoDB secret"; return 1; }
  fi
  
  if ! kubectl get secret k5-iam-settings --namespace ${NAMESPACE} > /dev/null 2>&1; then
    kubectl create secret generic k5-iam-settings --namespace ${NAMESPACE} --from-literal=hostname="${KEYCLOAK_HOSTNAME}" --from-literal=realm="${KEYCLOAK_REALM=}" 1> /dev/null || { echo "Failed to create MongoDB secret"; return 1; }
  fi

   HELM_OPTIONS="${HELM_OPTIONS:-} \
   --set global.domain=${DOMAIN} \
   --set global.rationalLicenseKeyServer=${LICENSE_SERVER} \
   --set global.network.egressPolicy.enabled=false
   --set global.network.ingressPolicy.enabled=true
   --set license=${ACCEPT_LICENSE}
   "

  HELM_OPTIONS="${HELM_OPTIONS} ${ADDITIONAL_HELM_OPTIONS}"

  helm upgrade --install ${HELM_NAME} ibm-helm/ibm-devops-solution-workbench --version ${CHART_VERSION} ${HELM_OPTIONS} \
    -n ${NAMESPACE} -f ${ROOT_DIR}/values-k8s.yaml  || return 1
}

run_install
```

## Backup

See Solution Documentation for information on backup.

## Uninstall

Delete the product:

```bash
NAMESPACE=devops-solution-workbench
HELM_NAME=devops-solution-workbench
helm uninstall $HELM_NAME -n $NAMESPACE
```

The claims and persistent volumes that contain user data are not automatically be deleted. If you re-install the product these resources will be re-used if present.

To delete _EVERYTHING_, including user data contained in claims and persistent volumes

```bash
NAMESPACE=devops-solution-workbench
kubectl delete namespace $NAMESPACE
```

Note: This will hang if the namespace contains workload which has not terminated.

### Configuration

| Parameter                            | Description                                                                                 | Default |
|--------------------------------------|---------------------------------------------------------------------------------------------|---------|
| `license`                            | Confirmation that the EULA has been accepted. For example `true`                            | REQUIRED |
| `global.domain`                      | External fully qualified domain name of the cluster                                         | REQUIRED |
| `global.network.egressPolicy.enabled`  | Enable/disable default Egress Network Policy                                                | REQUIRED |
| `global.network.ingressPolicy.enabled` | Enable/disable default Ingress Network Policy                                               | REQUIRED |
| `global.rationalLicenseKeyServer`    | Where floating licenses are hosted to entitle use of the product. For example `@ip-address` | REQUIRED |


## OpenShift Installation Instructions

## Prerequisites

1. OpenShift, OpenShift CLI (oc), and Helm 3.

    * [RedHat OpenShift Container Platform](https://docs.openshift.com/container-platform/4.18/release_notes/ocp-4-18-release-notes.html) v4.16 or later (x86_64)

    * [Install and setup OpenShift CLI](https://docs.openshift.com/container-platform/4.18/cli_reference/openshift_cli/getting-started-cli.html)

    * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Image and Helm Chart - The DevOps Solution Workbench images, and helm chart can be accessed via the Entitled Registry and public Helm repository.

    * The public Helm chart repository can be accessed at <https://github.com/IBM/charts/tree/master/repo/ibm-helm> and directions for accessing the DevOps Solution Workbench chart will be discussed later in this README.
    * Get a key to the entitled registry
      * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
      * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
      * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  Note: Secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Solution Workbench into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

      ```bash
      oc create secret docker-registry ibm-entitlement-key \
        --namespace [namespace_name] \
        --docker-username=cp \
        --docker-password=<EntitlementKey> \
        --docker-server=cp.icr.io
      ```

### Licensing

DevOps Solution Workbench requires an installed IBM Rational License Key Server (RLKS).  You must specify this RLKS server during installation.

See IBM Rational License Key Server documentation for more details.

## Install

Before you begin, follow requisite steps and configuration at Installation of DevOps Solution Workbench:  <https://docs-devops-solution-workbench.knowis.net/5.1/docs/installing-upgrading/>

Fetch chart for install:

```bash
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
helm pull --untar ibm-helm/ibm-devops-solution-workbench --version 5.1.0
```

Create Admin resources (crds and cluster roles):
```bash
oc apply -f lib/aggregate-roles.yaml
oc apply -f lib/crds.yaml
```

```bash
#Pull ibm helm charts
CHART_VERSION=5.1.0
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
helm pull --untar ibm-helm/ibm-devops-solution-workbench --version ${CHART_VERSION}
#
#Required
#External fully qualified domain name of the cluster
#
# Note: The default configuration inherits the default domain when you created
# your Openshift cluster.  You may also choose to further customize the
# domain such as adding a prefix, for instance devops-solution-workbench.$(oc get....),
# using an altnernative ingress controller, or directly specifying a fully
# qualified name associated with your cluster.
#
#See Installation of DevOps Solution Workbench documentation for more details:
#https://docs-devops-solution-workbench.knowis.net/5.1/docs/installing-upgrading/
DOMAIN=$(oc get -n openshift-ingress-operator ingresscontroller default -o jsonpath='{.status.domain}')

#Required
#Set value to 'true' to accept the license.
ACCEPT_LICENSE=

#Required
#Hostname of IBM Rational license server
#E.g.: "27000@license.domain"
LICENSE_SERVER=

#Required
NAMESPACE=devops-solution-workbench
HELM_NAME=devops-solution-workbench

#Required
#E.g.: "mongodb://admin:password@mongodb.namespace.svc.cluster.local:27017/admin"
MONGODB_CONNECTION_STRING=

#Required
#Keycloak Config
KEYCLOAK_HOSTNAME=
KEYCLOAK_REALM=
KEYCLOAK_ADMIN_USERNAME=
KEYCLOAK_ADMIN_PW=

#Optional Additional Helm options
ADDITIONAL_HELM_OPTIONS=""

ROOT_DIR=./ibm-devops-solution-workbench

run_install() {

  if ! oc get namespace ${NAMESPACE} > /dev/null 2>&1; then
    oc create namespace ${NAMESPACE} || { echo "Failed to create namespace"; return 1; }
  fi
  
  

  if ! oc get secret k5-designer-mongodb --namespace ${NAMESPACE} > /dev/null 2>&1; then
    oc create secret generic k5-designer-mongodb --namespace ${NAMESPACE} --from-literal=connectionString="${MONGODB_CONNECTION_STRING}" 1> /dev/null || { echo "Failed to create MongoDB secret"; return 1; }
  fi
  
  if ! oc get secret k5-iam-secret --namespace ${NAMESPACE} > /dev/null 2>&1; then
    oc create secret generic k5-iam-secret --namespace ${NAMESPACE} --from-literal=adminUsername="${KEYCLOAK_ADMIN_USERNAME}" --from-literal=adminPassword="${KEYCLOAK_ADMIN_PW}" 1> /dev/null || { echo "Failed to create MongoDB secret"; return 1; }
  fi
  
  if ! oc get secret k5-iam-settings --namespace ${NAMESPACE} > /dev/null 2>&1; then
    oc create secret generic k5-iam-settings --namespace ${NAMESPACE} --from-literal=hostname="${KEYCLOAK_HOSTNAME}" --from-literal=realm="${KEYCLOAK_REALM=}" 1> /dev/null || { echo "Failed to create MongoDB secret"; return 1; }
  fi

   HELM_OPTIONS="${HELM_OPTIONS:-} \
   --set global.domain=${DOMAIN} \
   --set global.rationalLicenseKeyServer=${LICENSE_SERVER} \
   --set global.network.egressPolicy.enabled=false
   --set global.network.ingressPolicy.enabled=true
   --set license=${ACCEPT_LICENSE}
   "

  fi

  HELM_OPTIONS="${HELM_OPTIONS} ${ADDITIONAL_HELM_OPTIONS}"

  helm upgrade --install ${HELM_NAME} ${ROOT_DIR} ${HELM_OPTIONS} -n ${NAMESPACE} || return 1

}

run_install
```

## Backup

See Solution Documentation for information on backup.

## Uninstall

Delete the product:

```bash
NAMESPACE=devops-solution-workbench
HELM_NAME=devops-solution-workbench
helm uninstall $HELM_NAME -n $NAMESPACE
```

The claims and persistent volumes that contain user data are not automatically be deleted. If you re-install the product these resources will be re-used if present.

To delete _EVERYTHING_, including user data contained in claims and persistent volumes

```bash
NAMESPACE=devops-solution-workbench
oc delete project $NAMESPACE
```

Note: This will hang if the namespace contains workload which has not terminated.

### Configuration

| Parameter                              | Description                                                                                 | Default |
|----------------------------------------|---------------------------------------------------------------------------------------------|---------|
| `license`                              | Confirmation that the EULA has been accepted. For example `true`                            | REQUIRED |
| `global.domain`                        | External fully qualified domain name of the cluster                                         | REQUIRED |
| `global.network.egressPolicy.enabled`  | Enable/disable default Egress Network Policy                                                | REQUIRED |
| `global.network.ingressPolicy.enabled` | Enable/disable default Ingress Network Policy                                               | REQUIRED |
| `global.rationalLicenseKeyServer`      | Where floating licenses are hosted to entitle use of the product. For example `@ip-address` | REQUIRED |


### Solution Documentation

[DevOps Solution Workbench](https://docs-devops-solution-workbench.knowis.net/5.1/docs/about/overview/)
