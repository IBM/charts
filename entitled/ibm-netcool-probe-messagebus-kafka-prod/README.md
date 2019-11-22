# IBM Tivoli Netcool/OMNIbus Message Bus Probe for Kafka Helm Chart

This helm chart deploys the IBM Netcool/OMNIbus Message Bus for Kafka Probe onto Kubernetes. This probe processes Kafka events from a Kafka 
server to a Netcool Operations Insight operational dashboard.

## Introduction

IBM® Netcool® Operations Insight enables IT and network operations teams to increase effectiveness, efficiency
and reliability by leveraging cognitive analytics capabilities to identify, isolate and resolve problems before
they impact your business. It provides a consolidated view across your local, cloud and hybrid environments and
delivers actionable insight into the health and performance of services and their associated dynamic network and
IT infrastructures. More information can be seen here: [IBM Marketplace - IT Operations Management](https://www.ibm.com/marketplace/it-operations-management)

## Chart Details

- Deploys a Tivoli Netcool/OMNIbus Message Bus probe configured for Kafka onto Kubernetes that can receive messages from a Kafka server.
- This chart can be deployed more than once on the same namespace.

## Prerequisites

- This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe either on IBM Cloud Private (ICP) or on-premise:
  - For ICP, IBM Netcool Operations Insight 1.6.0.1 is required. Refer to the installation instructions at [IBM Knowledge Center - Installing on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_installing-on-icp.html).
  - For on-premise, IBM Tivoli Netcool/OMNIbus 8.1 is required. Refer to the installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).

- [Scope-based Event Grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/concept/omn_con_ext_aboutscopebasedegrp.html) is installed. The probe requires several table fields to be installed in the ObjectServer. For on-premise installation, refer instructions at [IBM Knowledge Center - Installing scope-based event grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ext_installingscopebasedegrp.html). The events will be grouped by a preset `ScopeId` in the probe rules file if the event grouping automation triggers are enabled.

- Kubernetes 1.10.

- The Administrator role is the minimum role required to install this chart in order to.
    - Enable Pod Disruption Budget policy when installing the chart.
    - Retrieve and edit sensitive information from a secret such as the credentials to use to authenticate with the Object Server or replace the Key database files for secure communications with the Object Server.
  - The chart must be installed by a Cluster Administrator to perform the following tasks in addition to those listed above:
    - Obtain the Node IP using `kubectl get nodes` command if using the NodePort service type.
    - Create a new namespace with custom PodSecurityPolicy if necessary. See PodSecurityPolicy Requirements [section](#podsecuritypolicy-requirements) for more details.
- A custom service account must be created in the namespace for this chart. Perform one of the following actions:
  - Have the Cluster Administrator pre-create the custom service account in the namespace. This installation requires the service account name to specified to install the chart and can be done by an Administrator.
  - Install the chart with the service account being automatically created. This installation must be performed by the Cluster Administrator.

- To connect the probe to a Kafka server using a secure connection, the Kubernetes Secrets for the client Truststore certificate and the client Keystore certificate must be created before deploying the helm chart. Creating the Secrets requires the Operator role or higher. Refer to the Message Bus Probe for Kafka Integrations Helm Chart Guide [here](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/messagebus_kafka/wip/reference/mbkaf_config_ssl.html)

## Resources Required

- CPU Requested : 250m (250 millicpu)
- Memory Requested : 256Mi (~ 268 MB)

### PodSecurityPolicy Requirements

On non-Red Hat OpenShift Container Platform, this chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart. The predefined PodSecurityPolicy definitions can be viewed [here](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/README.md).

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory. Detailed steps to create the PodSecurityPolicy is documented [here](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_common_psp.html).

* From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  * Custom PodSecurityPolicy definition:
    ```
    apiVersion: policy/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is based on the most restrictive policy,
        requiring pods to run with a non-root UID, and preventing pods from accessing the host."
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
        cloudpak.ibm.com/version: "1.1.0"
      name: ibm-netcool-probe-messagebus-kafka-prod-psp
    spec:
      allowPrivilegeEscalation: false
      forbiddenSysctls:
      - '*'
      fsGroup:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      requiredDropCapabilities:
      - ALL
      runAsUser:
        rule: MustRunAsNonRoot
      runAsGroup:
        rule: MustRunAs
        ranges:
        - min: 1
          max: 65535
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      volumes:
      - configMap
      - emptyDir
      - projected
      - secret
      - downwardAPI
      - persistentVolumeClaim
    ```
* From the command line, you can run the setup scripts included under `pak_extensions`.
  
  As a cluster administrator, the pre-install scripts and instructions are located at:
  * pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin/operator the namespace scoped scripts and instructions are located at:
  * pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

### Red Hat OpenShift SecurityContextConstraints Requirements

On the Red Hat OpenShift Container Platform, this chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      annotations:
        kubernetes.io/description: "This policy is the most restrictive, 
          requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
        cloudpak.ibm.com/version: "1.1.0"
      name: ibm-netcool-probe-messagebus-kafka-prod-scc
    allowHostDirVolumePlugin: false
    allowHostIPC: false
    allowHostNetwork: false
    allowHostPID: false
    allowHostPorts: false
    allowPrivilegedContainer: false
    allowPrivilegeEscalation: false
    allowedCapabilities: null
    allowedFlexVolumes: null
    allowedUnsafeSysctls: null
    defaultAddCapabilities: null
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
    # This can be customized for seLinuxOptions specific to your host machine
    seLinuxContext:
      type: RunAsAny
    # seLinuxOptions:
    #   level:
    #   user:
    #   role:
    #   type:
    supplementalGroups:
      type: MustRunAs
      ranges:
      - max: 65535
        min: 1
    # This can be customized to host specifics
    volumes:
    - configMap
    - downwardAPI
    - emptyDir
    - persistentVolumeClaim
    - projected
    - secret
    # If you want a priority on your SCC -- set for a value more than 0
    # priority:
    ```
- From the command line, you can run the setup scripts included under `pak_extensions`.

  As a cluster admin the pre-install instructions are located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped instructions are located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

## Secure Probe and Object Server Communication

There are several mechanisms to secure Netcool/OMNIbus system. Authentication can be used to
restrict user access while Secure Sockets Layer (SSL) protocol can be used for different levels of encryption.

The probe connection mode is dependant on the server component configuration. 
Check with your Netcool/OMNIbus Administrator whether the server is configured 
with either secured mode enabled without SSL, SSL enabled with secured mode disabled, 
or secured mode enabled with SSL protected communications.

For more details on running the Object Server in secured mode, 
refer to [Running the ObjectServer in secure mode](https://www.ibm.com/support/knowledgecenter/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/admin/reference/omn_adm_runningobjservsecuremode.html) page on IBM Knowledge Center.

For more details on SSL protected communications, refer to 
[Using SSL for client and server communications](https://www.ibm.com/support/knowledgecenter/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/concept/omn_con_ssl_usingssl.html) page on IBM Knowledge Center.

The chart must be configured according to the server components setup in order to 
establish a secured connection with or without SSL. 
This can be configured by setting the `messagebus.netcool.connectionMode` chart parameter with one of these options:

* `Default` - This is the default mode. Use this mode to connect with the Object Server with neither secure mode nor SSL.
* `AuthOnly` - Use this mode when the Object Server is configured to run in secured mode without SSL.
* `SSLOnly` - Use this mode when the Object Server is configured with SSL without secure mode.
* `SSLAndAuth` - Use this mode the Object Server is configured with SSL and secure mode.

To secure the communications between probe clients and the Object Server, there are several tasks 
that must be completed before installing the chart.
  1. [Determine Files Required For The Secret](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_securing_server_comms.html?view=kc#secure_probe_and_object_server_communication_requirement__determine-files-required-for-the-secret)
  2. [Preparing Credential Files for Authentication](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_securing_server_comms.html?view=kc#secure_probe_and_object_server_communication_requirement__preparing-credential-files-for-authentication)
  3. [Preparing Key Database File for SSL Communication](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_securing_server_comms.html?view=kc#secure_probe_and_object_server_communication_requirement__preparing-key-database-file-for-ssl-communication)
  4. [Create Probe-Server Communication Secret](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_securing_server_comms.html?view=kc#secure_probe_and_object_server_communication_requirement__create-probe-server-communication-secret)

If you are using the `Default` mode, you can skip the these steps and 
proceed configuring the chart with your Object Server connection details.

Please refer to the this Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_securing_server_comms.html) for detailed steps to prepare this required secret.

**Note** There are several known limitations listed in the [Limitations section](#limitations) when securing probe communications.

## Role-Based Access Control

Role-Based Access Control (RBAC) is applied to the chart by using a custom service account having a specific role binding. RBAC provides greater security by ensuring that the chart operates within the specified scope. Refer to [Role-Based Access Control page](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_role_based_access.html) in IBM Knowledge Center for more details to create the RBAC resources.

## Installing the Chart

To install the chart with the release name `my-mb-kafka-probe`:

1. Extract the helm chart archive and customize `values.yaml`. The [configuration](#configuration) section lists the parameters that can be configured during installation.

2. The command below shows how to install the chart with the release name `my-mb-kafka-probe` using the configuration specified in the customized `values.yaml`. Helm searches for the `ibm-netcool-probe-messagebus-kafka-prod` chart in the helm repository called `stable`. This assumes that the chart exists in the `stable` repository.

```sh
helm install --tls --namespace <your pre-created namespace> --name my-mb-kafka-probe -f values.yaml stable/ibm-netcool-probe-messagebus-kafka-prod
```
> **Tip**: List all releases using `helm list --tls` or search for a chart using `helm search`.

## Verifying the Chart

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release> --tls`.

## Uninstalling the Chart

To uninstall/delete the `my-mb-kafka-probe` deployment:

```sh
$ helm delete my-mb-kafka-probe --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Clean up any prerequisites that were created

As a Cluster Administrator, run the cluster administration clean up script included under pak_extensions to clean up cluster scoped resources when appropriate.

- post-delete/clusterAdministration/deleteSecurityClusterPrereqs.sh

As a Cluster Administrator, run the namespace administration clean up script included under pak_extensions to clean up namespace scoped resources when appropriate.

- post-delete/namespaceAdministration/deleteSecurityNamespacePrereqs.sh

## Configuration

The following table lists the configurable parameters of the `ibm-netcool-probe-messagebus-kafka-prod` chart and their default values.

|  Parameter                                          | Description  |
| ----------------------------------------------------| -------------|
| **messagebus.license** | The license state of the image being deployed. Enter `accept` to install and use the image. The default is `not accepted` |
| **messagebus.replicaCount** | Number of deployment replicas. Omitted when `autoscaling.enabled` set to `true`. The default is `1` |
| **messagebus.global.image.secretName** | Name of the Secret containing the Docker Config to pull the image from a private repository. Leave blank if the probe image already exists in the local image repository or if the Service Account has already been assigned with an Image Pull Secret. The default is `nil` |
| **messagebus.global.serviceAccountName** | Name of the service account to be used by the helm chart. If the Cluster Administrator has already created a service account in the namespace, specify the name of the service account here. If left blank, the chart will automatically create a new service account in the namespace when it is deployed. This new service account will be removed from the namespace when the chart is removed. The default is `nil`. |
| **messagebus.image.repository** | Probe image repository. Update this repository name to pull from a private image repository. The image name should be set to `netcool-probe-messagebus`. |
| **messagebus.image.tag** | The `netcool-probe-messagebus` image tag. The default is `10.0.5.0-amd64` |
| **messagebus.image.testRepository** | The Utility image repository. Update this repository name to pull from a private image repository. The default is `netcool-integration-util` |
| **messagebus.image.testImageTag** | The Utility image image tag. The default is `2.0.0-amd64` |
| **messagebus.image.pullPolicy** | Image pull policy. The default is `Always` |
| **messagebus.netcool.connectionMode** | The connection mode to use when connecting to the Netcool/OMNIbus Object Server. Refer to [Securing Probe and Object Server Communications section](#securing-probe-and-object-server-communications) for more details. **Note**: Refer to limitations section for more details on available connection modes for your environment. The default is `default`. |
| **messagebus.netcool.primaryServer** | The primary Netcool/OMNIbus server the probe should connect to (required). Usually set to NCOMS or AGG_P. The default is `nil` |
| **messagebus.netcool.primaryHost** | The host of the primary Netcool/OMNIbus server (required). Specify the Object Server Hostname or IP address. The default is `nil` |
| **messagebus.netcool.primaryPort** | The port number of the primary Netcool/OMNIbus server (required). The default is `nil` |
| **messagebus.netcool.backupServer** | The backup Netcool/OMNIbus server to connect to. If the backupServer, backupHost and backupPort parameters are defined in addition to the primaryServer, primaryHost, and primaryPort parameters, the probe will be configured to connect to a virtual object server pair called `AGG_V`. The default is `nil` |
| **messagebus.netcool.backupHost** | The host of the backup Netcool/OMNIbus server. Specify the Object Server Hostname or IP address. The default is `nil` |
| **messagebus.netcool.backupPort** | The port of the backup Netcool/OMNIbus server. The default is `nil` |
| **messagebus.probe.messageLevel** | Probe log message level. The default is `warn` |
| **messagebus.probe.setUIDandGID** | If true, the helm chart specifies UID and GID values to be assigned to the netcool user in the container. Otherwise when false the netcool user will not be assigned any UID or GID by the helm chart. Refer to the deployed PSP or SCC in the namespace. The default is `true` |
| **messagebus.probe.transportType** | Probe transport type. The default is `KAFKA` |
| **messagebus.probe.heartbeatInterval** | Specifies the frequency (in seconds) with which the probe checks the status of the host server. The default is `10` |
| **messagebus.probe.secretName** | Name of Secret for authentication credentials for the HTTP and Kafka Transport. The default is `nil` |
| **messagebus.probe.rulesConfigmap** | Specifies a customised ConfigMap to be used for the rules files. This field will override the selection made for the `messagebus.probe.rulesFile` parameter. This field must be left blank if not required. The default is `nil` |
| **messagebus.probe.jsonParserConfig.messagePayload** | Specifies the JSON tree to be identified as message payload from the notification (kafka consumer) channel. See example for more details on how to configure the Probe's JSON parser. The default is `json` |
| **messagebus.probe.jsonParserConfig.messageHeader** | (Optional) Specifies the JSON tree to be identified as message header from the notification (kafka consumer) channel. Attributes from the headers will be added to the generated event. The default is `nil` |
| **messagebus.probe.jsonParserConfig.jsonNestedPayload** | (Optional) Specifies the JSON tree within a nested JSON or JSON string to be identified as message payload from the notification (kafka consumer) channel. The `messagebus.probe.jsonParserConfig.messagePayload` parameter must be set to point to the attribute containing the JSON String. The default is `nil` |
| **messagebus.probe.jsonParserConfig.jsonNestedHeader** | (Optional) Specifies the JSON tree within a nested JSON or JSON string to be identified as message header from the notification (kafka consumer) channel. The `messagebus.probe.jsonParserConfig.messageHeader` parameter must be set to point to the attribute containing the JSON String. The default is `nil` |
| **messagebus.probe.jsonParserConfig.messageDepth** | Specifies the number of JSON child node levels in the message to traverse during parsing. The default is `3` |
| **messagebus.kafka.connection.zookeeperClient.target** | Use this property to specify the ZooKeeper endpoint eg. `zookeeper:2181` The default is `nil` |
| **messagebus.kafka.connection.zookeeperClient.topicWatch** | Use this property to enable the ZooKeeper topic watch service. The default is `false` |
| **messagebus.kafka.connection.zookeeperClient.brokerWatch** | Use this property to enable the ZooKeeper broker watch service. The default is `false` |
| **messagebus.kafka.connection.brokers** | Use this property to specify the broker endpoints in a comma-separated list eg. `PLAINTEXT://kafkaserver1:9092,PLAINTEXT://kafkaserver2:9092` The default is `nil` |
| **messagebus.kafka.connection.topics** | Use this property to specify topics in a comma-separated list eg. `topicABC,topicXYZ` The default is `nil` |
| **messagebus.kafka.client.securityProtocol** | The security protocol to be used. The default is `nil` |
| **messagebus.kafka.client.ssl.trustStoreSecretName** | Secret name for the TrustStore file and its password. The default is `nil` |
| **messagebus.kafka.client.ssl.keyStoreSecretName** | Secret name for the KeyStore file and its password. The default is `nil` |
| **messagebus.kafka.client.saslPlainMechanism** | Enable the PLAIN mechanism for Simple Authentication and Security Layer connections. The default is `false` |
| **messagebus.kafka.client.consumer.groupId** | The group identifier eg. `test-consumer-group`. The default is `nil` |
| **messagebus.autoscaling.enabled** | Set to `false` to disable auto-scaling. The default is `true` |
| **messagebus.autoscaling.minReplicas** | Minimum number of probe replicas. The default is `1` |
| **messagebus.autoscaling.maxReplicas** | Maximum number of probe replicas. The default is `5` |
| **messagebus.autoscaling.cpuUtil** | The target CPU utilization (in percentage). Example: `60` for 60% target utilization. The default is `60` |
| **messagebus.poddisruptionbudget.enabled** | Set to `true` to enable Pod Disruption Budget to maintain high availability during a node maintenance. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control. The default is `false` |
| **messagebus.poddisruptionbudget.minAvailable** | The number of minimum available pods during node drain. Can be set to a number or percentage, eg: 1 or 10%. Caution: Setting to 100% or equal to the number of replicas may block node drains entirely. The default is `1` |
| **messagebus.resources.limits.cpu** | CPU resource limits. The default is `500m` |
| **messagebus.resources.limits.memory** | Memory resource limits. The default is `512Mi` |
| **messagebus.resources.requests.cpu** | CPU resource requests. The default is `250m` |
| **messagebus.resources.requests.memory** | Memory resource requests. The default is `256Mi` |
| **messagebus.arch** | Worker node architecture. Fixed to `amd64`. |


You can specify each parameter using the --set key=value[,key=value] argument to helm install to override any of the parameter values from the command line. For example:
```sh
$ helm install --tls --namespace <your pre-created namespace> --name my-mb-kafka-probe --set license=accept,probe.messageLevel=debug
```
This sets the license parameter to `accept` and probe.messageLevel to `debug`.

## Limitations

- Only supports amd64 platform architecture.
- Validated to run on the following platforms:
  - IBM Cloud Private 3.2.0
  - IBM Cloud Private 3.1.2
  - IBM Cloud Private 3.2.0 on Red Hat OpenShift Container Platform 3.11
  - IBM Cloud Private 3.1.2 on Red Hat OpenShift Container Platform 3.10
- Validated to run against Apache Kafka 2.11-2 (Scala 2.11)
- Validated to run against IBM Event Streams V2019.2.1
- Validated to run against Microsoft Azure Event Hubs for Kafka
- When connecting to an Object Server in the same IBM Cloud Private cluster, you may connect the probe to the secure connection proxy which is deployed with the IBM Netcool Operations Insight chart to encrypt the communication using TLS but the TLS termination is done at the proxy. It is recommended to enable IPSec on IBM Cloud Private to secure cluster data network communications.

## Documentation

-   [IBM Tivoli Netcool/OMNIbus Message Bus Probe for Kafka Integrations Helm Chart](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/messagebus_kafka/wip/concept/mbkaf_intro.html)
- [IBM Tivoli Netcool/OMNIBus Probe for Message Bus (Probe) Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/message_bus/wip/concept/messbuspr_intro.html)
- [IBM Tivoli Netcool OMNIbus Probes and Gateways Helm Charts](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/common/Helms.html)
- [Init container: Understanding Pod status](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-init-containers/#understanding-pod-status)
- [Using helm CLI](https://github.com/helm/helm/blob/master/docs/using_helm.md)
