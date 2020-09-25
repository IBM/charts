# Release Notes for IBM Netcool Operations Insight

## What's new

- Openshift 4.3/4.4 support
- The release descriptions for Netcool Operations Insight are available at [Release notes](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/relnotes/soc_relnotes.html#soc_relnotes__title_Newfeatures).

## Fixes

- Compliance fixes.
- Distributed persistent storage is still recommended, but not required.

## Breaking Changes

### Version 1.x to 2.x

- Switched from deployments to statefulset for all pods except for jdbcgw and proxy.
- Move to new Kubernetes labels.

## Prerequisites

1. This chart requires Openshift 4.3 or 4.4.
2. This chart requires amd64 worker nodes.
3. This chart requires permissions to create ClusterRole and ClusterRoleBinding resources.

## Documentation

Full documentation on deploying the ibm-netcool-prod chart can be found in the [Netcool Operations Insight documentation](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/collaterals/soc_netops_kc_welcome.html).

## Version History

| Chart | Date       | Kubernetes Required | Breaking Changes     | Details                          |
| ----- | ---------- | ------------------- | -------------------- | -------------------------------- |
| 2.1.5 | Sep, 2020  | >=1.11.0            | -                    | NOI 1.6.2, Openshift 4.4, 4.5 support |
| 2.1.4 | Jun, 2020  | >=1.11.0            | -                    | NOI 1.6.1, Openshift 4.3/4.4 support|
| 2.1.3 | Mar, 2020  | >=1.11.0            | -                    | NOI 1.6.0.3, Openshift 4.3 support|
| 2.1.2 | Jan, 2020  | >=1.11.0            | -                    | NOI 1.6.0.2, Hybrid mode & Openshift 4.2 support|
| 2.1.1 | Oct, 2019  | >=1.11.0            | -                    | NOI 1.6.0.1, UI updates, Bug fixes, Topology Analytics |
| 2.1.0 | Jun, 2019  | >=1.11.0            | -                    | NOI 1.6.0, OpenShift support & Cloud based Event Analytics |
| 2.0.0 | Feb, 2019  | >=1.11.1            | labels & statefulset | NOI 1.5.0.1 & minimal scalability |
| 1.0.0 | Sept, 2018 | >=1.10              | -                    | Initial release of NOI chart |

----
### Build details

- Build Number: master-242
- Git Commit: 29a7b63

