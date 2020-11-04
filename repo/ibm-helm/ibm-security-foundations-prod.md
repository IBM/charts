
# Introduction

## Summary

IBM Cloud Pak&reg; for Security provides a platform to quickly integrate your existing security tools to generate deeper insights into threats across hybrid, multicloud environments.

The IBM Cloud Pak for Security platform uses an infrastructure-independent common operating environment that can be installed and run anywhere. It comprises containerized software pre-integrated with Red Hat OpenShift enterprise application platform, which is trusted and certified by thousands of organizations around the world.

IBM Cloud Pak for Security can connect disparate data sources—to uncover hidden threats and make better risk-based decisions — while leaving the data where it resides. By using open standards and IBM innovations, IBM Cloud Pak for Security can securely access IBM and third-party tools to search for threat indicators across any cloud or on-premises location. Connect your workflows with a unified interface so you can respond faster to security incidents. Use IBM Cloud Pak for Security to orchestrate and automate your security response so that you can better prioritize your team's time.


## Chart Details

The ibm-security-foundations-prod chart installs foundation elements of IBM Cloud Pak for Security, which include:

- **Middleware Operator**. Manages the install of data and platform assets used by IBM Cloud Pak for Security, including: ElasticSearch, Etcd, MinIO and RabbitMQ.
- **Sequences Operator**. Orchestrates the install of IBM Cloud Pak for Security components.
- **Arango Operator**. Manages the install of ArangoDB for IBM Cloud Pak for Security.
- **Ambassador**. Creates and manages the Envoy gateway service of IBM Cloud Pak for Security.
- **Custom Resource Definitions**. To enable management of these elements by IBM Cloud Pak for Security.
- **Extensions Operator**. Manages the setup of the connector factories.
- **Entitlements Operator**. Assembles the Bill Of Materials (BoM) of Application Entitlements and Offerings which are deployed on the cluster.

The Middleware and Sequence operator deployed as part of this chart are Namespace-scoped. They watch and manage resources within the namespace that IBM Cloud Pak for Security is installed.

## Prerequisites

- Red Hat OpenShift Container Platform >=4.4.14 or >=4.5.8
- Helm 3.2.4
- Helm 2.12.3 (in upgrade scenario from CP4S 1.3)
- Kubernetes 1.16.2 or later
- Common Services 3.4
- Cluster admin privileges


## PodDisruptionBudget

Pod disruption budget is used to maintain high availability during Node maintenance. Administrator role or higher is required to enable pod disruption budget on clusters with role based access control. The default is false. See `global.poddisruptionbudget` in the [configuration](#configuration) section.


## SecurityContextConstraints Requirements

The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart.

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation.

This chart also defines a custom SecurityContextConstraints object which is used to finely control the permissions/capabilities needed to deploy this chart, the definition of this SCC is shown below:


 ```
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: []
allowedUnsafeSysctls:
  - net.core.somaxconn
apiVersion: security.openshift.io/v1
defaultAddCapabilities: []
fsGroup:
  ranges:
  - max: 5000
    min: 1000
  type: MustRunAs
groups: []
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: ibm-isc-scc is a copy of nonroot scc which allows somaxconn changes
  name: ibm-isc-scc
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- KILL
- MKNOD
- SETUID
- SETGID
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  ranges:
  - max: 5000
    min: 1000
  type: MustRunAs
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```
The following script
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-install/preInstall.sh
```
is run at install time to set the SecurityContextConstraints required by the chart and provision CustomResourceDefinitions, ServiceAccounts and Roles.


## Resources Required

By default, `ibm-security-foundations` has the following resource request requirements per pod:

| Service   | Memory (GB) | CPU (cores) |
| --------- | ----------- | ----------- |
| Ambassador|    256Mi    | 100m        |
| Sequences |    256Mi    | 250m        |
| Middleware|    256Mi    | 250m        |
| Kube-arangodb|   256Mi    | 250m   |
| Extension Discovery| 256Mi | 100m |
| Entitlements | 256Mi | 250m |
| ISC Truststore | 256Mi | 250m |


## Installing the Chart

To install the chart including its prerequisites, please refer to the `Installing IBM Cloud Pak® for Security` section in the README available within the [CASE bundle](https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-security-1.0.9.tgz) for IBM Cloud Pak&reg; for Security.

### Verifying the Chart

The verification of the installation of the chart can be performed by following the procedure described in the `Verifying the Installation` section in the README available within the [CASE bundle](https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-security-1.0.9.tgz) for IBM Cloud Pak&reg; for Security.


### Upgrade or update the installation

To upgrade or update your installation, please refer to the `Upgrading IBM Cloud Pak® for Security` section in the README available within the [CASE bundle](https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-security-1.0.9.tgz) for IBM Cloud Pak&reg; for Security.

### Uninstalling the chart

To uninstall the chart, please refer to the `Uninstalling IBM Cloud Pak® for Security` section in the README available within the [CASE bundle](https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-security-1.0.9.tgz) for IBM Cloud Pak&reg; for Security.


## Configuration

The table in the `Configuration` section in the README available within the [CASE bundle](https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-security-1.0.9.tgz) for IBM Cloud Pak&reg; for Security consists the list of configurable parameters for IBM Cloud Pak&reg; for Security.

## Limitations

This chart can only run on amd64 architecture type.

## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.4.0/cp4s_v1r3/docs/scp-core/overview.html).
