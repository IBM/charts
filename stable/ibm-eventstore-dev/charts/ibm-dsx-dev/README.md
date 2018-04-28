
# DSX Developer Edition Helm Chart

Data Science Experience (DSX) is delivered as an integrated set of pods and kubernetes services. DSX pods use kube-dns to discover each other by a _fixed_ name - hence its important that each independent copy of DSX gets deployed in a separate Kube namespace.

## Requirements

### Namespace

Deploying DSX Developer requires a namesapce to be created before deployment.

You can create a namespace by executing:

```shell
kubectl create namespace <a namespace>
```
You can also create a namespace from ICp UI by following these steps:
- From Menu navigate to Manage -> Namespaces
- Click Create Namespace Button
- Enter a namespace and click Create button


### Storage

Deploying DSX Developer requires two persistent volumes.

Creating two `PersistentVolume`s in a shared storage (e.g. NFS) with the following specs:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
  labels:
    assign-to: "user-home"
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>/user-home
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
  labels:
    assign-to: "spark-metrics"
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>/tmp/spark-events
```
**Note:** Ensure that `<NFS PATH>/user-home` and `<NFS PATH>/tmp/spark-events` have write permission before deploying the persistent volume.

If you want to use GlusterFS, please follow the steps below to create PV for user-home.  You need to do the same for `spark-events`

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    component: glusterfs
  name: glusterfs-3-cluster
  namespace: <namespace>
spec:
  ports:
  - port: 1
    protocol: TCP
    targetPort: 1
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
---
apiVersion: v1
kind: Endpoints
metadata:
  name: glusterfs-3-cluster
  namespace: <namespace>
subsets:
- addresses:
  - ip: <worker node IP>
  - ip: <worker node IP>
  - ip: <worker node IP>
  ports:
  - port: 1
    protocol: TCP
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: user-home-pv
  labels:
    assign-to: "user-home"
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  glusterfs:
    endpoints: glusterfs-3-cluster
    path: user-home
```
**Note:** Ensure that `<NFS PATH>/user-home` and `<NFS PATH>/tmp/spark-events` have write permission before deploying the persistent volume.

If you want to use GlusterFS, please follow the steps below to create PV for `user-home`.  You need to do the same for `spark-events`

```yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    component: glusterfs
  name: glusterfs-3-cluster
  namespace: <namespace>
spec:
  ports:
  - port: 1
    protocol: TCP
    targetPort: 1
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
---
apiVersion: v1
kind: Endpoints
metadata:
  name: glusterfs-3-cluster
  namespace: <namespace>
subsets:
- addresses:
  - ip: <worker node IP>
  - ip: <worker node IP>
  - ip: <worker node IP>
  ports:
  - port: 1
    protocol: TCP
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: user-home-pv
  labels:
    assign-to: "user-home"
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  glusterfs:
    endpoints: glusterfs-3-cluster
    path: user-home
```

**Note:** Ensure that `user-home` is created and started before deploying the persistent volume.  To do that, please following the steps below:

```
kubectl get pod
kubectl exec -it <glusterfs pod> -- sh

gluster volume create user-home replica 3 arbiter 1 <ip1:dir> <ip2:dir> <ip3:dir>
gluster volume start user-home
```

=======
**Note:** Ensure that `user-home` is created and started before deploying the persistent volume.  To do that, please following the steps below:

```
kubectl get pod
kubectl exec -it <glusterfs pod> -- sh

gluster volume create user-home replica 3 arbiter 1 <ip1:dir> <ip2:dir> <ip3:dir>
gluster volume start user-home
```

You can create the PVs using the above templates by executing:

```shell
kubectl create -f <yaml-file>
```

You can also create the PVs from ICp UI by following these steps:
- From Menu navigate to Platform -> Storage
- Click Create PersistentVolume button

## Deploying DSX Developer

To deploy DSX Developer using ICp UI, please do the following steps:
- From Menu navigate to Catalog -> Helm charts
- Click Configure button
- Fill in release name
- Fill in namespace
- Accept the license agreement
- Click on Install button

Once the install process is completed, open a browser and enter `http://<external ip>:32443`

You can deploy DSX Developer manually by executing:
```shell
helm install --namespace <a namespace> --name <a release name> ibm-dsx-dev
```

You can add the `--debug --dry-run` options to show the template being generated before doing the actual deployment.

Note: By default is port `32443`. If you want to use a different port, you can specify your port by executing:
```shell
helm install --namespace <a namespace> --name <a release name> ibm-dsx-dev --set dsxservice.externalPort=<a node port>
```

## Accessing DSX Developer

from a browser, use
``
http://<external ip>:<node port>
``
to access the application. Login for the first time with `admin/password`

## Uninstalling DSX Developer

To uninstall DSX Developer simply delete the name that was deployed:

```shell
helm delete --purge <release name>
```

Note: This will not delete the `PesistentVolume`, if it was created manually.

## Detailed example

This sample deployment uses NFS PV.

1) Create a yaml named user-home-pv-dsx.yaml file with the following content:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: user-home-pv
  labels:
    assign-to: "user-home"
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 1.20.20.20
    path: /mnt/nfs/user-home
---
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: spark-metrics-pv
    labels:
      assign-to: "spark-metrics"
  spec:
    capacity:
      storage: 50Gi
    accessModes:
      - ReadWriteMany
    nfs:
      server: 1.20.20.20
      path: /mnt/nfs/tmp/spark-events
```
Note: Please ensure that /mnt/user-home is created in your NFS server.

2) Create a PV:

```shell
kubectl create -f ./user-home-pv-dsx.yaml
```

3) Create a namespace:

```shell
kubectl create namespace dsx-desktop
```

4) Deploy DSX Developer using the helm install command:

```shell
helm install --name dsx01 --namespace dsx-desktop --set dsxservice.externalPort=32000 ibm-dsx-dev
```

5) Open a browser and enter:
``
http://<external ip>:32000
``

6) Uninstall DSX Developer:

```shell
helm delete --purge dsx01
```

## Configuration
The following tables show parameters that can be customized eithe by using `--set <paramter>=<value>` one by one, or the _recommended_ method of having a `overrides.yaml` file with the list of values and passing them this file during deployment with `-f overrides.yaml`.


### Common Parameters

| Parameter                                 | Description                       | Default Value                |
|-------------------------------------------|-----------------------------------|------------------------------|
| image.pullPolicy                          | Image Pull Policy                 | IfNotPresent                 |
| persistence.useDynamicProvisioning        | Use Dynamic PV Provisioning       | false                        |
| dsxservice.externalPort                   | The external port                 | 32443                        |


### Persistence Parameters

If `persistence.useDynamicProvisioning` has been set to `true`, the `.storageClass` of each of the following values should be set to the class that provides this feature, unless the `default` StorageClass provides Dynamic Provisioning already. The following table show the default values for each of the `<prefix>.<suffix>`:

| Prefix/Suffix      | name                | persistence.storageClass | persistence.existingClaimName| persistence.size|
|--------------------|---------------------|--------------------------|------------------------------|-----------------|
|**userHomePvc**     | user-home     | _(None)_                 | _(None)_                     | 1Gi             |


DSX Persistence storage requires the following setting which can not be modified at deployment.

| Parameter                                 | Description                         | Default            | Constraints  |
|-------------------------------------------|-------------------------------------|--------------------|--------------|
| userHomePvc.persistence.enabled           | Is persistence storage enabled      | true               | required     |
| userHomePvc.persistence.accessMode        | Storage Access Mode                 | ReadWriteMany      | required     |

**Description**:
- `name` The name of the PVC
- `persistence.storageClass` The storage class to use with the PVC (required for Dynamic Provisioning)
- `persistence.existingClaimName` Use an already existing PVC
- `persistence.size` The minimum size of the persistent volume to attach to/request.

### Containers Parameters

#### Image Parameters

Default parameters values for the images and tag to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                | image.repository                      |image.tag|
|-------------------------------|---------------------------------------|---------|
|**dsxUxServerContainer**	  		|hybridcloudibm/dsx-dev-icp-dsx-core		|v1.015   |
|**zeppelinServerContainer**		|hybridcloudibm/dsx-dev-icp-zeppelin		|v1.015   |
|**notebookServerContainer**		|hybridcloudibm/dsx-dev-icp-jupyter			|v1.015   |
|**rstudioServerContainer**			|hybridcloudibm/dsx-dev-icp-rstudio 		|v1.015   |

#### Resources Parameters

Default parameters values for the cpu and memory to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                |resources.requests.cpu|resources.limits.cpu|resources.requests.memory|resources.limits.memory|
|-------------------------------|----------------------|--------------------|-------------------------|-----------------------|
|**dsxUxServerContainer**		  	|1000m                 |2000m               |256Mi                    |512Mi                  |
|**zeppelinServerContainer**		|500m                  |1000m               |2048Mi                   |4096Mi                 |
|**notebookServerContainer**		|500m                  |2000m               |1024Mi                   |2048Mi                 |
|**rstudioServerContainer**	  	|500m                  |1000m               |2Gi                      |3Gi                    |


## Test drive DSX

For more details visit  https://datascience.ibm.com/desktop  
and for additional documentation https://datascience.ibm.com/docs/content/desktop/welcome.html


### Jupyter

1). Create a new Jupyter Notebook

My Notebooks >  Jupyter Notebooks and click on   (+) add new notebook  -> from URL

Import scikit-learn Cookbook from URL:
    ``
    https://raw.githubusercontent.com/ibm-et/jupyter-samples/master/scikit-learn/sklearn_cookbook.ipynb
    ``

2). Start afresh:

``
    Cell -> All Output -> Clear
``

3). Run

all cells (note some parts are memory intensive)

``
    Cell -> Run All
``

### Zeppelin

1). Download a sample notebook

For example:

``
wget --no-check-certificate  -O starter-bank.json "https://raw.githubusercontent.com/hortonworks-gallery/zeppelin-notebooks/master/2A94M5J1Z/note.json"
``

2). Add a  Zeppelin notebook:
``
My Notebooks >  Zeppelin Notebooks and click on   (+) add new notebook   -> from file
``

Pick starter-bank.json (the sample file you downloaded earlier)

3). Start afresh

Click on the eraser icon button at the top to clear any existing output

4). Run

Click on the play icon button at the top to run all paragraphs


### RStudio

1). In the console - setup  spark connection

paste the following code:

```
library(sparklyr)
library(dplyr)
sc <- spark_connect(master = "local")
```
(or you can use the Spark view pane on the top right too)

2). run the 'mtcars' sample:

```
source('~/ibm-sparkaas-demos/sparkaas_mtcars.R', echo=TRUE)
```

You will see the table mtcars open up. You can also switch to the Spark pane  (top right) & open up other tables

Open up the File (bottom right) Pane and  open up the ibm-sparkaas-demos/sparkaas_mtcars.R sample to see what exactly it does. You can also use the R Script editor to re-run or edit/save as etc.
