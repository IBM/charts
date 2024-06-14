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

### Installing the operator

To install the operator, run the following command:

```
helm install \
    <release-name> ibm-eventstreams-operator-<helm-chart-version>.tgz \
    -n "<namespace>" \
    --set watchAnyNamespace=<true/false>
```

Where
- `<release-name>` is the name you provide to identify your operator.
- `ibm-eventstreams-operator-<helm-chart-version>.tgz` is the Helm chart you downloaded earlier.
- `-n "<namespace>"` is the name of the namespace where you want to install the operator.
- `--set watchAnyNamespace=<true/false>` determines whether the operator manages instances of {{site.data.reuse.short_name}} in any namespace or only a single namespace (default is `false` if not specified).

  Set to `true` for the operator to manage instances in any namespace, or do not specify if you want the operator to only manage instances in a single namespace.

For example, to install the operator on a cluster where it will manage all instances of {{site.data.reuse.short_name}}, run the command as follows:

`helm install eventstreams ibm-eventstreams-operator-3.1.0.tgz -n "my-namespace" --set watchAnyNamespace=true`

For example, to install the operator that will manage {{site.data.reuse.short_name}} instances in only the `eventstreams` namespace, run the command as follows:

`helm install eventstreams ibm-eventstreams-operator-3.1.0.tgz -n "my-eventstreams"`

**Note:** If you are installing any subsequent operators in the same cluster, ensure you run the `helm install` command with the `--set createGlobalResources=false` option (as these resources have already been installed).

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
