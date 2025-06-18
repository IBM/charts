# IBM Cloud Pak for Integration operator Chart

## Introduction

This chart install the IBM Cloud Pak for Integration operator into a namespace. The Cloud Pak for Integration CustomResourceDefinitions (CRDs) will be deployed from this chart if and only if a version of the CRD does not already exist in the cluster.

Use the Cloud Pak for Integration operator to deploy the following components:
- **Platform UI:** deploy and manage new instances of the Cloud Pak components and navigate between them in a simple, consistent manner. The Platform UI simplifies monitoring, maintenance, and upgrades.

Use the Platform UI to manage the following components:
- **IBM API Connect:** create, manage, secure, and socialize APIs.
- **IBM App Connect:** build integration workflows to connect applications and data.
- **IBM DataPower Gateway:** add security, control, integration, and optimized access to your workloads.
- **IBM Event Streams:** build applications that can handle Kafka events.
- **IBM Event Endpoint Management:** describe, catalog, and socialize Kafka event sources.
- **IBM Event Processing:** transform event streaming data in real time, turning events into insights.


## Prerequisites

- Helm v3
- Kubernetes cluster '>=1.30.0 <1.33.0'

## Resources Required

The operator requires 0.2 CPU cores and 1 Gi of memory.

## Installing the Chart
### Checking for previous installs

```
kubectl get crd | grep 'integration.ibm.com'
```

If you have found any crds with the previous command these will need upgrading and you can do that with the following command

```
for crd in crds/*; do; kubectl apply -f $crd; done
```

To install this chart, issue the following command to install in a particular namespace:

```
helm install ibm-integration --namespace <namespace> .
```

See configuration section below for information regarding tuning your operator installation.

## Uninstalling the Chart

To uninstall this chart, issue the following command:

```
helm uninstall ibm-integration
```

## Configuration
### Chart values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| operator.installMode | string | `"OwnNamespace"` | installMode for the operator to determine at what scope it operates (OwnNamespace|AllNamespaces) |
| operator.deployment.resources | object | `{"limits":{"cpu":"200m","memory":"1Gi"},"requests":{"cpu":"200m","memory":"1Hi"}}` | Resource limits to apply to the operator pod |
| operator.privateRegistry | string | `""` | Private registry override to allow users to pull from alternative private registries |

### Additional install parameters

The default chart values can be overridden when running the helm install command by using the `--set` switch. See the following example of changing the operator.installMode. By default the operator will only reconcile resources in it's own namespace. Use the following to reconcile resources in all namespaces:
```
helm install ibm-integration --set operator.installMode="AllNamespaces" .
```
