# IBM Voice Gateway Helm Chart (Developer Trial)

## Introduction

This chart will deploy IBM Voice Gateway (Developer Trial).

[IBM Voice Gateway](https://www.ibm.com/support/knowledgecenter/SS4U29/welcome_voicegateway.html) provides a way to integrate a set of orchestrated Watson services with a public or private telephone network by using the Session Initiation Protocol (SIP). Voice Gateway enables direct voice interactions over a telephone with a cognitive self-service agent or transcribes a phone call between a caller and agent so that the conversation can be processed with analytics for real-time agent feedback.

## Chart Details

- The Chart will deploy a pod with 2 containers - Media Relay and Sip Orchestrator.

## Prerequisites

- IBM Cloud Private 3.1
- A user with Cluster administrator role is required to install the chart.
- IBM Cloud Private has RBAC enabled, so it requires that you add certain RBAC objects before you deploy the Voice Gateway Helm Chart in a non-default namespace.

### Configure RBAC 
Following RBAC objects must be created before deploying the Voice Gateway Helm Chart in a non-default namespace:

#### PodSecurityPolicy
  ```yaml
  apiVersion: extensions/v1beta1
  kind: PodSecurityPolicy
  metadata:
    name: voice-gateway-psp
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

#### ServiceAccount
*Note: You need to change namespace value to the namespace where you are installing the Voice Gateway Helm Chart.*
  ```yaml
  apiVersion: v1
  kind: ServiceAccount
  metadata:
    name: voice-gateway-serviceaccount
    namespace: <voice-gateway-deployment-namespace>
  ```

#### ClusterRole
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRole
  metadata:
    name: voice-gateway-clusterrole
  rules:
  - apiGroups:
    - extensions
    resources:
    - podsecuritypolicies
    resourceNames:
    - voice-gateway-psp
    verbs:
    - use  
  ```
  
#### ClusterRoleBinding
*Note: You need to change namespace value to the namespace where you are installing the Voice Gateway Helm Chart.*
  ```yaml
  apiVersion: rbac.authorization.k8s.io/v1
  kind: ClusterRoleBinding
  metadata:
    name: voice-gateway-clusterrolebinding
  roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: voice-gateway-clusterrole
  subjects:
  - kind: ServiceAccount
    name: voice-gateway-serviceaccount
    namespace: <voice-gateway-deployment-namespace>
  ```

### Required
- Create the following Watson services on IBM Cloud.
  - [Watson Speech to Text](https://console.bluemix.net/catalog/services/speech-to-text/)
  - [Watson Text to Speech](https://console.bluemix.net/catalog/services/text-to-speech/) (self-service only)
  - [Watson Assistant (formerly Conversation)](https://console.bluemix.net/catalog/services/watson-assistant-formerly-conversation/) (self-service only)
  
    **Important:** For the Watson Assistant service, you'll need to add a workspace with a dialog. You can quickly get started by importing the [sample-conversation-en.json](https://github.com/WASdev/sample.voice.gateway/tree/master/conversation) file from your cloned sample.voice.gateway GitHub repository. To learn more about importing JSON files, see [Creating workspaces](https://console.bluemix.net/docs/services/conversation/configure-workspace.html#creating-workspaces) in the Conversation documentation. If you build your own dialog instead of using the sample, ensure that your dialog includes a node with the *conversation_start* condition and node with a default response.
  
- Create a tenantConfig.json with the tenant credentials and any additional parameters. A sample tenantConfig.json can be found in the [tenantConfig.json](https://github.com/WASdev/sample.voice.gateway/blob/master/kubernetes/multi-tenant/tenantConfig.json) file.
- Visit [Advanced JSON configuration](https://www.ibm.com/support/knowledgecenter/SS4U29/json_config_props.html) for more information.

- Complete the steps mentioned on [IBM® Cloud Private metering service](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_metrics/metering_service.html#track_usage) page to create the Metering API Key.
- Retrieve the Metering API Key:
    - After you have created the API Key, return to the IBM Cloud Private Management Console, open the menu and click **Platform > Metering**.
    - On the *Metering dashboard*, select **Manage API Keys**. Use this form to retrieve the metering API key that you created.

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

## Installing the chart

To install the chart with the release name `my-release`:

When installing the chart using CLI, you need to create a secret `vgw-tenantconfig-secret` from the tenantConfig.json file before deployment using the following command:
  ```bash
  kubectl create secret generic vgw-tenantconfig-secret --from-file=tenantConfig.json
  ```

Create file `metering.yaml` with the following parameters configured:
  ```yaml
  metering:
      meteringApiKey: ""
  ```
    
Use the `--set` option on the command line to specify parameters.
For example:
  ```bash
  helm install ibm-charts/ibm-voice-gateway-dev --name my-release \
  --set tenantConfigSecretName=vgw-tenantconfig-secret \
  -f metering.yaml
  ```
    
> The above command contains mandatory parameters for a successful deployment of the Voice Gateway Helm Chart.

To add any extra parameters, you can create a values.yaml files with the parameters and specify it in the command using `-f values.yaml`

## Verifying the chart

To verify the chart, you need a system with kubectl and helm installed and configured.

1. Check for chart deployment information by issuing the following commands:
  ```bash
  helm list
  helm status my-release
  ```
    
2. Get the name of the pod that was deployed with ibm-voice-gateway-dev by issuing the following command:
  ```bash
  kubectl get pod
  ```
    
3. Check under Events to see whether the image was successfully pulled and the container was created and started by issuing the following command with the pod name:
  ```bash
  kubectl describe pod <pod name>
  ```

## Uninstalling the chart

1. To uninstall the deployed chart from the master node dashboard, click Workloads -> Helm Releases.
- Find the release name and under action click delete.

2. To uninstall the deployed chart from the command line, issue the following command:
  ```bash
  helm delete --purge my-release
  kubectl delete pvc -l release=my-release 
  ```

## Configuration

The following table lists the configurable parameters of the ibm-voice-gateway-dev chart and their default values.

| Parameter                             | Description                                                  | Default                                                    |
| ------------------------------        | ----------------------------------------------------------   | ---------------------------------------------------------- |
| `arch.amd64`                  | Architecture preference for target worker node | `3 - Most preferred`       |
| `productName`                  | Product name | `IBM Voice Gateway`       |
| `serviceAccountName`                  | Name of service account | `n/a`       |
| `replicaCount`                    | Number of replicas                                                  | `1`                         |
| `nodeSelector`                    | Node selector label                                                  | `n/a`                         |
| `tenantConfigSecretName`           | Tenant Config secret name             | `vgw-tenantconfig-secret`                                                      |
| `image.sipOrchestrator.repository`           | Sip Orchestrator repository             | `ibmcom/voice-gateway-so`                                                      |
| `image.sipOrchestrator.containerName`           | Sip Orchestrator container name             | `vgw-sip-orchestrator`                                                      |
| `image.sipOrchestrator.tag`           | Sip Orchestrator docker image tag             | `1.0.0.7`                                                      |
| `image.mediaRelay.repository`           | Media Relay repository             | `ibmcom/voice-gateway-mr`                                                      |
| `image.mediaRelay.containerName`           | Media Relay container name             | `vgw-media-relay`                                                      |
| `image.mediaRelay.tag`           | Media Relay docker image tag             | `1.0.0.7`                                                      |
| `image.pullPolicy`           | Image pull policy             | `Always`                                                      |
| `image.imagePullSecrets`           | Docker repository image pull secret             | `n/a`                                                      |
| `persistence.useDynamicProvisioning`           | Dynamic provisioning setup             | `false`                                                      |
| `recordingsVolume.name`           | Name of the persistent volume claim             | `recordings`                                                      |
| `recordingsVolume.storageClassName`           | Existing storage class name             | `n/a`                                                      |
| `recordingsVolume.size`           | Size of the volume claim             | `2Gi`                                                      |
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
| `sipOrchestratorEnvVariables.mediaRelayHost`           | Media Relay Host             | `localhost:8080`                                                      |
| `sipOrchestratorEnvVariables.sipPort`           | SIP Port             | `5060`                                                      |
| `sipOrchestratorEnvVariables.sipPortTcp`           | SIP Port for TCP             | `5060`                                                      |
| `sipOrchestratorEnvVariables.sipPortTls`           | SIP Port for TLS             | `5061`                                                      |
| `sipOrchestratorEnvVariables.logLevel`           | Log Level             | `audit`                                                      |
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
| `metering.meteringServerURL`           | Metering Server URL             | `https://mycluster.icp:8443/meteringapi`                                                      |
| `metering.meteringApiKey`           | Metering Api Key             | `n/a`                                                      |
| `metering.icpMasterNodeIP`           | IBM Cloud Private Master Node IP             | `mycluster.icp`                                                      |


### Configuring secrets for PROXY_PASSWORD for the Sip Orchestrator and the Media Relay

- You can create the secret separately for the Sip Orchestrator and the Media Relay or use the same one.
- To create the secret use one of the two ways:
  ```bash
  kubectl create secret generic so-proxy-password --from-literal=SO_PROXY_PASSWORD=4ny7aahcg8
  kubectl create secret generic mr-proxy-password --from-literal=MR_PROXY_PASSWORD=9k6tyspyg2
  ```
    
  ```bash
  kubectl create secret generic proxy-password --from-literal=SO_PROXY_PASSWORD=4ny7aahcg8 --from-literal=MR_PROXY_PASSWORD=9k6tyspyg2
  ```

- Enter the secret name in the `proxyPasswordSecret` field of the respective container or you can set the mediaRelayEnvVariables.proxyPasswordSecret and sipOrchestratorEnvVariables.proxyPasswordSecret variables during installation using Helm CLI.

## Storage

- PersistentVolume needs to be pre-created prior to installing the chart if `Enable Recording` is set to `true` and no dynamic provisioning has been set up. 
- A PersistentVolume can be created with specification as shown in the following yaml example: 
  
  ```yaml
  kind: PersistentVolume
  apiVersion: v1
  metadata:
    name: <persistent volume name>
    labels: {}
  spec:
    capacity:
      storage: 2Gi
    accessModes:
    - ReadWriteMany
    persistentVolumeReclaimPolicy: Retain
    hostPath:
      path: <PATH>
  ```

  **Important:** Make sure the name of PersistentVolume is `recordings`,  accessModes is `ReadWriteMany` and persistentVolumeReclaimPolicy is `Retain`.

  You can create a PersistentVolume using the above template by executing:
  ```bash
  kubectl create -f <yaml-file>
  ```
  
## Limitations

Because this deployment uses hostNetwork mode, the Helm Chart will deploy one pod per node.

## Documentation

[Deploying Voice Gateway Helm Chart](https://www.ibm.com/support/knowledgecenter/SS4U29/deployicp.html)