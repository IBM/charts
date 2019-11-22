## Requirements

- ICP >= 2.1.0
- [IBM Cloud Private CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/manage_cluster/install_cli.html)
- kubectl
- Shared Storage (GlusteFS or NFS)
- 3 Worker Nodes (Minimum 8 Cores/32 GB)

## Installing DSX Local on catalog
Using the IBM Cloud Private CLI tool and the bundle from PPA run:

```shell
bx pr load-ppa-archive --archive ibm-dsx-prod.tar.gz
```

You should see an output similar to this:
```
Creating temporary directory
OK

Expanding archive
OK

Reading manifest
OK

Importing docker images
  Processing image: privatecloud-cloudant-repo:v3.13.168
    Loading Image
    Tagging Image
    Pushing image as: mycluster.icp:8500/default/privatecloud-cloudant-repo:v3.13.168
...
...
...
  Processing image: privatecloud-wml-ingestion:v3.13.122
    Loading Image
    Tagging Image
    Pushing image as: mycluster.icp:8500/default/privatecloud-wml-ingestion:v3.13.122
OK

Uploading helm charts
  Processing chart: charts/ibm-dsx-prod-1.2.0.tgz
  Updating chart values.yaml
  Uploading chart
  {"url":"https://my-icp.cluster:8443/helm-repo/charts/index.yaml"}
OK

Archive finished processing
```

For the chart to correctly display in the Catalog after the installation. Go to the ICP UI `> Manage > Helm Repositories`, and select `Sync Repositories`

`ibm-dsx-prod` should be now visible and correctly displaying under `> Catalog > Helm Charts`

## Configure `kubectl`

Go to the ICP UI top right corner, select the user and `Configure Client`. Copy and paste in your terminal. The user must have administrator privileges for the following actions.

## Set the images scope to global:
Run the following command so images can be installed in any namespace, we need to set their scope to `global`.

With `kubectl` authenticated, run the following command:

```
for image in $(kubectl get images | tail -n +2 | awk '{ print $1; }'); do kubectl get image $image -o yaml | sed 's/scope: namespace/scope: global/' | kubectl apply -f -; done
```

You should see an output similar to this one:
```
image "dsx-u-core" configured
image "filemgmt" configured
image "jupyter-notebook" configured
image "privatecloud-cloudant-repo" configured
image "privatecloud-ml-deployment" configured
image "privatecloud-ml-online-scoring" configured
image "privatecloud-ml-pipelines-api" configured
image "privatecloud-nginx-repo" configured
image "privatecloud-pipeline" configured
image "privatecloud-portal-machine-learning" configured
image "privatecloud-portal-mlaas" configured
image "privatecloud-redis-repo" configured
image "privatecloud-repository" configured
image "privatecloud-rstudio" configured
image "privatecloud-spawner-api" configured
image "privatecloud-usermgmt" configured
image "privatecloud-wml-ingestion" configured
image "spark" configured
image "wmlbatchscoringservicehydra" configured
image "zeppelin-notebook" configured
```

If this warning `Warning: kubectl apply should be used on resource created by either kubectl create --save-config or kubectl apply` shows up, ignore it.

## Storage setup
Use **ONLY ONE** of the following options:

### A) Dynamic Provisioning
If using storage dynamic provisioning with GlusterFS, ensure that the appropriate storage class exists. This can be checked with:
```
kubectl get storageclasses | grep glusterfs
```
If nothing shows up, check with your cluster administrator about the availability of GlusterFS.

### B) NFS Storage:

If using NFS as the storage type, you will need to set-up beforehand the PersistentVolumes (PVs). For this the following information is needed:

- NFS Server ip
- NFS mount path

Also you will need to create 4 directories in the NFS mount path:

- cloudant
- redis
- spark-metrics
- user-home

With this information and the directories created, go to the ICP UI `> Platform > Storage` and create the following PVs with this information:

#### Cloudant:
##### General Tab:

|Name            |Capacity|Access Mode    |Storage Type|
|----------------|--------|---------------|------------|
|cloudant-repo-pv| 10Gi   |Read write many| NFS        |

##### Labels:
|Name            |Value        |
|----------------|-------------|
|assign-to       |cloudant     |

##### Parameters:
|Key             |Value                       |
|----------------|----------------------------|
|nfs.server      | **NFS_SERVER_IP**          |
|nfs.path        | **NFS_MOUNT_PATH**/cloudant|

#### Redis:
##### General:

|Name            |Capacity|Access Mode    |Storage Type|
|----------------|--------|---------------|------------|
|redis-repo-pv   | 10Gi   |Read write many| NFS        |

##### Labels:
|Name            |Value        |
|----------------|-------------|
|assign-to       |redis        |

##### Parameters:
|Key             |Value                    |
|----------------|-------------------------|
|nfs.server      | **NFS_SERVER_IP**       |
|nfs.path        | **NFS_MOUNT_PATH**/redis|


#### Spark Metrics:
##### General:

|Name            |Capacity|Access Mode    |Storage Type|
|----------------|--------|---------------|------------|
|spark-metrics-pv| 50Gi   |Read write many| NFS        |

##### Labels:
|Name            |Value        |
|----------------|-------------|
|assign-to       |spark-metrics|

##### Parameters:
|Key             |Value                            |
|----------------|---------------------------------|
|nfs.server      | **NFS_SERVER_IP**               |
|nfs.path        | **NFS_MOUNT_PATH**/spark-metrics|

#### User Home:

**The size of this PVs should adapt to your needs** , **100Gi** is the bare minimum that you should have, **1TB** is the recommended size.

##### General:

|Name            |Capacity|Access Mode    |Storage Type|
|----------------|--------|---------------|------------|
|user-home-pv    | 100Gi  |Read write many| NFS        |

##### Labels:
|Name            |Value        |
|----------------|-------------|
|assign-to       |user-home    |

##### Parameters:
|Key             |Value                        |
|----------------|-----------------------------|
|nfs.server      | **NFS_SERVER_IP**           |
|nfs.path        | **NFS_MOUNT_PATH**/user-home|

## Namespace
Create a namespace by going to the ICP UI `> Manage > Namespaces`, select `Create Namespace`. This is the namespace where all the DSX will live.

## Deploying DSX Local

### Configuration

Go to the ICP UI `> Catalog > Helm Charts`, and select `ibm-dsx-prod`, select `Configure`. Changing any of the following values is entirely optional. Check the [Persistence Parameters](#persistence-parameters), if using Dynamic Provisioning for storage.

The only required values on this steps is the `Release Name` and `Namespace` to deploy to. Set and appropriate name for the release, and select the namespace that was created in the previous step.

It is also highly recommended to set the correct amount of worker nodes with the `runtimes.workerNodes` parameter and ensure the `runtimes.preloadRuntimes` is set to true or checked. This will speed up the launch of notebooks after deployment, by preloading notebooks images in each worker node.

### Common parameters

| Parameter                          | Description                     | Default Value |
|------------------------------------|---------------------------------|---------------|
| image.pullPolicy                   | Image Pull Policy               | IfNotPresent  |
| persistence.useDynamicProvisioning | Use Dynamic PV Provisioning     | false         |
| persistence.storageClassName       | StorageClass to use for the PVs | _(None)_      |
| dsxservice.externalPort            | Port where DSX Local is exposed | 31843         |
| sparkContainer.workerReplicas      | Count of spark worker replicas  | 3             |
| runtimes.workerNodes               | Number of worker nodes          | 3             |
| runtimes.preloadRuntimes           | Should runtime images be preloaded| true             |

### Persistence Parameters

If `persistence.useDynamicProvisioning` has been set to `true`, the `.storageClassName` must be set to the appropriate one, unless the `default` StorageClass provides Dynamic Provisioning already.

If using NFS the `persistence.size` of each should match what was created in the previous step if not using Dynamic provisioning.

| Prefix/Suffix      | name                | persistence.existingClaimName| persistence.size|
|--------------------|---------------------|------------------------------|-----------------|
|**userHomePVC**     | user-home-pvc       | _(None)_                     | 100Gi           |
|**cloudantSrvPVC**  | cloudant-srv-mount  | _(None)_                     | 10Gi            |
|**redisPVC**        | redis-mount         | _(None)_                     | 10Gi            |
|**sparkMetricsPVC** | spark-metrics-pvc   | _(None)_                     | 50Gi            |

**Description**:
- `*.name` The name of the PVC
- `*.persistence.existingClaimName` Use an already existing PVC
- `*.persistence.size` The minimum size of the persistent volume to attach to/request.

### Containers Parameters

#### Image Parameters

Default parameters values for the images and tag to use in each container in the format `<prefix>.<suffix>`. **This should not be modified, unless there is a specific reason to do so**

|  Prefix/Suffix                | image.repository                    |image.tag|
|-------------------------------|-------------------------------------|---------|
|cloudantRepo                   |privatecloud-cloudant-repo           |v3.13.428|
|dsxConnectionBack              |dsx-connection-back                  |1.0.4    |
|dsxCore                        |dsx-core                             |v3.13.10 |
|dsxScriptedML|privatecloud-dsx-scripted-ml|v0.01.2|
|filemgmt|filemgmt|1.0.2|
|hdpzeppelinDsxD8a2ls2x|hdpzeppelin-dsx-d8a2ls2x|v1.0.10|
|jupyterD8a2rls2xShell|jupyter-dsx-d8a2ls2x|v1.0.11|
|jupyterD8a3rls2xShell|jupyter-dsx-d8a3ls2x|v1.0.7|
|jupyterGpuPy35|jupyter-gpu-py35|v1.0.9|
|mlOnlineScoring|privatecloud-ml-online-scoring|v3.13.6|
|mlPipelinesApi|privatecloud-ml-pipelines-api|v3.13.4|
|mllib|ml-libs|v3.13.30|
|nginxRepo|privatecloud-nginx-repo|v3.13.6|
|pipeline|privatecloud-pipeline|v3.13.3|
|portalMachineLearning|privatecloud-portal-machine-learning|v3.13.20|
|portalMlaas|privatecloud-portal-mlaas|v3.13.17|
|redisRepo|privatecloud-redis-repo|v3.13.431|
|repository|privatecloud-repository|v3.13.2|
|rstudio|privatecloud-rstudio|v3.13.8|
|spark|spark|1.5.1|
|sparkClient|spark-client|v1.0.2|
|sparkaasApi|sparkaas-api|v1.3.14|
|spawnerApiK8s|privatecloud-spawner-api-k8s|v3.13.5|
|usermgmt|privatecloud-usermgmt|v3.13.5|
|utilsApi|privatecloud-utils-api|v3.13.5|
|wmlIngestion|privatecloud-wml-ingestion|v3.13.2|

#### Resources Parameters

Default parameters values for the cpu and memory to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                |resources.requests.cpu|resources.limits.cpu|resources.requests.memory|resources.limits.memory|
|-------------------------------|----------------------|--------------------|-------------------------|-----------------------|
|cloudantRepo|500m|1000m|1024Mi|2048Mi|
|dsxConnectionBack|500m|1000m|128Mi|256Mi|
|dsxCore|1000m|2000m|512Mi|1024Mi|
|filemgmt|500m|1000m|256Mi|512Mi|
|mlOnlineScoring|200m|500m|1024Mi|2048Mi|
|mlPipelinesApi|200m|500m|128Mi|256Mi|
|nginxRepo|500m|1000m|256Mi|512Mi|
|pipeline|200m|500m|1024Mi|2048Mi|
|portalMachineLearning|100m|300m|128Mi|512Mi|
|portalMlaas|100m|300m|256Mi|512Mi|
|redisRepo|500m|1000m|256Mi|512Mi|
|repository|100m|300m|512Mi|1024Mi|
|spark|500m|1000m|2048Mi|4096Mi|
|spawnerApiK8s|200m|500m|128Mi|256Mi|
|usermgmt|500m|1000m|256Mi|512Mi|
|wmlIngestion|100m|300m|512Mi|1024Mi|


#### Replicas Parameters

In addition to the number of spark workers, there are some services that also offer the option to have several instance of the same service running for High Availability (HA), this can be adjusted depending on workload and resources available:

|  Prefix/Suffix                |replicas| Description             													|
|-------------------------------|--------|--------------------------------------------------|
|dsxConnectionBack|3| Connection to additional services
|dsxCore|3| Main Webapp portal
|mlPipelinesApi|2| Machine Learning Pipeline
|nginxRepo|3| Main Proxy that gets exposed
|portalMachineLearning|2| Projects Machine Learning portal
|portalMlaas|2| Published Machine Learning portal
|usermgmt|2| User management services

## Installing DSX Local
Check the deployments and when cloudant, redis, usermgmt, dsx-core, and ibm-nginx are up and ready, you can access the DSX UI by visiting:
https://MASTER_NODE_IP:dsxservice.externalPort/
