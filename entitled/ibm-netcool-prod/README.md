IBM Netcool Operations Insight enables you to monitor the health and performance of IT and network infrastructure across local, cloud and hybrid environments.

# IBM Netcool Operations Insight

## Introduction

IBM Netcool Operations Insight enables you to monitor the health and performance of IT and network infrastructure across local, cloud and hybrid environments. It also incorporates strong event management capabilities, and leverages real-time alarm and alert analytics, combined with broader historic data analytics, to deliver actionable insight into the performance of services and their associated dynamic network and IT infrastructures.

## Contents

- [Details](#details)
- [Prerequisites](#prerequisites)
- [Resources Required](#resources-required)
- [Installing the operator from olm](#to-install-the-operator-via-olm)
- [Storage](#storage)
- [Configuration](#configuration)
- [Limitations](#limitations)
- [Documentation](#documentation)

# Details

The ibm-netcool-prod operator and its dependent sub operators provide the capability to deploy the following Operations Management applications and capabilities from the IBM Netcool Operations Insight solution:

- Netcool/OMNIbus Core
- Netcool/OMNIbus WebGUI
- Netcool/Impact
- DB2 Enterprise Server Edition database
- Message Bus gateway to support interaction between the components
- Cloud Native Event Analytics
- Event management
- Topology management

The operator also deploys one of the following components required to enable Operations Management.

- openLDAP server - for use when no external LDAP connection is required.
- openLDAP proxy - to connect to an existing LDAP server outside of the deployment.

For more information on how these applications work together to provide Netcool Operations Insight functionality, see
[Netcool Operations Insight documentation: Deployment modes](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/integration/concept/soc_int_deploymentmodes.html).

For more information on event management, see [Configuring integrations](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/config/task/cfg_configuring-integrations.html)

For more information on topology management, see [Working with topology](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/asm/doc/Using/c_asm_using.html)

## Prerequisites

- [Basic prerequisites](#basic-prerequisites)
- [Store passwords in secrets](#store-passwords-in-secrets)
- [Red Hat OpenShift SecurityContextConstraints Requirements](#red-hat-openshift-securitycontextconstraints-requirements)

### Basic prerequisites

The following prerequisites are required for a successful installation.

- A Kubernetes cluster. For more information on the cluster, see  [Netcool Operations Insight documentation: Products and components on a container platform](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/integration/concept/soc_int_noicontphysicaldeplexample.html).
- Openshift CLI (oc), see [Getting started with the CLI](https://docs.openshift.com/container-platform/4.4/cli_reference/openshift_cli/getting-started-cli.html).
- Kubernetes v1.11.0 or later.
- PersistentVolume support on the cluster.
- Kubernetes command line interface (`kubectl`) installed and able to communicate with the cluster. For more information, including the required version of `kubectl`, see [Accessing your cluster using kubectl](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.1/manage_cluster/install_kubectl.html).
- Create ClusterRole and ClusterRoleBinding for topology management observers. For more information, see https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/integration/task/soc_int_preparing-rhocp-cluster.html
- Openshift image mirroring and cluster pull secrets
https://docs.openshift.com/container-platform/4.4/openshift_images/image-configuration.html#images-configuration-registry-mirror_image-configuration


For more information on prerequisites, see  [Netcool Operations Insight Documentation: Preparing for installation](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/integration/task/soc_int_preparing-rhocp-installation.html).

### Store passwords in secrets.
  Following our security requirements, we do not install with default passwords. There are two options for password generation.
 - The install will generate random passwords and store these passwords in secrets, which you can extract after the install.  
 - You can create the passwords in secrets prior to install, where you choose the password [following these guidelines](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/integration/task/int-creating_passwords_and_secrets-rhocp.html).

### Red Hat OpenShift Security Context Constraints Requirements

The operator requires a Security Context Constraints (SCC) to be bound to the target service account prior to installation. All pods will use this SCC. An SCC constrains the actions a pod can perform. Actions such as Host IPC access. Host IPC access is required by our Db2 pod.  

Choose either  
  - Predefined Security Context Constraints `privileged`
  - Custom SCC - If you wish to create a custom SCC, see https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/integration/task/soc_int_preparing-rhocp-cluster.html

## Ingress Controller Configuration

Your Openshift environment may need to be updated to allow network policies to function correctly. To determine if your OpenShift environment is affected, view the default ingresscontroller and locate the property `endpointPublishingStrategy.type`. If it is set to `HostNetwork`, the network policy will not work against routes unless the default namespace contains the selector label.

```
kubectl get ingresscontroller default -n openshift-ingress-operator -o yaml

  endpointPublishingStrategy:
    type: HostNetwork
```
To set the selector label within the default namespace, run the following command:

```
kubectl patch namespace default --type=json -p '[{"op":"add","path":"/metadata/labels","value":{"network.openshift.io/policy-group":"ingress"}}]'
```

## Resources Required

The operators have the following minimum resource requirements.

**Note**: This bare minimum setup will not provide production-like
performance; however, it will be sufficient for demonstration purposes.

- 9 virtual machines in your Kubernetes cluster, assigned as follows:
    - 1 infrustructure node: 4 CPU, 8GB Memory 300GB Disk.
    - 3 master nodes: 8 CPU, 16GB Memory 300GB Disk
    - 5 Worker nodes: 16 CPU, 32GB Memory 600GB Disk
    
- For more information about sizing, see https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/integration/reference/soc_sizing_full.html

- For more information about supported storage, see https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/integration/concept/soc_int_storage_rhocp.html.


# Installing
## Prerequisites


- Create a custom namespace to deploy into:
```
kubectl create namespace <namespace>
```
Where `<namespace>` is the name of the custom namespace that you want to create.


- Create ServiceAccount and add user permissions:
```
oc create serviceaccount noi-service-account -n <namespace>
oc adm policy add-scc-to-user privileged system:serviceaccount:<namespace>:noi-service-account
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "noi-registry-secret"}]}'
```
Where `<namespace>` is the namespace for the project that you are deploying to.

## Installing the operator with the Operator Lifecycle Management console

### Create a Catalog source
  - Within the OpenShift Console (4.3 or higher), select the menu navigation Administration -> Cluster Settings
  - Under the Global Settings tab, select OperatorHub configuration resource
  - Under the Sources tab, click the Create Catalog Source button
  - Provide a catalog source name and the image URL: docker.io/ibmcom
  - If a specific version is required, change the latest tag to the version. Select the Create button.
  - The catalog source appears, after a few minutes refresh the screen to see the number of operators count become 1.
  
### Create Operator
  - Select the menu navigation OperatorHub and search for the NOI operator. Select the operator card, then the Install button.
  - Select a custom namespace to install the operator. Do not use namespaces that are kubernetes or openshift owned like kube-system or default. If you don't already have a project, create a project under the navigation menu Home -> Projects.
  - Select the Subscribe button.
  - Under the navigation menu Operators -> Installed Operators, view the NOI operator. It may take a few minutes to install. View the status at the bottom of the installed NOI operator page which should reflect Succeeded.
  - Determine if installing Cloud (Full NOI) or Hybrid.  Select Create Instance link under the correct custom resource.
  - Use the Yaml or Form view and provide the required values to install NOI. See [Operator Properties](#operator-properties)  Select the Create button.
  - Under the All Instances tab, a NOI formation and NOI (Cloud/Hybrid) instance should appear. View the status of each of those for updates on the installation. When the instances state shows OK then NOI is fully installed and ready.


# Configuration

## Uninstall Cleanup
Delete the operator by running the following commands:

  ```
  oc delete deployment noi-operator
  oc delete role noi-operator
  oc delete rolebinding noi-operator
  oc delete clusterrole noi-operator
  oc delete clusterrolebinding noi-operator
  oc delete serviceaccount noi-operator
  oc delete crd noiformations.noi.ibm.com
  oc delete crd noiconnectionlayers.noi.ibm.com
  oc delete crd noihybrids.noi.ibm.com
  oc delete crd nois.noi.ibm.com

  ```
Search for the Custom Resource Definitions (CRD) created by the Netcool Operations Insight installation and delete them by running the commands:
```
oc get crd | egrep "noi|cem|asm"
oc delete crd <crd-name>
```
For more information, see https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/integration/task/int_uninstalling-noi-on-rhocp.html
  
## Operator Properties

### Full Noi

<!--TABLESTART-->
|Property|Description|
|--------|-----------|
|clusterDomain|"'Use the fully qualified domain name (FQDN) to specify"|
|deploymentType|"Deployment type (trial or production)"|
|entitlementSecret|"Entitlment secret to pull images"|
|helmValuesASM|"To be used as an attribute of your Go Spec object  Example"|
|helmValuesCEM|"To be used as an attribute of your Go Spec object  Example"|
|helmValuesNOI|"Add additional helm values that aren't necessarily within"|
|license.accept|"I have read and agreed to the license agreement"|
||"Advanced properties"|
|advanced.antiAffinity|"To prevent primary and backup server pods from being"|
|advanced.imagePullPolicy|"The default pull policy is IfNotPresent, which causes"|
|advanced.imagePullRepository|"Docker registry that all component images are pulled"|
||"LDAP properties - http://ibm.biz/install_noi_icp"|
|ldap.baseDN|"Configure the LDAP base entry by specifying the base"|
|ldap.bindDN|"Configure LDAP bind user identity by specifying the"|
|ldap.mode|"Choose (standalone) for a built-in LDAP server or (proxy)"|
|ldap.port|"Configure the port of your organization's LDAP server."|
|ldap.sslPort|"Configure the SSL port of your organization's LDAP"|
|ldap.storageClass|"LDAP Storage Class"|
|ldap.storageSize|"LDAP Storage Size"|
|ldap.suffix|"Configure the top entry in the LDAP directory information"|
|ldap.url|"Configure the URL of your organization's LDAP server."|
||"Persistence properties"|
|persistence.enabled|"Enable persistence storage"|
|persistence.storageClassCassandraBackup|"Storage Class Cassandra Backup"|
|persistence.storageClassCassandraData|"Storage Class Cassandra Data"|
|persistence.storageClassCouchdb|"Couchdb Storage Class"|
|persistence.storageClassDB2|"DB2 Storage Class"|
|persistence.storageClassElastic|"Storage Class Elasticsearch"|
|persistence.storageClassImpactGUI|"Impact GUI Storage Class"|
|persistence.storageClassImpactServer|"Impact Server Storage Class"|
|persistence.storageClassKafka|"Storage Class Kafka"|
|persistence.storageClassNCOBackup|"NCOBackup Storage Class"|
|persistence.storageClassNCOPrimary|"NCO Primary Storage Class"|
|persistence.storageClassZookeeper|"Storage Class Zookeeper"|
|persistence.storageSizeCassandraBackup|"Storage Size Cassandra Backup"|
|persistence.storageSizeCassandraData|"Storage Size Cassandra Data"|
|persistence.storageSizeCouchdb|"Couchdb Storage Size"|
|persistence.storageSizeDB2|"DB2 Storage Size"|
|persistence.storageSizeElastic|"Storage Size Elasticsearch"|
|persistence.storageSizeImpactGUI|"Impact GUI Storage Size"|
|persistence.storageSizeImpactServer|"Impact Server Storage Size"|
|persistence.storageSizeKafka|"Storage Size Kafka"|
|persistence.storageSizeNCOBackup|"NCOBackup Storage Size"|
|persistence.storageSizeNCOPrimary|"NCO Primary Storage Size"|
|persistence.storageSizeZookeeper|"Storage Size Zookeeper"|
|"Topology properties"||
|storageClassFileObserver: |"Observer file"|
|storageSizeFileObserver: '5Gi'|"Observer file size"|
|topology.enabled|"Enable Topology"|
|topology.observers|"Topology Observers"|
<!--TABLEEND--> 

### Hybrid

<!--TABLEHYBRIDSTART-->
|Property|Description|
|--------|-----------|
|clusterDomain|"'Use the fully qualified domain name (FQDN) to specify"|
|deploymentType|"Deployment type (trial or production)"|
|entitlementSecret|"Entitlment secret to pull images"|
|helmValuesASM|""*  To be used as an attribute of your Go Spec object  Example"|
|helmValuesCEM|""*  To be used as an attribute of your Go Spec object  Example"|
|helmValuesNOI|"Add additional helm values that aren't necessarily within"|
|license|"I have read and agreed to the license agreement"|
||"Advanced properties"|
|advanced.antiAffinity|"To prevent primary and backup server pods from being"|
|advanced.imagePullPolicy|"The default pull policy is IfNotPresent, which causes"|
|advanced.imagePullRepository|"Docker registry that all component images are pulled"|
||"Dash properties"|
|dash.acceptSelfSigned|"A flag to indicate whether or not to accept self signed"|
|dash.trustedCAConfigMapName|"Config map containing CA certificates to be trusted"|
|dash.url|"URL of the DASH server. i.e. 'protocol://fully.qualified.domain.name:port'"|
|dash.username|"Username for connecting to on-premise DASH."|
||"LDAP properties - http://ibm.biz/install_noi_icp"|
|ldap.baseDN|"Configure the LDAP base entry by specifying the base"|
|ldap.bindDN|"Configure LDAP bind user identity by specifying the"|
|ldap.mode|"Choose (standalone) for a built-in LDAP server or (proxy)"|
|ldap.port|"Configure the port of your organization's LDAP server."|
|ldap.sslPort|"Configure the SSL port of your organization's LDAP"|
|ldap.storageClass|"LDAP Storage Class"|
|ldap.storageSize|"LDAP Storage Size"|
|ldap.suffix|"Configure the top entry in the LDAP directory information"|
|ldap.url|"Configure the URL of your organization's LDAP server."|
||"ObjectServer properties"|
|objectServer.backupHost|"Hostname of the backup ObjectServer."|
|objectServer.backupPort|"Port number of the backup ObjectServer."|
|objectServer.deployPhase|"This setting determines when the OMNIbus CNEA schema"|
|objectServer.primaryHost|"Hostname of the primary ObjectServer."|
|objectServer.primaryPort|"Port number of the primary ObjectServer."|
|objectServer.sslRootCAName|"This is used to specify the CN name for the CA certificate"|
|objectServer.sslVirtualPairName|"Only needed when setting up an SSL connection to an"|
|objectServer.username|"Username for connecting to on-premise ObjectServer."|
||"PersistenceHybrid properties"|
|persistence.enabled|"Enable persistence storage"|
|persistence.storageClassCassandraBackup|"Storage Class Cassandra Backup"|
|persistence.storageClassCassandraData|"Storage Class Cassandra Data"|
|persistence.storageClassCouchdb|"Couchdb Storage Class"|
|persistence.storageClassKafka|"Storage Class Kafka"|
|persistence.storageClassZookeeper|"Storage Class Zookeeper"|
|persistence.storageSizeCassandraBackup|"Storage Size Cassandra Backup"|
|persistence.storageSizeCassandraData|"Storage Size Cassandra Data"|
|persistence.storageSizeCouchdb|"Couchdb Storage Size"|
|persistence.storageSizeDB2|"DB2 Storage Size"|
|persistence.storageSizeKafka|"Storage Size Kafka"|
|persistence.storageSizeZookeeper|"Storage Size Zookeeper"|
||"Topology properties"|
|topology.enabled|"Enable Topology"|
|topology.observers|"Topology Observers"|
<!--TABLEHYBRIDEND-->



### Hybrid Layer
<!--TABLEHYBRIDLAYERSTART--> 
|Property|Description|
|--------|-----------|
|helmValues|"Add additional helm values that aren't necessarily within"|
|noiReleaseName|"Provide the NOI release name to be associated with the"|
||"Provide the ObjectServer properties related to associated"|
|objectServer.backupHost|"Hostname of the backup ObjectServer."|
|objectServer.backupPort|"Port number of the backup ObjectServer."|
|objectServer.deployPhase|"This setting determines when the OMNIbus CNEA schema"|
|objectServer.primaryHost|"Hostname of the primary ObjectServer."|
|objectServer.primaryPort|"Port number of the primary ObjectServer."|
|objectServer.sslRootCAName|"This is used to specify the CN name for the CA certificate"|
|objectServer.sslVirtualPairName|"Only needed when setting up an SSL connection to an"|
|objectServer.username|"Username for connecting to on-premise ObjectServer."|
<!--TABLEHYBRIDLAYEREND--> 
## Storage

You must create storage prior to your installation of Operations Management on OpenShift.

Due to the high I/O bandwidth and low network latency that is required by Operations Management, network-based storage options such as Network File System (NFS) and GlusterFS are not supported. vSphere or local storage are the currently supported storage classes.

For more information on storage requirements and the steps required to set up your storage, see [Netcool Operations Insight Documentation: Preparing for installation](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/integration/task/soc_int_preparing-rhocp-installation.html).


## Limitations

* Platform limited, only supports `amd64` worker nodes.
* StatefulSet are not currently scalable.
* IBM Netcool Operations Insight has been tested on version 4.3 and 4.4 of OpenShift.
* IBM Netcool Operations Insight does not support IBM Kubernetes Service.

## Documentation

Full documentation on deploying the ibm-netcool-prod chart can be found in the [Netcool Operations Insight documentation](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.1/com.ibm.netcool_ops.doc/soc/collaterals/soc_netops_kc_welcome.html).
