# IBM App Connect Operator Chart

## Introduction

The IBM App Connect Operator manages App Connect resources such as Dashboard, Designer Authoring, IntegrationRuntimes and SwitchServers

## Chart Details

This chart deploys a App Connect Operator Deployment into a namespace. The App Connect CRDs will be deployed from this chart if and only if a version of it does not already exist in the cluster.

## Prerequisites

- Helm v3
- Kubernetes cluster '>=1.27.0 < 1.33.0'

## Resources Required

The App Connect Operator requires a minimum of

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
    ephemeral-storage: 50Mi
  limits:
    memory: 1Gi
    ephemeral-storage: 512Mi
```

## Installing the Chart
### Checking for previous installs

```
kubectl get crd | grep 'appconnect.ibm.com'
```

If you have found any crds with the previous command these will need upgrading and you can do that with the following command

```
for crd in crds/*; do; kubectl apply -f $crd; done
```

To install this chart, issue the following command:

```
helm install ibm-appconnect \
    --set namespace="YOUR_NAMESPACE" \
    .
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
kubectl delete crd/appconnect.ibm.com_integrationservers.yaml
kubectl delete crd/appconnect.ibm.com_switchservers.yaml
kubectl delete crd/appconnect.ibm.com_traces.yaml
```

**Warning:** Deleting the CRDs will cause all Custom Resource (CR) instances to also be deleted.

## Configuration
### Chart values
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| namespace | string | `"appconnect"` | Namespace where you wish to deploy the operator |
| operator.deployment.image | string | `"appconnect-operator"` | Operator image name |
| operator.deployment.pullPolicy | string | `"Always"` | PullPolicy for the operator image (Always, IfNotPresent, or Never) |
| operator.deployment.repository | string | `"icr.io/cpopen"` | Remote repository where you will pull the operator pod  |
| operator.deployment.resources | object | `{"limits":{"ephemeral-storage":"512Mi","memory":"1Gi"},"requests":{"cpu":"100m","ephemeral-storage":"50Mi","memory":"128Mi"}}` | Resource limits to apply to the operator pod |
| operator.deployment.sha | string | `nil` | SHA value of the operator image |
| operator.deployment.tag | string | `nil` | Tag value for the operator image (optional) ignored if you supply SHA value |
| operator.env | object | `{}` | Environment variables that you wish to pass to the operator pod e.g key: "value" |
| operator.imagePullSecrets | list | `[]` | Names of secrets which allow pulling from authenticated registries |
| operator.installMode | string | `"OwnNamespace"` | installMode for the operator to determine at what scope it operates (OwnNamespace|AllNamespaces) |
| operator.privateRegistry | string | `""` | Private registry override to allow users to pull from alternative private registries |
| operator.replicas | int | `1` | Number of replicas for the operator pod (1 recommended) |

## Additional install parameters

### Private registry
```
helm install ibm-appconnect \
    --set namespace="YOUR NAMESPACE" \
    --set operator.deployment.repository="dev.registry/fake" \
    --set operator.privateRegistry="dev.registry/fake" \
    .
```
