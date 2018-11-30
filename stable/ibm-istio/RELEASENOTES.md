# What's new in Chart Version 1.0.4

This release addresses some critical issues found by the community when using Istio 1.0.0.

**NOTE:** This helm chart is using [Istio 1.0.2 release](https://github.com/istio/istio/releases/tag/1.0.2).

# Fixes

- Fixed bug in Envoy where the sidecar would crash if receiving normal traffic on the mutual TLS port.

- Fixed bug with Pilot propagating incomplete updates to Envoy in a multicluster environment.

- Added a few more Helm options for Grafana.

- Improved Kubernetes service registry queue performance.

- Fixed bug where `istioctl` `proxy-status` was not showing the patch version.

- Add validation of virtual service SNI hosts.

# Prerequisites

* Kubernetes 1.9 or newer with [RBAC (Role-Based Access Control)](https://kubernetes.io/docs/admin/authorization/rbac/) enabled
  If you wish to enable [automatic sidecar injection](https://istio.io/docs/setup/kubernetes/sidecar-injection/#automatic-sidecar-injection), you must use Kubernetes version 1.9 or greater and the kube-apiserver process has the `admission-control` flag set with the `MutatingAdmissionWebhook` and `ValidatingAdmissionWebhook` admission controllers added and listed in the correct order and the admissionregistration API is enabled.
  ```
  $ kubectl api-versions | grep admissionregistration
  admissionregistration.k8s.io/v1alpha1
  admissionregistration.k8s.io/v1beta1
  ```

# Version History

| Chart Version | Community Chart Version | Date | Kubernetes Version Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ----- | ---- | --------------------------- | ------------------ | ---------------- | ------- |
| 1.0.4 | 1.0.2 | Nov 12, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.2</li><li>ibmcom/istio-proxy_init:1.0.2</li><li>ibmcom/kubectl:v1.11.3</li><li>ibmcom/istio-grafana:1.0.2</li><li>ibmcom/istio-citadel:1.0.2</li><li>ibmcom/istio-galley:1.0.2</li><li>ibmcom/istio-mixer:1.0.2</li><li>ibmcom/istio-servicegraph:1.0.2</li><li>ibmcom/istio-pilot:1.0.2</li><li>ibmcom/istio-sidecar_injector:1.0.2</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/kiali:istio-release-1.0</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | new features and architectural improvement |
| 1.0.3 | 1.0.0 | Aug 22, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.0</li><li>ibmcom/istio-proxy_init:1.0.0</li><li>ibmcom/kubectl:v1.11.1</li><li>ibmcom/istio-grafana:1.0.0</li><li>ibmcom/istio-citadel:1.0.0</li><li>ibmcom/istio-galley:1.0.0</li><li>ibmcom/istio-mixer:1.0.0</li><li>ibmcom/istio-servicegraph:1.0.0</li><li>ibmcom/istio-pilot:1.0.0</li><li>ibmcom/istio-sidecar_injector:1.0.0</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/istio-release-1.0</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | new features and architectural improvement |
| 1.0.2 | 1.0.0 | Aug 13, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.0</li><li>ibmcom/istio-proxy_init:1.0.0</li><li>ibmcom/kubectl:v1.10.0</li><li>ibmcom/istio-grafana:1.0.0</li><li>ibmcom/istio-citadel:1.0.0</li><li>ibmcom/istio-galley:1.0.0</li><li>ibmcom/istio-mixer:1.0.0</li><li>ibmcom/istio-servicegraph:1.0.0</li><li>ibmcom/istio-pilot:1.0.0</li><li>ibmcom/istio-sidecar_injector:1.0.0</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/kiali:v0.5.0</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | new architectural support |
| 1.0.1 | 1.0.0 | Aug 3, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.0</li><li>ibmcom/istio-proxy_init:1.0.0</li><li>ibmcom/kubectl:v1.10.0</li><li>ibmcom/istio-grafana:1.0.0</li><li>ibmcom/istio-citadel:1.0.0</li><li>ibmcom/istio-galley:1.0.0</li><li>ibmcom/istio-mixer:1.0.0</li><li>ibmcom/istio-servicegraph:1.0.0</li><li>ibmcom/istio-pilot:1.0.0</li><li>ibmcom/istio-sidecar_injector:1.0.0</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/kiali:v0.5.0</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | new features and architectural improvement |
| 1.0.0 | 1.0.0 | July 31, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.0</li><li>ibmcom/istio-proxy_init:1.0.0</li><li>ibmcom/kubectl:v1.10.0</li><li>ibmcom/istio-grafana:1.0.0</li><li>ibmcom/istio-citadel:1.0.0</li><li>ibmcom/istio-galley:1.0.0</li><li>ibmcom/istio-mixer:1.0.0</li><li>ibmcom/istio-servicegraph:1.0.0</li><li>ibmcom/istio-pilot:1.0.0</li><li>ibmcom/istio-sidecar_injector:1.0.0</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/kiali:v0.5.0</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | new features and architectural improvement |
| 0.8.0 | 0.8.0 | June 1, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxy:0.8.0</li><li>ibmcom/istio-proxyv2:0.8.0</li><li>ibmcom/istio-proxy_init:0.8.0</li><li>ibmcom/kubectl:v1.10.0</li><li>ibmcom/istio-grafana:0.8.0</li><li>ibmcom/istio-citadel:0.8.0</li><li>ibmcom/istio-mixer:0.8.0</li><li>ibmcom/istio-servicegraph:0.8.0</li><li>ibmcom/istio-pilot:0.8.0</li><li>ibmcom/istio-sidecar_injector:0.8.0 </li><li>ibmcom/prom-statsd-exporter:v0.5.0</li><li>ibmcom/prometheus:v2.0.0</li><li>ibmcom/jaegertracing-all-in-one:1.5</li></ul> | None | new features and architectural improvement |
| 0.7.1 | 0.7.1 | Apr 27, 2018| >=1.7.3 | <ul><li>ibmcom/istio-proxy:0.7.1</li><li>ibmcom/istio-proxy_init:0.7.1</li><li>ibmcom/istio-kubectl:v1.10.0</li><li>ibmcom/istio-grafana:0.7.1</li><li>ibmcom/istio-ca:0.7.1</li><li>ibmcom/istio-mixer:0.7.1</li><li>ibmcom/istio-servicegraph:0.7.1</li><li>ibmcom/istio-pilot:0.7.1</li><li>ibmcom/istio-sidecar_injector:0.7.1 </li><li>ibmcom/prom-statsd-exporter:v0.5.0</li><li>ibmcom/prometheus:v2.0.0</li><li>ibmcom/zipkin:2.6.0</li></ul> | None | Tech Preview |
