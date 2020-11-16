# IBM Db2 for z/OS Data Gate
=================================================================

## Introduction

IBM Db2 for z/OS Data Gate (Db2 Data Gate) propagates your data from a Db2 for z/OS subsystem to a Db2 LUW database through an integrated, low latency, high throughput synchronization protocol. With Db2 Data Gate, your read-only applications can quickly access your Db2 for z/OS data without impacting the performance of the core transaction engine.

# Details
The chart will do the followings:
* Create two deployments with data-gate as prefix for IBM Db2 for z/OS Data Gate and UI, which are traditional deployments follows a replica set of 1.
* Create two services with data-gate as prefix for IBM Db2 for z/OS Data Gate.
* Create a ConfigMap with data-gate as prefix, which provide IBM Db2 for z/OS Data Gate configuration.
* Create a Job with data-gate as prefix, which provide configure nginx rules for IBM Db2 for z/OS Data Gate.

## Chart Details
This chart will do the following:

- Deploy two deployments.
  - There are 4 containers in one deployment.
    - The init container "config-aese" does the initialization work for target database.
    - The init container "data-gate-stunnel-init" does the initialization work for encryption part.
    - The container "data-gate-stunnel" takes responsibility for data encryption/decryption  
    - The container "data-gate-server" hosts the server process to do management work.
    - The container "data-gate-apply"  hosts the apply process to sync data.
    - The container "data-gate-api" hosts the api process to provide the backend api for data gate ui.
  - The second deployment is for UI pod which provides UI for user to do add/load table and monitor status.
- Create a route to expose datagate instance to Z side.

# Prerequisites
* Kubernetes Level - ">=1.11.0"
* Architecture - "amd64" or "s390x"
* PersistentVolume requirements - requires NFS which is a mounted clustered filesystem across all worker nodes. We also support Glusterfs, Ceph and Portworx etc.
* IBM Db2 Advanced Enterprise Server Edition / IBM Db2 Warehouse Edition - ">= 11.5.1.0"

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-datagate-psp
    spec:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      allowedCapabilities:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      runAsUser:
        rule: RunAsAny
      fsGroup:
        rule: RunAsAny
      volumes:
      - configMap
      - secret
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    We use the pre-defined role "cpd-admin-role" in CP4D for datagate.

    - From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
      - Custom SecurityContextConstraints definition:
        ```
        apiVersion: security.openshift.io/v1
        kind: SecurityContextConstraints
        metadata:
          name: ibm-datagate-scc
        readOnlyRootFilesystem: false
        allowedCapabilities:
        - CHOWN
        - DAC_OVERRIDE
        - SETGID
        - SETUID
        - NET_BIND_SERVICE
        seLinux:
          type: RunAsAny
        supplementalGroups:
          type: RunAsAny
        runAsUser:
          type: RunAsAny
        fsGroup:
          rule: RunAsAny
        volumes:
        - configMap
        - secret
        ```

- From the command line, you can run the setup scripts included under pak_extensions
  As a cluster admin the pre-install instructions are located at:
  - pre-install/clusterAdministration/< your scripts...>

  As team admin the namespace scoped instructions are located at:
  - pre-install/namespaceAdministration/< your scripts...>

# SecurityContextConstraints Requirements

# Red Hat OpenShift SecurityContextConstraints Requirements
On Red Hat OpenShift Container Platform, this chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This custom SCC provided by CP4D and is installed as part of the CP4D install. A sample of the custom SCC from CP4D has been provided below for reference.

```
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups: []
kind: SecurityContextConstraints
metadata:
  name: cpd-user-scc
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- KILL
- MKNOD
- SETUID
- SETGID
runAsUser:
  type: MustRunAsRange
  uidRangeMax: 1000361000
  uidRangeMin: 1000320900
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users:
- system:serviceaccount:zen:cpd-viewer-sa
- system:serviceaccount:zen:cpd-editor-sa
- system:serviceaccount:zen:cpd-databases-sa
- system:serviceaccount:zen:cpd-cdcp-sa
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

# Resources Required
There is the minimum source request for Db2 Data Gate Instance.
* 4 Cores per node
* 16 GB Memory per node

# Installing the Chart
* This chart is to be installed via Cloud Pak for Data integrated interface using add-on logic.

1. Open the UI of datagate add-on
2. Click "new instance" button
3. Input the requested parameters on UI
4. Click "confirm" button
5. Check the stauts of new datagate instance in "my instance" Page.

For full step-by-step documentation on how to install this chart follow this link:
https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_latest/zen-docs/svc-welcome/dg.html

### Typical Resource Configuration of Singular Data Gate Instance.

| Workload Type | CPU | Memory |
|---------------|-----|--------|
| Small         |  4vCPUs  |   12GB   |
| Medium        |  6vCPUs  |   24GB   |
| Large         |  8vCPUs  |   32GB   |

### High Availability
1. We leverage the HA of deployment to make sure the datagate instance is always available.
2. We can deploy two datagate instances with the same source database on Z and different target database to eliminate the risk occurring at target database.

# Configuration
The following tables lists the configurable parameters of the Db2 Data Gate chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|arch|The helm chart will try to detect the architecture based on the master node. Choose an explicit architecture here to overwrite it.||
|database.name|The name of the database. Defaults to BLUDB|BLUDB|
|images.pullPolicy|The pull policy for docker images|IfNotPresent|
|limit.cpu|CPU cores limit for the database|2000m|
|limit.memory|Memory limit for the database|16Gi|
|storage.storageClassName|Choose a specific storage class name.||
|storage.existingClaimName|Name of an existing Persistent Volume Claim that references a Persistent Volume||
|storage.useDynamicProvisioning|If dynamic provisioning is available in the cluster this option will automatically provision the requested volume if set to true.|true|

# Storage
We support NFS as the data storage with the following way,
- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - Enable persistence for this deployment: selected (default) (persistence.enabled=true)
    - Use dynamic provisioning for persistent volume: selected (non-default) (persistence.useDynamicProvisioning=true)
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - Enable persistence for this deployment: selected (default) (persistence.enabled=true)
    - Use dynamic provisioning for persistent volume: non-selected (default) (persistence.useDynamicProvisioning=false)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.    


### Existing PersistentVolumeClaims

Example for specifying an existing PersistentVolumeClaim for the `data-stor` volume request,
1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart
```bash
$ helm install --name my-release --set dataVolume.existingClaimName=PVC_NAME
```

the PersistentVolumeClaim will be mount with access mode as 'read write many'
```
  accessModes:
  - ReadWriteMany
```

# Multiple instance support
IBM Db2 for z/OS Data Gate supports to provision multiple instance in a single Cloud Pak for Data cluster.

# Limitations
We do not want to scale our Db2 Data Gate deployment. This means we must leave the replica at 1. If we scale it over 1, the Db2 Date Gate instances will reference the same filesystem that consist of the instance, database directory, etc. This will cause Data Gate to crash.

* Chart can only run on amd64 or s390x architecture type.

# Must gather process
If you hit any issue, please gather the following log, and contact IBM Support to begin diagnosing,
1. View details of the Db2 Data Gate instance to identify your Deployment id, e.g. data-gate-1580866011565
2. On your Cloud Pak for Data master node, run this command to get your pod name
  oc get po|grep <Deployment id>
3. goto the pod
  oc exec -it <pod name> -c data-gate-server bash
4. Run gather_log.sh in the pod

# Documentation
KnowledgeCenter url: https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_latest/zen-docs/svc-welcome/dg.html
