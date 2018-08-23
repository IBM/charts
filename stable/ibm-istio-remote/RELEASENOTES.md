# What's new in Chart Version 1.0.3

We’re proud to release Istio 1.0! Istio has been in development for nearly two years, and the 1.0 release represents a substantial milestone for us. All of our [core features](https://istio.io/about/feature-stages/) are now ready for production use.

Istio 1.0 only has a few new features relative to 0.8 as most of the effort for this release went into fixing bugs and improving performance.

# Fixes

- Add support for ppc64le architecture. Now you can run Istio control plane and data plane on nodes with power platform.

- Update `kubectl` version from `v1.10.0` to `v1.11.1`

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
| 1.0.3 | Aug 22, 2018| >= 1.9  | ibmcom/istio-proxyv2:1.0.0 ibmcom/istio-proxy_init:1.0.0 ibmcom/kubectl:v1.11.1 ibmcom/istio-citadel:1.0.0 ibmcom/istio-sidecar_injector:1.0.0 | None | new features and architectural improvement |
| 1.0.1 | Aug 13, 2018| >= 1.9  | ibmcom/istio-proxyv2:1.0.0 ibmcom/istio-proxy_init:1.0.0 ibmcom/kubectl:v1.10.0 ibmcom/istio-citadel:1.0.0 ibmcom/istio-sidecar_injector:1.0.0 | None | new architectural support |
| 1.0.0 | July 31, 2018| >= 1.9  | ibmcom/istio-proxyv2:1.0.0 ibmcom/istio-proxy_init:1.0.0 ibmcom/kubectl:v1.10.0 ibmcom/istio-citadel:1.0.0 ibmcom/istio-sidecar_injector:1.0.0 | None | new features and architectural improvement |
| 0.8.0 | June 1, 2018| >= 1.7.3 | ibmcom/istio-citadel:0.8.0 | None | Initial release |
