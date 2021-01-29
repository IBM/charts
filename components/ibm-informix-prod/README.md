## IBM Informix Helm Chart
IBM&reg; Informix is a fast and scalable database server that manages traditional relational, object-relational, and dimensional databases. Its small footprint and self-managing capabilities are suited for enterprise and embedded data-management solutions.


### Introduction
This chart configures IBM Informix and Installs the [IBM Informix Database Server](https://www.ibm.com/support/knowledgecenter/SSGU8G_14.1.0/com.ibm.welcome.doc/welcome.htm) data store in IBM OpenShift cluster.


### Chart Details

### Prerequisites
- OpenShift Container Platform (OCP) V4.2 or later
- API key for accessing IBM entitled registry
- Helm 3


### ClusterRole

```YAML
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: informix-cr
rules:
- apiGroups:
  - extensions
  resources:
  - podsecuritypolicies
  resourceNames:
  - informix-psp
  verbs:
    - use
- apiGroups: [""]
  resources: ["pods", "pods/log", pods/exec]
  verbs: ["get", "list", "patch", "watch", "update", "create"]

- apiGroups: [""]
  resources: ["services"]
  verbs: ["get", "list"]

- apiGroups: ["batch", "extensions"]
  resources: ["jobs"]
  verbs: ["get", "list", "watch", "patch"]
```


# SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.
The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints

  - Custom SecurityContextConstraints definition:
```YAML
kind: SecurityContextConstraints
apiVersion: v1
metadata:
  name: informix-scc
allowHostDirVolumePlugin: true
allowHostIPC: true
allowHostNetwork: false
allowHostPID: false
allowHostPorts: true
allowPrivilegedContainer: false
allowedCapabilities:
- "SYS_RESOURCE"
- "IPC_OWNER"
- "SYS_NICE"
- "NET_RAW"
- "CHOWN"
- "DAC_OVERRIDE"
- "FSETID"
- "FOWNER"
- "SETGID"
- "SETUID"
- "SETFCAP"
- "SETPCAP"
- "NET_BIND_SERVICE"
- "SYS_CHROOT"
- "KILL"
- "AUDIT_WRITE"
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
fsGroup:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
```


## Resources Required
The following values are the minimum required resources limit for Informix database server.

| Software  | Memory (MB) | CPU (cores) | Disk (MB) | Nodes |
| --------- | ----------- | ----------- | --------- | ----- |
| Server    |    200      |     1       |   500     |   1   |



### Request to deploy Informix server POD to a subset of nodes
Informix server POD has toleration for `IfxSccGroup` taint. If you have a need for Informix server POD to be deployed exclusively on a subset of worker nodes in a cluster then those worker nodes to be appled with `IfxSccGroup` taint and `informix-scc-nodes` label. The node affinity preference for this label is set to `preferredDuringSchedulingIgnoredDuringExecution`.

```bash
# Example for applying taint and label on a node
oc adm taint nodes worker1.example.com Tainted4Informix=IfxSccGroup:NoSchedule
oc label nodes worker1.example.com informix-scc-nodes=ifx-custom-scc
```


## Installing the Chart

Installation of IBM Informix server require Informix specific `Security Context Constraints (SCC)` policies to be applied on the OpenShift cluster, it is a one time process on the cluster. Please complete the step specified in [Pre Install Cluster Setup for IBM Informix](../../case/ibm-informix/inventory/ibmInformixProdSetup/README.md) prior to the IBM Informix server installation.


If you have completed the OneTimeSetUp mentioned above then you may initiate the actual installation of Informix server.
```bash
# helm install {my-release} {chart-repository-name}/{chart name} [optional parameters]
helm install ifx-rel-v1 ibm-informix-prod/stable/ibm-informix-bundle/charts/ibm-informix-prod

# FYI: The instance that you created can be uninstalled by using
helm uninstall ifx-rel-v1
```


## Configuration Options

By any chance if you like to override the default option, the you may pass it as command line argument to the HELM install. 

For example, here is a usage of overriding the image registry option and CPU. 
```bash
helm install ifx-rel-v1 ibm-informix-prod/stable/ibm-informix-bundle/charts/ibm-informix-prod \
       --set images.eng.image.registry=cp.stg.icr.io,resource.requests.cpu=2
```
The following tables lists the configurable parameters of the IBM Informix chart and their default values

| Parameter                            | Description                                     | Default                                                                    |
| ----------------------------------   | ---------------------------------------------   | -------------------------------------------------------------------------- |
| `images.eng.image.registry`          | container image registry                        | `cp.icr.io`                                                                |
| `images.eng.image.repository`        | container image repository                      | `cp/cpd/informix-eng`                                                      |
| `images.eng.image.tag`               | container image tag                             | `14.10.5.28`                                                                |
| `dataVolume.size`                    | Size of data volume                             | `20Gi`                                                                     |
| `resources.requests.memory`          | Memory resource request                         | `100m`                                                                     |
| `resource.requests.cpu`              | CPU resource request                            | `200m`                                                                     |
| `resources.limits.memory`            | Memory limit                                    | `1024Gi                                                                    |
| `resource.limits.cpu`                | CPU resource limit                              | `128`                                                                      |
| `persistence.storageClass`           | Storage class of backing PVC                    | `rook-ceph-cephfs-internal`                                                |
| `persistence.size`                   | Size of data volume                             | `5Gi`                                                                      |


### Storage
The IBM® Informix Cloud Pak for Data add-on has tested with the following three storage type.
- NFS
- Portworx
- rook-ceph

##### File system permissions
The `owner` and `group` of the file system is `informix` and volume access mode is `755`

##### Persistent volume storage access modes
IBM Informix server supports only `ReadWriteOnce` (RWO) access mode; the volume can be mounted as read-write by a single node.


### Limitations
- Limited console facility: enhanced console facility is expected to be in next release.

