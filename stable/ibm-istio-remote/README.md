# Istio-Remote

[Istio](https://istio.io/) is an open platform for providing a uniform way to integrate microservices, manage traffic flow across microservices, enforce policies and aggregate telemetry data.

## Introduction

This chart is installed on remote clusters to connect with the Istio control plane on a local cluster, to support the [Istio multi-cluster](https://istio.io/docs/setup/kubernetes/multicluster-install/) feature.

## Chart Details

This chart will install the security (Citadel) component and register the following four services on a remote cluster with Istio installed:
- istio-pilot
- istio-policy
- istio-statsd-prom-bridge
- zipkin

## Prerequisites
- A user with `cluster-admin` ClusterRole is required to install the chart.
- Kubernetes 1.9 or newer cluster with RBAC (Role-Based Access Control) enabled is required.
- Helm 2.7.2 or newer is required.
- Set environment variables for Pod IPs from the Istio control plane needed by remote cluster:
```
export PILOT_POD_IP=$(kubectl -n istio-system get pod -l istio=pilot -o jsonpath='{.items[0].status.podIP}')
export POLICY_POD_IP=$(kubectl -n istio-system get pod -l istio=mixer -o jsonpath='{.items[0].status.podIP}')
export STATSD_POD_IP=$(kubectl -n istio-system get pod -l istio=statsd-prom-bridge -o jsonpath='{.items[0].status.podIP}')
export ZIPKIN_POD_IP=$(kubectl -n istio-system get pod -l app=jaeger -o jsonpath='{.items[0].status.podIP}')
```

## Resources Required

The chart deploys pods that consume minimum resources as specified in the resources configuration parameters.

## Installing the Chart

1. Create namespace `istio-system` for the chart:
```
$ kubectl create ns istio-system
```

2. To install the chart with the release name `istio-remote` in namespace `istio-system`:
```
$ helm install ../ibm-istio-remote --name istio-remote --namespace istio-system --set global.pilotEndpoint=${PILOT_POD_IP} --set global.policyEndpoint=${POLICY_POD_IP} --set global.statsdEndpoint=${STATSD_POD_IP} --set global.zipkinEndpoint=${ZIPKIN_POD_IP}
```
**Note**:  Currently, only one instance of Istio or Istio-Remote can be installed on a cluster at a time.

## Configuration

The `istio-remote` helm chart requires the four specific variables to be configured as defined in the following table:

| Helm Variable | Accepted Values | Default | Purpose of Value |
| ------------- | --------------- | ------- | ---------------- |
| `global.pilotEndpoint` | A valid IP address | istio-pilot.istio-system | Specifies the Istio control plane's pilot Pod IP address |
| `global.policyEndpoint` | A valid IP address | istio-policy.istio-system | Specifies the Istio control plane's policy Pod IP address |
| `global.statsdEndpoint` | A valid IP address | istio-statsd-prom-bridge.istio-system | Specifies the Istio control plane's statsd Pod IP address |
| `global.zipkinEndpoint` | A valid IP address | zipkin.istio-system | Specifies the Istio control plane's zipkin Pod IP address |
| `global.imagePullPolicy` | Specifies the image pull policy | valid image pull policy | `IfNotPresent` |
| `global.kubectl.repository` | Specifies the kubectl image location | valid image repository | `ibmcom/kubectl` |
| `global.kubectl.tag` | Specifies the kubectl image version | valid image tag | `v1.10.0` |
| `global.rbacEnabled` | Specifies whether to create Istio RBAC rules or not | true/false | `true` |
| `global.imagePullSecrets` | Specifies image pull secrets for private docker registry | array consists of imagePullSecret | Empty Array |
| `global.priorityClassName` | Specifies priority class to make sure Istio pods will not be evicted because of low prioroty class | `system-cluster-critical`/`system-node-critical`/`""` | `""` |
| `global.management` | Specifies whether deploy to node with labels `management=true` | true/false | `true` |
| `global.dedicated` | Specifies whether to deploy to dedicated node with taint `dedicated=:NoSchedule` | true/false | `true` |
| `global.criticalAddonsOnly` | Specifies whether to deploy istio as a critical addon | true/false | `true` |
| `global.extraNodeSelector.key` | Specifies extra node selector key | string as key | `""` |
| `global.extraNodeSelector.value` | Specifies extra node selector value | string as value | `""` |
| `global.arch.amd64`| Architecture preference for amd64 node | `0 - Do not use`/`1 - Least preferred`/`2 - No preference`/`3 - Most preferred` | `2 - No preference` |
| `global.arch.ppc64le` | Architecture preference for ppc64le node | `0 - Do not use`/`1 - Least preferred`/`2 - No preference`/`3 - Most preferred` | `2 - No preference` |
| `security.replicaCount` | Specifies number of desired pods for Citadel | number | `1` |
| `security.image.repository` | Specifies the Citadel image location | valid image repository | `ibmcom/istio-citadel` |
| `security.image.tag` | Specifies the Citadel image version | valid image tag | `0.8.0` |
| `security.resources.limits` | CPU/Memory for resource limits | valid CPU&memory settings | Memory: `1024Mi`, CPU: `7000m` |
| `security.resources.requests` | CPU/Memory for resource requests | valid CPU&memory settings | Memory: `128Mi`, CPU: `100m` |

**Note**: If you install the Istio helm chart in another Kubernetes distribution other than IBM Cloud Private (eg. IBM Cloud Kubernetes Services), please make sure to set parameter `--set global.management=false` if there isn't any node with label `management=true`, or else you can add label `management=true` to the node that you want to run Istio via `kubectl label node <node> management=true`.

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

- The `pilotEndpoint`, `policyEndpoint`, `statsdEndpoint`, `zipkinEndpoint` endpoints need to be resolvable via Kubernetes. The simplest approach to enabling resolution for these variables is to specify the Pod IP of the various services. One problem with this is Pod IPs change during the lifetime of the service.

- Currently ICP Catalog UI doesn't support input type of `array` and `object`, customization for field `global.imagePullSecrets` should be done via helm command-line instead of ICP Catalog UI.
