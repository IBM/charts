
# IBM Content Platform Engine Chart

## Introduction

IBM Content Platform Engine offers enterprise-level scalability and flexibility to handle the most demanding content challenges, the most complex business processes, and integration to all your existing systems. FileNet P8 is a reliable, scalable, and highly available enterprise platform that enables you to capture, store, manage, secure, and process information to increase operational efficiency and lower total cost of ownership. FileNet P8 enables you to streamline and automate business processes, access and manage all forms of content, and automate records management to help meet compliance needs.

## Chart Details

IBM Content Platform Engine (CPE) enables you to develop, test, evaluate and demonstrate database and warehousing applications in a production environment.

## Prerequisites
- IBM Cloud Private 3.1.2
- IBM Cloud Pak for Automation product chart from IBM Cloud Private catalog.
- NFS Server
- IBM Content Platform Engine requires several preparation items to be completed before you deploy your application. These preparation items include creating or designating LDAP users and groups, preparing databases for the application data and managed content, and configuring storage for the applications in IBM® Cloud Private.  Follow this [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_prepare_ecm.html) for more details.   
- IBM® Cloud Private Administrator role is required to deploy IBM® Cloud Pak for Automation.
- IBM Content Platform Engine requires 7 persistent volumes before chart deployment.  This is your configuration storage in IBM® Cloud Private:

| Persistent Volumes                    | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `cpe-icp-cfgstore-pv`                  | `Configuration files for Liberty` |
| `cpe-icp-logstore-pv`                  | `Content Platform Engine & Liberty logs` |
| `cpe-icp-filestore-pv`                  | `Content storage volume for advanced storage area` |
| `cpe-icp-icmrulesstore-pv`                  | `Rules for ICM` |
| `cpe-icp-textextstore-pv`                  | `Text extraction volume used by CSS` |
| `cpe-icp-bootstrapstore-pv`                  | `Content Platform Engine bootstrap file location` |
| `cpe-icp-fnlogstore-pv`                  | `Text extraction volume used by CSS` |


- Use the below resource to create necessary PersistentVolume or it can be created by using the IBM Cloud Private console:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cpe-icp-cfgstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/cpe/configDropins/overrides
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cpe-icp-cfgstore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cpe-icp-logstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/cpe/logs
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cpe-icp-logstore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cpe-icp-filestore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/cpe/asa
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cpe-icp-filestore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cpe-icp-textext-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/cpe/textext
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cpe-icp-textext-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cpe-icp-fnlogs-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/cpe/FileNet
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cpe-icp-fnlogs-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cpe-icp-icmrules-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/cpe/icmrules
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cpe-icp-icmrules-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cpe-icp-bootstrap-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/cpe/bootstrap
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cpe-icp-bootstrap-pv
```

- On the NFS server create the corresponding folders for the persistentvolumes..
```
  mkdir -p /home/cfgstore/cpe/configDropins/overrides
  mkdir -p /home/cfgstore/cpe/logs
  mkdir -p /home/cfgstore/cpe/asa
  mkdir -p /home/cfgstore/cpe/FileNet
  mkdir -p /home/cfgstore/cpe/icmrules
  mkdir -p /home/cfgstore/cpe/bootstrap
  mkdir -p /home/cfgstore/cpe/textext
```
- Modify the folder permissions.
```
  chown -Rf 50001:50000 /home/cfgstore/cpe
```


- IBM Content Platform Engine also requires 7 PersistentVolumeClaim(PVC) before chart deployment. 

| Persistent Volume Claim                     | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `cpe-icp-cfgstore-pvc`                  | `Configuration files for Liberty` |
| `cpe-icp-logstore-pvc`                  | `Content Platform Engine & Liberty logs` |
| `cpe-icp-filestore-pvc`                  | `Content storage volume for advanced storage area` |
| `cpe-icp-icmrulesstore-pvc`                  | `Rules for ICM` |
| `cpe-icp-textextstore-pvc`                  | `Text extraction volume used by CSS` |
| `cpe-icp-bootstrapstore-pvc`                  | `Content Platform Engine bootstrap file location` |
| `cpe-icp-fnlogstore-pvc`                  | `Text extraction volume used by CSS` |

- Use the below resource to create necessary PersistentVolumeClaim or it can be created by using the IBM Cloud Private console:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cpe-icp-cfgstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: cpe-icp-cfgstore-pv
  volumeName: cpe-icp-cfgstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cpe-icp-logstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: cpe-icp-logstore-pv
  volumeName: cpe-icp-logstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cpe-icp-filestore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: cpe-icp-filestore-pv
  volumeName: cpe-icp-filestore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cpe-icp-textext-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: cpe-icp-textext-pv
  volumeName: cpe-icp-textext-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cpe-icp-fnlogs-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: cpe-icp-fnlogs-pv
  volumeName: cpe-icp-fnlogs-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cpe-icp-icmrules-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: cpe-icp-icmrules-pv
  volumeName: cpe-icp-icmrules-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cpe-icp-bootstrap-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: cpe-icp-bootstrap-pv
  volumeName: cpe-icp-bootstrap-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
```


## Installing the Chart
This chart is not available as a catalog item inside IBM® Private Cloud 3.1.2. To install this chart deploy IBM® Cloud Pak for Automation chart from IBM® Cloud Private 3.1.2 catalog

## Verifying the Chart
Follow IBM® Cloud Pak for Automation chart's readme to verify IBM Content Platform Engine chart.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

$ helm delete my-release --purge --tls

The command removes all the Kubernetes components associated with the chart and deletes the release.  

If autoscaling is enabled for the deployment , manually remove  Horizontal Pod Autoscaler (HPA).
$ kubectl delete hpa my-release 

## Configuration

The configuration parameters  of this chart can be provided using IBM Business Automation Configurator. Follow this [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_prepare_ecm.html) for more details.

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
  name: icp4a-ibacc--psp
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
- Minium storage space required for each PersistanceVolumeClaim is 1GB.
- Minimum resources required for IBM Content Platform Engine pod.
```
  requests:
  cpu: 500m
  memory: 512Mi
```
## Limitations

- Only IBM Cloud Private 3.1.2 is supported.
- Dynamic Provisioning is not supported.
- Known issues for content services. See here [link](https://www.ibm.com/support/knowledgecenter/SSNW2F_5.5.0/com.ibm.p8.containers.doc/containers_knownissues.htm)

## Documentation

- Follow this [link]( https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_cm_cpeparams.html )
