[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # (\(C\) Copyright IBM Corporation 2018 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)

# IBM PowerAI Enterprise

[IBM PowerAI Enterprise](https://www.ibm.com/support/knowledgecenter/en/SSFHA8_1.1.2/powerai_enterprise_overview.html) makes deep learning and machine learning more accessible to your staff, and the benefits of AI more obtainable for your business.


## Legends
| Name | Details |
| ---- | ------- |
| Management console dashboard | IBM® Cloud Private management console dashboard|
| paiemaster | Default name of the IBM PowerAI Enterprise master node.|
| Cluster management console | IBM PowerAI Enterprise console|


## Introduction
IBM PowerAI Enterprise provides GPU accelerated open source libraries and frameworks for deep learning and machine learning. It distributes model training and inference in dynamically scaled multi-tenant Apache Spark clusters. It provides robust, end-to-end workflow support for deep learning lifecycle management, including installation and configuration; data preparation; building, optimizing, and training, validating and inferencing the model.

## Chart Details
You can deploy IBM PowerAI Enterprise as a Helm chart to quickly launch a master pod in the Kubernetes cluster. Each PowerAI Enterprise Helm chart deployment creates one independently managed and isolated cluster in your envrionment. Each cluster is managed by its own cluster management console which runs in the master pod. You can access the cluster management console from your browser by way of an Http proxy or an Ingress proxy configured in Kubernetes. Through the cluster management console, a user with a specific role (cluster administrator or consumer administrator) or permission (Spark instance groups Configure permission) can create and manage multiple Spark instance groups for different tenants. 

Each Spark instance group can have unique properties based on your preferences. For example, you can specify the version of Spark installed, the number of CPUs, GPUs, and amount of memory resources assigned to it, and so on. Once a Spark instance group is created, IBM Spectrum Conductor, which is bundled with IBM PowerAI Enterprise, automatically generates the Spark instance group container image and deploys it onto the Kubernetes cluster. A Spark instance group is a first class Kubernetes deployment, upon which Kubernetes can manage its resource usage. A Spark instance group exposes its Spark master service for remote batch submission or a Livy service for third party notebooks (like IBM Watson Studio) to connect to.

Each tenant can log in to the cluster management console using its own authority to access its own Spark instance group. A tenant can submit Spark batch jobs and notebook applications without overlapping other tenants. Each Spark instance group grows its replicas based on its workload demands. You can set up its replicas' threshold by assigning a quota to its namespace.

This Helm chart deploys two singleton services called cwsetcd and cwsproxy, which help to do host-ip mapping within IBM PowerAI Enterprise deployments. This chart deploys a singleton daemonset called cwsimagecleaner, which helps to deploy an auto-generated Spark instance group image onto the nodes in the Kubernetes cluster. It commits the image to the icp registry. After the Spark instance group is deleted, cwsimagecleaner is also responsible for cleaning up its image from the nodes and the registry.


## Prerequisites

### [Set up IBM® Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/installing/install.html)

### [Install kubectl CLI to access the cluster using the CLI](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/manage_cluster/cfc_cli.html)  

### Storage
Make sure that the storage requests and kernel parameters are correctly set up before installing IBM PowerAI Enterprise.

This ibm-powerai-enterprise-prod chart requires shared storage facilities to save metadata for high availability.
- A persistent volume (>=3Gi) is mandatory for the IBM PowerAI Enterprise master and Spark instance group high availability, with the storage class name specified by master.sharedStorageClassName.
- A persistent volume (>=2Gi) is mandatory for IBM PowerAI Enterprise ETCD high availability, with the storage class name specified by cluster.etcdSharedStorageClassName. Because the ETCD is a singleton deployment within the entire Kubernetes cluster, you only need to specify this persistent volume for the first deployment of the IBM PowerAI Enterprise Helm chart.  
- A persistent volume (>=4Gi) is mandatory for shared deep learning storage for data sets etc, with the storage class name specified by dli.sharedFsStorageClassName. The packages must be in the format described below.


You can define a persistent volume either by using the following specification sample as input to the kubectl command, or by entering it through the management console dashboard "Platform -> Storage -> Create PersistentVolume".  
```
# cat pv.yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
     name: pv-share
    spec:
     capacity:
      storage: 5Gi
     accessModes:
        - ReadWriteMany
     persistentVolumeReclaimPolicy: Recycle
     # storageClassName: gold
     nfs:
            path: /root/share
            server: xx.xx.xx.xx

# kubectl create -f pv.yaml
```
If you uncomment "storageClassName = gold" in the above sample, then only a deployment with a storage request with the class name "gold" matches.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition for a deployment named "enterprise" in the namespace "custom":


```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  labels:
    app: enterprise-paiemaster
    chart: "ibm-powerai-enterprise-prod"
    heritage: "Tiller"
    release: "enterprise"
  name: privileged-enterprise
spec:
  allowPrivilegeEscalation: true
  allowedCapabilities:
  - LEASE
  - NET_BIND_SERVICE
  - NET_ADMIN
  - NET_BROADCAST
  - SETGID
  - SETUID
  - SYS_ADMIN
  - SYS_CHROOT
  - SYS_NICE
  - SYS_RESOURCE
  - SYS_TIME
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - KILL
  - SETFCAP
  fsGroup:
    rule: RunAsAny
  hostIPC: true
  hostNetwork: true
  hostPID: true
  hostPorts:
  - max: 65535
    min: 0
  privileged: true
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - '*'
  ```
  * Custom ClusterRole for the custom PodSecurityPolicy:

  ```
  apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: enterprise-paiemaster
    chart: "ibm-powerai-enterprise-prod"
    heritage: "Tiller"
    release: "enterprise"
  name: privileged-enterprise
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["services"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["endpoints"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: [""]
  resources: ["nodes","persistentvolumeclaims"]
  verbs: ["get","list"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get"]
- apiGroups: ["extensions"]
  resources: ["deployments", "deployments/scale"]
  verbs: ["create","delete","get","list","patch","update","watch"]
- apiGroups: ["extensions"]
  resources: ["podsecuritypolicies"]
  resourceNames: [privileged-enterprise]  
  verbs: ["use"]
  
  ```
  ### Configuration files

  All the required files can be found in ibm_cloud_pak/pak_extensions/prereqs directory of the downloaded archive. To deploy against a custom namespace with custom PodSecurityPolicy, follow the below steps.  
  
  - Run the below script to create the custom namespace, PodSecurityPolicy, ClusterRole, ClusterRoleBindings and serviceaccount for this release of the chart.
  ```
  #  ./createSecurityNamespacePreReqs.sh <namespace> <release>
  ```    
  - secret_template.yaml: Use this file to create secrets with Base64 encoded username/password.
  - secret-helm-template.yaml: Use this file to create Docker registry key.
  - secret-imagecleaner-template.yaml: Use this file to create image cleaner secret. This secret should be created only in the **default** namespace.
  - serviceaccount_template.yaml: Use this file to create service account.

### Creating Secrets

IBM PowerAI Enterprise creates new Spark instance groups when requested from the cluster management console console by invoking the Kubernetes Helm/Tiller service under the covers. This requires a user with the Kubernetes Cluster or Team administrator role to access the [Tiller](https://docs.helm.sh/developers/) service from a pod running in the IBM PowerAI Enterprise cluster.

To satisfy this requirement, two Kubernetes secrets must be created for each namespace. One secret is used to connect to the local Docker registry, and the other is for deploying Spark instance groups under the same namespace.


To create secrets, follow these steps:

1. Use the following steps to fetch and create the Docker registry key:

````
    
  # echo -n <management console dashboard username>:<management console dashboard user password> | base64
  <base64 encoded credential>

  Sample output:
  # echo -n admin:admin | base64
  YWRtaW46YWRtaW4=
  #
  
  Replace the Base64 encoded credential in the below file to create the registry key.

  # cat config.json
	{“auths”: {“mycluster.icp:8500": {“auth”: “<base64 encoded credential>“}}}
	
	# cat config.json | base64
	<registry key value>
	
  sample output:
	# cat config.json | base64
	eyJhdXRocyI6IHsibXljbHVzdGVyLmljcDo4NTAwIjogeyJhdXRoIjogIllXUnRhVzQ2WVdSdGFX
	ND0ifX19Cg==
	#
	
  # cat secret.yaml
	apiVersion: v1
	kind: Secret
	metadata:
	  name: <IBM PowerAI Enterprise Helm release name>-registrykey
	  namespace: <PowerAI Enterprise Helm release namespace>
	  labels:
		heritage: "Tiller"
		release: "<IBM PowerAI Enterprise Helm release name>"
		chart: "ibm-powerai-enterprise-prod"
		app: <IBM PowerAI Enterprise Helm release name>-paiemaster
	type: kubernetes.io/dockerconfigjson
	data:
	  .dockerconfigjson: <registry key value>
  
  # kubectl create -f secret.yaml	

  # cat secret-imagecleaner.yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: imagecleaneregistrykey-default
      namespace: default
    labels:
      heritage: "Tiller"
      release: "<release name>"
      chart: "ibm-powerai-enterprise-prod"
      app: <release-name>-paiemaster
    type: kubernetes.io/dockerconfigjson
    data:
      .dockerconfigjson: <registry key value>

   # kubectl create -f secret-imagecleaner.yaml
	
````
	
2. Use the following template to create secrets for the master node and Spark instance groups:

````  
To create a secret with admin/admin credentials:

   # echo -n admin | base64
   <<base64 encoded username>>
   #

   # echo -n admin | base64
   <base64 encoded password>

   # cat secret-helm.yaml
	apiVersion: v1
	kind: Secret
	metadata:
	  name: <IBM PowerAI Enterprise Helm release name>-admin-secret
	  namespace: <PowerAI Enterprise Helm release namespace>
	  labels:
		heritage: "Tiller"
		release: "<IBM PowerAI Enterprise Helm release name>"
		chart: "ibm-powerai-enterprise-prod"
		app: <IBM PowerAI Enterprise Helm release name>-paiemaster
	  spec:  
	type: Opaque
	data:
	  username: <base64 encoded username>
	  password: <base64 encoded password>
	  
  # kubectl create -f secret-helm.yaml

````
### Creating ServiceAccount

Before installing IBM PowerAI Enterprise, create a service account for your deployment. This step is not required if you are deploying with custom PodSecurityPolicy. The script createSecurityNamespacePreReqs.sh will create the service account for the deployment.

```
# cat service_account.yaml
	apiVersion: v1
        kind: ServiceAccount
        metadata:
          name: cws-<IBM PowerAI Enterprise Helm release name>
          namespace: <PowerAI Enterprise Helm release namespace>
        labels:
              app: <IBM PowerAI Enterprise Helm release name>-paiemaster
              chart: "ibm-powerai-enterprise-prod"
              heritage: "Tiller"
              release: "<IBM PowerAI Enterprise Helm release name>"
	  
  # kubectl create -f service_account.yaml
```  
  
### Kernel parameters
Before you install IBM PowerAI Enterprise, the `vm_max_map_count` kernel must be set to at least 262144 on all the Kubernetes worker nodes for the ELK services to start and run normally. To set the vm_max_map_count kernel value:
- Set the kernel value dynamically to ensure that the change takes effect immediately:
````
  # sysctl -w vm.max_map_count=262144
````
- Set the kernel value in the /etc/sysctl.conf file to ensure that the change persists when you restart your node:
````
  vm.max_map_count=262144
````

## Resources Required
The `IBM PowerAI Enterprise master CPU request` and `IBM PowerAI Enterprise master memory request` parameters are the initial CPU and memory requests that are used to create the master container. The default values are 4 OS CPUs and 4G memory, as listed in /proc/cpuinfo. These values cannot exceed 16 OS CPUs and 16G memory.

The `Compute container CPU request`, `Compute container memory request`, and `Compute container GPU request` parameters define the maximum amount of resources each compute container can request during a Spark instance group creation. The default request values are 6 vcores and 6G memory for each container. They can be adjusted less than the default values when you create a spark instance group.

For the number that you can specify for the CPU and memory columns, refer to the [Kubernetes Specification](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).

The number of GPUs is a nonzero positive integer.  The default value is one.  

## Installing the Chart

PowerAI Enterprise Helm Chart is listed in the management console dashboard. Go to catalog and search for ibm-powerai-enterprise-prod.
Click Configure and enter information for the Helm Release name and the Namespace fields. 

You can use the following values to fine tune your IBM PowerAI Enterprise installation.

### Images and registries
The base image of the master container is defined by the `IBM PowerAI Enterprise master image name` parameter, which is pushed to the default image registry "mycluster.icp:8500/default".

### Dynamic scaling
When the Helm chart is deployed, only the IBM PowerAI Enterprise master container is created. After installation, you can create Spark instance groups from the cluster management console. Every Spark instance group initially has only one container. Once workloads reach the Spark master within the Spark instance group, the Spark master can request more containers from the Kubernetes API server based on its workloads' demands. The total number of replicas of the Spark instance group can be up to the value defined by the `Maximum compute containers` parameter. The Spark master scans its current demands every X seconds (defined by `The interval of dynamic scaling compute containers` parameter) and requests the defined number of containers (defined by the `The unit of dynamic scaling compute containers` parameter).

### The proxy for accessing the cluster management console

IBM PowerAI Enterprise supports two types of proxy services for accessing the cluster management console. The cluster management console is where you start to work with your Spark instance groups, including Spark batch and notebook workloads.

- `HttpProxy`

HttpProxy uses a service called `cwsproxy` to redirect web accesses into the IBM PowerAI Enterprise cluster management console by setting up a network proxy at the client browser. For instance, from a Firefox browser where you want to access the cluster management console, open "Preferences -> Advanced -> Network -> Connection Settings", define "Manual proxy configuration" with the public IP address of a node in the Kubernetes cluster. cwsproxy is a singleton service that is started by the first IBM PowerAI Enterprise installation that has HttpProxy configured, and is then reused by any other IBM PowerAI Enterprise installation with HttpProxy.

- Navigate to the cluster management console by using the URL: https://`releasename`-`IBM PowerAI Enterprise master name`:8443/platform. For example, https://enterprise-paiemaster:8443/platform.

Note: `releasename`-`IBM PowerAI Enterprise master name` (e.g. enterprise-paiemaster) is also the master deployment name of the IBM PowerAI Enterprise installation.

- `IngressProxy`

IngressProxy allows you to directly access the IBM PowerAI Enterprise cluster management console. Every IBM PowerAI Enterprise master deployment publishes an IngressProxy service with 4 node ports that can access IBM Spectrum Conductor internal services bundled with IBM PowerAI Enterprise. IBM Spectrum Conductor Deep Learning Impact requires 7 node ports. 

1. Configure a base port and 4 successive ports (7 successive ports for IBM Spectrum Conductor Deep Learning Impact) that are available on every node in the Kubernetes cluster.

2. Configure your client DNS server to resolve `releasename`-`IBM PowerAI Enterprise master name` to any public IP address of the Kubernetes cluster. Alternately, you can configure the host mapping in the client host /etc/hosts for a UNIX OS or /etc/hosts counterpart for Windows OS. For instance:
```
$ cat /etc/hosts
xx.xx.xx.xx enterprise-paiemaster
```
3. Navigate to the IBM PowerAI Enterprise cluster management console by using the following URL: https://`releasename`-`IBM PowerAI Enterprise master name`:`baseport`. For example, https://enterprise-paiemaster:30546/platform.

Note: Due to the Web service design limitation, notebooks are not supported with IngressProxy. For that case, you can switch to use HttpProxy.

### LDAP client
IBM PowerAI Enterprise can import the same user base as the Kubernetes cluster, as long as the configuration of `LDAP Server IP` and `LDAP BaseDN` is consisted within the configuration in the Kubernetes cluster. The LDAP user can log in to the cluster management console to work on their own Spark instance groups and workloads.


## Applying Resource Enforcement
To apply a resource quota (for example, maximum 10 pods) against an IBM PowerAI Enterprise cluster, you can attach the quota onto its namespace. For example:
```   
# cat quota10.yaml
    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: quota10
    spec:
      hard:
        pods: "10"

# kubectl create -f quota10.yaml --namespace=custom
```

## Configuration
The following table lists the configurable parameters of the ibm-powerai-enterprise-prod chart. You can modify the default values during installation as required.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| master.name      | IBM PowerAI Enterprise master name        | paiemaster                                            |
| master.cpu       | IBM PowerAI Enterprise master CPU request | 4000m                                          |
| master.memory            | IBM PowerAI Enterprise master memory request   | 4096Mi                            |
| master.sharedStorageClassName      | IBM PowerAI Enterprise master HA storage class name       |       |
| master.imageName | IBM PowerAI Enterprise master image name       |   mycluster.icp:8500/default/powerai-enterprise:1.1.2    |
| master.imagePullPolicy | IBM PowerAI Enterprise master image pull policy              | Always                           |
| sig.maxReplicas       | Maximum compute containers      | 10                           |
| sig.cpu      | compute container CPU request         | 6000m                     |
| sig.memory   | compute container memory request        | 6144Mi            |
| sig.gpu      | compute container GPU request     |        1                       |
| sig.ssAllocationUnit           | The unit of dynamic scaling compute containers      | 2          |
| sig.ssAllocationInterval      | The interval of dynamic scaling compute containers    | 120      |
| dli.enabled     | Enables IBM Spectrum Conductor Deep Learning Impact    | true              |          
| cluster.ldapServerIp      | LDAP server IP |                            |
| cluster.ldapBaseDn        | LDAP BaseDN    |    dc=mycluster,dc=icp                    |
| cluster.etcdSharedStorageClassName       | Conductor ETCD HA storage class name |                               |
| cluster.proxyOption        | The proxy for accessing the cluster management console   |    HttpProxy                    |
| cluster.basePort        | IngressProxy only - Base Port    |     30645                   |
| cluster.ascdDebugPort        | A debug port for troubleshooting internal daemons    |     32311                   |
| cluster.useDynamicProvisioning        | A flag for turning on Dynamic Provisioning   |     false                   |
| helm.credentialType | Secret |   |

Specify each parameter using the "--set key=value[key=value]" argument like "--set sig[gpu=2]"  with the "helm install" command

Alternatively, a YAML file that specifies the values for the parameters can be specified when you install the chart.

## Storage

### Storage class names
Use a known storage with a class name. If you leave the `XXX storage class name` parameter empty, Kubernetes uses the default storageclass that is defined by either the Kubernetes system administrator or any available PersistentVolume in the system that can satisfy the capacity request (e.g. 5Gi).

## Accessing Spark master of a Spark instance group

### Livy server

Apache Livy is a service that enables easy interaction with a Spark cluster over a REST interface. When you create a Spark instance group, you can enable a Livy server for the Spark batch master of the Spark instance group by specifying the livy image name and top directory path. When the Spark instance group is started, you can use the Livy server to submit Spark jobs or snippets of Spark code, synchronous or asynchronous result retrieval, and Spark Context management, all by using a simple REST interface or an RPC client library. Note that the Livy server is exposed as a Kubernetes NodePort service in the namespace of the Spark instance group; the service name is $conductorHelmReleaseName-$sparkInstanceGroupName-livy.


## Limitations
- If you are using IngressProxy, notebooks are not supported.
- If you have enabled a Livy server, you can only run interactive session of the Livy API. Submitting batch applications using the Livy API is not supported.
- Spark Instance Groups must share the same namespace that the PowerAI Enterprise deployment uses.
- These instructions apply to IBM® Cloud Private only.

## Accessing IBM PowerAI Enterprise
IBM PowerAI Enterprise uses the following HTTPS services, which are available through either `HttpProxy` or `IngressProxy`:

- The `webgui` service hosts the cluster management console (available at https://*host_master*:*port*/platform). For more information, see [Cluster management console](https://www.ibm.com/support/knowledgecenter/SSZU2E_2.3.0/getting_started/management_console_overview.html).


After you log in to the cluster management console, if you encounter an error in a pop-up window, safely ignore the error to continue.

- The `REST` service hosts the REST APIs for resource management and package deployment. For more information, see [RESTful APIs](http://www.ibm.com/support/knowledgecenter/SSZU2E_2.3.0/get_started/locating_rest_apis.html).
- The `ascd` service hosts the REST APIs, which hosts the RESTful APIs for Spark instance group and application instance management. For more information, see [RESTful APIs](https://www.ibm.com/support/knowledgecenter/SSZU2E_2.3.0/get_started/locating_rest_apis.html).


## Uninstalling the Chart
Uninstall IBM PowerAI Enterprise by using one of the following methods, assuming the IBM PowerAI Enterprise release name is "enterprise":
- Dashboard: Click the menu: "Workloads -> Helm Releases", find all release names with the prefix of the "enterprise".  There will be one master and all of the spark instance groups such as enterprise, enterprise-sig1, etc.  Select each and click "Action -> Delete".
- Command: To remove IBM PowerAI Enterprise as well as all Spark instance groups created within it, run the following commands:   
```
# kubectl get deployment --namespace enterprise | sed -e 1d | awk '{print $1}' | xargs helm delete --purge --tls
# kubectl delete namespace enterprise
```
- Command: To remove the chart secrets, run the following commands:
```
# kubectl get secrets -n <PowerAI Enterprise Helm release namespace>
# kubectl delete secret <secret name associated with the Chart> -n  <PowerAI Enterprise Helm release namespace>
```

Note: We recommend that you remove the Spark instance groups from the cluster management console prior to removing the chart. This will remove any Spark instance group deployments and container images from Kubernetes as well.

The associated persistent volumes that were created prior for the deployment must to be deleted manually from the cluster management console. For more understanding on persistent volume clean up, see [Kubernetes guide](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy)

## Documentation
To learn more about IBM PowerAI, see [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SS5SF7_1.5.4/welcome/welcome.htm)

To learn more about using IBM Spectrum Conductor Deep Learning Impact, see [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSWQ2D_1.2.1/gs/product-overview.html).

To learn more about using IBM Spectrum Conductor, see [IBM Knowledge Center](http://www.ibm.com/support/knowledgecenter/SSZU2E_2.3.0/icp/conductor_icp.html).
