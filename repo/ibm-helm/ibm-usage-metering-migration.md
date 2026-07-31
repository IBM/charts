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
| `ibmUsageMetering.spec` | Custom IBM Usage Metering resource specification | `{}` |
| `ibmUsageMetering.imageRegistryNamespaceOperator` | Operator image registry namespace | `cpopen` |
| `ibmUsageMetering.imageRegistryNamespaceOperand` | Operand image registry namespace | `cpopen/cpfs` |
| `ibmUsageMetering.enableRoutes` | Enable OpenShift routes | `true` |
| `ibmUsageMetering.createRBAC` | Create RBAC resources required by the chart | `true` |

### Cluster-Scoped Chart Parameters (ibm-usage-metering-cluster-scoped Helm chart)

The cluster-scoped chart does not expose any configurable Helm values.

## Uninstalling

```bash
helm uninstall ibm-usage-metering --namespace <target-namespace>
helm uninstall ibm-usage-metering-cluster-scoped
```

## Documentation

- [IBM Usage Metering Service](https://ibm.biz/usage_metering_service)
