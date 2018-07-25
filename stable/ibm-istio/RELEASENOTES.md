# What's new in Chart Version 0.8.0

This is a major release for Istio on the road to 1.0. There are a great many new features and architectural improvements in addition to the usual pile of bug fixes and performance improvements.

## Networking

- **Revamped Traffic Management Model**. We're finally ready to take the wraps off our [new traffic management APIs](https://istio.io/blog/2018/v1alpha3-routing/). We believe this new model is easier to understand while covering more real world deployment [use-cases](https://istio.io/docs/tasks/traffic-management/). For folks upgrading from earlier releases there is a [migration guide](https://istio.io/docs/setup/kubernetes/upgrading-istio/) and a conversion tool built into `istioctl` to help convert your config from the old model.

- **Streaming Envoy configuration**. By default Pilot now streams configuration to Envoy using its [ADS API](https://github.com/envoyproxy/data-plane-api/blob/master/XDS_PROTOCOL.md). This new approach increases effective scalability, reduces rollout delay and should eliminate spurious 404 errors.

- **Gateway for Ingress/Egress**. We no longer support combining Kubernetes Ingress specs with Istio routing rules as it has led to several bugs and reliability issues. Istio now supports a platform independent [Gateway](https://istio.io/docs/concepts/traffic-management/rules-configuration/#gateways) model for ingress & egress proxies that works across Kubernetes and Cloud Foundry and works seamlessly with routing. The Gateway supports [Server Name Indication](https://en.wikipedia.org/wiki/Server_Name_Indication) based routing,
as well as serving a certificate based on the server name presented by the client.

- **Constrained Inbound Ports**. We now restrict the inbound ports in a pod to the ones declared by the apps running inside that pod.

## Security

- **Introducing Citadel**. We've finally given a name to our security component. What was formerly known as Istio-Auth or Istio-CA is now called Citadel.

- **Multicluster Support**. We support per-cluster Citadel in multicluster deployments such that all Citadels share the same root certificate and workloads can authenticate each other across the mesh.

- **Authentication Policy**. We've created a unified API for [authentication policy](https://istio.io/docs/tasks/security/authn-policy/) that controls whether service-to-service communication uses mutual TLS as well as end user authentication. This is now the recommended way to control these behaviors.

## Telemetry

- **Self-Reporting**. Mixer and Pilot now produce telemetry that flows through the normal Istio telemetry pipeline, just like services in the mesh.

## Setup

- **A la Carte Istio**. Istio has a rich set of features, however you don't need to install or consume them all together. By using Helm or `istioctl gen-deploy`, users can install only the features they want. For example, users can install Pilot only and enjoy traffic management functionality without dealing with Mixer or Citadel. Learn more about [customization through Helm](https://istio.io/docs/setup/kubernetes/helm-install/#customization-with-helm)
and about [`istioctl gen-deploy`](https://istio.io/docs/reference/commands/istioctl/#istioctl%20gen-deploy).

## Mixer adapters

- **CloudWatch**. Mixer can now report metrics to AWS CloudWatch. [Learn more](https://istio.io/docs/reference/config/policy-and-telemetry/adapters/cloudwatch/)

# Fixes

This release includes the usual pile of bug fixes that can be checked out here: https://github.com/istio/istio/compare/0.8.0...master 

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
| 0.8.0 | June 1, 2018| >= 1.9  | ibmcom/istio-proxy:0.8.0 ibmcom/istio-proxyv2:0.8.0 ibmcom/istio-proxy_init:0.8.0 ibmcom/kubectl:v1.10.0 ibmcom/istio-grafana:0.8.0 ibmcom/istio-citadel:0.8.0 ibmcom/istio-mixer:0.8.0 ibmcom/istio-servicegraph:0.8.0 ibmcom/istio-pilot:0.8.0 ibmcom/istio-sidecar_injector:0.8.0 ibmcom/prom-statsd-exporter:v0.5.0 ibmcom/prometheus:v2.0.0 ibmcom/jaegertracing-all-in-one:1.5 | None | new features and architectural improvement |
| 0.7.1 | Apr 27, 2018| >=1.7.3 | ibmcom/istio-kubectl:v1.10.0 ibmcom/istio-grafana:0.7.1 ibmcom/istio-ca:0.7.1 ibmcom/istio-mixer:0.7.1 ibmcom/istio-servicegraph:0.7.1 ibmcom/istio-proxy_init:0.7.1 ibmcom/istio-proxy:0.7.1 ibmcom/istio-pilot:0.7.1 ibmcom/istio-sidecar_injector:0.7.1 ibmcom/zipkin:2.6.0 ibmcom/prom-statsd-exporter:v0.5.0 ibmcom/prometheus:v2.0.0 | None | Tech Preview |