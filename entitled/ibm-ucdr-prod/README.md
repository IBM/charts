# UrbanCode Deploy Agent Relay - Helm Chart

[UrbanCode Deploy Agent Relay](https://developer.ibm.com/urbancode/products/urbancode-deploy/) is a tool for automating application deployments through your environments. It is designed to facilitate rapid feedback and continuous delivery in agile development while providing the audit trails, versioning and approvals needed in production.

## Introduction

This chart deploys a single instance of the IBM UrbanCode Deploy agent relay that may be scaled to multiple instances.

## Chart Details
* Includes a StatefulSet workload object and corresponding service

## Prerequisites

1. Kubernetes 1.16.0+; kubectl and oc CLI; Helm 3; 
* [Install and setup oc/kubectl CLI](https://docs.okd.io/latest/cli_reference/get_started_cli.html#installing-the-cli)
* [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Image and Helm Chart - The UCD agent relay image and helm chart can be accessed via the Entitled Registry and public Helm repository.
* Entitled Registry
    * The public Helm chart repository can be accessed at https://github.com/IBM/charts/tree/master/repo/ibm-helm and directions for accessing the UrbanCode Deploy agent relay chart will be discussed later in this README.
    * Get a key to the entitled registry
        * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
        * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
        * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  Once this secret has been created you will specify the secret name as the value for the image.secret parameter in the values.yaml you provide to 'helm install ...'  Note: Secrets are namespace scoped, so they must be created in every namespace you plan to install UCD into.  Example Docker registry secret to access Entitled Registry with an Entitlement key. 

```
oc create secret docker-registry entitledregistry-secret --docker-username=cp --docker-password=<EntitlementKey> --docker-server=cp.icr.io
``` 

3. The UrbanCode agent relay must have a UrbanCode Deploy server to connect to.

4. A PersistentVolume (PV) that will hold the conf directory for the UrbanCode Deploy agent relay is required.  This same PV is used to persist the agent relay cache data if caching is enabled and persisted.  If your cluster supports dynamic volume provisioning you will not need to create a PV or PersistentVolumeClaim (PVC) before installing this chart.  If your cluster does not support dynamic volume provisioning, you will need to either ensure a PV is available or you will need to create one before installing this chart.  You can optionally create the PVC to bind it to a specific PV, or you can let the chart create a PVC and bind to any available PV that meets the required size and storage class.  Sample YAML to create the PV and PVC are provided below.

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

5. Secret - A Kubernetes Secret object must be created to store the CodeStation authentication token and the password for all keystores used by the product.  The authentication token and keystore password are retrieved during Helm chart installation.  By default, the chart will look for a secret named 'HelmReleaseName-secrets' where 'HelmReleaseName' is the release name you give when installing this Helm chart.  You can also create a secret with a different name and specify it in the Values.secret.name field

* Through the kubectl CLI, create a Secret object in the target namespace.
    Generate the base64 encoded value for the CodeStation authentication token.

```
echo -n 255b21b7-ca48-4f2e-95c0-048fdbff4197 | base64
MjU1YjIxYjctY2E0OC00ZjJlLTk1YzAtMDQ4ZmRiZmY0MTk3
echo -n 'MyKeystorePassword' | base64
TXlLZXlzdG9yZVBhc3N3b3Jk
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
  keystorepassword: TXlLZXlzdG9yZVBhc3N3b3Jk
```

Create the Secret using kubectl apply

```
kubectl apply -f ./secret.yaml
```

Delete or shred the secret.yaml file.


### PodSecurityPolicy Requirements

If you are running on OpenShift, skip this section and continue to the [SecurityContextConstraints Requirements](#securitycontextconstraints-requirements) section below.

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

### SecurityContextConstraints Requirements

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
Kubernetes 1.16.0+

## Installing the Chart

Add the IBM helm chart repository to the local client.
```bash
$ helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/
```

Get a copy of the values.yaml file from the helm chart so you can update it with values used by the install.
```bash
$ helm inspect values ibm-helm/ibm-ucdr-prod > myvalues.yaml
```

Edit the file myvalues.yaml to specify the parameter values to use when installing the UCD agent relay instance.  The [configuration](#Configuration) section lists the parameter values that can be set.

To install the chart into namespace 'ucdtest' with the release name `my-ucdr-release` and use the values from myvalues.yaml:

```bash
$ helm install my-ucdr-release ibm-helm/ibm-ucdr-prod --namespace ucdtest --values myvalues.yaml
```

> **Tip**: List all releases using `helm list`.

## Verifying the Chart
Check the Resources->Agent Relays page of the UrbanCode Deploy server UI to verify the agent relay has connected successfully.

## Uninstalling the Chart

To uninstall/delete the `my-ucdr-release` deployment:

```bash
$ helm delete my-ucdr-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## Configuration

### Parameters

The Helm chart has the following values that can be overriden using the --set parameter or specified via -f my_values.yaml.

##### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| version |  | The product version to install |  |
| image | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to Always |
|       | secret |  An image pull secret used to authenticate with the image registry | Empty (default) if no authentication is required to access the image registry. |
| license | accept | Set to true to accept license agreement |  |
| persistence | enabled | Determines if persistent storage will be used to hold the UCD server appdata directory contents. This should always be true to preserve server data on container restarts. | Default value "true" |
|             | useDynamicProvisioning | Set to "true" if the cluster supports dynamic storage provisoning | Default value "false" |
|             | fsGroup | fsGroup value to use for gid when accessing persistent storage | Default value is "0" |
| confVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the UCD agent conf directory is created by the chart. | Default value is "conf" |
|            | existingClaimName | The name of an existing Persistent Volume Claim that references the Persistent Volume that will be used to hold the UCD agent conf directory. |  |
|            | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true". |  |
|            | size | Size of the volume to hold the UCD agent conf directory |  |
| serverHostPort |  | UCD server hostname and WSS port in the form hostname:port. If specifying failover info, separate multiple hostname:port with a comma. For example, wss://ucd1.example.com:7919,wss://ucd2.example.com:7919) |  |
| codeStationReplication | enabled | Specify true to enable artifact caching on the relay. |  |
|                        | persisted | Specify true to persist the artifact cache when the relay container is restarted. |  |
|                        | serverUrl | The full URL of the central server to connect to, such as https://myserver.example.com:8443. |  |
|                        | serverPassword | An authentication token from the server. |  |
|                        | maxCacheSize | The size to which to limit the artifact cache, such as 500M for 500 MB or 5G for 5 GB. To not put a limit on the cache, specify none. |  |
|                        | geotags | If you choose to cache files on the relay, you can specify one or more component version statuses here, separated by semicolons. The agent relay automatically caches component versions with any of these statuses so that those versions are ready when they are needed for a deployment. A status can contain a space except in the first or last position. A status can contain commas. The special * status replicates all artifacts, but use this status with caution, because it can make the agent relay store a large amount of data. If no value is specified, no component versions are cached automatically. |  |
| ingress | httpproxyhost | Hostname used by UrbanCode Deploy Agent Relay for HTTP proxy connections via Ingress (e.g. relayhttpproxyhost.<proxy node address>.nip.io). | |
|          | codestationhost | Hostname used by UrbanCode Deploy Agent Relay for artifact cache requests via Ingress (e.g. codestationhost.<proxy node address>.nip.io:443). See chart readme documentation for more details | |
| resources | constraints.enabled | Specifies whether the resource constraints specified in this helm chart are enabled.   | false (default) or true  |
|           | limits.cpu  | Describes the maximum amount of CPU allowed | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed | Default is 2Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value | Default is 1Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |

## Scaling
To increase or decrease the number of UrbanCode Deploy Agent Relay instances/replicas issue the following command:

```bash
$ oc scale --replicas=2 statefulset/releaseName-ibm-ucdr-prod
```

## Storage
See the Prerequisites section of this page for storage information.

## Limitations

