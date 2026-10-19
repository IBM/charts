# IBM Usage Metering Helm Chart

## Overview

A Helm chart for IBM Usage Metering installation. IBM products can integrate with Usage Metering Service (UMS) to capture two types of product usage metrics: contractual metrics for compliance purposes, and adoption metrics for various scenarios related to usage analysis.

## Installation

### Fresh Installation

```bash
# Install cluster-scoped resources
helm install ibm-usage-metering-cluster-scoped <ibm-usage-metering-cluster-scoped-chart> 

# Install IBM Usage Metering
helm install ibm-usage-metering <ibm-usage-metering-chart>  \
  --namespace <target-namespace> \
  --create-namespace
```

### Migration from OLM

For migration from OLM-based deployment, see [helm-migration/README.md](../helm-migration/README.md).

## Configuration

### Main Chart Parameters (ibm-usage-metering Helm chart)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.licenseAccept` | Accept IBM license agreement | `true` |
| `global.imagePullPrefix` | Image registry prefix | `icr.io` |
| `global.imagePullSecret` | Image pull secret name | `ibm-entitlement-key` |
| `global.operatorNamespace` | Namespace where the operator is installed | `""` |
| `global.instanceNamespace` | Namespace where the IBM Usage Metering instance is created | `""` |
| `global.tetheredNamespaces` | Comma-separated list of additional namespaces to watch (used when `watchNamespace` is not set) | `""` |
| `ibmUsageMetering.spec` | Custom IBM Usage Metering resource specification | `{}` |
| `ibmUsageMetering.imageRegistryNamespaceOperator` | Operator image registry namespace | `cpopen` |
| `ibmUsageMetering.imageRegistryNamespaceOperand` | Operand image registry namespace | `cpopen/cpfs` |
| `ibmUsageMetering.enableRoutes` | Enable OpenShift routes | `true` |
| `ibmUsageMetering.createRBAC` | Create RBAC resources required by the chart | `true` |
| `ibmUsageMetering.createRBACInWatchedNamespaces` | Create RBAC resources in each watched namespace (requires `executionMode: PROCESSOR_CAPACITY_ENABLED`) | `true` |
| `ibmUsageMetering.executionMode` | Execution mode for contractual metrics collection. Set to `PROCESSOR_CAPACITY_ENABLED` to enable processor capacity metering | `standard` |
| `ibmUsageMetering.watchNamespace` | Comma-separated list of namespaces to watch. When empty, derived from `global.instanceNamespace` and `global.tetheredNamespaces` | `""` |
| `ibmUsageMetering.features.nodeCpuCappingEnabled` | Enable node CPU capping | `true` |
| `ibmUsageMetering.features.kubeRBACAuthEnabled` | Enable kube RBAC authentication | `false` |
| `ibmUsageMetering.operator.serviceAccount.name` | Override the operator pod service account name. Use with `createRBAC: false` for pre-created service accounts | `ibm-usage-metering-operator` |
| `ibmUsageMetering.operator.podAnnotations` | Extra annotations added to the operator pod. Existing IBM product annotations cannot be overridden | `{}` |
| `ibmUsageMetering.operator.podLabels` | Extra labels added to the operator pod. Existing selector labels cannot be overridden | `{}` |
| `ibmUsageMetering.operator.nodeSelector` | Node selector for the operator pod | `{}` |
| `ibmUsageMetering.operator.affinity` | Affinity rules for the operator pod | `{}` |
| `ibmUsageMetering.operand.serviceAccount.name` | Override the operand pod service account name. Use with `createRBAC: false` for pre-created service accounts | `ibm-usage-metering-instance` |
| `ibmUsageMetering.operand.podAnnotations` | Extra annotations added to the operand pod. Existing IBM product annotations cannot be overridden | `{}` |
| `ibmUsageMetering.operand.podLabels` | Extra labels added to the operand pod. Existing selector labels cannot be overridden | `{}` |
| `ibmUsageMetering.operand.nodeSelector` | Node selector for the operand pod | `{}` |
| `ibmUsageMetering.operand.affinity` | Affinity rules for the operand pod | `{}` |

## Generated resources

### `ibm-licensing-external-config` ConfigMap

During installation, the chart creates a ConfigMap named `ibm-licensing-external-config` in the instance namespace. It contains a single key:

| Key | Description |
|-----|-------------|
| `excludeNamespace` | Comma-separated list of namespaces watched by UMS (derived from `global.instanceNamespace`, `ibmUsageMetering.watchNamespace`, and `global.tetheredNamespaces`). IBM License Service reads this value to exclude UMS-managed namespaces from its own reporting. |

This ConfigMap is managed solely by Helm and is **not** watched or reconciled by the UMS operator, so adopters can safely edit it after installation.

## Uninstalling

```bash
helm uninstall ibm-usage-metering --namespace <target-namespace>
helm uninstall ibm-usage-metering-cluster-scoped
```

## Documentation

- [IBM Usage Metering Service](https://ibm.biz/usage_metering_service)
