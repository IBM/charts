# RStudio

[RStudio](https://www.rstudio.com/products/rstudio/) RStudio is an integrated development environment (IDE) for R

```console
$ helm install stable/ibm-rstudio-dev
```
## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Prerequisites

- Kubernetes 1.7+ 
- Tiller 2.7.2 or later

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m)

## Introduction

This chart bootstraps a [RStudio](https://hub.docker.com/r/ppc64le/rstudio/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release stable/ibm-rstudio-dev
```

## Default Credentials
The default credentials for the Rstudio service are test/test

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Details
This chart bootstraps a [RStudio](https://hub.docker.com/r/ppc64le/rstudio/) deployment on a [Kubernetes](http://kubernetes.io) cluster


## Configuration

The following table lists the configurable parameters of the RStudio chart and their default values.

|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `image`                   | The image to pull and run       | `ppc64le/rstudio:0.99`                                  |
| `imagePullPolicy`         | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `node`                    | Specify what architecture Node  |  `ppc64le`                                              |


The above parameters map to `ibm-rstudio-dev` params.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/ibm-rstudio-dev
```

> **Tip**: You can use the default `values.yaml`

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart] ( https://github.com/ppc64le/charts/issues )

[Submit issue to RStudio docker image]  ( https://github.com/ppc64le/build-scripts/issues )

[Submit issue to RStudio open source community] ( https://github.com/rstudio/rstudio/issues )

[ICP Support] ( https://ibm.biz/icpsupport )

## Limitations

##NOTE

This chart is deployed in default cluster, either by disabling container image security feature of cluster or adding the following rule to your cluster image policy:
apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
kind: <ClusterImagePolicy Name>
metadata:
  name: ibmcloud-default-cluster-image-policy
spec:
   repositories:
    - name: "*"
      policy:
        trust:
          enabled: true

This chart is validated on ppc64le.
