# TOMEE

[TOMEE](http://tomee.apache.org/) The Embedded or Remote EE Application Server.

```console
$ helm install stable/ibm-tomee-dev
```

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Prerequisites

- Kubernetes 1.7+ 
- Tiller 2.7.2 or later

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m)

## Introduction

This chart bootstraps a [TOMEE](https://github.com/apache/tomee) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.


## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm intall --name my-release stable/ibm-tomee-dev
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Chart Details
This chart bootstraps a [TOMEE](https://hub.docker.com/r/ppc64le/tomee/) deployment on a [Kubernetes](http://kubernetes.io) cluster


## Configuration

The following table lists the configurable parameters of the Open Liberty chart and their default values.

|      Parameter            |          Description            |                         Default                         |
|---------------------------|---------------------------------|---------------------------------------------------------|
| `image`                   | The image to pull and run       |  default ex. tomee:8-jre-1.7.5-webprofile               |
| `imagePullPolicy`         | Image pull policy               | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `node`                    | Specify what architecture Node  | `amd64` or `ppc64le`                                    |


The above parameters map to `ibm-tomee-dev` params.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. 

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/ibm-tomee-dev
```


## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart] ( https://github.com/ppc64le/charts/issues )

[Submit issue to Tomee docker image]  ( https://github.com/ppc64le/build-scripts/issues )

[Submit issue to Tomee open source community] ( https://jira.apache.org/jira/projects/TOMEE/issues/TOMEE-2365?filter=allopenissues )



> **Tip**: You can use the default `values.yaml`

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
  - name: docker.io/tomee:8-jre-1.7.5-webprofile
    policy:
      va:
        enabled: false
```


## Limitations
##NOTE This chart has been validated on ppc64le.
