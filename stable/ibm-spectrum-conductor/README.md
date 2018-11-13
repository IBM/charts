[![IBM Spectrum Conductor](https://developer.ibm.com/storage/wp-content/uploads/sites/91/2018/01/conductor.jpg)](https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=46ecec34-bd69-43f7-a627-7c469c1eddf8)
# IBM Spectrum Conductor 2.3 - Beta

## Introduction
IBM Spectrum Conductor helps you deploy Apache Spark applications efficiently and effectively. As an end-to-end solution for deploying and managing Spark applications, it is designed to address the requirements of organizations that adopt Spark technology for their big data analytics requirements. IBM Spectrum Conductor can support multiple instances of Apache Spark, maximizing resource utilization, and increasing performance and scale.

## Chart Details
You can deploy IBM Spectrum Conductor as a Helm chart to quickly launch and run a master deployment with one pod in the Kubernetes cluster. The master deployment includes a cluster management console that you can access from your browser by way of an Http proxy or an ingress proxy that is deployed together with the master deployment. Through the cluster management console, a user with a certain role (cluster administrator or consumer administrator) or permission (Spark Instance Groups Configure permission) can create and manage multiple Spark instance groups for different tenants. One IBM Spectrum Conductor deployment represents one Spark as a service for a department or a business unit.

Based on your preference, a Spark instance group contains a dedicated Spark version, a customized Spark configuration, notebook (Jupyter or Zeppelin) editions, and end user application dependencies. Once a Spark instance group is created, IBM Spectrum Conductor automatically generates its Docker image and deploys it onto the Kubernetes cluster. A Spark instance group is a first class Kubernetes deployment, upon which Kubernetes can manage its resource usage respectively. A Spark instance group exposes its Spark master service for remote batch submission or a Livy service for 3rd party notebooks (like IBM DSX) to connect to.

Each tenant can log in to the cluster management console using their own authority to access their own Spark instance group. A tenant can submit Spark batch jobs and notebook applications, without overlapping with other tenants. Each Spark instance group grows its replicas based on its workload demands. You can also set up its replicas threshold by its namespace and an assigned quota.

> **Important**: The IBM Spectrum Conductor 2.3 Evaluation Edition has entitlement until **December 31 2018**.

This Helm chart deploys two singleton services called cwsetcd and cwsproxy, which helps to do host-ip mapping within IBM Spectrum Conductor deployments.

This ibm-spectrum-conductor Helm chart deploys a singleton daemonset called cwsimagecleaner, which helps to deploy an auto-generated Spark instance group image onto the nodes in the kubernetes cluster. It commits the image to the private registry as you configured. After the Spark instance group is deleted, cwsimagecleaner is also responsible for cleaning up its image from the nodes and the registry.



## Prerequisites

### PodSecurityPolicy Requirements

### Storage
Make sure that the storage requests and kernel parameters are correctly set up before you click `configure` to install IBM Spectrum Conductor.

This ibm-spectrum-conductor chart requires shared storage facilities to save metadata for high availability.
- A Persistent Volume (>=3G) is mandatory for the IBM Spectrum Conductor master and Spark instance group high availability, with the option to specify a storage class name by master.sharedStorageClassName ;
- A Persistent Volume (>=2G) is mandatory for IBM Spectrum Conductor ETCD high availability, with the option to specify a storage class name by cluster.etcdSharedStorageClassName. Because the ETCD is a singleton deployment within the entire Kubernetes cluster, you need to specify only its storage the first time you install IBM Spectrum Conductor.  

You can define a Persistent Volume by either using the following specification sample to feed the kubectl cmd, or entering it through the Dashboard "Platform -> Storage -> Create PersistentVolume".  
```
cat pv.yaml
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
     # sharedStorageClassName: gold
     nfs:
            path: /root/share
            server: 9.37.250.81

kubectl create -f pv.yaml
```
If you uncomment "sharedStorageClassName = gold" in the above sample, then only a deployment with a storage request with the class name "gold" matches.

### Helm TLS certificate

The ibm-spectrum-conductor chart performs on-going Spark instance group creation that internally requires a user with cluster or team administrator role to establish helm TLS certificates for accessing Tiller from a pod running in the cluster.

ibm-spectrum-conductor provides two options to satisfy this requirement. You can either input the username and password of a cluster or team administrator role in the configuration, or manually create a Kubernetes secret. Use the following steps to create the secret and feed the secret in the configuration.  

Before creating a secret, make sure to complete the following:

1. Setup IBM® Cloud Private CLI to manage the cluster.
   * [For IBM private Cloud 2.1.0.3](http://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/manage_cluster/install_cli.html)
   * [For IBM Private Cloud 3.1.0 or higher](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_cluster/install_cli.html)

2. Install kubectl CLI to access the cluster using the CLI.
   * [CLI installation guide for IBM Private Cloud 2.1.0.3](http://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/manage_cluster/cfc_cli.html)
   * [CLI installation guide for IBM Private Cloud 3.1.0 or higher](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_cluster/cfc_cli.html)

To create a secret, do the following:

1. Create a service account in LDAP which is utilized by the Kubernetes cluster (see http://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.3/user_management/configure_ldap.html for IBM Private Cloud 2.1.0.3 or https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/user_management/configure_ldap.html for IBM Private Cloud 3.1.0 or higher). The service account must be created by a cluster administrator or an administrator of a team and has access to the following resource:
Namespace: "default", <the new namespace to install the ibm-spectrum-conductor helm chart>
Helm repository: ibm-charts, local-charts

Then utilize its credentials (uid/pwd) with cloud CLI to retrieve certificates (ca.pem, key.pem, and cert.pem) into $HELM_HOME
 * For IBM Private Cloud 2.1.0.3
````
  # bx pr login -a https://<cluster_host_name>:8443 --skip-ssl-validation
````
 * For IBM Private Cloud 3.1.0 or higher
````
 # cloudctl login -a https://<cluster_host_name>:8443 --skip-ssl-validation
````
2. Use base64 encoded certificates from $HELM_HOME (or "cd $(helm home)" ) to create a kubernetes secret containing them.
````
  # cat ca.pem | base64 | tr -d \\n > ca.pem.base64
  # cat cert.pem | base64 | tr -d \\n > cert.pem.base64
  # cat key.pem | base64 | tr -d \\n > key.pem.base64
````

````
  # cat secret.yaml
		apiVersion: v1
		kind: Secret
		metadata:
		  name: <any name>-helm-secret
		  namespace: <namespace of the conductor to be installed to>
		data:
		  ca.pem: "<content of file ca.pem.base64>"
		  cert.pem: "<content of file cert.pem.base64>"
		  key.pem: "<content of file key.pem.base64>"

  # kubectl create -f secret.yaml
````

3. Enter the secret name just created in `TLS Secret Name` input in Conductor Facility Configuration section when installing the ibm-spectrum-conductor chart.

### Kernel parameters
Before you install IBM Spectrum Conductor, the `vm_max_map_count` kernel must be set on all the Kubernetes work node(s) to a value of at least 262144 for the ELK services to start and run normally. To set the vm_max_map_count kernel to a value of at least 262144:
- Set the kernel value dynamically to ensure that the change takes effect immediately:
````
  # sysctl -w vm.max_map_count=262144
````
- Set the kernel value in the /etc/sysctl.conf file to ensure that the change is still in effect when you restart your node:
````
  vm.max_map_count=262144
````

### GPU dependencies
The ibm-spectrum-conductor out-of-box image does not contain the GPU bundled dependencies, such as Cuda and cuDNN for license consideration.
To use the full GPU functions in IBM Spectrum Conductor, you must build a new image that contains the GPU dependencies. For more information, see the [image instructions on IBM Cloud](https://git.ng.bluemix.net/ibmcws-icp-samples/icp-evaluation/tree/master/icp-conductor-gpu-image).

## Resources Required
The `Conductor master CPU request` and `Conductor master memory request` parameters are the initial CPU and memory requests that are used to create the master container. The default values are 4 vcores and 4G memory. The hard limits are enforced to be 16 vcores and 16G memory.

The `Compute container CPU request`, `Compute container memory request`, and `Compute container GPU request` parameters define maximum resources each computer container can request during a Spark instance group creation. The default request values are 4 vcores and 4G memory for each container. They can be adjusted less than the default values when you create a spark instance group.

For the number that you can specify for the CPU and memory columns, refer to the [Kubernetes Specification](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).

The number of GPU is an integer equal or greater than zero. Default value is zero. A number greater than zero for `Compute container GPU request` is required to turn on IBM Spectrum Conductor on GPU support.

## Installing the Chart
Install by a helm command: For example, install a IBM Spectrum Conductor deployment with the name "spaas1" in the namespace "spass1"     
```
helm install ibm-spectrum-conductor --name spaas1 --namespace spaas1
```
To fine tune your IBM Spectrum Conductor installation, take the following configurations into account.

### Name, namespace, and license
`Release Name` is the cluster name for the IBM Spectrum Conductor deployment. You can create multiple IBM Spectrum Conductor deployments with unique release names respectively. Try not to reuse a previously deleted release name unless you refresh the storage for cwsetcd.

`Target namespace` is the namespace for the IBM Spectrum Conductor deployment and is inherited by the newly created Spark instance groups in IBM Spectrum Conductor. Each IBM Spectrum Conductor deployment can define a unique namespace during creation.

`license agreements` a check mark that is required to proceed.

### Images and registries
The base image of the master container is defined by the `Conductor master image name` parameter, which is pulled from the `Conductor master image registry` parameter through the credentials defined by the `Conductor master image registry user` and `Conductor master image registry user password` parameters. You need to only adjust these parameters if you have a self-build image, for example you build an image with GPU drivers on top of the default image "ibmcom/spectrum-conductor:2.3".

After you create a Spark instance group, an image is built and persisted into the `Spark instance group image registry` parameter. The default place is the default image registry: "mycluster.icp:8500". The credential to access the registry is defined in the `Spark instance group image registry user` and `Spark instance group image registry user password` parameters.

### Dynamic scaling
The IBM Spectrum Conductor installation starts from only one master container. Then you start to create your Spark instance groups. Every Spark instance group initially has only one container. Once workloads reach the Spark master within the Spark instance group, the Spark master can request more containers from the Kubernetes API server based on its workloads demands. The total replicas of the Spark instance group can reach up to the value defined for the `Maximum computer containers` parameter. The Spark master scans only its current demands every X (defined by `The interval of dynamic scaling compute containers` parameter) seconds and requests the defined number of containers (defined by the `The unit of dynamic scaling compute containers` parameter).

### GPU support
To turn on GPU support in IBM Spectrum Conductor, you must
1. Set a positive number for the `Compute container GPU request` parameter.
2. Build your own image with the nvidia GPU driver on top of the default IBM Spectrum Conductor image "ibmcom/spectrum-conductor:2.3". See the [image instructions on IBM Cloud](https://git.ng.bluemix.net/ibmcws-icp-samples/icp-evaluation/tree/master/icp-conductor-gpu-image).

### The proxy for accessing the cluster management console
IBM Spectrum Conductor supports two types of proxy services for accessing the cluster management console. The cluster management console is where you start to work with your Spark instance groups that includes Spark batch and notebook workloads.

- `HttpProxy`

HttpProxy is using a service called `cwsproxy` to redirect web accesses into the IBM Spectrum Conductor cluster management console, by setting up a network proxy at the client browser. For instance, from a Firefox browser where you want to access the cluster management console, open "Preferences -> Advanced -> Network -> Connection Settings", define "Manual proxy configuration" with a public IP of a node in the Kubernetes cluster. cwsproxy is a singleton service that is started only by the first IBM Spectrum Conductor installation that has HttpProxy configured, and then reused by the IBM Spectrum Conductor installation with HttpProxy.

- Navigate to the cluster management console by using the url: https://`releasename`-`Conductor master name`:8443/platform. For example, https://spaas1-cwsmaster:8443/platform.

Note: `releasename`-`Conductor master name` (e.g. spaas1-cwsmaster) is also the master deployment name of the Conductor installation.

- `IngressProxy`

IngressProxy allows you to directly access the IBM Spectrum Conductor cluster management console. Every IBM Spectrum Conductor master deployment publishes an IngressProxy service with 4 node ports that can access IBM Spectrum Conductor internal services.  

1. Configure a base port and 4 successive ports that are available on every node in the Kubernetes cluster.

2. Configure your client DNS server to resolve `releasename`-`Conductor master name` to any public IP of the kubernetes cluster. Alternately, you can configure the host mapping in the client host /etc/hosts for a UNIX OS or /etc/hosts counterpart for Windows OS. For instance,
```
$ cat /etc/hosts
9.21.51.91 spaas1-cwsmaster
```
3. Navigate to the IBM Spectrum Conductor cluster management console by using the following URL: https://`releasename`-`Conductor master name`:`baseport`. For example, https://spaas1-cwsmaster:30443/platform.

Note: Due to the Web service design limitation, notebooks are not supported with Ingressproxy. For the case, you can switch to use HttpProxy.

### LDAP client
IBM Spectrum Conductor can import the same user base as the Kubernetes cluster, as long as the configuration of `LDAP Server IP` and `LDAP BaseDN` is consist with the configuration in the Kubernetes cluster. The LDAP user can log in to the cluster management console to work on their own Spark instance groups and workloads.

### Architecture scheduling preferences
- For either `amd64` or `ppc64le`, leave them as default "2-No preference" if your cluster is homogeneous.
- If you have a hybrid Kubernetes cluster with both Linux 64-bit and Linux on POWER 64-bit nodes, then you must pick one or the other when you deploy the Spectrum-Conductor Helm chart.   

## Applying Resource Enforcement
To apply a resource quota (for example, maximum 10 pods) against an IBM Spectrum Conductor cluster, you can attach the quota onto its namespace. For example:
```   
cat quota10.yaml
    apiVersion: v1
    kind: ResourceQuota
    metadata:
      name: quota10
    spec:
      hard:
        pods: "10"

kubectl create -f quota10.yaml --namespace=spaas1
```

## Configuration
The following table lists the configurable parameters of the ibm-spectrum-conductor chart. Modify the default values during installation as required.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| master.name      | Conductor master name        | cwsmaster                                            |
| master.cpu       | Conductor master CPU request | 4000m                                          |
| master.memory            | Conductor master memory request   | 4096Mi                            |
| master.sharedStorageClassName      | Conductor master HA storage class name       |       |
| master.imageName | Conductor master image name       |   ibmcom/spectrum-conductor:2.3     |
| master.imagePullPolicy | Conductor master image pull policy              | IfNotPresent                           |
| master.registry | Conductor master image registry       |        |
| master.registryUser   | Conductor master image registry user  |              |
| master.registryPasswd    | Conductor master image registry user password |       |
| sig.maxReplicas       | Maximum computer containers      | 10                           |
| sig.cpu      | compute container cpu request         | 4000m                     |
| sig.memory   | compute container memory request        | 4096Mi             |
| sig.gpu      | compute container gpu request     |                               |
| sig.ssAllocationUnit           | The unit of dynamic scaling compute containers      | 2          |
| sig.ssAllocationInterval      | The interval of dynamic scaling compute containers    | 120      |
| sig.registry | Spark instance group image registry       | mycluster.icp:8500       |
| sig.registryUser   | Spark instance group image registry user  | admin             |
| sig.registryPasswd    | Spark instance group image registry user password | admin    |
| cluster.ldapServerIp      | LDAP server IP |                            |
| cluster.ldapBaseDn        | LDAP BaseDN    |    dc=mycluster,dc=icp                    |
| cluster.etcdSharedStorageClassName       | Conductor ETCD HA storage class name |                               |
| cluster.proxyOption        | The proxy for accessing the cluster management console   |    HttpProxy                    |
| cluster.basePort        | IngressProxy only - Base Port    |     32443                   |
| cluster.ascdDebugPort        | A debug port for troubleshooting internal daemons    |     31311                   |
| cluster.useDynamicProvisioning        | A flag for turning on Dyanamic Provisioning   |     false                   |
| helm.credentialType | 2 options to configure the coredential for helm: Secret or UsernamePassword        |    UsernamePassword    |
| helm.credentialName   | a valid credentialName (username or secret name)   |              |
| helm.password    | Password of the user, required only if choose the UsernamePassword |       |
| arch.amd64         | x64 preference for target worker node       |     2 - No preference      |
| arch.ppc64le       | Power PPC64LE preference for target worker node       | 2 - No preference    |

Specify each parameter using the "--set key=value[,key=value]" argument to "helm install".

Alternatively, a YAML file that specifies the values for the parameters can be provided while you install the chart.

## Storage

### Storage class names
Use a known storage with a class name. If you leave the `XXX storage class name` parameter empty, Kubernetes uses the default storageclass that is defined by either the Kubernetes system administrator or any available PersistentVolume in the system that can satisfy the capacity request (e.g. 5Gi).

## Accessing Spark master of Spark Instance Group

### Livy server
Apache Livy is a service that enables easy interaction with a Spark cluster over a REST interface. When you create a Spark instance group, you can enable a livy server for the Spark batch master of the Spark instance group by specifying the livy image name and top directory path. When the Spark instance group is started, you can use the livy server to submit Spark jobs or snippets of Spark code, synchronous or asynchronous result retrieval, and Spark Context management, all by using a simple REST interface or an RPC client library. Note that the livy server is exposed as a kubernetes NodePort service in the namespace of the Spark instance group; the service name is made of $conductorHelmReleaseName-$sparkInstanceGroupName-livy.

## Limitations
- If you have a hybrid Kubernetes cluster with both Linux 64-bit and Linux on POWER 64-bit nodes, then you must pick one or the other when you deploy the ibm-spectrum-conductor Helm chart.  
- If you are using IngressProxy, notebooks are not supported.
- If you are using IngressProxy and authentication and authorization for the submission user is enabled, the Spark UI is not supported.
- If you enable livy server, you can only run an interactive session of livy API. Submitting batch applications using the livy API is not supported yet.

## Accessing IBM Spectrum Conductor
IBM Spectrum Conductor uses the following HTTPS services, which are available through either `HttpProxy` or `IngressProxy`:

- The `webgui` service hosts the cluster management console (available at https://*host_master*:*port*/platform). For more information, see [Cluster management console](https://www.ibm.com/support/knowledgecenter/SSZU2E_2.3.0/getting_started/management_console_overview.html).

After you log in to the cluster management console, if you encounter an error in a pop-up window, safely ignore the error to continue.

- The `REST` service hosts the REST APIs for resource management and package deployment. For more information, see [RESTful APIs](http://www.ibm.com/support/knowledgecenter/SSZU2E_2.3.0/get_started/locating_rest_apis.html).
- The `ascd` service hosts the REST APIs, which hosts the RESTful APIs for Spark instance group and application instance management. For more information, see [RESTful APIs](https://www.ibm.com/support/knowledgecenter/SSZU2E_2.3.0/get_started/locating_rest_apis.html).

## Uninstalling the Chart
Uninstall IBM Spectrum Conductor by using one of the following methods, assuming the IBM Spectrum Conductor release name is "spaas1":
- The dashboard: Navigate to "Workloads > Helm Releases" and find all release names with prefix "spaas1", including the master and all Spark instance groups, such as: spaas1, spaas1-sig1. Delete each one by clicking "Action > Delete".
- To remove IBM Spectrum Conductor and all Spark instance groups, run the following command:   
```
kubectl get deployment --namespace spaas1 | sed -e 1d | awk '{print $1}' | xargs helm delete --purge
kubectl delete namespace spaas1
```
Note: We recommend that you remove the Spark instance groups from the cluster management console. This will remove any Spark instance group deploymens from Kubernetes as well.

## Documentation
To learn more about using IBM Spectrum Conductor, see the online [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSZU2E_2.3.0/icp/conductor_icp.html).
