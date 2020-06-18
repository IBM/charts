# IBM Watson Addon Chart 🇦🇷

![helm-chart](https://img.shields.io/badge/helm_chart_version-v3.2.4-green.svg) ![watson-gateway](https://img.shields.io/badge/watson_gateway_docker_image-v3.4.1-green.svg)

# Introduction

This chart deploys the `watson-gateway` Docker image to the IBM Cloud Pak for Data environment, allowing users to manage service instances and access the tooling.

## Chart Details

The Docker image includes:

- Watson Add-on: Adds an add-on to the Cloud Pak for Data add-ons page in the AI category
- Ingress and authorization configuration for tooling: `/<release-name>/<service-name>`
- Ingress configuration for API: `/<release-name>/<service-name>/<service-instance>/instances/api`
- IBM Cloud Account and Resource Controller API mocks (to be used by tooling)
- Injects `X-Watson-UserInfo` to the API requests: `/<release-name>/<service-name>/instances/<service-instance>/api`

## Prerequisites

- IBM Cloud Pak for Data 2.5.0.0 or later
- Kubernetes 1.11 or later
- Tiller 2.9.0 or later
- `watson-gateway` docker image
- `opencontent-common-utils` docker image
- This chart includes a `PodDisruptionBudget` for high resiliency

## Resources Required

| Container      | Memory Request | Memory Limit | CPU Request | CPU Limit |
| -------------- | -------------- | ------------ | ----------- | --------- |
| watson-gateway | 100Mi          | 150Mi        | 100m        | 500m      |

## Pre-install steps

The gateway has two scripts that need to be run.

### `labelNamespace.sh`

Should be run once per cluster

```sh
./ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration/labelNamespace.sh CP4D_NAMESPACE>
```

Where `<CP4D_NAMESPACE>` is the namespace where CP4D is installed (usually `zen`).
The `<CP4D_NAMESPACE>` namespace **must** have a label for the `NetworkPolicy` to correctly work. Only nginx and zen pods will be able allowed to communicate with the pods in the namespace where this chart is installed.

### `deleteInstances.sh`

Should be run before every installation

```sh
./ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration/deleteInstances.sh <CP4D_NAMESPACE>
```

Where `<CP4D_NAMESPACE>` is the namespace where CP4D is installed (usually `zen`).
The scripts removes instances that were deleted as part of a previous installation

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install --tls --name my-release ibm-watson-gateway
```

This command deploys a tooling instance with sane defaults.

After the command runs, it prints the current status of the release. You can also access the Watson add-on page through the IBM Cloud Pak for Data UI:

1.  From any page, navigate to **Add-ons** icon in the top right corner.
1.  Click the **AI** category. The Watson add-on should be there.

> **Tip**: List all releases using `helm list`

## Verifying the Chart

See the instruction (from `NOTES.txt` within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: `helm status my-release --tls`.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm delete my-release --purge
```

The command removes almost all the Kubernetes components associated with the chart and deletes the release.
The chart creates a TLS secret with a helm `pre-hook`. In order to remove it use:

```
kubectl get secrets -l release=my-release
```

And then delete the secret using:

```
kubectl delete secret <secret-name>
```

## Service Account

The chart needs to create a secret and add a label to the namespace where CP4D is installed.
Users can specify an account with permission to do the operation previously described otherwise the chart will create a new service account for this.

- Set `privilegedServiceAccount.name` to specify the account for privileged operations, creating a secret or adding a label to a namespace
  - **Note**: if you specify a service account the permissions **must** have at least the permissions in the following [role](./templates/07-role.yaml)
- Set `serviceAccount.name` to specify the account to use when running the deployment/pod

**Tip:** You can specify a `tpl` function as value

```yml
privilegedServiceAccount:
  name: { { .Values.global.serviceAccount.name } }
```

## Configuration

### 🖼 Addon

The `addon` parameters control the information that the Addon will show to users in the Cloud Pak for Data Addons page

| Parameter                             | Description                                                                                                                              | Default                                                                                                            |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `displayName`                         | The name to be displayed in the addons page                                                                                              | Watson Assistant                                                                                                   |
| `platformVersion`                     | The Cloud Pak for Data version. For 2.X the addon uses Carbon 9 and starting from 3.x Carbon 10                                          |
| `version`                             | The addon version to be used when provisioning instances. <br/>**It should match the `Chart.Version` in the umbrella chart**             | This chart version                                                                                                 |
| `shortDescription`                    | Short description (up to 140 characters) of the addon. This is what is displayed in the cards within the addons grid                     | Watson Assistant lets you build conversational interfaces into any application, device, or channel.                |
| `longDescription`                     | Detailed explanation of the addon to be exposed in the Addon details page                                                                | Watson Assistant is an offering for building conversational interfaces into any application, device, or channel... |
| `serviceId`                           | The service id to be use in tooling, api and other urls                                                                                  | `assistant`                                                                                                        |
| `maxInstances`                        | Max number of service instances that can be provisioned                                                                                  | `20`                                                                                                               |
| `maxDeployments`                      | Max number of service deployments existing in the catalog (setting to 1 will override the placeholder and only allows for 1 deployment)  | `''`                                                                                                               |
| `deployDocs`                          | URL to the documentation on how to deploy this addon.                                                                                    | `.../docs/services/discovery-data`                                                                                 |
| `productDocs`                         | URL to the documentation on how to use this addon within Cloud Pak for Data.                                                             | `.../docs/services/discovery-data`                                                                                 |
| `productImages`                       | The number of images to display in the addon detail page. Use 0 if the addon detail page should not display images                       | `0`                                                                                                                |
| `instanceId`                          | The hardcoded instance id that will be used as part of the `X-Watson-UserInfo` header. Make sure that `addon.maxInstances` is set to `1` | `''`                                                                                                               |
| `organizationId`                      | The hardcoded organization/resource group id that will be used as part of the `X-Watson-UserInfo` header and during provisioning calls   | `ba4ab788-68a9-492b-87da-9179cb1e6541`                                                                             |
| `accountId`                           | The hardcoded account id that will be used as part of the `X-Watson-UserInfo` header and in the account managment api                    | `02a92df0-657c-43c9-94fc-2280450b1e0b`                                                                             |
| `planId`                              | The hardcoded plan id that will be used as part of the `X-Watson-UserInfo` header                                                        | `cec95e99-75b8-4e2f-a176-8687f31597fd`                                                                             |
| `apiReferenceDocs`                    | URL to the API Reference page. Leave it empty if your service doesn't have an API Reference page                                         | `https://cloud.ibm.com/apidocs`                                                                                    |
| `gettingStartedDocs`                  | URL to the Getting Started documentation page. Leave it empty if your service doesn't have an Getting Started page                       | `https://cloud.ibm.com/docs/watson`                                                                                |
| `showUserManagement`                  | True if there should be a tab in the instance dashboard to add/edit/remove users.                                                        | `true`                                                                                                             |
| `showCredentials`                     | True if the generated service credentials should be displayed in the instance dashboard.                                                 | `true`                                                                                                             |
| `disableUpgrade`                      | True if the chart should fail on helm upgrade.                                                                                           | `true`                                                                                                             |
| `networkPolicy.enable`                | Whether or not to enable NetworkPolicies securing this service                                                                           | `true`                                                                                                             |
| `networkPolicy.additionalLabels`      | Any additional pod labels (in your namespace) that need to access your service                                                           | `{}`                                                                                                               |
| `tls.image.repository`                | Docker image repository that will be used to create the TLS secret                                                                       | `opencontent-common-utils`                                                                                         |
| `tls.image.name`                      | Docker image tag that will be used to create the TLS secret                                                                              | `1.1.2-amd64`                                                                                                      |
| `tls.image.hooks.create.type`         | Type of the hook for tls secret creation. If an empty string, it is run as a standard job and not as a hook.                             | `pre-install`                                                                                                      |
| `tls.image.hooks.create.weight`       | Weight of the hook for tls secret creation. Specifies order of the hooks w.r.t. the other hooks of the same type.                        | `-1`                                                                                                               |
| `tls.image.hooks.create.deletePolicy` | Hook delete policy specifies what happens with the tls secret creation job when hook completes.                                          | `hook-succeeded`                                                                                                   |
| `tls.image.hooks.delete.type`         | Type of the hook for tls secret clean-up job.                                                                                            | `post-delete`                                                                                                      |
| `tls.image.hooks.delete.weight`       | Weight of the hook for tls secret clean-up. Specifies order of the hooks w.r.t. the other hooks of the same type.                        | `0`                                                                                                                |
| `tls.image.hooks.delete.deletePolicy` | Hook delete policy specifies what happens with the tls secret cleanup job when hook completes.                                           | `hook-succeeded`                                                                                                   |
| `addonService.antiAffinity.policy`    | Policy for anti affinity of the gateway pod. If **soft** is set, the scheduler tries to create the pods on nodes (with the default topology key) not to co-locate them, but it will not be guaranteed. If **hard**, the scheduler tries to create the pods on nodes not to co-locate them and will not create the pods in case of co-location. If the other value, anti affinity is disabled. | `soft` |
| `addonService.antiAffinity.topologyKey` | Key for the node label that the system uses to denote a topology domain. | `kubernetes.io/hostname` |

### 🛳 Backend Service

The `backendService` parameters help the Addon route requests to the backend service where the API is running. If your addon uses different services then configure the main one here and the rest using the [Additional Services](#-additional-services).

| Parameter         | Description                                                                                                                                                                                                         | Default                                                |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `name`            | Name of the kubernetes service to which terminate the requests from API requests                                                                                                                                    | discovery-frontend                                     |
| `nameTemplate`    | Helm template helper used to get the service name associated with the API                                                                                                                                           | `""`                                                   |
| `namespace`       | Namespace where the API service lives                                                                                                                                                                               | Defaults to the namespace where the chart is installed |
| `port`            | Port to access the API service                                                                                                                                                                                      | `8443`                                                 |
| `secure`          | True if your service uses HTTPS                                                                                                                                                                                     | `true`                                                 |
| `brokerPath`      | If set, a provisioning callback will be sent to `{backend-service-url}` using `{broker-path}/{instanceId}` as path. An empty string value (default) disables provisioning                                                                           | `''`                                                   |
| `rewriteTarget`   | Set to `/` if you want requests to have their path stripped. The value should start and end with `/`</br> For example, if your API expects requests to be `/api/v1/environment` you will use `/api/`                | `/`                                                    |
| `exposeAPI`       | True if the service exposes an `/api/` endpoint. Watson Knowledge Studio will set this to `false`.                                                                                                                  | `true`                                                 |
| `nginxDirectives` | List of nginx directives that will be used in the location. Use directives if you need to specify parameteres like proxy timeout, body limit or connection timeout.<br/>For example: `proxy_set_header Host $host;` | `[]`                                                   |
| `authentication` | If set to false we skip JWT token checking for this path | `true`                                                   |

### ➕ Additional Services

If you need to specify multiple kubernetes services depending on the API call, you will configure _Additional Services_

| Parameter            | Description                                                     | Default |
| -------------------- | --------------------------------------------------------------- | ------- |
| `additionalServices` | A list of `backendService` elements to add as additional routes | `[]`    |

### 💻 Additional Toolings

If you need to specify multiple tooling services, you will configure _Additional Toolings_

| Parameter            | Description                                       | Default |
| -------------------- | ------------------------------------------------- | ------- |
| `additionalToolings` | A list of `tooling` elements with a `path` route. | `[]`    |

### 🔧 Tooling

For addons with Tooling, the tooling parameters should be configure so that the addon knows how to talk to the tooling and the URLs that the users see can route to the appropiate kubernetes service

| Parameter         | Description                                                                                                                                                                                                         | Default                                                |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `enable`          | Set to `true` if tooling routing should be configured                                                                                                                                                               | `false`                                                |
| `name`            | Name of the tooling kubernetes service                                                                                                                                                                              | watson-tooling                                         |
| `nameTemplate`    | Helm template helper used to get the service name associated with the tooling                                                                                                                                       | `""`                                                   |
| `namespace`       | Namespace where the API tooling lives                                                                                                                                                                               | Defaults to the namespace where the chart is installed |
| `port`            | Port to access the tooling service                                                                                                                                                                                  | `8443`                                                 |
| `rewriteTarget`   | Set to `/` if you want requests to have their path stripped. The value should start and end with `/`</br> For example, if your Tooling expects requests to be `/tooling/index.html` you will use `/tooling/`        | `/`                                                    |
| `secure`          | set to true if your tooling kubernetes service requires https                                                                                                                                                       | `true`                                                 |
| `nginxDirectives` | List of nginx directives that will be used in the location.<br/>For example `proxy_set_header Host $host;`. Use directives if you need to specify parameteres like proxy timeout, body limit or connection timeout. | `[]`                                                   |

### 🌍 Global parameters

Global parameters that will be set by the umbrella chart.

| Parameter                 | Description                                                             | Default |
| ------------------------- | ----------------------------------------------------------------------- | ------- |
| `global.image.repository` | The Cloud Pak for Data Docker repository URL. https://{{icpDockerRepo}} | `empty` |
| `global.image.pullSecret` | The Cloud Pak for Data Docker repository image secret | `empty` |
| `global.appName` | The application name to be used by sch | `watson-gateway` |
| `autoscaling.enabled` | True if autoscaling is enabled | `true` |
| `preInstallValidation` | True if the CPD installation in `zenNamespace` should be validated before installing the addon | `true` |
| `metering.productName` | Specified the product name for metering annotations | The value of `addon.displayName` |
| `metering.productID` | Specified the product ID for metering annotations | `ICP4D-addon-IBMWatsonAddon-{{ .ReleaseName }}-{{ addon.serviceId }}` |
| `metering.productVersion` | Specified the product version for metering annotations | `2.1.13` |
| `topologySpreadConstraints.enabled`           | Specifies whether the topology spread contraints should be added to gateway deployment | `false`                                    |
| `topologySpreadConstraints.maxSkew`           | How much the availability zones can differ in number of pods.                          | `1`                                        |
| `topologySpreadConstraints.topologyKey`       | Label of nodes defining availability/failure zone                                      | `failure-domain.beta.kubernetes.io/zone`   |
| `topologySpreadConstraints.whenUnsatisfiable` | Action in case new pod cannot be scheduled because topology contraints.                | `ScheduleAnyway`                           |

### Afinity configuration

Node/pod affinities for SIRE pods. If specified overrides default affinity ("sch.affinity.nodeAffinity") to run on any amd64 node. Use `affinities`

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/e2e-az-name
              operator: In
              values:
                - e2e-az1
                - e2e-az2
```

### NGINX configuration

The following headers will be set by default as part of the nginx configuration, you can use `nginxDirectives` to set other directives

```nginx
proxy_set_header  Host $host;
proxy_set_header  X-Real-IP $remote_addr;
proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header  X-Forwarded-Proto $scheme;
```

### WebSockets

Adding support for WebSockets can be done using the `nginxDirectives`.

```yaml
nginxDirectives:
  - "proxy_http_version 1.1;"
  - "proxy_set_header Upgrade $http_upgrade;"
  - 'proxy_set_header Connection "upgrade";'
```

## SecurityContext

If `schConfigName` is set, the following `SecurityContext` should be specified in the sch configuration.

```yaml
    securityContextSpec:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
{{- end }}
    securityContextContainer:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
{{- end }}
        privileged: false
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}
```

## PodSecurityPolicy Requirements

The predefined PodSecurityPolicy name [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

Custom PodSecurityPolicy definition:

```yml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-restricted-psp
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
    - "*"
  fsGroup:
    ranges:
      - max: 65535
        min: 1
    rule: MustRunAs
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

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

Custom SecurityContextConstraints definition:

```yml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    cloudpak.ibm.com/version: "1.0.0"
  name: ibm-restricted-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: false
allowedCapabilities: []
allowedFlexVolumes: []
allowedUnsafeSysctls: []
defaultAddCapabilities: []
defaultPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
fsGroup:
  type: MustRunAs
  ranges:
    - max: 65535
      min: 1
readOnlyRootFilesystem: false
requiredDropCapabilities:
  - ALL
runAsUser:
  type: MustRunAsNonRoot
seccompProfiles:
  - docker/default
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: MustRunAs
  ranges:
    - max: 65535
      min: 1
volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
priority: 0
```

## Limitations

- Watson Gateway only runs on Intel architecture nodes.
- This chart should only use the default image tags provided with the chart. Different image versions might not be compatible with different versions of this chart.

_Copyright© IBM Corporation 2019. All Rights Reserved._
