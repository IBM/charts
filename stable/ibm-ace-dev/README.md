# IBM APP CONNECT ENTERPRISE

![ACE Logo](https://raw.githubusercontent.com/ot4i/ace-helm/master/appconnect_enterprise_logo.svg?sanitize=true)

## Introduction

IBM® App Connect Enterprise is a market-leading lightweight enterprise integration engine that offers a fast, simple way for systems and applications to communicate with each other. As a result, it can help you achieve business value, reduce IT complexity and save money. IBM App Connect Enterprise supports a range of integration choices, skills and interfaces to optimize the value of existing technology investments. 

## Chart Details

This chart deploys a single IBM App Connect Enterprise for Developers integration server into a Kubernetes environment.

## Prerequisites

No prerequisites

## Installing the Chart

To install the chart with the release name `rel1`:

```
helm install --name rel1 ibm-ace-dev --set license=accept
```

This command accepts the [IBM App Connect Enterprise for Developers license](LICENSE) and deploys an IBM App Connect Enterprise for Developers server on the Kubernetes cluster. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: See all the resources deployed by the chart using `kubectl get all -l release=rel1`

## Uninstalling the Chart

To uninstall/delete the `rel1` release:

```
helm delete rel1
```

The command removes all the Kubernetes components associated with the chart.

## Configuration
The following table lists the configurable parameters of the `ibm-ace-dev` chart and their default values.

| Parameter                        | Description                                     | Default                                                    |
| -------------------------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| `license`                        | Set to `accept` to accept the terms of the IBM license  | `Not accepted`                                     |
| `image.repository`               | Image full name including repository            | `ibmcom/ace`                                                |
| `image.tag`                      | Image tag                                       | `11.0.0.0`                                                        |
| `image.pullPolicy`               | Image pull policy                               | `IfNotPresent`                                             |
| `image.pullSecret`               | Image pull secret, if you are using a private Docker registry | `nil`                                        |
| `service.type`                   | Kubernetes service type exposing ports       | `NodePort`                                  |
| `resources.limits.cpu`          | Kubernetes CPU limit for the Queue Manager container | `2`                                                   |
| `resources.limits.memory`       | Kubernetes memory limit for the Queue Manager container | `2048Mi`                                              |
| `resources.requests.cpu`        | Kubernetes CPU request for the Queue Manager container | `1`                                                 |
| `resources.requests.memory`     | Kubernetes memory request for the Queue Manager container | `512Mi`                                            |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

> **Tip**: You can use the default [values.yaml](values.yaml)

## Resources Required

This chart uses the following resources by default:

- 1 CPU core
- 0.5 Gi memory

See the [configuration](#configuration) section for how to configure these values.

## Limitations

This Chart can run only on amd64 architecture type.

## Useful Links

[View the IBM App Connect Enterprise Dockerfile repository on Github](https://github.com/ot4i/ace-docker)

[View the Official IBM App Connect Enterprise for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/ace/)

[Learn more about IBM App Connect Enterprise](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.ace.home.doc/help_home.htm)

[Learn more about IBM App Connect Enterprise and Docker](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bz91300_.htm)

[Learn more about IBM App Connect Enterprise and Lightweight Integration](https://ibm.biz/LightweightIntegrationLinks)

_Copyright IBM Corporation 2018. All Rights Reserved._

_The IBM App Connect Enterprise logo is copyright IBM. You will not use the IBM App Connect Enterprise logo in any way that would diminish the IBM or IBM App Connect Enterprise image. IBM reserves the right to end your privilege to use the logo at any time in the future at our sole discretion. Any use of the IBM Integration Bus logo affirms that you agree to adhere to these conditions._
