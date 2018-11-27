# IBM Blockchain Platform

IBM® Blockchain Platform Community Edition delivers the fundamental components that you need to run a blockchain network on your own infrastructure through IBM Cloud Private (ICP). The components include Hyperledger Fabric runtime Certificate Authorities (CAs), orderers, and peers.

IBM Blockchain Platform Community Edition is a free offering to explore, develop, and test multi-cloud blockchain networks. **Do not use the Community Edition for production.**

## Introduction

This chart enables users to deploy distributed peers or to build blockchain networks by using their existing infrastructure and to connect to their systems of record. The hybrid deployment environment is based on Kubernetes, which allows users to easily deploy IBM Blockchain Platform on many types of platforms, including IBM Z and x86. The IBM Blockchain Platform chart is based on Hyperledger Fabric v1.2.1.

You can choose to run only distributed peers or to build a blockchain network that includes certificate authorities, SOLO ordering service, and peers on your own infrastructure. If you choose to run only peers in your ICP, you can connect the peers to IBM Blockchain Platform Starter and Enterprise Plan networks on IBM Cloud.

The information contained in this README is intended to be used as a quick set of steps for getting started and deploying the helm charts. For a more comprehensive set of instructions including the deployment flow, we recommend you use the [IBM Blockchain for ICP documentation](https://console.bluemix.net/docs/services/blockchain/ibp-for-icp-about.html).

## Chart Details

This chart contains the three fundamental components of a blockchain network: Certificate Authority (CA), orderer, and peer. When you load the Helm Chart, **you can select and install only one component at a time**.

- This chart can deploy CAs, orderers, and peers, which are based on Fabric v1.2.1.
- The Helm Chart allows you to deploy these components into new or existing Persistent Volume Claims (PVCs).

For considerations and more information about the sequence to install these components, see [IBM Blockchain Platform deployment guide](https://console.bluemix.net/docs/services/blockchain/ibp_for_icp_deployment_guide.html).


## Limitations

IBM Blockchain Platform for ICP supports the following operating systems:
- Red Hat Enterprise Linux (RHEL) 7.3, 7.4, 7.5
- Ubuntu 18.04 LTS and 16.04 LTS
- SUSE Linux Enterprise Server (SLES) 12 SP3

This Helm Chart has been validated to run on IBM Cloud Private v3.1.0 clusters that run on Ubuntu Linux by using the following worker nodes and backing storage:
- **IBM Z**: z/VM and z/KVM, which are using NFS.
- **x86**: Linux 64-bit that uses GlusterFS.

Before you begin, ensure that you understand the following **considerations** and **limitations**:

- You are responsible for the health monitoring, security, logging, and resource usage of your components.
- Components that run in ICP are not visible in the Network Monitor of the networks on IBM Cloud.
- Components that run in ICP cannot be addressed by using the Swagger UI in the Network Monitor UI of networks on IBM Cloud.
- This Helm Chart deploys a single instance of CA, orderer, or peer. You can deploy only one component at a time.
- You can deploy multiple components to a single namespace in ICP with different release names.
- Mutual TLS is not supported.

**CA Considerations**
- The CA is compatible with any component at v1.2.1 of Hyperledger Fabric.
- This Helm Chart deploys a single instance of the CA. As it is considered best practice to have a separate CA for each organization, it might be necessary to deploy several CAs. For example, if you plan to deploy one orderer and three peers, you need at least two CAs: one for the orderer organization and another for the peer organization.
- Though you might choose to run a separate MySQL database, this option is not supported with the Helm Chart. The Helm Chart will, however, deploy a MySQLite database inside the CA to handle the database necessities of the CA, which include tracking the number of enrollments per user and any revoked certificates.

**Orderer Considerations**
- The orderer is compatible with any component at v1.2.1 of Hyperledger Fabric.
- This Helm Chart deploys a single instance of the SOLO ordering service, that is, an orderer. Note that it is not possible to deploy more than one SOLO orderer on a channel to make the ordering service highly available. This is one reason why SOLO ordering services are considered to be for development, rather than production environments. You can, however, deploy multiple instances of the SOLO ordering service to different networks (that is, with a separate consortium).

**Peer Considerations**
- The peer can be connected to an IBM Blockchain Platform Starter or Enterprise Plan network, or to a network created with this helm chart.
- You can connect your peer only to blockchain networks that are at Fabric level v1.1 or v1.2.1.
- The database type of the peer must match the database type of your blockchain network, either LevelDB or CouchDB.
- The CouchDB Fauxton interface is not available on the peer.
- [Gossip](https://console.bluemix.net/docs/services/blockchain/glossary.html#gossip) for peers is not currently supported. This implies that Fabric features that depend on gossip, such as [private data](https://hyperledger-fabric.readthedocs.io/en/release-1.2/private-data-arch.html "private data") and [service discovery](https://hyperledger-fabric.readthedocs.io/en/release-1.2/discovery-overview.html "service discovery"), are also not supported.


## Prerequisites

- Install an [IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/kc_welcome_containers.html) cluster at version 3.1.0 and the [IBM Cloud Private CLI 3.1.0](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/manage_cluster/install_cli.html).
- Review the storage requirements for your PVC in the **Storage** section of this README.
- Download the Helm Chart file of IBM Blockchain Platform for ICP and [import it in the ICP cluster](https://console.bluemix.net/docs/services/blockchain/howto/helm_install_icp.html).
- Create Kubernetes secret object in ICP for the component to install. For more information, see [Create CA Kubernetes secret object](https://console.bluemix.net/docs/services/blockchain/howto/CA_deploy_icp.html#admin-secret), [Create orderer Kubernetes secret object](https://console.bluemix.net/docs/services/blockchain/howto/orderer_deploy_icp.html#create-msp-secret-object), or [Create peer Kubernetes secret object](https://console.bluemix.net/docs/services/blockchain/howto/peer_deploy_icp.html#creating-msp-secret-object).
- If you want to run this Helm Chart on an ICP cluster without Internet connectivity, you need to create archives on an Internet-connected machine before you can install the archives on your the ICP cluster. For more information, see [Adding featured applications to clusters without Internet connectivity](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/app_center/add_package_offline.html). Note that you can find the specification file `manifest.yaml` under the `ibm-blockchain-platform-dev/ibm_cloud_pak` directory in the Helm Chart.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
- Predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)
- Custom PodSecurityPolicy definition:
  ```
  apiVersion: extensions/v1beta1
  kind: PodSecurityPolicy
  metadata:
    name: ibm-blockchain-platform-psp
  spec:
    hostIPC: false
    hostNetwork: false
    hostPID: false
    privileged: true
    allowPrivilegeEscalation: true
    readOnlyRootFilesystem: false
    seLinux:
      rule: RunAsAny
    supplementalGroups:
      rule: RunAsAny
    runAsUser:
      rule: RunAsAny
    fsGroup:
      rule: RunAsAny
    requiredDropCapabilities:
    - ALL
    allowedCapabilities:
    - NET_BIND_SERVICE
    - CHOWN
    - DAC_OVERRIDE
    - SETGID
    - SETUID
    volumes:
    - '*'
  ```
- Custom ClusterRole for the custom PodSecurityPolicy:
  ```
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    annotations:
    name: ibm-blockchain-platform-clusterrole
  rules:
  - apiGroups:
    - extensions
    resourceNames:
    - ibm-blockchain-platform-psp
    resources:
    - podsecuritypolicies
    verbs:
    - use
  - apiGroups:
    - ""
    resources:
    - secrets
    verbs:
    - create
    - delete
    - get
    - list
    - patch
    - update
    - watch
  ```
- Custom ClusterRoleBinding for the custom ClusterRole:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
     name: ibm-blockchain-platform-clusterrolebinding
    roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: ClusterRole
     name: ibm-blockchain-platform-clusterrole
    subjects:
    - kind: ServiceAccount
      name: default
      namespace: default
    ```

### Prereq configuration scripts can be used to create and delete required resources
Find the following scripts in `pak_extensions/prereqs` directory of the downloaded archive.

- **createSecurityClusterPrereqs.sh** to create the PodSecurityPolicy and ClusterRole for all releases of this chart.
- **createSecurityNamespacePrereqs.sh** to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.  
  Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`
- **deleteSecurityClusterPrereqs.sh** to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
- **deleteSecurityNamespacePrereqs.sh** to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.  
  Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`

## Resources Required
Ensure that your ICP system meets the minimum hardware resource requirements:

| Component | vCPU | RAM | Disk for data storage |
|-----------|------|-----|-----------------------|
| CA | 1 |192 MB | 1 GB |
| Orderer | 2 | 512 MB | 100 GB with the ability to expand when the data grows. |
| Peer | 2 | 2 GB | 50 GB with the ability to expand when the data grows. |
| CouchDB for Peer | 2| 2 GB |50 GB with the ability to expand when the data grows. |

**Notes:**
- A vCPU is a virtual core that is assigned to a virtual machine or a physical processor core if the server is not partitioned for virtual machines. You need to consider vCPU requirements when you decide the virtual processor core (VPC) for your deployment in ICP. VPC is a unit of measurement to determine the licensing cost of IBM products. For more information about scenarios to decide VPC, see [Virtual processor core (VPC)](https://www.ibm.com/support/knowledgecenter/en/SS8JFY_9.2.0/com.ibm.lmt.doc/Inventory/overview/c_virtual_processor_core_licenses.html).
- These minimum resource levels are sufficient for testing and experimentation. For an environment with a large volume of transactions, it is important to allocate a sufficiently large amount of storage. For example, 250 GB for your peer and 500 GB for your orderer. The amount of storage to use will depend on the number of transactions and the number of signatures that are required from your network. If you are about to exhaust the storage on your peer or orderer, you must deploy a new peer or orderer with a larger file system and let it sync via your other components on the same channels.


## Installing the Chart

1. Log in to the ICP cluster and click the **Catalog** link in the upper right corner.
2. Click **Blockchain** in the left navigation panel and click the `ibm-blockchain-platform-dev` tile on the right. View the Readme file that includes information about installing and configuring the Helm chart.
3. Click **Configuration** tab at the top of the panel or click the **Configure** button in the lower right corner.
4. Complete the configuration for the network component that you want to install. For more information about the configuration parameters, see the **Configuration** section below.  
 **Although the Helm Chart UI says "To install this chart, no configuration is needed", you DO NEED to configure certain parameters to deploy a component.**
5. Click **Install**.

**Note:** You can install only one component at a time. If you plan to build a blockchain network with all these components, you need to install a CA before you install an orderer and a peer. For more information about deploying these components, see [IBM Blockchain Platform for ICP deployment guide](https://console.bluemix.net/docs/services/blockchain/ibp_for_icp_deployment_guide.html).

## Configuration

Select the check box of the component to install and complete the parameter fields. The following tables list the configuration parameters for each component and the default values.

### General and global configuration parameters
You need to complete the following parameter configuration for either component to install.

|  Parameter     | Description    | Default  | Required |
| --------------|-----------------|-------|------- |
| `Helm release name`| The name of your helm release. | none | yes |
| `Target namespace`| Choose the Kubernetes namespace to install the Helm Chart. | none | yes |
||||
| `Service account name`| Enter the name of the [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) that you will use to run the pod. | default | no |

### CA configuration parameters
*Description on CA configuration parameters is also available in [IBM Blockchain Platform documentation](https://console.bluemix.net/docs/services/blockchain/howto/CA_deploy_icp.html#icp-ca-configuration-parms).*

|  Parameter     | Description    | Default  | Required |
| --------------|-----------------|-------|------- |
| `Install CA`| Select to install a CA | Unchecked | no |
| `CA name`| Specify a name to use for the Certificate Authority. **Important:** Make a note of this value. It is required later when you configure an orderer or peer. | SampleOrgCA | yes |
| `CA worker node architecture`| Select your cloud platform architecture (ADM64 or S390X). | AMD64 | yes|
| `CA database type`| The type of database to store CA data. Only SQLite is supported. | SQLite | yes |
| `CA data persistence enabled` | If checked, data will be available when the container restarts. Otherwise, all data will be lost in the event of a failover or pod restart. | checked | no |
| `CA use dynamic provisioning` | Check to enable dynamic provisioning for storage volumes. | checked | no |
| `CA storage class name`| Specify a unique storage class name. Otherwise, the default storage class in the cluster is used. | none | no |
| `CA existing volume claim`| Specify the name of an existing Volume Claim and leave all other fields blank. | none | no |
| `CA selector label`| Specify the [Selector label](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) for your PVC. | none | no |
| `CA selector value`| Specify the [Selector value](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) for your PVC. | none | no |
| `CA storage access mode`| Specify the storage [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for the PVC. | ReadWriteMany | yes |
| `CA volume claim size`| Choose the size of disk to use. | 2Gi | yes |
| `CA image repository`| Location of the CA Helm Chart.  | ibmcom/ibp-fabric-ca | yes |
| `CA Docker image tag`| Value of the tag that is associated with the CA image. This field is autofilled to the image version. Do not change it.| 1.2.1 | yes |
| `CA service type` | This field specifies whether [external ports should be exposed](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types) on the CA. Select NodePort to expose the ports externally (recommended) and select ClusterIP to not expose the ports. LoadBalancer and ExternalName are not supported in this release. | NodePort | yes |
| `CA secret (Required)`| Enter the name of the Kubernetes secret object that you created for your `ca-admin-name` and `ca-admin-password`. | none | yes |
| `CA CPU request`| Specify the minimum number of CPUs to allocate to the CA. | 1 | yes |
| `CA CPU limit`| Specify the maximum number of CPUs to allocate to the CA. | 2 | yes |
| `CA memory request`| Specify the minimum amount of memory to allocate to the CA. | 1Gi | yes |
| `CA memory limit`| Specify the maximum amount of memory to allocate to the CA. | 4Gi | yes |
| `CA TLS instance name`| Specify a name of the CA TLS instance that will be used to enroll an orderer or peer. | none | yes |
| `CSR common name`| Specify the Common Name (CN) that the generated CA root cert will present when contacted. | tlsca-common | yes |
| `Proxy IP`| Enter the [Proxy Node IP for the cluster](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/installing/install_proxy.html) where the CA is deployed. | 127.0.0.1 | no |

### Orderer configuration parameters
*Description on orderer configuration parameters is also available in [IBM Blockchain Platform documentation](https://console.bluemix.net/docs/services/blockchain/howto/orderer_deploy_icp.html#icp-orderer-configuration-parms).*

|  Parameter     | Description    | Default  | Required |
| --------------|-----------------|-------|------- |
| `Install Orderer`| Select to install an orderer. | unchecked | no |
| `Orderer worker node architecture`| Select your ICP worker node architecture (AMD64 or S390X). | Autodetected architecture based on your master node. | yes |
| `Orderer configuration`| You can customize the configuration of the orderer. This information will overwrite the content in the orderer configuration file, that is `orderer.yaml`.  *Waiting on additional instructions from dev*  | none | no |
| `Organization MSP secret (Required)`| Specify the name of the secret object that contains organization MSP certificates and keys. | none | no |
| `Orderer data persistence enabled` | Data will be available when the container restarts. If unchecked, all data will be lost in the event of a failover or pod restart. | checked | no |
| `Orderer use dynamic provisioning` | Check to enable dynamic provisioning for storage volumes. | checked | no |
| `Orderer image repository` | Location of the Orderer Helm Chart. This field is autofilled to the installed path. If you are using the Community Edition and don't have internet access, change this field to the location where you downloaded the Fabric orderer image. | ibmcom/ibp-fabric-orderer | no |
| `Orderer Docker image tag`| Autofilled to the version of the Orderer image. | 1.2.1 | yes |
| `Orderer consensus type`| The consensus type of the ordering service. | SOLO | yes |
| `Orderer organization name`| Specify the name you would like to use for the orderer organization. | none | no |
| `Orderer Org MSP ID`| Specify the name you want to use for the MSP ID of the orderer organization. | none | no |
| `Orderer storage class name`| Specify a storage class name for the orderer. | none | no |
| `Orderer existing volume claim`| Specify the name of an existing Volume Claim and leave all other fields blank. | none | no |
| `Orderer selector label`| Specify the [Selector label](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) for your PVC. | none | no |
| `Orderer selector value`| Specify the [Selector value ](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) for your PVC. | none | no |
| `Orderer storage access mode`| Specify the storage [access mode ](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for the PVC. | ReadWriteMany | yes |
| `Orderer volume claim size`| Choose the size of disk to use, which must be at least 2 Gi. | 8 Gi | yes |
| Orderer service type` | This field specifies whether external ports should be exposed on the orderer. Select NodePort to expose the ports externally (recommended), and ClusterIP to expose the ports on a cluster-internal IP. | NodePort | yes |
| `Orderer CPU request`| Specify the minimum number of CPUs to allocate to the Orderer. | 1 | yes |
| `Orderer CPU limit`| Specify the maximum number of CPUs to allocate to the Orderer. | 2 | yes |
| `Orderer memory request`| Specify the minimum amount of memory to allocate to the Orderer. | 1Gi | yes |
| `Orderer memory limit`| Specify the maximum amount of memory to allocate to the Orderer. | 2Gi | yes |

### Peer configuration parameters
*Description on peer configuration parameters is also available in [IBM Blockchain Platform documentation](https://console.bluemix.net/docs/services/blockchain/howto/peer_deploy_icp.html#icp-peer-configuration-parms).*

|  Parameter     | Description    | Default  | Required |
| --------------|-----------------|-------|------- |
| `Install Peer` | Select to install a peer|unchecked |no |
| `Peer worker node architecture`| Select your cloud platform architecture (AMD64 or S390x)| AMD64 | yes |
| `Peer image repository`| Location of the Peer Helm Chart. This field is autofilled to the installed path. If you are using the Community Edition and don't have internet access, it should match the directory where you downloaded the Fabric peer image. | ibmcom/ibp-fabric-peer | yes |
| `Peer Docker image tag`| Autofilled to the version of the Peer image. | 1.2.1 | yes |
| `Peer configuration`|You can customize the configuration of the peer. This information will overwrite the content in the peer configuration file, that is `core.yaml`.|none|no|
| `Peer configuration secret (Required)`|Name of the [Peer configuration secret](#peer-config-secret) you created in ICP. |none|yes|
|`Organization MSP (Required)`|This value can be found in Network Monitor (IBP UI) by clicking Remote Peer Configuration on the Overview screen. If not connecting to an IBP network, you can create a new Organization MSP value such as 'org1' or specify an existing Organization MSP that the peer will be part of.  |none|yes|
|`Peer service type`|Used to specify whether [external ports should be exposed](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types) on the peer. Select NodePort to expose the ports externally (recommended), and ClusterIP to not expose the ports. LoadBalancer and ExternalName are not supported in this release. |NodePort|yes|
| `State database`| The [state database](https://console.bluemix.net/docs/services/blockchain/glossary.html#state-database) used to store your channel ledger. The peer needs to use the same database as your [blockchain network](https://console.bluemix.net/docs/services/blockchain/v10_dashboard.html#network-preferences). | none | yes |
|`CouchDB image repository`| Applies only if CouchDB is selected as the ledger database. This field is autofilled to the installed path. If you are using the Community Edition and don't have internet access, it should match the directory where you downloaded the Fabric CouchDB image.| ibmcom/ibp-couchdb | yes |
| `CouchDB Docker image tag`| Applies only if CouchDB is selected as the ledger database. Autofilled to the version of the CouchDB image. | 0.4.10 | yes |
| `Peer Data persistence enabled`| Enable the ability to persist data after cluster restarts or fails. See [storage in Kubernetes  ](https://kubernetes.io/docs/concepts/storage/) for more information.  *If unchecked, all data will be lost in the event of a failover or pod restart.* | checked | no |
| `Peer use dynamic provisioning`| Check to enable dynamic provisioning for storage volumes. | checked | no |
| `Peer persistent volume claim`| For new claim only. Enter a name for your new Persistent Volume Claim (PVC) to be created. | my-data-pvc | no |
| `Peer storage class name`| Specify a storage class name for the peer. | Blank if creating a new PVC; otherwise, specify the storage class that is associated with the existing PVC. | no |
| `Peer existing volume claim`| Specify the name of an existing Volume Claim and leave all other fields blank. | new claim name | no |
| `Peer selector label`| Specify the [Selector label](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ ) for your PVC.| default | no |
| `Peer selector value`| Specify the [Selector value](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ ) for your PVC. | default | no |
| `Peer storage access mode`| Specify the storage [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for the PVC.  | ReadWriteMany| no |
| `Peer volume claim size`| Size of the Volume Claim, must be larger than 2Gi. | 8Gi  | yes |
| `State database persistent volume claim`| For new claim only. Enter a name for your new Persistent Volume Claim (PVC) to be created. | statedb-pvc | no |
| `State database storage class name`| Specify a storage class name for state database. | none | no |
| `State database existing volume claim`| Specify the name of an existing Volume Claim and leave all other fields blank. | none | no |
| `State database selector label`| Specify the [Selector label](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) for your PVC| none | no |
| `State database selector value`| Specify the [Selector value](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) for your PVC | none | no |
| `State database storage access mode`| Specify the storage [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for the PVC. | ReadWriteMany| no |
| `State database volume claim size`| Choose the size of disk to use. | 8Gi | yes |
| `CouchDB - Data persistence enabled`| For CouchDB container, ledger data will be available when the container restarts. *If unchecked, all data will be lost in the event of a failover or pod restart.*| checked | no |
| `CouchDB - Use dynamic provisioning`| For CouchDB container to use Kubernetes dynamic storage.| checked | no |
| `Peer CPU request` | Minimum number of CPUs to allocate to the peer. | 1 | yes |
| `Peer CPU limit` | Maximum number of CPUs to allocate to the peer.| 2 | yes |
| `Peer Memory request` | Minimum amount of memory to allocate to the peer. | 1Gi | yes |
| `Peer Memory limit` | Maximum amount of memory to allocate to the peer. | 4Gi | yes |
| `CouchDB CPU request` | Minimum number of CPUs to allocate to CouchDB.| 1 | yes |
| `CouchDB CPU limit` | Maximum number of CPUs to allocate to CouchDB. | 2 | yes |
| `CouchDB Memory request` | Minimum amount of memory to allocate to CouchDB.| 1Gi | yes |
| `CouchDB Memory limit` | Maximum amount of memory to allocate to CouchDB. | 4Gi | yes |

## Verifying the installation
After you complete the configuration parameters and click the **Install** button, click the **View Helm Release** button to view your deployment. If it was successful, you should see the value 1 in the `DESIRED`, `CURRENT`, `UP TO DATE`, and `AVAILABLE` fields in the Deployment table. You may need to click refresh and wait for the table to be updated.

## Storage

- You need to determine the storage that your components will use. If you use the default settings, the Helm Chart will create a new Persistent Volume claim with the name of `my-data-pvc` for your component data. If you deploy a peer, it will create another Persistent Volume claim with the name of `statedb-pvc` for your state database.
- If you do not want to use the default storage settings, ensure that a *new* storageClass is set up during the ICP installation or the Kubernetes system administrator needs to create a storageClass before you deploy.
- You can choose to deploy the components on either the AMD64 or S390X platforms. However, be aware that [Dynamic provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/) is available for only AMD64 nodes in ICP. If your cluster includes a mix of S390X and AMD64 worker nodes, dynamic provisioning cannot be used.
- If dynamic provisioning in not used, [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) must be created and set up with labels that can be used to refine the Kubernetes Persistent Volume Claim (PVC) bind process.
- If you use NFS v2/v3 Persistent Volumes, you must enable the **NFS status monitor for NFSv2/v3 Filesystem Locks** module, which is also known as **rpc-statd**, on the host system where the NFS file system exists. This module allows your NFS file system to check for exclusive locks on files that other processes hold. Run the following commands to enable this module:
  ```
  sudo systemctl enable rpc-statd
  sudo systemctl start rpc-statd
  ```

## Operating your components
After you install the fundamental components in ICP, you can make them operational by completing some operational steps.

### Certificate authority
After you install IBM Blockchain Platform CA in ICP, a configmap is created with default environment variables settings. You can then change or add environment variables for the CA server to configure its behavior. For more information about CA server configuration parameters, see [Fabric CA server documentation](https://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html#fabric-ca-server).

After you configure the configmap, you need to restart the CA server before the changes take effect. To restart the CA server, you can delete the Fabric CA server POD. ICP will create a new POD that reflects the changes.

For instructions on operating your CA, see
[IBM Blockchain Platform documentation](https://console.bluemix.net/docs/services/blockchain/howto/CA_operate.html#ca-operate).

### SOLO ordering service
IBM Blockchain Platform Orderer in ICP deploys a SOLO ordering service for your network. As a general rule, orderer admins are responsible for:

- Completing the orderer-specific parts of the channel configuration. For more information about the permissions that are involved in changing a channel configuration and where the orderer admin fits in, see documentation on channel configurations.
- Boostrapping and maintaining orderers.

However, with a SOLO ordering service, that is, only one orderer node in the network, bootstrapping other orderers is not valid. Maintenance of the orderer can be handled by the orderer admin, though if access mechanisms leveraging ssh logins (as an example) are leverage, even that is not necessary.

### Peer
You can choose to deploy only peers or to build a complete Fabric network in your ICP. After you install an IBM Blockchain Platform peer in ICP, you can either connect it to an IBM Blockchain Platform Starter or Enterprise Plan network or add it to your network in ICP.

For instructions on operating your peer, see
[IBM Blockchain Platform documentation](https://console.bluemix.net/docs/services/blockchain/howto/peer_operate_icp.html#peer-operate_icp).

## Support

IBM Blockchain Platform does not provide support for the IBM Blockchain Platform Community Edition.

If you encounter issues that are related to your blockchain components, you can make use of free blockchain developer resources and support forums and get help from IBM and the Fabric community. For more information, see [blockchain resources and support forums](https://console.bluemix.net/docs/services/blockchain/ibmblockchain_support.html#resources).

For issues that are related to IBM Cloud Private, you can take advantage of both free digital support and paid support [offered by ICP](https://www.ibm.com/developerworks/community/blogs/fe25b4ef-ea6a-4d86-a629-6f87ccf4649e/entry/Learn_more_about_IBM_Cloud_Private_Support?lang=en_us).

## Documentation

- [IBM Blockchain Platform documentation](https://console.bluemix.net/docs/services/blockchain/index.html)
- [IBM Blockchain Platform for ICP documentation](https://console.bluemix.net/docs/services/blockchain/ibp-for-icp-about.html#overview)
