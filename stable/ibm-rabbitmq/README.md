# RabbitMQ

[RabbitMQ](https://www.rabbitmq.com/) is an open source message broker software that implements the Advanced Message Queuing Protocol (AMQP).

## Introduction

This chart bootstraps a [RabbitMQ](https://www.rabbitmq.com/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Chart Details

This chart creates:

- Deployment of a Highly Available RabbitMQ server
- Service to expose the RabbitMQ deployment within cluster
- Secret containing credentials to connect to the RabbitMQ
- (optional) PersistentVolumeClaim if persistence is enabled

## Scaling 

This chart creates a statefulset to deploy rabbitmq cluster. The no. of replicas in this statefulset can be scaled down or scaled up after installing the chart.

## Prerequisites

- Kubernetes 1.12 or later
- Tiller 2.9.1 or later
- PV support on the underlying infrastructure
- Persistent Volume is required if persistance is enabled. Currently, only volumes created via dynamic provisioning are supported.

## Red Hat OpenShift SecurityContextConstraints Requirements
 
The predefined SCC name [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart. If your target namespace is bound to this SCC, you can proceed to install the chart.

## Custom SecurityContextConstraints definition:

```yaml
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: MustRunAs
groups:
- system:authenticated
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: restricted denies access to all host features and requires
      pods to be run with a UID, and SELinux context that are allocated to the namespace.
  name: ibm-rabbitmq-scc
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- KILL
- MKNOD
- SETUID
- SETGID
runAsUser:
  type: MustRunAsRange
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## PodSecurityPolicy Requirements

The predefined PodSecurityPolicy name [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to this PodSecurityPolicy, you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:

    ```yaml
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-rabbitmq-psp
    spec:
      allowPrivilegeEscalation: false
      forbiddenSysctls:
      - '*'
      fsGroup:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      requiredDropCapabilities:
      - ALL
      runAsUser:
        rule: MustRunAsNonRoot
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      volumes:
      - configMap
      - emptyDir
      - projected
      - secret
      - downwardAPI
      - persistentVolumeClaim
    ```

  - Custom ClusterRole for the custom PodSecurityPolicy:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-rabbitmq-psp
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-chart-dev-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```


## Resources Required

The chart deploys rabbitmq pods that includes default configuration of 256Mi memory and 200m CPU. 

The helm test, creds gen and creds clean up jobs all of them uses Memory: 128Mi, CPU: 50m. All of them are not deployed or exists at the same time, so its resources can be reused by others. 

The chart deploys pods consuming minimum resources as specified in the resources configuration parameter (default:  Memory-896Mi and CPU-650m)

## Configuration

The following tables lists the configurable parameters of the RabbitMQ chart and their default values.

|         Parameter          |                       Description                       |                         Default    |
|----------------------------|---------------------------------------------------------|----------------------------------------------------------|
| `arch.amd64`               | Most preferred to run on amd64 architecture    | `3 - Most preferred`          |
| `config.image.name`         | rabbitmq copy config image name     | `opencontent-rabbitmq-config-copy`                                               |
| `config.image.tag`                | Docker image tag         | `1.0.0`                                |
| `rabbitmq.image.name`         | rabbitmq image name    | `opencontent-rabbitmq-3`                                               |
| `rabbitmq.image.tag`                | Docker image tag       | `1.0.0`                                |
| `creds.image.name`         | creds image name         | `opencontent-icp-cert-gen-1`             |
| `creds.image.tag`                | Docker image tag                                        | `1.0.5`                                |
| `global.image.repository`           | Image registry to be gloablly used in the chart                           | `hyc-cp-opencontent-docker-local.artifactory.swg-devops.com` |
| `global.image.pullSecret`           | Image pull secret to be gloablly used in the chart  | |
| `global.image.pullPolicy`           | Image pull policy to be gloablly used in the chart                        |`IfNotPresent` |
| `global.sch.enabled`                | Specifies if ibm-sch chart is used as required subchart. If set to `false`, the umbrella chart has to provide this dependency | `true` |
| securityContext.rabbitmq.runAsUser  | The User ID that needs to be run as by all rabbitmq containers. This applies only when installed on non-openshift clusters.  |   `999` |
| securityContext.creds.runAsUser  | The User ID that needs to be run as by all creds job containers. This applies only when installed on non-openshift clusters. | `523` |
| `auth.rabbitmqUsername`         | RabbitMQ default username                               | `admin`|
| `auth.managementUsername`         | RabbitMQ management username                               | `management`|
| `tls.enabled`              | Enabled TLS security on communications ports            | `true`|
| `tls.tlsSecretName`        | Existing TLS secret Name with certs. If not provided, secrets will be generated with certs. || 
| `auth.authSecretName`         | RabbitMQ existing secret name. If not provided, secret will be generated with random passwords  | |
| `rabbitmqNodePort`         | Node port (5671 with TLS, else 5672)                    | `5671` |
| `rabbitmqManagerPort`      | RabbitMQ Manager port (15671 with TLS, else 15672)      | `15671` |
| `rabbitmqVhost`            | RabbitMQ application vhost                              | `/` |
| `rabbitmqHipeCompile` | Precompile parts of RabbitMQ using HiPE | `false` |
| `extraConfig` | Additional configuration to add to default configmap | {}| 
| `definitions.users` | Additional users |   | 
| `definitions.vhosts`  | Additional vhosts|   | 
| `definitions.parameters` |  Additional parameters|  | 
| `definitions.permissions`|  Additional permissions|    | 
| `definitions.queues` |  Pre-created queues |  | 
| `definitions.exchanges` | Pre-created exchanges | | 
| `definitions.bindings` |  Pre-created bindings |  | 
| `definitions.policies` |  HA policies to add to definitions.json |  | 
| `initContainer.resources.requests.memory` | Requested memory   | `128Mi` |
| `initContainer.resources.requests.cpu`   | Requested CPU  | `100m`|
| `initContainer.resources.limits.memory` |  memory limit  | `128Mi` |
| `initContainer.resources.limits.cpu`   |  CPU limit | `100m`|
| `resources.requests.memory` | Requested memory | `256Mi` |
| `resources.requests.cpu`   | Requested CPU  | `200m`|
| `resources.limits.memory` |  memory limit  | `256Mi` |
| `resources.limits.cpu`   |  CPU limit  | `200m`|
| `persistence.enabled`      | Enable persistence for this deployment                  | `true` |
| `persistence.useDynamicProvisioning` | Use dynamic provisioning                      | `false`|
| `persistentVolume.accessMode|  Persistent volume access modes  | `ReadWriteOnce`|
| `persistentVolume.storageClass`| Persistent volume storage class| |
| `persistentVolume.size`| Persistent volume size | `10Gi`|
| `dataPVC.selector.label`   | Field to select the volume                              | |
| `dataPVC.selector.value`   | Value of the field to select the volume                 |  |
| `livenessProbe.initialDelaySeconds`  | Number of seconds after the container has started before the probe is initiated.  | `120`     |
| `livenessProbe.periodSeconds`        | How often (in seconds) to perform the probe.    | `10`     |
| `livenessProbe.timeoutSeconds`       | Number of seconds after which the probe times out.   | `5`      |
| `livenessProbe.failureThreshold`  | Minimum consecutive successes for the probe to be considered successful after having failed.| `1`   |
| `livenessProbe.failureThreshold`     |  Number of failures to accept before giving up and marking the pod as Unready.  | `6`      |
| `readinessProbe.failureThreshold`    | Number of failures to accept before giving up and marking the pod as Unready. | `6`      |
| `readinessProbe.initialDelaySeconds` | Number of seconds after the container has started before the probe is initiated.   | `20`     |
| `readinessProbe.timeoutSeconds`      | Number of seconds after which the probe times out.     | `3`      |
| `readinessProbe.periodSeconds`       | How often (in seconds) to perform the probe.   | `5`   |

## Installing the Chart

To install with default configuration
```
helm install ibm-rabbitmq-1.4.0.tgz --name <releasename> --tls
```
To install with different configuration

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
helm install ibm-rabbitmq-1.4.0.tgz --name my-release \
  --set auth.rabbitmqUsername=admin \
     --tls
```

The above command sets the RabbitMQ admin username to `admin`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
helm install ibm-rabbitmq-1.4.0.tgz --name my-release -f values.yaml 
```

> **Tip**: You can use the default values.yaml

## Verifying the Chart

To list the pods created by this chart,
```
kubectl get pods -l release=<releasename>
```
Port forward the Rabbitmq UI service to local
```
kubectl port-forward <podname> 15671:15671
```
Hit the URL `https://localhost:15671/` in browser


## Uninstalling the Chart
```
helm delete <releasename> --purge --tls
```

## Storage

The image stores the RabbitMQ data and configurations at the `/var/lib/rabbitmq` path of the container.

The chart mounts a [Persistent Volume](kubernetes.io/docs/user-guide/persistent-volumes/) volume at this location. By default, you must create the persistent volume ahead of time as shown in step 1 of the Installing the Chart section above. If you have dynamic provisioning set up, you can install the helm chart with persistence.useDynamicProvisioning=true. An existing PersistentVolumeClaim can also be defined.

## Custom Secret

This helm chart, by default, generates two secrets - one for passwords and another for certs. To avoid this random generation of passwords and certs, a custom secret can be created and their name can be passed in the parameters auth.authSecretName and tls.tlsSecretName as respectively. 

a) Auth secret(auth.authSecretName) should have the following keys:
  rabbitmq-erlang-cookie
  rabbitmq-management-password
  rabbitmq-password
  definitions.json

b) TLS secret(tls.tlsSecretName) should have the following keys:         
  tls.cacrt
  tls.crt
  tls.key

## Limitations

- Does not support Hostpath type storage
- The chart is not tested/supported in ppc64le and s390x architectures.

## Copyright

© Copyright IBM Corporation 2018. All Rights Reserved.
