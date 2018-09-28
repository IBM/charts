# WAS VM Quickstarter

THIS CHART IS NOW DEPRECATED. On September 28th, 2018 this version of the Helm chart for IBM WAS VM Quickstarter Community Edition will no longer be supported. The chart is replaced by the ibm-was-vm-quickstarter-dev chart. The production version of the chart, ibm-was-vm-quickstarter-prod, is available on IBM Passport Advantage. This chart will be removed on October 12, 2018.

IBM WebSphere Application Server for IBM Cloud Private VM Quickstarter Community Edition provides the WebSphere product experience in a cloud environment by enabling self-service creation of preconfigured WebSphere environments running in virtual machines. Throughout this documentation, the service is also referred to as _WAS VM Quickstarter_.

## Introduction
The WAS VM Quickstarter brings the WebSphere experience to the cloud so that you can leverage existing scripts and skills to provide a supported, cloud-managed environment for hosting WebSphere applications. WebSphere Application Server provides flexible, secure Java runtimes that easily serve up everything from single, lightweight applications and microservices to large enterprise cloud deployments.

The service management console installed by this Helm chart provides the self-service portal that is used to create and manage VM-based WAS assets. Behind the scenes, the service console applications use IBM Cloud Automation Manager to provide the orchestrations that stand up these deployments in a VMWare datacenter that you define in the Helm chart.

For both the WAS VM Quickstarter administrators, who set up and maintain the service, and the service users that provision WebSphere instances, the WAS VM Quickstarter provides a number of key benefits.

#### For WAS VM Quickstarter administrators

As a WAS VM Quickstarter administrator, you install the WAS VM Quickstarter service in IBM Cloud Private. Within the service, you can manage the virtual machine resources, manage the available WebSphere Application Server fix packs and interim fixes, and other tasks described in this documentation.
* Use the provided administration scripts to test and administer the WAS VM Quickstarter service from the command line.
* Manage pools of virtual machine resources to optimize service instance creation time.

#### For WebSphere Application Server users

WebSphere Application Server developers or administrators use the WAS VM Quickstarter service management console to quickly provision WebSphere instances. Within the environment, They are responsible for adjusting the configuration of the WebSphere environment and deploying their applications. Setting up the WebSphere environment is outside the scope of this documentation. For details, see [Setting up WebSphere Application Server on IBM Cloud Private with the WAS VM Quickstarter](https://ibm.biz/WASQuickstarterRecipe).

From the WAS VM Quickstarter service management console, you can:
* Size VMs using simple T-shirt-sized blocks of resources.
* Choose the number of application server nodes for ND deployments.
* Select the current or previous (n or n-1) WAS fix pack to create the new service.
* Target the on-premises migration wizard to move configuration and applications to the WAS VM Quickstarter environment.

### Resource Management
WAS VM Quickstarter manages WAS deployments with a simplified resource model, using service blocks to compute total and remaining capacity of the target vSphere deployment.  A service block is defined to be 1 vCPU, 2 GB of RAM, and 25 GB of disk space. For example, 2 service blocks would then be 2 vCPUs, 4 GB of RAM, and 50 GB of disk space.   

When you create a WAS service instance, you can select the size of the virtual machine that is provisioned. VM sizes are simplified into T-shirt-sized service blocks, where the next-largest block is twice the size.

| T-shirt Size | Blocks |
| --- | --- |
| Small | 1 |
| Medium | 2 |
| Large | 4 |
| XLarge | 8 |
| XXLarge | 16 |

All WebSphere virtual machines are pooled at the small size. When a user provisions a larger VM, the environment is scaled up automatically.

## Setting up the WAS VM Quickstarter

1. Review the system prerequisites and required software as described in [WAS VM Quickstarter Prerequisites](http://ibm.biz/WASQuickstarterPrerequisites). You'll install the following products:
   * VMware vSphere and ESXi
   * IBM Cloud Private
   * IBM Cloud Automation Manager
1. Deploy the WAS VM Quickstarter Helm chart, as described on this page in the sections under _Chart Details_.
   * To migrate existing applications to WAS VM Quickstarter, additional configuration is needed. For more information, see [Migrating applications to WAS VM Quickstarter](http://ibm.biz/WASQuickstarterMigration).
1. [Set up the Cloud Automation Manager Content Runtime VM](http://ibm.biz/WASQuickstarterContentRuntime).
1. [Register the WAS VM Quickstarter console](http://ibm.biz/WASQuickstarterOperations#registering-the-was-vm-quickstarter-console-with-iam) with the Identity and Access Management (IAM) component.
1. [Initialize resource pools](http://ibm.biz/WASQuickstarterOperations#initializing-resource-pools).
1. Test your setup by running the provided [installation verification test script](http://ibm.biz/WASQuickstarterOperations#ivtsh). If the script runs successfully, your WAS VM Quickstarter setup is complete!

After you set up the WAS VM Quickstarter service, your WebSphere developers can begin creating WAS service instances from the service management console. To find the URL to the console, in the IBM Cloud Private user interface, go to **Workloads > Helm Releases** and select the deployment. Under the **Notes** section, copy the commands under _Console address_ and paste them into a command window.

The commands will output the URL, which is in the following format. Share this URL with your WebSphere developers so that they can create and manage WAS service instances.
```
WAS VM Quickstarter console: https://<hostname>/<your-service>-wasaas-console
```

### Getting help

If you have questions about WAS VM Quickstarter or run into any problems, reach out to us on Slack! You can find us in the [IBM Cloud Technology](https://slack-invite-ibm-cloud-tech.mybluemix.net/) team under the `#was-vm-quickstarter` channel.

***

## Chart Details

![Sample WAS VM Quickstarter Deployment](http://ibm.biz/WASQuickstarterDiagram)

The Helm chart deploys the following components:
* `wasaas-console` Kubernetes pod, which hosts the self-service console application.
* `wasaas-broker` Kubernetes pod, which hosts the self-service REST APIs.
* `wasaas-cloudsm-frontend` Kubernetes pod, which hosts the front end of the service management framework.
* `wasaas-cloudsm-backend` Kubernetes pod, which hosts the back end of the service management framework.
* `wasaas-couchdb` Kubernetes pod, which hosts the CouchDB NoSQL datastore that stores the service management data for the service.
* `wasaas-devops` Kubernetes pod, which hosts devops scripts, such as must-gather and installation verification test (IVT) scripts.
* Ingresses for the `wasaas-console` and `wasaas-broker` pods.


## Prerequisites
The following prerequisites apply only to deploying the Helm chart. For a detailed list of system installation prerequisites, see [WAS VM Quickstarter Prerequisites](http://ibm.biz/WASQuickstarterPrerequisites).

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

Setting up the migration volume requires additional steps. For more information, see [Migrating applications to WAS VM Quickstarter](http://ibm.biz/WASQuickstarterMigration).

#### Use the UI

For information about creating persistent volumes by using the user interface, see [Creating a PersistentVolume](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/manage_cluster/create_volume.html) in the IBM Cloud Private documentation. Use the corresponding values from the YAML example

## Resources Required

For a detailed list of required system resources such as CPU, memory, and disk space, see [WAS VM Quickstarter Prerequisites](http://ibm.biz/WASQuickstarterPrerequisites#operational-prerequisites).

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --name my-release stable/ibm-was-vm-quickstarter
```

**Note**: The WAS VM Quickstarter must be installed in the `default` namespace.

The command deploys `ibm-was-vm-quickstarter` on the Kubernetes cluster in the `default` namespace. The [configuration](#configuration) section lists the parameters that can be configured during installation.

**Tip**: List all releases using `helm list`.

### Verifying the Chart

Verify that your Kubernetes pods were deployed successfully.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --tls --purge my-release
```

The command removes all of the Kubernetes components associated with the chart and deletes the release.


## Configuration

The following tables lists the configurable parameters of the `ibm-was-vm-quickstarter` chart and their default values.

| Parameter                  | Description                                     | Default                               |
| -----------------------    | ---------------------------------------------   | ------------------------------------- |
| `broker.image.repository`       | WAS VM Quickstarter broker Docker image repository. | `ibmcom/wasaas-wasdevaas`  |
| `broker.image.tag`              | WAS VM Quickstarter broker Docker image tag.  |  `1.0` |
| `broker.ingress.path`           | WAS VM Quickstarter broker ingress path.  | `/wasaas-broker/`  |
| `broker.username`               | Functional user name for WAS VM Quickstarter broker application.  | `wasaasbroker`  |
| `broker.password`               | Password for the functional user name for WAS VM Quickstarter broker application.  | `""`  |
| `broker.provider.username`      | WAS VM Quickstarter administration user name.  | `admin`  |
| `broker.provider.password`      | Password for the WAS VM Quickstarter administration user name.  | `""`  |
| `environment`                   | The environment name for this WAS VM Quickstarter instance.  | `CAM` |  
| `iam.endpoint`                  | IAM endpoint address. For example: `https://<master_ip>:8443` | `""` |
| `iam.clientId`                  | IAM OAuth client ID  | `wasaas-broker` |
| `iam.clientSecret`              | IAM OAuth client secret  | `""` |
| `image.pullPolicy`              | The pull policy for the WAS VM Quickstarter Docker images.  | 'Always' |
| `cam.ip`                        | IP address of the Cloud Automation Manager that the WAS VM Quickstarter will target for WAS deployments. | `""` |
| `cam.port`                      | The port address of CAM. |`30000` |
| `cam.user`                      | The CAM administrator user name. | `admin` |
| `cam.password`                  | The CAM administrator user's password. | `""`  |
| `cam.cloudConnectionName`       | The CAM content runtime name that will host the WAS VM Quickstarter orchestration artifacts. | `vm-quickstarter-runtime` |
| `cloudsm.capacity`              | Resource capacity in [service blocks](#resource-management). | `10` |
| `cloudsm.image.repository`      | WAS VM Quickstarter service management Docker image repository. | `ibmcom/wasaas-cloudsm`  |
| `cloudsm.image.tag`             | WAS VM Quickstarter service management Docker image tag.  |  `1.0` |
| `cloudsm.username`              | Functional user name for WAS VM Quickstarter service management applications.  | `wasaasservice`  |
| `cloudsm.password`              | Password for the functional user name for WAS VM Quickstarter service management applications.  | `""`  |
| `console.image.repository`      | WAS VM Quickstarter Console Docker image repository. | `ibmcom/wasaas-console`  |
| `console.image.tag`             | WAS VM Quickstarter console Docker image tag.  |  `1.0` |
| `console.ingress.path`          | WAS VM Quickstarter console ingress path  | `/wasaas-console/`  |
| `couchdb.image.repository`      | WAS VM Quickstarter CouchDB Docker image repository. | `couchdb`  |
| `couchdb.image.tag`             | WAS VM Quickstarter CouchDB Docker image tag.  |  `2.2.1` |
| `couchdb.adminUsername`         | WAS VM Quickstarter CouchDB administrator user name.  | `admin`  |
| `couchdb.adminPassword`         | WAS VM Quickstarter CouchDB administrator password.  | `""`  |
| `couchdb.persistentVolume.useDynamicProvisioning` | Indicates whether to use dynamic provisioning.  |  `false` |
| `couchdb.persistentVolume.size`                   | Persistent volume size.  | `10Gi`  |
| `couchdb.persistentVolume.storageClass`           | Persistent volume storage class.  | `""`  |
| `devops.image.repository`       | WAS VM Quickstarter devOps Docker image repository. | `ibmcom/wasaas-devops`  |
| `devops.image.tag`              | WAS VM Quickstarter devOps Docker image tag.  |  `1.0` |
| `migration.enabled`             | Enabled is true if the migration feature is enabled. | `false` |
| `migration.mountPoint`          | The directory path of the migration store on the NFS server.  | `""` |
| `migration.serverAddress`       | The IP address or host name of the NFS server. | `""` |
| `vsphere.osAdminUser`           | The OS image administrator user name. | `root` |
| `vsphere.osAdminPassword`       | The OS image administrator user password | `myPassword` |
| `vsphere.osImage`               | The OS image deployed in the vSphere datacenter, which the WAS VM Quickstarter uses to host the WAS deployments. | `myImage` |
| `vsphere.rootDiskSize`          | The disk size of the OS image. 25 GB is recommended. | `25` |
| `vsphere.rootDiskDatastore`     | The name of the data store that hosts the image. | `myDataStore` |
| `vsphere.resourcePool`          | The name of the vSphere resource pool to target for WAS deployments. | `myResourcePool` |
| `vsphere.folder`                | The name of the vSphere folder to use as target for WAS deployments. | `myFolder` |
| `vsphere.domain`                | The name of the vSphere domain to use as target for WAS deployments. | `myDomain` |
| `vsphere.datacenter`            | The name of the vSphere datacenter to use as target for WAS deployments. | `myDataCenter`
| `vsphere.networkInterfaceLabel` | The name of the vSphere network interface label to use as target for WAS deployments. | `myNetwork` |
| `vsphere.dnsServers`            | The IP addresses of the DNS servers to configure for WAS deployments. | `8.8.8.8` |
| `vsphere.dnsSuffxies`           | The DNS domain suffix to use for host name and URLs for WAS deployments. | `ipc.local` |
| `vsphere.ipv4Gateway`           | The IP address of the IPv4 gateway to use for WAS deployments. | `10.2.3.1` |
| `vsphere.ipv4PrefixLength`      | The length of your IPv4 prefix. | `24` |
| `vsphere.ipPool`                | The set of IP addresses to be used as host IPs for WAS virtual machine deployments. See [Prerequisites](http://ibm.biz/WASQuickstarterPrerequisites) for details. | `10.2.3.2,10.2.3.3,10.2.3.4` |

Specify each parameter using the `--set key=value[,key=value]` argument when you run the `helm install` command.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Considerations for GDPR Readiness

To prepare for General Data Protection Regulation (GDPR) readiness, review the information for the related products:
* [IBM Cloud Private considerations for GDPR readiness](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/getting_started/gdpr_readiness.html)
* [IBM Cloud Automation Manager considerations for GDPR readiness ](https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.2/cam_gdpr_readiness.html)
  * [Deploying a GDPR enabled Content Runtime](https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.2/content/cam_content_runtime_gdpr_setup.html)
* [WebSphere Application Server considerations for GDPR readiness](http://www-01.ibm.com/support/docview.wss?uid=swg22016599)

## Limitations
- You can deploy the Helm chart multiple times by using different Helm releases.  If you target the same Cloud Automation Manager and vSphere environments, care must be given to set the capacity and IP addresses to not collide with other instances of the WAS VM Quickstarter service.
- The WAS VM Quickstarter Helm chart must be installed in the `default` namespace.
- The migration feature supports only Red Hat Enterprise Linux (RHEL) target guest VMs. Ubuntu VMs are not supported.

## Documentation

#### For administrators

See the following pages within this documentation:
* [WAS VM Quickstarter Prerequisites](http://ibm.biz/WASQuickstarterPrerequisites)
* [Setting Up the Content Runtime](http://ibm.biz/WASQuickstarterContentRuntime)
* [Migrating Applications to WAS VM Quickstarter](http://ibm.biz/WASQuickstarterMigration)
* [Administering WAS VM Quickstarter](http://ibm.biz/WASQuickstarterOperations)

#### For WebSphere Application Server users

* [Setting up WebSphere Application Server on IBM Cloud Private with the WAS VM Quickstarter](http://ibm.biz/WASQuickstarterRecipe)
* [WebSphere Application Server V9.0 documentation](https://www.ibm.com/support/knowledgecenter/SSAW57_9.0.0/as_ditamaps/was900_welcome_ndmp.html)
* [WebSphere Application Server Liberty documentation](https://www.ibm.com/support/knowledgecenter/SSAW57_liberty/as_ditamaps/was900_welcome_liberty_ndmp.html)
