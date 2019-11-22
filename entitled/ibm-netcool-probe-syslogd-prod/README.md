# [IBM Tivoli Netcool/OMNIbus Syslogd Probe](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/syslogd/wip/concept/syslogd_intro.html)
This helm chart deploys Netcool/OMNIbus Syslogd probe onto Kubernetes. These probes capture syslog event by binding to a UDP Port from source and process syslog events based on the rules file to a Netcool Operations Insight operational dashboard.

## Introduction
IBM® Netcool® Operations Insight enables IT and network operations teams to increase effectiveness, efficiency
and reliability by leveraging cognitive analytics capabilities to identify, isolate and resolve problems before
they impact your business. It provides a consolidated view across your local, cloud and hybrid environments and
delivers actionable insight into the health and performance of services and their associated dynamic network and
IT infrastructures. More information can be seen here: [IBM Marketplace - IT Operations Management](https://www.ibm.com/uk-en/marketplace/it-operations-management)

## Chart Details
- Deploys Tivoli Netcool/OMNIbus Syslogd probe onto Kubernetes to receive and process syslog events.
- The probe deployment is fronted by a service.  

## Prerequisites
- Kubernetes version 1.11.1.
- Tiller version 2.9.1.
- This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe. To create and run the IBM Tivoli Netcool/OMNIbus ObjectServer, see installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html)
- Netcool Knowledge Library (NcKL) Intra-Device correlation automation is installed and enabled. This automation creates the following objects in the Object Server to aid in determining the causal relevance of events:
  - Intra-device correlation (AdvCorr) tables within the alerts database
  - Supplementary automations implemented as an AdvCorr trigger group and three related triggers
  - Additional columns in the alerts.status table

## Resources Required
- CPU Requested : 250m (250 millicpu)
- Memory Requested : 256Mi (~ 268 MB)

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart. The predefined PodSecurityPolicy definitions can be viewed [here](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/README.md).

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory. Detailed steps to create the PodSecurityPolicy is documented [here](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_common_psp.html).

* From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  * Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is based on the most restrictive policy,
        requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
      name: ibm-netcool-probe-syslogd-prod-psp
    spec:
      allowPrivilegeEscalation: false
      forbiddenSysctls:
      - '*'
      fsGroup:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      hostNetwork: false
      hostPID: false
      hostIPC: false
      requiredDropCapabilities:
      - ALL
      runAsUser:
        rule: MustRunAsNonRoot
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
      name: ibm-netcool-probe-syslogd-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-netcool-probe-syslogd-prod-psp
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
      name: ibm-netcool-probe-syslogd-prod-rolebinding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ibm-netcool-probe-syslogd-prod-clusterrole
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


## Specifying the image repository
The software package of `Syslogd` helm chart also includes the Docker image for the probe and busybox. Importing the software package into ICP adds the Docker image into the locally managed ICP image repository. Images' scope are limited to the namespace of the user who performed the import.

### _Import the package as an admin_
Import the software package as cluster admin or team admin.  When configuring the helm chart, `image.repository` parameter should be configured to `mycluster.icp:8500/default` to use the local image registry or a private image registry. Note that `mycluster.icp` is the default cluster CA domain name, please change this to the correct cluster CA domain name to pull from the local image manager.

### _Configure the image to be available for all namespaces_
To configure the image to be available for all namespaces, refer to Changing image scope [guide](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.1/manage_images/change_scope.html) in IBM Knowledge Center.

## Installing the Chart

1. Extract the helm chart archive and customize the `values.yaml`. The [configuration](#configuration) section lists the parameters that can be configured during installation.

2. The command below shows how to install the chart with the release name `my-probe` using the configuration specified in the customized `values.yaml`. Helm searches the `ibm-netcool-probe-syslogd-prod` chart in the helm repository called `stable`. This assumes that the chart exists in the `stable` repository.

  ```sh
  helm install --tls --namespace <your pre-created namespace> --name my-probe -f values.yaml stable/ibm-netcool-probe-syslogd-prod
  ```

> **Tip**: List all releases using `helm list --tls` or search for a chart using `helm search`.

### Verifying the Chart

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release> --tls`.

### Uninstalling the Chart

To uninstall/delete the `my-probe` deployment:

```sh
$ helm delete my-probe --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Clean up any prerequisites that were created

As a Cluster Administrator, run the cluster administration clean up script included under pak_extensions to clean up cluster scoped resources when appropriate.

- post-delete/clusterAdministration/deleteSecurityClusterPrereqs.sh

As a Cluster Administrator, run the namespace administration clean up script included under pak_extensions to clean up namespace scoped resources when appropriate.

- post-delete/namespaceAdministration/deleteSecurityNamespacePrereqs.sh


## Configuration
The following tables lists the configurable parameters of the `ibm-netcool-probe-syslogd-prod` chart and their default values.

| Parameter                          | Description                                                                                                                                                                                                                                                                               | Default                                                        |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `license`                          | The license state of the image being deployed. Overwrite with `accept` to install and use the image.                                                                                                                                                                                      | `not accepted`                                                 |
| `arch`                             | Supported architecture. Only amd64 is supported                                                                                                                                                                                                                                           | `amd64`                                                        |
| `replicaCount`                     | Number of deployment replicas. Ignored when `autoscaling.enabled` set to `true`                                                                                                                                                                                                           | `1`                                                            |
| `global.image.secretName`          | Name of the Secret containing the Docker Config to pull image from a private repository. Leave blank if the probe image already exists in the local image repository or the Service Account has been assigned with an Image Pull Secret.                                                  | `nil`                                                          |
| `image.repository`                 | Probe image repository. Update this repository name to pull from a private image repository. The image name should be set to `netcool-probe-syslogd`.                                                                                                                                     | `netcool-probe-syslogd`                                        |
| `image.tag`                        | The `netcool-probe-syslogd` image tag                                                                                                                                                                                                                                                     | `5.0.3_4`                                                      |
| `image.testRepository`             | Utility image repository. Update this repository name to pull the test image from a private image repository. The test image name should be set to `busybox`.                                                                                                                             | `busybox`                                                      |
| `image.testImageTag`               | Utility image image tag.                                                                                                                                                                                                                                                                  | `1.28.4`                                                       |
| `image.pullPolicy`                 | Image pull policy                                                                                                                                                                                                                                                                         | Set to `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `netcool.primaryServer`            | The primary Netcool/OMNIbus server the probe should connect to (required). Usually set to NCOMS or AGG_P.                                                                                                                                                                                 | `nil`                                                          |
| `netcool.primaryHost`              | The host of the primary Netcool/OMNIbus server (required). Specify the  Object Server Hostname or IP address.                                                                                                                                                                             | `nil`                                                          |
| `netcool.primaryPort`              | The port number of the primary Netcool/OMNIbus server (required).                                                                                                                                                                                                                         | `nil`                                                          |
| `netcool.backupServer`             | The backup Netcool/OMNIbus server to connect to. If the backupServer, backupHost and backupPort parameters are defined in addition to the primaryServer, primaryHost, and primaryPort parameters, the probe will be configured to connect to a virtual object server pair called `AGG_V`. | `nil`                                                          |
| `netcool.backupHost`               | The host of the backup Netcool/OMNIbus server. Specify the  Object Server Hostname or IP address.                                                                                                                                                                                         | `nil`                                                          |
| `netcool.backupPort`               | The port of the backup Netcool/OMNIbus server.                                                                                                                                                                                                                                            | `nil`                                                          |
| `probe.messageLevel`               | Specify the message logging level.                                                                                                                                                                                                                                                        | `warn`                                                         |
| `probe.rulesFile`                  | Specifies the rules files to use, `standard` or `NCKL` (Netcool Knowledge Library). Defaults to Standard.                                                                                                                                                                                 | `standard`                                                     |
| `probe.readRulesFileTimeout`       | Specify the period (minutes) to checks whether rules file has been modified. If modified, probe re-reads the file.                                                                                                                                                                        | `10`                                                           |
| `probe.whiteSpaces`                | Take note of the **white space** " \\t" before the tab character! To specify the characters that the probe treats as whitespace. _Due to the markdown rendering the white space included might not appear visually_                                                                       | `\t`                                                           |
| `probe.breakCharacters`            | List characters that are used in the FIFO to separate non-quoted tokens.                                                                                                                                                                                                                  | `,=`                                                           |
| `probe.offsetOne`                  | Specify the number of token elements to create.                                                                                                                                                                                                                                           | `20`                                                           |
| `probe.offsetTwo`                  | specify the position (count of tokens) within the syslogd message at which the details section begins.                                                                                                                                                                                    | `6`                                                            |
| `probe.offsetZero`                 | Specify the character position from where the probe should parse the event data.                                                                                                                                                                                                          | `0`                                                            |
| `probe.quoteCharacters`            | Specify the characters that the probe treats as quote marks. Anything contained within matching quote characters is treated as a single token.                                                                                                                                            | `\'\"`                                                         |
| `probe.timeFormat`                 | Specify the timestamp conversion format.                                                                                                                                                                                                                                                  | `%b %d %H:%M:%S`                                               |
| `service.probe.type`               | k8s service type exposing ports, e.g. `NodePort`                                                                                                                                                                                                                                          | `ClusterIP`                                                    |
| `service.probe.externalPort`       | External UDP Port for this service                                                                                                                                                                                                                                                        | `514`                                                          |
| `autoscaling.enabled`              | Set to `false` to disable auto-scaling                                                                                                                                                                                                                                                    | `true`                                                         |
| `autoscaling.minReplicas`          | Minimum number of probe replicas                                                                                                                                                                                                                                                          | `2`                                                            |
| `autoscaling.maxReplicas`          | Maximum number of probe replicas                                                                                                                                                                                                                                                          | `5`                                                            |
| `autoscaling.cpuUtil`              | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods. Eg: Set to 60 for 60% target utilization."                                                                                                                                               | `60`                                                           |
| `poddisruptionbudget.enabled`      | Set to `true` to enable Pod Disruption Budget to maintain high availability during a node maintenance. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control enabled.                                                       | `false`                                                        |
| `poddisruptionbudget.minAvailable` | The minimum number of available pods during node drain. Can be set to a number or percentage, eg: 1 or 10%. Caution: Setting to 100% or equal to the number of replicas may block node drains entirely.                                                                                   | `1`                                                            |
| `resources.requests.memory`        | Memory resource requests                                                                                                                                                                                                                                                                  | `256Mi`                                                        |
| `resources.requests.cpu`           | CPU resource requests                                                                                                                                                                                                                                                                     | `250m`                                                         |
| `resources.limits.memory`          | Memory resource limits                                                                                                                                                                                                                                                                    | `512Mi`                                                        |
| `resources.limits.cpu`             | CPU resource limits                                                                                                                                                                                                                                                                       | `500m`                                                         |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example `helm install --tls --namespace <namespace> --name my-probe --set license=accept,probe.messageLevel=debug` to set the `license` parameter to `accept` and `probe.messageLevel` to `debug`.


## Limitations
* Platform limited, only supports `amd64`.
* This probe only supports UDP protocol.
* Validated to run on IBM Cloud Private 3.1.0 and 3.1.1
* Due to a limitation on Kubernetes Ingress resource, additional post-installation step is required in order to receive external TCP/UDP traffic when using ClusterIP service type.
  A Cluster Administrator needs to reconfigure the nginx-ingress-controller with a "static" configuration based on Configmaps
  and restart the ingress controller for the changes to take effect.
  **CAUTION:** Restarting the ingress controller would impact other workloads running. Consider performing the change during a planned downtime
  in production environments. See [Exposing the probe service](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_expose_probe.html) page for more details.
* IBM Tivoli Netcool/OMNIbus Knowledge Library (NcKL) that is package with the chart only supports Cisco and Juniper Networks event sources. For more information about supported event source refer to the link provided in [documentation](#Documentation) section.
* Helm test requires a ClusterIP service which exposes HTTP API for remote administration. This chart will be enhanced to add additional security to this administration API service in the next release.

## Documentation
* [IBM Tivoli Netcool/OMNIbus Syslogd Probe](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/syslogd/wip/concept/syslogd_intro.html)
* [IBM Tivoli Netcool/OMNIbus Syslogd Probe's properties and command line options](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/syslogd/wip/reference/syslogd_props.html)
* [IBM Tivoli Netcool/OMNIbus Common probe properties and command-line options](https://www.ibm.com/support/knowledgecenter/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/probegtwy/reference/omn_prb_commonprobeprops.html)
* [IBM Tivoli Netcool/OMNIbus Knowledge Library - Supported Cisco syslog event sources](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/nckl/wip/reference/nckl_csco_syslg_evnt_srcs.html)
* [IBM Tivoli Netcool/OMNIbus Knowledge Library - Supported Juniper syslog event sources](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/nckl/wip/reference/nckl_jnpr_syslog_evnt_srcs.html)