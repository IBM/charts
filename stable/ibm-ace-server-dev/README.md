# IBM APP CONNECT ENTERPRISE

![ACE Logo](https://raw.githubusercontent.com/ot4i/ace-helm/master/integration_server.svg?sanitize=true)

**Deploying an IBM App Connect Enterprise Integration Server directly with this chart will instantiate an empty Integration Server. Bar files will have to be manually deployed to this server.**

**Alternatively, go back to the catalog to install an IBM App Connect Enterprise Dashboard (`ibm-ace-dashboard-dev`). This dashboard provides a UI to upload BAR files and deploy and manage Integration Servers.**

## Introduction

IBM® App Connect Enterprise is a market-leading lightweight enterprise integration engine that offers a fast, simple way for systems and applications to communicate with each other. As a result, it can help you achieve business value, reduce IT complexity and save money. IBM App Connect Enterprise supports a range of integration choices, skills and interfaces to optimize the value of existing technology investments.

## Chart Details

This chart deploys a single IBM App Connect Enterprise for Developers Integration Server into a Kubernetes environment.

## Prerequisites

* Kubernetes 1.9 or greater, with beta APIs enabled
* A user with operator role is required to install the chart
* If persistence is enabled (see [configuration](#configuration)), then you either need to create a PersistentVolume, or specify a Storage Class if classes are defined in your cluster
* If you are using SELinux you must meet the [MQ requirements](https://www-01.ibm.com/support/docview.wss?uid=swg21714191)

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

See the [configuration](#configuration) section for how to configure these values.

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

> **Important**: Due to Helm secret management anyone with access to tiller can run a `helm get values --tls` command and see secret information in plain text (https://github.com/helm/helm/issues/2196) - only administrators or cluster administrators should have access to tiller. The {{ RELEASE }}-ibm-ace-server-dev secret is created as part of this chart. If you are concerned about access to this information please replace these after installation separate from the helm release, then delete the {{ RELEASE }}-ibm-ace-server-dev-XXXXX pods to force the pods to pick up the new secret values: (Please see the [configuration](#configuration) section for how to configure these values):
- **mqsc**
- **keystorePassword**
- **keystoreKey-{{ $key }}**
- **keystoreCert-{{ $key }}**
- **keystorePass-{{ $key }}**
- **truststorePassword**
- **truststoreCert-{{ $key }}**
- **odbcini**
- **policy**
- **policyDescriptor**
- **serverconf**
- **setdbparms**
- **viewerusers**

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
| `image.tag`                      | Image tag                                       | `11.0.0.2`                                                 |
| `image.pullPolicy`               | Image pull policy                               | `IfNotPresent`                                             |
| `image.pullSecret`               | Image pull secret, if you are using a private Docker registry | `nil`                                        |
| `arch`                           | Architecture scheduling preference for worker node (only amd64 supported) - read only | `amd64`              |
| `fsGroupGid`                     | File system group ID for volumes that support ownership management | `nil`                                   |
| `persistence.enabled`            | Use Persistent Volumes for all defined volumes  | `true`                                                     |
| `persistence.useDynamicProvisioning`| Use dynamic provisioning (storage classes) for all volumes | `true`                                       |
| `dataPVC.name`                   | Suffix for the Persistent Volume Claim name     | `data`                                                     |
| `dataPVC.storageClassName`       | Storage class of volume for main MQ data (under /var/mqm) | `nil`                                     |
| `dataPVC.size`                   | Size of volume for main MQ data (under /var/mqm) | `2Gi`                                                     |
| `service.type`                   | Kubernetes service type exposing ports          | `NodePort`                                                 |
| `service.webuiPort`              | Web UI port number - read only                   | `7600`                                                    |
| `service.serverlistenerPort`     | Http server listener port number - read only     | `7800`                                                    |
| `service.serverlistenerTLSPort`  | Https server listener port number - read only    | `7843`                                                    |
| `aceonly.resources.limits.cpu`        | Kubernetes CPU limit for the container when running a server without MQ      | `1`                                                       |
| `aceonly.resources.limits.memory`     | Kubernetes memory limit for the container when running a server without MQ   | `1024Mi`                                                  |
| `aceonly.resources.requests.cpu`      | Kubernetes CPU request for the container when running a server without MQ    | `1`                                                       |
| `aceonly.resources.requests.memory`   | Kubernetes memory request for the container when running a server without MQ | `1024Mi`                                                  |
| `acemq.resources.limits.cpu`      | Kubernetes CPU limit for the container when running a server with MQ      | `1`                                                       |
| `acemq.resources.limits.memory`   | Kubernetes memory limit for the container when running a server with MQ   | `2048Mi`                                                  |
| `acemq.resources.requests.cpu`    | Kubernetes CPU request for the container when running a server with MQ    | `1`                                                       |
| `acemq.resources.requests.memory` | Kubernetes memory request for the container when running a server with MQ | `2048Mi`                                                  |
| `replicaCount`                   | When running without a Queue Manager, set how many replicas of the deployment pod to run | `3`               |
| `queueManager.name`              | MQ Queue Manager name                           | Helm release name                                          |
| `queueManager.dev.adminPassword` | Developer defaults - administrator password     | Random generated string.  See the notes that appear when you install for how to retrieve this. |
| `queueManager.dev.appPassword`   | Developer defaults - app password               | `nil` (no password required to connect an MQ client)       |
| `queueManager.mqsc`              | Multi-line value containing an mqsc file to run against the Queue Manager | `nil`                            |
| `integrationServer.name`         | ACE Integration Server name                     | Helm release name                                          |
| `integrationServer.keystore.password` | A password to set for the Integration Server's keystore | `nil`                                         |
| `integrationServer.keystore.keys.{keyname}.passphrase` | The passphrase for the private key being imported, if there is one | `nil`             |
| `integrationServer.keystore.keys.{keyname}.key` | Multi-line value containing the private key in PEM format | `nil`                             |
| `integrationServer.keystore.keys.{keyname}.cert` | Multi-line value containing the certificate in PEM format | `nil`                            |
| `integrationServer.truststore.password` | A password to set for the Integration Server's truststore | `nil`                                     |
| `integrationServer.truststore.certs.{certname}.cert`| Multi-line value containing the trust certificate in PEM format | `nil`                   |
| `integrationServer.odbcini`      | Multi-line value containing an odbc.ini file for the Integration Server to define any ODBC data connections | `nil` |
| `integrationServer.policy`       | Multi-line value containing a policy to apply   | `nil`                                                      |
| `integrationServer.policyDescriptor`| Multi-line value containing the policy descriptor file | `nil`                                            |
| `integrationServer.serverconf`   | Multi-line value containing a server.conf.yaml  | `nil`                                                      |
| `integrationServer.setdbparms`   | Multi-line value containing the `{ResourceName} {UserId} {Password}` to pass to [mqsisetdbparms command](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/an09155_.htm) | `nil`         |
| `log.format`                     | Output log format on container's console. Either `json` or `basic` | `json`                                         |
| `metrics.enabled`                | Enable Prometheus metrics for the Queue Manager and Integration Server | `true`                              |
| `livenessProbe.initialDelaySeconds` | The initial delay before starting the liveness probe. Useful for slower systems that take longer to start the Queue Manager |	`120` |
| `readinessProbe.initialDelaySeconds` | The initial delay before starting the readiness probe |	`10` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

> **Tip**: You can use the default [values.yaml](values.yaml)

## Storage

When Queue Manager is enabled, the chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) for the storage of MQ configuration data and messages.  By using a Persistent Volume based on network-attached storage, Kubernetes can re-schedule the MQ server onto a different worker node. You should not use "hostPath" or "local" volumes, because this will not allow moving between nodes. The default size of the persistent volume claim is 2Gi.

Performance requirements will vary widely based on workload, but as a guideline, use a Storage Class which allows for at least 200 IOPS (based on 16 KB block size with a 50/50 read/write mix).

For volumes that support onwership management, specify the group ID of the group owning the persistent volumes' file systems using the `fsGroupGid` parameter.

## Resources Required

This chart uses the following resources per pod by default:

- ACE server without an associated Queue Manager:
   - 1 CPU core
   - 1024 Mi memory
- ACE server with an associated Queue Manager:
   - 1 CPU core
   - 2048 Mi memory

See the [configuration](#configuration) section for how to configure these values.

## Logging

The `log.format` value controls whether the format of the output logs is:
- basic: Human readable format intended for use in development, such as when viewing through `kubectl logs`
- json: Provides more detailed information for viewing through Kibana

## Limitations

This Chart can run only on amd64 architecture type.

## Useful Links

[View the IBM App Connect Enterprise Dockerfile repository on Github](https://github.com/ot4i/ace-docker)

[View the Official IBM App Connect Enterprise for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/ace/)

[Learn more about IBM App Connect Enterprise](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.ace.home.doc/help_home.htm)

[Learn more about IBM App Connect Enterprise and Docker](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bz91300_.htm)

[Learn more about IBM App Connect Enterprise and Lightweight Integration](https://ibm.biz/LightweightIntegrationLinks)

_Copyright IBM Corporation 2018. All Rights Reserved._

_The IBM App Connect Enterprise logo is copyright IBM. You will not use the IBM App Connect Enterprise logo in any way that would diminish the IBM or IBM App Connect Enterprise image. IBM reserves the right to end your privilege to use the logo at any time in the future at our sole discretion. Any use of the IBM App Connect Enterprise logo affirms that you agree to adhere to these conditions._
