# IBM APP CONNECT ENTERPRISE

![Integration Server Logo](https://raw.githubusercontent.com/ot4i/ace-helm/master/integration_server.svg?sanitize=true)

## Introduction

IBM® App Connect Enterprise is a market-leading lightweight enterprise integration engine that offers a fast, simple way for systems and applications to communicate with each other. As a result, it can help you achieve business value, reduce IT complexity and save money. IBM App Connect Enterprise supports a range of integration choices, skills and interfaces to optimize the value of existing technology investments.

## Chart Details

This chart deploys a single IBM App Connect Enterprise integration server into a Kubernetes environment. 

## Prerequisites

* Kubernetes 1.11.0 or later, with beta APIs enabled
* A user with operator role is required to install the chart
* If persistence is enabled (see configuration), you must either create a persistent volume; or specify a storage class if classes are defined in your cluster
* If you are using SELinux you must meet the [MQ requirements](https://www-01.ibm.com/support/docview.wss?uid=swg21714191)

To separate secrets from the Helm release, a secret can be preinstalled with the following shape and referenced from the Helm chart with the `integrationServer.configurationSecret` value. Substitute `<alias>` with a reference to your certificate:
```
apiVersion: v1
kind: Secret
metadata:
  name: <secretName>
type: Opaque
data:
  adminPassword:
  agentc:
  agentp:
  agentx:
  appPassword:
  ca.crt:
  extensions:
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
  switch:
  tls.cert
  tls.key
  truststoreCert-<alias>:
  truststorePassword:
  useraccounts
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
  agentc:
  agentp:
  agentx:
  appPassword:
  ca.crt:
  credentials:
  extensions:
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
  switch:
  tls.cert
  tls.key
  truststoreCert-MyCert1:
  truststoreCert-MyCert2:
  truststorePassword:
```

The following table describes the secret keys:

| Key                             | Description                                                        |
| ------------------------------- | ------------------------------------------------------------------ |
| `agentc`                        | Multi-line value containing a agentc.json file.                     |
| `agentp`                        | Multi-line value containing a agentp.json file.                     |
| `agentx`                        | Multi-line value containing a agentx.json file.                     |
| `credentials`                   | Multi-line value containing a file which has details of accounts used to connect to external endpoints  |
| `ca.crt`                        | The ca certificate in PEM format (will be copied into /home/aceuser/aceserver/tls on startup)  |
| `extensions`                    | Multi-line value containing an extensions.zip file.                 |
| `keystoreCert-<alias>`          | Multi-line value containing the certificate in PEM format.          |
| `keystoreKey-<alias>`           | Multi-line value containing the private key in PEM format.          |
| `keystorePass-<alias>`          | The passphrase for the private key being imported, if there is one. |
| `keystorePassword`              | A password to set for the integration server's keystore.            |
| `mqsc`                          | Multi-line value containing an mqsc file to run against the queue manager. |
| `odbcini`                       | Multi-line value containing an odbc.ini file for the integration server to define any ODBC data connections. |
| `policy`                        | Multi-line value containing a policy to apply.                      |
| `policyDescriptor`              | Multi-line value containing the policy descriptor file.             |
| `serverconf`                    | Multi-line value containing a server.conf.yaml.                     |
| `setdbparms`                    | This supports 2 formats: Each line which starts mqsisetdbparms will be run as written, or each line should specify the <resource> <userId> <password>, separated by a single space |
| `serverconf`                    | Multi-line value containing a server.conf.yaml.                     |
| `switch`                        | Multi-line value containing a switch.json.                          |
| `tls.key`                        | The tls key in PEM format (will be copied into /home/aceuser/aceserver/tls on startup) |
| `tls.crt`                        | The tls certificate in PEM format (will be copied into /home/aceuser/aceserver/tls on startup) |
| `truststoreCert-<alias>`        | Multi-line value containing the trust certificate in PEM format.    |
| `truststorePassword`            | A password to set for the integration server's truststore.          |
| `useraccounts`                  | Multi-line value containing a credentials.yaml file containing endpoint accounts details to create data source  | 

If using `ibm-ace-dashboard-icp4i-prod` for managing integration servers then further instructions and helper script are provided when adding a server. A full set of working example secrets can be found in the pak_extensions/pre-install directory.

## IBM App Connect Designer Flows Prerequisites

The integration server can optionally host flows that are authored in IBM App Connect Designer. This can be enabled by using the "IBM App Connect Designer flows" drop-down list on the Configuration tab.

| Value | Description |
|-------|-------------|
| Disabled | Use this option if your BAR file does not contain any IBM App Connect Designer flows. |
| Enabled for cloud-managed and local connectors | Use this option if your BAR file contains IBM App Connect Designer flows that use cloud-managed or local connectors. An IBM Cloud API key must be provided in the Kubernetes secret that contains your server configuration. |
| Enabled for local connectors only | Use this option if your BAR file contains IBM App Connect Designer flows that use only local connectors. |

For more information, see [https://ibm.biz/createintserver-ace](https://ibm.biz/createintserver-ace).



## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster-scoped, as well as namespace-scoped, pre- and post-actions that need to occur.

The predefined SecurityContextConstraints [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart. If your target namespace is not bound to this SecurityContextConstraints resource you can bind it with the following command:

`oc adm policy add-scc-to-group ibm-anyuid-scc system:serviceaccounts:<namespace>` For example, for release into the `default` namespace:
```bash
oc adm policy add-scc-to-group ibm-anyuid-scc system:serviceaccounts:default
```

### Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-ace-scc
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
fsGroup:
  type: RunAsAny
spec:
  allowPrivilegeEscalation: true
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

If a sidecar container for running flows authored in App Connect Designer is deployed into the pod, the following resources will also be used by default:

* 1 CPU core
* 256 MiB memory

See the configuration section below for how to configure these values.

## Installing the Chart

**Deploying an IBM App Connect Enterprise integration server directly with this chart will instantiate an empty integration server. BAR files will have to be manually deployed to this server, and those BAR file deployments will not persist across a restarted pod.**

**Alternatively, go back to the catalog to install an IBM App Connect Enterprise dashboard (`ibm-ace-dashboard-icp4i-prod`). This dashboard provides a UI to upload BAR files and deploy and manage integration servers.**

If using a private Docker registry, an image pull secret needs to be created before installing the chart. Supply the name of the secret as the value for `image.pullSecret`.

To install the chart with the release name `ace-server`:

```bash
helm install --name ace-server ibm-ace-server-icp4i-prod --set license=accept --tls
```

This command accepts the IBM App Connect Enterprise license and deploys an IBM App Connect Enterprise integration server on the Kubernetes cluster.  Note that this will deploy an empty integration server.  If you have an IBM App Connect Enterprise dashboard, you can get a content server URL and set it in the release with the following command:

```bash
helm install --name ace-server ibm-ace-server-icp4i-prod --set license=accept --set contentServerURL="{your content server URL}" --tls
```

The configuration section lists the parameters that can be configured during installation.

> **Tip**: See all the resources deployed by the chart by using `kubectl get all -l release=ace-server`.

## Verifying the Chart

See the instruction (from NOTES.txt in the chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command:

```bash
helm status ace-server --tls`
```

## Uninstalling the Chart

To uninstall/delete the `ace-server` release:

```
helm delete --purge ace-server --tls
```

The command removes all the Kubernetes components associated with the chart, except any persistent volume claims (PVCs). This is the default behaviour of Kubernetes, and ensures that valuable data is not deleted.

## Configuration
The following table lists the configurable parameters of the `ibm-ace-server-icp4i-prod` chart and their default values.

| Parameter                        | Description                                     | Default                                                    |
| -------------------------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| `license`                        | Set to `accept` to accept the terms of the IBM license.  | `Not accepted`                                     |
| `contentServerURL`               | URL provided by the App Connect Enterprise dashboard to pull resources from. | `nil`                      |
| `productionDeployment`           | Boolean toggle for whether App Connect Enterprise server is being run in a production environment or a pre-production environment. | `true`  |
| `imageType`                      | Run an integration server a standalone server, an integration server with MQ client or an integration server with MQ server. Options `ace`, `acemqclient` or `acemqserver`. | `ace` |
| `imageType`                      | Run an integration server a standalone server, an integration server with MQ client or an integration server with MQ server. Options `ace`, `acemqclient` or `acemqserver`. | `ace` |
| `designerFlowsOperationMode`     | Choose whether to deploy sidecar containers into the pod for running flows authored in App Connect Designer. Options `disabled`, `all` (Enabled for cloud-managed and local connectors) or `local` (Enabled for local connectors only) | `disabled` |
| `image.aceonly`                  | Image repository and tag for the App Connect Enterprise Server only image.    | `cp.icr.io/cp/icp4i/ace/ibm-ace-server-prod:11.0.0.6.1` |
| `image.acemqclient`              | Image repository and tag for the App Connect Enterprise Server  & MQ Client image.    | `cp.icr.io/cp/icp4i/ace/ibm-ace-mqclient-server-prod:11.0.0.6.1`         |
| `image.acemq`                    | Image repository and tag for the App Connect Enterprise Server  & MQ Server image.  | `cp.icr.io/cp/icp4i/ace/ibm-ace-mq-server-prod:11.0.0.6.1`               |
| `image.configurator`             | Image repository and tag for the App Connect Enterprise configurator image.    | `cp.icr.io/cp/icp4i/ace/ibm-ace-icp-configurator-prod:11.0.0.6.1` |
| `image.designerflows`            | Image repository and tag for the App Connect Enterprise designer flows image.    | `cp.icr.io/cp/icp4i/ace/ibm-ace-designer-flows-prod:11.0.0.6.1` |
| `image.connectors`               | Image repository and tag for the App Connect Enterprise loopback connector image.    | `cp.icr.io/cp/icp4i/ace/ibm-ace-lcp-prod:11.0.0.6.1` |
| `image.pullPolicy`               | Image pull policy.                               | `IfNotPresent`                                             |
| `image.pullSecret`               | Image pull secret, if you are using a private Docker registry. | `nil`                                        |
| `arch`                           | Architecture scheduling preference for worker node (only amd64 supported) - read only. | `amd64`              |
| `persistence.enabled`            | Use Persistent Volumes for all defined volumes.  | `true`                                                     |
| `persistence.useDynamicProvisioning`| Use dynamic provisioning (storage classes) for all volumes. | `true`                                       |
| `dataPVC.name`                   | Suffix for the Persistent Volume Claim name.     | `data`                                                     |
| `dataPVC.storageClassName`       | Storage class of volume for main MQ data (under /var/mqm). | `nil`                                            |
| `dataPVC.size`                   | Size of volume for main MQ data (under /var/mqm). | `2Gi`                                                     |
| `service.type`                   | Kubernetes service type exposing ports.          | `NodePort`                                                 |
| `service.webuiPort`              | Web UI port number - read only.                   | `7600`                                                    |
| `service.serverlistenerPort`     | HTTP server listener port number - read only.     | `7800`                                                    |
| `service.serverlistenerTLSPort`  | HTTPS server listener port number - read only.    | `7843`                                                    |
| `service.switchAgentCPort`       | Port used by the Switch for agentC calls, normally 9010.   | `nil`                                            |
| `service.switchAgentPPort`       | Port used by the Switch for agentP calls, normally 9011.   | `nil`                                            |
| `service.switchAdminPort`        | Port used by the Switch for admin calls, normally 9012.    | `nil`                                            |
| `service.iP`                     | An IP address or DNS name that the nodeport is connected to, that is, the proxy node's IP or fully qualified domain name (FQDN). | `nil`               |
| `aceonly.resources.limits.cpu`        | Kubernetes CPU limit for the container when running a server without MQ.      | `1`                      |
| `aceonly.resources.limits.memory`     | Kubernetes memory limit for the container when running a server without MQ.   | `1024Mi`                 |
| `aceonly.resources.requests.cpu`      | Kubernetes CPU request for the container when running a server without MQ.    | `200m`                   |
| `aceonly.resources.requests.memory`   | Kubernetes memory request for the container when running a server without MQ. | `256Mi`                  |
| `aceonly.replicaCount`                | When running without a queue manager, set how many replicas of the deployment pod to run. | `3`          |
| `acemq.resources.limits.cpu`      | Kubernetes CPU limit for the container when running a server with MQ.      | `1`                             |
| `acemq.resources.limits.memory`   | Kubernetes memory limit for the container when running a server with MQ.   | `2048Mi`                        |
| `acemq.resources.requests.cpu`    | Kubernetes CPU request for the container when running a server with MQ.    | `500m`                          |
| `acemq.resources.requests.memory` | Kubernetes memory request for the container when running a server with MQ. | `512Mi`                         |
| `acemq.pki.keys`                      | An array of YAML objects that detail Kubernetes secrets containing TLS Certificates with private keys. See section titled "Supplying certificates to be used for TLS" for more details.  | `[]` |
| `acemq.pki.trust`                     | An array of YAML objects that detail Kubernetes secrets containing TLS Certificates. See section titled "Supplying certificates to be used for TLS" for more details.  | `[]` |
| `acemq.qmname`              | MQ queue manager name.                           | Helm release name.                                          |
| `acemq.initVolumeAsRoot`              | Whether or not the storage class (such as NFS) requires root permissions to initialize.                           | Initialize MQ volume using root.                                          | `true` | `nameOverride`                  | Set to partially override the resource names used in this chart. | `ibm-mq`                                   |
| `designerflows.resources.limits.cpu`        | Kubernetes CPU limit for the sidecar container for running flows authored in App Connect Designer.      | `1`                      |
| `designerflows.resources.limits.memory`     | Kubernetes memory limit for the sidecar container for running flows authored in App Connect Designer.   | `256Mi`                 |
| `designerflows.resources.requests.cpu`      | Kubernetes CPU request for the sidecar container for running flows authored in App Connect Designer.    | `50m`                      |
| `designerflows.resources.requests.memory`   | Kubernetes memory request for the sidecar container for running flows authored in App Connect Designer. | `32Mi`                 |
| `connectors.resources.limits.cpu`        | Kubernetes CPU limit for the loopback connector provider sidecar container. | `1`                      |
| `connectors.resources.limits.memory`     | Kubernetes memory limit for loopback connector provider sidecar container.  | `768Mi`                 |
| `connectors.resources.requests.cpu`      | Kubernetes CPU request for loopback connector provider sidecar container    | `150m`                      |
| `connectors.resources.requests.memory`   | Kubernetes memory request for loopback connector provider sidecar container | `200Mi`      |
| `integrationServer.name`         | App Connect Enterprise integration server name.                     | Helm release name.                                          |
| `integrationServer.defaultAppName`         | Allows you to specify a name for the default application for the deployment of independent resources.                     | `nil`                                          |
| `integrationServer.configurationSecret`            | The name of the secret to create or to use that contains the server configuration. | `nil`                    |
| `integrationServer.fsGroupGid`                     | File system group ID for volumes that support ownership management (such as NFS). | `nil`  |
| `log.format`                     | Output log format on container's console. Either `json` or `basic`. | `json`                                         |
| `log.mqDebug`                     | Enables additional MQ log output for debug purposes. | `false`                                         |
| `metrics.enabled`                | Enable Prometheus metrics for the queue manager and integration server. | `true`                              |
| `livenessProbe.initialDelaySeconds` | The initial delay before starting the liveness probe. Useful for slower systems that take longer to start the queue manager. |	`360` |
| `readinessProbe.initialDelaySeconds` | The initial delay before starting the readiness probe. |	`10` |
| `odTracingConfig.enabled`                                        | Whether or not to enable the OD for this release      | `false`               |
| `odTracingConfig.odAgentImageRepository`                         | Repository where the OD agent image is located        | `cp.icr.io/cp/icp4i/ace/icp4i-od-agent`      |
| `odTracingConfig.odAgentImageTag`                                | The tag for the Docker image for the OD agent         | `1.0.1`               |
| `odTracingConfig.odAgentLivenessProbe.initialDelaySeconds`       | How long to wait before starting the probe            | `60`                  |
| `odTracingConfig.odAgentReadinessProbe.initialDelaySeconds`      | How long to wait before the probe is ready            | `10`                  |
| `odTracingConfig.odCollectorImageRepository`                     | Repository where the OD collector image is located    | `cp.icr.io/cp/icp4i/ace/icp4i-od-collector`  |
| `odTracingConfig.odCollectorImageTag`                            | The tag for the Docker image for the OD collector     | `1.0.1`               |
| `odTracingConfig.odCollectorLivenessProbe.initialDelaySeconds`   | How long to wait before starting the probe            | `60`                  |
| `odTracingConfig.odCollectorReadinessProbe.initialDelaySeconds`  | How long to wait before the probe is ready            | `10`                  |
| `odTracingConfig.odTracingNamespace`                             | Namespace where the Operation Dashboard was released  | `nil`                 |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Storage

When choosing to deploy the 'App Connect Enterprise with MQ Server' image (`imageType=acemqserver`) the chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) for the storage of MQ configuration data and messages.  By using a persistent volume (PV) based on network-attached storage, Kubernetes can re-schedule the MQ server onto a different worker node. You should not use "hostPath" or "local" volumes, because this will not allow moving between nodes. The default size of the persistent volume claim is 2Gi.

Performance requirements will vary widely based on workload, but as a guideline, use a storage class which allows for at least 200 IOPS (based on a block size of 16 KB with a 50/50 read/write mix).

For volumes that support ownership management, such as NFS, specify the group ID of the group owning the persistent volumes' file systems using the `integrationServer.fsGroupGid` parameter. NFS and some other storage classes also require the `acemq.initVolumeAsRoot` parameter to be enabled so that root permissions can be used to initialize the volume for MQ.

**If not using dynamic provisioning:** You only need to have an available PV, that is, one that is not already bound). You do not need to create a persistent volume claim (PVC); installation of this chart automatically creates it and binds it to an available PV. The name entered in dataPVC.name will become part of the final name of the PVC created by the chart. Supply a dataPVC.size that is no bigger than the size of the PV created previously so that the volume is claimed by the PVC.

## Resources Required

This chart uses the following resources per pod by default:

- Using the 'App Connect Enterprise only' or 'App Connect Enterprise with MQ Client' images (`aceonly` or `acemqclient`):
   - 1 CPU core
   - 1024 Mi memory
- Using the 'App Connect Enterprise with MQ Server' image (`acemqserver`):
   - 1 CPU core
   - 2048 Mi memory
   
If a sidecar container for running flows authored in App Connect Designer is deployed into the pod, the following resources will additionally be used for that container by default:
* 1 CPU core
* 256Mi memory

See the configuration section for how to configure these values.

## Logging

The `log.format` value controls whether the format of the output logs is:
- basic: Human readable format intended for use in development, such as when viewing through `kubectl logs`
- json: Provides more detailed information for viewing through Kibana

On the command line, you can use utilities like 'jq' to format this output, for example:

```sh
kubectl logs foo-ibm-mq-0 | jq -r '.ibm_datetime + " " + .message'
```

## Limitations

### MQ Highly Available Setup Scenario

This delivery includes sample code which makes provision for *future* use of MQ multi-instance queue managers in a high availability scenario. This *full feature* is not available for production in this release but is intended to be available in the near future.

### Upgrade Notes

This chart has replaced the *Local default Queue Manager* checkbox with a *Which type of image to run* dropown list. That's because this chart now comes with an additional Docker image, the App Connect Enterprise with MQ client image. Users of Server 2.0.0 and later releases, can reuse existing values when upgrading but must ensure that the new option has the correct value to maintain your image selection.

This chart has changed the way we specify images. Previously we used a common tag across all images. In this release we have moved to including the tag with the name of the image. If you have customised the image name you will need to make sure that when upgrading you include the image tag on the appropriate image value

## Documentation

### Supplying certificates to be used for TLS for MQ

The `pki.trust` and `pki.keys` allow you to supply details of Kubernetes secrets that contain TLS certificates. The TLS certificates are imported into the container at runtime and MQ will be configured to use them. You can supply certificates that contain only a public key and certificates that contain both public and private keys. 

If you supply invalid files or invalid YAML objects, the container terminates with an appropriate message. The following two sections detail the requirements for supplying each type of certificate.

#### Supplying certificates that contain the public and private keys
When supplying a Kubernetes secret that contains certificate files for both the public and private key, ensure that the secret contains two files with the same name, one with a suffix of `.crt` and the other with a suffix of `.key`. For example: `tls.crt` and `tls.key`. The extension of the file denotes whether the file is the public key (`.crt`) or the private key (`.key`) and must be correct. If your certificate has been issued by a Certificate Authority, then the certificate from the CA must be included as a separate file with the `.crt` extension. For example: `ca.crt`.

The format of the YAML objects for `pki.keys` value is as follows:

```YAML
- name: mykey
  secret:
    secretName: mykeysecret
    items:
      - tls.key
      - tls.crt
      - ca.crt
```

or, alternatively, in a single line, you can supply the following: 

```YAML
- name: mykey, secret: {secretName: mykeysecret, items: [tls.key, tls.crt, ca.crt]}
```

`name` must be a lowercase alphanumeric value and is used as the label for the certificate in the keystore and queue manager.

`secret.secretName` must match the name of a Kubernetes secret that contains the TLS certificates you wish to import.

`secret.items` must list the TLS certificate files contained in `secret.secretName` you want to import.

To supply the YAML objects when deploying via Helm you should use the following: 
`--set pki.keys[0].name=mykey,pki.keys[0].secret.secretName=mykeysecret,pki.keys[0].secret.items[0]=tls.key,pki.keys[0].secret.items[1]=tls.crt,pki.keys[0].secret.items[2]=ca.crt`

If you supply multiple YAML objects then the queue manager will use the first object chosen by the label name alphabetically. For example if you supply the following labels: `alabel`, `blabel` and `clabel`. The queue manager and MQ Console will use the certificate with the label `alabel` for its identity. In this queue manager this can be changed by running the MQSC command: `ALTER QMGR CERTLABL('<new label>')`.

#### Supplying certficates which contain only the public key
When supplying a Kubernetes secret that contains a certificate file with only the public key, ensure that the secret contains files that have the extension `.crt`. For example: `tls.crt` and `ca.crt`. 

The format of the YAML objects for `pki.trust` value is as follows:

```YAML
- secret:
    secretName: mycertificate
    items:
      - tls.crt
```

or alternatively in a single line you can supply the following: `- secret: {secretName: mycertificate, items: [tls.crt]}`

`secret.secretName` must match the name of a Kubernetes secret that contains the TLS certificates you wish to add.

`secret.items` must list the TLS certificate files contained in `secret.secretName` you want to add.

To supply the YAML objects when deploying by using Helm you should use the following:

```YAML
--set pki.trust[0].secret.secretName=mycertificate,pki.trust[0].secret.items[0]=tls.crt
```

If you supply multiple YAML objects then all of the certificates specified will be added into the queue managers and MQ Console Truststore.


[View the IBM App Connect Enterprise Dockerfile repository on Github](https://github.com/ot4i/ace-docker)

[View the Official IBM App Connect Enterprise for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/ace/)

[Learn more about IBM App Connect Enterprise](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.ace.home.doc/help_home.htm)

[Learn more about IBM App Connect Enterprise and Docker](https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bz91300_.htm)

[Learn more about IBM App Connect Enterprise and Lightweight Integration](https://ibm.biz/LightweightIntegrationLinks)
