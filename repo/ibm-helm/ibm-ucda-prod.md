# DevOps Deploy Agent - Helm Chart

## Introduction
[DevOps Deploy Agent](https://www.ibm.com/cloud/urbancode/deploy) is a tool for automating application deployments through your environments. It is designed to facilitate rapid feedback and continuous delivery in agile development while providing the audit trails, versioning and approvals needed in production.


## Chart Details
* This chart deploys a single instance of the DevOps Deploy agent that may be scaled to multiple instances.
* The Persistent Volume access modes ReadWriteOnce (RWO) and ReadWriteMany (RWX) are both supported for use with IBM DevOps Deploy agent.  However, ReadWriteMany is required to successfully scale to more than one replica/instance of the agent.
* Includes a StatefulSet workload object
* Support has been validated on OpenShift clusters running onPrem, in IBM Satellite, and IBM ROKS.

## Prerequisites

1. Kubernetes 1.19.0+; kubectl and oc CLI; Helm 3;
  * Install and setup oc/kubectl CLI depending on your architecture.
    * [ppc64le](https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [s390x](https://mirror.openshift.com/pub/openshift-v4/s390x/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [x86_64](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz)
  * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Accessing the container Image - The DevOps Deploy agent image is accessed via the IBM Entitled Registry.

    * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
    * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
    * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  If the secret is named ibm-entitlement-key it will be used as the default pull secret, no value needs to be specified in the image.secret field.  Once this secret has been created you will specify the secret name as the value for the image.secret parameter in the values.yaml you provide to 'helm install ...'.  Note that secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Deploy agent into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

```
oc create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password=<EntitlementKey> --docker-server=cp.icr.io
```

3. The agent must have an DevOps Deploy server or relay to connect to.

4. Secret - A Kubernetes Secret object must be created to store the password for all keystores used by the product.  The name of the secret you create must be specified in the property 'secret.name' in your values.yaml.

* Through the kubectl CLI, create a Secret object in the target namespace.

```bash
kubectl create secret generic ucd-secrets \
  --from-literal=keystorepassword=MyKeystorePassword

```

5. A PersistentVolume that will hold the conf directory for the DevOps Deploy agent is required.  If your cluster supports dynamic volume provisioning you will not need to create a PersistentVolume (PV) or PersistentVolumeClaim (PVC) before installing this chart.  If your cluster does not support dynamic volume provisioning, you will need to either ensure a PV is available or you will need to create one before installing this chart.  You can optionally create the PVC to bind it to a specific PV, or you can let the chart create a PVC and bind to any available PV that meets the required size and storage class.  Sample YAML to create the PV and PVC are provided below.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ucda-conf-vol
  labels:
    volume: ucda-conf-vol
spec:
  capacity:
    storage: 10Mi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: 192.168.1.17
    path: /volume1/k8/ucda-conf
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ucda-conf-volc
spec:
  storageClassName: ""
  accessModes:
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 10Mi
  selector:
    matchLabels:
      volume: ucda-conf-vol
```
  * The following storage options have been tested with IBM DevOps Deploy

    * IBM Block Storage supports the ReadWriteOnce access mode.  ReadWriteMany is not supported.

    * IBM File Storage supports ReadWriteMany which is required for multiple instances of the DevOps Deploy agent.

  * IBM DevOps Deploy requires non-root access to persistent storage. When using IBM File Storage you need to either use one of the IBM provided “gid” file storage classes (ie. ibmc-file-gold-gid) with default group ID 65531 or create your own customized storage class to specify a different group ID. See the information at https://cloud.ibm.com/docs/containers?topic=containers-cs_storage_nonroot for more details.  Once you know the correct group ID, set the persistence.fsGroup property in the values.yaml to that group ID.

  6.  If a route or ingress is used to access the WSS port of the DevOps Deploy server from an DevOps Deploy agent, then port 443 should be specified along with the configured URL to access the proper service port defined for the DevOps Deploy Server.

### PodSecurityPolicy Requirements

If you are running on OpenShift, skip this section and continue to the [SecurityContextConstraints Requirements](#securitycontextconstraints-requirements) section below.

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you.

The predefined PodSecurityPolicy named [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

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
  allowPrivilegeEscalation: true
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
  - KILL
  - MKNOD
  - SETUID
  - SETGID
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
* 50 millicores CPU

## Client Data Storage Locations

All client data is stored in the conf persistent volume.  DevOps Deploy does not do any active encryption of this data location.  This location should be included in whatever backup plans the user chooses to implement.

## Installing the Chart

Add the IBM helm chart repository to the local client.
```bash
$ helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/
```

Get a copy of the values.yaml file from the helm chart so you can update it with values used by the install.
```bash
$ helm inspect values ibm-helm/ibm-ucda-prod > myvalues.yaml
```

Edit the file myvalues.yaml to specify the parameter values to use when installing the DevOps Deploy agent instance.  The [configuration](#Configuration) section lists the parameter values that can be set.

To install the chart into namespace 'ucdtest' with the release name `my-ucda-release` and use the values from myvalues.yaml:

```bash
$ helm install my-ucda-release ibm-helm/ibm-ucda-prod --namespace ucdtest --values myvalues.yaml
```

> **Tip**: List all releases using `helm list`.

## Verifying the Chart
Check the Resources->Agents page of the DevOps Deploy server UI to verify the agent has connected successfully.

## Upgrading the Chart

Check [here](https://community.ibm.com/community/user/wasdevops/blogs/laurel-dickson-bull1/2022/07/08/container-upgrade) for information about ugrading the chart.

## Uninstalling the Chart

To uninstall/delete the `my-ucda-release` deployment:

```bash
$ helm delete my-ucda-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Disaster Recovery

Backup product data and essential Kubernetes resources so that you can recover your DevOps Deploy agent instance after a disaster.

### Backup Kubernetes Resources

Backup the Kubernetes resoures required to redeploy the DevOps Deploy agent after a disaster.  Follow these steps to save the configuration of essential Kubernetes resources.

1. Save Helm values
   Run the following command to save a local copy of the Helm values file
```bash
helm get values <Helm-release-name> --namespace <ucd_namespace> --all >savedHelmValues.yaml
```
2. Save secret containing DevOps Deploy agent keystore passwords
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

Backup the conf directory used by the DevOps Deploy server.  To ensure the most accurate saving of data, no deployments should be active.  Follow these steps to take a backup of the agent.

1. Scale the statefulset resource to 0 to shutdown the DevOps Deploy agent.
2. Backup the conf Persistent Volume.
3. Scale the statefulset resource to 1 to restart the DevOps Deploy server.

### Recover from a disaster

If you have successfully backed up the resources and data as described in [Backup Kubernetes Resources](#backup-kubernetes-resources) and [Backup Product Data](#backup-product-data) you can recreate an instance of DevOps Deploy agent using that data.  Follow these steps to recreate your DevOps Deploy agent instance.

1. Create a new project/namespace to hold the Kubernetes resources associated with the DevOps Deploy agent instance.
2. Create the Kubernetes secret that contains the DevOps Deploy agent keystore password by running the following command.
```bash
oc apply -n <ucd_namespace> -f <ucdsecrets_name>.yaml
```
3. Create the image pull secret needed to access images in the IBM Entitled Registry by running the following command.
```bash
oc apply -n <ucd_namespace> -f <ibm-entitlement-key>.yaml
```
4. Create the conf Persistent Volume and associated Persistent Volume Claim and load the saved conf directory contents into the Persistent Volume.
5. Create a values.yaml file that contains the properties and values from your savedHelmValues.yaml file.  Be sure that the Values.confVolume.existingClaimName field is set to the Persistent Volume Claim for the new conf Persistent Volume.
6. Create the new DevOps Deploy agent instance by running the following command.
```bash
helm install my-recovered-release ibm-helm/ibm-ucda-prod --namespace <ucd_namespace> --values myRecoveredValues.yaml
```

## Configuration

### Parameters

The Helm chart has the following values that can be overriden using the --set parameter or specified via -f my_values.yaml.

##### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| version |  | DevOps Deploy agent product version |  |
| replicas | agent | Number of DevOps Deploy agent replicas | Non-zero number of replicas.  Defaults to 1 |
| image | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to Always |
|       | secret |  An image pull secret used to authenticate with the image registry | Empty (default) if no authentication is required to access the image registry. |
| license | accept | Set to true to indicate you have read and agree to license agreements : http://www-03.ibm.com/software/sla/sladb.nsf/searchlis/?searchview&searchorder=4&searchmax=0&query=(urbancode+deploy) | false |
| persistence | enabled | Determines if persistent storage will be used to hold the DevOps Deploy agent conf directory contents. This should always be true to preserve agent data on container restarts. | Default value "true" |
|             | useDynamicProvisioning | Set to "true" if the cluster supports dynamic storage provisoning | Default value "true" |
|             | fsGroup | The group ID to use to access persistent volumes | Default value "1001" |
| confVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the DevOps Deploy agent conf directory is created by the chart. | Default value is "conf" |
|               | existingClaimName | The name of an existing Persistent Volume Claim that references the Persistent Volume that will be used to hold the DevOps Deploy agent conf directory. |  |
|               | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true". |  |
|               | size | Size of the volume to hold the DevOps Deploy agent conf directory |  |
|              | accessMode | Persistent storage access mode for the conf directory persistent volume. | ReadWriteOnce |
| relayUri |  | Agent Relay Proxy URI if the agent is connecting to a relay. If multiple relays are specified, separate them with commas. For example, random:(http://relay1:20080,http://relay2:20080) |  |
| codestationUrl |  | Agent Relay Codestation URL. If multiple relays are specified, separate them with commas. For example, random:(http://relay1:20081,http://relay2:20081) |  |
| serverUri |  | DevOps Deploy server URI. If multiple servers are specified, separate them with commas. For example, random:(wss://ucd1.example.com:7919,wss://ucd2.example.com:7919) |  |
| secret | name | Kubernetes secret which defines password to use when creating keystores. | |
| agentTeams |  | Teams to add this agent to when it connects to the DevOps Deploy server.Format is <team>:<type>. Multiple team specifications are separated with a comma. |  |
| userUtils | existingClaimName | Name of existing Persistent Volume Claim that refers to Persistent Volume that contains executables for the agent process to execute as part of deployment processes. | |
|  | executablesPath | Relative pathname to the directory containing the user provided executable(s).  Comma separate multiple directory paths. | Default is '.', the top-level directory of the PV. |
| resources | constraints.enabled | Specifies whether the resource constraints specified in this helm chart are enabled.   | false (default) or true  |
|           | limits.cpu  | Describes the maximum amount of CPU allowed | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed | Default is 2Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 50m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value | Default is 200Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |

## Scaling
To increase or decrease the number of DevOps Deploy Agent instances issue the following command:

```bash
$ oc scale --replicas=2 statefulset/releaseName-ibm-ucda-prod
```

## User defined utilities to run in DevOps Deploy Agent container
Users can extend the tools the agent can execute without having to modify the image. The user can provide a Persistent Volume Claim(PVC) in the values.yaml file. This PVC would refer to a Persistent Volume(PV) the user has created and load the executables they want the agent to run. See the userUtils.existingClaimName and userUtils.executablesPath in the "Configuration" on how to provide user defined utilities.  

## Storage
See the Prerequisites section of this page for storage information.

## Limitations
