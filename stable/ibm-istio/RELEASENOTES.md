# What's new in Chart Version 1.0.3

We’re proud to release Istio 1.0! Istio has been in development for nearly two years, and the 1.0 release represents a substantial milestone for us. All of our [core features](https://istio.io/about/feature-stages/) are now ready for production use.

These release notes describe what’s different between Istio 0.8 and Istio 1.0. Istio 1.0 only has a few new features relative to 0.8 as most of the effort for this release went into fixing bugs and improving performance.

## Networking

- **SNI Routing using Virtual Services.** Newly introduced `TLS` sections in [VirtualService](https://istio.io/docs/reference/config/istio.networking.v1alpha3/#VirtualService) can be used to route TLS traffic based on SNI values. Service ports named as TLS/HTTPS can be used in conjunction with virtual service TLS routes. TLS/HTTPS ports without an accompanying virtual service will be treated as opaque TCP.
- **Streaming gRPC Restored.** Istio 0.8 caused periodic termination of long running streaming gRPC connections. This has been fixed in 1.0.
- **Old (v1alpha1) Networking APIs Removed.** Support for the old `v1alpha1` traffic management model has been removed.
- **Istio Ingress Deprecated.** The old Istio ingress is deprecated and disabled by default. We encourage users to use [gateways](https://istio.io/docs/concepts/traffic-management/#gateways) instead.

## Policy and Telemetry

- **Updated Attributes.** The set of [attributes](https://istio.io/docs/reference/config/policy-and-telemetry/attribute-vocabulary/) used to describe the source and destination of traffic have been completely revamped in order to be more precise and comprehensive.
- **Policy Check Cache.** Mixer now features a large level 2 cache for policy checks, complementing the level 1 cache present in the sidecar proxy. This further reduces the average latency of externally-enforced policy checks.
- **Telemetry Buffering.** Mixer now buffers report calls before dispatching to adapters, which gives an opportunity for adapters to process telemetry data in bigger chunks, reducing overall computational overhead in Mixer and its adapters.
- **Out of Process Adapters.** Mixer now includes initial support for out-of-process adapters. This will be the recommended approach moving forward for integrating with Mixer. Initial documentation on how to build an out-of-process adapter is provided by the [Out Of Process gRPC Adapter Dev Guide](https://github.com/istio/istio/wiki/Out-Of-Process-gRPC-Adapter-Dev-Guide) and the [gRPC Adapter Walk-through](https://github.com/istio/istio/wiki/gRPC-Adapter-Walkthrough).
- **Client-Side Telemetry.** It’s now possible to collect telemetry from the client of an interaction, in addition to the server-side telemetry.

## Adapters

- **SignalFX.** There is a new [signalfx](https://istio.io/docs/reference/config/policy-and-telemetry/adapters/signalfx/) adapter.
- **Stackdriver.** The [stackdriver](https://istio.io/docs/reference/config/policy-and-telemetry/adapters/stackdriver/) adapter has been substantially enhanced in this release to add new features and improve performance.

## Security

- **Authorization.** We’ve reimplemented our [authorization functionality](https://istio.io/docs/concepts/security/#authorization). RPC-level authorization policies can now be implemented without the need for Mixer and Mixer adapters.
- **Improved Mutual TLS Authentication Control.** It’s now easier to [control mutual TLS authentication](https://istio.io/docs/concepts/security/#authentication) between services. We provide `PERMISSIVE` mode so that you can [incrementally turn on mutual TLS](https://istio.io/docs/tasks/security/mtls-migration/) for your services. We removed service annotations and have a [unique approach to turn on mutual TLS](https://istio.io/docs/tasks/security/authn-policy/), coupled with client-side [destination rules](https://istio.io/docs/concepts/traffic-management/#destination-rules).
- **JWT Authentication.** We now support [JWT authentication](https://istio.io/docs/concepts/security/#authentication) which can be configured using [authentication policies](https://istio.io/docs/concepts/security/#authentication-policies).

## `istioctl`

- Added the [istioctl authn tls-check](https://istio.io/docs/reference/commands/istioctl/#istioctl-authn-tls-check) command.
- Added the [istioctl proxy-status](https://istio.io/docs/reference/commands/istioctl/#istioctl-proxy-status) command.
- Added the `istioctl experimental convert-ingress` command.
- Removed the `istioctl experimental convert-networking-config` command.
- Enhancements and bug fixes:
  * Align `kubeconfig` handling with `kubectl`
  * `istioctl get all` returns all types of networking and authentication configuration.
  * Added the `--all-namespaces` flag to `istioctl` get to retrieve resources across all namespaces.

# Fixes

- Fix the broken feature of installing dedicated gateway for your application. Now, you can install multiple standalone gateways, even in the same namespace. We have provided an external [YAML file](./additionalFiles/values-istio-gateways.yaml) with overrides as an example to show how to install a standalone gateway:
```
$ helm install ../ibm-istio --name istio-gateways --namespace istio-system -f ./additionalFiles/values-istio-gateways.yaml
```
**Note**: You can customize the values in `gateways` section of the file, but make sure the values you specified should not conflict with the ones for existing gateways.

- Add support for ppc64le architecture. Now you can run Istio control plane and data plane on nodes with power platform.

- Update `kubectl` version from `v1.10.0` to `v1.11.1`

- Fix the issue that username/passphrase for Istio addons(grafana and kiali) are exposed in `values.yaml` file

- Fix the issue that `Custom Resource Definitions` can't be removed after the chart is deleted

- Fix the issue that `jaeger` service can't be accessed from `kiali` UI

# Prerequisites

* Kubernetes 1.9 or newer with [RBAC (Role-Based Access Control)](https://kubernetes.io/docs/admin/authorization/rbac/) enabled
  If you wish to enable [automatic sidecar injection](https://istio.io/docs/setup/kubernetes/sidecar-injection/#automatic-sidecar-injection), you must use Kubernetes version 1.9 or greater and the kube-apiserver process has the `admission-control` flag set with the `MutatingAdmissionWebhook` and `ValidatingAdmissionWebhook` admission controllers added and listed in the correct order and the admissionregistration API is enabled.
  ```
  $ kubectl api-versions | grep admissionregistration
  admissionregistration.k8s.io/v1alpha1
  admissionregistration.k8s.io/v1beta1
  ```

# Version History

| Chart | Date | Kubernetes Version Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ------------------ | ---------------- | ------- |
| 1.0.3 | Aug 22, 2018| >= 1.9  | ibmcom/istio-proxyv2:1.0.0 ibmcom/istio-proxy_init:1.0.0 ibmcom/kubectl:v1.11.1 ibmcom/istio-grafana:1.0.0 ibmcom/istio-citadel:1.0.0 ibmcom/istio-galley:1.0.0 ibmcom/istio-mixer:1.0.0 ibmcom/istio-servicegraph:1.0.0 ibmcom/istio-pilot:1.0.0 ibmcom/istio-sidecar_injector:1.0.0 ibmcom/prom-statsd-exporter:v0.6.0 ibmcom/prometheus:v2.3.1 ibmcom/jaegertracing-all-in-one:1.5 ibmcom/kiali:v0.5.0 ibmcom/cert-manager:v0.3.1  | None | new features and architectural improvement |
| 1.0.2 | Aug 13, 2018| >= 1.9  | ibmcom/istio-proxyv2:1.0.0 ibmcom/istio-proxy_init:1.0.0 ibmcom/kubectl:v1.10.0 ibmcom/istio-grafana:1.0.0 ibmcom/istio-citadel:1.0.0 ibmcom/istio-galley:1.0.0 ibmcom/istio-mixer:1.0.0 ibmcom/istio-servicegraph:1.0.0 ibmcom/istio-pilot:1.0.0 ibmcom/istio-sidecar_injector:1.0.0 ibmcom/prom-statsd-exporter:v0.6.0 ibmcom/prometheus:v2.3.1 ibmcom/jaegertracing-all-in-one:1.5 ibmcom/kiali:v0.5.0 ibmcom/cert-manager:v0.3.1  | None | new architectural support |
| 1.0.1 | Aug 3, 2018| >= 1.9  | ibmcom/istio-proxyv2:1.0.0 ibmcom/istio-proxy_init:1.0.0 ibmcom/kubectl:v1.10.0 ibmcom/istio-grafana:1.0.0 ibmcom/istio-citadel:1.0.0 ibmcom/istio-galley:1.0.0 ibmcom/istio-mixer:1.0.0 ibmcom/istio-servicegraph:1.0.0 ibmcom/istio-pilot:1.0.0 ibmcom/istio-sidecar_injector:1.0.0 ibmcom/prom-statsd-exporter:v0.6.0 ibmcom/prometheus:v2.3.1 ibmcom/jaegertracing-all-in-one:1.5 ibmcom/kiali:v0.5.0 ibmcom/cert-manager:v0.3.1  | None | new features and architectural improvement |
| 1.0.0 | July 31, 2018| >= 1.9  | ibmcom/istio-proxyv2:1.0.0 ibmcom/istio-proxy_init:1.0.0 ibmcom/kubectl:v1.10.0 ibmcom/istio-grafana:1.0.0 ibmcom/istio-citadel:1.0.0 ibmcom/istio-galley:1.0.0 ibmcom/istio-mixer:1.0.0 ibmcom/istio-servicegraph:1.0.0 ibmcom/istio-pilot:1.0.0 ibmcom/istio-sidecar_injector:1.0.0 ibmcom/prom-statsd-exporter:v0.6.0 ibmcom/prometheus:v2.3.1 ibmcom/jaegertracing-all-in-one:1.5 ibmcom/kiali:v0.5.0 ibmcom/cert-manager:v0.3.1  | None | new features and architectural improvement |
| 0.8.0 | June 1, 2018| >= 1.9  | ibmcom/istio-proxy:0.8.0 ibmcom/istio-proxyv2:0.8.0 ibmcom/istio-proxy_init:0.8.0 ibmcom/kubectl:v1.10.0 ibmcom/istio-grafana:0.8.0 ibmcom/istio-citadel:0.8.0 ibmcom/istio-mixer:0.8.0 ibmcom/istio-servicegraph:0.8.0 ibmcom/istio-pilot:0.8.0 ibmcom/istio-sidecar_injector:0.8.0 ibmcom/prom-statsd-exporter:v0.5.0 ibmcom/prometheus:v2.0.0 ibmcom/jaegertracing-all-in-one:1.5 | None | new features and architectural improvement |
| 0.7.1 | Apr 27, 2018| >=1.7.3 | ibmcom/istio-kubectl:v1.10.0 ibmcom/istio-grafana:0.7.1 ibmcom/istio-ca:0.7.1 ibmcom/istio-mixer:0.7.1 ibmcom/istio-servicegraph:0.7.1 ibmcom/istio-proxy_init:0.7.1 ibmcom/istio-proxy:0.7.1 ibmcom/istio-pilot:0.7.1 ibmcom/istio-sidecar_injector:0.7.1 ibmcom/zipkin:2.6.0 ibmcom/prom-statsd-exporter:v0.5.0 ibmcom/prometheus:v2.0.0 | None | Tech Preview |
