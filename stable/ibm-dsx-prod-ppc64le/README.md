# DSX Local on Power Chart
Data Science Experience (DSX) Local on Power is delivered as an interconnected set of pods and kubernetes services, running across multiple namespaces. DSX Local on Power supports one installation per cluster, all worker nodes of the cluster should be Power nodes.

## Requirements

### Permissions:

You need admin privileges to deploy this Chart due to its multiple namespace
nature. To do this, login into your ICp cluster, click the `Admin` in the top
right of the UI, and select `Configure Client`. Copy and paste in your terminal.

You will need to create a `RoleBinding` to allow the `spawner-api` service to deploy notebooks. After getting authenticated in the terminal, run this command:

```shell
kubectl create rolebinding ibm-private-cloud-admin-binding --clusterrole=admin --user="system:serviceaccount:ibm-private-cloud:default" --namespace=ibm-private-cloud
```

### Storage:

Cluster with Dynamic Provisioning enabled (e.g. GlusterFS), and set the parameter during deployment:
```
--set persistence.useDynamicProvisioning=true
```

**OR**

Four `PersistentVolume`s in a shared storage (e.g. NFS) with the following specs:

1. Two `user-home` persistent volumes:

	```yaml
	apiVersion: v1
	kind: PersistentVolume
	metadata:
	  name: user-home-pv-1
	  labels:
	    assign-to: "user-home"
	spec:
	  capacity:
	    storage: 100Gi
	  accessModes:
	    - ReadWriteMany
	  persistentVolumeReclaimPolicy: Retain
	  nfs:
	    server: <NFS Server>
	    path: <NFS PATH>/user-home
	---
	apiVersion: v1
	kind: PersistentVolume
	metadata:
	  name: user-home-pv-2
	  labels:
	    assign-to: "user-home"
	spec:
	  capacity:
	    storage: 100Gi
	  accessModes:
	    - ReadWriteMany
	  persistentVolumeReclaimPolicy: Retain
	  nfs:
	    server: <NFS Server>
	    path: <NFS PATH>/user-home
	```

2. One `spark-metrics` persistent volume:
	```yaml
	apiVersion: v1
	kind: PersistentVolume
	metadata:
	  name: spark-metrics-pv-1
	  labels:
	    assign-to: "spark-metrics"
	spec:
	  capacity:
	    storage: 50Gi
	  accessModes:
	    - ReadWriteMany
	  persistentVolumeReclaimPolicy: Retain
	  nfs:
	    server: <NFS SERVER>
	    path: <NFS PATH>/spark-metrics
	```

3. One `cloudant` persistent volume:
	```yaml
	apiVersion: v1
	kind: PersistentVolume
	metadata:
	  name: cloudant-repo-pv
	  labels:
	    assign-to: "cloudant-repo"
	spec:
	  capacity:
	    storage: 10Gi
	  accessModes:
	    - ReadWriteMany
	  persistentVolumeReclaimPolicy: Retain
	  nfs:
	    server: <NFS SERVER>
	    path: <NFS PATH>/cloudant
	```

4. One `redis` persistent volume:
	```yaml
	apiVersion: v1
	kind: PersistentVolume
	metadata:
	  name: redis-repo-pv
	  labels:
	    assign-to: "redis-repo"
	spec:
	  capacity:
	    storage: 10Gi
	  accessModes:
	    - ReadWriteMany
	  persistentVolumeReclaimPolicy: Retain
	  nfs:
	    server: <NFS SERVER>
	    path: <NFS PATH>/redis
	```

**FOR NFS YOU NEED TO CREATE EACH OF THE DIRECTORIES MANUALLY FIRST BEFORE DEPLOYING THE PVS**
```
<NFS PATH>/user-home
<NFS PATH>/spark-metrics
<NFS PATH>/cloudant
<NFS PATH>/redis
```


You can create the PVs using the above templates by executing:

```
kubectl create -f <yaml-file>
```

### Namespaces:

This deployment also requires 4 namesapces to be created before deployment:

```
sysibmadm-data
sysibm-adm
ibm-private-cloud
dsxl-ml
```

Make sure this namespaces are shown as active under the ICp UI in
`Admin > Namespaces`.

## Deploying DSX Local on Power

This Chart requires to be deployed 4 times, the example below uses the `dsxns` prefix for each of the release names, you could choose something different:

```shell
helm install --namespace sysibmadm-data --name dsxns1  stable/ibm-dsx-prod-ppc64le
helm install --namespace sysibm-adm --name dsxns2 stable/ibm-dsx-prod-ppc64le
helm install --namespace dsxl-ml --name dsxns3 stable/ibm-dsx-prod-ppc64le
helm install --namespace ibm-private-cloud --name dsxns4 stable/ibm-dsx-prod-ppc64le
```

You can add the `--debug --dry-run` options to each of the commands to show the
templates being generated before doing the actual deployment.

## Accessing DSX Local on Power

After deploying the namespace `ibm-private-cloud` you should see a message:

```
NOTES:
Data Science Experience (DSX) is delivered as an interconnected set of pods and kubernetes services. DSX Local on Power supports one installation per cluster.
A unique node port must be selected to be able to access the DSX web application.

When the ibm-nginx deployment is ready, use https://<external ip>:31443 to access the application.
```

Which indicates on which port is DSX Local on Power running. By default is port `31843`. Login for the first time with `admin/password`

## Uninstalling DSX Local on Power

To uninstall DSX Local on Power simply delete the 4 releases that were deployed:

```
helm delete --purge dsxns1 dsxns2 dsxns3 dsxns4
```

This will not delete the `PesistentVolumes`, if these were created manually.

## Configuration
The following tables show parameters that can be customized eithe by using `--set <paramter>=<value>` one by one, or the _recommended_ method of having a `overrides.yaml` file with the list of values and passing them this file during deployment with `-f overrides.yaml`.

### Common parameters

| Parameter                          | Description                     | Default Value |
|------------------------------------|---------------------------------|---------------|
| image.pullPolicy                   | Image Pull Policy               | IfNotPresent  |
| persistence.useDynamicProvisioning | Use Dynamic PV Provisioning     | false         |
| dsxservice.externalPort            | Port where DSX Local is exposed | 31843         |
| sparkContainer.workerReplicas      | Count of spark worker replicas  | 3             |


### Persistence Parameters

If `persistence.useDynamicProvisioning` has been set to `true`, the `.storageClass` of each of the following values should be set to the class that provides this feature, unless the `default` StorageClass provides Dynamic Provisioning already. The following table show the default values for each of the `<prefix>.<suffix>`:

| Prefix/Suffix      | name                | persistence.storageClass | persistence.existingClaimName| persistence.size|
|--------------------|---------------------|--------------------------|------------------------------|-----------------|
|**userHomePvc**     | user-home-mount     | _(None)_                 | _(None)_                     | 100Gi           |
|**cloudantSrvPvc**  | cloudant-srv-mount  | _(None)_                 | _(None)_                     | 10Gi            |
|**redisPvc**        | redis-mount         | _(None)_                 | _(None)_                     | 10Gi            |
|**sparkMetricsPvc** | spark-metrics-mount | _(None)_                 | _(None)_                     | 50Gi            |

**Description**:
- `*.name` The name of the PVC
- `*.persistence.storageClass` The storage class to use with the PVC (required for Dynamic Provisioning)
- `*.persistence.existingClaimName` Use an already existing PVC
- `*.persistence.size` The minimum size of the persistent volume to attach to/request.

### Containers Parameters

#### Image Parameters

Default parameters values for the images and tag to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                | image.repository                    |image.tag|
|-------------------------------|-------------------------------------|---------|
|**cloudantRepoContainer**			|privatecloud-cloudant-repo						|v3.13.168-ppc64le|
|**usermgmtContainer**					|privatecloud-usermgmt								|v3.13.169-ppc64le|
|**nginxContainer**							|privatecloud-nginx-repo							|v3.13.109-ppc64le|
|**dsxCoreContainer**						|dsx_core															|v3.13.72-ppc64le	|
|**redisRepoContainer**					|privatecloud-redis-repo							|v3.13.167-ppc64le|
|**filemgmtContainer**					|filemgmt															|1.0.1-ppc64le		|
|**spawnerApiContainer**				|privatecloud-spawner-api							|v3.13.106-ppc64le|
|**rstudioContainer**						|privatecloud-rstudio									|v3.13.1-ppc64le		|
|**jupyterContainer**						|jupyter-notebook											|v3.13.1-ppc64le		|
|**zeppelinContainer**					|zeppelin-notebook										|v3.13-ppc64le		|
|**sparkContainer**							|spark																|1.4-ppc64le			|
|**dsxConnectionBackContainer**	|dsx-connection-back									|1.0.0-ppc64le		|
|**mlDeploymentContainer**			|privatecloud-ml-deployment						|v3.13.125-ppc64le|
|**mlScoringContainer**					|privatecloud-ml-online-scoring				|v3.13.125-ppc64le|
|**mlPipelinesContainer**				|privatecloud-ml-pipelines-api				|v3.13.122-ppc64le|
|**pipelineContainer**					|privatecloud-pipeline								|v3.13.126-ppc64le|
|**portalMLContainer**					|privatecloud-portal-machine-learning	|v3.13.125-ppc64le|
|**portalMLAASContainer**				|privatecloud-portal-mlaas						|v3.13.133-ppc64le|
|**repositoryContainer**				|privatecloud-repository							|v3.13.129-ppc64le|
|**wmlBatchScoringContainer**		|wmlbatchscoringservicehydra					|v3.13.44-ppc64le	|
|**wmlIngestionContainer**			|privatecloud-wml-ingestion						|v3.13.122-ppc64le|

#### Resources Parameters

Default parameters values for the cpu and memory to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                |resources.requests.cpu|resources.limits.cpu|resources.requests.memory|resources.limits.memory|
|-------------------------------|----------------------|--------------------|-------------------------|-----------------------|
|**cloudantRepoContainer**			|500m                  |1000m               |1024Mi                   |2048Mi                 |
|**usermgmtContainer**					|500m                  |1000m               |256Mi                    |512Mi                  |
|**nginxContainer**							|500m                  |1000m               |256Mi                    |512Mi                  |
|**dsxCoreContainer**						|1000m                 |2000m               |512Mi                    |1024Mi                 |
|**redisRepoContainer**					|500m                  |1000m               |256Mi                    |512Mi                  |
|**filemgmtContainer**					|500m                  |1000m               |256Mi                    |512Mi                  |
|**spawnerApiContainer**				|200m                  |500m                |128Mi                    |256Mi                  |
|**sparkContainer**							|500m                  |1000m               |2048Mi                   |4096Mi                 |
|**dsxConnectionBackContainer**	|500m                  |1000m               |128Mi                    |256Mi                  |
|**mlDeploymentContainer**			|200m                  |500m                |512Mi                    |1024Mi                 |
|**mlScoringContainer**					|200m                  |500m                |1024Mi                   |2048Mi                 |
|**mlPipelinesContainer**				|200m                  |500m                |128Mi                    |256Mi                  |
|**pipelineContainer**					|200m                  |500m                |128Mi                    |256Mi                  |
|**portalMLContainer**					|100m                  |300m                |128Mi                    |256Mi                  |
|**portalMLAASContainer**				|100m                  |300m                |256Mi                    |512Mi                  |
|**repositoryContainer**				|100m                  |300m                |512Mi                    |1024Mi                 |
|**wmlBatchScoringContainer**		|100m                  |300m                |512Mi                    |1024Mi                 |
|**wmlIngestionContainer**			|100m                  |300m                |512Mi                    |1024Mi                 |


#### Replicas Parameters

In addition to the number of spark workers, there are some services that also offer the option to have several instance of the same service running for High Availability (HA), this can be adjusted depending on workload and resources available:

|  Prefix/Suffix                |replicas| Description             													|
|-------------------------------|--------|--------------------------------------------------|
|**usermgmtContainer**					|2		   | User management services													|
|**nginxContainer**							|3	     | Main proxy that communicates and exposes services|
|**dsxCoreContainer**						|3       | Main portal webapp																|
|**dsxConnectionBackContainer**	|3    	 | Connection to external services									|
|**portalMLContainer**					|2 		   | Additional Machine learning services portal			|
|**portalMLAASContainer**				|2   		 | Main Machine Learning and model management portal|

