# IBM Storage Enabler for Containers

## Introduction
IBM Storage Enabler for Containers (ISEC) allows IBM storage systems to be used as persistent volumes for stateful applications running in Kubernetes clusters.
IBM Storage Enabler for Containers uses Kubernetes dynamic provisioning for creating and deleting volumes on IBM storage systems.
In addition, IBM Storage Enabler for Containers utilizes the full set of Kubernetes FlexVolume APIs for volume operations on a host.
The operations include initiation, attachment/detachment, mounting/unmounting etc.

## Chart Details
This chart includes:
* A Storage Enabler for Containers server for running Kubernetes Dynamic Provisioner and FlexVolume.
* A Storage Enabler for Containers database for storing the persistent data for the Enabler for Container service.
* A Kubernetes Dynamic Provisioner for creating storage volumes on-demand, using Kubernetes storage classes based on Spectrum Connect storage services or Spectrum Scale storage classes.
* A Kubernetes FlexVolume DaemonSet for attaching/detaching and mounting/unmounting storage volumes into a pod within a Kubernetes node.

## Prerequisites
### IBM block storage
Before installing the Helm chart for Storage Enabler for Containers in conjuction with IBM block storage:
- Install and configure IBM Spectrum Connect, according to the application requirements.
- Establish a proper communication link between Spectrum Connect and Kubernetes cluster.
- For ICP deployment, make sure the user has the cluster admin access level.
- For each worker node:
   - Install relevant Linux packages to ensure Fibre Channel and iSCSI connectivity.
   - Configure Linux multipath devices on the host.
   - Configure storage system connectivity.
   - Make sure that the node kubelet service has the attach/detach capability enabled.
- For each master node:
   - Enable the attach/detach capability for the kubelet service.
   - If the controller-manager is configured to run as a pod in your Kubernetes cluster, allow for event recording in controller-manager log file.

The next configuration steps describe installation using command-line interface. For installation, using ICP GUI, see the Installation section of the Enabler for Containers user guide. 
- Create a namespace for two secrets:
```bash
kubectl create ns <namespace_name>
```   
- Create two secrets: Enabler for Containers secret for Spectrum Connect and Enabler for Containers secret for its database. Verify that Spectrum Connect credentials secret username and password are the same as Enabler for Containers interface username and password in Spectrum Connect UI.
```bash
kubectl create secret generic <enabler_sc_credentials_secret_name> --from-literal=username=<username> --from-literal=password=<password> -n <namespace>
kubectl create secret generic <enabler_db_credentials_secret_name> --from-literal=dbname=ubiquity --from-literal=username=<username> --from-literal=password=<password> -n <namespace>
```   
- If dedicated SSL certificates are required, see the Managing SSL certificates section in the IBM Storage Enabler for Containers user guide.
- When using IBM Cloud Private with the Spectrum Virtualize Family products, use only hostnames for the Kubernetes cluster nodes, do not use IP addresses.

### IBM Spectrum Scale
Prior to installing the Helm chart for Storage Enabler for Containers in conjunction with IBM Spectrum Scale:
- Install and configure IBM Spectrum Scale, according to the application requirements.
- Establish a proper communication link between Spectrum Scale Management GUI Address and Kubernetes cluster.
- For each worker node:
   - Install Spectum Scale client packages.
   - Mount Spectrum Scale filesystem for persistent storage.
- For each master node:
   - Enable the attach/detach capability for the kubelet service.
   - If the controller-manager is configured to run as a pod in your Kubernetes cluster, allow for event recording in controller-manager log file.
- Create a namespace for two secrets:
```bash
kubectl create ns <namespace_name>
```   
- Create two secrets: Enabler for Containers secret for Spectrum Scale and Enabler for Containers secret for its database. Verify that Spectrum Scale credentials secret username and password are the same as Enabler for Containers username and password define for Spectrum Scale Management API (GUI) Server.
```bash
kubectl create secret generic <enabler_scale_credentials_secret_name> --from-literal=username=<username> --from-literal=password=<password> -n <namespace>
kubectl create secret generic <enabler_db_credentials_secret_name> --from-literal=dbname=ubiquity --from-literal=username=<username> --from-literal=password=<password> -n <namespace>
```   
These configuration steps are mandatory and cannot be skipped. For detailed description of installation prerequisites, see the Compatibility and Requirements sections for IBM Spectrum Connect and IBM Spectrum Scale in the IBM Storage Enabler for Containers user guide on IBM Knowledge Center at https://www.ibm.com/support/knowledgecenter/SSCKLT.

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation or to be bound to the current namespace during installation by setting "customPodSecurityPolicy.enabled" to "true" and setting "customPodSecurityPolicy.clusterRole".

The recommended predefined PodSecurityPolicy name: [`ibm-anyuid-hostpath-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.
The predefined clusterRole name: ibm-anyuid-hostpath-clusterrole has been verified for this chart, if you use it you can proceed to install the chart.

You can also define a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy allows pods to run with 
          any UID and GID and any volume, including the host path.
          WARNING:  This policy allows hostPath volumes.
          Use with caution."
      name: custom-psp
    spec:
      allowPrivilegeEscalation: true
      fsGroup:
        rule: RunAsAny
      requiredDropCapabilities:
      - MKNOD
      allowedCapabilities:
      - SETPCAP
      - AUDIT_WRITE
      - CHOWN
      - NET_RAW
      - DAC_OVERRIDE
      - FOWNER
      - FSETID
      - KILL
      - SETUID
      - SETGID
      - NET_BIND_SERVICE
      - SYS_CHROOT
      - SETFCAP
      runAsUser:
        rule: RunAsAny
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      volumes:
      - '*'
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: custom-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - custom-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```

## Resources Required
IBM Storage Enabler for Containers can be deployed on different operating systems, while provisioning storage from a variety of IBM arrays, as detailed in the release notes of the package.  

## Installing the Chart
First add the IBM Stable charts repository:

```bash
$ helm repo add --tls ibm-stable https://raw.githubusercontent.com/IBM/charts/master/repo/stable
```

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --name my-release --namespace ubiquity ibm-stable/ibm-storage-enabler-for-containers
```

The command deploys <chart name> on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.


> **Note**: You can list all releases using the  `helm list --tls` command.

### Verifying the Chart
You can check the status by running:
```bash
$ helm status --tls my-release
```

If all statuses are free of errors, you can run sanity test by:
```bash
$ helm test --tls my-release
```

### Uninstalling the Chart
Verify that there are no persistent volumes (PVs) that have been created, using IBM Storage Enabler for Containers. 
To uninstall/delete the `my-release` release:

```bash
$ helm delete --tls `my-release` --purge
```

The command removes the IBM Storage Enabler for Containers components associated with the Helm chart, metadata, user credentials, and other elements.

When the Helm chart is deleted, the first elements to be removed are the Enabler for Container database deployment and its PVC. If the `helm delete` command fails after several attempts, delete these entities manually before continuing. Then, verify that the Enabler for Container database deployment and its PVC are deleted, and complete the uninstall procedure by running
```
$ helm delete --tls `my-release` --purge --no-hooks
```
## Configuration

The following table lists the configurable parameters of the <Ubiquity> chart and their default values.

[//]: # (Do not edit the table directly, use Tables Generator: https://www.tablesgenerator.com/markdown_tables)

| Parameter                                                | Description                                                                                                                                                                                                                                                                                                                                   | Default                           |
|----------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| `backend`                                                | Backend type for Provisioner and FlexVolume. Allowed values: spectrumConnect or spectrumScale                                                                                                                                                                                                                                                 | `spectrumConnect`                 |
| `spectrumConnect.connectionInfo.fqdn`                    | IP address or FQDN of the Spectrum Connect server.                                                                                                                                                                                                                                                                                            |                                   |
| `spectrumConnect.connectionInfo.port`                    | Communication port of the Spectrum Connect server.                                                                                                                                                                                                                                                                                            | `8440`                            |
| `spectrumConnect.connectionInfo.existingSecret`          | Secret for Spectrum Connect interface. The value must be the same as configured in Spectrum Connect. Keys username and password are mandatory.                                                                                                                                                                                                 |                                   |
| `spectrumConnect.backendConfig.instanceName`             | A prefix for any new volume created on the storage system.                                                                                                                                                                                                                                                                                    |                                   |
| `spectrumConnect.backendConfig.defaultStorageService`    | Default Spectrum Connect storage service to be used, if not specified by the storage class.                                                                                                                                                                                                                                                   |                                   |
| `spectrumConnect.backendConfig.newVolumeDefaults.fsType` | File system type of a new volume, if not specified by the user in the storage class. Allowed values: ext4 or xfs.                                                                                                                                                                                                                             | `ext4`                            |
| `spectrumConnect.backendConfig.newVolumeDefaults.size`   | Default volume size (in GiB), if not specified by the user when creating a new volume.                                                                                                                                                                                                                                                        | `1`                               |
| `spectrumConnect.storageClass.storageService`            | The Spectrum Connect storage service which is directed to Enabler for Containers DB storage class profile.                                                                                                                                                                                                                                    |                                   |
| `spectrumConnect.storageClass.fsType`                    | The fstype parameter of Enabler for Containers DB storage class. Allowed values: ext4 or xfs.                                                                                                                                                                                                                                                 | `ext4`                            |
| `spectrumScale.connectionInfo.fqdn`                      | Spectrum Scale IP address or FQDN of the Management API (GUI) Server.                                                                                                                                                                                                                                                                         |                                   |
| `spectrumScale.connectionInfo.port`                      | Communication port of Spectrum Scale Management API (GUI) Server.                                                                                                                                                                                                                                                                             | `443`                             |
| `spectrumScale.connectionInfo.existingSecret`            | Secret for Spectrum Scale Management API (GUI) Server user credentials. The value must be the same as configured in Spectrum Scale. Keys username and password are mandatory.                                                                                                                                                                 |                                   |
| `spectrumScale.backendConfig.defaultFilesystemName`      | Default Spectrum Scale filesystem to be used for creating persistent volume.                                                                                                                                                                                                                                                                  |                                   |
| `ubiquitydb.resources`                                   | Resources configuration required for deploying Enabler for Containers DB.                                                                                                                                                                                                                                                                     |                                   |
| `ubiquitydb.nodeSelector`                                | Extra node selector for deployment.                                                                                                                                                                                                                                                                                                           |                                   |
| `ubiquitydb.dbCredentials.existingSecret`                | Secret for Enabler for Containers DB. Define keys username, password and dbname for the secret object used by Enabler for Containers DB. The dbname must be set to 'ubiquity'.                                                                                                                                                                |                                   |
| `ubiquityDb.persistence.useExistingPv`                   | Set this parameter to True if you want to use an existing PVC as Enabler for Containers database PVC. Use it only when you want to upgrade Ubiquity from old version installed by script to the latest version.                                                                                                                               | `false`                           |
| `ubiquityDb.persistence.pvName`                          | Name of the persistent volume to be used for the ubiquity-db database. For the Spectrum Virtualize and Spectrum Accelerate storage systems, use the default value (ibm-ubiquity-db). For the DS8000 storage system, use a shorter value, such as (ibmdb). This is necessary because the DS8000 volume name length cannot exceed 8 characters. | `ibm-ubiquity-db`                 |
| `ubiquityDb.persistence.pvSize`                          | Default size (in GiB) of the persistent volume to be used for the ubiquity-db database.                                                                                                                                                                                                                                                       | `20`                              |
| `ubiquityDb.persistence.storageClass.storageClassName`   | Storage class name. The storage class parameters are used for creating an initial storage class for the ubiquity-db PVC. You can use this storage class for other applications as well. It is recommended to set the storage class name to be the same as the Spectrum Connect storage service name.                                          |                                   |
| `ubiquityDb.persistence.storageClass.defaultClass`       | Set to True if the storage class of Enabler for Containers DB will be used as default storage class.                                                                                                                                                                                                                                          | `false`                           |
| `ubiquity.resources`                                     | Resources configuration required for deploying Enabler for Containers.                                                                                                                                                                                                                                                                        |                                   |
| `ubiquityK8sFlex.resources`                              | Resources configuration required for deploying Kubernetes FlexVolume daemonSet.                                                                                                                                                                                                                                                               |                                   |
| `ubiquityK8sFlex.tolerations`                            | Toleration labels for pod assignment, such as [{\"key\": \"key\",,\"operator\":\"Equal\", \"value\": \"value\",,\"effect\":\"NoSchedule\"}]                                                                                                                                                                                                   |                                   |
| `ubiquityK8sFlex.flexLogDir`                             | If the default value is changed, make sure that the new path exists on all the nodes                                                                                                                                                                                                                                                          | `/var/log`                        |
| `ubiquityK8sFlexInitContainer.resources`                 | Resources configuration required for deploying Kubernetes FlexVolume daemonSet Init-Container.                                                                                                                                                                                                                                                |                                   |
| `ubiquityK8sFlexSidecar.resources`                       | Resources configuration required for deploying Kubernetes FlexVolume daemonSet sidecar container.                                                                                                                                                                                                                                             |                                   |
| `ubiquityK8sProvisioner.resources`                       | Resources configuration required for deploying Kubernetes Provisioner.                                                                                                                                                                                                                                                                        |                                   |
| `customPodSecurityPolicy.enabled`                        | Custom pod security policy. If enabled, it is applied to all pods in the chart.                                                                                                                                                                                                                                                              | `false`                           |
| `customPodSecurityPolicy.clusterRole`                    | The name of clusterRole that has the required policies attached.                                                                                                                                                                                                                                                                              | `ibm-anyuid-hostpath-clusterrole` |
| `globalConfig.logLevel`                                  | Log level. Allowed values: debug, info, error.                                                                                                                                                                                                                                                                                                | `info`                            |
| `globalConfig.sslMode`                                   | SSL verification mode. Allowed values: require (No validation is required, the IBM Storage Enabler for Containers server generates self-signed certificates on the fly.) or verify-full (Certificates are provided by the user.).                                                                                                             | `require`                         |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Storage
IBM Storage Enabler for Containers allows IBM storage system volumes to be used for stateful applications running in Kubernetes clusters. The full list of supported IBM systems is detailed in the Enabler for Containers realease notes (see the Documentation section below).

## Troubleshooting
You can use the IBM Storage Enabler for Containers logs for problem identification. To collect and display logs, related to the different components of IBM Storage Enabler for Containers, use this script: 

```bash
./ubiquity_cli.sh -a collect_logs
```
The logs are kept in the `./ubiquity_collect_logs_MM-DD-YYYY-h:m:s` folder. The folder is placed in the directory, from which the log collection command was run.

## Limitations
* Only one type of IBM storage backend (block or file) can be configured on the same Kubernetes or ICP cluster.
* Only one instance of IBM Storage Enabler for Containers can be deployed in a Kubernetes cluster, serving all Kubernetes namespaces.
* None of the deployments under this chart  support scaling. Thus, their replica must be 1.

## Documentation
Full documentation set for IBM Storage Enabler for Containers is available on IBM Knowledge Center at https://www.ibm.com/support/knowledgecenter/SSCKLT.
