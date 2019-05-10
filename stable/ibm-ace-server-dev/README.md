# IBM APP CONNECT ENTERPRISE

![ACE Logo](https://raw.githubusercontent.com/ot4i/ace-helm/master/integration_server.svg?sanitize=true)

**Deploying an IBM App Connect Enterprise Integration Server directly with this chart will instantiate an empty Integration Server. Bar files will have to be manually deployed to this server.**

**Alternatively, go back to the catalog to install an IBM App Connect Enterprise Dashboard (`ibm-ace-dashboard-dev`). This dashboard provides a UI to upload BAR files and deploy and manage Integration Servers.**

## Introduction

IBM® App Connect Enterprise is a market-leading lightweight enterprise integration engine that offers a fast, simple way for systems and applications to communicate with each other. As a result, it can help you achieve business value, reduce IT complexity and save money. IBM App Connect Enterprise supports a range of integration choices, skills and interfaces to optimize the value of existing technology investments.

## Chart Details

This chart deploys a single IBM App Connect Enterprise for Developers Integration Server into a Kubernetes environment.

## Prerequisites

* Kubernetes 1.11.1 or greater, with beta APIs enabled
* A user with operator role is required to install the chart
* If persistence is enabled (see configuration), then you either need to create a PersistentVolume, or specify a Storage Class if classes are defined in your cluster
* If you are using SELinux you must meet the [MQ requirements](https://www-01.ibm.com/support/docview.wss?uid=swg21714191)

To separate secrets from the Helm release a secret can be pre-installed with the following shape and referenced from the Helm chart with the `configurationSecret` value. Substitute `<alias>` with a reference to your certificate:
```
apiVersion: v1
kind: Secret
metadata:
  name: <secretName>
type: Opaque
data:
  adminPassword:
  appPassword:
  keystoreCert-<alias>:
  keystoreKey-<alias>:
  keystorePass-<alias>:
  keystorePassword:
  mqsc:
  odbcini:
  policy:
  policyDescriptor:
  serverconf:
  setdbparms:
  truststoreCert-<alias>:
  truststorePassword:
```

Below is an example of the format of the secret where two certs are being supplied

```
apiVersion: v1
kind: Secret
metadata:
  name: sample-configuration-secret
type: Opaque
data:
  adminPassword:
  appPassword:
  keystoreCert-MyCert1:
  keystoreKey-MyCert1:
  keystorePass-MyCert1:
  keystoreCert-MyCert2:
  keystoreKey-MyCert2:
  keystorePass-MyCert2:
  keystorePassword:
  mqsc:
  odbcini:
  policy:
  policyDescriptor:
  serverconf:
  setdbparms:
  truststoreCert-MyCert1:
  truststoreCert-MyCert2:
  truststorePassword:
```

The following table describes the secret keys:

| Key                              | Description                                                        |
| -------------------------------- | ------------------------------------------------------------------ |
| `adminPassword`                  | MQ Developer defaults - administrator password                     |
| `appPassword`                    | MQ Developer defaults - app password                               |
| `keystoreCert-<alias>`           | Multi-line value containing the certificate in PEM format          |
| `keystoreKey-<alias>`            | Multi-line value containing the private key in PEM format          |
| `keystorePass-<alias>`           | The passphrase for the private key being imported, if there is one |
| `keystorePassword`               | A password to set for the Integration Server's keystore            |
| `mqsc`                           | Multi-line value containing an mqsc file to run against the Queue Manager |
| `odbcini`                        | Multi-line value containing an odbc.ini file for the Integration Server to define any ODBC data connections |
| `policy`                         | Multi-line value containing a policy to apply                      |
| `policyDescriptor`               | Multi-line value containing the policy descriptor file             |
| `serverconf`                     | Multi-line value containing a server.conf.yaml                                               |
| `setdbparms`                     | Multi-line value containing the `{ResourceName} {UserId} {Password}` to pass to [mqsisetdbparms command](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/an09155_.htm) |
| `truststoreCert-<alias>`         | Multi-line value containing the trust certificate in PEM format    |
| `truststorePassword`             | A password to set for the Integration Server's truststore          |

If using `ibm-ace-dashboard-prod` for managing Integration Servers then further instructions and helper script are provided when adding a server. A full set of working example secrets can be found in the pak_extensions/pre-install directory.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* ICPv3.1 - Predefined  PodSecurityPolicy name: [`privileged`](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/manage_cluster/enable_pod_security.html)
* ICPv3.1.1 - Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-ace-psp
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
  - persistentVolumeClaim
  forbiddenSysctls:
  - '*'
```

## Resources Required

This chart uses the following resources by default:

* 1 CPU core
* 1 GiB memory without MQ
* 2 GiB memory with MQ

See the configuration section for how to configure these values.

## Installing the Chart

**Deploying an IBM App Connect Enterprise Integration Server directly with this chart will instantiate an empty Integration Server. Bar files will have to be manually deployed to this server, and those bar file deployments will not persist across a restarted pod.**

**Alternatively, go back to the catalog to install an IBM App Connect Enterprise Dashboard (`ibm-ace-dashboard-dev`). This dashboard provides a UI to upload BAR files and deploy and manage Integration Servers.**

If using a private Docker registry (including an ICP Docker registry), an image pull secret needs to be created before installing the chart. Supply the name of the secret as the value for `image.pullSecret`.

To install the chart with the release name `ace-server-dev`:

```
helm install --name ace-server-dev ibm-ace-server-dev --set license=accept --tls
```

This command accepts the IBM App Connect Enterprise license and deploys an IBM App Connect Enterprise Integration Server on the Kubernetes cluster.  Note that this will deploy an empty Integration Server.  If you have an IBM App Connect Enterprise Dashboard, you can get a content server URL and set it in the release with the following command:

```
helm install --name ace-server-dev ibm-ace-server-dev --set license=accept --set contentServerURL="{your content server URL}" --tls
```

The configuration section lists the parameters that can be configured during installation.

> **Tip**: See all the resources deployed by the chart using kubectl get all -l release=ace-server-dev

## Verifying the Chart

See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --tls.

## Uninstalling the Chart

To uninstall/delete the `ace-server-dev` release:

```
helm delete --purge ace-server-dev --tls
```

The command removes all the Kubernetes components associated with the chart, except any Persistent Volume Claims (PVCs). This is the default behaviour of Kubernetes, and ensures that valuable data is not deleted.

## Configuration
The following table lists the configurable parameters of the `ibm-ace-server-dev` chart and their default values.

| Parameter                        | Description                                     | Default                                                    |
| -------------------------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| `license`                        | Set to `accept` to accept the terms of the IBM license  | `Not accepted`                                     |
| `contentServerURL`               | URL provided by the ACE dashboard to pull resources from | `nil`                                                |
| `queueManagerEnabled`            | Boolean toggle for whether to run a StatefulSet with an MQ Queue Manager associated with the ACE Integration Server, or a Deployment without an MQ Queue Manager| `false` |
| `image.tag`                      | Image tag                                       | `11.0.0.4`                                                 |
| `image.pullPolicy`               | Image pull policy                               | `IfNotPresent`                                             |
| `image.pullSecret`               | Image pull secret, if you are using a private Docker registry | `nil`                                        |
| `arch`                           | Architecture scheduling preference for worker node (only amd64 supported) - read only | `amd64`              |
| `fsGroupGid`                     | File system group ID for volumes that support ownership management | `nil`                                   |
| `persistence.enabled`            | Use Persistent Volumes for all defined volumes  | `true`                                                     |
| `persistence.useDynamicProvisioning`| Use dynamic provisioning (storage classes) for all volumes | `true`                                       |
| `dataPVC.name`                   | Suffix for the Persistent Volume Claim name     | `data`                                                     |
| `dataPVC.storageClassName`       | Storage class of volume for main MQ data (under /var/mqm) | `nil`                                            |
| `dataPVC.size`                   | Size of volume for main MQ data (under /var/mqm) | `2Gi`                                                     |
| `service.type`                   | Kubernetes service type exposing ports          | `NodePort`                                                 |
| `service.webuiPort`              | Web UI port number - read only                  | `7600`                                                     |
| `service.serverlistenerPort`     | Http server listener port number - read only    | `7800`                                                     |
| `service.serverlistenerTLSPort`  | Https server listener port number - read only   | `7843`                                                     |
| `service.iP`                     | This is a hostname/IP that the nodeport is connected to i.e. a workers IP    | `nil`               |
| `aceonly.resources.limits.cpu`        | Kubernetes CPU limit for the container when running a server without MQ      | `1`                      |
| `aceonly.resources.limits.memory`     | Kubernetes memory limit for the container when running a server without MQ   | `1024Mi`                 |
| `aceonly.resources.requests.cpu`      | Kubernetes CPU request for the container when running a server without MQ    | `1`                      |
| `aceonly.resources.requests.memory`   | Kubernetes memory request for the container when running a server without MQ | `1024Mi`                 |
| `acemq.resources.limits.cpu`      | Kubernetes CPU limit for the container when running a server with MQ      | `1`                             |
| `acemq.resources.limits.memory`   | Kubernetes memory limit for the container when running a server with MQ   | `2048Mi`                        |
| `acemq.resources.requests.cpu`    | Kubernetes CPU request for the container when running a server with MQ    | `1`                             |
| `acemq.resources.requests.memory` | Kubernetes memory request for the container when running a server with MQ | `2048Mi`                        |
| `replicaCount`                   | When running without a Queue Manager, set how many replicas of the deployment pod to run | `3`               |
| `queueManager.name`              | MQ Queue Manager name                           | Helm release name                                          |
| `integrationServer.name`         | ACE Integration Server name                     | Helm release name                                          |
| `integrationServer.defaultAppName`         | Allows you to specifiy a name for the default application for the deployment of independent resources                     | `nil`     
| `configurationSecret`            | The name of the secret to create or to use that contains the server configuration | `nil`                    |
| `log.format`                     | Output log format on container's console. Either `json` or `basic` | `json`                                  |
| `metrics.enabled`                | Enable Prometheus metrics for the Queue Manager and Integration Server | `true`                              |
| `livenessProbe.initialDelaySeconds` | The initial delay before starting the liveness probe. Useful for slower systems that take longer to start the Queue Manager |	`360` |
| `readinessProbe.initialDelaySeconds` | The initial delay before starting the readiness probe |	`10`                                            |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Storage

When Queue Manager is enabled, the chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) for the storage of MQ configuration data and messages.  By using a Persistent Volume based on network-attached storage, Kubernetes can re-schedule the MQ server onto a different worker node. You should not use "hostPath" or "local" volumes, because this will not allow moving between nodes. The default size of the persistent volume claim is 2Gi.

Performance requirements will vary widely based on workload, but as a guideline, use a Storage Class which allows for at least 200 IOPS (based on 16 KB block size with a 50/50 read/write mix).

For volumes that support onwership management, specify the group ID of the group owning the persistent volumes' file systems using the `fsGroupGid` parameter.

**If not using Dynamic Provisioning:** The only requirement is to have an available Persistent Volume (a PV that is not already bound). No Persistent Volume Claim (PVC) needs to be created, the installation of this chart will automatically create it and bind it to an available PV. The name entered in `dataPVC.name` will become part of the final name of the PVC created by the chart. Supply a `dataPVC.size` no bigger than the size of the Persistent Volume created previously so the volume is claimed by the PVC.

## Resources Required

This chart uses the following resources per pod by default:

- ACE server without an associated Queue Manager:
   - 1 CPU core
   - 1024 Mi memory
- ACE server with an associated Queue Manager:
   - 1 CPU core
   - 2048 Mi memory

See the configuration section for how to configure these values.

## Logging

The `log.format` value controls whether the format of the output logs is:
- basic: Human readable format intended for use in development, such as when viewing through `kubectl logs`
- json: Provides more detailed information for viewing through Kibana

## Limitations

This Chart can run only on amd64 architecture type.

## Documentation

[View the IBM App Connect Enterprise Dockerfile repository on Github](https://github.com/ot4i/ace-docker)

[View the Official IBM App Connect Enterprise for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/ace/)

[Learn more about IBM App Connect Enterprise](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.ace.home.doc/help_home.htm)

[Learn more about IBM App Connect Enterprise and Docker](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bz91300_.htm)

[Learn more about IBM App Connect Enterprise and Lightweight Integration](https://ibm.biz/LightweightIntegrationLinks)