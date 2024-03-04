  # (CHARTNAME) (-Beta)
* [(PRODUCTNAME)](https://<PRODUCTURL>) is ... brief sentence regarding product
* Add "-Beta" as suffix if beta version - beta versions are generally < 1.0.0
* Don't include versions of charts or products

## Introduction
This chart ...
* Paragraph overview of the workload
* Include links to external sources for more product info
* Don't say "for xxx" - the chart should remain a general chart not directly stating target platform. 

## Chart Details
* Simple bullet list of what is deployed as the standard config
* General description of the topology of the workload 
* Keep it short and specific with items such as : ingress, services, storage, pods, statefulsets, etc. 

## Prerequisites
* See the [IBM Cloud Pak Dependency Management Guidance](https://ibm.biz/Bdfjqd) for help with this section.
* Kubernetes Level - indicate if specific APIs must be enabled (i.e. Kubernetes 1.6 with Beta APIs enabled)
* PersistentVolume requirements (if persistence.enabled) - PV provisioner support, StorageClass defined, etc. (i.e. PersistentVolume provisioner support in underlying infrastructure with ibmc-file-gold StorageClass defined if persistance.enabled=true)
* Simple bullet list of CPU, MEM, Storage requirements
* Even if the chart only exposes a few resource settings, this section needs to be inclusive of all / total resources of all charts and subcharts.
* Describe any custom image policy requirements if using a non-whitelisted image repository.
* 
### SecurityContextConstraints Requirements
_WRITER NOTES:  Replace the Predefined SCC Name and SCC Definition with the required values in your chart.  See [ https://ibm.biz/icppbk-psp] for help._

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined OpenShift SecurityContextConstraints name: `anyuid` has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-chart-dev-scc
    readOnlyRootFilesystem: false
    allowedCapabilities:
    - CHOWN
    - DAC_OVERRIDE
    - SETGID
    - SETUID
    - NET_BIND_SERVICE
    seLinux:
      type: MustRunAs
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

## Resources Required
* Describes Minimum System Resources Required

## Pre-install steps

Before installing the chart to your cluster, the cluster admin must perform the following pre-install steps.

* Create a namespace
* Create a ServiceAccount
    ```
    apiVersion: v1
    kind: ServiceAccount
    metadata: 
      name: {{ sa_name }}-nginxref-nginx
    imagePullSecrets:
    - name: sa-{{ NAMESPACE }}
    ```
* Create a RoleBinding
    ```
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: RoleBinding
    metadata: 
      name: {{ rb_name }}-rb
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: {{ role_name }}-role
    subjects:
    - kind: ServiceAccount
      name: {{ sa_name }}-nginxref-nginx
      namespace: {{ NAMESPACE }}
    ```
* Create a Role
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata: 
      name: {{ role_name }}-role
    rules: 
    - apiGroups: 
      - ""
      resources: 
      - configmaps
      verbs: 
      - get
      - watch
      - list
    ```

If you use the custom security configuration provided here, you must specify messagesight-sa as the service account for your charts.


## Installing the Chart
* Include at the basic things necessary to install the chart from the Helm CLI - the general happy path
* Include setup of other items required
* Security privileges required to deploy chart (role, SecurityContextConstraint, etc)
* Include verification of the chart 
* Ensure CLI only and avoid any product-specific language used

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --namespace <your pre-created namespace> --name my-release stable/<chartname>
```

The command deploys <Chart name> on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.


> **Tip**: List all releases using `helm list`

* Generally teams have subsections for : 
   * Verifying the Chart
   * Uninstalling the Chart

### Verifying the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --tls.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions with additional commands required for clean-up.  

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
```

### Cleanup any pre-reqs that were created
If cleanup scripts were included in the pak_extensions/post-delete directory; run them to cleanup namespace and cluster scoped resources when appropriate.

## Configuration
* Define all the parms in the values.yaml 
* Include "how used" information
* If special configuration impacts a "set of values", call out the set of values required (a = true, y = abc_value, c = 1) to get a desired outcome. One example may be setting on multiple values to turn on or off TLS. 

The following tables lists the configurable parameters of the <CHARTNAME> chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `replicaCount`             | Number of deployment replicas                   | `1`                                                        |
| `image.repository`         | `PRODUCTNAME` image repository                  | `nginx`                                                    |
| `image.pullPolicy`         | Image pull policy                               | `Always` if `imageTag` is `latest`, else `IfNotPresent`    |
| `image.tag`                | `PRODUCTNAME` image tag                         | `stable`                                                   |
| `service.type`             | k8s service type exposing ports, e.g. `NodePort`| `ClusterIP`                                                |
| `service.externalPort`     | External TCP Port for this service              | `80`                                                       |
| `ingress.enabled`          | Ingress enabled                                 | `false`                                                    |
| `ingress.hosts`            | Host to route requests based on                 | `false`                                                    |
| `ingress.annotations`      | Meta data to drive ingress class used, etc.     | `nil`                                                      |
| `ingress.tls`              | TLS secret to secure channel from client / host | `nil`                                                      |
| `resources.requests.memory`| Memory resource requests                        | `128Mi`                                                    |
| `resources.requests.cpu`   | CPU resource requests                           | `100m'                                                     |
| `resources.limits.memory`  | Memory resource limits                          | `128Mi`                                                    |
| `resources.limits.cpu`     | CPU resource limits                             | `100m`                                                     |
| `dashboard.enabled`        | Enable automatic load of grafana dashboard      | `true`                                                     |


A subset of the above parameters map to the env variables defined in [(PRODUCTNAME)](PRODUCTDOCKERURL). For more information please refer to the [(PRODUCTNAME)](PRODUCTDOCKERURL) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default values.yaml

## Storage
* Define how storage works with the workload
* Dynamic vs PV pre-created
* Considerations if using hostpath, local volume, empty dir
* Loss of data considerations
* Any special quality of service or security needs for storage

## Limitations
* Deployment limits - can you deploy more than once, can you deploy into different namespace
* List specific limitations such as platforms, security, replica's, scaling, upgrades etc.. - noteworthy limits identified
* List deployment limitations such as : restrictions on deploying more than once or into custom namespaces. 
* Not intended to provide chart nuances, but more a state of what is supported and not - key items in simple bullet form.
* Does it work on ROKS or  ?

## Documentation
* Can have as many supporting links as necessary for this specific workload however don't overload the consumer with unnecessary information.
* Can be links to special procedures in the knowledge center.
