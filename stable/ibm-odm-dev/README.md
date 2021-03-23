# ODM for developers Helm chart (ibm-odm-dev)

The [IBM® Operational Decision Manager](https://www.ibm.com/us-en/marketplace/operational-decision-manager) (ODM) chart `ibm-odm-dev` is used to deploy an ODM evaluation cluster in IBM  Kubernetes environments.



## Introduction

ODM is a tool for capturing, automating, and governing repeatable business decisions. You identify situations about your business and then automate the actions to take as a result of the insight you gained about your policies and customers. For more information, see [ODM in knowledge center](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/welcome/kc_welcome_odmV.html).

## Chart Details

The `ibm-odm-dev` Helm chart is a package of preconfigured Kubernetes resources that bootstrap an ODM deployment on a Kubernetes cluster. Configuration parameters are available to customize some aspects of the deployment. However, the chart is designed to get you up and running as quickly as possible, with appropriate default values. If you accept the default values, sample data is added to the database as part of the installation, and you can begin exploring rules in ODM immediately.

The `ibm-odm-dev` chart deploys a single container of five ODM services:
- Decision Center Business Console
- Decision Center Enterprise Console
- Decision Server Console
- Decision Server Runtime
- Decision Server Runner

The `ibm-odm-dev` chart supports the following options for persistence:

- H2 as an internal database. This is the **default** option.
Persistent Volume (PV) is required if you choose to use an internal database. PV represents an underlying storage capacity in the infrastructure. PV must be created with accessMode ReadWriteOnce and storage capacity of 2Gi or more, before you install ODM. You create a PV in the Admin console or with a .yaml file.
- PostgreSQL as an external database. If you specify a server name for the external database, the external database is used, otherwise the internal database is used. Before you select this option, you must have an external PostgreSQL database up and running.

By default, the `internalDatabase.populateSampleData` parameter is set to `true`, which adds sample data to the database. A decision service is created in Decision Center and is also deployed to Rule Execution Server. The sample data can be used to test your newly created release.

> **Note:** The ability to populate the database with sample data is available only when using the internal database and the persistence locale for Decision Center is set to English (United States). Sample data is not available for the external database.

## Prerequisites

- Kubernetes 1.11+ with Beta APIs enabled
- Helm 3.2 and later version
- One PersistentVolume needs to be created prior to installing the chart if internalDatabase.persistence.enabled=true and internalDatabase.persistence.dynamicProvisioning=false. In that case, it is required that the securityContext.fsGroup 1001 has read and write permissions on the postgres data directory. You can update the permissions by mounting the volume temporarily or accessing the host machine and performing the following commands:
```console
chown -R :1001 /config/dbdata/
chmod -R ug+rw /config/dbdata/
chmod o-t /config/dbdata/
```
- Review  and accept the product license:
  - Set license=view to print the license agreement
  - Set license=accept to accept the license

Ensure you have a good understanding of the underlying concepts and technologies:
- Helm chart, Docker, container
- Kubernetes
- Helm commands
- Kubernetes command line tool

Before you install ODM for developers, you need to gather all the configuration information that you will use for your release. For more details, refer to the [ODM for developers configuration parameters](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/ref_parameters_dev.html).

If you want to create your own decision services from scratch, you need to install Rule Designer from the [Eclipse Marketplace](https://marketplace.eclipse.org/content/ibm-operational-decision-manager-developers-v-8104-rule-designer).

### Service Account Requirements

By default, the chart creates and uses the custom serviceAccount named `<releasename>-ibm-odm-dev-service-account`.

The serviceAccount should be granted the appropriate PodSecurityPolicy or SecurityContextConstraints depending on your cluster. Refer to the [PodSecurityPolicy Requirements](#podsecuritypolicy-requirements) or [Red Hat OpenShift SecurityContextConstraints Requirements](#red-hat-openshift-securitycontextconstraints-requirements) documentation.

You can also configure the chart to use a custom serviceAccount. In this case, a cluster administrator can create a custom serviceAccount and the namespace administrator is then able to configure the chart to use the created serviceAccount by setting the parameter `serviceAccountName`:

```console
$ helm install my-odm-dev-release \
  --set license=accept \
  --set serviceAccountName=ibm-odm-dev-service-account \
  ibm-charts/ibm-odm-dev
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

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart.

You can apply the following yaml file to create the custom SecurityContextConstraints.
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

## Resources Required

### Minimum Configuration

|   | CPU Minimum (m) | Memory Minimum (Mi) |
| ---------- | ----------- | ------------------- |
| ODM services | 1           | 1024                  |


## Installing the Chart

The following instructions should be executed as namespace administrator.

Add the ibm chart repository:

```console
$ helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
```

A release must be configured before it is installed.
To install a release with the default configuration and a release name of `my-odm-dev-release`, use the following command:

```console
$ helm install my-odm-dev-release --set license=accept ibm-charts/ibm-odm-dev
```

> **Tip**: List all existing releases with the `helm list` command.

Using Helm, you specify each parameter with a `--set key=value` argument in the `helm install` command.
For example:

```console
$ helm install my-odm-dev-release \
  --set license=accept \
  --set internalDatabase.databaseName=my-db \
  --set internalDatabase.user=my-user \
  --set internalDatabase.password=my-password \
  ibm-charts/ibm-odm-dev
```

It is also possible to use a custom-made .yaml file to specify the values of the parameters when you install the chart.
For example:

```console
$ helm install --set license=accept my-odm-dev-release -f values.yaml ibm-charts/ibm-odm-dev
```

> **Tip**: The default values are in the `values.yaml` file of the `ibm-odm-dev` chart.

The release is an instance of the `ibm-odm-dev` chart: all the ODM components are now running in a  Kubernetes cluster.

> **Note**: If you plan on using `helm template` command for ODM installation, add the `--validate` flag to validate your manifests against your Kubernetes cluster:
> ```console
> $ helm template my-odm-dev-release --set license=accept ibm-charts/ibm-odm-dev > my-values.yaml
> $ kubectl apply -f my-values.yaml
> ```

### Verifying the Chart

1. Navigate to your release and view the service details.

>The welcome page of IBM Operational Decision Manager Developer Edition displays with links to the ODM components and other resources.

>If you accepted the default persistence, a sample project is available in your ODM release and you can explore and modify the rules and decision tables.

>The Loan Validation sample is a decision service that determines whether a borrower is eligible for a loan. The decision service validates transaction data, checks customer eligibility, assigns a score, and computes insurance rates that are based on the assigned score.

2. Click the Decision Center Business Console to open the service in a browser.

3. Navigate to the Library tab of the Decision Center Business Console, select the decision service, then the release and browse Decision Artifacts to view the rules and make changes.

**Note:** The persistence locale for Decision Center is set to English (United States), which means that the project can be viewed only in English.

Now you want to execute the sample decision service to request a loan. Follow the procedure described here [Try out the Business console](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.icp/topics/tsk_test_loan_valid.html)

### Uninstalling the chart

To uninstall and delete a release named `my-odm-dev-release`, use the following command:

```console
$ helm delete my-odm-dev-release
```

The command removes all the Kubernetes components associated with the chart, except any Persistent Volume Claims (PVCs).  This is the default behavior of Kubernetes, and ensures that valuable data is not deleted.  In order to delete the ODM's data, you can delete the PVC using the following command:

```console
$ kubectl delete pvc <release_name>-odm-pvclaim -n <namespace>
```

## Architecture

- Three major architectures are now available for ODM for developers Edition worker nodes:
  - AMD64 / x86_64
  - s390x
  - ppc64le


## Configuration

To configure the `ibm-odm-dev` chart, check out the list of available [ODM for developers configuration parameters](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/ref_parameters_dev.html).

## Storage

Uses cases for H2 as an internal database:

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

The following ODM on premises features are not supported: [Features not included in this platform.](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/com.ibm.odm.kube/topics/con_limitations.html)

## Documentation

See [ODM in knowledge center](https://www.ibm.com/support/knowledgecenter/SSQP76_8.10.x/welcome/kc_welcome_odmV.html).
