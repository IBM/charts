# IBM Cloud Cost and Asset Management

## Introduction
IBM Cloud Cost and Asset Management gives hybrid cloud users visibility and actionable insight into their cloud investments.  It provides streamlined dashboards with views on key metrics such as costs, cost trends, asset utilization, asset locations and asset types that are driving spend.

Users can now see public cloud costs as well as VMWare based private cloud costs and assets in dashboards. They can also find recommendations for cost control for select public clouds.

## Chart Details

This chart deploys IBM Cloud Cost and Asset Management as a number of deployments and services.

## Prerequisites

1. Install the [IBM Cloud Management Platform chart(ibm-cloud-mgmt-platform-prod)](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/install_core.html) chart
2. The persistent volumes for the Cost and Asset Management are required to be pre-created. For details see [here](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/cam_create_pv.html)
3. Create namespace and secrets required for the Cost and Asset Management

   Run the pre-install scripts to create the Namespace & Secrets
   Refer to [instruction](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/cam_prereq.html) to run the pre-install scripts.
4. Create the PSP as mentioned in PodSecurityPolicy Requirements below.
5. Operator access required to install chart

## Resources Required

* [list of hardware requirements](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/cam_hw_requirements.html)


## PodSecurityPolicy Requirements
On ICP :
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Have your cluster administrator create a custom PodSecurityPolicy for you. Additionally, the predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

- Custom PodSecurityPolicy definition:
```
---
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: cam-security
  labels:
spec:
  allowPrivilegeEscalation: false
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
  - MKNOD
  allowedCapabilities:
  - SETGID
  - SETFCAP
  - CHOWN
  - DAC_OVERRIDE
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
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
  forbiddenSysctls:
  - '*'
```

- Custom Role for the custom PodSecurityPolicy:
```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cam-security-role
  labels:
rules:
 -
   apiGroups:
     - extensions
   resourceNames:
     - cam-security
   resources:
     - podsecuritypolicies
   verbs:
     - use
```
- Custom RoleBinding for the custom PodSecurityPolicy:
```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cam-security-psp-users
  labels:
subjects:
 - kind: Group
   apiGroup: rbac.authorization.k8s.io
   name: "system:serviceaccounts:<<Namespace for ibm-cloud-cost-asset-mgmt-prod chart>>"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: cam-security-role
```

## Red Hat OpenShift SecurityContextConstraints Requirements
On ICP with OpenShift
Ask your Openshift Administrator to add a new SCC and add it to the service account in the project where ibm-cloud-mgmt-platform-prod is deployed. For reference [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc)

```
---
apiVersion: security.openshift.io/v1
metadata:
  annotations:
  name: cost-mgmt
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities:
- CHOWN
- SETFCAP
- SETGID
- DAC_OVERRIDE
defaultAddCapabilities: []
fsGroup:
  type: RunAsAny
groups:
- system:cluster-admins
kind: SecurityContextConstraints
priority: 12
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: null
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret

```

Run the command below to get the SCC created using the content above in cost-mgmt.yaml :
```
oc create -f cost-mgmt.yaml
```
Run the below command to add the scc added above to project where you are going to deploy chart:
```
oc adm policy add-scc-to-group cost-mgmt system:serviceaccounts:<<project name of ibm-cloud-cost-asset-mgmt-prod chart>>
```
## Installing the Chart

Add the IBM Cloud Private internal Helm repository called local-charts to the Helm CLI as an external repository, as described [here](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/app_center/add_int_helm_repo_to_cli.html).

To install the chart with the release name `cam` in the namespace `cam`:

```bash
$ helm install mycluster/ibm-cloud-cost-asset-mgmt-prod --tls --name cam --namespace cam --set serviceType="NodePort",k8StorageType="nfs",uiHost="<uihost>",apiGatewayUrl="<gatewayurl>",coreNamespace="<coreNamespace>",k8Namespace="<k8Namespace>"
```

For detailed instructions on installing Cost and Asset Management chart refer  [here](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/cam_install.html)

## Configuration

The following tables lists the configurable parameters of the `ibm-cloud-cost-asset-mgmt-prod` chart and their default values. For Installing with serviceType as Ingress refer [here](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/ingress_install.html)

| Parameter | Description| Default    |                                     
| --------- | ---------- | ---------- |
| `uiHost`| User Interface Host.|  |
| `uiPort`| User Interface Port.| `30080` |
| `serviceType`| Kubernetes Service Type.| `NodePort`  |
| `apiGatewayUrl`| URL for Gateway Host : https://<icp_proxy_ip>:30091 for serviceType NodePort.|  |
| `storageType`| Kubernetes Storage Type.||
| `enableBackups`| Select to enable Backup.  | `false`  |
| `persistence.enabled` | Select to enable persistence | `true` |
| `persistence.useDynamicProvisioning` | Select for dynamic provisioning | `true` |
|`coreNamespace`| Namespace where `ibm-cloud-mgmt-platform-prod` chart is deployed ||
|`k8Namespace`| Namespace where this chart is getting deployed ||
|`orchestratorCronTime`|Time Orchestrator Cron has to be scheduled||
|`recommendationCronTime`|Time Recommendation Cron has to be scheduled||
|`mysqlReplication`|Select to enable MariaDB Replication||
|`mysqlNodeport`|MariaDB NodePort||
|`k8StorageAccessMode.nfs`|Kubernetes Storage Access Modes for NFS|`ReadWriteMany`|
|`k8StorageAccessMode.glusterfsStorage`|Kubernetes Storage Access Modes for GlusterFS |`ReadWriteMany`|
|`camDataPv0.glusterfsStorage.storageClass`|Storage Class to be used with GlusterFS ||
|`camRabbitmqPv0.glusterfsStorage.storageClass`|Storage Class to be used with GlusterFS ||
|`mariadbDataPv0.glusterfsStorage.storageClass`|Storage Class to be used with GlusterFS ||
|`mariadbBackupPv0.glusterfsStorage.storageClass`|Storage Class to be used with GlusterFS ||
|`mariadbTmpPv0.glusterfsStorage.storageClass`|Storage Class to be used with GlusterFS ||


For the full list of configuration options supported by this chart see [here](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/cam_installation_parameters.html)

## Limitations

This Chart is tested only with amd64 architecture.

## Documentation

[IBM Cloud Cost and Asset Management Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSMPHF/welcome_cost_asset_management.html)
