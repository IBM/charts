# Istio

[Istio](https://istio.io/) is an open platform for providing a uniform way to integrate microservices, manage traffic flow across microservices, enforce policies and aggregate telemetry data.

## Introduction

This chart bootstraps all istio [components](https://istio.io/docs/concepts/what-is-istio/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Chart Details

This chart can install multiple istio components as subcharts:

| Subchart | Component | Description | Enabled by Default |
| -------- | --------- | ----------- | ------------------ |
| gateways | Gateways | A platform independent [Gateway](https://istio.io/docs/concepts/traffic-management/#gateways) model for ingress & egress proxies that works across Kubernetes and Cloud Foundry and works seamlessly with routing. | Yes |
| sidecarInjectorWebhook | Automatic Sidecar Injector | A [mutating webhook](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#admission-webhooks) implementation to automatically inject an envoy sidecar container into application pods. | Yes |
| galley | Galley | The top-level config ingestion, processing and distribution component for Istio, responsible for insulating the rest of the Istio components from the details of obtaining user configuration from the underlying platform. | Yes |
| mixer | Mixer | A centralized component that is leveraged by the proxies and microservices to enforce policies such as authorization, rate limits, quotas, authentication, request tracing and telemetry collection. | Yes |
| pilot | Pilot | A component responsible for configuring the proxies at runtime. | Yes |
| security | Citadel | A centralized component responsible for certificate issuance and rotation. | Yes |
| istiocoredns | [istio-coredns-plugin](https://github.com/istio-ecosystem/istio-coredns-plugin) | A CoreDNS gRPC plugin to serve DNS records out of Istio ServiceEntries. | No |
| nodeagent | NodeAgent | A per-node component responsible for certificate issuance and rotation. | No |
| istiocni | Istio-CNI | A component that sets up the pods' networking to fulfill this requirement in place of the Istio injected pod initContainers approach. | No |
| grafana | [Grafana](https://grafana.com/) | A visualization tool for monitoring and metric analytics & dashboards for Istio | No |
| prometheus | [Prometheus](https://prometheus.io/) | A service monitoring system for Istio that collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true. | No |
| servicegraph | Service Graph | A small add-on for Istio that generates and visualizes graph representations of service mesh. | No |
| tracing | [Jaeger](https://www.jaegertracing.io/) or [Zipkin](https://zipkin.io/) | Istio uses Jaeger or Zipkin as a tracing provider that is used for monitoring and troubleshooting Istio service mesh. | No |
| kiali | [Kiali](https://www.kiali.io/) | Kiali works with Istio to visualise the service mesh topology, features like circuit breakers or request rates. | No |
| certmanager | [CertManager](https://github.com/jetstack/cert-manager) | An Istio add-on to automate the management and issuance of TLS certificates from various issuing sources. | No |

To enable or disable each component, change the corresponding `enabled` flag.

## PodSecurityPolicy Requirements

### When installing on 3.1.1 or later

This chart requires a PodSecurityPolicy to be bound to the target namespace(`istio-system`) prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace(`istio-system`) is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-istio-psp
    spec:
      allowPrivilegeEscalation: true
      allowedCapabilities:
      - '*'
      allowedUnsafeSysctls:
      - '*'
      fsGroup:
        rule: RunAsAny
      hostIPC: true
      hostNetwork: true
      hostPID: true
      hostPorts:
      - max: 65535
        min: 0
      privileged: true
      runAsUser:
        rule: RunAsAny
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      volumes:
      - '*'
    ```
  - Custom ClusterRole and ClusterRoleBinding for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-istio-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-istio-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: ibm-istio-clusterrolebinding
    roleRef:
      kind: ClusterRole
      name: ibm-istio-clusterrole
      apiGroup: rbac.authorization.k8s.io
    subjects:      
    - kind: Group
      name: system:serviceaccounts:istio-system
      apiGroup: rbac.authorization.k8s.io
    ```

- The cluster admin can either paste the above `PSP` and `ClusterRole` & `ClusterRoleBinding` definitions into the create resource screen in the UI or run the following two commands:
  ```
  kubectl create -f <PSP-yaml-file>
  kubectl create clusterrole ibm-istio-clusterrole \
      --verb=use \
      --resource=podsecuritypolicy \
      --resource-name=ibm-istio-psp
  kubectl create clusterrolebinding ibm-istio-clusterrolebinding \
    --clusterrole=ibm-istio-clusterrole \
    --group=system:serviceaccounts:istio-system
  ```

## Prerequisites

- A user with `cluster-admin` ClusterRole is required to install the chart.
- Kubernetes 1.9 or newer cluster with RBAC (Role-Based Access Control) enabled is required.
- To enable automatic sidecar injection, Kubernetes 1.9+ with `admissionregistration` API is required, and the `kube-apiserver` process must have the `admission-control` flag set with the `MutatingAdmissionWebhook` and `ValidatingAdmissionWebhook` admission controllers added and listed in the correct order.

## Resources Required

The chart deploys pods that consume minimum resources as specified in the resources configuration parameter.

## Installing the Chart

1. **Important**: If your helm version is < 2.10, which doesn't support `crd-install` hook, then you need to manually install Istio’s CRDs via `kubectl apply` before deploying the `ibm-istio` chart; After all Istio’s CRDs are committed in the kube-apiserver, you have to add `--set global.crds=false` parameter to `helm install ...` command line(or if you're installing `ibm-istio` from `Catalog`, uncheck the `crds` checkbox in global section) when you deploy the `ibm-istio` chart. To manually install Istio’s CRDs, you can execute the following commands:

   ```
   $ kubectl apply -f https://raw.githubusercontent.com/IBM/charts/master/stable/ibm-istio/additionalFiles/crds/crd-1*.yaml
   ```

   or if you have downloaded the chart locally:
   ```
   $ kubectl apply -f ../ibm-istio/additionalFiles/crds/crd-1*.yaml
   ```
   **Note**: If you are enabling `certmanager`, you also need to install its CRDs and wait a few seconds for the CRDs to be committed in the kube-apiserver:
   ```
   $ kubectl apply -f https://raw.githubusercontent.com/IBM/charts/master/stable/ibm-istio/additionalFiles/crds/crd-certmanager-*.yaml
   ```

   or if you have downloaded the chart locally:
   ```
   $ kubectl apply -f ../ibm-istio/additionalFiles/crds/crd-certmanager-*.yaml
   ```

2. Create namespace `istio-system` for the chart:
   ```
   $ kubectl create ns istio-system
   ```

3. If you are using security mode for Grafana, create the secret first as follows:
   Encode username, you can change the username to the name as you want:
   ```
   $ echo -n 'admin' | base64
   YWRtaW4=
   ```

   Encode passphrase, you can change the passphrase to the passphrase as you want:
   ```
   $ echo -n 'admin' | base64
   YWRtaW4=
   ```

   Set the namespace where Istio was installed:
   ```
   $ NAMESPACE=istio-system
   ```

   Create secret for Grafana:
   ```
   $ cat <<EOF | kubectl apply -f -
   apiVersion: v1
   kind: Secret
   metadata:
     name: grafana
     namespace: $NAMESPACE
     labels:
       app: grafana
   type: Opaque
   data:
     username: YWRtaW4=
     passphrase: YWRtaW4=
   EOF
   ```
   
4. If you are enabling `kiali`, you also need to create the secret that contains the username and passphrase for `kiali` dashboard:
   ```
   $ echo -n 'admin' | base64
   YWRtaW4=
   $ echo -n 'admin' | base64
   YWRtaW4=
   $ NAMESPACE=istio-system
   $ cat <<EOF | kubectl apply -f -
   apiVersion: v1
   kind: Secret
   metadata:
     name: kiali
     namespace: $NAMESPACE
     labels:
       app: kiali
   type: Opaque
   data:
     username: YWRtaW4=
     passphrase: YWRtaW4=
   EOF
   ```

5. To install the chart with the release name `istio` in namespace `istio-system`:
   - With [automatic sidecar injection](https://istio.io/docs/setup/kubernetes/sidecar-injection/#automatic-sidecar-injection) (requires Kubernetes >=1.9.0):
   ```
   $ helm install ../ibm-istio --name istio --namespace istio-system
   ```

   - Without the sidecar injection webhook:
   ```
   $ helm install ../ibm-istio --name istio --namespace istio-system --set sidecarInjectorWebhook.enabled=false
   ```

## Configuration

The Helm chart ships with reasonable defaults.  There may be circumstances in which defaults require overrides.
To override Helm values, use `--set key=value` argument during the `helm install` command.  Multiple `--set` operations may be used in the same Helm operation.

Helm charts expose configuration options which are currently in alpha.  The currently exposed options are explained in the following table:

| Parameter | Description | Values | Default |
| --------- | ----------- | ------ | ------- |
| `global.monitoringPort` | Specifies the monitor port for mixer, pilot, galley and citadel | valid port number | `15014` |
| `global.k8sIngress.enabled` | Specifies whether to enable gateway for lagency k8s resources. | true/false | `false` |
| `global.k8sIngress.gatewayName` | Specifies the gateway used for legacy k8s ingress resources | `ingressgateway` or any defined gateway | `ingressgateway` |
| `global.k8sIngress.enableHttps` | Specifies whether to use the https for ingress | true/false | `false` |
| `global.istioRemote` | Specifies whether to deploy Istio remote chart on remote cluster | true/false | `false` |
| `global.createRemoteSvcEndpoints` | Specifies whether to create service endpoints on Istio remote chart on remote cluster, if `istioRemote=true` | true/false | `false` |
| `global.remotePilotCreateSvcEndpoint` | Specifies whether to create pilot service endpoints on Istio remote chart on remote cluster, if `istioRemote=true` | true/false | `false` |
| `global.remotePilotAddress` | Specifies the address of pilot on central Istio control plane | valid address | `""` |
| `global.remotePolicyAddress` | Specifies the address of Istio policy checker on central Istio control plane | valid address | `""` |
| `global.remoteTelemetryAddress` | Specifies the address of Istio telemetry on central Istio control plane | valid address | `""` |
| `global.remoteZipkinAddress` | Specifies the address of zipkin tracer on central Istio control plane | valid address | `""` |
| `global.proxy.repository` | Specifies the proxy image location | valid image repository | `ibmcom/istio-proxyv2` |
| `global.proxy.tag` | Specifies the proxy image version | valid image tag | `1.1.0` |
| `global.proxy.clusterDomain` | Specifies the cluster domain, default value is 'cluster.local' | valid cluster domain | `cluster.local` |
| `global.proxy.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | `{requests.cpu: 10m}` |
| `global.proxy.concurrency` | Controls number of proxy worker threads. If set to 0 (default), then start worker thread for each CPU thread/core | valid number(>=0) | `0` |
| `global.proxy.accessLogFile`| Specifies the access log for each sidecar, an empty string will disable access log for sidecar | valid file path or empty string | `""` |
| `global.proxy.accessLogFormat`| Configures the access log format for each sidecar | valid log format | `""` |
| `global.proxy.accessLogEncoding`| Configures the access log encoding for each sidecar, default value is 'TEXT' | 'JSON' or 'TEXT' | `"TEXT"` |
| `global.proxy.dnsRefreshRate`| Configures the DNS refresh rate for each sidecar, default value is '5s' | valid time string | `"5s"` |
| `global.proxy.privileged` | Configure privileged securityContext for proxy. If set to true, istio-proxy container will have privileged securityContext | true/false | `false` |
| `global.proxy.enableCoreDump` | Specifies whether to enable debug information for envoy sidecar | true/false | `false` |
| `global.proxy.statusPort` | Specifies the status port for each sidecar, set to '0' to disable health checking | valid port number or `0` | `15020` |
| `global.proxy.readinessInitialDelaySeconds` | Specifies the initial delay in seconds of readiness probe each sidecar | valid number in seconds | `1` |
| `global.proxy.readinessPeriodSeconds` | Specifies the period in seconds of readiness probe each sidecar | valid number in seconds | `2` |
| `global.proxy.readinessFailureThreshold` | Specifies the failure threshold of readiness probe each sidecar | valid number | `30` |
| `global.proxy.includeIPRanges` | Specifies istio egress capture whitelist | example: includeIPRanges: "172.30.0.0/16,172.20.0.0/16" | `*` |
| `global.proxy.excludeIPRanges` | Specifies istio egress capture blacklist | example: excludeIPRanges: "172.40.0.0/16,172.50.0.0/16" | `""` |
| `global.proxy.excludeInboundPorts` | Specifies istio egress capture port blacklist | example: excludeInboundPorts: "81:8081" | `""` |
| `global.proxy.autoInject` | Specifies whether to enable ingress and egress policy for envoy sidecar | `enabled`/`disabled` | `enabled` |
| `global.proxy.envoyStatsd.enabled` | Specifies whether to enable the destination statsd in envoy | true/false | `false` |
| `global.proxy.envoyStatsd.host` | Specifies host for the destination statsd in envoy | destination statsd host | `""` |
| `global.proxy.envoyStatsd.port` | Specifies host port for the destination statsd in envoy | destination statsd port | `""` |
| `global.proxy.envoyMetricsService.enabled` | Specifies whether to enable the external envoy metrics server | true/false | `false` |
| `global.proxy.envoyMetricsService.host` | Specifies the host for the external envoy metrics server | valid metrics service host | `""` |
| `global.proxy.envoyMetricsService.port` | Specifies the port for the external envoy metrics server | valid metrics service port | `""` |
| `global.proxy.tracer` | Specifies the tracer service name for the Istio | valid tracer service name | `"zipkin"` |
| `global.proxy_init.repository` | Specifies the proxy init image location | valid image repository | `ibmcom/istio-proxy_init` |
| `global.proxy_init.tag` | Specifies the proxy init image version | valid image tag | `1.1.0` |
| `global.imagePullPolicy` | Specifies the image pull policy | valid image pull policy | `IfNotPresent` |
| `global.controlPlaneSecurityEnabled` | Specifies whether control plane mTLS is enabled | true/false | `false` |
| `global.disablePolicyChecks` | Specifies whether to disables mixer policy checks | true/false | `true` |
| `global.policyCheckFailOpen` | Specifies whether the traffic is allowed if the client is unable to connect to mixer | true/false | `false` |
| `global.enableTracing` | Specifies whether to enables the Tracing | true/false | `true` |
| `global.tracer` | Configures the tracer service for the Istio service mesh | valid tracer service | `{}` |
| `global.mtls.enabled` | Specifies whether mTLS is enabled by default between services | true/false | `false` |
| `global.imagePullSecrets` | Specifies image pull secrets for private docker registry | array consists of imagePullSecret | [] |
| `global.oneNamespace` | Specifies whether to restrict the applications namespace the controller manages | true/false | `false` |
| `global.defaultNodeSelector` | Configures the default node selector for all Istio components | valid node selector | `{}` |
| `global.defaultTolerations` | Configures the default tolerations for all Istio components | valid tolerations | `[]` |
| `global.configValidation` | Specifies whether to perform server-side validation of configuration | true/false | `true` |
| `global.meshExpansion.enabled` | Specifies whether to support mesh expansion | true/false | `false` |
| `global.meshExpansion.useILB` | Specifies whether to expose the pilot and citadel mtls and the plain text pilot ports on an internal gateway | true/false | `false` |
| `global.kubectl.repository` | Specifies the kubectl image location | valid image repository | `ibmcom/kubectl` |
| `global.kubectl.tag` | Specifies the kubectl image version | valid image tag | `v1.13.5` |
| `global.crds` | Specifies whether to install all Istio CRDs with `crd-install` hook | `true` |
| `global.istioNamespace` | Specifies Istio installation namespace when generate a standalone gateway | valid namespace | `""` |
| `global.omitSidecarInjectorConfigMap` | Specifies whether to omit the istio-sidecar-injector configmap when generate a standalone gateway | true/false | `false` |
| `global.multiCluster.enabled` | Specifies whether to enable multicluster deployment using gateway | true/false | `false` |
| `gobal.defaultResources` | Specifies resources(CPU/Memory) requests & limits applied to all deployments | valid CPU&memory settings | `{requests.cpu: 10m}` |
| `gobal.defaultPodDisruptionBudget.enabled` | Specifies whether to enable the pod disruption budget | true/false | `false` |
| `global.priorityClassName` | Specifies priority class, it can be 'system-cluster-critical' or 'system-node-critical' | valid priority class name | `""` |
| `global.useMCP` | Specifies whether to enable the mesh control protocol for configuring mixer and pilot | true/false | `false` |
| `global.trustDomain` | Configures the default trust root domain for the entire Istio service mesh | valid cluster domain | `""` |
| `global.outboundTrafficPolicy.mode` | Specifies the default outbound traffic policy mode, default value is 'ALLOW_ANY' | 'ALLOW_ANY' or 'REGISTRY_ONLY' | 'ALLOW_ANY' |
| `global.sds` | Specifies the configuration for the secret discovery service(SDS) | SDS configuration | `{}` |
| `global.meshNetworks` | Configures the mesh networks to be used by the Split Horizon EDS | valid mesh network | `{}` |
| `global.enableHelmTest` | Specifies whether to render the helm test resources, default value is false | true/false | `false` |
| `global.arch.amd64`| Architecture preference for amd64 node | `0 - Do not use`/`1 - Least preferred`/`2 - No preference`/`3 - Most preferred` | `2 - No preference` |
| `global.arch.ppc64le` | Architecture preference for ppc64le node | `0 - Do not use`/`1 - Least preferred`/`2 - No preference`/`3 - Most preferred` | `2 - No preference` |
| `gateways.enabled` | Specifies whether the Istio Gateway should be installed | true/false | `true` |
| `gateways.istio-ingressgateway.enabled` | Specifies whether the Ingress Gateway should be installed | true/false | `true` |
| `gateways.istio-ingressgateway.labels` | Specifies labels for Ingress Gateway | valid labels | `app: istio-ingressgateway` |
| `gateways.istio-ingressgateway.replicaCount` | Specifies number of desired pods for Ingress Gateway deployment | number | `1` |
| `gateways.istio-ingressgateway.autoscaleMin` | Specifies lower limit for the number of pods that can be set by the autoscaler | number | `1` |
| `gateways.istio-ingressgateway.autoscaleMax` | Specifies upper limit for the number of pods that can be set by the autoscaler | number | `5` |
| `gateways.istio-ingressgateway.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `gateways.istio-ingressgateway.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `gateways.istio-ingressgateway.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `gateways.istio-ingressgateway.cpu.targetAverageUtilization` | Specify the CPU target average utilization for ingressgateway | valid CPU utilization | `80` |
| `gateways.istio-ingressgateway.loadBalancerIP` | Specifies load balancer IP if its type is LoadBalancer | valid IP address | `""` |
| `gateways.istio-ingressgateway.type` | Specifies service type for Ingress Gateway | valid service type | `LoadBalancer` |
| `gateways.istio-ingressgateway.serviceAnnotations` | Specifies the annotations for Ingress Gateway service | valid service annotations | {} |
| `gateways.istio-ingressgateway.ports` | Specifies service ports settings for Ingress Gateway | valid service ports settings |  |
| `gateways.istio-ingressgateway.secretVolumes` | Specifies deployment certs volume settings for Ingress Gateway | valid deployment volume |  |
| `gateways.istio-egressgateway.enabled` | Specifies whether the Egress Gateway should be installed | true/false | `true` |
| `gateways.istio-egressgateway.labels` | Specifies labels for Egress Gateway | valid labels | `app: istio-egressgateway` |
| `gateways.istio-egressgateway.replicaCount` | Specifies number of desired pods for Egress Gateway deployment | number | `1` |
| `gateways.istio-egressgateway.autoscaleMin` | Specifies lower limit for the number of pods that can be set by the autoscaler | number | `1` |
| `gateways.istio-egressgateway.autoscaleMax` | Specifies upper limit for the number of pods that can be set by the autoscaler | number | `5` |
| `gateways.istio-egressgateway.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `gateways.istio-egressgateway.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `gateways.istio-egressgateway.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `gateways.istio-egressgateway.cpu.targetAverageUtilization` | Specify the CPU target average utilization for egressgateway | valid CPU utilization | `80` |
| `gateways.istio-egressgateway.serviceAnnotations` | Specifies the annotations for Egress Gateway service | valid service annotations | {} |
| `gateways.istio-egressgateway.type` | Specifies service type that used for Egress Gateway | valid service type | `ClusterIP` |
| `gateways.istio-egressgateway.ports` | Specifies service ports settings for Egress Gateway | valid service ports settings |  |
| `gateways.istio-egressgateway.secretVolumes` | Specifies service secretVolumes settings for Egress Gateway | valid service ports settings |  |
| `gateways.istio-ilbgateway.enabled` | Specifies whether the Mesh ILB Gateway should be installed | true/false | `false` |
| `gateways.istio-ilbgateway.labels` | Specifies labels for ILB Gateway | valid labels | `app: istio-ilbgateway` |
| `gateways.istio-ilbgateway.replicaCount` | Specifies number of desired pods for Mesh ILB Gateway deployment | number | `1` |
| `gateways.istio-ilbgateway.autoscaleMin` | Specifies lower limit for the number of pods that can be set by the autoscaler | number | `1` |
| `gateways.istio-ilbgateway.autoscaleMax` | Specifies upper limit for the number of pods that can be set by the autoscaler | number | `5` |
| `gateways.istio-ilbgateway.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | `{requests.cpu: 800m, requests.memory: 512Mi}` |
| `gateways.istio-ilbgateway.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `gateways.istio-ilbgateway.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `gateways.istio-ilbgateway.cpu.targetAverageUtilization` | Specify the CPU target average utilization for ilbgateway | valid CPU utilization | `80` |
| `gateways.istio-ilbgateway.loadBalancerIP` | Specifies load balancer IP if its type is LoadBalancer | valid IP address | `""` |
| `gateways.istio-ilbgateway.serviceAnnotations` | Specifies the annotations for ILB Gateway service | valid service annotations | {} |
| `gateways.istio-ilbgateway.type` | Specifies service type for ILB Gateway | valid service type | `LoadBalancer` |
| `gateways.istio-ilbgateway.ports` | Specifies service ports settings for Mesh ILB Gateway | valid service ports settings |  |
| `gateways.istio-ilbgateway.secretVolumes` | Specifies service secretVolumes settings for Mesh ILB Gateway | valid service ports settings |  |
| `sidecarInjectorWebhook.enabled` | Specifies whether the automatic sidecar injector should be installed | true/false | `true` |
| `sidecarInjectorWebhook.replicaCount` | Specifies number of desired pods for automatic sidecar injector webhook | number | `1` |
| `sidecarInjectorWebhook.enableNamespacesByDefault` | Specifies use the default namespaces for automatic sidecar injector webhook | true/false | `false` |
| `sidecarInjectorWebhook.image.repository` | Specifies the Automatic Sidecar Injector image location | valid image repository | `ibmcom/istio-sidecar_injector` |
| `sidecarInjectorWebhook.image.tag` | Specifies the Automatic Sidecar Injector image version | valid image tag | `1.1.0` |
| `sidecarInjectorWebhook.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `sidecarInjectorWebhook.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `galley.enabled` | Specifies whether Galley should be installed | true/false | `true` |
| `galley.replicaCount` | Specifies number of desired pods for Galley deployment | number | `1` |
| `galley.image.repository` | Specifies the galley image location | valid image repository | `ibmcom/istio-galley` |
| `galley.image.tag` | Specifies the galley image version | valid image tag | `1.1.0` |
| `galley.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `galley.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `galley.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `mixer.enabled` | Specifies whether Mixer should be installed | true/false | `true` |
| `mixer.replicaCount` | Specifies number of desired pods for Mixer deployment | number | `1` |
| `mixer.image.repository` | Specifies the Mixer image location | valid image repository | `ibmcom/istio-mixer` |
| `mixer.image.tag` | Specifies the Mixer image version | valid image tag | `1.1.0` |
| `mixer.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `mixer.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `mixer.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `mixer.istio-policy.autoscaleEnabled` | Specifies whether to enable auto scaler for the mixer policy checker | true/false | true |
| `mixer.istio-policy.autoscaleMin` | Specifies lower limit for the number of pods that can be set by the autoscaler | number | `1` |
| `mixer.istio-policy.autoscaleMax` | Specifies upper limit for the number of pods that can be set by the autoscaler | number | `5` |
| `mixer.istio-policy.cpu.targetAverageUtilization` | Specifies the average utilization of cpu | number | `80` |
| `mixer.istio-telemetry.autoscaleEnabled` | Specifies whether to enable auto scaler for the mixer telemetry | true/false | true |
| `mixer.istio-telemetry.autoscaleMin` | Specifies lower limit for the number of pods that can be set by the autoscaler | number | `1` |
| `mixer.istio-telemetry.autoscaleMax` | Specifies upper limit for the number of pods that can be set by the autoscaler | number | `5` |
| `mixer.istio-telemetry.cpu.targetAverageUtilization` | Specifies the average utilization of cpu | number | `80` |
| `pilot.enabled` | Specifies whether Pilot should be installed | true/false | `true` |
| `pilot.replicaCount` | Specifies number of desired pods for Pilot deployment | number | `1` |
| `pilot.autoscaleMin` | Specifies lower limit for the number of pods that can be set by the autoscaler | number | `1` |
| `pilot.autoscaleMax` | Specifies upper limit for the number of pods that can be set by the autoscaler | number | `5` |
| `pilot.image.repository` | Specifies the Pilot image location | valid image repository | `ibmcom/istio-pilot` |
| `pilot.image.tag` | Specifies the Pilot image version | valid image tag | `1.1.0` |
| `pilot.sidecar` | Specifies whether to enable the envoy sidecar to Pilot | true/false | `true` |
| `pilot.traceSampling` | Specifies the number of trace sample for Pilot | number | `100.0` |
| `pilot.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | `{requests.cpu: 500m, requests.memory: 2048Mi}` |
| `pilot.env` | Specifies ENV variable settings for pilot deployment | valid env settings | `{PILOT_PUSH_THROTTLE_COUNT: 100, GODEBUG: gctrace=2}` |
| `pilot.cpu.targetAverageUtilization` | Specifies cpu target average utilization for pilot deployment | number | `80` |
| `pilot.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `pilot.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `security.enabled` | Specifies whether Citadel should be installed | true/false | `true` |
| `security.replicaCount` | Specifies number of desired pods for Citadel deployment | number | `1` |
| `security.selfSigned` | Specifies whether self-signed CA is enabled | true/false | `true` |
| `security.image.repository` | Specifies the Citadel image location | valid image repository | `ibmcom/istio-citadel` |
| `security.image.tag` | Specifies the Citadel image version | valid image tag | `1.1.0` |
| `security.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `security.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `security.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `nodeagent.enabled`| Specifies whether citadel node agent should be installed | true/false | `false` |
| `nodeagent.image.repository` | Specifies the citadel node agent image location | valid image repository | `ibmcom/istio-node-agent-k8s` |
| `nodeagent.image.tag` | Specifies the citadel node agent image version | valid image tag | `1.1.0` |
| `nodeagent.env` | Specifies the environment variables for the citadel node agent | valid env | {} |
| `nodeagent.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `nodeagent.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `nodeagent.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `istiocni.enabled`| Specifies whether the istio-cni should be installed | true/false | `false` |
| `istiocni.image.repository` | Specifies the istio-cni image location | valid image repository | `ibmcom/istio-cni` |
| `istiocni.image.tag` | Specifies the istio-cni image version | valid image tag | `1.1.0` |
| `istiocni.logLevel` | Specifies the log level for the istio-cni | valid log level | `info` |
| `istiocni.excludeNamespaces` | Specifies the exclude namespaces for the istio-cni | valid namespace array | `["istio-system"]` |
| `istiocni.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `istiocoredns.enabled`| Specifies whether Istio coreDNS should be installed | true/false | `false` |
| `istiocoredns.coreDNSImage.repository` | Specifies the coreDNS image location | valid image repository | `ibmcom/coredns` |
| `istiocoredns.coreDNSImage.tag` | Specifies the coreDNS image version | valid image tag | `1.2.6` |
| `istiocoredns.coreDNSPluginImage.repository` | Specifies the Istio coreDNS plugin image location | valid image repository | `ibmcom/istio-coredns-plugin` |
| `istiocoredns.coreDNSPluginImage.tag` | Specifies the Istio coreDNS plugin image version | valid image tag | `0.2-istio-1.1` |
| `istiocoredns.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `istiocoredns.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `istiocoredns.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `grafana.enabled` | Specifies whether enable grafana addon should be installed | true/false | `false` |
| `grafana.replicaCount` | Specifies number of desired pods for grafana | number | `1` |
| `grafana.image.repository` | Specifies the Grafana image location | valid image repository | `ibmcom/grafana` |
| `grafana.image.tag` | Specifies the Grafana image version | valid image tag | `5.2.0-f3` |
| `grafana.persist` | Specifies whether enable date persistence for the grafana deployment | true/false | `false` |
| `grafana.storageClassName` | Specifies storage class name for the grafana deployment | valid storage class name | `""` |
| `grafana.security.enabled` | Specifies security for the grafana service | true/false | `false` |
| `grafana.security.secretName` | Specifies secret name that contains username and passphrase for the Grafana dashboard | valid secret name | `grafana` |
| `grafana.security.usernameKey` | Specifies the username key for the secret that contains username for the Grafana dashboard | valid secret key string | `username` |
| `grafana.security.passphraseKey` | Specifies the passphrase key for the secret that contains passphrase for the Grafana dashboard | valid secret key string | `passphrase` |
| `grafana.service.name` | Specifies name for the Grafana service | valid service name | `http` |
| `grafana.service.annotations` | Specifies the annotation for the Grafana service | valid service annotation | {} |
| `grafana.service.type` | Specifies type for the Grafana service | valid service type | `ClusterIP` |
| `grafana.service.externalPort` | Specifies external port for the Grafana service | valid service port | `3000` |
| `grafana.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `grafana.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `grafana.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `prometheus.enabled` | Specifies whether Prometheus addon should be installed | true/false | `true` |
| `prometheus.replicaCount` | Specifies number of desired pods for Prometheus | number | `1` |
| `prometheus.image.repository` | Specifies the Prometheus image location | valid image repository | `ibmcom/prometheus` |
| `prometheus.image.tag` | Specifies the Prometheus image version | valid image tag | `v2.8.0` |
| `prometheus.service.annotations` | Specifies the annotation for the Prometheus service |  valid service annotations | `{}` |
| `prometheus.service.nodePort.enabled` | Specifies whether to enable Node Port for Prometheus service |  true/false | `false` |
| `prometheus.service.nodePort.port` | Specifies Node Port for Prometheus service | valid service Node Port | `32090` |
| `prometheus.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `prometheus.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `prometheus.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `servicegraph.enabled` | Specifies whether Servicegraph addon should be installed | true/false | `false` |
| `servicegraph.replicaCount` | Specifies number of desired pods for Servicegraph deployment | number | `1` |
| `servicegraph.image.repository` | Specifies the Servicegraph image location | valid image repository | `ibmcom/istio-servicegraph` |
| `servicegraph.image.tag` | Specifies the Servicegraph image version | valid image tag | `1.1.0` |
| `servicegraph.service.annotations` | Specifies the annotation for the Servicegraph service | valid service annotation | {} |
| `servicegraph.service.name` | Specifies name for the Servicegraph service | valid service name | `http` |
| `servicegraph.service.type` | Specifies type for the Servicegraph service | valid service type | `ClusterIP` |
| `servicegraph.service.externalPort` | Specifies external port for the Servicegraph service | valid service port | `8088` |
| `servicegraph.ingress.enabled` | Specifies whether ingress for Servicegraph should be enabled | true/false | `false` |
| `servicegraph.ingress.hosts` | Specify the hosts for Servicegraph ingress | array consists of valid hosts | [] |
| `servicegraph.ingress.annotations` | Specify the annotations for Servicegraph ingress | object consists of valid annotations | {} |
| `servicegraph.ingress.tls` | Specify the TLS settigs for Servicegraph ingress | array consists of valid TLS settings | [] |
| `servicegraph.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `servicegraph.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `servicegraph.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `servicegraph.prometheusAddr` | Specify the prometheus address on Servicegraph | valid address | `http://prometheus:9090` |
| `tracing.enabled` | Specifies whether Tracing addon should be installed | true/false | `false` |
| `tracing.provider` | Specifies which the provider for tracing service | valid tracing provider | `jaeger` |
| `tracing.jaeger.image.repository` | Specifies the jaeger image location | valid image repository | `ibmcom/jaegertracing-all-in-one` |
| `tracing.jaeger.image.tag` | Specifies the jaeger image version | valid image tag | `1.9` |
| `tracing.jaeger.memory.max_traces` | Specifies max traces limits for Jaeger | valid number | `50000` |
| `tracing.jaeger.ingress.enabled` | Specifies whether Jaeger ingress should be enabled | true/false | `false` |
| `tracing.jaeger.ingress.hosts` | Specify the hosts for jaeger ingress | array consists of valid hosts | [] |
| `tracing.jaeger.ingress.annotations` | Specify the annotations for jaeger ingress | object consists of valid annotations | {} |
| `tracing.jaeger.ingress.tls` | Specify the TLS settigs for jaeger ingress | array consists of valid TLS settings | [] |
| `tracing.replicaCount` | Specifies number of desired pods for Tracing deployment | number | `1` |
| `tracing.service.annotations` | Specifies annotations for the Tracing service | valid service annotations | `{}` |
| `tracing.service.name` | Specifies name for the Tracing service | valid service name | `http` |
| `tracing.service.type` | Specifies type for the Tracing service | valid service type | `ClusterIP` |
| `tracing.service.externalPort` | Specifies external port for the Tracing service | valid service port | `9411` |
| `tracing.ingress.enabled` | Specifies whether ingress for Tracing should be enabled | true/false | `false` |
| `tracing.ingress.hosts` | Specify the hosts for Tracing ingress | array consists of valid hosts | [] |
| `tracing.ingress.annotations` | Specify the annotations for Tracing ingress | object consists of valid annotations | {} |
| `tracing.ingress.tls` | Specify the TLS settigs for Tracing ingress | array consists of valid TLS settings | [] |
| `tracing.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `tracing.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `tracing.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `kiali.enabled` | Specifies whether kiali addon should be installed | true/false | `false` |
| `kiali.replicaCount` | Specifies number of desired pods for kiali | number | `1` |
| `kiali.image.repository` | Specifies the kiali image location | valid image repository | `ibmcom/kiali` |
| `kiali.image.tag` | Specifies the kiali image version | valid image tag | `v0.14` |
| `kiali.ingress.enabled` | Specifies whether the kiali ingress enabled | true/false | `false` |
| `kiali.ingress.hosts` | Specify the hosts for Kiali ingress | array consists of valid hosts | [] |
| `kiali.ingress.annotations` | Specify the annotations for Kiali ingress | object consists of valid annotations | {} |
| `kiali.ingress.tls` | Specify the TLS settigs for Kiali ingress | array consists of valid TLS settings | [] |
| `kiali.dashboard.secretName` | Specifies secret name that contains username and passphrase for the Kiali dashboard | valid secret name | `kiali` |
| `kiali.dashboard.usernameKey` | Specifies the username key for the secret that contains username for the Kiali dashboard | valid secret key string | `username` |
| `kiali.dashboard.passphraseKey` | Specifies the passphrase key for the secret that contains passphrase for the Kiali dashboard | valid secret key string | `passphrase` |
| `kiali.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `kiali.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `kiali.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |
| `certmanager.enabled` | Specifies whether the Cert Manager addon should be installed | true/false | `false` |
| `certmanager.replicaCount` | Specifies number of desired pods for cert-manager | number | `1` |
| `certmanager.image.repository` | Specifies the Cert Manager image location | valid image repository | `ibmcom/icp-cert-manager-controller` |
| `certmanager.image.tag` | Specifies the Cert Manager image version | valid image tag | `0.7.0` |
| `certmanager.extraArgs` | Specifies the extra argument for Cert Manager | valid arguments | [] |
| `certmanager.podAnnotations` | Specifies the annotations for Cert Manager pod | valid annotation | {} |
| `certmanager.podLabels` | Specifies the labels for Cert Manager pod | valid label | {} |
| `certmanager.podDnsPolicy` | Specifies the pod DNS policy | valid DNS policy | `ClusterFirst` |
| `certmanager.podDnsConfig` | Specifies the pod DNS configuration | valid Configuration | {} |
| `certmanager.email` | Specifies the email for certmanager | valid email | `""` |
| `certmanager.resources` | CPU/Memory for resource requests & limits | valid CPU&memory settings | {} |
| `certmanager.tolerations` | Specifies customized tolerations for deployment | valid tolerations | [] |
| `certmanager.nodeSelector` | Specifies customized node selector for deployment | valid node selector | {} |

## Uninstalling the Chart

To uninstall/delete the `istio` release but continue to track the release:

```
$ helm delete istio
```

To uninstall/delete the `istio` release completely and make its name free for later use:

```
$ helm delete istio --purge
```

## Limitations

Currently, only one instance of Istio can be installed on a cluster at a time.
