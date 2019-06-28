# IBM Voice Gateway Helm Chart (Developer Trial)

## Introduction
This chart will deploy IBM Voice Gateway (Developer Trial).

[IBM Voice Gateway](https://www.ibm.com/support/knowledgecenter/SS4U29/welcome_voicegateway.html) provides a way to integrate a set of orchestrated Watson services with a public or private telephone network by using the Session Initiation Protocol (SIP). Voice Gateway enables direct voice interactions over a telephone with a cognitive self-service agent or transcribes a phone call between a caller and agent so that the conversation can be processed with analytics for real-time agent feedback.

## Chart Details
- The Chart will deploy a pod with 2 containers - Media Relay and Sip Orchestrator.

## Prerequisites
- IBM Cloud Private 3.1.0 or greater
- A user with Cluster administrator role is required to install the chart.

### PodSecurityPolicy Requirements 
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

      
### Required  
#### Configure watson services:
- Create the following Watson services on IBM Cloud.
  - [Watson Speech to Text](https://console.bluemix.net/catalog/services/speech-to-text/)
  - [Watson Text to Speech](https://console.bluemix.net/catalog/services/text-to-speech/) (self-service only)
  - [Watson Assistant (formerly Conversation)](https://console.bluemix.net/catalog/services/watson-assistant-formerly-conversation/) (self-service only)
  
    **Important:** For the Watson Assistant service, you'll need to add a workspace with a dialog. You can quickly get started by importing the [sample-conversation-en.json](https://github.com/WASdev/sample.voice.gateway/tree/master/conversation) file from your cloned sample.voice.gateway GitHub repository. To learn more about importing JSON files, see [Creating workspaces](https://console.bluemix.net/docs/services/conversation/configure-workspace.html#creating-workspaces) in the Conversation documentation. If you build your own dialog instead of using the sample, ensure that your dialog includes a node with the *conversation_start* condition and node with a default response.
  
#### Configure tenant configuration secret:
- Create a tenantConfig.json with the tenant credentials and any additional parameters. A sample tenantConfig.json can be found in the [tenantConfig.json](https://github.com/WASdev/sample.voice.gateway/blob/master/kubernetes/multi-tenant/tenantConfig.json) file.
  > Visit [Advanced JSON configuration](https://www.ibm.com/support/knowledgecenter/SS4U29/json_config_props.html) for more information.

- Create a secret `vgw-tenantconfig-secret` from the tenantConfig.json file using the following command:
  ```bash
  kubectl create secret generic vgw-tenantconfig-secret --from-file=tenantConfig=tenantConfig.json -n <namespace>
  ```
  > Make sure to use the namespace you want to deploy this chart in.

#### Create metering API Key Secret:
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

## Resources Required
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

| Parameter                             | Description                                                  | Default                                                    |
| ------------------------------        | ----------------------------------------------------------   | ---------------------------------------------------------- |
| `arch.amd64`                  | Architecture preference for target worker node | `3 - Most preferred`       |
| `productName`                  | Product name | `IBM Voice Gateway`       |
| `replicaCount`                    | Number of replicas                                                  | `1`                         |
| `nodeSelector`                    | Node selector label                                                  | `n/a`                         |
| `tenantConfigSecretName`           | Tenant Config secret name             | `vgw-tenantconfig-secret`                                                      |
| `image.sipOrchestrator.repository`           | Sip Orchestrator repository             | `ibmcom/voice-gateway-so`                                                      |
| `image.sipOrchestrator.containerName`           | Sip Orchestrator container name             | `vgw-sip-orchestrator`                                                      |
| `image.sipOrchestrator.tag`           | Sip Orchestrator docker image tag             | `1.0.2.0`                                                      |
| `image.mediaRelay.repository`           | Media Relay repository             | `ibmcom/voice-gateway-mr`                                                      |
| `image.mediaRelay.containerName`           | Media Relay container name             | `vgw-media-relay`                                                      |
| `image.mediaRelay.tag`           | Media Relay docker image tag             | `1.0.2.0`                                                      |
| `image.pullPolicy`           | Image pull policy             | `Always`                                                      |
| `image.imagePullSecrets`           | Docker repository image pull secret             | `n/a`                                                      |
| `persistence.useDynamicProvisioning`           | Dynamic provisioning setup             | `false`                                                      |
| `persistence.recordingsVolume.enablePersistentRecordings`           | Enable persistent volume for recordings             | `false`                                                      |
| `persistence.recordingsVolume.name`           | Name of the persistent volume claim             | `recordings`                                                      |
| `persistence.recordingsVolume.storageClassName`           | Existing storage class name             | `n/a`                                                      |
| `persistence.recordingsVolume.size`           | Size of the volume claim             | `2Gi`                                                      |
| `persistence.logsVolume.enablePersistentLogs`           | Enable persistent volume for logs             | `false`                                                      |
| `persistence.logsVolume.name`           | Name of the persistent volume claim             | `persistent-logs`                                                      |
| `persistence.logsVolume.storageClassName`           | Existing storage class name             | `n/a`                                                      |
| `persistence.logsVolume.size`           | Size of the volume claim             | `2Gi`                                                      |
| `mediaRelayEnvVariables.mediaRelayWsHost`           | Media Relay WS Host             | `0.0.0.0`                                                      |
| `mediaRelayEnvVariables.mediaRelayWsPort`           | Media Relay WS Port             | `8080`                                                      |
| `mediaRelayEnvVariables.rtpUdpPortRange`           | RTP UDP Port Range             | `16384-16394`                                                      |
| `mediaRelayEnvVariables.clusterWorkers`           | Cluster Workers             | `1`                                                      |
| `mediaRelayEnvVariables.maxSessions`           | Max Simultaneous Sessions             | `0`                                                      |
| `mediaRelayEnvVariables.enableRecording`           | Enable call audio recording on the Media Relay             | `false`                                                      |
| `mediaRelayEnvVariables.stereoRecording`           | Stereo Recording             | `false`                                                      |
| `mediaRelayEnvVariables.mediaRelayLogLevel`           | Media Relay Log Level             | `INFO`                                                      |
| `mediaRelayEnvVariables.mediaRelayLogRotationFileCount`           | Media Relay Log Rotation File Count             | `10`                                                      |
| `mediaRelayEnvVariables.mediaRelayLogRotationPeriod`           | Media Relay Log Rotation Period             | `1d`                                                      |
| `mediaRelayEnvVariables.rtpPacketLossReportingThreshold`           | RTP Packet Loss Reporting Threshold             | `1000`                                                      |
| `mediaRelayEnvVariables.proxyType`           | Media Relay Proxy Type             | `http`                                                      |
| `mediaRelayEnvVariables.proxyHost`           | Media Relay Proxy Host             | `n/a`                                                      |
| `mediaRelayEnvVariables.proxyPort`           | Media Relay Proxy Port             | `n/a`                                                      |
| `mediaRelayEnvVariables.proxyUsername`           | Media Relay Proxy Username             | `n/a`                                                      |
| `mediaRelayEnvVariables.proxyPasswordSecret`           | Media Relay Proxy Password secret name             | `n/a`                                                      |
| `mediaRelayEnvVariables.watsonSttEnableProxy`           | Watson STT Enable Proxy             | `true`                                                      |
| `mediaRelayEnvVariables.watsonTtsEnableProxy`           | Watson TTS Enable Proxy             | `true`                                                      |
| `mediaRelayEnvVariables.musicOnHoldEnableProxy`           | Music On Hold Enable Proxy             | `false`                                                      |
| `mediaRelayEnvVariables.enableMrcp`           | Enable MRCPv2 connections             | `false`                                                      |
| `mediaRelayEnvVariables.unimrcpConfigSecretName`           | unimrcpConfig secret name             | `unimrcp-config-secret`                                                      |
| `mediaRelayEnvVariables.mrcpv2SipPort`           | MRCPv2 SIP Port             | `5555`                                                      |
| `mediaRelayEnvVariables.enableSsl`           | Enable SSL             | `false`                                                      |
| `mediaRelayEnvVariables.sslClientCACertSecret`           | SSL client CA certificate secret             | `client-ca-cert-secret`                                                      |
| `mediaRelayEnvVariables.enableMutualAuth`           | Secure connections using Mutual Authentication             | `false`                                                      |
| `mediaRelayEnvVariables.sslClientPkcs12FileSecret`           | SSL client PKCS12 file secret             | `ssl-client-pkcs12-file-secret`                                                      |
| `mediaRelayEnvVariables.sslClientPassphraseSecret`           | SSL client passphrase secret name             | `ssl-client-passphrase-secret`                                                      |
| `sipOrchestratorEnvVariables.httpHost`           | HTTP Host             | `127.0.0.1`                                                      |
| `sipOrchestratorEnvVariables.secureAdminInterface`           | Secure admin interface with credentials             | `false`                                                      |
| `sipOrchestratorEnvVariables.adminCredentialSecret`           | Admin Credential secret             | `admin-credentials`                                                      |
| `sipOrchestratorEnvVariables.mediaRelayHost`           | Media Relay Host             | `localhost:8080`                                                      |
| `sipOrchestratorEnvVariables.sipPort`           | SIP Port             | `5060`                                                      |
| `sipOrchestratorEnvVariables.sipPortTcp`           | SIP Port for TCP             | `5060`                                                      |
| `sipOrchestratorEnvVariables.sipPortTls`           | SIP Port for TLS             | `5061`                                                      |
| `sipOrchestratorEnvVariables.logLevel`           | Log Level             | `info`                                                      |
| `sipOrchestratorEnvVariables.logMaxFiles`           | Log Max Files             | `5`                                                      |
| `sipOrchestratorEnvVariables.logMaxFileSize`           | Log Max File Size             | `100`                                                      |
| `sipOrchestratorEnvVariables.enableAuditMessages`           | Enable Audit Messages             | `true`                                                      |
| `sipOrchestratorEnvVariables.enableTranscriptionAuditMessages`           | Enable Transcription Audit Messages             | `false`                                                      |
| `sipOrchestratorEnvVariables.latencyReportingThreshold`           | Latency Reporting Threshold             | `1000`                                                      |
| `sipOrchestratorEnvVariables.relayLatencyReportingThreshold`           | Relay Latency Reporting Threshold             | `1000`                                                      |
| `sipOrchestratorEnvVariables.proxyHost`           | Sip Orchestrator Proxy Host             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.proxyPort`           | Sip Orchestrator Proxy Port             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.proxyUsername`           | Sip Orchestrator Proxy Username             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.proxyPasswordSecret`           | Sip Orchestrator Proxy Password secret name            | `n/a`                                                      |
| `sipOrchestratorEnvVariables.trustedIpList`           | Trusted IP List             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.cmrHealthCheckFailErrCode`           | CMR Health Check Fail Err Code             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.consoleLogFormat`           | Console logging format             | `json`                                                      |
| `sipOrchestratorEnvVariables.consoleLogLevel`           | Console logging level             | `info`                                                      |
| `sipOrchestratorEnvVariables.consoleLogSource`           | Console logging sources             | `message,trace,accessLog,ffdc`                                                      |
| `sipOrchestratorEnvVariables.enableSslorMutualAuth`           | Secure connections using SSL or Mutual Authentication             | `false`                                                      |
| `sipOrchestratorEnvVariables.sslKeyTrustStoreSecret`           | SSL key trust store secret             | `trust-store-file-secret`                                                      |
| `sipOrchestratorEnvVariables.sslFileType`           | SSL file type             | `JKS`                                                      |
| `sipOrchestratorEnvVariables.sslPassphraseSecret`           | SSL passphrase secret name             | `ssl-passphrase-secret`                                                      |
| `sipOrchestratorEnvVariables.enableMetricsAuth`           | Enable authentication for the monitoring API             | `false`                                                      |
| `sipOrchestratorEnvVariables.metricsSamplingInterval`           | Metrics Sampling Interval in seconds             | `600`                                                      |
| `metering.meteringApiKeySecret`           | Metering Api Key Secret            | `metering-api-key-secret`                                                      |
| `metering.icpMasterNodeIP`           | IBM Cloud Private Master Node Domain/IP             | `mycluster.icp`                                                      |
| `metering.meteringServerURL`           | Metering Server URL             | `https://mycluster.icp:8443/meteringapi`                                                      |

### Optional Configurations  
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

## Storage
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
    - ReadWriteMany
    persistentVolumeReclaimPolicy: Retain
    hostPath:
      path: <PATH>
  ```

  You can create a PersistentVolume using the above template by executing:
  ```bash
  kubectl create -f <yaml-file> -n <namespace>
  ```
  
## Limitations
Because this deployment uses hostNetwork mode, the Helm Chart will deploy one pod per node.

## Documentation
[Deploying Voice Gateway Helm Chart](https://www.ibm.com/support/knowledgecenter/SS4U29/deployicp.html)