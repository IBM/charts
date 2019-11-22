# IBM Cloud Management Platform

## Introduction
A Helm chart for deploying the common services used by the IBM Cloud Cost and Asset Management application and other related applications. The common infrastructure services include messaging service, API gateway service, security services (Single Sign-On, authorization, API Key Management), notification, common portal, audit logs, etc."

## Chart Details

This chart deploys IBM Cloud Management Platform as a number of deployments and services.

## Prerequisites

  1. Precreate the persistent volumes for the common services. For details see [here](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/cam_create_pv.html)
  2. Create namespace and secrets required for the common services
     Run the pre-install scripts to create the Namespace & Secrets
     Refer to  [instruction](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/cam_prereq.html) to run the pre-install scripts.
  3. Create the PSP as mentioned in PodSecurityPolicy Requirements below.     
  4. Operator access required to install chart.

## Resources Required

* [list of hardware requirements](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/core_hw_requirements.html)

## PodSecurityPolicy Requirements
On ICP :
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Have your cluster administrator create a custom PodSecurityPolicy for you. Additionally, the predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

- Custom PodSecurityPolicy definition:
```
---
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: core-security
  labels:
spec:
  privileged: false
  allowPrivilegeEscalation: true
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
  - MKNOD
  allowedCapabilities:
  - CHOWN
  - SETFCAP
  - IPC_LOCK
  - NET_ADMIN
  - SETGID
  - SETUID
  - DAC_OVERRIDE
  - FOWNER
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
- Custom Role for the custom PodSecurityPolicy:
```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: core-security-role
  labels:
rules:
 -
   apiGroups:
     - extensions
   resourceNames:
     - core-security
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
  name: core-security-psp-users
  labels:
subjects:
 - kind: Group
   apiGroup: rbac.authorization.k8s.io
   name: "system:serviceaccounts:<<Namespace for ibm-cloud-mgmt-platform-prod>>"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: core-security-role
```

## Red Hat OpenShift SecurityContextConstraints Requirements
On ICP with OpenShift
Ask your Openshift Administrator to add a new SCC and add it to the service account in the project where ibm-cloud-mgmt-platform-prod is deployed. For reference [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc)

```
---
apiVersion: security.openshift.io/v1
metadata:
  annotations:
  name: platform-mgmt
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities:
- CHOWN
- SETFCAP
- IPC_LOCK
- NET_ADMIN
- SETGID
- SETUID
- FOWNER
- DAC_OVERRIDE
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups:
- system:cluster-admins
kind: SecurityContextConstraints
priority: 10
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```
Run the command below to get the SCC created using the content above from platform-mgmt.yaml :
```
oc create -f platform-mgmt.yaml
```
Run the below command to add the scc added above to project where you are going to deploy chart:
```
oc adm policy add-scc-to-group platform-mgmt system:serviceaccounts:<<project name of ibm-cloud-mgmt-platform-prod chart>>
```

## Installing the Chart

Add the IBM Cloud Private internal Helm repository called local-charts to the Helm CLI as an external repository, as described [here](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/app_center/add_int_helm_repo_to_cli.html).

To install the chart with the release name `platform` in the namespace `platform`:

```bash
$ helm install mycluster/ibm-cloud-mgmt-platform-prod --tls --name platform --namespace platform --set  serviceType="NodePort",k8StorageType="nfs",secrets.gateway.apiKey="<apikey>",enforceCertificateValidation="false",apiGatewayUrl="<gatewayurl>"
```
For detailed instructions on installing IBM Cloud Management Platform refer  [here](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/install_core.html)

## Configuration

The following tables lists the configurable parameters of the `ibm-cloud-mgmt-platform-prod` chart and their default values.For Installing with serviceType as Ingress refer [here](https://www.ibm.com/support/knowledgecenter/SSMPHF_3200/ingress_install.html)

| Parameter | Description| Default    |                                     
| --------- | ---------- | ---------- |
| `serviceType`| Kubernetes Service Type.| `NodePort`  |
| `storageType`| Kubernetes Storage Type.|   |
| `apiGatewayUrl`| URL for Gateway Host : https://<icp_proxy_ip>:30091 for serviceType NodePort.|   |
| `secrets.gateway.apiKey`| Any valid string.|   |
| `gatewayHost`| Gateway Host - Value has to be provided for serviceType Ingress.|   |
| `httpProxy`| HTTP Proxy settings.  |   |
| `httpsProxy`| HTTPS Proxy settings.  |   |
| `noProxy`| NO Proxy settings.  | `couchdb,mongodb,cb-audit-service,cb-budget-adapter,cb-cam-diagnostics,cb-core-auth,cb-core-auth-internal,cb-core-authorization-service,cb-core-configuration-service,cb-couchdb-br,cb-cred-svc,cb-help-service,cb-mongodb-br,cb-notification-api,cb-vault-hvault,cb-vault-api`  |
| `enforceCertificateValidation`| Select to Enforce self-signed TLS certificate. | `true`  |
| `enableBackups`| Select to enable Backup.  | `false`  |
| `persistence.enabled` | Select to enable persistence | `true` |
| `persistence.useDynamicProvisioning` | Select for dynamic provisioning | `true` |
|`k8StorageAccessMode.nfs`|Kubernetes Storage Access Modes for NFS|`ReadWriteMany`|
|`k8StorageAccessMode.glusterfsStorage`|Kubernetes Storage Access Modes for GlusterFS |`ReadWriteMany`|
|`coreCouchdbPv0.glusterfsStorage.storageClass`|Storage Class to be used with GlusterFS ||
|`coreRabbitmqPv0.glusterfsStorage.storageClass`|Storage Class to be used with GlusterFS ||


## Limitations
This Chart is tested only with amd64 architecture.

## Documentation

[IBM Cloud Cost and Asset Management Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSMPHF/welcome_cost_asset_management.html)
