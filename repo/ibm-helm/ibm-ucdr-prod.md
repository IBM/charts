# DevOps Deploy Agent Relay - Helm Chart

## Introduction
[DevOps Deploy Agent Relay](https://www.ibm.com/cloud/urbancode/deploy) is a tool for automating application deployments through your environments. It is designed to facilitate rapid feedback and continuous delivery in agile development while providing the audit trails, versioning and approvals needed in production.

## Chart Details
* This chart deploys a single instance of the IBM DevOps Deploy agent relay that may be scaled to multiple instances.
* The Persistent Volume access modes ReadWriteOnce (RWO) and ReadWriteMany (RWX) are both supported for use with IBM DevOps Deploy agent relay.  However, ReadWriteMany is required to successfully scale to more than one replica/instance of the agent relay.
* Includes a StatefulSet workload object
* Support has been validated on OpenShift clusters running onPrem, in IBM Satellite, and IBM ROKS.

## Prerequisites

1. Kubernetes 1.19.0+/OpenShift 4.6.0+; kubectl and oc CLI; Helm 3;
  * Install and setup oc/kubectl CLI depending on your architecture.
    * [ppc64le](https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [s390x](https://mirror.openshift.com/pub/openshift-v4/s390x/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [x86_64](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz)
  * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Accessing the container Image - The DevOps Deploy agent relay image is accessed via the IBM Entitled Registry.

    * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
    * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
    * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  If the secret is named ibm-entitlement-key it will be used as the default pull secret, no value needs to be specified in the image.secret field.  Once this secret has been created you will specify the secret name as the value for the image.secret parameter in the values.yaml you provide to 'helm install ...'.  Note that secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Deploy agent relay into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

  ```
  oc create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password=<EntitlementKey> --docker-server=cp.icr.io
  ```
3. The DevOps Deploy agent relay must have a DevOps Deploy server to connect to.

4. Secret - A Kubernetes Secret object must be created to store the DevOps Deploy server's Codestation authentication token and the password for all keystores used by the product.  The name of the secret you create must be specified in the property 'secret.name' in your values.yaml.

* Through the oc/kubectl CLI, create a Secret object in the target namespace.

```bash
oc create secret generic ucd-secrets \
  --from-literal=cspassword=255b21b7-ca48-4f2e-95c0-048fdbff4197 \
  --from-literal=keystorepassword=MyKeystorePassword
```

**NOTE:** If you need to change the keystorepassword after the initial agent relay deployment, follow the instructions shown here: [Changing Password For Keystore File](#changing-password-for-keystore-file).

5. A PersistentVolume that will hold the conf directory for the DevOps Deploy relay is required.  If your cluster supports dynamic volume provisioning you will not need to create a PersistentVolume (PV) or PersistentVolumeClaim (PVC) before installing this chart.  If your cluster does not support dynamic volume provisioning, you will need to either ensure a PV is available or you will need to create one before installing this chart.  You can optionally create the PVC to bind it to a specific PV, or you can let the chart create a PVC and bind to any available PV that meets the required size and storage class.  Sample YAML to create the PV and PVC are provided below.  Ensure that the spec.persistentVolumeReclaimPolicy parameter is set to Retain on the conf directory persistent volume. By default, the value is Delete for dynamically created persistent volumes. Setting the value to Retain ensures that the persistent volume is not freed or deleted if its associated persistent volume claim is deleted.

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
  persistentVolumeReclaimPolicy: Retain
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
* The following storage options have been tested with IBM DevOps Deploy

  * IBM Block Storage supports the ReadWriteOnce access mode.  ReadWriteMany is not supported.

  * IBM File Storage supports ReadWriteMany which is required for multiple instances of the DevOps Deploy agent.

* IBM DevOps Deploy requires non-root access to persistent storage. When using IBM File Storage you need to either use one of the IBM provided “gid” file storage classes (ie. ibmc-file-gold-gid) with default group ID 65531 or create your own customized storage class to specify a different group ID. See the information at https://cloud.ibm.com/docs/containers?topic=containers-cs_storage_nonroot for more details.  Once you know the correct group ID, set the persistence.fsGroup property in the values.yaml to that group ID.

6.  If a route or ingress is used to access the WSS port of the DevOps Deploy server from an DevOps Deploy relay, then port 443 should be specified along with the configured URL to access the proper service port defined for the DevOps Deploy Server.

### SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. The default `SecurityContextConstraints` named restricted has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

  * Custom SecurityContextConstraints definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegeEscalation: false
  allowPrivilegedContainer: false
  allowedCapabilities: null
  defaultAddCapabilities: null
  fsGroup:
    type: MustRunAs
  metadata:
    annotations:
      kubernetes.io/description: restricted denies access to all host features and requires
        pods to be run with a UID, and SELinux context that are allocated to the namespace.  This
        is the most restrictive SCC and it is used by default for authenticated users.
    name: ucd-restricted
  priority: null
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - ALL
  runAsUser:
    type: MustRunAsRange
  seLinuxContext:
    type: MustRunAs
  supplementalGroups:
    type: RunAsAny
  users: []
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  ```

## Resources Required
* 200MB of RAM
* 100 millicores CPU

## Client Data Storage Locations

All client data is stored in the conf persistent volume.  DevOps Deploy does not do any active encryption of this data location.  This location should be included in whatever backup plans the user chooses to implement.

## Installing the Chart

Add the IBM helm chart repository to the local client.
```bash
$ helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/
```

Get a copy of the values.yaml file from the helm chart so you can update it with values used by the install.
```bash
$ helm inspect values ibm-helm/ibm-ucdr-prod > myvalues.yaml
```

Edit the file myvalues.yaml to specify the parameter values to use when installing the DevOps Deploy agent relay instance.  The [configuration](#Configuration) section lists the parameter values that can be set.

To install the chart into namespace 'ucdtest' with the release name `my-ucdr-release` and use the values from myvalues.yaml:

```bash
$ helm install my-ucdr-release ibm-helm/ibm-ucdr-prod --namespace ucdtest --values myvalues.yaml
```

> **Tip**: List all releases using `helm list`.

## Verifying the Chart
Check the Resources->Agent Relays page of the DevOps Deploy server UI to verify the agent relay has connected successfully.

## Upgrading the Chart

Check [here](https://community.ibm.com/community/user/wasdevops/blogs/laurel-dickson-bull1/2022/07/08/container-upgrade) for information about ugrading the chart.

## Uninstalling the Chart

To uninstall/delete the `my-ucdr-release` deployment:

```bash
$ helm delete my-ucdr-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Changing Password For Keystore File

To change the password used by the DevOps Deploy Agent Relay keystore file, follow these steps:

1. Scale the statefulset resource to 0 to shutdown the DevOps Deploy Agent Relay.

2. Update the Kubernetes secret used to define the agent relay passwords to set the **keystorepassword** to the new value.

3. **IMPORTANT:** Update the Kubernetes secret used to define the agent relay passwords to set the **previouskeystorepassword** to the existing keystore password being used.

4. Scale the statefulset resource to 1 to restart the DevOps Deploy Agent Relay.

5. When the Agent Relay is restarted, the keystore passwords will be updated to the new value during pod initialization.

## Disaster Recovery

Backup product data and essential Kubernetes resources so that you can recover your DevOps Deploy relay instance after a disaster.

### Backup Kubernetes Resources

Backup the Kubernetes resoures required to redeploy the DevOps Deploy relay after a disaster.  Follow these steps to save the configuration of essential Kubernetes resources.

1. Save Helm values
   Run the following command to save a local copy of the Helm values file
```bash
helm get values <Helm-release-name> --namespace <ucd_namespace> --all >savedHelmValues.yaml
```
2. Save secret containing DevOps Deploy relay keystore passwords
   Find the value for the Values.secret.name property in the saved Helm values file above.  This is the name of the secret we want to save a local copy of.  Run the following command, replacing **ucdsecrets_name** with the value from the values.secret.name property.
```bash
oc get secret <ucdsecrets_name> -n <ucd_namespace> -o yaml > <ucdsecrets_name>.yaml
```
3. Save image pull secret
   Find the value for the Values.image.secret property in the saved Helm values file above.  This is the name of the secret used to pull images from the IBM Entitled Registry.  Run the following command, replacing **ibm-entitlement-key** with the value from the Values.image.secret property.
```bash
oc get secret <ibm-entitlement-key> -n <ucd_namespace> -o yaml > <ibm-entitlement-key>.yaml
```

### Backup Product Data

Backup the conf directory used by the DevOps Deploy server.  To ensure the most accurate saving of data, no deployments should be active.  Follow these steps to take a backup of the relay.

1. Scale the statefulset resource to 0 to shutdown the DevOps Deploy relay.
2. Backup the conf Persistent Volume.
3. Scale the statefulset resource to 1 to restart the DevOps Deploy relay.

### Recover from a disaster

If you have successfully backed up the resources and data as described in [Backup Kubernetes Resources](#backup-kubernetes-resources) and [Backup Product Data](#backup-product-data) you can recreate an instance of DevOps Deploy relay using that data.  Follow these steps to recreate your DevOps Deploy relay instance.

1. Create a new project/namespace to hold the Kubernetes resources associated with the DevOps Deploy relay instance.
2. Create the Kubernetes secret that contains the DevOps Deploy relay keystore password by running the following command.
```bash
oc apply -n <ucd_namespace> -f <ucdsecrets_name>.yaml
```
3. Create the image pull secret needed to access images in the IBM Entitled Registry by running the following command.
```bash
oc apply -n <ucd_namespace> -f <ibm-entitlement-key>.yaml
```
4. Create the conf Persistent Volume and associated Persistent Volume Claim and load the saved conf directory contents into the Persistent Volume.
5. Create a values.yaml file that contains the properties and values from your savedHelmValues.yaml file.  Be sure that the Values.confVolume.existingClaimName field is set to the Persistent Volume Claim for the new conf Persistent Volume.
6. Create the new DevOps Deploy relay instance by running the following command.
```bash
helm install my-recovered-release ibm-helm/ibm-ucdr-prod --namespace <ucd_namespace> --values myRecoveredValues.yaml
```
## Configuration

### Parameters

The Helm chart has the following values.

##### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| version |  | DevOps Deploy relay product vesion | Defaults to latest product version |
| replicas | relay | Number of DevOps Deploy relay replicas | Non-zero number of replicas.  Defaults to 1 |
| image | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to IfNotPresent |
|       | secret |  An image pull secret used to authenticate with the image registry | If no value is specified we will look for a pull secret named ibm-entitlement-key. |
| license | accept | Set to true to indicate you have read and agree to license agreements : https://ibm.biz/devops-deploy-license | false |
| service | type | Specify type of service | Valid options are ClusterIP, NodePort and LoadBalancer (for clusters that support LoadBalancer). Default is LoadBalancer |
| persistence | enabled | Determines if persistent storage will be used to hold the DevOps Deploy server appdata directory contents. This should always be true to preserve server data on container restarts. | Default value "true" |
|             | useDynamicProvisioning | Set to "true" if the cluster supports dynamic storage provisoning | Default value "false" |
|             | fsGroup | The group ID to use to access persistent volumes | Default value "1001" |
| confVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the DevOps Deploy relay conf directory is created by the chart. | Default value is "conf" |
|            | existingClaimName | The name of an existing Persistent Volume Claim that references the Persistent Volume that will be used to hold the DevOps Deploy relay conf directory. |  |
|            | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true" and existingClaimName is empty. |  |
|            | size | Size of the volume to hold the DevOps Deploy relay conf directory |  |
|              | accessMode | Persistent storage access mode for the ext-lib persistent volume. | ReadWriteOnce |
| serverHostPort |  | DevOps Deploy server hostname and WSS port in the form hostname:port. If specifying failover info, separate multiple hostname:port with a comma. For example, ucd1.example.com:7919,ucd2.example.com:7919) |  |
| secret | name | Kubernetes secret which defines required DevOps Deploy passwords. | You may leave this blank to use default name of HelmReleaseName-secrets where HelmReleaseName is the name of your Helm Release, otherwise specify the secret name here. |
| codeStationReplication | enabled | Specify true to enable artifact caching on the relay. | false |
|                        | persisted | Specify true to persist the artifact cache when the relay container is restarted. | true |
|                        | serverUrl | The full URL of the central server to connect to, such as https://myserver.example.com:8443. |  |
|                        | maxCacheSize | The size to which to limit the artifact cache, such as 500M for 500 MB or 5G for 5 GB. To not put a limit on the cache, specify none. |  |
|                        | geotags | If you choose to cache files on the relay, you can specify one or more component version statuses here, separated by semicolons. The agent relay automatically caches component versions with any of these statuses so that those versions are ready when they are needed for a deployment. A status can contain a space except in the first or last position. A status can contain commas. The special * status replicates all artifacts, but use this status with caution, because it can make the agent relay store a large amount of data. If no value is specified, no component versions are cached automatically. |  |
| resources | constraints.enabled | Specifies whether the resource constraints specified in this helm chart are enabled.   | false (default) or true  |
|           | limits.cpu  | Describes the maximum amount of CPU allowed | Default is 4000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed | Default is 4Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | limits.ephemeral-storage | Describes the maximum amount of ephemeral storage allowed | Default is 2Gi. See Kubernetes - [ephemeral storage](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#setting-requests-and-limits-for-local-ephemeral-storage) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 100m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value | Default is 200Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.ephemeral-storage | Describes the minimum amount of ephemeral storage required. If not specified, the amount will default to the limit (if specified) or the implementation-defined value  | Default is 500Mi. See Kubernetes - [ephemeral storage](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#setting-requests-and-limits-for-local-ephemeral-storage) |

## Scaling
To increase or decrease the number of DevOps Deploy Agent Relay instances/replicas issue the following command:

```bash
$ oc scale --replicas=2 statefulset/releaseName-ibm-ucdr-prod
```

## Storage
See the Prerequisites section of this page for storage information.

## Limitations
