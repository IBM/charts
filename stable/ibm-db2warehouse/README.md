# Db2 Warehouse 11.5.4.0


## Introduction
This chart configures 
* Db2 Warehouse is designed for high-performance, in-database analytics.

* Product description - https://www.ibm.com/hr-en/marketplace/db2-warehouse 

## Chart Details
* SMP (Symmetric Multiprocessing) or MPP (Massively Parallel Processing) by setting the replica count for the Db2U container.
* Main engine deploys in a StatefulSet topology

## Prerequisites
* Kubernetes Level - ">=1.11.0"

* Helm Level:
    - Power: ">=2.12(*) and < 3.0"
    - X86: ">=2.14(*) and < 3.0"
> (*) Tested Integrations
* OpenShift Version - "3.11, 4.3"


* PersistentVolume requirements - requires one of the following:
	- NFS
	- IBM Cloud File Storage (gold storage class)
	- Portworx
	- Red Hat OpenShift Container Storage 4.3 and above
	- or a hostPath PV that is a mounted clustered filesystem 

* An [IBM Cloud](https://cloud.ibm.com/login) account


## Resources Required 
* 
	- 1 worker node for SMP or 2-999 worker nodes for MPP
	- For SMP Cores: 7.7 (4 for the Db2 engine and 3.7 for Db2 auxiliary services)
	- Memory: 22.4 GiB (16 GiB for the Db2 engine (SMP) and 6.4 GiB for Db2 auxiliary services)
	- For MPP, the memory required by the Db2 Engine depends on the number of worker nodes selected. For 1 node, the minimum required amount is 16 GiB. For 2 or more nodes, the minimum required amount is 24 GiB per worker node.



# Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.
The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
```
kind: SecurityContextConstraints
apiVersion: security.openshift.io/v1
metadata:
  name: db2wh-scc
allowHostDirVolumePlugin: true
allowHostIPC: true
allowHostNetwork: false
allowHostPID: false
allowHostPorts: true
# privileged container is only needed for the init container that sets kernel parameters
allowPrivilegedContainer: true
allowedCapabilities:
- "SYS_RESOURCE"
- "IPC_OWNER"
- "SYS_NICE"
# Default capabilities add by docker if not drop.
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
priority: 10
runAsUser:
    type: RunAsAny
seLinuxContext:
    type: MustRunAs
fsGroup:
    type: RunAsAny
supplementalGroups:
    type: RunAsAny
```



## Installing the Chart


### 1. Pre-install cluster configuration
- Create a project of your desired name
  ```
  $ oc new-project <PROJECT>
  ```  
- Security privileges required to deploy chart described above. Run the following commands on your Red Hat Openshift cluster
  ```bash
  $ cd ./ibm_cloud_pak/pak_extensions
  $ ./pre-install/clusterAdministration/createSecurityClusterPrereqs.sh
  $ ./pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh <PROJECT>
  ```

- Create the LDAP bluadmin secret with the following command, filling in RELEASE_NAME and PASSWORD variables accordingly:
  ```
  $ RELEASE_NAME=""
  $ PASSWORD=""
  $ oc create secret generic ${RELEASE_NAME}-db2u-ldap-bluadmin --from-literal=password="${PASSWORD}"
  ```

- Create the Db2 instance secret with the following command, filling in RELEASE_NAME and PASSWORD variables accordingly:
  ```
  $ RELEASE_NAME=""
  $ PASSWORD=""
  $ oc create secret generic ${RELEASE_NAME}-db2u-instance --from-literal=password="${PASSWORD}"
  ```
 
### 2. Accessing IBM Container Registry
You can get Db2 Warehouse container images from the IBM Cloud Container Registry. You need to setup the environment to be able to access IBM Cloud Registry for this deployment.

* Create an API key:
1. Log into [IBM Cloud](https://cloud.ibm.com/login)
2. Select **Manage > Access(IAM)** from the toolbar
3. Select **API keys** from the side menu, click **Create an IBM Cloud API Key**
4. Enter a Name and Description. Click **create**
5. You can copy the API key or select to download the key and save it.

* Create image registry secret in your current project

  Run the following commands on your Red Hat Openshift cluster, replacing `<APIKey>` with the API Key obtained in the previous step
  ```bash
  $ oc create secret docker-registry ibm-registry \
      --docker-server=icr.io \
      --docker-username=iamapikey \
      --docker-password=<APIKey>
  $ oc secrets link db2u ibm-registry --for=pull
  ```
  > Always use `iamapikey` as the value of `docker-username` field

### 3. Chart installation
  Locate `db2u-install` script under `./ibm_cloud_pak/pak_extensions/common` and proceed to install the charts. The usage of `db2u-install` is:

  ```
  Usage: ./db2u-install --db-type STRING --namespace STRING --release-name STRING [--existing-pvc STRING | --storage-class STRING | --helm-opt-file FILENAME ] [OTHER ARGUMENTS...]

    Install arguments:
        --db-type STRING            the type of database to deplpy. Must be one of: db2wh, db2oltp (required)
        --db-name STRING            the name of database to deplpy. The default value is BLUDB (optional). The length of the value must not exceed 8 characters
        --namespace STRING          namespace/project to install  into (required)
        --release-name STRING       release name for helm (required)
        --arch STRING               architecture of the cluster (optional)
        --existing-pvc STRING       existing PersistentVolumeClaim to use for persistent storage
        --storage-class STRING      StorageClass to use to dynamically provision a volume. Use this option for NFS storage class.
                                    For advanced settings that require multiple storage classes, use help-opt-file instead.
        --cpu-size STRING           amount of CPU cores to set at engine pod's request
        --memory-size STRING        amount of memory to set at engine pod's request
        --helm-opt-file STRING      path to a file containing helm options in key=value format separated by a new line (optional)
                                    for an example, refer to ./helm_options
                                    for an exhaustive list of supported options, refer to the Configuration section of the README
        --accept-eula               accept end user license agreement without prompting the dialog (optional)
        --upgrade                   upgrade the helm release (optional)

    Helm arguments:
        --dry-run                   simulate an install/upgrade
        --tls                       enable TLS for request
        --tiller-namespace STRING   namespace/project of Tiller (default "kube-system")
        --tls-ca-cert STRING        path to TLS CA certificate file (default "$HELM_HOME/ca.pem")
        --tls-cert STRING           path to TLS certificate file (default "$HELM_HOME/cert.pem")
        --tls-key STRING            path to TLS key file (default "$HELM_HOME/key.pem")
        --tls-verify                enable TLS for request and verify remote
        --home STRING               location of your Helm config. Overrides $HELM_HOME (default "~/.helm")
        --host STRING               address of Tiller. Overrides $HELM_HOST
        --kube-context STRING       name of the kubeconfig context to use

    Miscellaneous arguments:
        -h, --help                  display the usage
  ```

> **Note:** Installing these charts directly (without using the provided db2u-install script), using Helm, or changing parameters in the values.yaml file are not recommended. Either of these actions may cause the components to malfunction or expose security vulnerabilities.

### Examples:

- Installation with single storage class:
  ```bash
  $ cd ./ibm_cloud_pak/pak_extensions/common
  $ ./db2u-install \
    --db-type db2oltp \
    --db-name MYDB \
    --namespace db2u-project \
    --release-name db2u-release-1 \
    --storage-class managed-nfs-storage
  ```

- Installation with advanced storage options specified in a configuration file:

  A configuration file can be passed using `--helm-opt-file=FILENAME` argument to set the advanced helm options.
  For example:
 
  ```bash
  $ cd ./ibm_cloud_pak/pak_extensions/common
  $ ./db2u-install \
    --db-type db2oltp \
    --namespace db2u-project \
    --release-name db2u-release-2 \ 
    --helm-opt-file ./helm_options
  ```
  A sample configuration file `./ibm_cloud_pak/pak_extensions/common/helm_options` is included with this chart.

  ```bash
  storage.useDynamicProvisioning="true"
  storage.enableVolumeClaimTemplates="true"
  storage.storageLocation.dataStorage.enablePodLevelClaim="true"
  storage.storageLocation.dataStorage.enabled="true"
  storage.storageLocation.dataStorage.volumeType="pvc"
  storage.storageLocation.dataStorage.pvc.claim.storageClassName="ocs-storagecluster-ceph-rbd"
  storage.storageLocation.dataStorage.pvc.claim.size="40Gi"
  storage.storageLocation.metaStorage.enabled="true"
  storage.storageLocation.metaStorage.volumeType="pvc"
  storage.storageLocation.metaStorage.pvc.claim.storageClassName="ocs-storagecluster-cephfs"
  storage.storageLocation.metaStorage.pvc.claim.size="40Gi"
  ```
  > **Note:** Values of storageClassName must be valid names from `oc get sc` output on your system.
  
  For an exhaustive list of supported options, refer to [Configuration](#configuration) section of this README.

## SELinux Considerations
For information on using Red Hat OpenShift with SELinux in enforcing mode, see the [Db2 Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSEPGG_11.5.0/com.ibm.db2.luw.db2u_openshift.doc/doc/c_db2u_selinux.html).

## Enabling Db2 HADR

To enable Db2 HADR (High Availability Disaster Recovery) in a db2u standalone deployment the following option has to be added to the helm options file:

```
hadr.enabled="true"
```

## Enabling Db2 REST

To enable Db2 REST in a db2u standalone deployment the following option to be added to the helm options file:

```
rest.enabled="true"
```

To enable the rest server to communicate outside the cluster you need to create an external route and apply it.

Here is an example route yaml file

```
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  labels:
    app: db2wh-rest
    app.kubernetes.io/managed-by: Helm
    chart: ibm-db2warehouse
    component: db2wh
    heritage: Helm
    release: db2wh-rest
  name: db2wh-rest-db2u-rest-svc
spec:
  port:
    targetPort: rest-server
  tls:
    termination: passthrough
  to:
    kind: Service
    name: db2wh-rest-db2u-rest-svc
    weight: 100
  wildcardPolicy: None
```

Here is the command to create it

```
oc create -f <YAML_FILE>
```






## Verifying the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release.

## Uninstalling the Chart

To delete the deployment:

```
$ helm delete --purge <RELEASE-NAME>
```

To delete the pre-install configuration objects:

```
$ oc delete -n <PROJECT> sa/db2u role/db2u-role rolebinding/db2u-rolebinding
```

To delete the secrets:

```
$ oc delete -n <PROJECT> secret/<RELEASE-NAME>-db2u-ldap-bluadmin secret/<RELEASE-NAME>-db2u-instance
```


The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions with additional commands required for clean-up.

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```
$ kubectl delete pvc -l release=my-release
```

## Configuration

The following tables lists the configurable parameters of the ibm-db2warehouse chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|dedicated|Enforce that Db2 is scheduled on worker nodes that haved been labeled and tainted with icp4data=${value}. Use with option global.nodeLabel.value below.|True|
|subType|Database subtype can be either [smp, mpp] for db2wh. For db2oltp, the subtype is smp.|smp|
|arch|The helm chart will try to detect the architecture based on the master node. Choose an explicit architecture here to overwrite it.|x86_64|
|mln.total|The total number of MLNs to be used and evenly spread out to the number of worker nodes.|1|
|global.dbType|Database type can be either [db2wh, db2oltp]|db2wh|
|global.nodeLabel.value|Value for the node label in order to deploy Db2 on a dedicated node. The node must be labeled and tainted with icp4data=${value}||
|images.universalTag|The tag specified here will be used by all images except those that explicitly specify a tag.|latest|
|images.pullPolicy|Always, Never, or IfNotPresent. Defaults to Always|IfNotPresent|
|images.auth.image.tag|The tag for the version of the LDAP authentication container|11.5.4.0-56|
|images.auth.image.repository|The container is deployed to serve as an LDAP server for database authentication if ldap.enabled is true and no ldap server is not specified|icr.io/obs/hdm/db2u/db2u.auxiliary.auth|
|images.rest.image.tag|The container tag that is used to pull the version of the rest container.|11.5.4.0-56|
|images.rest.image.repository|The REST container image, which is used to perform host the REST sever|icr.io/obs/hdm/db2u/db2u.rest|
|images.etcd.image.tag|The etcd conatiner tag that used to pull the version of the needed container.|3.3.10-56|
|images.etcd.image.repository|The etcd container is used in MPP configurations to automate the failover of MPP nodes|icr.io/obs/hdm/db2u/etcd|
|images.instdb.image.tag|The container tag that is used to pull the version of the Database and instance payload container|11.5.4.0-56|
|images.instdb.image.repository|This container carries the payload required to restore a database and instance into a newly deployed release.|icr.io/obs/hdm/db2u/db2u.instdb|
|images.db2u.replicas|The number of Db2 Warehouse pods that will serve the database. Replica count of 1 signifies SMP and 2 and more is an MPP configuration.|1|
|images.db2u.image.tag|The container tag that is used to pull the version of Db2 Warehouse main engine container.|11.5.4.0-56|
|images.db2u.image.repository|The main database engine for the Db2 Warehouse release|icr.io/obs/hdm/db2u/db2u|
|images.tools.image.tag|The container tag that is used to pull the version of the tools container.|11.5.4.0-56|
|images.tools.image.repository|The tools container image, which is used to perform outside of the engine operations|icr.io/obs/hdm/db2u/db2u.tools|
|database.name|The name of the database. Defaults to BLUDB|BLUDB|
|database.pageSize|The default database page size. Defaults to 32768.|32768|
|database.bluadminPwd|Password for the LDAP database administrator which is the main LDAP user||
|database.codeset|The default database codeset. Defaults to UTF-8.|UTF-8|
|database.collation|The default database collation sequence. Defaults to IDENTITY.|IDENTITY|
|database.territory|The default database territory. Defaults to US.|US|
|storage.storageClassName|Choose a specific storage class name to use during deployment. A storage class offers the foundation for dynamic provisioning.||
|storage.existingClaimName|Name of an existing Persistent Volume Claim that references a Persistent Volume||
|storage.useDynamicProvisioning|If dynamic provisioning is available in the cluster this option will automatically provision the requested volume if set to true.|False|
|instance.db2Support4K|Db2 supports storage devices that use a 4KB sector size in production environments. Default to false.|False|
|limit.cpu|CPU cores limit to apply to Db2. Db2 won't be able to exceed the provided value.|2|
|limit.memory|Memory limit to apply to Db2. Db2 won't be able to exceed the provided value.|4.3Gi|



## Storage
* requires one of the following:
	- NFS
	- IBM Cloud File Storage (gold storage class)
	- Portworx
	- Red Hat OpenShift Container Storage 4.3 and above
	- or a hostPath PV that is a mounted clustered filesystem

## Limitations
