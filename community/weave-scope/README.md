# Weave Scope

## About this chart

This chart installs [Weave Scope](https://github.com/weaveworks/scope), an interactive container monitoring and cluster visualization application.

## Prerequisites

* Kubernetes >= 1.9

## Image Policy Requirements

If Container Image Security is enabled, you have to add `quay.io/weaveworks/*` to the trusted registries so that these container images can be pulled during chart installation.

## Installing the Chart

To install the chart with the release name `weave-scope` in the `scope` namespace:

```bash
$ helm install --name weave-scope stable/weave-scope --namespace scope
```

The command deploys Weave Scope on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

Test the installation with:

```bash
helm test weave-scope
```

## Uninstalling the Chart

To uninstall/delete the `weave-scope` deployment:

```bash
$ helm delete --purge weave-scope
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

| Parameter | Description | Default |
|----------:|:------------|:--------|
| **image.repository** | the image that will be used for this release (required) | `quay.io/weaveworks/scope` |
| **image.tag** | the version of Weave Scope desired for this release (required) | `1.10.1`
| **image.pullPolicy** | the imagePullPolicy for the container (required): IfNotPresent, Always, or Never | `IfNotPresent`
| **frontend.service.port** | the port exposed by the Scope frontend service | `80` |
| **frontend.service.type** | the type of the frontend service: ClusterIP, NodePort or LoadBalancer | `ClusterIP` |
| **agent.dockerBridge** | the name of the Docker bridge interface | `docker0` |
| **agent.rbac.create** | whether RBAC resources should be created | true |
| **agent.serviceAccount.create** | whether a new service account name that the agent will use should be created. | `true` |
| **agent.serviceAccount.name** | service account to be used.  If not set and serviceAccount.create is `true` a name is generated using the fullname template. |  |

## Other notes

The Weave Scope agent runs as a privileged container with access to the host network and Docker engine socket.
