
# IBM FileNet Content Services GraphQL API Chart

## Introduction

IBM FileNet Content Services GraphQL API enables you to develop, test, evaluate and demonstrate database and warehousing applications in a non-production environment.

## Chart Details

IBM FileNet Content Services GraphQL chart provides an intuitive API that enables the caller to create, retrieve, update, or delete resources. The API is ideal for web and mobile application development because it supports retrieving exactly the data you need with a single call.

## Prerequisites
- IBM Cloud Private 3.1.2
- NFS Server
- IBM FileNet Content Engine 5.5.3 iFix1
- IBM FileNet Content Services GraphQL API requires several preparation items to be completed before you deploy your application. These preparation items include creating or designating LDAP users and groups and configuring storage for the applications in IBM® Cloud Private.  Follow this [link](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_prepare_ecm.html) for more details.   
- IBM® Cloud Private Cluster Administrator role is required to deploy IBM® Cloud Pak for Automation.
- IBM FileNet Content Services GraphQL API requires 2 persistent volumes before chart deployment.  This is your configuration storage in IBM® Cloud Private:

| Persistent Volumes                    | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `crs-cfgstore-pv`                  | `Configuration files for Liberty` |
| `crs-logstore-pv`                  | `Content GraphQL Service & Liberty logs` |


- Use the below resource to create necessary PersistentVolume or it can be created by using the IBM Cloud Private console:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: crs-cfgstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/crs/configDropins/overrides
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: crs-cfgstore-pv
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: crs-logstore-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
  nfs:
    path: /home/cfgstore/crs/logs
    server: <NFS Server>
  persistentVolumeReclaimPolicy: Retain
  storageClassName: crs-logstore-pv
---
```

- Create the corresponding folders for the PersistentVolumes on the NFS server:
```
  mkdir -p /home/cfgstore/crs/configDropins/overrides
  mkdir -p /home/cfgstore/crs/logs
```
- Modify the folder permissions.
```
 - For all persistent volumes (PVs), make sure the ownership on the PV are set to the root group, and permissions to root group have read/write/execution.
  For example:
  rwxrwxr-x   2 50001 root     [PV volume]
  chown -Rf 50001:root /home/cfgstore/crs

 - If the ownership and the permissions are not properly set, change the ownerships and permissions using the following commands:
   chgrp -R 0 [PV volume]
   chmod -R g=u  [PV volume]
```


- IBM FileNet Content Services GraphQL API also requires 2 PersistentVolumeClaim(PVC) before chart deployment. 

| Persistent Volume Claim                     | Description                                        |
| ---------------------------   | ---------------------------------------------      |
| `crs-cfgstore-pvc`                  | `Configuration files for Liberty` |
| `crs-logstore-pvc`                  | `Content GraphQL Service & Liberty logs` |

- Create the following PersistentVolumes via the command line or in the IBM Cloud Private console:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: crs-cfgstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: crs-cfgstore-pv
  volumeName: crs-cfgstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: crs-logstore-pvc
  namespace: <NAMESPACE>
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: crs-logstore-pv
  volumeName: crs-logstore-pv
status:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 1Gi
---
```

## Installing the Chart
This chart is not available from the IBM Cloud Private catalog UI and must be installed from the CLI. Use the following helm command to install the chart:
```
helm install local-charts/ibm-dba-contentrestservice-dev --name dbamc-crs --namespace dbamc --set crsProductionSetting.license=accept,crsProductionSetting.jvmHeapXms=512,crsProductionSetting.jvmHeapXmx=1024,dataVolume.existingPVCforCfgstore=crs-cfgstore,dataVolume.existingPVCforCfglogs=crs-logs,autoscaling.enabled=False,replicaCount=1,image.repository=mycluster:8500/dbamc/crs,image.tag=5.5.3 --tls

```

## Verifying the Chart

To verify IBM® FileNet Content Services GraphQL API, you will need the proxy address and the node port,then access the IBM® FileNet Content Services GraphQL API by running the following commands:
```
 Get the IBM® FileNet Content Services GraphQL API proxy IP.
 kubectl get nodes -l proxy=true -o jsonpath='{.items[0].status.addresses[0].address}' to obtain the proxy ip.
 kubectl get svc -n <NAMESPACE> to see a list of the services for later use.

 Get the IBM® FileNet Content Services GraphQL API service port.
 kubectl get -o jsonpath='{.spec.ports[1].nodePort}' services <CRS_SERVICENAME>  -n <NAMESPACE>

 https://<PROXY_IP><CRS_NODE_PORT>/contentapi/rest/share/v1/info
```


## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:
```
$ helm delete my-release --purge --tls
```
The command removes all the Kubernetes components associated with the chart and deletes the release.  

If autoscaling is enabled for the deployment, manually remove the Horizontal Pod Autoscaler (HPA).
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
## Red Hat OpenShift SecurityContextConstraints Requirements

* This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.
* The predefined SecurityContextConstraints name: [`restricted`] (https://ibm.biz/cpkspec-scc)  has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.
* This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.
* From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints

- Custom SecurityContextConstraints definition:
```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: icp4a-ocp-dev-scc
readOnlyRootFilesystem: false
allowedCapabilities:
- CHOWN
- DAC_OVERRIDE
- SETGID
- SETUID
- NET_BIND_SERVICE
seLinux:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
runAsUser:
  type: RunAsAny
fsGroup:
  rule: RunAsAny
volumes:
- configMap
- secret
```

## Resources Required
- Minium storage space required for each PersistanceVolumeClaim is 1GB.
- Minimum resources required for IBM FileNet Content Services GraphQL API pod.
```
  requests:
  cpu: 500m
  memory: 512Mi
```
## Limitations

- Only IBM Cloud Private 3.1.2 is supported.
- Dynamic Provisioning is not supported.
- Known issues can be found [here](https://www.ibm.com/support/knowledgecenter/SSNW2F_5.5.0/com.ibm.p8.containers.doc/containers_knownissues.htm)

## Documentation

- Follow this [link]( https://www.ibm.com/support/pages/technology-preview-using-filenet-content-manager-content-services-graphql-api )
