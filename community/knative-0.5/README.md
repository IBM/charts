# Knative

This chart installs Knative components for Build, Serving, Eventing and Eventing-Sources.

## Introduction

- Visit [Knative Build](https://github.com/knative/build/blob/master/README.md) for more information about Build.
- Visit [Knative Eventing](https://github.com/knative/eventing/blob/master/README.md) for more information about Eventing.
- Visit [Knative Eventing Sources](https://github.com/knative/eventing-sources/blob/master/README.md) for more information about Eventing Sources.
- Visit [Knative Serving](https://github.com/knative/serving/blob/master/README.md) for more information about Serving.

## Chart Details

This chart is comprised of multiple subcharts which is illustrated in the structure below:
```
knative                         (default)
├── build                       (default)
├── eventing
│   └── inMemoryProvisioner
├── serving                     (default)
│   └── monitoring              (default)
│       └── prometheus         (default)
└── eventingSources
```
Disabling a chart will disable all charts below it in the chart structure. When enabling a subset of charts note that the parent charts are prerequisites and must be installed previously or in conjunction.

## Prerequisites
- Requires kubectl v1.10+.
- Knative requires a Kubernetes cluster v1.11 or newer with the
[MutatingAdmissionWebhook admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#how-do-i-turn-on-an-admission-controller)
enabled.
- Istio - You should have Istio installed on your Kubernetes cluster. If you do not have it installed already you can do so by running the following commands:
```bash
$ kubectl apply --filename https://github.com/knative/serving/releases/download/v0.5.2/istio-crds.yaml \
--filename https://github.com/knative/serving/releases/download/v0.5.2/istio.yaml
```
or by following these steps:
[Installing Istio](https://www.knative.dev/docs/install/knative-with-any-k8s/#installing-istio)


## Installing the Chart

Please ensure that you have reviewed the [prerequisites](#prerequisites).

1. Install Knative crds
```bash
$ kubectl apply -f https://raw.githubusercontent.com/IBM/charts/master/community/knative/all-crds.yaml
```

2. Install the chart using helm cli:

```bash
$ helm repo add ibm-community-charts https://raw.githubusercontent.com/IBM/charts/master/repo/community
$ helm install ibm-community-charts/knative --name <my-release> [--tls]
```

The command deploys Knative on the Kubernetes cluster in the default configuration.  The [configuration](#configuration) section lists the parameters that can be configured during installation.

You can use the command ```helm status <my-release> [--tls]``` to get a summary of the various Kubernetes artifacts that make up your Knative deployment.

### Configuration

| Parameter                                  | Description                              | Default |
|--------------------------------------------|------------------------------------------|---------|
| `build.enabled`                                  | Enable/Disable Knative Build             | `true`    |
| `build.buildController.image`                    | Build Controller Image                   | ibmcom/knative-build-cmd-controller:0.5    |
| `build.buildController.replicas`                 | Number of pods for Build Contoller       |    1      |
| `build.buildWebhook.image`                       | Build Webhook Image                      | ibmcom/knative-build-cmd-webhook:0.5  |
| `build.buildWebhook.replicas`                    | Number of pods for Build Webhook         |    1      |
| `build.credsInit.image`                          | credsInit Image                          |    ibmcom/knative-build-cmd-creds-init:0.5    |
| `build.gcsFetcher.image`                         | gcsFetcher Image                          |    ibmcom/gcs-fetche:0.5      |
| `build.gitInit.image`                            | gitInit Image                            |    ibmcom/knative-build-cmd-git-init:0.5      |
| `build.nop.image`                                | nop Image                                |    ibmcom/knative-build-cmd-nop:0.5      |
| `eventing.enabled`                         | Enable/Disable Knative Eventing          | `false`   |
| `eventing.eventingController.image`        | Controller Image                         | ibmcom/knative-eventing-cmd-controller:0.5 | 
| `eventing.eventingController.replicas`                        | Controller Replicas                      | 1         |
| `eventing.webhook.image`                   | Webhook Image                            | ibmcom/knative-eventing-cmd-webhook:0.5 |
| `eventing.webhook.replicas`                | Webhook Replicas                         | 1         |
| `eventing.inMemoryProvisioner.enabled`     | Enable/Disable In-Memory Provisioner     | `false`   |
| `eventing.inMemoryProvisioner.inMemoryChannelController.controller.image` | Controller Image                    | ibmcom/knative-eventing-pkg-provisioners-inmemory-controller:0.5 |
| `eventing.inMemoryProvisioner.inMemoryChannelController.replicas`    | Controller Replicas           | 1         |
| `eventing.inMemoryProvisioner.inMemoryChannelDispatcher.dispatcher.image` | Dispatcher Image | ibmcom/knative-eventing-cmd-fanoutsidecar:0.5 | 
| `eventing.inMemoryProvisioner.inMemoryChannelDispatcher.replicas` | Dispatcher Replicas | 1       |
| `eventingSources.enabled`                  | Enable/Disable Knative Eventing Sources  | `false`   |
| `eventingSources.controllerManager.manager.image`        | Manager Image for Controller Manager | ibmcom/knative-eventing-sources-cmd-manager:0.5   |
| `serving.enabled`                          | Enable/Disable Knative Serving           | `true`    |
| `serving.activator.image`                  | Activator Image                          | ibmcom/knative-serving-cmd-activator:0.5   |
| `serving.activatorService.type`            | Activator Ingress Type                   | ClusterIP |
| `serving.autoscaler.image`                 | Autoscaler Image                         | ibmcom/knative-serving-cmd-autoscaler:0.5   |
| `serving.autoscaler.replicas`              | Autoscaler Replicas                      | 1         |
| `serving.controller.image`                 | Controller Image                         | ibmcom/knative-serving-cmd-controller:0.5 |
| `serving.controller.replicas`              | Controller Replicas                      | 1         |
| `serving.queueProxy.image`                 | Queue Proxy Image                        | ibmcom/knative-serving-cmd-queue:0.5  |
| `serving.webhook.image`                    | Webhook Image                            | ibmcom/knative-serving-cmd-webhook:0.5  |
| `serving.webhook.replicas`                 | Webhook Replicas                         | 1         |
| `serving.monitoring.enabled`               | Enable/Disable Knative Monitoring        | `true`    |
| `serving.monitoring.prometheus.enabled`    | Enable/Disable Prometheus Metrics        | `true`    |
| `serving.monitoring.prometheus.grafana.image`    | Grafana Image        | ibmcom/grafana:5.2.0-f3   |
| `serving.monitoring.prometheus.grafana.replicas`    | Number of Grafana pods         | 1    |
| `serving.monitoring.prometheus.grafana.type`    | Grafana Ingress Type        | NodePort   |
| `serving.monitoring.prometheus.kubeControllerManager.type`    | kubeControllerManager Ingress Type |  ClusterIP  |
| `serving.monitoring.prometheus.kubeStateMetrics.addonResizer.image` | Add On Resizer Image for Kube State Metrics | ibmcom/addon-resizer:2.1   |
| `serving.monitoring.prometheus.kubeStateMetrics.image`    | Kube State Metrics Image        | ibmcon/kube-state-metrics:v1.3.0-f3   |
| `serving.monitoring.prometheus.kubeStateMetrics.kubeRbacProxyMain.image`    | Kube Rbac Proxy Main Image for Kube State Metrics  | ibmcom/kube-rbac-proxy:v0.3.0   |
| `serving.monitoring.prometheus.kubeStateMetrics.kubeRbacProxySelf.image`    | Kube Rbac Proxy Self Image for Kube State Metrics  | ibmcom/kube-rbac-proxy:v0.3.0   |
| `serving.monitoring.prometheus.kubeStateMetrics.replicas`  | Number of Kube State Metrics Pods |  1  |
| `serving.monitoring.prometheus.nodeExporter.image` | Node Exporter Image for Prometheus | ibmcom/node-exporter:v0.16.0-f3   |
| `serving.monitoring.prometheus.nodeExporter.kubeRbacProxy.https.hostPort`    | Https Host Port for Kube Rbac Proxy Node Exporter  | 9100  |
| `serving.monitoring.prometheus.nodeExporter.kubeRbacProxy.image`    | Kube Rbac Proxy Image  | ibmcom/kube-rbac-proxy:v0.3.0  |
| `serving.monitoring.prometheus.nodeExporter.type`    | Node Exporter Ingress Type  | ClusterIP  |
| `serving.monitoring.prometheus.prometheusSystem.prometheus.image`    | Prometheus Image for Prometheus System  | ibmcom/prometheus:v2.8.0  |
| `serving.monitoring.prometheus.prometheusSystem.replicas`    | Number of Prometheus System Pods  | 2  |
| `serving.monitoring.prometheus.prometheusSystemDiscovery.type`    | Ingress Type for Prometheus System Discovery  | ClusterIP  |
| `serving.monitoring.prometheus.prometheusSystemNp.type`    | Ingress Type for Prometheus System Np  | NodePort  |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

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
$ kubectl delete -f https://raw.githubusercontent.com/IBM/charts/master/community/knative/all-crds.yaml
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Limitations

Currently this chart does not support multiple installs of Knative, upgrades or rollbacks.

## Documentation

To learn more about Knative in general, see the [Knative Documentation](https://www.knative.dev/docs).

# Support

If you're a developer, operator, or contributor trying to use Knative, the
following resources are available for you:

- [Knative Users](https://groups.google.com/forum/#!forum/knative-users)
- [Knative Developers](https://groups.google.com/forum/#!forum/knative-dev)

For contributors to Knative, we also have [Knative Slack](https://slack.knative.dev).