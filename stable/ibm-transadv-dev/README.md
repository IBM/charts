## Introduction

[Transformation Advisor](https://developer.ibm.com/product-insights/transformation-advisor/) has the capability to quickly evaluate your on-premise applications for rapid deployment on WebSphere Application Server and Liberty on Public and/or Private Cloud environments. 

Transformation Advisor will:
 - Gather your preferences regarding your current and desired target environments
 - Via a downloaded agent it will analyse your existing applications and upload the results to a single location
 - Provide recommendations for migration and development cost estimates to undertake the migrations across different platforms
 - Automatically create the necessary images and deploy your application directly into [IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.2/featured_applications/transformation_advisor.html) 

## Chart Details
The Transformation Advisor is delivered as an interconnected set of pods and kubernetes services. It consists of three pods: server, ui and database.

## Dynamic Provisioning

By default Transformation Advisor is configured to use dynamic provisioning. We strongly recommend that you use this option for your data storage.

## Static Provisioning

If you choose not to use dynamic provisioning you can change the default settings for a Persistence Volume (PV), an existing claim (PVC), or no storage at all. Please see below for the different options:

Use following code to create a host path PV (only suitable for single worker systems and should not be used in production)

```bash
kind: PersistentVolume
apiVersion: v1
metadata:
  name: transadv-pv
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

In case NFS PV is used one needs to run following commands on NFS server to avoid "permission for changing ownership" error:
```bash
mkdir -p /opt/couchdb/data
```
```bash
chomd -R 777 /opt/couchdb/data
```

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

## Resources Required

### Minimum Configuration

| Subsystem  | CPU Minimum | Memory Minimum (GB) | Disk Space Minimum (GB) |
| ---------- | ----------- | ------------------- | ----------------------- |
| CouchDB    | 1           | 2                   | 8                       |
| Server     | 1           | 2                   |                         |
| UI         | 1           | 2                   |                         |

## Prerequisites

If persistence is enabled but no dynamic provisioning is used, Persistent Volumes must be created.

## Installing the Chart

To install the chart via helm with the release name `my-release`:

```bash
helm install --name my-release stable/ibm-transadv-dev
```

The command deploys `ibm-transadv-dev` on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Note**: This parameter is required for install `authentication.icp.masterIp`

> **Tip**: List all releases using `helm list`

## Open Transformation Advisor UI
- From Menu navigate to Workloads -> Deployments
- Click "ibm-transadv-dev-ui" deployment
- Click on Endpoint "access 3000"

If ingress is used in ICP 2.1.0.1 or 2.1.0.2
- From Menu navigate to Workloads -> Deployments
- Click "ibm-transadv-dev-ui" deployment
- Manually construct the URL of that form https://`<Ingress IP`>/`<Release name`>-ui
- "Release name" can be taken from the **Expose details** section in the "ibm-transadv-dev-ui" deployment page

## Configuration

The following tables lists the configurable parameters of the Transformation Advisor helm chart and their default values.

| Parameter                                           | Description                                                  | Default                                                 |
| --------------------------------------------------- | -------------------------------------------------------------| --------------------------------------------------------|
| arch.amd64                                          | Amd64 worker node scheduler preference in a hybrid cluster   | 3 - Most preferred                                      |
| arch.ppc64le                                        | Ppc64le worker node scheduler preference in a hybrid cluster | 2 - No preference                                       |
| arch.s390x                                          | S390x worker node scheduler preference in a hybrid cluster   | 2 - No preference                                       |
| ingress.enabled                                     | enable ingress to reach the service                          | true                                                    |
| authentication.icp.masterIp                         | master node IP                                               | ""                                                      |
| authentication.icp.endpointPort                     | master node login port                                       | 8443                                                    |
| authentication.oidc.endpointPort                    | OIDC authentication endpoint port                            | 9443                                                    |
| authentication.oidc.clientId.clientId               | a OIDC registry will be created with this id                 | ca5282946fac07867fbc937548cb35d3ebbace7e           |
| authentication.oidc.clientSecret                    | a OIDC registry will be created with this secret             | 94b6cbce793d0606c0df9e8d656a159f0c06631b           |
| couchdb.image.repository                            | couchdb image repository                                     | ibmcom/transformation-advisor-db                        |
| couchdb.image.tag                                   | couchdb image tag                                            | 1.6.0                                                   |
| couchdb.image.pullPolicy                            | couchdb image pull policy                                    | IfNotPresent                                            |
| couchdb.resources.requests.memory                   | requests memory                                              | 2Gi                                                     |
| couchdb.resources.requests.cpu                      | requests cpu                                                 | 1000m                                                   |
| couchdb.resources.limits.memory                     | limits memory                                                | 8Gi                                                     |
| couchdb.resources.limits.cpu                        | limits cpu                                                   | 16000m                                                  |
| couchdb.persistence.enabled                         | persistence enabled                                          | true                                                    |
| couchdb.persistence.accessMode                      | couchdb access mode                                          | ReadWriteMany                                           |
| couchdb.persistence.size                            | couchdb storage size                                         | 8Gi                                                     |
| couchdb.persistence.useDynamicProvisioning          | use dynamic provisioning                                     | true                                                    |
| couchdb.persistence.existingClaim                   | existing pv claim                                            | ""                                                      |
| couchdb.persistence.storageClassName                | couchdb storage class name                                   | ""                                                      |
| transadv.image.repository                           | transadv server image                                        | ibmcom/transformation-advisor-server                    |
| transadv.image.tag                                  | transadv server image tag                                    | 1.6.0                                                   |
| transadv.image.pullPolicy                           | image pull policy                                            | IfNotPresent                                            |
| transadv.resources.requests.memory                  | requests memory                                              | 2Gi                                                     |
| transadv.resources.requests.cpu                     | requests cpu                                                 | 1000m                                                   |
| transadv.resources.limits.memory                    | limits memory                                                | 4Gi                                                     |
| transadv.resources.limits.cpu                       | limits cpu                                                   | 16000m                                                  |
| transadv.service.nodePort                           | transadv sevice node port                                    | 30111                                                   |
| transadvui.image.repository                         | transadv ui image                                            | ibmcom/transformation-advisor-ui                        |
| transadvui.image.tag                                | transadv ui image tag                                        | 1.6.0                                                   |
| transadvui.image.pullPolicy                         | image pull policy                                            | IfNotPresent                                            |
| transadvui.resources.requests.memory                | requests memory                                              | 2Gi                                                     |
| transadvui.resources.requests.cpu                   | requests cpu                                                 | 1000m                                                   |
| transadvui.resources.limits.memory                  | limits memory                                                | 4Gi                                                     |
| transadvui.resources.limits.cpu                     | limits cpu                                                   | 16000m                                                  |
| transadvui.service.nodePort                         | transadv sevice node port                                    | 30222                                                   |
| transadvui.inmenu                                   | add to Platform menu                                         | true                                                    |

## Limitations

## Copyright

© Copyright IBM Corporation 2017. All Rights Reserved.
