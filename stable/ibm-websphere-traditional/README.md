# IBM WebSphere Application Server traditional

Encapsulates Helm chart and other cloud pak artifacts for WebSphere Application Server traditional.

## Introduction

This chart deploys IBM WebSphere Application Server traditional Base edition. WebSphere Application Server traditional excels as the foundation for a service-oriented architecture. Version 9.0 offers support for Java™ SE 8 and Java EE 7 technology and several enhancements.

## Chart Details

This chart will install the following:

* One [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to rollout a [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/) to create [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/) with IBM WebSphere Application Server traditional based containers.
* A [NodePort Service](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) to enable secure connection from outside the cluster.

## Prerequisites

If you prefer to install from the command prompt, you will need:

* The `cloudctl`, `kubectl` and `helm` commands available.
* Your environment configured to connect to the target cluster.

The installation environment has the following prerequisites:

* Kubernetes version `1.11.1`.
* [PersistentVolume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) support in the underlying infrastructure if `logs.persistLogs` (See "[Create Persistent Volumes](#create-persistent-volumes)" below).

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-websphere-traditional-psp
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

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-websphere-traditional-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-websphere-traditional-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

#### Configuration scripts can be used to create the required resources

Download the following scripts located at [/ibm_cloud_pak/pak_extensions/pre-install](https://github.com/IBM/charts/tree/master/stable/ibm-websphere-traditional/ibm_cloud_pak/pak_extensions/pre-install) directory.

* The pre-install instructions are located at `clusterAdministration/createSecurityClusterPrereqs.sh` for cluster admins to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team admin/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

#### Configuration scripts can be used to clean up resources created

Download the following scripts located at [/ibm_cloud_pak/pak_extensions/post-delete](https://github.com/IBM/charts/tree/master/stable/ibm-websphere-traditional/ibm_cloud_pak/pak_extensions/post-delete) directory.

* The post-delete instructions are located at `clusterAdministration/deleteSecurityClusterPrereqs.sh` for cluster admins to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team admin/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`

### Docker Image Requirements

The Helm chart requires the Docker image to have certain directory linked. The `ibmcom/websphere-traditional` image from Docker Hub already has the expected links. If you are not extending from this image, you must add the following to your `Dockerfile`:

```docker
RUN ln -s /opt/IBM/WebSphere/AppServer/profiles/${PROFILE_NAME}/logs /logs \
  && chown $USER:$GROUP /logs
```

The Helm chart also assumes that the Docker image has a startup script that looks for properties files inside `/etc/websphere` and automatically applies them to the application server.  The `ibmcom/websphere-traditional` image from Docker Hub already has this script.

## Resources Required

See [System Requirements for WebSphere Application Server v9.0](http://www-01.ibm.com/support/docview.wss?rs=180&uid=swg27047911#base-90) and [Preparing the operating system for product installation](https://www.ibm.com/support/knowledgecenter/SSEQTP_9.0.0/com.ibm.websphere.installation.base.doc/ae/tins_prepare.html).

## Installing the Chart

There are three steps to run your application on IBM WebSphere Application Server traditional in your environment:

* Create an application image based on IBM WebSphere Application Server traditional
* Create persistent volumes (Optional)
* Install the Helm chart

### Create Persistent Volumes

Persistence is not enabled by default so no persistent volumes are required. If you are not using persistence, you can skip this section.

Enable persistence if you want logs generated by the server to be retained in the event of a restart. If persistence is enabled, one physical volume will be required for each instance of the server.

To create physical volumes, you must have the Cluster administrator role.

You can find more information about storage requirements below.

For volumes that support ownership management, specify the group ID of the group owning the persistent volumes' file systems using the `persistence.fsGroupGid` parameter.

### Create an application image

You need to create an application image that extends from the base IBM WebSphere Application Server traditional image found on Docker Hub. You can find detailed information on this process on the [official GitHub page](https://github.com/WASdev/ci.docker.websphere-traditional#docker-hub-image).

### Install the Helm chart

Add the IBM Cloud Private internal Helm repository called `local-charts` to the Helm CLI as an external repository, as described [here](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/app_center/add_int_helm_repo_to_cli.html).

Install the chart, specifying the release name and namespace with the following command:

```bash
helm install --name <release_name> --namespace=<namespace_name> ibm-websphere-traditional --tls
```

NOTE: The release name should consist of lower-case alphanumeric characters and not start with a digit or contain a space.

The command deploys IBM WebSphere Application Server traditional on the Kubernetes cluster with the default configuration.

The [Configuration](#configuration) lists the parameters that can be overridden during installation by adding them to the Helm install command as follows:

```bash
--set key=value[,key=value]
```

### Verifying the Chart

See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm delete my-release --purge --tls
```

This command removes all the Kubernetes components associated with the chart, except any persistent volume claims (PVCs) which is created when `logs.persistLogs`. This is the default behavior of Kubernetes, and ensures that valuable data is not deleted. In order to delete the server data, you can delete the PVC using the following command:

```bash
kubectl delete pvc my-pvc
```

Note: You can use `kubectl get pvc` to see the list of available PVCs.

### Cleanup any pre-requirement that were created

If cleanup scripts where included in the [/ibm_cloud_pak/pak_extensions/prereqs](./ibm_cloud_pak/pak_extensions/prereqs) directory; run them to cleanup namespace and cluster scoped resources when appropriate.

## Configuration

The following tables lists the configurable parameters of the IBM WebSphere Application Server traditional chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `replicaCount`             | The number of desired replica pods that run simultaneously                   | `1`                                                        |
| `image.repository`         | Docker image repository                         | `ibmcom/websphere-traditional`                             |
| `image.pullPolicy`         | Docker image pull policy. Defaults to `Always` when the latest tag is specified.                             | `IfNotPresent`                                             |
| `image.tag`                | Docker image tag                                | `9.0.0.10`                                          |
| `image.extraEnvs`          | Additional Environment Variables                | `[]`                                                       |
| `image.extraVolumeMounts`  | Extra Volume Mounts                             | `[]`                                                       |
| `deployment.annotations`   | Custom deployment annotations                   | `{}`                                                       |
| `deployment.labels`        | Custom deployment labels                        | `{}`                                                       |
| `pod.annotations`          | Custom pod annotations                          | `{}`                                                       |
| `pod.labels`               | Custom pod labels                               | `{}`                                                       |
| `pod.extraVolumes`         | Additional Volumes for server pods.             | `{}`                                                       |
| `service.type`             | Kubernetes service type exposing ports| `NodePort`                                                 |
| `service.name`             | Kubernetes service name for HTTP                                | `https-was`                                                |
| `service.port`             | The abstracted service port for HTTP, which other pods use to access this service                     | `9443`                                                    |
| `service.targetPort`       | Secured HTTP port the container accepts traffic on. Ensure that it matches the port exposed by the container       | `9443`                                                    |
| `service.annotations`      | Kubernetes service custom annotations"|        `{}`                                                 |
| `service.labels`           | Kubernetes service custom labels"|        `{}`                                                      |
| `ingress.enabled`          | Specifies whether to enable [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)                                  | `false`                                                    |
| `ingress.rewriteTarget`    | Specifies target URI where traffic must be redirected | `/`                                                  |
| `ingress.path`             | Specifies path for the Ingress HTTP rule        | `/`                                                        |
| `ingress.annotations`      | Kubernetes ingress custom annotations |        `{}`                                                 |
| `ingress.labels`           | Kubernetes ingress custom labels      |        `{}`                                                      |
| `configProperties.configMapName`      | Name of the [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#create-a-configmap) that contains one or more [configuration properties](https://www.ibm.com/support/knowledgecenter/SSEQTP_9.0.0/com.ibm.websphere.base.doc/ae/txml_config_prop.html) files to configure your WebSphere Application Server traditional environment | `""`         |
| `readinessProbe.initialDelaySeconds`| Number of seconds after the container has started before readiness probe is initiated | `30`        |
| `readinessProbe.periodSeconds`| How often (in seconds) to perform the readiness probe. Minimum value is 1  | `5`                                                        |
| `readinessProbe.httpGet.enabled`| Specifies whether to determine readiness by sending an HTTP GET request to the specified path on the server (`readinessProbe.httpGet.path`). Otherwise, uses connection to a TCP socket on the specified target port  | `false` |
| `readinessProbe.httpGet.path`| Path to access on the server | `/`                                                                         |
| `livenessProbe.initialDelaySeconds`| Number of seconds after the container has started before liveness probe is initiated | `180`         |
| `livenessProbe.periodSeconds`| How often (in seconds) to perform the liveness probe. Minimum value is 1 | `20`                            |
| `livenessProbe.httpGet.enabled`| Specifies whether to determine livenessProbe by sending an HTTP GET request to the specified path on the server (`livenessProbe.httpGet.path`). Otherwise, uses connection to a TCP socket on the specified target port  | `false` |
| `livenessProbe.httpGet.path`| Path to access on the server | `/`                                                                          |
| `autoscaling.enabled`      | Enables a Horizontal Pod Autoscaler. Enabling this field disables the `replicaCount` field | `false`         |
| `autoscaling.minReplicas`  | Lower limit for the number of pods that can be set by the autoscaler              | `1`                                                        |
| `autoscaling.maxReplicas`  | Upper limit for the number of pods that can be set by the autoscaler. It cannot be lower than `minReplicas`| `10`                                 |
| `autoscaling.targetCPUUtilizationPercentage` | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods | `50` |
| `resources.constraints.enabled`| Specifies whether the resource constraints are enabled               | `false`                                                    |
| `resources.requests.memory`| Describes the minimum amount of memory required. Corresponds to `requests.memory` in Kubernetes.                        | `2Gi`                                                      |
| `resources.requests.cpu`   | Describes the minimum amount of CPU required. Corresponds to `requests.cpu` in Kubernetes                           | `500m`                                                     |
| `resources.limits.memory`  | Describes the maximum amount of memory allowed                          | `10Gi`                                                     |
| `resources.limits.cpu`     | Describes the maximum amount of CPU allowed                             | `500m`                                                     |
| `arch.amd64`               | Architecture preference for amd64 worker node   | `2 - No preference`                                        |
| `arch.ppc64le`             | Architecture preference for ppc64le worker node | `0 - Do not use`                                           |
| `arch.s390x`               | Architecture preference for s390x worker node   | `0 - Do not use`                                           |
| `persistence.name`         | A prefix for the name of the persistence volume claim (PVC). A PVC will not be created unless `logs.persistLogs` is set to `true` | `pvc` |
| `persistence.size`         | Size of the volume to hold all the persisted data | `1Gi`                                                    |
| `persistence.fsGroupGid`             | The group ID added to the containers with persistent storage to allow access. Volumes that support ownership management must be owned and writable by this group ID | `1000`                        |
| `persistence.useDynamicProvisioning` | If `true`, the persistent volume claim will use the `storageClassName` to bind the volume. Otherwise, the selector will be used for the binding process | `true` |
| `persistence.storageClassName`       | Specifies a StorageClass pre-created by the Kubernetes sysadmin. When set to `""`, then the PVC is bound to the default StorageClass setup by kube Administrator | `""` |
| `persistence.selector.label`         | When matching a PV, the label is used to find a match on the key. See Kubernetes - [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) | `""` |
| `persistence.selector.value`         | When matching a PV, the value is used to find a match on the values. See Kubernetes - [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) | `""` |
| `logs.persistLogs`         | When `true`, the server logs will be persisted to the volume bound according to the persistence parameters | `false` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install ... --tls`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. The following commands creates a YAML file and installs a chart:

```bash
$ cat << EOF > my-values.yaml
logs:
  persistLogs: false
image:
  repository: mycluster.icp:8500/my-namespace/my-app
  tag: v1
  pullPolicy: Always
EOF

$ helm install --name my-release --namespace=my-namespace ibm-websphere-traditional --values=my-values.yaml --tls
```

### Configure Environment using Configuration Properties

Your WebSphere Application Server traditional environment can be configured using a ConfigMap that contains one or more configuration properties files. The configuration values will be automatically applied to the application server. Specify the name of your ConfigMap using `configProperties.configMapName` parameter. In the following example, the ConfigMap is named `my-config-properties`.

The keys in the `data` section of the ConfigMap correspond to the name of the property files and must end with `.props`. In the following example, the property file is named `jvm.props`.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config-properties
data:
  jvm.props: |-
    ResourceType=JavaVirtualMachine
    ImplementingResourceType=Server
    ResourceId=Cell=!{cellName}:Node=!{nodeName}:Server=!{serverName}:JavaProcessDef=:JavaVirtualMachine=
    AttributeInfo=jvmEntries
    initialHeapSize=2048
```

* You can find more information here :
  * [Managing specific configuration objects using properties files](https://www.ibm.com/support/knowledgecenter/SSEQTP_9.0.0/com.ibm.websphere.base.doc/ae/txml_config_prop.html)
  * [Creating a ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#create-a-configmap)

### Configure Liveness and Readiness Probes

With the default configuration, readiness and liveness probes are determined by attempting to establish a connection by opening a TCP socket to your container on the specified target port. If connection can be established then the container is considered healthy, otherwise the container is considered a failure.

You can use HTTP probes instead to determine readiness and liveness. For readiness, configure `readinessProbe.httpGet.enabled` and `readinessProbe.httpGet.path` parameters. For liveness, configure `livenessProbe.httpGet.enabled` and `livenessProbe.httpGet.path` parameters.

The `readinessProbe.initialDelaySeconds` and `livenessProbe.initialDelaySeconds` parameters define how long to wait before performing the first probe. You should set appropriate values for your container to ensure that the readiness and liveness probes don’t interfere with each other. Otherwise, the liveness probe might continiously restart the pod and the pod will never be marked as ready.

More information about configuring liveness and readiness probes can be found [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/)

### Accessing the WebSphere Application Server Administrative Console

Administrators can use `kubectl port-forward` to access the Admin Console of a WebSphere Application Server instance running inside a pod. Forward a local port to the admin console port:

```bash
kubectl port-forward <pod_name> <local_port>:<admin_console_port>
```

For example, run `kubectl port-forward websphere-server-pod-1 9043:9043` and then access Admin Console at `https://127.0.0.1:9043/ibm/console`

The default admin user ID is `wsadmin` and the default password can be retrieved by running `kubectl exec <pod_name> cat /tmp/PASSWORD`

Note that when a server running inside a pod is restarted, the container will be killed and all changes made via Admin console will be lost. Hence, any configurations that require a server restart should be done using configuration properties or scripts.

### Analyzing WebSphere Application Server messages

Logging in JSON format is enabled by default. Log events are forwarded to Elasticsearch automatically. Use Kibana to monitor and analyze the log events. Sample Kibana dashboards are provided at the Helm chart's [dashboards](https://github.com/IBM/charts/tree/master/stable/ibm-websphere-traditional/ibm_cloud_pak/pak_extensions/dashboards/) folder.

#### View JSON logs in a Kibana dashboard

**Important**: WebSphere Application Server must have generated log records before you set up the dashboard. Otherwise, you might see warnings or errors about missing fields when you import the dashboard.
1. Create a logstash-* index pattern.
   1. In the IBM Cloud Private console, open the Kibana dashboard by selecting **Platform > Logging**, and then select **Management > Index Patterns**.
   2. In the Index name or pattern field, enter logstash-*.
   3. For the Time Filter field, select @timestamp.
   4. Click **Create**.
  
2. Create the WebSphere Application Server Kibana dashboard.
   1. Download the sample Kibana dashboard JSON file from the dashboards folder in the IBM/charts/ibm-websphere-traditional GitHub repository.
   2. Import the WebSphere Application Server sample dashboard.
      1. From the Kibana tab, select **Management > Saved Objects**.
      2. Click **Import**, and select the sample dashboard JSON file.
      3. Click **Yes, overwrite all** to complete importing the dashboard.
3. View the WebSphere Application Server dashboard on the Kibana tab by clicking **Dashboard** and selecting the dashboard.

#### View basic mode logs in Kibana

1. In the IBM Cloud Private console, open the Kibana dashboard by selecting **Platform > Logging**.
2. Click the **Discover** tab.
3. Review the log files.

## Storage

If persistence is enabled, each server Pod requires one Physical Volume. You either need to create a
[persistent volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#static) for each server Pod, or specify a
storage class that supports [dynamic provisioning](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#dynamic).

If these persistent volumes are to be created manually, this must be done by the system administrator who will add these to a central pool before the Helm chart can be installed. The installation will then claim the required number of persistent volumes from this pool. For manual creation, `persistence.useDynamicProvisioning` must be disabled in the Helm chart when it is installed. It is up to the administrator to provide appropriate storage to back these physical volumes.

If these persistent volumes are to be created automatically at the time of installation, the system administrator must enable support for this prior to installing the Helm chart. For automatic creation `persistence.useDynamicProvisioning` should be enabled in the Helm chart when it is installed and storage class names provided to define which types of Persistent Volume get allocated to the deployment. If `persistence.storageClassName` is not specified, the default StorageClass setup by kube Administrator would be used.

More information about persistent volumes and the system administration steps required can be found [here](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

## Limitations

See release notes (RELEASENOTES.md) for the list of limitations.

## Documentation

For more information about WebSphere Application Server traditional, visit [Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_9.0.0/com.ibm.websphere.base.doc/ae/welcome_base.html).
