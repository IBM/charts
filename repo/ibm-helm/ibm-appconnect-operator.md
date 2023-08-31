# IBM App Connect Operator Chart

## Introduction

The IBM App Connect Operator manages App Connect resources such as Dashboard, Designer Authoring, IntegrationRuntimes, IntegrationServers and Switches

## Chart Details

This chart deploys a App Connect Operator Deployment into a namespace. The App Connect CRDs will be deployed from this chartif and only if a version of it does not already exist in the cluster.

## Prerequisites

- Helm v3
- Kubernetes cluster

### PodDisruptionBudget

The App Connect Operator is recommended to have a single instance active at all time. The following PodDisruptionBudget can be created to enforce this.

```yaml
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: appconnect-operator-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      name: appconnect-operator
```

### PodSecurityPolicy Requirements

Custom PodSecurityPolicy definition:

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-appconnect-operator-restricted-psp
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
fsGroup:
  type: RunAsAny
spec:
  allowPrivilegeEscalation: true
  requiredDropCapabilities:
  - MKNOD
  allowedCapabilities:
  - CHOWN
  - FOWNER
  - DAC_OVERRIDE
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - persistentVolumeClaim
  forbiddenSysctls:
  - '*'
```

## Resources Required

The App Connect Operator requires a minimum of

```yaml
resources:
  requests:
    cpu: "500m"
    memory: "512Mi"
```

## Installing the Chart

To install this chart, issue the following command:

```
helm install <name> .
```

See configuration section below for information regarding tuning your operator installation.

## Uninstalling the Chart

To uninstall this chart, issue the following command:

```
helm uninstall <name>
```

Due to [limitations](https://helm.sh/docs/chart_best_practices/custom_resource_definitions/) in Helm, the Custom Resource Definitions (CRDs) are not deleted when the operator is uninstalled via Helm. To clean up the CRDs, issue the following commands:

```bash
kubectl delete crd/appconnect.ibm.com_configurations.yaml
kubectl delete crd/appconnect.ibm.com_dashboards.yaml
kubectl delete crd/appconnect.ibm.com_designerauthorings.yaml
kubectl delete crd/appconnect.ibm.com_integrationruntimes.yaml
kubectl delete crds/appconnect.ibm.com_integrationservers.yaml
kubectl delete crds/appconnect.ibm.com_switchservers.yaml
kubectl delete crds/appconnect.ibm.com_traces.yaml
```

**Warning:** Deleting the CRDs will cause all Custom Resource (CR) instances to also be deleted.

## Configuration
### Chart values

|Value|Description|Default|
|-|-|-|
|`operator.replicas`|Number of Operator pods to deploy|`1`|
|`operator.image.repository`|Repository containing Operator image|`icr.io/cpopen/appconnect-operator`|
|`operator.image.tag`|Name of Operator image|`latest`|
|`operator.image.pullPolicy`|Image pull policy for Operator|`Always`|
|`operator.imagePullSecrets`|List of pull secret names|`[]`|
|`operator.installMode`|InstallMode of the operator|`OwnNamespace`|
|`operator.watchNamespaces`|Namespaces the Operator should watch|`[]`|
|`operator.logLevel`|Set logLevel for Operator pod|`info`|

#### `operator.replicas`

This Operator supports deploying with multiple replicas across multiple zones. When more than one Operator pod is present, a leader will be determined. Only the leader manages App Connect resources.

#### `operator.imagePullSecrets`

Optional list of pull secrets if operator images are pulled from a registry which requires authentication. Example syntax:

```yaml
operator:
  imagePullSecrets:
    - name: my-pull-secret
```

#### `operator.installMode`

This can be one of four options:
- OwnNamespace
- SingleNamespace
- MultiNamespace
- AllNamespaces

**OwnNamespace**

OwnNamespace makes the Operator listen in the namespace it is installed in and nowhere else. With this option, `operator.watchNamespaces` is ignored.

**SingleNamespace**

SingleNamespace makes the Operator listen to an arbitrary namespace, defined in `operator.watchNamespaces`. With this option, the first namespace in the `operator.watchNamespaces` list is used, the rest are ignored.

**MultiNamespace**

MultiNamespace makes the Operator listen to any number of arbitrary namespaces, defined in `operator.watchNamespaces`. With this option, all namespaces defined in `operator.watchNamespaces` are used.

**AllNamespaces**

AllNamespaces makes the Operator listen to all namespaces. With this option, `operator.watchNamespaces` is ignored.

#### `operator.watchNamespaces`

This is a list of namespaces the Operator should watch. Usage of this list is dependent on the `operator.installMode`.

#### `operator.logLevel`

Log level can be set to one of:
- error
- info
- debug
- integer > 0

This value will adjust the verbosity of the logs produced by the Operator. Default value is `info`. Operator logs currently only support `error`, `info`, and `debug` logs, setting an integer higher than 1 will increase the verbosity of library code while higher than 4 will set the verbosity level of `client-go` for Kubernetes API logging.

### Operator Components

|Resource Type|Name Format|Created By|
|-|-|-|
|Cluster Role|`<release>-<namespace>-appconnect-operator`|Chart|
|Cluster Role Binding|`<release>-<namespace>-appconnect-operator`|Chart|
|Deployment|`<release>-appconnect-operator`|Chart|
|Role|`<release>-<namespace>-appconnect-operator`|Chart|
|Role Binding|`<release>-<namespace>-appconnect-operator`|Chart|
|Service Account|`<release>-<namespace>-appconnect-operator`|Chart|

## Limitations

This chart is able to be installed in development, nonproduction, and production environments.
