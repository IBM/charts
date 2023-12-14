
IBM Transformation Extender Advanced v10.0.1.8

## What's New

ITXA 10.0.1.8 Certified Container release.
See IBM ITXA Documentation for a full list of [what's new in ITXA 10.0.1.8.](https://www.ibm.com/docs/en/stea/10.0?topic=welcome-whats-new-in-version-10018)

## Introduction
[IBM Transformation Extender Advanced (ITXA)](https://www.ibm.com/docs/en/stea/10.0) includes support for Enveloping, De-enveloping, and processing of Standards based documents.  This includes validation and acknowledgement generation.  It also supports tranformation via either the IBM Transformation Extender (ITX) or Sterling B2BI Integrator core engines.  ITXA can also leverage the ITX Financial Payment, Supply Chain, or HealthCare packs to support industry specific standards.

## Chart Details

This chart deploys Transformation Extender Advanced on a container management platform with the following resources deployments

* Create a deployment `<release name>-ibm-itxa-prod-itxauiserver` for ITXA UI application server with 1 replica by default. 
* Create a deployment `<release name>-ibm-itxa-prod-itxadatasetup`. It is used for performing Database Initialization Job for ITXA that is required to deploy and run the ITXA application.
* Create a service `<release name>-ibm-itxa-prod-itxauiserver`. This service is used to access the ITXA application server using a consistent IP address.
* Create a ConfigMap `itxa-config`. This is used to provide ITXA configuration.
* service-account will be created if value is provided for .Values.global.serviceAccountName. This service will not be created if .Values.global.serviceAccountName is blank.

**Note** : `<release name>` refers to the name of the helm release and `<server name>` refers to the app server name.

## Prerequisites
## Quickstart Checklist

1. Redhat Openshift Container Platform version 4.10, 4.11, or 4.12 or Kubernetes Cluster version 1.23 to 1.26 is available.
2. Ensure that all images are downloaded from the IBM Entitled Registry and pushed to an image registry accessible by the cluster.  See [Downloading Artifacts](https://www.ibm.com/docs/en/stea/10.0?topic=images-downloading-artifacts) for more details.
3. [Download the helm chart](https://www.ibm.com/docs/en/stea/10.0?topic=da-downloading-certified-container-helm-charts-from-chart-repository) from the IBM Charts repository and Extract to a working directory.
4. If integrating ITXA with B2BI, it is recommended to install ITXA and B2BI in the same namespace.  If not you will need to duplicate the Persistent Volume (PV) and create separate Persistent Volume Claims (PVCs) in each namespace.
5. The ITXA PVC is automatically created for you based on settings in values.yaml under global.persistence section. If you enable dynamic provisioning, the PV will also be created for you at deployment time. If you disable dynamic provisioning, you need to create PV using the sample  [Persistent Volume yaml](#install-persistent-related-objects-in-openshift) below. The storage class you use must support ReadWriteMany (RWX) Storage since the volume will be shared between the ITXA and B2BI Pods.
6. Determine Subdomain for your cluster using the info from [Identify Sub Domain Name of your cluster](#Identify-Sub-Domain-Name-of-your-cluster) below.  This info will be needed later in values.yaml.
7. Create The following Kubernetes Secrets per [the instructions below](#install-Persistent-related-objects-in-openshift): itxa-db-secret, tls-itxa-secret, itxa-ingress-secret and itxa-user-secret.
8. Create Role, RBAC, Pod Security Policy, Cluster Role, Cluster Rolebinding, and Security Context Constraint [using sample yamls below](#PodSecurityPolicy-Requirements) -
    **Red Hat OpenShift SecurityContextConstraints Requirements** and **PodSecurityPolicy Requirements**
9. Configure the proper JDBC driver to match the Database you are using.  For detailed instructions see [Specifying the proper database driver](#specifying-the-proper-database-driver) below.
10. Populate necessary sections in the values.yaml that is included with the helm chart.
    1.  Set License to true.
    2.  Add proper images and tags and pull secret for your repo.
    3.  Add proper secret names to match the secrets you created.
    4.  Update the itxauiserver.ingress.host to match the appname and subdomain you determined in step 6 above.
11.  User 1001 must have access to the NFS volume mounted via the PVC.  How you do this varies depending on what storage provider you are using.  In some cases you can do it directly from the NFS share, in other cases you may need to mount the PVC via a container running as root and run:
        - `chown -R 1001 /[mounted dir]`
        - `chgrp -R 0 /[mounted dir]`
        - `chmod -R 770 /[mounted dir]`

12. If user needs to install any of the packs, refer the section below [Adding ITXA Packs](#adding-itxa-packs) to modify the itxa-init-db image, add the packs, and push the new image to your repo. Once db init image is modified with packs, edit values.yaml as follows:

Set itxadbinit to true. 
Set the itxaUI to false
Set the packs to true.  

```
 install:
  itxaUI:
    enabled: false
  itxadbinit:
    enabled: true
	
itxadatasetup:
  dbType: <DB_TYPE>
  deployPacks:
    edi: true
    fsp: true
    hc: true
```	

Then run helm install pointing to the values.yaml you've been editing. For example to use the values.yaml and helm charts in the default ibm-itxa-prod directory run:  
`helm install <releasename> -f ibm-itxa-prod/values.yaml ./ibm-itxa-prod --timeout 3600s --debug`.  

This will initialize the Database with the proper tables.  This can take several minutes to an hour depending on database latency and resources.

13. Once complete, modify values.yaml to disable itxadbinit and enable itxaUI and install the ITXA UI per below. 

   ```
   install:
   itxaUI:
    enabled: true
   itxadbinit:
    enabled: false
   ```
	
Then, run  `helm upgrade` with the same command line you ran for helm install above.
	
   Verify the ITXA UI pod comes up and you can connect to it via `https://[hostname]/spe/myspe` with ID "admin" and the password you specified in the parameter `adminPassword` of `itxa-user-secret.yaml` file.
   Hostname should match the app and subdomain name you determined above.  For example `https://itxa.mycluster.mydomain.com`


## Detailed Instructions


## Installing the Chart (Installing the ITXA UI Server)

Prepare a custom values.yaml file based on the configuration section. Ensure that application license is accepted by setting the value of `global.license` to true.

Note:

1. Ensure that all the sections in values.yaml like global, itxauiserver, itxadatasetup and metering need to be populated before installing ITXA UI Server. The sample values.yaml is provided in the helm charts.


### Helm Install

### Configure  repository (Below content explains how to configure the repository (NFS Share folder) on a NFS server.)
Refer the URL for NFS server: https://www.linuxtechi.com/setup-nfs-server-on-centos-8-rhel-8/
Make sure you have set the permissions on the repository correctly.
You can do that by mounting the above folder into a node and execute below cmds on NFS server.

- `sudo chown -R 1001 /[mounted dir]`
- `sudo chgrp -R 0 /[mounted dir]`
- `sudo chmod -R 770 /[mounted dir]`

The above cmds make sure the repository folders and files have right permissions for the pods to access them.
As mentioned, the owner of the files in repository folders, is the user 1001 and group as root.
Also the rwx permissions are 770.

### Identify Sub Domain Name of your cluster

- Steps to find Sub Domain Name. 
  You would need this information when you need to provide a hostname to provide to ingress and in sign-in certificates.
  Taking an example of a cluster web console URL - `https://console-openshift-console.somename.os.mycompany.com`
  1. Identify the cluster name in the console URL, for eg somename is the cluster name.
  2. Identify the base domain which is placed after the cluster name. In above the base domain is os.mycompany.com.
  3. So sub domain name is derived as - app.<cluster name>.<base domain> i.e. apps.somename.os.mycompany.com

# Install Persistent related objects in Openshift

- Note - The charts are bundled with sample files as templates , you can use these to plugin in your configuration and
  create pre-req objects. They are packaged in prereqs.zip along with the chart.

1. Download the charts from IBM site.
2. Create a storage class and persistent volume with access mode as 'Read write many' with minimum 12GB space.

- Create persistent volume, itxa_pv.yaml file as below -

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: itxa-pv
  labels:
    intent: itxa-logs
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 12Gi
  nfs:
    path: /shared/nfs
    server: my.nfs.server.com
  persistentVolumeReclaimPolicy: Retain
  storageClassName: itxa-sc
```

`oc create -f itxa_pv.yaml`

- Create a Storage class, file itxa_sc.yaml as below -

```yaml
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

* Create a Database secret, file itxa-db-secret.yaml as below -
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: itxa-db-secret
type: Opaque
stringData:
  dbUser: xxxx
  dbPassword: xxxx
  dbHostIp: "1.2.3.4"
  databaseName: dbname
  dbPort: "50000"
```
`oc create -f itxa-db-secret.yaml`

3. Create a secret tls-itxa-secret.yaml with a password for Liberty Keystore pkcs12.
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-itxa-secret
type: Opaque
stringData:
  tlskeystorepassword: [tlskeystore password]
```
`oc create -f tls-itxa-secret.yaml`
Password can be anything, it will be used by Liberty for keystore access.
You will need to mention this secret name in Values.global.tlskeystoresecret field.

4. If you choose to create a self signed certificate for ingress, please follow below steps. 
  Create certificate and key for ingress - ingress.crt and key ingress.key
  This is for create cert for ingress object to enable https for ITXA.
  Prereq is to select a ingress host for launching ITXA.
  
  e.g. ingress host  your machine specific.
  Pleae note the ingress host should end in the subdomain name of your machine.
 
  cmd - 
  `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./ingress.key -out ./ingress.crt -subj "/CN=[ingress_host]/O=[ingress_host]"`
  
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
    4. Check the ingress tls secret name is set correctly as per cert created above, in place of itxauiserver.ingress.ssl.secretname

### Steps to set a default Password
1. Before installing ITXA UI Server create a secret file `itxa-user-secret.yaml`.

  Example: Replace <ADMIN_USER_PASSWORD> with password
  ```yaml
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


### To install the chart with the release name `my-release` via cmd line:

1. Ensure that the chart is downloaded locally by following the instructions given [here.](https://www.ibm.com/support/knowledgecenter/SS4QMC_10.0.0/installation/ITXARHOC_downloadHelmchart.html)
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
For example:
helm install initdb --values=values.yaml --set global.install.itxadbinit.enabled=true ibm-itxa-prod-1.0.0.tgz


5. Similarly to install ITXA UI Application run below command

```
helm install my-release [chartpath] --timeout 3600s --set global.license=true, global.install.itxaUI.enabled=true, global.install.itxadbinit.enabled=false
```
helm install itxaui --values=values.yaml --set global.install.itxaUI.enabled=true ibm-itxa-prod-1.0.0.tgz

6. Test the health of the pods -

Depending on the capacity of the kubernetes worker node and database connectivity, the whole deploy process can take on average

- 1-2 minutes for 'installation against a pre-loaded database' and
- 15-20 minutes for 'installation against a fresh new database'

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

Test the installation - 

Check if the routes are created by running command - 
```
oc get routes
```

You can get the application 
ITXA UI Login - https://[hostname]/spe/myspe


## PodSecurityPolicy Requirements

With Kubernetes v1.25, the Pod Security Policy (PSP) API has been removed and replaced with Pod Security Admission (PSA) contoller. Kubernetes PSA conroller enforces predefined Pod Security levels at the namespace level. The Kubernetes Pod Security Standards defines three different levels: privileged, baseline, and restricted. Refer to Kubernetes [Pod Security Standards] ( https://kubernetes.io/docs/concepts/security/pod-security-standards/) documentation for more details. For users upgrading from older Kubernetes version to v1.25 or higher, refer to Kubernetes Migrate from PSP documentation to help with migrating from PodSecurityPolicies to the built-in Pod Security Admission controller.
For users continuing on older Kubernetes versions (<1.25) and using PodSecurityPolicies, choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you. Below is an optional custom PSP definition based on the IBM restricted PSP.

- Custom PodSecurityPolicy definition:

```yaml
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

- Custom ClusterRole and RoleBinding definitions:

```yaml
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

The Helm chart is verified with the predefined `SecurityContextConstraints` named [`anyuid.`](https://ibm.biz/cpkspec-scc) 
Run the following command to bind this predefined scc `anyuid` to the ServiceAccount <serviceaccount> on target namespace as <namespace>.

```
oc adm policy add-scc-to-user anyuid system:serviceaccount:[namespace]:[serviceaccount]
	
```


Alternatively, you can use a custom `SecurityContextConstraints.` Ensure that you bind the `SecurityContextConstraints` resource to the target namespace prior to installation.

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

```
kubectl create -f <custom-scc.yaml>
```

## Configuration

### Ingress

- For ITXA UI Server Ingress can be enabled by setting the parameter `itxauiserver.ingress.enabled` as true. If ingress is enabled, then the application is exposed as a `ClusterIP` service, otherwise the application is exposed as `NodePort` service. It is recommended to enable and use ingress for accessing the application from outside the cluster. For production workloads, the only recommended approach is Ingress with cluster ip. Do not use NodePort.

- `itxauiserver.ingress.host` - the fully-qualified domain name that resolves to the IP address of your cluster’s proxy node. Based on your network settings it may be possible that multiple virtual domain names resolve to the same IP address of the proxy node. Any of those domain names can be used. For example "example.com" or "test.example.com" etc.

#### Specifying the proper database driver

The jdbc jars are bundled in the image "itxa-resources". These jars will be available in the ITXA containers at location /ibm/resources. So now, customer does not need to upload jars either in S3 Object or store in NFS Share.

Populate following fields in values.yaml to use these jdbc jars present inside the containers.
a. Set global.resourcesInit.enabled to true.
b. Provide image name and tag for "itxa-resources".
c. Comment the following fields for S3 storage:
global.database.s3host, global.database.s3bucket, global.database.dbDriver

Example resourcesInit section in values.yaml:

```
resourcesInit:
enabled: true
image:
name: itxa-resources
tag: <tag_name>
#digest: sha256:1d9045511c1203e6d6d25ed32c700dfca230076412915857c2c40b1409151b7c
pullPolicy: "IfNotPresent"
```

### Installation of new database

This will create the required database tables and factory data in the database.


1. Create db2 database user.
2. Add following properties in `itxa-db-secret.yaml` file.

```yaml
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

3.  Create secret using following command
    ```
    oc create -f itxa-db-secret.yaml
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
    edi: true
    fsp: true
    hc: true
  tenantId: ""
  ignoreVersionWarning: true
  loadFactoryData: "install"
```

Then run helm install command to install database.

```
 helm install my-release [chartpath] --timeout 3600
```


## Upgrading the Chart

You would want to upgrade your deployment when you have a new docker image for application server or a change in configuration, for e.g. new application servers to be deployed/started.

1. Ensure that the chart is downloaded locally by following the instructions given [here.](https://www.ibm.com/support/knowledgecenter/SS4QMC_10.0.0/installation/ITXARHOC_downloadHelmchart.html)

2. Ensure that the `itxadatasetup.loadFactoryData` parameter is set to `donotinstall` or blank. Run the following command to upgrade your deployments.

```
helm upgrade my-release -f values.yaml [chartpath] --timeout 3600 --tls
```
## Adding ITXA Packs

In order to use the ITXA Financial Payments, HealthCare, or Supply Chain Packs, they must be manually added to the itxa-init-db image.
To do this:
1.  Download any ITXA packs you have entitlement for to a local directory.
2.  Create the following file below and name it `Dockerfile`.  You can remove any copy commands for packs you do not have.
```
FROM <repo location>/itxa-init-db:<tag>
COPY <local dir>/spe_edi_pack_for_ALL.jar /opt/IBM/spe/.
COPY <local dir>/spe_fsp_pack_for_ALL.jar /opt/IBM/spe/.
COPY <local dir>/spe_hc_pack_for_ALL.jar /opt/IBM/spe/.
```
Save the image and run `docker build -t Dockerfile`

To do this, you must create a Dockerfile and run `docker build <directory containing Dockerfile>` to build a new version of the itxa-init-db image containing the packs

This will build the image and load it to the docker repo on your local machine.  From there you can use docker tag and docker push to provide a new image tag and push to your internal repo.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment run the command:

```
 helm delete my-release  --tls
```

Note: If you need to clean the installation you may also consider deleting the secrets and peristent volume created as part of prerequisites.

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
`global.appSecret`                             | ITXA DB Secret Name.  Used to store DB connection info  | `itxa-db-secret`
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


## Limitations

1.  Getting permission errors on persistent volume access when I try to deploy the chart.

This is due to the container user (UID 1001) not having the appropriate permissions on the NFS file share that is used for the PV and PVC.  If you have access to the NFS storage directly you can add this user.  Otherwise another option if you are using OCP is to deploy a container with root access, connect it to the PVC, run the chmod from that container, then exit and delete the POD/deployment.  One way to do this is described below.

Create Busybox deployment and set proper access on ITXA file share.
  1.  Create a busybox deployment yaml that mounts the same pvc name that you are using for the itxa common pvc.
  2.  Create the deployment using `oc create -f busybox.yaml`
  3.  This will create the deployment, but it may not deploy a pod due to incompatible security settings.  This is fine.
  4.  Deploy a debug pod with root access based on the busybox deployment.  `oc debug busybox --as-root -n <project_name>`
  5.  Once the container comes up, open the terminal for it, change to the directory where you mounted the PVC and change permissions.
        - `chown -R 1001 /[mounted dir]`
        - `chgrp -R 0 /[mounted dir]`
        - `chmod -R 770 /[mounted dir]`
        Note you only have to do this once unless you delete and recreate the volume.  Once the permissions are set properly they won't need to be touched again if you uninstall and reinstall the chart.
  6.  Once you are done you can delete the deployment which will also delete the pod.

  2.  Getting a nonfatal general error when itxa-init-db job tries to run which fails the installation.

  The DB init job fails to complete and in the logs you see:

  Caused by: <openjpa-2.4.3-r422266:1833086 nonfatal general error> org.apache.openjpa.persistence.PersistenceException: DB2 SQL Error: SQLCODE=-613, SQLSTATE=54008, SQLERRMC=PRIM_KEY..., DRIVER=4.32.28 {stmnt -1060018007 CREATE TABLE SPE_CODELIST_ITEM_COLUMN (PRIM_KEY VARCHAR(1072) NOT NULL, COLUMN_NAME VARCHAR(255), COLUMN_VALUE VARCHAR(255), ITEM_KEY VARCHAR(816), LIST_KEY VARCHAR(304), PRIMARY KEY (PRIM_KEY))} [code=-613, state=54008]

  This is caused by the database being set up to use 4k pages.  4k pages are too small for a varchar(1024) primary key resulting in the error.

  To correct this, you will need to drop the existing tablespace and recreate the appropriate tablespaces to use 32k pages.


## Resources Required

Openshift Cluster v4.12 or v4.13



