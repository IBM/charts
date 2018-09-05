# IBM Blockchain Platform Remote Peer (Beta)

## Introduction

IBM® Blockchain Platform Remote Peer for IBM Cloud Private (ICP) Beta enables you to run peers on your own infrastructure. Members of the IBM Blockchain Platform can install the remote peer through ICP and then connect the peer to Starter or Enterprise Plan networks on the platform. The IBM Blockchain Platform and remote peers are based on Hyperledger Fabric. This Beta edition of the IBM Blockchain Remote Peer offering is meant for exploration, development, and testing.

IBM Blockchain Platform Remote Peer for IBM Cloud Private helps blockchain network members grow their networks, use their existing infrastructure, and connect to their systems of record. The hybrid deployment environment is based on Kubernetes, which allows users to easily deploy IBM Blockchain Platform on s390x and x86 platform types.

**To operate a remote peer, you must have an organization that belongs to an existing Starter Plan or Enterprise Plan network on IBM Blockchain Platform. If you are not a member of any blockchain network, you need to create or join a network. For more information, see [Creating a network](https://console.bluemix.net/docs/services/blockchain/get_start.html#creating-a-network) or [Joining a network](https://console.bluemix.net/docs/services/blockchain/get_start.html#joining-a-network).**

## Chart Details

&#45; This chart deploys an IBM Blockchain Platform remote peer.  
&#45; The chart deploys an instance of CouchDB or LevelDB as the peer's state database.  
&#45; The chart allows you to deploy a new Persistent Volume Claim for peer storage.  
&#45; The chart allows you to deploy a new Persistent Volume Claim for database storage.

## Pricing and Support

IBM Blockchain Platform Remote Peer on IBM Cloud Private is a free Beta edition that is suitable for evaluation and experimentation. You can access and download the free Beta edition from [github](https://github.com/IBM/charts/tree/master/stable/ibm-blockchain-platform-remote-peer).

**Note:** To operate a remote peer, you must have an organization that belongs to a Starter Plan or Enterprise Plan network on IBM Blockchain Platform. This implies that you or another member in the network must pay the IBM Blockchain [membership fee](https://console.bluemix.net/docs/services/blockchain/howto/pricing.html#key-elements-of-pricing) for your organization. For more information about paying fees, see [Paying mode](https://console.bluemix.net/docs/services/blockchain/howto/paying_mode.html).

The Beta edition of the IBM Blockchain Platform Remote Peer offering is meant for exploration, development, and testing. **This Beta edition is not intended for production usage.** IBM Blockchain does not provide support for this offering. If you encounter any issues that are related to your remote peer, see [blockchain resources and support forums](https://console.bluemix.net/docs/services/blockchain/v10_dashboard.html#support-forums).

If you are encountering issues relating to IBM Cloud Private, you can take advantage of both free digital support and paid support [offered by  ICP](https://www.ibm.com/developerworks/community/blogs/fe25b4ef-ea6a-4d86-a629-6f87ccf4649e/entry/Learn_more_about_IBM_Cloud_Private_Support?lang=en_us).

## Limitations 	

This Helm Chart has been validated to run on IBM Cloud Private clusters using the following worker nodes and backing storage.

&#45; **IBM Z**: z/VM using NFS  
&#45; **amd64**: xKVM using NFS, GlusterFS

An IBM Blockchain Platform remote peer does not have the full functionality or support of peers hosted on IBM Blockchain Platform. Before you begin, ensure that you understand the following **restrictions** and **limitations**:

&#45; You must be a member of a Starter Plan or Enterprise Plan network on the IBM Blockchain Platform to connect a remote peer. The remote peer leverages the API endpoints, Hyperledger Fabric CAs, and Ordering Service of the IBM Blockchain Platform Plan network to operate.  
&#45; Remote peers are not visible in the Network Monitor UI on IBM Blockchain Platform. You need to manage remote peers, such as adding them to channels, installing chaincode, and viewing peer status, locally by using the SDKs or CLI commands.  
&#45; Remote peers cannot be addressed using the Swagger UI in the Network Monitor UI on IBM Blockchain Platform.
&#45; You are responsible for the management of health monitoring, security, logging, and resource usage of your remote peers.
&#45; You can connect remote peers only to blockchain networks that are at Hyperledger Fabric v1.1 level.  
&#45; The state database type of the remote peers must be the same as the database type that is used on the blockchain network. The database type can be LevelDB or CouchDB.   
&#45; Gossip for remote peers is not currently supported.  
&#45; This helm chart deploys a single instance of the remote peer. It is recommended that you install at least two
remote peers for High Availability.  
&#45; You can deploy multiple remote peers to a single name space in ICP with different deployment names.  

## Prerequisites

**IBM Cloud Private**

&#45; You need an [IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.3/kc_welcome_containers.html) cluster at version 2.1.0.3. If you are using the remote peer for development, test, or experimentation, you can install the [IBM Cloud Private Community Edition](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/installing/install_containers_CE.html) for free.  
&#45; You will need to install the IBM Cloud Private CLI [2.1.0.3](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.3/manage_cluster/install_cli.html) to install and operate the remote peer.  
&#45; Review the storage requirements for your PVC in the **Storage** section of this README.

**IBM Blockchain Platform**

Your organization needs to be added to a channel on the blockchain network before you can join the channel with your remote peer.

  &#45; You can start a new channel for the remote peer. As the channel initiator, you can automatically include your organization during [channel creation](https://console.bluemix.net/docs/services/blockchain/howto/create_channel.html#creating-a-channel). Note that you need to have at least one peer on IBM Blockchain Platform before you can create a channel in the Network Monitor UI.  

  &#45; Another member of the blockchain network can also add your organization to an existing channel using a [channel update](https://console.bluemix.net/docs/services/blockchain/howto/create_channel.html#updating-a-channel). A member of the channel with peers on IBM Blockchain Platform can use the Network Monitor UI to add your organization to the channel even if you do not host any peers on the platform.

**Retrieving network endpoint information**

*These instructions are also available in the [IBM Blockchain Platform documentation](https://console.bluemix.net/docs/services/blockchain/howto/remote_peer_icp.html#network-endpoints).*

You need to provide the API endpoints of your network to your remote peer during configuration. These endpoints allow a remote peer to find and connect to the network on IBM Blockchain Platform. On the **Overview** screen of your Network Monitor, click the **Remote Peer Configuration** button.

A pop-up window opens and displays the values of the following fields. Save the values from the following fields and you need to use them when you configure the remote peer.

&#45; **Network ID**  
&#45; **Organization MSP**  
&#45; **Certificate Authority (CA) Name**  
&#45; **Certificate Authority (CA) URL**  
&#45; **Certificate Authority (CA) TLS Certificate**  

You can copy and paste the fields individually, or save them as a JSON file by clicking the **Download** button. **Note** that if you download the information in JSON, you need to convert the TLS certificate into PEM format before you provide it to the remote peer. You can use the CLI to convert the certificate into PEM format by issuing the `echo -e "<CERT>" > admin.pem` command.

**Registering a remote peer**

*These instructions are also available in the [IBM Blockchain Platform documentation](https://console.bluemix.net/docs/services/blockchain/howto/remote_peer_icp.html#register-peer).*

You need to add a new peer identity to your network on the IBM Blockchain Platform before the remote peer can join the network. Complete the following steps to enroll and register a remote peer.

1. (1) Log in to the Network Monitor of your network on IBM Blockchain Platform. On the "Certificate Authority" screen of your Network Monitor, you can view all the identities that have been registered with the network, such as your admin or client applications.

2. (2) Click the **Add User** button at the top of the panel. This will open up a pop up screen that will allow you register your remote peer to the network after filling out the fields below. Save the username and password for when you configure your peer.
  &#45; **ID:** The use name of your peer, which is referred to as your `enroll ID` when you configure your peer. **Save this value** for future usage when deploying the remote peer.  
  &#45; **Secret:** The password of your peer, which is referred to as your `enroll Secret` when you configure your peer. **Save this Value** for future usage when deploying the remote peer.  
  &#45; **Type:** Select `peer` for this field.  
  &#45; **Affiliation:** This is the affiliation under your organization, `org1` for example, that your remote peer will belong to. Select an existing affiliation from the drop down list or type in a new one.  
  &#45; **Maximum Enrollments:** You can use this field to limit the number of times you can enroll or generate certificates using this identity. If not specified, the value defaults to unlimited enrollments.  

  After you fill in the fields, click **Submit** to register the remote peer. The registered peer is then listed in the table as an identity on the network.

## Resources Required
Ensure that your ICP system meets the minimum hardware resource requirements:

&#45; 2x vCPU  
&#45; 2 GB RAM  
&#45; 4 GB space for chaincode  
&#45; 10 GB space for the ledger with ability to grow as the ledger expands

## Installing the Chart

1. (1) Download the package from [github](https://github.com/IBM/charts/tree/master/repo/stable/ibm-blockchain-platform-remote-peer-0.9.0.tgz).

2. (2) Login to your ICP Cluster.

   ```
   bx pr login -a https://<cluster_CA_domain>:8443 --skip-ssl-validation
   ```

3. (3)  Configure the kubectl CLI.
     1. (3.1) Login in to the IBM Cloud Private UI.  
     2. (3.2) Go to the upper right hand corner of the UI, click on the `User Name` > `Configure client`.  
     3. (3.3) Copy and paste the configuration information run the commands.   

4. (4) Before you install the Helm Chart, ensure the [Docker CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/manage_images/configuring_docker_cli.html) is configured. After you configure the Docker CLI, access the image registry on your cluster by using the following command:
   ```
   docker login <cluster_CA_domain>:8500
   ```

5. (5) In the directory that you store your Helm Chart, run the following command with the CLI to install the Helm Chart on your ICP cluster. Replace `<helm_chart_from_github>` with the `.tgz` file downloaded from the github repository.

   ```
    bx pr load-helm-chart --archive <helm_chart_from_github> --clustername <cluster_name>
   ```

## Configuration 	
*Description on configuration parameters is also available in the [IBM Blockchain Platform documentation](https://console.bluemix.net/docs/services/blockchain/howto/remote_peer_icp.html#icp-configuration-parms).*

After you enroll and register your peer identity in the Network Monitor UI, you can configure and install your remote peer
using the ICP console.

### Configuration parameters

You need to provide the information that your remote peer needs to connect to the network on IBM Blockchain Platform.
The following table lists the configurable parameters of Helm Chart and their default values.

|  Parameter     | Description    | Default  | Required |
| --------------|-----------------|-------|------- |
|**Configuration** | **Configure Release name and Target namespace for your remote peer** |  ||
| `Release name`| The name of your helm release | none | yes |
| `Target namespace`| The Kubernetes namespace | default | yes |
| | | |
|**Cluster configuration** |**Cluster configuration information** | ||
| `Worker node architecture`| Select your cloud platform architecture (amd64 or S390x)| Autodetected architecture based on your master node | yes |
| `Image`| Path to the helm chart | Autofilled to the installed path, do not change this value | yes |
| | | |
|**Blockchain network** | **The network configuration information required for the remote peer**| | |
| `Network ID`| Value of the network id found in your IBM Blockchain Platform UI. Click the `Remote Peer Configuration` button on the Overview panel and copy and paste that information here.| none | yes |
| `Organization MSP`| Value of the organization MSP id found in your IBM Blockchain Platform UI. Click the `Remote Peer Configuration` button on the Overview panel and copy and paste that information here.|none|yes|
| `Certificate Authority (CA) Name`| Value of the CA Name found in your IBM Blockchain Platform UI. Click the `Remote Peer Configuration` button on the Overview panel and  copy and paste that information here.|none|yes|
| `Certificate Authority (CA) URL`| Value of the CA URL found in your IBM Blockchain Platform UI. Click the `Remote Peer Configuration` button on the Overview panel and  copy and paste that information here. | none | yes |
| `Certificate Authority (CA) TLS Certificate` | CA TLS certificate string in your IBM Blockchain Platform UI. Click the `Remote Peer Configuration` button on the Overview panel and copy and paste that information here. | none | yes |
| | | |
|**Remote peer identity** | **The enroll id and secret used to register your remote peer**| | |
| `Peer enroll ID`| This in the Enroll ID you entered in your IBM Blockchain Platform UI Certificate Authority panel. | none | yes |
| `Peer enroll secret`| This in the Enroll Secret you entered in your IBM Blockchain Platform UI Certificate Authority panel.| none | yes |
| | | |
|**Remote peer database** | **Ledger database type**| | |
| `Ledger database`| The database used to store your channel ledger. This database must be the same type as your IBM Blockchain Platform network. It is visible in the application by clicking your User name > Network Preferences| none | yes |
| `CouchDB image`| Only applies if CouchDB was selected as the ledger database. Autofilled to the installed path, do not change  | yes |
|**Data persistence** | Enable the ability to persist data after cluster restarts or fails. See [storage in Kubernetes](https://kubernetes.io/docs/concepts/storage/) for more information. | | |
| `Data persistence enabled`| State data will be available when the container restarts. *If unchecked, all data will be lost in the event of a failover or pod restart.*| checked | no |
| `Use dynamic provisioning`| Use Kubernetes dynamic storage.| checked | no |
| | | |
|**Persistent volume configuration** | **Persistent Volume Claim to be used by your peer** |  |  |
| `Persistent volume claim`| Enter a name for your new Persistent Volume Claim (PVC) which will be created| my-data-pvc | no |
| `Storage class name`| Chose storage class name | blank if creating a new PVC, otherwise specify the storage class associated with the existing PVC | no |
| `Existing volume claim`| Specify the name of an existing Volume Claim and leave all other fields blank| new claim name | no |
| `Storage access mode`|Specify the storage [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for the PVC. | ReadOnlyMany| no |
| `Selector label`| [Selector label](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) for your PVC| default | no |
| `Selector value`| [Selector value](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) for your PVC | default | no |
| `Volume claim size`| Size of the Volume Claim, must be larger than 2Gi | 8Gi  | yes |
| | | |
|**State database data persistence** | **Persist data after your container is restarted or fails. See [storage in Kubernetes](https://kubernetes.io/docs/concepts/storage/) for more information.** | | |
| `Data persistence enabled`| Ledger data will be available when the container restarts. *If unchecked, all data will be lost in the event of a failover or pod restart.*| checked | no |
| `Use dynamic provisioning`| Use Kubernetes dynamic storage.| checked | no |
| | | | |
|**State database persistent volume configuration** |**Persistent Volume Claim to be used for the state database. See [Storage in Kubernetes](https://kubernetes.io/docs/concepts/storage/) for more information.** |||
| `Persistent volume claim`| Enter a name or use the default for your new state database Persistent Volume Claim which will be created| statedb-pvc | no |
| `State database storage class name`|Choose storage class name| none | no |
| `State database existing volume claim`| To use an existing volume claim, enter the pvc name and leave all other fields blank | none | no |
| `State database storage access mode`| Specify the storage [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for the PVC. | ReadOnlyMany| no |
| `Selector label`| [Selector label](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) of your pvc| default | no |
| `Selector value`| [Selector value](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) of your pvc| default | no |
| `State database volume claim size`| Size of the Persistent Volume Claim | 8Gi | no |
| | | |
| **Peer resources** | **Min and Max CPU and Memory for the peer PVC** | | |
| `Peer CPU request` | Minimum number of CPUs to allocate to the peer | 2 | yes |
| `Peer CPU limit` | Maximum number of CPUs to allocate to the peer | 2 | yes |
| `Peer Memory request` | Minimum amount of memory to allocate to the peer | 4Gi | yes |
| `Peer Memory limit` | Maximum amount of memory to allocate to the peer | 4Gi | yes |
| | | |
|**CouchDB Resources** | **Min and Max CPU and RAM allocated to CouchDB PVC**| | | |
| `CouchDB CPU request` |Minimum number of CPUs to allocate to CouchDB| 2 | yes |
| `CouchDB CPU limit` | Maximum number of CPUs to allocate to CouchDB | 2 | yes |
| `CouchDB Memory request` | Minimum amount of memory to allocate to CouchDB | 4Gi | yes |
| `CouchDB Memory limit` | Maximum amount of memory to allocate to CouchDB | 4Gi | yes |  

When CouchDB is selected as the remote peer database, two containers are created in the pod, one for the peer and one for CouchDB.
The Peer container includes a single volume mount to the Peer PVC which stores the blocks and transactions on the file system. The CouchDB container mounts the peer state database PVC which contains the ledger data.

When LevelDB is selected as the Remote peer database, a single container is created in the pod for running both the peer and LevelDB
processes. This container has two volume mounts, one for the Peer PVC and the second volume mount is for the peer state database PVC which contains the ledger data.

| Remote Peer database selection  | Contents of Container #1  | Contents of Container #2 |
| --------------|-----------------|---------------|
| CouchDB | Remote Peer which mounts the Peer PVC| CouchDB which mounts the state database PVC |
| LevelDB | Remote Peer and LevelDB which mounts the Peer PVC and the state database PVC | n/a |

## Verifying the peer installation
After you complete the configuration parameters and click the **Install** button to launch the remote peer, you can view the peer log to check whether your peer installation is successful.

1. (1) After you click **Install**, click the **View Helm Release** button in the pop-up window. Scroll down to the **Pods** section. When the Pods status shows **Running**, you can find your remote peer instance under the **Deployments** section.
2. (2) In the ICP console, click the **Menu** icon in the upper left corner. From the menu list, click **Workloads** > **Deployments**. In the deployment table, click the remote peer instance that you created. This will open the deployment overview screen opens. Click the **Logs** tab to view your remote peer logs. You can enter the string `Started` in the search field.  

      &#45; If your remote peer is started successfully, you can see logs that are similar to the following example:  

      ```
      [36m2018-06-25 14:22:36.929 UTC [inproccontroller] func2 -> DEBU 196[0m chaincode-support \
      started for qscc-1.1.0
      [36m2018-06-25 14:22:36.929 UTC [inproccontroller] func1 -> DEBU 197[0m chaincode started \
      for qscc-1.1.0
      2018-06-25 14:22:36.942 UTC [nodeCmd] serve -> INFO 1cc[0m Started peer with ID=[name:"fabric-peer" ],\
      network ID=[fa74d88bbd9f46a48a6e4c9986e84228], address=[10.1.156.81:7051]
      ```

      &#45; If you see no logs in the screen, your remote peer may not have started successfully. To view additional logs for problem determination, click the **Menu** icon in the upper left corner and then click **Workloads** > **Helm Releases**. Click your helm release to open it. Click the **View Logs** link next to the associated **Pod** to view additional chart logs in the Kibana interface.

## Storage

&#45; You need to determine the storage that your peer will use. If you use the default settings, the Helm Chart will create a new 8 Gi Persistent Volume claim with the name of `my-data-pvc` for your peer data, and another 8 Gi Persistent Volume claim with the name of `statedb-pvc` for your state database.  
&#45; When CouchDB is selected as the database, two containers are created in the pod, one for the Peer and one for CouchDB. The Peer container includes a single volume mount to the Peer PVC which stores the blocks and transactions on the file system. The CouchDB container mounts the peer state database PVC which contains the ledger data.  
&#45; When LevelDB is selected as the Remote peer database, a single container is created in the pod for running both the peer and LevelDB processes. This container has two volume mounts, one for the Peer PVC and the second volume mount is for the peer state database PVC which contains the ledger data.  
&#45; If you do not want to use the default storage settings, ensure that a *new* storageClass is set up during the ICP installation or the Kubernetes system administrator needs to create a storageClass before you deploy.  
&#45; You can choose to deploy the remote peer on either the amd64 or s390x platforms. However, be aware that [Dynamic provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/) is only available for amd64 nodes in ICP. If your cluster includes a mix of s390x and amd64 worker nodes, dynamic provisioning cannot be used.  
&#45; If not using dynamic provisioning, [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) must be created and setup with labels that can be used to refine the kubernetes Persistent Volume Claim (PVC) bind process.  

## Operating your remote peer

After you set up IBM Blockchain Platform remote peers in an environment outside IBM Cloud, you need to complete several operational steps before your peer can issue transactions to invoke and query the ledger of the blockchain network. For instructions on operating your remote peer, see the
[IBM Blockchain Platform documentation](https://console.bluemix.net/docs/services/blockchain/howto/remote_peer_operate_icp.html#remote-peer-operate).

## Documentation 	

- [IBM Blockchain Platform Documentation](https://console.bluemix.net/docs/services/blockchain/index.html)
- [IBM Blockchain Platform Remote Peer Documentation](https://console.bluemix.net/docs/services/blockchain/howto/remote_peer.html#remote-peer-overview)																														
