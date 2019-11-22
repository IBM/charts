# What’s new in IBM Netcool/OMNIbus Probe Cloud Monitoring Integration Chart Version 4.1.0

## Breaking Changes

None

## Enhancements

1.   Update probe image to version 10.0.5 which includes several security patches. Test utility image also updated to version 2.0.0. Image and Helm chart International Program License Agreement ("IPLA") license files updated to L/N: L-PPAN-BFXKQE.
2.   IBM Shared Configurable Helper sub-chart updated to version 1.2.13.
3.   The Pod Security Policy template provided in the chart pak_extension directory has been updated to use the `policy/v1beta1` API following [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) version 1.1.0. Previously, the PSP was using  `extensions/v1beta1` API. For Red Hat Openshift Container Platform, the Security Context Constraints template has also been updated to with [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) version 1.1.0.
4.   The initialization script (init.sh) has been migrated into the Docker image to reduce clutter in the probe Configmap.
5.   Horizontal Pod Autoscaler has been updated to use `autoscaling/v2beta1` API version. There is no change in the target CPU average utilization default value.
6.   Minor update to metering annotation used by the chart. The annotations now reflect Netcool Operations Insight v1.6.0.1 and pod metrics will be grouped by this version.

## Fixes

None


## Prerequisites

1.  This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe either on IBM Cloud Private (ICP) or on-premise:
  - For ICP, IBM Netcool Operations Insight 1.6.0.1 is required. Refer to the installation instructions at [IBM Knowledge Center - Installing on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_installing-on-icp.html).
  - For on-premise, IBM Tivoli Netcool/OMNIbus 8.1 is required. Refer to the installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).
2. [Scope-based Event Grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/concept/omn_con_ext_aboutscopebasedegrp.html) is installed. The probe requires several table fields to be installed in the ObjectServer. For on-premise installation, refer instructions at [IBM Knowledge Center - Installing scope-based event grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ext_installingscopebasedegrp.html). The events will be grouped by a preset `ScopeId` in the probe rules file if the event grouping automation triggers are enabled.
3.  Kubernetes 1.10.
4.  Tiller 2.9.1.
5.  Logstash 5.5.1.
6.  Prometheus 2.3.1 and Prometheus Alert Manager 0.15.0.
7.  IBM Cloud Event Management Helm Chart 2.4.0

## Version History

| Chart | Date         | Kubernetes Required | ICP Required | Image(s) Supported                  | Breaking Changes               | Details                                                                                                                                                                                                                                      |
| ----- | ------------ | ------------------|  ------------ | ----------------------------------- | ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 4.1.0 | Oct 31, 2019 | >=1.10 | >=3.1.2      | netcool-probe-messagebus:10.0.5.0-amd64      | Updated image with Probe for Message Bus version 10.0.   | [More details](#change-history) 
| 4.0.0 | Jun 28, 2019 | >=1.10 | >=3.1.2      | netcool-probe-messagebus:9.0.9.2-amd64      | Support for ICP with OpenShift. New probe image based on UBI.   | Several changes [More details](#change-history)                                                                                                               |
| 3.0.0 | Feb 28, 2019 | >=1.11.1 | >=3.1.0      | netcool-probe-messagebus:9.0.9      | Prerequisite update           | Several changes [More details](#change-history)                                                                                                                                                                                      |
| 2.0.1 | Oct 11, 2018 | >=1.9.1 | >=2.1.0.2    | netcool-probe-messagebus:8.0        | None                           | Several changes [More details](#changes-in-version-201)                                                                                                                                                                                      |
| 2.0.0 | Aug 9, 2018  | >=1.9.1 | >=2.1.0.2    | netcool-probe-messagebus:8.0        | Prerequisite and image update | Several enhancements [More details](#changes-in-version-200)                                                                                                                                                                                 |
| 1.0.0 | May 4, 2018  | >=1.8.3 | >=2.1.0.1    | netcool-probe-messagebus:7.0        | None                           | New chart release with latest probe docker image for production environment use. This version is licensed under the IBM Program License Agreement and can be downloaded from IBM Passport Advantage. [More details](#changes-in-version-100) |
| 0.2.0 | Apr 24, 2018 |  >=1.7.3 | >=2.1.0      | ibmcom/netcool-probe-messagebus:7.0 | Image update                   | New chart release with latest probe docker image. [More details](#changes-in-version-020)                                                                                                                                                    |
| 0.1.2 | Apr 24, 2018 |  >=1.7.3 | >=2.1.0      | ibmcom/netcool-probe-messagebus:6.1 | Deprecate public beta chart    | Deprecate public beta chart.                                                                                                                                                                                                                 |
| 0.1.1 | Mar 25, 2018 | >=1.7.3 | >=2.1.0      | ibmcom/netcool-probe-messagebus:6.1 | None                           | Initial Release                                                                                                                                                                                                                              |

## Change History

### Changes in Version 4.1.0

Refer to the "What’s new" [section](#enhancements) above for more details.

### Changes in Version 4.0.0

#### Breaking Changes

1. Probe image updates to support IBM Cloud Private on Red Hat Openshift Container Platform. The probe image has been updated with Red Hat Universal Base Image (UBI) as the base image with a new tag convention and the tag now has a `amd64` suffix. A new utility image "netcool-integration-util" is used for helm tests which is also based on UBI base image. International Program License Agreement ("IPLA") file in probe images updated to L/N: L-PPAN-BBRHJW.

#### Fixes

1. Corrected `logstashProbe.replicaCount` and `prometheusProbe.replicaCount` paramater UI metadata setting. These are now made optional on the ICP UI because Horizontal Pod Autoscaling is enabled by default and the minimum replica count settings will be used. The `logstashProbe.replicaCount` and `prometheusProbe.replicaCount` are used when Horizontal Pod Autoscaling is disabled.

#### Enhancements

1.   Update chart description to "IBM Netcool/OMNIbus Probe Cloud Monitoring Integration" (formerly "IBM Netcool Probe for Kubernetes") in chart documentation.
2.   New integration with IBM Cloud Event Management ("CEM") on IBM Cloud Private. You can enable a probe to receive events from IBM CEM to monitor your cloud native applications in Netcool Operations Insight. Additional fields is required in the `alerts.status` table to support this integration. Refer to chart's README for steps to configure the Object Server and IBM CEM. 
3.   Support for secured connection using SSL with or without authentication with your Netcool/OMNIbus Object Server. Refer to the README for more details and the requirements to enable secured communications with the Object Server.
4.   Starting from IBM Cloud Private 3.1.2, you can use a Custom Resource Definition (CRD) to apply Prometheus Alert Manager rules. The guide in the README is updated to show a sample `AlertRule` CRD which you can use to create new rules and apply them in the Alert Manager.
5.   Support for deployment on IBM Cloud Private with OpenShift. The probe image has been updated with Red Hat Universal Base Image (UBI) as the base image with a new tag convention and the tag now has a `amd64` suffix. A new utility image "netcool-integration-util" is used for helm tests which is also based on UBI base image. International Program License Agreement ("IPLA") file in probe images updated to L/N: L-PPAN-BBRHJW.
6.   Chart International Program License Agreement ("IPLA") file updated to L/N: L-PPAN-BBRHJW.
7.   The helm chart will now deploy using a custom service account to apply the required privileges instead of sharing the default namespace service account. You may configure the chart to use an existing service account configured by your Cluster Administrator by setting the `global.serviceAccountName` parameter. If the  `global.serviceAccountName` parameter is unset, a new service account is automatically created during deployment and will be removed together with the Helm release. You may also need to specify the `global.image.secretName` parameter with the image pull secret name if you are using a private image repository.
8.   The `image.pullPolicy` default value has been changed to `Always` (previously `IfNotPresent`). This is to ensure that each Pod uses an updated image of the same tag to improve security which may include library updates or security patches in any of the image layers.
9.   Probe heartbeat interval increased to 60 seconds to reduce log messages generated by frequent heartbeat checks.


### Changes in Version 3.0.0

#### Breaking Changes

-   Prerequisite updates
    -   Kubernetes version increased to 1.11.1.
    -   Tiller version increased to 2.9.1.
    -   Prometheus version increased 2.3.1.
    -   Prometheus Alert Manager version increased 0.15.0.
-   New PodSecurityPolicy requirement added as prerequisite. This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. You can choose either a namespace bound with a predefined PodSecurityPolicy (`ibm-restricted-psp`) or have your cluster administrator create a custom PodSecurityPolicy for you. Please see README for more details.
-   Tivoli Netcool/OMNIbus Message Bus Probe image upgraded to 9.0 from 8.0. Default `image.tag` updated to `9.0.9` from `8.0`. This version includes:
    - Tivoli Netcool/OMNIbus 8.1.0 Fix Pack 18 libraries.
    - Probe dependency libraries upgrade.
        - Common Transformer Module upgraded to version 9.0 from 8.0.
        - Common Transport Module upgraded to version 20.0 from 19.0.
    -    Ubuntu 16.04 Operating System patch (ubuntu:xenial-20190122).
    -    This image runs the probe process as a non-root user for improved security.
    -    License file updated. Changed to L/N: L-PKEY-B8JMCA license (previously L/N: L-TKAI-B33FE5).
-   Combined `image.repository` and `image.name` parameters into `image.repository` so that the `cloudctl` command line tool is able to update the repository prefix accordingly when loading the PPA package. This `image.repository` parameter is now a mandatory parameter.
-   Pod Disruption Budget is now disabled by default `poddisruptionbudget.enabled=false` to allow Operators to install this chart. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control.
-   This helm chart has been updated to use the new standard Kubernetes labels for the chart-defined resources. As a result of this change, this helm chart cannot be upgraded from version 2.0.3 or earlier and must be installed using a new installation. Future versions of this helm chart will be 
able to support upgrade installations.
-    Below is a summary of the changes to the chart-defined resources:

| Old Label        | New Label           |
| ------------- |:-------------:|
| app      | app.kubernetes.io/name |
| chart      | helm.sh/chart      |
| component | app.kubernetes.io/component      |
| heritage | app.kubernetes.io/managed-by      |
| productVersion | app.kubernetes.io/version      |
| release | app.kubernetes.io/instance      |

#### Fixes

-   Updated Prometheus probe's helm test uses the same image as Logstash probe to send HTTP GET request.
-   Added `kubeVersion` attribute in Chart.yaml file.
-   Fixed the sample command in Notes section when using ClusterIP service type.
-   Internal improvements:
    -   Updated internal IBM Shared Configuration Helper sub-chart to version 1.2.6.
    -   Internal improvements on ICP UI chart configuration page.
    -   Corrected the `probe.messageLevel` metadata to make it configurable via UI.
    -   Helper functions now have unique names to avoid potential conflict.
    -   Corrected UI tooltip description for `logstashProbe.autoscaling.cpuUtil` and `prometheusProbe.autoscaling.cpuUtil` to indicate that these parameters expect a number for target average CPU utilization (represented as a percentage of requested CPU) over all the pods instead of number of pods.

#### Enhancements

-   Packaging updated to follow CloudPak structure.
-   Changed the default internal port to `4080` from privileged port `80`.
-   Added [Pod Security Policy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) (`securityContext`) attributes into Deployment specification to specify required settings for Pod Isolation.
-   Updated the `image.testRepository` default value to also include the test image name (busybox).
-   Introduce new `image.testImageTag` parameter (defaults to `1.28.4` for busybox) to configure the test image if necessary.
-   Set `netcool.primaryServer`, `netcool.primaryHost` and `netcool.primaryPort` default values to `nil` so that the UI highlights that these parameters require user input.
-   Ingress hostname is updated with the Helm release name as a prefix to ensure uniqueness of the ingress virtual hostname to avoid potential conflicts when more than one release is installed with the same ingress virtual hostname if ingress is enabled. For example, if the `logstashProbe.ingress.hosts` or `prometheusProbe.ingress.hosts` is set to `- netcool-probe-logstash.local` and `- netcool-probe-prometheus.local` respectively, and the release name is `my-probe`, the actual host will be `my-probe.netcool-probe-logstash.local` for Logstash probe and `my-probe.netcool-probe-prometheus.local` for the Prometheus probe.
-   Sample Prometheus alert rules in README file is updated to use the metrics provided by Prometheus 2.3.1.


### Changes in Version 2.0.1

#### Fixes

-   Add missing Apache 2.0 License.
-   Minor correction to Ingress template indentation.

### Changes in Version 2.0.0

Pre-requisites updates. More details in [pre-requisites](#prerequisites).

-   Minimum Kubernetes version required is 1.9 and Tiller 2.7.2.

#### Enhancements

-   Chart code re-factorization. The `image.repository` parameter does not include the image name. A new `image.name` parameter is introduced and fixed to `netcool-probe-messagebus`. The `image.repository` value is a common value which is used to pull the probe image as well as `busybox` for helm test.
-   Rules files and probe configurations are now split into a separate configmap so that it is easier to customize the rules files.
-   Resource names are updated to be consistent for all resource types. This is related to the use of SCH as part of internal improvements.
-   Message Bus probe default image upgraded to version 8.0.
    -   Internal improvements in Message Bus 8.0 Webhook transport.
    -   Fixed: Message Bus 8.0 fixes an issue when a payload larger than 1kB causes an error to be logged.
-   Default probe service type is now set to `ClusterIP` from `NodePort` to conform to best practices and reduce security concerns.
-   Helm upgrade with a change in the probe configmap will trigger a rolling update.
-   License number updated to L-TKAI-B33FE5 (previously L-TKAI-AX9BWA).

#### Internal improvements

-   Implement helper functions using Shared Configurable Helper v1.2.1 sub-chart.

### Changes in Version 1.0.0

#### Enhancements

-   New chart release with latest probe docker image for production environment use. This version is licensed under the IBM Program License Agreement.
-   Changed `image.pullSecret` parameter to `global.image.secretName` to allow chart being used as sub-chart.

### Changes in Version 0.2.0

#### Enhancements

-   Upgraded chart to run with `netcool-probe-messagebus:7.0` docker image.
-   Support for Pod Disruption Budget and Pod Anti-Affinity to ensure high availability.
-   Prometheus probe rules file enhanced to support alerts which contain pod and container labels.
-   Added sample Prometheus alert rules for Prometheus 1.8 and 2.0 in README file.
-   New optional `image.pullSecret` configuration parameter to specify a Secret with a Docker Config.

### Changes in Version 0.1.2

Deprecate beta chart version. New version v1.0.0 will be made available through IBM Passport Advantage.

## Documentation

-   IBM Tivoli Netcool/OMNIBus Probe for Kubernetes Helm Chart Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/kubernetes/wip/concept/kub_intro.html)
-   Obtaining the IBM Tivoli Netcool/OMNIBus Probe for Kubernetes Helm Chart (Commercial Edition) [page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/common/topicref/hlm_obtaining_ppa_package.html)
