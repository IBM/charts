# Hazelcast Enterprise

[Hazelcast IMDG Enterprise](https://hazelcast.com/products/enterprise/) is the most widely used in-memory data grid with hundreds of thousands of installed clusters around the world. It offers caching solutions ensuring that data is in the right place when it’s needed for optimal performance.

## Quick Start

```bash
$ helm repo add hazelcast https://hazelcast.github.io/charts/
$ helm repo update
$ helm install --set hazelcast.licenseKey=<license_key> hazelcast/hazelcast-enterprise
```

## Introduction

This chart bootstraps a [Hazelcast Enterprise](https://github.com/hazelcast/hazelcast-docker/tree/master/hazelcast-enterprise-kubernetes) and [Management Center](https://github.com/hazelcast/management-center-docker) deployments on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.9+

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --set hazelcast.licenseKey=<license_key> --name my-release hazelcast/hazelcast-enterprise
```

The command deploys Hazelcast on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the Hazelcast chart and their default values.

| Parameter                                  | Description                                                                                                    | Default                                              |
|--------------------------------------------|----------------------------------------------------------------------------------------------------------------|------------------------------------------------------|
| `image.repository`                         | Hazelcast Image name                                                                                           | `hazelcast/hazelcast-enterprise-kubernetes`          |
| `image.tag`                                | Hazelcast Image tag                                                                                            | `{VERSION}`                                          |
| `image.pullPolicy`                         | Image pull policy                                                                                              | `IfNotPresent`                                       |
| `image.pullSecrets`                        | Specify docker-registry secret names as an array                                                               | `nil`                                                |
| `cluster.memberCount`                      | Number of Hazelcast members                                                                                    | 2                                                    |
| `hazelcast.licenseKey`                     | Hazelcast Enterprise License Key                                                                               | `nil`                                                |
| `hazelcast.licenseKeySecretName`           | Kubernetes Secret Name, where Hazelcast Enterprise License Key is stored (can be used instead of licenseKey)   | `nil`                                                |
| `hazelcast.rest`                           | Enable REST endpoints for Hazelcast member                                                                     | `true`                                               |
| `hazelcast.javaOpts`                       | Additional JAVA_OPTS properties for Hazelcast member                                                           | `nil`                                                |
| `hazelcast.configurationFiles`             | Hazelcast configuration files                                                                                  | `{DEFAULT_HAZELCAST_XML}`                            |
| `nodeSelector`                             | Hazelcast Node labels for pod assignment                                                                       | `nil`                                                |
| `livenessProbe.enabled`                    | Turn on and off liveness probe                                                                                 | `true`                                               |
| `livenessProbe.initialDelaySeconds`        | Delay before liveness probe is initiated                                                                       | `30`                                                 |
| `livenessProbe.periodSeconds`              | How often to perform the probe                                                                                 | `10`                                                 |
| `livenessProbe.timeoutSeconds`             | When the probe times out                                                                                       | `5`                                                  |
| `livenessProbe.successThreshold`           | Minimum consecutive successes for the probe to be considered successful after having failed                    | `1`                                                  |
| `livenessProbe.failureThreshold`           | Minimum consecutive failures for the probe to be considered failed after having succeeded.                     | `3`                                                  |
| `readinessProbe.enabled`                   | Turn on and off readiness probe                                                                                | `true`                                               |
| `readinessProbe.initialDelaySeconds`       | Delay before readiness probe is initiated                                                                      | `30`                                                 |
| `readinessProbe.periodSeconds`             | How often to perform the probe                                                                                 | `10`                                                 |
| `readinessProbe.timeoutSeconds`            | When the probe times out                                                                                       | `1`                                                  |
| `readinessProbe.successThreshold`          | Minimum consecutive successes for the probe to be considered successful after having failed                    | `1`                                                  |
| `readinessProbe.failureThreshold`          | Minimum consecutive failures for the probe to be considered failed after having succeeded.                     | `3`                                                  |
| `resources`                                | CPU/Memory resource requests/limits                                                                            | `nil`                                                |
| `service.type`                             | Kubernetes service type ('ClusterIP', 'LoadBalancer', or 'NodePort')                                           | `ClusterIP`                                          |
| `service.port`                             | Kubernetes service port                                                                                        | `5701`                                               |
| `rbac.create`                              | Enable installing RBAC Role authorization                                                                      | `true`                                               |
| `serviceAccount.create`                    | Enable installing Service Account                                                                              | `true`                                               |
| `serviceAccount.name`                      | Name of Service Account, if not set, the name is generated using the fullname template                         | `nil`                                                |
| `mancenter.enabled`                        | Turn on and off Management Center application                                                                  | `true`                                               |
| `mancenter.image.repository`               | Hazelcast Management Center Image name                                                                         | `hazelcast/management-center`                        |
| `mancenter.image.tag`                      | Hazelcast Management Center Image tag (NOTE: must be the same or one minor release greater than Hazelcast image version) | `{VERSION}`                                  |
| `mancenter.image.pullPolicy`               | Image pull policy                                                                                              | `IfNotPresent`                                       |
| `mancenter.image.pullSecrets`              | Specify docker-registry secret names as an array                                                               | `nil`                                                |
| `mancenter.javaOpts`                       | Additional JAVA_OPTS properties for Hazelcast Management Center                                                | `nil`                                                |
| `mancenter.licenseKey`                     | License Key for Hazelcast Management Center, if not provided, can be filled in the web interface               | `nil`                                                |
| `mancenter.licenseKeySecretName`           | Kubernetes Secret Name, where Management Center License Key is stored (can be used instead of licenseKey)      | `nil`                                                |
| `mancenter.nodeSelector`                   | Hazelcast Management Center node labels for pod assignment                                                     | `nil`                                                |
| `mancenter.resources`                      | CPU/Memory resource requests/limits                                                                            | `nil`                                                |
| `mancenter.persistence.enabled`            | Enable Persistent Volume for Hazelcast Management                                                              | `true`                                               |
| `mancenter.persistence.existingClaim`      | Name of the existing Persistence Volume Claim, if not defined, a new is created                                | `nil`                                                |
| `mancenter.persistence.accessModes`        | Access Modes of the new Persistent Volume Claim                                                                | `ReadWriteOnce`                                      |
| `mancenter.persistence.size`               | Size of the new Persistent Volume Claim                                                                        | `8Gi`                                                |
| `mancenter.service.type`                   | Kubernetes service type ('ClusterIP', 'LoadBalancer', or 'NodePort')                                           | `ClusterIP`                                          |
| `mancenter.service.port`                   | Kubernetes service port                                                                                        | `5701`                                               |
| `mancenter.livenessProbe.enabled`          | Turn on and off liveness probe                                                                                 | `true`                                               |
| `mancenter.livenessProbe.initialDelaySeconds` | Delay before liveness probe is initiated                                                                    | `30`                                                 |
| `mancenter.livenessProbe.periodSeconds`    | How often to perform the probe                                                                                 | `10`                                                 |
| `mancenter.livenessProbe.timeoutSeconds`   | When the probe times out                                                                                       | `5`                                                  |
| `mancenter.livenessProbe.successThreshold` | Minimum consecutive successes for the probe to be considered successful after having failed                    | `1`                                                  |
| `mancenter.livenessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded.                     | `3`                                                  |
| `mancenter.readinessProbe.enabled`         | Turn on and off readiness probe                                                                                | `true`                                               |
| `mancenter.readinessProbe.initialDelaySeconds` | Delay before readiness probe is initiated                                                                  | `30`                                                 |
| `mancenter.readinessProbe.periodSeconds`   | How often to perform the probe                                                                                 | `10`                                                 |
| `mancenter.readinessProbe.timeoutSeconds`  | When the probe times out                                                                                       | `1`                                                  |
| `mancenter.readinessProbe.successThreshold`| Minimum consecutive successes for the probe to be considered successful after having failed                    | `1`                                                  |
| `mancenter.readinessProbe.failureThreshold`| Minimum consecutive failures for the probe to be considered failed after having succeeded.                     | `3`                                                  |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set hazelcast.licenseKey=<license_key>,cluster.memberCount=3,hazelcast.rest=false \
    hazelcast/hazelcast-enterprise
```

The above command sets number of Hazelcast members to 3 and disables REST endpoints.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml hazelcast/hazelcast-enterprise
```

> **Tip**: You can use the default [values.yaml](values.yaml) with the `hazelcast.license` filled in

## Custom Hazelcast configuration

Custom Hazelcast configuration can be specified inside `values.yaml`, as the `hazelcast.configurationFiles.hazelcastXml` property.

```yaml
hazelcast:
  configurationFiles:
    hazelcastXml: |-
      <?xml version="1.0" encoding="UTF-8"?>
      <hazelcast xsi:schemaLocation="http://www.hazelcast.com/schema/config hazelcast-config-3.10.xsd"
                     xmlns="http://www.hazelcast.com/schema/config"
                     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    
        <properties>
          <property name="hazelcast.discovery.enabled">true</property>
        </properties>
        <network>
          <join>
            <multicast enabled="false"/>
            <tcp-ip enabled="false" />
            <discovery-strategies>
              <discovery-strategy enabled="true" class="com.hazelcast.kubernetes.HazelcastKubernetesDiscoveryStrategy">
              </discovery-strategy>
            </discovery-strategies>
          </join>
        </network>

        <management-center enabled="${hazelcast.mancenter.enabled}">${hazelcast.mancenter.url}</management-center>

        <!-- Custom Configuration Placeholder -->
      </hazelcast>
```
