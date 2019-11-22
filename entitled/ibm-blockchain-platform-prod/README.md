# IBM Blockchain Platform console

The IBM® Blockchain Platform console is a user interface that simplifies the processes to build, monitor, govern, and operate a blockchain network in a multi-cloud environment.

## Introduction

The IBM Blockchain Platform console enables you to build a blockchain network with fundamental components, create and manage identities, set up channels, install and instantiate smart contracts, and govern your network policies. This chart can be deployed on many types of platforms, including LinuxONE, IBM Z, and x86.  The information contained in this README is intended to be used as a quick set of steps for getting started and deploying the console.

## Chart Details

This Helm chart deploys the console into a new or existing Persistent Volume Claim (PVC).

## Resources Required

Ensure that your system meets the minimum hardware resource requirements for the console:

| **Component** (all containers) | CPU  | Memory (GB) | Storage (GB) |
|--------------------------------|---------------|-----------------------|------------------------|
| **Console** | 1.3 | 2.5 | 10 |

You system and storage class will also need sufficient resources for the components you create. To see the recommended resource allocations for your blockchain components, see the Resources required section in the [IBM Cloud documentation](https://cloud.ibm.com/docs/services/blockchain?topic=blockchain-console-deploy-icp#console-deploy-icp-resources-required).

**Notes:**
- A vCPU is a virtual core that is assigned to a virtual machine or a physical processor core if the server is not partitioned for virtual machines. You need to consider vCPU requirements when you decide the virtual processor core (VPC) for your deployment in IBM Cloud Private. VPC is a unit of measurement to determine the licensing cost of IBM products. For more information about scenarios to decide VPC, see [Virtual processor core (VPC) ![External link icon](../images/external_link.svg "External link icon")](https://www.ibm.com/support/knowledgecenter/en/SS8JFY_9.2.0/com.ibm.lmt.doc/Inventory/overview/c_virtual_processor_core_licenses.html "IBM License Metric Tool 9.2").
- A vCPU is equivalent to one CPU, which is equivalent to one VPC.

## Limitations

Before you begin, ensure that you understand the following limitations:

- You are responsible for the management of health monitoring, security, logging, and resource usage of your blockchain components.
- The console can only be used to create and govern components based on Hyperledger Fabric v1.4.1 or higher.
- You can only import nodes that have been exported from other IBM Blockchain Platform consoles. In order to be able to operate an imported node from the console, you also need to import the associated node's administrator identity into your console wallet. If the node is of type peer or orderer, you need to import the associated organization MSP definition.   

## Prerequisites

You need to install or configure the following dependencies before you deploy the console.

1. Review the storage requirements for your PVC in the **Storage** section of this README.

2. You should create a new, custom namespace for your IBM Blockchain Platform deployment. Your namespace needs to use the required PodSecurityPolicy. If you plan of creating multiple blockchain networks, for example to create different environments for development, staging, and production, you should create a unique namespace for each environment.

3. Retrieve the value of the cluster Proxy IP address of your CA from the IBM Cloud Private console. **Note:** You will need to be a [Cluster administrator](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/user_management/assign_role.html) to access your proxy IP. Log in to the IBM Cloud Private cluster. In the left navigation panel, click **Platform** and then **Nodes** to view the nodes that are defined in the cluster. Click the node with the role `proxy` and then copy the value of the `Host IP` from the table. **Important:** Save this value and you will use it when you configure the `Proxy IP` field of the Helm chart.

4. Create an [image security policy](https://cloud.ibm.com/docs/services/blockchain/howto/console-deploy-icp.html#console-deploy-icp-image-policy) that allows your deployment to download the required images from your cluster docker registry.

5. Create a password that you will use to login to console for the first time and store it inside a Kubernetes secret object. You can find the steps to create the secret in the [IBM Cloud documentation](https://cloud.ibm.com/docs/services/blockchain/howto/console-deploy-icp.html#console-deploy-icp-password-secret).

### PodSecurityPolicy Requirements

This chart requires specific security and access policies be bound to the target namespace prior to installation. Use the following steps to configure the policies prior to configuration of the Helm Chart:

1. Choose either a predefined PodSecurityPolicy for your namespace, or have your cluster administrator create a custom PodSecurityPolicy for you:
- You can use the predefined PodSecurityPolicy of [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)
- You can also create using YAML below a Custom PodSecurityPolicy definition:
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

2. Create a ClusterRole for the PodSecurityPolicy.
- If you created a custom security policy, you can create a security policy using the YAML file below:
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
If you are using a predefined PodSecurityPolicy, you only need to create a ClusterRole policy using the second apiGroups section:
  ```
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    annotations:
    name: ibm-blockchain-platform-clusterrole
  rules:
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

3. Create a custom ClusterRoleBinding. If you decide to change the ServiceAccount name in the file below, you need to provide the name to the `Service account name` field in the **All Parameters** Section of the configuration page when deploying the Helm chart.
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

## Installing the Chart

1. Log in to your cluster dashboard and click the **Catalog** link in the upper right corner.
2. Search for **Blockchain** and click the `ibm-blockchain-platform-prod` tile on the right. The **Overview** tab contains this Readme file that includes information about installing and configuring the Helm chart.
3. Click **Configuration** tab at the top of the panel or click the **Configure** button in the lower right corner of the Overview tab.
4. Specify the values for the Configuration and pod security parameters and accept the license agreement.
5. Navigate to the **Parameters** section:
- You can deploy the console by only using the **Quickstart parameters**. Use this option if you are experimenting or getting started.
- You can use the **All parameters** section to customize network access, resources and storage. This section is recommended only more experienced Kubernetes users.
6. Click **Install**.

## Configuration

Complete the configuration parameter fields. The following tables list the configuration parameters and their default values.

*Description on configuration parameters is also available in [IBM Blockchain Platform documentation](https://test.cloud.ibm.com/docs/services/blockchain/howto?topic=blockchain-console-deploy-icp).*

### General and Pod Security parameters

You need to complete the following parameters to deploy the console.

|  Parameter     | Description    | Default  | Required |
| --------------|-----------------|-------|------- |
| `Helm release name`| Name to identify your helm release deployment. Begin with a lowercase letter, end with any alphanumeric character, and must contain only hyphens and lowercase alphanumeric characters. | None | Yes |
| `Target namespace`| Specify the namespace that you created for your console and components. The namespace must include an `ibm-privileged-psp` policy. Otherwise, [bind a PodSecurityPolicy](https://cloud.ibm.com/docs/services/blockchain?topic=blockchain-icp-console-setup#icp-console-setup-psp) to your namespace. | None | Yes |
| `Target Cluster`| Specify the clusters where you would like to deploy the resource. Available clusters are filtered by the selected namespace and Kubernetes version requirements. | None | Yes |
| `Target namespace policies`| Pre-configured to use your target namespace. The values must include the `ibm-privileged-psp` or `ibm-blockchain-platform-psp` policy. | None | Yes |

### Quick start parameters

You can deploy the chart only using the quickstart parameters below and use the default storage, resource, and networking values.

|  Parameter     | Description    | Default  | Required |
| --------------|-----------------|-------|------- |
| **Console settings** | **Administration and deployment of your console** | | |
| `Proxy IP` | IP address of the proxy node of your cluster. | None| Yes |
| `Console administrator email` | Email used to log into the console. | None | Yes |
| `Console administrator password secret name` | Name of the secret that you [created to store the password](#console-deploy-icp-password-secret) that you will use to login to the console. | None | Yes|
| **Network settings** | **Network access to your console** | | |
| `Console hostname` | Enter the same value as the Proxy IP. | None | Yes |
| `Console port` | Enter the port you would like to use in the range of 31210 - 31220. This port cannot be used by another application. | None | Yes |
| `Proxy hostname` | Proxy server hostname. Enter the same value as the Proxy IP. | None | Yes |
| `Proxy port` | Enter any port you would like to use in the range of 31210 - 31220. This port cannot be used by another application or the console. | None | Yes |
| **Storage settings** | **Storage to be used by your console** | | |
| `Storage class name` | Enter the name of the storage class to be used by the console and the components that you create. | None | Yes |

### All Parameters

You can also enter the parameters below to customize the network access, resources and storage used by your console.

|  Parameter     | Description    | Default  | Required |
| --------------|-----------------|-------|------- |
| `License` | Set to accept to indicate that you accept the terms of the license | Not accepted | Yes |
| `Architecture` | Select your cloud platform architecture. (AMD64 or S390x) | AMD64 | No |
| **Console settings** | **Administration and deployment of your console** | | |
| `Service account name` | Service account to be used by operator. | None | No |
| `Proxy IP` | IP address of the proxy node in your cluster. | None | Yes|
| `Console administrator email` | Email used to log in to the console. | None | Yes |
| `Console administrator password secret name` | Name of the secret that you [created to store the password](#console-deploy-icp-password-secret) that you will use to login to the console. | None | Yes|
| **Docker image settings** | **Use these settings to customize the Fabric images to be pulled by the console** | | |
| `imagePullSecret name` | imagePullSecret to be used to download images. | `ibp-ibmregistry` | No |
| **Network settings** | **Network access to your console** | | |
| `Console hostname` | Enter the same value as the proxy IP. | None | Yes |
| `Console port` | Enter any port you would like to use in the range of 31210 - 31220. | None | Yes |
| `Proxy hostname` | Proxy server hostname. Enter the same value as the Proxy IP. | None | Yes |
| `Proxy port` | Enter any port you would like to use in the range of 31210 - 31220. This port cannot be used by another application or the console. | None | Yes |
| `TLS secret` | Name of the secret that you [created to store the TLS certificates](#console-deploy-icp-tls-secret) that will be used by the console. | None | No |
| **Storage settings**| **Provision storage for your console and tools** | | |
| `Volume claim size`| Size of the Persistent Volume Claim to be provisioned. | 10Gi  | No |
| `Storage class name`| Name of the storage class to be used by the console and the components you create. | None | Yes |
| `Storage access mode`| Specify the storage [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for the PVC.  | ReadWriteMany | No |
| **Allocate resources**| **Allocate resources to the console** | | |
| `Opstools CPU limit` | Maximum number of CPUs to allocate to the opstools component. | 500m | No |
| `Opstools memory limit` | Maximum amount of memory to allocate to the opstools component. | 1000Mi | No |
| `Opstools CPU request` | Minimum number of CPUs to allocate to the opstools component. | 500m | No |
| `Opstools memory request` | Minimum amount of memory to allocate to the opstools component.| 1000Mi | No |
| `Configtxlator CPU limit` | Maximum number of CPUs to allocate to the configtxlator tool. | 25m | No |
| `Configtxlator memory limit` | Maximum amount of memory to allocate to the configtxlator tool. | 50Mi | No |
| `Configtxlator CPU request` | Minimum number of CPUs to allocate to the configtxlator tool.| 25m | No |
| `Configtxlator memory request` | Minimum amount of memory to allocate to the configtxlator tool.| 50Mi | No |
| `CouchDB CPU limit` | Maximum number of CPUs to allocate to CouchDB. | 500m | No |
| `CouchDB memory limit` | Maximum amount of memory to allocate to CouchDB. | 1000Mi | No |
| `CouchDB CPU request` | Minimum number of CPUs to allocate to CouchDB.| 500m | No |
| `CouchDB memory request` | Minimum amount of memory to allocate to CouchDB.| 1000Mi | No |
| `Operator CPU limit` | Maximum number of CPUs to allocate to operator component. | 100m | No |
| `Operator memory limit` | Maximum amount of memory to allocate to operator component. | 200Mi | No |
| `Operator CPU request` | Minimum number of CPUs to allocate to operator component. | 100m | No |
| `Operator memory request` | Minimum amount of memory to allocate to operator component. | 200Mi | No |
| `Deployer CPU limit` | Maximum number of CPUs to allocate to deployer component. | 100m | No |
| `Deployer memory limit` | Maximum amount of memory to allocate to deployer component. | 200Mi | No |
| `Deployer CPU request` | Minimum number of CPUs to allocate to deployer component. | 100m | No |
| `Deployer memory request` | Minimum amount of memory to allocate to deployer component. | 200Mi | No |

## Verifying the installation

After you complete the configuration parameters and click the **Install** button, click the **View Helm Release** button to view your deployment. If it was successful, you should see the value 1 in the `DESIRED`, `CURRENT`, `UP TO DATE`, and `AVAILABLE` fields in the Deployment table. You may need to click refresh and wait for the table to be updated.

## Using the console

You can use your browser to access the console after installation. You can find the URL in the **Notes:** section of the Helm release overview screen that opens after deployment. Check to make sure you are not using the ESR version of Firefox. If you are, switch to another browser such as Chrome and retry.

In your browser, you should be able to see the console login screen:
- For the **User ID**, use the value you provided for the `Console administrator email` field during configuration.
- For the **Password**, use the value you encoded and stored inside the [password secret](https://cloud.ibm.com/docs/services/blockchain/howto/console-deploy-icp.html#console-deploy-icp-password-secret) and then passed to the console during configuration. This password will become the default password for the console that all new users use to login to the console. After you login for the first time, you will be asked to provide a new password that you can use to login to the console.

The administrator that provisioned the helm chart can grant other users access to the console and specify which operations they can preform. For more information, see [Managing users from the console](https://cloud.ibm.com/docs/services/blockchain/howto/ibp-console-import-nodes.html#console-icp-manage-users).

## Storage

The IBM Blockchain Helm chart uses dynamic provisioning to provision the storage that will be used the console and the blockchain components you will create. Before you deploy the console, you need to create a storageClass with a sufficient amount of backing storage for your console and your components. You need to provide the name of the storageClass you created during configuration.

- If you use the default settings, the Helm chart will create a new Persistent Volume claim with the name of Helm release for your console data.


## Support

For information on digital support offerings, see the IBM Blockchain Platform support [resources and support forums](https://console.bluemix.net/docs/services/blockchain/ibmblockchain_support.html#resources).

If you have purchased a console license and you want to contact Customer support, see this [information](https://www.ibm.com/developerworks/community/blogs/fe25b4ef-ea6a-4d86-a629-6f87ccf4649e/entry/Learn_more_about_IBM_Cloud_Private_Support?lang=en) on accessing the IBM Support Community and opening a support ticket.

## Documentation

- [IBM Blockchain Platform documentation](https://cloud.ibm.com/docs/services/blockchain?topic=blockchain-get-started-ibp)
- [IBM Blockchain Platform console documentation](https://cloud.ibm.com/docs/services/blockchain?topic=blockchain-ibp-console-build-network)
