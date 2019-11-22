# What’s new in IBM Tivoli Netcool/OMNIBus Probe for Tivoli EIF Helm Chart (Commercial Use) Version 2.0.0

## Breaking Changes

* Prerequisite updates
    * Kubernetes version increased to 1.11.1.
    * Tiller version increased to 2.9.1.
* New PodSecurityPolicy requirement added as prerequisite. This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. You can choose either a namespace bound with a predefined PodSecurityPolicy (`ibm-restricted-psp`) or have your cluster administrator create a custom PodSecurityPolicy for you. Please see README for more details.
* Default image tag updated to `13.0.7_4`. This image runs the probe process as a non-root user.
* Combined `image.repository` and `image.name` parameters into `image.repository` so that the `cloudctl` command line tool is able to update the repository prefix accordingly when loading the PPA package. This `image.repository` parameter is now a mandatory parameter.
* Shared Configurable Helper (SCH) subchart upgraded to v1.2.6
* This helm chart has been updated to use the new standard Kubernetes labels for the chart-defined resources. As a result of this change, this helm chart cannot be upgraded from version 2.0.3 or earlier and must be installed using a new installation. Future versions of this helm chart will be 
able to support upgrade installations.
* Below is a summary of the changes to the chart-defined resources:

| Old Label        | New Label           |
| ------------- |:-------------:|
| app      | app.kubernetes.io/name |
| chart      | helm.sh/chart      |
| component | app.kubernetes.io/component      |
| heritage | app.kubernetes.io/managed-by      |
| productVersion | app.kubernetes.io/version      |
| release | app.kubernetes.io/instance      |

## Fixes

* Corrected `kubectl port-forward` command syntax in Notes.txt for ClusterIP configuration
* Added `--namespace` to `kubectl port-forward` command syntax in Notes.txt for ClusterIP configuration
* Added `kubeVersion` attribute in Chart.yaml file.
* Internal improvements:
  * Updated internal IBM Shared Configuration Helper (SCH) sub-chart to version 1.2.6.

## Enhancements

* Packaging updated to follow CloudPak structure. Several utility scripts are provided in the pak_extensions/pre-install directory in the CloudPak archive.
* Added [Pod Security Policy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) (`securityContext`) attributes into Deployment specification to specify required settings for Pod Isolation.
* Updated the `image.testRepository` default value to also include the test image name (busybox).
* Introduce new `image.testImageTag` parameter (defaults to `1.28.4` for busybox) to configure the test image if necessary.

## Prerequisites

1.  This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe. To create and run the IBM Tivoli Netcool/OMNIbus ObjectServer, see installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).
2.  Scope-based Event Grouping automation is installed and enabled, see installation instructions at [IBM Knowledge Center - Installing scope-based event grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ext_installingscopebasedegrp.html)
3.  Kubernetes 1.11.1. Verified running on IBM Cloud Private version 3.1.0 and 3.1.1.
4.  Tiller 2.9.1

## Documentation

For more info on the Tivoli EIF Probe, please visit IBM Knowledge Center - [Tivoli EIF Probe Introduction](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/tivoli_eif_v11/wip/reference/tveifv11_intro.html)

## Version History

| Chart | Date         | Kubernetes Required | Image(s) Supported               | Details                                                  |
| ----- | ------------ | ------------------- | -------------------------------- | -------------------------------------------------------- |
| 2.0.0 | Feb 28, 2019 | >=1.11.1            | netcool-probe-tivolieif:13.0.7_4 | Update image version to 13.0.7_4                         |
| 1.0.1 | Oct 11, 2018 | >=1.9               | netcool-probe-tivolieif:13.0     | Add Apache 2.0 License.                                  |
| 1.0.0 | Jul 18, 2018 | >=1.9               | netcool-probe-tivolieif:13.0     | Initial version for Production                           |
| 0.1.1 | Jul 12, 2018 | >=1.9               | netcool-probe-tivolieif:13.0     | Fixes to the Configuration page for license and tooltips |
| 0.1.0 | Jul  9, 2018 | >=1.9               | netcool-probe-tivolieif:13.0     | Initial Version                                          |

## Change History

### Changes in Version 2.0.0

Refer to the "What’s new" [section](#breaking-changes) above for more details.

### Changes in Version 1.0.1

* Added Apache 2.0 license to the helm chart.

### Changes in Version 1.0.0

Initial version of the `ibm-netcool-probe-tivolieif-prod` chart for production.

### Changes in Version 0.1.1

* Various fixes to the Configuration page for license and tooltips.

### Changes in Version 0.1.0

Initial version of the `ibm-netcool-probe-tivolieif-prod` chart.
