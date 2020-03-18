# IBM APP CONNECT ENTERPRISE

![IBM App Connect Enterprise Logo](https://raw.githubusercontent.com/ot4i/ace-docker/master/app_connect_light_256x256.png)

**Important:**
* Only one dashboard can be installed per namespace.
* If using a private Docker registry, an image pull secret needs to be created before installing the chart.

## Introduction

IBM® App Connect Enterprise is a market-leading lightweight enterprise integration engine that offers a fast, simple way for systems and applications to communicate with each other. As a result, it can help you achieve business value, reduce IT complexity and save money. IBM App Connect Enterprise supports a range of integration choices, skills and interfaces to optimize the value of existing technology investments.

## Chart Details

This chart deploys a single IBM App Connect Enterprise dashboard into a Kubernetes environment. The dashboard provides a UI to manage and create new integration servers and upload BAR files.

## Prerequisites

* Kubernetes 1.11.0 or later, with beta APIs enabled.
* A user with cluster administrator role is required to install the chart.
* If persistence is enabled (see [configuration](#configuration)):
  * You must either create a persistent volume, or specify a storage class if classes are defined in your cluster.
  * The storage class must support read-write-many

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart. If your target namespace is not bound to this SecurityContextConstraints resource you can bind it with the following command:

`oc adm policy add-scc-to-group ibm-anyuid-scc system:serviceaccounts:<namespace>` For example, for release into the `default` namespace:
```code
oc adm policy add-scc-to-group ibm-anyuid-scc system:serviceaccounts:default
```

### Custom SecurityContextConstraints definition:

```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-ace-scc
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
fsGroup:
  type: RunAsAny
spec:
  allowPrivilegeEscalation: true
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

Only one dashboard can be installed per namespace.

**Important:** If using a private Docker registry, an image pull secret needs to be created before installing the chart. Supply the name of the secret as the value for `image.pullSecret`.

To install the chart with the release name `dashboard`:

```
helm install --name dashboard ibm-ace-dashboard-icp4i-prod --tls --set license=accept --set tls.hostname=$(kubectl get configmap -n kube-public ibmcloud-cluster-info -o jsonpath="{.data.proxy_address}")
```

## Verifying the Chart

See the instructions (from NOTES.txt, packaged with the chart) after the helm installation completes for chart verification. The instructions can also be viewed by running the command:
```
helm status dashboard --tls.
```

## Uninstalling the Chart

To uninstall/delete the `dashboard` release:

```
helm delete dashboard --purge --tls
```

The command removes all the Kubernetes components associated with the chart.

## Configuration
The following table lists the configurable parameters of the `ibm-ace-dashboard-icp4i-prod` chart and their default values.

| Parameter                                 | Description                                     | Default                                                    |
| ----------------------------------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| `image.contentServer`                     | Content server Docker image                     | `cp.icr.io/cp/icp4i/ace/ibm-ace-content-server-prod:11.0.0.6.1`                   |
| `image.controlUI`                         | Control UI Docker image                         | `cp.icr.io/cp/icp4i/ace/ibm-ace-dashboard-prod:11.0.0.6.1`                       |
| `image.configurator`                      | Configurator Docker image                       | `cp.icr.io/cp/icp4i/ace/ibm-ace-icp-configurator-prod:11.0.0.6.1`                 |
| `image.pullPolicy`                        | Image pull policy.                               | `IfNotPresent`                                             |
| `image.pullSecret`                        | Image pull secret, if you are using a private Docker registry. | `nil`                                        |
| `serverChartLocation`                     | The repository location that the charts were imported into. | `ibm-entitled-charts`          |
| `arch`                                    | Architecture scheduling preference for worker node (only amd64 supported) - readonly. | `amd64`               |
| `security.fsGroupGid`                     | File system group ID for volumes that support ownership management. | `nil`                                   |
| `security.initVolumeAsRoot`               | Whether or not storage provider requires root permissions to initialize. | `true` 
| `tls.hostname`                            | The hostname of the ingress proxy that has to be configured in the ingress definition.  If left empty this will default to the common services `proxy_address` value | `nil`               |
| `tls.secret`                              | Specifies the name of the secret for the certificate to be used in the Ingress definition. If not supplied the default ingress cert will be used. | `nil`   |
| `contentServer.resources.limits.cpu`      | Kubernetes CPU limit for the dashboard content server container. | `1`                                        |
| `contentServer.resources.limits.memory`   | Kubernetes memory limit for the dashboard content server container. | `1024Mi`                                |
| `contentServer.resources.requests.cpu`    | Kubernetes CPU request for the dashboard content server container. | `100m`                                   |
| `contentServer.resources.requests.memory` | Kubernetes memory request for the dashboard content server container. | `256Mi`                               |
| `controlUI.resources.limits.cpu`          | Kubernetes CPU limit for the dashboard UI container. | `1`                                                    |
| `controlUI.resources.limits.memory`       | Kubernetes memory limit for the dashboard UI container. | `1024Mi`                                            |
| `controlUI.resources.requests.cpu`        | Kubernetes CPU request for the dashboard UI container. | `100m`                                               |
| `controlUI.resources.requests.memory`     | Kubernetes memory request for the dashboard UI container. | `256Mi`                                           |
| `persistence.enabled`                     | Use persistent storage for IBM App Connect Enterprise dashboard - IBM App Connect Enterprise dashboard requires persistent storage to function correctly. | `true` |
| `persistence.existingClaimName`           | Name of an existing PVC to be used with IBM App Connect Enterprise dashboard - should be left blank if you use dynamic provisioning or if you want IBM App Connect Enterprise dashboard to make its own PVC. | `nil` |
| `persistence.useDynamicProvisioning`      | Use Dynamic Provisioning - `existingClaimName` must be left blank to use Dynamic Provisioning. | `true`       |
| `persistence.size`                        | Storage size of persistent storage to provision. | `5Gi`                                                      |
| `persistence.storageClassName`            | Storage class name - if blank will use the default storage class. | `nil`                                     |
| `log.format`                              | Output log format on container's console. Either `json` or `basic`. | `json`                                  |
| `log.level`                              | Output log level on container's console. Either `info` or `debug`. | `info`                                  |
| `replicaCount`                            | How many replicas of the dashboard pod to run. | `3`                                                      |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Storage
The IBM App Connect Enterprise dashboard requires a persistent volume to store runtime artefacts used by an IBM App Connect Enterprise integration server. The default size of the persistent volume claim is 5Gi. Configure the size with the `persistence.size` option to scale with the number and size of runtime artefacts that are expected to be uploaded to IBM App Connect Enterprise dashboard.

The persistent volume claim must have an access mode of ReadWriteMany (RWX), and must not use "hostPath" or "local" volumes.

For volumes that support ownership management, specify the group ID of the group owning the persistent volumes' file systems using the `security.fsGroupGid` parameter.

## Resources Required

This chart has the following resource requirements per pod by default:

- 200m CPU core
- 512 Mi memory

See the [configuration](#configuration) section for how to configure these values.

## Logging

The `log.format` value controls whether the format of the output logs is:
- basic: Human-readable format intended for use in development, such as when viewing through `kubectl logs`
- json: Provides more detailed information for viewing through Kibana

## Limitations

The dashboard is not supported on Safari running on either macOS or iOS.

## Documentation

[View the IBM App Connect Enterprise Dockerfile repository on Github](https://github.com/ot4i/ace-docker)

[View the Official IBM App Connect Enterprise for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/ace/)

[View the Official IBM App Connect Enterprise dashboard for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/ace-dashboard/)

[Learn more about IBM App Connect Enterprise](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.ace.home.doc/help_home.htm)

[Learn more about IBM App Connect Enterprise and Docker](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bz91300_.htm)

[Learn more about IBM App Connect Enterprise and Lightweight Integration](https://ibm.biz/LightweightIntegrationLinks)
