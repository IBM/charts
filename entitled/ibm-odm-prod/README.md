# ODM for production Helm chart (ibm-odm-prod)

The [IBM® Operational Decision Manager](https://www.ibm.com/us-en/marketplace/operational-decision-management) (ODM) chart `ibm-odm-prod` is used to deploy a production-ready cluster in IBM Kubernetes environments.


## Introduction

ODM is a tool for capturing, automating, and governing repeatable business decisions. You identify situations about your business and then automate the actions to take as a result of the insight you gained about your policies and customers. For more information, see [ODM in knowledge center](https://www.ibm.com/docs/en/odm/8.11.0).

## Chart Details

The `ibm-odm-prod` Helm chart is a package of preconfigured Kubernetes resources that bootstrap an ODM deployment on a Kubernetes cluster. Configuration parameters are available to customize most aspects of the deployment. The default values serve as examples but are appropriate to a production environment and can be used as is.

The `ibm-odm-prod` chart deploys five containers corresponding to the four ODM services:
- Decision Center Business Console
- Decision Server Console
- Decision Server Runtime
- Decision Runner

The `ibm-odm-prod` chart supports the following options for persistence:

- PostgreSQL as an internal database. This is the **default** option. Persistent Volume (PV) is required if you choose to use an internal database. PV represents an underlying storage capacity in the infrastructure. PV must be created with accessMode ReadWriteOnce and storage capacity of 5Gi or more, before you install ODM. You create a PV in the Admin console or with a .yaml file.
- PostgreSQL, Db2, Microsoft SQL Server or Oracle as an external database. If you specify a server name for the external database, the external database is used otherwise the internal database is used. Before you select this option, you must have an external PostgreSQL, Db2, Microsoft SQL Server or Oracle database up and running.

## Architecture

The following architectures are supported:
- amd64  
- ppc64le
- s390x

## Prerequisites

- Kubernetes 1.19+ with Beta APIs enabled
- Helm 3.2 and later version
- Review the [product license](LICENSES/LICENSE-EN) and set `license=true` to accept the license agreement
- One PersistentVolume needs to be created prior to installing the chart if internalDatabase.persistence.enabled=true and internalDatabase.persistence.dynamicProvisioning=false. In that case, it is required that the securityContext.fsGroup 26 has read and write permissions on the postgres data directory. You can update the permissions by mounting the volume temporarily or accessing the host machine and performing the following commands:

```console
chown -R 26:26 /var/lib/pgsql/data
chmod -R ug+rw /var/lib/pgsql/data
```

Ensure you have a good understanding  of the underlying concepts and technologies:
- Helm chart, Docker, container
- Kubernetes
- Helm commands
- Kubernetes command line tool

Before you install ODM for production, you need to gather all the configuration information that you will use for your release. For more details, refer to the [ODM for production configuration parameters](https://www.ibm.com/docs/en/odm/8.11.0?topic=reference-odm-production-configuration-parameters).

To use the default user access, you **must** define a password to be used by the default users like *odmAdmin* by setting the parameter `usersPassword`.
If you want to provide customized user access, read [Configuring user access](https://www.ibm.com/docs/en/odm/8.11.0?topic=production-configuring-user-access).

If you want to use a custom security certificate, read [Defining the security certificate](https://www.ibm.com/docs/en/odm/8.11.0?topic=production-defining-security-certificate)

 If you want to create your own decision services from scratch, you need to install Rule Designer from the [Eclipse Marketplace](https://marketplace.eclipse.org/content/ibm-operational-decision-manager-developers-v-8110-rule-designer).

### Database Credentials Secret

 To preserve sensitive data, you must create a secret that encapsulates the database user and password before you install the Helm release. For details, refer to [Configuring user access](https://www.ibm.com/docs/en/odm/8.11.0?topic=production-configuring-user-access).

 Specify the name of the secret as the value for the parameters `internalDatabase.secretCredentials` or `externalDatabase.secretCredentials`, depending on the type of database you use.

### Service Account Requirements

By default, the chart creates and uses the custom serviceAccount named `<releasename>-ibm-odm-prod-service-account`.

The serviceAccount should be granted the appropriate PodSecurityPolicy or SecurityContextConstraints depending on your cluster. Refer to the [PodSecurityPolicy Requirements](#podsecuritypolicy-requirements) or [Red Hat OpenShift SecurityContextConstraints Requirements](#red-hat-openshift-securitycontextconstraints-requirements) documentation.

You can also configure the chart to use a custom serviceAccount. In this case, a cluster administrator can create a custom serviceAccount and the namespace administrator is then able to configure the chart to use the created serviceAccount by setting the parameter `serviceAccountName`:

```console
$ helm install my-odm-prod-release \
  --set license=true \
  --set internalDatabase.secretCredentials=my-odm-db-secret \
  --set serviceAccountName=ibm-odm-prod-service-account \
  /path/to/ibm-odm-prod-<version>.tgz
```

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement, a specific cluster and namespace might have to be scoped by a cluster administrator.

The predefined PodSecurityPolicy name [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verifed for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart.

A cluster administrator can create the custom PodSecurityPolicy and the ClusterRole by applying the following descriptors files in the appropriate namespace:
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-odm-psp
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-odm-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-odm-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be granted to the serviceAccount prior to installation.
A cluster administrator can either bind the SecurityContextConstraints to the target namespace or add the scc specifically to the serviceAccount.

The predefined SecurityContextConstraints name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart. In Openshift, `restricted` is used by default for authenticated users.

To use the `restricted` scc, you must define the `customization.runAsUser` parameter as empty since the restricted scc requires to use an arbitrary UID.

```console
$ helm install my-odm-prod-release \
  --set license=true \
  --set customization.runAsUser='' \
  /path/to/ibm-odm-prod-<version>.tgz
```

> **Note**: Similarly, if you use the internal database, `internalDatabase.runAsUser` should be set empty.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart.

A cluster administrator can create the custom SecurityContextConstraints by applying the following descriptors files in the appropriate namespace:
* Custom SecurityContextConstraints definition:

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

The custom scc can be added to the default custom serviceAccount by a cluster administrator with the following command:
```console
$ oc adm policy add-scc-to-user ibm-odm-scc /
 -z <releasename>-ibm-odm-prod-service-account /
 -n <namespace>
```

  > **Note**: The cluster administrator can also bind the custom scc to the target namespace where the default custom serviceAccount will be created:
  > ```console
  > $ oc adm policy add-scc-to-group ibm-odm-scc /
  >   system:serviceaccounts:<namespace>
  > ```

## Resources Required

### Starter Profile

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

### Custom Configuration

You can customize the CPU and Memory Requests and Limits per container (decisionCenter, decisionRunner, decisionServerRuntime, decisionServerConsole) by using the parameters:
- `<containerName>.replicaCount` (except for decisionServerConsole where it can only be 1)
- `<containerName>.resources.limits.cpu`
- `<containerName>.resources.limits.memory`
- `<containerName>.resources.requests.cpu`
- `<containerName>.resources.requests.memory`

> TIP: For stability, it is recommended to define the request limit values equal, especially for Decision Server Runtime.

#### Production Profile

| Service  | CPU Request | CPU Limit | Memory Request (Gi) | Memory Limit (Gi) | Replica Count |
| - | - | - | - | - | - |
| Decision Center | 1 | 1 | 4 | 8 | 2 |
| Decision Runner | 0.5 | 2 | 2 | 2 | 2 |
| Decision Server Console | 0.5 | 2 | 0.5 | 1 | 1 |
| Decision Server Runtime | 2 | 2 | 2 | 2 | 3 |
| **Total**  | **9.5CPU** | **14CPU** | **18.5Gi** | **27Gi** | **/** |

Cluster Node: 2
Networking speed: 1Gbs

#### HA Profile

| Service  | CPU Request | CPU Limit | Memory Request (Gi) | Memory Limit (Gi) | Replica Count |
| - | - | - | - | - | - |
| Decision Center | 2 | 2 | 4 | 16 | 2 |
| Decision Runner | 0.5 | 4 | 2 | 2 | 2 |
| Decision Server Console | 0.5 | 2 | 0.5 | 2 | 1 |
| Decision Server Runtime | 2 | 2 | 4 | 4 | 6 |
| **Total**  | **17.5CPU** | **26CPU** | **36.5Gi** | **62Gi** | **/** |

Cluster Node: 2
Networking speed: 1Gbs

## Installing the Chart

The following instructions should be executed as namespace administrator.

A release must be configured before it can be installed.

To install a release with the default configuration and a release name of `my-odm-prod-release`, use the following command:

```console
$ helm install my-odm-prod-release \
  --set license=true \
  --set usersPassword=my-password \
  --set internalDatabase.secretCredentials=my-odm-db-secret \
  /path/to/ibm-odm-prod-<version>.tgz
```

> **Tip**: List all existing releases with the `helm list --tls` command.

Using Helm, you specify each parameter with a `--set key=value` argument in the `helm install` command.
For example:

```console
$ helm install my-odm-prod-release \
  --set license=true \
  --set internalDatabase.databaseName=my-db \
  --set internalDatabase.secretCredentials=my-odm-db-secret \
  /path/to/ibm-odm-prod-<version>.tgz
```

> **Tip**: You can set a list of values with the syntax: `--set image.pullSecrets="{a,b}"` which is equivalent to:
> ```yaml
> image:
>   pullSecrets:
>   - a
>   - b
> ```

It is also possible to use a custom-made .yaml file to specify the values of the parameters when you install the chart.
For example:

```console
$ helm install my-odm-prod-release \
  -f values.yaml \
  /path/to/ibm-odm-prod-<version>.tgz
```

> **Tip**: The default values are in the `values.yaml` file of the `ibm-odm-prod` chart.


The package is deployed asynchronously in a matter of minutes, and is composed of several services.
The release is an instance of the `ibm-odm-prod` chart: all the ODM components are now running in a  Kubernetes cluster.

### Verifying the Chart

Navigate to your release and view the service details. For details, refer to [Completing post-deployment tasks](https://www.ibm.com/docs/en/odm/8.11.0?topic=production-completing-post-deployment-tasks).

### Uninstalling the Chart

To uninstall and delete a release named `my-odm-prod-release`, use the following command:

```console
$ helm delete my-odm-prod-release
```

The command removes all the Kubernetes components associated with the chart, except any Persistent Volume Claims (PVCs).  This is the default behavior of Kubernetes, and ensures that valuable data is not deleted.  In order to delete the ODM data, you can delete the PVC using the following command:

```console
$ kubectl delete pvc <release_name>-odm-pvclaim -n <namespace>
```

## Post-installation Steps

If you have been customizing the default user registry, you will have to synchronize it with the Decision Center database. For details, see
[Synchronizing users and groups in Decision Center](https://www.ibm.com/docs/en/odm/8.11.0?topic=access-synchronizing-users-groups-in-decision-center).


## Configuration

To configure the `ibm-odm-prod` chart, check out the list of available [ODM for production configuration parameters](https://www.ibm.com/docs/en/odm/8.11.0?topic=reference-odm-production-configuration-parameters).

## Storage

Use cases for PostgreSQL as an internal database:

- Persistent storage using Kubernetes dynamic provisioning. Uses the default storageclass defined by the Kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - internalDatabase.persistence.enabled: true (default)
    - internalDatabase.persistence.useDynamicProvisioning: true
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - internalDatabase.persistence.enabled: true
    - internalDatabase.persistence.useDynamicProvisioning: false (default)
  - Kubernetes binding process selects a pre-existing volume based on the accessMode and size.

### Storage Options Supported

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

## Track ODM usage with the IBM License Service

You must install the IBM License Service in your cluster in order to track your ODM usage.

### In Openshift

Install the IBM Licens Service operator following [the documentation](https://github.com/IBM/ibm-licensing-operator/blob/latest/docs/Content/Install_on_OCP.md).

After a couple of minutes, the pod `ibm-licensing-service-instance` pod should be running and you will be able to retrieve the Licensing Srevice URL with this command:

```bash
export LICENSING_URL=$(oc get routes -n ibm-common-services | grep ibm-licensing-service-instance | awk '{print $2}')
```

### For other platforms

Follow the **Installation** section of the [Manual installation without the Operator Lifecycle Manager (OLM)](https://github.com/IBM/ibm-licensing-operator/blob/latest/docs/Content/Install_without_OLM.md)

After a couple of minutes, the you will be able to access the IBM License Service by retrieving the URL with this command:

```bash
export LICENSING_URL=$(kubectl get ingress ibm-licensing-service-instance -n ibm-common-services | awk '{print $4}' | tail -1)
```

### Retrieving license usage

Retrieve the License Service token and access the `http://$LICENSING_URL/status?token=$TOKEN` url to view the licensing usage or retrieve the licensing report zip file by running:

```bash
export TOKEN=$(kubectl get secret ibm-licensing-token -o jsonpath={.data.token} -n ibm-common-services | base64 -d)
curl -k https://$LICENSING_URL/snapshot?token=$TOKEN --output report.zip
```

For more information, Refer to the [Licensing Service documentation](https://github.com/IBM/ibm-licensing-operator/blob/latest/docs/Content/Retrieving_data.md).

## Limitations

The following ODM on premises features are not supported:
[Features not included](https://www.ibm.com/docs/en/odm/8.11.0?topic=kubernetes-features-not-included-in-odm-certified)

## Documentation

See [ODM on Certified Kubernetes in knowledge center](https://www.ibm.com/docs/en/odm/8.11.0?topic=operational-decision-manager-certified-kubernetes-8110).
