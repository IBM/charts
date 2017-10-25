# Node.js sample Helm Chart

### This sample is for demonstrative purposes only and is NOT for production use. ###

### For all features to be available this is best viewed in Google Chrome or Safari.

The source code for this application is available on [GitHub](https://github.com/ibm-developer/icp-nodejs-sample).

## Introduction
This sample application is intended to guide you through the process of deploying your own Node.js applications into IBM Cloud Private. Useful links and examples are provided and the application itself is one that makes use of various monitoring capabilities. Note that this sample was produced in early October 2017 and so the code you are provided with by using the generators may differ!

This sample was created using `idt create` with the following choices:
- Web App
- Basic Web
- Node

Modifications were then made to use EJS, to add a gulp task, and to add the content. The stylesheet provided is largely based on the [Node.js @ IBM developer center](https://developer.ibm.com/node).

- This example uses [appmetrics](https://github.com/RuntimeTools/appmetrics) and [appmetrics-dash](https://github.com/RuntimeTools/appmetrics-dash): the endpoint being `/appmetrics-dash`.
- This example features the "scrape" annotation in the `<chart directory>/templates/service.yaml` file. In combination with the [appmetrics-prometheus](https://github.com/RuntimeTools/appmetrics-prometheus) module inclusion and usage, this enables the sample to be automatically scraped by a deployed instance of Prometheus in order for metrics to be gathered and displayed using the Prometheus web UI. You can view the raw data that will be available to Prometheus at the `/metrics` endpoint.
This allows developers to quickly determine how the application is performing across potentially many Kubernetes pods.
- This example uses [appmetrics-zipkin](https://github.com/RuntimeTools/appmetrics-zipkin). If Zipkin is deployed (e.g. with the Microservice Builder fabric), trace information will be available under the service name "icp-nodejs-sample". To enable this feature, modify `Dockerfile` and set `USE_ZIPKIN` to `true`. You can dynamically modify applications as well using the IBM CLoud Private web UI - this includes the setting of environment variables and it's recommended you restart the pod for the change to take effect.
- This example can be deployed using the IBM Cloud Developer Tools, for example: `idt deploy -t container --deploy-image-target mycluster.icp:8500/default/nodejs-sample`.

The `mycluster.icp` example here should match up with the entry you've added in `/etc/hosts`: it is the location of the private registry.

## Prerequisites

There is only one optional requirement to make the most out of this sample: you should have Prometheus deployed into your IBM Cloud Private cluster where this sample will be installed. This is not a mandatory step and can be done after deployment, happy installing!

## Installing the Chart

The Helm chart can be installed from the app center by finding the nodejs-sample and following the installation steps.

The Helm chart can also be installed with the following command from the directory containing `Chart.yaml`:

`helm install --name tester .` where tester can be anything.

You can find more information about deployment methods in the [IBM Cloud Private documentation](https://www.ibm.com/support/knowledgecenter/SSBS6K/product_welcome_cloud_private.html).

## Verifying the Chart
You can view the deployed sample in your web browser. To retrieve the IP and port:

`export SAMPLE_NODE_IP=$(kubectl get nodes --namespace {{ .Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")`

`export SAMPLE_NODE_PORT=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ template "fullname" . }})`

Open your web browser at `http://${SAMPLE_NODE_IP}:${SAMPLE_NODE_PORT}` to view the sample.

## Uninstalling the Chart

If you installed it with `helm install --name tester .` you'd remove the sample with `helm delete --purge tester`. You can find the deployment with `helm list --all` and searching for an entry with the chart name "ibm-nodejs-sample".

## Configuration

The following table lists the configurable parameters of the ibm-nodejs-sample chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `replicaCount`             | How many pods to deploy                         | 1                                                          |
| `revisionHistoryLimit`     | Optional field that specifies the number of old ReplicaSets to retain to allow rollback   | 1                |
| `image.repository`         | image repository                                | `ibmcom/icp-nodejs-sample`                                 |
| `image.tag`                | Image tag                                       | `latest`                                                    |
| `image.pullPolicy`         | Image pull policy                               | `Always`                                                   |
| `livenessProbe.initialDelaySeconds`   | How long to wait before beginning the checks our pod(s) are up |   30                             |
| `livenessProbe.periodSeconds`         | The interval at which we'll check if a pod is running OK before being restarted     | 10          |
| `service.name`             | k8s service name                                | `Node`                                                     |
| `service.type`             | k8s service type exposing port                  | `NodePort`                                                 |
| `service.port`             | TCP Port for this service                       | 3000                                                       |
| `resources.limits.memory`  | Memory resource limits                          | `128m`                                                     |
| `resources.limits.cpu`     | CPU resource limits                             | `100m`                                                     |

#### Configuring Node.js applications

See the [Node.js @ IBM developer center](https://developer.ibm.com/node/) for all things Node.js - including more samples, tutorials and blog posts. For configuring Node.js itself, consult the official [Node.js community documentation](https://nodejs.org/en/docs/).

### Deploying on platforms other than x86-64
- Ensure your nodes are labelled according to their architecture under the "Platform" -> "Nodes" page under IBM Cloud Private. An example label that's automatically created for us is `beta-kubernetes.io/arch-s390x`.
- Modify this chart's `templates/deployment.yaml` file, looking for the `selector` tag.
- To ensure the deployment(s) use the correct Docker image, modify the `selector` tag and add the following under `spec` (you can see examples in `templates/deployment.yaml`).

- For IBM Linux on Z systems:
  ```
    nodeSelector:
      beta.kubernetes.io/arch: s390x
  ```
- For IBM Power Little-Endian systems:
  ```
    nodeSelector:
      beta.kubernetes.io/arch: ppc64le
  ```
- For more details see [here](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/).


### Disclaimers
Node.js is an official trademark of Joyent. Images are used according to the Node.js visual guidelines - no copyright claims are made. You can view the guidelines [here](https://nodejs.org/static/documents/foundation-visual-guidelines.pdf).

This icp-nodejs-sample is not formally related to or endorsed by the official Node.js open source or commercial project.
