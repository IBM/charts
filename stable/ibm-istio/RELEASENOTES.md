# What's new in Chart Version 1.0.6

This release addresses some critical vulnerability issues found by the community when using Istio 1.0.2.

**NOTE:** This helm chart is using [Istio 1.0.2 release](https://github.com/istio/istio/releases/tag/1.0.2).

# Fixes

- Remediated vulnerability issues in kubectl: CVE-2018-16839 CVE-2018-16840 CVE-2018-16842 CVE-2018-0734 CVE-2018-5407

- Remediated vulnerability issues in istio-proxyv2: CVE-2018-16839 CVE-2018-16840 CVE-2018-16842 CVE-2018-0734 CVE-2018-0735 CVE-2018-5407 CVE-2018-15686 CVE-2018-15687 CVE-2018-15688 CVE-2018-6954 CVE-2018-1000030 CVE-2018-1000802 CVE-2018-1060 CVE-2018-1061 CVE-2018-14647

- Remediated vulnerability issues in istio-proxy_init: CVE-2018-16839 CVE-2018-16840 CVE-2018-16842 CVE-2018-0734 CVE-2018-0735 CVE-2018-5407 CVE-2018-15686 CVE-2018-15687 CVE-2018-15688 CVE-2018-6954

- Remediated vulnerability issues in istio-pilot: CVE-2018-16839 CVE-2018-16840 CVE-2018-16842 CVE-2018-0734 CVE-2018-0735 CVE-2018-5407 CVE-2018-1000030 CVE-2018-1000802 CVE-2018-1060 CVE-2018-1061 CVE-2018-14647 CVE-2018-15686 CVE-2018-15687 CVE-2018-15688 CVE-2018-6954

- Remediated vulnerability issues in istio-grafana: CVE-2018-0732 CVE-2018-0734 CVE-2018-0735 CVE-2018-0737 CVE-2018-5407 CVE-2018-16839 CVE-2018-16842

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
| 1.0.6 | 1.0.2 | May 20, 2019| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.2.3</li><li>ibmcom/istio-proxy_init:1.0.2.2</li><li>ibmcom/kubectl:v1.13.5</li><li>ibmcom/istio-grafana:1.0.2.2</li><li>ibmcom/istio-citadel:1.0.2</li><li>ibmcom/istio-galley:1.0.2</li><li>ibmcom/istio-mixer:1.0.2</li><li>ibmcom/istio-servicegraph:1.0.2</li><li>ibmcom/istio-pilot:1.0.2.2</li><li>ibmcom/istio-sidecar_injector:1.0.2</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.8.0</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/kiali:v0.8.0.1</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | addresses critical vulnerability issues |
| 1.0.5 | 1.0.2 | Jan 12, 2019| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.2.1</li><li>ibmcom/istio-proxy_init:1.0.2.1</li><li>ibmcom/kubectl:v1.12.4</li><li>ibmcom/istio-grafana:1.0.2.1</li><li>ibmcom/istio-citadel:1.0.2</li><li>ibmcom/istio-galley:1.0.2</li><li>ibmcom/istio-mixer:1.0.2</li><li>ibmcom/istio-servicegraph:1.0.2</li><li>ibmcom/istio-pilot:1.0.2.1</li><li>ibmcom/istio-sidecar_injector:1.0.2</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1-f2</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/kiali:v0.8.0.1</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | addresses critical vulnerability issues |
| 1.0.4 | 1.0.2 | Nov 12, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.2</li><li>ibmcom/istio-proxy_init:1.0.2</li><li>ibmcom/kubectl:v1.11.3</li><li>ibmcom/istio-grafana:1.0.2</li><li>ibmcom/istio-citadel:1.0.2</li><li>ibmcom/istio-galley:1.0.2</li><li>ibmcom/istio-mixer:1.0.2</li><li>ibmcom/istio-servicegraph:1.0.2</li><li>ibmcom/istio-pilot:1.0.2</li><li>ibmcom/istio-sidecar_injector:1.0.2</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/kiali:v0.8</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | new features and architectural improvement |
| 1.0.3 | 1.0.0 | Aug 22, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.0</li><li>ibmcom/istio-proxy_init:1.0.0</li><li>ibmcom/kubectl:v1.11.1</li><li>ibmcom/istio-grafana:1.0.0</li><li>ibmcom/istio-citadel:1.0.0</li><li>ibmcom/istio-galley:1.0.0</li><li>ibmcom/istio-mixer:1.0.0</li><li>ibmcom/istio-servicegraph:1.0.0</li><li>ibmcom/istio-pilot:1.0.0</li><li>ibmcom/istio-sidecar_injector:1.0.0</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/istio-release-1.0</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | new features and architectural improvement |
| 1.0.2 | 1.0.0 | Aug 13, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.0</li><li>ibmcom/istio-proxy_init:1.0.0</li><li>ibmcom/kubectl:v1.10.0</li><li>ibmcom/istio-grafana:1.0.0</li><li>ibmcom/istio-citadel:1.0.0</li><li>ibmcom/istio-galley:1.0.0</li><li>ibmcom/istio-mixer:1.0.0</li><li>ibmcom/istio-servicegraph:1.0.0</li><li>ibmcom/istio-pilot:1.0.0</li><li>ibmcom/istio-sidecar_injector:1.0.0</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/kiali:v0.5.0</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | new architectural support |
| 1.0.1 | 1.0.0 | Aug 3, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.0</li><li>ibmcom/istio-proxy_init:1.0.0</li><li>ibmcom/kubectl:v1.10.0</li><li>ibmcom/istio-grafana:1.0.0</li><li>ibmcom/istio-citadel:1.0.0</li><li>ibmcom/istio-galley:1.0.0</li><li>ibmcom/istio-mixer:1.0.0</li><li>ibmcom/istio-servicegraph:1.0.0</li><li>ibmcom/istio-pilot:1.0.0</li><li>ibmcom/istio-sidecar_injector:1.0.0</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/kiali:v0.5.0</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | new features and architectural improvement |
| 1.0.0 | 1.0.0 | July 31, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxyv2:1.0.0</li><li>ibmcom/istio-proxy_init:1.0.0</li><li>ibmcom/kubectl:v1.10.0</li><li>ibmcom/istio-grafana:1.0.0</li><li>ibmcom/istio-citadel:1.0.0</li><li>ibmcom/istio-galley:1.0.0</li><li>ibmcom/istio-mixer:1.0.0</li><li>ibmcom/istio-servicegraph:1.0.0</li><li>ibmcom/istio-pilot:1.0.0</li><li>ibmcom/istio-sidecar_injector:1.0.0</li><li>ibmcom/prom-statsd-exporter:v0.6.0</li><li>ibmcom/prometheus:v2.3.1</li><li>ibmcom/jaegertracing-all-in-one:1.5</li><li>ibmcom/kiali:v0.5.0</li><li>ibmcom/cert-manager:v0.3.1</li></ul> | None | new features and architectural improvement |
| 0.8.0 | 0.8.0 | June 1, 2018| >= 1.9  | <ul><li>ibmcom/istio-proxy:0.8.0</li><li>ibmcom/istio-proxyv2:0.8.0</li><li>ibmcom/istio-proxy_init:0.8.0</li><li>ibmcom/kubectl:v1.10.0</li><li>ibmcom/istio-grafana:0.8.0</li><li>ibmcom/istio-citadel:0.8.0</li><li>ibmcom/istio-mixer:0.8.0</li><li>ibmcom/istio-servicegraph:0.8.0</li><li>ibmcom/istio-pilot:0.8.0</li><li>ibmcom/istio-sidecar_injector:0.8.0 </li><li>ibmcom/prom-statsd-exporter:v0.5.0</li><li>ibmcom/prometheus:v2.0.0</li><li>ibmcom/jaegertracing-all-in-one:1.5</li></ul> | None | new features and architectural improvement |
| 0.7.1 | 0.7.1 | Apr 27, 2018| >=1.7.3 | <ul><li>ibmcom/istio-proxy:0.7.1</li><li>ibmcom/istio-proxy_init:0.7.1</li><li>ibmcom/istio-kubectl:v1.10.0</li><li>ibmcom/istio-grafana:0.7.1</li><li>ibmcom/istio-ca:0.7.1</li><li>ibmcom/istio-mixer:0.7.1</li><li>ibmcom/istio-servicegraph:0.7.1</li><li>ibmcom/istio-pilot:0.7.1</li><li>ibmcom/istio-sidecar_injector:0.7.1 </li><li>ibmcom/prom-statsd-exporter:v0.5.0</li><li>ibmcom/prometheus:v2.0.0</li><li>ibmcom/zipkin:2.6.0</li></ul> | None | Tech Preview |
