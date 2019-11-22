# What's new in IBM Tivoli Netcool/OMNIbus Message Bus Probe for Webhook Integration Version 2.0.0

## Breaking Changes

-   Prerequisite updates:

    -   Kubernetes version increased to 1.11.1.
    -   Tiller version increased to 2.9.1.

- New PodSecurityPolicy requirement added as prerequisite. This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. You can choose either a namespace bound with a predefined PodSecurityPolicy (`ibm-restricted-psp`) or have your cluster administrator create a custom PodSecurityPolicy for you. Please see README for more details.
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

-   Packaging updated to follow CloudPak structure.
-   Added [Pod Security Policy](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) (`securityContext`) attributes into Deployment specification to specify required settings for Pod Isolation.
-   Requires predefined PodSecurityPolicy name: `ibm-restricted-psp` for ICP 3.1.x.
-   Introduce new `image.testRepository` parameter and default value is set test image name (busybox). Configure this parameter to pull the image from a private image registry.
-   Introduce new `image.testImageTag` parameter (defaults to `1.28.4` for busybox) to configure the test image if necessary.
-   Include `nginx.ingress.kubernetes.io` annotation along with `ingress.kubernetes.io` to support Kubernetes recent changes on the default annotation prefix.
-   Update default `image.tag` parameter to `9.0.9` from `8.0.29`.
-   Metering annotation `productVersion` and application version attribute in Chart.yaml (`appVersion`) updated to `9.0` from `8.0.29`.
-   Update Secret type to `kubernetes.io/tls` type instead of `Opaque` of the generated TLS secret resource created by the chart.
-   Deployment template now uses `apps/v1` API version.

## Fixes

-   Internal improvements:
    -   Content verification linter fixes.
    -   Helper functions now have unique names to avoid potential conflict.
    -   Corrected UI tooltip description for `autoscaling.cpuUtil` and `autoscaling.cpuUtil` to indicate that these parameters expect a number for target average CPU utilization (represented as a percentage of requested CPU) over all the pods instead of number of pods.
-   Added PodSecurityPolicy requirement in README.
-   Added `kubeVersion` attribute in Chart.yaml.
-   Updated internal IBM Shared Configuration Helper sub-chart to version 1.2.6.
-   Fixed issue where Notes section fails to render when ingress is disabled and service type is set to `NodePort`.
-   Fixed the sample command in Notes section when using ClusterIP service type.


## Prerequisites

1.  Kubernetes 1.11.1.
2.  Tiller 2.9.1.

## Documentation

-   IBM Tivoli Netcool/OMNIbus Probe for Message Bus Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/message_bus/wip/concept/messbuspr_intro.html)

## Version History

| Chart | Date         | Kubernetes Required | Image(s) Supported              | Breaking Changes     | Details                             |
| ----- | ------------ | ------------------- | ------------------------------- | -------------------- | ----------------------------------- |
| 2.0.0 | Feb 28, 2019 | >=1.11.1            | netcool-probe-messagebus:9.0.9  | Pre-requisite update | See details in [What's New section](#breaking-changes) above. |
| 1.0.0 | Oct 11, 2018 | >=1.9.1             | netcool-probe-messagebus:8.0.29 | None                 | Initial Version                     |

## Change History

### Changes in Version 2.0.0

Refer to "What's New" [section](#breaking-changes) above for details.

### Changes in Version 1.0.0

Initial version for production use.
