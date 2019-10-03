# IBM-Nodejs-LoopBack Helm Chart

Encapsulates Helm chart and other cloud pak artifacts for a [Node.js](http://nodejs.org) LoopBack application.

## Introduction

[Node.js](http://nodejs.org) is an open source runtime build on the V8 JavaScript Engine.
[LoopBack](http://loopback.io) is an open source server-side web framework written in Node.js.

## Resources Required

Minimum resources required will be dependant on your application. 

## Chart Details

This chart will install the following:

* One [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) to rollout a [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/) to create [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/) with Node.js based containers.
* A [NodePort Service](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport) to enable secure connection from outside the cluster.

## Prerequisites

You will need to provide your own Node.js LoopBack application. This chart does not include an application image of its own.

If you prefer to install from the command prompt, you will need:

* The `cloudctl`, `kubectl` and `helm` commands available.
* Your environment configured to connect to the target cluster.

The installation environment has the following prerequisites:
                                                                                                          
* Kubernetes version `>=1.9.1`.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-nodejs-loopback-psp
    spec:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      allowedCapabilities:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      runAsUser:
        rule: RunAsAny
      fsGroup:
        rule: RunAsAny
      volumes:
      - configMap
      - secret
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-nodejs-loopback-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-nodejs-loopback-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
- From the command line, you can run the setup scripts included under pak_extensions
  
  As a cluster admin the pre-install instructions are located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh
  As team admin the namespace scoped instructions are located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

#### Configuration scripts can be used to create the required resources

Download the following scripts located at [/ibm_cloud_pak/pak_extensions/pre-install](https://github.com/IBM/charts/tree/master/stable/kitura/ibm_cloud_pak/pak_extensions/pre-install) directory.

* The pre-install instructions are located at `clusterAdministration/createSecurityClusterPrereqs.sh` for cluster admins to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team admin/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

#### Configuration scripts can be used to clean up resources created

Download the following scripts located at [/ibm_cloud_pak/pak_extensions/post-delete](https://github.com/IBM/charts/tree/master/stable/ibm-nodejs-loopback/ibm_cloud_pak/pak_extensions/post-delete) directory.

* The post-delete instructions are located at `clusterAdministration/deleteSecurityClusterPrereqs.sh` for cluster admins to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team admin/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

#### Creating the required resources

This chart defines a custom `SecurityContextConstraints` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using the supplied instructions or scripts in the `pak_extensions/pre-install` directory.

* From the user interface, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`
  * Custom `SecurityContextConstraints` definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    name: ibm-nodejs-loopback-scc
  readOnlyRootFilesystem: false
  allowedCapabilities:
  - CHOWN
  - DAC_OVERRIDE
  - SETGID
  - SETUID
  - NET_BIND_SERVICE
  seLinuxContext:
    type: RunAsAny
  supplementalGroups:
    type: RunAsAny
  runAsUser:
    type: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes:
  - configMap
  - secret
  ```

* From the command line, you can run the setup scripts included under `pak_extensions/pre-install`
  As a cluster admin the pre-install instructions are located at:
  * `pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`

  As team admin the namespace scoped instructions are located at:
  * `pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`

## Installing the Chart

There are two steps to run your LoopBack application:

* Create a Node.js LoopBack application image 
  * For information on LoopBack see https://loopback.io/doc/en/lb4/
* Install the Helm chart

### Install the Helm chart

Add the internal Helm repository called `local-charts` to the Helm CLI as an external repository, as described [here](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/app_center/add_int_helm_repo_to_cli.html).

Install the chart, specifying the release name and namespace with the following command:

```bash
helm install --name <release_name> --namespace=<namespace_name> loopback --tls
```

NOTE: The release name should consist of lower-case alphanumeric characters and not start with a digit or contain a space.

The command deploys a Node.js application with LoopBack included on the Kubernetes cluster with the default configuration.

The [Configuration](#configuration) lists the parameters that can be overridden during installation by adding them to the Helm install command as follows:

```bash
--set key=value[,key=value]
```

### Verifying the Chart

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status my-release`

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm delete my-release --purge --tls
```

## Configuration

The following tables lists the configurable parameters of the Node.js LoopBack chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `replicaCount`             | The number of desired replica pods that run simultaneously                   | `1`                           |
| `image.repository`         | Docker image repository                         | ``                             |
| `image.pullPolicy`         | Docker image pull policy. Defaults to `Always` when the latest tag is specified.                             | `IfNotPresent`       |
| `image.tag`                | Docker image tag                                | ``                                          |
| `image.pullSecrets`        | Image pull secrets, if using Docker registries that require credentials. | `[]`                                |
| `image.extraEnvs`          | Additional Environment Variables                | `[]`                                                       |
| `image.extraVolumeMounts`  | Extra Volume Mounts                             | `[]`                                                       |
| `image.security`           | Configure the security attributes of the image  | `{}`                                                       |
| `image.readinessProbe.initialDelaySeconds`| Number of seconds after the container has started before readiness probe is initiated | `30`  |
| `image.readinessProbe.periodSeconds`| How often (in seconds) to perform the readiness probe. Minimum value is 1  | `5`                          |
| `image.readinessProbe.httpGet.path`| Path to access on the server | `/health`                                                                         |
| `image.livenessProbe.initialDelaySeconds`| Number of seconds after the container has started before liveness probe is initiated | `180`         |
| `image.livenessProbe.periodSeconds`| How often (in seconds) to perform the liveness probe. Minimum value is 1 | `20`                            |
| `image.livenessProbe.httpGet.path`| Path to access on the server | `/health`                            |
| `deployment.annotations`   | Custom deployment annotations                   | `{}`                                                       |
| `deployment.labels`        | Custom deployment labels                        | `{}`                                                       |
| `pod.annotations`          | Custom pod annotations                          | `{}`                                                       |
| `pod.labels`               | Custom pod labels                               | `{}`                                                       |
| `pod.extraVolumes`         | Additional Volumes for server pods.             | `{}`                                                       |
| `pod.security`             | Configure the security attributes of the pod    | `{}`
| `service.type`             | Kubernetes service type exposing ports| `NodePort`                                                 |
| `service.name`             | Kubernetes service name for HTTP                                | `https-was`                                                |
| `service.externalPort`             | The abstracted service port for HTTP, which other pods use to access this service                     | `3000`              |
| `service.annotations`      | Kubernetes service custom annotations"|        `{}`                                                 |
| `service.labels`           | Kubernetes service custom labels"|        `{}`                                                      |
| `ingress.enabled`          | Specifies whether to enable [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)                                  | `false`                                                    |
| `ingress.rewriteTarget`    | Specifies the target URI where the traffic must be redirected  |  | |
| `ingress.path`             | Specifies the path for the Ingress HTTP rule  | | |
| `ingress.host`             | Specifies a fully qualified domain names of Ingress, as defined by RFC 3986 |  | |
| `ingress.secretName`       | Specifies the name of the Kubernetes secret that contains Ingress' TLS certificate and key |   | |
| `ingress.annotations`      | Kubernetes ingress custom annotations |        `{}`                                                 |
| `ingress.labels`           | Kubernetes ingress custom labels      |        `{}`                                                      |
| `ingress.hosts`             | Specifies an array of fully qualified domain names of Ingress, as defined by RFC 3986. | `[]` |
| `autoscaling.enabled`      | Enables a Horizontal Pod Autoscaler. Enabling this field disables the `replicaCount` field | `false`         |
| `autoscaling.minReplicas`  | Lower limit for the number of pods that can be set by the autoscaler              | `1`                      |
| `autoscaling.maxReplicas`  | Upper limit for the number of pods that can be set by the autoscaler. It cannot be lower than `minReplicas`| `10`     |
| `autoscaling.targetCPUUtilizationPercentage` | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods | `50` |
| `resources.requests.memory`| Describes the minimum amount of memory required. Corresponds to `requests.memory` in Kubernetes.                        | `128Mi`   |
| `resources.requests.cpu`   | Describes the minimum amount of CPU required. Corresponds to `requests.cpu` in Kubernetes                           | `100m`        |
| `resources.limits.memory`  | Describes the maximum amount of memory allowed                          | `128Mi`                                   |
| `resources.limits.cpu`     | Describes the maximum amount of CPU allowed                             | `100m`                                       |
| `rbac`      | `install`             | Install RBAC. Set to `true` if using a namespace with RBAC. | `true` |
| `arch.amd64`               | Architecture preference for amd64 worker node   | `3 - Most peferred`                                        |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install ...`.

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

$ helm install --name my-release --namespace=my-namespace loopback --values=my-values.yaml
```

## Configure Default Values.yaml Variables

### Configure Image Variables

#### Extra Environment

Configuring the `image.extraEnvs` property allows you to provide your own custom environment variables to the container within a pod. For example you could set a custom log level for your LoopBack application: 
```yaml
extraEnvs: 
  LOG_LEVEL: "error"
```
Which could then be consumed within your LoopBack application. 

For more information about `extraEnvs` capabilities see the [Kubernetes Evironment Variables](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/) documentation.

#### Extra Volume Mounts

Configuring the `image.extraVolumeMounts` property allows you to provide additional volume mounts for your Pod. A volume is just a directory, possibly with some data in it, which is accessible to the Containers in a Pod. How that directory comes to be, the medium that backs it, and the contents of it are determined by the particular volume type used.

To see a list of volume types available and how to configure them see the [Kubernetes Volume](https://kubernetes.io/docs/concepts/storage/volumes/) documentation.

#### Security

Configuring the `image.security` property allows you to provide custom pod security context to an image. This will overwrite the default configuration which is as follows:
```yaml
podSecurityContext:
  securityContext:
    privileged: false
    readOnlyRootFilesystem: false
    allowPrivilegeEscalation: false
    capabilities:
      drop:
      - ALL
      add:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
```

For more information about security context see the [Kubernetes Security Context for a Pod or Container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) documentation.

### Configure Deployment Variables

#### Annotations

Configuring the `deployment.annotations` property allows you to add custom annotations to your Deployment Object. 

For more information on Annotations see the [Kubernetes Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) documentation.

#### Labels

Configuring the `deployment.labels` property allows you to add custom labels to your Deployment Object. 

For more information on Labels see the [Kubernetes Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) documentation.

### Configure Pod Variables

#### Annotations

Configuring the `pod.annotations` property allows you to add custom annotations to your Pod Object. 

For more information on Annotations see the [Kubernetes Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) documentation.

#### Labels

Configuring the `pod.labels` property allows you to add custom labels to your Pod Object. 

For more information on Labels see the [Kubernetes Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) documentation.

#### Extra Volumes

A volume is just a directory, possibly with some data in it, which is accessible to the Containers in a Pod. How that directory comes to be, the medium that backs it, and the contents of it are determined by the particular volume type used.

To see a list of volume types available and how to configure them see the [Kubernetes Volume](https://kubernetes.io/docs/concepts/storage/volumes/) documentation.

#### Security

Configuring the `pod.security` property allows you to provide custom pod security policy to an image. For example:
```yaml
security:
    hostNetwork: false
    hostPID: false
    hostIPC: false
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
```

For more information on Pod Security Policy see the [Kubernetes Pod Security Policies](https://kubernetes.io/docs/concepts/policy/pod-security-policy/) documentation.

### Configure Service Variables

#### Annotations

Configuring the `service.annotations` property allows you to add custom annotations to your Service Object. 

For more information on Annotations see the [Kubernetes Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) documentation.

#### Labels

Configuring the `service.labels` property allows you to add custom labels to your Service Object. 

For more information on Labels see the [Kubernetes Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) documentation.

### Configure Ingress Variables

#### Annotations

Configuring the `ingress.annotations` property allows you to add custom annotations to your Ingress Object. 

For more information on Annotations see the [Kubernetes Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) documentation.

#### Labels

Configuring the `ingress.labels` property allows you to add custom labels to your Ingress Object. 

For more information on Labels see the [Kubernetes Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) documentation.

#### Hosts

Configuring the `ingress.hosts` property allows you to provide an array of hosts to determine the paths on which the ingress rules will bind to. For examples:

```yaml
ingress: 
  hosts: ['foo.bar.com']
```

Would state that the rules apply to that host only.

For more information on Ingress see the [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) documentation.

### User provided certificates

Users should uncomment the appropiate section of the Helm chart and insert a reference to their certificates.

## Considerations for Application developers

### Backup and recovery

Application developers should consider appropiate backup and recovery procedures.

### Encryption of data at rest

Application developers should consider appropiate encryption of application data.

### Monitoring

Monitoring is enabled by default

## Limitations

This chart is only available on Linux Intel platforms.

## Documentation

For more information about LoopBack, visit the [LoopBack Website](https://loopback.io/).
