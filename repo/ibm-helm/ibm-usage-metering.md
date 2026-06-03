# IBM Usage Metering Helm Chart

## Overview

A Helm chart for IBM Usage Metering installation. IBM products can integrate with Usage Metering Service (UMS) that is used to capture two types of product usage metrics: contractual metrics for compliance purposes, and adoption metrics for various scenarios related to usage analysis.

## Prerequisites

- OpenShift 4.6+
- Helm 3.0+

## Installation

### Fresh Installation

```bash
# Install cluster-scoped resources
helm install ibm-usage-metering-cluster-scoped ./helm-cluster-scoped \
  --namespace <target-namespace> \
  --create-namespace

# Install IBM Usage Metering
helm install ibm-usage-metering ./helm \
  --namespace <target-namespace> \
  --set global.licenseAccept=true
```

### Migration from OLM

For migration from OLM-based deployment, see [helm-migration/README.md](../helm-migration/README.md).

## Configuration

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.licenseAccept` | Accept IBM license agreement | `true` |
| `global.imagePullPrefix` | Image registry prefix | `icr.io` |
| `global.imagePullSecret` | Image pull secret name | `ibm-entitlement-key` |
| `global.operatorNamespace` | Namespace for operator | `""` |
| `global.instanceNamespace` | Namespace for instance | `""` |

### IBM Usage Metering Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ibmUsageMetering.spec` | Custom specification | `{}` |
| `ibmUsageMetering.imageRegistryNamespaceOperator` | Operator image namespace | `cpopen` |
| `ibmUsageMetering.imageRegistryNamespaceOperand` | Operand image namespace | `cpopen/cpfs` |
| `ibmUsageMetering.enableRoutes` | Enable OpenShift routes | `true` |

## Uninstalling

```bash
helm uninstall ibm-usage-metering --namespace <target-namespace>
helm uninstall ibm-usage-metering-cluster-scoped --namespace <target-namespace>
```

## Documentation

- [IBM Usage Metering Service](https://ibm.biz/usage_metering_service)
- [GitHub Repository](https://github.ibm.com/cloud-license-reporter/ibm-usage-metering-operator)
