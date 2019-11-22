
# IBM® Business Automation Navigator Chart

## Introduction

IBM® Business Automation Navigator  container is a Docker image that enables you to quickly deploy IBM® Business Automation Navigator without a traditional software installation. The IBM® Business Automation Navigator container image is based on the IBM® Business Automation Navigator v3.0.6 and Liberty v19.0.0.2 releases.

For more details about IBM® Business Automation Navigator, see the IBM® Knowledge Center [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.offerings/topics/con_ban.html)

## Chart Details

This chart is consist of IBM® Business Automation Navigator container. IBM® Business Automation Navigator provides a console to enable teams to view their documents, folders, and searches in ways that help them to complete their tasks.

## Prerequisites
- IBM® Cloud Private 3.1.2
- IBM® Cloud Pak for Automation product chart from IBM® Cloud Private catalog.
- NFS Server
- IBM® Business Automation Navigator requires several preparation items to be completed before you deploy your application. These preparation items include creating or designating LDAP users and groups, preparing databases for the application data and managed content, and configuring storage for the applications in IBM® Cloud Private.  Follow this [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_prepare_ban.html) for more details.

- IBM® Cloud Private Administrator role is required to deploy IBM® Cloud Pak for Automation.
- IBM® Business Automation Navigator requires 6 persistent volumes to be pre-created prior to installing the chart. 

| Persistent Volume                    | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `icn-icp-cfgstore-pv`                  | `Configuration files for Liberty` |
| `icn-icp-logstore-pv`                  | `Navigator and Liberty logs` |
| `icn-icp-pluginstore-pv`                  | `Custom plugins for Navigator` |
| `icn-icp-vw-cachestore-pv`                  | `Daeja VieweONE logs` |
| `icn-icp-vw-logstore-pv`                  | `Daeja VieweONE cache` |
| `icn-icp-asperastore-pv`                  | `Aspera upload (It's optional for user who wants to use Aspera)` |


- Use the below resource to create necessary PersistentVolume:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: icn-icp-cfgstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/icn/configDropin/overrides
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: icn-icp-cfgstore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: icn-icp-logstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/icn/logs
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: icn-icp-logstore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: icn-icp-pluginstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/icn/plugins
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cn-icp-pluginstore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: icn-icp-vw-cachestore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/icn/viewercache
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: icn-icp-vw-cachestore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: icn-icp-vw-logstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/icn/viewerlog
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: icn-icp-vw-logstore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: icn-icp-asperastore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/icn/aspera
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: icn-icp-asperastore-pv
---
```

- On the NFS server create the corresponding folders for the persistentvolumes..
```
  mkdir -p /home/cfgstore/icn/configDropins/overrides
  mkdir -p /home/cfgstore/icn/logs
  mkdir -p /home/cfgstore/icn/plugins
  mkdir -p /home/cfgstore/icn/viewerlog
  mkdir -p /home/cfgstore/icn/viewercache
  mkdir -p /home/cfgstore/icn/Aspera
```
- Modify the folder permissions.
```
  chown -Rf 50001:50000 /home/cfgstore/icn
```

The following persistent volume need to allocate:

| Persistent Volume Claim                     | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `icn-icp-cfgstore-pvc`                  | `Configuration files for Liberty` |
| `icn-icp-logstore-pvc`                  | `Navigator and Liberty logs` |
| `icn-icp-pluginstore-pvc`                  | `Custom plugins for Navigator` |
| `icn-icp-vw-cachestore-pvc`                  | `Daeja VieweONE logs` |
| `icn-icp-vw-logstore-pvc`                  | `Daeja VieweONE cache` |
| `icn-icp-asperastore-pvc`                  | `Aspera upload (It's optional for user who wants to use Aspera)` |

- Use the below resource to create necessary PersistentVolumeClaim or it can be created by using the IBM® Cloud Private console:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: icn-icp-cfgstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: icn-icp-cfgstore-pv
  volumeName: icn-icp-cfgstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: icn-icp-logstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: icn-icp-logstore-pv
  volumeName: icn-icp-logstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: icn-icp-pluginstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: icn-icp-pluginstore-pv
  volumeName: icn-icp-pluginstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: icn-icp-vw-logstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: icn-icp-vw-logstore-pv
  volumeName: icn-icp-vw-logstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: icn-icp-vw-cachestore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: icn-icp-vw-cachestore-pv
  volumeName: icn-icp-vw-cachestore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: icn-icp-asperastore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: icn-icp-asperastore-pv
  volumeName: icn-icp-asperastore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---

```

## Installing the Chart
To install this chart, deploy IBM Cloud Pak for Automation chart from IBM Cloud Private 3.1.2 catalog as installer and select IBM FileNet Content Process Engine.

## Verifying the Chart
Follow IBM® Cloud Pak for Automation chart's readme to verify IBM® Business Automation Navigator Chart.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

$ helm delete my-release --purge --tls

The command removes all the Kubernetes components associated with the chart and deletes the release.

If autoscaling is enabled for the deployment , manually remove  Horizontal Pod Autoscaler (HPA).

$ kubectl delete hpa my-release

## Configuration

The configuration parameters of this chart can be provided using IBM Business Automation Configurator. Follow this [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_prepare_ban.html) for more details.

## PodSecurityPolicy Requirements

* This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.
* The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.
* This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface.
* From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

- Custom PodSecurityPolicy definition:
```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: icp4a-ibacc-psp
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
  name: icp4a-ibacc-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - icp4a-ibacc-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

## Resources Required
- Minimum resources required for each PersistentVolumeClaim is 1GB.

- Minimum resources required for IBM® Business Automation Navigator pod.
```
  cpu: 500m
  memory: 512Mi
```
## Limitations
- This chart is not available as a catalog item inside IBM Private Cloud 3.1.2. 
- Only IBM Cloud Private 3.1.2 is supported.
- Dynamic Provisioning is not supported.
- Known issues can be found [here](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.overview/topics/con_limitations.html).

