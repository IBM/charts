# ODM for production Helm chart (ibm-odm-prod)

The [IBM® Operational Decision Manager](https://www.ibm.com/us-en/marketplace/operational-decision-management) (ODM) chart `ibm-odm-prod` is used to deploy a production-ready cluster in IBM Kubernetes environments.


## Introduction

ODM is a tool for capturing, automating, and governing repeatable business decisions. You identify situations about your business and then automate the actions to take as a result of the insight you gained about your policies and customers. For more information, see [ODM in knowledge center](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/welcome/kc_welcome_odmV.html).

## Chart Details

The `ibm-odm-prod` Helm chart is a package of preconfigured Kubernetes resources that bootstrap an ODM deployment on a Kubernetes cluster. Configuration parameters are available to customize most aspects of the deployment. The default values serve as examples but are appropriate to a production environment and can be used as is.

The `ibm-odm-prod` chart deploys five containers corresponding to the five ODM services:
- Decision Center Business Console
- Decision Center Enterprise Console
- Decision Server Console
- Decision Server Runtime
- Decision Server Runner

The `ibm-odm-prod` chart supports the following options for persistence:

- PostgreSQL as an internal database. This is the **default** option. Persistent Volume (PV) is required if you choose to use an internal database. PV represents an underlying storage capacity in the infrastructure. PV must be created with accessMode ReadWriteOnce and storage capacity of 5Gi or more, before you install ODM. You create a PV in the Admin console or with a .yaml file.
- PostgreSQL, Db2 or Microsoft SQL Server as an external database. If you specify a server name for the external database, the external database is used otherwise the internal database is used. Before you select this option, you must have an external PostgreSQL, Db2 or Microsoft SQL Server database up and running.

## Architecture

The following architectures are supported:
- amd64  
- ppc64le
- s390x

## Prerequisites

- Kubernetes 1.11+ with Beta APIs enabled
- Helm 3.2 and later version
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

Before you install ODM for production, you need to gather all the configuration information that you will use for your release. For more details, refer to the [ODM for production configuration parameters](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/ref_parameters_prod.html).

If you want to provide customized user access, read [Configuring user access](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/tsk_config_user_access.html)

If you want to use a custom security certificate, read [Defining the security certificate](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/tsk_replace_security_certificate.html)

 If you want to create your own decision services from scratch, you need to install Rule Designer from the [Eclipse Marketplace](https://marketplace.eclipse.org/content/ibm-operational-decision-manager-developers-v-8105-rule-designer).

### Database Credentials Secret

 To preserve sensitive data, you must create a secret that encapsulates the database user and password before you install the Helm release. For details, see the **Before you begin** section in [Installing a Helm release of ODM for production](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/tsk_config_odm_kube.html).

 Specify the name of the secret as the value for the parameters `internalDatabase.secretCredentials` or `externalDatabase.secretCredentials`, depending on the type of database you use.

### Service Account Requirements

By default, the chart creates and uses the custom serviceAccount named `<releasename>-ibm-odm-prod-service-account`.

The serviceAccount should be granted the appropriate PodSecurityPolicy or SecurityContextConstraints depending on your cluster. Refer to the [PodSecurityPolicy Requirements](#podsecuritypolicy-requirements) or [Red Hat OpenShift SecurityContextConstraints Requirements](#red-hat-openshift-securitycontextconstraints-requirements) documentation.

You can also configure the chart to use a custom serviceAccount. In this case, a cluster administrator can create a custom serviceAccount and the namespace administrator is then able to configure the chart to use the created serviceAccount by setting the parameter `serviceAccountName`:

```console
$ helm install my-odm-prod-release \
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

To use the `restricted` scc, you must define the `customization.runAsUser` parameter as empty since the restricted scc requires to used an arbitrary UID.

```console
$ helm install my-odm-prod-release \
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
  type: MustRunAsNonRoot
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

### Minimum Configuration

| Service  | CPU Minimum (m) | Memory Minimum (Mi) |
| ---------- | ----------- | ------------------- |
| Decision Center | 500           | 1500                  |
| Decision Runner     | 500           | 512                  |
| Decision Server Console  | 500           | 512                  |
| Decision Server Runtime    | 500           | 512                   |
| **Total**  | **2000** (2CPU)     | **2048** (2Gb)             |


## Installing the Chart

The following instructions should be executed as namespace administrator.

A release must be configured before it can be installed.

To install a release with the default configuration and a release name of `my-odm-prod-release`, use the following command:

```console
$ helm install my-odm-prod-release \
  --set internalDatabase.secretCredentials=my-odm-db-secret \
  /path/to/ibm-odm-prod-<version>.tgz
```

> **Tip**: List all existing releases with the `helm list --tls` command.

Using Helm, you specify each parameter with a `--set key=value` argument in the `helm install` command.
For example:

```console
$ helm install my-odm-prod-release \
  --set internalDatabase.databaseName=my-db \
  --set internalDatabase.secretCredentials=my-odm-db-secret \
  /path/to/ibm-odm-prod-<version>.tgz
```

> **Tip**: You can set an list of values with the syntax: `--set image.pullSecrets[0]=a,image.pullSecrets[1]=b}` which is equivalent to:
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

Navigate to your release and view the service details. For details, see the **What to do next** section in [Installing a Helm release of ODM for production](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/tsk_config_odm_kube.html).

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
[Synchronizing users and groups in Decision Center](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/tsk_synchronize_users.html).


## Configuration

To configure the `ibm-odm-prod` chart, check out the list of available [ODM for production configuration parameters](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/ref_parameters_prod.html).

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


## Limitations

The following ODM on premises features are not supported:
[Features not included](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/con_limitations.html)

## Documentation

See [ODM knowledge center](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/welcome/kc_welcome_odmV.html).
