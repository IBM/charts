# IBM CLOUD TRANSFORMATION ADVISOR

Useful videos can be found [here](https://transformationadvisor.github.io/video/).

## Introduction

[IBM Cloud Transformation Advisor](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/featured_applications/transformation_advisor.html) helps you plan, prioritize, and package your on-premises workloads for modernization on IBM Cloud and IBM Cloud Private. 

IBM Cloud Transformation Advisor will:
 - Gather your preferences regarding your current on-premises environment and desired cloud environments
 - Analyze your existing middleware deployments and upload the results to the IBM Cloud Transformation Advisor UI with a downloaded data collector
 - Provide recommendations for cloud migration and modernization as well as an estimated effort to migrate to different platforms
 - Create necessary deployment artifacts to accelerate your migration into IBM Cloud and IBM Cloud Private

IBM Cloud Transformation Advisor can scan and analyze the following on-premises workloads. The list is frequently growing, so check back often for what's new!

**Java EE application servers**
- WebSphere Application Server v7+ (application-only scanning v6.1+)
- Oracle (&trade;) WebLogic v6.x+
- Redhat (&trade;) JBoss v4.x+
- Apache Tomcat v6.x+
- Java applications directly 

**Messaging**
- IBM MQ v7+

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

In case NFS PV is used one needs to make sure the path exists on a disk where the data is stored and that it has enough permissions. The path is configurable on install time and defaults to "/opt/couchdb/data". This is to avoid "permission for changing ownership" error:
```bash
mkdir -p /opt/couchdb/data
```
```bash
chmod -R 777 /opt/couchdb/data
```
In case a group is set up:
```bash
chmod -R 770 /opt/couchdb/data
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

Note: `couchdb.persistence.volumeMountPath` is set to `/opt/couchdb/data` by default. One needs to make sure TA user can write to this folder or change the path to the folder. Path can be modified via this field `Path to mount the volume` on TA install screen.

## Resources Required

### Minimum Configuration

| Subsystem  | CPU Minimum | Memory Minimum (GB) | Disk Space Minimum (GB) |
| ---------- | ----------- | ------------------- | ----------------------- |
| CouchDB    | 1           | 2                   | 8                       |
| Server     | 1           | 2                   |                         |
| UI         | 1           | 2                   |                         |

## Install into a non-default namespace

1. After installation, TA with Ingress will not be enabled automatically unless you have registered OIDC client with the same OIDC client id, OIDC client secret, and TA release name.

2. To enabled TA, you need an Admin to run the script at the bottom of your helm release page. Here is how to go to helm release page: 
Click the hamburger menu on the left upper corner in the ICP console > Workloads > Helm Releases > Click the TA release name you just created > Notes section is at the bottom of the page

## Prerequisites

* If ingress is enabled, access to "services" namespace is required to set up authentication. 
* If persistence is enabled but no dynamic provisioning is used, Persistent Volumes must be created.
    
### Secret

As of TA 1.8.0, you need to create a secret on ICP. Here are two examples:

#### Create Secret from Command Line

Here is an example command to create a secret:
```bash
kubectl -n ta create secret generic transformation-advisor-secret --from-literal=db_username='plain-text-username' --from-literal=secret='plain-text-password'
```

Note: 

1. Please avoid equal sign (i.e. =) in plain text values. Your _secret_ may not start with -hashed- in plain text value.
2. `-n ta` refers to the namespace where the secret is to be created. The secret needs to be created in the same namespace as the TA deployment. 

#### Create Secret from UI

In ICP admin console, go to left menu side bar > Configuration > Secrets > Create Secret.

In the Secret, 
1. In the "General" section - you need to enter a name, which will be asked in the TA helm installation page. e.g. you can create a name called `transformation-advisor-secret`
2. In the "General" section - select the namespace to the same one which your TA will be installed to. You may need to create a namespace of your choice first.
3. In the "Data" section - add two entries of data with names called `db_username` and `secret` respectively. The value of these values must be base64 encoded, and the raw values must have no space.
There are many ways to get base64 encoded. e.g. In bash

```bash
$ echo -n 'admin' | base64
# output: YWRtaW4=

echo -n "this-will-be-my-secret-without-space" | base64
# output: dGhpcy13aWxsLWJlLW15LXNlY3JldC13aXRob3V0LXNwYWNl
# Please you user own secret value
```

Note: You need base64 encoded values if you create the secret from ICP UI.

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. 

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
  
```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive, 
      requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
    cloudpak.ibm.com/version: "1.0.0"
  name: ibm-transadv-restricted-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: false
allowedCapabilities: []
allowedFlexVolumes: []
allowedUnsafeSysctls: []
defaultAddCapabilities: []
defaultPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
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

- Apply the SCC to all ServiceAccounts in the target namespace using the command:
```  
oc adm policy add-scc-to-group <scc-name> system:serviceaccounts:<namespace>
```

## Installing the Chart

To install the chart via helm with the release name `my-release`:

```bash
helm install --name my-release --set authentication.icp.edgeIp=<edgeIP> --set authentication.icp.secretName=<my-secret> stable/ibm-transadv-dev --tls
```

The command deploys `ibm-transadv-dev` on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Note**: Those parameters are required for install `authentication.icp.edgeIp`, `authentication.icp.secretName`

## Open Transformation Advisor UI
- From Transformation Advisor release
- Click "Launch" button
- Click "release-name"-ui  

(If "View In Menu" option is enabled on install)  
- From Menu navigate to Tools
- Click "Transformation"

## Backup and restore data

Please follow instruction in [here](https://transformationadvisor.github.io/doc/db_backup) to backup/restore your data.

## Configuration

The following tables lists the configurable parameters of the Transformation Advisor helm chart and their default values.

| Parameter                                           | Description                                                  | Default                                                 |
| --------------------------------------------------- | -------------------------------------------------------------| --------------------------------------------------------|
| arch.amd64                                          | Amd64 worker node scheduler preference in a hybrid cluster   | 3 - Most preferred                                      |
| ingress.enabled                                     | enable ingress to reach the service                          | true                                                    |
| authentication.icp.edgeIp                           | edge node IP                                                 | ""                                                      | 
| authentication.icp.endpointPort                     | edge node login port                                         | 8443 _(1)_                                                    |
| authentication.icp.secretName                       | The name of the secret in the Configuration in the same namespace of this release to be installed to| ""               |
| authentication.oidc.endpointPort                    | OIDC authentication endpoint port                            | 9443                                                    |
| authentication.oidc.clientId.clientId               | a OIDC registry will be created with this id                 | ca5282946fac07867fbc937548cb35d3ebbace7e                |
| authentication.oidc.clientSecret                    | a OIDC registry will be created with this secret             | 94b6cbce793d0606c0df9e8d656a159f0c06631b                |
| security.serviceAccountName                         | name of the service account to use                           | default                                                 |
| couchdb.image.repository                            | couchdb image repository                                     | ibmcom/transformation-advisor-db                        |
| couchdb.image.tag                                   | couchdb image tag                                            | 1.9.8                                                   |
| couchdb.image.pullPolicy                            | couchdb image pull policy                                    | IfNotPresent                                            |
| couchdb.resources.requests.memory                   | requests memory                                              | 2Gi                                                     |
| couchdb.resources.requests.cpu                      | requests cpu                                                 | 1000m                                                   |
| couchdb.resources.limits.memory                     | limits memory                                                | 8Gi                                                     |
| couchdb.resources.limits.cpu                        | limits cpu                                                   | 16000m                                                  |
| couchdb.persistence.enabled                         | persistence enabled                                          | true                                                    |
| couchdb.persistence.volumeMountPath                 | volume mount path                                            | /opt/couchdb/data                                       |
| couchdb.persistence.accessMode                      | couchdb access mode                                          | ReadWriteMany                                           |
| couchdb.persistence.size                            | couchdb storage size                                         | 8Gi                                                     |
| couchdb.persistence.useDynamicProvisioning          | use dynamic provisioning                                     | true                                                    |
| couchdb.persistence.existingClaim                   | existing pv claim                                            | ""                                                      |
| couchdb.persistence.storageClassName                | couchdb storage class name                                   | ""                                                      |
| transadv.image.repository                           | transadv server image                                        | ibmcom/transformation-advisor-server                    |
| transadv.image.tag                                  | transadv server image tag                                    | 1.9.8                                                   |
| transadv.image.pullPolicy                           | image pull policy                                            | IfNotPresent                                            |
| transadv.resources.requests.memory                  | requests memory                                              | 2Gi                                                     |
| transadv.resources.requests.cpu                     | requests cpu                                                 | 1000m                                                   |
| transadv.resources.limits.memory                    | limits memory                                                | 4Gi                                                     |
| transadv.resources.limits.cpu                       | limits cpu                                                   | 16000m                                                  |
| transadv.service.nodePort                           | transadv sevice node port                                    | 30111                                                   |
| transadvui.image.repository                         | transadv ui image                                            | ibmcom/transformation-advisor-ui                        |
| transadvui.image.tag                                | transadv ui image tag                                        | 1.9.8                                                   |
| transadvui.image.pullPolicy                         | image pull policy                                            | IfNotPresent                                            |
| transadvui.resources.requests.memory                | requests memory                                              | 2Gi                                                     |
| transadvui.resources.requests.cpu                   | requests cpu                                                 | 1000m                                                   |
| transadvui.resources.limits.memory                  | limits memory                                                | 4Gi                                                     |
| transadvui.resources.limits.cpu                     | limits cpu                                                   | 16000m                                                  |
| transadvui.service.nodePort                         | transadv sevice node port                                    | 30222                                                   |
| transadvui.inmenu                                   | add to Tools menu                                            | true                                                    |

Notes:

_(1)_ The edge node login port can be varied when ICP is configured and installed. In ICP 3.1.2 or later, the port information can be found in the left navigation in ICP console UI, Configuration > ConfigMaps; 
then search for __ibmcloud-cluster-info__, the edge node login port value is from _cluster_router_https_port_ 

## Limitations

- This chart should only use the default image tags provided with the chart. Different image versions might not be compatible with different versions of this chart.

## FAQ

For more help, or if you are experiencing issues please refer to the FAQ [here](https://transformationadvisor.github.io/).

## Copyright

© Copyright IBM Corporation 2018. All Rights Reserved.
