
## Introduction

Transformation Advisor has the capability to quickly evaluate your on-premise applications for rapid deployment on WebSphere Application Server and Liberty on Public and/or Private Cloud environments. 

Transformation Advisor will:
 - Gather your preferences regarding your current and desired target environments
 - Via a downloaded agent it will analyse your existing applications and upload the results to a single location
 - Provide recommendations for migration and development cost estimates to undertake the migrations across different platforms

The Transformation Advisor is delivered as an interconnected set of pods and kubernetes services. It consists of three pods - a server, a ui and a database. 

## Persistence

By default Transformation Advisor expects a Persistence Volume (PV) to be available. You can change the default value to use an existing claim, or to not use any storage. Please see below for the different options:

### Create a Persistence Volume:

Create pv.yaml file with following content

```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: transadv-pv-volume
  labels:
    type: local
spec:
  persistentVolumeReclaimPolicy: Recycle
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/tmp/data"
```

Create pv

```
kubectl create -f pv.yaml
```

### Using an existing Persistence Volume Claim

If you already have a suitable claim available then you can use that as follows:
- During the install you will be prompted with a list of parameter values
- Set the value of **couchdb.persistence.existingClaim** to the claim that you already have

### No Persistence Volumes
*This option is not recommended*

You may install Transformation Advisor without using a Persistence Volume, however this has a number of limitations:
 - If the couchDB container is restarted for any reason then **all of your data will be lost**
 - If the couchDB container is restarted for any resaon you will then need to **restart the server container** to re-initialize the couchDB

To use no Persistence Volumes as follows:
 - During the install you will be prompted with a list of parameter values
-  Untick the following option **couchdb.persistence.enabled** 

## Open Transformation Advisor UI
- From Menu navigate to Workloads -> Deployments
- Click "ibm-transadv-dev-ui" deployment
- Click on Endpoint "access 3000"

## Configuration 

The following tables lists the configurable parameters of the Transformation Advisor helm chart and their default values.

| Parameter                                      | Description                       | Default                                                                     |
| -------------------------------                | -------------------------------   | ----------------------------------------------------------------           |
| couchdb.image.repository                       | couchdb image repository          | klaemo/couchdb                                                             |
| couchdb.image.tag                              | couchdb image tag                 | 2.0.0                                                                       |
| couchdb.image.pullPolicy                       | couchdb image pull policy         | IfNotPresent                                                               |
| couchdb.resources.requests.memory              | requests memory                   | 2Gi                                                                         |
| couchdb.resources.requests.cpu                 | requests cpu                      | 1000m                                                                       |
| couchdb.resources.limits.memory                | limits memory                     | 8Gi                                                                         |
| couchdb.resources.limits.cpu                   | limits cpu                        | 16000m                                                                     |
| couchdb.service.name                           | couchdb service name              | couchdb                                                                     |
| couchdb.service.internalPort                   | couchdb internal port             | 5984                                                                       |
| couchdb.user                                   | couchdb user                      | admin                                                                       |
| couchdb.password                               | couchdb password                  | admindbpass                                                                 |
| couchdb.persistence.enabled                    | persistence enabled               | true                                                                       |
| couchdb.persistence.accessMode                 | couchdb access mode               | ReadWriteMany                                                               |
| couchdb.persistence.size                       | couchdb storage size              | 8Gi                                                                         |
| couchdb.persistence.useDynamicProvisioning     | use dynamic provisioning          | false                                                                       |
| couchdb.persistence.existingClaim              | use existing pv claim             | false                                                                       |
| couchdb.persistence.storageClassName           | couchdb storage class name        |                                                                            |
| transadv.image.repository                      | transadv server image             | ibmcom/icp-transformation-advisor-dc                                       |
| transadv.image.tag                             | transadv server image tag         | 1.1.0                                                                       |
| transadv.image.pullPolicy                      | image pull policy                 | IfNotPresent                                                               |
| transadv.resources.requests.memory             | requests memory                   | 2Gi                                                                         |
| transadv.resources.requests.cpu                | requests cpu                      | 1000m                                                                       |
| transadv.resources.limits.memory               | limits memory                     | 4Gi                                                                         |
| transadv.resources.limits.cpu                  | limits cpu                        | 16000m                                                                     |
| transadv.service.name                          | transadv service name             | transadv                                                                   |
| transadv.service.internalPort                  | transadv sevice internal port     | 9080                                                                       |
| transadv.service.nodePort                      |transadv sevice node port          | 30111                                                                       |
| transadvui.image.repository                    | transadv ui image                 | ibmcom/icp-transformation-advisor-ui                                       |
| transadvui.image.tag                           | transadv ui image tag             | 1.1.0                                                                       |
| transadvui.image.pullPolicy                    | image pull policy                 | IfNotPresent                                                               |
| transadvui.resources.requests.memory           | requests memory                   | 2Gi                                                                         |
| transadvui.resources.requests.cpu              | requests cpu                      | 1000m                                                                       |
| transadvui.resources.limits.memory             | limits memory                     | 4Gi                                                                         |
| transadvui.resources.limits.cpu                | limits cpu                        | 16000m                                                                     |
| transadvui.service.name                        | transadv ui service name          | ui                                                                         |
| transadvui.service.internalPort                | transadv sevice internal port     | 3000 


# For those who use Kubectl CLI

## Prerequisites

- Ensure kubectl points to your ICP
https://github.com/IBM/charts
- Ensure `helm` is installed

## Installing the Chart

```
helm install -n ibm-transadv-dev ./ --debug
```
## Verifying the installation
Go to the URL displayed in Notes.txt and ensure application is running

## Uninstalling the Chart
```
helm delete --purge ibm-transadv-dev
```
## Open Transformation Advisor UI
Go to the URL displayed in Notes.txt

Alternatively follow these instructions :
From a browser, use http://<**NodeIP**>:<**NodePort**> to access the application.

In order to do this you will need to know the Node IP and the nodeport for the UI deployment.

To find out the value for <**NodePort**> you can use the `kubectl get svc` command line command as shown below
```
kubectl get svc

couchdb               10.0.0.152   <nodes>       5984:32049/TCP   37m
                                                      ^^^^^
                                                      32049 is the NodePort in this instance
```
To find out the value for <**NodeIP**> 
```
kubectl cluster-info

Kubernetes master is running at https://9.162.177.182:8001
                                        ^^^^^^^^^^^^^
                                        9.162.177.182 is the NodeIP in this instance
```

## Copyright

© Copyright IBM Corporation 2017. All Rights Reserved.
