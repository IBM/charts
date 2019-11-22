
# IBM Content Management Interoperability Services (CMIS) Chart

## Introduction

IBM Content Management Interoperability Services (CMIS) enables you to develop, test, evaluate and demonstrate database and warehousing applications in a production environment.

## Chart Details
This chart is consist of IBM Content Management Interoperability Services (CMIS) Container.  It is a persistent relational database intended to be deployed in IBM® Cloud Private environments

## Prerequisites
- IBM® Cloud Private 3.1.2
- IBM® Cloud Pak for Automation product chart from IBM® Cloud Private catalog.
- NFS Server
- IBM® Content Management Interoperability Services  requires preparation items to be completed before you deploy your application. The preparation is to configuring storage for the applications in IBM® Cloud Private.  Follow this [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_cm_cmisparams.html) for more details.
- IBM® Cloud Private Administrator role is required to deploy IBM® Cloud Pak for Automation.
- IBM Content Management Interoperability Services (CMIS) requires 2 persistent volumes before chart deployment:

| Persistent Volumes                    | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `cmis-icp-cfgstore-pv`                  | `Configuration files for Liberty` |
| `cmis-icp-logstore-pv`                  | `Content Management Interoperability Services Liberty logs` |

- Use the below resource to create necessary PersistentVolume or it can be created by using the IBM® Cloud Private console:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cmis-icp-cfgstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/cmis/configDropins/overrides
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cmis-icp-cfgstore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: cmis-icp-logstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/cmis/logs
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: cmis-icp-logstore-pv
  ```

- On the NFS server create the corresponding folders for the persistentvolumes..
  ``` 
      mkdir -p /home/cfgstore/cmis/configDropins/overrides
      mkdir -p /home/cfgstore/cmis/logs
  ```

- Modify the folder permissions.
  ```
    chown -Rf 50001:50000 /home/cfgstore/cmis
  ``` 
- IBM Content Management Services also requires 2 PersistentVolumeClaim(PVC) before chart deployment.

| Persistent Volumes                    | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `cmis-icp-cfgstore-pvc`                  | `Configuration files for Liberty` |
| `cmis-icp-logstore-pvc`                  | `Content Management Interoperability Services Liberty logs` |

  - Use the below resource to create necessary PersistentVolumeClaim or it can be created by using the IBM® Cloud Private console:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cmis-icp-cfgstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: cmis-icp-cfgstore-pv
  volumeName: cmis-icp-cfgstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: cmis-icp-logstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: cmis-icp-logstore-pv
  volumeName: cmis-icp-logstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi

```

## Installing the Chart
This chart is not available as a catalog item inside IBM® Private Cloud 3.1.2. To install this chart deploy IBM® Cloud Pak for Automation chart from IBM® Cloud Private 3.1.2 catalog.

## Verifying the Chart
Follow IBM® Cloud Pak for Automation chart's readme to verify IBM® Content Management Interoperability Services chart.

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
- Minimum resources required for each PersistentVolumeClaim is 1GB.
- Minimum resources required for IBM Content Management Interoperability Services pod.
```
  cpu: 500m
  memory: 512Mi
```

## Limitations
- This chart is not available as a catalog item inside IBM® Private Cloud 3.1.2. 
- Only IBM® Cloud Private 3.1.2 is supported.
- Dynamic Provisioning is not supported.
- Known issues can be found [here](https://www.ibm.com/support/knowledgecenter/SSNW2F_5.5.0/com.ibm.p8.containers.doc/containers_knownissues.htm)

## Documentation

- Follow this  [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_install_ecm_containers.html)
