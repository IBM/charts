# WAS VM Quickstarter
[IBM WebSphere Application Server for IBM Cloud Private VM Quickstarter](https://www.ibm.com/support/knowledgecenter/SSTF9X/welcome.html) provides the WebSphere product experience in a cloud environment by enabling self-service creation of preconfigured WebSphere environments running in virtual machines. Throughout this document, the service is also referred to as _WAS VM Quickstarter_.

## Introduction
The WAS VM Quickstarter brings the WebSphere experience to the cloud so that you can leverage existing scripts and skills to provide a supported, cloud-managed environment for hosting WebSphere applications. WebSphere Application Server provides flexible, secure Java runtimes that easily serve up everything from single, lightweight applications and microservices to large enterprise cloud deployments.

The service management console installed by this Helm chart provides the self-service portal that is used to create and manage VM-based WAS assets. Behind the scenes, the service console applications use IBM Cloud Automation Manager to provide the orchestrations that stand up these deployments in a VMWare datacenter that you define in the Helm chart.

## Setting up the WAS VM Quickstarter
See [Installing WAS VM Quickstarter](https://www.ibm.com/support/knowledgecenter/SSTF9X/install-service.html) for a complete set of installation instructions for the service. This Helm chart is a part of the overall installation instructions.

## Chart Details

The Helm chart deploys the following components:
* `wasaas-console` Kubernetes pod which hosts the self-service console application.
* `wasaas-broker` Kubernetes pod which hosts the self-service REST APIs.
* `wasaas-cloudsm-frontend` Kubernetes pod which hosts the front end of the service management framework.
* `wasaas-cloudsm-backend` Kubernetes pod which hosts the back end of the service management framework.
* `wasaas-couchdb` Kubernetes pod which hosts the CouchDB NoSQL datastore that stores the service management data for the service.
* `wasaas-devops` Kubernetes pod which hosts devops scripts, such as must-gather and installation verification test (IVT) scripts.
* Ingresses for the `wasaas-console` and `wasaas-broker` pods.


## Prerequisites
The following prerequisites apply only to deploying the Helm chart. For a detailed list of system installation prerequisites, see [WAS VM Quickstarter Prerequisites](https://www.ibm.com/support/knowledgecenter/SSTF9X/install-prerequisites.html).

You must be a cluster administrator to install the Helm chart. The `wasaas-devops` container requires additional permissions to access a secret in the `services` namespace and to discover the ip address of the proxy node.

### Persistent Volumes

 The WAS VM Quickstarter service requires the following persistent volumes:
* CouchDB volume for service management data (10 GB or larger)

  The WAS VM Quickstarter service requires a persistent volume to host a CouchDB database to store service data.  The volume relates the data for a particular service instance to the specific resources that are assigned to the service instance. The volume must be configured with a storage capacity of at least 10 GB.
* Optional: Migration volume (10 GB or larger)

  If the optional migration feature is enabled, a persistent volume is required to hold migration artifacts until the target WebSphere server or cell is provisioned. The migration persistent volume must reference an NFS server and have a storage capacity of at least 10 GB.

You can either define your persistent volumes in a YAML file or in the IBM Cloud Private user interface.

#### Use a YAML file

Create a `pv.yaml` file that defines the CouchDB volume. Use the values in the following example, replacing the items in <brackets\>. This example uses an NFS server, but you can use any shared server supported by IBM Cloud Private. The NFS or other shared server must be set up before you create the persistent volume.

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
 name: data-<release-name>-ibm-was-vm-quickstarter-couchdb-0
 labels:
   component: "couchdb"
   release: "<release-name>"
spec:
 capacity:
   storage: 10Gi
 accessModes:
 - ReadWriteOnce
 persistentVolumeReclaimPolicy: Retain
 nfs:
   path: /nfs/wasaas/<environment-name>/couchdb-0
   server: <nfs-server-address>
```

Run the following command to create the volume:

  ```bash
kubectl create -f pv.yaml
  ```

Setting up the migration volume requires additional steps. For more information, see [Migrating applications to WAS VM Quickstarter](https://www.ibm.com/support/knowledgecenter/SSTF9X/migrate-apps.html).

#### Use the UI

For information about creating persistent volumes by using the user interface, see [Creating a PersistentVolume](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_cluster/create_volume.html) in the IBM Cloud Private documentation. Use the corresponding values from the YAML example

### Secrets

The WAS VM Quickstarter service requires a secret to be created that contains CAM administrator user name and password.

You can either define the secret using the `kubectl` command or in the IBM Cloud Private user interface.

For example, when using `kubectl`, run the following command to create the secret:

  ```bash
kubectl create secret generic cam-credentials --from-literal='username=myadmin' --from-literal='password=mypassword'
  ```

You will need to pass the secret name as the `cam.secret` parameter during Helm chart installation.

## Resources Required

For a detailed list of required system resources such as CPU, memory, and disk space, see [WAS VM Quickstarter Prerequisites](https://www.ibm.com/support/knowledgecenter/SSTF9X/install-vm-template-reqs.html).

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --name my-release stable/ibm-was-vm-quickstarter-dev
```

The command deploys `ibm-was-vm-quickstarter-dev` on the Kubernetes cluster in the `default` namespace. The [configuration](#configuration) section lists the parameters that can be configured during installation.

**Tip**: List all releases using `helm list --tls`.

### Verifying the Chart

Verify that your Kubernetes pods were deployed successfully.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --tls --purge my-release
```

The command removes all of the Kubernetes components associated with the chart and deletes the release.


## Configuration

The following tables lists the configurable parameters of the `ibm-was-vm-quickstarter-dev` chart and their default values.

| Parameter                  | Description                                     | Default                               |
| -----------------------    | ---------------------------------------------   | ------------------------------------- |
| `environment`                   | The environment name for this WAS VM Quickstarter instance | `CAM` |  
| `cam.ip`                        | IP address of the Cloud Automation Manager that the WAS VM Quickstarter will target for WAS deployments | |
| `cam.port`                      | The port address of CAM |`30000` |
| `cam.secret`                    | A secret name that contains CAM administrator user name and password |  |
| `cam.cloudConnectionName`       | The CAM connection name | `vm-quickstarter-connection` |
| `cam.contentRuntimeName`        | The CAM content runtime name that will host the WAS VM Quickstarter orchestration artifacts | `vm-quickstarter-runtime` |
| `vsphere.osAdminUser`           | The OS image administrator user name | |
| `vsphere.osAdminPassword`       | The OS image administrator user password | |
| `vsphere.osImage`               | The OS image deployed in the vSphere datacenter, which the WAS VM Quickstarter uses to host the WAS deployments | |
| `vsphere.rootDiskSize`          | The disk size of the OS image. 25 GB is recommended | |
| `vsphere.rootDiskDatastore`     | The name of the data store that hosts the image | |
| `vsphere.resourcePool`          | The name of the vSphere resource pool to target for WAS deployments | |
| `vsphere.folder`                | The name of the vSphere folder to use as target for WAS deployments | |
| `vsphere.domain`                | The name of the vSphere domain to use as target for WAS deployments | |
| `vsphere.datacenter`            | The name of the vSphere datacenter to use as target for WAS deployments. | |
| `vsphere.networkInterfaceLabel` | The name of the vSphere network interface label to use as target for WAS deployments | |
| `vsphere.dnsServers`            | The IP addresses of the DNS servers to configure for WAS deployments | `8.8.8.8` |
| `vsphere.dnsSuffxies`           | The DNS domain suffix to use for host name and URLs for WAS deployments | |
| `vsphere.ipv4Gateway`           | The IP address of the IPv4 gateway to use for WAS deployments | |
| `vsphere.ipv4PrefixLength`      | The length of your IPv4 prefix | |
| `vsphere.ipPool`                | comma separated list of IP addresses to be used as host IPs for WAS virtual machine deployments. See [Prerequisites](https://www.ibm.com/support/knowledgecenter/SSTF9X/install-prerequisites.html) for details | |
| `console.image.repository`      | WAS VM Quickstarter Console Docker image repository | `ibmcom/wasaas-console`  |
| `console.image.tag`             | WAS VM Quickstarter console Docker image tag  |  `2.0` |
| `console.ingress.path`          | WAS VM Quickstarter console ingress path  | `/wasaas-console/`  |
| `broker.image.repository`       | WAS VM Quickstarter broker Docker image repository | `ibmcom/wasaas-wasdevaas`  |
| `broker.image.tag`              | WAS VM Quickstarter broker Docker image tag  |  `2.0` |
| `broker.ingress.path`           | WAS VM Quickstarter broker ingress path  | `/wasaas-broker/`  |
| `cloudsm.image.repository`      | WAS VM Quickstarter service management Docker image repository | `ibmcom/wasaas-cloudsm`  |
| `cloudsm.image.tag`             | WAS VM Quickstarter service management Docker image tag  |  `2.0` |
| `cloudsm.capacity`              | Resource capacity in [service blocks](#resource-management) | `10` |
| `devops.image.repository`       | WAS VM Quickstarter devOps Docker image repository | `ibmcom/wasaas-devops`  |
| `devops.image.tag`              | WAS VM Quickstarter devOps Docker image tag  |  `2.0` |
| `couchdb.image.repository`      | WAS VM Quickstarter CouchDB Docker image repository | `couchdb`  |
| `couchdb.image.tag`             | WAS VM Quickstarter CouchDB Docker image tag  |  `2.2.1` |
| `couchdb.persistentVolume.useDynamicProvisioning` | Indicates whether to use dynamic provisioning  |  `false` |
| `couchdb.persistentVolume.size`                   | Persistent volume size  | `10Gi`  |
| `couchdb.persistentVolume.storageClass`           | Persistent volume storage class  | |
| `iam.endpoint`                  | IAM endpoint address. For example: `https://<master_ip>:8443` | |
| `migration.enabled`             | Enabled is true if the migration feature is enabled | `false` |
| `migration.mountPoint`          | The directory path of the migration store on the NFS server  | |
| `migration.serverAddress`       | The IP address or host name of the NFS server |  |
| `image.pullPolicy`              | The pull policy for the WAS VM Quickstarter Docker images  | `Always` |


 You should create a YAML file that specifies the values for the parameters that can be used when installing the chart.  Alternatively, specify each parameter using the `--set key=value[,key=value]` argument when you run the `helm install` command.



## Limitations
- You can deploy the Helm chart multiple times by using different Helm releases.  If you target the same Cloud Automation Manager and vSphere environments, care must be given to set the capacity and IP addresses to not collide with other instances of the WAS VM Quickstarter service.

## Documentation

#### For administrators

See the following pages within this documentation:
* [WAS VM Quickstarter Prerequisites](https://www.ibm.com/support/knowledgecenter/SSTF9X/install-prerequisites.html)
* [Setting Up the Content Runtime](https://www.ibm.com/support/knowledgecenter/SSTF9X/content-runtime-setup.html)
* [Migrating Applications to WAS VM Quickstarter](https://www.ibm.com/support/knowledgecenter/SSTF9X/migrate-config.html)
* [Administering WAS VM Quickstarter](https://www.ibm.com/support/knowledgecenter/SSTF9X/admin-service.html)

#### For WebSphere Application Server users

* [Setting up WebSphere Application Server on IBM Cloud Private with the WAS VM Quickstarter](https://www.ibm.com/support/knowledgecenter/SSTF9X/was-setup.html)
* [WebSphere Application Server V9.0 documentation](https://www.ibm.com/support/knowledgecenter/SSAW57_9.0.0/as_ditamaps/was900_welcome_ndmp.html)
* [WebSphere Application Server Liberty documentation](https://www.ibm.com/support/knowledgecenter/SSAW57_liberty/as_ditamaps/was900_welcome_liberty_ndmp.html)
