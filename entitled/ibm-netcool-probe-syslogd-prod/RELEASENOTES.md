# What’s new in IBM Netcool Probe Syslogd Chart Version 2.0.0

## Breaking Changes

-   Pre-requisite updates:
    -   Kubernetes required version increased to 1.11.1.
    -   Tiller version increased to 2.9.1.
-   New PodSecurityPolicy requirement added as prerequisite. This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. You can choose either a namespace bound with a predefined PodSecurityPolicy (`ibm-restricted-psp`) or have your cluster administrator create a custom PodSecurityPolicy for you. The probe image is upgraded to run the probe process as non-root user for improved security and to support running in a namespace with a restrictive PodSecurityPolicy. Please see README for more details.
-   This version of Syslogd Probe helm chart has been updated to use a new Docker image version `netcool-probe-syslogd:5.0.3_4` which runs the probe process as non-root user.
-   Tivoli Netcool/OMNIbus Syslogd Probe image version upgraded to `netcool-probe-syslogd:5.0.3_4` from `netcool-probe-syslogd:5.0`. Default `image.tag` updated to `5.0.3_4` from `5.0`. This version includes:
    -    Tivoli Netcool/OMNIbus 8.1.0 Fix Pack 18 libraries.
    -    Ubuntu 16.04 Operating System patch (ubuntu:xenial-20190122).
    -    This image runs the probe process as a non-root user for improved security.
    -    License file updated. Changed to L/N: L-PKEY-B8JMCA license (previously L/N: L-TKAI-B33FE5).
-   Combined `image.repository` and `image.name` parameters into `image.repository` so that the `cloudctl` command line tool is able to update the repository prefix accordingly when loading the PPA package. This `image.repository` parameter is now a mandatory parameter.
-   Pod Disruption Budget is now disabled by default `poddisruptionbudget.enabled=false` to allow Operators to install this chart. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control.
-   This helm chart has been updated to use the new standard Kubernetes labels for the chart-defined resources. As a result of this change, this helm chart cannot be upgraded from version 1.0.0 or earlier and must be installed using a new installation. Future versions of this helm chart will be 
able to support upgrade installations.
-   Below is a summary of the changes to the chart-defined resources:

| Old Label        | New Label           |
| ------------- |:-------------:|
| app      | app.kubernetes.io/name |
| chart      | helm.sh/chart      |
| component | app.kubernetes.io/component      |
| heritage | app.kubernetes.io/managed-by      |
| productVersion | app.kubernetes.io/version      |
| release | app.kubernetes.io/instance      |


## Enhancements

-   Added [Pod Security Policy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) (`securityContext`) attributes into Deployment specification to specify required settings for Pod Isolation.
-   Requires predefined PodSecurityPolicy name: `ibm-restricted-psp` or a custom PodSecurityPolicy.
-   Test pod template now uses the same image pull secret (`image.secretName`) parameter as the probe pods.
-   Updated the `image.testRepository` default value to also include the test image name (busybox).
-   Introduce new `image.testImageTag` parameter (defaults to `1.28.4` for busybox) to configure the test image if necessary.
-   Deployment template now uses `apps/v1` API version.
-   Updated Nhttpd ClusterIP external port to 8080 from 8081 for consistency.

## Fixes

-   Fixed rendering issue when `probe.rulesFile` set to `NCKL`.
-   Internal improvements
    -   Fix linter errors.
    -   Added `kubeVersion` attribute in Chart.yaml.
    -   Updated internal IBM Shared Configuration Helper sub-chart to version 1.2.6.
    -   Helper functions now have unique names to avoid potential conflict.
    -   Corrected UI tooltip description for `autoscaling.cpuUtil` to indicate that this parameter expects a number for target average CPU utilization (represented as a percentage of requested CPU) over all the pods instead of number of pods.

## Prerequisites

1.  This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe. To create and run the IBM Tivoli Netcool/OMNIbus ObjectServer, see installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).
2.  Scope-based Event Grouping automation is installed and enabled, see installation instructions at [IBM Knowledge Center - Installing scope-based event grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ext_installingscopebasedegrp.html)
3.  Kubernetes version 1.11.1.
4.  Tiller 2.9.1

## Documentation

For more information about IBM Tivoli Netcool/OMNIbus Syslogd probe, visit [Syslogd probe intro](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/syslogd/wip/concept/syslogd_intro.html)

## Version History

| Chart | Date         | Kubernetes Required | Image(s) Supported            | Breaking Changes               | Details                        |
| ----- | ------------ | ------------------- | ----------------------------- | ------------------------------ | ------------------------------ |
| 2.0.0 | Feb 28, 2019 | >=1.11.1            | netcool-probe-syslogd:5.0.3_4 | Pre-requisite and image update | Image update & several fixes   |
| 1.0.1 | Oct 11, 2018 | >=1.9               | netcool-probe-syslogd:5.0     | None                           | Add Apache 2.0 License         |
| 1.0.0 | Aug 9, 2018  | >=1.9               | netcool-probe-syslogd:5.0     | None                           | Initial Version for Production |

## Change History

### Changes in Version 2.0.0

Refer to "What's New" [section](#breaking-changes) for more details.

### Changes in Version 1.0.1

#### Fixes

-   Add Apache 2.0 License in Helm Chart.
-   The `probe.messageLevel` and `probe.rulesFile` parameters changed to be mutable.
