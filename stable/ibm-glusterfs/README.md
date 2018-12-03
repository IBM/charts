# GlusterFS Storage Cluster

## Introduction

[GlusterFS](https://www.gluster.org/) is a Scale Out Network Attached Storage file system.

[Heketi](https://github.com/heketi/heketi) provides a RESTful management interface that can be used to manage the lifecycle of GlusterFS volumes.

The `ibm-glusterfs` Helm chart deploys a GlusterFS storage cluster on the storage nodes in your IBM® Cloud Private cluster. It also deploys Heketi to manage the lifecycle of the storage cluster and dynamically create volumes. The application workload can then use the Heketi service to create volumes for data persistence from the GlusterFS storage cluster. Along with the GlusterFS storage cluster, the chart also creates a storage class with GlusterFS as the provisioner.

## Chart Details

The Helm chart completes the following tasks:

- Runs a precheck job to validate the storage class name, Heketi authentication secret name, Heketi backup database secret name, storage node name, storage node IP address, Heketi topology, device path, kernel modules that were loaded, and GlusterFS ports.
- Creates a configmap based on the precheck validation.
- Creates a secret to store the Heketi database.
- Deploys GlusterFS as a daemonset onto the Kubernetes nodes that you labeled as storage nodes.
- Creates the Heketi service and Heketi deployment to communicate with GlusterFS.
- Creates the storage class if it is set to true.

## Limitations
- The chart supports the installation of only a new storage cluster under kube-system namespace.
- The chart supports creation of only one GlusterFS storage cluster in an IBM® Cloud Private cluster.

## Prerequisites

- An IBM® Cloud Private Version 3.1.0 or later must be installed.
- You must use at least three storage nodes to configure GlusterFS storage cluster. For more information about creating storage nodes, see [Deployment Scenarios](#deployment-scenarios).
- The storage device that is used for GlusterFS must have a capacity of at least 25 GB.
- The storage devices that you use for GlusterFS must be raw disks. They must not be formatted, partitioned, or used for file system storage needs. You must use the symbolic link (symlink) to identify the GlusterFS storage device. For more information about creating symlinks, see [Storage Devices](#storage-devices).
- You must install the `dm_thin_pool` kernel module on all the storage nodes. For more information, see [Configure dm_thin_pool](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_cluster/prepare_nodes.html).
- You must install the GlusterFS client on the nodes in your cluster that might use a GlusterFS volume. For more information, see [Install GlusterFS client](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_cluster/prepare_nodes.html)
- The GlusterFS client version must be the same as the version of the GlusterFS server that is installed.
- You must pre-create a secret with a password for the Heketi user 'admin' and provide the secret name in the `heketi.authSecret` parameter. Follow these steps to create the secret:
  1. Encode the new password in `base64` and update the `admin_password` section with the new base64-encoded password.

     ```bash
     echo -n "admin" | base64

     YWRtaW4=
     ```
  2. Use the management console or kubectl to create the secret:

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

     **Note**: The name of the key must be the same as `admin_password`.

## PodSecurityPolicy Requirements

## Deployment Scenarios

GlusterFS storage cluster can be deployed on dedicated storage host group nodes or on worker nodes.

### Dedicated GlusterFS storage nodes

Define a custom host group with at least three nodes. For more information about defining a host group, see [Defining custom host groups](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/hosts.html#hostgroup). This custom host group automatically labels the nodes and taints them to make the nodes dedicated for GlusterFS Storage. If you enabled firewall in your cluster, you need to open all the ports that are used by GlusterFS daemon and bricks.

### Worker nodes as GlusterFS storage nodes

Ensure that you use at least three worker nodes to configure GlusterFS. You have two options to install GlusterFS on worker nodes.

  - You can use existing IBM Cloud Private worker nodes to install GlusterFS. You must manually label these nodes.

(OR)

  - You can use dedicated nodes to configure GlusterFS and add these nodes as worker nodes during custom host group creation. To skip the node tainting, you must set the `no_taint_group: ["<hostgroup-name>"]` parameter in the `/<installation_directory>/cluster/config.yaml` file.

## Configure GlusterFS storage nodes

- Configure GlusterFS on dedicated nodes 

  1. Configure a custom host group with the dedicated GlusterFS storage nodes. For more information about how to add a host group, see [Adding a host group](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/installing/add_node.html#host_group).

     Following is an example configuration of a host group with dedicated GlusterFS storage nodes. You add this configuration in the /<installation_directory>/cluster/hosts file.

       **Note:** The worker nodes and the GlusterFS storage nodes are not the same.

       ```bash
       [worker]
       2.2.2.2
       ...
       2.2.2.9
       .
       .
       [hostgroup-glusterfs]
       6.6.6.6
       ...
       6.6.6.9
       ```

  2. If firewall is enabled, add the list of required ports to the /<installation_directory>/cluster/config.yaml file. Locate the section firewall_enabled: true. Add the following ports for the custom host group that you created with dedicated GlusterFS storage nodes.

     Following is an example configuration of the custom host group hostgroup-glusterfs:

       ```bash
       firewall_open_ports:
         hostgroup-glusterfs:
           - 24007/tcp
           - 24008/tcp
           - 2222/tcp
           - 49152-49251/tcp
       ```

- Configure GlusterFS on nodes that are also used as worker nodes

  1. Complete the steps mentioned in the section "Configure GlusterFS on dedicated nodes".

  2. Add `no_taint_group: ["<hostgroup-name>"]` parameter in the `/<installation_directory>/cluster/config.yaml` file. 

     Following is an example configuration of adding the `no_taint_group` parameter. You add this configuration in the /<installation_directory>/cluster/config.yaml file.

       ```bash
       no_taint_group: ["hostgroup-glusterfs"]
       ```

- Configure GlusterFS on existing worker nodes
    
  1. You must manually label these nodes. For example, following is the command to add `storagenode=glusterfs` as the label:

      ```bash
     kubectl label nodes <node1_ipaddr node2_ipaddr node3_ipaddr...> storagenode=glusterfs --overwrite=true
     ```

     **Note:**
       - You must use the same label key and value pair in `nodeSelector.key` and `nodeSelector.value` parameters. 
       - Sometimes, these manually labeled nodes are not persisted.
 
  2. If firewall is enabled, ensure that the ports that are used by GlusterFS daemon (24007), GlusterFS management (24008), SSHD (2222), and bricks (49152:49251) are added to the firewall.
  
     **Note:** You must manually add firewall rules for these ports.


## Storage Devices

You must use the symlink to identify the GlusterFS storage device. Do not use device names, such as `/dev/sdb`, because the name might change between system restarts.

  **Note**: The special characters that Heketi allows to be used in the device name are `^/[a-zA-Z0-9_.:/-]+$`. If your device name or system-generated symlink has special characters that are not allowed by Heketi, then you must manually create the symlink.

### Use system generated symlinks

To get the symlink that the system assigns to a device, complete these steps:

  1. Identify the storage devices to use. You can list the available storage devices by entering this command:

     ```bash
     $ ls -altr /dev/disk/*
     ```

  2. Identify devices that have at least 25 GB of storage capacity.

  3. Erase all file system, raid, and partition-table signatures by using the `wipefs` command. For example, to erase the signatures on device `/dev/sdb`, run the following command:

     ```bash
     $ sudo wipefs --all --force /dev/sdb
     ```

  4. Get the symlink of the device by entering this command:

     ```bash
     $ ls -altr /dev/disk/*
     ```

  5. Make a note of the symlink and its link path. For each device that you are using for GlusterFS configuration, you need to add the `<link path>/<symlink>`.

### Use manually created symlinks

In some environments, such as IBM Cloud VSI or SUSE Linux Enterprise Server (SLES), no symlinks are automatically generated for the devices. You must manually create symlinks by writing custom udev (userspace /dev) rules. When you create the symlink, use attributes that are unique to the device.

Following example includes steps to manually generate symlinks. The steps might vary with operating systems and environments.

  1. Get information about the device's attributes.

     ```bash
     $ udevadm info --root --name=/dev/vdb
     ```

     The output resembles the following code:
     ```bash
     P: /devices/pci0000:00/0000:00:10.0/virtio4/block/vdb
     N: vdb
     E: DEVNAME=/dev/vdb
     E: DEVPATH=/devices/pci0000:00/0000:00:10.0/virtio4/block/vdb
     E: DEVTYPE=disk
     E: MAJOR=253
     E: MINOR=16
     E: SUBSYSTEM=block
     E: TAGS=:systemd:
     E: USEC_INITIALIZED=6705725
     E: elevator=noop
     ```
     Use the DEVTYPE, SUBSYSTEM, and DEVPATH attributes to create the symlink of the device.

  2. Create a custom udev rules file.

     ```bash
     $ vi /lib/udev/rules.d/10-custom-icp.rules
     ```

     Add these lines of code to the file. Replace the attribute values with your device attribute values.

     ```bash
     ENV{DEVTYPE}=="disk", ENV{SUBSYSTEM}=="block", ENV{DEVPATH}=="/devices/pci0000:00/0000:00:10.0/virtio4/block/vdb" SYMLINK+="disk/gluster-disk-1"
     ```

  3. Reload the udev rules to create the symlinks.

     ```bash
     $ udevadm control --reload-rules
     $ udevadm trigger --type=devices --action=change
     ```

  4. Verify that the symlinks are created.

     ```bash
     $ ls -ltr /dev/disk/gluster-*
     ```

     The output resembles the following code:

     ```bash
     lrwxrwxrwx 1 root root 3 Jul  4 23:12 /dev/disk/gluster-disk-1 -> ../../vdb
     ```

## Resources Required

The GlusterFS and Heketi containers have the following resource requests and limits:

| Container                  | Memory Request        | Memory Limit          | CPU Request           | CPU Limit             |
| -----------------------    | ------------------    | ------------------    | ------------------    | ------------------    |
| GlusterFS                  | 512Mi                 | 1Gi                   | 500m                  | 1000m                 |
| Heketi                     | 512Mi                 | 1Gi                   | 500m                  | 1000m                 |


## Installing GlusterFS cluster

### Installing the chart

To install `ibm-glusterfs` chart from the command line with release name `my-release`:

```bash
$ helm install --name my-release --namespace kube-system -f  values.yaml stable/ibm-glusterfs --tls
```

### Configuration

The following table lists the configurable parameters of the `ibm-glusterfs` chart and their default values.

| Parameter                                 | Description                                             | Default           |
|-------------------------------------------|---------------------------------------------------------|-------------------|
| arch.amd64                                | Architecture preference for amd64 node                  | 2 - No preference |
| arch.ppc64le                              | Architecture preference for ppc64le node                | 2 - No preference |
| arch.s390x                                | Architecture preference for s390x node                  | 0 - Do not use    |
| preValidation.image.repository            | Pre-validation image to use for this deployment         | ibmcom/icp-storage-util |
| preValidation.image.tag                   | Pre-validation image tag to use for this deployment     | 3.1.0             |
| preValidation.image.pullPolicy            | Pre-validation image pull policy                        | IfNotPresent      |
| gluster.image.repository                  | GlusterFS image to use for this deployment              | ibmcom/gluster    |
| gluster.image.tag                         | GlusterFS image tag to use for this deployment          | v4.0.2            |
| gluster.image.pullPolicy                  | GlusterFS image pull policy                             | IfNotPresent      |
| gluster.installType                       | GlusterFS installation type.                            | Fresh             |
| gluster.resources.requests.cpu            | Describes the minimum amount of CPU required            | Default is 500m. See Kubernetes - [CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
| gluster.resources.requests.memory         | Describes the minimum amount of memory required         | Default is 512Mi. See Kubernetes - [Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)                 |
| gluster.resources.limits.cpu              | Describes the maximum amount of CPU allowed             | Default is 1000m  |
| gluster.resources.limits.memory           | Describes the maximum amount of memory allowed          | Default is 1Gi    |
| heketi.image.repository                   | Heketi image to use for this deployment                 | ibmcom/heketi     |
| heketi.image.tag                          | Heketi image tag to use for this deployment             | v8.0.0            |
| heketi.image.pullPolicy                   | Heketi image pull policy                                | IfNotPresent      |
| heketi.backupDbSecret                     | Name of the k8s secret where Heketi database is backed up to | heketi-db-backup  |
| heketi.authSecret                         | Secret for password of the Heketi `admin` user          |                   |
| heketi.maxInFlightOperations              | Maximum number of requests processed by heketi at a time| 20                |
| heketi.resources.requests.cpu             | Describes the minimum amount of CPU required            | Default is 500m   |
| heketi.resources.requests.memory          | Describes the minimum amount of memory required         | Default is 512Mi  |
| heketi.resources.limits.cpu               | Describes the maximum amount of CPU allowed             | Default is 1000m  |
| heketi.resources.limits.memory            | Describes the maximum amount of memory allowed          | Default is 1Gi    |
| heketiTopology.k8sNodeName                | Name of the kubelet node that runs the GlusterFS pod    |                   |
| heketiTopology.k8sNodeIp                  | Storage node's network address                          |                   |
| heketiTopology.devices                    | Raw device list                                         |                   |
| storageClass.create                       | GlusterFS storage class to be created                   | true              |
| storageClass.name                         | GlusterFS storage class name                            | glusterfs         |
| storageClass.isDefault                    | GlusterFS storage class is default                      | false             |
| storageClass.volumeType                   | GlusterFS storage class volume type                     | replicate:3       |
| storageClass.reclaimPolicy                | GlusterFS storage class reclaim policy                  | Delete            |
| storageClass.volumeBindingMode            | GlusterFS storage class volume binding mode             | Immediate         |
| storageClass.volumeNamePrefix             | GlusterFS storage class volume name prefix              | icp               |
| storageClass.additionalProvisionerParams  | storage class additional provisioner parameters         |                   |
| storageClass.allowVolumeExpansion         | GlusterFS storage class volume expansion to be allowed  | true              |
| prometheus.enabled                        | Prometheus configurations to be enabled                 | false             |
| prometheus.path                           | Heketi path to pull the metrics                         | /metrics          |
| prometheus.port                           | Port that Heketi service is exposed                     | 8080              |
| nodeSelector.key                          | Node label key for GlusterFS and Heketi pods            | hostgroup         |
| nodeSelector.value                        | Node label value for GlusterFS and Heketi pods          | glusterfs         |
| podPriorityClass                          | Priority class preference for storage pods              | system-cluster-critical       |

Specify each parameter by using the `--set key=value[,key=value]` argument to `helm install`

Or, you can also provide a YAML file with the parameter values while you install the chart.

Following is an example command:

```bash
$ helm install --name my-release --namespace kube-system -f values.yaml stable/ibm-glusterfs --tls
```

### Verifying the chart

- If the chart is successfully installed, you see a message on the management console (GUI). If you used the Helm CLI, you see the following message:

  ```bash
  Installation of GlusterFS is successful.

  1. Heketi Service is created

     kubectl --namespace kube-system get service -l  glusterfs=heketi-service

  2. Heketi Deployment is successful

     kubectl --namespace kube-system get deployment -l  glusterfs=heketi-deployment

  3. Storage class glusterfs can be used to create GlusterFS volumes.

     kubectl get storageclasses glusterfs
  ```

  After the chart is successfully installed, it takes couple of minutes to start all the required pods. Verify that all the pods are running and the cluster is usable.

  - Verify that the required and available pods are same as mentioned in the GlusterFS daemon set.
  - Verify that the required and available pods are same as mentioned in the Heketi deployment.
  - Verify that Heketi topology has all the nodes that were configured.

All the pods are in same namespace where this chart is being deployed.

When the GlusterFS cluster is ready, you can use a storage class to claim a volume. See [Provisioning a persistent volume](#pvc).

- If the chart fails to install, you see the following message:

  ```bash
  Error: Job failed: BackoffLimitExceeded
  ```

  Verify the configmap for details.
  ```bash
  kubectl --namespace kube-system get configmap -l glusterfs-precheck=precheck-results-cm
  ```

## Provisioning a persistent volume

After you deploy the chart, you can use a PersistentVolumeClaim (PVC) to claim the GlusterFS volume that is configured on the storage nodes. You can use the GlusterFS storage class to provision GlusterFS storage.

```bash
$ kubectl get storageclass
NAME                     TYPE
glusterfs (default)        kubernetes.io/glusterfs
```

Use the following sample YAML file to create a persistent volume claim:

```bash
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-claim
spec:
  storageClassName: glusterfs
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

$ kubectl apply -f pvc_doc.yaml
```

Verify that the PVC is created and bound to the volume:

```bash
$ kubectl get pvc
NAME       STATUS    VOLUME                                     CAPACITY   ACCESSMODES   STORAGECLASS        AGE
pv-claim   Bound     pvc-fc768253-6e2a-11e8-acec-005056a8a9c9   1Gi        RWO           glusterfs             13s
```

## Uninstalling the chart

To uninstall or delete the `my-release` deployment, run the following command:

```bash
$ helm delete --purge  my-release --tls
```

**Note**: The Helm delete command deletes all the objects except `heketi.backupDbSecret`. You must manually delete the `heketi.backupDbSecret` object if you do not need it.


## Reinstalling GlusterFS
If your previous GlusterFS installation failed or you want to reinstall GlusterFS, you must first prepare your nodes for the reinstallation. Complete these steps:

### Delete the Helm chart
  ```bash
  helm delete --purge  <release_name> --tls
  ```

### Remove the configuration directories

Remove the Heketi and GlusterFS daemon configuration directories from each storage node that is used for reinstallation. Run these commands:

  ```bash
  rm -rf /var/lib/heketi
  rm -rf /var/lib/glusterd
  rm -rf /var/log/glusterfs
  ```

### Prepare the disks to be used for GlusterFS installation

You can reuse the disks or add new disks for a reinstallation of GlusterFS.

If you are resuing the disks, complete these steps:

  **Note:** The disk cleanup process might not work in some environments. If that happens, you might need to use fresh disks.

  - Back up the data on the disks that were used in an earlier installation. The steps that follow might cause a loss of data on the old disks.

  - Run these commands to remove the GlusterFS volumes:

    1. Remove the logical volumes and volume group.
       ```bash
       lvscan | grep 'vg_' | awk '{print $2}' | xargs -n 1 lvremove -y
       vgscan | grep 'vg_' | awk '{print $4}' | xargs -n 1 vgremove
       ```

    2. Scan for the physical volumes.
       ```bash
       pvscan
       ```

    3. Remove all physical volumes.
       ```bash
       pvremove <pv_name>
       ```

    4. Erase all file system, raid, and partition-table signatures.
       ```bash
       wipefs --all --force <device_name>
       ```
Next, complete the tasks in [Installing the chart](#installing-the-chart)
