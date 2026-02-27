# Event Streams operator

The Event Streams operator installs, configures, and manages instances of Event Streams on your Kubernetes cluster.

Built on Apache Kafka®, [Event Streams](https://ibm.github.io/event-automation/es/about/overview/) is a high-throughput, fault-tolerant, event streaming platform that helps you build intelligent, responsive, event-driven applications.

## Introduction

This chart deploys the Event Streams operator.

## Chart Details

This Helm chart will install the following:

- eventstreams-cluster-operator deployment
- eventstreams-cluster-operator pod

## Prerequisites

Ensure you have the following setup available:

- The Kubernetes (`kubectl`) and Helm (`helm`) command-line tools available.
- Your environment configured to connect to the target cluster.


The installation environment has the following prerequisites:

- Kubernetes platform versions >=1.25 supporting RedHat UBI Linux-based containers.
- A namespace dedicated for use by Event Streams.
- A storage class that supports block storage on the cluster.

**Note:** Do not use this chart to install the Event Streams operator on clusters that have other Cloud Pak for Integration components installed.

## Installing the Chart

### Installation Options

The Event Streams operator supports two installation models:

1. **Standard Installation (Default)**: Installs both cluster-scoped resources (CRDs, ClusterRoles) and namespace-scoped resources (operator deployment) in a single Helm release.

2. **Split Installation**: Installs cluster-scoped and namespace-scoped resources as separate Helm releases, useful for multi-tenant environments where CRDs are shared across multiple operator instances.

### Standard Installation

To install the operator with both cluster-scoped and namespace-scoped resources:

```bash
helm install \
    <release-name> ibm-eventstreams-operator-<helm-chart-version>.tgz \
    -n "<namespace>" \
    --set watchAnyNamespace=<true/false>
```

Where:
- `<release-name>` is the name you provide to identify your operator.
- `ibm-eventstreams-operator-<helm-chart-version>.tgz` is the Helm chart you downloaded earlier.
- `-n "<namespace>"` is the name of the namespace where you want to install the operator.


- `--set watchAnyNamespace=<true/false>` determines whether the operator manages instances in any namespace or only a single namespace (default is `false`).

**Example**: Install operator managing all namespaces:
```bash
helm install eventstreams ibm-eventstreams-operator-3.1.0.tgz -n "my-namespace" --set watchAnyNamespace=true
```

**Example**: Install operator managing only its own namespace:
```bash
helm install eventstreams ibm-eventstreams-operator-3.1.0.tgz -n "my-eventstreams"
```

### Split Installation (Multi-Tenant)

For multi-tenant environments, you can install cluster-scoped resources once and then install multiple operator instances that share those resources.

**Step 1**: Install cluster-scoped resources (CRDs, ClusterRoles):
```bash
helm install \
    <release-name> ibm-eventstreams-operator-<helm-chart-version>.tgz \
    -n "<namespace>" \
    --set namespaceScopedResources=false
```

**Step 2**: Install namespace-scoped resources (operator) in each tenant namespace:
```bash
helm install \
    <release-name> ibm-eventstreams-operator-<helm-chart-version>.tgz \
    -n "<namespace>" \
    --set clusterScopedResources=false \
    --set watchAnyNamespace=<true/false>
```

**Example**: Install cluster-scoped resources:
```bash
helm install es-crds ibm-eventstreams-operator-<helm-chart-version>.tgz \
    -n es-system \
    --create-namespace \
    --set namespaceScopedResources=false
```

**Example**: Install operator managing only its own namespace:
```bash
helm install es-operator-team-a ibm-eventstreams-operator-<helm-chart-version>.tgz \
    -n team-a \
    --create-namespace \
    --set clusterScopedResources=false \
    --set watchAnyNamespace=true
```


Repeat Step 2 for additional tenant namespaces as needed.

### Configuration Parameters

#### Resource Scope Parameters

- `clusterScopedResources` (default: `true`): Controls installation of cluster-scoped resources (CRDs, ClusterRoles, ClusterRoleBindings).
  - Set to `false` when installing namespace-scoped resources in a split installation.
  
- `namespaceScopedResources` (default: `true`): Controls installation of namespace-scoped resources (operator deployment, RoleBindings, ConfigMaps).
  - Set to `false` when installing only cluster-scoped resources in a split installation.

- `createGlobalResources` (deprecated): Legacy parameter for backward compatibility. Use `clusterScopedResources` instead.

#### Other Parameters

- `watchAnyNamespace` (default: `false`): When `true`, the operator manages Event Streams instances in all namespaces. When `false`, it only manages instances in its own namespace.

- `watchNamespaces` (default: `[]`): List of specific namespaces to watch. Leave empty to watch only the release namespace.

### Upgrading Existing Installations

Existing installations will continue to work without changes. The new parameter names are backward compatible:

```bash
# Both commands are equivalent and will install all resources
helm upgrade eventstreams ibm-eventstreams-operator-<helm-chart-version>.tgz -n "my-namespace"
helm upgrade eventstreams ibm-eventstreams-operator-<helm-chart-version>.tgz -n "my-namespace" --set clusterScopedResources=true
```

**Note**: Migration from a standard installation to a split installation is not supported. Use the split installation model only for new deployments.

### Verifying the Chart

To check the status of the installed operator, run the following command:

`kubectl get deploy eventstreams-cluster-operator`

A successful installation will return a result similar to the following with `1/1` in the `READY` column:

```
NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
eventstreams-cluster-operator   1/1     1            1           7d4h
```

### Uninstalling the Chart

To uninstall the operator, ensure your environment is targeting the namespace where the Helm chart is installed in, and then run the following command:

```
helm uninstall <release-name>
```

## Limitations

- The chart must be loaded into the catalog by a Team Administrator or Cluster Administrator.
- The chart must be deployed into a namespace dedicated for use by IBM Event Streams.
- The chart can only be deployed by a Team Administrator or Cluster Administrator.

## Documentation

Find out more about [Event Streams](https://ibm.github.io/event-automation/es/about/overview/).

See [sample configurations](https://github.com/IBM/ibm-event-automation/tree/main/event-streams/cr-examples/eventstreams/kubernetes) for installing Event Streams on Kubernetes platforms other than OpenShift.
