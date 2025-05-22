# IBM Connect:Direct Web Services V6.4.0

## Introduction

IBM Connect:Direct Web Services targets transforming the Managed File Transfer market with a modern user experience and help your business by:
- Reducing the operating cost
- Deploying solutions rapidly
- Opening new opportunities by enabling easy integration with other Web service-based applications
IBM Connect:Direct Web Services extends a Web-based User Interface (Web Console) and a RESTful API-based interface to Connect:Direct users. To find out more, see the Knowledge Center for [ IBM Connect:Direct Web Services ](  https://www.ibm.com/docs/en/connect-direct/6.4.0?topic=sterling-connectdirect-web-services-v64 ).

## Chart Details

This chart deploys IBM Connect:Direct Web Services on a container management platform with the following resources deployments

- a statefulset pod `<release-name>-ibm-cdws` with 1 replica by default.
- a configMap `<release-name>-ibm-cdws`. This is used to provide default configuration in cdws_param_file.
- a service `<release-name>-ibm-cdws`. This is used to expose the Connect:Direct Web Services services for access using clients.
- a service-account `<release-name>-ibm-cdws-serviceaccount`. This service will not be created if `serviceAccount.create` is `false`.
- a persistence volume claim `<release-name>-ibm-cdws-pvc`.

## Prerequisites

1. Red Hat OpenShift Container Platform Version should be >= 4.14 and <=4.17
2. Kubernetes version >= 1.27 and < 1.32.
3. Helm version >= 3.2
4. Ensure that the docker images for IBM Connect:Direct Web Services from IBM Entitled Registry are downloaded and pushed to an image registry accessible to the cluster.
5. Create a persistent volume for mapping configuration and logs of Connect:Direct Web Services. Sample file can be found at location ibm_cloud_pak/pak_extensions/pre-install/volumes/
6. Create a secret with all secure credentials such as ca-signed certificate password, keystore and truststore passwords. Example can be found at ibm_cloud_pak/pak_extensions/pre-install/secret/.
7. Create a secret to pull the image from a private registry or repository using following command
```
kubectl create secret docker-registry <name of secret> --docker-server=<your-registry-server> --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>
```

### SecurityContextConstraints Requirements

This chart supports restricted scc. For more details, refer: https://docs.openshift.com/container-platform/4.17/authentication/managing-security-context-constraints.html
  
### Installing a PodDisruptionBudget

* defaultPodDisruptionBudget.enabled - If true, It will create a pod disruption budget for IBM Connect:Direct Web Services pods.
* defaultPodDisruptionBudget.minAvailable - It will specify Minimum number / percentage of pods that should remain scheduled for IBM Connect:Direct Web Services pod.
  
## Network Policy
For Certified Container deployments, few default network policies are created out of the box as per mandatory security guidelines. By default all ingress and egress traffic are denied with few additional policies to allow communication within cluster and on ports configured in the helm charts configuration. Additionally custom ingress and egress policies can be configured in values yaml to allow traffic from and to specific external service endpoints.

Note: By default all ingress and egress traffic from or to external services are denied. You will need to create custom network policies to allow ingress and egress traffic from or to services outside of the cluster like database, MQ, protocol adapter endpoints, any other third party service integration and so on.

Out of the box Ingress policies

* Deny all ingress traffic
* Allow ingress traffic from all pods in the current namespace in the cluster
* Allow ingress traffic on the additional configured ports in helm values

Out of the box Egress policies

* Deny all egress traffic
* Allow egress traffic within the cluster

## Resources Required

This chart uses the following resources by default:

* 500Mi of persistent volume
* 2 GB Disk space
* 1500m CPU
* 1Gi Memory
* 1 master node and at least 1 worker node

## Agreement to IBM Connect:Direct Web Services License

You must read the IBM Connect:Direct Web Services License agreement terms before installation, using the below link:
[License](http://www-03.ibm.com/software/sla/sladb.nsf) (L/N:  L-ZWKV-MQ9Z94)

## Installing the Chart

Prepare a custom values.yaml file based on the configuration section.

To install the chart with the release name my-release:

Ensure that the chart is downloaded locally and available.

Run the below command

```bash
$ helm install my-release -f values.yaml ibm-cdws-1.1.6.tgz
```

Depending on the capacity of the kubernetes worker node and database network connectivity, chart deployment can take on average 2-3 minutes for Installing Web Services.

## Configuration

The following tables lists the configurable parameters of the IBM Connect:Direct Web Services chart and their default values.

| Parameter                                       | Description                                         | Default                                  |
| ------------------------------------------------| ----------------------------------------------------| -----------------------------------------|
| `arch`                                          | Node Architecture                                   | `amd64`                                  |
| `replicaCount`                                  | Number of deployment replicas                       | `1`                                      |
| `image.repository`                              | Image full name including repository                |                                          |
| `image.tag`                                     | Image tag                                           |                                          |
| `image.imageSecrets`                            | Image pull secrets                                  |                                          |
| `image.pullPolicy`                              | Image pull policy                                   | `IfNotPresent`                           |
| `cdwsParams.certificateLabel`                   | Certificate label for CA-signed Certificate/Self-signed certificate |                                          |
| `cdwsParams.certificateExpiryTime`              | Self-signed certificate - Enter the certificate expiration time in days |                                          |
| `cdwsParams.commonName`                         | Self-signed certificate - Identifies the host name associated with the certificate |                                          |
| `cdwsParams.organization`                       | Self-signed certificate - The legal name of your organization. This should not be abbreviated and should include suffixes such as Inc, Corp, or LLC. |                                          |
| `cdwsParams.locality`                           | Self-signed certificate - The city where your organization is located. |                                          |
| `cdwsParams.state`                              | Self-signed certificate - The state/region where your organization is located. |                                          |
| `cdwsParams.country`                            | Self-signed certificate - The two-letter ISO code for the country where your organization is location. |                                          |
| `cdwsParams.emailId`                            | Self-signed certificate - An email address used to contact your organization. |                                          |
| `cdwsParams.dnsName`                            | Self-signed certificate - Identifies the domain name associated with the certificate. |                                          |
| `cdwsParams.ipAddress`                          | Self-signed certificate - Identifies the IP Address associated with the certificate. |                                          |
| `cdwsParams.restOnly`                           | To enable RESTful API interface only when set to yes| `no`                                     |
| `dashboard.enabled`                             | For making monitoring dashboard enabled             |                                          |
| `service.type`                                  | Kubernetes service type exposing ports              | `LoadBalancer`                           |
| `service.loadBalancerIP`                        | For passing load balancer IP                        |                                          |
| `service.loadBalancerSourceRanges`              | Load Balancer sources                               | `[]`                                     |
| `service.externalTrafficPolicy`                 | For passing external Traffic Policy                 | `Local`                                  |
| `service.sessionAffinity`                       | For giving session Affinity                         | `ClientIP`                               |
| `service.port`                                  | Web Console port number                             | `9443`                                   |
| `service.webConsoleName`                        | Web Console name                                    | `cdws-web-console`                       |
| `service.protocol`                              | Web Console Protocol for service                    | `TCP`                                    |
| `service.allowIngressTraffic`                   | Allowing Ingress traffic for Web Console            | `true`                                   |
| `service.externalIP`                            | External IP for service discovery                   |                                          |
| `storageSecurity.fsGroup`                       | Used for controlling access to block storage        |                                          |
| `storageSecurity.supplementalGroups`            | Groups IDs are used for controlling access          | `[]`                                     |
| `secret.secretName`                             | Secret name for Secure Parameters                   |                                          |
| `secret.caCertSecretName`                       | CA Certificate file to be imported at the time of install|                                          |
| `secret.trustCertSecretName`                    | Trusted Certificate file to be imported at the time of install|                                          |
| `resources.limits.cpu`                          | Container CPU limit                                 | `1500m`                                  |
| `resources.limits.memory`                       | Container memory limit                              | `1Gi`                                    |
| `resources.requests.cpu`                        | Container CPU requested                             | `1000m`                                  |
| `resources.requests.memory`                     | Container Memory requested                          | `1Gi`                                    |
| `initResources.limits.cpu`                      | Init Container CPU limit                            | `500m`                                   |
| `initResources.limits.memory`                   | Init Container memory limit                         | `1Gi`                                    |
| `initResources.requests.cpu`                    | Init Container CPU requested                        | `250m`                                   |
| `initResources.requests.memory`                 | Init Container Memory requested                     | `1Gi`                                    |
| `serviceAccount.create`                         | Enable/disable service account creation             | `true`                                   |
| `serviceAccount.name`                           | Name of Service Account to use  for container       |                                          |
| `persistentVolumeExtra.enabled`                 | persistent volume for user input                    | `false`                                  |
| `persistentVolumeExtra.storageClassName`        | Storage class of the PVC                            | `manual`                                 |
| `persistentVolumeExtra.size`                    | Size of PVC volume                                  | `100Mi`                                  |
| `persistentVolumeExtra.claimName`               | Already created PVC name                            |                                          |
| `persistentVolumeExtra.accessMode`              | PV accessMode                                       | `ReadWriteOnce`                          |
| `persistentVolumeExtra.selector.label`          | Label name for attaching PV                         |                                          |
| `persistentVolumeExtra.selector.value`          | Label value for attaching PV                        |                                          |
| `affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity" |                                      |
| `affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity" |                                      |
| `affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity" |                                      |
| `affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity" |                                      |
| `affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity" |                                      |
| `affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity" |                                      |
| `autoscaling.enabled`                           | Autoscaling is enabled or not                       | `true`                                   |
| `autoscaling.minReplicas`                       | minimum pod replica                                 | `1`                                      |
| `autoscaling.maxReplicas`                       | Maximum pod replica                                 | `2`                                      |
| `autoscaling.targetCPUUtilizationPercentage`    | Traget CPU Utilization                              | `70`                                     |
| `autoscaling.targetMemoryUtilizationPercentage` | Traget Memory Utilization                           | `70`                                     |
| `livenessProbe.initialDelaySeconds`             | Initial delays for liveness                         | `15`                                     |
| `livenessProbe.timeoutSeconds`                  | Timeout for liveness                                | `10`                                     |
| `livenessProbe.periodSeconds`                   | Time period for liveness                            | `15`                                     |
| `readinessProbe.initialDelaySeconds`            | Initial delays for readiness                        | `15`                                     |
| `readinessProbe.timeoutSeconds`                 | Timeout for readiness                               | `10`                                     |
| `readinessProbe.periodSeconds`                  | Time period for readiness                           | `15`                                     |
| `networkPolicy.egress`                          | Network Policy egress rules                         | `{}`                                     |
| `networkPolicy.ingress`                         | Network Policy ingress rules                        | `{}`                                     |
| `route.enabled`                                 | Route for OpenShift Enabled/Disabled                | `false`                                  |
| `secComp.type`                                  | seccomp profile type                                | `RuntimeDefault`                         |
| `secComp.profile`                               | seccomp profile filepath                            | ``                                       |
| `timeZone`                                      | This flag is used for setting TimeZone of container | `Asia/Calcutta`                          |
| `defaultPodDisruptionBudget.minAvailable`       | Minimum replicas required for pod disruption budget | `0`                                      |
| `ingress.enabled`                               | Flag to eanble or disable ingress                   | `false`                                  |
| `ingress.host`                                  | Ingress hostname                                    |                                          |
| `ingress.controller`                            | Ingress controller name                             |                                          |
| `ingress.annotations`                           | annotation for ingress resource                     | `[]`                                     |
| `ingress.tls.enabled`                           | TLS is enabled or disabled for ingress resource     | `false`                                  |
| `ingress.tls.secretName`                        | TLS secret name if enabled                          |                                          |
| `hostAliases.enabled`                           | Enable hostname and IP mapping for DNS resolution   | `false`                                  |
| `hostAliases.hostEntries`                       | For providing IP and hostname mapping               | `[]`

Specify each parameter in values.yaml to `helm install`. For example,

## Affinity

The chart provides various ways in the form of node affinity, pod affinity and pod anti-affinity to configure advanced pod scheduling in kubernetes. Refer the kubernetes documentation for details on usage and specifications for the below features.

* Node affinity - This can be configured using parameters `affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the Web Services server.
Depending on the architecture preference selected for the parameter `arch`, a suitable value for node affinity is automatically appended in addition to the user provided values.

* Pod affinity - This can be configured using parameters `affinity.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the Web Services server.

* Pod anti-affinity - This can be configured using parameters `affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the Web Services server.
Depending on the value of the parameter `podAntiAffinity.replicaNotOnSameNode`, a suitable value for pod anti-affinity is automatically appended in addition to the user provided values. This is to configure whether replicas of a pod should be scheduled on the same node. If the value is `prefer` then `podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` is automatically appended whereas if the value is `require` then `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` is appended. If the value is blank, then no pod anti-affinity value is automatically appended. If the value is `prefer` then the weighting for the preference is set using the parameter `podAntiAffinity.weightForPreference` which should be specified in the range 1-100.

## Verifying the Chart

See the instructions (from NOTES.txt,packaged with the chart) after the helm installation completes for chart verification. The instructions can also be viewed by running the command:

```
helm status <release name>
```

## Upgrading the Chart

You would want to upgrade your deployment when you have a new docker image for application server or a change in configuration, for e.g. new service ports to be exposed. To upgrade the chart with the release name `my-release`

1. Ensure that the chart is downloaded locally and available.

2. Run the following command to upgrade your deployments.

```sh
helm upgrade my-release -f values.yaml ibm-cdws-1.1.6.tgz
```

Refer [RELEASENOTES.md](RELEASENOTES.md) for Fix history.

## Rollback the Chart

What if we notice that we made a mistake after upgrading or upgraded environment is not working as expected? Then we can easily rollback the chart to a previous revision. We support rollback 'one version back' only. To rollback the chart with the release name `my-release`.

1. Run the following command to rollback your deployments to previous version.

```bash
helm rollback my-release --recreate-pods
```

2. After executing the rollback command to check is the history of a release. We only need to provide the release name `my-release`.

```bash
helm bash my-release
```

## Uninstalling the Chart

To uninstall the `my-release`

```bash
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. Since there are certain kubernetes resources created as pre-requisite for chart, helm uninstall command will not delete them . You need to manually delete the following resources.

1. The persistence volume

2. The secrets

## Backup & Restore

**To Backup:**

You need to take backup of configuration data and other information like stats and TCQ which are present in the persistent volume by following the below steps:

1. Go to mount path of Persistent Volume.

2. Make copy of all of the directories listed below and store them at your desired and secured place.
   * `json`
   * `configFiles`
   * `restLogs`
  
> **Note**:In case of traditional installation of Connect:Direct Web Services, you should take the backup of the below directories and save them at your desired location:
   * `INSTALLATION_DIR/JSONFileSystem`
   * `INSTALLATION_DIR/RestLogs`
   * `INSTALLATION_DIR/mftws/BOOT-INF/classes`
These files are required to be backed up in classes folder: application.properties, .hiddenFile, ssl-server.jks, trustedkeystore.jks, log4j2.yaml.

**To Restore:**

Restoring the data in new deployment, it can be achieved by following steps

1. Create a Persistent Volume.

2. Copy all the backed up directories to the mount path of Persistent Volume.

3. Create a new deployment using the above Persistent Volume using variable `persistentVolume.name` in helm cli command. The pod would come up with desired data.

## Exposing Services

This chart creates a service of `LoadBalancer` for communication within the cluster. This type can be changed while installing chart using `service.type` key defined in values.yaml. There is one port where IBM Connect:Direct Web Services processes run. Port (9443) whose value can be updated during chart installation using `service.port`.

IBM Connect:Direct Web Services services for API and file transfer can be accessed using LoadBalancer external IP and mapped ports. If external LoadBalancer is not present then refer to Master node IP for communication.

Use `networkPolicy` to control traffic flow at the port level.

> **Note**: `NodePort` service type is not recommended. It exposes additional security concerns and are hard to manage from both an application and networking infrastructure perspective.

## DIME and DARE

1. All sensitive application data at rest is stored in binary format so user cannot decrypt it. This chart does not support encryption of user data at rest by default. Administrator can configure storage encryption to encrypt all data at rest
2. Data in motion is encrypted using transport layer security(TLS 1.2). For more information please see product [Knowledge center link]( https://www.ibm.com/docs/en/connect-direct/6.4.0?topic=sterling-connectdirect-web-services-v64 )

## Storage

IBM Connect:Direct Web Services Helm chart supports both dynamic and pre-created persistent storage.

* Either use storage class for dynamic provisioning or pre-create Persistent Volume
* To retain the data stored on Persistent Volume, the storage class should have reclaim policy as `Retain`
* The default access mode is set to `ReadWriteOnce`

## Limitations

- High availability and scalability are supported in traditional way of Web Services deployment using Kubernetes load balancer service.
- IBM Connect:Direct Web Services chart supports only amd64 architecture.

## Documentation

[IBM Connect:Direct Web Services](https://www.ibm.com/docs/en/connect-direct/6.4.0?topic=sterling-connectdirect-web-services-v64)
