# ibm-nodejs-sample

THIS CHART IS NOW DEPRECATED. On March 30, 2020 the ibm-nodejs-sample Helm chart will no longer be supported. As this chart was a demonstrative sample application, that was not intended to be used in production, there will be no replacement chart. The chart will be removed on April 30, 2020.

* A sample application using Node.js

### This sample is for demonstrative purposes only and is NOT for production use. ###

## Introduction
This chart deploys a Node.js web application which hosts documentation on the process of creating and deploying your own Node.js applications.

This sample application

- was initially created using `idt create`
- uses [appmetrics](https://github.com/RuntimeTools/appmetrics) and [appmetrics-dash](https://github.com/RuntimeTools/appmetrics-dash): the endpoint being `/appmetrics-dash`.
- has a "scrape" annotation in the `<chart directory>/templates/service.yaml` file. In combination with the [appmetrics-prometheus](https://github.com/RuntimeTools/appmetrics-prometheus) module inclusion and usage, this enables the sample to be automatically scraped by a deployed instance of Prometheus in order for metrics to be gathered and displayed using the Prometheus web UI. You can view the raw data that will be available to Prometheus at the `/metrics` endpoint.
This allows developers to quickly determine how the application is performing across potentially many Kubernetes pods.
- can be deployed using the IBM Cloud Developer Tools.

## Chart Details

This chart contains definitions for two Kubernetes resources

* A Pod - which hosts the application
* A Service - which exposes the application's endpoints

## Prerequisites

(Optional) You should have Prometheus deployed in your cluster. This is not a mandatory step and can also be done after deployment

## PodSecurityPolicy Requirements

## Resources Required

By default this application requests and limits itself to 128MiB of memory and 100milicpus.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release --tls
```

where my-release can be anything: this is the desired name of the release. A name will be automatically generated if not specified.

### Verifying the Chart

See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge my-release --tls
```
You can find the deployment with `helm list --all --tls` and searching for an entry with the chart name "ibm-nodejs-sample".

## Configuration

The following table lists the configurable parameters of the ibm-nodejs-sample chart and their default values.

| Parameter                   | Description                                     | Default                                                    |
| --------------------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| `image.repository`          | Image repository                                | `ibmcom/icp-nodejs-sample`                                 |
| `image.tag`                 | Image tag                                       | `latest`                                                    |
| `image.pullPolicy`          | Image pull policy                               | `Always`                                                   |
| `livenessProbe.initialDelaySeconds`   | How long to wait before beginning the checks our pod(s) are up |   30                             |
| `livenessProbe.periodSeconds`         | The interval at which we'll check if a pod is running OK before being restarted     | 10          |
| `service.name`              | k8s service name                                | `Node`                                                     |
| `service.type`              | k8s service type exposing port                  | `NodePort`                                                 |
| `service.port`              | TCP Port for this service                       | 3000                                                       |
| `resources.requests.memory` | Minimum memory requirement                      | `128Mi                                                     |
| `resources.requests.cpu`    | Minimum CPU requirement                         | `100m`                                                     |
| `resources.limits.memory`   | Memory resource limits                          | `128Mi`                                                    |
| `resources.limits.cpu`      | CPU resource limits                             | `100m`                                                     |

## Storage

Not applicable

## Limitations

* Verified on IBM Cloud Private
* Verified on IBM Kubernetes Service

## Documentation

See the [Node.js @ IBM developer center](https://developer.ibm.com/node/) for all things Node.js - including more samples, tutorials and blog posts. For configuring Node.js itself, consult the official [Node.js community documentation](https://nodejs.org/en/docs/).

### Deploying on platforms other than x86-64
- Multiarch images are used so the correct Node.js Docker image will be pulled based on your platform. Supported platforms for this sample include ppc64le, x86-64 and s390x.
- Note that the IBM Cloud Developer Tools are not available for every platform: consult the [CLI docs](https://www.ibm.com/cloud/cli) to find out more.

### Disclaimers
Node.js is an official trademark of Joyent. Images are used according to the Node.js visual guidelines - no copyright claims are made. You can view the guidelines [here](https://nodejs.org/static/documents/foundation-visual-guidelines.pdf).

This sample is not formally related to or endorsed by the official Node.js open source or commercial project.
