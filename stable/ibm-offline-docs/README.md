# IBM Customizable Offline Documentation Helm Chart

## Introduction

This helm chart contains the current and previous two versions of the IBM Cloud Pak for Multicloud Management documentation to be viewed in an offline, air gap environment. In addition to product documentation, there is a feature to include non-IBM custom documentation content under the `Our Content (Non-IBM)` product. See the [Configuring the custom documentation](#configuring-the-custom-documentation) section for details.

With each new release, the Docker image is updated to include the new release documentation. For the latest documentation, see the live IBM Knowledge Center entry [IBM Cloud Pak for Multicloud Management](https://www.ibm.com/support/knowledgecenter/SSFC4F/product_welcome_cloud_pak.html).

Note: This helm chart is updated quarterly with new release versions. If you see either missing or incorrect information, check the live IBM Knowledge Center documentation before you contact IBM support. Maintaining the `Our Content (Non-IBM)` product is not covered by IBM support.

## Resources Required

A persistent volume is required, if you plan on adding custom content.

## Chart Details

## Prerequisites

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace before installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you.

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-websphere-liberty-psp
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
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

#### Configuration scripts can be used to create the required resources

Download the following scripts from the [/ibm_cloud_pak/pak_extensions/pre-install](https://github.com/IBM/charts/tree/master/stable/ibm-offline-docs/ibm_cloud_pak/pak_extensions/pre-install) directory.

* The preinstall instructions are at `clusterAdministration/createSecurityClusterPrereqs.sh` for cluster admins to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for the team admin or operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart is installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

#### Configuration scripts can be used to clean up resources created

Download the following scripts from the [/ibm_cloud_pak/pak_extensions/post-delete](https://github.com/IBM/charts/tree/master/stable/ibm-offline-docs/ibm_cloud_pak/pak_extensions/post-delete) directory.

* The post-delete instructions are at `clusterAdministration/deleteSecurityClusterPrereqs.sh` for cluster admins to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for the team admin or operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

#### Creating the required resources

This chart defines a custom `SecurityContextConstraints` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using the supplied instructions or scripts in the `pak_extensions/pre-install` directory.

* From the user interface, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`
  * Custom SecurityContextConstraints definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
    name: ibm-websphere-liberty-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowedCapabilities: []
  allowedFlexVolumes: []
  defaultAddCapabilities: []
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

* From the command line, you can run the setup scripts included under `pak_extensions/pre-install`
  As a cluster admin the pre-install instructions are located at:
  * `pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`

  As team admin the namespace scoped instructions are located at:
  * `pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`

### Limitations

This chart is available only for Linux® x86_64.

### Installing the Chart

The helm chart has the following values that can be overridden by using `--set name=value`. For example:

*    `helm install ibm-offline-docs --name ibm-offline-docs -f overrides.yaml --tls`

### Configuration

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| `image`   | `pullPolicy` | Image Pull Policy | `Always`, `Never`, or `IfNotPresent`. Defaults to `Always` if `:latest` tag is specified, or `IfNotPresent` otherwise. See Kubernetes - [Updating Images](https://kubernetes.io/docs/concepts/containers/images/#updating-images)  |
|           | `repository` | Name of image, including repository prefix (if required) | See Docker - [Extended tag description](https://docs.docker.com/engine/reference/commandline/tag/#parent-command) |
|           | `tag`        | Docker image tag | See Docker - [Tag](https://docs.docker.com/engine/reference/commandline/tag/) |
|           | `license`    |  The license state of the image that is being deployed | `Empty` (default) for development. `accept` if you have previously accepted the production license. |
|           | `extraVolumeMounts`  | Additional `volumeMounts` for server pods | YAML array of `volumeMounts` definitions |
| `pod`     | `extraVolumes`        | Additional volumes for server pods | YAML array of `volume` definitions |

### Configuring the Custom Documentation

#### Adding custom documentation content
You can add custom documentation content to be displayed in the product list under the `Our Content (Non-IBM)` product. To do this you need to set the `image.extraVolumeMounts` and `pod.extraVolumes` configuration parameters to specify where to pick up the custom content.

Example `overrides.yaml` file:

```yaml
image:
  extraVolumeMounts:
    - name: ourcontent
      mountPath: /ourcontent
      readOnly: false

pod:
  extraVolumes:
    - name: ourcontent
      hostPath:
        path: /path/to/ourcontent

```

Inside your custom content folder, you must have a `summary.md` file that describes the table of contents for your content and all of your HTML files that contain your content.

For example:

```
# Summary

 * [Our Content](product_welcome_custom.html)
   * [Intro](Intro.html)
```

In this example, `product_welcome_custom.html` is the main welcome page for your content and `intro.html` is an example topic.

#### Persisting logs

Create a persistent volume (PV) in a shared storage, for example NFS, with the following specification:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: <optional - must match PVC>
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>
```
Note: For NFS PATH, you need to create your directory manually before you deploy the persistent volume.

You can create a PV by using this template by running:
```shell
kubectl create -f <yaml-file>
```
You can also create a PV from the IBM Cloud Pak for Multicloud Management dashboard by following these steps:

1. From the dashboard, click **Create resource**.
2. Select the cluster where the resource will be deployed.
3. Copy and paste the PV template into the YAML editor.
4. Click **Create**.

Note: For volumes that support ownership management, specify the group ID of the group that owns the persistent volumes' file systems by using the `persistence.fsGroupGid` parameter.

#### Analyzing log messages

Logging in JSON format is enabled by default. Log events are forwarded to Elasticsearch automatically. Audit events can also be forwarded to Elasticsearch. Audit events can contain sensitive data. Make sure you have enabled security in the logging stack.

#### Ingress configuration

If you are deploying your chart into the IBM Cloud Pak for Multicloud Management:

* `ingress.host` can be provided and set to a fully qualified domain name that resolves to the IP address of your cluster’s proxy node. For example, `example.com` resolved to the proxy node. When a domain name is not available, the service [`nip.io`](http://nip.io) can be used to provide a resolution based on an IP address. For example, `liberty.<IP>.nip.io` where `<IP>` would be replaced with the IP address of your cluster’s proxy node. The IP address of your cluster’s proxy node can be found by using the following command: `kubectl get nodes -l proxy=true`. Users can also leave this parameter as empty.

* `ingress.secretName` set to the name of the secret containing Ingress TLS certificate and key. If this is not provided, it dynamically creates a self-signed certificate/key, stores it in a Kubernetes secret and uses the secret in Ingress' TLS.

If the chart is deployed into IBM Cloud Kubernetes Service:

* `ingress.host` must be provided and set to the IBM-provided Ingress _subdomain_ or your custom domain. See [Select an app domain and TLS termination](https://console.bluemix.net/docs/containers/cs_ingress.html#public_inside_2) for more info on how to get this value in IBM Cloud Kubernetes Service.
* `ingress.secretName` must be provided. If you are using the IBM-provided Ingress domain, set this parameter to the name of the IBM-provided Ingress secret. However, if you are using a custom domain, set this parameter to the secret that you created earlier that holds your custom TLS certificate and key. See [IBM Cloud Kubernetes Service documentation](https://console.bluemix.net/docs/containers/cs_ingress.html#public_inside_2) for more information on how to get these values in an IBM Cloud Kubernetes Service cluster.
