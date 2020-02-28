# IBM Voice Gateway Helm Chart (Developer Trial)

## Introduction

This chart will deploy IBM Voice Gateway (Developer Trial) to either IBM Cloud Pak for Data environment or to the IBM Cloud Private environment.

[IBM Voice Gateway](https://www.ibm.com/support/knowledgecenter/SS4U29/welcome_voicegateway.html) provides a way to integrate a set of orchestrated Watson services with a public or private telephone network by using the Session Initiation Protocol (SIP). Voice Gateway enables direct voice interactions over a telephone with a cognitive self-service agent or transcribes a phone call between a caller and agent so that the conversation can be processed with analytics for real-time agent feedback.

## Chart Details

- The Chart provided can be used to deploy Media Relay, Sip Orchestrator, SMS Gateway and G729 Codec Service containers.
- Media Relay, Sip Orchestrator and G729 Codec Service containers are deployed in one pod and SMS Gateway is deployed in one pod.

This chart can be deployed on IBM Cloud Private or to the IBM Cloud Pak for Data environment. 

## IBM Cloud Private 

### Prerequisites
- IBM Cloud Private 3.1.0 or greater
- A user with Cluster administrator role is required to install the chart.
- Detailed requirements are explained in knowledge center article of [Getting Started with IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SS4U29/deployicp.html)

### PodSecurityPolicy Requirements for IBM Cloud Private

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

#### Predefined PodSecurityPolicy

The predefined PodSecurityPolicy [`ibm-anyuid-hostaccess-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

#### Custom PodSecurityPolicy

To set up a custom PodSecurityPolicy, the cluster administrator can either manually create the following resources, or use the configuration scripts to create and delete the resources.

- Custom PodSecurityPolicy definition:
  ```yaml
  apiVersion: extensions/v1beta1
  kind: PodSecurityPolicy
  metadata:
    name: ibm-voice-gateway-psp
  spec:
    privileged: false
    hostNetwork: true
    hostPorts:
      - min: 0
        max: 65535
    allowPrivilegeEscalation: false
    runAsUser:
      rule: MustRunAsNonRoot
    seLinux:
      rule: RunAsAny
    supplementalGroups:
      rule: 'MustRunAs'
      ranges:
        - min: 1
          max: 65535
    fsGroup:
      rule: 'MustRunAs'
      ranges:
        - min: 1
          max: 65535
    volumes:
      - 'configMap'
      - 'downwardAPI'
      - 'emptyDir'
      - 'persistentVolumeClaim'
      - 'secret'
      - 'projected'
  ```
- Custom ClusterRole for the custom PodSecurityPolicy:
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: ibm-voice-gateway-clusterrole
  rules:
    - apiGroups:
        - extensions
      resources:
        - podsecuritypolicies
      resourceNames:
        - ibm-voice-gateway-psp
      verbs:
        - use
  ```

##### Configuration scripts for custom PodSecurityPolicy:

Download the following scripts from the [prereqs](https://github.com/IBM/charts/tree/master/stable/ibm-voice-gateway-dev/ibm_cloud_pak/pak_extensions/prereqs) directory.

- `createSecurityClusterPrereqs.sh`: Creates the PodSecurityPolicy and ClusterRole for all releases of this chart.
- `createSecurityNamespacePrereqs.sh`: Creates the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  - Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`
- `deleteSecurityClusterPrereqs.sh`: Deletes the PodSecurityPolicy and ClusterRole for all releases of this chart.
- `createSecurityNamespacePrereqs.sh`: Deletes the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  - Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`


### Required for IBM Cloud Private

#### Configure watson services:

- Create the following Watson services on IBM Cloud for Media Relay and Sip Orchestrator.

  - [Watson Speech to Text](https://cloud.ibm.com/catalog/services/speech-to-text/)
  - [Watson Text to Speech](https://cloud.ibm.com/catalog/services/text-to-speech/) (self-service only)

- Create the Watson Assistant services on IBM Cloud for Media Relay and Sip Orchestrator and SMS Gateway

  - [Watson Assistant](https://cloud.ibm.com/catalog/services/watson-assistant) (self-service only)

    **Important:** For the Watson Assistant service, you'll need to add a workspace with a dialog(Dialog skill). You can quickly get started by importing the [sample-conversation-en.json](https://github.com/WASdev/sample.voice.gateway/tree/master/conversation) file from your cloned sample.voice.gateway GitHub repository. To learn more about importing JSON files, see [Creating Dialog skill](https://cloud.ibm.com/docs/services/assistant?topic=assistant-skill-dialog-add) in the Assistant documentation. If you build your own dialog instead of using the sample, ensure that your dialog includes a node with the _conversation_start_ condition and node with a default response.

#### Create metering API Key Secret (Only for IBM Cloud Private platform):

- Complete the steps mentioned on [IBM® Cloud Private metering service](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_metrics/metering_service.html#track_usage) page to create the Metering API Key.
  > Make sure to create the API Key in the namespace you are going to deploy the helm chart.
- Retrieve the Metering API Key:
    - After you have created the API Key, return to the IBM Cloud Private Management Console, open the menu and click **Platform > Metering**.
    - On the *Metering dashboard*, select **Manage API Keys**. Use this form to retrieve the metering API key that you created.
- Add the generated API Key in a text file `metering-api-key.txt` (Make sure there are no extra spaces or new lines in the text file)
- Create secret for the metering API Key:
  ```
  kubectl create secret generic metering-api-key-secret --from-file=meteringApiKey=metering-api-key.txt -n <namespace>
  ```

## IBM Cloud Pak for Data 

### Prerequisites
- Cloud Pak for Data on OpenShift 3.11
- Detailed requirements are explained in knowledge center article of [Getting Started with IBM Cloud Pak for Data](https://www.ibm.com/support/knowledgecenter/SS4U29/deploywavi.html)

### SecurityContext

If `schConfigName` is set, the following `SecurityContext` should be specified in the sch configuration.

```yaml
    securityContextSpec:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
{{- end }}
    securityContextContainer:
      securityContext:
        runAsNonRoot: true
{{- if not (.Capabilities.APIVersions.Has "security.openshift.io/v1") }}
        runAsUser: {{ .Values.runAsUser }}
{{- end }}
        privileged: false
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}
```

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-anyuid-hostaccess-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-voice-gateway-scc
    allowHostDirVolumePlugin: true
    allowHostIPC: false
    allowHostNetwork: true
    allowHostPID: false
    allowHostPorts: true
    allowPrivilegedContainer: false
    allowPrivilegeEscalation: false
    defaultAllowPrivilegeEscalation: false
    forbiddenSysctls:
      - "*"
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
    ```
### Required for IBM Cloud Pak for Data

#### Configure Watson services:

- Create the following Watson services on IBM Cloud Pak for Data cluster for Media Relay and Sip Orchestrator.

  - [Watson Speech to Text](https://cloud.ibm.com/catalog/services/speech-to-text/)
  - [Watson Text to Speech](https://cloud.ibm.com/catalog/services/text-to-speech/) (self-service only)

- Create the following Watson Assistant services on IBM Cloud Pak for Data for Media Relay and Sip Orchestrator and SMS Gateway

  - [Watson Assistant](https://cloud.ibm.com/catalog/services/watson-assistant) (self-service only)

    **Important:** For the Watson Assistant service, you'll need to add a workspace with a dialog(Dialog skill). You can quickly get started by importing the [sample-conversation-en.json](https://github.com/WASdev/sample.voice.gateway/tree/master/conversation) file from your cloned sample.voice.gateway GitHub repository. To learn more about importing JSON files, see [Creating Dialog skill](https://cloud.ibm.com/docs/services/assistant?topic=assistant-skill-dialog-add) in the Assistant documentation. If you build your own dialog instead of using the sample, ensure that your dialog includes a node with the _conversation_start_ condition and node with a default response.

## IBM Cloud Private or IBM Cloud Pak for Data

Following will be required for Voice Gateway container deployments on either IBM Cloud Private or IBM Cloud Pak for Data environments

### Configure tenant configuration secret :

#### For Media Relay and Sip Orchestrator:
- Create a tenantConfig.json with the tenant credentials and any additional parameters. A sample tenantConfig.json can be found in the [tenantConfig.json](https://github.com/WASdev/sample.voice.gateway/blob/master/kubernetes/multi-tenant/tenantConfig.json) file.

  > Visit [Advanced JSON configuration](https://www.ibm.com/support/knowledgecenter/SS4U29/json_config_props.html) for more information.

- Create a secret `vgw-tenantconfig-secret` from the tenantConfig.json file using the following command:
  ```bash
  kubectl create secret generic vgw-tenantconfig-secret --from-file=tenantConfig=tenantConfig.json -n <namespace>
  ```
  > Make sure to use the namespace you want to deploy this chart in.

#### For SMS Gateway:

- Create a tenantConfig.json with the tenant credentials and any additional parameters. A sample multi tenant configuration can be found in the [tenantConfig.json](https://github.com/WASdev/sample.voice.gateway/blob/master/sms/kubernetes/bluemix/multi-tenant/tenantconfig/tenantConfig.json) file.

  > Visit [Advanced JSON configuration](https://www.ibm.com/support/knowledgecenter/en/SS4U29/sms_json_config_props.html) for more information.

- Create a secret `smsgw-tenantconfig-secret` from the tenantConfig.json file using the following command:
  ```bash
  kubectl create secret generic smsgw-tenantconfig-secret --from-file=tenantConfig=tenantConfig.json -n <namespace>
  ```
  > Make sure to use the namespace you want to deploy this chart in.


## Resources Required for Media Relay and Sip Orchestrator

- The chart makes use of hostNetwork mode.
- To enable recording you will have to configure a PersistentVolume or must have dynamic provisioning set up.
- System requirements:
  ```
  RAM         8 gigabytes (GB)
  vCPUs       2 vCPU with x86-64 architecture at 2.4 GHz clock speed
                  Note: Varies based on expected number of concurrent calls and other factors
  Storage     50 gigabytes (GB)
                  Note: Call recording and log storage settings significantly affect storage requirements
  OS          Ubuntu 16.04 LTS, Red Hat Enterprise Linux (RHEL) 7.3 and 7.4
  ```

## Resources Required for SMS Gateway

- System requirements:
  ```
  RAM         8 gigabytes (GB)
  vCPUs       2 vCPU with x86-64 architecture at 2.4 GHz clock speed
                  
  Storage     50 gigabytes (GB)
                  Note: log storage settings significantly affect storage requirements
  OS          Ubuntu 16.04 LTS, Red Hat Enterprise Linux (RHEL) 7.3 and 7.4
  ```

## Installing the Chart

To install the chart with the release name `my-release`:

For example:

```bash
helm install ibm-charts/ibm-voice-gateway-dev --name my-release --namespace <namespace>
```

To specify any extra parameters you can use the `--set` option or create a `yaml` file with the parameters and specify it using the `-f` option on the command line.

> For a complete list of supported parameters, please take a look at the table in [Configuration](#configuration) section below.

## Verifying the chart

To verify the chart, you need a system with kubectl and helm installed and configured.

1. Check for chart deployment information by issuing the following commands:

```bash
helm list --namespace <namespace>
helm status my-release --namespace <namespace>
```

2. Get the name of the pod that was deployed with ibm-voice-gateway-dev by issuing the following command:

```bash
kubectl get pod -n <namespace>
```

3. Check under Events to see whether the image was successfully pulled and the container was created and started by issuing the following command with the pod name:

```bash
kubectl describe pod <pod name> -n <namespace>
```

## Uninstalling the chart

1. To uninstall the deployed chart from the master node dashboard, click Workloads -> Helm Releases.

- Find the release name and under action click delete.

2. To uninstall the deployed chart from the command line, issue the following command:

```bash
helm delete --purge my-release --namespace <namespace>
kubectl delete pvc -l release=my-release -n <namespace>
```

## Configuration

The following table lists the configurable parameters of the ibm-voice-gateway-dev chart and their default values.

| Parameter                                                      | Description                                           | Default                         |
| -------------------------------------------------------------- | ----------------------------------------------------- | ------------------------------- |
| `global.image.repository`                                                   | Docker registry to pull the images from        | `ibmcom`            |
| `global.image.pullSecrets`                                       | Docker registry image pull secret                   | `n/a`                           |
| `global.disableSslCertValidation`                                       | Disable SSL Certificate Validation. Should not be used for production environment                   | `false`                           |
| `arch.amd64`                                                   | Architecture preference for target worker node        | `3 - Most preferred`            |
| `sip.enable`                                                   | Enable Voice Gateway                                  | `true`                          |
| `sip.nodeSelector`                                                   | Node Selector label                                  | `n/a`                          |
| `sip.resources.requests.cpu`                                                   | CPU resource request                                  | `1000m`                          |
| `sip.resources.requests.memory`                                                   | Memory resource request                                  | `4Gi`                          |
| `sip.resources.limits.cpu`                                                   | CPU resource limit                                  | `2000m`                          |
| `sip.resources.limits.memory`                                                   | Memory resource limit                                  | `8Gi`                          |
| `replicaCount`                                                 | Number of replicas                                    | `1`                             |
| `tenantConfigSecretName`                                       | Tenant Config secret name                             | `vgw-tenantconfig-secret`       |
| `image.sipOrchestrator.name`                             | Sip Orchestrator docker image name                           | `voice-gateway-so`       |
| `image.sipOrchestrator.containerName`                          | Sip Orchestrator container name                       | `vgw-sip-orchestrator`          |
| `image.sipOrchestrator.tag`                                    | Sip Orchestrator docker image tag                     | `1.0.5.0`                       |
| `image.mediaRelay.name`                                  | Media Relay docker image name                                | `voice-gateway-mr`       |
| `image.mediaRelay.containerName`                               | Media Relay container name                            | `vgw-media-relay`               |
| `image.mediaRelay.tag`                                         | Media Relay docker image tag                          | `1.0.5.0`                       |
| `image.pullPolicy`                                             | Image pull policy                                     | `IfNotPresent`                        |
| `sip.codecs.g729.enable`                                       | Enable G729 Codec Service                   | `false`                           |
| `sip.codecs.image.name`                                       | G729 Codec Service docker image name                   | `voice-gateway-codec-g729`                           |
| `sip.codecs.image.containerName`                                       | G729 Codec Service container name                   | `vgw-codec-g729`                           |
| `sip.codecs.image.tag`                                       | G729 Codec Service docker image tag                   | `1.0.5.0`                           |
| `sip.codecs.g729.resources.requests.cpu`                                                   | CPU resource request                                  | `1000m`                          |
| `sip.codecs.g729.resources.requests.memory`                                                   | Memory resource request                                  | `4Gi`                          |
| `sip.codecs.g729.resources.limits.cpu`                                                   | CPU resource limit                                  | `2000m`                          |
| `sip.codecs.g729.resources.limits.memory`                                                   | Memory resource limit                                  | `8Gi`                          |
| `persistence.useDynamicProvisioning`                           | Dynamic provisioning setup                            | `false`                         |
| `persistence.recordingsVolume.enablePersistentRecordings`      | Enable persistent volume for recordings               | `false`                         |
| `persistence.recordingsVolume.name`                            | Name of the persistent volume claim                   | `recordings`                    |
| `persistence.recordingsVolume.storageClassName`                | Existing storage class name                           | `n/a`                           |
| `persistence.recordingsVolume.size`                            | Size of the volume claim                              | `2Gi`                           |
| `persistence.logsVolume.enablePersistentLogs`                  | Enable persistent volume for logs                     | `false`                         |
| `persistence.logsVolume.name`                                  | Name of the persistent volume claim                   | `persistent-logs`               |
| `persistence.logsVolume.storageClassName`                      | Existing storage class name                           | `n/a`                           |
| `persistence.logsVolume.size`                                  | Size of the volume claim                              | `2Gi`                           |
| `mediaRelayEnvVariables.mediaRelayWsHost`                      | Media Relay WS Host                                   | `0.0.0.0`                       |
| `mediaRelayEnvVariables.mediaRelayWsPort`                      | Media Relay WS Port                                   | `8080`                          |
| `mediaRelayEnvVariables.rtpUdpPortRange`                       | RTP UDP Port Range                                    | `16384-16394`                   |
| `mediaRelayEnvVariables.clusterWorkers`                        | Cluster Workers                                       | `1`                             |
| `mediaRelayEnvVariables.maxSessions`                           | Max Simultaneous Sessions                             | `0`                             |
| `mediaRelayEnvVariables.enableRecording`                       | Enable call audio recording on the Media Relay        | `false`                         |
| `mediaRelayEnvVariables.stereoRecording`                       | Stereo Recording                                      | `false`                         |
| `mediaRelayEnvVariables.mediaRelayLogLevel`                    | Media Relay Log Level                                 | `INFO`                          |
| `mediaRelayEnvVariables.mediaRelayLogRotationFileCount`        | Media Relay Log Rotation File Count                   | `10`                            |
| `mediaRelayEnvVariables.mediaRelayLogRotationPeriod`           | Media Relay Log Rotation Period                       | `1d`                            |
| `mediaRelayEnvVariables.rtpPacketLossReportingThreshold`       | RTP Packet Loss Reporting Threshold                   | `1000`                          |
| `mediaRelayEnvVariables.proxyType`                             | Media Relay Proxy Type                                | `http`                          |
| `mediaRelayEnvVariables.proxyHost`                             | Media Relay Proxy Host                                | `n/a`                           |
| `mediaRelayEnvVariables.proxyPort`                             | Media Relay Proxy Port                                | `n/a`                           |
| `mediaRelayEnvVariables.proxyUsername`                         | Media Relay Proxy Username                            | `n/a`                           |
| `mediaRelayEnvVariables.proxyPasswordSecret`                   | Media Relay Proxy Password secret name                | `n/a`                           |
| `mediaRelayEnvVariables.watsonSttEnableProxy`                  | Watson STT Enable Proxy                               | `true`                          |
| `mediaRelayEnvVariables.watsonTtsEnableProxy`                  | Watson TTS Enable Proxy                               | `true`                          |
| `mediaRelayEnvVariables.musicOnHoldEnableProxy`                | Music On Hold Enable Proxy                            | `false`                         |
| `mediaRelayEnvVariables.enableMrcp`                            | Enable MRCPv2 connections                             | `false`                         |
| `mediaRelayEnvVariables.unimrcpConfigSecretName`               | unimrcpConfig secret name                             | `unimrcp-config-secret`         |
| `mediaRelayEnvVariables.mrcpv2SipPort`                         | MRCPv2 SIP Port                                       | `5555`                          |
| `mediaRelayEnvVariables.enableSsl`                             | Enable SSL                                            | `false`                         |
| `mediaRelayEnvVariables.sslClientCACertSecret`                 | SSL client CA certificate secret                      | `client-ca-cert-secret`         |
| `mediaRelayEnvVariables.enableMutualAuth`                      | Secure connections using Mutual Authentication        | `false`                         |
| `mediaRelayEnvVariables.sslClientPkcs12FileSecret`             | SSL client PKCS12 file secret                         | `ssl-client-pkcs12-file-secret` |
| `mediaRelayEnvVariables.sslClientPassphraseSecret`             | SSL client passphrase secret name                     | `ssl-client-passphrase-secret`  |
| `sipOrchestratorEnvVariables.httpHost`                         | HTTP Host                                             | `*`                     |
| `sipOrchestratorEnvVariables.httpPort`                         | HTTP Port                                             | `9086`                     |
| `sipOrchestratorEnvVariables.httpPortTls`                         | HTTP Port for TLS                                             | `9446`                     | 
| `sipOrchestratorEnvVariables.secureAdminInterface`             | Secure admin interface with credentials               | `false`                         |
| `sipOrchestratorEnvVariables.adminCredentialSecret`            | Admin Credential secret                               | `admin-credentials`             |
| `sipOrchestratorEnvVariables.mediaRelayHost`                   | Media Relay Host                                      | `localhost:8080`                |
| `sipOrchestratorEnvVariables.sipPort`                          | SIP Port                                              | `5060`                          |
| `sipOrchestratorEnvVariables.sipPortTcp`                       | SIP Port for TCP                                      | `5060`                          |
| `sipOrchestratorEnvVariables.sipPortTls`                       | SIP Port for TLS                                      | `5061`                          |
| `sipOrchestratorEnvVariables.logLevel`                         | Log Level                                             | `info`                          |
| `sipOrchestratorEnvVariables.logMaxFiles`                      | Log Max Files                                         | `5`                             |
| `sipOrchestratorEnvVariables.logMaxFileSize`                   | Log Max File Size                                     | `100`                           |
| `sipOrchestratorEnvVariables.enableAuditMessages`              | Enable Audit Messages                                 | `true`                          |
| `sipOrchestratorEnvVariables.enableTranscriptionAuditMessages` | Enable Transcription Audit Messages                   | `false`                         |
| `sipOrchestratorEnvVariables.latencyReportingThreshold`        | Latency Reporting Threshold                           | `1000`                          |
| `sipOrchestratorEnvVariables.relayLatencyReportingThreshold`   | Relay Latency Reporting Threshold                     | `1000`                          |
| `sipOrchestratorEnvVariables.proxyHost`                        | Sip Orchestrator Proxy Host                           | `n/a`                           |
| `sipOrchestratorEnvVariables.proxyPort`                        | Sip Orchestrator Proxy Port                           | `n/a`                           |
| `sipOrchestratorEnvVariables.proxyUsername`                    | Sip Orchestrator Proxy Username                       | `n/a`                           |
| `sipOrchestratorEnvVariables.proxyPasswordSecret`              | Sip Orchestrator Proxy Password secret name           | `n/a`                           |
| `sipOrchestratorEnvVariables.trustedIpList`                    | Trusted IP List                                       | `n/a`                           |
| `sipOrchestratorEnvVariables.cmrHealthCheckFailErrCode`        | CMR Health Check Fail Err Code                        | `n/a`                           |
| `sipOrchestratorEnvVariables.consoleLogFormat`                 | Console logging format                                | `json`                          |
| `sipOrchestratorEnvVariables.consoleLogLevel`                  | Console logging level                                 | `info`                          |
| `sipOrchestratorEnvVariables.consoleLogSource`                 | Console logging sources                               | `message,trace,accessLog,ffdc`  |
| `sipOrchestratorEnvVariables.enableSslorMutualAuth`            | Secure connections using SSL or Mutual Authentication | `false`                         |
| `sipOrchestratorEnvVariables.sslKeyTrustStoreSecret`           | SSL key trust store secret                            | `trust-store-file-secret`       |
| `sipOrchestratorEnvVariables.sslFileType`                      | SSL file type                                         | `JKS`                           |
| `sipOrchestratorEnvVariables.sslPassphraseSecret`              | SSL passphrase secret name                            | `ssl-passphrase-secret`         |
| `sipOrchestratorEnvVariables.enableMetricsAuth`                | Enable authentication for the monitoring API          | `false`                         |
| `sipOrchestratorEnvVariables.metricsSamplingInterval`          | Metrics Sampling Interval in seconds                  | `600`                           |
| `metering.apiKeySecret`           | (ICP only) Metering Api Key Secret            | `metering-api-key-secret`                                            |
| `metering.icpMasterNodeIP`           | (ICP only) IBM Cloud Private Master Node Domain/IP             | `mycluster.icp`                                  |
| `metering.serverURL`           | (ICP only) Metering Server URL             | `https://mycluster.icp:8443/meteringapi`                                   |
| `sms.enable`                                                   | Enable SMS Gateway                                    | `false`                         |
| `sms.replicas`                                                 | Number of replicas                                    | `1`                             |
| `sms.nodeSelector`                                                   | Node Selector label                                  | `n/a`                          |
| `sms.tenantConfigSecretName`                                   | Tenant Config secret name                             | `smsgw-tenantconfig-secret`     |
| `sms.image.name`                                         | SMS Gateway docker image name                                | `voice-gateway-sms`      |
| `sms.image.containerName`                                      | SMS Gateway container name                            | `vgw-sms-gateway`               |
| `sms.image.tag`                                                | SMS Gateway docker image tag                          | `1.0.5.0`                       |
| `sms.image.containerPort`                                      | SMS Gateway for TCP                                   | `9080`                          |
| `sms.image.servicePort`                                      | Service Port for TCP connection                                   | `30087`                          |
| `sms.image.containerPortTls`                                   | SMS Gateway for TLS                                   | `9443`                          |
| `sms.image.servicePortTls`                                   | Service Port for TLS connection                                   | `30047`                          |
| `sms.image.pullPolicy`                                         | Image pull policy                                     | `IfNotPresent`                  |
| `sms.networkPolicy.smsProviderPort`                  | SMS Provider Port                                     | `80`                  |
| `sms.networkPolicy.smsProviderPortTls`             | SMS Provider TLS Port                                     | `443`                  |
| `sms.networkPolicy.disableNonSecurePort`                    | Disable Non Secure Port. Recommended to be enabled in Production Environment                            | `false`                  |
| `sms.persistence.volume.useDynamicProvisioning`                | Dynamic provisioning setup                            | `false`                         |
| `sms.persistence.volume.logs.enable`                           | Enable persistent volume for logs                     | `false`                         |
| `sms.persistence.volume.logs.name`                             | Name of the persistent volume claim                   | `sms-persistent-logs`           |
| `sms.persistence.volume.logs.storageClassName`                 | Existing storage class name                           | `n/a`                           |
| `sms.persistence.volume.logs.size`                             | Size of the volume claim                              | `2Gi`                           |
| `sms.persistence.volume.transReports.enable`                   | Enable persistent volume for transReports             | `false`                         |
| `sms.persistence.volume.transReports.name`                     | Name of the persistent volume claim                   | `transcription-reports`         |
| `sms.persistence.volume.transReports.storageClassName`         | Existing storage class name                           | `n/a`                           |
| `sms.persistence.volume.transReports.size`                     | Size of the volume claim                              | `2Gi`                           |
| `sms.persistence.volume.usageReports.enable`                   | Enable persistent volume for usageReports             | `false`                         |
| `sms.persistence.volume.usageReports.name`                     | Name of the persistent volume claim                   | `usage-reports`                 |
| `sms.persistence.volume.usageReports.storageClassName`         | Existing storage class name                           | `n/a`                           |
| `sms.persistence.volume.usageReports.size`                     | Size of the volume claim                              | `2Gi`                           |
| `sms.logging.level`                                            | Log Level                                             | `info`                          |
| `sms.logging.maxFiles`                                         | Log Max Files                                         | `5`                             |
| `sms.logging.maxFileSize`                                      | Log Max File Size                                     | `100`                           |
| `sms.logging.enableTranscriptionMessages`                      | Enable Transcription Messages                         | `false`                         |
| `sms.logging.latencyReportingThreshold`                        | Latency Reporting Threshold                           | `1000`                          |
| `sms.logging.hideCallerID`                                     | Mask caller ID information                            | `false`                         |
| `sms.providerProxy.enable`                                     | Enable SMS provider Proxy                             | `false`                         |
| `sms.providerProxy.host`                                       | SMS provider Proxy Host                               | `n/a`                           |
| `sms.providerProxy.port`                                       | SMS provider Proxy Port                               | `n/a`                           |
| `sms.providerProxy.username`                                   | SMS provider Proxy Username                           | `n/a`                           |
| `sms.providerProxy.passwordSecret`                             | SMS provider Proxy Password secret name               | `n/a`                           |
| `sms.cloudantProxy.enable`                                     | Enable SMS Gateway Cloudant Proxy                     | `false`                         |
| `sms.cloudantProxy.url`                                        | SMS Gateway Cloudant Proxy Host                       | `n/a`                           |
| `sms.cloudantProxy.username`                                   | SMS Gateway Cloudant Proxy Username                   | `n/a`                           |
| `sms.cloudantProxy.passwordSecret`                             | SMS Gateway Cloudant Proxy Password secret name       | `n/a`                           |
| `sms.assistantProxy.enable`                                    | Enable SMS Gateway Proxy                              | `false`                         |
| `sms.assistantProxy.host`                                      | SMS Gateway Proxy Host                                | `n/a`                           |
| `sms.assistantProxy.port`                                      | SMS Gateway Proxy Port                                | `n/a`                           |
| `sms.assistantProxy.username`                                  | SMS Gateway Proxy Username                            | `n/a`                           |
| `sms.assistantProxy.passwordSecret`                            | SMS Gateway Proxy Password secret name                | `n/a`                           |
| `sms.ssl.enable`                                               | Enable Secure connections using SSL                   | `false`                         |
| `sms.ssl.keyStoreFileSecret`                                   | SSL key store file secret                             | `key-store-file-secret`         |
| `sms.ssl.keyStorePassphraseSecret`                             | SSL key store passphrase secret                       | `ssl-passphrase-secret`         |
| `sms.ssl.keyFileType`                                          | SSL file type                                         | `JKS`                           |
| `sms.ssl.trustStoreFileSecret`                                 | SSL trust store file secret                           | `trust-store-file-secret`       |
| `sms.ssl.trustStorePassphraseSecret`                           | SSL trust store passphrase secret                     | `ssl-trust-passphrase-secret`   |
| `sms.ssl.trustFileType`                                        | SSL trust file type                                   | `JKS`                           |
| `sms.reporting.enable`                                         | Enable Reporting                                      | `false`                         |
| `sms.reporting.host`                                           | SMS Gateway Reporting host                            | `n/a`                           |
| `sms.reporting.enableLimitOnReportingBackupFiles`              | Enable limit on number of backup files                | `false`                         |
| `sms.reporting.usageReportingMaxBackupFiles`                   | Max Usage report backup files                         | `100 `                          |
| `sms.reporting.transcriptionReportingMaxBackupFiles`           | Max transcription report backup files                 | `1000`                          |
| `sms.reporting.maxEventsToBatch`                               | Max reporting events in one publish                   | `500`                           |

### Optional Configurations

#### G729AB Codec Service

- To enable G729AB Codec Service, enable option `Enable G729 Codec Service`

#### MRCPv2 configuration

- More info: [Configuring services with MRCPv2](https://www.ibm.com/support/knowledgecenter/SS4U29/MRCP.html)
- Create unimrcpConfig secret from the `unimrcpclient.xml` file:
  ```
  kubectl create secret generic unimrcp-config-secret --from-file=unimrcpConfig=unimrcpclient.xml -n <namespace>
  ```
- If you changed the default MRCPv2 SIP Port, make sure to update that in the helm chart configuration also.
- Enable MRCP in the configuration before deployment

#### SSL configuration

- More info: [Configuring SSL and TLS encryption](https://www.ibm.com/support/knowledgecenter/SS4U29/security.html#configuring-ssl-and-tls-encryption)

##### Adding trusted certificates for the SIP Orchestrator (For enabling SSL or Mutual Authentication):

- Create secret from the trust store key file:
  ```
  kubectl create secret generic trust-store-file-secret --from-file=trustStoreFile=myPKCS12File.p12 -n <namespace>
  ```
- Create secret for the SSL Passphrase:
  - Add passphrase in a text file `ssl_passphrase.txt` (Make sure there are no extra spaces or new lines in the text file)
  - Create secret from the text file:
    ```
    kubectl create secret generic ssl-passphrase-secret --from-file=sslPassphrase=ssl_passphrase.txt -n <namespace>
    ```
- Set type of the SSL file in the configuration
- Enable option `Enable SSL or Mutual Authentication` in the SIP Orchestrator configuration before deployment

##### Adding trusted certificates for the Media Relay (For enabling SSL):

- Create secret from client CA certificate file:
  ```
  kubectl create secret generic client-ca-cert-secret --from-file=clientCaCertFile=ca-bundle.pem -n <namespace>
  ```
- Enable option `Enable SSL` in the Media Relay configuration before deployment

##### Adding certificates for the Media Relay (For Mutual Authentication):

- Create secret from the SSL client PKCS12 file:
  ```
  kubectl create secret generic ssl-client-pkcs12-file-secret --from-file=clientPkcs12File=myPKCS12File.p12 -n <namespace>
  ```
- Create secret for the SSL Passphrase:
  - Add passphrase in a text file `ssl_client_passphrase.txt` (Make sure there are no extra spaces or new lines in the text file)
  - Create secret from the text file:
    ```
    kubectl create secret generic ssl-client-passphrase-secret --from-file=sslClientPassphrase=ssl_client_passphrase.txt -n <namespace>
    ```
  - Enable option `Enable Mutual Authentication` in the Media Relay configuration before deployment

##### Adding trusted certificates for the SMS Gateway (For enabling SSL):

- Create secret from the trust store or the key store file:
  ```
  kubectl create secret generic trust-store-file-secret --from-file=trustStoreFile=myPKCS12File.p12 -n <namespace>
  kubectl create secret generic key-store-file-secret --from-file=keyStoreFile=myPKCS12File.p12 -n <namespace>
  ```
  
- Create secret for the SSL Passphrase:
  - Add passphrase in a text file `ssl_passphrase.txt` (Make sure there are no extra spaces or new lines in the text file)
  - Create secret from the text file:
    ```
    kubectl create secret generic ssl-passphrase-secret --from-file=sslKeyPassphrase=ssl_passphrase.txt -n <namespace>
    ```
  - Do the same for truststore file passphrase
    ```
    kubectl create secret generic ssl-trust-passphrase-secret --from-file=sslTrustPassphrase=ssl_trust_passphrase.txt -n <namespace>
    ```
- Set type of the SSL file in the configuration
- Enable option `Enable SSL ` in the SMS Gateway configuration before deployment



#### Configuring secrets for proxy password for the Sip Orchestrator and the Media Relay:

- You can create the secret separately for the Sip Orchestrator and the Media Relay or use the same one.
- Create an individual text file with the Sip Orchestrator and the Media Relay proxy password. For example: `so_proxy_password.txt` and `mr_proxy_password.txt` (Make sure there are no extra spaces or new lines in the text file)
- To create the secret use one of the two ways:
  - Create separate secrets for each container:
  ```bash
  kubectl create secret generic so-proxy-password --from-file=soProxyPassword=so_proxy_password.txt -n <namespace>
  kubectl create secret generic mr-proxy-password --from-file=mrProxyPassword=mr_proxy_password.txt -n <namespace>
  ```
  - Create one secret for both containers:
  ```bash
  kubectl create secret generic proxy-password --from-file=soProxyPassword=so_proxy_password.txt --from-file=mrProxyPassword=mr_proxy_password.txt -n <namespace>
  ```
- Enter the secret name in the `Proxy Password secret name` field of the respective container or you can set the mediaRelayEnvVariables.proxyPasswordSecret and sipOrchestratorEnvVariables.proxyPasswordSecret variables during installation using Helm CLI.

#### Secure admin interface with credentials:

- Create username and password secret for admin credentials using the following command:
  ```bash
  kubectl create secret generic admin-credentials --from-literal=adminUsername=<USERNAME> --from-literal=adminPassword=<PASSWORD> -n <namespace>
  ```
- Enable option `Secure admin interface with credentials` in SIP Orchestrator configuration before deployment.

## Storage required for Voice Gateway containers

- A PersistentVolume needs to be pre-created prior to installing the chart if you want to enable persistent recording or persistent logs and no dynamic provisioning has been set up.
- A PersistentVolume can be created with specification as shown in the following yaml example:

  ```yaml
  kind: PersistentVolume
  apiVersion: v1
  metadata:
    name: <persistent volume name>
  spec:
    storageClassName: <optional - must match PVC>
    capacity:
      storage: 4Gi
    accessModes:
      - ReadWriteOnce
    persistentVolumeReclaimPolicy: Retain
    hostPath:
      path: <PATH>
  ```

  You can create a PersistentVolume using the above template by executing:

  ```bash
  kubectl create -f <yaml-file> -n <namespace>
  ```

## Limitations

Because this deployment uses `hostNetwork` mode, the Helm chart will deploy one pod per node.

## Documentation

[Deploying Voice Gateway Helm Chart](https://www.ibm.com/support/knowledgecenter/SS4U29/deployicp.html)
