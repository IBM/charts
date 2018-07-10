# GlusterFS Storage cluster

## Introduction

[GlusterFS](https://www.gluster.org/) is a Scale Out Network Attached Storage file system.

[Heketi](https://github.com/heketi/heketi) provides a RESTful management interface which can be used to manage the lifecycle of GlusterFS volumes.

The Helm chart deploys a GlusterFS storage cluster on the worker nodes in your IBM® Cloud Private cluster. It also deploys Heketi to manage the lifecycle of the storage cluster and creates volume to dynamically create volumes. The application workload can then use the Heketi service to create volumes for data persistence from the GlusterFS storage cluster. Along with the GlusterFS storage cluster, the chart also creates a storage class with the GlusterFS as the provisioner.

## Chart Details

The chart will do the following:

- Runs a precheck job to validate the storage class name, Heketi topology, device path, kernel modules that were loaded, and GlusterFS ports.
- Creates a configmap based on the precheck validation.
- Creates a secret to store the Heketi database.
- Deploys GlusterFS as a daemon set onto the Kubernetes nodes that you labeled as storage nodes.
- Creates the Heketi service and Heketi deployment to communicate with GlusterFS.
- Creates the storage class if it is set to true.

## Limitations
- The chart supports the installation of only a new storage cluster under kube-system namespace.
- The chart supports creation of only one GlusterFS Storage cluster in a IBM® Cloud Private cluster.  
- The chart accepts only three storage nodes as input from the UI. To deploy more storage nodes, you must deploy the chart by using the Helm CLI. Provide the parameters in the values.yaml file.

## Prerequisites

- You must use at least three nodes to configure GlusterFS Storage cluster.
- The storage device that is used for GlusterFS must have a capacity of at least 25 GB.
- The storage devices that you use for GlusterFS must be raw disks. They must not be formatted, partitioned, or used for file system storage needs.
- The selected nodes must be labelled as storage nodes. For example, if the label is "storagenode=glusterfs", run the following command:
  ```bash
  kubectl label nodes <node1_ipaddr node2_ipaddr node3_ipaddr...> storagenode=glusterfs --overwrite=true
  ```
- Ensure that the ports that are used by GlusterFS daemon (24007), GlusterFS management(24008) and Bricks port range  (49152:49251) are added to the firewall.
-  Install the GlusterFS client and configure the dm_thin_pool kernel module on the nodes in your cluster that might use a GlusterFS volume.
- Ensure that the GlusterFS client version is the same as GlusterFS server version that is installed.
- Pre-create a secret with a password for the Heketi user 'admin' and provide the secret name in the field heketi.authSecret.
    1. Encode the new password in base64 and update the admin_password section with the new base64 encoded password.
       ```bash
       echo -n "admin" | base64

       YWRtaW4=
       ```
    2. Use the ICP console or kubectl to create the secret:
       ```bash
       kind: Secret
       apiVersion: v1
       metadata:
         name: heketi-secret
         labels:
           glusterfs: "heketi-secret"
       type: kubernetes.io/glusterfs
       data:
         admin_password: YWRtaW4= 

  
       kubectl apply -f secrets.yaml -n kube-system
       ```
    > **Note**: The name of the key should be the same as mentioned here: `admin_password`.


## Resources Required

The GlusterFS and Heketi containers have the following resource requests and limits:

| Container                  | Memory Request        | Memory Limit          | CPU Request           | CPU Limit             |
| -----------------------    | ------------------    | ------------------    | ------------------    | ------------------    |
| GlusterFS                  | 128Mi                 | 256Mi                 | 100m                  | 200m                  |
| Heketi                     | 512Mi                 | 1Gi                   | 500m                  | 1000m                 |


## Installing GlusterFS cluster

## Installing the chart

To install `ibm-glusterfs` chart from the command line with release name `my-release`:

```bash
$ helm install --name my-release -f  values.yaml stable/ibm-glusterfs --tls
```

## Configuration

The following table lists the configurable parameters of the `ibm-glusterfs` chart and their default values.

| Parameter                                         | Description                                     | Default           |
|---------------------------------------------------|-------------------------------------------------|-------------------|
| arch.amd64                                        | Architecture preference for amd64 node          | 2 - No preference |
| arch.ppc64le                                      | Architecture preference for ppc64le node        | 2 - No preference |
| arch.s390x                                        | Architecture preference for s390x node          | 0 - Do not use    |
| preValidation.image.repository                    | Hyperkube image to use for this deployment      | ibmcom/hyperkube  |
| preValidation.image.tag                           | Hyperkube image tag to use for this deployment  | v1.10.0           |
| preValidation.image.pullPolicy                    | Hyperkube image pull policy                     | IfNotPresent      |
| gluster.image.repository                          | GlusterFS image to use for this deployment      | ibmcom/gluster    |
| gluster.image.tag                                 | GlusterFS image tag to use for this deployment  | 3.12.1            |
| gluster.image.pullPolicy                          | GlusterFS image pull policy                     | IfNotPresent      |
| gluster.installType                               | GlusterFS installation type.                    | Fresh             |
| gluster.resources.requests.cpu                    | Describes the minimum amount of CPU required    | Default is 100m. See Kubernetes - [CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
| gluster.resources.requests.memory                 | Describes the minimum amount of memory required | Default is 128Mi. See Kubernetes - [Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)                 |
| gluster.resources.limits.cpu                      | Describes the maximum amount of CPU allowed     |  Default is 200m  |
| gluster.resources.limits.memory                   | Describes the maximum amount of memory allowed  | Default is 256Mi  |
| heketi.image.repository                           | Heketi image to use for this deployment         | ibmcom/heketi     |
| heketi.image.tag                                  | Heketi image tag to use for this deployment     | 5                 |
| heketi.image.pullPolicy                           | Heketi image pull policy                        | IfNotPresent      |
| heketi.backupDbSecret                             | Heketi database to be backed up to a k8s secret | "heketi-db-backup"|
| heketi.authSecret                                 | Secret for password of the Heketi user 'admin'  |                   |
| heketi.resources.requests.cpu                     | Describes the minimum amount of CPU required    | Default is 500m   |
| heketi.resources.requests.memory                  | Describes the minimum amount of memory required | Default is 512Mi  |
| heketi.resources.limits.cpu                       | Describes the maximum amount of CPU allowed     | Default is 1000m  |
| heketi.resources.limits.memory                    | Describes the maximum amount of memory allowed  | Default is 1Gi    |
| heketiTopology.k8sNodeName                        | Name of the kubelet node that runs the Gluster pod|                 |
| heketiTopology.k8sNodeIp                          | Storage node's network address                  |                   |
| heketiTopology.devices                            | Raw device list                                 |                   |
| storageClass.create                               | GlusterFS storage class to be created           | false             |
| storageClass.name                                 | GlusterFS storage class name                    | glusterfs         |
| storageClass.isDefault                            | GlusterFS storage class is default              | false             |
| storageClass.volumeType                           | GlusterFS storage class volume type             | replicate:3       |
| storageClass.reclaimPolicy                        | GlusterFS storage class reclaim policy          | Delete            |
| storageClass.volumeBindingMode                    | GlusterFS storage class volume binding mode     | Immediate         |
| storageClass.volumeNamePrefix                     | GlusterFS storage class volume name prefix      | icp               |
| storageClass.additionalProvisionerParams          | storage class additional provisioner parameters |                   |
| nodeSelector.key                                  | Node Selector key for GlusterFS and Heketi pods | storagenode       |
| nodeSelector.value                                | Node Selector value for GlusterFS and Heketi pods | glusterfs       |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`

Alternatively, you can provide a YAML file with the parameter values while you install the chart.

For example,

```bash
$ helm install --name my-release -f values.yaml stable/ibm-glusterfs --tls
```

## Verifying the chart

If the chart is successfully installed, you will see a success message on the management console (GUI).

If you used the Helm CLI, you see the following message if the chart is successfully installed:

```bash
Installation of GlusterFS is successful.

1. Heketi Service is created

   kubectl --namespace default get service -l  glusterfs=heketi-service

2. Heketi Deployment is successful

   kubectl --namespace default get deployment -l  glusterfs=heketi-deployment

3. Storage class gluster can be used to create GlusterFS volumes.

   kubectl get storageclasses gluster
```

After the chart is successfully installed, it takes couple of minutes to start all the required pods. Verify that all the pods are running and the cluster is usable. Now, you can use the storage class to claim a volume.

- Verify that the desired and available pods are same as mentioned in the GlusterFS daemon set.
- Verify that the desired and available pods are same as mentioned in the Heketi deployment.
- Verify that Heketi topology has all the nodes that were configured.
    
All the above Pods are in same namespace where this chart is being deployed.

## Provisioning Persistent Volume

After you deploy the chart, you can use a PersistentVolumeClaim (PVC) to claim the GlusterFS volume that is configured on the storage nodes. You can use the GlusterFS storage class to provision GlusterFS storage.

```bash
$ kubectl get storageclass
NAME                     TYPE
gluster (default)        kubernetes.io/glusterfs
``` 

Use the following sample yaml file to create a persistent volume claim:

```bash
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-claim
spec:
  storageClassName: gluster
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

$ kubectl apply -f pvc_doc.yaml 
persistentvolumeclaim "pv-claim" created

$ kubectl get pvc
NAME       STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS        AGE
pv-claim   Bound     pvc-fc768253-6e2a-11e8-acec-005056a8a9c9   1Gi        RWO           gluster             13s
```

## Uninstalling the chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge  my-release --tls
```

**Note**: Deletion of helm release will not delete the secret `heketi.backupDbSecret`. 
