# IBM Db2 Advanced Enterprise Edition Helm Chart - For RedHat OpenShift deployments
  
IBM Db2 Advanced Enterprise Server Edition provides advanced data management and analytics capabilities for both transactional and warehousing workloads. It adds ease of purchase and licensing flexibility using a newly introduced simplified license metric, the Virtual Processor Core (VPC) sold as a monthly license charge. Clients can acquire the product directly online and have the option to deploy either on- premises or on cloud.

## Introduction

This chart is consist of IBM Db2 Advanced Enterprise Server Edition and is a persistent relational database intended to be deployed in IBM Cloud Private environments.
The Db2 Advanced Enterprise Server helm and docker container package can be deployed via [IBM Cloud Private CLI](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/manage_cluster/install_cli.html).

## Chart Details
This chart will do the following:

- Provide prerequisite SCC policy to be applied by a cluster administrator prior to chart install
- Deploy Db2 using a [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/). A traditional deployment follows a replica set of 1, while an [HADR](#db2-hadr) deployment follows a replica set of 2.  
- Create a Db2 Service configured to connect to the available Db2 instance on the configured client port.
- When deployed, the chart will run an initContainer, which will modify the host kernel parameters as described here - https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.qb.server.doc/doc/c0057140.html and then exit. Kernel parameters are required to be modified in order for Db2 to function correctly. 

## Prerequisites
Some prerequisites can be found under [Release Notes](ReleaseNotes.md) along with what's new.

### Security Context Constraint (Prereq #1)

- The Db2 chart requires a cluster administrator to apply the provided namespace and SCC yaml files. The SCC applies the required privileges to the new namespace where Db2 will be installed. A cluster administrator can run the following to apply the security context constraint. After the archive downloaded from PPA is extracted, there will be a directory, called `prerequisite`, which will contain a script and a set of YaML files. Run the script from that directgory as follows:

`createSCCandNS.sh --namespace <NAMESPACE>`

- If the namespace existed, only the SCC will be applied. If the namespace did not exist, a new namespace will be created with the SCC applied. 

- Remember to deploy Db2 Oltp Aese in the namespace you have created with the respective privileges. This can be done by selecting the associated namespace in the `Target namespace` configuration panel. Or if installing by command line, you may specify `--namespace <namespace>`.  

### Storage (Prereq #2) 

- Persistence method needs to be selected to ensure data is not lost in the event we lose the node running the Db2 application. 
PersistentVolume needs to be pre-created prior to installing the chart if `Enable persistence for this deployment` is selected and `Use dynamic provisioning for persistent volume` is not. For further details about the default values, see [persistence](#persistence) section.

#### Single Server Instance Storage
- 1 persistent volume is recommended. It can be created by using the kube UI or via a yaml file as the following example (Example shows an NFS persistent volume. Supported options are NFS and GlusterFS):

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
  labels:
    assign-to: "data-stor"
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>
```
> If using NFS as means of storage, it is required to have no_root_squash.

#### HADR Instance Storage
- If deploying an HA service visit [Db2 HADR](#db2-hadr) section, 6 persistent volumes are recommended. NFS or dynamic provisioning of a shared storage type between the workernodes is recommended. They can be created by using a kube UI or via yaml files as the following examples:

> **Db2 data persistent volumes for data-stor (x2):**

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>
```

> **Db2 HADR config volume for hadr-stor - NFS recommended (x1):**

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>
```

> **etcd cluster persistent volumes for etcd-stor (x3):**

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>
```

## Installing the Chart

The chart and image archive need to downloaded from Passport Advantage and then imported into the cluster. Prior to installation an SCC (Security Context Constraint) must be applied to an existing or new namespace where the Db2 chart will be installed. 
Once the archive from Passport Advantage is installed, make sure to first extract it, and run the `createSCCandNS.sh` script as follows:

`createSCCandNS.sh --namespace <NAMESPACE>`

The above will create a namespace (or modify existing) to apply the SCC. 

Once done, you can load the chart/image archive into the cluster. The following instructions can help you through this process - https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/installing/install_entitled_workloads.html

Once loaded, you can either use the helm command or the UI to install the chart. 

To install via Helm command line with the release name `my-release` if you do not have the helm repository:

```bash
#This will show the repositories
helm repo list

#This will show all the charts related to the repository
helm search list

#Finally install the respective chart
$ helm install --name my-release --set options.databaseName=TESTDB --set imageRepository="docker-registry.default.svc:5000/<NAMESPACE>/db2server_aese_rhel" local/ibm-db2oltp-aese-rhos:3.1.0, where <NAMESPACE> is the namespace you are installing in. 
```

The command deploys ibm-db2oltp-aese-rhos on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Configuration

You may change the default of each parameter using the `--set key=value[,key=value]`.
I.e `helm install --name my-release --set options.databaseName=TESTDB --set imageRepository="docker-registry.default.svc:5000/<NAMESPACE>/db2server_aese_rhel" local/ibm-db2oltp-aese-rhos:3.1.0`, where <NAMESPACE> is the namespace you are installing in.

> **Tip**: You can configure the default [values.yaml](values.yaml)


The following tables lists the configurable parameters of the ibm-db2oltp-aese chart and their default values when installing via a kube UI from clicking `configure`. They are a wrapper for the real values found in values.yaml

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `arch`                              | Worker node architecture                            | `nil` - will try to detect it automatically based on the node deploying the chart. User can explicitely select amd64 | 
| `imageRepository`                   | Db2 Advanced Enterprise Edition image repository    | Default is `docker-registry-default.<MASTER HOSTNAME>/<NAMESPACE>/db2server_aese_rhel` but MUST be changed to `docker-registry.default.svc:5000/<NAMESPACE>/db2server_aese_rhel` before install, locally available in your cluster                              |     
| `imageTag`                          | Db2 Advanced Enterprise Edition image tag           | `11.1.3.3b` - will be suffixed with `-<arch>` once architecture is determined   |
| `imagePullPolicy`                   | Image pull policy                                   | `IfNotPresent`                                                                  |
| `service.name`                      | The name of the Service                             | `ibm-db2oltp-aese-rhos`                                                               |
| `service.port`                      | TCP port                                            | `50000`                                                                         |
| `service.tsport`                    | Text search port                                    | `55000`                                                                         |
| `service.type`                      | k8s service type exposing ports, e.g.`ClusterIP`    | `ClusterIP`                                                                     |
| `db2inst.instname`                  | Db2 instance name                                   | `nil` - Default user will be created - db2inst1                                 | 
| `db2inst.password`                  | Db2 instance password                               | `nil` - A 10 character random generated password. See below for instructions on how to retrieve it.|  
| `options.databaseName`              | Create database with name provided                  | `nil` - No database will be created                                             |  
| `options.oracleCompatibility`       | Enable compatibility with Oracle                    | `false` - Feature will not be activated. Set to true to enable it.              |       
| `persistence.enabled`               | Enable persistence for this install                 | `true`  - Recommended value. If set to false, Db2 HADR can not be configured.   |
| `peristence.useDynamicProvisioning` | Use dynamic provisioning for persistent volume      | `false` - Set to true if dynamic provisioning is available on the cluster.      |
| `hadr.enabled`                      | Configure Db2 HADR                                  | `false` - If set to true, Db2 HADR will be configured. Read below for details.  |
| `hadr.useDynamicProvisioning`       | Dynamic provisioning for Db2 HADR shared volume     | `false` - Set to true if dynamic provisioning is available on the cluster.      |
| `dataVolume.name`                   | Name of the Db2 DB storage persistent volume claim  | `data-stor`                                                                     |
| `dataVolume.existingClaimName`      | Existing volume claim for data-stor                 | `nil` - Only supported in non-HADR scenarios.                                   |
| `dataVolume.storageClassName`       | Existing storage class name for data-stor           | `nil`                                                                           |
| `dataVolume.size`                   | Size of the volume claim for data-stor              | `20Gi`                                                                          |
| `hadrVolume.name`                   | Name of the Db2 HADR persistent volume claim        | `hadr-stor`                                                                     |
| `hadrVolume.existingClaimName`      | Existing volume claim for hadr-stor                 | `nil`                                                                           |
| `hadrVolume.storageClassName`       | Existing storage class name for hadr-stor           | `nil`                                                                           |
| `hadrVolume.size`                   | Size of the volume claim for hadr-stor              | `1Gi`                                                                           |
| `etcdVolume.name`                   | Name of the Etcd persistent volume claim            | `etcd-stor`                                                                     |
| `etcdVolume.storageClassName`       | Existing storage class name for etcd-stor           | `nil`                                                                           |
| `etcdVolume.size`                   | Size of the volume claim for etcd-stor              | `1Gi`                                                                           |

## Resources Required

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `Resource configuration`            | CPU/Memory resource requests/limits                 | Memory request/limit: `2Gi`/`16Gi`, CPU request/limit: `2000m`/`4000m`          |

## Verifying the Chart

In the developerWorks recipe, visit step `Confirming Db2 Application is Ready` [here](https://developer.ibm.com/recipes/tutorials/ibm-db2-on-ibm-cloud-private-with-redhat-openshift/)

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` statefulset:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions additional commands required for clean-up.  

For example :

When deleting a release with statefulsets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
``` 


# DOCUMENTATION AND ADDITIONAL INFORMATION

## Db2 HADR

High availability disaster recovery (HADR) provides a high availability solution for both partial and complete site failures. HADR protects against data loss by replicating data changes from a source database, called the primary database, to the target databases, called the standby databases.
Db2 HADR on a kubernetes cluster is currently supported to be deployed within the same data center, i.e. HA only. Future releases will address automatic deployment accross data centers and geographies. For more information about HADR, click on this [knowledge center link](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.ha.doc/doc/c0011267.html)  

- To deploy the Db2 chart with HADR enabled, select the `Enable Db2 HADR feature` in the kube UI, or if using helm CLI, `--set hadr.enabled=true`
- If Db2 HADR is enabled, there are a few prerequisites:
  * Data persistence MUST be enabled, i.e. make sure "Enable persistence for this install" is checked off in the kube UI, or if using helm CLI, make sure that `persistence.enabled=true` in values.yaml or `--set persistence.enabled=true` on the command line. 
  * User MUST have an HADR persistence volume pre-created. A single volume is needed - 1Gi in size, ReadWriteMany access mode. It is recommended that this volume is NFS accessible by all worker nodes. 
  * User MUST have an ETCD persistent volumes pre-created. Three volumes are needed as etcd is deployed in a 3-node cluster configuration. Each volume should be 1Gi in size and ReadWriteOnce access mode. 
  * Additional configuration options for these volumes are available in the table above - such as size, name, existing claim names, and storage class names.  
- Once Db2 HADR has been enabled, the install will kick off 2 replicas of the ibm-db2oltp-aese statefulset. Each pod in this set will be configured as a PRIMARY and a STANDBY database. The PRIMARY will be configured on ibm-db2oltp-aese-0 pod and STANDBY on the ibm-db2oltp-aese-1 pod. If takeover happens, the PRIMARY will get switched to the ibm-db2oltp-aese-1 pod and when STANDBY is restarted, it will be set up on the ibm-db2oltp-aese-0. This will get switched as roles change during takeovers. 
- An automatic client re-route [ACR](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.ha.doc/doc/c0011976.html) is set up on each primary and standby pods so that applications can be directed to a standby server if a primary crash occurs. 
- Refer to the Db2 integration recipe for how to connect to your primary database - [here](https://developer.ibm.com/recipes/tutorials/db2-integration-into-ibm-cloud-private/)


## Architecture

- Currently, for IBM Cloud Private on RedHat Openshift, only AMD64 architecture is available. 
  - AMD64 / x86_64

An `arch` field in values.yaml is recommended in order to guarantee that the chart has chosen the right architecture to deploy to and the right tagged container is pulled. If left blank, the chart will determine the architecture based on the master node architecture. 

## Retrieving the Db2 instance password

The Db2 instance password is either auto-generated to a 10 character random password or user-specified. To retrieve the Db2 instance password, the user can execute the following command, where <SECRET NAME> is the secret for the statefulset as retrieved by `kubectl get secrets`::

`kubectl get secret --namespace default <SECRET NAME> -o jsonpath="{.data.password}" | base64 --decode; echo`

The command will output the decoded secret. 

## Persistence

- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - Enable persistence for this deployment: selected (default) (persistence.enabled=true)
    - Use dynamic provisioning for persistent volume: selected (non-default) (persistence.useDynamicProvisioning=true)
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - Enable persistence for this deployment: selected (default) (persistence.enabled=true)
    - Use dynamic provisioning for persistent volume: non-selected (default) (persistence.useDynamicProvisioning=false)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.    


- No persistent storage. This mode with use emptyPath for any volumes referenced in the deployment
  - enable this mode by setting the global values to:
    - Enable persistence for this deployment: non-selected (non-default) (persistence.enabled=false)
    - Use dynamic provisioning for persistent volume: non-selected (non-default) (persistence.useDynamicProvisioning=false)


### Existing PersistentVolumeClaims

Example for specifying an existing PersistentVolumeClaim for the `data-stor` volume request (Only supported in non-HADR scenarios). For HADR scenarios, an existing PersistentVolumeClaim for `hadr-stor` is allowed but it must be RWX. 
1. Create the PersistentVolume 
1. Create the PersistentVolumeClaim
1. Install the chart
```bash
$ helm install --name my-release --set dataVolume.existingClaimName=PVC_NAME
```

The volume defaults to mount at a subdirectory of the volume instead of the volume root to avoid the volume's hidden directories from interfering with database creation.


## Namespace Considerations

Since Db2 requires certain Linux capabilities exposed in a namespace, make sure to apply the SCC to the targeted namespace, prior to installing the chart:

`createSCCandNS.sh --namespace <NAMESPACE>`

The above will create a namespace (or modify existing) to apply the SCC.


## Limitations
- We do not want to scale our Db2 StatefulSets. This means we must leave the replica at 1 (itself) if for a single instance deployment and a replica of 2 if for a HADR deployment. If we scale it over 1 or 2, the Db2 instances will reference the same filesystem that consist of the instance, database directory, etc. This will cause Db2 to crash.
- Only supports storage options that have backends for persistent volume claims.
- ROLLING UPGRADES FROM PREVIOUS CHART RELEASES ARE NOT SUPPORTED
