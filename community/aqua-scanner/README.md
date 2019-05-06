<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Scanner Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Platform Scanner CLI.

## Contents

- [Aqua Security Scanner Helm Chart](#aqua-security-scanner-helm-chart)
  - [Contents](#contents)
  - [Installing the Chart](#installing-the-chart)
  - [Configurable Variables](#configurable-variables)
    - [Scanner](#scanner)
  - [Support](#support)
  
## Installing the Chart

Clone the GitHub repository with the chart

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

```bash
helm upgrade --install --namespace aqua scanner ./scanner --set imageCredentials.username=<>,imageCredentials.password=<>
```

## Configurable Variables

The following table lists the configurable parameters of the Console and Enforcer charts with their default values.

### Scanner

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `rbac.enabled`                    | Create a service account and a ClusterRole    | `false`                                                                   |
| `rbac.roleRef`                    | Use an existing ClusterRole    | ``                                                                   |
| `admin.token`                    | Use this Aqua license token   | `N/A`                                                                   |
| `admin.password`                    | Use this Aqua admin password   | `N/A`                                                                  |
| `docker.socket.path`                    | Docker Socket Path   | `/var/run/docker.sock`                                                                  |
| `serviceAccount`                    | Service Account to use   | `csp-sa`                                                                  |
| `server.serviceName`                    | Service name of aqua server ui   | `csp-consul-svc`                                                                  |
| `server.port`                    | service svc port   | `8080`                                                                  |
| `docker.socket.path`                    | Docker Socket Path   | `/var/run/docker.sock`                                                                  |
| `docker.socket.path`                    | Docker Socket Path   | `/var/run/docker.sock`                                                                  |
| `enabled`                 | Enable the Scanner-CLI component  | `false`                                        |
| `replicaCount`                | Number of Scanner-CLI replicas to run  | `1`                                        |
| `user`                | Username for the scanner user assigned to the Scanner role  | `N/A`                                        |
| `password`                | Password for scanner user  | `N/A`                                        |

## Support

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub please contact us at https://github.com/aquasecurity.