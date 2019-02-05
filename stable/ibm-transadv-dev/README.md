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
- Oracle tm WebLogic v6.x+
- Redhat tm JBoss v4.x+
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

## Resources Required

### Minimum Configuration

| Subsystem  | CPU Minimum | Memory Minimum (GB) | Disk Space Minimum (GB) |
| ---------- | ----------- | ------------------- | ----------------------- |
| CouchDB    | 1           | 2                   | 8                       |
| Server     | 1           | 2                   |                         |
| UI         | 1           | 2                   |                         |

## Install into a non-default namespace

1. You need to follow the **PodSecurityPolicy Requirements** section below to create a namespace, service account, pod security policy, a role that has the policy and bind the
role to the service account.

2. After installation, TA with Ingress will not be enabled automatically unless you have registered OIDC client with the same OIDC client id, OIDC client secret, and TA release name.

3. To enabled TA, you need an Admin to run the script at the bottom of your helm release page. Here is how to go to helm release page: 
Click the hamburger menu on the left upper corner in the ICP console > Workloads > Helm Releases > Click the TA release name you just created > Notes section is at the bottom of the page

## PodSecurityPolicy Requirements 

NOTE: ICP 3.1.1+ provides a pre-defined set of PodSecurityPolicies:
* ibm-restricted-psp (default PSP, most-restrictive)
* ibm-anyuid-psp
* ibm-anyuid-hostpath-psp
* ibm-anyuid-hostaccess-psp
* ibm-privileged-psp (least-restrictive)   

Select any of those along with the preselected ibm-restricted-psp while creating the namespace for Transformation Advisor. Installation will use default settings. No additional steps are needed.  

In case of a custom PSP being required:  

* If you have [pod security policy control](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#enabling-pod-security-policies) enabled, you must have a [PodSecurityPolicy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) that supports the following [securityContext](https://kubernetes.io/docs/concepts/policy/security-context/) settings:
  * capabilities:
    * CHOWN
    * DAC_OVERRIDE
    * FOWNER
    * FSETID
    * KILL
    * SETGID
    * SETUID
    * SETPCAP
    * NET_BIND_SERVICE
    * NET_RAW
    * SYS_CHROOT
    * AUDIT_WRITE
    * SETFCAP
  * allowPrivilegeEscalation: true
  * readOnlyRootFilesystem: false
  * runAsNonRoot: false
  * runAsUser: 0
  * privileged: false
> We are targeting to reduce the list above in future releases of this helm chart.  

> **Note**: If you are deploying to an IBM Cloud Private environment that does not support these security settings by default. Follow these [instructions](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/app_center/nd_helm.html) to enable your deployment.

Here is an example setup for a non-default namespace installation:
```bash
kubectl create namespace ta

kubectl create serviceaccount -n ta ta-sa

kubectl -n ta create -f- <<EOF
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ta-psp
spec:
  allowPrivilegeEscalation: true
  readOnlyRootFilesystem: false
  allowedCapabilities:
  - CHOWN
  - DAC_OVERRIDE
  - FOWNER
  - FSETID
  - KILL
  - SETGID
  - SETUID
  - SETPCAP
  - NET_BIND_SERVICE
  - NET_RAW
  - SYS_CHROOT
  - AUDIT_WRITE
  - SETFCAP
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes:
  - '*'
EOF

kubectl -n ta create role psp:unprivileged \
    --verb=use \
    --resource=podsecuritypolicy \
    --resource-name=ta-psp

kubectl -n ta create rolebinding ta-sa:psp:unprivileged \
    --role=psp:unprivileged \
    --serviceaccount=ta:ta-sa
```    

## Prerequisites

* If ingress is enabled, access to "services" namespace is required to set up authentication. 
* If persistence is enabled but no dynamic provisioning is used, Persistent Volumes must be created.
    
### Secret

As of TA 1.8.0, you need to create a secret on ICP. e.g. on ICP version 2.1.0.2, go to left menu side bar > Configuration > Secrets > Create Secret.

In the Secret, 
1. You need to enter a name, which will be asked in the TA helm installation page. e.g. you can create a name called `transformation-advisor-secret`
2. Select the namespace to the same one which your TA will be installed to. You may need to create a namespace of your choice first.
3. Add two entries of data with names called `db_username` and `secret` respectively. The value of these values must be base64 encoded, and the raw values must have no space.
There are many ways to get base64 encoded. e.g. In bash

```bash
$ echo -n 'admin' | base64
# output: YWRtaW4=

echo -n "this-will-be-my-secret-without-space" | base64
# output: dGhpcy13aWxsLWJlLW15LXNlY3JldC13aXRob3V0LXNwYWNl
# Please you user own secret value
```

Here is an example command to create a secret:
```bash
kubectl -n ta create secret generic transformation-advisor-secret --from-literal=db_username='admin' --from-literal=secret='password'
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

## Configuration

The following tables lists the configurable parameters of the Transformation Advisor helm chart and their default values.

| Parameter                                           | Description                                                  | Default                                                 |
| --------------------------------------------------- | -------------------------------------------------------------| --------------------------------------------------------|
| arch.amd64                                          | Amd64 worker node scheduler preference in a hybrid cluster   | 3 - Most preferred                                      |
| arch.ppc64le                                        | Ppc64le worker node scheduler preference in a hybrid cluster | 2 - No preference                                       |
| arch.s390x                                          | S390x worker node scheduler preference in a hybrid cluster   | 2 - No preference                                       |
| ingress.enabled                                     | enable ingress to reach the service                          | true                                                    |
| authentication.icp.edgeIp                           | edge node IP                                                 | ""                                                      | 
| authentication.icp.endpointPort                     | edge node login port                                         | 8443                                                    |
| authentication.icp.secretName                       | The name of the secret in the Configuration in the same namespace of this release to be installed to| ""               |
| authentication.oidc.endpointPort                    | OIDC authentication endpoint port                            | 9443                                                    |
| authentication.oidc.clientId.clientId               | a OIDC registry will be created with this id                 | ca5282946fac07867fbc937548cb35d3ebbace7e                |
| authentication.oidc.clientSecret                    | a OIDC registry will be created with this secret             | 94b6cbce793d0606c0df9e8d656a159f0c06631b                |
| security.serviceAccountName                         | name of the service account to use                           | default                                                 |
| couchdb.image.repository                            | couchdb image repository                                     | ibmcom/transformation-advisor-db                        |
| couchdb.image.tag                                   | couchdb image tag                                            | 1.9.2                                                   |
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
| transadv.image.tag                                  | transadv server image tag                                    | 1.9.2                                                   |
| transadv.image.pullPolicy                           | image pull policy                                            | IfNotPresent                                            |
| transadv.resources.requests.memory                  | requests memory                                              | 2Gi                                                     |
| transadv.resources.requests.cpu                     | requests cpu                                                 | 1000m                                                   |
| transadv.resources.limits.memory                    | limits memory                                                | 4Gi                                                     |
| transadv.resources.limits.cpu                       | limits cpu                                                   | 16000m                                                  |
| transadv.service.nodePort                           | transadv sevice node port                                    | 30111                                                   |
| transadvui.image.repository                         | transadv ui image                                            | ibmcom/transformation-advisor-ui                        |
| transadvui.image.tag                                | transadv ui image tag                                        | 1.9.2                                                   |
| transadvui.image.pullPolicy                         | image pull policy                                            | IfNotPresent                                            |
| transadvui.resources.requests.memory                | requests memory                                              | 2Gi                                                     |
| transadvui.resources.requests.cpu                   | requests cpu                                                 | 1000m                                                   |
| transadvui.resources.limits.memory                  | limits memory                                                | 4Gi                                                     |
| transadvui.resources.limits.cpu                     | limits cpu                                                   | 16000m                                                  |
| transadvui.service.nodePort                         | transadv sevice node port                                    | 30222                                                   |
| transadvui.inmenu                                   | add to Tools menu                                            | true                                                    |

## Limitations

- Prior to TA 1.8, Transformation Advisor must be deployed in to the ```default``` namespace.

- This chart should only use the default image tags provided with the chart. Different image versions might not be compatible with different versions of this chart.

## FAQ

For more help, or if you are experiencing issues please refer to the FAQ [here](https://transformationadvisor.github.io/).

## Copyright

© Copyright IBM Corporation 2018. All Rights Reserved.
