# IBM Voice Gateway Helm Chart (Developer Trial)

## Introduction

This chart will deploy IBM Voice Gateway (Developer Trial).

[IBM Voice Gateway](https://www.ibm.com/support/knowledgecenter/SS4U29/welcome_voicegateway.html) provides a way to integrate a set of orchestrated Watson services with a public or private telephone network by using the Session Initiation Protocol (SIP). Voice Gateway enables direct voice interactions over a telephone with a cognitive self-service agent or transcribes a phone call between a caller and agent so that the conversation can be processed with analytics for real-time agent feedback.

## Chart Details

- The Chart will deploy a pod with 2 containers - Media Relay and Sip Orchestrator.

## Prerequisites

### Required
- Create the following Watson services on IBM Cloud.
  - [Watson Speech to Text](https://www.ibm.com/watson/services/speech-to-text/)
  - [Watson Text to Speech](https://www.ibm.com/watson/services/text-to-speech/) (self-service only)
  - [Watson Conversation](https://www.ibm.com/watson/services/conversation/) or [Watson Virtual Agent](https://www.ibm.com/us-en/marketplace/cognitive-customer-engagement) (self-service only)
  
    **Important:** For the Conversation service, you'll need to add a workspace with a dialog. You can quickly get started by importing the [sample-conversation-en.json](https://github.com/WASdev/sample.voice.gateway/tree/master/conversation) file from your cloned sample.voice.gateway GitHub repository. To learn more about importing JSON files, see [Creating workspaces](https://console.bluemix.net/docs/services/conversation/configure-workspace.html#creating-workspaces) in the Conversation documentation. If you build your own dialog instead of using the sample, ensure that your dialog includes a node with the *conversation_start* condition and node with a default response.
  
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

Use the `--set` option on the command line to specify each parameter for the Watson service credentials.

    For example:
    ```bash
    helm install ibm-charts/ibm-voice-gateway --name my-release \
    --set serviceCredentials.watsonSttUsername="9h7f54cb-f28f-4a64-91e1-a0657e1dd3f4" \
    --set serviceCredentials.watsonSttPassword="IAB5jfxls0Zt" \
    --set serviceCredentials.watsonTtsUsername="9h7f54cb-8b0f-4766-8b15-eaa8f7c3fae7" \
    --set serviceCredentials.watsonTtsPassword="HcmzFp1kec1P" \
    --set serviceCredentials.watsonConversationWorkspaceId="a23de67h-e527-40d5-a867-5c0ce9e72d0d" \
    --set serviceCredentials.watsonConversationUsername="9h7f54cb-d9ed-46b3-8492-e9a9bf555021" \
    --set serviceCredentials.watsonConversationPassword="InWtiUpYhF1Z" \
    --set sipOrchestratorEnvVariables.whitelistToUri="2345556789"
    ```

## Verifying the chart

To verify the chart, you need a system with kubectl and Helm installed. 

1. Configure kubectl CLI and helm CLI and check for deployment information by issuing the following commands:
```bash
helm list
helm status my-release
```
2. Copy the name of the pod that was deployed with ibm-voice-gateway-dev by issuing the following command:
```bash
kubectl get pod
```
3. Using the pod name, check under Events to see whether the image was successfully pulled and the container was created and started. Issue the following command:
```bash
kubectl describe pod <pod name>
```

## Uninstalling the chart

1. To uninstall the deployed chart from the master node dashboard, click Workloads -> Helm Releases.
2. Find the release name and under action click delete.

To uninstall the deployed chart from the command line, issue the following command:
```bash
helm delete --purge my-release
kubectl delete pvc -l release=my-release 
```

## Configuration

The following table lists the configurable parameters of the ibm-voice-gateway-dev chart and their default values.

| Parameter                             | Description                                                  | Default                                                    |
| ------------------------------        | ----------------------------------------------------------   | ---------------------------------------------------------- |
| `arch.amd64`                  | Architecture preference for target worker node | `3 - Most preferred`       |
| `replicaCount`                    | Number of replicas                                                  | `1`                         | 
| `serviceCredentials.watsonSttUsername`           | Watson STT Username             | `n/a`                                                      |
| `serviceCredentials.watsonSttPassword`           | Watson STT Password             | `n/a`                                                      |
| `serviceCredentials.watsonSttUrl`           | Watson STT URL             | `https://stream.watsonplatform.net/speech-to-text/api`                                                      |
| `serviceCredentials.watsonTtsUsername`           | Watson TTS Username             | `n/a`                                                      |
| `serviceCredentials.watsonTtsPassword`           | Watson TTS Password             | `n/a`                                                      |
| `serviceCredentials.watsonTtsUrl`           | Watson TTS URL             | `https://stream.watsonplatform.net/text-to-speech/api`                                                      |
| `serviceCredentials.watsonConversationWorkspaceId`           | Watson Conversation Workspace ID             | `n/a`                                                      |
| `serviceCredentials.watsonConversationUsername`           | Watson Conversation Username             | `n/a`                                                      |
| `serviceCredentials.watsonConversationPassword`           | Watson Conversation Password             | `n/a`                                                      |
| `serviceCredentials.watsonConversationUrl`           | Watson Conversation URL             | `https://gateway.watsonplatform.net/conversation/api`                                                      |
| `image.sipOrchestrator.image`           | Sip Orchestrator Docker image             | `ibmcom/voice-gateway-so`                                                      |
| `image.sipOrchestrator.containerName`           | Sip Orchestrator container name             | `vgw-sip-orchestrator`                                                      |
| `image.mediaRelay.image`           | Media Relay Docker image             | `ibmcom/voice-gateway-mr`                                                      |
| `image.mediaRelay.containerName`           | Media Relay container name             | `vgw-media-relay`                                                      |
| `image.tag`           | Docker image tag             | `1.0.0.5`                                                      |
| `image.pullPolicy`           | Docker image pull policy             | `Always`                                                      |
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
| `mediaRelayEnvVariables.proxyPassword`           | Media Relay Proxy Password             | `n/a`                                                      |
| `mediaRelayEnvVariables.watsonSttEnableProxy`           | Watson STT Enable Proxy             | `true`                                                      |
| `mediaRelayEnvVariables.watsonTtsEnableProxy`           | Watson TTS Enable Proxy             | `true`                                                      |
| `mediaRelayEnvVariables.musicOnHoldEnableProxy`           | Music On Hold Enable Proxy             | `false`                                                      |
| `mediaRelayEnvVariables.watsonSttModel`           | Watson STT Model             | `en-US_NarrowbandModel`                                                      |
| `mediaRelayEnvVariables.echoSuppression`           | Echo Suppression             | `true`                                                      |
| `mediaRelayEnvVariables.watsonTtsVoice`           | Watson TTS Voice             | `en-US_AllisonVoice`                                                      |
| `mediaRelayEnvVariables.ttsCacheTimeToLive`           | TTS Cache Time to Live             | `0`                                                      |
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
| `sipOrchestratorEnvVariables.proxyPassword`           | Sip Orchestrator Proxy Password             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.whitelistFromUri`           | Whitelist From URI             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.whitelistToUri`           | Whitelist To URI             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.trustedIpList`           | Trusted IP List             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.customSipInviteHeader`           | Custom SIP Invite Header             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.customSipSessionHeader`           | Custom SIP Session Header             | `Call-ID`                                                      |
| `sipOrchestratorEnvVariables.sendProvisionalResponse`           | Send Provisional Response             | `true`                                                      |
| `sipOrchestratorEnvVariables.sendSipCallIdToConversation`           | Send SIP Call ID To Conversation             | `false`                                                      |
| `sipOrchestratorEnvVariables.sendSipRequestUriToConversation`           | Send SIP Request URI To Conversation             | `false`                                                      |
| `sipOrchestratorEnvVariables.sendSipToUriToConversation`           | Send SIP To URI To Conversation             | `false`                                                      |
| `sipOrchestratorEnvVariables.sendSipFromUriToConversation`           | Send SIP From URI To Conversation             | `false`                                                      |
| `sipOrchestratorEnvVariables.conversationFailedReplyMessage`           | Conversation Failed Reply Message             | `Call being transferred to an agent due to a technical problem. Good bye.`                                                      |
| `sipOrchestratorEnvVariables.transferDefaultTarget`           | Transfer Default Target             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.transferFailedReplyMessage`           | Transfer Failed Reply Message             | `Call transfer to an agent failed. Please try again later. Good bye.`                                                      |
| `sipOrchestratorEnvVariables.disconnectCallOnTransferFailure`           | Disconnect Call On Transfer Failure             | `true`                                                      |
| `sipOrchestratorEnvVariables.putCallerOnHoldOnTransfer`           | Put Caller On Hold On Transfer             | `true`                                                      |
| `sipOrchestratorEnvVariables.cmrHealthCheckFailErrCode`           | CMR Health Check Fail Err Code             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.reportingUrl`           | Reporting URL             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.reportingUsername`           | Reporting Username             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.reportingPassword`           | Reporting Password             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.reportingCdrEventIndex`           | Reporting CDR Event Index             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.reportingConversationEventIndex`           | Reporting Conversation Event Index             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.reportingTranscriptionEventIndex`           | Reporting Transcription Event Index             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.watsonConversationApiVersion`           | Watson Conversation Api Version             | `2017-05-26`                                                      |
| `sipOrchestratorEnvVariables.watsonConversationReadTimeout`           | Watson Conversation Read Timeout             | `5`                                                      |
| `sipOrchestratorEnvVariables.watsonConversationConnectTimeout`           | Watson Conversation Connect Timeout             | `10`                                                      |
| `sipOrchestratorEnvVariables.watsonVaUrl`           | Watson VA URL             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.watsonVaBotId`           | Watson VA Bot ID             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.watsonVaClientId`           | Watson VA Client ID             | `n/a`                                                      |
| `sipOrchestratorEnvVariables.watsonVaClientSecret`           | Watson VA Client Secret             | `n/a`                                                      |



## Storage

- PersistentVolume needs to be pre-created prior to installing the chart if `Enable Recording` is set to `true` and no dynamic provisioning has been set up. 
- A PersistentVolume can be created by creating a yaml file as shown in the following example: 
  
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

      kubectl create -f <yaml-file>

## Limitations

Because this deployment uses hostNetwork mode, the Helm Chart will deploy one pod per node.

## Documentation

[Deploying Voice Gateway Helm Chart](https://www.ibm.com/support/knowledgecenter/SS4U29/deployicp.html)