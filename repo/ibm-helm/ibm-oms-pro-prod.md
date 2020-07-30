# ibm-oms-pro-prod

IBM&reg; (IBM Order Management Software Professional Edition v10).

## Introduction

This document describes how to deploy IBM Order Management Software Professional Edition v10. This helm chart does not install database server or messaging server. Both these middlewares need to be setup and configured separately for IBM Order Management Software Professional Edition.

Note: This helm chart supports deployment of IBM Order Management Software Professional Edition with DB2 database and MQ messaging.

## Chart Details

This chart will do the following:

- Create a deployment `<release name>-ibm-oms-pro-prod-appserver` for IBM Order Management application server with 1 replica by default.
- Create a deployment `<release name>-ibm-oms-pro-prod-healthmonitor` for IBM Order Management HealthMonitor agent, if health monitor is enabled.
- Create a deployment `<release name>-ibm-oms-pro-prod-<server name>` for each of the IBM Order Management agent or integration server configured.
- Create a service `<release name>-ibm-oms-pro-prod`. This service is used to access the application server using a consistent IP address.
- Create a job `<release name>-ibm-oms-pro-prod-datasetup`. It is used for performing data setup that is required to deploy and run the applications. This may not be created if the data setup is disabled at the time of install or upgrade.
- Create a job `<release name>-ibm-oms-pro-prod-preinstall`. This is used to perform pre-installation activities like generating ingress tls secret.
- Create a ConfigMap `<release name>-ibm-oms-pro-prod-config`. This is used to provide Order Management and Liberty configuration.
- Create a ConfigMap `<release name>-ibm-oms-pro-prod-def-server-xml-conf`. This is used to provide default server.xml for Liberty. This will not be created if a custom server.xml is used.

**Note** : `<release name>` refers to the name of the helm release and `<server name>` refers to the agent/integration server name.

## Prerequisites

1. Kubernetes version >= 1.11.3

2. Helm version >= 3.0.0

3. Ensure that DB2 database server is installed and the database is accessible from inside the cluster. For database timezone considerations refer section "Timezone considerations".

4. Ensure that MQ server is installed and the MQ server is accessible from inside the cluster.

5. Ensure that the docker images for IBM Order Management Software Professional Edition are loaded to an appropriate docker registry. The default images for IBM Order Management Software Professional Edition can be loaded from IBM Passport Advantage. Alternatively, customized images for IBM Order Management Software Professional Edition can also be used.

6. Ensure that the docker registry is configured in Manage -> Resource Security -> Image Policies and also ensure that docker image can be pulled on all of Kubernetes worker nodes.

7. Create a persistent volume with access mode as 'Read write many' with minimum 10GB space.

8. Create a secret with datasource connectivity details as given below. The name of this secret needs to be supplied as the value of parameter `global.appSecret`. It is recommended to prefix the release name to the secret name.

   - Create a yaml file oms_details_temp.yaml as below.

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: '<Release-name>-oms-secret'
   type: Opaque
   stringData:
     consoleadminpassword: '<liberty console admin password>'
     consolenonadminpassword: '<liberty console non admin password>'
     dbpassword: '<password for database user>'
   ```

   - Run the below command. This will encode the values in the above file and create a Secret.

   ```sh
   kubectl create -f oms_details_temp.yaml -n <namespace>

   ```

9. If you are deploying IBM Order Management Software on a namespace other than default, then create a Role Based Access Control(RBAC) if not already created, with cluster admin role.

   - The following is an example of the RBAC for default service account on target namespace as `<namespace>`.

   ```yaml
   kind: Role
   apiVersion: rbac.authorization.k8s.io/v1
   metadata:
     name: oms-role-<namespace>
     namespace: <namespace>
   rules:
     - apiGroups: ['']
       resources: ['secrets']
       verbs: ['get', 'watch', 'list', 'create', 'delete', 'patch', 'update']

   ---
   kind: RoleBinding
   apiVersion: rbac.authorization.k8s.io/v1
   metadata:
     name: oms-rolebinding-<namespace>
     namespace: <namespace>
   subjects:
     - kind: ServiceAccount
       name: default
       namespace: <namespace>
   roleRef:
     kind: Role
     name: oms-role-<namespace>
     apiGroup: rbac.authorization.k8s.io
   ```

10. Before configuring any agents or integration server in the chart, read the instructions provided in the "Configuring Agent or Integration Servers" section.

11. Installing a PodDisruptionBudget.

## Timezone considerations

In order to deploy Order Management Software, the timezone of the database, application servers, and agents should be same. Additionally, this timezone must be compatible with the locale code specified in Order Management Software.
By default, the containers are deployed in UTC, also the locale code in Order Management is set as en_US_UTC. Hence ensure that the database is also deployed in UTC.

## Resources Required

This chart uses the following resources by default:

- 2560Mi memory for application server.
- 1024Mi memory for each agent/integration server and health monitor.
- 1 CPU core for application server.
- 0.5 CPU core for each agent/integration server and health monitor.

## Configuration

### Installation on a new database

When installing the chart on a new database which does not have Order Management Software tables and factory data:

- Ensure that `datasetup.loadFactoryData` parameter is set to `install` and `datasetup.mode` parameter is set as `create`. This will create the required database tables and factory data in the database before installing the chart.
- Ensure that you do not specify any agents/integration servers with parameters `omserver.servers.name`. When installing against a fresh database, you will not have any agent and integration server configured in Order Management and hence it does not make sense to configure agents and integration servers in the chart. Once the application server is deployed, you can configure the agents/integration servers in Order Management. Refer section "Configuring Agent/Integration Servers" on how to deploy agents and integration servers.

### Installation against a pre-loaded database

When installing the chart against a database which already has the Order Management Software tables and factory data ensure that `datasetup.loadFactoryData` parameter is set to `donotinstall` or blank. This will avoid re-creating tables and overwriting factory data.

### The following table lists the configurable parameters for the chart

| Parameter                                                                         | Description                                                                                                                                               | Default                                                  |
| --------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| `global.license`                                                                  | Set the value to `True` in order to accept the application license                                                                                        |
| `global.license_store_call_center`                                                | Set the value to `True` in order to accept the Store and Call Center application license                                                                  |
| `appserver.replicaCount`                                                          | Number of appserver instances                                                                                                                             | `1`                                                      |
| `appserver.image`                                                                 | Docker image details of appserver                                                                                                                         |
| `appserver.exposeRestService`                                                     | This flag is applicable only when route API (`route.openshift.io/v1`) exists. When enabled a new deployment of `om-app` image is created exposing `/smcfs` with a new route having the prefix `xapirest`.              |
| `appserver.config.vendor`                                                         | OMS Vendor                                                                                                                                                | `websphere`                                              |
| `appserver.config.vendorFile`                                                     | OMS Vendor file                                                                                                                                           | `servers.properties`                                     |
| `appserver.config.serverName`                                                     | App server name                                                                                                                                           | `DefaultAppServer`                                       |
| `appserver.config.jvm`                                                            | Server min/max heap size and jvm parameters                                                                                                               | `1024m` min, `2048m` max, no parameters                  |
| `appserver.config.database.maxPoolSize`                                           | DB max pool size                                                                                                                                          | `50`                                                     |
| `appserver.config.database.minPoolSize`                                           | DB min pool size                                                                                                                                          | `10`                                                     |
| `appserver.config.corethreads`                                                    | Core threads for Liberty                                                                                                                                  | `20`                                                     |
| `appserver.config.maxthreads`                                                     | Maximum threads for Liberty                                                                                                                               | `100`                                                    |
| `appserver.config.libertyServerXml`                                               | Custom server.xml for Liberty. Refer section "Customizing server.xml for Liberty"                                                                         |
| `appserver.livenessCheckBeginAfterSeconds`                                        | Approx wait time(secs) to begin the liveness check                                                                                                        | `900`                                                    |
| `appserver.livenessFailRestartAfterMinutes`                                       | Approx time period (mins) after which server is restarted if liveness check keeps failing for this period                                                 | `10`                                                     |
| `appserver.service.type`                                                          | Service type                                                                                                                                              | `NodePort`                                               |
| `appserver.service.http.port`                                                     | HTTP container port                                                                                                                                       | `9080`                                                   |
| `appserver.service.http.nodePort`                                                 | HTTP external port                                                                                                                                        | `30080`                                                  |
| `appserver.service.https.port`                                                    | HTTPS container port                                                                                                                                      | `9443`                                                   |
| `appserver.service.https.nodePort`                                                | HTTPS external port                                                                                                                                       | `30443`                                                  |
| `appserver.resources`                                                             | CPU/Memory resource requests/limits                                                                                                                       | Memory: `2560Mi`, CPU: `1`                               |
| `appserver.ingress.enabled`                                                       | Whether Ingress settings enabled                                                                                                                          | true                                                     |
| `appserver.ingress.host`                                                          | Ingress host                                                                                                                                              |
| `appserver.ingress.controller`                                                    | Controller class for ingress controller                                                                                                                   | nginx                                                    |
| `appserver.ingress.contextRoots`                                                  | Context roots which are allowed to be accessed through ingress                                                                                            | ["smcfs", "sbc", "sma", "isccs", "wsc", "adminCenter"]   |
| `appserver.ingress.annotations`                                                   | Annotations for the ingress resource                                                                                                                      |
| `appserver.ingress.ssl.enabled`                                                   | Whether SSL enabled for ingress                                                                                                                           | true                                                     |
| `appserver.podLabels`                                                             | Custom labels for the appserver pod                                                                                                                       |
| `appserver.tolerations`                                                           | Tolerations for appserver pod. Specify in accordance with k8s PodSpec.tolerations. Refer section "Affinity and Tolerations".                              |
| `appserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`           | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                        |
| `appserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`          | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                       |
| `appserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`            | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                         |
| `appserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`           | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                        |
| `appserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`        | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                     |
| `appserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`       | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                    |
| `appserver.podAntiAffinity.replicaNotOnSameNode`                                  | Directive to prevent scheduling of replica pod on the same node. valid values: `prefer`, `require`, blank. Refer section "Affinity and Tolerations".      | `prefer`                                                 |
| `appserver.podAntiAffinity.weightForPreference`                                   | Preference weighting 1-100. Used if 'prefer' is specified for `appserver.podAntiAffinity.replicaNotOnSameNode`. Refer section "Affinity and Tolerations". | 100                                                      |
| `omserver.image`                                                                  | Docker image details of agent server                                                                                                                      |
| `omserver.deployHealthMonitor`                                                    | Deploy health monitor agent                                                                                                                               | `true`                                                   |
| `omserver.common.jvmArgs`                                                         | Default JVM args that will be passed to the list of agent servers                                                                                         |
| `omserver.common.replicaCount`                                                    | Default number of instances of agent servers that will be deployed                                                                                        |
| `omserver.common.resources`                                                       | Default CPU/Memory resource requests/limits                                                                                                               | Memory: `1024Mi`, CPU: `0,5`                             |
| `omserver.common.readinessFailRestartAfterMinutes`                                | Approx time period (mins) after which agent is restarted if readiness check keeps failing for this period                                                 | 10                                                       |
| `omserver.common.podLabels`                                                       | Custom labels for the agent pod                                                                                                                           |
| `omserver.common.tolerations`                                                     | Tolerations for agent pod. Specify in accordance with k8s PodSpec.tolerations. Refer section "Affinity and Tolerations".                                  |
| `omserver.common.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                        |
| `omserver.common.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`    | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                       |
| `omserver.common.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`      | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                         |
| `omserver.common.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                        |
| `omserver.common.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`  | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                     |
| `omserver.common.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".                                    |
| `omserver.common.podAntiAffinity.replicaNotOnSameNode`                            | Directive to prevent scheduling of replica pod on the same node. valid values: `prefer`, `require`, blank. Refer section "Affinity and Tolerations".      | `prefer`                                                 |
| `omserver.common.podAntiAffinity.weightForPreference`                             | Preference weighting 1-100. Used if 'prefer' is specified for `appserver.podAntiAffinity.replicaNotOnSameNode`. Refer section "Affinity and Tolerations". | 100                                                      |
| `omserver.servers.group`                                                          | Agent server group name                                                                                                                                   | `Default Servers`                                        |
| `omserver.servers.name`                                                           | List of agent server names                                                                                                                                |
| `omserver.servers.jvmArgs`                                                        | JVM args that will be passed to the list of agent servers                                                                                                 |
| `omserver.servers.replicaCount`                                                   | Number of instances of agent servers that will be deployed                                                                                                |
| `omserver.servers.resources`                                                      | CPU/Memory resource requests/limits                                                                                                                       | Memory: `1024Mi`, CPU: `0,5`                             |
| `datasetup.loadFactoryData`                                                       | Load factory data                                                                                                                                         |
| `datasetup.mode`                                                                  | Run factory data load in create                                                                                                                           | `create`                                                 |
| `global.mq.bindingConfigName`                                                     | Name of the mq binding file config map                                                                                                                    |
| `global.mq.bindingMountPath`                                                      | Path where the binding file will be mounted                                                                                                               | `/opt/ssfs/.bindings`                                    |
| `global.persistence.claims.name`                                                  | Persistent volume name                                                                                                                                    | oms-common                                               |
| `global.persistence.claims.accessMode`                                            | Access Mode                                                                                                                                               | ReadWriteMany                                            |
| `global.persistence.claims.capacity`                                              | Capacity                                                                                                                                                  | 10                                                       |
| `global.persistence.claims.capacityUnit`                                          | CapacityUnit                                                                                                                                              | Gi                                                       |
| `global.persistence.securityContext.fsGroup`                                      | File system group id to access the persistent volume                                                                                                      | 0                                                        |
| `global.persistence.securityContext.supplementalGroup`                            | Supplemental group id to access the persistent volume                                                                                                     | 0                                                        |
| `global.image.repository`                                                         | Repository for Order management images                                                                                                                    |
| `global.appSecret`                                                                | Order management secret name                                                                                                                              |
| `global.database.dbvendor`                                                        | DB Vendor DB2/Oracle                                                                                                                                      | DB2                                                      |
| `global.database.serverName`                                                      | DB server IP/host                                                                                                                                         |
| `global.database.port`                                                            | DB server port                                                                                                                                            |
| `global.database.dbname`                                                          | DB name or catalog name                                                                                                                                   |
| `global.database.user`                                                            | DB user                                                                                                                                                   |
| `global.database.datasourceName`                                                  | external datasource name                                                                                                                                  | jdbc/OMDS                                                |
| `global.database.systemPool`                                                      | is DB system pool                                                                                                                                         | true                                                     |
| `global.database.schema`                                                          | Database schema name.For Db2 it is defaulted as `global.database.dbname` and for Oracle it is defaulted as `global.database.user`                         |
| `global.serviceAccountName`                                                       | Service account name                                                                                                                                      |
| `global.customerOverrides`                                                        | array of customer overrides properties as `key=value`                                                                                                     |
| `global.envs`                                                                     | environment variables as array of kubernetes `EnvVars` objects                                                                                            |
| `global.arch`                                                                     | Architecture affinity while scheduling pods                                                                                                               | amd64: `2 - No preference`, ppc64le: `2 - No preference` |

### Deploying Multiple Application Images
The chart provides ability to deploy multiple application images as part of the a single helm release. This can be done using the new structure of appserver.images,

```yaml
appserver:
  replicaCount: 1
  image:
    tag: 10.0.0.12
    pullPolicy: IfNotPresent
    names:
    - name: om-app
      tag: 10.0.0.12
    - name: om-app-isccs_sbc
    - name: om-app-sma_wsc
      applications:
      - path: "/sma"
      - path: "/wsc"
        routePrefix: webstore
      replicaCount: 2
```
The `appserver.image.names` can be used to pass an array of image names with additional optional configuration for specifying paths to be exposed, route prefixes to be used, tag names and replicaCounts.

In the above example, 3 deployments will be made for the 3 images listed (`om-app`, `om-app-isccs_sbc` and `om-app-sma_wsc`). The routes and paths exposed will follow the below convention,

- If image name is `om-app` and no paths are defined, all the contexts defined in `appserver.ingress.contextRoots` will be exposed. The `routePrefix` will be defaulted to `<context>-default`. For example, `smcfs-default`, `sbc-default` etc.
- If image name is `om-app-<modules>`, the module names are broken using hyphen (`-`) and underscore (`_`) characters to form a list of modules. The `routePrefix` will be defaulted to `<context>-app-default`. For example, for the image named `om-app-isccs_sbc`, the paths exposed are `isccs` and `sbc` with `routePrefix`es  `isccs-app-default` and `sbc-app-default` respectively.
- If image name is provided along with `path` information only, `routePrefix` will be defaulted to `<path>-path-default`. For example, if only `- path: "/sma"` is provided with no `routePrefix`, the `routePrefix` will be computed to `sma-path-default`.
- In all the cases, if `routePrefix` is provided, the routes will be exposed with the provided prefix. Also, when paths are explicitly listed under `applications`, only the listed paths will be exposed through the routes. For example, if `om-app` image is provided with `path: "/smcfs"`, only smcfs context root will be exposed in the route.

### Deploying REST API Service
If route API (`route.openshift.io/v1`) exists in the cluster, `appserver.exposeRestService` can be used to create a deployment dedicated for REST API. When set to true, a new deployment with image `om-app` and tag as provided in `appserver.image.tag` will be created with a dedicated service and an associated route. The route will be prefixed with `xapirest`.

### Accessing Deployed Applications

#### Kubernetes Ingress Configuration

- Ingress can be enabled by setting the parameter `appserver.ingress.enabled` as true. If ingress is enabled, then the application is exposed as a `ClusterIP` service, otherwise the application is exposed as `NodePort` service. It is recommended to enable and use ingress for accessing the application from outside the cluster. `NodePort` service should be avoided.

- `appserver.ingress.host` - the fully-qualified domain name that resolves to the IP address of your cluster’s proxy node. Based on your network settings it may be possible that multiple virtual domain names resolve to the same IP address of the proxy node. Any of those domain names can be used. For example "example.com" or "test.example.com" etc.

- `appserver.ingress.ssl.enabled` - It is strongly recommended to enable SSL. If SSL is enabled by setting this parameter to true, a secret is needed to hold the TLS certificate.
  If the optional parameter `appserver.ingress.ssl.secretname` is left as blank, a secret containing a self signed certificate is automatically generated.

  However, for **production environments** it is strongly recommended to obtain a CA certified TLS certificate and create a secret manually as below.

  1. Obtain a CA certified TLS certificate for the given `appserver.ingress.host` in the form of key and certificate files.
  2. Create a secret from the above key and certificate files by running below command

     ```sh
     kubectl create secret tls <Release-name>-ingress-secret --key <file containing key> --cert <file containing certificate> -n <namespace>
     ```

  3. Use the above created secret as the value of the parameter `appserver.ingress.ssl.secretname`.

- `appserver.ingress.contextRoots` - The context roots which are allowed to be accessed through ingress. By default the following context roots are allowed.
  `smcfs`, `sbc`, `sma`, `isccs`, `wsc`, `adminCenter`. If any additional context root needs to be allowed through ingress then the same needs to be added to this list.

#### Red Hat OpenShift Route Configuration

- If using Red Hat OpenShift cluster, routes can be enabled by setting the parameter `appserver.ingress.enabled` as true. If routes are enabled, then the application is exposed as a `ClusterIP` service, otherwise the application is exposed as `NodePort` service. It is recommended to enable and use routes for accessing the application from outside the cluster. `NodePort` service should be avoided.
- `appserver.ingress.host` - the fully-qualified domain name of the cluster through which applications are exposed.
- `appserver.ingress.ssl.enabled` - It is strongly recommended to enable SSL. If SSL is enabled by setting this parameter to true, routes are created with https egress URL. Also, the routes will be exposed with the cluster's default certificate.

However, for **production environments** it is strongly recommended to obtain a CA certified TLS certificate and update the routes manually as below.

1. Obtain a CA certified TLS certificate for the given `appserver.ingress.host` in the form of key and certificate files.
2. The below script will allow patching all the routes created through the helm install with the certificate information based on the `<Release_name>`.

```
CRT_FN=<Path to Certificate>
KEY_FN=<Path to Private Key>
CABUNDLE_FN=<Path to CA Bundle File>

CERTIFICATE="$(awk '{printf "%s\\n", $0}' ${CRT_FN})"
KEY="$(awk '{printf "%s\\n", $0}' ${KEY_FN})"
CABUNDLE=$(awk '{printf "%s\\n", $0}' ${CABUNDLE_FN})

oc patch route $(oc get routes -l release=<Release_name> -o jsonpath="{.items[*].metadata.name}") -p '{"spec":{"tls":{"certificate":"'"${CERTIFICATE}"'", "key":"'"${KEY}"'" ,"caCertificate":"'"${CABUNDLE}"'"}}}'
```

### Network Policy

- A network policy is a specification of how groups of pods are allowed to communicate with each other and other network endpoints.
- The Kubernetes NetworkPolicy resource provides firewall capabilities to pods, similar to AWS Security groups, and it programs the software defined networking infrastructure (OpenShift Default, Flannel, etc...). You can implement sophisticated network access policies to control ingress access to your workload pods.
- The default NetworkPolicy `default-network-policy` is provided that allows communications of pods that have role as `appserver`. For e.g.

  ```yaml
  ---
  kind: NetworkPolicy
  apiVersion: networking.k8s.io/v1
  metadata:
    name: <Release-name>-network-policy
  spec:
    podSelector:
      matchLabels:
        role: appserver
  ```

- To implement your own NetworkPolicy, you can follow the steps documented here [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

### Configuring Agent/ or Integration Servers

Once you have a deployment ready with application server running, you can configure the agents and integration servers by logging into the IBM Order Management Application Manager. After completing the changes as described below, the release needs to be upgraded. Refer below for more details.

### IBM Order Management Software Professional Edition related configuration

- You need to define the agent and integration servers in the Application Manager.
- Once the agent or integration servers are defined, you can deploy (start) the same by providing the names of those agent or integration servers as a list to `omserver.servers.name` parameter in the chart values.yaml. For e.g.

```yaml
---
servers:
  - group: 'Logical Group 1'
    name:
      - scheduleOrder
      - releaseOrder
    jvmArgs: "-Xms512m\ -Xmx1024m"
    replicaCount: 1
    resources:
      requests:
        memory: 1024Mi
        cpu: 0.5

  - group: 'Logical Group 2'
    name:
      - integrationServer1
      - orderPurge
    jvmArgs: "-Xms512m\ -Xmx1024m"
    replicaCount: 2
    resources:
      requests:
        memory: 1024Mi
        cpu: 0.5
```

Please note you cannot use underscore`(_)` character while defining the agent/integration server name.

- The parameters directly inside `omserver.common` e.g. jvmArgs, resources, tolerations etc will be applied to each of the `omserver.servers`. These parameters can also be overriden in each of `omserver.servers`. All the agent servers defined under the same group will share the same `omserver.common` parameters, e.g. `resources`. You can define multiple groups in `omserver.servers[]` if there is a requirement for different set of `omserver.common` parameters. For e.g, if you have a requirement to run certain agents with higher cpu and memory requests, or a higher replication count, you can define a new group and update its `resources` object accordingly.

### MQ related configuration

- Ensure that all the JMS resources configured in IBM Order Management Software agents and integration servers are configured in MQ and corresponding `.bindings` file generated.
- Create a ConfigMap for storing the MQ bindings. E.g. you can use the below command to create the ConfigMap from a given ".bindings" file.

```sh
kubectl create configmap <config map name> --from-file=<path_to_.bindings_file> -n <namespace>
```

- Ensure that the above ConfigMap is specified in the parameter `global.mq.bindingConfigName`.

Once the changes are made in the values.yaml file, you need to run the `helm upgrade` command. Refer section "Upgrading the Chart" for details.

## Limitations

- The database must be installed in UTC timezone.

## PodSecurityPolicy Requirements

Note: This section is applicable to generic (non Red Hat OpenShift) k8s platform.

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

- Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: 'This policy allows pods to run with
      any UID and GID, but preventing access to the host.'
  name: ibm-oms-anyuid-psp
spec:
  allowPrivilegeEscalation: true
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
    - MKNOD
  allowedCapabilities:
    - SETPCAP
    - AUDIT_WRITE
    - CHOWN
    - NET_RAW
    - DAC_OVERRIDE
    - FOWNER
    - FSETID
    - KILL
    - SETUID
    - SETGID
    - NET_BIND_SERVICE
    - SYS_CHROOT
    - SETFCAP
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
    - configMap
    - emptyDir
    - projected
    - secret
    - downwardAPI
    - persistentVolumeClaim
  forbiddenSysctls:
    - '*'
```

To create a custom PodSecurityPolicy, create a file `oms_psp.yaml` with the above definition and run the below command

```sh
kubectl create -f oms_psp.yaml
```

- Custom ClusterRole and RoleBinding definitions:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
  name: ibm-oms-anyuid-clusterrole
rules:
  - apiGroups:
      - extensions
    resourceNames:
      - ibm-oms-anyuid-psp
    resources:
      - podsecuritypolicies
    verbs:
      - use

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ibm-oms-anyuid-clusterrole-rolebinding
  namespace: <namespace>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ibm-oms-anyuid-clusterrole
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: Group
    name: system:serviceaccounts:<namespace>
```

The `<namespace>` in the above definition should be replaced with the namespace of the target environment.
To create a custom ClusterRole and RoleBinding, create a file `oms_psp_role_and_binding.yaml` with the above definition and run the below command

```sh
kubectl create -f oms_psp_role_and_binding.yaml
```

## Red Hat OpenShift SecurityContextConstraints Requirements

Note: This section is specific to Red Hat® OpenShift.

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation.

The predefined `SecurityContextConstraints` name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

Alternatively, a custom `SecurityContextConstraints` can be created using:

- Custom SecurityContextConstraints definition:

```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
  name: ibm-oms-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities: []
allowedFlexVolumes: []
defaultAddCapabilities: []
fsGroup:
  type: MustRunAs
  ranges:
    - max: 65535
      min: 1
readOnlyRootFilesystem: false
requiredDropCapabilities:
  - ALL
runAsUser:
  type: MustRunAsNonRoot
seccompProfiles:
  - docker/default
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: MustRunAs
  ranges:
    - max: 65535
      min: 1
volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
priority: 0
```

To create a custom `SecurityContextConstraints`, create a file `ibm-oms-scc.yaml` with the above definition and run the below command:

```sh
kubectl create -f ibm-oms-scc.yaml
```

## Installing the Chart

Prepare a custom values.yaml file based on the configuration section. Ensure that application license is accepted by setting the value of `global.license` and `global.license_store_call_center` to `True`.

To install the chart with the release name `my-release`:

1. Ensure that the chart is downloaded locally by following the instructions given [here.](https://www.ibm.com/support/knowledgecenter/SS6PEW_10.0.0/com.ibm.help.install.omsoftware.doc/installation/c_OMRHOC_download_OMSChart.html)

2. Run the below command:

```sh
helm install --name my-release -f values.yaml ./ibm-oms-pro-prod --timeout 3600 --tls --namespace <namespace>
```

Depending on the capacity of the kubernetes worker node and database connectivity, the whole deploy process can take on average:

- 2-3 minutes for 'installation against a pre-loaded database' and
- 20-30 minutes for 'installation against a fresh new database'

When you check the deployment status, the following values can be seen in the Status column:

- Running: This container is started.
- Init: 0/1: This container is pending on another container to start.

You may see the following values in the Ready column:

- 0/1: This container is started but the application is not yet ready.
- 1/1: This application is ready to use.

Run the following command to make sure there are no errors in the log file:

```sh
kubectl logs <pod_name> -n <namespace> -f
```

## Affinity and Tolerations

The chart provides various ways in the form of node affinity, pod affinity, pod anti-affinity and tolerations to configure advance pod scheduling in kubernetes. Refer the kubernetes documentation for details on usage and specifications for the below features.

- Tolerations - This can be configured using parameter `appserver.tolerations` for the appserver, and parameter `omserver.common.tolerations` for the agent servers.

- Node affinity - This can be configured using parameters `appserver.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `appserver.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the appserver, and parameters `omserver.common.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `omserver.common.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the agent servers.
  Depending on the architecture preference selected for the parameter `global.arch`, a suitable value for node affinity is automatically appended in addition to the user provided values.

- Pod affinity - This can be configured using parameters `appserver.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `appserver.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the appserver, and parameters `omserver.common.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `omserver.common.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the agent servers.

- Pod anti-affinity - This can be configured using parameters `appserver.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `appserver.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the appserver, and parameters `omserver.common.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `omserver.common.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the agent servers.
  Depending on the value of the parameter `podAntiAffinity.replicaNotOnSameNode`, a suitable value for pod anti-affinity is automatically appended in addition to the user provided values. This is to configure whether replicas of a pod should be scheduled on the same node. If the value is `prefer` then `podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` is automatically appended whereas if the value is `require` then `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` is appended. If the value is blank, then no pod anti-affinity value is automatically appended. If the value is `prefer` then the weighting for the preference is set using the parameter `podAntiAffinity.weightForPreference` which should be specified in the range 1-100.

## Readiness and Liveness

Readiness and liveness checks are provided for the agents and application server pods as applicable.

1. Application Server pod
   The following parameters can be used to tune the readiness and liveness checks for application server pods.

   - `appserver.livenessCheckBeginAfterSeconds` - This can be used to specify the delay in starting the liveness check for the application server. The default value is 900 seconds (15 minutes).
   - `appserver.livenessFailRestartAfterMinutes` - This can be used to specify the approximate time period, after which the pod will get restarted if the liveness check keeps on failing continuously for this period of time. The default value is 10 minutes.

   For E.g. if the values for `appserver.livenessCheckBeginAfterSeconds` `appserver.livenessFailRestartAfterMinutes` are `900` and `10` respectively, and the application server pod is not able to start up successfully after `25` minutes, then it will be restarted.
   Further, after the application server has started up successfully, if the liveness check keeps failing continuously for a period of `10` minutes, then it will be restarted.

2. Agent server pod
   The following parameter can be used to tune the readiness check for agent server pods.

- `omserver.common.readinessFailRestartAfterMinutes` - This can be used to specify the approximate time period, after which the pod will get restarted if the readiness check keeps on failing continuously for this period of time. The default value is 10 minutes.
  For E.g. if the value for `omserver.common.readinessFailRestartAfterMinutes` is `10`, and the agent server pod is not able to start up successfully after `10` minutes, then it will be restarted.

## Customizing server.xml for Liberty

A custom server.xml for the liberty application server can be configured as below. Note that if a custom server.xml is not specified then a default server.xml is auto generated.

1. Create the custom server.xml file with the name `server.xml`.

2. Create a ConfigMap containing the custom server.xml with the below command

   ```sh
   kubectl create configmap <config map name> --from-file=<path_to_custom_server.xml> -n <namespace>
   ```

3. Specify the above created ConfigMap in the chart parameter `appserver.config.libertyServerXml`.

**Important Notes:**

1. Ensure that the database information specified in the datasource section of server.xml is same as what is specified in the chart through the object `global.database`.
2. Ensure that the http and https ports in server.xml are same as specified in the chart through the parameters `appserver.service.http.port` and `appserver.service.https.port`.

## Upgrading the Chart

You would want to upgrade your deployment when you have a new docker image for application/agent server or a change in configuration, for e.g. new agent/integration servers to be deployed/started.

1. Ensure that the chart is downloaded locally by following the instructions given [here.](https://www.ibm.com/support/knowledgecenter/SS6PEW_10.0.0/com.ibm.help.install.omsoftware.doc/installation/c_OMRHOC_download_OMSChart.html)

2. Ensure that the `datasetup.loadFactoryData` parameter is set to `donotinstall` or blank. Run the following command to upgrade your deployments.

```sh
helm upgrade my-release -f values.yaml ./ibm-oms-pro-prod --timeout 3600 --tls
```

## Rollback

Sometimes, you may want to roll back your deployment when the deployment is not stable, for e.g. crash looping.

To roll back a release, run the following command where `RELEASE`  is the name of a release and `REVISION` is a revision(version) number:

```sh
helm rollback [RELEASE] [REVISION] --tls
```

More information about Helm Rollback [here.](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/em_icp_rollback.html)

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment run the command:

```sh
 helm delete my-release  --purge --tls
```

Since there are certain kubernetes resources created using the `pre-install` hook, helm delete command will not delete them. You need to manually delete the following resources created by the chart.

- `<release name>-ibm-oms-pro-prod-config`
- `<release name>-ibm-oms-pro-prod-def-server-xml-conf`
- `<release name>-ibm-oms-pro-prod-datasetup`
- `<release name>-ibm-oms-pro-prod-auto-ingress-secret`

Note: You may also consider deleting the secrets and persistent volume created as part of prerequisites.
