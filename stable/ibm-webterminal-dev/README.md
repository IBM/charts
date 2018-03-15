# Web Terminal

[xterm.js](https://github.com/xtermjs/xterm.js) is a web-based, full-featured terminal that allows command line access to your cluster.

## Introduction

The web terminal offers quick access to command line tools such as `kubectl`, `helm`, and `calicoctl`. Using these tools, you can easily administer your cluster and applications.
Version [2.8.1](https://github.com/xtermjs/xterm.js/releases/tag/2.8.1) of xterm.js is used.

## Prerequisites

- Kubernetes 1.5+ with Beta APIs enabled

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/ibm-webterminal-dev
```

The command deploys `ibm-webterminal` on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions additional commands required for clean-up.

## Configuration
The following tables lists the configurable parameters of the `ibm-webterminal` chart and their default values.

| Parameter                        | Description                                           | Default                                                   |
| -------------------------------- | ----------------------------------------------------- | --------------------------------------------------------- |
| `arch.amd64`                     | Preference to run on amd64 architecture               | `2 - No preference`                                       |
| `arch.ppc64le`                   | Preference to run on ppc64le architecture             | `2 - No preference`                                       |
| `image.repository`               | `web-terminal` image repository                       | `ibmcom/web-terminal`                                     |
| `image.tag`                      | `web-terminal` image tag                              | `2.8.1-r1`                                                |
| `image.pullPolicy`               | Image pull policy                                     | `Always` if `imageTag` is `latest`, else `IfNotPresent`   |
| `credentials.username`           | The username to access the terminal                   | `admin`                                                   |
| `credentials.password`           | The password to secure access to the terminal         | `admin`                                                   |
| `calicoctl.enabled`              | Configure `calicoctl` for use from the terminal       | `false`                                                   |
| `service.type`                   | k8s service type exposing ports, e.g. `NodePort`      | `NodePort`                                                |
| `service.externalPort`           | k8s service external port                             | `3000`                                                    |
| `nodeSelector`                   | Node labels for pod assignment                        | `""`                                                      |
| `resources.requests.memory`      | Memory resource requests                              | `200Mi`                                                   |
| `resources.requests.cpu`         | CPU resource requests                                 | `100m`                                                    |
| `resources.limits.memory`        | Memory resource limits                                | `200Mi`                                                   |
| `resources.limits.cpu`           | CPU resource limits                                   | `100m`                                                    |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default [values.yaml](values.yaml)