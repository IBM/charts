# Knative

This chart installs Knative components for Build, Serving and Eventing.

## Introduction

- Visit [knative build](https://github.com/IBM/charts/blob/master/community/knative/charts/build/README.md) for more information about Build.
- Visit [knative eventing](https://github.com/IBM/charts/blob/master/community/knative/charts/eventing/README.md) for more information about Eventing.
- Visit [knative serving](https://github.com/IBM/charts/blob/master/community/knative/charts/serving/README.md) for more information about Serving.

## Chart Details

In its default configuration, this chart will create the following Kubernetes resources:

- Internal Services
    - controller, webhook

- Knative Build Pods:
    - Deployments: controller, webhook

- Knative Serving Pods:
    - Deployments: kube-state-metrics, knative-ingressgateway
    - DaemonSet: fluent-ds
    - ServiceAccounts: elasticsearch-logging, fluentd-ds, kube-state-metrics, node-exporter, prometheus-system, autoscaler, controller
    - metric: revisionrequestcount, revisionrequestduration, revisionrequestsize, revisionresponsesize

- Knative Eventing Pods:
    - Deployments: in-memory-channel-controller, in-memory-channel-dispatcher, eventing-controller, webhook

- Custom Resource Definitions:
    - buildtemplates.build.knative.dev
    - builds.build.knative.dev
    - clusterbuildtemplates.build.knative.dev
    - subscriptions.eventing.knative.dev
    - channels.eventing.knative.dev
    - revisions.serving.knative.dev
    - clusteringresses.networking.internal.knative.dev
    - configurations.serving.knative.dev
    - services.serving.knative.dev
    - podautoscalers.autoscaling.internal.knative.dev
    - routes.serving.knative.dev
    - images.caching.internal.knative.dev

- HorizontalPodAutoscaler:
    - knative-ingressgateway

## Prerequisites

- Knative requires a Kubernetes cluster v1.10 or newer with the
[MutatingAdmissionWebhook admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#how-do-i-turn-on-an-admission-controller)
enabled.
- Requires kubectl v1.10+.
- Istio - You should have Istio installed on your Kubernetes cluster. If you do not have it installed already you can do so by running the following command:
```bash
$ kubectl apply --filename https://raw.githubusercontent.com/knative/serving/v0.2.3/third_party/istio-1.0.2/istio.yaml
```

- Install crds:

```bash
$ kubectl apply --filename https://raw.githubusercontent.com/IBM/charts/master/community/knative/all-crds.yaml
```

### Container image security requirements

If Container Image Security is enabled, you will not be able to download non-trusted container images. If this is the case, please add the following to the trusted registries at the cluster level, so that knative container images can be pulled during chart installation:

- gcr.io/knative-releases/github.com/knative/build/*
- gcr.io/knative-releases/github.com/knative/serving/*
- gcr.io/knative-releases/github.com/knative/eventing/*
- gcr.io/cloud-builders/gcs-fetcher:*
- k8s.gcr.io/fluentd-elasticsearch:*
- k8s.gcr.io/elasticsearch:*
- k8s.gcr.io/addon-resizer:*
- quay.io/coreos/kube-rbac-proxy:*
- quay.io/coreos/kube-state-metrics:*
- quay.io/coreos/monitoring-grafana:*
- quay.io/prometheus/node-exporter:*
- docker.io/prom/prometheus:*
- docker.io/openzipkin/zipkin:*
- docker.io/istio/proxyv2:*

Follow [image security enforcement using ICP](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_images/image_security.html) for more information.

## Installing the Chart

Please ensure that you have reviewed the prerequisites section.

To install the chart using helm cli:

Install Knative
```bash
$ helm install ./knative --name <my-release> [--tls]
```

The command deploys Knative on the Kubernetes cluster in the default configuration.  The configuration section lists the parameters that can be configured during installation.

You can use the command ```helm status <my-release> [--tls]``` to get a summary of the various Kubernetes artifacts that make up your Knative deployment.

### Configuration

This chart is made up of multiple subcharts in the structure below:
```
knative
├── build
├── eventing
│   ├── in-memory-provisioner
│   └── kafka-provisioner
└── serving
    └── monitoring
        ├── elasticsearch
        ├── prometheus
        └── zipkin
```
To enable/disable each subchart, change the following values:
```
global:
  build:
    enabled: true
  eventing:
    enabled: false
    in-memory-provisioner:
      enabled: false
    kafka-provisioner:
      enabled: false
  serving:
    enabled: true
    monitoring:
      enabled: false
      elasticsearch:
        enabled: false
      prometheus:
        enabled: false
      zipkin:
        enabled: false
```
Disabling a chart will disable all charts below it in the chart structure. When enabling a subset of charts note that the parent charts are prerequisites and must be installed previously or in conjunction. 

[Values.yaml](https://github.com/IBM/charts/blob/master/community/knative/values.yaml) outlines the configuration options that are supported by this chart.
To configure the individual components, change the values located within each subchart.

### Verifying the Chart

To verify all Pods are running, try:
```bash
$ helm status <my-release> [--tls]
```

## Uninstalling the Chart

To uninstall/delete the deployment:
```bash
$ helm delete <my-release> --purge [--tls]
```

To uninstall/delete the crds:
```bash
$ kubectl delete --filename https://raw.githubusercontent.com/IBM/charts/master/community/knative/all-crds.yaml
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Limitations
- Only one instance of each knative component can exist per cluster.
- There is no rollback or upgrade path for this chart.

Look inside each subchart to view the their limitations.

## Documentation

To learn more about Knative in general, see the [Overview](https://github.com/knative/docs/blob/master/README.md).

# Support

If you're a developer, operator, or contributor trying to use Knative, the
following resources are available for you:

- [Knative Users](https://groups.google.com/forum/#!forum/knative-users)
- [Knative Developers](https://groups.google.com/forum/#!forum/knative-dev)

For contributors to Knative, we also have [Knative Slack](https://slack.knative.dev).
