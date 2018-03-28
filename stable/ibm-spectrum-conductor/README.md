[![IBM Spectrum Conductor](https://developer.ibm.com/storage/wp-content/uploads/sites/91/2018/01/conductor.jpg)](https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=46ecec34-bd69-43f7-a627-7c469c1eddf8)
# IBM Spectrum Conductor with Spark and IBM Spectrum Conductor Deep Learning Impact - Technical Preview

## Introduction
IBM Spectrum Conductor with Spark helps you deploy Apache Spark applications efficiently and effectively. As an end-to-end solution for deploying and managing Spark applications, it is designed to address the requirements of organizations that adopt Spark technology for their big data analytics requirements. IBM Spectrum Conductor with Spark can support multiple instances of Apache Spark, maximizing resource utilization, and increasing performance and scale.

IBM Spectrum Conductor Deep Learning Impact is an add-on to IBM Spectrum Conductor with Spark that provides deep learning capabilities to your IBM Spectrum Conductor with Spark environment. It provides robust, end-to-end workflow support for deep learning lifecycle management from installation and configuration, data ingest and preparation, building, optimizing, and training the model, to inference and testing. 

## Chart Details
You can deploy IBM Spectrum Conductor with Spark as a Helm chart to quickly launch and run a master deployment with one pod in the Kubernetes cluster. The master deployment includes a cluster management console that you can access from your browser by way of an Http proxy or an ingress proxy that is deployed together with the master deployment. Through the cluster management console, a user with a certain role or permission (cluster administrator, consumer administrator, or has the Spark Instance Groups Configure permission) can create and manage multiple Spark instance groups for different tenants. One IBM Spectrum Conductor with Spark deployment represents one Spark as a service for a department or a business unit. 

Based on your preference, a Spark instance group contains a dedicated Spark version, a customized Spark configuration, notebook (Jupyter/Zeppelin) editions, and end user application dependencies. Once a Spark instance group is created, IBM Spectrum Conductor with Spark automatically generates its Docker image and deploys it onto the Kubernetes cluster. A Spark instance group is a first class Kubernetes deployment, upon which Kubernetes can manage its resource usage respectively. 

Each tenant logs in to the cluster management console through its own authority to access its own Spark instance group. A tenant can submit Spark batch jobs, notebook applications, and train their deep learning models and validate inference without overlapping with other tenants. Each Spark instance group grows its replicas based on its workload demands. You can also set up its replicas threshold by its namespace and an assigned quota.

Optionally, you can turn on deep learning capabilities in IBM Spectrum Conductor with Spark by enabling the IBM Spectrum Conductor Deep Learning Impact add-on. To enable IBM Spectrum Conductor Deep Learning Impact, make sure to meet any additional prerequisites and complete the additional installation steps.

> **Tips**: The IBM Spectrum Conductor with Spark 2.2.1 and IBM Spectrum Conductor Deep Learning Impact 1.1 Technical Preview has entitlement until **July 31 2018**, and is supported only on IBM Cloud Private version 2.1.0.1. 

This Helm chart also deploys a singleton service called cwsetcd, which helps to do host-ip mapping within an IBM Spectrum Conductor with Spark cluster.

## Prerequisites

### Storage
Make sure that the storage requests and kernel parameters are correctly set up before you click `configure` to install IBM Spectrum Conductor with Spark. 

This ibm-spectrum-conductor chart requires shared storage facilities to save metadata for high availability. 
- A Persistent Volume (>=3G) is mandatory for the IBM Spectrum Conductor with Spark master and Spark instance group high availability, with the storage class name specified by master.sharedStorageClassName ; 
- A Persistent Volume (>=2G) is mandatory for IBM Spectrum Conductor with Spark ETCD high availability, with storage class name specified by cluster.etcdSharedStorageClassName. Because the ETCD is a singleton deployment within the entire Kubernetes cluster, you need to specify only its storage the first time you install IBM Spectrum Conductor with Spark.  
  
Optionally, to enable IBM Spectrum Conductor Deep Learning Impact:   
  
- A Persistent Volume (>=4G each) is mandatory for shared deep learning storage for datasets etc, with the storage class name specified by dli.sharedFsStorageClassName.
- A Persistent Volume (>=4G each) is mandatory for storing deep learning frameworks and NCCL, with the storage class name specified by dli.frameworksStorageClassName. The packages must be in the following format:

```
    root@dli-cwsmaster:~# ls -l /opt/DL
    drwxr-xr-x  7 root root 4096 Feb  4 02:32 caffe
    drwxr-xr-x 10 root root 4096 Feb  1 18:25 CaffeOnSpark.spark161
    drwxr-xr-x 10 root root 4096 Feb  1 18:25 CaffeOnSpark.spark211
    drwxr-xr-x 10 root root 4096 Feb  1 18:25 CaffeOnSpark.spark220
    drwxr-xr-x  5 root root 4096 Feb  4 02:32 nccl
    drwxr-xr-x  4 root root 4096 Feb  4 02:32 tensorflow 
``` 
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

### Kernel parameters
Before you install IBM Spectrum Conductor with Spark, the `vm_max_map_count` kernel must be set on the Kubernetes node(s) to a value of at least 262144 for the ELK services to start and run normally. To set the vm_max_map_count kernel to a value of at least 262144:
- Set the kernel value dynamically to ensure that the change takes effect immediately:
````
  # sysctl -w vm.max_map_count=262144
````
- Set the kernel value in the /etc/sysctl.conf file to ensure that the change is still in effect when you restart your node:
````
  # vm.max_map_count=262144
````

### GPU dependencies
The Spectrum-Conductor out-of-box image does not contain the GPU bundled dependencies, such as Cuda and cuDNN for license consideration. 
To use the full GPU functions in IBM Spectrum Conductor with Spark, you must build a new image that conatins the GPU dependencies. For more information, see the [image instructions on IBM Cloud](https://git.ng.bluemix.net/ibmcws-icp-samples/icp-technical-preview/tree/master/icp-conductor-gpu-image).

## Resources Required
The `Conductor master CPU request` and `Conductor master memory request` parameters are the initial CPU and memory requests that are used to create the master container. The default values are 4 vcores and 4G memory. There is no limit enforcement against the master.

The `Compute container CPU request`, `Compute container memory request`, and `Compute container GPU request` parameters define how many resources each computer container requests; however, it cannot grow beyond the limits of `Compute container CPU limit`, `Compute container memory limit` and `Compute container GPU limit`. The default request values are 2 vcores and 2G memory for each container, with limits of 4 vcores and 6G memory. 

For the number that you can specify for the CPU and memory columns, refer to the [Kubernetes Specification](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).

The number of GPU is an integer equal or greater than zero. Default value is zero. A number greater than zero for `Compute container GPU request` is required to turn on IBM Spectrum Conductor with Spark on GPU, as well as to enable IBM Spectrum Conductor Deep Learning Impact. 

## Installing the Helm chart
Install by a helm command: For example, install a IBM Spectrum Conductor with Spark deployment with the name "spaas1" in the namespace "spass1"     
```
helm install ibm-spectrum-conductor --name spaas1 --namespace spaas1
```
To fine tune your IBM Spectrum Conductor with Spark installation, take the following configurations into account. 

### Name, namespace, and license
`Release Name` is the cluster name for the IBM Spectrum Conductor with Spark deployment. You can create multiple IBM Spectrum Conductor with Spark deployments with unique release names respectively. Try not to reuse a previously deleted release name unless you refresh the storage for cwsetcd.

`Target namespace` is the namespace for the IBM Spectrum Conductor with Spark deployment and is inherited by the newly created Spark instance groups in IBM Spectrum Conductor with Spark. Each IBM Spectrum Conductor with Spark deployment can define a unique namespace during creation. 

`license agreements` a check mark that is required to proceed. 

### Images and registries
The base image of the master container is defined by the `Conductor master image name` parameter, which is pulled from the `Conductor master image registry` parameter through the credentials defined by the `Conductor master image registry user` and `Conductor master image registry user password` parameters. You need to only adjust these parameters if you have a self-build image, for example you build an image with GPU drivers on top of the default image "ibmcom/spectrum-conductor:2.2.1".

After you create a Spark instance group, an image is built and persisted into the `Spark instance group image registry` parameter. The default place is the default image registry: "mycluster.icp:8500". The credential to access the registry is defined in the `Spark instance group image registry user` and `Spark instance group image registry user password` parameters.

### Dynamic scaling
The IBM Spectrum Conductor with Spark installation starts from only one master container. Then you start to create your Spark instance groups. Every Spark instance group initially has only one container. Once workloads reach the Spark master within the Spark instance group, the Spark master can request more containers from the Kubernetes API server based on its workloads demands. The total replicas of the Spark instance group can reach up to the value defined for the `Maximum computer containers` parameter. The Spark master scans only its current demands every X (defined by `The interval of dynamic scaling compute containers` parameter) seconds and requests the defined number of containers (defined by the `The unit of dynamic scaling compute containers` parameter). 

### GPU support (for IBM Spectrum Conductor with Spark only)
To turn on GPU support in IBM Spectrum Conductor with Spark, you must 
1. Set a positive number for the `Compute container GPU request` parameter.
2. Build your own image with the nvidia GPU driver on top of the default IBM Spectrum Conductor with Spark image "ibmcom/spectrum-conductor:2.2.1". See the [image instructions on IBM Cloud](https://git.ng.bluemix.net/ibmcws-icp-samples/icp-technical-preview/tree/master/icp-conductor-gpu-image).


### Enable IBM Spectrum Conductor Deep Learning Impact 

To use IBM Spectrum Conductor Deep Learning Impact 1.1 Technical Preview, you must build your own full image. The default image "spectrum-dli:1.1.0-x86_64" is a partial image that is missing required dependency packages. 

First, pull the IBM Spectrum Conductor Deep Learning Impact image from ibmcom/spectrum-dli:
    docker pull ibmcom/spectrum-dli:1.1.0-x86_64

Then, build your own full image on top of the partial image and push it to your own registry, refer to the [image instructions on IBM Cloud](https://git.ng.bluemix.net/ibmcws-icp-samples/icp-technical-preview/tree/master/icp-dli-dependency-image).

To enable deep learning, you must select the `Enable IBM Spectrum Conductor Deep Learning Impact 1.1 Technical Preview` option and specify the full image as `Conductor master image name` and set `Conductor master image registry`.


### The proxy for accessing the cluster management console
In the technical preview, IBM Spectrum Conductor with Spark supports two types of proxy services for accessing the cluster management console. The cluster management console is where you start to work with your Spark instance groups that include Spark batch/notebook workloads. 

- `HttpProxy`

HttpProxy is using a service called `cwsproxy` to redirect web accesses into the IBM Spectrum Conductor with Spark cluster management console, by setting up a network proxy at the client browser. For instance, from a Firefox browser where you want to access the cluster management console, open "Preferences -> Advanced -> Network -> Connection Settings", define "Manual proxy configuration" with a public IP of a node in the Kubernetes cluster. cwsproxy is a singleton service that is started only by the first IBM Spectrum Conductor with Spark installation that has HttpProxy configured, and then reused by the IBM Spectrum Conductor with Spark installation with HttpProxy. 

- Navigate to the cluster management console by using the url: https://`releasename`-`Conductor master name`:8443/platform. For example, https://spaas1-cwsmaster:8443/platform.

Note: `releasename`-`Conductor master name` (e.g. spaas1-cwsmaster) is also the master deployment name of the Conductor with spark installation. 

- `IngressProxy`

IngressProxy allows you to directly access the IBM Spectrum Conductor with Spark cluster management console. Every IBM Spectrum Conductor with Spark master deployment publishes an IngressProxy service with 4 node ports that can access IBM Spectrum Conductor with Spark internal services. IBM Spectrum Conductor Deep Learning Impact requires 7 node ports. 

1. Configure a base port and 4 successive ports (7 successive ports for IBM Spectrum Conductor Deep Learning Impact) that are available on every node in the Kubernetes cluster. 

2. Configure your client DNS server to resolve `releasename`-`Conductor master name` to any public IP of the ICP cluster. Alternately, you can configure the host mapping in the client host /etc/hosts for a UNIX OS or /etc/hosts counterpart for Windows OS. For instance, 
```
$ cat /etc/hosts
9.21.51.91 spaas1-cwsmaster
```
3. Navigate to the IBM Spectrum Conductor with Spark cluster management console by using the following URL: https://`releasename`-`Conductor master name`:`baseport`. For example, https://spaas1-cwsmaster:30443/platform.

Note: Due to the Web service design limitation from the Spark UI, the IngressProxy cannot guarantee to open every page of the Spark UI and the Spark History Server UI from the cluster management console. Spark version 1.6.1 and notebooks are not supported with Ingressproxy. For both of these cases, you can switch to use HttpProxy. 

### LDAP client
IBM Spectrum Conductor with Spark can import the same user base as the Kubernetes cluster, as long as the configuration of `LDAP Server IP` and `LDAP BaseDN` is consist with the configuration in the Kubernetes cluster. The LDAP user can log in to the cluster management console to work on their own Spark instance groups and workloads. 

### Architecture scheduling preferences
- For either `amd64` or `ppc64le`, leave them as default "2-No preference" if your cluster is homogeneous. 
- If you have a hybrid Kubernetes cluster with both Linux 64-bit and Linux on POWER 64-bit nodes, then you must pick one or the other when you deploy the Spectrum-Conductor Helm chart.   

## Applying Resource Enforcement
To apply a resource quota (for example, maximum 10 pods) against an IBM Spectrum Conductor with Spark cluster, you can attach the quota onto its namespace. For example:
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
| master.imageName | Conductor master image name       |   ibmcom/spectrum-conductor:2.2.1     |
| master.imagePullPolicy | Conductor master image pull policy              | IfNotPresent                           |
| master.registry | Conductor master image registry       |        |
| master.registryUser   | Conductor master image registry user  |              |
| master.registryPasswd    | Conductor master image registry user password |       |
| sig.maxReplicas       | Maximum computer containers      | 10                           |
| sig.cpu      | compute container cpu request         | 2000m                     |
| sig.memory   | compute container memory request        | 2048Mi             |
| sig.gpu      | compute container gpu request     |                               |
| sig.maxCpu      | compute container cpu limit     | 4000m        |
| sig.maxMemory   | compute container memory limit  | 6144Mi          |
| sig.maxGpu   | compute container gpu limit  | 2         |
| sig.ssAllocationUnit           | The unit of dynamic scaling compute containers      | 120           |
| sig.ssAllocationInterval      | The interval of dynamic scaling compute containers    | 60      |
| sig.registry | Spark instance group image registry       | mycluster.icp:8500       |
| sig.registryUser   | Spark instance group image registry user  | admin             |
| sig.registryPasswd    | Spark instance group image registry user password | admin    |
| dli.enabled     | Enables IBM Spectrum Conductor Deep Learning Impact    | false              |
| dli.frameworksStorageClassName  | Deep learning frameworks storage class name  |    |
| dli.sharedFsStorageClassName  | Deep learning training result storage class name   |             |
| cluster.ldapServerIp      | LDAP server IP |                            |
| cluster.ldapBaseDn        | LDAP BaseDN    |    dc=mycluster,dc=icp                    |
| cluster.etcdSharedStorageClassName       | Conductor ETCD HA storage class name |                               |
| cluster.proxyOption        | The proxy for accessing the cluster management console   |    HttpProxy                    |
| cluster.basePort        | IngressProxy only - Base Port    |     30443                   |
| arch.amd64         | x64 preference for target worker node       |     2 - No preference      |
| arch.ppc64le       | Power PPC64LE preference for target worker node       | 2 - No preference    |

Specify each parameter using the "--set key=value[,key=value]" argument to "helm install".

Alternatively, a YAML file that specifies the values for the parameters can be provided while you install the chart.

## Storage

### Storage class names
Use a known storage with a class name. If you leave the `XXX storage class name` parameter empty, Kubernetes uses the default storageclass that is defined by either the Kubernetes system administrator or any available PersistentVolume in the system that can satisfy the capacity request (e.g. 5Gi). 

## Limitations
- If you have a hybrid Kubernetes cluster with both Linux 64-bit and Linux on POWER 64-bit nodes, then you must pick one or the other when you deploy the Spectrum-Conductor Helm chart.  
- If you are using IngressProxy, due to the Web service design limitation from the Spark UI, the IngressProxy cannot guarantee to open every page of the Spark UI  and the Spark History Server UI from the cluster management console. 
- If you are using IngressProxy, Spark version 1.6.1 and notebooks are not supported. 

## Accessing IBM Spectrum Conductor with Spark
IBM Spectrum Conductor with Spark uses the following HTTPS services, which are available through either `HttpProxy` or `IngressProxy`:

- The `webgui` service hosts the cluster management console (available at https://*host_master*:*port*/platform). For more information, see [Cluster management console](https://www.ibm.com/support/knowledgecenter/SSZU2E_2.2.1/getting_started/management_console_overview.html).

After you log in to the cluster management console, if you encounter an error in a pop-up window, safely ignore the error to continue.

- The `REST` service hosts the REST APIs for resource management and package deployment. For more information, see [RESTful APIs](https://www.ibm.com/support/knowledgecenter/SSZU2E_2.2.1/get_started/locating_rest_apis.html).
- The `ascd` service hosts the REST APIs, which hosts the RESTful APIs for Spark instance group and application instance management. For more information, see [RESTful APIs](https://www.ibm.com/support/knowledgecenter/SSZU2E_2.2.1/get_started/locating_rest_apis.html).

## Uninstalling the Chart
Uninstall IBM Spectrum Conductor with Spark by using one of the following methods, assuming the IBM Spectrum Conductor with Spark release name is "spaas1":
- the dashboard: Click the menu: "Workloads -> Helm Releases", find all names with the prefix of the "spaas1" release name (will be one master and all the spark instance groups, such as: spaas1, spaas1-sig1, etc.), and click "Action -> Delete" on each. 
- To remove IBM Spectrum Conductor with Spark as well as all Spark instance created within it, run the following command:   
```
kubectl get deployment --namespace spaas1 | sed -e 1d | awk '{print $1}' | xargs helm delete --purge
kubectl delete namespace spaas1
```
Note: We recommend that you remove Spark instance groups from the cluster management console; which removes the deployments of the Spark instance groups from Kubernetes as well. 

## Documentation
To learn more about using IBM Spectrum Conductor with Spark, see the online [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSZU2E_2.2.1/icp/conductor_icp.html).

To learn more about using IBM Spectrum Conductor Deep Learning Impact, see the online [IBM Knowledge Center](http://www.ibm.com/support/knowledgecenter/SSWQ2D_1.1.0/icp/dli-icp.html).
