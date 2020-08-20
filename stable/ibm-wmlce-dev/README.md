[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # (\(C\) Copyright IBM Corporation 2018,2019 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)


# IBM Watson Machine Learning Community Edition

THIS CHART IS NOW DEPRECATED. On August 20th, this version of the Helm chart for IBM WML CE will no longer be supported. This chart will be removed on September 20th, 2020.

[IBM Watson Machine Learning Community Edition (WML CE)](https://developer.ibm.com/linuxonpower/deep-learning-powerai/) makes deep learning, machine learning, and AI more accessible and more performant.

## Introduction

IBM WMLCE incorporates some of the most popular deep learning frameworks along with unique IBM augmentations to improve cluster performance and support larger deep learning models. 


## Chart Details

- Deploys a pod with the WMLCE container with all of the supported WMLCE Frameworks.
- Supports persistent storage, allowing you to access your datasets and provide your training application code to the pod.
- Provides control over the command that is run during pod startup.
- Allows you to control which GPU Type is used. Useful when running multiple worker nodes of different GPU Type. i.e. AC922 with V100 and 822LC with P100

## Prerequisites

- Kubernetes v1.11.3 or later with GPU scheduling enabled, and Tiller v2.7.2 or later
- The application must run on nodes with *supported GPUs* [see IBM WML CE V1.6.1 release notes](https://developer.ibm.com/linuxonpower/deep-learning-powerai/releases/).  
- Helm 2.7.2 and later version
- If you wish to leverage persistent storage for data sets and/or runtime code, you should enable `persistence.enabled=true` and create your persistent volume prior to deploying the chart (unless you use `dynamic provisioning`).  It can be created by using the IBM Cloud private UI or via a yaml file as in the following example:
Note: accessModes can be ReadWriteOnce/ReadWriteMany/ReadOnlyMany

```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: "wmlce-datavolume"
  labels:
    type: local
spec:
  storageClassName: ""
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/wmlce/data"

```

### PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator setup a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-wmlce-psp
spec:
  allowPrivilegeEscalation: true
  requiredDropCapabilities: 
  - ALL
  allowedCapabilities: 
  - AUDIT_WRITE 
  - CHOWN 
  - FOWNER             
  - SETUID 
  - SETGID 
  - SYS_CHROOT
  - IPC_LOCK
  - SYS_PTRACE
  - SYS_RESOURCE
  - DAC_OVERRIDE
  - NET_BIND_SERVICE
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
  annotations:
  name: ibm-wmlce-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-wmlce-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
```
* Custom ClusterRoleBinding for the custom ClusterRole:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ibm-wmlce-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ibm-wmlce-clusterrole
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:{{ NAMESPACE }}
```
### Prereq configuration scripts can be used to create and delete required resources

- Find the following scripts in pak_extensions/prereqs directory of the downloaded archive.

  - createSecurityClusterPrereqs.sh to create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  - createSecurityNamespacePrereqs.sh to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
    Example usage: ./createSecurityNamespacePrereqs.sh myNamespace
  - deleteSecurityClusterPrereqs.sh to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
  - deleteSecurityNamespacePrereqs.sh to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
    Example usage: ./deleteSecurityNamespacePrereqs.sh myNamespace

## Resources Required

Generally WMLCE leverages GPUs for training and inferencing. You can control the number of GPUs a given pod has access to using the `resources.gpu` value.  Setting it to 0 will allow deployment on a non-gpu system.
You can also control the GPU-type that is assigned to a given pod. Set this using the `resources.gputype` value. This uses a nodeSelector label of `gputype` (E.G. gputype=nvidia-tesla-v100-16gb) and will need to be configured prior to Helm chart deployment. This is useful when running a mix of GPU-enabled Worker nodes, For Example: IBM Power Systems AC922 (POWER9) with V100 GPUs and IBM Power Systems 822LC for HPC (POWER8) with P100 GPUs.

CPU - A minimum of 8 ppc64le/amd64 hardware cores
Memory - A minimum of 16 GB
Storage - 40GB minimum persistent storage

## Limitations

* This chart is intended to be deployed in IBM Cloud Private.
* This chart provides some basic building blocks to get started with WMLCE.  It is generally expected (though not required) that the WMLCE docker image and helm chart would be extended for a specific production use case.
* When DDL/Distributed mode with InfiniBand is enabled, IPC_LOCK, SYS_PTRACE, SYS_RESOURCE, and hostPID capabilities will be added.
* Distributed mode can be used to deploy cluster for all distrubuted frameworks like SnapMl/DDL.
* In future releases `ddl` option will be deprecated.
* DDL/Distributed mode with Infiniband is only supported when all worker nodes are running on RHEL as the host operating system.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --namespace <your pre-created namespace> --name my-release --set license=accept stable/<chartname> 
```

The command deploys ibm-wmlce-dev on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list --tls`

## Verifying the Chart

See NOTES.txt associated with this chart for verification instructions.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release. After deleting the chart, you should consider deleting any persistent volume that you created.

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.


```console
$ kubectl delete pvc -l release=my-release
```
```console
$ kubectl delete pv <name_of_pv>
```

## Configuration
The following table lists the configurable parameters of the `ibm-wmlce-dev` chart and their default values.

| Parameter                        | Description                                     | Default                                                    |
| -------------------------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| `license`                        | Set `license=accept` to accept the terms of the license | `Not accepted`                                     |
| `image.repository`               | WMLCE image repository.          | `docker.io/ibmcom/powerai`                       |
| `image.tag`                      | Docker Image tag. To get the tag of other images, visit "hub.docker.com/r/ibmcom/powerai"                                    | `1.6.1-all-ubuntu18.04`                                                        |
| `image.pullPolicy`               | Docker Image pull policy (Options - IfNotPresent, Always, Never)                              | `IfNotPresent`                                             |
| `global.image.secretName`               | Docker Image pull secret, if you are using a private Docker registry | `nil`                                        |
| `service.type`                   | Kubernetes service type for exposing ports (Options - ClusterIP, None)       | `nil`                                  |
| `service.port`                   | Kubernetes port number to expose       | `nil`                                  |
| `resources.gpu`          | Number of GPUs on which to run the container. A value of 0 will not allocate a GPU.  | `1`                                                   |
| `resources.gputype`      | Type of GPU on which to run the container. Requires use of nodeSelector label of gputype to be configured prior. (E.G. gputype=nvidia-tesla-v100-16gb). | `nvidia-tesla-v100-16gb`
| `paiDistributed.mode`            | Enable WMLCE Distributed mode.  | `false`                                                   |
| `paiDistributed.gpuPerHost`            | Number of GPUs per host .  | `4`                                                   |
| `paiDistributed.sshKeySecret`            | Secret containing 'id_rsa' and 'id_rsa.pub' keys for the containers.  | `nil`                                                   |
| `paiDistributed.useHostNetwork`            | For better performance with TCP, use the host network. WARNING: SSH port needs to be different than 22.  | `false`                                                   |
| `paiDistributed.sshPort`            | Port used by SSH.  | `22`                                                   |
| `paiDistributed.useInfiniBand`         | Use InfiniBand for cross node communication. | `false`                                                   |
| `ddl.enabled`            | Enable WMLCE Distributed mode when using DDL.  | `false`                                                   |
| `ddl.gpuPerHost`            | Number of GPUs per host when using DDL.  | `4`                                                   |
| `ddl.sshKeySecret`            | Secret containing 'id_rsa' and 'id_rsa.pub' keys for the containers.  | `nil`                                                   |
| `ddl.useHostNetwork`            | For better performance with TCP, use the host network. WARNING: SSH port needs to be different than 22.  | `false`                                                   |
| `ddl.sshPort`            | Port used by SSH.  | `22`                                                   |
| `ddl.useInfiniBand`         | Use InfiniBand for cross node communication. | `false`                                                   |
| `persistence.enabled`       | Use a PVC to persist data | `false`                                              |
| `persistence.useDynamicProvisioning`        | Use dynamic provisioning for persistent volume | `false`                                                 |
| `wmlcePVC.name`        | Name of volume claim | `datavolume`                                                 |
| `wmlcePVC.accessMode`        | Volume access mode (Options: ReadWriteOnce, ReadWriteMany, ReadOnlyMany) | `ReadWriteMany`                                                 |
| `wmlcePVC.existingClaim`        | Data PVC existing claim name | nil (will create a new claim by default)                                                 |
| `wmlcePVC.storageClassName`     | Data PVC Storage class | nil (uses default cluster storage class for dynamic provisioning)                                            |
| `wmlcePVC.size`              | Data PVC size                          | `8Gi`                                        |
| `command`              | Command need to run inside pod. E.G. /usr/bin/python /wmlce/data/train.py;                           | `nil`

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.
```bash
$ helm install --tls --namespace <your pre-created namespace> --name my-release --set license=accept; \
resources.gpu=1 stable/<chartname>
``` 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.
> **Tip**: The default values are in the values.yaml file of the WMLCE chart.

```bash
$ helm install --name my-release -f values.yaml stable/<chartname>
```

The volume is mounted in /wmlce/data when `persistence.enabled=true`


## Storage

You can optionally provide a persistent volume to the deployment. This volume can hold data that you wish to process, as well as executables for the command you wish to run. For example, if you had python code that would train a model on a given set of data, this volume would host your python code as well as your data, and you can run the python code by specifying the appropriate command.
