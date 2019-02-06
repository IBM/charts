# kube-state-metrics Helm Chart
## Introduction
The original work for this helm chart is present @ [Helm Charts Charts]( https://github.com/helm/charts) Based on the [kube-state-metrics]( https://github.com/helm/charts/tree/master/stable/kube-state-metrics) chart

## Chart Details
* Installs the [kube-state-metrics agent](https://github.com/kubernetes/kube-state-metrics).

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m)

## PodSecurityPolicy Requirements

## Prerequisites
- Kubernetes 1.7+ 
- Tiller 2.7.2 or later

## Limitations
## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install stable/ibm-kube-state-metrics-dev
```

## Configuration

| Parameter                             | Description                                             | Default                                     |
|---------------------------------------|---------------------------------------------------------|---------------------------------------------|
| `image.repository`                    | The image repository to pull from                       | ibmcom/kube-state-metrics-ppc64le:v1.3.0    |
| `image.tag`                           | The image tag to pull from                              | `<latest version>`                          |
| `image.pullPolicy`                    | Image pull policy                                       | IfNotPresent                                |
| `service.port`                        | The port of the container                               | 8080                                        |
| `prometheusScrape`                    | Whether or not enable prom scrape                       | True                                        |
| `rbac.create`                         | If true, create & use RBAC resources                    | False                                       |
| `rbac.serviceAccountName`             | ServiceAccount to be used (ignored if rbac.create=true) | default                                     |
| `nodeSelector`                        | Node labels for pod assignment                          | {}                                          |
| `tolerations`                         | Tolerations for pod assignment	                      | []                                          |
| `podAnnotations`                      | Annotations to be added to the pod                      | {}                                          |
| `resources`                           | kube-state-metrics resource requests and limits         | {}                                          |
| `collectors.cronjobs`                 | Enable the cronjobs collector.                          | true                                        |
| `collectors.daemonsets`               | Enable the daemonsets collector.                        | true                                        |
| `collectors.deployments`              | Enable the deployments collector.                       | true                                        |
| `collectors.endpoints`                | Enable the endpoints collector.                         | true                                        |
| `collectors.horizontalpodautoscalers` | Enable the horizontalpodautoscalers collector.          | true                                        |
| `collectors.jobs`                     | Enable the jobs collector.                              | true                                        |
| `collectors.limitranges`              | Enable the limitranges collector.                       | true                                        |
| `collectors.namespaces`               | Enable the namespaces collector.                        | true                                        |
| `collectors.nodes`                    | Enable the nodes collector.                             | true                                        |
| `collectors.persistentvolumeclaims`   | Enable the persistentvolumeclaims collector.            | true                                        |
| `collectors.persistentvolumes`        | Enable the persistentvolumes collector.                 | true                                        |
| `collectors.pods`                     | Enable the pods collector.                              | true                                        |
| `collectors.replicasets`              | Enable the replicasets collector.                       | true                                        |
| `collectors.replicationcontrollers`   | Enable the replicationcontrollers collector.            | true                                        |
| `collectors.resourcequotas`           | Enable the resourcequotas collector.                    | true                                        |
| `collectors.services`                 | Enable the services collector.                          | true                                        |
| `collectors.statefulsets`             | Enable the statefulsets collector.                      | true                                        |


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
  - name: 
    policy: docker.io/ibmcom/kube-state-metrics-ppc64le:v1.3.0
      va:
        enabled: false
``` 

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart] ( https://github.com/ppc64le/charts/issues )

[Submit issue to kube-state-metrics docker image]  (https://hub.docker.com/r/ibmcom/kube-state-metrics/ )

[Submit issue to kube-state-metrics open source community] ( https://github.com/kubernetes/kube-state-metrics/issues )

[ICP Support] ( https://ibm.biz/icpsupport )

## NOTE
This chart has been validated on ppc64le.
