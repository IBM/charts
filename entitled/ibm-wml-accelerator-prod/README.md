# IBM WML Accelerator

[IBM WML Accelerator](https://www.ibm.com/support/knowledgecenter/SSFHA8_1.2.1/wmla_kc_welcome.html) makes deep learning and machine learning more accessible to your staff, and makes the benefits of AI more obtainable for your business.


## Legends
| Name | Details |
| ---- | ------- |
| Management console dashboard | IBM® Cloud Pak for Data console dashboard|
| wmlamaster | Default name of the IBM WML Accelerator master node.|


## Introduction
IBM WML Accelerator provides GPU accelerated open source libraries and frameworks for deep learning and machine learning. It provides robust, end-to-end workflow support for deep learning lifecycle management, including installation and configuration; data preparation; building, optimizing, and training, validating, and inferencing the model.

## Chart Details
You can deploy IBM WML Accelerator as a Helm chart to quickly launch a master pod in the Kubernetes cluster. Each WML Accelerator Helm chart deployment creates one independently managed and isolated cluster in your environment.

## Prerequisites

### Storage
Make sure that the storage requests parameters are correctly set up before installing IBM Watson Machine Learning Accelerator.

This ibm-wml-accelerator-prod chart requires shared storage facilities to save metadata for high availability.

- A persistent volume (>=10Gi) is mandatory for the IBM WML Accelerator master and Spark instance group high availability, with the storage class name specified by master.sharedStorageClassName.
- A persistent volume (>=20Gi) is mandatory for shared deep learning storage for data sets etc, with the storage class name specified by dli.sharedFsStorageClassName. The packages must be in the format described below.
- A persistent volume (>=20Gi) is mandatory for shared conda environments used to run training jobs, with the storage class name specified by master.condaStorageClassName. Give permission for wmla user(15585) to read/write on shared directory used by persistent volume. Example: ``` chown 15585:15585 ${pvpath} ```
- A persistent volume (>=4Gi) is mandatory for infoservice, with the storage class name specified by infoservice.storageClassName. Give permission for wmla user(15585) to read/write on shared directory used by persistent volume. Example: ``` chown 15585:15585 ${pvpath} ```
- A persistent volume (>=10Gi) is mandatory for hpac, with the storage class name specified by hpac.storageClassName. You can define a persitent volume using the following sample definition for hpac.
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mylsfvol
  labels:
    lsfvol: "lsfvol"
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: "Retain"
  nfs:
    # FIXME: Use your NFS servers IP and export
    server: 10.1.1.1
    path: "/export/stuff"
```
Save the definition and replace the server and path values to match your NFS server. Note the labels. These are used to make sure that this volume is used with the chart deployment. The configuration files are located in this volume.


You can define a persistent volume either by using the following specification sample as input to the kubectl command.
```
# cat pv.yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
     name: pv-share
    spec:
     capacity:
      storage: 5Gi
     accessModes:
        - ReadWriteMany
     persistentVolumeReclaimPolicy: Retain
     # storageClassName: gold
     nfs:
            path: /root/share
            server: xx.xx.xx.xx

# oc create -f pv.yaml
```
If you uncomment "storageClassName = gold" in the above sample, then only a deployment with a storage request with the class name "gold" matches.

Note: The persistentVolumeReclaimPolicy used for PersistentVolumes (PVs) is `Retain`, so if you delete a PersistentVolumeClaim, the corresponding PersistentVolume is not be deleted. Instead, it is moved to the 'Released' state and the data remains intact. If you want to use the same PV mount paths for next deployment, back up the relevant data, empty the directories and delete the PVs.


### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition for a deployment named "wmla" in the namespace "custom":

  - Custom PodSecurityPolicy definition:
```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  labels:
    app: wmla-wmlamaster
    chart: "ibm-wml-accelerator-prod"
    heritage: "Tiller"
    release: "wmla"
  name: privileged-wmla
spec:
  allowPrivilegeEscalation: true
  allowedCapabilities:
  - LEASE
  - NET_BIND_SERVICE
  - NET_ADMIN
  - NET_BROADCAST
  - SETGID
  - SETUID
  - SYS_ADMIN
  - SYS_CHROOT
  - SYS_NICE
  - SYS_RESOURCE
  - SYS_TIME
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - KILL
  - SETFCAP
  fsGroup:
    rule: RunAsAny
  hostIPC: true
  hostNetwork: true
  hostPID: true
  hostPorts:
  - max: 65535
    min: 0
  privileged: true
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - '*'
  ```
  * Custom ClusterRole for the custom PodSecurityPolicy:

  ```
  apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: wmla-wmlamaster
    chart: "ibm-wml-accelerator-prod"
    heritage: "Tiller"
    release: "wmla"
  name: privileged-wmla
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["endpoints"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["nodes","persistentvolumeclaims"]
  verbs: ["get","list"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
- apiGroups: ["extensions"]
  resources: ["deployments", "deployments/scale"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: ["extensions"]
  resources: ["podsecuritypolicies"]
  resourceNames: [privileged-wmla]
  verbs: ["use"]

  ```
## Red Hat OpenShift SecurityContextConstraints Requirements

The pods created by deploying the chart should be at a minimum [`privileged`](https://ibm.biz/cpkspec-scc) on OpenShift.

* Custom SecurityContextConstraints definition for a deployment named "wmla" in the namespace "custom":

    - Custom SecurityContextConstraints definition:

```
kind: SecurityContextConstraints
apiVersion: v1
metadata:
  name: scc-wmla
  labels:
    release: "wmla"
allowPrivilegedContainer: true
allowedCapabilities:
  - LEASE
  - NET_BIND_SERVICE
  - NET_ADMIN
  - NET_BROADCAST
  - SETGID
  - SETUID
  - SYS_ADMIN
  - SYS_CHROOT
  - SYS_NICE
  - SYS_RESOURCE
  - SYS_TIME
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - KILL
  - SETFCAP
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
users:
- system:custom:cws-wmla
```

- The below SCC is required for HPAC

```
allowHostDirVolumePlugin: true
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities:
- KILL
- SETUID
- SETGID
- CHOWN
- SETPCAP
- NET_BIND_SERVICE
- DAC_OVERRIDE
- SYS_ADMIN
- SYS_TTY_CONFIG
allowedUnsafeSysctls:
- '*'
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups:
- system:cluster-admins
- system:nodes
- system:masters
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'this allows access to many privileged and host
      features and the ability to run as any user, any group, any fsGroup, and with
      any SELinux context.  WARNING: this is only for hpac.'
  name: ibm-lsf-scc
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
- NET_RAW
- SYS_CHROOT
- SETFCAP
- AUDIT_WRITE
- FOWNER
- FSETID
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
seccompProfiles:
- '*'
supplementalGroups:
  type: RunAsAny
users:
- system:admin
volumes:
- '*'
```
  ### Configuration files

  All the required files can be found in the ibm_cloud_pak/pak_extensions/prereqs directory of the downloaded archive. To deploy against a custom namespace with custom PodSecurityPolicy, follow the below steps.

  - Run the below script to create the custom namespace, PodSecurityPolicy, ClusterRole, ClusterRoleBindings and serviceaccount for this release of the chart.
  ```
  #  ./createSecurityNamespacePreReqs.sh <namespace> <release> <JWT public key file> <HPAC namespace>
  ```
  - secret_template.yaml: Use this file to create secrets with Base64 encoded username/password.
  - secret_helm_template.yaml: Use this file to create a Docker registry key.
  - serviceaccount_template.yaml: Use this file to create a service account.

### Creating ServiceAccount

Before installing IBM WML Accelerator, create a service account for your deployment. This step is not required if you are deploying with custom PodSecurityPolicy. The script createSecurityNamespacePreReqs.sh will create the service account for the deployment.

```
# cat service_account.yaml
	apiVersion: v1
        kind: ServiceAccount
        metadata:
          name: cws-<IBM WML Accelerator Helm release name>
          namespace: <WML Accelerator Helm release namespace>
        labels:
              app: <IBM WML Accelerator Helm release name>-wmlamaster
              chart: "ibm-wml-accelerator-prod"
              heritage: "Tiller"
              release: "<IBM WML Accelerator Helm release name>"

  # oc create -f service_account.yaml
```

### Kernel parameters
For the Elk Elasticsearch services to start and run correctly in IBM Watson Machine Learning Accelerator, vm.max_map_count must be set to 262144 on each node. You can check this value on any node by using following command:
```
  # cat /proc/sys/vm/max_map_count
  262144
```

If not already done, this can be set manually on a node by running `sudo sysctl -w vm.max_map_count=262144` .
To ensure that this value is maintained after the node restarts, add or edit `vm.max_map_count=262144` in the `/etc/sysctl.conf` file on the nodes.


## Resources Required
The `IBM WML Accelerator master CPU request` and `IBM WML Accelerator master memory request` parameters are the initial CPU and memory requests that are used to create the master container. The default values are 4 OS CPUs and 4G memory, as listed in /proc/cpuinfo. These values cannot exceed 16 OS CPUs and 16G memory.

For the number that you can specify for the CPU and memory columns, refer to the [Kubernetes Specification](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).

The number of GPUs is a nonzero positive integer.  The default value is one.

## Limitations
This chart supports IBM Cloud Pack for Data.

No encryption of the data at rest or in motion is provided by this chart. It is up to the administrator to configure storage encryption and IPSEC to secure the data.

Even though the WMLA installation gives a message like `Installation for assembly wml-accelerator completed successfully`, there is a  chance that HPAC and MSD pods may not be up because HPAC and MSD are subcharts deployed via Helm in the master pod. The CP4D operator pod does not wait for these pods to be up and running.

## Installing the Chart

Run the helm command to install the Helm chart. For example, to install an IBM WML Accelerator deployment named "paie" in the namespace "default", run this command:
```
  # helm install --name <WMLA-release-name> --namespace <namespace> -f ibm-wml-accelerator-prod/values.yaml ibm-wml-accelerator-prod 
```

Note: Run this command from the Helm chart's "stable" directory.

You can use the following values to fine tune your IBM WML Accelerator installation:

### Images and registries
The base image of the master container is defined by the `IBM WML Accelerator master image name` parameter, which is pushed to the default image registry "docker-registry.default.svc:5000".

### To run wmla on dedicated set of machines in a cluster
WMLA can not share GPU nodes with other workloads on same cluster. If there are multiple workloads which require GPU, for WMLA, we need to setup dedicated machines. Its a four step process.
1. Taint the nodes so that no other workload can run on dedicated machines
2. Add label to wmla machines so that wmla workload only run on dedicated machines
3. Add toleration to nvidia daemonset so that nvidia daemonset can run on all machines.
4. Add toleration/label information in wmla override file before wmla installation

In a multi-tenant wmla deployment these steps needs to be done when we deploy wmla first time. These steps are explained below in detail

### Taint a compute node to be tolerated by a specific namespace

To taint a compute node, use the following command:
`oc adm taint nodes <node-name> <taint-key>=<taint-value>:<taint-effect>`

### Label a compute node to be tolerated by a specific namespace

To label a compute node for wmla, use the following command:
` oc label nodes <node-name> <label-key>=<label-value>`

We only use node label key and ignore its value in wmla config.

### Deploy nvidia-device-plugin daemonset

Once the NVIDIA device plugin is installed, next step is to deploy the NVIDIA device plugin daemonset and instructions are here https://github.com/zvonkok/origin-ci-gpu/blob/release-3.11/doc/How%20to%20use%20GPUs%20with%20DevicePlugin%20in%20OpenShift%203.11%20.pdf

In https://github.com/redhat-performance/openshift-psap/blob/master/blog/gpu/device-plugin/nvidia-device-plugin.yml need to add a toleration `- operator: Exists`

## Configuration
The following table lists the configurable parameters of the ibm-wml-accelerator-prod chart. You can modify the default values during installation as required.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| master.name      | IBM WML Accelerator master name        | wmlamaster                                            |
| master.cpu       | IBM WML Accelerator master CPU request | 4000m                                          |
| master.memory            | IBM WML Accelerator master memory request   | 4096Mi                            |
| master.sharedStorageClassName      | IBM WML Accelerator master HA storage class name       |       |
| master.condaStorageClassName       | IBM WML Accelerator conda storage class name       |       |
| master.existingcondaPVC            | IBM WML Accelerator pre existing conda pvc         |       |
| master.imagePullPolicy | IBM WML Accelerator master image pull policy              | Always                           |
| sig.maxReplicas       | Maximum compute containers      | 10                           |
| sig.cpu      | compute container CPU request         | 1000m                     |
| sig.memory   | compute container memory request        | 2144Mi            |
| sig.gpu      | compute container GPU request     |        0                       |
| sig.ssAllocationUnit           | The unit of dynamic scaling compute containers      | 2          |
| sig.ssAllocationInterval      | The interval of dynamic scaling compute containers    | 120      |
| dli.enabled     | Enables IBM Spectrum Conductor Deep Learning Impact    | true              |
| isOcpIr  | isOcpIr is true if the internal docker registry is used on OCP (OpenShift Container Platform), false otherwise    | false |
| isCp4dAddon | set isCp4dAddon to true  | false |
| cluster.basePort        | NodePort used for all HTTPS access to the application   |     30745                   |
| cluster.ascdDebugPort        | A debug port for troubleshooting internal daemons    |     31311                   |
| cluster.tlsCertificateSecretName      | Secret holding a custom TLS certificate for GUI and API traffic   | nil - a self signed certificate is created by default  |
| cluster.useDynamicProvisioning        | A flag for turning on Dynamic Provisioning   |     false                   |
| singletons.namespace | Namespace where shared resources reside. Note: ALL releases must use the same singleton namespace or singleton cleanup may fail when the last release is deleted. | wmla-singletons |
| singletons.condaParentHostPath | Parent directory for WMLA conda environments created on applicable nodes | /var/data/wmla-conda |
| singletons.setNodesMaxMapCount | Deploy DaemonSet which uses privileged pods that set vm.max_map_count on all nodes. Also alters singletons PodSecurityPolicy to allow privileged pods | false |

Specify each parameter using the "--set key=value[key=value]" argument like "--set sig[gpu=2]"  with the "helm install" command

Alternatively, a YAML file that contains the values for the parameters can be specified when you install the chart.

## Storage

### Storage class names
Use a known storage with a class name. If you leave the `XXX storage class name` parameter empty, Kubernetes uses the default storageclass that is defined by either the Kubernetes system administrator or any available PersistentVolume in the system that can satisfy the capacity request (e.g. 5Gi).


## Uninstalling the Chart

Uninstallation of IBM WML Accelerator involves two parts . This section will provide instructions on uninstalling both IBM WML Accelerator and wmla-hpac-ibm-wmla-pod-scheduler. 

### Uninstalling IBM WML Accelerator

add updated steps here in different PR

### Uninstalling wmla-hpac-ibm-wmla-pod-scheduler 
The wmla-hpac-ibm-wmla-pod-scheduler should only be removed when there is no other instance of IBM WML Accelerator running on the cluster.

- Command: To remove wmla-hpac-ibm-wmla-pod-scheduler deployed in the namespace `hapc-ns`, run the following commands:
```
# oc delete project hpac-ns
```
- Command: Verify that all the persistent volume claim(PVC) are also deleted. The following command should return nothing. 
```
# oc get pv | grep wmla-hpac-ibm-wmla-pod-scheduler-prod
```
- Command: If PVC is not deleted , run the below commands to delete the associated pv for example `hpacshare-pv` manually.
```
# oc delete pv hpacshare-pv
```
- Command: To remove cluster scope artifacts , run the below commands
```
# oc delete customresourcedefinitions.apiextensions.k8s.io “paralleljobs.ibm.com”
```


#TODO : update these instructions
Uninstall IBM WML Accelerator by using one of the following methods, assuming the IBM WML Accelerator release name is "wmla":
- Command: To remove IBM WML Accelerator, run the following commands:
```
# oc get deployment --namespace wmla | sed -e 1d | awk '{print $1}' | xargs helm delete --purge --tls
# oc delete namespace wmla
```
- Command: To remove the chart secrets, run the following commands:
```
# oc get secrets -n <WML Accelerator Helm release namespace>
# oc delete secret <secret name associated with the Chart> -n  <WML Accelerator Helm release namespace>
```
- Command: To remove all the chart secrets, service accounts, pod security policy, cluster roles, cluster role bindings use the following script from ibm_cloud_pak/pak_extensions/prereqs directory, where pod security policy <psp> can be 'customPSP' or 'defaultPSP':
```
  # ./cleanup.sh <namespace> <release> <psp>
```

The associated persistent volumes that were created prior to the deployment must to be manually deleted from the cluster management console. For more indormation about persistent volume cleanup, see the [Kubernetes guide.](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy)

## Documentation
To learn more about Watson Machine Learning Accelerator, see the [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSFHA8_1.2.1/wmla_kc_welcome.html)

To learn more about using IBM Spectrum Conductor Deep Learning Impact, see [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSWQ2D_1.2.1/gs/product-overview.html).
