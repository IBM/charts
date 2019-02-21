# Filebeat

## Introduction

[filebeat](https://www.elastic.co/guide/en/beats/filebeat/current/index.html) is used to ship Kubernetes and host logs to multiple outputs.

## Prerequisites

- Kubernetes cluster v1.7+
- Tiller 2.7.2 or later

## Note

By default this chart only ships a single output to a file on the local system.  Users should set config.output.file.enabled=false and configure their own outputs as [documented](https://www.elastic.co/guide/en/beats/filebeat/current/configuring-output.html)

This chart is validated on ppc64le.

## Resources Required
The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default: Memory: 200Mi, CPU: 100m)

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose predefined ibm-anyuid-psp PodSecurityPolicy.

## Chart Details

This chart will deploy filebeat.

## Limitations

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/filebeat
```

## Configuration

The following table lists the configurable parameters of the filebeat chart and their default values.

| Parameter                                                | Description                                                                                              | Default                                            |
| -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| `image.repository`                                       | Docker image repo                                                                                        | `docker.elastic.co/beats/filebeat-oss`             |
| `image.tag`                                              | Docker image tag                                                                                         | `6.5.3`                                            |
| `image.pullPolicy`                                       | Docker image pull policy                                                                                 | `IfNotPresent`                                     |
| `image.pullSecrets`                                      | Specify image pull secrets                                                                               | `nil`                                              |
| `config.filebeat.config.prospectors.path`                | Mounted `filebeat-prospectors` configmap                                                                 | `${path.config}/prospectors.d/*.yml`               |
| `config.filebeat.config.prospectors.reload.enabled`      | Reload prospectors configs as they change                                                                | `false`                                            |
| `config.filebeat.config.modules.path`                    |                                                                                                          | `${path.config}/modules.d/*.yml`                   |
| `config.filebeat.config.modules.reload.enabled`          | Reload module configs as they change                                                                     | `false`                                            |
| `config.processors`                                      |                                                                                                          | `- add_cloud_metadata`                             |
| `config.filebeat.prospectors`                            |                                                                                                          | see values.yaml                                    |
| `config.output.file.path`                                |                                                                                                          | `"/usr/share/filebeat/data"`                       |
| `config.output.file.filename`                            |                                                                                                          | `filebeat`                                         |
| `config.output.file.rotate_every_kb`                     |                                                                                                          | `10000`                                            |
| `config.output.file.number_of_files`                     |                                                                                                          | `5`                                                |
| `config.http.enabled`                                    |                                                                                                          | `false`                                            |
| `config.http.port`                                       |                                                                                                          | `5066`                                             |
| `indexTemplateLoad`                                      | List of Elasticsearch hosts to load index template, when logstash output is used                         | `[]`                                               |
| `command`                                                | Custom command (Docker Entrypoint)                                                                       | `[]`                                               |
| `args`                                                   | Custom args (Docker Cmd)                                                                                 | `[]`                                               |
| `plugins`                                                | List of beat plugins                                                                                     | `[]`                                               |
| `extraVars`                                              | A list of additional environment variables                                                                | `[]`                                              |
| `extraVolumes`                                           | Add additional volumes                                                                                   | `[]`                                               |
| `extraVolumeMounts`                                      | Add additional mounts                                                                                    | `[]`                                               |
| `extraInitContainers`                                    | Add additional initContainers                                                                            | `[]`                                               |
| `resources`                                              |                                                                                                          | `{}`                                               |
|`priorityClassName`                                       | priorityClassName                                                                                        | `nil`                                              |
| `nodeSelector`                                           |                                                                                                          | `{}`                                               |
| `annotations`                                            |                                                                                                          | `{}`                                               |
| `tolerations`                                            |                                                                                                          | `[]`                                               |
| `affinity`                                               |                                                                                                          | `{}`                                               |
| `rbac.create`                                            | Specifies whether RBAC resources should be created                                                       | `true`                                             |
| `serviceAccount.create`                                  | Specifies whether a ServiceAccount should be created                                                     | `true`                                             |
| `serviceAccount.name`                                    | the name of the ServiceAccount to use                                                                     | `""`                                               |
| `podSecurityPolicy.enabled`                              | Should the PodSecurityPolicy be created. Depends on `rbac.create` being set to `true`.                                                                     | `false`                                               |
| `podSecurityPolicy.annotations`                                    | Annotations to be added to the created PodSecurityPolicy:                                                                    | `""`                                               |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/filebeat
```

## Uninstalling the Chart

* To uninstall/delete the `filebeat` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Support

The helm charts are provided "as-is" and without warranty of any kind.

All helm charts and packages are supported through standard open source forums and helm charts are updated on a best effort basis.

Any issues found can be reported through the links below, and fixes may be proposed/submitted using standard git issues as noted below.

[Submit issue to Helm Chart] ( https://github.com/ppc64le/charts/issues )

[Submit issue to filebeat docker image]  ( https://hub.docker.com/r/ibmcom/filebeat-ppc64le )

[Submit issue to filebeat open source community] ( https://github.com/elastic/beats/issues )

