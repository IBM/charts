# ibm-apiconnect-icp4i-prod

[(IBM API Connect)](https://www.ibm.com/cloud/api-connect) is a market-leading API management solution that enables automated API creation, simple discovery of assets, self-service access for developers, and built-in security and governance.

## Introduction

This chart installs an `IBM API Connect` cluster, consisting of up to four subsystems: Management, Analytics, Portal, and Gateway.

## Chart Details

The standard deployment consists of five sub-releases: one for each of the four subsystems, plus the cassandra operator.

## Prerequisites

- PersistentVolume requirements - A StorageClass object that supports dynamic PersistentVolume provisioning; Block storage is required
- Helm TLS Secret - A secret for Helm TLS Certificates
- IBM platform core services - `auth-idp`, `catalog-ui`, `helm-api`, `icp-management-ingress`, `nginx-ingress`, `platform-ui`, `tiller`

For more details, refer to the [API Connect Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSMNED_2018/com.ibm.apic.install.doc/installing_icp.html).

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-anyuid-hostpath-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy allows pods to run with 
          any UID and GID and any volume, including the host path.  
          WARNING:  This policy allows hostPath volumes.  
          Use with caution." 
      name: ibm-apiconnect-anyuid-hostpath-psp
    spec:
      allowPrivilegeEscalation: true
      fsGroup:
        rule: RunAsAny
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
      runAsUser:
        rule: RunAsAny
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      volumes:
      - '*'
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      annotations:
      name: ibm-apiconnect-anyuid-hostpath-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-apiconnect-anyuid-hostpath-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-anyuid-hostpath-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      annotations:
        kubernetes.io/description: "This policy allows pods to run with
          any UID and GID and any volume, including the host path.
          WARNING:  This policy allows hostPath volumes.
          Use with caution."
        cloudpak.ibm.com/version: "1.0.0"
      name: ibm-apiconnect-anyuid-hostpath-scc
    allowHostDirVolumePlugin: true
    allowHostIPC: false
    allowHostNetwork: false
    allowHostPID: false
    allowHostPorts: false
    allowPrivilegedContainer: false
    allowPrivilegeEscalation: true
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
    allowedFlexVolumes: []
    allowedUnsafeSysctls: []
    defaultAddCapabilities: []
    defaultPrivilegeEscalation: true
    forbiddenSysctls:
      - "*"
    fsGroup:
      type: RunAsAny
    readOnlyRootFilesystem: false
    requiredDropCapabilities:
    - MKNOD
    runAsUser:
      type: RunAsAny
    seLinuxContext:
      type: RunAsAny
    supplementalGroups:
      type: RunAsAny
    volumes:
    - '*'
    users: []
    priority: 0
    ```

### Configuration Requirements for Non-Cluster-Admin Role

Installation of this chart using the default RBAC and Service Account resources requires a cluster admin role.  If these resources are created prior to installation by a user with a cluster admin role, this chart can be installed by a user with a team operator role.

A user with a cluster admin role can update the following files in the pak_extension pre-install directory and execute `kubectl create -f <file>` for each to create the required resources.

- `crds.yaml` - CustomResourceDefinition resources used by API Connect Operator and Cassandra Operator
- `rbac.yaml` - ClusterRole, ClusterRoleBinding, Role, and RoleBinding resources required to install API Connect
- `service-account.yaml` - ServiceAccount resource used in above ClusterRoleBinding and RoleBinding resources

A user with a team operator role can set the following during installation to use the above resources once they have been created.

- `global.createCRDs=false`
- `operator.serviceAccount.create=false`
- `operator.serviceAccount.name=ibm-apiconnect-sa`

## Resources Required

The operator in this chart requires the following resources:
```
limits:
  cpu: 100m
  memory: 128Mi
requests:
  cpu: 100m
  memory: 128Mi
```

Refer to the [IBM® API Connect Version 2018 Detailed System Requirements](https://www.ibm.com/software/reports/compatibility/clarity-reports/report/html/softwareReqsForProduct?deliverableId=B1ED0870B82D11E7A229E0F52AF6E722) report for subsystem requirements.

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release ibm-apiconnect-icp4i-prod --tls
```

The command deploys <ibm-apiconnect-icp4i-prod> on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list --tls`

Grafana dashboards for API Connect and DataPower are automatically loaded during the chart installation. In order to see these dashboards, the grafana organization must be set to match the namespace where API Connect was installed.

## Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  It may also be necessary to clean up any orphaned components remaining after deletion.

For example :
When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
```

## Configuration

| Parameter                           | Description                                                                                                              | Default         |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------------- |
| `productionDeployment`              | Indicates that chart will be installed to run with production workloads                                                  | `true`          |
| `cloudAdministratorUsername`        | Username of IBM Cloud Private user to set as API Connect Cloud Manager admin                                             | `admin`         |
| `cloudIntegrationPlatformNamespace` | Namespace in which Cloud Integration Platform is installed                                                               | `integration`   |
| `clusterDomainSuffix`               | Cluster DNS search domain suffux                                                                                         | `cluster.local` |

### Global configuration

| Parameter               | Description                                                    | Default    |
| ----------------------- | -------------------------------------------------------------- | ---------- |
| `global.registry`       | Registry containing `IBM API Connect` images                   |            |
| `global.registrySecret` | Image pull secret for registry                                 |            |
| `global.storageClass`   | Storage class object name                                      |            |
| `global.createCrds`     | Create CRD's during installation (requires cluster admin role) | `true`     |
| `global.mode`           | Deployment mode (dev or standard)                              | `standard` |
| `global.certSecret`     | (Optional) Secret containing custom or existing common certs   |            |
| `global.routingType`    | Ingress type to use (OpenShift Route or Kubernetes Ingress)    |            |

### Operator configuration

| Parameter                | Description                                                              | Default               |
| ------------------------ | ------------------------------------------------------------------------ | --------------------- |
| `operator.arch`          | Architecture scheduling preferences for API Connect operator             | `amd64`               |
| `operator.image`         | Relative path to API Connect operator image                              | `apiconnect-operator` |
| `operator.tag`           | IBM API Connect operator image tag                                       |                       |
| `operator.pullpolicy`    | API Connect operator image pull policy                                   | `IfNotPresent`        |
| `operator.helmTlsSecret` | Secret with items for base64-encoded helm key.pem, cert.pem, and ca.pem  |                       |

### Management subsystem configuration

| Parameter                         | Description                                                     | Default       |
| --------------------------------- | --------------------------------------------------------------- | ------------- |
| `management.enabled`              | Enable installation of management subsystem                     | `true`        |
| `management.name`                 | Management subsystem name                                       | `management`  |
| `management.certSecret`           | (Optional) Secret containing custom or existing subsystem certs |               |
| `management.storageClass`         | (Optional) Storage class override for management subsystem      |               |
| `management.apiManagerUiEndpoint` | FQDN of API manager UI endpoint                                 |               |
| `management.cloudAdminUiEndpoint` | FQDN of Cloud admin endpoint                                    |               |
| `management.consumerApiEndpoint`  | FQDN of consumer API endpoint                                   |               |
| `management.platformApiEndpoint`  | FQDN of platform API endpoint                                   |               |

### Cassandra cluster configuration

| Parameter                         | Description                                  | Default |
| --------------------------------- | -------------------------------------------- | ------- |
| `cassandra.cassandraClusterSize`  | Size of management DB cluster (min 3 for HA) | `3`     |
| `cassandra.cassandraMaxMemoryGb`  | Memory limit for DB                          | `9`     |
| `cassandra.cassandraVolumeSizeGb` | Size of DB storage volume (not resizable)    | `50`    |

### Cassandra backup configuration

| Parameter                                 | Description                                                                      | Default   |
| ----------------------------------------- | -------------------------------------------------------------------------------- | --------- |
| `cassandraBackup.cassandraBackupAuthUser` | (Optional) Server username for DB backups                                        |           |
| `cassandraBackup.cassandraBackupAuthPass` | [WARNING] This field is immutable; passwords must be set by post-install actions |           |
| `cassandraBackup.cassandraBackupHost`     | (Optional) FQDN for DB backups server                                            |           |
| `cassandraBackup.cassandraBackupPath`     | (Optional) path for DB backups server                                            | /backups  |
| `cassandraBackup.cassandraBackupPort`     | (Optional) Server port for DB backups                                            | 22        |
| `cassandraBackup.cassandraBackupProtocol` | (Optional) Protocol for DB backups (sftp/ftp/objstore)                           | sftp      |
| `cassandraBackup.cassandraBackupSchedule` | (Optional) Cron schedule for DB backups                                          | 0 0 * * * |

### Cassandra postmortems configuration

| Parameter                                           | Description                                                                      | Default                  |
| --------------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------ |
| `cassandraPostmortems.cassandraPostmortemsAuthUser` | (Optional) Server username for DB metrics server                                 |                          |
| `cassandraPostmortems.cassandraPostmortemsAuthPass` | [WARNING] This field is immutable; passwords must be set by post-install actions |                          |
| `cassandraPostmortems.cassandraPostmortemsHost`     | (Optional) FQDN for DB metrics server                                            |                          |
| `cassandraPostmortems.cassandraPostmortemsPath`     | (Optional) path for DB metrics server                                            | `/cassandra-postmortems` |
| `cassandraPostmortems.cassandraPostmortemsPort`     | (Optional) Server port for DB metrics                                            | `22`                     |
| `cassandraPostmortems.cassandraPostmortemsSchedule` | (Optional) Cron schedule for DB metrics                                          | `0 0 * * *`              |

### Portal subsystem configuration

| Parameter                       | Description                                                   | Default  |
| ------------------------------- | ------------------------------------------------------------- | -------- |
| `portal.enabled`                | Enable the portal subsystem                                   | `true`   |
| `portal.name`                   | Portal subsystem name                                         | `portal` |
| `portal.certSecret`             | (Optional) Secret containing custom or existing portal certs  |          |
| `portal.storageClass`           | (Optional) Storage class override for portal subsystem        |          |
| `portal.portalDirectorEndpoint` | FQDN of Portal admin endpoint                                 |          |
| `portal.portalWebEndpoint`      | FQDN of Portal web endpoint                                   |          |
| `portal.adminStorageSizeGb`     | Size of admin storage volume                                  | `1`      |
| `portal.backupStorageSizeGb`    | Size of backup data storage volume                            | `5`      |
| `portal.dbLogsStorageSizeGb`    | Size of DB logs storage volume                                | `2`      |
| `portal.dbStorageSizeGb`        | Size of DB storage volume                                     | `12`     |
| `portal.wwwStorageSizeGb`       | Size of Site data storage volume                              | `5`      |

### Portal backup configuration

| Parameter                          | Description                                                                      | Default     |
| ---------------------------------- | -------------------------------------------------------------------------------- | ----------- |
| `portalBackup.siteBackupAuthUser`  | (Optional) Server username for portal backups                                    |             |
| `portalBackup.siteBackupAuthPass`  | [WARNING] This field is immutable; passwords must be set by post-install actions |             |
| `portalBackup.siteBackupHost`      | (Optional) FQDN for portal backups server                                        |             |
| `portalBackup.siteBackupPath`      | (Optional) Path for portal backups                                               | `/backups`  |
| `portalBackup.siteBackupPort`      | (Optional) port for portal backups server                                        | `22`        |
| `portalBackup.siteBackupProtocol`  | (Optional) Protocol for portal backups (sftp/ftp/objstore)                       | `sftp`.     |
| `portalBackup.siteBackupSchedule`  | (Optional) Cron schedule for portal backups                                      | `0 2 * * *` |


### Analytics subsystem configuration

| Parameter                              | Description                                                     | Default     |
| -------------------------------------- | --------------------------------------------------------------- | ----------- |
| `analytics.enabled`                    | Enable the analytics subsystem                                  | `true`      |
| `analytics.name`                       | Analytics subsystem name                                        | `analytics` |
| `analytics.certSecret`                 | (Optional) Secret containing custom or existing analytics certs |             |
| `analytics.storageClass`               | (Optional) Storage class override for analytics subsystem       |             |
| `analytics.esStorageClass`             | (Optional) Storage class override for ES                        |             |
| `analytics.enableMessageQueue`         | (Optional) Enable Analytics Message Queue Service               | `false`     |
| `analytics.mqStorageClass`             | (Optional) Storage class override for Message Queue             |             |
| `analytics.analyticsClientEndpoint`    | FQDN of Analytics client/UI endpoint                            |             |
| `analytics.analyticsIngestionEndpoint` | FQDN of Analytics ingestion endpoint                            |             |
| `analytics.coordinatingMaxMemoryGb`    | Memory limit for ES coordinating nodes                          | `12`        |
| `analytics.dataMaxMemoryGb`            | Memory limit for ES data nodes                                  | `12`        |
| `analytics.dataStorageSizeGb`          | Size of data storage volume                                     | `200`       |
| `analytics.masterMaxMemoryGb`          | Memory limit for ES master nodes                                | `12`        |
| `analytics.masterStorageSizeGb`        | Size of master storage volume                                   | `5`         |

### Gateway subsystem configuration

| Parameter                                      | Description                                                                       | Default        |
| ---------------------------------------------- | --------------------------------------------------------------------------------- | -------------- |
| `gateway.enabled`                              | Enable the Gateway subsystem                                                      | `true`         |
| `gateway.name`                                 | Gateway subsystem name                                                            | `gateway`      |
| `gateway.certSecret`                           | (Optional) Secret containing custom or existing gateway certs                     |                |
| `gateway.storageClass`                         | (Optional) Storage class override for gateway subsystem                           |                |
| `gateway.apiGatewayEndpoint`                   | FQDN of API Gateway traffic                                                       |                |
| `gateway.gatewayServiceEndpoint`               | FQDN of API Gateway management API                                                |                |
| `gateway.replicaCount`                         | Number of gateway replicas                                                        | `3`            |
| `gateway.maxCpu`                               | CPU usage limit                                                                   | `4`            |
| `gateway.maxMemoryGb`                          | Memory limit                                                                      | `6`            |
| `gateway.v5CompatibilityMode`                  | Run V5 gateway                                                                    | `true`         |
| `gateway.enableTms`                            | Enable token management system                                                    | `false`        |
| `gateway.tmsPeeringStorageSizeGb`              | Size of token management system storage volume                                    | `10`           |
| `gateway.highPerformancePeering`               | [WARNING]: Enabling this will incur a service disruption for existing deployments |                |
| `gateway.image`                                | Gateway image                                                                     |                |
| `gateway.imageTag`                             | Docker tag for gateway image                                                      |                |
| `gateway.monitoringImage`                      | Gateway monitoring image                                                          |                |
| `gateway.monitoringImageTag`                   | Docker image tag for gateway monitoring image                                     |                |
| `gateway.odTracing.enabled`                    | Enable IBM Cloud Pak For Integration Operations Dashboard                         | `false`        |
| `gateway.odTracing.odManagerNamespace`         | Namespace where the Operations Dashboard is running                               | `tracing`      |
| `gateway.odTracing.odAgentImage          `     | OD agent image                                                                    |                |
| `gateway.odTracing.odAgentImageTag`            | Docker image tag for OD agent                                                     |                |
| `gateway.odTracing.odCollectorImage`           | OD collector image                                                                |                |
| `gateway.odTracing.odCollectorImageTag`        | Docker image tag for OD collector                                                 |                |
| `gateway.imagePullPolicy`                      | Docker image pull policy for gateway images (Always/IfNotPresent)                 | `IfNotPresent` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

> **Tip**: You can use the default values.yaml

## Limitations

Installation of this chart using the default RBAC and Service Account values requires a cluster admin role.

## Documentation

Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSMNED_2018/com.ibm.apic.cmc.doc/con_cmc_overview.html).
