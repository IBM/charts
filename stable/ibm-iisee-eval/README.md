# IBM InfoSphere Information Server for Evaluation Helm Chart

[InfoSphere Information Server](https://www.ibm.com/analytics/us/en/technology/information-server/) provides you with complete information management and governance solutions for analytical insights to create business value through data. 

## Introduction

This chart provides the deployment of IBM InfoSphere Information Server for Evaluation. 

## Chart Details

This chart will do the following
- It deploys all tiers of Information Server in a single pod 
- It deploys Unified Governance pods

## Prerequisites

- Chart should be installed by reviewing and accepting the license terms and conditions.
- PersistentVolume support on the underlying infrastructure
- A dynamic provisioner for the PersistentVolumes

## Resources Required

- Resource Requirements - Default values are set for  CPU, Memory, Storage. Modify the values at the installation time based on expected workload

Default parameters values for the cpu and memory to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                |resources.requests.cpu|resources.requests.memory|
|-------------------------------|----------------------|-------------------------|
|**iisService**		        |2000m                 |6000Mi                   |
|**solrService**                |200m                  |1000Mi                   |
|**cassandraService**           |2000m                 |4000Mi                   |
|**kafkaService**               |500m                  |1000Mi                   |
|**zookeeperService**           |500m                  |2000Mi                   |
|**otherServices**              |500m                  |2000Mi                   |

### Storage Parameters

| Prefix/Suffix                         | volumeClaim.size          | volumeClaim.storageClassName | volumeClaim.existingClaimName|
|---------------------------------------|---------------------------|------------------------------|------------------------------|
|cassandra                              | 5Gi                       | `nil`                        |  `nil`                       |
|zookeeper                              | 5Gi                       | `nil`                        |  `nil`                       |
|kafka                                  | 5Gi                       | `nil`                        |  `nil`                       |
|elasticsearch                          | 5Gi                       | `nil`                        |  `nil`                       |
|logstash                               | 5Gi                       | `nil`                        |  `nil`                       |
|solr                                   | 5Gi                       | `nil`                        |  `nil`                       |
|iisService                             | 1Mi                       | `nil`                        |  `nil`                       |
## Installing and Removing the Chart

### Installing the Chart

- If deploying the chart to a non-default namespace, ensure to set the Pod Security Policy as per [this link](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/app_center/nd_helm.html). The chart uses `HOST_IPC` access and the following capabilities: `IPC_OWNER, SYS_NICE, SYS_RESOURCE, SYS_ADMIN`
- Chart uses Persistent Volumes. Dynamic provisioning of Persistent Volumes is enabled by default. The cluster should be set up with Dynamic Provisioning (e.g. GlusterFS). See [persistence](#persistence) section. If dynamic provisioning is not enabled, create the persistent volumes using the template below


```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cas-pv
  labels:
    assign-to: "<RELEASE_NAME>-cassandra"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: <NFS SERVER> 
    path: <NFS PATH>/cassandra
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: es-pv
  labels:
    assign-to: "<RELEASE_NAME>-es"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: <NFS SERVER>
    path: <NFS PATH>/es
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: kafka-pv
  labels:
    assign-to: "<RELEASE_NAME>-kafka"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: <NFS SERVER>
    path: <NFS PATH>/kafka
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: log-pv
  labels:
    assign-to: "<RELEASE_NAME>-logstash"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: <NFS SERVER>
    path: <NFS PATH>/log
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: zk-pv
  labels:
    assign-to: "<RELEASE_NAME>-zookeeper"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: <NFS SERVER>
    path: <NFS PATH>/zk
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: secret-pv
  labels:
    assign-to: "<RELEASE_NAME>-iiscert"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: <NFS SERVER>
    path: <NFS PATH>/secret
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: solr-pv
  labels:
    assign-to: "<RELEASE_NAME>-solr"
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: <NFS SERVER>
    path: <NFS PATH>/solr

```


#### Deploying IIS Evaluation 

To deploy IIS Evaluation using IBM Cloud Private UI, please do the following steps:
- Click Configure button
- Fill in release name
- Fill in namespace
- Accept the license agreement
- Click on Install button

You can deploy manually by executing the helm CLI:

```bash
$ helm install --name my-release --set license=accept stable/ibm-iisee-eval
```

The command deploys ibm-iisee-eval on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

### Verifying the Chart
After installation, go to Helm releases menu:
Click on the release name and scroll to Notes section
```
Notes
IBM InfoSphere Information Server for Evaluation v11.7 is delivered as an interconnected set of pods and kubernetes services.  
Ensure all pods are up and running before trying to access the application.                                                                                   

To obtain the haproxy port to access the IIS launchpad, run the below command

export NODE_PORT_HAPROXY=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ template "fullname" . }}-haproxy)

To obtain the IIS port to access the DataStage Flow Designer, run the below command

export NODE_PORT_IIS=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ .Release.Name }}-iis-service)

Use https://<external ip>:$NODE_PORT_HAPROXY/ibm/iis/launchpad to access the IIS launchpad. 

Use https://<external ip>:$NODE_PORT_IIS/ibm/iis/dscdesigner to access DataStage Flow Designer.

  IIS admin user/password      : isadmin/P455w0rd

```

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. 

## Configuration

The following tables lists the configurable parameters of the ibm-iisee-eval chart and their default values.

### Common Parameters

| Parameter                                 | Description                       | Default Value                |
|-------------------------------------------|-----------------------------------|------------------------------|
| release.image.pullPolicy                  | Image Pull Policy                 | IfNotPresent                 |
| release.image.repository                  | Image Repository                  | iighostd                     |
| release.image.tag                         | Image Tag                         | 11.7                        |
| persistence.enabled                       | Enable persistence                | true                         |
| persistence.useDynamicProvisioning        | Use Dynamic PV Provisioning       | true                         |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default [values.yaml](values.yaml)

## Storage

- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - persistence.enabled: true (default)
    - persistence.useDynamicProvisioning: true (default)
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.

- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - persistence.enabled: true (default)
    - persistence.useDynamicProvisioning: false (non-default)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.    

The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) volume. The volume is created using dynamic volume provisioning. If the PersistentVolumeClaim should not be managed by the chart, define `persistence.existingClaim`.

### Existing PersistentVolumeClaims

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart
```bash
$ helm install --set persistence.existingClaim=PVC_NAME
```
## Limitations
- The chart can be installed on amd64 intel platform only
- The Information Server pod does not have persistent volume. If the pod is restarted, data will be lost
- To deploy more than once in the same namespace or different namespace, modify the port numbers in the configuration details
- Validated to run on IBM Cloud Private

