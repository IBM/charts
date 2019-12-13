# IBM Meta Session Scheduler 1.2.2

## Legends

| Name | Details |
| ---- | ------- |
| MSS | IBM® WMLA Meta Session Scheduler|
| InfoService | MSS Info Service that is used for job history storage.|

## Introduction

IBM Spectrum Meta Session Scheduler is a generic job scheduler plugin for containers' cloud, like Redhat OpenShift and Kubernetes. It is IBM Watson Machine Learning Accelerator's backend job scheduler. IBM Spectrum Meta Session Scheduler 1.2.2 brings a wide range of job scheduling capability especially which includes:

* Hierarchical fairshare cross users
* Priority based user job scheduling
* Parallel and elastic jobs
* Elastic Job resource preemption
* Restful API

## Chart Details

With WMLA MSS Helm chart, you can deploy IBM WMLA MSS in the Kubernetes namespace and launch it quickly. Each MSS Helm chart deployment creates one MSS cluster in the namespace. Each MSS cluster is managed by its own wmla-mss pod. You can access MSS by REST api `http://wmla-mss:9080/dlim/v1/job`. Through the REST api, client can submit, query and kill jobs that are managed by MSS. For FINISHED/KILLED/ERROR jobs, client must using MSS InfoService REST api `http://wmla-infoservice:8892/dlim/v1/infoservice/history/query/job/${namespace}/<job id>` to query details.

## Prerequisites

### Storage
Make sure that the storage requests parameters are correctly set up before installing MSS.

This MSS chart requires shared storage facilities to save metadata for high availability.
- A persistent volume (>=1Gi) is mandatory for the MSS high availability, with the storage class name specified by etcd.storageClassName.
- A persistent volume (>=4Gi) is mandatory for Infoservice, with the storage class name specified by infoservice.storageClassName. Give permission for wmla user(15585) to read/write on shared directory used by persistent volume. Example: ``` chown 15585:15585 ${pvpath} ```
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

Note: The persistentVolumeReclaimPolicy used for PersistentVolumes (PVs) is `Retain`, so if you delete a PersistentVolumeClaim, the corresponding PersistentVolume will not be deleted. Instead, it is moved to the 'Released' state, and the data remains intact. If you want to use the same PV mount paths for next deployment, back up the relevant data, empty the directories and delete the PVs.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)

* Custom PodSecurityPolicy definition for a deployment named "wmla" in the namespace "custom":
  - Custom PodSecurityPolicy definition:
```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  labels:
    app.kubernetes.io/name: wmla-mss
    helm.sh/chart: ibm-mss-prod-1.0.0
    app.kubernetes.io/instance: wmla
    app.kubernetes.io/managed-by: Tiller
    release: wmla
  name: wmla-mss
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

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: wmla-mss
  namespace: custom
  labels:
    app.kubernetes.io/name: wmla-mss
    helm.sh/chart: ibm-mss-prod-1.0.0
    app.kubernetes.io/instance: wmla
    app.kubernetes.io/managed-by: Tiller
    release: wmla
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["endpoints", "configmaps"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch"]
- apiGroups: [""]
  resources: ["nodes", "persistentvolumeclaims", "resourcequotas"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
- apiGroups: ["batch", "extensions"]
  resources: ["jobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["ibm.com"]
  resources: ["paralleljobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["extensions"]
  resources: ["podsecuritypolicies"]
  resourceNames: ["wmla-mss"]
  verbs: ["use"]
```

## Red Hat OpenShift SecurityContextConstraints Requirements

The pods created by deploying the chart should be at a minimum [`privileged`](https://ibm.biz/cpkspec-scc) on OpenShift.

* Custom SecurityContextConstraints definition for a deployment named "wmla" in the namespace "custom":

  * Custom SecurityContextConstraints definition:

```yaml
kind: SecurityContextConstraints
apiVersion: v1
metadata:
  name: wmla-scc
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
- system:custom:wmla-mss
```

## Resources Required

The `IBM WML Accelerator Meta Session Scheduler CPU request` and `IBM WML Accelerator Meta Session Scheduler Memory request` parameters are the initial CPU and memory requests that are used to create the MSS container. The default values are 1 OS CPU and 2G memory, as listed in /proc/cpuinfo. These values cannot exceed 2 OS CPUs and 4G memory.

The `IBM WML Accelerator MSS Info Service CPU request` and `IBM WML Accelerator MSS Info Service Memory request` parameters are the initial CPU and memory requests that are used to create the MSS Info Service container. The default values are 1 OS CPU and 1G memory, as listed in /proc/cpuinfo. These values cannot exceed 2 OS CPUs and 2G memory.

For the number that you can specify for the CPU and memory columns, refer to the [Kubernetes Specification](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).

## Installing the Chart

IBM Meta Session Scheduler Helm Chart is listed in the management console dashboard. Go to catalog and search for ibm-mss-prod.
Click Configure and enter information for the Helm Release name and the Namespace fields.

Run the helm command to install the Helm chart. For example, to install an IBM Meta Session Scheduler deployment named "wmla" in the namespace "custom", run this command:

```bash
  helm install --name wmla --namespace custom --tls ibm-mss-prod
```

Note: Run this command from the Helm chart's "stable" directory.

You can use the following values to fine tune your IBM Meta Session Scheduler installation.

### Images and registries

The base image of the mss container is defined by `wml-accelerator-msd`, which is pushed to the default image registry "docker-registry.default.svc:5000".

## Configuration

The following table lists the configurable parameters of the ibm-mss-prod chart. You can modify the default values during installation as required.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|resources.requests.cpu|MSS container CPU request|1000m|
|resources.requests.memory|MSS container Memory request|2048Mi|
|logLevel|MSS logging level|INFO|
|infoservice.resources.requests.cpu|Info Service container CPU request|1000m|
|infoservice.resources.requests.memory|Info Service container Memory request|1024Mi|

## Uninstalling the Chart

Uninstall IBM WML Meta Session Scheduler by using one of the following methods, assuming the IBM WML Meta Session Scheduler release name is "wmla", namespace is "custom":

* Command: To remove IBM WML Meta Session Scheduler, run the following commands:

```bash
 helm delete wmla --purge --tls
```

The associated persistent volumes that were created prior for the deployment must to be deleted manually from the cluster management console. For more understanding on persistent volume clean up, see [Kubernetes guide](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy).

## Documentation

To learn more about IBM PowerAI, see [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SS5SF7_1.5.4/welcome/welcome.htm)

To learn more about using Watson Machine Learning Accelerator, see [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSFHA8).

To learn more about using IBM Spectrum Conductor Deep Learning Impact, see [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSWQ2D_1.2.1/gs/product-overview.html).

## Limitations
