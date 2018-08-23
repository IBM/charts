# Istio-Remote

[Istio](https://istio.io/) is an open platform for providing a uniform way to integrate microservices, manage traffic flow across microservices, enforce policies and aggregate telemetry data.

## Introduction

This chart is installed on remote clusters to connect with the Istio control plane on a local cluster, to support the [Istio multi-cluster](https://istio.io/docs/setup/kubernetes/multicluster-install/) feature. 

Multicluster functions by enabling Kubernetes control planes running a remote configuration to connect to **one** Istio control plane. Once one or more remote Kubernetes clusters are connected to the Istio control plane, Envoy can then communicate with the **single** Istio control plane and form a mesh network across multiple Kubernetes clusters.

## Chart Details

This chart will install the security (Citadel) and sidecar injector webhook(optional) components and create a headless service and endpoint for `istio-pilot` with the `remotePilotAddress`.

## Prerequisites
- A user with `cluster-admin` ClusterRole is required to install the chart.
- Kubernetes 1.9 or newer cluster with RBAC (Role-Based Access Control) enabled is required.
- Wait for the Istio control plane to finish initializing and then run these operations on the Istio control plane cluster to capture the Istio control-plane service endpoints–e.g. `Pilot`, `Policy`, and `Statsd` Pod IP endpoints.
```
export PILOT_POD_IP=$(kubectl -n istio-system get pod -l istio=pilot -o jsonpath='{.items[0].status.podIP}')
export POLICY_POD_IP=$(kubectl -n istio-system get pod -l istio-mixer-type=policy -o jsonpath='{.items[0].status.podIP}')
export STATSD_POD_IP=$(kubectl -n istio-system get pod -l istio=statsd-prom-bridge -o jsonpath='{.items[0].status.podIP}')
export TELEMETRY_POD_IP=$(kubectl -n istio-system get pod -l istio-mixer-type=telemetry -o jsonpath='{.items[0].status.podIP}')
export ZIPKIN_POD_IP=$(kubectl -n istio-system get pod -l app=jaeger -o jsonpath='{range .items[*]}{.status.podIP}{end}')
```
  Then copy these environment variables to each node before using Helm to connect the remote cluster to the Istio control plane.

## Resources Required

The chart deploys pods that consume minimum resources as specified in the resources configuration parameters.

## Installing the Chart

1. Create namespace `istio-system` for the chart:
```
$ kubectl create ns istio-system
```

2. To install the chart with the release name `istio-remote` in namespace `istio-system`:
```
$ helm install ../ibm-istio-remote --name istio-remote  --namespace istio-system --set global.remotePilotAddress=${PILOT_POD_IP} --set global.remotePolicyAddress=${POLICY_POD_IP} --set global.remoteTelemetryAddress=${TELEMETRY_POD_IP} --set global.proxy.envoyStatsd.enabled=true --set global.proxy.envoyStatsd.host=${STATSD_POD_IP} --set global.remoteZipkinAddress=${ZIPKIN_POD_IP}
```
**Note**:  Currently, only one instance of Istio or Istio-Remote can be installed on a cluster at a time.

## Configuration

The `istio-remote` helm chart requires the four specific variables to be configured as defined in the following table:

| Parameter | Description | Values | Default |
| --------- | ----------- | ------ | ------- |
| `global.proxy.repository` | Specifies the proxy image location | valid image repository | `ibmcom/istio-proxyv2` |
| `global.proxy.tag` | Specifies the proxy image version | valid image tag | `1.0.0` |
| `global.proxy.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | `{requests.cpu: 100m, requests.memory: 128Mi}` |
| `global.proxy.accessLogFile`| Specifies the access log for each sidecar, an empty string will disable access log for sidecar | valid file path or empty string | `/dev/stdout` |
| `global.proxy.enableCoreDump` | Specifies whether to enable debug information for envoy sidecar | true/false | `false` |
| `global.proxy.includeIPRanges` | Specifies istio egress capture whitelist | example: includeIPRanges: "172.30.0.0/16,172.20.0.0/16" | `*` |
| `global.proxy.excludeIPRanges` | Specifies istio egress capture blacklist | example: excludeIPRanges: "172.40.0.0/16,172.50.0.0/16" | `""` |
| `global.proxy.excludeInboundPorts` | Specifies istio egress capture port blacklist | example: excludeInboundPorts: "81:8081" | `""` |
| `global.proxy.autoInject` | Specifies whether to enable ingress and egress policy for envoy sidecar | `enabled`/`disabled` | `enabled` |
| `global.proxy.envoyStatsd.enabled` | Specifies whether to enable the destination statsd in envoy | true/false | `true` |
| `global.proxy.envoyStatsd.host` | Specifies host for the destination statsd in envoy | destination statsd host | `istio-statsd-prom-bridge` |
| `global.proxy.envoyStatsd.port` | Specifies host port for the destination statsd in envoy | destination statsd port | `9125` |
| `global.proxyInit.repository` | Specifies the proxy init image location | valid image repository | `ibmcom/istio-proxy_init` |
| `global.proxyInit.tag` | Specifies the proxy init image version | valid image tag | `1.0.0` |
| `global.imagePullPolicy` | Specifies the image pull policy | valid image pull policy | `IfNotPresent` |
| `global.kubectl.repository` | Specifies the kubectl image location | valid image repository | `ibmcom/kubectl` |
| `global.kubectl.tag` | Specifies the kubectl image version | valid image tag | `v1.11.1` |
| `global.controlPlaneSecurityEnabled` | Specifies whether control plane mTLS is enabled | true/false | `false` |
| `global.disablePolicyChecks` | Specifies whether to disables mixer policy checks | true/false | `false` |
| `global.enableTracing` | Specifies whether to enables the Tracing | true/false | `true` |
| `global.mtls.enabled` | Specifies whether mTLS is enabled by default between services | true/false | `false` |
| `global.imagePullSecrets` | Specifies image pull secrets for private docker registry | array consists of imagePullSecret | [] |
| `global.remotePilotCreateSvcEndpoint` | Specifies whether to create a headless service and endpoint for `istio-pilot` with the `remotePilotAddress` | true/false | `false` |
| `global.remotePilotAddress` | Specifies the pilot Pod IP address for the Istio control plane | valid pod IP address | `""` |
| `global.remotePolicyAddress` | Specifies the mixer policy Pod IP address for the Istio control plane | valid pod IP address | `""` |
| `global.remoteTelemetryAddress` | Specifies the mixer telemetry Pod IP address for the Istio control plane | valid pod IP address | `""` |
| `global.remoteZipkinAddress` | Specifies the tracing Pod IP address for the Istio control plane | valid pod IP address | `""` |
| `gobal.defaultResources` | Specifies resources(CPU/Memory) requests & limits applied to all deployments | valid CPU&memory settings | `{requests.cpu: 10m}` |
| `global.omitSidecarInjectorConfigMap` | Specifies whether to omit the istio-sidecar-injector configmap when generate a standalone gateway | true/false | `false` |
| `global.priorityClassName` | Specifies priority class to make sure Istio pods will not be evicted because of low prioroty class | valid priority class name | `""` |
| `global.proxyNode` | Specifies whether to deploy to proxy node with labels `proxy=true`(effective only on IBM Cloud Private) | true/false | `true` |
| `global.dedicated` | Specifies whether to deploy to dedicated node with taint `dedicated=:NoSchedule`(effective only on IBM Cloud Private) | true/false | `true` |
| `global.extraNodeSelector` | Specifies customized node selector for all components | valid node selector | {} |
| `global.arch.amd64`| Architecture preference for amd64 node | `0 - Do not use`/`1 - Least preferred`/`2 - No preference`/`3 - Most preferred` | `2 - No preference` |
| `global.arch.ppc64le` | Architecture preference for ppc64le node | `0 - Do not use`/`1 - Least preferred`/`2 - No preference`/`3 - Most preferred` | `2 - No preference` |
| `sidecarinjectorwebhook.enabled` | Specifies whether the Automatic Sidecar Injector should be installed | true/false | `true` |
| `sidecarinjectorwebhook.replicaCount` | Specifies number of desired pods for Automatic Sidecar Injector Webhook | number | `1` |
| `sidecarinjectorwebhook.enableNamespacesByDefault` | Specifies use the default namespaces for Automatic Sidecar Injector Webhook | true/false | `false` |
| `sidecarinjectorwebhook.image.repository` | Specifies the Automatic Sidecar Injector image location | valid image repository | `ibmcom/istio-sidecar_injector` |
| `sidecarinjectorwebhook.image.tag` | Specifies the Automatic Sidecar Injector image version | valid image tag | `1.0.0` |
| `sidecarinjectorwebhook.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `security.replicaCount` | Specifies number of desired pods for Citadel deployment | number | `1` |
| `security.selfSigned` | Specifies whether self-signed CA is enabled | true/false | `true` |
| `security.image.repository` | Specifies the Citadel image location | valid image repository | `ibmcom/istio-citadel` |
| `security.image.tag` | Specifies the Citadel image version | valid image tag | `1.0.0` |
| `security.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |

## Uninstalling the Chart

To uninstall/delete the `istio-remote` release:
```
$ helm delete istio-remote
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

To uninstall/delete the `istio-remote` release completely and make its name free for later use:
```
$ helm delete istio-remote --purge
```

## Limitations

- In a [multicluster deployment](https://istio.io/docs/setup/kubernetes/multicluster-install) the mixer-telemetry and mixer-policy components do not connect to the Kubernetes API endpoints of any of the remote clusters. This results in a loss of telemetry fidelity as some of the metadata associated with workloads on remote clusters is incomplete.

- The `pilotEndpoint`, `policyEndpoint`, `statsdEndpoint`, `zipkinEndpoint` endpoints need to be resolvable via Kubernetes. The simplest approach to enabling resolution for these variables is to specify the Pod IP of the various services. One problem with this is Pod IPs change during the lifetime of the service.

- Currently ICP Catalog UI doesn't support input type of `array` and `object`, customization for these fields should be done via helm command-line instead of ICP Catalog UI.
