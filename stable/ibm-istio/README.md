# Istio

[Istio](https://istio.io/) is an open platform for providing a uniform way to integrate microservices, manage traffic flow across microservices, enforce policies and aggregate telemetry data.

## Introduction

This chart bootstraps all istio [components](https://istio.io/docs/concepts/what-is-istio/overview.html) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Chart Details

This chart can install multiple istio components as subcharts:
- ingress
- mixer
- pilot
- security (certificate authority)
- sidecar injector
- grafana
- prometheus
- servicegraph
- zipkin

To enable or disable then change the `enabled` flag of each component.

Note: To enable or disable `security`, change `global.securityEnabled` flag.

## Prerequisites

- Kubernetes 1.7.3 or newer is required
- Helm 2.7.2 or newer or alternately the ability to modify RBAC rules is also required
- If you want to enable automatic sidecar injection, Kubernetes 1.9+ with `admissionregistration` API is required, and `kube-apiserver` process must have the `admission-control` flag set with the `MutatingAdmissionWebhook` and `ValidatingAdmissionWebhook` admission controllers added and listed in the correct order.

## Resources Required

The chart deploys pods that consume minimum resources as specified in the resources configuration parameter.

## Installing the Chart

To install the chart with the release name `istio` in namespace `istio-system`:
```
$ kubectl create namespace istio-system
$ helm install istio --name istio --namespace=istio-system
```
The command deploys `Istio` on the Kubernetes cluster in the default configuration. The configuration section lists the components that can be configured during installation.

## Configuration

The following table lists the configurable parameters of the ibm-istio chart and their default values.

| Parameter                                        | Description                                     | Default                                        |
| ------------------------------------------------ | ----------------------------------------------- | ---------------------------------------------- |
| `global.proxy.repository`                        | Proxy image repository                          | `ibmcom/istio-proxy`                           |
| `global.proxy.tag`                               | Proxy image tag                                 | `0.7.1`                                        |
| `global.proxy.imagePullPolicy`                   | Proxy Image pull policy                         | `IfNotPresent`                                 |
| `global.proxyInit.repository`                    | Proxy_init image repository                     | `ibmcom/istio-proxy_init`                      |
| `global.proxyInit.tag`                           | Proxy_init image tag                            | `0.7.1`                                        |
| `global.proxyInit.imagePullPolicy`               | Proxy_init Image pull policy                    | `IfNotPresent`                                 |
| `global.kubectl.repository`                      | Kubectl image repository                        | `ibmcom/istio-kubectl`                         |
| `global.kubectl.tag`                             | Kubectl image tag                               | `v1.10.0`                                      |
| `global.kubectl.imagePullPolicy`                 | Kubectl Image pull policy                       | `IfNotPresent`                                 |
| `global.securityEnabled`                         | Enable Control Plane Mtls                       | `true`                                         |
| `global.mtls.enabled`                            | Enable mutual TLS authentication                | `true`                                         |
| `global.rbacEnabled`                             | Enable RBAC                                     | `true`                                         |
| `global.imagePullSecrets`                        | Image pull secrets for private docker registry  | Empty Array                                    |
| `global.refreshInterval`                         | Refresh interval                                | `10s`                                          |
| `ingress.enabled`                                | Enable ingress                                  | `true`                                         |
| `ingress.serviceAccountName`                     | Service account name used if disable RBAC       | `default`                                      |
| `ingress.autoscaleMin`                           | The min for auto scaler                         | `2`                                            |
| `ingress.autoscaleMax`                           | The max for auto scaler                         | `8`                                            |
| `ingress.resources.limits`                       | CPU/Memory for Ingress resource limits          | Memory: `128Mi`, CPU: `100m`                   |
| `ingress.resources.requests`                     | CPU/Memory for Ingress resource requests        | Memory: `128Mi`, CPU: `100m`                   |
| `ingress.service.nodePort.enabled`               | Enable Service NodePort for Ingress             | `false`                                        |
| `ingress.service.nodePort.port`                  | Service NodePort for Ingress                    | `32000`                                        |
| `ingress.management`                             | Whether to deploy to management node            | `true`                                         |
| `ingress.dedicated`                              | Whether to deploy to dedicated node             | `true`                                         |
| `ingress.criticalAddonsOnly`                     | Whether to only permit critical addons          | `true`                                         |
| `ingress.arch.amd64`                             | Architecture preference for amd64 worker node   | `2 - No preference`                            |
| `ingress.arch.ppc64le`                           | Architecture preference for ppc64le worker node | `2 - No preference`                            |
| `ingress.arch.s390x`                             | Architecture preference for s390x worker node   | `2 - No preference`                            |
| `sidecar-injector.enabled`                       | Enable sidecar-injector                         | `false`                                        |
| `sidecar-injector.serviceAccountName`            | Service account name used if disable RBAC       | `default`                                      |
| `sidecar-injector.replicaCount`                  | Replica count for sidecar-injector              | `1`                                            |
| `sidecar-injector.image.repository`              | Sidecar-injector image repository               | `ibmcom/istio-sidecar_injector`                |
| `sidecar-injector.image.tag`                     | Sidecar-injector image tag                      | `0.7.1`                                        |
| `sidecar-injector.image.imagePullPolicy`         | Sidecar-injector Image pull policy              | `IfNotPresent`                                 |
| `sidecar-injector.resources.limits`              | CPU/Memory for resource limits                  | Memory: `128Mi`, CPU: `100m`                   |
| `sidecar-injector.resources.requests`            | CPU/Memory for resource requests                | Memory: `128Mi`, CPU: `100m`                   |
| `sidecar-injector.management`                    | Whether to deploy to management node            | `true`                                         |
| `sidecar-injector.dedicated`                     | Whether to deploy to dedicated node             | `true`                                         |
| `sidecar-injector.criticalAddonsOnly`            | Whether to only permit critical addons          | `true`                                         |
| `sidecar-injector.arch.amd64`                    | Architecture preference for amd64 worker node   | `2 - No preference`                            |
| `sidecar-injector.arch.ppc64le`                  | Architecture preference for ppc64le worker node | `2 - No preference`                            |
| `sidecar-injector.arch.s390x`                    | Architecture preference for s390x worker node   | `2 - No preference`                            |
| `sidecar-injector.includeIPRanges`               | Istio egress capture whitelist                  | Empty string                                   |
| `mixer.enabled`                                  | Enable mixer                                    | `true`                                         |
| `mixer.serviceAccountName`                       | Service account name used if disable RBAC       | `default`                                      |
| `mixer.replicaCount`                             | Replica count for mixer                         | `1`                                            |
| `mixer.image.repository`                         | Mixer image repository                          | `ibmcom/istio-mixer`                           |
| `mixer.image.tag`                                | Mixer image tag                                 | `0.7.1`                                        |
| `mixer.image.imagePullPolicy`                    | Mixer Image pull policy                         | `IfNotPresent`                                 |
| `mixer.resources.limits`                         | CPU/Memory for resource limits                  | Memory: `128Mi`, CPU: `100m`                   |
| `mixer.resources.requests`                       | CPU/Memory for resource requests                | Memory: `128Mi`, CPU: `100m`                   |
| `mixer.management`                               | Whether to deploy to management node            | `true`                                         |
| `mixer.dedicated`                                | Whether to deploy to dedicated node             | `true`                                         |
| `mixer.criticalAddonsOnly`                       | Whether to only permit critical addons          | `true`                                         |
| `mixer.arch.amd64`                               | Architecture preference for amd64 worker node   | `2 - No preference`                            |
| `mixer.arch.ppc64le`                             | Architecture preference for ppc64le worker node | `2 - No preference`                            |
| `mixer.arch.s390x`                               | Architecture preference for s390x worker node   | `2 - No preference`                            |
| `mixer.prometheusStatsdExporter.repository`      | Prometheus Statsd Exporter image repository     | `ibmcom/prom-statsd-exporter`                  |
| `mixer.prometheusStatsdExporter.tag`             | Prometheus Statsd Exporter image tag            | `v0.5.0`                                       |
| `mixer.prometheusStatsdExporter.imagePullPolicy` | Prometheus Statsd Exporter image pull policy    | `IfNotPresent`                                 |
| `mixer.prometheusStatsdExporter.resources`       | CPU/Memory for resource requests/limits         | Memory: `128Mi`, CPU: `100m`                   |
| `pilot.enabled`                                  | Enable pilot                                    | `true`                                         |
| `pilot.serviceAccountName`                       | Service account name used if disable RBAC       | `default`                                      |
| `pilot.replicaCount`                             | Replica count for pilot                         | `1`                                            |
| `pilot.image.repository`                         | Pilot image repository                          | `ibmcom/istio-pilot`                           |
| `pilot.image.tag`                                | Pilot image tag                                 | `0.7.1`                                        |
| `pilot.image.imagePullPolicy`                    | Pilot Image pull policy                         | `IfNotPresent`                                 |
| `pilot.resources.limits`                         | CPU/Memory for resource limits                  | Memory: `128Mi`, CPU: `100m`                   |
| `pilot.resources.requests`                       | CPU/Memory for resource requests                | Memory: `128Mi`, CPU: `100m`                   |
| `pilot.management`                               | Whether to deploy to management node            | `true`                                         |
| `pilot.management`                               | Whether to deploy to management node            | `true`                                         |
| `pilot.dedicated`                                | Whether to deploy to dedicated node             | `true`                                         |
| `pilot.criticalAddonsOnly`                       | Whether to only permit critical addons          | `true`                                         |
| `pilot.arch.amd64`                               | Architecture preference for amd64 worker node   | `2 - No preference`                            |
| `pilot.arch.ppc64le`                             | Architecture preference for ppc64le worker node | `2 - No preference`                            |
| `pilot.arch.s390x`                               | Architecture preference for s390x worker node   | `2 - No preference`                            |
| `security.serviceAccountName`                    | Service account name used if disable RBAC       | `default`                                      |
| `security.replicaCount`                          | Replica count for istio-ca                      | `1`                                            |
| `security.image.repository`                      | Istio-ca image repository                       | `ibmcom/istio-ca`                              |
| `security.image.tag`                             | Istio-ca image tag                              | `0.7.1`                                        |
| `security.image.imagePullPolicy`                 | Istio-ca Image pull policy                      | `IfNotPresent`                                 |
| `security.resources.limits`                      | CPU/Memory for resource limits                  | Memory: `128Mi`, CPU: `100m`                   |
| `security.resources.requests`                    | CPU/Memory for resource requests                | Memory: `128Mi`, CPU: `100m`                   |
| `security.management`                            | Whether to deploy to management node            | `true`                                         |
| `security.dedicated`                             | Whether to deploy to dedicated node             | `true`                                         |
| `security.criticalAddonsOnly`                    | Whether to only permit critical addons          | `true`                                         |
| `security.arch.amd64`                            | Architecture preference for amd64 worker node   | `2 - No preference`                            |
| `security.arch.ppc64le`                          | Architecture preference for ppc64le worker node | `2 - No preference`                            |
| `security.arch.s390x`                            | Architecture preference for s390x worker node   | `2 - No preference`                            |
| `grafana.enabled`                                | Enable grafana                                  | `false`                                        |
| `grafana.replicaCount`                           | Replica count for grafana                       | `1`                                            |
| `grafana.image.repository`                       | Grafana image repository                        | `ibmcom/istio-grafana`                         |
| `grafana.image.tag`                              | Grafana image tag                               | `0.7.1`                                        |
| `grafana.image.imagePullPolicy`                  | Grafana Image pull policy                       | `IfNotPresent`                                 |
| `grafana.service.name`                           | Grafana service name                            | `http`                                         |
| `grafana.service.type`                           | Grafana service type                            | `ClusterIP`                                    |
| `grafana.service.externalPort`                   | Grafana service external port                   | `3000`                                         |
| `grafana.service.internalPort`                   | Grafana service internal port                   | `3000`                                         |
| `grafana.ingress.enabled`                        | Enable ingress for grafana                      | `false`                                        |
| `grafana.ingress.hosts`                          | Ingress host to create an record                | `{"grafana.local"}`                            |
| `grafana.ingress.annotations`                    | Ingress annotations for grafana                 | Empty                                          |
| `grafana.ingress.tls`                            | Ingress TLS for grafana                         | Empty                                          |
| `grafana.resources.limits`                       | CPU/Memory for resource limits                  | Memory: `128Mi`, CPU: `100m`                   |
| `grafana.resources.requests`                     | CPU/Memory for resource requests                | Memory: `128Mi`, CPU: `100m`                   |
| `grafana.management`                             | Whether to deploy to management node            | `true`                                         |
| `grafana.dedicated`                              | Whether to deploy to dedicated node             | `true`                                         |
| `grafana.criticalAddonsOnly`                     | Whether to only permit critical addons          | `true`                                         |
| `grafana.arch.amd64`                             | Architecture preference for amd64 worker node   | `2 - No preference`                            |
| `grafana.arch.ppc64le`                           | Architecture preference for ppc64le worker node | `2 - No preference`                            |
| `grafana.arch.s390x`                             | Architecture preference for s390x worker node   | `2 - No preference`                            |
| `prometheus.enabled`                             | Enable prometheus                               | `false`                                        |
| `prometheus.replicaCount`                        | Replica count for prometheus                    | `1`                                            |
| `prometheus.image.repository`                    | Prometheus image repository                     | `ibmcom/prometheus`                            |
| `prometheus.image.tag`                           | Prometheus image tag                            | `v2.0.0`                                       |
| `prometheus.image.imagePullPolicy`               | Prometheus Image pull policy                    | `IfNotPresent`                                 |
| `prometheus.service.nodePort.enabled`            | Enable Service NodePort for prometheus          | `false`                                        |
| `prometheus.service.nodePort.port`               | Service NodePort for prometheus                 | `32090`                                        |
| `prometheus.ingress.enabled`                     | Enable ingress for prometheus                   | `false`                                        |
| `prometheus.ingress.hosts`                       | Ingress host to create an record                | `{"prometheus.local"}`                         |
| `prometheus.ingress.annotations`                 | Ingress annotations for prometheus              | Empty                                          |
| `prometheus.ingress.tls`                         | Ingress TLS for prometheus                      | Empty                                          |
| `prometheus.resources.limits`                    | CPU/Memory for resource requests/limits         | Memory: `1024Mi`, CPU: `100m`                   |
| `prometheus.resources.requests`                  | CPU/Memory for resource requests/limits         | Memory: `256Mi`, CPU: `100m`                   |
| `prometheus.management`                          | Whether to deploy to management node            | `true`                                         |
| `prometheus.dedicated`                           | Whether to deploy to dedicated node             | `true`                                         |
| `prometheus.criticalAddonsOnly`                  | Whether to only permit critical addons          | `true`                                         |
| `prometheus.arch.amd64`                          | Architecture preference for amd64 worker node   | `2 - No preference`                            |
| `prometheus.arch.ppc64le`                        | Architecture preference for ppc64le worker node | `2 - No preference`                            |
| `prometheus.arch.s390x`                          | Architecture preference for s390x worker node   | `2 - No preference`                            |
| `servicegraph.enabled`                           | Enable servicegraph                             | `false`                                        |
| `servicegraph.replicaCount`                      | Replica count for servicegraph                  | `1`                                            |
| `servicegraph.image.repository`                  | Servicegraph image repository                   | `ibmcom/istio-servicegraph`                    |
| `servicegraph.image.tag`                         | Servicegraph image tag                          | `0.7.1`                                        |
| `servicegraph.image.imagePullPolicy`             | Servicegraph Image pull policy                  | `IfNotPresent`                                 |
| `servicegraph.service.name`                      | Servicegraph service name                       | `http`                                         |
| `servicegraph.service.type`                      | Servicegraph service type                       | `ClusterIP`                                    |
| `servicegraph.service.externalPort`              | Servicegraph service external port              | `8088`                                         |
| `servicegraph.service.internalPort`              | Servicegraph service internal port              | `8088`                                         |
| `servicegraph.ingress.enabled`                   | Enable ingress for servicegraph                 | `false`                                        |
| `servicegraph.ingress.hosts`                     | Ingress host to create an record                | `{"servicegraph.local"}`                       |
| `servicegraph.ingress.annotations`               | Ingress annotations for servicegraph            | Empty                                          |
| `servicegraph.ingress.tls`                       | Ingress TLS for servicegraph                    | Empty                                          |
| `servicegraph.resources.limits`                  | CPU/Memory for resource limits                  | Memory: `128Mi`, CPU: `100m`                   |
| `servicegraph.resources.requests`                | CPU/Memory for resource requests                | Memory: `128Mi`, CPU: `100m`                   |
| `servicegraph.management`                        | Whether to deploy to management node            | `true`                                         |
| `servicegraph.dedicated`                         | Whether to deploy to dedicated node             | `true`                                         |
| `servicegraph.criticalAddonsOnly`                | Whether to only permit critical addons          | `true`                                         |
| `servicegraph.arch.amd64`                        | Architecture preference for amd64 worker node   | `2 - No preference`                            |
| `servicegraph.arch.ppc64le`                      | Architecture preference for ppc64le worker node | `2 - No preference`                            |
| `servicegraph.arch.s390x`                        | Architecture preference for s390x worker node   | `2 - No preference`                            |
| `zipkin.enabled`                                 | Enable zipkin                                   | `false`                                        |
| `zipkin.replicaCount`                            | Replica count for zipkin                        | `1`                                            |
| `zipkin.image.repository`                        | zipkin image repository                         | `ibmcom/zipkin`                                |
| `zipkin.image.tag`                               | zipkin image tag                                | `2.6.0`                                        |
| `zipkin.image.imagePullPolicy`                   | zipkin Image pull policy                        | `IfNotPresent`                                 |
| `zipkin.service.name`                            | zipkin service name                             | `http`                                         |
| `zipkin.service.type`                            | zipkin service type                             | `ClusterIP`                                    |
| `zipkin.service.externalPort`                    | zipkin service external port                    | `9411`                                         |
| `zipkin.service.internalPort`                    | zipkin service internal port                    | `9411`                                         |
| `zipkin.ingress.enabled`                         | Enable ingress for zipkin                       | `false`                                        |
| `zipkin.ingress.hosts`                           | Ingress host to create an record                | `{"zipkin.local"}`                             |
| `zipkin.ingress.annotations`                     | Ingress annotations for zipkin                  | Empty                                          |
| `zipkin.ingress.tls`                             | Ingress TLS for zipkin                          | Empty                                          |
| `zipkin.resources.limits`                        | CPU/Memory for resource limits                  | Memory: `1024Mi`, CPU: `2000m`                 |
| `zipkin.resources.requests`                      | CPU/Memory for resource requests                | Memory: `512Mi`, CPU: `100m`                   |
| `zipkin.management`                              | Whether to deploy to management node            | `true`                                         |
| `zipkin.dedicated`                               | Whether to deploy to dedicated node             | `true`                                         |
| `zipkin.criticalAddonsOnly`                      | Whether to only permit critical addons          | `true`                                         |
| `zipkin.arch.amd64`                              | Architecture preference for amd64 worker node   | `2 - No preference`                            |
| `zipkin.arch.ppc64le`                            | Architecture preference for ppc64le worker node | `2 - No preference`                            |
| `zipkin.arch.s390x`                              | Architecture preference for s390x worker node   | `2 - No preference`                            |

## Enable automatic sidecar injection

Automatic sidecar injection requires Kubernetes 1.9 or later. Verify that the `kube-apiserver` process has the `admission-control` flag set with the `MutatingAdmissionWebhook` and `ValidatingAdmissionWebhook` admission controllers added and listed in the correct order and the `admissionregistration` API is enabled:
```
$ kubectl api-versions | grep admissionregistration
admissionregistration.k8s.io/v1alpha1
admissionregistration.k8s.io/v1beta1
```

If all prerequisites are fully met, install the istio chart by setting parameter `sidecar-injector.enabled` to true:
```
$ helm install istio --name istio --namespace=istio-system --set sidecar-injector.enabled=true
```

The `sidecar injector` pod should now be running after the chart is deployed:
```
$ kubectl -n istio-system get deployment -listio=sidecar-injector
NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
istio-sidecar-injector   1         1         1            1           1m
```

The `sidecar injector` depends on [namespaceSelector](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) to decide whether to inject sidecar to application object based on whether the namespace for that application object matches the selector. The default `namespaceSelector` is `istio-injection=enabled`.

Label namespace that application object will be deployed to by command (take `default` namesapce as example):
```
$ kubectl label namespace default istio-injection=enabled
$ kubectl get namespace -L istio-injection
NAME           STATUS    AGE       ISTIO-INJECTION
default        Active    1h        enabled
istio-system   Active    1h        
kube-public    Active    1h        
kube-system    Active    1h
```

Finally you can deploy the application directly using `kubectl create` to `default` namespace.

In some cases, you may want to skip auto-injection for specified pods, to achieve this, add annotation `sidecar.istio.io/inject: "false"` to pod template.

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

Note: Some resources are left behind after the chart is deleted, these resources aren't created by the chart during installation, instead they are created by the containers running in the chart. We have an issue to track this: https://github.com/istio/istio/issues/5380 Fortunely, the existence of these resources will not prevent a second installation of the chart. If you want to completely purge all Istio related resources, you have to manually clean up them.

## Limitations

Currently you may encounter an issue of **TIMEOUT** when install the chart from ICP UI, that's because the chart contains several hooks which take time longer than the timeout setting of 30 seconds for `Helm` api of ICP UI. Actually the chart can be deployed successfully by the `Tiller`, so please ignore the **TIMEOUT** message and verify the chart has been released from **Workloads** -> **Helm Releases** page.

Because `Istio` injects sidecar container into applications that requires a) run privileged containers and b) add Linux capability — referred to as NET_ADMIN, need to create extra `PodSecurityPolicy` for namespace in which appications are deployed. See https://medium.com/ibm-cloud/deploy-istio-enabled-application-on-ibm-cloud-private-in-a-non-default-namespace-e44f897ce228


## Documentation

[Working with Istio](https://www-03preprod.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/manage_cluster/istio.html)
