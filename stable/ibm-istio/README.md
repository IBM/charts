# Istio

[Istio](https://istio.io/) is an open platform for providing a uniform way to integrate microservices, manage traffic flow across microservices, enforce policies and aggregate telemetry data.

## Introduction

This chart bootstraps all Istio [components](https://istio.io/docs/concepts/what-is-istio/overview.html) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Chart Details

This chart can install multiple Istio components as subcharts:

| Subchart | Component | Description | Enabled by Default |
| -------- | --------- | ----------- | ------------------ |
| ingress | Ingress | An [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) implementation with [envoy proxy](https://github.com/envoyproxy/envoy) that allows inbound connections to reach the mesh. This deprecated component is used to support combining Kubernetes Ingress specs with Istio routing rules and it will be removed in the next release. | Yes |
| ingressgateway | Ingress Gateway | A new component used to replace the `ingress` component, supports a platform independent [Gateway](https://istio.io/docs/concepts/traffic-management/rules-configuration/#gateways) model for ingress. | Yes |
| egressgateway | Egress Gateway | A new component used to replace `ingress`, together with `ingressgateway` supports new [Traffic Management API](https://istio.io/blog/2018/v1alpha3-routing/). | Yes |
| sidecarinjectorwebhook | Automatic Sidecar Injector | A [mutating webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#admission-webhooks) implementation to automatically inject an envoy sidecar container into application pods. | Yes |
| mixer | Mixer | A centralized component that is leveraged by the proxies and microservices to enforce policies such as authorization, rate limits, quotas, authentication, request tracing and telemetry collection. | Yes |
| pilot | Pilot | A component responsible for configuring the proxies at runtime. | Yes |
| security | Citadel | A centralized component responsible for certificate issuance and rotation. | Yes |
| grafana | [Grafana](https://grafana.com/) | A visualization tool for monitoring and metric analytics & dashboards for Istio | No |
| prometheus | [Prometheus](https://prometheus.io/) | A service monitoring system for Istio that collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true. | Yes |
| servicegraph | Service Graph | A small add-on for Istio that generates and visualizes graph representations of service mesh. | No |
| tracing | [Jaeger](https://www.jaegertracing.io/) | Istio uses Jaeger as a tracing system that is used for monitoring and troubleshooting Istio service mesh. | No |

To enable or disable each component, change the corresponding `enabled` flag.

## Prerequisites

- A user with `cluster-admin` ClusterRole is required to install the chart.
- Kubernetes 1.9 or newer cluster with RBAC (Role-Based Access Control) enabled is required.
- Helm 2.7.2 or newer is required.
- To enable automatic sidecar injection, Kubernetes 1.9+ with `admissionregistration` API is required, and the `kube-apiserver` process must have the `admission-control` flag set with the `MutatingAdmissionWebhook` and `ValidatingAdmissionWebhook` admission controllers added and listed in the correct order.

## Resources Required

The chart deploys pods that consume minimum resources as specified in the resources configuration parameter.

## Installing the Chart

1. Create namespace `istio-system` for the chart:
   ```
   $ kubectl create ns istio-system
   ```

2. To install the chart with the release name `istio` in namespace `istio-system`:
   - With [automatic sidecar injection](https://istio.io/docs/setup/kubernetes/sidecar-injection/#automatic-sidecar-injection) (requires Kubernetes >=1.9.0):
   ```
   $ helm install ../ibm-istio --name istio --namespace istio-system
   ```
   
   - Without the sidecar injection webhook:
   ```
   $ helm install ../ibm-istio --name istio --namespace istio-system --set sidecarinjectorwebhook.enabled=false
   ```

**Note**:  Currently, only one instance of Istio can be installed on a cluster at a time.

## Configuration

The Helm chart ships with reasonable defaults.  There may be circumstances in which defaults require overrides.
To override Helm values, use `--set key=value` argument during the `helm install` command.  Multiple `--set` operations may be used in the same Helm operation.

Helm charts expose configuration options which are currently in alpha.  The currently exposed options are explained in the following table:

| Parameter | Description | Values | Default |
| --------- | ----------- | ------ | ------- |
| `global.proxy.repository` | Specifies the proxy image location | valid image repository | `ibmcom/istio-proxy` |
| `global.proxy.tag` | Specifies the proxy image version | valid image tag | `0.8.0` |
| `global.proxy.enableCoreDump` | Specifies whether to enable debug information for envoy sidecar | true/false | `false` |
| `global.proxy.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `global.proxy.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `1024Mi`, CPU: `8000m` |
| `global.proxy.includeIPRanges` | Specifies istio egress capture whitelist | example: includeIPRanges: "172.30.0.0/16,172.20.0.0/16" | `*` |
| `global.proxy.excludeIPRanges` | Specifies istio egress capture blacklist | example: excludeIPRanges: "172.40.0.0/16,172.50.0.0/16" | `""` |
| `global.proxy.excludeInboundPorts` | Specifies istio egress capture port blacklist | example: excludeInboundPorts: "81:8081" | `""` |
| `global.proxy.policy` | Specifies whether to enable ingress and egress policy for envoy sidecar | `enabled`/`disabled` | `enabled` |
| `global.proxyv2.repository` | Specifies the proxy v2 image location | valid image repository | `ibmcom/istio-proxyv2` |
| `global.proxyv2.tag` | Specifies the proxy v2 image version | valid image tag | `0.8.0` |
| `global.proxyInit.repository` | Specifies the proxy init image location | valid image repository | `ibmcom/istio-proxy_init` |
| `global.proxyInit.tag` | Specifies the proxy init image version | valid image tag | `0.8.0` |
| `global.imagePullPolicy` | Specifies the image pull policy | valid image pull policy | `IfNotPresent` |
| `global.kubectl.repository` | Specifies the kubectl image location | valid image repository | `ibmcom/kubectl` |
| `global.kubectl.tag` | Specifies the kubectl image version | valid image tag | `v1.10.0` |
| `global.priorityClassName` | Specifies priority class to make sure Istio pods will not be evicted because of low prioroty class | `system-cluster-critical`/`system-node-critical`/`""` | `""` |
| `global.controlPlaneSecurityEnabled` | Specifies whether control plane mTLS is enabled | true/false | `false` |
| `global.mtls.enabled` | Specifies whether mTLS is enabled by default between services | true/false | `false` |
| `global.rbacEnabled` | Specifies whether to create Istio RBAC rules or not | true/false | `true` |
| `global.imagePullSecrets` | Specifies image pull secrets for private docker registry | array consists of imagePullSecret | Empty Array |
| `global.refreshInterval` | Specifies the mesh discovery refresh interval | integer followed by s | `10s` |
| `global.oneNamespace` | Specifies whether to restrict the applications namespace the controller manages | true/false | `false` |
| `global.meshExpansionEnabled` | Specifies whether to support mesh expansion | true/false | `false` |
| `global.management` | Specifies whether deploy to node with labels `management=true` | true/false | `true` |
| `global.dedicated` | Specifies whether to deploy to dedicated node with taint `dedicated=:NoSchedule` | true/false | `true` |
| `global.criticalAddonsOnly` | Specifies whether to deploy istio as a critical addon | true/false | `true` |
| `global.extraNodeSelector.key` | Specifies extra node selector key | string as key | `""` |
| `global.extraNodeSelector.value` | Specifies extra node selector value | string as value | `""` |
| `global.arch.amd64`| Architecture preference for amd64 node | `0 - Do not use`/`1 - Least preferred`/`2 - No preference`/`3 - Most preferred` | `2 - No preference` |
| `global.arch.ppc64le` | Architecture preference for ppc64le node | `0 - Do not use`/`1 - Least preferred`/`2 - No preference`/`3 - Most preferred` | `2 - No preference` |
| `ingress.enabled` | Specifies whether Ingress should be installed (deprecated)| true/false | `true` |
| `ingress.replicaCount` | Specifies number of desired pods for Ingress deployment | number | `1` |
| `ingress.autoscaleMin` | Specifies lower limit for the number of pods that can be set by the autoscaler | number | `1` |
| `ingress.autoscaleMax` | Specifies upper limit for the number of pods that can be set by the autoscaler | number | `1` |
| `ingress.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `512Mi`, CPU: `4000m` |
| `ingress.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `ingress.service.loadBalancerIP` | Specifies load balancer IP if its type is LoadBalancer | valid IP address | `""` |
| `ingress.service.type` | Specifies service type for Ingress | valid service type | `LoadBalancer` |
| `ingressgateway.enabled` | Specifies whether the Ingress Gateway should be installed | true/false | `true` |
| `ingressgateway.serviceAccountName` | Specifies service account that used for Ingress Gateway | valid service account name | `istio-ingressgateway-service-account` |
| `ingressgateway.replicaCount` | Specifies number of desired pods for Ingress Gateway deployment | number | `1` |
| `ingressgateway.autoscaleMin` | Specifies lower limit for the number of pods that can be set by the autoscaler | number | `1` |
| `ingressgateway.autoscaleMax` | Specifies upper limit for the number of pods that can be set by the autoscaler | number | `1` |
| `ingressgateway.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `512Mi`, CPU: `4000m` |
| `ingressgateway.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `ingressgateway.service.name` | Specifyies name for Ingress Gateway service | valid service name | `istio-ingressgateway` |
| `ingressgateway.service.labels` | Specifyies labels for Ingress Gateway service | valid service labels | `istio: ingressgateway` |
| `ingressgateway.service.loadBalancerIP` | Specifies load balancer IP for Ingress Gateway service if its type is LoadBalancer | valid IP address | `""` |
| `ingressgateway.service.type` | Specifies service type for Ingress Gateway | valid service type | `LoadBalancer` |
| `ingressgateway.service.ports` | Specifies service ports settings for Ingress Gateway | valid service ports settings |  |
| `ingressgateway.deployment.labels` | Specifyies labels for Ingress Gateway deployment | valid deployment labels | `istio: ingressgateway` |
| `ingressgateway.deployment.ports` | Specifies deployment ports settings for Ingress Gateway | valid deployment ports |  |
| `ingressgateway.deployment.secretVolumes` | Specifies deployment certs volume settings for Ingress Gateway | valid deployment volume |  |
| `egressgateway.enabled` | Specifies whether the Egress Gateway should be installed | true/false | `true` |
| `egressgateway.serviceAccountName` | Specifies service account that used for Egress Gateway | valid service account name | `istio-egressgateway-service-account` |
| `egressgateway.replicaCount` | Specifies number of desired pods for Egress Gateway deployment | number | `1` |
| `egressgateway.autoscaleMin` | Specifies lower limit for the number of pods that can be set by the autoscaler | number | `1` |
| `egressgateway.autoscaleMax` | Specifies upper limit for the number of pods that can be set by the autoscaler | number | `1` |
| `egressgateway.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `512Mi`, CPU: `4000m` |
| `egressgateway.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `egressgateway.service.name` | Specifyies name for Egress Gateway service | valid service name | `istio-egressgateway` |
| `egressgateway.service.labels` | Specifyies labels for Egress Gateway service | valid service labels | `istio: egressgateway` |
| `egressgateway.service.type` | Specifies service type for Egress Gateway | valid service type | `ClusterIP` |
| `egressgateway.service.ports` | Specifies service ports settings for Egress Gateway | valid service ports settings |  |
| `egressgateway.deployment.labels` | Specifyies labels for Egress Gateway deployment | valid deployment labels | `istio: egressgateway` |
| `egressgateway.deployment.ports` | Specifies deployment ports settings for Egress Gateway | valid deployment ports |  |
| `sidecarinjectorwebhook.enabled` | Specifies whether the Automatic Sidecar Injector should be installed | true/false | `true` |
| `sidecarinjectorwebhook.replicaCount` | Specifies number of desired pods for Automatic Sidecar Injector Webhook | number | `1` |
| `sidecarinjectorwebhook.image.repository` | Specifies the Automatic Sidecar Injector image location | valid image repository | `ibmcom/istio-sidecar_injector` |
| `sidecarinjectorwebhook.image.tag` | Specifies the Automatic Sidecar Injector image version | valid image tag | `0.8.0` |
| `sidecarinjectorwebhook.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `512Mi`, CPU: `5000m` |
| `sidecarinjectorwebhook.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `mixer.enabled` | Specifies whether Mixer should be installed | true/false | `true` |
| `mixer.replicaCount` | Specifies number of desired pods for Mixer | number | `1` |
| `mixer.image.repository` | Specifies the Mixer image location | valid image repository | `ibmcom/istio-mixer` |
| `mixer.image.tag` | Specifies the Mixer image version | valid image tag | `0.8.0` |
| `mixer.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `1024Mi`, CPU: `8000m` |
| `mixer.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `mixer.prometheusStatsdExporter.repository` | Specifies the Prometheus Statsd Exporter image location | valid image repository | `ibmcom/prom-statsd-exporter` |
| `mixer.prometheusStatsdExporter.tag` | Specifies the Prometheus Statsd Exporter image version | valid image tag | `v0.5.0` |
| `mixer.prometheusStatsdExporter.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `256Mi`, CPU: `2000m` |
| `mixer.prometheusStatsdExporter.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `pilot.enabled` | Specifies whether Pilot should be installed | true/false | `true` |
| `pilot.replicaCount` | Specifies number of desired pods for Pilot | number | `1` |
| `pilot.image.repository` | Specifies the Pilot image location | valid image repository | `ibmcom/istio-pilot` |
| `pilot.image.tag` | Specifies the Pilot image version | valid image tag | `0.8.0` |
| `pilot.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `1024Mi`, CPU: `8000m` |
| `pilot.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `security.enabled` | Specifies whether Citadel should be installed | true/false | `true` |
| `security.replicaCount` | Specifies number of desired pods for Citadel | number | `1` |
| `security.image.repository` | Specifies the Citadel image location | valid image repository | `ibmcom/istio-citadel` |
| `security.image.tag` | Specifies the Citadel image version | valid image tag | `0.8.0` |
| `security.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `1024Mi`, CPU: `7000m` |
| `security.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `security.cleanUpOldCA` | Specify whether to clean old istio-ca resources | true/false | `true` |
| `grafana.enabled` | Specifies whether Grafana addon should be installed | true/false | `false` |
| `grafana.replicaCount` | Specifies number of desired pods for Grafana | number | `1` |
| `grafana.image.repository` | Specifies the Grafana image location | valid image repository | `ibmcom/istio-grafana` |
| `grafana.image.tag` | Specifies the Grafana image version | valid image tag | `0.8.0` |
| `grafana.service.name` | Specifies name for the Grafana service | valid service name | `http` |
| `grafana.service.type` | Specifies type for the Grafana service | valid service type | `ClusterIP` |
| `grafana.service.externalPort` | Specifies external port for the Grafana service | valid service port | `3000` |
| `grafana.ingress.enabled` | Specifies whether ingress for Grafana should be enabled | true/false | `false` |
| `grafana.ingress.hosts` | Specify the hosts for Grafana ingress | array consists of valid hosts | Empty Array |
| `grafana.ingress.annotations` | Specify the annotations for Grafana ingress | object consists of valid annotations | Empty Object |
| `grafana.ingress.tls` | Specify the TLS settigs for Grafana ingress | array consists of valid TLS settings | Empty Array |
| `grafana.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `512Mi`, CPU: `1000m` |
| `grafana.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `prometheus.enabled` | Specifies whether Prometheus addon should be installed | true/false | `true` |
| `prometheus.replicaCount` | Specifies number of desired pods for Prometheus | number | `1` |
| `prometheus.image.repository` | Specifies the Prometheus image location | valid image repository | `ibmcom/prometheus` |
| `prometheus.image.tag` | Specifies the Prometheus image version | valid image tag | `v2.0.0` |
| `prometheus.service.nodePort.enabled` | Specifies whether to enable Node Port for Prometheus service |  true/false | `false` |
| `prometheus.service.nodePort.port` | Specifies Node Port number for Prometheus service | valid service Node Port | `32090` |
| `prometheus.ingress.enabled` | Specifies whether ingress for Prometheus should be enabled | true/false | `false` |
| `prometheus.ingress.hosts` | Specify the hosts for Prometheus ingress | array consists of valid hosts | Empty Array |
| `prometheus.ingress.annotations` | Specify the annotations for Prometheus ingress | object consists of valid annotations | Empty Object |
| `prometheus.ingress.tls` | Specify the TLS settigs for Prometheus ingress | array consists of valid TLS settings | Empty Array |
| `prometheus.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `1024Mi`, CPU: `5000m` |
| `prometheus.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `servicegraph.enabled` | Specifies whether Servicegraph addon should be installed | true/false | `false` |
| `servicegraph.replicaCount` | Specifies number of desired pods for Servicegraph | number | `1` |
| `servicegraph.image.repository` | Specifies the Servicegraph image location | valid image repository | `ibmcom/istio-servicegraph` |
| `servicegraph.image.tag` | Specifies the Servicegraph image version | valid image tag | `0.8.0` |
| `servicegraph.service.name` | Specifies name for the Servicegraph service | valid service name | `http` |
| `servicegraph.service.type` | Specifies type for the Servicegraph service | valid service type | `ClusterIP` |
| `servicegraph.service.externalPort` | Specifies external port for the Servicegraph service | valid service port | `8088` |
| `servicegraph.ingress.enabled` | Specifies whether ingress for Servicegraph should be enabled | true/false | `false` |
| `servicegraph.ingress.hosts` | Specify the hosts for Servicegraph ingress | array consists of valid hosts | Empty Array |
| `servicegraph.ingress.annotations` | Specify the annotations for Servicegraph ingress | object consists of valid annotations | Empty Object |
| `servicegraph.ingress.tls` | Specify the TLS settigs for Servicegraph ingress | array consists of valid TLS settings | Empty Array |
| `servicegraph.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `256Mi`, CPU: `200m` |
| `servicegraph.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |
| `tracing.enabled` | Specifies whether Tracing(jaeger) addon should be installed | true/false | `false` |
| `tracing.jaeger.enabled` | Specifies whether core Jaeger services should be installed | true/false | `false` |
| `tracing.jaeger.memory.maxTraces` | Specifies max traces limits for Jaeger | valid number | `50000` |
| `tracing.replicaCount` | Specifies number of desired pods for Tracing(jaeger) | number | `1` |
| `tracing.image.repository` | Specifies the Tracing(jaeger) image location | valid image repository | `ibmcom/jaegertracing-all-in-one` |
| `tracing.image.tag` | Specifies the Tracing(jaeger) image version | valid image tag | `1.5` |
| `tracing.service.name` | Specifies name for the Tracing(jaeger) service | valid service name | `http` |
| `tracing.service.type` | Specifies type for the Tracing(jaeger) service | valid service type | `ClusterIP` |
| `tracing.service.externalPort` | Specifies external port for the Tracing(jaeger) service | valid service port | `9411` |
| `tracing.ingress.enabled` | Specifies whether ingress for Tracing(jaeger) should be enabled | true/false | `false` |
| `tracing.ingress.hosts` | Specify the hosts for Tracing(jaeger) ingress | array consists of valid hosts | Empty Array |
| `tracing.ingress.annotations` | Specify the annotations for Tracing(jaeger) ingress | object consists of valid annotations | Empty Object |
| `tracing.ingress.tls` | Specify the TLS settigs for Tracing(jaeger) ingress | array consists of valid TLS settings | Empty Array |
| `tracing.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `1024Mi`, CPU: `5000m` |
| `tracing.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |

**Note**: If you install the Istio helm chart in another Kubernetes distribution other than IBM Cloud Private (eg. IBM Cloud Kubernetes Services), please make sure to set parameter `--set global.management=false` if there isn't any node with label `management=true`, or else you can add label `management=true` to the node that you want to run Istio via `kubectl label node <node> management=true`.

## Uninstalling the Chart

To uninstall/delete the `istio` release:
```
$ helm delete istio
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

To uninstall/delete the `istio` release completely and make its name free for later use:
```
$ helm delete istio --purge
```

## Limitations

- A gateway with virtual services pointing to a headless service won't work ([Issue #5005](https://github.com/istio/istio/issues/5005)).

- There is a [problem with Google Kubernetes Engine 1.10.2](https://github.com/istio/istio/issues/5723). The workaround is to use Kubernetes 1.9 or switch the node image to Ubuntu. A fix is expected in GKE 1.10.4.

- There is a known namespace issue with the `istioctl experimental convert-networking-config` tool where the desired namespace may be changed to the `istio-system namespace`, please manually adjust to use the desired namespace after running the conversation tool. [Learn more](https://github.com/istio/istio/issues/5817)

- There is a [helm upgrade issue](https://github.com/kubernetes/helm/issues/1193) which will cause upgrading Istio from 0.7.1 to 0.8.0 to fail. Currently if you want to upgrade from 0.7.1 to 0.8.0, you need to manually delete 0.7.1 and then re-install 0.8.0.

- Currently ICP Catalog UI doesn't support input type of `array` and `object`, any customization for field `global.imagePullSecrets`, `grafana.ingress`, `prometheus.ingress`, `servicegraph.ingress` and `tracing.ingress` should be done via helm command-line instead of ICP Catalog UI.
