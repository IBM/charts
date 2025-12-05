# ODM for production Helm chart (ibm-odm-prod)

The [IBM® Operational Decision Manager](https://www.ibm.com/products/operational-decision-manager) (ODM) chart `ibm-odm-prod` is used to deploy a production-ready cluster in IBM Kubernetes environments.

## Introduction

ODM is a tool for capturing, automating, and governing repeatable business decisions. You identify situations about your business and then automate the actions to take as a result of the insight you gained about your policies and customers. For more information, see [ODM in knowledge center](https://www.ibm.com/docs/en/odm/9.5.0).

**Table of Content**

- [Chart Details](#chart-details)
- [Prerequisites](#prerequisites)
- [Installing the Chart](#installing-the-chart)
- [Chart Requirements](#chart-requirements)
- [Security Requirements](#security-requirements)
- [Configuration](#configuration)
- [Limitations](#limitations)
- [Documentation](#documentation)

---

## Chart Details

The `ibm-odm-prod` Helm chart is a package of preconfigured Kubernetes resources that bootstrap an ODM deployment on a Kubernetes cluster. Configuration parameters are available to customize most aspects of the deployment. The default values serve as examples but are appropriate to a production environment and can be used as is.

The `ibm-odm-prod` chart deploys five containers corresponding to the optional internal database server and the four ODM services:
- Decision Center Business Console
- Decision Server Console
- Decision Server Runtime
- Decision Runner

The `ibm-odm-prod` chart supports the following options for persistence:

- PostgreSQL as an internal database. This is the **default** option. Persistent Volume (PV) is required if you choose to use an internal database. PV represents an underlying storage capacity in the infrastructure. PV must be created with accessMode `ReadWriteOnce` and storage capacity of 5Gi or more, before you install ODM. You create a PV in the Admin console or with a `.yaml` file. This internal database is only suitable for prototyping and **not for production**.

- PostgreSQL, Db2, Microsoft SQL Server or Oracle as an external database. If you specify a server name for the external database, the external database is used otherwise the internal database is used. Before you select this option, you must have an external PostgreSQL, Db2, Microsoft SQL Server or Oracle database up and running.

### Architecture

The following architectures are supported:
- amd64  
- ppc64le
- s390x

## Prerequisites

- Kubernetes 1.28+
- Helm aligned with the Kubernetes version.
- One PersistentVolume needs to be created prior to installing the chart if `internalDatabase.persistence.enabled=true` and `internalDatabase.persistence.dynamicProvisioning=false`. In that case, it is required that the securityContext.fsGroup 26 has read and write permissions on the postgres data directory. You can update the permissions by mounting the volume temporarily or accessing the host machine and performing the following commands:

  ```console
  chown -R 26:26 /var/lib/pgsql/data
  chmod -R ug+rw /var/lib/pgsql/data
  ```
  Refer to [Internal Storage Requirements](#internal-storage-requirements) section for more information.

- To preserve sensitive data, you must create a secret that encapsulates the database user and password before you install the Helm release.
  ```
  kubectl create secret generic my-odm-db-secret \
          --from-literal=db-user=<user-name> \
          --from-literal=db-password=<password>
  ```

  For details, refer to [Configuring the database](https://www.ibm.com/docs/en/odm/9.5.0?topic=production-configuring-database).

- Ensure you have a good understanding of the underlying concepts and technologies:
  - Docker, container
  - Kubernetes
  - Helm chart, Helm commands
  - Kubernetes command line tool

- Before you install ODM for production, you need to gather all the configuration information that you will use for your release. For more details, refer to the [Chart Requirements](#chart-requirements) section.
- To protect ODM Decision applications from voluntary disruptions such as draining a node for maintenance or scaling down a cluster, you might want to consider using [PodDisruptionBudgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets).

  A PodDisruptionBudget(PDB) is part of the Kubernetes API for specifying safety constraints on Pods during voluntary disruptions. PDB could ensure a minimum number of pods of a replicated application to be available and helps maintain the high availability of the application.
  For example, if you have a deployment of Decision Server Runtime with 4 replicas and set maxUnavailable to 1, Kubernetes only allows at most 1 replica to be disrupted at a time.

   ```yaml
  apiVersion: policy/v1
  kind: PodDisruptionBudget
  metadata:
    name: dr-pdb
    namespace: odm-namespace
  spec:
    maxUnavailable: 1
    selector:
      matchLabels:
        app.kubernetes.io/component: decisionServerRuntime
    ```
  For Decision Runner, use the following matching label `app.kubernetes.io/component: decisionRunner`. For Decision Center, use `app.kubernetes.io/component: decisionCenter`.
> **Note**: 
> >PDB requires elevated privileges to apply to the cluster.
> 
> >Do not apply PDB on the application that has only 1 replica such as Decision Server console. Node drains and upgrades could get stuck.

For more information, see [Specifying a Disruption Budget for your Application](https://kubernetes.io/docs/tasks/run-application/configure-pdb/).

## Installing the Chart

The following instructions should be executed as namespace administrator.

1. Create a secret to use the Entitled Registry

    - To get your entitlement key, log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.

    - In the **Container software library** tile, verify your entitlement on the **View library** page, and then go to **Get entitlement key**  to retrieve the key.

    - Create the pull secret:

    ```shell
    kubectl create secret docker-registry icregistry-secret \
        --docker-server=cp.icr.io \
        --docker-username=cp \
        --docker-password="<API_KEY_GENERATED>" \
        --docker-email=<USER_EMAIL>
    ```

    Where:

    - *API_KEY_GENERATED* is the entitlement key from the previous step. Make sure you enclose the key in double-quotes.
    - *USER_EMAIL* is the email address associated with your IBMid.

    > Note: The **cp.icr.io** value for the docker-server parameter is the only registry domain name that contains the images. You must set the *docker-username* to **cp** to use an entitlement key as *docker-password*.


2. Add the public IBM Helm charts repository

    ```console
    helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm
    helm repo update
    ```

3. Check you can access ODM's chart

    ```console
    helm search repo ibm-odm-prod
    ```
    ```console
    NAME                    CHART VERSION	APP VERSION	DESCRIPTION                     
    ibm-helm/ibm-odm-prod   25.0.0       	9.5.0.0   	IBM Operational Decision Manager  License By in...
    ```

4. Install the chart

    A release must be configured before it can be installed.

    To install a release with the default configuration and a release name of `my-odm-prod-release`, use the following command:

    ```console
    helm install my-odm-prod-release \
      --set license=true \
      --set image.pullSecrets=icregistry-secret \
      --set usersPassword=my-password \
      --set internalDatabase.secretCredentials=my-odm-db-secret \
      --set internalDatabase.populateSampleData=true \
      ibm-helm/ibm-odm-prod
    ```

    > Note: In OpenShift, you must set the following parameters `--set customization.runAsUser='' --set internalDatabase.runAsUser=''` and you can also set the parameter `--set service.enableRoute=true`. Refer to [Required Parameters](#required-parameters) for more information.

The package is deployed asynchronously in a matter of minutes, and is composed of several services.
The release is an instance of the `ibm-odm-prod` chart: all the ODM components are now running in a  Kubernetes cluster.

### Required Parameters

- Review the [product license](LICENSES/LICENSE-EN) and set `license=true` to accept the license agreement.

- If you want to use the default user access, you **must** define a password to be used by the default users like *odmAdmin* by setting the parameter `usersPassword`. Refer to [Configuring user access](https://www.ibm.com/docs/en/odm/9.5.0?topic=production-configuring-user-access) to provide customized user access.

- Specify the name of the secret, created in [Prerequisites](#prerequisites) section, as the value for the parameters `internalDatabase.secretCredentials` or `externalDatabase.secretCredentials`, depending on the type of database you use.

- If you are deploying on OpenShift, you must define the `customization.runAsUser` parameter as empty since the **restricted** scc requires to use an arbitrary UID.

- Similarly, if you use the internal database, `internalDatabase.runAsUser` should be set empty. For more information, refer to the [Red Hat OpenShift SecurityContextConstraints Requirements](#red-hat-openshift-securitycontextconstraints-requirements) section.

Here is an example to install ODM on Openshift including a PostgreSQL internal database with samples:
  ```console
  helm install my-odm-prod-release \
    --set license=true \
    --set image.pullSecrets=icregistry-secret \
    --set usersPassword=my-password \
    --set internalDatabase.secretCredentials=my-odm-db-secret \
    --set internalDatabase.populateSampleData=true \
    --set internalDatabase.runAsUser='' \
    --set customization.runAsUser='' \
    --set service.enableRoute=true \
    ibm-helm/ibm-odm-prod
  ```
  
Refer to the [Configuration](#configuration) section for advanced configuration. You can find the default values of all parameters in the [ODM for production configuration parameters](https://www.ibm.com/docs/en/odm/9.5.0?topic=reference-odm-production-configuration-parameters).

### Using helm template

If you plan on using `helm template` command for ODM installation, add the `--validate` flag to validate your manifests against your Kubernetes cluster:

```console
helm template my-odm-prod-release \
  --set license=true \
  --set image.pullSecrets=icregistry-secret \
  --set usersPassword=my-password \
  --set internalDatabase.secretCredentials=my-odm-db-secret \
  --set internalDatabase.populateSampleData=true \
  --validate \
  ibm-helm/ibm-odm-prod > my-values.yaml
kubectl apply -f my-values.yaml
```

### Verifying the Chart

Navigate to your release and view the service details. For details, refer to [Completing post-deployment tasks](https://www.ibm.com/docs/en/odm/9.5.0?topic=production-completing-post-deployment-tasks).

### Getting started with business rules

This [tutorial](https://github.com/DecisionsDev/odm-for-container-getting-started/tree/master) is for technical and business users who want an introduction to business rules authoring and management, with IBM Operational Decision Manager (ODM) running in a container environment.

### Tracking ODM usage with the IBM License Service

You must install the IBM License Service in your cluster in order to track your ODM usage.

Install the IBM License Service following the **Installation** section of the [Installing License Service without Operator Lifecycle Manager (OLM)](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.9?topic=ils-installing-license-service-without-operator-lifecycle-manager-olm).

For specific platforms such as Amazon Elastic Kubernetes Service (EKS), Google Kubernetes Engine (GKE), Azure kubernetes Service (AKS), and Red Hat OpenShift Kubernetes Service on IBM Cloud (ROKS), see the respective article at [DecisionsDev/odm-docker-kubernetes](https://github.com/DecisionsDev/odm-docker-kubernetes/blob/master/README.md#deploying-odm-rules-on-a-specific-platform) repository for additional steps.

To retrieve the data, see [Retrieving license usage data](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.9?topic=reporting-retrieving-license-usage-data).

For more information about IBM Licensing Service, see [License usage metering and reporting](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.9?topic=service-license-usage-metering-reporting). 

### Uninstalling the Chart

To uninstall and delete a release named `my-odm-prod-release`, use the following command:

```console
helm delete my-odm-prod-release
```

The command removes all the Kubernetes components associated with the chart, except any Persistent Volume Claims (PVCs). This is the default behavior of Kubernetes, and ensures that valuable data is not deleted. In order to delete the ODM data, you can delete the PVC using the following command:

```console
kubectl delete pvc <release_name>-odm-pvclaim -n <namespace>
```

## Chart Requirements

### Resources Required

You can find the default resources configuration and some custom configurations.

- **Starter Profile**

  The default configuration:

  | Service  | CPU Request | CPU Limit | Memory Request (Mi) | Memory Limit (Mi) | Replica Count |
  | - | - | - | - | - | - |
  | Decision Center | 0.5 | 2 | 1500 | 4096 | 1 |
  | Decision Runner | 0.5 | 2 | 512 | 4096 | 1 |
  | Decision Server Console | 0.5 | 2 | 512 | 1024 | 1 |
  | Decision Server Runtime | 0.5 | 2 | 512 | 4096 | 1 |
  | **Total**  | **2CPU** | **4CPU** | **3036Mi** | **13Gi** | **/** |

  Cluster Node: 1
  Networking speed: 1Gbs

- **Custom Configuration**

  You can customize the CPU and Memory Requests and Limits per container (decisionCenter, decisionRunner, decisionServerRuntime, decisionServerConsole) by using the parameters:
  - `<containerName>.replicaCount` (except for decisionServerConsole where it can only be 1)
  - `<containerName>.resources.limits.cpu`
  - `<containerName>.resources.limits.memory`
  - `<containerName>.resources.requests.cpu`
  - `<containerName>.resources.requests.memory`

  > TIP: For stability, it is recommended to define the request limit values equal, especially for Decision Server Runtime.

  Here are two recommended configurations:

  - **Production Profile**

    | Service  | CPU Request | CPU Limit | Memory Request (Gi) | Memory Limit (Gi) | Replica Count |
    | - | - | - | - | - | - |
    | Decision Center | 1 | 1 | 4 | 8 | 2 |
    | Decision Runner | 0.5 | 2 | 2 | 2 | 2 |
    | Decision Server Console | 0.5 | 2 | 0.5 | 1 | 1 |
    | Decision Server Runtime | 2 | 2 | 2 | 2 | 3 |
    | **Total**  | **9.5CPU** | **14CPU** | **18.5Gi** | **27Gi** | **/** |

    Cluster Node: 2
    Networking speed: 1Gbs

  - **HA Profile**

    | Service  | CPU Request | CPU Limit | Memory Request (Gi) | Memory Limit (Gi) | Replica Count |
    | - | - | - | - | - | - |
    | Decision Center | 2 | 2 | 4 | 16 | 2 |
    | Decision Runner | 0.5 | 4 | 2 | 2 | 2 |
    | Decision Server Console | 0.5 | 2 | 0.5 | 2 | 1 |
    | Decision Server Runtime | 2 | 2 | 4 | 4 | 6 |
    | **Total**  | **17.5CPU** | **26CPU** | **36.5Gi** | **62Gi** | **/** |

    Cluster Node: 2
    Networking speed: 1Gbs

### Internal Storage Requirements

Use cases for PostgreSQL as an internal database:

- Persistent storage using Kubernetes dynamic provisioning. Uses the default storageclass defined by the Kubernetes admin or by using a custom storageclass which will override the default.
 - Set global values to:
   - **internalDatabase.persistence.enabled**: `true` (default)
   - **internalDatabase.persistence.useDynamicProvisioning**: `true`
 - Specify a custom *storageClassName* per volume or leave the value empty to use the default *storageClass*.

- Persistent storage using a predefined *PersistentVolumeClaim* or *PersistentVolume* setup prior to the deployment of this chart
 - Set global values to:
   - **internalDatabase.persistence.enabled**: `true` (default)
   - **internalDatabase.persistence.useDynamicProvisioning**: `false` (default)
 - Kubernetes binding process selects a pre-existing volume based on the accessMode and size.


Storage providers supported:
- OpenShift Container Storage / OpenShift Data Foundation version 4.x, from version 4.2 or higher
- IBM Cloud File storage:
  - `File Bronze`
  - `File Silver`
  - `File Gold`
- IBM Storage Suite for IBM Cloud Paks:
  - File storage from IBM Spectrum Fusion/Scale (ideal for RWX)
  - Block storage from IBM Spectrum Virtualize, FlashSystem or DS8K
- Portworx Storage, version 2.5.5 or above
- Amazon Elastic File Storage (EFS) for RWX mode access

On-premise storage options supported for all architectures:
- `Rook-Ceph`


## Security Requirements

### Service Account Requirements

By default, the chart creates and uses a custom service account named `<releasename>-ibm-odm-prod-service-account`.

The service account should be granted the appropriate `SecurityContextConstraints` (SCC) depending on your cluster.
 Refer [Red Hat OpenShift SecurityContextConstraints Requirements](#red-hat-openshift-securitycontextconstraints-requirements) documentation for specific guidelines.

You can also configure the chart to use a custom service account. In this case, a cluster administrator can create the custom service account, and the namespace administrator can configure the chart to use this service account by setting the `serviceAccountName` parameter:

```console
helm install my-odm-prod-release \
  --set license=true \
  --set serviceAccountName=ibm-odm-prod-service-account \
  --set image.pullSecrets=icregistry-secret \
  --set usersPassword=my-password \
  --set internalDatabase.secretCredentials=my-odm-db-secret \
  --set internalDatabase.populateSampleData=true \
  ibm-helm/ibm-odm-prod
```

### Pod Security

Red Hat OpenShift Container Platform (OCP) provides Pod security using `SecurityContextConstraints` (SCC) resources to enforce policies based on user and group mappings, similar to the Kubernetes Pod Security Policy (PSP) API. Starting with Kubernetes v1.25, the Pod Security Admission (PSA) controller replaces PSP and introduces namespace-based enforcement for Pod security, simplifying management.

From OpenShift 4.11 onwards, the PSA controller which enforces Pod security standards at the namespace level is supported. For more details, refer to [Understanding and Managing Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/).

### Pod Security Context

The following Pod Security Contexts are recommended for ODM pods to comply with Kubernetes and OpenShift security standards (compatible with both the `restricted` SCC in OpenShift <4.11 and `restricted-v2` SCC in OpenShift 4.11+):

```yaml
securityContext:
  allowPrivilegeEscalation: false
  privileged: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
    - ALL
  runAsNonRoot: true
```

### Security context parameters description

- **`allowPrivilegeEscalation: false`**  
  Prevents processes in the container from gaining additional privileges, even if the process could potentially do so. This is a key security measure to block privilege escalation attempts.

- **`privileged: false`**  
  Disables access to the host’s devices and limits actions requiring root privileges. This ensures that the container's scope of actions is limited, reducing the risk of compromising the node.

- **`readOnlyRootFilesystem: true`**  
  Ensures that the root file system remains immutable, reducing the potential for attacks that involve modifying executable files or system libraries within the container.

- **`capabilities: drop: - ALL`**  
  Drops all Linux capabilities to run the container with the least privileges possible, reducing the attack surface. This follows the principle of least privilege to minimize the risk of privilege escalation.

- **`runAsNonRoot: true`**  
  Enforces that the container runs as a non-root user. If an image attempts to run as the root user (UID 0), the container will fail to start, ensuring that no process in the container has root privileges.

These settings align with the latest Kubernetes security standards and are compatible with Kubernetes-native clusters and OpenShift environments.

For OpenShift-specific changes to Pod Security Standards, see [Important OpenShift changes to Pod Security Standards](https://connect.redhat.com/en/blog/important-openshift-changes-pod-security-standards).

If you are upgrading from older Kubernetes versions to v1.25 and above, refer to [Kubernetes Migrate from PSP](https://kubernetes.io/docs/tasks/configure-pod-container/migrate-from-psp/) for guidance on migrating from PSP to the new PSA controller.

### Red Hat OpenShift SecurityContextConstraints Requirements

  This chart requires a SecurityContextConstraints to be granted to the serviceAccount prior to installation.
  A cluster administrator can either bind the SecurityContextConstraints to the target namespace or add the scc specifically to the serviceAccount.

  The predefined SecurityContextConstraints name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart. In Openshift, `restricted` is used by default for authenticated users.

  > **Note**: To use the `restricted` scc, you must define the `customization.runAsUser` parameter as empty. Similarly, if you use the internal database, `internalDatabase.runAsUser` should be set empty.

  This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. A cluster administrator can create the custom SecurityContextConstraints by applying the following descriptors files in the appropriate namespace:

  <details>
  <summary>Custom SecurityContextConstraints definition:</summary>

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
    name: ibm-odm-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowPrivilegeEscalation: false
  allowedCapabilities: []
  allowedFlexVolumes: []
  allowedUnsafeSysctls: []
  defaultAddCapabilities: []
  defaultPrivilegeEscalation: false
  forbiddenSysctls:
    - "*"
  fsGroup:
    type: MustRunAs
    ranges:
    - max: 65535
      min: 1
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - ALL
  runAsUser:
    type: MustRunAsRange
  seccompProfiles:
  - docker/default
  seLinuxContext:
    type: RunAsAny
  supplementalGroups:
    type: MustRunAs
    ranges:
    - max: 65535
      min: 1
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  priority: 0
  ```
  </details>

  The custom scc can be added to the default custom serviceAccount by a cluster administrator with the following command:
  ```console
  oc adm policy add-scc-to-user ibm-odm-scc /
   -z <releasename>-ibm-odm-prod-service-account /
   -n <namespace>
  ```

  > **Note**: The cluster administrator can also bind the custom scc to the target namespace where the default custom serviceAccount will be created:
  > ```console
  > oc adm policy add-scc-to-group ibm-odm-scc /
  >   system:serviceaccounts:<namespace>
  > ```

## Configuration

- To use the default user access, you **must** define a password to be used by the default users like *odmAdmin* by setting the parameter `usersPassword`. If you want to provide customized user access, read [Configuring user access](https://www.ibm.com/docs/en/odm/9.5.0?topic=production-configuring-user-access).

- If you want to use a custom security certificate, read [Defining the security certificate](https://www.ibm.com/docs/en/odm/9.5.0?topic=production-defining-security-certificate)

- If you want to create your own decision services from scratch, you need to install Rule Designer from the [Eclipse Marketplace](https://marketplace.eclipse.org/content/ibm-operational-decision-manager-developers-v95x-rule-designer).

You can find all configuration settings in the topic [Customizing ODM for production](https://www.ibm.com/docs/en/odm/9.5.0?topic=production-customizing-odm). For more details, check out the list of available [ODM for production configuration parameters](https://www.ibm.com/docs/en/odm/9.5.0?topic=reference-odm-production-configuration-parameters).

## Limitations

The following ODM on premises features are not supported:
[Features not included](https://www.ibm.com/docs/en/odm/9.5.0?topic=kubernetes-decision-features-not-included)

## Documentation

See [ODM on Certified Kubernetes in knowledge center](https://www.ibm.com/docs/en/odm/9.5.0?topic=operational-decision-manager-certified-kubernetes-950).

You can find step-by-step guides on how to deploy an Operational Decision Manager (ODM) instance on different platforms (Amazon Elastic Kubernetes Service (EKS), Google Kubernetes Engine (GKE), Azure kubernetes Service (AKS), and Red Hat OpenShift Kubernetes Service on IBM Cloud (ROKS)) and configure ODM with custom SSO like Okta, in the [DecisionsDev/odm-docker-kubernetes](https://github.com/DecisionsDev/odm-docker-kubernetes/blob/master/README.md) repository.
