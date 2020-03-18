# IBM Sterling Configure Price Quote Software v10

## Introduction

This document describes how to deploy IBM Sterling Configure Price Quote Software v10. This helm chart does not install database server. Database need to be setup and configured separately for IBM Sterling Configure Price Quote Software .

Note: This helm chart supports deployment of IBM Sterling Configure Price Quote Software with DB2 or Oracle database.

## CASE Details

The Container Application Software for Enterprises (CASE) and the associated CASE Bundle are well defined file and directory structures. 

A CASE Bundle includes a CASE and additional information to allow testing, validation and certification of software. It provides a convenient way to store the source (helm charts and operator source code) along with the tests in a single location. The CI/CD pipeline understands how to process a CASE Bundle, but only the CASE itself is published.

The folder structure for a case bundle looks like this:

    <CASE Bundle Name>
        resolvers.yaml
        resolvers-auth.yaml
        manifest.yaml
        README.md  (definition TBD) 
        case
            <CASE Name>
            ...
        charts
            <Helm Chart Name>
            ...
        operators
            <Operator Name>
            ...
        tests
            test-01

## Chart Details

This chart will do the following:
* Create a deployment `<release name>-ibm-cpq-prod-vmappserver` for IBM Sterling Visual Modeler(VM) application server with 1 replica by default. 
* Create a deployment `<release name>-ibm-cpq-prod-ocappserver` for IBM Sterling Omni Configurator(OC) application server with 1 replica by default. 
* Create a service `<release name>-ibm-cpq-prod-vmappserver`. This service is used to access the VM application server using a consistent IP address.
* Create a service `<release name>-ibm-cpq-prod-ocappserver`. This service is used to access the OC application server using a consistent IP address.
* Create a job `<release name>-ibm-cpq-prod-cpqdatasetup`. It is used for performing data setup for CPQ that is required to deploy and run the CPQ application. This may not be created if the data setup is disabled at the time of install or upgrade.
* Create a ConfigMap `<release name>-ibm-cpq-prod-vm-config`. This is used to provide VM and Liberty configuration.
* Create a ConfigMap `<release name>-ibm-cpq-prod-oc-config`. This is used to provide OC and Liberty configuration.

**Note** : `<release name>` refers to the name of the helm release and `<server name>` refers to the app server name.

## Prerequisites for CPQ

1. Kubernetes version >= 1.11.3

2. Ensure that DB2/Oracle database server is installed and the database is accessible from inside the cluster. For database timezone considerations refer section "Timezone considerations".

3. Ensure that the docker images for IBM Sterling Configure Price Quote Software are loaded to an appropriate docker registry. The default images for IBM Sterling Configure Price Quote Software can be downloaded from IBM Entitled Registry along with IBM Marketplace. Alternatively from IBM Passport Advantage.Customized images for IBM Sterling Configure Price Quote Software can also be used.

4. Ensure that the docker registry is configured in Manage -> Resource Security -> Image Policies and also ensure that docker image can be pulled on all of Kubernetes worker nodes.

## Installing the Chart (Installing the VisualModeler(VM) and OmniConfigurator(OC) Applications)
## Installing the CASE
## Below steps gives an example to install the helm chart into 'default' namespace of Openshift.
* Note The file permissions set up in the VM and OC Pod use owner as 1001 and group as root for the application related folders.

## Pre-requisite steps to be executed to install VM / OC
### Pulling Image directly from Entitled Registry - Option 1
Out of the box , the charts are programmed to pull the image directly from Entitled Registry - cp.icr.io/ibm-cpq.
(However you can change this behavior by going to Option 2.)
To do that follow below steps -
1.Create a secret -
`oc create secret docker-registry er-secret --docker-username=iamapikey --docker-password=[ER-Prod API Key] --docker-server=cp.icr.io`
2.Populate the field in charts in Values.yaml - global.image.pullsecret with the above secret name i.e. "er-secret"
3.The above steps should enable the charts to pull the images from Entitled Registry, when they are installed using helm.

### Push Image to Openshift Image Registry - Option 2
If you have a image downloaded , please follow below steps if you plan to use the downloaded images by uploading to your Openshift Image Registry.
1. On a node from where you have access to the Openshift cluster make sure you have installed Openshift Command Line Interface (CLI).
   Also install podman to interact with Openshift Image Registry.
2. Openshift has image registry secured by default. In which case user need to expose the image registry service to 
   create a route. This is required to create a route URL to the image registry to faciliate
   to pushing ofimages so the application can pull it from while deploying. This would be in the field global.image.repository
   of the helm chart.
   Go to link https://docs.openshift.com/container-platform/4.3/registry/securing-exposing-registry.html
   and expose the svc to route for image registry.
   Please note above link is for version 4.3, please choose the appropriate version as per your installation.
3. Route URL will be created for eg default-route-openshift-image-registry.apps.whir.os.fyre.ibm.com.
   For you this URL will be different and depends on the Openshift installation.
   We will refer to this as [image-registry-routeURL].
4. Go to the browser and hit URL - https://[image-registry-routeURL]

   Copy the certificate (eg firefox browser)
     * Firefox --> Click on https icon in the Location bar, there will be a pop up screen , you should see 'Connection Secure' 'or Connection Not Secure'. Click on 'Right arrow' to see 'Connection details'.
     * Click on 'More Information' and then click on button 'View Certificate'. 
     * The browser will open a new page. Locate the link 'Download' PEM (cert) to download the certificate(.crt) and save it.
     * Save the certificate in the node /etc/docker/certs.d/[image-registry-routeURL]/
       routerURL in our example is "default-route-openshift-image-registry.apps.whir.os.fyre.ibm.com
5. Login to the Openshift Cluster
   `oc login [adminuser]` - Use whatever admin user was created with Openshift was installed.
6. Push the image to Openshift registry  
   Login to podman
   `podman login [image-registry-routeURL]` - you will need admin user credentials.
   * Once you login to the registry, you will need to tag it appropriately.
     For eg to push the image to 'default' namespace eg tag cmd for VisualModeler image would be -
     `podman tag [ImageId] default-route-openshift-image-registry.apps.whir.os.fyre.ibm.com/default/cpq-vm-app:10.0-x86-64`
      Then push the image to this registry using 
     `podman push default-route-openshift-image-registry.apps.whir.os.fyre.ibm.com/default/cpq-vm-app:10.0-x86-64`
7. Since you are now pointing to OPenshift Repo you don't need the set the field pullsecret
   You can set the filed as  `global.image.pullsecret="'`.
   This will skip the imagepullsecret in the Pods.

### Helm Install 
* Install helm client
1. Install helm v3.0.3 from https://helm.sh/
   Install it on Linux client by running the command
   curl -s https://get.helm.sh/helm-v3.0.3-linux-386.tar.gz | tar xz
   Locate helm executable and put it in $PATH
   You may want to update PATH variable in your linux login profile script.
2. `oc login to cluster` to login to OpenShift cluster
3. `helm version` (you will need to put helm in $PATH) to verify that the Helm client of correct version is installed.
  The above should show something like -
 * version.BuildInfo{Version:"v3.0.3", GitCommit:"ac925eb7279f4a6955df663a0128044a8a6b7593", GitTreeState:"clean", GoVersion:"go1.13.6"}

### Install repository (Below content explains how to install the repository on a NFS server.)
1. Repository is the VisualModeler file structure where it stores models as xml files.
2. The repository is provided packaged with the CPQ Base Image as repo.tar.
3. Once you have a NFS server set up, have a shared directory which stores the VisualModeler repository.
   For that you need to extract the repo.tar and have a directory structure similar to below -

   [mounted dir]/configurator_logs

   [mounted dir]/omniconfigurator

   [mounted dir]/omniconfigurator/extensions

   [mounted dir]/omniconfigurator/models

   [mounted dir]/omniconfigurator/properties

   [mounted dir]/omniconfigurator/rules

   [mounted dir]/omniconfigurator/tenants

   Make sure you have set the permissions on the repository correctly.
   You can do that by mounting the above folder into a node and execute below cmds.
   * `sudo chown -R 1001 /[mounted dir]`
   * `sudo chgrp -R 0 /[mounted dir]`
   * `sudo chmod -R 770 /[mounted dir]`

   The above cmds make sure the repository folders and files have right permissions for the pods to access them.
   As noted the owner of the files in folders is the user 1001 and group as root.
   Also the rwx permissions are 770.
   * Warning : The repository is shared between the VM , OC and IFS application. The way it works is , once the repository is copied
   to a NFS shared folder, a PVC from the application, will be pointing to it. The intended folder is then mounted in the pod via the config map.
   Caution is to be followed since the pod will mount only unique folder. For eg if two folders point to same NFS location , only one of them will
   be mounted in the pod. You can check by executing hte cmd - `df -h` inside the pod to make sure you have got correct mounts. The mounted path should
   be in sync with the path of the repository you give in the SMCFS Application Platform console.

### Install Persistent related objects in Openshift - (Below are example files used to create Persistent Volume and related object using NFS server.)
* Note - The charts are bundled with sample files as templates , you can use these to plugin in your configuration and
  create pre-req objects. They are packaged in prereqs.zip.

1. Download the charts from IBM site. Add the dependencies as a part of PPA.
2. Create a persistent volume , persistent volume claim and storage class with access mode as 'Read write many' with minimum 12GB space.

* Create a pv.yaml file as below
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cpq-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 12Gi
  nfs:
    path: [nfs-shared-path]]
    server: [nfs-server]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cpq-sc
```
`oc create -f pv.yaml`
* Create persistent volume claim , pvc.yaml file as below -
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-cpq-vmoc-claim
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: cpq-sc
  volumeName: cpq-pv
  ```
`oc create -f pvc.yaml`
* Create a Storage class, file sc.yaml as below -
```  
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: cpq-sc
parameters:
  type: pd-standard
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Retain
volumeBindingMode: Immediate
```
`oc create -f sc.yaml`

* Please note , the `name`s used in the pv,pvc,sc should have correct references across the files.

* Create a Database secret, file cpq-secrets.yaml as below -
```
apiVersion: v1
kind: Secret
metadata:
  name: cpq-secrets
type: Opaque
stringData:
  dbUser: xxxx
  dbPassword: xxxx
  dbHostIp: "1.2.3.4"
  dbPort: "50000"
```
`oc create -f cpq-secrets.yaml`

3. If you choose to create a self signed certificate for ingress, please follow below steps. 
  Create certificate and key for ingress - ingress.crt and key ingress.key
  This is for create cert for ingress object to enable https for VM.
  Prereq is to select a hostname for launching VM.
  
  e.g. cpq.vm.ibm.com.apps.whir.os.fyre.ibm.com  your machine specific.
  Pleae note the hostname should end in the subdomain name of your machine.
 
  cmd - 
  `openssl req -x509 -nodes -days 365 -newkey ./ingress.key -out ingress.crt -subj "/CN=[hostname]/O=[hostname]"`

  e.g. cmd - 
  `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./ingress.key -out ./ingress.crt -subj "/CN=cpq.vm.ibm.com.apps.whir.os.fyre.ibm.com/O=cpq.vm.ibm.com.apps.whir.os.fyre.ibm.com"`
  
  cmd - 
  `oc create secret tls vm-ingress-secret --key ingress.key --cert ingress.crt`
 * You need to refer this secret name into values.yaml - vmappserver.ingress.ssl.secretname
 * Also enable ssl by setting vmappserver.ingress.ssl.enabled to true.

For **production environments** it is strongly recommended to obtain a CA certified TLS certificate and create a secret manually as below.

 1. Obtain a CA certified TLS certificate for the given `vmappserver.ingress.host` in the form of key and certificate files.
 2. Create a secret from the above key and certificate files by running below command
```
	oc create secret tls <release-name>-ingress-secret --key <file containing key> --cert <file containing certificate> -n <namespace>
```
 3. Use the above created secret as the value of the parameter `vmappserver.ingress.ssl.secretname`.

 4. Set the following variables in the values.yaml
    1. Set the Registry from where you will pull the images-
        e.g. global.image.repository: "image-registry.openshift-image-registry.svc:5000/default" 
    2. Set the image names -
        e.g. vmappserver.image.name: cpq-vm-app 
        e.g. vmappserver.image.tag: 10.0-x86-64
        e.g. ocappserver.image.name: cpq-oc-app
        e.g. ocappserver.image.tag: 10.0-x86-64
    3. Set the ingress host
        e.g. vmappserver.ingress.host: "cpq.vm.ibm.com.apps.whir.os.fyre.ibm.com"
        * Note: The hostname should end in same subdomain as the cluster node.
    4. Follow above steps for ocappserver.
    5. Check global.persistence.claims.name “nfs-cpq-vmoc-claim” matches with name given in pvc.yaml.
    6. Check the ingress tls secret name is set correctly as per cert created above, in place of vmappserver.ingress.ssl.secretname


### To install the chart with the release name `my-release`:
1. Ensure that the chart is downloaded locally by following the instructions given.
2. Set up which application you need to install.
Decide which application you need to install and set the 'enabled' flag to true for it, in the values.yaml file.
Preferred way is to install one application at a time. Hence you will need to disable the flag for the application once already installed.
  ```
   install:
    configurator:
      enabled: false
    visualmodeler:
      enabled: true
    ifs:
      enabled: false
    runtime:
      enabled: false      
   ```
3. Check the settings are good in values.yaml by simulating the install chart.
  cmd - helm template --name=my-release [chartpath]
  This should give you all kubernetes objects which would be getting deployed on Openshift.
  This cmd won't actually install kubernetes objects.
4. To install the application in Openshift run below cmd -
 cmd - helm install my-release [chartpath] --timeout 3600
5. Similarly install OmniConfigurator OC.
6. Test the installation -

  VM admin - https://[hostname]/VisualModeler/en/US/enterpriseMgr/admin?

  VM matrix - https://[hostname]/VisualModeler/en/US/enterpriseMgr/matrix?

  OC - https://[hostname]/ConfiguratorUI/UI/index.html#

  OC Backend - https://[hostname]/configurator/

Depending on the capacity of the kubernetes worker node and database connectivity, the whole deploy process can take on average 
* 5-6 minutes for 'installation against a pre-loaded database' and 
* 50-60 minutes for 'installation against a fresh new database'

When you check the deployment status, the following values can be seen in the Status column: 
– Running: This container is started. 
– Init: 0/1: This container is pending on another container to start.

You may see the following values in the Ready column: 
– 0/1: This container is started but the application is not yet ready. 
– 1/1: This application is ready to use.

Run the following command to make sure there are no errors in the log file:
```
oc logs <pod_name> -n <namespace> -f
```

10. If you are deploying IBM Sterling Configure Price Quote Software on a namespace other than default, then create a Role Based Access Control(RBAC) if not already created, with cluster admin role.
* The following is an example of the RBAC for default service account on target namespace as `<namespace>`.

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cpq-role-<namespace>
  namespace: <namespace>
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list","create","delete","patch","update"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cpq-rolebinding-<namespace>
  namespace: <namespace>
subjects:
- kind: ServiceAccount
  name: default
  namespace: <namespace>
roleRef:
  kind: Role
  name: cpq-role-<namespace>
  apiGroup: rbac.authorization.k8s.io


```
For a different namespace (i.e. other than default namespace) you will need to add anyuid scc to default service account in that namespace

`oc adm policy add-scc-to-user anyuid -z default`

## PodSecurityPolicy Requirements

In case you need a PodSecurityPolicy to be bound to the target namespace follow below steps. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* ICPv3.1 - Predefined  PodSecurityPolicy name: [`default`](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/manage_cluster/enable_pod_security.html)
* ICPv3.1.1 - Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)

* Custom PodSecurityPolicy definition:

```
apiVersion: apps/v1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy allows pods to run with 
      any UID and GID, but preventing access to the host."
  name: ibm-cpq-anyuid-psp
spec:
  allowPrivilegeEscalation: true
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities: 
  - MKNOD
  allowedCapabilities:
  - SETPCAP
  - AUDIT_WRITE
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - FSETID
  - KILL
  - SETUID
  - SETGID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETFCAP 
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
  forbiddenSysctls: 
  - '*' 
```
To create a custom PodSecurityPolicy, create a file `cpq_psp.yaml` with the above definition and run the below command
```
oc create -f cpq_psp.yaml
```

* Custom ClusterRole and RoleBinding definitions:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
  name: ibm-cpq-anyuid-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-cpq-anyuid-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ibm-cpq-anyuid-clusterrole-rolebinding
  namespace: <namespace>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ibm-cpq-anyuid-clusterrole
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:<namespace>

```
The `<namespace>` in the above definition should be replaced with the namespace of the target environment.
To create a custom ClusterRole and RoleBinding, create a file `cpq_psp_role_and_binding.yaml` with the above definition and run the below command
```
oc create -f cpq_psp_role_and_binding.yaml
```
## Red Hat OpenShift SecurityContextConstraints Requirements
[`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc)
Predefined securitycontextconstraint - restricted is to be used.
* To enable pods to run as anyuid , yo will need to add the `serveraccount default` to anyuid scc.
  Use this cmd to do that - `oc adm policy add-scc-to-user anyuid -z default`

Custom SecurityContextConstraints definition:
```
apiVersion: apps/v1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive, requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-restricted-psp
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

## Timezone considerations
In order to deploy CPQ Software, the timezone of the database, application servers, and agents should be same. Additionally, this timezone must be compatible with the locale code specified in CPQ Software.
By default, the containers are deployed in UTC, also the locale code in CPQ is set as en_US_UTC. Hence ensure that the database is also deployed in UTC.


## Configuration
### Ingress
* For Visual Modeler Ingress can be enabled by setting the parameter `vmappserver.ingress.enabled` as true. If ingress is enabled, then the application is exposed as a `ClusterIP` service, otherwise the application is exposed as `NodePort` service. It is recommended to enable and use ingress for accessing the application from outside the cluster. For production workloads, the only recommended approach is Ingress with cluster ip. Do not use NodePort.

* `vmappserver.ingress.host` - the fully-qualified domain name that resolves to the IP address of your cluster’s proxy node. Based on your network settings it may be possible that multiple virtual domain names resolve to the same IP address of the proxy node. Any of those domain names can be used. For example "example.com" or "test.example.com" etc.

* `vmappserver.ingress.ssl.enabled` - It is strongly recommended to enable SSL. If SSL is enabled by setting this parameter to true, a secret is needed to hold the TLS certificate.

* For Omnni Configurator Ingress can be enabled by setting the parameter `ocappserver.ingress.enabled` as true. If ingress is enabled, then the application is exposed as a `ClusterIP` service, otherwise the application is exposed as `NodePort` service. It is recommended to enable and use ingress for accessing the application from outside the cluster. For production workloads, the only recommended approach is Ingress with cluster ip. Do not use NodePort.

* `ocappserver.ingress.host` - the fully-qualified domain name that resolves to the IP address of your cluster’s proxy node. Based on your network settings it may be possible that multiple virtual domain names resolve to the same IP address of the proxy node. Any of those domain names can be used. For example "example.com" or "test.example.com" etc.

* `ocappserver.ingress.ssl.enabled` - It is strongly recommended to enable SSL. If SSL is enabled by setting this parameter to true, a secret is needed to hold the TLS certificate.

### Installation of new database
This will create the required database tables and factory data in the database.
#### DB2 database secrets:
1. Create db2 database user.
2. Add following properties in `cpq-secrets.yaml` file.
  ```
  apiVersion: v1
  kind: Secret
  metadata:
    name: <secrets_name>
  type: Opaque
  stringData:
    dbUser: <DB_USER>
    dbPassword: <DB_PASSWORD>
    dbHostIp: "<DB_HOST>"
    databaseName: <DATABASE_NAME>
    dbPort: "<DB_PORT>"

  ```
 3. Create secret using following command
     ```
     oc create -f cpq-secrets.yaml
     ```
#### Oracle database secrets:
1. Create oracle database user.
2. Create tablespace `DATA` on database server using following script:
  ```
   Create TABLESPACE DATA 
   ADD DATAFILE 'data01.DBF' 
   SIZE 1000M;
  ```
  This tablespace is required for importing data successfully into oracle user.

3. Add following properties in `cpq-secrets.yaml`
  ```
  apiVersion: v1
  kind: Secret
  metadata:
    name: <secrets_name>
  type: Opaque
  stringData:
    dbUser: <DB_USER>
    dbPassword: <DB_PASSWORD>
    dbHostIp: "<DB_HOST>"
    databaseName: <DATABASE_NAME>
    dbPort: "<DB_PORT>"
    tableSpaceName: "DATA"
  ```
 4. Create secret using following command
     ```
     oc create -f cpq-secrets.yaml
     ```  
#### Once secret is created using above steps, make following changes in `values.yaml` file in order to install new database.

```yaml
global:
  appSecret: "<SECRET_NAME_CREATED_USING_ABOVE_STEPS>"
  database:
    dbvendor: <DBTYPE>
    
  install:
    configurator:
      enabled: false
    visualmodeler:
      enabled: false
    ifs:
      enabled: false
    runtime:
      enabled: true
      
cpqdatasetup:
  dbType: "<DBTYPE>"
  createDB: true
  loadDB: true
  skipCreateWAR: true
  generateImage: false
  loadFactoryData: "install"
  
runtime:
  image: 
    name: <image_name>
    tag: <image_tag>
    pullPolicy: IfNotPresent  

```
Then run helm install command to install database. 
  ```
   helm install my-release [chartpath] --timeout 3600
  ```


### The following table lists the configurable parameters for the VM and OC charts TODO - add base

Parameter                                        | Description                                                          | Default 
-------------------------------------------------|----------------------------------------------------------------------| -------------
`vmappserver.replicaCount`                       | Number of vmappserver instances                                      | `1`
`vmappserver.image`                              | Docker image details of vmappserver                                  |   
`vmappserver.config.vendor`                      | OMS Vendor                                                           | `websphere`
`vmappserver.config.vendorFile`                  | OMS Vendor file                                                      | `servers.properties`
`vmappserver.config.serverName`                  | App server name                                                      | `DefaultAppServer`
`vmappserver.config.jvm`                         | Server min/max heap size and jvm parameters                          | `1024m` min, `2048m` max, no parameters
`vmappserver.livenessCheckBeginAfterSeconds`     | Approx wait time(secs) to begin the liveness check                   | `900`
`vmappserver.livenessFailRestartAfterMinutes`    | Approx time period (mins) after which server is restarted if liveness check keeps failing for this period | `10`
`vmappserver.service.type`                       | Service type                                                         | `NodePort`
`vmappserver.service.http.port`                  | HTTP container port                                                  | `9080`
`vmappserver.service.http.nodePort`              | HTTP external port                                                   | `30080`
`vmappserver.service.https.port`                 | HTTPS container port                                                 | `9443`
`vmappserver.service.https.nodePort`             | HTTPS external port                                                  | `30443`
`vmappserver.resources`                          | CPU/Memory resource requests/limits                                  | Memory: `2560Mi`, CPU: `1`
`vmappserver.ingress.enabled`                    | Whether Ingress settings enabled                                     | true
`vmappserver.ingress.host`                       | Ingress host                                                         |
`vmappserver.ingress.controller`                 | Controller class for ingress controller                              | nginx
`vmappserver.ingress.contextRoots`               | Context roots which are allowed to be accessed through ingress       | ["VisualModeler"]
`vmappserver.ingress.annotations`                | Annotations for the ingress resource                                 |
`vmappserver.ingress.ssl.enabled`                | Whether SSL enabled for ingress                                      | true
`vmappserver.podLabels`                          | Custom labels for the vmappserver pod                                  |
`vmappserver.tolerations`                        | Tolerations for vmappserver pod. Specify in accordance with k8s PodSpec.tolerations.         |
`importcert.secretname`                          | Secret name consisting of certificate to be imported into VM.
`ocappserver.replicaCount`                       | Number of ocappserver instances                                      | `1`
`ocappserver.image`                              | Docker image details of ocappserver                                  |   
`ocappserver.config.vendor`                      | OMS Vendor                                                           | `websphere`
`ocappserver.config.vendorFile`                  | OMS Vendor file                                                      | `servers.properties`
`ocappserver.config.serverName`                  | App server name                                                      | `DefaultAppServer`
`ocappserver.config.jvm`                         | Server min/max heap size and jvm parameters                          | `1024m` min, `2048m` max, no parameters
`ocappserver.livenessCheckBeginAfterSeconds`     | Approx wait time(secs) to begin the liveness check                   | `900`
`ocappserver.livenessFailRestartAfterMinutes`    | Approx time period (mins) after which server is restarted if liveness check keeps failing for this period | `10`
`ocappserver.service.type`                       | Service type                                                         | `NodePort`
`ocappserver.service.http.port`                  | HTTP container port                                                  | `9080`
`ocappserver.service.http.nodePort`              | HTTP external port                                                   | `30080`
`ocappserver.service.https.port`                 | HTTPS container port                                                 | `9443`
`ocappserver.service.https.nodePort`             | HTTPS external port                                                  | `30443`
`ocappserver.resources`                          | CPU/Memory resource requests/limits                                  | Memory: `2560Mi`, CPU: `1`
`ocappserver.ingress.enabled`                    | Whether Ingress settings enabled                                     | true
`ocappserver.ingress.host`                       | Ingress host                                                         |
`ocappserver.ingress.controller`                 | Controller class for ingress controller                              | nginx
`ocappserver.ingress.contextRoots`               | Context roots which are allowed to be accessed through ingress       | ["ConfiguratorUI","configurator"]
`ocappserver.ingress.annotations`                | Annotations for the ingress resource                                 |
`ocappserver.ingress.ssl.enabled`                | Whether SSL enabled for ingress                                      | true
`ocappserver.podLabels`                          | Custom labels for the ocappserver pod                                  |
`ocappserver.tolerations`                        | Tolerations for ocappserver pod. Specify in accordance with k8s PodSpec.tolerations. Refer 
`importcert.secretname`                          | Secret name consisting of certificate to be imported into OC.
section "Affinity and Tolerations". | 
`vmappserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`vmappserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`vmappserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`       | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". |
`vmappserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`vmappserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`   | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". |
`vmappserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`  | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`vmappserver.podAntiAffinity.replicaNotOnSameNode` | Directive to prevent scheduling of replica pod on the same node. valid values: `prefer`, `require`, blank. Refer section "Affinity and Tolerations". | `prefer`
`vmappserver.podAntiAffinity.weightForPreference`  | Preference weighting 1-100. Used if 'prefer' is specified for `vmappserver.podAntiAffinity.replicaNotOnSameNode`. Refer section "Affinity and Tolerations". | 100 
`ocappserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ocappserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ocappserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`       | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". |
`ocappserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ocappserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`   | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". |
`ocappserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`  | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ocappserver.podAntiAffinity.replicaNotOnSameNode` | Directive to prevent scheduling of replica pod on the same node. valid values: `prefer`, `require`, blank. Refer section "Affinity and Tolerations". | `prefer`
`ocappserver.podAntiAffinity.weightForPreference`  | Preference weighting 1-100. Used if 'prefer' is specified for `ocappserver.podAntiAffinity.replicaNotOnSameNode`. Refer section "Affinity and Tolerations". | 100 
`global.image.repository`                      | Registry for CPQ images                               |
`global.image.pullsecret`                      | Used in imagePullSecrets of Pods, please see above - Pre-requisite steps .. Option 1 and 2 |
`global.appSecret`                             | CPQ secret name                                         |
`global.persistence.claims.name`               | Persistent volume name                                               | pq-vmoc-claim
`global.persistence.securityContext.fsGroup`   | File system group id to access the persistent volume                 | 0
`global.persistence.securityContext.supplementalGroup`| Supplemental group id to access the persistent volume          | 0
`global.database.dbvendor`                     | DB Vendor DB2/Oracle                                                 | DB2
`global.database.schema`                       | Database schema name.For Db2 it is defaulted as `global.database.dbname` and for Oracle it is defaulted as `global.serviceAccountName`                    | Service account name                                                 |
`global.arch`                                  | Architecture affinity while scheduling pods                          | amd64: `2 - No preference`, ppc64le: `2 - No preference`
`global.install.configurator.enabled`          | Install Configurator                                                 |
`global.install.visualmodeler.enabled`         | Install VisualModeler                                                |
`global.install.ifs.enabled`                   | Install IFS                                                          |
`global.install.runtime.enabled`               | Install Base Pod (Required for factory data loading)              |
`cpqdatasetup.dbType`                          | Type of Database used by CPQ Application                             | 
`cpqdatasetup.createDB`                        | Specifying this flag as true will create Database Schema             | true
`cpqdatasetup.loadDB`                          | Specifying this flag as true will load configuration data            | true
`cpqdatasetup.skipCreateWAR`                   | Specifying this flag as true will prevent the creatio of application war | true
`cpqdatasetup.generateImage`                   | Specifying this flag as true will prevent the creation of CPQ image  | false
`cpqdatasetup.loadFactoryData`                 | Load factory data of IFS Application                                 |


## Affinity and Tolerations
The chart provides various ways in the form of node affinity, pod affinity, pod anti-affinity and tolerations to configure advance pod scheduling in kubernetes. 
Refer the kubernetes documentation for details on usage and specifications for the below features.

* Tolerations - This can be configured using parameter `vmappserver.tolerations` for the vmappserver and similarly for OC.

* Node affinity - This can be configured using parameters `vmappserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `vmappserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the vmappserver, and parameters `ocappserver.common.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ocappserver.common.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the ocappserver.
Depending on the architecture preference selected for the parameter `global.arch`, a suitable value for node affinity is automatically appended in addition to the user provided values.

* Pod affinity - This can be configured using parameters `vmappserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `vmappserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the appserver, and parameters `ocappserver.common.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ocappserver.common.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the ocappserver.

* Pod anti-affinity - This can be configured using parameters `vmappserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `vmappserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the appserver, and parameters `ocappserver.common.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ocappserver.common.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the ocappserver.
Depending on the value of the parameter `podAntiAffinity.replicaNotOnSameNode`, a suitable value for pod anti-affinity is automatically appended in addition to the user provided values. This is to configure whether replicas of a pod should be scheduled on the same node. If the value is `prefer` then `podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` is automatically appended whereas if the value is `require` then `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` is appended. If the value is blank, then no pod anti-affinity value is automatically appended. If the value is `prefer` then the weighting for the preference is set using the parameter `podAntiAffinity.weightForPreference` which should be specified in the range 1-100.

## Readiness and Liveness
Readiness and liveness checks are provided for the agents and application server pods as applicable.

1. Application Server pod
The following parameters can be used to tune the readiness and liveness checks for application server pods.

* `vmappserver.livenessCheckBeginAfterSeconds` - This can be used to specify the delay in starting the liveness check for the application server. The default value is 900 seconds (15 minutes).
* `vmappserver.livenessFailRestartAfterMinutes` - This can be used to specify the approximate time period, after which the pod will get restarted if the liveness check keeps on failing continuously for this period of time. The default value is 10 minutes.

For E.g. if the values for `vmappserver.livenessCheckBeginAfterSeconds` `vmappserver.livenessFailRestartAfterMinutes` are `900` and `10` respectively, and the application server pod is not able to start up successfully after `25` minutes, then it will be restarted.
Further, after the application server has started up successfully, if the liveness check keeps failing continuously for a period of `10` minutes, then it will be restarted.

## Upgrading the Chart

You would want to upgrade your deployment when you have a new docker image for application/agent server or a change in configuration, for e.g. new agent/integration servers to be deployed/started. 

1. Ensure that the chart is downloaded locally by following the instructions given [here.](https://www.ibm.com/support/knowledgecenter/SS6PEW_10.0.0/com.ibm.help.install.omsoftware.doc/installation/c_OMICP_download_OMSChart.html)

2. Ensure that the `datasetup.loadFactoryData` parameter is set to `donotinstall` or blank. Run the following command to upgrade your deployments. 

```
helm upgrade my-release -f values.yaml [chartpath] --timeout 3600 --tls
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment run the command:

```
 helm delete my-release  --tls
```
Note:If you need to clean the installation you may also consider deleting the secrets and peristent volume created as part of prerequisites.

## Dashboard Experience
Openshift comes with Out of the box Dashboard displaying objects deployed. 
Please check the OPenshift documentation for the usage of Dashboard.
https://docs.openshift.com/container-platform/4.3/welcome/index.html
(Please confirm the version once you visit the above page.)

## Limitations
* The database must be installed in UTC timezone.

## Backup/recovery process
Back up of persistent data for CPQ falls in two types - Database and the Repository.
Database back up needs to be taken on regular basis as a back up plan.
Similary the repository folders should be backed up on regular basis to back up the models xml files and other properties defined as a part of repository.
Since the application pods are stateless , there is no backup/recovery process required for the pods.
If needed the application once deployed can be deleted using helm del [release-name]
If needed the applicatin can be rolledback using helm rollback [release-name] 0

## Usage of VM-OC Base image and customization.
1. You download the artifacts from github https://github.ibm.com/vainakil/CPQ_PUNE.git in a directory in linux (for eg master node)
Execute following command from /opt folder to pull the data from github:
	git clone https://github.ibm.com/vainakil/CPQ_PUNE.git

2. Goto the directory where above artifacts are downloaded and run the cmd -
   ```
   buildah bud -t vb/cpqcontainer:v01 -f Dockerfile.rt.
   ```  
   Install Buildah if it's not available using command: 
   ```
   yum -y install buildah
   ```
   This will build VM-OC Base image.

3. Run the cmd -
   ```
   podman run -it --net=podman --privileged -e LICENSE=accept vb/cpqcontainer:v01 
   ```
   This will take you inside the base container in /opt/VMSDK folder
 
4. The folder /opt/VMSDK contains all the artifacts.
 
5. Once you created the container, Come out of the container. copy IBM_VisualModeler.jar, configurator.war, ConfiguratorUI.war of latest fixpack inside the container in /opt/VMSDK/newartifacts folder using following commands:
Go to the folder where you have downloaded these 3 artifacts from jenkins build. 

	     podman cp IBM_VisualModeler.jar <container_id>:/opt/VMSDK/newartifacts
	     podman cp configurator.war <container_id>:/opt/VMSDK/newartifacts
	     podman cp ConfiguratorUI.war <container_id>:/opt/VMSDK/newartifacts
		 

6. Once inside container, run ./executeAll.sh command to generate 3 images - VM, OC and base. 

   ***6.1 DB Independent image :***
   ```
      ./executeAll.sh --createDB=false --loadDB=false --MODE=all --generateImage=true --generateImageTar=true --pushImage=true --imageRegistryURL=<Image_Registry_URL> --imageRegistryPassword=****** --IMAGE_TAG_NAME=<img_tag_name>
   ```	 
   
Arguments usage:

createDB - <true|false> - Set value to false if you are generating the images. Set value to true while creating and loading the                                   database.

loadDB - <true|false> - Set value to false if you are generating the images. Set value to true while creating and loading the                                   database.

MODE - <vm|oc|base|all> - Set value to vm to generate only VM appserver image. Set value to oc to generate only OC appserver 				       image. Set value to base to generate only vmoc base image. Set value to all to generate all 3 images.

generateImage - <true|false> - set value to true if you want to generate the image. Otherwise set to false. 

generateImageTar - <true|false> - set to true if you want to save the image into .tar file.

pushImage - <true|false> - set to true if you want to push the image into registry.	

imageRegistryURL - specify registry URL to push the image.

imageRegistryPassword - password/API key required to login to registry.

IMAGE_TAG_NAME - Provide tag name to image. The generated image will be pushed in registry with this tag name.
  
	
   ***6.2 DB specific image :***
    In order to generate database specific image i.e. db2 or oracle image. Pass DBTYPE to executeAll command.
   ```
     ./executeAll.sh --DBTYPE=<dbtype> --createDB=false --loadDB=false --MODE=all --generateImage=true --generateImageTar=true --pushImage=true --imageRegistryURL=<Image_Registry_URL> --imageRegistryPassword=****** --IMAGE_TAG_NAME=<img_tag_name>
  ```
Arguments usage:  
DBTYPE - <db2|oracle> -  Provide the value either db2 or oracle to generate db2 or oracle image respectively. 
   
 7. ***Visual Modeler Customization -***
 	Once you created the base container using above commands in step 2 and 3, run following command in container to create projects/matrix folder under /opt/VMSDK folder. 
   ```
   ./executeAll.sh --DBTYPE=dbtype --createDB=false --loadDB=false --MODE=vm --generateImage=false
   ```
   Then follow KC for copying customization changes. Once you copied the customization changes, run following commands from /opt/VMSDK folder to build visualmodeler war with customized changes and generate/push customized images.
   ```
    ./buildvmwar.sh --DBTYPE="$DBTYPE"
    
    ./generateImage.sh --DBTYPE="$DBTYPE" --MODE=vm --IMAGE_TAG_NAME="$IMAGE_TAG_NAME" --generateImageTarFlag=true --pushImageFlag=true --imageRegistryURL="$imageRegistryURL" --imageRegistryPassword="$imageRegistryPassword"
   ```
 8. ***Omni Configurator Repository Customization -***     
       Follow KC for OC Repository customization in detail.

## Customizing server.xml for Liberty 
### You can customize the server.xml of liberty via helm charts. 
There are 2 files provided server_vm.xml and server_oc.xml , which will be deployed as server.xml to the respective applications.
* Warning - Please don't change out of the box settings provided in server xml, it may impact the application.

-------------------------------------------------------------------------------------------


# IBM Sterling Field Sales Edition v10
=======================================================================

## Introduction

The below content describes how to deploy IBM Sterling Field Sales v10. This helm chart does not install database server or messaging server. Both these middlewares need to be setup and configured separately for IBM Sterling Field Sales.

Note: This helm chart supports deployment of IBM Sterling Field Sales with DB2 database and MQ messaging.

## Chart Details

This chart will do the following:
* Create a deployment `<release name>-ibm-cpq-prod-ifsappserver` for IBM Sterling Sterling Field Sales application server with 1 replica by default.
* Create a deployment `<release name>-ibm-cpq-prod-ifshealthmonitor` for IBM Sterling Field Sales HealthMonitor, if health monitor is enabled.
* Create a deployment `<release name>-ibm-cpq-prod-<server name>` for each of the IBM Sterling Field Sales agent or integration server configured.
* Create a service `<release name>-ibm-cpq-prod-ifsappserver`. This service is used to access the IFS application server using a consistent IP address.
* Create a job `<release name>-ibm-cpq-prod-ifsdatasetup`. It is used for performing data setup for IFS that is required to deploy and run the IFS application. This may not be created if the data setup is disabled at the time of install or upgrade.
* Create a job `<release name>-ibm-cpq-prod-preinstall`. This is used to perform pre-installation activities like generating ingress tls secret.
* Create a ConfigMap `<release name>-ibm-cpq-prod-ifsconfig`. This is used to provide IFS and Liberty configuration.
* Create a ConfigMap `<release name>-ibm-cpq-prod-def-server-xml-conf`. This is used to provide default server.xml for Liberty. This will not be created if a custom server.xml is used.

**Note** : `<release name>` refers to the name of the helm release and `<server name>` refers to the agent/integration server name.


## Prerequisites for IFS.

1. Kubernetes version >= 1.11.3

2. Ensure that DB2 database server is installed and the database is accessible from inside the cluster. For database timezone considerations refer section "Timezone considerations".

3. Ensure that MQ server is installed and the MQ server is accessible from inside the cluster. 

4. Ensure that the docker images for IBM Sterling Field Sales are loaded to an appropriate docker registry. The default images for IBM Sterling Field Sales can be loaded  from IBM Passport Advantage. Alternatively, customized images for IBM Sterling Field Sales can also be used.

5. Ensure that the docker registry is configured in Manage -> Resource Security -> Image Policies and also ensure that docker image can be pulled on all of Kubernetes worker nodes.

6. Create a persistent volume with access mode as 'Read write many' with minimum 10GB space.

7. Create a secret with datasource connectivity details as given below. The name of this secret needs to be supplied as the value of parameter `ifs.appSecret`. It is recommended to prefix the release name to the secret name.
* Create a yaml file ifs_secrets.yaml as below.
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: "<release-name>-ifs-secrets"
type: Opaque
stringData:
  consoleadminpassword: "<liberty console admin password>"
  consolenonadminpassword: "<liberty console non admin password>"
  dbpassword: "<password for database user>"
```

* Run the below command. This will encode the values in the above file and create a Secret.

```sh
oc create  -f ifs_secrets.yaml -n <namespace>

```

* For IFS Create a persistent volume with access mode as 'Read write many' with minimum 10GB space.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ifs-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 12Gi
  nfs:
    path: [nfs-shared-path]
    server: [nfs-server]
  persistentVolumeReclaimPolicy: Retain

```

```
oc create -f ifs_pv.yaml -n <namespace>

```

8. If you are deploying IBM Sterling Field Sales on a namespace other than default, then create a Role Based Access Control(RBAC) if not already created, with cluster admin role.
* The following is an example of the RBAC for default service account on target namespace as `<namespace>`.

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ifs-role-<namespace>
  namespace: <namespace>
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list","create","delete","patch","update"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ifs-rolebinding-<namespace>
  namespace: <namespace>
subjects:
- kind: ServiceAccount
  name: default
  namespace: <namespace>
roleRef:
  kind: Role
  name: ifs-role-<namespace>
  apiGroup: rbac.authorization.k8s.io


```

9. Before configuring any agents or integration server in the chart, read the instructions provided in the "Configuring Agent or Integration Servers" section.

## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* ICPv3.1 - Predefined  PodSecurityPolicy name: [`default`](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/manage_cluster/enable_pod_security.html)
* ICPv3.1.1 - Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: apps/v1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy allows pods to run with 
      any UID and GID, but preventing access to the host."
  name: ibm-ifs-anyuid-psp
spec:
  allowPrivilegeEscalation: true
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities: 
  - MKNOD
  allowedCapabilities:
  - SETPCAP
  - AUDIT_WRITE
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - FSETID
  - KILL
  - SETUID
  - SETGID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETFCAP 
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
  forbiddenSysctls: 
  - '*' 
```
To create a custom PodSecurityPolicy, create a file `ifs_psp.yaml` with the above definition and run the below command
```sh
oc create -f ifs_psp.yaml
```

* Custom ClusterRole and RoleBinding definitions:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
  name: ibm-ifs-anyuid-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-ifs-anyuid-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ibm-ifs-anyuid-clusterrole-rolebinding
  namespace: <namespace>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ibm-ifs-anyuid-clusterrole
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:<namespace>

```
The `<namespace>` in the above definition should be replaced with the namespace of the target environment.
To create a custom ClusterRole and RoleBinding, create a file `ifs_psp_role_and_binding.yaml` with the above definition and run the below command
```sh
oc create -f ifs_psp_role_and_binding.yaml
```

## Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation.

The predefined `SecurityContextConstraints` name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

Alternatively, a custom `SecurityContextConstraints` can be created using,

* Custom SecurityContextConstraints definition:

```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
  name: ibm-ifs-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: []
allowedFlexVolumes: []
defaultAddCapabilities: []
fsGroup:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seccompProfiles:
- docker/default
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```
To create a custom `SecurityContextConstraints`, create a file `ibm-ifs-scc.yaml` with the above definition and run the below command
```sh
oc create -f ibm-ifs-scc.yaml
```

## Timezone considerations
In order to deploy Sterling Field Sales, the timezone of the database, application servers, and agents should be same. Additionally, this timezone must be compatible with the locale code specified in Sterling Field Sales.
By default, the containers are deployed in UTC, also the locale code in Order Management is set as en_US_UTC. Hence ensure that the database is also deployed in UTC.


## Configuration

### Installation on a new database
When installing the chart on a new database which does not have Sterling Field Sales tables and factory data, 
* ensure that `ifsdatasetup.loadFactoryData` parameter is set to `install` and `ifsdatasetup.mode` parameter is set as `create`. This will create the required database tables and factory data in the database before installing the chart.
* ensure that you do not specify any agents/integration servers with parameters `ifsagentserver.servers.name`. When installing against a fresh database, you will not have any agent and integration server configured in Order Management and hence it does not make sense to configure agents and integration servers in the chart. Once the application server is deployed, you can configure the agents/integration servers in Order Management. Refer section "Configuring Agent/Integration Servers" on how to deploy agents and integration servers.


### Installation against a pre-loaded database
When installing the chart against a database which already has the Sterling Field Sales tables and factory data ensure that `ifsdatasetup.loadFactoryData` parameter is set to `donotinstall` or blank. This will avoid re-creating tables and overwriting factory data.


### The following table lists the configurable parameters for the chart

Parameter                                    | Description                                                          | Default 
-----------------------------------------------| ---------------------------------------------------------------------| -------------
`ifs.license`                                  | Set the value to `accept` in order to accept the application license |
`ifsappserver.replicaCount`                    | Number of appserver instances                                        | `1`
`ifsappserver.image`                           | Docker image details of appserver                                    |   
`ifsappserver.config.vendor`                   | OMS Vendor                                                           | `websphere`
`ifsappserver.config.vendorFile`               | OMS Vendor file                                                      | `servers.properties`
`ifsappserver.config.serverName`               | App server name                                                      | `DefaultAppServer`
`ifsappserver.config.jvm`                      | Server min/max heap size and jvm parameters                          | `1024m` min, `2048m` max, no parameters
`ifsappserver.config.database.maxPoolSize`     | DB max pool size                                                     | `50`
`ifsappserver.config.database.minPoolSize`     | DB min pool size                                                     | `10`
`ifsappserver.config.corethreads`              | Core threads for Liberty                                             | `20`
`ifsappserver.config.maxthreads`               | Maximum threads for Liberty                                          | `100`
`ifsappserver.config.libertyServerXml`         | Custom server.xml for Liberty. Refer section "Customizing server.xml for Liberty" |
`ifsappserver.livenessCheckBeginAfterSeconds`  | Approx wait time(secs) to begin the liveness check                   | `900`
`ifsappserver.livenessFailRestartAfterMinutes` | Approx time period (mins) after which server is restarted if liveness check keeps failing for this period     | `10`
`ifsappserver.service.type`                    | Service type                                                         | `NodePort`
`ifsappserver.service.http.port`               | HTTP container port                                                  | `9080`
`ifsappserver.service.http.nodePort`           | HTTP external port                                                   | `30080`
`ifsappserver.service.https.port`              | HTTPS container port                                                 | `9443`
`ifsappserver.service.https.nodePort`          | HTTPS external port                                                  | `30443`
`ifsappserver.resources`                       | CPU/Memory resource requests/limits                                  | Memory: `2560Mi`, CPU: `1`
`ifsappserver.ingress.enabled`                 | Whether Ingress settings enabled                                     | true
`ifsappserver.ingress.host`                    | Ingress host                                                         |
`ifsappserver.ingress.controller`              | Controller class for ingress controller                              | nginx
`ifsappserver.ingress.contextRoots`            | Context roots which are allowed to be accessed through ingress       | ["smcfs", "sbc", "sma", "isccs", "wsc", "adminCenter"]
`ifsappserver.ingress.annotations`             | Annotations for the ingress resource                                 |
`ifsappserver.ingress.ssl.enabled`             | Whether SSL enabled for ingress                                      | true
`ifsappserver.podLabels`                       | Custom labels for the appserver pod                                  |
`ifsappserver.tolerations`                     | Tolerations for appserver pod. Specify in accordance with k8s PodSpec.tolerations. Refer section 
`importcert.secretname`                        | Secret name consisting of certificate to be imported into IFS.
"Affinity and Tolerations". | 
`ifsappserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ifsappserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ifsappserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`       | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". |
`ifsappserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ifsappserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`   | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". |
`ifsappserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`  | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ifsappserver.podAntiAffinity.replicaNotOnSameNode` | Directive to prevent scheduling of replica pod on the same node. valid values: `prefer`, `require`, blank. Refer section "Affinity and Tolerations". | `prefer`
`ifsappserver.podAntiAffinity.weightForPreference`  | Preference weighting 1-100. Used if 'prefer' is specified for `ifsappserver.podAntiAffinity.replicaNotOnSameNode`. Refer section "Affinity and Tolerations". | 100 
`ifsagentserver.image`                               | Docker image details of agent server                                 |  
`ifsagentserver.deployHealthMonitor`                 | Deploy health monitor agent                                          | `true`
`ifsagentserver.common.jvmArgs`                      | Default JVM args that will be passed to the list of agent servers    | 
`ifsagentserver.common.replicaCount`                 | Default number of instances of agent servers that will be deployed   |  
`ifsagentserver.common.resources`                    | Default CPU/Memory resource requests/limits                          | Memory: `1024Mi`, CPU: `0,5`
`ifsagentserver.common.readinessFailRestartAfterMinutes` | Approx time period (mins) after which agent is restarted if readiness check keeps failing for this period | 10
`ifsagentserver.common.podLabels`                                                        | Custom labels for the agent pod                                  |
`ifsagentserver.common.tolerations`                                                      | Tolerations for agent pod. Specify in accordance with k8s PodSpec.tolerations. Refer section "Affinity and Tolerations". | 
`ifsagentserver.common.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ifsagentserver.common.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ifsagentserver.common.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`       | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". |
`ifsagentserver.common.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ifsagentserver.common.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`   | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". |
`ifsagentserver.common.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`  | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`ifsagentserver.common.podAntiAffinity.replicaNotOnSameNode` | Directive to prevent scheduling of replica pod on the same node. valid values: `prefer`, `require`, blank. Refer section "Affinity and Tolerations". | `prefer`
`ifsagentserver.common.podAntiAffinity.weightForPreference`  | Preference weighting 1-100. Used if 'prefer' is specified for `ifsappserver.podAntiAffinity.replicaNotOnSameNode`. Refer section "Affinity and Tolerations". | 100 
`ifsagentserver.servers.group`                       | Agent server group name                                              | `Default Servers`
`ifsagentserver.servers.name`                        | List of agent server names                                           | 
`ifsagentserver.servers.jvmArgs`                     | JVM args that will be passed to the list of agent servers            | 
`ifsagentserver.servers.replicaCount`                | Number of instances of agent servers that will be deployed           |  
`ifsagentserver.servers.resources`                   | CPU/Memory resource requests/limits                                  | Memory: `1024Mi`, CPU: `0,5`
`datasetup.loadFactoryData`                    | Load factory data                                                    | 
`datasetup.mode`                               | Run factory data load in create                                      | `create`
`ifs.mq.bindingConfigName`                  | Name of the mq binding file config map                               | 
`ifs.mq.bindingMountPath`                   | Path where the binding file will be mounted                          | `/opt/ssfs/.bindings`
`ifs.persistence.claims.name`               | Persistent volume name                                               | oms-common
`ifs.persistence.claims.accessMode`         | Access Mode                                                          | ReadWriteMany
`ifs.persistence.claims.capacity`           | Capacity                                                             | 10
`ifs.persistence.claims.capacityUnit`       | CapacityUnit                                                         | Gi
`ifs.persistence.securityContext.fsGroup`   | File system group id to access the persistent volume                 | 0
`ifs.persistence.securityContext.supplementalGroup`| Supplemental group id to access the persistent volume          | 0
`ifs.image.repository`                      | Repository for Order management images                               |
`ifs.appSecret`                             | Order management secret name                                         |
`ifs.database.dbvendor`                     | DB Vendor DB2/Oracle                                                 | DB2
`ifs.database.serverName`                   | DB server IP/host                                                    |
`ifs.database.port`                         | DB server port                                                       |
`ifs.database.dbname`                       | DB name or catalog name                                              |
`ifs.database.user`                         | DB user                                                              |
`ifs.database.datasourceName`               | external datasource name                                             |jdbc/OMDS
`ifs.database.systemPool`                   | is DB system pool                                                    | true
`ifs.database.schema`                       | Database schema name.For Db2 it is defaulted as `ifs.database.dbname` and for Oracle it is defaulted as `ifs.database.user` |
`ifs.serviceAccountName`                    | Service account name                                                 |
`ifs.customerOverrides`                     | array of customer overrides properties as `key=value`                |
`ifs.envs`                                  | environment variables as array of kubernetes `EnvVars` objects       |
`ifs.arch`                                  | Architecture affinity while scheduling pods                          | amd64: `2 - No preference`, ppc64le: `2 - No preference`


## Ingress configuration
* Ingress can be enabled by setting the parameter `ifsappserver.ingress.enabled` as true. If ingress is enabled, then the application is exposed as a `ClusterIP` service, otherwise the application is exposed as `NodePort` service. It is recommended to enable and use ingress for accessing the application from outside the cluster. For production workloads, the only recommended approach is Ingress with cluster ip. Do not use NodePort.

* `ifsappserver.ingress.host` - the fully-qualified domain name that resolves to the IP address of your cluster’s proxy node. Based on your network settings it may be possible that multiple virtual domain names resolve to the same IP address of the proxy node. Any of those domain names can be used. For example "example.com" or "test.example.com" etc.

* `ifsappserver.ingress.ssl.enabled` - It is strongly recommended to enable SSL. If SSL is enabled by setting this parameter to true, a secret is needed to hold the TLS certificate.
If the optional parameter `ifsappserver.ingress.ssl.secretname` is left as blank, a secret containing a self signed certificate is automatically generated.

	However, for **production environments** it is strongly recommended to obtain a CA certified TLS certificate and create a secret manually as below.

 1. Obtain a CA certified TLS certificate for the given `ifsappserver.ingress.host` in the form of key and certificate files.
 2. Create a secret from the above key and certificate files by running below command
```sh
	oc create secret tls <Release-name>-ingress-secret --key <file containing key> --cert <file containing certificate> -n <namespace>
```
 3. Use the above created secret as the value of the parameter `ifsappserver.ingress.ssl.secretname`.

* `ifsappserver.ingress.contextRoots` - The context roots which are allowed to be accessed through ingress. By default the following context roots are allowed. 
`smcfs`, `sbc`,`ifs`, `wsc`, `adminCenter`. If any additional context root needs to be allowed through ingress then the same needs to be added to this list.

4. Set the following variables in the values.yaml
    1. Set the Registry from where you will pull the images-
        e.g. global.image.repository: "image-registry.openshift-image-registry.svc:5000/default" 
    2. Set the image names -
        e.g. ifsappserver.image.name: cpq-ifs-app 
        e.g. ifsappserver.image.tag: 10.0-x86-64
        e.g. ifsagentserver.image.name: cpq-ifs-agent
        e.g. ifsagentserver.image.tag: 10.0-x86-64
    3. Set the ingress host
        e.g. ifsappserver.ingress.host: "cpq.ifs.ibm.com.apps.whir.os.fyre.ibm.com"
    4. Check ifs.persistence.claims.name “ifs-common” matches with name given in    pvc.yaml.
    5. Check the ingress tls secret name is set correctly as per cert created above,
  in place of ifsappserver.ingress.ssl.secretname


## Installing the Chart
Prepare a custom values.yaml file based on the configuration section. Ensure that application license is accepted by setting the value of `ifs.license` to `accept`.

To install the chart with the release name `my-release`:
1. Ensure that the chart is downloaded locally by following the instructions given [here.](https://www.ibm.com/support/knowledgecenter/SS6PEW_10.0.0/com.ibm.help.install.omsoftware.doc/installation/c_OMRHOC_download_OMSChart.html)

2. In order to setup IFS Application set global.ifs.enable : true in values.yaml file.
3. Check the settings are good in values.yaml by simulating the install chart.
  cmd - helm template my-release stable/ibm-cpq-prod
  This should give you all kubernetes objects which would be getting deployed on Openshift.
  But this cmd won't install anything.
4. To install the application in Openshift run below cmd -
 cmd - helm install my-release [chartpath] --timeout 3600 --tls --namespace <namespace>
5. Test the installation -
  IFS - https://[hostname]/ifs/ifs/login.do?

Depending on the capacity of the kubernetes worker node and database connectivity, the whole deploy process can take on average 
* 2-3 minutes for 'installation against a pre-loaded database' and 
* 20-30 minutes for 'installation against a fresh new database'


When you check the deployment status, the following values can be seen in the Status column: – Running: This container is started. – Init: 0/1: This container is pending on another container to start.

You may see the following values in the Ready column: – 0/1: This container is started but the application is not yet ready. – 1/1: This application is ready to use.

Run the following command to make sure there are no errors in the log file:
```sh
oc logs <pod_name> -n <namespace> -f
```

## Affinity and Tolerations
The chart provides various ways in the form of node affinity, pod affinity, pod anti-affinity and tolerations to configure advance pod scheduling in kubernetes. Refer the kubernetes documentation for details on usage and specifications for the below features.

* Tolerations - This can be configured using parameter `ifsappserver.tolerations` for the appserver, and parameter `ifsagentserver.common.tolerations` for the agent servers.

* Node affinity - This can be configured using parameters `ifsappserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ifsappserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the appserver, and parameters `ifsagentserver.common.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ifsagentserver.common.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the agent servers.
Depending on the architecture preference selected for the parameter `global.arch`, a suitable value for node affinity is automatically appended in addition to the user provided values.

* Pod affinity - This can be configured using parameters `ifsappserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ifsappserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the appserver, and parameters `ifsagentserver.common.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ifsagentserver.common.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the agent servers.

* Pod anti-affinity - This can be configured using parameters `ifsappserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ifsappserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the appserver, and parameters `ifsagentserver.common.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ifsagentserver.common.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the agent servers.
Depending on the value of the parameter `podAntiAffinity.replicaNotOnSameNode`, a suitable value for pod anti-affinity is automatically appended in addition to the user provided values. This is to configure whether replicas of a pod should be scheduled on the same node. If the value is `prefer` then `podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` is automatically appended whereas if the value is `require` then `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` is appended. If the value is blank, then no pod anti-affinity value is automatically appended. If the value is `prefer` then the weighting for the preference is set using the parameter `podAntiAffinity.weightForPreference` which should be specified in the range 1-100.


## Configuring Agent/ or Integration Servers
Once you have a deployment ready with application server running, you can configure the agents and integration servers by logging into the IBM Order Management Application Manager. After completing the changes as described below, the release needs to be upgraded. Refer below for more details.


### IBM Sterling Field Sales related configuration
* You need to define the agent and integration servers in the Application Manager. 
* Once the agent or integration servers are defined, you can deploy (start) the same by providing the names of those agent or integration servers as a list to `ifsagentserver.servers.name` parameter in the chart values.yaml. For e.g.

```yaml
...
  servers:
  - group: "Logical Group 1"
    name:
    - scheduleOrder
    - releaseOrder
    jvmArgs: "-Xms512m\ -Xmx1024m"
    replicaCount: 1
    resources:
      requests:
        memory: 1024Mi
        cpu: 0.5

  - group: "Logical Group 2"
    name:
    - integrationServer1
    - orderPurge
    jvmArgs: "-Xms512m\ -Xmx1024m"
    replicaCount: 2
    resources:
      requests:
        memory: 1024Mi
        cpu: 0.5
...
```
Please note you cannot use underscore`(_)` character while defining the agent/integration server name.

* The parameters directly inside `ifsagentserver.common` e.g. jvmArgs, resources, tolerations etc will be applied to each of the `ifsagentserver.servers`. These parameters can also be overriden in each of `ifsagentserver.servers`. All the agent servers defined under the same group will share the same `ifsagentserver.common` parameters, e.g. `resources`. You can define multiple groups in `ifsagentserver.servers[]` if there is a requirement for different set of `ifsagentserver.common` parameters. For e.g, if you have a requirement to run certain agents with higher cpu and memory requests, or a higher replication count, you can define a new group and update its `resources` object accordingly.


### MQ related configuration
* Ensure that all the JMS resources configured in IBM Sterling Field Sales agents and integration servers are configured in MQ and corresponding `.bindings` file generated. 
* Create a ConfigMap for storing the MQ bindings. E.g. you can use the below command to create the ConfigMap from a given ".bindings" file.

```sh
oc create configmap <config map name> --from-file=<path_to_.bindings_file> -n <namespace>
```

* Ensure that the above ConfigMap is specified in the parameter `ifs.mq.bindingConfigName`.


Once the changes are made in the values.yaml file, you need to run the ``helm upgrade`` command. Refer section "Upgrading the Chart" for details.


## Readiness and Liveness
Readiness and liveness checks are provided for the agents and application server pods as applicable.

1. Application Server pod
The following parameters can be used to tune the readiness and liveness checks for application server pods.

* `ifsappserver.livenessCheckBeginAfterSeconds` - This can be used to specify the delay in starting the liveness check for the application server. The default value is 900 seconds (15 minutes).
* `ifsappserver.livenessFailRestartAfterMinutes` - This can be used to specify the approximate time period, after which the pod will get restarted if the liveness check keeps on failing continuously for this period of time. The default value is 10 minutes.

For E.g. if the values for `ifsappserver.livenessCheckBeginAfterSeconds` `ifsappserver.livenessFailRestartAfterMinutes` are `900` and `10` respectively, and the application server pod is not able to start up successfully after `25` minutes, then it will be restarted.
Further, after the application server has started up successfully, if the liveness check keeps failing continuously for a period of `10` minutes, then it will be restarted.

2. Agent server pod
The following parameter can be used to tune the readiness check for agent server pods.

* `ifsagentserver.common.readinessFailRestartAfterMinutes` - This can be used to specify the approximate time period, after which the pod will get restarted if the readiness check keeps on failing continuously for this period of time. The default value is 10 minutes.
For E.g. if the value for `ifsagentserver.common.readinessFailRestartAfterMinutes` is `10`, and the agent server pod is not able to start up successfully after `10` minutes, then it will be restarted.


## Customizing server.xml for Liberty
A custom server.xml for the liberty application server can be configured as below. Note that if a custom server.xml is not specified then a default server.xml is auto generated.

1. Create the custom server.xml file with the name `server.xml`.

2. Create a ConfigMap containing the custom server.xml with the below command
```sh
oc create configmap <config map name> --from-file=<path_to_custom_server.xml> -n <namespace>
```
3. Specify the above created ConfigMap in the chart parameter `ifsappserver.config.libertyServerXml`. 

**Important Notes:**
1. Ensure that the database information specified in the datasource section of server.xml is same as what is specified in the chart through the object `ifs.database`.
2. Ensure that the http and https ports in server.xml are same as specified in the chart through the parameters `ifsappserver.service.http.port` and `ifsappserver.service.https.port`.


## Upgrading the Chart

You would want to upgrade your deployment when you have a new docker image for application/agent server or a change in configuration, for e.g. new agent/integration servers to be deployed/started. 

1. Ensure that the chart is downloaded locally by following the instructions given [here.](https://www.ibm.com/support/knowledgecenter/SS6PEW_10.0.0/com.ibm.help.install.cpqoftware.doc/installation/c_OMRHOC_download_OMSChart.html)

2. Ensure that the `datasetup.loadFactoryData` parameter is set to `donotinstall` or blank. Run the following command to upgrade your deployments. 

```sh
helm upgrade my-release -f values.yaml [chartpath] --timeout 3600 --tls
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment run the command:

```sh
 helm delete my-release  --tls
```

Since there are certain kubernetes resources created using the `pre-install` hook, helm delete command will not delete them. You need to manually delete the following resources created by the chart.
* `<release name>`-ibm-cpq-prod-config
* `<release name>`-ibm-cpq-prod-def-server-xml-conf
* `<release name>`-ibm-cpq-prod-datasetup
* `<release name>`-ibm-cpq-prod-auto-ingress-secret

Note: You may also consider deleting the secrets and peristent volume created as part of prerequisites.

# Below content applies to CPQ irrespective of the application.
## Reinstall the Chart 
To re-install user need to first delete the deployment. 

`helm delete my-release`

Please make sure all the objects related to your release are deleted.

You can do that by `oc get all -l release=my-release`

* If you perform helm delete then it is mandatory to delete the pv and recreate it.
  `helm delete pv ifs-pv -n <namespace>`
  `oc create -f ifs_pv.yaml -n <namespace>`

This would give you all objects those are related to your release.
If you see any objects related to your release remaining , please go ahead and delete them by using `oc delete`.

To re-install , use `oc install --name=my-release [chartpath]`

## Import Certificates
If there is a requirement to import server certificates into CPQ (VM,OC,IFS), you can do that
by the import certificate feature of the chart. For e.g. integration with SFDC(Salesforce) will require to import certificates to CPQ.
* To do that follow below steps -
1. Get the certificate which you need to add to CPQ application.
   One way of getting a certificate is by exporting it through browser (lock icon in the location bar).
   The browser will show the certificate which you can save as either a .crt file or if you need the
   chain of certificates, .pem.
2. Save this file into the node where you have installed the helm charts.
3. You will need to create a Openshift secret object using this cert file.
   To do that execute the cmd
   `oc create secret generic vm-cert-secret --from-file=cert=vm.crt`
   or
   `oc create secret generic vm-cert-secret --from-file=cert=vm.pem`
   * Where vm.crt or vm.pem is the file which contains the certificate.
   * vm-cert-secret is the name of secret you need to give.
   * Note - To import multiple certificates you need to create a chain of certificates in a .pem file with below format -
     ```
      -----BEGIN CERTIFICATE-----
      XXX
      -----END CERTIFICATE-----
      -----BEGIN CERTIFICATE-----
      XXX
      -----END CERTIFICATE-----
      -----BEGIN CERTIFICATE-----
      XXX
      -----END CERTIFICATE-----
                                 <-- * Please Note a empty line at the bottom of the .pem file, this is mandatory.
     ```
4. For eg if you need to import this certificate into VM populate the Values.vmappserver.importcert.secretname
   by giving the secret name which you created in above step.
5. This certificate will be imported to the truststore of VM application server , once you install VM.
6. Similarly you can import certificates to OC and IFS.
7. To confirm the import of certificate is successful you can execute below cmd -
  `oc exec [podname] -- keytool -v -list -keystore /home/default/trustStore.jks`
   Where podname is the name of the pod got by `oc get pods`
   The password of the trustStore is `password`.

## Troubleshooting
The health of the applications can be checked by executing 

`oc get pods`

An exceprt is shown below for a pod named as mypod -
```
NAME   READY   STATUS
mypod  1/1     Running 
```
Where NAME is name of the pod running, and other columns show the status of the pods.
If you don't see READY status as above , you will need to collect log to identify the issue.
*Note: Application VisualModeler takes upto 5 mins to be up and running.

To get information about all pods running along with what node they are running on -

`oc get pods -o wide`

To get the information about events fired in the namespace -

`oc get events`

This would describe the pod that you are interested in, in a human readable format.

`oc describe pod mypod`

This would give the information about the pod in yaml format.

`oc get pod mypod -o yaml`

This would give the console logs of the pod.

`oc logs mypod`

Execute the above cmds to collect information about the pod you are interested in.
You can locate Events section when you describe a pod , to know any triggered events on the pod.
To get more information about the messages/errors found by executing above cmds you can visit -
https://docs.openshift.com

To know more about the application logs you can open a shell to the pod -

`oc rsh mypod`

This would allow you to execute linux cmds to locate logs.
To locate logs you can `cd /logs` inside the pod.
More debug logs can be found at `cd /output` inside the pod.
For easier view of log files you can copy logs out of the pod to your local, as below  e.g.

`oc cp mypod:/logs/messages.log ./messages.log`

To check whether the NFS is mounted in pod you can -

`oc rsh mypod `

and then 

`df -h` inside the pod.

To restart a pod you can simple delete it and it will auto restart -

`oc delete pod mypod`

The logs for VM and OC are available on the shared NFS where you store the repository.
You can mount the repository on a system and check out the logs in path /omscommonfile/configrepo in the repository. 
Look into the repository install section above 'Install repository' for repository details.
* Warning - Make sure your NFS storage has enough space for the logs and to use it adequately you may
want to clean the older logs.

Check yfs_application_menu to make sure IFS Field Sales application installed properly.
This table should contain Application_Menu_Key for Field Sales (Field_Sales_Menu).

Check yfs_heartbeat and make sure the entry HealthMonitor Service is present.

### Errors - Below section documents some common errors that user might face while deploying application.

* `ImagePullBackOff` - This error can mean multiple things, to get the exact error you will need to describe the pod
and look into the Events section.

* `CrashLoopBackOff` - A CrashloopBackOff means that you have a pod starting, crashing, starting again, and then crashing again.
You will need to describe the pod and look into the Events section.
Also you can look into the application logs my opening a session in the pod.

* `LivenessProbeFailure` - If the liveness probe fails, the Openshift kills the Container, and the Container is subjected to its restart policy. You can describe the pod and also look into application logs to identify any exception/error.

* `ReadinessProbeFailure` - Indicates whether the Container is ready to service requests. If the readiness probe fails, the endpoints controller removes the Pod’s IP address from the endpoints of all Services that match the Pod.
You can describe the pod and also look into application logs to identify any exception/error.

* If podman push or pull errors out with a error
Error: Error copying image to the remote destination: Error trying to reuse blob
or
Error: error pulling image
you will need to make sure you login to the registry where you want to push the image to.
Make sure you have logged in to the cluster by `oc login` and then
`podman login -u [username] -p $(oc whoami -t) [image-registry]`

## Resources Required 
1. Openshift Cluster
* Mininum - 1 Master 3 Worker nodes
* Minimum - Each Node should have 8CPU, 16GB RAM, 250GB Disk

2. VM/OC	
* 2560Mi memory for application servers
* 1 CPU core for application servers
* 3840Mi memory for application servers.
* 2 CPU core for application servers.

3. IFS
This chart uses the following resources by default:
* 2560Mi memory for application server
* 1024Mi memory for each agent/integration server and health monitor
* 1 CPU core for application server
* 0.5 CPU core for each agent/integration server and health monitor

## Upgrade Path
To get to the v10 container version -
* If user is on 9.x he would need to first upgrade to v10.
* Once on V10 then he would need to upgrade to v10 Containerized.
* The customer needs to download the v10 images , put any customization using the Base Image and use the
  same Database from the version he will be upgrading from. More documentation can be found on the Knowledge Center.
 
## Limitations
* The database must be installed in UTC timezone.

## Backup/recovery process
Back up of persistent data for IFS like Database back up needs to be taken on regular basis as a back up plan.
Since the application pods are stateless , there is no backup/recovery process required for the pods.

If needed the application once deployed can be deleted using helm delete --purge [release-name]

If needed the applicatin can be rolledback using helm rollback [release-name] 0

helm rollback - Roll back a release to a previous revision
To see revision numbers, run 
 - `helm history my-release`
 - `helm rollback my-release 0`
