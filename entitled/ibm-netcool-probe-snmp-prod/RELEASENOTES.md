# What’s new in IBM Tivoli Netcool/OMNIbus Probe for SNMP Chart Version 2.0.0

## Breaking Changes

-   Pre-requisite updates:
    -   Kubernetes version increased to 1.11.1.
    -   Tiller version increased to 2.9.1.
-   New PodSecurityPolicy requirement added as prerequisite. This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. You can choose either a namespace bound with a predefined PodSecurityPolicy (`ibm-restricted-psp`) or have your cluster administrator create a custom PodSecurityPolicy for you. The probe image is upgraded to run the probe process as non-root user for improved security and to support running in a namespace with a restrictive PodSecurityPolicy. Please see README for more details.
-   Tivoli Netcool/OMNIbus SNMP Probe image version upgraded to `netcool-probe-snmp:20.2.0_4` from `netcool-probe-snmp:20.2`. Default `image.tag` updated to `20.2.0_4` from `20.2`. This version includes:
    -    Tivoli Netcool/OMNIbus 8.1.0 Fix Pack 18 libraries.
    -    Ubuntu 16.04 Operating System patch (ubuntu:xenial-20190122).
    -    This image runs the probe process as a non-root user for improved security.
    -    License file updated. Changed to L/N: L-PKEY-B8JMCA license (previously L/N: L-TKAI-B33FE5).
-   Combined `image.repository` and `image.name` parameters into `image.repository` so that the `cloudctl` command line tool is able to update the repository prefix accordingly when loading the PPA package. This `image.repository` parameter is now a mandatory parameter.
-   Pod Disruption Budget is now disabled by default `poddisruptionbudget.enabled=false` to allow Operators to install this chart. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control.
-   This helm chart has been updated to use the new standard Kubernetes labels for the chart-defined resources. As a result of this change, this helm chart cannot be upgraded from version 1.0.1 or earlier and must be installed using a new installation. Future versions of this helm chart will be 
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

-   Updated internal IBM Shared Configuration Helper sub-chart to version 1.2.6.
-   Added [Pod Security Policy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) (`securityContext`) attributes into Deployment specification to specify required settings for Pod Isolation.
-   Requires predefined PodSecurityPolicy name: `ibm-restricted-psp` in ICP 3.1.1.
-   Test pod template now uses the same image pull secret (`image.secretName`) parameter as the probe pods.
-   Updated the `image.testRepository` default value to also include the test image name (busybox).
-   Introduce new `image.testImageTag` parameter (defaults to `1.28.4` for busybox) to configure the test image if necessary.
-   Update SNMP V3 Security User Configuration documentation to show sample configurations in YAML format for convenience.
-   Deployment template now uses `apps/v1` API version.

## Fixes

-   Internal improvements. Minor update to UI metadata file.
    -   Corrected UI tooltip description for `autoscaling.cpuUtil` to indicate that this parameter expects a number for target average CPU utilization (represented as a percentage of requested CPU) over all the pods instead of number of pods.
-   Added `kubeVersion` attribute in Chart.yaml.
-   Fixed Linter errors


## Prerequisites

1.  This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe. To create and run the IBM Tivoli Netcool/OMNIbus ObjectServer, see installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).
2.  Scope-based Event Grouping automation is installed and enabled, see installation instructions at [IBM Knowledge Center - Installing scope-based event grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ext_installingscopebasedegrp.html)
3.  Netcool Knowledge Library (NcKL) Intra-Device correlation automation is installed and enabled. More info to install this manually on on-premise Object Server is outlined [here](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/nckl/wip/reference/nckl_cnf_obj_intrdvc.html). This automation creates the following objects in the Object Server to aid in determining the causal relevance of events.
    -   Intra-device correlation (AdvCorr) tables within the alerts database
    -   Supplementary automation implemented as an AdvCorr trigger group and three related triggers
    -   Additional columns in the alerts.status table
4.  Kubernetes 1.11.1.
5.  Tiller 2.9.1

## Documentation

For more info on the SNMP Probe, please visit IBM Knowledge Center - [SNMP Probe Introduction](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/snmp/wip/concept/snmp_introduction_c.html)

## Version History

| Chart | Date         | Kubernetes | Image(s) Supported          | Breaking Changes               | Details                        |
| ----- | ------------ | ---------- | --------------------------- | ------------------------------ | ------------------------------ |
| 2.0.0 | Feb 28, 2019 | >=1.11.1   | netcool-probe-snmp:20.2.0_4 | Pre-requisite and image update | Image update & several enhancements |
| 1.0.1 | Oct 11, 2018 | >=1.9      | netcool-probe-snmp:20.2     | None                           | Add Apache 2.0 License         |
| 1.0.0 | Aug  9, 2018 | >=1.9      | netcool-probe-snmp:20.2     | None                           | Initial Version for Production |

# Change History

## Changes in Version 2.0.0

Refer to "What's New" [section](#breaking-changes) above for details.

## Changes in Version 1.0.1

### Fixes

-   Add Apache 2.0 License in Helm Chart.
-   The `probe.messageLevel` and `probe.rulesFile` parameters changed to be mutable.

## Changes in Version 1.0.0

Initial version for production use.

## Documentation

-   IBM Tivoli Netcool/OMNIbus SNMP Probe Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/snmp/wip/concept/snmp_introduction_c.html)
    -   SNMP v3 Support [page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/snmp/wip/reference/snmp_support_v3_r.html)
-   IBM Tivoli Netcool Knowledge Library (NcKL) Knowledge Center [introduction page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/nckl/wip/reference/nckl_intrdctn.html)
