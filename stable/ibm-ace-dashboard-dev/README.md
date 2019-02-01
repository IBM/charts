# IBM APP CONNECT ENTERPRISE

![ACE Logo](https://raw.githubusercontent.com/ot4i/ace-helm/master/appconnect_enterprise_logo.svg?sanitize=true)

**Only one Dashboard can be installed per namespace**

**Important:** If using a private Docker registry (including an ICP Docker registry), an image pull secret needs to be created before installing the chart.

## Introduction

IBM® App Connect Enterprise is a market-leading lightweight enterprise integration engine that offers a fast, simple way for systems and applications to communicate with each other. As a result, it can help you achieve business value, reduce IT complexity and save money. IBM App Connect Enterprise supports a range of integration choices, skills and interfaces to optimize the value of existing technology investments.

## Chart Details

This chart deploys a single IBM App Connect Enterprise Dashboard into a Kubernetes environment. The dashboard provides a UI to manage and create new Integration Servers and upload BAR files.

## Prerequisites

* Kubernetes 1.9 or greater, with beta APIs enabled
* A user with cluster administrator role is required to install the chart
* If persistence is enabled (see [configuration](#configuration)), then you either need to create a Persistent Volume, or specify a Storage Class if classes are defined in your cluster.

## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* ICPv3.1 - Predefined  PodSecurityPolicy name: [`privileged`](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/manage_cluster/enable_pod_security.html)
* Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-ace-psp
spec:
  allowPrivilegeEscalation: true
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
  - MKNOD
  allowedCapabilities:
  - SETPCAP
  - AUDIT_WRITE
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - FSETID
  - KILL
  - SETUID
  - SETGID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETFCAP
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - persistentVolumeClaim
  forbiddenSysctls:
  - '*'
```

## Installing the Chart

**Only one Dashboard can be installed per namespace**

**Important:** If using a private Docker registry (including an ICP Docker registry), an image pull secret needs to be created before installing the chart. Supply the name of the secret as the value for `image.pullSecret`.

To install the chart with the release name `ace-demo-ingress`:

```
helm install --name ace-demo-ingress ibm-ace-dashboard-dev --tls
```

The ACE Dashboard can then be accessed via a web browser. Follow the instructions at the end of the installation to obtain the dashboard URL.

> **Tip**: See all the resources deployed by the chart using `kubectl get all -l release=ace-demo-ingress`

## Uninstalling the Chart

To uninstall/delete the `ace-demo-ingress` release:

```
helm delete ace-demo-ingress --tls
```

The command removes all the Kubernetes components associated with the chart.

## Configuration
The following table lists the configurable parameters of the `ibm-ace-dashboard-dev` chart and their default values.

| Parameter                                 | Description                                     | Default                                                    |
| ----------------------------------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| `image.tag`                               | Image tag                                       | `11.0.0.3`                                                 |
| `image.pullPolicy`                        | Image pull policy                               | `IfNotPresent`                                             |
| `image.pullSecret`                        | Image pull secret, if you are using a private Docker registry | `nil`                                        |
| `arch`                                    | Architecture scheduling preference for worker node (only amd64 supported) - readonly | `amd64`               |
| `fsGroupGid`                              | File system group ID for volumes that support ownership management | `nil`                                   |
| `tls.hostname`                        | The hostname of the ingress proxy that has to be configured in the ingress definition  | `nil`               |
| `tls.generate`                         | Specifies whether to create ingress proxy SSL certs using the ICP CA and save it in the secret named in `tls.secret` | true|  
| `tls.secret`                   | Specifies the secret name for the certificate that has to be used in the Ingress definition. If generate is false this is the secret that contains the user provided certs | `ibm-ace-dashboard-prod-tls-secret`   |
| `contentServer.resources.limits.cpu`      | Kubernetes CPU limit for the dashboard content server container | `1`                                        |
| `contentServer.resources.limits.memory`   | Kubernetes memory limit for the dashboard content server container | `1024Mi`                                |
| `contentServer.resources.requests.cpu`    | Kubernetes CPU request for the dashboard content server container | `100m`                                   |
| `contentServer.resources.requests.memory` | Kubernetes memory request for the dashboard content server container | `256Mi`                               |
| `controlUI.resources.limits.cpu`          | Kubernetes CPU limit for the dashboard UI container | `1`                                                    |
| `controlUI.resources.limits.memory`       | Kubernetes memory limit for the dashboard UI container | `1024Mi`                                            |
| `controlUI.resources.requests.cpu`        | Kubernetes CPU request for the dashboard UI container | `100m`                                               |
| `controlUI.resources.requests.memory`     | Kubernetes memory request for the dashboard UI container | `256Mi`                                           |
| `persistence.enabled`                     | Use persistent storage for IBM ACE Dashboard - IBM ACE Dashboard requires persistent storage to function correctly | `true` |
| `persistence.existingClaimName`           | Name of an existing PVC to be used with IBM ACE Dashboard - should be left blank if you use Dynamic Provisioning or if you want IBM ACE Dashboard to make its own PVC | `nil` |
| `persistence.useDynamicProvisioning`      | Use Dynamic Provisioning - `existingClaimName` must be left blank to use Dynamic Provisioning | `true`       |
| `persistence.size`                        | Storage size of persistent storage to provision | `5Gi`                                                      |
| `persistence.storageClassName`            | Storage class name - if blank will use the default storage class | `nil`                                     |
| `log.format`                              | Output log format on container's console. Either `json` or `basic` | `json`                                  |
| `replicaCount`                            | Set how many replicas of the dashboard pod to run | `3`                                                      |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

> **Tip**: You can use the default [values.yaml](values.yaml)

## Storage
IBM ACE Dashboard requires a persistent volume to store runtime artefacts used by an IBM ACE Server. The default size of the persistent volume claim is 5Gi. Configure the size with the `persistence.size` option to scale with the number and size of runtime artefacts that are expected to be uploaded to IBM ACE Dashboard.

The persistent volume claim must have an access mode of ReadWriteMany (RWX), and must not use "hostPath" or "local" volumes.

For volumes that support onwership management, specify the group ID of the group owning the persistent volumes' file systems using the `fsGroupGid` parameter.

## Resources Required

This chart has the following resource requirements per pod by default:

- 200m CPU core
- 512 Mi memory

See the [configuration](#configuration) section for how to configure these values.

## Logging

The `log.format` value controls whether the format of the output logs is:
- basic: Human readable format intended for use in development, such as when viewing through `kubectl logs`
- json: Provides more detailed information for viewing through Kibana

## Limitations

This Chart can run only on amd64 architecture type.

The dashboard is not supported on Safari 12 running on macOS 10.14 (Mojave) or iOS 12.

## Useful Links

[View the IBM App Connect Enterprise Dockerfile repository on Github](https://github.com/ot4i/ace-docker)

[View the Official IBM App Connect Enterprise for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/ace/)

[View the Official IBM App Connect Enterprise Dashboard for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/ace-dashboard/)

[Learn more about IBM App Connect Enterprise](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.ace.home.doc/help_home.htm)

[Learn more about IBM App Connect Enterprise and Docker](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bz91300_.htm)

[Learn more about IBM App Connect Enterprise and Lightweight Integration](https://ibm.biz/LightweightIntegrationLinks)

_Copyright IBM Corporation 2018. All Rights Reserved._

_The IBM App Connect Enterprise logo is copyright IBM. You will not use the IBM App Connect Enterprise logo in any way that would diminish the IBM or IBM App Connect Enterprise image. IBM reserves the right to end your privilege to use the logo at any time in the future at our sole discretion. Any use of the IBM App Connect Enterprise logo affirms that you agree to adhere to these conditions._
