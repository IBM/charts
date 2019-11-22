# IBM Tivoli Netcool/OMNIbus SNMP Probe Helm Chart

This helm chart deploys IBM Tivoli Netcool/OMNIbus SNMP Probe onto Kubernetes. This probe processes SNMP notifications or traps from
managed devices or SNMP agents to a Netcool Operations Insight operational dashboard.

## Introduction

IBM® Netcool® Operations Insight enables IT and network operations teams to increase effectiveness, efficiency
and reliability by leveraging cognitive analytics capabilities to identify, isolate and resolve problems before
they impact your business. It provides a consolidated view across your local, cloud and hybrid environments and
delivers actionable insight into the health and performance of services and their associated dynamic network and
IT infrastructures. More information can be seen here: [IBM Marketplace - IT Operations Management](https://www.ibm.com/uk-en/marketplace/it-operations-management)

## Chart Details

- Deploys Tivoli Netcool/OMNIbus SNMP probe onto Kubernetes to receive SNMP notifications or traps.
- The probe deployment is fronted by a service.
- This chart can be deployed more than once on the same namespace.

## Prerequisites

- Kubernetes 1.11.1.
- Tiller 2.9.1.

- This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe. To create and run the IBM Tivoli Netcool/OMNIbus ObjectServer, see installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).

- Netcool Knowledge Library (NcKL) Intra-Device correlation automation is installed and enabled. More info to install this manually on on-premise Object Server is outlined [here](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/nckl/wip/reference/nckl_cnf_obj_intrdvc.html). This automation creates the following objects in the Object Server to aid in determining the causal relevance of events:
  - Intra-device correlation (AdvCorr) tables within the alerts database
  - Supplementary automations implemented as an AdvCorr trigger group and three related triggers
  - Additional columns in the alerts.status table
- Operator role is the minimum role required to install this chart.
  - Administrator role is required in order to:
    - Enable Pod Disruption Budget policy when installing the chart.
    - Retrieve sensitive information from a secret such as SNMP v3 Users data.
  - The chart must be installed by a Cluster Administrator to perform the following tasks in addition to those listed above:
    - Obtain the Node IP using `kubectl get nodes` command if using the NodePort service type.
    - Create a new namespace with custom PodSecurityPolicy if necessary. See PodSecurityPolicy Requirements [section](#podsecuritypolicy-requirements) for more details.

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
      name: ibm-netcool-probe-snmp-prod-psp
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
      name: ibm-netcool-probe-snmp-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-netcool-probe-snmp-prod-psp
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
      name: ibm-netcool-probe-snmp-prod-rolebinding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ibm-netcool-probe-snmp-prod-clusterrole
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


## Installing the Chart

1. Extract the helm chart archive and customize the `values.yaml`. The [configuration](#configuration) section lists the parameters that can be configured during installation.

2. The command below shows how to install the chart with the release name `my-snmp-probe` using the configuration specified in the customized `values.yaml`. Helm searches the `ibm-netcool-probe-snmp-prod` chart in the helm repository called `stable`. This assumes that the chart exists in the `stable` repository.

  ```sh
  helm install --namespace <your pre-created namespace> --name my-snmp-probe -f values.yaml stable/ibm-netcool-probe-snmp-prod --tls
  ```

> **Tip**: List all releases using `helm list --tls` or search for a chart using `helm search`.

### Verifying the Chart

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release> --tls`.

### Uninstalling the Chart

To uninstall/delete the `my-snmp-probe` deployment:

```sh
helm delete my-snmp-probe --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Clean up any prerequisites that were created

As a Cluster Administrator, run the cluster administration clean up script included under pak_extensions to clean up cluster scoped resources when appropriate.

- post-delete/clusterAdministration/deleteSecurityClusterPrereqs.sh

As a Cluster Administrator, run the namespace administration clean up script included under pak_extensions to clean up namespace scoped resources when appropriate.

- post-delete/namespaceAdministration/deleteSecurityNamespacePrereqs.sh


## Configuration

The following tables lists the configurable parameters of the `ibm-netcool-probe-snmp-prod` chart and their default values.

| Parameter                                        | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Default                                                        |
|--------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|
| `license`                                        | The license state of the image being deployed. Enter `accept` to install and use the image.                                                                                                                                                                                                                                                                                                                                                                        | `not accepted`                                                 |
| `replicaCount`                                   | Number of deployment replicas. Omitted when `autoscaling.enabled` set to `true`                                                                                                                                                                                                                                                                                                                                                                                    | `1`                                                            |
| `global.image.secretName`                        | Name of the Secret containing the Docker Config to pull image from a private repository. Leave blank if the probe image already exists in the local image repository or the Service Account has been assigned with an Image Pull Secret.                                                                                                                                                                                                                           | `nil`                                                          |
| `image.repository`                               | Probe image repository. Update this repository name to pull from a private image repository. See default value as example. The image name should be set to `netcool-probe-snmp`.                                                                                                                                                                                                                                                                                   | `netcool-probe-snmp`                                           |
| `image.tag`                                      | The `netcool-probe-snmp` image tag                                                                                                                                                                                                                                                                                                                                                                                                                                 | `20.2.0_4`                                                     |
| `image.testRepository`                           | Utility image repository. Update this repository name to pull the test image from a private image repository. The test image name should be set to `busybox`.                                                                                                                                                                                                                                                                                                      | `busybox`                                                      |
| `image.testImageTag`                             | Utility image tag.                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `1.28.4`                                                       |
| `image.pullPolicy`                               | Image pull policy                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Set to `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `netcool.primaryServer`                          | The primary Netcool/OMNIbus server the probe should connect to (required). Usually set to NCOMS or AGG_P.                                                                                                                                                                                                                                                                                                                                                          | `nil`                                                          |
| `netcool.primaryHost`                            | The host of the primary Netcool/OMNIbus server (required). Specify the  Object Server Hostname or IP address.                                                                                                                                                                                                                                                                                                                                                      | `nil`                                                          |
| `netcool.primaryPort`                            | The port number of the primary Netcool/OMNIbus server (required).                                                                                                                                                                                                                                                                                                                                                                                                  | `nil`                                                          |
| `netcool.backupServer`                           | The backup Netcool/OMNIbus server to connect to. If the backupServer, backupHost and backupPort parameters are defined in addition to the primaryServer, primaryHost, and primaryPort parameters, the probe will be configured to connect to a virtual object server pair called `AGG_V`.                                                                                                                                                                          | `nil`                                                          |
| `netcool.backupHost`                             | The host of the backup Netcool/OMNIbus server. Specify the  Object Server Hostname or IP address.                                                                                                                                                                                                                                                                                                                                                                  | `nil`                                                          |
| `netcool.backupPort`                             | The port of the backup Netcool/OMNIbus server.                                                                                                                                                                                                                                                                                                                                                                                                                     | `nil`                                                          |
| `probe.messageLevel`                             | Probe log message level.                                                                                                                                                                                                                                                                                                                                                                                                                                           | `warn`                                                         |
| `probe.rulesFile`                                | Probe rules file to use. Default is `Standard`, set to `NCKL` to use Netcool Knowledge Library Rules Files pre-installed in the `netcool-probe-snmp` image.                                                                                                                                                                                                                                                                                                        | `Standard`                                                     |
| `probe.snmpv3.snmpConfigChangeDetectionInterval` | Specifies the frequency (in minutes) between 0 to 10080 to check for `mttrapd.conf` configuration changes. Set to `0` to disable automatic detection and loading.                                                                                                                                                                                                                                                                                                  | `1`                                                            |
| `probe.snmpv3.snmpv3Only`                        | Set to `true` to only processes SNMPv3 traps and informs. This allows you to limit event processing. Otherwise, set to `false` (default) to process SNMP v1, v2 and v3. More info on SNMP V3 support, see [documentation](#documentation) section                                                                                                                                                                                                                  | `false`                                                        |
| `probe.snmpv3.reuseEngineBoots`                  | Specifies whether the probe reuses the engine ID and the number of SNMP engine boots specified in the mttrapd.conf file. Set to `true`  (default) to reuse the engine ID and number of SNMP boots. Otherwise, specify `false` to not reuse.                                                                                                                                                                                                                        | `true`                                                         |
| `probe.snmpv3.usmUserBase`                       | Specifies whether the probe reads the `mttrapd.conf` file in the directory specified by the PeristentDir property or the ConfPath property or both of those directories. Set to `2` (default) to use both files, set to `1` to only use the file in PersistenDir diectory, or set to `0` to only use the file in ConfPath directory.                                                                                                                               | `2`                                                            |
| `probe.snmpv3.snmpv3MinSecurityLevel`            | Specifies which SNMPv3 traps the SNMP Probe processes. By default the probe processes SNMPv3 traps of all security levels. Set to `1`  (default) to The probe processes SNMP V3 Traps/Inform PDUs of security level NoAuth, AuthNoPriv, or AuthPriv, set to `2` to process SNMP V3 Traps/Inform PDUs of security level AuthNoPriv or AuthPriv, or set to `3` to process SNMP V3 Traps/Inform PDUs of security level AuthPriv. Otherwise, specify `0` to not reuse. | `1`                                                            |
| `probe.snmpv3.secretName`                        | Name of the existing (pre-created) secret containing an encoded list of USM user configuration. Leave unset to create a new secret with the user settings configured in `probe.snmpv3.users`. See below for more [details](#snmp-v3-security-user-configuration). Default is an empty list.                                                                                                                                                                        | `nil`                                                          |
| `probe.snmpv3.users`                             | A list of security users for SNMP v3. Ignored if `probe.snmpv3.secretName` is set. See below for more [details](#snmp-v3-security-user-configuration). Default is an empty list.                                                                                                                                                                                                                                                                                   | `[]`                                                           |
| `service.probe.type`                             | SNMP Probe k8 service type exposing ports, e.g. `ClusterIP` or `NodePort`.                                                                                                                                                                                                                                                                                                                                                                                         | `ClusterIP`                                                    |
| `service.probe.externalPort`                     | External TCP and UDP Port for this service                                                                                                                                                                                                                                                                                                                                                                                                                         | `162`                                                          |
| `autoscaling.enabled`                            | Set to `false` to disable auto-scaling                                                                                                                                                                                                                                                                                                                                                                                                                             | true                                                           |
| `autoscaling.minReplicas`                        | Minimum number of probe replicas                                                                                                                                                                                                                                                                                                                                                                                                                                   | `2`                                                            |
| `autoscaling.maxReplicas`                        | Maximum number of probe replicas                                                                                                                                                                                                                                                                                                                                                                                                                                   | `5`                                                            |
| `autoscaling.cpuUtil`                            | The target CPU utilization (in percentage). Example: `60` for 60% target utilization.                                                                                                                                                                                                                                                                                                                                                                              | `60`                                                           |
| `poddisruptionbudget.enabled`                    | Set to `true` to enable Pod Disruption Budget to maintain high availability during a node maintenance. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control enabled.                                                                                                                                                                                                                                | `false`                                                        |
| `poddisruptionbudget.minAvailable`               | The minimum number of available pods during node drain. Can be set to a number or percentage, eg: 1 or 10%. Caution: Setting to 100% or equal to the number of replicas may block node drains entirely.                                                                                                                                                                                                                                                            | `1`                                                            |
| `resources.limits.memory`                        | Memory resource limits                                                                                                                                                                                                                                                                                                                                                                                                                                             | `512Mi`                                                        |
| `resources.limits.cpu`                           | CPU resource limits                                                                                                                                                                                                                                                                                                                                                                                                                                                | `500m`                                                         |
| `resources.requests.cpu`                         | CPU resource requests                                                                                                                                                                                                                                                                                                                                                                                                                                              | `250m`                                                         |
| `resources.requests.memory`                      | Memory resource requests                                                                                                                                                                                                                                                                                                                                                                                                                                           | `256Mi`                                                        |
| `arch`                                           | Worker node architecture. Fixed to `amd64`.                                                                                                                                                                                                                                                                                                                                                                                                                        | `amd64`                                                        |
You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install` to override any of the parameter value from the command line. For example `helm install --tls --namespace <namespace> --name my-snmp-probe --set license=accept,probe.messageLevel=debug` to set the `license` parameter to `accept` and `probe.messageLevel` to `debug`.

## SNMP V3 Security User Configuration

An administrator can create a secret prior installing the chart. The chart can then be configured to use this existing secret by specifying the secret name in `probe.snmpv3.secretName` parameter. Steps to create a secret is shown in [Creating a Secret with SNMP v3 Users data](#creating-a-secret-with-snmp-v3-users-data) section below.

To create a new secret automatically during chart installation, leave the `probe.snmpv3.secretName` unset and follow the details below on how to set the `probe.snmpv3.users` parameter to specify a list of SNMP V3 users.

The SNMP V3 User object consists of the following parameters:

| Parameter                   | Description                                                                                                                       | Example        |
|-----------------------------|-----------------------------------------------------------------------------------------------------------------------------------|----------------|
| `name`                      | The security user name                                                                                                            | `netcoolTrap`  |
| `authEncryptionMethod`      | The authentication type (MD5, SHA, or SHA256). When running in FIPS 140-2 mode, use the value SHA for this option.                | `MD5`          |
| `authEncryptionPassword`    | The authentication password (must be at least eight characters).                                                                  | `tr4psMD5`     |
| `privacyEncryptionMethod`   | (Optional) The type of privacy (either DES or AES). When running the probe in FIPS 140-2 mode, use the value AES for this option. | `DES`          |
| `privacyEncryptionPassword` | (Optional) The Provide the privacy password.                                                                                      | `tr4psDES`     |
| `authEngineIdentifier`      | The engine ID of the trap source associated with the user. The engine ID is required for traps but optional for informs.          | `0x0102030405` |

The user value for the example settings above is shown below and should be set to the `probe.snmpv3.users` parameter and `probe.snmpv3.secretName` unset to enable them. 

For UI installation, set the `SNMP V3 Users` parameter value to:

```yaml
- name: netcoolTrap
  authEncryptionMethod: MD5
  authEncryptionPassword: tr4psMD5
  privacyEncryptionMethod: DES
  privacyEncryptionPassword: tr4psDES
  authEngineIdentifier: '0x0102030405'
```

An example single user configuration using `values.yaml` for CLI installation is shown below:

```yaml
probe:
  snmpv3:
    enabled: true
    users:
      - name: netcoolTrap
        authEncryptionMethod: "MD5"
        authEncryptionPassword: "tr4psMD5"
        privacyEncryptionMethod: "DES"
        privacyEncryptionPassword: "tr4psDES"
        authEngineIdentifier: "0x0102030405"
```


Add more user entries to add more security users. Example below shows two security users `netcoolTrap` and `netcoolInforms`. 

For UI installation, set the `SNMP V3 Users` parameter value to:

```yaml
- name: netcoolTrap
  authEncryptionMethod: MD5
  authEncryptionPassword: tr4psMD5
  privacyEncryptionMethod: DES
  privacyEncryptionPassword: tr4psDES
  authEngineIdentifier: '0x0102030405'
- name: netcoolInform
  authEncryptionMethod: MD5
  authEncryptionPassword: 1nformsMD5
  privacyEncryptionMethod: DES
  privacyEncryptionPassword: 1nformsDES
  authEngineIdentifier: ''
```

An example multi-user configuration using `values.yaml` for CLI installation is shown below:

```yaml
probe:
  snmpv3:
    enabled: true
    users:
      - name: netcoolTrap
        authEncryptionMethod: "MD5"
        authEncryptionPassword: "tr4psMD5"
        privacyEncryptionMethod: "DES"
        privacyEncryptionPassword: "tr4psDES"
        authEngineIdentifier: "0x0102030405"
      - name: netcoolInform
        authEncryptionMethod: "MD5"
        authEncryptionPassword: "1nformsMD5"
        privacyEncryptionMethod: "DES"
        privacyEncryptionPassword: "1nformsDES"
```

## Creating a Secret with SNMP v3 Users data

This section shows how to create a secret with the sample SNMP V3 user settings (specified in JSON) below. This setting contains two users `netcoolTrap` and `netcoolInform`, which is the same as the example in [SNMP V3 Security User Configuration](#snmp-v3-security-user-configuration).

```yaml
- name: netcoolTrap
  authEncryptionMethod: MD5
  authEncryptionPassword: tr4psMD5
  privacyEncryptionMethod: DES
  privacyEncryptionPassword: tr4psDES
  authEngineIdentifier: '0x0102030405'
- name: netcoolInform
  authEncryptionMethod: MD5
  authEncryptionPassword: 1nformsMD5
  privacyEncryptionMethod: DES
  privacyEncryptionPassword: 1nformsDES
  authEngineIdentifier: ''
```

1. For the user setting above, the entries that needs to be used is shown below. Save these entries in a file.

  ```generic
  createUser -e 0x0102030405 netcoolTrap MD5 tr4psMD5 DES tr4psDES
  createUser netcoolInform MD5 1nformsMD5 DES 1nformsDES
  ```

2. Save the above entries into a file called `users.txt`.

  ```sh
  $ cat <<EOF >> users.txt
  > createUser -e 0x0102030405 netcoolTrap MD5 tr4psMD5 DES tr4psDES
  > createUser netcoolInform MD5 1nformsMD5 DES 1nformsDES
  > EOF

  $ cat users.txt
  createUser -e 0x0102030405 netcoolTrap MD5 tr4psMD5 DES tr4psDES
  createUser netcoolInform MD5 1nformsMD5 DES 1nformsDES
  ```

3. Encode the contents of `users.txt` using Base64 encoding. **Note:** When using the base64 utility on Darwin/macOS users should avoid using the -b option to split long lines. Conversely Linux users should add the option -w 0 to base64 commands or the pipeline base64 | tr -d '\n' if -w option is not available.

  ```sh
  $ base64 users.txt
  Y3JlYXRlVXNlciAtZSAweDAxMDIwMzA0MDUgbmV0Y29vbFRyYXAgTUQ1IHRyNHBzTUQ1IERFUyB0cjRwc0RFUwpjcmVhdGVVc2VyIG5ldGNvb2xJbmZvcm0gTUQ1IDFuZm9ybXNNRDUgREVTIDFuZm9ybXNERVMK
  ```

4. Then insert the base64 encoded string into a `secret.yaml` file with `mttrapd.conf` as the key as shown below. This file will create a new Kubernetes secret with the called `my-snmp-probe-snmpv3-users`

  ```yaml
  # Secrets created separately from the release
  apiVersion: v1
  kind: Secret
  metadata:
    name: my-snmp-probe-snmpv3-users
  type: Opaque
  data:
    mttrapd.conf : Y3JlYXRlVXNlciAtZSAweDAxMDIwMzA0MDUgbmV0Y29vbFRyYXAgTUQ1IHRyNHBzTUQ1IERFUyB0cjRwc0RFUwpjcmVhdGVVc2VyIG5ldGNvb2xJbmZvcm0gTUQ1IDFuZm9ybXNNRDUgREVTIDFuZm9ybXNERVMK
  ```

5. Use the following command to create the secret on Kubernetes in the `default` namespace and to verify that the secret is created correctly.

```sh
$ kubectl -n default apply -f secret.yaml
secret "my-snmp-probe-snmpv3-users" created

$ kubectl get secrets my-snmp-probe-snmpv3-users --namespace default -o yaml
apiVersion: v1
data:
  mttrapd.conf: Y3JlYXRlVXNlciAtZSAweDAxMDIwMzA0MDUgbmV0Y29vbFRyYXAgTUQ1IHRyNHBzTUQ1IERFUyB0cjRwc0RFUwpjcmVhdGVVc2VyIG5ldGNvb2xJbmZvcm0gTUQ1IDFuZm9ybXNNRDUgREVTIDFuZm9ybXNERVMK
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"mttrapd.conf":"Y3JlYXRlVXNlciAtZSAweDAxMDIwMzA0MDUgbmV0Y29vbFRyYXAgTUQ1IHRyNHBzTUQ1IERFUyB0cjRwc0RFUwpjcmVhdGVVc2VyIG5ldGNvb2xJbmZvcm0gTUQ1IDFuZm9ybXNNRDUgREVTIDFuZm9ybXNERVMK"},"kind":"Secret","metadata":{"annotations":{},"name":"my-snmp-probe-snmpv3-users","namespace":"default"},"type":"Opaque"}
  creationTimestamp: 2018-07-20T03:54:14Z
  name: my-snmp-probe-snmpv3-users
  namespace: default
  resourceVersion: "2520884"
  selfLink: /api/v1/namespaces/default/secrets/my-snmp-probe-snmpv3-users
  uid: 91a034ec-8bd0-11e8-983d-005056a0a011
type: Opaque
```

1. With the secret above created, set the SNMP Probe `probe.snmpv3.secretName` to `my-snmp-probe-snmpv3-users` to use the pre-created secret.

## Limitations

- Only the AMD64 / x86_64 architecture is supported for IBM Tivoli Netcool/OMNIbus SNMP Probe.
- Validated to run on IBM Cloud Private 3.1.0 and 3.1.1.
- The NcKL rules files are pre-built in the `netcool-probe-snmp` image and not customizable.
- Due to a limitation on Kubernetes Ingress resource, additional post-installation step is required in order to receive external TCP/UDP traffic when using ClusterIP service type.
  A Cluster Administrator needs to reconfigure the nginx-ingress-controller with a "static" configuration based on Configmaps
  and restart the ingress controller for the changes to take effect.
  **CAUTION:** Restarting the ingress controller would impact other workloads running. Consider performing the change during a planned downtime
  in production environments. See [Exposing the probe service](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_expose_probe.html) page for more details.

## Documentation

- [IBM Tivoli Netcool/OMNIbus SNMP Probe Helm Chart Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/snmp/wip/concept/snmp_intro.html)
- IBM Tivoli Netcool/OMNIbus SNMP Probe Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/snmp/wip/concept/snmp_introduction_c.html)
  - SNMP v3 Support [page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/snmp/wip/reference/snmp_support_v3_r.html)
- IBM Tivoli Netcool Knowledge Library (NcKL) Knowledge Center [introduction page](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/probes/nckl/wip/reference/nckl_intrdctn.html)

## Troubleshooting

Describes potential issues and resolution steps when deploying the probe chart.

| Problem                                                                                                                                                                                                   | Cause                                                                                                 | Resolution                                                                                       |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| Probe logs shows an error when loading or reading rules file. Failed during field verification check. Fields `CorrScore`,`AdvCorrCauseType`,`CauseType`,`LocalObjRelate`, and `RemoteObjRelate` not found | The NcKL intra-device correlation automation is not installed, hence the required fields are missing. | Install NcKL intra-device correlation automation in your Object Server and re-install the chart. |
