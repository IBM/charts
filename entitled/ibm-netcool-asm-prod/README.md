# IBM Netcool Agile Service Manager

## Introduction
IBM Netcool Agile Service Manager (ASM) provides operations teams with complete up-to-date visibility and control over dynamic infrastructure and services. Agile Service Manager lets you query a specific networked resource, and then presents a configurable topology view of it within its ecosystem of relationships and states, both in real time and within a definable time window.

## Chart Details
This chart will deploy the ASM core services and observers into your Kubernetes environment.
* Cassandra, Elasticsearch, Kafka and Zookeeper are deployed as StatefulSet objects.
* Layout, Merge, Topology and Search make up the core services of ASM, and are deployed as Deployment objects.
* Several observers are enabled by default to provide integration with IBM Netcool Operations Insight and for monitoring the cluster in which the chart is deployed.
* You choose which further observers to deploy based on your infrastructure.

## Prerequisites
* Kubernetes v1.11.0+
* A minimum of three worker nodes with adequate storage volumes
* Each worker node must have a minimum of 16 cpu, 32Gi memory and 300Gi storage
* Some kernel parameters will need tuning on each worker node
* PersistentVolumes will need to be provisioned
* (Optional) PodSecurityPolicy needs to be provisioned and made available to the target namespace
* (Optional) If installing as a team administrator, the cluster administrator will need to create a ClusterRole and ClusterRoleBindings so ASM can observe the cluster in which the chart is deployed.
  * If the installer is Team Admin and using ICP 3.1.2 or later, set the `HELM_HOME` variable prior to calling any Helm CLI command: `eval $(cloudctl helm-init)`

#### Kernel parameters
Cassandra and Elasticsearch require you to set some kernel parameters for these services to start
and run normally. This needs to be done on the worker nodes where these services will run. These nodes are determined when you configure the
persistent storage. You need to set `vm.max_map_count` to a value of at least `1048575`. Set the
parameter with `sysctl` to ensure that the change takes effect immediately:
```
sysctl -w vm.max_map_count=1048575
```

You should also set the parameter in `/etc/sysctl.conf` to ensure that the change is still in effect after a node restart by adding:
```
vm.max_map_count=1048575
```

### PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

  ```yaml
  apiVersion: policy/v1beta1
  kind: PodSecurityPolicy
  metadata:
    annotations:
      kubernetes.io/description: "This policy defines the minimum security settings required to run IBM Netcool Agile Service Manager."
    name: ibm-netcool-asm-prod-psp
  spec:
    allowPrivilegeEscalation: false
    forbiddenSysctls:
    - '*'
    fsGroup:
      ranges:
      - max: 65535
        min: 1
      rule: MustRunAs
    requiredDropCapabilities:
    - ALL
    runAsUser:
      rule: MustRunAsNonRoot
    seLinux:
      rule: RunAsAny
    supplementalGroups:
      ranges:
      - max: 65535
        min: 1
      rule: MustRunAs
    volumes:
    - configMap
    - emptyDir
    - projected
    - secret
    - downwardAPI
    - persistentVolumeClaim
  ```

* Custom ClusterRole for the custom PodSecurityPolicy:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-netcool-asm-prod-clusterrole
    rules:
    - apiGroups:
      - policy
      resourceNames:
      - ibm-netcool-asm-prod-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```

### Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation.  Choose either a predefined SecurityContextConstraints or have your cluster administrator create a custom SecurityContextConstraints for you:
* Predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc)
* Custom SecurityContextConstraints definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
      kubernetes.io/description: "This policy defines the minimum security settings required to run IBM Netcool Agile Service Manager."
    name: ibm-netcool-asm-prod-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowedCapabilities: []
  allowedFlexVolumes: []
  defaultAddCapabilities: []
  fsGroup:
    type: MustRunAs
    ranges:
    - max: 65535
      min: 1
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - ALL
  runAsUser:
    type: MustRunAsNonRoot
  seccompProfiles:
  - docker/default
  seLinuxContext:
    type: RunAsAny
  supplementalGroups:
    type: MustRunAs
    ranges:
    - max: 65535
      min: 1
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  priority: 10
  ```

#### Pre-install scripts
A number of scripts are provided to assist with the prerequisites. You will find the following
scripts in `pak_extensions/pre-install` directory of the downloaded archive.

##### clusterAdministration/createSecurityClusterPrereqs.sh
This script can be used to create the PodSecurityPolicy and ClusterRole for all releases of this chart.
This script needs to be run as a cluster administrator.

##### clusterAdministration/createStorageVolumes.sh
This script can be used to create the required storage volumes for a single deployment of the chart.
This script needs to be run as a cluster administrator.
Before running the script you must add the required configuration to `clusterAdministration/storageConfig.env`. You need to specify the worker nodes, disk locations and capacity per service e.g.
```
WORKER1=172.99.0.1
WORKER2=172.99.0.2
WORKER3=172.99.0.3
FS_ROOT=/opt/ibm/netcool
# Volume capacity in Gi
CAPACITY_CASSANDRA=50
CAPACITY_KAFKA=15
CAPACITY_ELASTICSEARCH=75
CAPACITY_ZOOKEEPER=5
# (Optional) File Observer Settings
FILE_OBSERVER_DATA_CAPACITY=5
FILE_OBSERVER_DATA_NODE=${WORKER1}
```
The script takes two arguments;  the namespace where the chart will be installed, and the release name
that will be used for the install. Example usage:
```
bash createStorageVolumes.sh myNamespace myReleaseName
```
**You need to make sure the disk locations exist before the volumes can be used.**

##### clusterAdministration/createSecurityNamespacePrereqs.sh
This script can be used to create the ClusterRoleBinding for the namespace. This script must be run as a cluster administrator. The script takes one argument; the name of a pre-existing namespace where the chart will be installed. Example usage:
```
bash createSecurityNamespacePrereqs.sh myNamespace
```

## Resources Required
The default deployment configuration will start three instances of Cassandra, Elasticsearch, Kafka
and Zookeeper. To ensure maximum resiliency, you will need a minimum of three worker nodes in your
cluster with this configuration.

#### Compute Resources
This table summarises the required compute resources for a default production (size1) deployment.

| Service             | Memory (Mi) | CPU (m) |  
| ----------          | -----       | -----   |
| cassandra-0	        | 16000       |	6000    |
| cassandra-1	        | 16000       |	6000    |
| cassandra-2	        | 16000       |	6000    |
| elasticsearch-0	    | 4000	      | 2500    |
| elasticsearch-1	    | 4000	      | 2500    |
| elasticsearch-2	    | 4000	      | 2500    |
| event-observer      | 600		      | 6000    |
| kafka-0             |	2000      	| 2100    |
| kafka-1             |	2000      	| 2100    |
| kafka-2             |	2000      	| 2100    |
| kubernetes-observer |	600         |	1000    |
| layout              |	2500        | 1500    |
| merge               |	1500        | 1500    |
| search              | 800	        | 1500    |
| topology            | 3600        | 6000    |
| ui-api              | 750         | 1000    |
| zookeeper-0         |	450         |	1000    |
| zookeeper-1         |	450         |	1000    |
| zookeeper-2         |	450         |	1000    |

This table summarises the required compute resources per additional observer.

| Observer                   | Memory (Mi) | CPU (m) |  
| ----------                 | -----       | -----   |
| alm-observer               | 600         |	1000   |
| appdynamics-observer       | 600         |	1000   |
| aws-observer               | 600         |	1000   |
| azure-observer             | 600         |	1000   |
| bigfixinventory-observer   | 600         |	1000   |
| cienablueplanet-observer   | 600         |	1000   |
| ciscoaci-observer          | 600         |	1000   |
| contrail-observer          | 600         |	1000   |
| docker-observer            | 600         |	1000   |
| dns-observer               | 600         |	1000   |
| dynatrace-observer         | 600         |	1000   |
| file-observer              | 600         |	1000   |
| googlecloud-observer       | 600         |	1000   |
| ibmcloud-observer          | 600         |	1000   |
| itnm-observer              | 600         |	1000   |
| junipercso-observer        | 600         |	1000   |
| newrelic-observer          | 600         |	1000   |
| openstack-observer         | 600         |	1000   |
| rest-observer              | 600         |	1000   |
| servicenow-observer        | 600         |	1000   |
| taddm-observer             | 600         |	1000   |
| vmvcenter-observer         | 600         |	1000   |
| vmwarensx-observer         | 600         |	1000   |
| zabbix-observer            | 600         |	1000   |


#### Storage
This table summarises the storage requirements for a default deployment, which equates to
approximately 150GB per worker node.

| Service             | Storage (Gi) |
| ----------          | ------------ |
| cassandra-0	        | 50           |
| cassandra-1	        | 50           |
| cassandra-2	        | 50           |
| elasticsearch-0	    | 75           |
| elasticsearch-1	    | 75         	 |
| elasticsearch-2	    | 75         	 |
| kafka-0             |	15        	 |
| kafka-1             |	15        	 |
| kafka-2             |	15        	 |
| zookeeper-0         |	5            |
| zookeeper-1         |	5            |
| zookeeper-2         |	5            |

## Installing the Chart
Here is an example command for installing the ASM chart into a namespace called `netcool` with a release name of `asm`:
```
$ helm install --name asm --namespace netcool ibm-netcool-asm-prod-3.0.0.tgz --set license=accept --tls
```


## Uninstalling the Chart
Find the chart release you wish to uninstall with `helm list --tls`:
```
$ helm list --tls
NAME    	REVISION	UPDATED                 	STATUS  	CHART             	NAMESPACE  
asm-test	    1       	Sat Jun 08 07:41:50 2019	DEPLOYED	asm-3.0.0         	netcool-preprod    
asm-prod     	1       	Sat Jun 28 07:18:17 2019	DEPLOYED	asm-3.0.0         	netcool
asm-demo     	1       	Tue Jun 20 08:10:57 2019	DEPLOYED	asm-3.0.0         	default
```
Now delete the release with a `helm delete <name> --tls`:
```
helm delete asm-test --tls
```
You can use the `--purge` option to remove the release from the store and make its name free for later use.

#### Post-delete scripts
A number of scripts are provided to assist with the cleanup after an uninstall. Find the following
scripts in `pak_extensions/post-delete` directory of the downloaded archive.

##### namespaceAdministration/deleteSecurityNamespacePrereqs.sh
This script can be used to delete the RoleBinding for the namespace. This script can be run as a
cluster or team administrator. The script takes one argument; the name of the namespace where the
chart was installed. Example usage:
```
bash deleteSecurityNamespacePrereqs.sh myNamespace
```

##### clusterAdministration/deleteSecurityClusterPrereqs.sh
This script can be used to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
This script needs to be run as a cluster administrator.

##### clusterAdministration/deleteStorageVolumes.sh
This script can be used to remove the persistent storage volumes and claims for a release, once you
have uninstalled. This script needs to be run as a cluster administrator. The script takes one
argument; the release name that has been uninstalled. Example usage:
```
bash deleteStorageVolumes.sh myReleaseName
```
**You need to manually clean the data from the worker nodes**

## Configuration
This table summarises the parameters that can be overridden during installation by adding them to the Helm install command as follows: `--set key=value[,key=value]`

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| asm.almObserver.enabled | Option to install the Agile Lifecycle Manager observer | false |
| asm.appdynamicsObserver.enabled | Option to install the AppDynamics observer | false |
| asm.awsObserver.enabled | Option to install the Amazon Web Services observer | false |
| asm.azureObserver.enabled | Option to install the Microsoft Azure observer | false |
| asm.bigfixinventoryObserver.enabled | Option to install the BigFix Inventory observer | false |
| asm.cienablueplanetObserver.enabled | Option to install the Ciena Blue Planet observer | false |
| asm.ciscoaciObserver.enabled | Option to install the Cisco ACI observer | false |
| asm.contrailObserver.enabled | Option to install the Juniper Contrail observer | false |
| asm.dnsObserver.enabled | Option to install the DNS observer | false |
| asm.dockerObserver.enabled | Option to install the Docker observer | false |
| asm.dynatraceObserver.enabled | Option to install the Dynatrace observer | false |
| asm.fileObserver.enabled | Option to install the File observer | false |
| asm.googlecloudObserver.enabled | Option to install the Google Cloud Platform observer | false |
| asm.ibmcloudObserver.enabled | Option to install the IBM Cloud observer | false |
| asm.itnmObserver.enabled | Option to install the ITNM observer | false |
| asm.junipercsoObserver.enabled | Option to install the Juniper Networks CSO observer | false |
| asm.newrelicObserver.enabled | Option to install the New Relic observer | false |
| asm.openstackObserver.enabled | Option to install the OpenStack observer | false |
| asm.restObserver.enabled | Option to install the REST observer | false |
| asm.servicenowObserver.enabled | Option to install the ServiceNow observer | false |
| asm.taddmObserver.enabled | Option to install the TADDM observer | false |
| asm.vmvcenterObserver.enabled | Option to install the VMware vCenter observer | false |
| asm.vmwarensxObserver.enabled | Option to install the VMware NSX observer | false |
| asm.zabbixObserver.enabled | Option to install the Zabbix observer | false |
| license | Have you read and agree to the License agreement? set to 'accept' | not-accepted |
| noi.releaseName | The name of the Helm release of NOI to connect to. | noi  |
| global.image.repository | Docker registry to pull ASM images from |   
| global.ingress.api.enabled | Option to enable the creation of ingress objects for the application endpoints | true |
| global.ingress.domain | Optional hostname to bind to the ingress rules, which must resolve to an proxy node. Multiple deployments of this chart will need to specify different values. |  |
| global.ingress.tlsSecret | Optional TLS secret for the ingress hostname. |  |
| global.persistence.enabled | Option to disable the requests for PersistentVolumes, for test and demo only. | true
| global.persistence.storageSize.cassandradata | Option to configure the requested amount of storage for Cassandra | 50Gi
| global.persistence.storageSize.kafkadata | Option to configure the requested amount of storage for Kafka | 15Gi
| global.persistence.storageSize.zookeeperdata | Option to configure the requested amount of storage for Zookeeper | 5Gi
| global.persistence.storageSize.elasticdata | Option to configure the requested amount of storage for Elasticsearch | 75Gi
| global.cassandraNodeReplicas | The number of instances to run for Cassandra | 3    
| global.elasticsearch.replicaCount | The number of instances to run for Elasticsearch | 3
| global.environmentSize | 'size0' requests fewer resources and is suitable for test and demo. Choose 'size1' for a production deployment. | size1
| global.kafka.clusterSize | The number of instances to run for Kafka | 3 |
| global.zookeeper.clusterSize | The number of instances to run for Zookeeper | 3  |

## Storage
* It is recommended to use [local storage](https://kubernetes.io/docs/concepts/storage/volumes/#local) volumes for the ASM StatefulSet applications.
* Dynamic provisioning is not yet supported for local volumes, and so these volumes must be created before installing ASM.
* Kubernetes will take care of setting file permissions for `PersistentVolumes`

## Limitations
* This chart must be installed as a team administrator
* This chart requires IBM Cloud Private version 3.2.0 or later
* This chart is only supported on amd64 worker nodes
* This chart uses the default service account in the namespace in which it is deployed
* You must remove existing jobs before attempting an upgrade

## Documentation
Please see the [IBM Netcool Agile Service Manager Knowledge Center](https://www.ibm.com/support/knowledgecenter/SS9LQB_1.1.6/) for more information.
