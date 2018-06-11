# Swift sample Helm Chart
#### This sample is for demonstrative purposes only and is NOT for production use.

## Introduction
This Helm Chart deploys a sample Swift application running a simple [Kitura](https://github.com/IBM-Swift/Kitura) server.

## Chart Details
The sample is created using [Kitura](https://github.com/IBM-Swift/Kitura), a high performance and simple to use web framework for building Swift applications. See [kitura.io](https://kitura.io) for information on Kitura including more samples, tutorials and blog posts.

It includes a [health](https://github.com/IBM-Swift/Health) check endpoint accessible on `/health` and the ability to monitor the application's [metrics](https://github.com/RuntimeTools/SwiftMetrics) on the `/metrics` endpoint.

## Prerequisites
### Resources Required
The Swift sample app will run successfully with the default [configuration](#configuration) values for memory and cpu. These may need to be increased if you use this sample to build your own application.

## Installing the chart
The sample can be installed in the following ways:
- Via the `ibm-charts` repository by running the following commands:
```bash
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
```
```bash
helm install --name sample ibm-charts/ibm-swift-sample
```

- From the directory containing `Chart.yaml` by running:
```bash
helm install --name "name" .
```
 where "name" is what you wish to call your release.


### Verifying the chart
You can view the deployed Swift sample in your web browser. To retrieve the IP and port, paste the following into a terminal window:

```bash
export SAMPLE_SWIFT_IP=$(kubectl get nodes --namespace {{ .Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")
```

```bash
export SAMPLE_SWIFT_PORT=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ template "fullname" . }})
```

```bash
echo "Open your web browser at http://${SAMPLE_SWIFT_IP}:${SAMPLE_SWIFT_PORT} to view the sample."
```

### Uninstalling the Chart

If you installed using `helm install --name "name" .`, you can remove the sample with `helm delete --purge "name"`. You can find the deployment with `helm list --all` and searching for an entry with the chart name "ibm-swift-sample".

### Testing the Chart with Helm

You can programatically run the test in the following ways.
- `cd chart/ibm-swift-sample` then do `./test-chart.sh` OR
- `helm test "name"`, replacing "name" with whatever you named your deployment.

## Configuration

The following table lists the configurable parameters of the ibm-swift-sample chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `replicaCount`             | How many pods to deploy                         | 1                                                          |
| `revisionHistoryLimit`     | Optional field that specifies the number of old ReplicaSets to retain to allow rollback   | 1                |
| `image.repository`         | image repository                                | `ibmcom/icp-swift-sample`                                 |
| `image.tag`                | Image tag                                       | `latest`                                                    |
| `image.pullPolicy`         | Image pull policy                               | `Always`                                                   |
| `livenessProbe.initialDelaySeconds`   | How long to wait before beginning the checks our pod(s) are up |   30                             |
| `livenessProbe.periodSeconds`         | The interval at which we'll check if a pod is running OK before being restarted     | 10          |
| `service.name`             | k8s service name                                | `Swift`                                                     |
| `service.type`             | k8s service type exposing port                  | `NodePort`                                                 |
| `service.servicePort`      | TCP Port for this service                       | 8080                                                       |
| `resources.limits.memory`  | Memory resource limits                          | `128m`                                                     |
| `resources.limits.cpu`     | CPU resource limits                             | `100m`                                                     |

## Limitations

This sample is for demonstrative purposes only and is not recommended for production use. As such, you will only be able to deploy one instance of the sample per namespace.
