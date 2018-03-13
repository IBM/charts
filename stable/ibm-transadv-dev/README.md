
## Introduction

[Transformation Advisor](https://developer.ibm.com/product-insights/transformation-advisor/) has the capability to quickly evaluate your on-premise applications for rapid deployment on WebSphere Application Server and Liberty on Public and/or Private Cloud environments. 

Transformation Advisor will:
 - Gather your preferences regarding your current and desired target environments
 - Via a downloaded agent it will analyse your existing applications and upload the results to a single location
 - Provide recommendations for migration and development cost estimates to undertake the migrations across different platforms

The Transformation Advisor is delivered as an interconnected set of pods and kubernetes services. It consists of three pods - a server, a ui and a database. 

## Dynamic Provisioning

By default Transformation Advisor is configured to use dynamic provisioning. We strongly recommend that you use this option for your data storage.

## Static Provisioning

If you choose not to use dynamic provisioning you can change the default settings for a Persistence Volume (PV), an existing claim (PVC), or no storage at all. Please see below for the different options:

Complete the following steps to add the Persistent Volume

1. Navigate to **Platform** > **Storage**
1. Click **Create PersistentVolume**
1. Set the following values:
    - Name: transdev-pv-volume
    - Storage class name: (leave blank)
    - Capacity: 8
    - Unit: Gi
    - Access mode: Read write many
    - Reclaim policy: Recycle
    - Storage type: Host path
1. On the left menu select **Labels** and enter the following values:
    - Label: type
    - Value: local  
1. On the left menu select **Parameters** and enter the following values:
    - Key: path
    - Value: /usr/data  
**Note**: *Value here should be a value appropriate to your system*

- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - couchdb.persistence.enabled: true (default)
    - couchdb.persistence.useDynamicProvisioning: false (non-default)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.  
  

- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - couchdb.persistence.enabled: true (default)
    - couchdb.persistence.useDynamicProvisioning: true (default)
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass. 


- No persistent storage (This option is not recommended). 
  - You may install Transformation Advisor without using a Persistence Volume, however this has a number of limitations:
    - If the couchDB container is restarted for any reason then **all of your data will be lost**
    - If the couchDB container is restarted for any reason you will then need to **restart the server container** to re-initialize the couchDB
  - Enable this mode by setting the global values to:
    - couchdb.persistence.enabled: false (non-default)
    - couchdb.persistence.useDynamicProvisioning: false (non-default)


## Open Transformation Advisor UI
- From Menu navigate to Workloads -> Deployments
- Click "ibm-transadv-dev-ui" deployment
- Click on Endpoint "access 3000"

## Configuration 

The following tables lists the configurable parameters of the Transformation Advisor helm chart and their default values.

| Parameter                                           | Description                                                  | Default                                                 |
| --------------------------------------------------- | -------------------------------------------------------------| --------------------------------------------------------|
| arch.amd64                                          | Amd64 worker node scheduler preference in a hybrid cluster   | 3 - Most preferred                                      |
| arch.ppc64le                                        | Ppc64le worker node scheduler preference in a hybrid cluster | 2 - No preference                                       |
| couchdb.image.repository                            | couchdb image repository                                     | ibmcom/transformation-advisor-db                        |
| couchdb.image.tag                                   | couchdb image tag                                            | 1.4.0                                                   |
| couchdb.image.pullPolicy                            | couchdb image pull policy                                    | IfNotPresent                                            |
| couchdb.resources.requests.memory                   | requests memory                                              | 2Gi                                                     |
| couchdb.resources.requests.cpu                      | requests cpu                                                 | 1000m                                                   |
| couchdb.resources.limits.memory                     | limits memory                                                | 8Gi                                                     |
| couchdb.resources.limits.cpu                        | limits cpu                                                   | 16000m                                                  |
| couchdb.persistence.enabled                         | persistence enabled                                          | true                                                    |
| couchdb.persistence.accessMode                      | couchdb access mode                                          | ReadWriteMany                                           |
| couchdb.persistence.size                            | couchdb storage size                                         | 8Gi                                                     |
| couchdb.persistence.useDynamicProvisioning          | use dynamic provisioning                                     | true                                                    |
| couchdb.persistence.existingClaim                   | use existing pv claim                                        | false                                                   |
| couchdb.persistence.storageClassName                | couchdb storage class name                                   |                                                         |
| transadv.image.repository                           | transadv server image                                        | ibmcom/transformation-advisor-server                    |
| transadv.image.tag                                  | transadv server image tag                                    | 1.4.0                                                   |
| transadv.image.pullPolicy                           | image pull policy                                            | IfNotPresent                                            |
| transadv.resources.requests.memory                  | requests memory                                              | 2Gi                                                     |
| transadv.resources.requests.cpu                     | requests cpu                                                 | 1000m                                                   |
| transadv.resources.limits.memory                    | limits memory                                                | 4Gi                                                     |
| transadv.resources.limits.cpu                       | limits cpu                                                   | 16000m                                                  |
| transadv.service.nodePort                           | transadv sevice node port                                    | 30111                                                   |
| transadvui.image.repository                         | transadv ui image                                            | ibmcom/transformation-advisor-ui                        |
| transadvui.image.tag                                | transadv ui image tag                                        | 1.4.0                                                   |
| transadvui.image.pullPolicy                         | image pull policy                                            | IfNotPresent                                            |
| transadvui.resources.requests.memory                | requests memory                                              | 2Gi                                                     |
| transadvui.resources.requests.cpu                   | requests cpu                                                 | 1000m                                                   |
| transadvui.resources.limits.memory                  | limits memory                                                | 4Gi                                                     |
| transadvui.resources.limits.cpu                     | limits cpu                                                   | 16000m                                                  |
| transadvui.service.nodePort                         | transadv sevice node port                                    | 30222                                                   |


# For those who use Kubectl CLI

## Prerequisites

- Ensure kubectl points to your ICP
https://github.com/IBM/charts
- Ensure `helm` is installed

### Create a Persistence Volume:

Create pv.yaml file with following content

```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: <pv name>
  labels:
    type: local
spec:
  persistentVolumeReclaimPolicy: Recycle
  capacity:
    storage: 8Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/usr/data"
```

Create pv

```
kubectl create -f pv.yaml
```

## Installing the Chart

```
helm install -n <release name> ./ --debug
```
## Verifying the installation
Go to the URL displayed in Notes.txt and ensure application is running

## Uninstalling the Chart
```
helm delete --purge <release name>
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

## ICp Content Pipeline

We are delivering into the ICp Content Pipeline after a rename to ibm-transadv-dev

## Copyright

© Copyright IBM Corporation 2017. All Rights Reserved.
