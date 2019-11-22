# Db2 Warehouse 11.5.1.0


## Introduction
This chart configures IBM Db2 Warehouse - Enterprise Edition 3.9.1
* IBM Db2 Warehouse is an analytics data warehouse for private clouds
* Currently only used in Cloud Pak for Data environments
* Product description - https://www.ibm.com/hr-en/marketplace/db2-warehouse 

## Chart Details
* SMP (Symmetric Multiprocessing) or MPP (Massively Parallel Processing) by setting the replica count for the Db2U container.
* Main engine deploys in a StatefulSet topology

## Prerequisites
* Kubernetes Level - ">=1.10.1"
* PersistentVolume requirements - requires NFS or a hostPath PV that is a mounted clustered filesystem across all worker nodes. 
* Resource requirements - 1 worker node for SMP or 2-999 worker nodes for MPP; Cores: 1; Memory: the amount of memory required depends on the number of worker nodes selected. For 1 node, the minimum amount is 8 GB. For 2 or more nodes, the minimum is 24 GB assigned to each logical node.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

  - Custom PodSecurityPolicy definition:
```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: db2wh-psp
spec:
  allowPrivilegeEscalation: true
  readOnlyRootFilesystem: false
  privileged: false
  allowedCapabilities:
    - "SYS_RESOURCE"
    - "IPC_OWNER"
    - "SYS_NICE"
    - "NET_RAW" # need for ping, use in etcd
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
  fsGroup:
    rule: RunAsAny
  hostIPC: true
  hostNetwork: false
  hostPID: false
  hostPorts:
  - max: 65535
    min: 1
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - '*'
```
  - Custom ClusterRole for the custom PodSecurityPolicy:
```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: db2wh-cr
rules:
- apiGroups:
  - extensions
  resources:
  - podsecuritypolicies
  resourceNames:
  - db2wh-psp
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

- From the command line, you can run the setup scripts included under pak_extensions
  As a cluster admin the pre-install instructions are located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped instructions are located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.
The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
```
kind: SecurityContextConstraints
apiVersion: v1
metadata:
  name: db2wh-scc
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
- "NET_RAW" # need for ping, use in etcd
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
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
fsGroup:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
```

- From the command line, you can run the setup scripts included under pak_extensions
  As a cluster admin the pre-install instructions are located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped instructions are located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

## Resources Required
* 1 worker node for SMP or 2-999 worker nodes for MPP; Cores: 1; Memory: the amount of memory required depends on the number of worker nodes selected. For 1 node, the minimum amount is 8 GB. For 2 or more nodes, the minimum is 24 GB assigned to each logical node.

## Installing the Chart
* This chart is to be installed via Cloud Pak for Data integrated interface
* Security privileges required to deploy chart described above

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --name my-release --values values.yaml stable/ibm-db2wh-prod
```

The command deploys ibm-db2wh-prod on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation and can be included in a values.yaml file or individually entered through `--set`.


> **Tip**: List all releases using `helm list --tls`

### Verifying the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --tls.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions with additional commands required for clean-up.

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
```

## Configuration

The following tables lists the configurable parameters of the ibm-db2wh-prod chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|dedicated|The worker nodes must be label and tainted with icp4data=database-dbType, where dbType can be found in configuration option below.|True|
|arch|The helm chart will try to detect the architecture based on the master node. Choose an explicit architecture here to overwrite it.||
|mln.distribution|The number of MLNs to land on catalog/head node vs each of the data nodes when configuring MPP.|0:0|
|mln.total|The total number of MLNs to be used and evenly spread out to the number of worker nodes.|0|
|global.dbType|Database type can be either db2wh, db2oltp, or db2eventstore|db2wh|
|images.pullPolicy|Always, Never, or IfNotPresent. Defaults to Always|IfNotPresent|
|images.universalTag|The tag specified here will be used by all images except those that explicitly specify a tag.|latest|
|images.etcd.volume.storageClassName|Specific storageClassName to be used by the etcd container|oketi-gluster|
|images.etcd.volume.size|The size of the storage volume to be used for etcd related storage.|1Gi|
|images.etcd.volume.useDynamicProvisioning|Select if you want to dynamically provision a volume for etcd storage|False|
|images.etcd.volume.name|The etcd volume name to be used by the etcd container. |etcd-stor|
|images.etcd.image.tag|The etcd conatiner tag that used to pull the version of the needed container.|3.3.10-322|
|images.etcd.image.repository|The etcd container is used in MPP configurations to automate the failover of MPP nodes|etcd|
|images.etcd.storage.persisted|If set to false, etcd storage will be ephemeral|True|
|images.db2u.replicas|The number of Db2 Warehouse pods that will serve the database. Replica count of 1 signifies SMP and 2 and more is an MPP configuration.|1|
|images.db2u.image.tag|The container tag that is used to pull the version of Db2 Warehouse main engine container.|v11.5.1.0-322|
|images.db2u.image.repository|The main database engine for the Db2 Warehouse release|db2u|
|images.instdb.image.tag|The container tag that is used to pull the version of the Database and instance payload container|v11.5.1.0-322|
|images.instdb.image.repository|This container carries the payload required to restore a database and instance into a newly deployed release.|db2u.instdb|
|images.tools.image.tag|The container tag that is used to pull the version of the tools container.|v11.5.1.0-322|
|images.tools.image.repository|The tools container image, which is used to perform outside of the engine operations|db2u.tools|
|images.auth.replicas|The number of replicas for the LDAP authentication container|1|
|images.auth.image.tag|The tag for the version of the LDAP authentication container|v11.5.1.0-322|
|images.auth.image.repository|The container is deployed to serve as an LDAP server for database authentication if ldap.enabled is true and no ldap server is not specified|db2u.auxiliary.auth|
|database.db2InstancePwd|Password for the database instance user||
|database.workload|The Db2 Workload to tune the instance and the database||
|database.encrypt|Whether to encerpt the database using Db2 native encryption or not. Default is to encrypt.|YES|
|database.name|The name of the database. Defaults to BLUDB|BLUDB|
|database.pageSize|The default database page size. Defaults to 32768.|32768|
|database.bluadminPwd|Password for the LDAP database administrator which is the main LDAP user||
|database.compatibilityVector|The database DB2_COMPATIBILITY_VECTOR registry variable setting. Defaults to NULL.|NULL|
|database.db2InstanceGroup|The admin group that the database instance user belongs to.|db2iadm1|
|database.codeset|The default database codeset. Defaults to UTF-8.|UTF-8|
|database.collation|The default database collation sequence. Defaults to IDENTITY.|IDENTITY|
|database.db2FencedUser|The database fenced user name associated with the DB2 instance.|db2fenc1|
|database.territory|The default database territory. Defaults to US.|US|
|database.create|Create the database? Defaults to true|True|
|database.tableOrg|The default database table organization. Defaults to COLUMN.|COLUMN|
|database.db2InstanceUser|The database instance user.|db2inst1|
|storage.storageClassName|Choose a specific storage class name.||
|storage.existingClaimName|Name of an existing Persistent Volume Claim that references a Persistent Volume||
|storage.useDynamicProvisioning|If dynamic provisioning is available in the cluster this option will automatically provision the requested volume if set to true.|False|
|storage.persisted|Persisting the database data is recommended in order to avoid data loss.|True|
|storage.userHomeStor.existingClaimName|Name of an existing Persistent Volume Claim that references a Persistent Volume||
|limit.cpu|CPU cores limit for the database|1000m|
|limit.memory|Memory limit for the database|8Gi|
|ldap.ldap_admin|The ldap admin||
|ldap.ldap_user_group|The ldap user group||
|ldap.ldap_domain|The ldap domain||
|ldap.enabled|Enable ldap for database authentication|False|
|ldap.ldap_server|The ldap server to use||
|ldap.ldap_admin_group|The ldap admin group||



Specify each parameter using the `--set key=value[,key=value]` argument to `helm install --tls`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default values.yaml

## Storage
* requires NFS or a hostPath PV that is a mounted clustered filesystem across all worker nodes.

## Limitations