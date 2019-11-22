# [IBM Tivoli Netcool/OMNIbus Message Bus Probe for Webhook Integration](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/message_bus/wip/concept/messbuspr_intro.html)

## Introduction

IBM® Netcool® Operations Insight enables IT and network operations teams to increase effectiveness, efficiency
and reliability by leveraging cognitive analytics capabilities to identify, isolate and resolve problems before
they impact your business. It provides a consolidated view across your local, cloud and hybrid environments and
delivers actionable insight into the health and performance of services and their associated dynamic network and
IT infrastructures. More information can be seen here: [IBM Marketplace - IT Operations Management](https://www.ibm.com/marketplace/it-operations-management)

## Chart Details

-   Deploys a IBM Tivoli Netcool/OMNIbus Message Bus Probe configured with the Webhook transport onto Kubernetes to receive JSON data via HTTP notifications from a target server.

-   The probe deployment is fronted by a service.

-   This chart can be deployed more than once on the same namespace.

## Prerequisites

-   Kubernetes version - 1.11.1.
-   Tiller version - 2.9.1
-   When connecting the probe as a HTTP client to a TLS enabled server, a pre-created Kubernetes secret which contains the remote Server certificate and a Keystore password is required. The expected keys in the secret are `server.crt` and `keystorepassword.txt`. Creating the secret requires Operator role or higher. The secret is then used in init container, the init container has to be fully executed before the actual container can start. To understand the status of the pod when init container is running, read through the link provided in the documentation section.
- Operator role is the minimum role required to install this chart.
  - Administrator role is required in order to:
    - Enable Pod Disruption Budget policy when installing the chart.
    - Retrieve sensitive information from a secret such as TLS certificate.
  - The chart must be installed by a Cluster Administrator to perform the following tasks in addition to those listed above:
    - Obtain the Node IP using `kubectl get nodes` command if using the NodePort service type.
    - Create a new namespace with custom PodSecurityPolicy if necessary. See PodSecurityPolicy Requirements [section](#podsecuritypolicy-requirements) for more details.

## Resources Required

-   CPU Requested : 100m (100 millicpu)
-   Memory Requested : 128Mi (~ 134 MB)

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart. The predefined PodSecurityPolicy definitions can be viewed [here](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/README.md).

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory. Detailed steps to create the PodSecurityPolicy is documented [here](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_common_psp.html).

* From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  * Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
    annotations:
        kubernetes.io/description: "This policy is based on the most restrictive policy,
        requiring pods to run with a non-root UID, and preventing pods from accessing the host."
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
    name: ibm-netcool-probe-messagebus-webhook-prod-psp
    spec:
    allowPrivilegeEscalation: false
    forbiddenSysctls:
    - '*'
    fsGroup:
        ranges:
        - max: 65535
        min: 1
        rule: MustRunAs
    hostNetwork: false
    hostPID: false
    hostIPC: false
    requiredDropCapabilities:
    - ALL
    runAsUser:
        rule: MustRunAsNonRoot
    seLinux:
        rule: RunAsAny
    supplementalGroups:
        ranges:
        - max: 65535
        min: 1
        rule: MustRunAs
    volumes:
    - configMap
    - emptyDir
    - projected
    - secret
    - downwardAPI
    - persistentVolumeClaim
    ```
  * Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-netcool-probe-messagebus-webhook-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-netcool-probe-messagebus-webhook-prod-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
  * RoleBinding for all service accounts in the current namespace. Replace `{{ NAMESPACE }}` in the template with the actual namespace.
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: ibm-netcool-probe-messagebus-webhook-prod-rolebinding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ibm-netcool-probe-messagebus-webhook-prod-clusterrole
    subjects:
    - apiGroup: rbac.authorization.k8s.io
      kind: Group
      name: system:serviceaccounts:{{ NAMESPACE }}
    ```
* From the command line, you can run the setup scripts included under pak_extensions.
  
  As a cluster administrator, the pre-install scripts and instructions are located at:
  * pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin/operator the namespace scoped scripts and instructions are located at:
  * pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

## Installing the Chart

To install the chart with the release name `my-mb-webhook-probe`:

1.  Extract the helm chart archive and customize `values.yaml`. The [configuration](#configuration) section lists the parameters that can be configured during installation.

2.  The command below shows how to install the chart with the release name `my-mb-webhook-probe` using the configuration specified in the customized `values.yaml`. Helm searches for the `ibm-netcool-probe-messagebus-webhook-prod` chart in the helm repository called `stable`. This assumes that the chart exists in the `stable` repository.

```sh
helm install --tls --namespace <your pre-created namespace> --name my-mb-webhook-probe -f values.yaml stable/ibm-netcool-probe-messagebus-webhook-prod
```

> **Tip**: List all releases using `helm list --tls` or search for a chart using `helm search`.

## Verifying the Chart

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release> --tls`.

## Uninstalling the Chart

To uninstall/delete the `my-mb-webhook-probe` deployment:

```sh
$ helm delete my-mb-webhook-probe --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Clean up any prerequisites that were created

As a Cluster Administrator, run the cluster administration clean up script included under pak_extensions to clean up cluster scoped resources when appropriate.

- post-delete/clusterAdministration/deleteSecurityClusterPrereqs.sh

As a Cluster Administrator, run the namespace administration clean up script included under pak_extensions to clean up namespace scoped resources when appropriate.

- post-delete/namespaceAdministration/deleteSecurityNamespacePrereqs.sh

## Configuration

The following tables lists the configurable parameters of the `ibm-netcool-probe-messagebus-webhook-prod` chart and their default values.

There are two components that can be configured for the probe:

-   HTTP Server (Webhook) to receive HTTP notifications (Main operation mode)
-   HTTP Client to pull or re-synchronize events from a target server. (Optional in addition to HTTP Sever)

### HTTP Server configuration

| Parameter                                               | Description                                                                                                                                                                                                                                                                               | Default                                  |
|---------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------|
| `license`                                               | The license state of the image being deployed. Enter `accept` to install and use the image.                                                                                                                                                                                               | `not accepted`                           |
| `replicaCount`                                          | Number of deployment replicas                                                                                                                                                                                                                                                             | `1`                                      |
| `global.image.secretName`                               | Name of the Secret containing the Docker Config to pull image from a private repository. Leave blank if the probe image already exists in the local image repository or the Service Account has been assigned with an Image Pull Secret.                                                  | `nil`                                    |
| `image.repository`                                      | Probe image repository. Update this repository name to pull from a private image repository. The image name should be set to `netcool-probe-messagebus`                                                                                                                                   | `netcool-probe-messagebus`               |
| `image.tag`                                             | Probe image tag                                                                                                                                                                                                                                                                           | `9.0.9`                                  |
| `image.testRepository`                                  | Utility image (busybox) repository. Update this repository name to pull from a private image repository.                                                                                                                                                                                  | `busybox`                                |
| `image.testImageTag`                                    | Utility image image tag.                                                                                                                                                                                                                                                                  | `1.28.4`                                 |
| `image.pullPolicy`                                      | Image pull policy                                                                                                                                                                                                                                                                         | `IfNotPresent`                           |
| `netcool.primaryServer`                                 | The primary Netcool/OMNIbus server the probe should connect to (required). Usually set to NCOMS or AGG_P.                                                                                                                                                                                 | `nil`                                    |
| `netcool.primaryHost`                                   | The host of the primary Netcool/OMNIbus server (required). Specify the Object Server Hostname or IP address.                                                                                                                                                                              | `nil`                                    |
| `netcool.primaryPort`                                   | The port number of the primary Netcool/OMNIbus server (required).                                                                                                                                                                                                                         | `nil`                                    |
| `netcool.backupServer`                                  | The backup Netcool/OMNIbus server to connect to. If the backupServer, backupHost and backupPort parameters are defined in addition to the primaryServer, primaryHost, and primaryPort parameters, the probe will be configured to connect to a virtual object server pair called `AGG_V`. | `nil`                                    |
| `netcool.backupHost`                                    | The host of the backup Netcool/OMNIbus server. Specify the Object Server Hostname or IP address.                                                                                                                                                                                          | `nil`                                    |
| `netcool.backupPort`                                    | The port of the backup Netcool/OMNIbus server.                                                                                                                                                                                                                                            | `nil`                                    |
| `probe.messageLevel`                                    | Probe log message level.                                                                                                                                                                                                                                                                  | `warn`                                   |
| `probe.heartbeatInterval`                               | Probe heartbeat interval (in seconds) to check the transport connection status.                                                                                                                                                                                                           | 1                                        |
| `probe.rulesConfigmap`                                  | If set,it overrides the template rules files with this ConfigMap containing a custom rules files in `message_bus.rules` key. Leave empty to use the default rules file template which can be customized later.                                                                            | `nil`                                    |
| `probe.jsonParserConfig.notification.messagePayload`    | Specifies the JSON tree to be identified as message payload from the notification (webhook) channel. See example for more details on how to configure the Probe's JSON parser.                                                                                                            | `json`                                   |
| `probe.jsonParserConfig.notification.messageHeader`     | Specifies the JSON tree to be identified as message header from the notification (webhook) channel. Attributes from the headers will be added to the generated event.                                                                                                                     | `nil`                                    |
| `probe.jsonParserConfig.notification.jsonNestedPayload` | Specifies the JSON tree within a nested JSON or JSON string to be identified as message payload from the notification (webhook) channel. The `probe.jsonParserConfig.notification.messagePayload` must be set to point to the attribute containing the JSON String.                       | `nil`                                    |
| `probe.jsonParserConfig.notification.jsonNestedHeader`  | Specifies the JSON tree within a nested JSON or JSON string to be identified as message header from the notification (webhook) channel. The `probe.jsonParserConfig.notification.messageHeader` must be set to point to the attribute containing the JSON String.                         | `nil`                                    |
| `probe.jsonParserConfig.notification.messageDepth`      | Specifies the number of levels in the message to traverse during parsing.                                                                                                                                                                                                                 | `3`                                      |
| `service.probe.type`                                    | Probe k8 service type exposing ports, e.g. `ClusterIP` or `NodePort`.                                                                                                                                                                                                                     | `ClusterIP`                              |
| `service.probe.externalPort`                            | External Port for this service                                                                                                                                                                                                                                                            | `80`                                     |
| `ingress.enabled`                                       | Ingress enabled                                                                                                                                                                                                                                                                           | `false`                                  |
| `ingress.hosts`                                         | Host to route requests based on. The Helm Release Name will be appended as a prefix. **Required** when using Ingress. Ignored when ingress is disabled and the default value can be used as dummy value to proceed with installation.                                                     | `netcool-probe-messagebus-webhook.local` |
| `ingress.annotations`                                   | Meta data to drive ingress class used, etc.                                                                                                                                                                                                                                               | `nil`                                    |
| `ingress.tls.enabled`                                   | Set to `true` to enable TLS to secure channel from external clients / hosts.                                                                                                                                                                                                              | `false`                                  |
| `ingress.tls.secretName`                                | TLS secret to secure channel from external clients / hosts. The secret _must_ contain `tls.crt` and `tls.key` entries. If `ingress.tls.enabled=true` and this parameter is unset, a TLS secret will be created.                                                                           | `nil`                                    |
| `ingress.tls.caName`                                    | A Certificate Authority name used to create the CA certificate when signing the TLS certificate. Used when  `ingress.tls.secretName` is unset.                                                                                                                                            | `IBM Netcool/OMNIbus Integration`        |
| `webhook.httpVersion`                                   | The version of the HTTP protocol to use. Supports 1.1 or 1.0.                                                                                                                                                                                                                             | `1.1`                                    |
| `webhook.uri`                                           | Probe's Webhook URI into which the target device will POST notifications.                                                                                                                                                                                                                 | `/probe`                                 |
| `webhook.respondWithContent`                            | Set to `ON` to specify whether the probe includes the HTTP body received from the client HTTP request in the HTTP response.                                                                                                                                                               | `OFF`                                    |
| `webhook.validateBodySyntax`                            | Set to `ON` to perform a JSON format check on the HTTP request body.                                                                                                                                                                                                                      | `ON`                                     |
| `webhook.validateRequestURI`                            | Set this property to ON to enable URI path check. Setting this property to OFF disables the URI check and the webhook will accept all HTTP request regardless of the path set.                                                                                                            | `ON`                                     |
| `webhook.idleTimeout`                                   | The time (in seconds) to allow an idle HTTP client to be connected.                                                                                                                                                                                                                       | `180`                                    |
| `webhook.keepTokens`                                    | A comma-separated list of the attributes that the probe extracts from the incoming JSON data. These data items can be used in token substitution                                                                                                                                          | `nil`                                    |
| `autoscaling.enabled`                                   | Set to `false` to disable auto-scaling                                                                                                                                                                                                                                                    | true                                     |
| `autoscaling.minReplicas`                               | Minimum number of probe replicas                                                                                                                                                                                                                                                          | `2`                                      |
| `autoscaling.maxReplicas`                               | Maximum number of probe replicas                                                                                                                                                                                                                                                          | `5`                                      |
| `autoscaling.cpuUtil`                                   | The target CPU utilization (in percentage). Example: `60` for 60% target utilization.                                                                                                                                                                                                     | `60`                                     |
| `poddisruptionbudget.enabled`                           | Set to `true` to enable Pod Disruption Budget to maintain high availability during a node maintenance. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control enabled.                                                       | `false`                                  |
| `poddisruptionbudget.minAvailable`                      | The minimum number of available pods during node drain. Can be set to a number or percentage, eg: 1 or 10%. Caution: Setting to 100% or equal to the number of replicas may block node drains entirely.                                                                                   | `1`                                      |
| `resources.limits.memory`                               | Memory resource limits                                                                                                                                                                                                                                                                    | `512Mi`                                  |
| `resources.limits.cpu`                                  | CPU resource limits                                                                                                                                                                                                                                                                       | `500m`                                   |
| `resources.requests.cpu`                                | CPU resource requests                                                                                                                                                                                                                                                                     | `100m`                                   |
| `resources.requests.memory`                             | Memory resource requests                                                                                                                                                                                                                                                                  | `128Mi`                                  |
| `arch`                                                  | Worker node architecture. Fixed to `amd64`.                                                                                                                                                                                                                                               | `amd64`                                  |

### HTTP Client Configuration

(Optional) In addition to the above HTTP Server configuration, the probe can also be configured as a client to send HTTP requests such as to pull data (re-synchronization) from a server. Below are the HTTP Client component configuration parameters.

| Parameter                                         | Description                                                                                                                                                                                                                                                                                | Default |
|---------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| `probe.host`                                      | The target server IP or hostname.                                                                                                                                                                                                                                                          | `nil`   |
| `probe.port`                                      | The target server port.                                                                                                                                                                                                                                                                    | 80      |
| `probe.username`                                  | The username to use when authenticating with the target server.                                                                                                                                                                                                                            | `nil`   |
| `probe.password`                                  | The password to use when authenticating with the target server.                                                                                                                                                                                                                            | `nil`   |
| `probe.initialResync`                             | Set to `true` to send a re-synchronization request before sending a subscription request.                                                                                                                                                                                                  | `false` |
| `probe.resyncInterval`                            | The interval (in seconds) to check the transport connection status.                                                                                                                                                                                                                        | 0       |
| `probe.sslSecretName`                             | A pre-created Kubernetes secret containing `server.crt` and `keystorepassword.txt` keys. It is required when connecting to a HTTP server with TLS.                                                                                                                                         | `nil`   |
| `probe.jsonParserConfig.resync.messagePayload`    | Specifies the JSON tree to be identified as message payload from re-synchronization (HTTP REST API). See example for more details on how to configure the Probe's JSON parser.                                                                                                             | `json`  |
| `probe.jsonParserConfig.resync.messageHeader`     | Specifies the JSON tree to be identified as message header from re-synchronization (HTTP REST API). Attributes from the headers will be added to the generated event.                                                                                                                      | `nil`   |
| `probe.jsonParserConfig.resync.jsonNestedPayload` | Specifies the JSON tree within a nested JSON or JSON string to be identified as message payload from re-synchronization (HTTP REST API). The `probe.jsonParserConfig.resync.messagePayload` must be set to point to the attribute containing the JSON String.                              | `nil`   |
| `probe.jsonParserConfig.resync.jsonNestedHeader`  | Specifies the JSON tree within a nested JSON or JSON string to be identified as message header from re-synchronization (HTTP REST API). The `probe.jsonParserConfig.resync.messageHeader` must be set to point to the attribute containing the JSON String.                                | `nil`   |
| `probe.jsonParserConfig.resync.messageDepth`      | Specifies the number of levels in the message to traverse during parsing.                                                                                                                                                                                                                  | `3`     |
| `webhook.httpHeaders`                             | A comma-separated list of HTTP header options to use in all HTTP requests.Accepts key-value pairs using the equals sign (=) as the value separator. For example, `Accept=application/json,Content-Type=application/json,Use-Cookie=true,User-Agent=IBM Netcool/OMNIBus Message Bus Probe`. | `nil`   |
| `webhook.responseTimeout`                         | The time  (in seconds) the probe waits for a response from the target system before timing out.                                                                                                                                                                                            | `60`    |
| `webhook.autoReconnect`                           | Set to `ON` to re-establish the connection to the remote HTTP server when disconnected.                                                                                                                                                                                                    | `ON`    |
| `webhook.keepTokens`                              | A comma-separated list of the attributes that the probe extracts from the incoming JSON data. These data items can be used in token substitution in subsequent HTTP requests header or body.                                                                                               | `nil`   |
| `webhook.securityProtocol`                        | The security protocol to use when retrieving events from the REST API with TLS. Example: TLSv1.2, TLSv1.1 or TLSv1.0. The `probe.sslSecretName` is required.                                                                                                                               | `nil`   |
| `webhook.loginRequest.uri`                        | The URI that the probe uses to request a login. For example, can be used to obtain an access token.                                                                                                                                                                                        | `nil`   |
| `webhook.loginRequest.method`                     | The HTTP method for the login request.                                                                                                                                                                                                                                                     | `nil`   |
| `webhook.loginRequest.headers`                    | A comma-separated list of HTTP header options for login request. Overrides any header set in `webhook.httpHeaders`                                                                                                                                                                         | `nil`   |
| `webhook.loginRequest.content`                    | The HTTP body to send in the login request.                                                                                                                                                                                                                                                | `nil`   |
| `webhook.resyncRequest.uri`                       | The URI that the probe uses to pull (resync) data.                                                                                                                                                                                                                                         | `nil`   |
| `webhook.resyncRequest.method`                    | The HTTP method for the resync request.                                                                                                                                                                                                                                                    | `nil`   |
| `webhook.resyncRequest.headers`                   | A comma-separated list of HTTP header options for resync request. Overrides any header set in `webhook.httpHeaders`                                                                                                                                                                        | `nil`   |
| `webhook.resyncRequest.content`                   | The HTTP body to send in the resync request.                                                                                                                                                                                                                                               | `nil`   |
| `webhook.subscribeRequest.uri`                    | The URI that the probe uses to create a subscription for notification.                                                                                                                                                                                                                     | `nil`   |
| `webhook.subscribeRequest.method`                 | The HTTP method for the subscription request.                                                                                                                                                                                                                                              | `nil`   |
| `webhook.subscribeRequest.headers`                | A comma-separated list of HTTP header options for subscription request. Overrides any header set in `webhook.httpHeaders`                                                                                                                                                                  | `nil`   |
| `webhook.subscribeRequest.content`                | The HTTP body to send in the subscription request.                                                                                                                                                                                                                                         | `nil`   |
| `webhook.loginRefresh.uri`                        | The URI that the probe uses to refresh a login. For example, can be used to refresh an access token.                                                                                                                                                                                       | `nil`   |
| `webhook.loginRefresh.method`                     | The HTTP method for the login refresh request.                                                                                                                                                                                                                                             | `nil`   |
| `webhook.loginRefresh.headers`                    | A comma-separated list of HTTP header options for login refresh request. Overrides any header set in `webhook.httpHeaders`                                                                                                                                                                 | `nil`   |
| `webhook.loginRefresh.content`                    | The HTTP body to send in the login refresh request.                                                                                                                                                                                                                                        | `nil`   |
| `webhook.loginRefresh.interval`                   | The interval (in seconds) between successive refresh requests.                                                                                                                                                                                                                             | `nil`   |
| `webhook.subscribeRefresh.uri`                    | The URI that the probe uses to refresh the subscription.                                                                                                                                                                                                                                   | `nil`   |
| `webhook.subscribeRefresh.method`                 | The HTTP method for the subscription refresh request.                                                                                                                                                                                                                                      | `nil`   |
| `webhook.subscribeRefresh.headers`                | A comma-separated list of HTTP header options for subscription refresh request. Overrides any header set in `webhook.httpHeaders`                                                                                                                                                          | `nil`   |
| `webhook.subscribeRefresh.content`                | The HTTP body to send in the subscription refresh request.                                                                                                                                                                                                                                 | `nil`   |
| `webhook.subscribeRefresh.interval`               | The interval (in seconds) between successive refresh requests.                                                                                                                                                                                                                             | `nil`   |
| `webhook.refreshRetryCount`                       | The number of attempts to re-send the refresh requests before disconnecting from the server. This is used when the probe receives a non-OK refresh response.                                                                                                                               | 0       |
| `webhook.logoutRequest.uri`                       | The URI that the probe uses to request a logout. For example, can be used to delete a subscription on the target server.                                                                                                                                                                   | `nil`   |
| `webhook.logoutRequest.method`                    | The HTTP method for the logout request.                                                                                                                                                                                                                                                    | `nil`   |
| `webhook.logoutRequest.headers`                   | A comma-separated list of HTTP header options for logout request. Overrides any header set in `webhook.httpHeaders`                                                                                                                                                                        | `nil`   |
| `webhook.logoutRequest.content`                   | The HTTP body to send in the logout request.                                                                                                                                                                                                                                               | `nil`   |

You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install` to override any of the parameter value from the command line. For example `helm install --tls --namespace <namespace> --name my-mb-webhook-probe --set license=accept,probe.messageLevel=debug` to set the `license` parameter to `accept` and `probe.messageLevel` to `debug`.

## Limitations

-   Only supports amd64 architecture.
-   Validated to run on IBM Cloud Private 3.1.0 and 3.1.1
-   Only supports parsing JSON events from event sources.
-   There is known issue on the IBM Cloud Private UI where YAML object keys with dot (.) character is not rendered correctly. This affects the `ingress.annotations` parameter where the keys usually contain dot character. 

## Documentation

-   [IBM Tivoli Netcool/OMNIbus Message Bus Probe for Webhook Integrations Helm Chart](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/messagebus_webhook/wip/concept/mbweb_intro.html)
-   [IBM Tivoli Netcool/OMNIbus Probes and Gateways Helm Charts](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/common/Helms.html)
-   [IBM Tivoli Netcool/OMNIBus Probe for Message Bus Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/message_bus/wip/concept/messbuspr_intro.html)
-   [Init container: Understanding Pod status](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-init-containers/#understanding-pod-status)
-   [Using helm CLI](https://github.com/helm/helm/blob/master/docs/using_helm.md)

# Troubleshooting

| Problem                                                                                                                                                                                                                            | Cause                                                                                                                                                                                                                     | Resolution                                                                                                                                                                                                                                                                                                                                           |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Ingress annotation set during installation via ICP UI does not render correctly.                                                                                                                                                   | There is known issue on the IBM Cloud Private UI where YAML object keys with dot (.) character is not rendered correctly. This affects the `ingress.annotations` parameter where the keys usually contains dot character. | A fix will be delivered in the next ICP version. As a workaround, use the command-line to install the chart in order to set additional ingress annotations.                                                                                                                                                                                          |
| There are no events seen in the Object Server event list even though there are events sent to the probe endpoint and "Event Processor" log messages are seen in the probe debug log (needs to be configured to run in debug mode). | A potential cause is because the probe rules file is not configured correctly to parse tokens generated by the probe JSON parser.                                                                                         | By default, the probe starts using the default rules files. Configure the probe to use a custom rules file by creating a Configmap from a file. See [Creating An Overriding Rules Config Map](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/common/topicref/hlm_mb_override_default_rules_config.html) guide for more details. |