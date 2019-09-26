## Configuration

The following table lists the configurable parameters for this chart and their default values.

| Parameter                  | Description                        | Default                               |
| -----------------------    | ---------------------------------- | ------------------------------------- |
| `global.enableDashboard`  | Enable dashboard                   | true                                  |
| `service.externalPort`     | Kubernetes external service port   | 80                                    |
| `dashboard.image.repository`          | dashboard image name               | cdi-dashboard                         |
| `dashboard.tag`            | dashboard image tag                | latest                                |
| `global.images.pullPolicy` | image pulling policy               | Always                                |
| `global.docker.registry`   | image pulling secret               | cdtrainbow-registry                   |
| `global.images.registry`   | image repository                   | registry.ng.bluemix.net/cdtrainbow    |
| `global.replicas.dashboard`| k8s deployment replicas            | 1                                     |
| `resources.limits.cpu`      | dashboard CPU limit               | 1                                     |
| `resources.limits.memory`   | dashboard memory limit            | 1Gi                                   |
| `resources.requests.cpu`    | dashboard CPU requests            | 0.1                                   |
| `resources.requests.memory` | dashboard memory requests         | 256M                                  |
