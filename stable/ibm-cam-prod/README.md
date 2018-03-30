[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # (\(C\) Copyright IBM Corporation 2016-2018 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)

# Cloud Automation Manager Helm Chart

IBM Cloud Automation Manager is a cloud management solution on IBM Cloud Private (ICP) for deploying cloud infrastructure in multiple clouds with an optimized user experience.

## Introduction

IBM Cloud Automation Manager uses open source Terraform to manage and deliver cloud infrastructure as code. Cloud infrastructure delivered as code is reusable, able to be placed under version control, shared across distributed teams, and it can be used to easily replicate environments.

The Cloud Automation Manager content library comes pre-populated with sample templates to help you get started quickly. Use the sample templates as is or customize them as needed.  A Chef runtime environment can also be deployed using CAM for more advanced application configuration and deployment.

With Cloud Automation Manager, you can provision cloud infrastructure and accelerate application delivery into IBM Cloud, Amazon EC2, VMware vSphere, and VMware NSXv cloud environments with a single user experience.

You can spend more time building applications and less time building environments when cloud infrastructure is delivered with automation. You are able to get started fast with pre-built infrastructure from the Cloud Automation Manager library.

## Documentation

Additional documentation on IBM Cloud Automation Manager (CAM) and installation of CAM can be found here:
https://www.ibm.com/support/knowledgecenter/SS2L37/kc_welcome.html

## Prerequisites

### Hardware requirements

CAM may consume additional resources on top of ICP depending on its usage. You may want to allocate more resources to ICP than the minimum ICP hardware requirements.

### Persistent Volumes (60GB total)

Three persistent volumes (PVs) are required to store CAM DB and CAM log data
* 15 GB Persistent Volume for CAM DB
* 10 GB Persistent Volume for CAM Logs
* 15 GB Persistent Volume for CAM Terraform providers
* 20 GB Persistent Volume for CAM BPD
* Note: The persistant volumes need to be created prior to the CAM install.

### Internet connectivity is required for public cloud deployments and Chef runtimes

* Internet connectivity is required for deployments to public cloud providers like IBM Cloud, AWS and Azure. The automated setup of an advanced content runtime (Chef environment) using CAM also requires internet connectivity.

## Pre-Install Steps

### 1) Setup ICP persistent volumes for CAM DB, CAM Logs and CAM Terraform providers

For more information on creating persistant volumes see:
https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.2/cam_create_pv.html

### Using the ICP UI

On the ICP UI navigate to Platform > Storage > PersistentVolume > Create PersistentVolume and create the following three entries (this example uses NFS):
* 1) CAM DB
```
General Tab
  Name: cam-mongo-pv
  Capacity: 15
  Unit: Gi (default)
  Access Mode: ReadWriteMany
Labels Tab (in the format Label: Value)
  type: cam-mongo
Parameters Tab (in the format Key: Value)
  server: <your PV ip> e.g. the master node IP if the volume is on your master node
  path: <your PV path> e.g. /export/CAM_db
```
* 2) CAM Logs
```
General Tab
  Name: cam-logs-pv
  Capacity: 10
  Unit: Gi (default)
  Access Mode: ReadWriteMany
Labels Tab (in the format Label: Value)
  type: cam-logs
Parameters Tab (in the format Key: Value)
  server: <your PV ip> e.g. the master node IP if the volume is on your master node
  path: <your PV path> e.g. /export/CAM_logs
```
* 3) CAM Terraform
```
General Tab
  Name: cam-terraform-pv
  Capacity: 15
  Unit: Gi (default)
  Access Mode: ReadWriteMany
Labels Tab (in the format Label: Value)
  type: cam-terraform
Parameters Tab (in the format Key: Value)
  server: <your PV ip> e.g. the master node IP if the volume is on your master node
  path: <your PV path> e.g. /export/CAM_terraform
```
* 4) Blueprint Designer Application Data
```
General Tab
  Name: cam-bpd-appdata-pv
  Capacity: 20
  Unit: Gi (default)
  Access Mode: ReadWriteMany
Labels Tab (in the format Label: Value)
  type: cam-bpd-appdata
Parameters Tab (in the format Key: Value)
  server: <your PV ip> e.g. the master node IP if the volume is on your master node
  path: <your PV path> e.g. /export/CAM_BPD_appdata
```

### or using the kubectl CLI (samples in the downloaded tgz)

Edit the following yaml files to add your PV ip and path (this example uses NFS on a single VM ICP install)

Note: In each yaml below replace mycluster.icp with your host/ip for the NFS server

Note: In each yaml below replace /export/CAM_xxx with your path on the NFS server

Note: Blueprint Designer does not fully support NFS server; therefore, please use other storage type such as glusterfs or Host Path.

* 1)  Example of creating a PV for the CAM DB
```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: cam-mongo-pv
  labels:
    type: cam-mongo
spec:
  capacity:
    storage: 15Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: mycluster.icp
    path: /export/CAM_db

kubectl create -f ./ibm-cam-prod/pre-install/cam-mongo-pv.yaml
```

* 2) Example of creating a PV for the CAM Logs
```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: cam-logs-pv
  labels:
    type: cam-logs
spec:
  capacity:
    storage: 10Gi
  accessModes:
    -  ReadWriteMany
  nfs:
    server: mycluster.icp
    path: /export/CAM_logs

kubectl create -f ./ibm-cam-prod/pre-install/cam-logs-pv.yaml
```

* 3) Example of creating a PV for the CAM Terraform providers
```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: cam-terraform-pv
  labels:
    type: cam-terraform
spec:
  capacity:
    storage: 15Gi
  accessModes:
    -  ReadWriteMany
  nfs:
    server: mycluster.icp
    path: /export/CAM_terraform

kubectl create -f ./ibm-cam-prod/pre-install/cam-terraform-pv.yaml
```

* 4) Example of creating a PV for the Blueprint Designer application data
```
---
kind: Endpoints
apiVersion: v1
metadata:
  namespace: services
  name: glusterfs-cluster
subsets:
- addresses:
  - ip: <gluster node1 IP>
  ports:
  - port: 1729
- addresses:
  - ip: <gluster node2 IP>
  ports:
  - port: 1729
---
kind: Service
apiVersion: v1
metadata:
  namespace: services
  name: glusterfs-cluster
spec:
  ports:
  - port: 1729
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: cam-bpd-appdata-pv
  labels:
    type: cam-bpd-appdata
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteMany
  glusterfs:
    endpoints: glusterfs-cluster
    path: /glustervol1

kubectl create -f ./ibm-cam-prod/pre-install/cam-bpd-appdata-pv.yaml
```

Note: When using Host Path storage type to store Blueprint Designer's data, please follow the following steps.

1. Install CAM's helm chart with the following option:

```camBPDAppDataPV.persistence.accessMode: ReadWriteOnce```

2. Label the ICP's node that you would like to host the cam-bpd-ui container:

```kubectl label nodes <target node name> bpd=true```

3. After finishing the installation, modify cam-bpd-ui's development by adding nodeSelector bpd: "true" to the deployment template's spec

```kubectl edit deployment cam-bpd-ui -n services```

Example:

```
    nodeSelector:
      bpd: "true"
    imagePullSecrets:
    ....
```

## Installing the Chart

### To install the chart from the ICP UI:

Follow the knowledge center instructions for installing CAM: 
https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.2/cam_planning.html

At a high level steps for installing CAM include:

1. Login onto IBM Cloud Private url at: https:// :8443.

2. Navigate to Manage > Helm Repositories > Sync repositories to synchronize the helm repositories.

3. Navigate to Catalog > Helm Charts and select ibm-cam-prod

4. Review the readme details and click Configure.

5. In the Configure ibm-cam-prod page, enter the following details:
- Enter "cam" in the Release name field.
- Select "services" for the Target namespace.
- Check the license agreement box if you agree to the license
- Enter the Image Pull Secret Name to pull images from docker store or type `default` to use your namespace default service account image pull secret.  See the knowledge center for more information on generating image pull secrets. 
- (optional) Replace the Product ID with the one downloaded from IBM Passport Advantage if you are installing the full version of CAM (non-CE). 

6. When you see the Installation complete message, click View Helm Release.
- Note: You see the Installation complete message even if it takes a while before the Cloud Automation Manager pods are fully brought up (typically around 15 minutes).

7. Click cam in the Workloads > Helm Releases page to see the overall pod deployment progress.
- Tip: Checking the IBM Cloud Private Dashboard is a quick way to view the overall status of pod deployments, until all deployments show available (1).


### To install the chart from the helm CLI (this example installs chart version 1.2.0):

1. Download the chart from https://github.com/IBM/charts or if the chart is installed locally

```bash
$ wget https://mycluster.icp:8443/helm-repo/requiredAssets/ibm-cam-prod-1.2.0.tgz --no-check-certificate
```

2. Install the chart

```bash
$ helm install --name cam --namespace services ibm-cam-prod-1.2.0.tgz --tls
```

The command deploys cam on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

Note: Instructions for using the helm CLI with ICP can be found here:

https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0.2/app_center/create_helm_cli.html

### Monitoring the CAM install

You can optionally monitor the CAM install and pod deployment with a kubectl command:

```bash
root@myhost:~# kubectl -n services get pods
NAME                                       READY     STATUS    RESTARTS   AGE
cam-bpd-cds-66dc6bcc-fv559                 1/1       Running   0          3d
cam-bpd-mariadb-96786ff5d-gtlpp            1/1       Running   0          3d
cam-bpd-ui-5d5b68688c-c6d77                1/1       Running   0          3d
cam-broker-6ddc9b6746-q7nb2                1/1       Running   0          3d
cam-iaas-7d9967c8f6-kvgbt                  1/1       Running   0          3d
cam-mongo-6b7695895c-2fcw9                 1/1       Running   0          3d
cam-orchestration-7c4c9cfc86-fc9n9         1/1       Running   0          3d
cam-portal-ui-566bb874d-7xfmz              1/1       Running   0          3d
cam-provider-helm-67d9c854cd-clp5p         1/1       Running   0          3d
cam-provider-terraform-698cb974c6-ws9l5    1/1       Running   0          3d
cam-proxy-6478ff5c5b-gvfxr                 1/1       Running   0          3d
cam-service-composer-api-cdc66dff6-vq2lc   1/1       Running   0          3d
cam-service-composer-ui-6b6745756c-f82tf   1/1       Running   0          3d
cam-tenant-api-86d6b8d45d-q6qln            1/1       Running   0          3d
cam-ui-basic-677f89684c-dprfx              1/1       Running   0          3d
cam-ui-connections-788b865df8-8qnvl        1/1       Running   0          3d
cam-ui-instances-77c5d5b6-66nzn            1/1       Running   0          3d
cam-ui-templates-7ddd484779-b6vw5          1/1       Running   0          3d
redis-66668c4b6f-r5fmz                     1/1       Running   0          3d
```

### Accessing the CAM UI

Note: Once the helm install command completes, the CAM UI is available on the same IP as ICP on port 30000:

* `https://<CAM_IP_address>:30000`

Note: An ICP login page will be shown.  Log in as you would to ICP and you will be redirected to CAM after the login is successful.

## Uninstalling the Chart

To uninstall/delete cam deployment:

```bash
$ helm del cam --purge --tls
```

Note: Persistant Volume Claims (PVCs) are intentionally left behind for reuse with a future install of CAM.  
If the data is no longer needed then manual deletion can be performed for the PVCs, PVs and underlying storage volumes.  

## Configuration

The following table lists the configurable parameters of the cam chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `global.image.secretname`  | Image Pull Secret Name                          | Type `default` to use your namespace default service account image pull secret or enter your image pull secret name here. Required if downloading images from Docker Store  `store/ibmcorp`                                                      |
| `global.id.productID`      | CAM Product Identifier                          | Defaults to the CAM CE Product ID, or download a full version product ID from IBM Passport Advantage and specify it here                                           |
| `arch `                    | Architecture amd64 = Intel, ppc64le = Power     | amd64                                                      |
| `service.namespace`        | Namespace to deploy CAM                         | services                                                   |
| `database.bundled`         | Use internal MongoDB (set to false for external)| true                                                       |
| `database.url`             | External MongoDB endpoint (when bundled is true)| mongodb://cam-mongo:27017/cam                              |
| `database.encryption.password` | Overrides the default password used to encrypt data in CAM | nil                                         |
| `redis.bundled`            | Use internal Redis (set to false for external)  | true                                                       |
| `redis.host`               | External redis host (when bundled is true)      | redis                                                      |
| `redis.port`               | External redis port (when bundled is true)      | 6379                                                       |
| `image.repository`         | Repository for the CAM images                   | store/ibmcorp/                                             |
| `image.tag`                | Tag for the CAM images                          | 2.1.0.2                                                    |
| `image.pullPolicy`         | Pull Policy for the CAM images                  | IfNotPresent                                               |
| `image.dockerconfig`       | Docker Config for the CAM images                | nil                                                        |
| `camMongoPV.name`          | Name of MongoDB volume                          | cam-mongo-pv                                               |
| `camMongoPV.persistence.enabled` | Database persistance                      | true                                                       |
| `camMongoPV.persistence.useDynamicProvisioning` | Dynamic database PV        | false                                                      |
| `camMongoPV.persistence.existingClaimName` | Database existing claim name    | nil                                                        |
| `camMongoPV.persistence.storageClassName` | Database storage class           | nil                                                        |
| `camMongoPV.persistence.size` | Database PV size                             | 15Gi                                                       |
| `camLogsPV.name`          | Name of logs volume                              | cam-logs-pv                                                |
| `camLogsPV.persistence.enabled` | Logs persistance                           | true                                                       |
| `camLogsPV.persistence.useDynamicProvisioning` | Dynamic logs PV             | false                                                      |
| `camLogsPV.persistence.existingClaimName` | Logs existing claim name         | nil                                                        |
| `camLogsPV.persistence.storageClassName` | Logs storage class                | nil                                                        |
| `camLogsPV.persistence.size` | Logs PV size                                  | 10Gi                                                       |
| `camTerraformPV.name`        | Name of terraform volume                      | cam-terraform-pv                                           |
| `camTerraformPV.persistence.enabled` | Terraform persistance                 | true                                                       |
| `camTerraformPV.persistence.useDynamicProvisioning` | Dynamic Terraform PV   | false                                                      |
| `camTerraformPV.persistence.existingClaimName` | Terraform existing claim    | nil                                                        |
| `camTerraformPV.persistence.storageClassName` | Terraform storage class      | nil                                                        |
| `camTerraformPV.persistence.size` | Terraform PV size                        | 15Gi                                                       |
| `camBPDAppDataPV.name`        | Name of Template Designer volume             | cam-bpd-appdata-pv                                         |
| `camBPDAppDataPV.persistence.enabled` | Template Designer persistance                 | true                                              |
| `camBPDAppDataPV.persistence.useDynamicProvisioning` | Dynamic Template Designer PV   | false                                             |
| `camBPDAppDataPV.persistence.existingClaimName` | Template Designer existing claim    | nil                                               |
| `camBPDAppDataPV.persistence.storageClassName` | Template Designer storage class      | nil                                               |
| `camBPDAppDataPV.persistence.size` | Template Designer PV size               | 20Gi                                                       |
| `camBroker.replicaCount `    | Number of broker pods                         | 1                                                          |
| `camProxy.replicaCount `     | Number of proxy pods                          | 1                                                          |
| `camAPI.replicaCount `       | Number of API pods                            | 1                                                          |
| `camUI.replicaCount `        | Number of UI pods                             | 1                                                          |
| `resources.requests.memory`  | Memory resource requests                      | `256Mi`                                                    |
| `resources.requests.cpu`     | CPU resource requests                         | `100m`                                                     |
| `resources.limits.memory`    | Memory resource limits                        | `8Gi`                                                      |
| `resources.limits.cpu`       | CPU resource limits                           | `1`                                                        |
| `camBPDUI.bundled `       | Use Blueprint Desiger  (set to false if not needed)| true                         |
| `camBPDCDS.replicaCount `          | Number of Cloud Discovery Service pods                         | 1                                                      |
| `camBPDCDS.resources.requests.memory`  | Memory resource requests            | `128Mi`                   |
| `camBPDCDS.resources.requests.cpu`             | CPU resource requests                    | `100m`                     |
| `camBPDCDS.resources.limits.memory`    | Memory resource limits                        | `256Mi`                   |
| `camBPDCDS.resources.limits.cpu`        | CPU resource limits                                 | `200m`                    |
| `camBPDCDS.options.debug.enabled`        | Cloud Discovery Service's debug mode         | false        |
| `camBPDCDS.options.customSettingsFile` | Cloud Discovery Services' custom settings file | nil  |
| `camBPDDatabase.bundled`           | Use internal Maria DB (set to false for external)       | true               |
| `camBPDDatabase.resources.requests.memory`       |  Memory resource requests                           | `256Mi`      |
| `camBPDDatabase.resources.requests.cpu`          | CPU resource requests                           | `100m`                  |
| `camBPDExternalDatabase.type`   | External Database Type                          | db2, mysql, mariadb, oracle, or sqlserver  |
| `camBPDExternalDatabase.name`           | BPD Database Name                                | nil                            |
| `camBPDExternalDatabase.url`       | External Database Hostname/IP address    | nil                            |
| `camBPDExternalDatabase.port`           | External Database Port                           | nil                            |
| `camBPDExternalDatabase.secret`       | External Database username and password      | nil             |
| `camBPDExternalDatabase.extlibPV.existingClaimName`       | Persistence volume that contains a compatible JDBC Driver                | nil                         |
| `camBPDResources.requests.memory`   | Memory resource requests                              | `1Gi`   |
| `camBPDResources.requests.cpu`        | CPU resource requests                                       | `1000m`      |
| `camBPDResources.limits.memory`       | Memory resource limits                                      | `2Gi`          |
| `camBPDResources.limits.cpu`          | CPU resource limits                                               | `2000m`   |

## External mongodb and redis supported

By default, the CAM chart will create a bundled mongodb container and a bundled redis container.  However, for flexibility you can also point to a separately deployed mongodb and redis instances and the chart will simply use that as opposed to creating its own.  The values.yaml has options that control this behavior.

### External mongodb

For mongodb, `database.bundled` in values.yaml is true by default.  If you set this to false, then the helm chart will not create the `cam-mongo` related artifacts.  If `database.bundled` is set to false, then `database.url` must be updated to point to the mongodb endpoint. e.g. `mongodb://<mongodb-host>:<mongo-port>/cam`.  It is easiest to simply deploy the external mongo in the same `services` namespace, therefore its DNS name is resolvable by the CAM microservices.  You can use this mongodb chart to get started: https://github.com/kubernetes/charts/tree/master/stable/mongodb.  Make sure to use the mongodb version of the image is 3.4.4.  You can deploy with something like the following: `helm install --name external --namespace services --set persistence.enabled=false --set image=bitnami/mongodb:3.4.4-r0 --tls .`  With the command above you can then set `database.url` to `mongodb://external-mongodb:27017/cam`

### External redis

For redis, `redis.bundled` in values.yaml is true by default.  If you set this to false, then the helm chart will not create redis related artifacts.  If `redis.bundled` is set to false, then `redis.host` must be updated to point to the redis instance endpoint.  If your external redis is not on the standard port of 6379, then you must also set `redis.port`.  It is easiest to simply deploy the external redis in the same `services` namespace, therefore its DNS name is resolvable by the CAM microservices.  You can use this redis chart to get started: https://github.com/kubernetes/charts/tree/master/stable/redis-ha.  You can deploy with something like the following: `helm install --name external --namespace services --tls`  With the command above you can then set `redis.host` to `external-redis-ha`

### External DB2,  MySQL, MariaDB, Oracle, and SqlServer supported for BPD

For external DB2,  MySQL, MariaDB, Oracle, and SqlServer, `camBPDDatabase.bundled` in values.yaml is true by default.  If you set this to false, then the helm chart will not create `cam-bpd-mysql` related artifacts.  If `camBPDDatabase.bundled` is set to false, then `camBPDExternalDatabase` must be updated with all the required information such as `camBPDExternalDatabase.type`, `camBPDExternalDatabase.name`, `camBPDExternalDatabase.url`, `camBPDExternalDatabase.port`, `camBPDExternalDatabase.secret`, and `camBPDExternalDatabase.extlibPV.existingClaimName`.  The `camBPDExternalDatabase.extlibPV.existingClaimName` will be mapped to an existing persistent volume which contains a JDBC driver that is compatible with your external database.  Once all the information of the external database is provided, `cam-bpd-ui` pod will connect to the specified Database at start up.  Please note, `camBPDExternalDatabase.secret` must be mapped to a secret object which contains the external database username and password.

```
apiVersion: v1
kind: Secret
metadata:
  name: my_db_secret
type: Opaque
data:
  username: <base64 encoded value>
  password: <base64 encoded value>

kubectl create -f ./my_db_secret.yaml
```

If you set `camBPDDatabase.bundled` to true, and you need to retrieve the self generated password of `cam-bpd-mariadb`.  The following command can be used:
```bash
$kubectl get secret cam-bpd-mariadb-secret -n services -o yaml
```

## Cleaning the database (optional)

If you have persistence enabled, you can keep the CAM database from one upgrade to the next.  If you want to clean the CAM database (remove all CAM data), then on the PV where the database resides, delete everything under the `<your PV path>` directory
For example, if `<your PV path>` is /export/CAM_db/
```bash
rm -Rf /export/CAM_db/*
```
