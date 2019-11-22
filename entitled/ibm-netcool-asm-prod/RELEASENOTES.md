## What's new
### 4.0.0
This release of IBM Netcool Agile Service Manager on IBM Cloud Private contains:

* Additional resource styling
* Saving topologies as images
* Templates and subtopologies
  * Administrator users can create templates, which they can use to create subtopologies that operators can search for, and access in, the Topology Viewer.
* New observers:
  * AppDynamics
  * Google Cloud Platform
  * Juniper Networks CSO
  * Microsoft Azure
* Updated observers:
  * AWS Observer: The Observer Configuration UI now supports multi-region full load jobs and property filtering.
  * Ciena Blue Planet Observer now supports the additional 'websocket' job

## Breaking Changes
* You cannot upgrade an existing deployment of `ibm-netcool-asm-prod` chart version
 `<4.0.0` to this chart version. You will be required to delete the existing deployment,
 and reinstall this chart. Your data will be persisted.

## Fixes
* Cassandra auth schema is now correctly replicated to improve resiliency

## Prerequisites
1. This chart requires IBM Cloud Private version 3.2.0 or later
2. This chart is only supported on amd64 worker nodes
3. This chart requires the use of persistent storage in production
4. This chart requires permission to create ClusterRole and ClusterRoleBinding resources
5. This chart requires a deployment of ibm-netcool-prod in the same namespace
6. This chart uses the default service account in the namespace in which it is deployed
6. You must remove existing jobs before attempting an upgrade

## Documentation
* [IBM Netcool Agile Service Manager Knowledge Center](https://www.ibm.com/support/knowledgecenter/SS9LQB_1.1.6/)

## Version History

| Chart | Date       | Kubernetes Required | Breaking Changes                          | Details                        |
| ----- | ---------- | ------------------- | ----------------------------------------- | ------------------------------ |
| 4.0.0 | Oct, 2019  | >=1.11.0            | Cannot upgrade directly from chart <4.0.0 | Update for ASM 1.1.6           |
| 3.0.0 | June, 2019 | >=1.11.0            | Cannot upgrade directly from chart <3.0.0 | Update for ASM 1.1.5           |
| 2.0.1 | Apr, 2019  | >=1.11.0            | -                                         | Update for ASM 1.1.4 FP1       |
| 2.0.0 | Feb, 2019  | >=1.11.0            | Cannot upgrade directly from chart 1.0.0  | Update for ASM 1.1.4           |
| 1.0.0 | Sept, 2018 | >=1.10.0            | -                                         | Initial release of ASM chart   |
