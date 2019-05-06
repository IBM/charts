<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" /><img src="https://avatars3.githubusercontent.com/u/15859888?s=200&v=4" width="100" height="100"/>

# Aqua Security Server Helm Chart

These are Helm charts for installation and maintenance of Aqua Container Security Platform Console Server, Gateway, Database and Scanner CLI

## Contents

- [Aqua Security Server Helm Chart](#aqua-security-server-helm-chart)
  - [Contents](#contents)
  - [Prerequisites](#prerequisites)
    - [Container Registry Credentials](#container-registry-credentials)
    - [PostgreSQL database](#postgresql-database)
  - [Installing the Chart](#installing-the-chart)
    - [Server (console)](#server-console)
  - [Configurable Variables](#configurable-variables)
    - [Console](#console)
  - [Troubleshooting](#troubleshooting)
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

### PostgreSQL database

Aqua Security recommends implementing a highly-available PostgreSQL database. By default, the console chart will install a PostgreSQL database and attach it to persistent storage for POC usage and testing. For production use, one may override this default behavior and specify an existing PostgreSQL database by setting the following variables in values.yaml:

```yaml
db:
  external:
    enabled: true
    name: example-aquasec
    host: aquasec-db
    port: 5432
    user: aquasec-db-username
    password: verysecret
```
## Installing the Chart

Clone the GitHub repository with the charts

```bash
git clone https://github.com/aquasecurity/aqua-helm.git
cd aqua-helm/
```

### Server (console)

```bash
helm upgrade --install --namespace aqua csp ./server --set imageCredentials.username=<>,imageCredentials.password=<>
```

## Configurable Variables

### Console

| Parameter                         | Description                          | Default                                                                      |
| --------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------- |
| `imageCredentials.create`               | Set if to create new pull image secret    | `true`                                                                 |
| `imageCredentials.name`               | Your Docker pull image secret name    | `csp-registry-secret`                                                                   |
| `imageCredentials.username`               | Your Docker registry (DockerHub, etc.) username    | `N/A`                                                                   |
| `imageCredentials.password`               | Your Docker registry (DockerHub, etc.) password    | `N/A`                                                                   |
| `rbac.enabled`                    | Create a service account and a ClusterRole    | `false`                                                                   |
| `rbac.roleRef`                    | Use an existing ClusterRole    | ``                                                                   |
| `admin.token`                    | Use this Aqua license token   | `N/A`                                                                   |
| `admin.password`                    | Use this Aqua admin password   | `N/A`                                                                  |
| `db.external.enabled`             | Avoid installing a Postgres container and use an external database instead    | `false`                          |
| `db.external.name`                | PostgreSQL DB name    | ``N/A``                                        |
| `db.external.host`                | PostgreSQL DB hostname    | ``N/A``                                        |
| `db.external.port`                | PostgreSQL DB port    | `N/A`                                        |
| `db.external.user`                | PostgreSQL DB username    | `N/A`                                        |
| `db.external.password`            | PostgreSQL DB password    | `N/A`                                        |
| `db.image.repository`                   | Default PostgreSQL Docker image repository    | `database`                                        |
| `db.image.tag`                    | Default PostgreSQL Docker image tag    | `4.0`                                        |
| `db.service.type`                      | Default PostgreSQL service type    | `ClusterIP`                                        |
| `db.persistence.enabled`          | Enable a use of a PostgreSQL PVC    | `true`                                        |
| `db.persistence.storageClass`     | PostgreSQL PVC StorageClass   | `default`                                        |
| `db.persistence.size`             | PostgreSQL PVC volume size  | `30Gi`                                        |
| `db.persistence.accessMode`       | PostgreSQL PVC volume AccessMode  | `ReadWriteOnce`                                        |
| `db.resources`       | PostgreSQL pod resources  | `{}`                                        |
| `web.service.type`                | Web service type  | `ClusterIP`                                        |
| `web.ingress.enabled`             | Install ingress for the web component  | `false`                                        |
| `web.image.repository`                   | Default Web Docker image repository    | `server`                                        |
| `web.image.tag`                    | Default Web Docker image tag    | `4.0`                                        |
| `web.ingress.annotations`         | Web ingress annotations  | `{}`                                        |
| `web.ingress.hosts`               | Web ingress hosts definition  | `[]`                                        |
| `web.ingress.tls`                 | Web ingress tls  | `[]`                                        |
| `gate.service.type`                | Gate service type  | `ClusterIP`                                        |
| `gate.image.repository`                   | Default Gate Docker image repository    | `gate`                                        |
| `gate.image.tag`                    | Default Gate Docker image tag    | `4.0`                                        |
| `gate.publicIP`                    | Default Gate service public IP    | ``                                        |
| `scanner.enabled`                 | Enable the Scanner-CLI component  | `false`                                        |
| `scanner.replicas`                | Number of Scanner-CLI replicas to run  | `1`                                        |
| `scanner.user`                | Username for the scanner user assigned to the Scanner role  | `N/A`                                        |
| `scanner.password`                | Password for scanner user  | `N/A`                                        |

## Troubleshooting

* Database pod getting `CreateContainerConfigError`
  this is happenig because of your helm tiller version the solution is to delete the pod and waiting it to recreate
  ```sh
  kubectl delete pod <aqua-database-name> -n <namespace>
  kubectl get pods -n <namespace> -w
  ```

## Support

If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub please contact us at https://github.com/aquasecurity.