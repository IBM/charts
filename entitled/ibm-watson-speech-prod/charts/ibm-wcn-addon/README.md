# IBM Watson Addon Chart 🇦🇷

![helm-chart](https://img.shields.io/badge/helm_chart_version-v1.60.2-green.svg) ![wcn-addon](https://img.shields.io/badge/wcn_addon_docker_image-v1.50.2-green.svg)

# Introduction

This chart deploys the `wcn-addon` docker image to the IBM Cloud Pak for Data environment.

The docker image includes:

- Watson Addon: Adds an addon to the Cloud Pak for Data addons page in the AI category.
- Ingress and authorization configuration for tooling `/<release-name>/<service-name>`
- Ingress configuration for API `/<release-name>/<service-name>/<service-instance>/instances/api`
- IBM Cloud Account and Resource Controller API mocks(to be used by tooling).
- Injects `X-Watson-UserInfo` to the API requests. `/<release-name>/<service-name>/instances/<service-instance>/api`

# Prerequisites

- IBM Cloud Pak for Data 1.2.1.0
- Kubernetes 1.11 or later
- Tiller 2.9.0 or later
- `wcn-addon` docker image
- `opencontent-common-utils` docker image

# Resources Required

| Container | Memory Request | Memory Limit | CPU Request | CPU Limit |
| --------- | -------------- | ------------ | ----------- | --------- |
| wcn-addon | 100Mi          | 150Mi        | 100m        | 500m      |

## Pre-install steps

The addon has two scripts that needs to be run.

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
helm install --name my-release ibm-wcn-addon
```

This command deploys a tooling instance with sane defaults.

After the command runs, it prints the current status of the release. You can also access the addon page through the IBM Cloud Pak for Data UI:

1.  From any page, navigate to **Add-ons** icon in the top right corner.
1.  Click the **AI** category. The Watson addon should be there.

> **Tip**: List all releases using `helm list`

## Verifying the Chart

See NOTES.txt associated with this chart for verification instructions

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
- Set `serviceAccount.name` to specify the account to use when running the deployment/pod

**Tip:** You can specify a `tpl` function as value

```yml
privilegedServiceAccount:
  name: { { .Values.global.serviceAccount.name } }
```

## Chart Details

🔬

## Configuration

### 🖼 Addon

The `addon` parameters control the information that the Addon will show to users in the Cloud Pak for Data Addons page

| Parameter                        | Description                                                                                                                              | Default                                                                                                            |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `displayName`                    | The name to be displayed in the addons page                                                                                              | Watson Assistant                                                                                                   |
| `version`                        | The addon version to be used when provisioning instances. <br/>**It should match the `Chart.Version` in the umbrella chart**             | This chart version                                                                                                 |
| `shortDescription`               | Short description (up to 140 characters) of the addon. This is what is displayed in the cards within the addons grid                     | Watson Assistant lets you build conversational interfaces into any application, device, or channel.                |
| `longDescription`                | Detailed explanation of the addon to be exposed in the Addon details page                                                                | Watson Assistant is an offering for building conversational interfaces into any application, device, or channel... |
| `serviceId`                      | The service id to be use in tooling, api and other urls                                                                                  | `assistant`                                                                                                        |
| `maxInstances`                   | Max number of service instances that can be provisioned                                                                                  | `20`                                                                                                               |
| `maxDeployments`                 | Max number of service deployments existing in the catalog (setting to 1 will override the placeholder and only allows for 1 deployment)  | `''`                                                                                                               |
| `deployDocs`                     | URL to the documentation on how to deploy this addon.                                                                                    | `.../docs/services/discovery-data`                                                                                 |
| `productDocs`                    | URL to the documentation on how to use this addon within Cloud Pak for Data.                                                             | `.../docs/services/discovery-data`                                                                                 |
| `productImages`                  | The number of images to display in the addon detail page. Use 0 if the addon detail page should not display images                       | `0`                                                                                                                |
| `instanceId`                     | The hardcoded instance id that will be used as part of the `X-Watson-UserInfo` header. Make sure that `addon.maxInstances` is set to `1` | `''`                                                                                                               |
| `organizationId`                 | The hardcoded organization/resource group id that will be used as part of the `X-Watson-UserInfo` header and during provisioning calls   | `ba4ab788-68a9-492b-87da-9179cb1e6541`                                                                             |
| `accountId`                      | The hardcoded account id that will be used as part of the `X-Watson-UserInfo` header and in the account managment api                    | `02a92df0-657c-43c9-94fc-2280450b1e0b`                                                                             |
| `planId`                         | The hardcoded plan id that will be used as part of the `X-Watson-UserInfo` header                                                        | `cec95e99-75b8-4e2f-a176-8687f31597fd`                                                                             |
| `apiReferenceDocs`               | URL to the API Reference page. Leave it empty if your service doesn't have an API Reference page                                         | `https://cloud.ibm.com/apidocs`                                                                                    |
| `gettingStartedDocs`             | URL to the Getting Started documentation page. Leave it empty if your service doesn't have an Getting Started page                       | `https://cloud.ibm.com/docs/watson`                                                                                |
| `showUserManagement`             | True if there should be a tab in the instance dashboard to add/edit/remove users.                                                        | `true`                                                                                                             |
| `showCredentials`                | True if the generated service credentials should be displayed in the instance dashboard.                                                 | `true`                                                                                                             |
| `disableUpgrade`                 | True if the chart should fail on helm upgrade.                                                                                           | `true`                                                                                                             |
| `networkPolicy.enable`           | Whether or not to enable NetworkPolicies securing this service                                                                           | `true`                                                                                                             |
| `networkPolicy.additionalLabels` | Any additional pod labels (in your namespace) that need to access your service                                                           | `{}`                                                                                                               |
| `tls.image.repository`           | Docker image repository that will be used to create the TLS secret                                                                       | `opencontent-common-utils`                                                                                         |
| `tls.image.name`                 | Docker image tag that will be used to create the TLS secret                                                                              | `1.1.2-amd64`                                                                                                      |

### 🛳 Backend Service

The `backendservice` parameters help the Addon route requests to the backend service where the API is running. If your addon uses different services then configure the main one here and the rest using the [Additional Services](#-additional-services).

| Parameter         | Description                                                                                                                                                                                                         | Default                                                |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| `name`            | Name of the kubernetes service to which terminate the requests from API requests                                                                                                                                    | discovery-frontend                                     |
| `nameTemplate`    | Helm template helper used to get the service name associated with the API                                                                                                                                           | `""`                                                   |
| `namespace`       | Namespace where the API service lives                                                                                                                                                                               | Defaults to the namespace where the chart is installed |
| `port`            | Port to access the API service                                                                                                                                                                                      | `8443`                                                 |
| `secure`          | True if your service uses HTTPS                                                                                                                                                                                     | `true`                                                 |
| `brokerPath`      | If set, a provisioning callback will be sent to `{backend-service-url}` using `/{broker-path}/v2/service_instances/{instanceId}` as path                                                                            | `''`                                                   |
| `rewriteTarget`   | Set to `/` if you want requests to have their path stripped. The value should start and end with `/`</br> For example, if your API expects requests to be `/api/v1/environment` you will use `/api/`                | `/`                                                    |
| `exposeAPI`       | True if the service exposes an `/api/` endpoint. Watson Knowledge Studio will set this to `false`.                                                                                                                  | `true`                                                 |
| `nginxDirectives` | List of nginx directives that will be used in the location. Use directives if you need to specify parameteres like proxy timeout, body limit or connection timeout.<br/>For example: `proxy_set_header Host $host;` | `[]`                                                   |

### ➕ Additional Services

If you need to specify multiple kubernetes services depending on the API call, you will configure _Additional Services_

| Parameter            | Description                                                     | Default |
| -------------------- | --------------------------------------------------------------- | ------- |
| `additionalServices` | A list of `backendService` elements to add as additional routes | `[]`    |

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

| Parameter               | Description                                                              | Default     |
| ----------------------- | ------------------------------------------------------------------------ | ----------- |
| `global.i cpDockerRepo` | The Cloud Pak for Data Docker repository URL. https://{{i cpDockerRepo}} | `empty`     |
| `global.appName`        | The application name to be used by sch                                   | `wcn-addon` |
| `autoscaling.enabled`   | True if autoscaling is enabled                                           | `true`      |

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
  - 'proxy_http_version 1.1;'
  - 'proxy_set_header Upgrade $http_upgrade;'
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

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

## Limitations

- Watson Addon run only on Intel architecture nodes.
- This chart should only use the default image tags provided with the chart. Different image versions might not be compatible with different versions of this chart.

_Copyright© IBM Corporation 2019. All Rights Reserved._
