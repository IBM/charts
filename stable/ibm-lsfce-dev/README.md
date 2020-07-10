# IBM Spectrum LSF Community Edition

# **Notice of Deprication**
THIS CHART IS NOW DEPRECATED. On 1st July, 2020 this version of the Helm chart for IBM Spectrum LSF Community Edition will no longer be supported. This chart will be removed from the catalog on August 1st, 2020. There is currently no replacement available for this free version.  

[IBM Spectrum LSF Community Edition](https://www.ibm.com/support/knowledgecenter/en/SSWRJV_10.1.0/lsf_offering/lsfce10.1_quick_start.html) is a no-charge edition of IBM Spectrum LSF workload management platform.

## Introduction

This chart is not intended for separate use. It
is intended for use with IBM Cloud Private product. IBM Cloud Private is a, Kubernetes based, container management solution.  IBM Spectrum LSF Community Edition is a no-charge edition of IBM Spectrum LSF workload management platform.  IBM Spectrum LSF is a powerful workload management system for distributed computing environments. IBM Spectrum LSF provides a comprehensive set of intelligent, policy-driven scheduling features that enable you to utilize all of your compute infrastructure resources and ensure optimal application performance.

## Prerequisites
- A persistant volume claim is required for this chart.  It should be at least 1GByte and have ReadWriteMany access.  Prior to deploying the chart create the persistent volume claim.  Set the global.storage.existingClaimName to the name of the persistent volume claim during the installation of the chart. 

- IBM Spectrum LSF Community Edition is restricted to 2 CPU sockets.  If IBM Cloud Private has been installed on virtual machines, they should  be limited to 2 CPUs.

- A nodeSelector is used limit the machines to run on.  Tag the machines that have 2 CPU sockets by running:
```bash
$ kubectl get nodes --show-labels
$ kubectl label nodes {Name of node from above command} deploy_lsf=true
```


## Installing the Chart

To install the chart:

```bash
$ helm install --set global.dataVolume.existingClaimName={PVC_NAME} ibm-lsfce-dev
```

The command deploys ibm-lsfce-dev. The GUI can be accessed from IBM Cloud Private GUI by navigating to the Workloads, Services, and searching for the LSF CE Cluster and click on the Node port. 

The LSF Community Edition can have up to 10 nodes in the cluster, 1 master and 9 workers.  Set the global.lsf.worker.replicas to control the number of worker nodes.

The default login/password for the web GUI is lsfadmin / lsfadmin
The URL can be determined by running:
```bash
$ export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services `my-release`)
$  export NODE_IP=$(kubectl get --namespace default -o jsonpath="{.spec.clusterIP}" services `my-release`)
$  echo http://$NODE_IP:$NODE_PORT
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  Data written to the persistant volume claim will remain including any jobs submitted to the system.

## Configuration
The following table lists the configurable parameters of the ibm-lsfce-dev and lsf-slave charts and there default values.

| Parameter                     | Description                                     | Default                                |
| --------------------------    | ---------------------------------------------   | -------------------------------------- |
| `global.lsf.worker.replicas`  | The number of workers in the cluster.  Max 9    | `1`                                    | 
| `global.lsf.worker.cpu`       | The CPU resource to assign to the slave         | `200m`                                    | 
| `global.lsf.worker.memory`    | The Memory resources to assign to the slave     | `200Mi`                                      | 
| `global.lsf.image.repository` | `LSFCE` image repository                        | `ibmcom/lsfce`                         | 
| `global.lsf.image.tag`        | `LSFCE` image repository tag                    | `10.1.0`                               | 
| `global.lsf.image.pullPolicy` | The policy for processing missing images        | `IfNotPresent`                         | 
| `global.storage.existingClaimName`  | Name of an existing PersistentVolumeClaim to reuse | `lsf`                           | 
| `mariadb.image.repository`    | `mariadb` image repository                      | `ibmcom/mariadb`                       | 
| `mariadb.image.tag`           | `mariadb` image repository tag                  | `10.1.16`                              | 
| `mariadb.password`            | The default password for the database           | `passw0rd`                             | 

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

## Persistence

The chart requires an existing PersistentVolumeClaim.

- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart. 
  - Set the global.storage.existingClaimName to the name of the PersistentVolumeClaim

- The PersistentVolume can be created either by filling in the appropriate values in the IBM Cloud Private GUI, or using the json below.  Note the storage size, server IP, and path to the NFS export have to be set.
```bash
{
  "kind": "PersistentVolume",
  "apiVersion": "v1",
  "metadata": {
    "name": "lsf",
    "labels": {}
  },
  "spec": {
    "capacity": {
      "storage": "1Gi"
    },
    "accessModes": [
      "ReadWriteMany"
    ],
    "persistentVolumeReclaimPolicy": "Recycle",
    "nfs": {"server": "{IP Address of NFS Server}", "path": "{NFS Export Path}"}
  }
}
```

- Likewise the PersistentVolumeClaim can be created either by filling in the appropriate values in the IBM Cloud Private GUI, or using the json below. 
```bash
{
  "kind": "PersistentVolumeClaim",
  "apiVersion": "v1",
  "metadata": {
    "name": "lsf"
  },
  "spec": {
    "resources": {
      "requests": {
        "storage": "1Gi"
      }
    },
    "accessModes": [
      "ReadWriteMany"
    ]
  }
}
```

### Existing PersistentVolumeClaims

1. Create the PersistentVolume
2. Create the PersistentVolumeClaim
3. Install the chart
```bash
$ helm install --set global.dataVolume.existingClaimName=PVC_NAME
```

