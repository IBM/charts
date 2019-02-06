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

## Configure authentication

Create a secret in the same namespace as Weave Scope with your username and password:

```bash
$ kubectl -n scope create secret generic weave-scope-auth \
--from-literal=username=admin \
--from-literal=password=change-me
```

Install or upgrade the chart with basic auth enabled:

```bash
$ helm install --name weave-scope stable/weave-scope \
--namespace scope \
--set basicAuth.enabled=true \
--set basicAuth.secretName=weave-scope-auth
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

## Support

We are a very friendly community and love questions, help and feedback.

If you have any questions, feedback, or problems with Scope:

- Docs
  - Read [the Weave Scope docs](https://www.weave.works/docs/scope/latest/introducing/)
  - Check out the [frequently asked questions](https://github.com/weaveworks/scope/site/faq.md)
  - Find out how to [contribute to Scope](https://github.com/weaveworks/scope/CONTRIBUTING.md)
  - Learn more about how the [Scope community operates](https://github.com/weaveworks/scope/GOVERNANCE.md)
- Join the discussion
  - Invite yourself to the <a href="https://slack.weave.works/" target="_blank">Weave community</a> Slack.
  - Ask a question on the [#scope](https://weave-community.slack.com/messages/scope/) Slack channel.
  - Send an email to [Scope community group](https://groups.google.com/forum/#!forum/scope-community).
- Meetings and events:
  - Join the [Weave User Group](https://www.meetup.com/pro/Weave/) and get invited to online talks, hands-on training and meetups in your area.
  - Join (and read up on) the regular [Scope community meetings](https://docs.google.com/document/d/103_60TuEkfkhz_h2krrPJH8QOx-vRnPpbcCZqrddE1s/edit).
- [File an issue](https://github.com/weaveworks/scope/issues/new).

Your feedback is always welcome!