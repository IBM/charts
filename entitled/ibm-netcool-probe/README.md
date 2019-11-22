# IBM Netcool/OMNIbus Probe - Cloud Monitoring Integration

This Helm chart deploys IBM Netcool/OMNIbus Probe for Message Bus
onto Kubernetes. This probe processes events and alerts from
Logstash HTTP output, Prometheus Alertmanager, and IBM Cloud Event Management (CEM) to a Netcool Operations Insight operational dashboard.

## Introduction

IBM® Netcool® Operations Insight enables IT and network operations teams to increase effectiveness, efficiency
and reliability by leveraging cognitive analytics capabilities to identify, isolate and resolve problems before
they impact your business. It provides a consolidated view across your local, cloud and hybrid environments and
delivers actionable insight into the health and performance of services and their associated dynamic network and
IT infrastructures. More information can be seen here: [IBM Marketplace - IT Operations Management](https://www.ibm.com/uk-en/marketplace/it-operations-management)

## Chart Details

- Deploys IBM Netcool/OMNIbus Probe for Message Bus onto Kubernetes to start webhook endpoints to receive notification in a form of HTTP POST requests from monitoring systems such as IBM Cloud Event Management, Logstash, and Prometheus Alert Manager. All probes can be enabled in the same Helm release or enabled individually if necessary.

- Each probe deployment is fronted by a service.

- This chart can be deployed more than once on the same namespace.
  
- Each probe deployment uses a pre-defined probe rules file from a ConfigMap to parse the JSON alarms from each event source and maps the attributes to ObjectServer fields. The rules file sets the required Event Grouping field, for example `ScopeID`.

- The probe deployments are configured with [Horizontal Pod Autoscaler (HPA)](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) to maintain high availability of the service by default. [Pod Disruption Budgets (PDB)](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) can be enabled by an Administrator user. HPA and PDB can be customized or disabled to suit your environment.

## Prerequisites

- This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe either on IBM Cloud Private (ICP) or on-premise:
  - For ICP, IBM Netcool Operations Insight 1.6.0.1 is required. Refer to the installation instructions at [IBM Knowledge Center - Installing on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_installing-on-icp.html).
  - For on-premise, IBM Tivoli Netcool/OMNIbus 8.1 is required. Refer to the installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).

- [Scope-based Event Grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/concept/omn_con_ext_aboutscopebasedegrp.html) is installed. The probe requires several table fields to be installed in the ObjectServer. For on-premise installation, refer instructions at [IBM Knowledge Center - Installing scope-based event grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ext_installingscopebasedegrp.html). The events will be grouped by a preset `ScopeId` in the probe rules file if the event grouping automation triggers are enabled.

- Kubernetes 1.10
- Tiller 2.9.1
- Logstash 5.5.1. **Note** Logstash on ICP 3.2 on OCP 3.11 platforms require the logging service to be installed. The logging service is not installed on this platform by default.
- Prometheus 2.3.1 and Prometheus Alert Manager 0.15.0.
- IBM Cloud Event Management Helm Chart 2.4.0
- The chart must be installed by a Administrator to perform the following tasks:
    - Enable Pod Disruption Budget policy when installing the chart.
    - Perform post-installation tasks such as to configure Prometheus Alert Manager and Logstash in the `kube-system` namespace to add the probe endpoint.
    - Retrieve and edit sensitive information from a secret such as the credentials to use to authenticate with the Object Server or replace the Key database files for secure communications with the Object Server.
  - The chart must be installed by a Cluster Administrator to perform the following tasks in addition to those listed above:
    - Obtain the Node IP using `kubectl get nodes` command if using the NodePort service type.
    - Create a new namespace with custom PodSecurityPolicy if necessary. See PodSecurityPolicy Requirements [section](#podsecuritypolicy-requirements) for more details.
- A custom service account must be created in the namespace for this chart. Perform one of the following actions:
  - Have the Cluster Administrator pre-create the custom service account in the namespace. This installation requires the service account name to specified to install the chart and can be done by an Administrator.
  - Have the Cluster Administrator perform the installation without specifying a service account name so that the chart generates a service account and use it. When the Helm release is deleted, the service account will also be deleted.
- If secured communication is required or enabled on your Netcool/OMNIbus Object Server, a pre-created secret is required for this chart to establish a secured connection with the Object Server.
- Additional Object Server fields required in the `alerts.status` table for IBM CEM integration. Refer to [Integrating IBM Cloud Event Management (CEM) with Netcool Operations Insight section](#integrating-ibm-cloud-event-management-cem-with-netcool-operations-insight) for the SQL (Structured Query Language) to add the required fields.

### Resources Required

- CPU Requested : 100m (100 millicpu)
- Memory Requested : 128Mi (~ 134 MB)

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
        kubernetes.io/description: "This policy is the most restrictive, 
          requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
        cloudpak.ibm.com/version: "1.1.0"
      name: ibm-netcool-probe-psp
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
  * Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-netcool-probe-clusterrole
    rules:
    - apiGroups:
      - policy
      resourceNames:
      - ibm-netcool-probe-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
  * RoleBinding for all service accounts in the current namespace. Replace `{{ NAMESPACE }}` in the template with the actual namespace.
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: ibm-netcool-probe-rolebinding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ibm-netcool-probe-clusterrole
    subjects:
    - apiGroup: rbac.authorization.k8s.io
      kind: Group
      name: system:serviceaccounts:{{ NAMESPACE }}
    ```
* From the command line, you can run the setup scripts included under pak_extensions.
  
  As a cluster administrator, the pre-install scripts and instructions are located at:
  * pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin/operator the namespace scoped scripts and instructions are located at:
  * pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

### Red Hat OpenShift SecurityContextConstraints Requirements

On Red Hat OpenShift Container Platform, this chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

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
        cloudpak.ibm.com/version: "1.0.0"
      name: ibm-netcool-probe-scc
    allowHostDirVolumePlugin: false
    allowHostIPC: false
    allowHostNetwork: false
    allowHostPID: false
    allowHostPorts: false
    allowPrivilegedContainer: false
    allowPrivilegeEscalation: false
    allowedCapabilities: []
    allowedFlexVolumes: []
    allowedUnsafeSysctls: []
    defaultAddCapabilities: []
    defaultPrivilegeEscalation: false
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
- From the command line, you can run the setup scripts included under pak_extensions
  As a cluster admin the pre-install instructions are located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped instructions are located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

## Secure Probe and Object Server Communication Requirement

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
This can be configured by setting the `netcool.connectionMode` chart parameter with one of these options:

* `Default` - This is the default mode. Use this mode to connect with the Object Server with neither secure mode nor SSL.
* `AuthOnly` - Use this mode when the Object Server is configured to run in secured mode without SSL.
* `SSLOnly` - Use this mode when the Object Server is configured with SSL without secure mode.
* `SSLAndAuth` - Use this mode the Object Server is configured with SSL and secure mode.

To [secure the communications between probe clients and the Object Server](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_securing_server_comms.html?pos=2), there are several tasks 
that must be completed before installing the chart.
  1. Determine Files Required for the Secret
  2. Preparing Credential Files for Authentication
  3. Preparing Key Database File for SSL Communication
  4. Create Probe-Server Communication Secret

If you are using the `Default` mode, you can skip the these steps and 
proceed configuring the chart with your Object Server connection details.

Please refer to the this Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_securing_server_comms.html) for detailed steps to prepare this required secret.

**Note** There are several known limitations listed in the [Limitations section](#limitations) when securing probe communications.

## Securing Probe and Event Source Communications

To secure the communications between the probe and event sources such as Prometheus, Logstash or IBM CEM in the same cluster, you may enable IPSec to encrypt cluster data network traffic. For more information, refer to the Data Encryption section in the [Preparing to secure your cluster page](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/installing/plan_security.html).

## Role-Based Access Control

Role-Based Access Control (RBAC) is applied to the chart by using a custom service account having a specific role binding. RBAC provides greater security by ensuring that the chart operates within the specified scope. Refer to [Role-Based Access Control page](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_role_based_access.html) in IBM Knowledge Center for more details to create the RBAC resources.  

## Installing the Chart

1. Extract the helm chart archive and customize the `values.yaml`. The [configuration](#configuration) section lists the parameters that can be configured during installation.

2. The command below shows how to install the chart with the release name `my-probe` using the configuration specified in the customized `values.yaml`. Helm searches for the `ibm-netcool-probe` chart in the helm repository called `stable`. This assumes that the chart exists in the `stable` repository.

  ```sh
  helm install --tls --namespace <your pre-created namespace> --name my-probe -f values.yaml stable/ibm-netcool-probe
  ```

> **Tip**: List all releases using `helm list --tls` or search for a chart using `helm search`.


## Verifying the Chart

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release> --tls`.

## Uninstalling the Chart

To uninstall the chart with the release name `my-probe`:

```bash
$ helm delete my-probe --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## Clean up any prerequisites that were created

As a Cluster Administrator, run the cluster administration clean up script included under pak_extensions to clean up cluster scoped resources when appropriate.

- post-delete/clusterAdministration/deleteSecurityClusterPrereqs.sh

As a Cluster Administrator, run the namespace administration clean up script included under pak_extensions to clean up namespace scoped resources when appropriate.

- post-delete/namespaceAdministration/deleteSecurityNamespacePrereqs.sh


## Configuration

The integration requires configuration of the following components:

- This chart to deploy the Netcool/OMNIbus probes.
- Prometheus Alert Manager to add a new `receiver` to direct notification to the probe and apply Prometheus alert rules.
- Logstash pipeline to add a `http` output to send notification to the probe.
- An outgoing integration and event forwarding policy in IBM Cloud Event Management.

The following table lists the configurable parameters of this chart and their default values.

|  Parameter                                          | Description  |
| ----------------------------------------------------| -------------|
|  **license**                                          | The license state of the image being deployed. Enter `accept` to install and use the image. The default is `not accepted`. |
|  **image.repository**                                 | Probe image repository. Update this repository name to pull from a private image repository. The image name must be `netcool-probe-messagebus`. The default is `netcool-probe-messagebus`. |
|  **image.tag**                                        | Probe image tag. The default is `10.0.5.0-amd64`. |
|  **image.testRepository**                             | Utility image repository. Update this repository name to pull from a private image repository. The image name must be `netcool-integration-util`. The default is `netcool-integration-util`. |
|  **image.testImageTag**                               | Utility image tag. The default is `2.0.0-amd64`. |
|  **image.pullPolicy**                                 | Image pull policy. The default is `Always`. |
|  **global.image.secretName**                          | Name of the Secret containing the Docker Config to pull image from a private repository. Leave blank if the probe image already exists in the local image repository or the Service Account has been assigned with an Image Pull Secret. The default is `nil`. |
|  **global.serviceAccountName**                          | Name of the service account to be used by the helm chart. If the Cluster Administrator has already created a service account in the namespace, specify the name of the service account here. If left blank, the chart will automatically create a new service account in the namespace when it is deployed. This new service account will be removed from the namespace when the chart is removed. The default is `nil`. |
|  **netcool.connectionMode**                            | The connection mode to use when connecting to the Netcool/OMNIbus Object Server. Refer to [Securing Probe and Object Server Communications section](#securing-probe-and-object-server-communications) for more details. **Note**: Refer to limitations section for more details on available connection modes for your environment. The default is `default`. |
|  **netcool.primaryServer**                            | The primary Netcool/OMNIbus server the probe should connect to (required). Usually set to NCOMS or AGG_P. The default is `nil`. |
|  **netcool.primaryHost**                              | The host of the primary Netcool/OMNIbus server (required). Specify the  Object Server Hostname or IP address. The default is `nil`. |
|  **netcool.primaryPort**                              | The port number of the primary Netcool/OMNIbus server (required). The default is `nil`. |
|  **netcool.backupServer**                             | The backup Netcool/OMNIbus server to connect to. If the backupServer, backupHost and backupPort parameters are defined in addition to the primaryServer, primaryHost, and primaryPort parameters, the probe will be configured to connect to a virtual object server pair called `AGG_V`. The default is `nil`. |
|  **netcool.backupHost**                               | The host of the backup Netcool/OMNIbus server. Specify the  Object Server Hostname or IP address. The default is `nil`. |
|  **netcool.backupPort**                               | The port of the backup Netcool/OMNIbus server. The default is `nil`. |
|  **netcool.secretName**                               | A pre-created secret for AuthOnly, SSLOnly or SSLAndAuth connection mode. Certain fields are required depending on the connection mode. The default is `nil`. |
|  **probe.messageLevel**                               | Probe log message level. The default is `warn`. |
|  **probe.setUIDandGID**                               | If true, the helm chart specifies UID and GID values to be assigned to the netcool user in the container. Otherwise when false the netcool user will not be assigned any UID or GID by the helm chart. Refer to the deployed PSP or SCC in the 
namespace to determine the correct value for this parameter. The default is `true`. |
|  **probe.sslServerCommonName**                        | A comma-separated list of acceptable SSL Common Names when connecting to Object Server using SSL. This should be set when the CommonName field of the received certificate does not match the name specified by the primaryServer property. When a backupServer is specified, the probe will create an Object Server pair with AGG_V as the name. Set this parameter if the Common Name of the certificate does not match AGG_V. The default is `nil`. |
|  **probe.locale**                               | Probe environment locale setting. Used as the LC_ALL environment variable. The default is `en_US.utf8`. |
|  **logstashProbe.enabled**                            | Set to `true` to enable a probe for Logstash. The default is `true`. |
|  **logstashProbe.replicaCount**                       | Number of deployment replicas of the Logstash Probe.Ignored if `logstashProbe.autoscaling.enabled=true` and will use the `minReplicas` as the `replicaCount`. The default is `5`. |
|  **logstashProbe.service.type**                       | Logstash probe service type. Options are `NodePort` or `ClusterIP`. The default is `ClusterIP`. |
|  **logstashProbe.service.externalPort**               | Logstash probe external port that probe is running on. The default is `80`. |
|  **logstashProbe.ingress.enabled**                    | Set to `true` to enable ingress. Use to create Ingress record (should be used with service.type: ClusterIP) for Logstash probe. The default is `false`. |
|  **logstashProbe.ingress.hosts**                      | Sets the virtual host names for the same IP address. The Helm release name will be appended as a prefix. The default is `netcool-probe-logstash.local`. |
|  **logstashProbe.autoscaling.enabled**                | Set to `false` to disable auto-scaling. The default is true. |
|  **logstashProbe.autoscaling.minReplicas**            | Minimum number of probe replicas. The default is `2`. |
|  **logstashProbe.autoscaling.maxReplicas**            | Maximum number of probe replicas. The default is `6`. |
|  **logstashProbe.autoscaling.cpuUtil**                | The target CPU utilization (in percentage). Example: `60` for 60% target utilization. The default is `60`. |
|  **logstashProbe.poddisruptionbudget.enabled**        | Set to `true` to enable Pod Disruption Budget to maintain high availability during a node maintenance. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control. The default is `false`. |
|  **logstashProbe.poddisruptionbudget.minAvailable**   | The number of minimum available number of pods during node drain. Can be set to a number or percentage, eg: 1 or 10%. Caution: Setting to 100% or equal to the number of replicas) may block node drains entirely. The default is `1`. |
|  **prometheusProbe.enabled**                          | Set to `true` to enable a probe for Prometheus. The default is `true`. |
|  **prometheusProbe.replicaCount**                     | Number of deployment replicas of the Prometheus Probe. Ignored if `prometheusProbe.autoscaling.enabled=true` and will use the `minReplicas` as the `replicaCount`. The default is `1`. |
|  **prometheusProbe.service.type**                     | Prometheus probe service type. Options are `NodePort` or `ClusterIP`. The default is `ClusterIP`. |
|  **prometheusProbe.service.externalPort**             | Prometheus probe external port that probe is running on. The default is `80`. |
|  **prometheusProbe.ingress.enabled**                  | Set to `true` to enable ingress. Use to create Ingress record (should be used with service.type: ClusterIP) for Prometheus probe. The default is `false`. |
|  **prometheusProbe.ingress.hosts**                    | Sets the virtual host names for the same IP address. The Helm release name will be appended as a prefix. The default is `netcool-probe-prometheus.local`. |
|  **prometheusProbe.autoscaling.enabled**              | Set to `false` to disable auto-scaling. The default is true. |
|  **prometheusProbe.autoscaling.minReplicas**          | Minimum number of probe replicas. The default is `1`. |
|  **prometheusProbe.autoscaling.maxReplicas**          | Maximum number of probe replicas. The default is `3`. |
|  **prometheusProbe.autoscaling.cpuUtil**              | The target CPU utilization (in percentage). Example: `60` for 60% target utilization. The default is `60`. |
|  **prometheusProbe.poddisruptionbudget.enabled**      | Set to `true` to disable Pod Disruption Budget to maintain high availability during a node maintenance. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control. The default is `false`. |
|  **prometheusProbe.poddisruptionbudget.minAvailable** | The minimum number of available pods during node drain. Can be set to a number or percentage, eg: 1 or 10%. Caution: Setting to 100% or equal to the number of replicas may block node drains entirely. The default is `1`. |
|  **cemProbe.enabled**                          | Set to `true` to enable a probe for CEM. The default is `false`. |
|  **cemProbe.replicaCount**                     | Number of deployment replicas of the CEM Probe. Ignored if `cemProbe.autoscaling.enabled=true` and will use the `minReplicas` as the `replicaCount`. The default is `1`. |
|  **cemProbe.service.type**                     | CEM probe service type. Options are `NodePort` or `ClusterIP`. The default is `ClusterIP`. |
|  **cemProbe.service.externalPort**             | CEM probe external port that probe is running on. The default is `80`. |
|  **cemProbe.autoscaling.enabled**              | Set to `false` to disable auto-scaling. The default is true. |
|  **cemProbe.autoscaling.minReplicas**          | Minimum number of probe replicas. The default is `1`. |
|  **cemProbe.autoscaling.maxReplicas**          | Maximum number of probe replicas. The default is `3`. |
|  **cemProbe.autoscaling.cpuUtil**              | The target CPU utilization (in percentage). Example: `60` for 60% target utilization. The default is `60`. |
|  **cemProbe.poddisruptionbudget.enabled**      | Set to `true` to disable Pod Disruption Budget to maintain high availability during a node maintenance. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control. The default is `false`. |
|  **cemProbe.poddisruptionbudget.minAvailable** | The minimum number of available pods during node drain. Can be set to a number or percentage, eg: 1 or 10%. Caution: Setting to 100% or equal to the number of replicas may block node drains entirely. The default is `1`. |
|  **resources.limits.cpu**                             | Container CPU limit. The default is `500m`. |
|  **resources.limits.memory**                          | Container memory limit. The default is `512Mi`. |
|  **resources.requests.cpu**                           | Container CPU requested. The default is `100m`. |
|  **resources.requests.memory**                        | Container Memory requested. The default is `128Mi`. |
|  **arch**                                             | Worker node architecture. Fixed to `amd64`. |


You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install` to override any of the parameter value from the command line. For example `helm install --tls --namespace <namespace> --name my-probe --set license=accept,probe.messageLevel=debug` to set the `license` parameter to `accept` and `probe.messageLevel` to `debug`.


## Integrating Prometheus Alert Manager with Netcool Operations Insight

### Modifying Prometheus Alert Manager and Alert Rules Configuration

This procedure modifies the default Prometheus configuration.

1. After deploying the chart, get the probe's Endpoint Host and Port from the Workloads > Deployments page.
   - If the `prometheusProbe.service.type` is set to `ClusterIP`, the full webhook URL should look like  `http://<service name>.<namespace>:<externalPort>/probe/webhook/prometheus`.
     - To obtain the service name and port via command line, use the commands below. Substitute `<namespace>` with the namespace where the release is deployed and `<release_name>` with the Helm release name.
        ```
        # Get the Service name
        export SVC_NAME=$(kubectl get services --namespace <namespace> -l "app.kubernetes.io/instance=<release_name>,app.kubernetes.io/component=prometheusprobe" -o jsonpath="{.items[0].metadata.name}")

        # Get the Service port number
        export SVC_PORT=$(kubectl get services --namespace <namespace> -l "app.kubernetes.io/instance=<release_name>,app.kubernetes.io/component=prometheusprobe" -o jsonpath="{.items[0].spec.ports[0].port}")
        ```
   - If the `prometheusProbe.service.type` is set to `NodePort`, the full webhook URL should look like  `http://<External IP>:<Node Port>/probe/webhook/prometheus`.
     - To obtain the NodePort number via command line, use the commands below. Substitute `<namespace>` with the namespace where the release is deployed and `<release_name>` with the Helm release name.
      ```
        # Get the NodePort number from the Service resource
        export NODE_PORT_PROMETHEUS=$(kubectl get services --namespace <namespace> -l "app.kubernetes.io/instance=<release_name>,app.kubernetes.io/component=prometheusprobe" -o jsonpath="{.items[0].spec.ports[0].nodePort}")

        # On ICP 3.1.1 or later, you can obtain the External IP from the IBM Cloud Cluster Info Configmap using the command below.
        export NODE_IP_PROMETHEUS=$(kubectl get configmap --namespace kube-public ibmcloud-cluster-info -o jsonpath="{.data.proxy_address}")
        
        echo http://$NODE_IP_PROMETHEUS:$NODE_PORT_PROMETHEUS/probe/webhook/prometheus
      ```

2. Determine the Prometheus Alert Manager ConfigMap in the cluster. In this procedure, the ConfigMap in the `kube-system` namespace are `monitoring-prometheus-alertmanager`. The following steps will use this ConfigMap as example.

3. Edit the first ConfigMap (Prometheus Alert Manager ConfigMap) to add a new receiver in the receivers section. If a separate Prometheus is deployed, determine the Alert Manager ConfigMap and add the new receiver. To do this via the command line, load the `monitoring-prometheus-alertmanager` ConfigMap into a file.

```bash
kubectl get configmap monitoring-prometheus-alertmanager --namespace=kube-system -o yaml > alertmanager.yaml
```

4. Update the `alertmanager.yaml` file to add a new webhook receiver configuration. Sample ConfigMap configuration is shown below.Use the full webhook URL from step 1 above in the `url` parameter.

```bash
$ cat alertmanager.yaml
apiVersion: v1
data:
  alertmanager.yml: |-
    global:
    receivers:
    - name: 'netcool_probe'
      webhook_configs:
      - url: 'http://<ip_address>:<port>/probe/webhook/prometheus'
        send_resolved: true

    route:
      group_wait: 10s
      group_interval: 5m
      receiver: 'netcool_probe'
      repeat_interval: 3h
kind: ConfigMap
metadata:
  creationTimestamp: 2018-04-18T02:38:14Z
  labels:
    app: monitoring-prometheus
    chart: ibm-icpmonitoring-1.3.0
    component: alertmanager
    heritage: Tiller
    release: monitoring
  name: monitoring-prometheus-alertmanager
  namespace: kube-system
  resourceVersion: "1856489"
  selfLink: /api/v1/namespaces/kube-system/configmaps/monitoring-prometheus-alertmanager
  uid: 8aef5f39-42b1-11e8-bd3d-0050569b6c73

```

> **Note:** The `send_resolved` flag should be set to `true` so that the probe receives resolution events.

5. Save the changes in the file and replace the ConfigMap using:

```bash
$ kubectl replace configmap monitoring-prometheus-alertmanager --namespace=kube-system -f alertmanager.yaml

configmap "monitoring-prometheus-alertmanager" replaced
```

6. Review the sample alert rules CRD YAML below. You may update the rules or add more rules to generate more alerts to monitor your cluster. The Message Bus Probe rules file expects the following attributes from the alerts generated by Prometheus Alert Manager:
   1. `labels.severity` - The severity of the alert. Should be set to critical, major, minor, or warning. This is mapped to the Severity field in the Object Server alerts.status table.
   2. `labels.instance` - The instance generating the alert. This is mapped to the Node field in the Object Server alerts.status table.
   3. `labels.alertname` - The alert rule name. This is mapped to the AlertGroup field in the Object Server alerts.status table.
   4. `annotations.description` - (Optional) The full description of the alert. This is mapped to the Summary field in the Object Server alerts.status table.
   5. `annotations.summary` - A short description or summary of the alert. This is mapped to the Summary field in the Object Server alerts.status table if `annotations.description` is unset.
   6. `annotations.type` - The alert type. For example, "Container", "Service", or "Service". This is mapped to the AlertKey field in the Object Server alerts.status table.
   7. `labels.release` - (Optional) If set, will be mapped to the ScopeId field in the Object Server alerts.status table which will be used as the first level group to group related events.
   8. `labels.job` - (Optional) If set, will be mapped to the SiteName field in the Object Server alerts.status table which will be used as the sub-group to group related events.

> Sample alert-rules CRD. This file is also available in the included CloudPak under pak_extensions/prometheus-rules.
```yaml
# File: netcool-rules.yaml
# Please modify these rules to monitor specific workloads,
# containers, services or nodes in your cluster
apiVersion: monitoringcontroller.cloud.ibm.com/v1
kind: AlertRule
metadata:
  name: netcool-rules
spec:
  enabled: true
  data: |-
    groups:
    - name: alertrules.rules
      rules:
      ## Sample workload monitoring rules
      - alert: jenkins_down
        expr: absent(container_memory_usage_bytes{pod_name=~".*jenkins.*"})
        for: 30s
        labels:
          severity: critical
        annotations:
          description: Jenkins container is down for more than 30 seconds.
          summary: Jenkins down
          type: Container
      - alert: jenkins_high_cpu
        expr: sum(rate(container_cpu_usage_seconds_total{pod_name=~".*jenkins.*"}[1m]))
          / count(node_cpu_seconds_total{mode="system"}) * 100 > 70
        for: 30s
        labels:
          severity: warning
        annotations:
          description: Jenkins CPU usage is {{ humanize $value}}%.
          summary: Jenkins high CPU usage
          type: Container
      - alert: jenkins_high_memory
        expr: sum(container_memory_usage_bytes{pod_name=~".*jenkins.*"}) > 1.2e+09
        for: 30s
        labels:
          severity: warning
        annotations:
          description: Jenkins memory consumption is at {{ humanize $value}}.
          summary: Jenkins high memory usage
          type: Container
      ## End - Sample workload monitoring rules.
      ## Sample container monitoring rules
      - alert: container_restarts
        expr: delta(kube_pod_container_status_restarts_total[1h]) >= 1
        for: 10s
        labels:
          severity: warning
        annotations:
          description: The container {{ $labels.container }} in pod {{ $labels.pod }}
            has restarted at least {{ humanize $value}} times in the last hour on instance
            {{ $labels.instance }}.
          summary: Containers are restarting
          type: Container
      ## End - Sample container monitoring rules.
      ## Sample node monitoring rules
      - alert: high_cpu_load
        expr: node_load1 > 1.5
        for: 30s
        labels:
          severity: critical
        annotations:
          description: Docker host is under high load, the avg load 1m is at {{ $value}}.
            Reported by instance {{ $labels.instance }} of job {{ $labels.job }}.
          summary: Server under high load
          type: Server
      - alert: high_memory_load
        expr: (sum(node_memory_MemTotal_bytes) - sum(node_memory_MemFree_bytes + node_memory_Buffers_bytes
          + node_memory_Cached_bytes)) / sum(node_memory_MemTotal_bytes) * 100 > 85
        for: 30s
        labels:
          severity: warning
        annotations:
          description: Docker host memory usage is {{ humanize $value}}%. Reported by
            instance {{ $labels.instance }} of job {{ $labels.job }}.
          summary: Server memory is almost full
          type: Server
      - alert: high_storage_load
        expr: (node_filesystem_size_bytes{fstype="aufs"} - node_filesystem_free_bytes{fstype="aufs"})
          / node_filesystem_size_bytes{fstype="aufs"} * 100 > 85
        for: 30s
        labels:
          severity: warning
        annotations:
          description: Docker host storage usage is {{ humanize $value}}%. Reported by
            instance {{ $labels.instance }} of job {{ $labels.job }}.
          summary: Server storage is almost full
          type: Server
      - alert: monitor_service_down
        expr: up == 0
        for: 30s
        labels:
          severity: critical
        annotations:
          description: Service {{ $labels.instance }} is down.
          summary: Monitor service non-operational
          type: Service
      ## End - Sample node monitoring rules.
```

7. Use the following command to create a new `AlertRule` in the kube-system namespace.
```
$ kubectl apply -f netcool-rules.yaml --namespace kube-system
```

8. It usually takes a couple of minutes for Prometheus to reload the updated ConfigMap and apply the new configuration.  Verify that Prometheus events appear on the OMNIbus Event List.

## Integrating Logstash with Netcool Operations Insight

### Modifying Logstash Configuration

This procedure modifies the Logstash configuration:

1. After deploying the chart, get the probe's Endpoint Host and Port from the Workloads > Deployments page. 
   - If the `logstashProbe.service.type` is set to `ClusterIP`, the full webhook URL should look like  `http://<service name>.<namespace>:<externalPort>/probe/webhook/logstash`. 
     - To obtain the service name and port via command line, use the commands below. Substitute `<namespace>` with the namespace where the release is deployed and `<release_name>` with the Helm release name.
        ```
        # Get the Service name
        export SVC_NAME=$(kubectl get services --namespace <namespace> -l "app.kubernetes.io/instance=<release_name>,app.kubernetes.io/component=logstashprobe" -o jsonpath="{.items[0].metadata.name}")

        # Get the Service port number
        export SVC_PORT=$(kubectl get services --namespace <namespace> -l "app.kubernetes.io/instance=<release_name>,app.kubernetes.io/component=logstashprobe" -o jsonpath="{.items[0].spec.ports[0].port}")
        ```
   - If the `logstashProbe.service.type` is set to `NodePort`, the full webhook URL should look like  `http://<External IP>:<Node Port>/probe/webhook/logstash`.
     - To obtain the NodePort number via command line, use the commands below. Substitute `<namespace>` with the namespace where the release is deployed and `<release_name>` with the Helm release name.
        ```
        # Get the NodePort number from the Service resource
        export NODE_PORT_LOGSTASH=$(kubectl get services --namespace <namespace> -l "app.kubernetes.io/instance=<release_name>,app.kubernetes.io/component=logstashprobe" -o jsonpath="{.items[0].spec.ports[0].nodePort}")

        # On ICP 3.1.1 or later, you can obtain the External IP from the IBM Cloud Cluster Info Configmap using the command below.
        export NODE_IP_LOGSTASH=$(kubectl get configmap --namespace kube-public ibmcloud-cluster-info -o jsonpath="{.data.proxy_address}")

        echo http://$NODE_IP_LOGSTASH:$NODE_PORT_LOGSTASH/probe/webhook/logstash
        ```

2. Determine the Logstash Pipeline ConfigMap in the same namespace. In this procedure, the ConfigMap in the `kube-system` namespace is `logging-elk-logstash-pipeline-config`. If a separate Logstash is deployed, determine the pipeline ConfigMap and add a new `http output`. Note: In ICP 3.1.2 or below, the Logstash Pipeline ConfigMap name is `logging-elk-logstash-config`.

3. Edit the Logstash pipeline ConfigMap to add a new `http output`.  To do this via the command line, configure `kubectl` client and follow the steps below.

4. Load the ConfigMap into a file.

  ```bash
  kubectl get configmap logging-elk-logstash-pipeline-config --namespace=kube-system -o yaml > logging-elk-logstash-pipeline-config.yaml
  ```

5. Edit the `logging-elk-logstash-pipeline-config.yaml` and modify the output object to add a new `http output` object as shown below. Use the full webhook URL as shown in step 1 above in the `http.url` parameter.

  ```
      output {
        elasticsearch {
          index => "logstash-%{+YYYY.MM.dd}"
          hosts => "elasticsearch:9200"
        }
        http {
          url => "http://<ip_address>:<port>/probe/webhook/logstash"
          format => "json"
          http_method => "post"
          pool_max_per_route => "5"
        }
      }
  ```

  > **Note**: (Optional) The pool_max_per_route is set to limit concurrent connection to the probe to 5 so that Logstash does not flood the probe which may cause event loss.

6. Save the changes in the file and replace the ConfigMap.

  ```bash
  kubectl replace --namespace kube-system logging-elk-logstash-pipeline-config -f logging-elk-logstash-pipeline-config.yaml

  configmap "logging-elk-logstash-pipeline-config" replaced
  ```

7. Logstash takes a minute or so to reload the new configuration. Check the logs to make sure there are no errors sending HTTP POST notifications to the probe.

## Integrating IBM Cloud Event Management (CEM) with Netcool Operations Insight

### Configuring the Object Server

This section is only applicable to prepare an on-premise ObjectServer with the required fields. For NOI on ICP, you can skip this section because the required fields are already pre-installed in the ObjectServer. 

To integrate with IBM CEM, there are several additional Object Server fields required by the probe to map CEM event attributes into the `alerts.status` table. The additional fields can be added using the `$OMNIHOME/bin/nco_sql` and must be performed prior installing this chart.

1. Copy and save the following SQL (Structured Query Language) commands into a file called "cem.sql".
  ```sql
  -- Filename: cem.sql
  -- This SQL file adds the fields required by IBM Cloud Event Management
  ALTER TABLE alerts.status ADD COLUMN CEMSubscriptionID VARCHAR(64);
  go

  ALTER TABLE alerts.status ADD COLUMN CEMIncidentUUID VARCHAR(64);
  go

  ALTER TABLE alerts.status ADD COLUMN NodeType VARCHAR(64);
  go

  ALTER TABLE alerts.status ADD COLUMN CEMEventId  VARCHAR(64);
  go

  ALTER TABLE alerts.status ADD COLUMN CEMErrorCode INTEGER;
  go

  ALTER TABLE alerts.status ADD COLUMN CEMDeduplicationKey  VARCHAR(64);
  go
  ```

2. Load the SQL commands contained in the cem.sql file as follows:
  ```sh
  $OMNIHOME/bin/nco_sql -server server_name \
    -user user_name \
    -password 'password' < cem.sql
  ```

### Configuring IBM CEM

To integrate and receive events from IBM Cloud Event Management, the `ibm-cem` chart must be installed in the same cluster. 

Detailed steps to install and configure IBM Cloud Event Management in IBM Cloud Private (ICP) can be found on this [page](https://www.ibm.com/support/knowledgecenter/en/SSURRN/com.ibm.cem.doc/em_install_cem_icp.html).

The following steps shows how to create an outgoing integration, register the probe's webhook endpoint and create an event forwarding policy in IBM CEM.

1. Configure and install this `ibm-netcool-probe` chart in ICP. Ensure that the `cemProbe.enabled` parameter is set to `true` to enable a probe endpoint for CEM. Refer to the [Configuration section](#configuration) for more details.
2. Follow the instructions in the Notes section after installing this chart to obtain the probe's webhook endpoint URL. From the UI, go to Menu -> Workloads -> Helm Releases -> <Probe Release Name>.
3. As an CEM Administrator, go to Menu -> Workload -> Brokered Services -> <CEM Instance Name> and click "Launch" to launch and login to the CEM UI.
4. Go to the Administration page, click "Integrations".
5. Click "Configuring an integration" button, select an "Outgoing" integration for Netcool/OMNIbus, click "Configure" and follow the steps to configure the outgoing integration.
   1. Give a name for this outgoing integration. You may use the probe release name for easy reference.
   2. You may skip Step 2. "Download and decompress a package of configuration files" because this probe chart already has the required configuration and rules files pre-configured.
   3. Enter the probe webhook endpoint obtained from the probe release in the previous step.
   4. Skip step 4. "Enter your credentials" because this step is not applicable when integrating with a probe in ICP.
   5. Turn on the integration.
   6. Click Save and verify that the outgoing integration is successfully created.
6. To create an event forwarding policy, go to the Administration page and click "Policies", then click "Create event policy" to create a new event policy and follow the steps to configure the event policy. You may add a forwarding rule in an existing policy if necessary.
   1. Give a name and description for this policy.
   2. Select "All Events" to forward all CEM events to Netcool/OMNIbus. Optionally, you may configure the policy to only forward selected events.
   3. Check the "Forwarding events" option, click "Add integrations" button and then select the outgoing integration created in the previous step.
   4. Enable this event policy.
   5. Click "Save" and verify that the event policy is successfully installed. It should be listed in the Policies page.
7. It may take a moment before CEM start to forward events to Netcool/OMNIbus. Verify that CEM events appear in the OMNIbus Event List.

## Limitations

- Only the AMD64 / x86_64 architecture is supported for IBM Tivoli Netcool/OMNIbus Message Bus Probe.
- This chart is verified to run on IBM Cloud Private 3.1.2 or 3.2.0, IBM Cloud Private 3.1.2 on Red Hat OpenShift 3.10 and IBM Cloud Private 3.2.0 on Red Hat OpenShift 3.11.
- There are several known limitations when enabling secure connection between probe clients and server:
  - The required files in the secret must be created using the `nc_gskcmd` utility.
  - If your Object Server is configured with FIPS 140-2, the password for the key database file (`omni.kdb`) must meet the requirements stated in this [page](https://www.ibm.com/support/knowledgecenter/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ssl_creatingkeydatabasefips.html).
  - When encrypting a string value using the encryption config key file (`encryption.keyfile`), you must use the `AES_FIPS` as the cipher algorithm. `AES` algorithm is not supported.
  - When connecting to an Object Server in the same IBM Cloud Private cluster, you may connect the probe to the secure connection proxy which is deployed with the IBM Netcool Operations Insight chart to encrypt the communication using TLS but the TLS termination is done at the proxy. It is recommended to enable IPSec on IBM Cloud Private to secure cluster data network communications.
- Secure connection with external event sources (outside of the cluster) through the Ingress is not supported.

## Documentation

- IBM Netcool/OMNIbus Probe Cloud Monitoring Integration Helm Chart Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/kubernetes/wip/concept/kub_intro.html)
- Obtaining the IBM Netcool/OMNIbus Probe Cloud Monitoring Integration (Commercial Edition) [page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/common/topicref/hlm_obtaining_ppa_package.html)
- For more information on how to configure the Prometheus Alert Manager or the `ibm-icpmonitoring` chart, please refer to the IBM Cloud Private cluster monitoring [page](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_metrics/monitoring_service.html#config_prom)

## Troubleshooting

Describes potential issues and resolution steps when deploying the probe chart.

| Problem                                                                                                                                         | Cause                                                                                                        | Resolution                                                                          |
|-------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| Probe logs shows an error when loading or reading rules file. Failed during field verification check. Fields `SiteName` and `ScopeID` not found | The OMNIbus Object Server event grouping automation is not installed, hence the required fields are missing. | Install the event grouping automation in your Object Server and redeploy the chart. |
| Error "poddisruptionbudgets.policy is forbidden" occurred when deploying the chart with PodDiscruptionBudget enabled. | The user deploying the chart does not have the correct role to deploy the chart with PodDisruptionBudget enabled. | Administrator or Cluster Administrator role is required to deploy the chart with PodDisruptionBudget enabled. |
| The Logstash probe no longer receives any kubelet events from Logstash. | Since Kubernetes 1.8, kubelet writes to journald for systems with systemd instead of logging to file in a directory monitored by Logstash. Hence, the kubelet logs are not collected by Logstash and not forwarded to the probe. | This is a known limitation and there is no resolution for this issue because it is a change in architecture. |
| The probe deployment failed to mount to the Config Maps or some object name appear to be some what random. | If a long release name is used, the chart will generate a random suffix for objects that exceeds the character limit. This may cause mapping issues between the Kubernetes objects. | Use a shorter release name, below 20 characters. |
| Warning messages eg. `This chart requires a namespace with a ibm-restricted-psp pod security policy` are always displayed when installing the chart using the Catalog on ICP on OCP platforms. | Support for SCCs is not currently implemented for the Catalog. | These warning messages are to be ignored. The chart is still allowed to be installed using the Catalog and will apply SCCs instead of PSPs on ICP on OCP platforms. The Catalog will add support for SCCs in a future release of ICP. |
| The Logstash probe does not receive events from Logstash in ICP on Red Hat OCP. | Logging service may be disabled or there is no events in Logstash. | Verify that the logging service is enabled and events exist in Logstash (or Kibana). |
