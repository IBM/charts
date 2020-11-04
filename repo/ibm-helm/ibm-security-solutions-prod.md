
## ibm-security-solutions-prod

## Introduction
IBM Cloud Pak&reg; for Security Shared Platform Services, `ibm-security-solutions-prod`, provides a shared platform that integrates your disconnected security systems for a complete view of all your security data, without moving the data. It turns individual apps, services, and capabilities into unified solutions to empower your teams to act faster, and improves your security posture with collective intelligence from a global community. Reduce complexity, expand your visibility and maximize your existing investments with a powerful, open, cloud security platform that connects your teams, tools and data. For further details see the [IBM Cloud Pak for Security Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.3.0/cp4s_v1r3/docs/scp-core/overview.html).

## Chart Details

This chart installs `ibm-security-solutions-prod`, providing the IBM Cloud Pak for Security Shared Core Services.

The Cases and Postgres operators deployed as part of this chart are Namespace-scoped. They watch and manage resources within the namespace that IBM Cloud Pak for Security is installed

## Prerequisites

- The `ibm-security-foundations-prod` chart must be installed prior to this chart
- This chart must be installed into the same namespace as the `ibm-security-foundations-prod` chart
- Red Hat OpenShift Container Platform 4.4 or 4.5
- Helm 3.2.4
- Helm 2.12.3 (in  upgrade scenario from CP4S 1.3)
- Kubernetes 1.16.2 or later
- Common Services 3.4
- Cluster Admin privileges
- Persistent storage is configured


## PodDisruptionBudget
Pod disruption budget is used to maintain high availability during Node maintenance. Administrator role or higher is required to enable pod disruption budget on clusters with role based access control. The default is false. See `global.poddisruptionbudget` in the [configuration](#configuration) section.


## SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints object to be bound to the target namespace prior to installation.

The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, It is required that you allow the pods running Elasticsearch to run privileged containers. The reason for this requirement is to meet the production settings stated officially by the Elasticsearch documentation. To achieve this, you must you must also create a service account called ibm-dba-ek-isc-cases-elastic-bai-psp-sa that has the ibm-privileged-scc SecurityContextConstraint to allow running privileged containers.

## Resources Required

By default, `ibm-security-solutions-prod` has the following resource requests requirements per pod:

| Service  | Memory (GB) | CPU (cores)
| --------- | ----------- | ----------- |
| Cases  |    9950Mi   |  1760M  |
| Platform | 2190Mi | 1225M  |
| DE | 1024Mi | 300M |
| CAR | 128Mi | 100M |
| Extensions | 128Mi | 100M |
| UDS | 250Mi | 50M |
| TII | 900Mi | 600M |
| TIS | 1536Mi | 600M |
| CSA Adapter| 256Mi | 200M |
| Toolbox | 128Mi | 50m |

## Storage
IBM Cloud Pak for Security requires specific persistent volumes and persistent volume claims. To provide the required storage, persistent volume claims are created automatically during the installation of IBM Cloud Pak for Security.

Persistent storage separates the management of storage from the management and lifecycle of compute. For example, persistent storage, allows data to persist across Kubernetes container and worker restarts.

For more details on the size of the persistent volume please refer to [persistent storage requirements](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.3.0/cp4s_v1r3/docs/security-pak/persistent_storage.html)

The persistent volume claim must have an access mode of ReadWriteOnce (RWO).

For volumes that support ownership management, specify the group ID of the group owning the persistent volumes' file systems using the `storageClassFsGroup` and `storageClassSupplementalGroups` parameters as described in [configuration](#configuration) below.


## Installing the Chart

To install the chart including its prerequisites, please refer to the `Installing IBM Cloud Pak® for Security` section in the README available within the [CASE bundle](https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-security-1.0.8.tgz) for IBM Cloud Pak&reg; for Security.

### Verifying the Chart

The verification of the installation of the chart can be performed by following the procedure described in the `Verifying the Installation` section in the README available within the [CASE bundle](https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-security-1.0.8.tgz) for IBM Cloud Pak&reg; for Security.


### Upgrade or update the installation

To upgrade or update your installation, please refer to the `Upgrading IBM Cloud Pak® for Security` section in the README available within the [CASE bundle](https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-security-1.0.8.tgz) for IBM Cloud Pak&reg; for Security.

### Uninstalling the chart

To uninstall the chart, please refer to the `Uninstalling IBM Cloud Pak® for Security` section in the README available within the [CASE bundle](https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-security-1.0.8.tgz) for IBM Cloud Pak&reg; for Security.


## Configuration

The table in the `Configuration` section in the README available within the [CASE bundle](https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-security-1.0.8.tgz) for IBM Cloud Pak&reg; for Security consists the list of configurable parameters for IBM Cloud Pak&reg; for Security.


## Limitations

This chart can only run on amd64 architecture type.

This chart sets `global.useDynamicProvisioning` to `true`. Dynamic provisioning must not be disabled in the current version.


## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSTDPP_1.4.0/cp4s_v1r3/docs/scp-core/overview.html).
