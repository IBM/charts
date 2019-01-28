# Kibana

[kibana](https://github.com/elastic/kibana) is your window into the Elastic Stack. Specifically, it's an open source (Apache Licensed), browser-based analytics and search dashboard for Elasticsearch.

```console
$ helm install stable/ibm-kibana-dev
```
## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Chart Details
This chart bootstraps a kibana deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Introduction

This chart bootstraps a kibana deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Note 
The original work for this helm chart is present @ [Helm Charts Charts]( https://github.com/helm/charts) Based on the [kibana]( https://github.com/helm/charts/tree/master/stable/kibana) chart.

## Prerequisites
- Kubernetes 1.7+ 
- Tiller 2.7.2 or later
- Elasticsearch service must be running and path to it must be adding during configuration.

## Resources Required
The chart deploys pods consuming minimum resources as specified in the values.yaml file. 

## Installing the Chart

To install the chart with the release name `my-release`:

1. First have a running instance of the Elasticsearch Service,
```console
$ docker run -it -p 9200:9200 ibmcom/elasticsearch-ppc64le:5.6.10
```
2. Change the elasticsearchUrl entry in the values.yaml file to reflect the IP of the elasticsearch service
```
eg. http://1.2.3.4:9200
```

```console
$ helm install stable/ibm-kibana-dev --name my-release
```

The command deploys kibana on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the kibana chart and their default values.

Parameter | Description | Default
--- | --- | ---
`affinity` | node/pod affinities | None
`env` | Environment variables to configure Kibana | `{}`
`files` | Kibana configuration files (config properties can be set through the `env` parameter too). All the files listed under this variable will overwrite any existing files by the same name in kibana config directory. Files not mentioned under this variable will remain unaffected. | None
`image.pullPolicy` | Image pull policy | `IfNotPresent`
`image.repository` | Image repository | `ibmcom/kibana-ppc64le`
`image.tag` | Image tag | `5.5.1`
`image.pullSecrets` |Specify image pull secrets | `nil`
`commandline.args` | add additional commandline args | `nil`
`ingress.enabled` | Enables Ingress | `false`
`ingress.annotations` | Ingress annotations | None:
`ingress.hosts` | Ingress accepted hostnames | None:
`ingress.tls` | Ingress TLS configuration | None:
`nodeSelector` | node labels for pod assignment | `{}`
`podAnnotations` | annotations to add to each pod | `{}`
`replicaCount` | desired number of pods | `1`
`serviceAccountName` | serviceAccount that will run the pod | `nil`
`resources` | pod resource requests & limits | `{}`
`priorityClassName` | priorityClassName | `nil`
`service.externalPort` | external port for the service | `443`
`service.internalPort` | internal port for the service | `4180`
`service.externalIPs` | external IP addresses | None:
`service.loadBalancerIP` | Load Balancer IP address (to use with service.type LoadBalancer) | None:
`service.nodePort` | NodePort value if service.type is NodePort | None:
`service.type` | type of service | `ClusterIP`
`service.annotations` | Kubernetes service annotations | None:
`service.labels` | Kubernetes service labels | None:
`tolerations` | List of node taints to tolerate | `[]`
`elasticsearchUrl`| Add elasticsearch client IP.


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install stable/ibm-kibana-dev --name my-release \
  --set=image.tag=v0.0.2,resources.limits.cpu=200m
```

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install stable/ibm-kibana-dev --name my-release -f values.yaml
```

> **Tip**: You can use the default `values.yaml`

## Support

 The helm charts are provided "as-is" and without warranty of any kind.

 All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

 Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

 [Submit issue to Helm Chart] ( https://github.com/ppc64le/charts/issues )

 [Submit issue to Kibana docker image]  ( https://github.com/ppc64le/build-scripts/issues )

 [Submit issue to Kibana open source community] ( https://github.com/elastic/kibana/issues  )

 [ICP Support] ( https://ibm.biz/icpsupport )


## Limitations
