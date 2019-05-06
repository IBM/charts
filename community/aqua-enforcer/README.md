<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Enforcer Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Enforcer

## Contents

- [Aqua Security Enforcer Helm Chart](#aqua-security-enforcer-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
  - [Installing the Charts](#installing-the-charts)
  - [Configurable Variables](#configurable-variables)
    - [Enforcer](#enforcer)
  - [Issues and feedback](#issues-and-feedback)
  - [Support](#support)

## Prerequisites

### Container Registry Credentials

The Aqua server (Console and Gateway) components are available in our private repository, which requires authentication. By default, the charts create a secret based on the values.yaml. 

First, create a new namespace named "aqua":

```bash
kubectl create namespace aqua
```

Next, **(Optional)** create the secret:

```bash
kubectl create secret docker-registry csp-registry-secret  --docker-server="registry.aquasec.com" --namespace aqua --docker-username="jg@example.com" --docker-password="Truckin" --docker-email="jg@example.com"
```

## Installing the Charts

Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

```bash
helm upgrade --install --namespace aqua csp-enforcer ./enforcer --set imageCredentials.username=<>,imageCredentials.password=<>,enforcerToken=<aquasec-token>
```

## Configurable Variables

### Enforcer

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `false`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `aqua-image-pull-secret`                                                                   |
| `imageCredentials.username`               | Your Docker registry (DockerHub, etc.) username    | `N/A`                                                                   |
| `imageCredentials.password`               | Your Docker registry (DockerHub, etc.) password    | `N/A`                                                                   |
| `enforcerToken`                           | Aqua Enforcer token    | `N/A`                                                     |
| `server`                          | Gateway host name    | `aqua-gateway`                                                     |
| `port`                            | Gateway port    | `3622`                                                     |

## Issues and feedback

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.

## Support

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub please contact us at https://github.com/aquasecurity.