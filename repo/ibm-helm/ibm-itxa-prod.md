# IBM Transformation Extender Advanced v10.0.1.3

## What's New
* Qualified on OpenShift Container Platform 4.6 and 4.7.

## Introduction
* The v10.0.1.3 release of IBM Transformation Extender Advanced is built and deployed on OpenShift 4.6.
* This document describes how to deploy IBM Transformation Extender Advanced v10.0.1.3. This helm chart does not install database server. Database need to be setup and configured separately for IBM Transformation Extender Advanced.

Note: This helm chart supports deployment of IBM Transformation Extender Advanced v10.0.1.3 with DB2, Oracle and MSSQL database.

## Checklist
* Use below checklist before launching the ITXA applications
* Helper scripts can be found in prereqs.zip to create pre-requisite cluster objects. This zip is packaged along with these charts.
1. Helm is installed
2. NFS is installed, if this is a option chosen for storing the logs
3. PV and PVC are created
4. Hostnames are identified for ITXA
5. Certificates for application hostnames are available
6. Secrets are created for above certificates
7. User is created in Database
8. Secrets are created with Database access information and key store
9. JDBC driver Jar is uploaded in Cloud Object Store or in NFS Share
10. Charts downloaded and fields in values.yaml are populated
11. Install charts via helm install cmd
12. Database Initialization is done via helm install cmd before installing ITXA UI

## Details

This chart deploys Transformation Extender Advanced on a container management platform with the following resources deployments

* Create a deployment `<release name>-ibm-itxa-prod-itxauiserver` for ITXA UI application server with 1 replica by default. 
* Create a deployment `<release name>-ibm-itxa-prod-itxadatasetup`. It is used for performing Database Initialization Job for ITXA that is required to deploy and run the ITXA application.
* Create a service `<release name>-ibm-itxa-prod-itxauiserver`. This service is used to access the ITXA application server using a consistent IP address.
* Create a ConfigMap `itxa-config`. This is used to provide ITXA configuration.
* service-account will be created if value is provided for .Values.global.serviceAccountName. This service will not be created if .Values.global.serviceAccountName is blank.

**Note** : `<release name>` refers to the name of the helm release and `<server name>` refers to the app server name.

## Prerequisites for ITXA

1. Kubernetes version >= 1.17.0

2. Ensure that DB2/Oracle/MSSQL database server is installed and the database is accessible from inside the cluster. For database timezone considerations refer section "Timezone considerations".

3. Ensure that the docker images for IBM Sterling Transformation Extender Advanced Software are loaded to an appropriate docker registry. The default images for IBM Sterling Transformation Extender Advanced can be downloaded from IBM Entitled Registry.

4. Ensure that the docker registry is configured in Manage -> Resource Security -> Image Policies and also ensure that docker image can be pulled on all of Kubernetes worker nodes.

5. When using podman for image operations for eg launching Base Container, make sure you have root priviledges for the logged in user. Otherwise option is to use sudo.

#### Downloading the IBM Certified Container Software helm chart from IBM Chart repository
You can download the IBM Transformation Extender Advanced helm chart from [IBM Public chart repository](https://github.com/IBM/charts/tree/master/repo/ibm-helm/ibm-itxa-1.0.0.tgz).


## Installing the Chart (Installing the ITXA UI Server)
Prepare a custom values.yaml file based on the configuration section. Ensure that application license is accepted by setting the value of `global.license` to true.

## Installing of ITXA Runtime Server with Integrating Product

1. Before installing ITXA Runtime Server with other products like ITX. It is important that either ITX Init DB Server or ITXA UI Server is installed via helm install cmd

2. ITXA Runtime server can be installed using the helm chart provided by Integrating product like ITX.


Note:
1. All the section in values.yaml like global, itxauiserver, itxadatasetup and metering need to be populated before installing ITXA UI Server.


## Installing the CASE
## Below steps gives an example to install the helm chart into 'default' namespace of Openshift.
* Note The file permissions set up in the ITXA Pod use owner as 1001 and group as root for the application related folders.

## Pre-requisites for installing ITXA UI Server

### Pulling Image directly from Entitled Registry - Option 1
Out of the box , the charts are programmed to pull the image directly from Entitled Registry - cp.icr.io/ibm-itxa.
(However you can change this behavior by going to Option 2.)
To do that follow below steps -

1.Create a secret -
`oc create secret docker-registry er-secret --docker-username=iamapikey --docker-password=[ER-Prod API Key] --docker-server=cp.icr.io`

2.Populate the field in charts in Values.yaml - global.image.pullsecret with the above secret name i.e. "er-secret"

3.The above steps should enable the charts to pull the images from Entitled Registry, when they are installed using helm.

## Air gap Installation - Option 2

You can install certified containers in an air gap environment where your Kubernetes cluster does not have access to the internet. Therefore, it is important to properly configure and install the certified containers in such an environment.

### Downloading ITXA case bundle

You can download ITXA Software case bundle and the Helm chart from the remote repositories to your local machine, which will eventually be used for offline installation by running the following command:

  ```bash
    cloudctl case save                                \
      --case <URL containing the CASE file to parse.> \
      --outputdir </path/to/output/dir> 
  ```

For additional help on `cloudctl case save`, run `cloudctl case save -h`.

### Setting credentials to pull or push certified container images

To set up the credentials for downloading the certified container images from IBM Cloud Registry to your local registry, run the appropriate command.

- For local registry without authentication

  ```bash
    # Set the credentials to use for source registry
    cloudctl case launch              \
    --case </path/to/downloaded/case> \
    --inventory ibmItxaProd         \
    --action configure-creds-airgap   \
    --args "--registry $SOURCE_REGISTRY --user $SOURCE_REGISTRY_USER --pass $SOURCE_REGISTRY_PASS"
  ```

- For local registry with authentication

  ```bash
    # Set the credentials for the target registry (your local registry)
    cloudctl case launch              \
    --case </path/to/downloaded/case> \
    --inventory ibmItxaProd         \
    --action configure-creds-airgap   \
    --args "--registry $TARGET_REGISTRY --user $TARGET_REGISTRY_USER --pass $TARGET_REGISTRY_PASS"
  ```

### Mirroring the certified container images

To mirror the certified container images and configure your cluster by using the provided credentials, run the following command:

  ```bash
    cloudctl case launch              \
    --case </path/to/downloaded/case> \
    --inventory ibmItxaProd         \ 
    --action mirror-images            \
    --args "--registry <your local registry> --inputDir </path/to/directory/that/stores/the/case>"
  ```

The certified container images are pulled from the source registry to your local registry that you can use for offline installation.

### Set up temporary registry service

You can create a temporary registry to store images on a bastion server or laptop.  The command will give the registry address, user, and password you can use as the destination registry.

  ```bash
    ./airgap.sh registry service init
    ./airgap.sh registry service start
  ```


### Installing the Helm chart in an air gap environment

Before you begin, ensure that you review and complete the [prerequisites.](#deployment-prerequisites)  

To install the Helm chart, run the following command:

  ```bash
    cloudctl case launch                    \
        --case </path/to/downloaded/case>   \
        --namespace <NAME_SPACE>            \
        --inventory ibmItxaProd           \
        --action install                    \
        --args "--values </path/to/values.yaml> --releaseName <release-name> --chart </path/to/chart>"
    
    # --values: refers to the path of values.yaml file.
    # --releaseName: refers to the name of the release.
    # --chart: refers to the path of downloaded chart.
  ```

### Uninstalling the Helm chart in an air gap environment

To uninstall the Helm chart, run the following command:

  ```bash
    cloudctl case launch                    \
        --case </path/to/downloaded/case>   \
        --namespace <NAME_SPACE>            \
        --inventory ibmItxaProd           \
        --action uninstall                  \
        --args "--releaseName <release-name>"
    
    # --releaseName: refers to the name of the release.
  ```

### Push Image to Openshift Image Registry - Option 3
If you have a image downloaded , please follow below steps if you plan to use the downloaded images by uploading to your Openshift Image Registry.
1. On a node from where you have access to the Openshift cluster make sure you have installed Openshift Command Line Interface (CLI).
   Also install podman to interact with Openshift Image Registry.
2. Openshift has image registry secured by default. In which case user need to expose the image registry service to 
   create a route. This is required to create a route URL to the image registry to faciliate
   to pushing ofimages so the application can pull it from while deploying. This would be in the field global.image.repository
   of the helm chart.
   Go to link https://docs.openshift.com/container-platform/4.6/registry/securing-exposing-registry.html
   and expose the svc to route for image registry.
   Please note above link is for version 4.6, please choose the appropriate version as per your installation.
3. Route URL will be created.
   For you this URL will be different and depends on the Openshift installation.
   We will refer to this as [image-registry-routeURL].
4. Open your route URL- https://[image-registry-routeURL] in a browser.

   Copy the certificate (eg firefox browser)
     * Firefox --> Click on https icon in the Location bar, there will be a pop up screen , you should see 'Connection Secure' 'or Connection Not Secure'. Click on 'Right arrow' to see 'Connection details'.
     * Click on 'More Information' and then click on button 'View Certificate'. 
     * The browser will open a new page. Locate the link 'Download' PEM (cert) to download the certificate(.crt) and save it.
     * Save the certificate in the node /etc/docker/certs.d/[image-registry-routeURL]/
5. Login to the Openshift Cluster
   `oc login [adminuser]` - Use whatever admin user was created with Openshift was installed.
6. Push the image to Openshift registry  
   Login to podman
   `podman login [image-registry-routeURL]` - you will need admin user credentials.
   * Once you login to the registry, you will need to tag it appropriately.
     For eg to push the image to 'default' namespace eg tag cmd for ITXA UI image would be -
     `podman tag [ImageId] [image-registry-routeURL]/default/itxa-ui-server:10.0.1.3-x86_64`
      Then push the image to this registry using 
     `podman push [image-registry-routeURL]/default/itxa-ui-server:10.0.1.3-x86_64`
7. Since you are now pointing to Openshift Repo you don't need the set the field pullsecret
   You can set the filed as  `global.image.pullsecret="'`.
   This will skip the imagepullsecret in the Pods.

### Helm Install 
* Install helm client
1. Install helm v3.4.1 from https://helm.sh/
   Install it on Linux client by running the command
   curl -s https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz | tar xz
   Locate helm executable and put it in $PATH
   You may want to update PATH variable in your linux login profile script.
2. `oc login to cluster` to login to OpenShift cluster
3. `helm version` (you will need to put helm in $PATH) to verify that the Helm client of correct version is installed.
  The above should show something like -
 * version.BuildInfo{Version:"v3.4.1", GitCommit:"c4e74854886b2efe3321e185578e6db9be0a6e29", GitTreeState:"clean", GoVersion:"go1.14.11"}

### Install repository (Below content explains how to install the repository on a NFS server.)

   Make sure you have set the permissions on the repository correctly.
   You can do that by mounting the above folder into a node and execute below cmds.
   * `sudo chown -R 1001 /[mounted dir]`
   * `sudo chgrp -R 0 /[mounted dir]`
   * `sudo chmod -R 770 /[mounted dir]`

   The above cmds make sure the repository folders and files have right permissions for the pods to access them.
   As noted the owner of the files in folders is the user 1001 and group as root.
   Also the rwx permissions are 770.
   
 ### Identify Sub Domain Name of your cluster
* Steps to find Sub Domain Name. You would need this information when you need to provide a hostname to provide to ingress and in sign-in certificates.
  Taking an eg of a cluster web console URL  - `https://console-openshift-console.apps.somename.os.mycompany.com`
  1. Identify the cluster name in the console URL, for eg somename is the cluster name.
  2. Identify the base domain which is placed after the cluster name. In above the base domain is os.mycompany.com.
  3. So sub domain name is derived as - apps.<cluster name>.<base domain> i.e.  apps.somename.os.mycompany.com

### Install Persistent related objects in Openshift - (Below are example files used to create Persistent Volume and related object using NFS server.)
* Note - The charts are bundled with sample files as templates , you can use these to plugin in your configuration and
  create pre-req objects. They are packaged in prereqs.zip along with the chart.

1. Download the charts from IBM site.
2. Create a persistent volume , persistent volume claim and storage class with access mode as 'Read write many' with minimum 12GB space.

* Create a itxa_pv.yaml file as below
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: itxa-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 12Gi
  nfs:
    path: [nfs-shared-path]]
    server: [nfs-server]
  persistentVolumeReclaimPolicy: Retain
  storageClassName: itxa-sc
```
`oc create -f itxa_pv.yaml`
* Create persistent volume claim , itxa_pvc.yaml file as below -
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: itxa-nfs-claim
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: itxa-sc
  volumeName: itxa-pv
  ```
`oc create -f itxa_pvc.yaml`
* Create a Storage class, file itxa_sc.yaml as below -
```  
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: itxa-sc
parameters:
  type: pd-standard
provisioner: kubernetes.io/gce-pd
reclaimPolicy: Retain
volumeBindingMode: Immediate
```
`oc create -f itxa_sc.yaml`

* Please note , the `name`s used in the pv,pvc,sc should have correct references across the files.

* Create a Database secret, file itxa-secrets.yaml as below -
```
apiVersion: v1
kind: Secret
metadata:
  name: itxa-secrets
type: Opaque
stringData:
  dbUser: xxxx
  dbPassword: xxxx
  dbHostIp: "1.2.3.4"
  databaseName: dbname
  dbPort: "50000"
```
`oc create -f itxa-secrets.yaml`

3. Create a secret tls-itxa-secret.yaml with a password for Liberty Keystore pkcs12.
```
apiVersion: v1
kind: Secret
metadata:
  name: tls-itxa-secret
type: Opaque
stringData:
  tlskeystorepassword: [tlskeystore password]
```
`oc create -f tls-itxa-secret.yaml`
Password can be anything, it will be used by Libterty for keystore access.
You will need to mention this secret name in Values.global.tlskeystoresecret field.

4. If you choose to create a self signed certificate for ingress, please follow below steps. 
  Create certificate and key for ingress - ingress.crt and key ingress.key
  This is for create cert for ingress object to enable https for ITXA.
  Prereq is to select a ingress host for launching ITXA.
  
  e.g. ingress host  your machine specific.
  Pleae note the ingress host should end in the subdomain name of your machine.
 
  cmd - 
  `openssl req -x509 -nodes -days 365 -newkey ./ingress.key -out ingress.crt -subj "/CN=[ingress_host]/O=[ingress_host]"`
  
  cmd - 
  `oc create secret tls itxa-ingress-secret --key ingress.key --cert ingress.crt`
 * You need to refer this secret name into values.yaml - itxauiserver.ingress.ssl.secretname
 * Also enable ssl by setting itxauiserver.ingress.ssl.enabled to true.

For **production environments** it is strongly recommended to obtain a CA certified TLS certificate and create a secret manually as below.

 1. Obtain a CA certified TLS certificate for the given `itxauiserver.ingress.host` in the form of key and certificate files.
 2. Create a secret from the above key and certificate files by running below command
```
	oc create secret tls <release-name>-ingress-secret --key <file containing key> --cert <file containing certificate> -n <namespace>
```
 3. Use the above created secret as the value of the parameter `itxauiserver.ingress.ssl.secretname`.

 4. Set the following variables in the values.yaml
    1. Set the Registry from where you will pull the images-
        e.g. global.image.repository: "cp.icr.io/ibm-itxa" 
    2. Set the image names -
        e.g. itxauiserver.image.name: itxa-ui-server
        e.g. itxauiserver.image.tag: 10.0.1.3-x86_64
    3. Set the ingress host
        * Note: The ingress host should end in same subdomain as the cluster node.
    4. Check global.persistence.claims.name “itxa-nfs-claim” matches with name given in pvc.yaml.
    5. Check the ingress tls secret name is set correctly as per cert created above, in place of itxauiserver.ingress.ssl.secretname

### Steps to set a default Password
1. Before installing ITXA UI Server create a secret file `itxa-user-secret.yaml`.

  Example: Replace <ADMIN_USER_PASSWORD> with password
  ```
  apiVersion: v1
  kind: Secret
  metadata:
    name: "<secrets_name>"
  type: Opaque
  stringData:
    adminPassword: "<ADMIN_USER_PASSWORD>"
  ```
 2. Create secret using following command

     ```
     kubectl create -f itxa-user-secret.yaml
     ```

 3. Provide the secret name in values.yaml in itxauiserver section against the field userSecret
    Example 
     ```
     itxauiserver:
       --------------
       --------------
       userSecret: "itxa-user-secret"
      ```

 4. Once ITXA UI Server is installed the user can login to application using the admin password provided in the secret file.

 **Note** : It is mandatory to create itxa-user-secret.yaml and set default password.

### To install the chart with the release name `my-release` via cmd line:
1. Ensure that the chart is downloaded locally by following the instructions given.
2. Set up which application you need to install.
Decide which application you need to install and set the 'enabled' flag to true for it, in the values.yaml file.
Preferred way is to install one application at a time. Hence you will need to disable the flag for the application once already installed.
  ```
   install:
    itxaUI:
      enabled: false
    itxadbinit:
      enabled: false
   ```
3. Check the settings are good in values.yaml by simulating the install chart.
  cmd - helm template --name=my-release [chartpath]
  This should give you all kubernetes objects which would be getting deployed on Openshift.
  This cmd won't actually install kubernetes objects.
4. To run Database Initialization script run below command
 ```
 helm install my-release [chartpath] --timeout 3600 --set global.license=true, global.install.itxaUI.enabled=false, global.install.itxadbinit.enabled=true
 ```
5. Similarly to install ITXA UI Application run below command
 ```
 helm install my-release [chartpath] --timeout 3600 --set global.license=true, global.install.itxaUI.enabled=true, global.install.itxadbinit.enabled=false
  ```
6. Test the installation -

  ITXA UI Login - https://[hostname]/spe/myspe

Depending on the capacity of the kubernetes worker node and database connectivity, the whole deploy process can take on average 
* 1-2 minutes for 'installation against a pre-loaded database' and 
* 15-20 minutes for 'installation against a fresh new database'

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

7. If you are deploying IBM Sterling Transformation Extender Advanced on a namespace other than default, then create a Role Based Access Control(RBAC) if not already created, with cluster admin role.
* The following is an example of the RBAC for default service account on target namespace as `<namespace>`.

```
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: itxa-role-<namespace>
  namespace: <namespace>
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list","create","delete","patch","update"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: itxa-rolebinding-<namespace>
  namespace: <namespace>
subjects:
- kind: ServiceAccount
  name: default
  namespace: <namespace>
roleRef:
  kind: Role
  name: itxa-role-<namespace>
  apiGroup: rbac.authorization.k8s.io


```

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
  name: ibm-itxa-anyuid-psp
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
To create a custom PodSecurityPolicy, create a file `itxa_psp.yaml` with the above definition and run the below command
```
oc create -f itxa_psp.yaml
```

* Custom ClusterRole and RoleBinding definitions:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
  name: ibm-itxa-anyuid-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-itxa-anyuid-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ibm-itxa-anyuid-clusterrole-rolebinding
  namespace: <namespace>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ibm-itxa-anyuid-clusterrole
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:<namespace>

```
The `<namespace>` in the above definition should be replaced with the namespace of the target environment.
To create a custom ClusterRole and RoleBinding, create a file `itxa_psp_role_and_binding.yaml` with the above definition and run the below command
```
oc create -f itxa_psp_role_and_binding.yaml
```
## Red Hat OpenShift SecurityContextConstraints Requirements

The Helm chart is verified with the predefined `SecurityContextConstraints` named [`ibm-anyuid-scc.`](https://ibm.biz/cpkspec-scc) Alternatively, you can use a custom `SecurityContextConstraints.` Ensure that you bind the `SecurityContextConstraints` resource to the target namespace prior to installation.

### SecurityContextConstraints Requirements

Custom SecurityContextConstraints definition:
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
  name: ibm-itxa-scc
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
  type: MustRunAsRange
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

To create a custom `SecurityContextConstraints`, create a yaml file with the custom `SecurityContextConstraints` definition and run the following command:

```sh
kubectl create -f <custom-scc.yaml>
```

## Timezone considerations
In order to deploy ITXA Software, the timezone of the database and application servers should be same. By default, the containers are deployed in UTC

## Configuration
### Ingress
* For ITXA UI Server Ingress can be enabled by setting the parameter `itxauiserver.ingress.enabled` as true. If ingress is enabled, then the application is exposed as a `ClusterIP` service, otherwise the application is exposed as `NodePort` service. It is recommended to enable and use ingress for accessing the application from outside the cluster. For production workloads, the only recommended approach is Ingress with cluster ip. Do not use NodePort.

* `itxauiserver.ingress.host` - the fully-qualified domain name that resolves to the IP address of your cluster’s proxy node. Based on your network settings it may be possible that multiple virtual domain names resolve to the same IP address of the proxy node. Any of those domain names can be used. For example "example.com" or "test.example.com" etc.

#### Uploading of Database Driver.

1. Depending upon the Database the Customer uses the respective JDBC Jar need to be uploaded either in S3 Object or Need to be stored in NFS Share.
2. IF Customer uploads Database driver in S3 Object. Then it is mandatory to provide accessKey and secretKey in itxa-secrets.yaml along with other DB Parameter.
3. In values.yaml in global section following details need to be provided
  database:
    dbvendor: <db_vendor>
    s3host: "<s3_host>"
    s3bucket: "<s3_bucket>"

### Installation of new database
This will create the required database tables and factory data in the database.

#### DB2 database secrets:
1. Create db2 database user.
2. Add following properties in `itxa-secrets.yaml` file.
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
    accessKey: "<ACCESS_KEY>"
    secretKey: "<SECRET_KEY>"

  ```
 3. Create secret using following command
     ```
     oc create -f itxa-secrets.yaml
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

3. Add following properties in `itxa-secrets.yaml`
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
    accessKey: "<ACCESS_KEY>"
    secretKey: "<SECRET_KEY>"
  ```
 4. Create secret using following command
     ```
     oc create -f itxa-secrets.yaml
     ```  
#### Once secret is created using above steps, make following changes in `values.yaml` file in order to install new database.

```yaml
global:
  appSecret: "<SECRET_NAME_CREATED_USING_ABOVE_STEPS>"
  database:
    dbvendor: <DBTYPE>
    
  install:
    itxaUI:
      enabled: false
    itxadbinit:
      enabled: false
      
itxadatasetup:
  dbType: "oracle"
  deployPacks:
    edi: false
    fsp: false
    hc: false
  tenantId: ""
  ignoreVersionWarning: true
  loadFactoryData: "install"
  

```
Then run helm install command to install database. 
  ```
   helm install my-release [chartpath] --timeout 3600 
  ```
  
### Import Maps into database

1. Pull the image directly from Entitled Registry, push into openshift registry and then populate the fields in charts to install new database. Also, set following parameters to false and then install the charts. This will not deploy any pack inside the container and maps also will not be imported into database. 

	```
	deployPacks:
    edi: false
    fsp: false
    hc: false
	```
2. Once you installed the db init job, then set following parameters to true in values.yaml depending upon which pack you want to deploy.
   e.g: Suppose we want to deploy all three packs, then set all three flags to true as below:
   ```
   deployPacks:
    edi: true
    fsp: true
    hc: true
   ```
3. Then copy the pack jars into database pod created after first deployment in step#1. Run following commands.

	```
	kubectl cp spe_edi_pack_for_ALL.jar <itxa-initdb-pod>:/opt/IBM/<ITXA_ROOT_DIR>
	kubectl cp spe_fsp_pack_for_ALL.jar <itxa-initdb-pod>:/opt/IBM/<ITXA_ROOT_DIR>
	kubectl cp spe_hc_pack_for_ALL.jar <itxa-initdb-pod>:/opt/IBM/<ITXA_ROOT_DIR>
	```
	e.g:
	```
	kubectl cp spe_edi_pack_for_ALL.jar <itxa-initdb-pod>:/opt/IBM/spe
	```
4. Once you copied the required pack jars into database pod, run following command to deploy the packs and import the maps.
	```
	kubectl exec <itxa-initdb-pod> -- bash -c "/opt/IBM/spe/bin/executeAll.sh --DBTYPE=<DBTYPE> --deployEDIPack=<true|false> --deployFSPPack=<true|false> --deployHCPack=<true|false> --tenantId=DEFAULT --ignoreVersionWarning=true --s3host=<S3_Provider> --bucket=<S3_bucket> --objectKey=<database_jar_name> --secureDBConnection=<true|false> && touch /opt/IBM/logs/db/itxadatasetup.complete"
	```
	
	e.g: In order to deploy all three packs, set all three flags deployEDIPack, deployFSPPack, deployHCPack to true.
	```
	kubectl exec <itxa-initdb-pod> -- bash -c "/opt/IBM/spe/bin/executeAll.sh --DBTYPE=oracle --deployEDIPack=true --deployFSPPack=true --deployHCPack=true --tenantId=DEFAULT --ignoreVersionWarning=true --s3host=<S3_Provider> --bucket=<S3_bucket> --objectKey=ojdbc8.jar --secureDBConnection=false && touch /opt/IBM/logs/db/itxadatasetup.complete"
	```
	
	
	
### The following table lists the configurable parameters for the ITXA UI Server and ITXA DB Init charts.

Parameter                                        | Description                                                          | Default 
-------------------------------------------------|----------------------------------------------------------------------| -------------
`itxauiserver.replicaCount`                       | Number of itxauiserver instances                                      | `1`
`itxauiserver.image`                              | Docker image details of itxauiserver                                  | `itxa-ui-server`
`itxauiserver.runAsUser`                          | Needed for non OpenShift Container Platform cluster                                           | `1001`
`itxauiserver.config.vendor`                      | ITXA Vendor                                                           | `websphere`
`itxauiserver.config.vendorFile`                  | ITXA Vendor file                                                      | `servers.properties`
`itxauiserver.config.serverName`                  | App server name                                                      | `DefaultAppServer`
`itxauiserver.config.jvm`                         | Server min/max heap size and jvm parameters                          | `1024m` min, `2048m` max, no parameters
`itxauiserver.livenessCheckBeginAfterSeconds`     | Approx wait time(secs) to begin the liveness check                   | `600`
`itxauiserver.livenessFailRestartAfterMinutes`    | Approx time period (mins) after which server is restarted if liveness check keeps failing for this period | `10`
`itxauiserver.service.type`                       | Service type                                                         | `NodePort`
`itxauiserver.service.http.port`                  | HTTP container port                                                  | `9080`
`itxauiserver.service.http.nodePort`              | HTTP external port                                                   | `30083`
`itxauiserver.service.https.port`                 | HTTPS container port                                                 | `9443`
`itxauiserver.service.https.nodePort`             | HTTPS external port                                                  | `30446`
`itxauiserver.resources`                          | CPU/Memory resource requests/limits                                  | Memory: `2560Mi`, CPU: `1`
`itxauiserver.ingress.enabled`                    | Whether Ingress settings enabled                                     | true
`itxauiserver.ingress.host`                       | Ingress host                                                         |
`itxauiserver.ingress.controller`                 | Controller class for ingress controller                              | nginx
`itxauiserver.ingress.contextRoots`               | Context roots which are allowed to be accessed through ingress       | ["spe","adminCenter","/"]
`itxauiserver.ingress.annotations`                | Annotations for the ingress resource                                 |
`itxauiserver.ingress.ssl.enabled`                | Whether SSL enabled for ingress                                      | true
`itxauiserver.ingress.routeTimeout`               | Set the route timeout, default is 1 hour
`itxauiserver.podLabels`                          | Custom labels for the itxauiserver pod                                  |
`itxauiserver.tolerations`                        | Tolerations for itxauiserver pod. Specify in accordance with k8s PodSpec.tolerations.         |
`itxauiserver.importcert.secretname`              | Secret name consisting of certificate to be imported into OC.
`itxauiserver.readinessProbePath`                 | Path for Readiness Probe
`itxauiserver.userSecret`                         | Secret name consisting of default admin password.
section "Affinity and Tolerations". | 
`itxauiserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`itxauiserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`itxauiserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`       | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". |
`itxauiserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`itxauiserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`   | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". |
`itxauiserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`  | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations". | 
`itxauiserver.podAntiAffinity.replicaNotOnSameNode` | Directive to prevent scheduling of replica pod on the same node. valid values: `prefer`, `require`, blank. Refer section "Affinity and Tolerations". | `prefer`
`itxauiserver.podAntiAffinity.weightForPreference`  | Preference weighting 1-100. Used if 'prefer' is specified for `itxauiserver.podAntiAffinity.replicaNotOnSameNode`. Refer section "Affinity and Tolerations". | 100 
`global.license`                                  | Set the value to true in order to accept the application license | false
`global.image.repository`                      | Registry for ITXA images                               |Entitled Repo- cp.icr.io/ibm-itxa, OpenShift Container Platform Internal Repo for default namespace - image-registry.openshift-image-registry.svc:5000/default
`global.image.pullsecret`                      | Used in imagePullSecrets of Pods, please see above - Pre-requisite steps .. Option 1 and 2 |
`global.appSecret`                             | ITXA secret name                                                      | `itxa-secrets`
`global.tlskeystoresecret`                     | ITXA TLS Keystore Secret for Liberty keystore password pkcs12     | `tls-store-secret`
`global.persistence.claims.name`               | Persistent volume name                                               | `itxa-nfs-claim`
`global.persistence.securityContext.fsGroup`   | File system group id to access the persistent volume                 | 0
`global.persistence.securityContext.supplementalGroup`| Supplemental group id to access the persistent volume          | 0
`global.database.dbvendor`                     | DB Vendor DB2/Oracle                                                 | DB2
`global.database.schema`                       | Database schema name.For Db2 it is defaulted as `global.database.dbname` and for Oracle it is defaulted as `global.serviceAccountName`                    | Service account name                                                 |
`global.arch`                                  | Architecture affinity while scheduling pods                          | amd64: `2 - No preference`, ppc64le: `2 - No preference`
`global.install.itxaUI.enabled`          | Install ITXA UI Server                                                 |
`global.install.itxadbinit.enabled`         | Run Database Initialization Job                                                |


## Affinity and Tolerations
The chart provides various ways in the form of node affinity, pod affinity, pod anti-affinity and tolerations to configure advance pod scheduling in kubernetes. 
Refer the kubernetes documentation for details on usage and specifications for the below features.

* Tolerations - This can be configured using parameter `itxauiserver.tolerations` for the itxauiserver and similarly for OC.

* Node affinity - This can be configured using parameters `itxauiserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `itxauiserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the itxauiserver, and parameters `itxauiserver.common.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `itxauiserver.common.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the itxauiserver.
Depending on the architecture preference selected for the parameter `global.arch`, a suitable value for node affinity is automatically appended in addition to the user provided values.

* Pod affinity - This can be configured using parameters `itxauiserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `itxauiserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the appserver, and parameters `itxauiserver.common.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `itxauiserver.common.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the itxauiserver.

* Pod anti-affinity - This can be configured using parameters `itxauiserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `itxauiserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the appserver, and parameters `itxauiserver.common.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `itxauiserver.common.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the itxauiserver.
Depending on the value of the parameter `podAntiAffinity.replicaNotOnSameNode`, a suitable value for pod anti-affinity is automatically appended in addition to the user provided values. This is to configure whether replicas of a pod should be scheduled on the same node. If the value is `prefer` then `podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` is automatically appended whereas if the value is `require` then `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` is appended. If the value is blank, then no pod anti-affinity value is automatically appended. If the value is `prefer` then the weighting for the preference is set using the parameter `podAntiAffinity.weightForPreference` which should be specified in the range 1-100.

## Readiness and Liveness
Readiness and liveness checks are provided for the application server pods as applicable.

1. Application Server pod
The following parameters can be used to tune the readiness and liveness checks for application server pods.

* `itxauiserver.livenessCheckBeginAfterSeconds` - This can be used to specify the delay in starting the liveness check for the application server. The default value is 900 seconds (15 minutes).
* `itxauiserver.livenessFailRestartAfterMinutes` - This can be used to specify the approximate time period, after which the pod will get restarted if the liveness check keeps on failing continuously for this period of time. The default value is 10 minutes.

For E.g. if the values for `itxauiserver.livenessCheckBeginAfterSeconds` `itxauiserver.livenessFailRestartAfterMinutes` are `900` and `10` respectively, and the application server pod is not able to start up successfully after `25` minutes, then it will be restarted.
Further, after the application server has started up successfully, if the liveness check keeps failing continuously for a period of `10` minutes, then it will be restarted.

## Secure database(SSL) Connection:

### Oracle:
#### Steps to enable SSL on oracle server:
1. Login with oracle user
2. Check where oracle is installed on oracle server i.e. check the ORACLE_HOME path. e.g: /u01/app/oracle/product/19.0.0/dbhome_1
3. Run following commands: 
- Create wallet folder. e.g: `mkdir -p /u01/app/oracle/wallet`
- Create a new auto-login wallet.
  ```
  orapki wallet create -wallet "/u01/app/oracle/wallet" -pwd WalletPasswd123 -auto_login
  ```
- Create a self-signed certificate and load it into the wallet.
   ```
   orapki wallet add -wallet "/u01/app/oracle/wallet" -pwd WalletPasswd123 -dn "CN=`hostname`" -keysize 1024 -self_signed -validity 3650
   ```
- Check the contents of the wallet. Notice the self-signed certificate is both a user and trusted certificate.
  ```
  orapki wallet display -wallet "/u01/app/oracle/wallet" -pwd WalletPasswd123
  ``` 	
- Export the certificate, so we can load it into the client machine later.
   ```
   orapki wallet export -wallet "/u01/app/oracle/wallet" -pwd WalletPasswd123 -dn "CN=`hostname`" -cert /tmp/`hostname`-certificate.crt
   ```
- Check the certificate has been exported as expected.	
  ```
  cat /tmp/`hostname`-certificate.crt
  ```
- Modify sqlnet.ora and listener.ora. Sample files are shown below. Make sure you modify these files with oracle user.
 
   Modify sqlnet.ora to specify WALLET_LOCATION, SQLNET.AUTHENTICATION_SERVICES, SSL_CLIENT_AUTHENTICATION and SSL_CIPHER_SUITES.
   Modify listener.ora to specify SSL_CLIENT_AUTHENTICATION, WALLET_LOCATION and modify the listener list.
   
   sample files for reference:
   ```
   # sqlnet.ora Network Configuration File: /u01/app/oracle/product/19.0.0/dbhome_1/network/admin/sqlnet.ora
   # Generated by Oracle configuration tools.

   NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT)

   WALLET_LOCATION =
      (SOURCE =
        (METHOD = FILE)
        (METHOD_DATA =
          (DIRECTORY = /u01/app/oracle/wallet)
        )
      )

   SQLNET.AUTHENTICATION_SERVICES = (TCPS,NTS,BEQ)
   SSL_CLIENT_AUTHENTICATION = FALSE
   SSL_CIPHER_SUITES = (SSL_RSA_WITH_AES_256_CBC_SHA, SSL_RSA_WITH_3DES_EDE_CBC_SHA)

   SSL_VERSIION = 1.2 or 1.1 or 1.0

   ```
   
   ```
   # listener.ora Network Configuration File: /u01/app/oracle/product/19.0.0/dbhome_1/network/admin/listener.ora
   # Generated by Oracle configuration tools.

  SID_LIST_LISTENER =
    (SID_LIST =
      (SID_DESC =
        (GLOBAL_DBNAME = orcl)
        (ORACLE_HOME = /u01/app/oracle/product/19.0.0/dbhome_1)
        (SID_NAME = ORCL)
      )
    )

  SSL_CLIENT_AUTHENTICATION = FALSE

  WALLET_LOCATION =
    (SOURCE =
      (METHOD = FILE)
      (METHOD_DATA =
        (DIRECTORY = /u01/app/oracle/wallet)
      )
    )

  LISTENER =
    (DESCRIPTION_LIST =
      (DESCRIPTION =
        (ADDRESS = (PROTOCOL = TCP)(HOST = dustcart1.fyre.ibm.com)(PORT = 1521))
        (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
        (ADDRESS = (PROTOCOL = TCPS)(HOST = dustcart1.fyre.ibm.com)(PORT = 2484))
      )
    )

  ADR_BASE_LISTENER = /u01/app/oracle

   ```

- Restart the listener.
  `lsnrctl stop`
  `lsnrctl start`

#### Steps to be performed on client machine:
1. Copy the database certificate created above /tmp/`hostname`-certificate.crt on cluster where you install the charts.
2. Create the secret for database server certificate using below command:
   ```
   oc create secret generic oracle-cert-secret --from-file=cert=<Name-of-DB-Server-Certificate>`
   ```
3. Populate the fields in charts in Values.yaml.
   Set `global.secureDBConnection.enabled` to `true` and `global.secureDBConnection.dbservercertsecretname` with above secret name i.e. "oracle-cert-secret"
4. Then install the charts.   

### DB2:
#### Steps to enable SSL on DB2 server:
1. Login with db2inst1 user.
2. Check where sqllib is present by using command:
   ```
   find / -name sqllib
   ```
   e.g: /home/db2inst1/sqllib
   
   Go to folder where this sqllib is present. i.e. cd /home/db2inst1
3. Run following command: 
- Create key database.
  ```
  gsk8capicmd_64 -keydb -create -db "mydbserver.kdb" -pw "myServerPassw0rdpw0" -stash
  ```
- Add a certificate for your server to your key database.
  ```
  gsk8capicmd_64 -cert -create -db "mydbserver.kdb" -pw "myServerPassw0rdpw0" -label "myselfsigned" -dn "CN=rhyme1.fyre.ibm.com,O=IBM,OU=IBM,L=Pune,ST=Maharashtra,C=IN"
  ```
  Make sure you have specified your db hostname in CN.
- Extract the certificate you just created to a file named `mydbserver.arm`
  ```
  gsk8capicmd_64 -cert -extract -db "mydbserver.kdb" -pw "myServerPassw0rdpw0" -label "myselfsigned" -target "mydbserver.arm" -format ascii -fips
  ```
- Run following commands to set the following configuration parameters. Make sure you use your key database filename, stash filename, ssl label in commands.
  ```
  db2 get dbm cfg  | grep SSL_SVR_KEYDB
	
  db2 update dbm cfg using SSL_SVR_KEYDB /home/db2inst1/mydbserver.kdb

  db2 get dbm cfg  | grep SSL_SVR_KEYDB

  db2 get dbm cfg  | grep SSL_SVR_STASH

  db2 update dbm cfg using SSL_SVR_STASH /home/db2inst1/mydbserver.sth

  db2 get dbm cfg  | grep SSL_SVR_STASH

  db2 get dbm cfg | grep SSL_SVR_LABEL

  db2 update dbm cfg using SSL_SVR_LABEL myselfsigned

  db2 get dbm cfg | grep SSL_SVR_LABEL

  db2 get dbm cfg  | grep SSL_SVCENAME	

  db2 update dbm cfg using SSL_SVCENAME 50001

  db2 get dbm cfg  | grep SSL_SVCENAME

  db2 get dbm cfg | grep SSL_VERSIONS

  db2 update dbm cfg using SSL_VERSIONS TLSv12

  db2 get dbm cfg | grep SSL_VERSIONS
  ```
- Add the value SSL to the DB2COMM registry variable. Run commands:
  ```
  db2set
  db2set -i db2inst1 DB2COMM=SSL,TCPIP
  db2set
  ```
- Restart the DB2 instance.
  ```
  db2stop
  db2start
  ```
#### Steps to be performed on client machine:
1. Copy the database certificate created above `mydbserver.arm` on cluster where you install the charts.
2. Create the secret for database server certificate using below command:
   ```
   oc create secret generic db2-cert-secret --from-file=cert=<Name-of-DB-Server-Certificate>`
   ```
3. Populate the fields in charts in Values.yaml.
   set `global.secureDBConnection.enabled` to `true` and `global.secureDBConnection.dbservercertsecretname` with above secret name i.e. "db2-cert-secret"
4. Then install the charts.

## Upgrading the Chart

You would want to upgrade your deployment when you have a new docker image for application server or a change in configuration, for e.g. new application servers to be deployed/started. 

1. Ensure that the chart is downloaded locally by following the instructions given [here.](https://www.ibm.com/support/knowledgecenter/SS4QMC_10.0.0/installation/ITXARHOC_downloadHelmchart.html)

2. Ensure that the `itxadatasetup.loadFactoryData` parameter is set to `donotinstall` or blank. Run the following command to upgrade your deployments. 

```
helm upgrade my-release -f values.yaml [chartpath] --timeout 3600 --tls
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment run the command:

```
 helm delete my-release  --tls
```
Note: If you need to clean the installation you may also consider deleting the secrets and peristent volume created as part of prerequisites.


## Limitations
* The database must be installed in UTC timezone.

## Backup/recovery process
Back up of persistent data for ITXA falls in two types - Database and the Repository.
Database back up needs to be taken on regular basis as a back up plan.
Similary the repository folders should be backed up on regular basis to back up the models xml files and other properties defined as a part of repository.
Since the application pods are stateless , there is no backup/recovery process required for the pods.
If needed the application once deployed can be deleted using helm del [release-name]
If needed the applicatin can be rolledback using helm rollback [release-name] 0

## Customizing server.xml for Liberty 
### You can customize the server.xml of liberty via helm charts. 
There is a provided itxa-ui-server.xml , which will be deployed as server.xml to the liberty application.
* Warning - Please don't change out of the box settings provided in server xml, it may impact the application.

## Resources Required 
1. Openshift Cluster 4.6
* Minimum - 3 Master 3 Worker nodes
* Minimum - Each Node should have 8CPU, 16GB RAM, 250GB Disk

2. ITXAUIServer/ITXAInitDB	
* 2560Mi memory for application servers
* 1 CPU core for application servers
* 3840Mi memory for application servers.
* 2 CPU core for application servers.
