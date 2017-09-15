
<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [DSX Helm chart](#dsx-helm-chart)
	- [Requirements](#requirements)
	- [Accessing DSX](#accessing-dsx)
	- [Detailed example](#detailed-example)
	- [Test drive DSX](#test-drive-dsx)
		- [Jupyter](#jupyter)
		- [Zeppelin](#zeppelin)
		- [RStudio](#rstudio)

<!-- /TOC -->

# DSX Developer Edition Helm Chart (Beta)

Data Science Experience (DSX) is delivered as an integrated set of pods and kubernetes services. DSX pods use kube-dns to discover each other by a _fixed_ name - hence its important that each independent copy of DSX gets deployed in a separate Kube namespace.

## Requirements

1). **A persistent volume is required**

2). **A unique node port** must be selected at helm install time to be able to access the DSX web application from a browser.

3). **One Kubernetes namespace per DSX instance**

for example - here is how one could set these properties via  helm install :

```
--namespace <a namespace> --set dsxservice.externalPort=<a node port>
```

If these properties are not set, the *'default'* namespace and node port *32443* will be used.


## Accessing DSX

from a browser, use
``
http://<external ip>:<nodeport>
``
to access the application.


## Detailed example

1). Note: You must ensure that a persistent volume exists for DSX to work.

example of creating a _dummy_ NFS PV:

```

cat test-user-home-pv2.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: tmp-user-home-pv-dsx
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <nfs server ip>
    path: <your path>


kubectl create -f ./test-user-home-pv2.yaml

```
*Warning* . this dummy PV is just for illustration. please ensure that a real ReadWriteMany PV is created upfront**

2). install via helm into a namespace (example - dsx-test07)

```

helm install --name dsx07 --namespace dsx-test07 --set dsxservice.externalPort=32000 ibm-dsx-dev

```

## Configuration

Parameters
------------
The helm chart has the following Values that can be overriden using the install `--set` parameter. For example:

`helm install --set dsxservice.externalPort=32000`

**Common Parameters**

| Parameter                                 | Description                         | Default                      | Constraints |
|-------------------------------------------|-------------------------------------|------------------------------|-------------|
| image.secret                              | The secret to pull the images       | dsx-cumulus-registry-secret  |             |
| image.pullPolicy                          | Image Pull Policy                   | IfNotPresent                 |             |
| dsxservice.externalPort                   | The external port                   | 32443                        |             |
| userHomePvc.name                          | The PVC name                        | user-home-pvc                |             |
| userHomePvc.persistence.existingClaimName | Existing claim name                 |                              |             |
| userHomePvc.persistence.storageClassName  | Storage class name                  |                              |             |
| userHomePvc.persistence.size              | Storage Size                        | 1Gi                          | Min: 1Gi    |


DSX Persistence storage requires the following setting which can not be modified at deployment.

| Parameter                                 | Description                         | Default                      | Constraints |
|-------------------------------------------|-------------------------------------|------------------------------|-------------|
| userHomePvc.persistence.enabled           | Is persistence storage enabled      | true                         | required    |
| userHomePvc.persistence.accessMode        | Storage Access Mode                 | ReadWriteMany                | required    |


**UX Container Parameters**

Example
`helm install --set dsxUxServerContainer.image.tag=v1`

Note: Each value starts with *dsxUxServerContainer*

| Parameter                     | Description                                   | Default                                     | Constraints |
|-------------------------------|-----------------------------------------------|---------------------------------------------|-------------|
| .image.repository             | The image repository                          | "na.cumulusrepo.com/homer/dsx_starter_ux"   |             |
| .image.tag                    | The image version/tag                         | v1                                          |             |
| .resources.requests.cpu       | CPU Request                                   | 1000m                                       | Min: 1000m  |
| .resources.requests.memory    | Memory Request                                | 256Mi                                       | Min: 256Mi  |
| .resources.limits.cpu         | CPU Limit                                     | 2000m                                       |             |
| .resources.limits.memory      | Memory Limit                                  | 512Mi                                       |             |


**Zeppelin Container Parameters**

Example
`helm install --set zeppelinServerContainer.image.tag=v1`

Note: Each value starts with *zeppelinServerContainer*

| Parameter                     | Description                                   | Default                                     | Constraints |
|-------------------------------|-----------------------------------------------|---------------------------------------------|-------------|
| .image.repository             | The image repository                          | "na.cumulusrepo.com/homer/dsx_starter_ux"   |             |
| .image.tag                    | The image version/tag                         | v1                                          |             |
| .resources.requests.cpu       | CPU Request                                   | 500m                                        | Min: 500m   |
| .resources.requests.memory    | Memory Request                                | 2048Mi                                      | Min: 2048Mi |
| .resources.limits.cpu         | CPU Limit                                     | 1000m                                       |             |
| .resources.limits.memory      | Memory Limit                                  | 4096Mi                                      |             |


**Jupyter Container Parameters**

Example
`helm install --set notebookServerContainer.image.tag=v1`

Note: Each value starts with *notebookServerContainer*

| Parameter                     | Description                                   | Default                                        | Constraints |
|-------------------------------|-----------------------------------------------|------------------------------------------------|-------------|
| .image.repository             | The image repository                          | "na.cumulusrepo.com/homer/dsx_starter_jupyter" |             |
| .image.tag                    | The image version/tag                         | v1                                             |             |
| .resources.requests.cpu       | CPU Request                                   | 500m                                           | Min: 500m   |
| .resources.requests.memory    | Memory Request                                | 1024Mi                                         | Min: 1024Mi |
| .resources.limits.cpu         | CPU Limit                                     | 2000m                                          |             |
| .resources.limits.memory      | Memory Limit                                  | 512Mi                                          |             |


**RStudio Container Parameters**

Example
`helm install --set rstudioServerContainer.image.tag=v1`

Note: Each value starts with *rstudioServerContainer*

| Parameter                     | Description                                   | Default                                         | Constraints |
|-------------------------------|-----------------------------------------------|-------------------------------------------------|-------------|
| .image.repository             | The image repository                          | "na.cumulusrepo.com/homer/dsx_starter_rstudio"  |             |
| .image.tag                    | The image version/tag                         | v1                                              |             |
| .resources.requests.cpu       | CPU Request                                   | 500m                                            | Min: 500m   |
| .resources.requests.memory    | Memory Request                                | 2Gi                                             | Min: 2Gi    |
| .resources.limits.cpu         | CPU Limit                                     | 1000m                                           |             |
| .resources.limits.memory      | Memory Limit                                  | 3Gi                                             |             |


3). Verify deployment

Use kubectl against the targetted namespace to verify if the pods and services are running correctly. Note that the DSX images are big and can take quite a bit of time to be pulled from public registries.

``
kubectl get pods,svc -n=dsx-test07 -o wide
``



```
NAME                                  READY     STATUS    RESTARTS   AGE       IP              NODE
po/dsx-ux-server-318946341-rdx1k      1/1       Running   4          12m       192.168.0.29    187c-master-2.fyre.ibm.com
po/notebook-server-1006682539-zb2mj   1/1       Running   0          12m       192.168.96.33   187c-master-1.fyre.ibm.com
po/rstudio-server-1880015003-d2d1t    1/1       Running   0          12m       192.168.96.34   187c-master-1.fyre.ibm.com
po/zeppelin-server-757514753-hzgv7    1/1       Running   0          12m       192.168.0.28    187c-master-2.fyre.ibm.com

NAME           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE       SELECTOR
svc/dsx-ux     10.3.75.55      <nodes>       443:31126/TCP,80:32000/TCP   12m       component=dsx-ux-server,run=dsx-ux-server-deployment-pod
svc/jupyter    10.10.173.198   <none>        8888/TCP                     12m       component=notebook-server,run=notebook-server-deployment-pod
svc/rstudio    10.1.211.93     <none>        8787/TCP                     12m       component=rstudio-server,run=rstudio-server-deployment-pod
svc/zeppelin   10.12.87.162    <none>        8080/TCP                     12m       component=zeppelin-server,run=zeppelin-server-deployment-pod
```

4). Access the newly installed DSX instance

From the browser - acccess  
``
http://<host>:32000
``

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
