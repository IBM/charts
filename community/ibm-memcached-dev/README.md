# Memcached

> [Memcached](https://memcached.org/) is an in-memory key-value store for small chunks of arbitrary data (strings, objects) from results of database calls, API calls, or page rendering.

The original work for this helm chart is present @ [kubernetes Charts](https://github.com/kubernetes/charts/tree/master/stable/memcached) Based on the [memcached](https://github.com/bitnami/charts/tree/master/incubator/memcached) chart from the [Bitnami Charts](https://github.com/bitnami/charts) repository.

```bash
$ helm install stable/ibm-memcached-dev
```
## Resources Required
The chart deploys pods consuming minimum resources. 

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Introduction

This chart bootstraps a [Memcached](https://hub.docker.com/_/memcached/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Chart Details
This chart bootstraps a [Memcached](https://hub.docker.com/_/memcached/) deployment on a [Kubernetes](http://kubernetes.io) cluster

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/ibm-memcached-dev
```

The command deploys Memcached on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.
## Prerequisites

- Kubernetes 1.7+ 
- Tiller 2.7.2 or later

## Installing the Chart

To install the chart

```shell
helm install --name <release-name> stable/ibm-memcached-dev
```
## Verifying the Chart

See NOTES.txt associated with this chart for verification instructions.

## Uninstalling the Chart

To uninstall/delete the deployment:

```shell
helm delete --purge <release-name>
```

## Limitations

## Configuration

The following table lists the configurable parameters of the Memcached chart and their default values.

|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `image`                   | The image to pull and run       | default ex. memcached:1.5.11-alpine                      |
| `imagePullPolicy`         | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `memcached.verbosity`     | Verbosity level (v, vv, or vvv) | Un-set.                                                 |
| `memcached.maxItemMemory` | Max memory for items (in MB)    | `64`                                                    |

The above parameters map to `memcached` params. For more information please refer to the [Memcached documentation](https://github.com/memcached/memcached/wiki/ConfiguringServer).

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set memcached.verbosity=v \
    stable/ibm-memcached-dev
```

The above command sets the Memcached verbosity to `v`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/ibm-memcached-dev
```

> **Tip**: You can use the default `values.yaml`

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart] ( https://github.com/ppc64le/charts/issues )

[Submit issue to Memcached docker image]  ( https://hub.docker.com/_/memcached )

[Submit issue to Memcached open source community] ( https://github.com/memcached/memcached/issues )

[ICP Support] ( https://ibm.biz/icpsupport )

## Note (Cluster Image Security)
As container image security feature is enabled, create an image policy for a namespace with the following rule for the chart to be deployed in the `default` namespace:

```console
apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
kind: ImagePolicy
metadata:
  name: helm-chart
  namespace: default
spec:
  repositories:
  - name: docker.io/memcached:1.5.11-alpine
    policy:
      va:
        enabled: false
```
