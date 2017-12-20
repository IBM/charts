# Microservice Builder fabric for Kubernetes

## Introduction

This chart serves two purposes:

### 1. It runs a Job which creates the following kubernetes resources:
  - mb-keystore as a secret
  - mb-keystore-password as a secret
  - mb-truststore as a secret
  - mb-truststore-password as a secret
  - liberty-config as a configmap

These resources contain the server key and certificate that are used to provide secure connections between Liberty instances and other services.
For more information on how to use these resources, see [Using the Microservice Builder fabric](https://www.ibm.com/support/knowledgecenter/SS5PWC/fabric_task.html)  

### 2. It deploys Zipkin.
Zipkin is a distributed tracing system that collects and analyzes timing data of microservice applications.
For more information about Zipkin, see [Zipkin](http://zipkin.io/).

To access the Zipkin console, see [Configure Zipkin console access](https://www.ibm.com/support/knowledgecenter/SS5PWC/fabric_task.html)

## Installing the Chart

To install the chart with the release name `fabric`:

```bash
helm install --name fabric ibm-microservicebuilder-fabric
```

This command deploys a Microservice Builder fabric on the Kubernetes cluster. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: See all the resources deployed by the chart using `helm get manifest fabric`

## Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

## Uninstalling the Chart

To uninstall/delete the `fabric` release:

```bash
helm delete fabric --purge
```

The command removes all the Kubernetes components associated with the chart. The `--purge` option will allow you to re-deploy the chart with the same release name

## Configuration
The following table lists the configurable parameters of the `ibm-microservicebuilder-fabric` chart and their default values.


| Parameter | Description | Default |
| - | - | - |
| zipkin.collectorSampleRatePct | Proportion of traces for Zipkin to retain; between 0.0 (none) and 1.0 (all) | `1.0` |
| zipkin.elasticsearchHosts | A comma-separated list of Elasticsearch base URLs to provide persistence for Zipkin; defaults to in-memory storage if not set | `""` |
| zipkin.javaOpts | the Java options that are used for the Zipkin process | `"-Xmx512m"` |
| zipkin.replicaCount | the number of replica instances for the Zipkin deployment; this should only be increased above one if Elasticsearch is being used rather than in-memory storage | `1` |
| zipkin.service.name | the name that is used for the Kubernetes service fronting the Zipkin deployment | `"zipkin"` |
| zipkin.service.port | if zipkin.service.type is NodePort, the port to expose for the Zipkin Kubernetes service | `30411` |
| zipkin.service.type | the type of the Kubernetes service for Zipkin e.g. ClusterIP or NodePort; if using NodePort, note that there is no access control around the Zipkin endpoint and UI | `"ClusterIP"` |
| zipkin.image | image pulled for Zipkin | `"ibmcom/zipkin"` | 
| zipkin.imageTag | tag for Zipkin image | `"2.1.0"` |

For more information about Microservice Builder fabric, see [About the Microservices Builder fabric](https://www.ibm.com/support/knowledgecenter/en/SS5PWC/fabric_concept.html).
