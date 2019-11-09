# UrbanCode Deploy Agent Relay - Helm Chart

[UrbanCode Deploy Agent Relay](https://developer.ibm.com/urbancode/products/urbancode-deploy/) is a tool for automating application deployments through your environments. It is designed to facilitate rapid feedback and continuous delivery in agile development while providing the audit trails, versioning and approvals needed in production.

## Introduction

This chart deploys a single instance of the IBM UrbanCode Deploy agent relay.

## Chart Details
* Includes a StatefulSet workload object

## Prerequisites

1. The UrbanCode agent relay must have a UrbanCode Deploy server to connect to.

2. A PersistentVolume (PV) that will hold the conf directory for the UrbanCode Deploy agent relay is required.  This same PV is used to persist the agent relay cache data if caching is enabled and persisted.  If your cluster supports dynamic volume provisioning you will not need to create a PV or PersistentVolumeClaim (PVC) before installing this chart.  If your cluster does not support dynamic volume provisioning, you will need to either ensure a PV is available or you will need to create one before installing this chart.  You can optionally create the PVC to bind it to a specific PV, or you can let the chart create a PVC and bind to any available PV that meets the required size and storage class.  Sample YAML to create the PV and PVC are provided below.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ucdr-conf-vol
  labels:
    volume: ucdr-conf-vol
spec:
  capacity:
    storage: 10Mi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.1.17
    path: /volume1/k8/ucdr-conf
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ucdr-conf-volc
spec:
  storageClassName: ""
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 10Mi
  selector:
    matchLabels:
      volume: ucdr-conf-vol
```

Example setup scripts to create the Persistent Volume and Persistent Volume Claim are included in the Helm chart under pak_extensions/pre-install/persistentStorageAdministration directory.

3. Secret - A Kubernetes Secret object must be created to store the CodeStation authentication token.  The authentication token is retrieved during Helm chart installation.  By default, the chart will look for a secret named 'HelmReleaseName-secrets' where 'HelmReleaseName' is the release name you give when installing this Helm chart.  You can also create a secret with a different name and specify it in the Values.secret.name field 

The secret can be created either by using the Cluster Console or using the kubectl CLI.

* Through the Cluster Console, create Secret objects in the target namespace.
    * Click on Configuration->Secrets in the left navigation view
    * Click the New Secret button
    * On the General tab:
        * Enter the name of the secret object.  For example:  MyRelease-secrets
        * Choose the namespace where the chart is to be installed.
    * On the Data tab:
        * Enter 'cspassword' in the Name field.
        * Use your favorite base64 encoding tool to encode the CodeStation authentication token and paste it into the Value field.
    * Click the Create button.

* Through the kubectl CLI, create a Secret object in the target namespace.
    Generate the base64 encoded value for the CodeStation authentication token.

```
echo -n 255b21b7-ca48-4f2e-95c0-048fdbff4197 | base64
MjU1YjIxYjctY2E0OC00ZjJlLTk1YzAtMDQ4ZmRiZmY0MTk3
```

Create a file named secret.yaml with the following contents, using your Helm Relese name and base64 encoded values.

```
apiVersion: v1
kind: Secret
metadata:
  name: MyRelease-secrets
type: Opaque
data:
  cspassword: MjU1YjIxYjctY2E0OC00ZjJlLTk1YzAtMDQ4ZmRiZmY0MTk3
```

Create the Secret using kubectl apply

```
kubectl apply -f ./secret.yaml
```

Delete or shred the secret.yaml file.


### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you.

The predefined PodSecurityPolicy named [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the Cluster Console user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

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
      name: ibm-ucd-prod-psp
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
      name: ibm-ucd-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-ucd-prod-psp
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
      name: ibm-ucd-prod-rolebinding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ibm-ucd-prod-clusterrole
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

### Red Hat OpenShift SecurityContextConstraints Requirements

If running in a Red Hat OpenShift cluster, this chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

This chart defines a custom `SecurityContextConstraints` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using the supplied instructions or scripts in the `pak_extensions/pre-install` directory.

* From the user interface, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`
  * Custom SecurityContextConstraints definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
    name: ibm-ucd-prod-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowedCapabilities: []
  allowedFlexVolumes: []
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

* From the command line, you can run the setup scripts included under `pak_extensions/pre-install`
  As a cluster admin the pre-install instructions are located at:
  * `pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`

  As team admin the namespace scoped instructions are located at:
  * `pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`

## Resources Required
Kubernetes 1.9

## Installing the Chart

To install the chart into the namespace 'default', with the release name `my-ucdrelay`, and reading all remaining installation values from a file named my-relay-values.yaml:

```bash
$ helm install ibm-ucdr-prod-2.0.5.tgz --namespace default --name my-ucdrelay -f my-relay-values.yaml --tls
```

The [configuration](#Configuration) section lists the parameters that can be set during installation.

> **Tip**: List all releases using `helm list`

## Verifying the Chart
Check the Resources->Agent Relays page of the UrbanCode Deploy server UI to verify the agent relay has connected successfully.

## Uninstalling the Chart

To uninstall/delete the `my-ucdrelay` deployment:

```bash
$ helm delete --purge my-ucdrelay --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## Configuration

### Parameters

The Helm chart has the following values that can be overriden using the --set parameter or specified via -f my_values.yaml.

##### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| image | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to Always |
|       | repository | Name of image, including repository prefix (if required) | See [Extended description of Docker tags](https://docs.docker.com/engine/reference/commandline/tag/#extended-description) |
|       | tag | Docker image tag | See [Docker tag description](https://docs.docker.com/engine/reference/commandline/tag/) |
|       | secret |  An image pull secret used to authenticate with the image registry | Empty (default) if no authentication is required to access the image registry. |
| persistence | enabled | Determines if persistent storage will be used to hold the UCD server appdata directory contents. This should always be true to preserve server data on container restarts. | Default value "true" |
|             | useDynamicProvisioning | Set to "true" if the cluster supports dynamic storage provisoning | Default value "false" |
| confVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the UCD agent conf directory is created by the chart. | Default value is "conf" |
|            | existingClaimName | The name of an existing Persistent Volume Claim that references the Persistent Volume that will be used to hold the UCD agent conf directory. |  |
|            | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true". |  |
|            | size | Size of the volume to hold the UCD agent conf directory |  |
| serverHostPort |  | UCD server hostname and JMS port in the form hostname:port. If specifying failover info, separate multiple hostname:port with a comma. For example, ucd1.example.com:7918,ucd2.example.com:7918) |  |
| codeStationReplication | enabled | Specify true to enable artifact caching on the relay. |  |
|                        | persisted | Specify true to persist the artifact cache when the relay container is restarted. |  |
|                        | serverUrl | The full URL of the central server to connect to, such as https://myserver.example.com:8443. |  |
|                        | serverPassword | An authentication token from the server. |  |
|                        | maxCacheSize | The size to which to limit the artifact cache, such as 500M for 500 MB or 5G for 5 GB. To not put a limit on the cache, specify none. |  |
|                        | geotags | If you choose to cache files on the relay, you can specify one or more component version statuses here, separated by semicolons. The agent relay automatically caches component versions with any of these statuses so that those versions are ready when they are needed for a deployment. A status can contain a space except in the first or last position. A status can contain commas. The special * status replicates all artifacts, but use this status with caution, because it can make the agent relay store a large amount of data. If no value is specified, no component versions are cached automatically. |  |
| resources | constraints.enabled | Specifies whether the resource constraints specified in this helm chart are enabled.   | false (default) or true  |
|           | limits.cpu  | Describes the maximum amount of CPU allowed | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed | Default is 2Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value | Default is 1Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |

## Storage
See the Prerequisites section of this page for storage information.

## Limitations

