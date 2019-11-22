
# IBM® Content Search Service (CSS) Chart

## Introduction

IBM® Content Search Service (CSS) enables you to develop, test, evaluate and demonstrate database and warehousing applications in a production environment.

## Chart Details

This chart is consist of IBM® Content Search Service (CSS) Container and is a persistent relational database intended to be deployed in IBM® Cloud Private environments.

## Prerequisites

- IBM® Cloud Private 3.1.2
- IBM® Cloud Pak for Automation product chart from IBM® Cloud Private catalog.
- NFS Server
- IBM® Content Search Services requires preparation items to be completed before you deploy your application. The preparation is to configure storage for the applications in IBM® Cloud Private.  Follow this [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_cm_cssparams.html) for more details.
- IBM® Cloud Private Administrator role is required to deploy IBM® Cloud Pak for Automation.
- IBM® Content Search Services requires 4 persistent volumes to be pre-created prior to installing the chart. 

The following persistent volumes needs to be created :

| Persistent Volume Claim                     | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `css-cfgstore-pv`                  | `Configuration files for CSS` |
| `css-logstore-pv`                  | `Data persistence for CSS log files` |
| `css-tempstore-pv`                 | `Data persistence for CSS temp files` |
| `css-indexstore-pv`                | `Data persistence for content index data` |
| `css-customstore-pv`               | `Configuration volume for custom configuration` |

- Use the below resource to create necessary PersistentVolume or it can be created by using the IBM® Cloud Private console:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: css-cfgstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/css/CSS_Server_data
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: css-cfgstore-pv

apiVersion: v1
kind: PersistentVolume
metadata:
  name: css-logstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/css/CSS_Server_log
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: css-logstore-pv

apiVersion: v1
kind: PersistentVolume
metadata:
  name: css-tempstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/css/CSS_Server_temp
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: css-tempstore-pv

apiVersion: v1
kind: PersistentVolume
metadata:
  name: css-indexstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/css/CSSIndex_OS1
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: css-indexstore-pv

apiVersion: v1
kind: PersistentVolume
metadata:
  name: css-customstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/css/config
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: css-customstore-pv

```

- On the NFS server create the corresponding folders for the persistentvolumes..
```
  mkdir -p /home/cfgstore/css/CSS_Server_data
  mkdir -p /home/cfgstore/css/CSS_Server_log
  mkdir -p /home/cfgstore/css/CSS_Server_temp
  mkdir -p /home/cfgstore/css/CSSIndex_OS1
  mkdir -p /home/cfgstore/css/CSS_Server_Config
```
- Modify the folder permissions.
```
  chown -Rf 50001:50000 /home/cfgstore/css
```

- IBM Content Search Services also requires 5  persistentvolumeclaims(PVC) before chart deployment. Please make sure the PVC name for custom configuration is css-customstore:

| Persistent Volume Claim                     | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `css-cfgstore-pvc`                  | `Configuration files for CSS` |
| `css-logstore-pvc`                  | `Data persistence for CSS log files` |
| `css-tempstore-pvc`                 | `Data persistence for CSS temp files` |
| `css-indexstore-pvc`                | `Data persistence for content index data` |
| `css-customstore`                   | `Configuration volume for customer configuration` |


- Use the below resource to create necessary PersistentVolumeClaim or it can be created by using the IBM® Cloud Private console:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: css-cfgstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: css-cfgstore-pv
  volumeName: css-cfgstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: css-logstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: css-logstore-pv
  volumeName: css-logstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: css-tempstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: css-tempstore-pv
  volumeName: css-tempstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: css-indexstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: css-indexstore-pv
  volumeName: css-indexstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: css-customstore
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: css-customstore-pv
  volumeName: css-customstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
```

## Installing the Chart

To install this chart, deploy IBM Cloud Pak for Automation chart from IBM Cloud Private 3.1.2 catalog as installer and select IBM Content Search Services.

## Verifying the Chart

Follow IBM® Cloud Pak for Automation chart's readme to verify IBM® Content Search Services chart.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

$ helm delete my-release --purge --tls

The command removes all the Kubernetes components associated with the chart and deletes the release.  

- If autoscaling is enabled for the deployment , manually remove  Horizontal Pod Autoscaler (HPA).
$ kubectl delete hpa my-release

## Configuration

The configuration parameters  of this chart can be provided using IBM® Business Automation Configurator. Follow this [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_prepare_ecm.html) for more details.

## PodSecurityPolicy Requirements
* This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur. 
* The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.
* This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. 
* From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

- Custom PodSecurityPolicy definition:
```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibacc-psp
spec:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  allowedCapabilities:
  - CHOWN
  - DAC_OVERRIDE
  - SETGID
  - SETUID
  - NET_BIND_SERVICE
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes:
  - configMap
  - secret
```
- Custom ClusterRole for the custom PodSecurityPolicy:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibacc-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibacc--psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```
## Resources Required

- Minimum resources required for each PersistentVolumeClaim is 1GB.
- Minimum resources required for IBM® Content Search Service pod.
```
  cpu: 500m
  memory: 512Mi
```
## Limitations
- This chart is not available as a catalog item inside IBM® Private Cloud 3.1.2.
- Only IBM® Cloud Private 3.1.2 is supported.
- Only 1 replica is support for one helm release. If multiple replicas needed , you can create a new helm release with a different release name.
- Dynamic Provisioning is not supported.
- Known issues can be found [here](https://www.ibm.com/support/knowledgecenter/SSNW2F_5.5.0/com.ibm.p8.containers.doc/containers_knownissues.htm)

## Documentation

- Follow this  [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_install_ecm_containers.html)
