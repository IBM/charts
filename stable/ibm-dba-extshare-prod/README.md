
# IBM® FileNet External Share Chart

## Introduction

IBM® FileNet External Share container is a Docker image that enables you securely share external content with IBM FileNet Content Platform Engine using IBM® Business Automation Navigator. The IBM® FileNet External Share image is based on the IBM® Business Automation Navigator v3.0.6 and Liberty v19.0.0.2 releases.

For more details about IBM® FileNet External Share, see the [IBM® Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSEUEX_3.0.5/com.ibm.installingeuc.doc/eucco163.htm)

## Chart Details
This chart is consist of IBM® FileNet External Share for container and is a persistent relational database intended to be deployed in IBM® Cloud Private environments.

## Prerequisites
- IBM® Cloud Private 3.1.2
- NFS Server
- IBM® Content Platform Engine container deployed and running.
- IBM® Business Automation Navigator container deployed and running.
- IBM® FileNet External Share for container requires several preparation items to be completed before you deploy your application. These preparation items include creating or designating LDAP users and groups, preparing databases for the application data and managed content, and configuring storage for the applications in IBM® Cloud Private.  Follow this [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_prepare_ban.html) for more details
- IBM® Cloud Private Administrator role is required to deploy IBM® Cloud Pak for Automation.
- IBM® FileNet External Share for container requires 2 persistent volumes to be pre-created prior to installing the chart. 


| Persistent Volume                    | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `es-icp-cfgstore-pv`                  | `Configuration files for Liberty` |
| `es-icp-logstore-pv`                  | `External Share and Liberty logs` |


- Use the below resource to create necessary PersistentVolume:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: es-icp-cfgstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/icn/configDropin/overrides
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: es-icp-cfgstore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: es-icp-logstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/es/logs
    server: <NFS_SERVER>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: es-icp-logstore-pv
---
```

- On the NFS server create the corresponding folders for the persistentvolumes..
```
  mkdir -p /home/cfgstore/es/configDropins/overrides
  mkdir -p /home/cfgstore/es/logs
  
```
- Modify the folder permissions.
```
  chown -Rf 50001:50000 /home/cfgstore/es
```

The following persistent volume need to allocate:

| Persistent Volume Claim                     | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `es-icp-cfgstore-pvc`                  | `Configuration files for Liberty` |
| `es-icp-logstore-pvc`                  | `External Share and Liberty logs` |

- Use the below resource to create necessary PersistentVolumeClaim or it can be created by using the IBM® Cloud Private console:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: es-icp-cfgstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: es-icp-cfgstore-pv
  volumeName: es-icp-cfgstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: es-icp-logstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: es-icp-logstore-pv
  volumeName: es-icp-logstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
```

## Installing the Chart
This chart is hidden inside IBM Private Cloud 3.1.2 catalog. Use below helm command to install the chart.
```
 helm install local-charts/ibm-dba-extshare-prod --version 3.0.0 --name dbamc-es --namespace dbamc --set esProductionSetting.license=accept,esProductionSetting.jvmHeapXms=512,esProductionSetting.jvmHeapXmx=1024,dataVolume.existingPVCforESCfgstore=ecm-es-config-pvc,dataVolume.existingPVCforESLogstore=ecm-es-logs-pvc,autoscaling.enabled=False,replicaCount=1,image.repository=mycluster.icp:8500/dbamc/extshare,image.tag=ga-306-es,esProductionSetting.esDBType=db2,esProductionSetting.esJNDIDSName=ECMClientDS,esProductionSetting.esSChema=ICNDB,esProductionSetting.esTableSpace=UBI_ICN,esProductionSetting.esAdmin=ceadmin --tls

```

## Verifying the Chart

To verify IBM® FileNet External Share container you will need the proxy address and the node port,then access the IBM® FileNet External Share  container url by running the following commands:
```
 kubectl get nodes -l proxy=true -o jsonpath='{.items[0].status.addresses[0].address}' to obtain the proxy ip.
 kubectl get svc -n <NAMESPACE> to see a list of the services for later use.
 kubectl get -o jsonpath='{.spec.ports[1].nodePort}' services <ExternalShare_SERVICENAME>  -n <NAMESPACE>
 https://<PROXY_IP><ES_NODE_PORT>/contentapi/rest/share/v1/info
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

$ helm delete my-release --purge --tls

The command removes all the Kubernetes components associated with the chart and deletes the release.

If autoscaling is enabled for the deployment , manually remove  Horizontal Pod Autoscaler (HPA).

$ kubectl delete hpa my-release

## Configuration

The configuration parameters of this chart provided in knowledge center. Follow this [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_prepare_ban.html) for more details.

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

- Minimum resources required for IBM® FileNet External Share.
```
  cpu: 500m
  memory: 512Mi
```
## Limitations
- This chart is not available as a catalog item inside IBM Private Cloud 3.1.2. 
- Only IBM Cloud Private 3.1.2 is supported.
- Dynamic Provisioning is not supported.
- Known issues can be found [here](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.overview/topics/con_limitations.html).

