# What’s new in IBM Tivoli Netcool/OMNIBus Probe for Message Bus Kafka Helm Chart (Commercial Use) Version 2.1.0

## Breaking Changes

N/A

## Enhancements

1.   Support for deployment on IBM Cloud Private with OpenShift. The probe image has been updated with Red Hat Universal Base Image (UBI) as the base image with a new tag convention and the tag now has a `amd64` suffix. A new utility image "netcool-integration-util" is used for helm tests which is also based on UBI base image. International Program License Agreement ("IPLA") file in probe images updated to L/N: L-PPAN-BFXKQE.
2.   Chart International Program License Agreement ("IPLA") file updated to L/N: L-PPAN-BFXKQE.
3.   The helm chart will now deploy using a custom service account to apply the required privileges instead of sharing the default namespace service account. You may configure the chart to use an existing service account configured by your Cluster Administrator by setting the `messagebus.global.serviceAccountName` parameter. If the `messagebus.global.serviceAccountName` parameter is unset, a new service account is automatically created during deployment and will be removed together with the Helm release. You may also need to specify the `messagebus.global.image.secretName` parameter with the image pull secret name if you are using a private image repository.
4.   Support for connecting to Kafka services that do not expose a Zookeeper service. As such, Zookeeper parameters are no longer mandatory and 
can be left blank. Zookeeper Watch parameters are also set to false by default.
5.   Support to enable secure connections between the probe and ObjectServer.
6.   All authentication credentials and TrustStore/KeyStore files with their passwords are now required to be created as Secrets. This improves the 
    security of the chart by removing sensitive information from being displayed in the helm release. The following are the Secrets supported by 
    the chart:
    - Image Pull Secret for authenticating with the Docker Registry
    - ObjectServer authentication credentials
    - HTTP and Kafka Transport authentication credentials
    - TrustStore file and its password
    - KeyStore file and its password
7.   Horizontal Pod Autoscaler has been updated to use `autoscaling/v2beta1` API version. There is no change in the target CPU average utilization default value.

## Fixes

-   Resolved issue where probe cannot run due to a License Acceptance issue in ICP 3.1.1.
-   Resolved issue where certain fields are missing or not editable when configuring the chart in the ICP 3.1.1.
-   Added `kubeVersion` attribute in Chart.yaml file.
-   Updated internal IBM Shared Configuration Helper sub-chart to version 1.2.13.
-   Internal improvements on ICP UI chart configuration page.
-   Corrected Kubernetes command for ClusterIP in Notes.txt
-   The Quick Start section has been updated to present the minimum required parameters to deploy the probe using the Plaintext scenario.

## Prerequisites

1.  This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe either on IBM Cloud Private (ICP) or on-premise:
  - For ICP, IBM Netcool Operations Insight 1.6.0.1 is required. Refer to the installation instructions at [IBM Knowledge Center - Installing on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_installing-on-icp.html).
  - For on-premise, IBM Tivoli Netcool/OMNIbus 8.1 is required. Refer to the installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).
2.  [Scope-based Event Grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/concept/omn_con_ext_aboutscopebasedegrp.html) is installed. The probe requires several table fields to be installed in the ObjectServer. For on-premise installation, refer instructions at [IBM Knowledge Center - Installing scope-based event grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ext_installingscopebasedegrp.html). The events will be grouped by a preset `ScopeId` in the probe rules file if the event grouping automation triggers are enabled.
3.  Kubernetes 1.10.
4.  Tiller 2.9.1

## Version History

| Chart | Date         | Kubernetes | Supported Image(s)                      | Details                                                            |
| ----- | ------------ | ---------- | --------------------------------------- | ------------------------------------------------------------------ |
| 2.1.0 | Oct 31, 2019 | >=1.10     | netcool-probe-messagebus:10.0.5.0-amd64 | Support for ICP with OpenShift. New probe image based on UBI.      |
| 2.0.0 | Feb 28, 2019 | >=1.11.1   | netcool-probe-messagebus:9.0.9          | Added Pod Security Policy                                          |
| 1.0.0 | Oct 11, 2018 | >=1.9      | netcool-probe-messagebus:8.0.29         | Initial Commercial Use Version                                     |
| 0.1.1 |              | >=1.9      | netcool-probe-messagebus:8.0            | Added secure connections support                                   |
| 0.1.0 |              | >=1.9      | netcool-probe-messagebus:8.0            | Initial Version                                                    |


## Change History

### Changes in Version 2.1.0

Refer to the "Enhancements" [section](#enhancements) above for more details.

### Changes in Version 2.0.0

-   Pre-requisite update: Kubernetes version increased to 1.11.1.
-   Pre-requisite update: Tiller version increased to 2.9.1.
-   This version of the Message Bus Kafka Probe helm chart has been updated to use a new Docker image version `netcool-probe-messagebus:9.0.9` which runs the probe process as non-root user. Default `image.tag` updated to `9.0.9` from `8.0`.
-   Combined `image.repository` and `image.name` parameters into `image.repository` so that the `cloudctl` command line tool is able to update the repository prefix accordingly when loading the PPA package. This `image.repository` parameter is now a mandatory parameter.
-   New PodSecurityPolicy requirement added as prerequisite. This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. You can choose either a namespace bound with a predefined PodSecurityPolicy (`ibm-restricted-psp`) or have your cluster administrator create a custom PodSecurityPolicy for you. Please see README for more details.
-   This version also includes:
    - Tivoli Netcool/OMNIbus 8.1.0 Fix Pack 18 libraries.
    - Probe dependency libraries upgrade.
        - Common Transformer Module upgraded to version 9.0 from 8.0.
        - Common Transport Module upgraded to version 20.0 from 19.0.
    -    Ubuntu 16.04 Operating System patch (ubuntu:xenial-20190122).
    -    This image runs the probe process as a non-root user for improved security.
    -    License file updated. Changed to L/N: L-PKEY-B8JMCA license (previously L/N: L-TKAI-B33FE5).
- Shared Configurable Helper (SCH) subchart upgraded to v1.2.6
- This helm chart has been updated to use the new standard Kubernetes labels for the chart-defined resources. As a result of this change, this helm chart cannot be upgraded from version 2.0.3 or earlier and must be installed using a new installation. Future versions of this helm chart will be 
able to support upgrade installations.
- Below is a summary of the changes to the chart-defined resources:

| Old Label        | New Label           |
| ------------- |:-------------:|
| app      | app.kubernetes.io/name |
| chart      | helm.sh/chart      |
| component | app.kubernetes.io/component      |
| heritage | app.kubernetes.io/managed-by      |
| productVersion | app.kubernetes.io/version      |
| release | app.kubernetes.io/instance      |

### Changes in Version 1.0.0

- Initial production use version.

## Documentation

For more info on the Message Bus Probe, please visit IBM Knowledge Center - [Message Bus Probe Introduction](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/message_bus/wip/concept/messbuspr_intro.html)
