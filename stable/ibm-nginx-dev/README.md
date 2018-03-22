# ibm-nginx-dev

[NGINX](https://www.nginx.com/) is a free and open-source web server which can also be used as a reverse proxy, load balancer and HTTP cache.

## Introduction
This chart uses NGINX to host simple static content.

## Chart Details

This chart will do the following:

* Create a fixed size set of NGINX servers using a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
* Create a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) to export NGINX to the cluster.
* Optionally, use a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#create-a-configmap) to inject a nginx.conf file.
* Optionally, use or create a [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) to inject static content to host.
* Optionally, use or create a [PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims) to inject NGINX configuration.
* Optionally, an image that extends the official nginx images that already contains configuration and/or content to host.

## Prerequisites
* Kubernetes 1.7+ with Beta APIs enabled
* Existing PersistentVolumeClaims or PersistentVolumes if mounting static content or configuration files.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/ibm-nginx-dev
```

The command deploys `ibm-nginx-dev` on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the <CHARTNAME> chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `arch.amd64`               | Preference to run on amd64 architecture         | `2 - No preference` |
| `arch.ppc64le`             | Preference to run on ppc64le architecture       | `2 - No preference` |
| `arch.s390x`               | Preference to run on s390x architecture         | `2 - No preference` |
| `image.repository`         | Image repository                                | `nginx`                                                    |
| `image.pullPolicy`         | Image pull policy                               | `Always` if `imageTag` is `latest`, else `IfNotPresent`    |
| `image.tag`                | Image tag                                       | `1.13.9-alpine`                                            |
| `replicaCount`             | Number of deployment replicas                   | `1`                                                        |
| `configMapName`            | Name of the ConfigMap with the nginx.conf file  | ``                                                         |
| `service.port`             | TCP port NGINX will bind to.                    | `80`                                                       |
| `service.externalPort`     | External TCP Port for this service              | `80`                                                       |
| `confdPVC.enabled`         | Use a volume that contains NGINX config files   | `false`                                                    |
| `confdPVC.accessMode`      | Access mode for the volume                      | `ReadOnlyMany`                                             |
| `confdPVC.existingClaimName` | Name of an existing volume claim to use       | ``                                                         |
| `confdPVC.selector.label`  | The label to use when selecting a volume        | ``                                                         |
| `confdPVC.selector.value`  | The label value to match when selecting a volume | ``                                                        |
| `htmlPVC.enabled`          | Use a volume that contins static content files  | `false`                                                    |
| `htmlPVC.accessMode`       | Access mode for the volume                      | `ReadOnlyMany`                                             |
| `htmlPVC.existingClaimName` | Name of an existing volume claim to use        | ``                                                         |
| `htmlPVC.selector.label`   | The label to use when selecting a volume        | ``                                                         |
| `htmlPVC.selector.value`   | The label value to match when selecting a volume | ``                                                        |
| `readiness.enabled`        | Enable a readiness probe                        | `false`                                                    |
| `readiness.path`           | Readiness probe HTTP path                       | `/`                                                        |
| `readiness.initialDelaySeconds` | Readiness probe initial delay seconds      | `5`                                                        |
| `readiness.periodSeconds`  | Readiness proble interval seconds               | `5`                                                        |
| `liveness.enabled`         | Enable a liveness probe                         | `false`                                                    |
| `liveness.path`            | Liveness probe HTTP path                        | `/`                                                        |
| `liveness.initialDelaySeconds` | Liveness probe initial delay seconds        | `60`                                                       |
| `liveness.periodSeconds`   | Liveness proble interval seconds                | `60`                                                       |
| `resources.requests.memory`| Memory resource requests                        | `256Mi`                                                    |
| `resources.requests.cpu`   | CPU resource requests                           | `100m`                                                     |
| `resources.limits.memory`  | Memory resource limits                          | `256Mi`                                                    |
| `resources.limits.cpu`     | CPU resource limits                             | `100m`                                                     |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default values.yaml

## Storage

Storage can be used to inject NGINX configuration files into the chart and to inject content such as html files into the chart. These can
be used by creating your content in a persistent volume and then either creating an volume claim and referencing it by name with an
`existingClaimName` parameter or by using the `selector.label` and `selector.value` parameters to have the chart create a volume claim
to select the volume.

## Documentation

### Create your own image with content

To inject content and configuration, you do not have to use the volume configurations. Instead, you can just create your own image by extending the
`nginx` image. It could easily be down with a `Dockerfile` similar to this:

```
FROM nginx:1.13.9-alpine

# add all the files in the html directory to the image
ADD html /usr/share/nginx/html/

# add all the configuration files in the conf.d directory to the image
ADD conf.d /etc/nginx/conf.d/
```