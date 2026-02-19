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

# OpenShift Installation Instructions

## Prerequisites

1. OpenShift, Keycloak, OpenShift CLI (oc), and Helm 3.

   * [RedHat OpenShift Container Platform](https://docs.openshift.com/container-platform/4.18/release_notes/ocp-4-18-release-notes.html) v4.16 or later (x86_64)

   * [Red Hat build of Keycloak](https://access.redhat.com/products/red-hat-build-of-keycloak/) in version 26

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
       --docker-server=icr.io
     ```

### Licensing

DevOps Solution Workbench requires an installed IBM Rational License Key Server (RLKS).  You must specify this RLKS server during installation.

See IBM Rational License Key Server documentation for more details.

## Install

Before you begin, follow requisite steps and configuration at Installation of DevOps Solution Workbench:  <https://docs-devops-solution-workbench.knowis.net/5.1/docs/installing-upgrading/>

Fetch chart for install:

```bash
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
helm pull --untar ibm-helm/ibm-devops-model --version 5.1.1
```


```bash
#Pull ibm helm charts
CHART_VERSION=5.1.1
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
helm pull --untar ibm-helm/ibm-devops-model --version ${CHART_VERSION}
#
#Required
#External fully qualified domain name of the cluster
#See Installation of DevOps Solution Workbench documentation for more details:
#https://docs-devops-solution-workbench.knowis.net/5.1/docs/installing-upgrading/
CLUSTER_DOMAIN=$(oc get -n openshift-ingress-operator ingresscontroller default -o jsonpath='{.status.domain}')
#E.g.: DOMAIN="k5-designer.apps.openshift.cluster.cloud"
DOMAIN="k5-designer.${CLUSTER_DOMAIN}"

#Optional
#External fully qualified url of openshift console
#E.g.: OPENSHIFT_CONSOLE_URL="https://console-openshift-console.apps.openshift.cluster.cloud"
OPENSHIFT_CONSOLE_URL="https://console-openshift-console.${CLUSTER_DOMAIN}"

#Required
#Set value to 'true' to accept the license.
ACCEPT_LICENSE=

#Required
#Hostname of IBM Rational license server
#E.g.: "@license.domain"
LICENSE_SERVER=

#Required
#Secure seed required to generate passwords
#A random string
#Unrecoverable so keep it safe
PASSWORD_SEED=

#Required
NAMESPACE=devops-model
HELM_NAME=devops-model

#Optional
#if you are using an own or external mongoDB
#E.g.: "mongodb://mongo:password@mongodb.namespace.svc.cluster.local:27017/admin"
MONGODB_CONNECTION_STRING=

#Required
#Keycloak Config (including /auth path if required)
#e.g.: "https://keycloak.apps.openshift.cluster.cloud/auth
KEYCLOAK_URL=
KEYCLOAK_REALM="devops-model"
KEYCLOAK_ADMIN_USERNAME=
KEYCLOAK_ADMIN_PW=

#Optional Additional Helm options
ADDITIONAL_HELM_OPTIONS=""

ROOT_DIR=./ibm-devops-model

run_install() {

  if ! oc get namespace ${NAMESPACE} > /dev/null 2>&1; then
    oc create namespace ${NAMESPACE} || { echo "Failed to create namespace"; return 1; }
  fi
  
      
  if [ -n "${MONGODB_CONNECTION_STRING}" ]; then 
      if ! oc get secret mongodb-url-secret --namespace ${NAMESPACE} > /dev/null 2>&1; then
        oc create secret generic mongodb-url-secret --namespace ${NAMESPACE} --from-literal=connectionString="${MONGODB_CONNECTION_STRING}" 1> /dev/null || { echo "Failed to create MongoDB secret"; return 1; }
      fi
      HELM_OPTIONS="${HELM_OPTIONS} --set database.enabled=false"
  fi
  

   HELM_OPTIONS="${HELM_OPTIONS:-} \
   --set global.domain=${DOMAIN} \
   --set-literal global.passwordSeed=${PASSWORD_SEED} \
   --set global.rationalLicenseKeyServer=${LICENSE_SERVER} \
   --set global.k5.identity.url=${KEYCLOAK_URL} \
   --set global.k5.identity.realm=${KEYCLOAK_REALM} \
   --set global.k5.identity.username=${KEYCLOAK_ADMIN_USERNAME} \
   --set global.k5.identity.password=${KEYCLOAK_ADMIN_PW} \
   --set global.openshiftConsole=${OPENSHIFT_CONSOLE_URL} \
   --set k5-pipeline-manager.tekton.initialize=false \
   --set license="${ACCEPT_LICENSE}" 
   "

  HELM_OPTIONS="${HELM_OPTIONS} ${ADDITIONAL_HELM_OPTIONS}"

  helm upgrade --install ${HELM_NAME} ${ROOT_DIR} ${HELM_OPTIONS} -n ${NAMESPACE} --force-conflicts  || return 1

}

run_install
```

## Uninstall

Delete the product:

```bash
NAMESPACE=devops-model
HELM_NAME=devops-model
helm uninstall $HELM_NAME -n $NAMESPACE
```

The claims and persistent volumes that contain user data are not automatically be deleted. If you re-install the product these resources will be re-used if present.

To delete _EVERYTHING_, including user data contained in claims and persistent volumes

```bash
NAMESPACE=devops-model
oc delete project $NAMESPACE
```

Note: This will hang if the namespace contains workload which has not terminated.

### Configuration

| Parameter                                  | Description                                                                                 | Default  |
|--------------------------------------------|---------------------------------------------------------------------------------------------|----------|
| `license`                                  | Confirmation that the EULA has been accepted. For example `true`                            | REQUIRED |
| `global.domain`                            | Domain is the ingress domain which is used to create routes.                                | REQUIRED |
| `global.rationalLicenseKeyServer`          | Where floating licenses are hosted to entitle use of the product. For example `@ip-address` | REQUIRED |
| `global.k5.identity.url`                   | Keycloak URL (including `/auth` path if needed)                                             | REQUIRED |
| `global.k5.identity.realm`                 | Keycloak Realm that will be created during installation                                     | REQUIRED |
| `global.k5.identity.username`              | Keycloak Admin username                                                                     | REQUIRED |
| `global.k5.identity.password`              | Keycloak Admin password                                                                     | REQUIRED |
| `global.k5.autoscaling.enabled`            | Enable/disable Horizontal Pod Autoscaling (if disabled 1 pod per service is created)        | `true`   |
| `global.k5.network.routing.routes.enabled` | Enable/disable creation of Routes                                                           | `true`   |
| `global.k5.runtime.enabled`                | Enable/disable default runtime components                                                   | `true`   |
| `database.enabled`                         | Enable/disable default runtime components                                                   | `true`   |
| `rbac.create`                              | Enable/disable creation of needed ServiceAccounts, RoleBindings and Roles                   | `true`   |
| `runtime.aggregateRoles.create`            | Enable/disable creation of aggregation roles (needed for runtime)                           | `true`   |
| `runtime.crds.create`                      | Enable/disable creation of CustomResourceDefinitions (needed for runtime)                   | `true`   |
| `networkPolicy.create`                     | Enable/disable default Ingress Network Policy                                               | `false`  |
| `runtime.scc.create`                       | Enable/disable creation of Security Context Constraints (needed for runtime)                | `true`   |
| `truststore.create`                        | Enable/disable creation of Default Truststore                                               | `true`   |


### Routes Configuration

On OpenShift, the chart creates the following routes. They use the same host derived from `global.domain` (e.g. `k5-designer.<cluster-domain>`) except where a route has its own host.

In case the Routes need to be created manually the creation can be disabled via the helm chart setting: `global.k5.network.routing.routes.enabled=false`

The following table shows the required Routes:

| Route Name                            | Path         | Target Service                          | Rewrite target | Target port   | TLS policy | TLS termination |
|---------------------------------------|--------------|-----------------------------------------|----------------|---------------|------------|-----------------|
| `k5-designer-frontend-route`          | `/`          | `k5-designer-frontend-service`          | —              | https         | Redirect   | reencrypt       |
| `k5-designer-backend-route`           | `/backend`   | `k5-designer-backend-service`           | `/`            | https         | Redirect   | reencrypt       |
| `k5-diagram-modeller-route`           | `/diagram`   | `k5-diagram-modeller-service`           | `/`            | https         | Redirect   | reencrypt       |
| `k5-code-generation-provider-route`   | `/codegen`   | `k5-code-generation-provider-service`   | `/`            | https         | Redirect   | reencrypt       |
| `k5-git-integration-controller-route` | `/gic`       | `k5-git-integration-controller-service` | `/`            | https         | Redirect   | reencrypt       |
| `k5-configuration-management`         | `/cfg`       | `k5-configuration-management`           | —              | https         | Redirect   | reencrypt       |
| `k5-hub-backend-route`                | `/hub`       | `k5-hub-backend-service`                | `/`            | https         | Redirect   | reencrypt       |
| `k5-shortlink-route`                  | `/shortlink` | `k5-shortlink-service`                  | `/`            | https         | Redirect   | reencrypt       |
| `k5-pipeline-triggerwebhook`          | — (own host) | `el-k5-git-trigger`                     | —              | http-listener | —          | edge            |

- **Rewrite target**: `haproxy.router.openshift.io/rewrite-target` annotation; `—` means not set.
- `k5-pipeline-triggerwebhook` Route is only needed for "auto trigger" feature of Tekton Pipelines.


### Solution Documentation

[DevOps Solution Workbench](https://docs-devops-solution-workbench.knowis.net/5.1/docs/about/overview/)


# K8s Installation Instructions

## Prerequisites

1. An available K8s cluster.

2. Keycloak in version 26.

3. [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

4. Installed and configured [Emissary Ingress Controller](https://emissary-ingress.dev/docs/3.9/topics/running/ingress-controller/)
* See and execute install script ./lib/ingress-forwarding-emissary-install.sh

   5. Image and Helm Chart - The DevOps Solution Workbench images, and helm chart can be accessed via the Entitled Registry and public Helm repository.

* The public Helm chart repository can be accessed at <https://github.com/IBM/charts/tree/master/repo/ibm-helm> and directions for accessing the DevOps Solution Workbench chart will be discussed later in this README.
* Get a key to the entitled registry
   * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
   * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
   * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  Note: Secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Solution Workbench into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

  ```bash
  kubectl create secret docker-registry ibm-entitlement-key \
    --namespace [namespace_name] \
    --docker-username=cp \
    --docker-password=<EntitlementKey> \
    --docker-server=icr.io
  ```

### Licensing

DevOps Solution Workbench requires an installed IBM Rational License Key Server (RLKS).  You must specify this RLKS server during installation.

See IBM Rational License Key Server documentation for more details.

## Install

Before you begin, follow requisite steps and configuration at Installation of DevOps Solution Workbench:  <https://docs-devops-solution-workbench.knowis.net/5.1/docs/installing-upgrading/>

Fetch chart for install:

```bash
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
helm pull --untar ibm-helm/ibm-devops-model --version 5.1.1
```


```bash
#Pull ibm helm charts
CHART_VERSION=5.1.1
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm --force-update
helm pull --untar ibm-helm/ibm-devops-model --version ${CHART_VERSION}
#
#Required
#External fully qualified domain name of the cluster
#See Installation of DevOps Solution Workbench documentation for more details:
#https://docs-devops-solution-workbench.knowis.net/5.1/docs/installing-upgrading/
#E.g.: DOMAIN="k5-designer.k8s.cluster.cloud"
DOMAIN=

#Required
#Set value to 'true' to accept the license.
ACCEPT_LICENSE=

#Required
#Hostname of IBM Rational license server
#E.g.: "@license.domain"
LICENSE_SERVER=

#Required
#Secure seed required to generate passwords
#A random string
#Unrecoverable so keep it safe
PASSWORD_SEED=

#Required
NAMESPACE=devops-model
HELM_NAME=devops-model

#Optional
#if you are using an own or external mongoDB
#E.g.: "mongodb://mongo:password@mongodb.namespace.svc.cluster.local:27017/admin"
MONGODB_CONNECTION_STRING=

#Set SELF_SIGNED=true to generate and use a self-signed certificate for the
#installation of DevOps Solution Workbench
SELF_SIGNED=false

#Required
#Keycloak Config (including /auth path if required)
#e.g.: "https://keycloak.apps.openshift.cluster.cloud/auth
KEYCLOAK_URL=
KEYCLOAK_REALM="dsw"
KEYCLOAK_ADMIN_USERNAME=
KEYCLOAK_ADMIN_PW=

#Optional Additional Helm options
ADDITIONAL_HELM_OPTIONS=""

ROOT_DIR=./ibm-devops-model

run_install() {

  if ! kubectl get namespace ${NAMESPACE} > /dev/null 2>&1; then
    kubectl create namespace ${NAMESPACE} || { echo "Failed to create namespace"; return 1; }
  fi
  
  if [ -n "${MONGODB_CONNECTION_STRING}" ]; then 
      if ! kubectl get secret mongodb-url-secret --namespace ${NAMESPACE} > /dev/null 2>&1; then
        kubectl create secret generic mongodb-url-secret --namespace ${NAMESPACE} --from-literal=connectionString="${MONGODB_CONNECTION_STRING}" 1> /dev/null || { echo "Failed to create MongoDB secret"; return 1; }
      fi
      HELM_OPTIONS="${HELM_OPTIONS} --set database.enabled=false"
  fi 
  
  if [ "${SELF_SIGNED}" = "true" ]; then
    
    export TLS_CERT_SECRET_NAME=devops-tls-secret
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
    
     HELM_OPTIONS="${HELM_OPTIONS} --set global.privateCaBundleSecretName=${TLS_CERT_SECRET_NAME}"
  fi

   HELM_OPTIONS="${HELM_OPTIONS:-} \
   --set global.domain=${DOMAIN} \
   --set-literal global.passwordSeed=${PASSWORD_SEED} \
   --set global.rationalLicenseKeyServer=${LICENSE_SERVER} \
   --set global.k5.identity.url=${KEYCLOAK_URL} \ 
   --set global.k5.identity.realm=${KEYCLOAK_REALM} \ 
   --set global.k5.identity.username=${KEYCLOAK_ADMIN_USERNAME} \ 
   --set global.k5.identity.password=${KEYCLOAK_ADMIN_PW} \ 
   --set license=${ACCEPT_LICENSE}
   "

  HELM_OPTIONS="${HELM_OPTIONS} ${ADDITIONAL_HELM_OPTIONS}"

  helm upgrade --install ${HELM_NAME} ${ROOT_DIR} ${HELM_OPTIONS} -n ${NAMESPACE} --force-conflicts  || return 1

}

run_install
```


## Uninstall

Delete the product:

```bash
NAMESPACE=devops-model
HELM_NAME=devops-model
helm uninstall $HELM_NAME -n $NAMESPACE
```

The claims and persistent volumes that contain user data are not automatically be deleted. If you re-install the product these resources will be re-used if present.

To delete _EVERYTHING_, including user data contained in claims and persistent volumes

```bash
NAMESPACE=devops-model
kubectl delete namespace $NAMESPACE
```

Note: This will hang if the namespace contains workload which has not terminated.

### Configuration

| Parameter                         | Description                                                                                 | Default  |
|-----------------------------------|---------------------------------------------------------------------------------------------|----------|
| `license`                         | Confirmation that the License has been accepted. Must be `true`                             | REQUIRED |
| `global.domain`                   | Domain is the ingress domain which is used to create routes                                 | REQUIRED |
| `global.rationalLicenseKeyServer` | Where floating licenses are hosted to entitle use of the product. For example `@ip-address` | REQUIRED |
| `global.k5.identity.url`          | Keycloak URL (including `/auth` path if needed)                                             | OPTIONAL |
| `global.k5.identity.realm`        | Keycloak Realm that will be created during installation                                     | OPTIONAL |
| `global.k5.identity.username`     | Keycloak Admin username                                                                     | OPTIONAL |
| `global.k5.identity.password`     | Keycloak Admin password                                                                     | OPTIONAL |
| `global.k5.autoscaling.enabled`   | Enable/disable Horizontal Pod Autoscaling (if disabled 1 pod per service is created)        | `false`  |
| `global.k5.runtime.enabled`       | Enable/disable default runtime components                                                   | `false`  |
| `database.enabled`                | Enable/disable installation of included database (if false an own mongoDB must be provided) | `false`  |
| `rbac.create`                     | Enable/disable creation of needed ServiceAccounts, RoleBindings and Roles                   | `false`  |
| `runtime.aggregateRoles.create`   | Enable/disable creation of aggregation roles (needed for runtime)                           | `false`  |
| `runtime.crds.create`             | Enable/disable creation of CustomResourceDefinitions (needed for runtime)                   | `false`  |
| `networkPolicy.create`            | Enable/disable default Ingress Network Policy                                               | `false`  |
| `runtime.scc.create`              | Enable/disable creation of Security Context Constraints (needed for runtime)                | `false`  |
| `truststore.create`               | Enable/disable creation of Default Truststore                                               | `true`   |
