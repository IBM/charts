# IBM Voice Gateway Helm Chart (Production)

## Introduction

This chart will deploy IBM Voice Gateway Addon on IBM Cloud Pak for Data.

[IBM Voice Gateway](https://www.ibm.com/support/knowledgecenter/SS4U29/welcome_voicegateway.html) provides a way to integrate a set of orchestrated Watson services with a public or private telephone network by using the Session Initiation Protocol (SIP). Voice Gateway enables direct voice interactions over a telephone with a cognitive self-service agent or transcribes a phone call between a caller and agent so that the conversation can be processed with analytics for real-time agent feedback.

## Chart Details

- The Chart provided can be used to deploy Media Relay, Sip Orchestrator, SMS Gateway and G729 Codec Service containers.
- Media Relay, Sip Orchestrator and G729 Codec Service containers are deployed in one pod and SMS Gateway is deployed in one pod.

## Installing the Chart on IBM Cloud Pak for Data with OpenShift

### Prerequisites
- IBM Cloud Pak for Data V2.5.0.0 or V3.0.1
- Detailed requirements are explained in knowledge center article of [Getting Started with IBM Cloud Pak for Data](https://www.ibm.com/support/knowledgecenter/SS4U29/deploywavi.html)

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`hostaccess`](https://ibm.biz/cpkspec-scc) has been verified for this chart. If your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

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

You must install Voice Gateway into the same namespace as IBM Cloud Pak for Data which is normally `zen`.

Run this command to bind the `hostaccess` SecurityContextConstraint to the IBM Cloud Pak for Data namespace:

```bash
oc adm policy add-scc-to-group hostaccess system:serviceaccounts:{namespace}
```

- `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally zen).

### Required

#### Configure Watson services:

- Create the following Watson services on IBM Cloud Pak for Data cluster for Media Relay and Sip Orchestrator.

  - [Watson Speech to Text](https://cloud.ibm.com/catalog/services/speech-to-text/)
  - [Watson Text to Speech](https://cloud.ibm.com/catalog/services/text-to-speech/) (self-service only)

- Create the following Watson Assistant services on IBM Cloud Pak for Data for Media Relay and Sip Orchestrator and SMS Gateway

  - [Watson Assistant](https://cloud.ibm.com/catalog/services/watson-assistant) (self-service only)

    **Important:** For the Watson Assistant service, you'll need to add a workspace with a dialog(Dialog skill). You can quickly get started by importing the [sample-conversation-en.json](https://github.com/WASdev/sample.voice.gateway/tree/master/conversation) file from your cloned sample.voice.gateway GitHub repository. To learn more about importing JSON files, see [Creating Dialog skill](https://cloud.ibm.com/docs/services/assistant?topic=assistant-skill-dialog-add) in the Assistant documentation. If you build your own dialog instead of using the sample, ensure that your dialog includes a node with the _conversation_start_ condition and node with a default response.


### Configure tenant configuration secret:

#### For Media Relay and Sip Orchestrator:
- Create a tenantConfig.json with the tenant credentials and any additional parameters. A sample tenantConfig.json can be found in the [tenantConfig.json](https://github.com/WASdev/sample.voice.gateway/blob/master/kubernetes/multi-tenant/tenantConfig.json) file.

  > Visit [Advanced JSON configuration](https://www.ibm.com/support/knowledgecenter/SS4U29/json_config_props.html) for more information.

- Create a secret `vgw-tenantconfig-secret` from the tenantConfig.json file using the following command:
  ```bash
  oc create secret generic vgw-tenantconfig-secret --from-file=tenantConfig=tenantConfig.json -n <namespace>
  ```
  > Make sure to use the namespace you want to deploy this chart in.

#### For SMS Gateway:

- Create a tenantConfig.json with the tenant credentials and any additional parameters. A sample multi tenant configuration can be found in the [tenantConfig.json](https://github.com/WASdev/sample.voice.gateway/blob/master/sms/kubernetes/bluemix/multi-tenant/tenantconfig/tenantConfig.json) file.

  > Visit [Advanced JSON configuration](https://www.ibm.com/support/knowledgecenter/en/SS4U29/sms_json_config_props.html) for more information.

- Create a secret `smsgw-tenantconfig-secret` from the tenantConfig.json file using the following command:
  ```bash
  oc create secret generic smsgw-tenantconfig-secret --from-file=tenantConfig=tenantConfig.json -n <namespace>
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
  ```

## Resources Required for SMS Gateway

- System requirements:
  ```
  RAM         8 gigabytes (GB)
  vCPUs       2 vCPU with x86-64 architecture at 2.4 GHz clock speed

  Storage     50 gigabytes (GB)
                  Note: log storage settings significantly affect storage requirements
  ```

### Setting up the cluster

Run the following commands to do pre-installation set up of the cluster:

1.  Log into OpenShift

    ```bash
    oc login
    ```

1.  Make sure you are pointing at the correct OpenShift project

    ```bash
    oc project {namespace}
    ```

    - `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally zen).

### Creating files for installation
The ‘cluster-admin’ role is required to deploy IBM Voice Gateway.

1.  Create a `vg-override.yaml` file and define any custom configuration settings

    You can find the configuration settings in the **Configuration** section below.

1. Create a `vg-repo.yaml` file

   Here is a sample file for reference:

   ```yaml
   registry:
     - url: cp.icr.io/cp/cpd
       username: "cp"
       apikey: <entitlement-key>
       namespace: ""
       name: base-registry
     - url: cp.icr.io/cp
       username: "cp"
       apikey: <entitlement-key>
       namespace: ""
       name: voice-gateway
   fileservers:
     - url: https://raw.github.com/IBM/cloud-pak/master/repo/cpd3
   ```

   - `<entitlement-key>` is the key from [myibm.com](https://myibm.ibm.com/products-services/containerlibrary)
   - For the fileserver url, use "https://raw.github.com/IBM/cloud-pak/master/repo/cpd for 2.5.0 and https://raw.github.com/IBM/cloud-pak/master/repo/cpd3 for 3.0.1

### Installing the Assembly

```bash
./cpd-linux --repo vg-repo.yaml --assembly ibm-voice-gateway --version ${assembly_version} --namespace {namespace} -o vg-override.yaml
```

- `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.
- `{assembly_version}` is the IBM Voice Gateway release version.

### Installing the Assembly on an air-gap cluster
The same version/build of `cpd-linux` is required throughout the process

1. Be sure you have completed the `Setting up the cluster` and `Creating files for installation` steps above

1. Download images and Assembly files

   This should be run in a location with access to internet and the `cpd-linux` tool

   ```bash
   ./cpd-linux preloadImages --repo vg-repo.yaml --assembly ibm-voice-gateway --version ${assembly_version} --action download --download-path ./vg-workspace
   ```

   - `{assembly_version}` is the IBM Voice Gateway release version.

1. Push the `vg-workspace` folder to a location with access to the OpenShift cluster to be installed and the same version of the `cpd-linux` tool used in the preloadImages step above

1. Login to the Openshift cluster

   ```bash
   oc login
   ```

1. Push the Docker images to the internal docker registry

   ```bash
   ./cpd-linux preloadImages --action push --load-from ./vg-workspace --assembly ibm-voice-gateway --version ${assembly_version} --transfer-image-to $(oc registry info)/zen --target-registry-username kubeadmin --target-registry-password $(oc whoami -t) --insecure-skip-tls-verify
   ```

   - `{assembly_version}` is the IBM Voice Gateway release version.

1. Run the following command

   ```bash
   oc get secrets | grep default-dockercfg
   ```

1. Modify `vg-override.yaml` file and update `global.image.pullSecret` with the name of the secret you discovered in the previous step. Modify any other values that need to be customized

1. Install Voice Gateway

   ```bash
   ./cpd-linux --load-from ./vg-workspace --assembly ibm-voice-gateway --version ${assembly_version} --namespace {namespace} --cluster-pull-prefix {docker-registry}/{namespace} -o vg-override.yaml
   ```

   - `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.
   - `{docker-registry}` is the address of the internal OpenShift docker registry. Normally:
      - docker-registry.default.svc:5000 for OpenShift 3.X
      - image-registry.openshift-image-registry.svc:5000 for OpenShift 4.X
   - `{assembly_version}` is the IBM Voice Gateway release version.

## Verifying the chart

1. Check the status of the assembly and modules

   ```bash
   ./cpd-linux status --namespace {namespace} --assembly ibm-voice-gateway [--patches]
   ```
    - `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.
    - `--patches` additionally display applied patches

1.  Setup your Helm environment

    ```bash
    export TILLER_NAMESPACE=zen
    oc get secret helm-secret -n $TILLER_NAMESPACE -o yaml|grep -A3 '^data:'|tail -3 | awk -F: '{system("echo "$2" |base64 --decode > "$1)}'
    export HELM_TLS_CA_CERT=$PWD/ca.cert.pem
    export HELM_TLS_CERT=$PWD/helm.cert.pem
    export HELM_TLS_KEY=$PWD/helm.key.pem
    helm version --tls
    ```

    You should see output like this:

    ```bash
    Client: &version.Version{SemVer:"v2.14.3", GitCommit:"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085", GitTreeState:"clean"}
    Server: &version.Version{SemVer:"v2.14.3", GitCommit:"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085", GitTreeState:"clean"}
    ```

1. Check the status of resources

   ```bash
   helm ls --tls
   helm status ibm-voice-gateway --tls
   ```

1.  Run Helm tests

    ```bash
    helm test ibm-voice-gateway --tls [--timeout=18000] [--cleanup]
    ```

    - `--timeout={time}` waits for the time in seconds for the tests to run
    - `--cleanup` deletes test pods upon completion

### Uninstalling the chart

To uninstall and delete the `ibm-voice-gateway` deployment, run the following command:

```bash
./cpd-linux uninstall --assembly ibm-voice-gateway --namespace {namespace}
```

The uninstall won't delete the datastore resources; in order to delete the datastore resources you will need to run the following command:

```bash
oc delete job,deploy,replicaset,pod,statefulset,configmap,secret,ingress,service,serviceaccount,role,rolebinding,persistentvolumeclaim,poddisruptionbudget,horizontalpodautoscaler,networkpolicies,cronjob -l release=ibm-voice-gateway
```

If you used local-volumes, you also need to remove any persistent volumes, persistent volume claims and their contents.

## Configuration

The following table lists the configurable parameters of the ibm-voice-gateway-prod chart and their default values.

| Parameter                                                      | Description                                           | Default                         |
| -------------------------------------------------------------- | ----------------------------------------------------- | ------------------------------- |
| `global.image.repository`                                                   | Docker registry to pull the images from        | `cp.icr.io/cp`            |
| `global.image.pullSecrets`                                       | Docker registry image pull secret                   | `n/a`                           |
| `global.disableSslCertValidation`                                       | Disable SSL Certificate Validation. Should not be used for production environment                   | `false`                           |
| `arch.amd64`                                                   | Architecture preference for target worker node        | `3 - Most preferred`            |
| `sip.enable`                                                   | Enable Voice Gateway                                  | `true`                          |
| `sip.nodeSelector`                                                   | Node Selector label                                  | `n/a`                          |
| `sip.mediaRelay.resources.requests.cpu`                                                   | CPU resource request for Media Relay container              | `0.5`    |
| `sip.mediaRelay.resources.requests.memory`                                                   | Memory resource request for Media Relay container          | `1Gi`    |
| `sip.sipOrchestrator.resources.requests.cpu`                                                   | CPU resource request for Sip Orchestrator container            | `1.0`    |
| `sip.sipOrchestrator.resources.requests.memory`                                                   | Memory resource request for Sip Orchestrator container    | `1Gi`    |
| `replicaCount`                                                 | Number of replicas                                    | `1`                             |
| `tenantConfigSecretName`                                       | Tenant Config secret name                             | `vgw-tenantconfig-secret`       |
| `image.sipOrchestrator.repository`                             | Docker registry for Sip Orchestrator image                           | `cp.icr.io/cp`       |
| `image.sipOrchestrator.name`                             | Sip Orchestrator docker image name                           | `voice-gateway-so`       |
| `image.sipOrchestrator.containerName`                          | Sip Orchestrator container name                       | `vgw-sip-orchestrator`          |
| `image.sipOrchestrator.tag`                                    | Sip Orchestrator docker image tag                     | `1.0.7.0`                       |
| `image.mediaRelay.repository`                                  | Docker registry for Media Relay image                                | `cp.icr.io/cp`       |
| `image.mediaRelay.name`                                  | Media Relay docker image name                                | `voice-gateway-mr`       |
| `image.mediaRelay.containerName`                               | Media Relay container name                            | `vgw-media-relay`               |
| `image.mediaRelay.tag`                                         | Media Relay docker image tag                          | `1.0.7.0`                       |
| `image.pullPolicy`                                             | Image pull policy                                     | `IfNotPresent`                        |
| `sip.codecs.g729.enable`                                       | Enable G729 Codec Service                   | `false`                           |
| `sip.codecs.image.repository`                                       | Docker image repository to pull G729 Codec Service docker image     | `cp.icr.io/cp`                           |
| `sip.codecs.image.name`                                       | G729 Codec Service docker image name                   | `voice-gateway-codec-g729`                           |
| `sip.codecs.image.containerName`                                       | G729 Codec Service container name                   | `vgw-codec-g729`                           |
| `sip.codecs.image.tag`                                       | G729 Codec Service docker image tag                   | `1.0.7.0`                           |
| `sip.codecs.g729.resources.requests.cpu`                                                   | CPU resource request                                  | `0.5`                          |
| `sip.codecs.g729.resources.requests.memory`                                                   | Memory resource request                                  | `1Gi`                          |
| `sip.codecs.g729.envVariables.webSocketServerPort`                                                   | Server port to use for G729 Codec Service                                 | `9001`                          |
| `sip.codecs.g729.envVariables.logLevel`                                                   | Log level for G729 Codec Service                              | `INFO`                          |
| `persistence.useDynamicProvisioning`                           | Dynamic provisioning setup                            | `true`                         |
| `persistence.recordingsVolume.enablePersistentRecordings`      | Enable persistent volume for recordings               | `false`                         |
| `persistence.recordingsVolume.name`                            | Name of the persistent volume claim                   | `recordings`                    |
| `persistence.recordingsVolume.storageClassName`                | Existing storage class name                           | `n/a`                           |
| `persistence.recordingsVolume.size`                            | Size of the volume claim                              | `15Gi`                           |
| `persistence.logsVolume.enablePersistentLogs`                  | Enable persistent volume for logs                     | `false`                         |
| `persistence.logsVolume.name`                                  | Name of the persistent volume claim                   | `persistent-logs`               |
| `persistence.logsVolume.storageClassName`                      | Existing storage class name                           | `n/a`                           |
| `persistence.logsVolume.size`                                  | Size of the volume claim                              | `10Gi`                           |
| `mediaRelayEnvVariables.sdpAddress`                      | Media Relay SDP Address                                   | `n/a`                       |
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
| `sipOrchestratorEnvVariables.sipHost`                          | SIP Host                                              | `n/a`                          |
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
| `sms.enable`                                                   | Enable SMS Gateway                                    | `false`                         |
| `sms.replicas`                                                 | Number of replicas                                    | `1`                             |
| `sms.nodeSelector`                                                 | Node Selector label                                    | `n/a`                             |
| `sms.tenantConfigSecretName`                                   | Tenant Config secret name                             | `smsgw-tenantconfig-secret`     |
| `sms.redissonConfigSecretName`                                   | Redisson Config secret name                             | `secret-redisconfig`     |
| `sms.image.repository`                                         | Docker Registry for SMS Gateway image                                | `cp.icr.io/cp`      |
| `sms.image.name`                                         | SMS Gateway docker image name                                | `voice-gateway-sms`      |
| `sms.image.containerName`                                      | SMS Gateway container name                            | `vgw-sms-gateway`               |
| `sms.image.tag`                                                | SMS Gateway docker image tag                          | `1.0.7.0`                       |
| `sms.image.containerPort`                                      | SMS Gateway for TCP                                   | `9080`                          |
| `sms.image.servicePort`                                      | Service Port for TCP connection                                   | `30087`                          |
| `sms.image.containerPortTls`                                   | SMS Gateway for TLS                                   | `9443`                          |
| `sms.image.servicePortTls`                                   | Service Port for TLS connection                                   | `30047`                          |
| `sms.image.pullPolicy`                                         | Image pull policy                                     | `IfNotPresent`                  |
| `sms.resources.requests.cpu`                                                   | CPU resource request for SMS container              | `0.25`    |
| `sms.resources.requests.memory`                                                   | Memory resource request for SMS container          | `250Mi`    |
| `sms.resources.limits.cpu`                                                   | CPU resource limit for SMS container            | `2.0`    |
| `sms.resources.limits.memory`                                                   | Memory resource limit for SMS container    | `8Gi`    |
| `sms.networkPolicy.smsProviderPort`                  | SMS Provider Port                                     | `80`                  |
| `sms.networkPolicy.smsProviderPortTls`             | SMS Provider TLS Port                                     | `443`                  |
| `sms.networkPolicy.disableNonSecurePort`                    | Disable Non Secure Port. Recommended to be enabled in Production Environment                      | `false`                  |
| `sms.persistence.volume.useDynamicProvisioning`                | Dynamic provisioning setup                            | `true`                         |
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
| `sms.persistence.volume.usageReports.size`                     | Size of the volume claim                              | `1Gi`                           |
| `sms.logging.level`                                            | Log Level                                             | `info`                          |
| `sms.logging.maxFiles`                                         | Log Max Files                                         | `5`                             |
| `sms.logging.maxFileSize`                                      | Log Max File Size                                     | `100`                           |
| `sms.logging.enableTranscriptionMessages`                      | Enable Transcription Messages                         | `false`                         |
| `sms.logging.latencyReportingThreshold`                        | Latency Reporting Threshold                           | `1000`                          |
| `sms.logging.hideCallerID`                                     | Mask caller ID information                            | `false`                         |
| `sms.cache.redis.enable`                                     | Enable Redis caching server                             | `false`                         |
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
| `dvt.image.repository`                                         | Docker Registry for DVT image                                | `cp.icr.io/cp`      |
| `dvt.image.name`                                         | DVT docker image name                                | `voice-gateway-dvt`      |
| `dvt.image.tag`                                                | DVT docker image tag                          | `1.0.7.0`                       |
| `dvt.image.pullPolicy`                                                | DVT docker image pullPolicy                          | `IfNotPresent`                       |



### Optional Configurations

#### G729 Codec Service

- Enable G729 Codec Service: `sip.codecs.g729.enable: true`

#### MRCPv2 configuration

- More info: [Configuring services with MRCPv2](https://www.ibm.com/support/knowledgecenter/SS4U29/MRCP.html)
- Create unimrcpConfig secret from the `unimrcpclient.xml` file:
  ```
  oc create secret generic unimrcp-config-secret --from-file=unimrcpConfig=unimrcpclient.xml -n <namespace>
  ```
- If you changed the default MRCPv2 SIP Port, update `mediaRelayEnvVariables.mrcpv2SipPort`
- Enable MRCP in the configuration `mediaRelayEnvVariables.enableMrcp: true`

#### SSL configuration

- More info: [Configuring SSL and TLS encryption](https://www.ibm.com/support/knowledgecenter/SS4U29/security.html#configuring-ssl-and-tls-encryption)

##### Adding trusted certificates for the SIP Orchestrator (For enabling SSL or Mutual Authentication):

- Create secret from the trust store key file:
  ```
  oc create secret generic trust-store-file-secret --from-file=trustStoreFile=myPKCS12File.p12 -n <namespace>
  ```
- Create secret for the SSL Passphrase:
  - Add passphrase in a text file `ssl_passphrase.txt` (Make sure there are no extra spaces or new lines in the text file)
  - Create secret from the text file:
    ```
    oc create secret generic ssl-passphrase-secret --from-file=sslPassphrase=ssl_passphrase.txt -n <namespace>
    ```
- Set type of the SSL file in the configuration, update `sipOrchestratorEnvVariables.sslFileType`
- Enable option `Enable SSL or Mutual Authentication` in the SIP Orchestrator configuration: `sipOrchestratorEnvVariables.enableSslorMutualAuth: true`

##### Adding trusted certificates for the Media Relay (For enabling SSL):

- Create secret from client CA certificate file:
  ```
  oc create secret generic client-ca-cert-secret --from-file=clientCaCertFile=ca-bundle.pem -n <namespace>
  ```
- Enable SSL in the Media Relay configuration before deployment: `mediaRelayEnvVariables.enableSsl: true`

##### Adding certificates for the Media Relay (For Mutual Authentication):

- Create secret from the SSL client PKCS12 file:
  ```
  oc create secret generic ssl-client-pkcs12-file-secret --from-file=clientPkcs12File=myPKCS12File.p12 -n <namespace>
  ```
- Create secret for the SSL Passphrase:
  - Add passphrase in a text file `ssl_client_passphrase.txt` (Make sure there are no extra spaces or new lines in the text file)
  - Create secret from the text file:
    ```
    oc create secret generic ssl-client-passphrase-secret --from-file=sslClientPassphrase=ssl_client_passphrase.txt -n <namespace>
    ```
  - Enable Mutual Authentication in the Media Relay configuration: `mediaRelayEnvVariables.enableMutualAuth: true`

##### Adding trusted certificates for the SMS Gateway (For enabling SSL):

- Create secret from the trust store or the key store file:
  ```
  oc create secret generic trust-store-file-secret --from-file=trustStoreFile=myPKCS12File.p12 -n <namespace>
  oc create secret generic key-store-file-secret --from-file=keyStoreFile=myPKCS12File.p12 -n <namespace>
  ```

- Create secret for the SSL Passphrase:
  - Add passphrase in a text file `ssl_passphrase.txt` (Make sure there are no extra spaces or new lines in the text file)
  - Create secret from the text file:
    ```
    oc create secret generic ssl-passphrase-secret --from-file=sslKeyPassphrase=ssl_passphrase.txt -n <namespace>
    ```
  - Do the same for truststore file passphrase
    ```
    oc create secret generic ssl-trust-passphrase-secret --from-file=sslTrustPassphrase=ssl_trust_passphrase.txt -n <namespace>
    ```
- Set type of the SSL file in the configuration
- Enable SSL in the SMS Gateway configuration before deployment: `sms.ssl.enable: true`



#### Configuring secrets for proxy password for the Sip Orchestrator and the Media Relay:

- You can create the secret separately for the Sip Orchestrator and the Media Relay or use the same one.
- Create an individual text file with the Sip Orchestrator and the Media Relay proxy password. For example: `so_proxy_password.txt` and `mr_proxy_password.txt` (Make sure there are no extra spaces or new lines in the text file)
- To create the secret use one of the two ways:
  - Create separate secrets for each container:
  ```bash
  oc create secret generic so-proxy-password --from-file=soProxyPassword=so_proxy_password.txt -n <namespace>
  oc create secret generic mr-proxy-password --from-file=mrProxyPassword=mr_proxy_password.txt -n <namespace>
  ```
  - Create one secret for both containers:
  ```bash
  oc create secret generic proxy-password --from-file=soProxyPassword=so_proxy_password.txt --from-file=mrProxyPassword=mr_proxy_password.txt -n <namespace>
  ```
- Set the secret name in the configuration: `mediaRelayEnvVariables.proxyPasswordSecret` and `sipOrchestratorEnvVariables.proxyPasswordSecret`

#### Secure admin interface with credentials:

- Create username and password secret for admin credentials using the following command:
  ```bash
  oc create secret generic admin-credentials --from-literal=adminUsername=<USERNAME> --from-literal=adminPassword=<PASSWORD> -n <namespace>
  ```
- Enable Secure admin interface with: `sipOrchestratorEnvVariables.secureAdminInterface: true` in SIP Orchestrator configuration before deployment.

## Limitations

Because this deployment uses `hostNetwork` mode, the Helm chart will deploy one pod per node.

## Documentation

[Deploying Voice Gateway Addon on Cloud Pak for Data](https://www.ibm.com/support/knowledgecenter/SSQNUZ_current/svc-wavi/wavi-addon-install.html)
