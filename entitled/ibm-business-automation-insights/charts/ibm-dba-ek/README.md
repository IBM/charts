# IBM Cloud Pak for Automation Elasticsearch/Kibana Helm Chart

## Introduction

This Helm chart deploys Elasticsearch and Kibana, including the Open Distro for Elasticsearch security plugin.

## Chart Details

This chart deploys Elasticsearch and Kibana to Kubernetes platforms.

Elasticsearch is deployed through:
 - a [Kubernetes StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) of Elasticsearch data pods. These pods store Elasticsearch shards and each of these pods requires a persistent volume. See [official Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/modules-node.html#data-node) for details.
 - a [Kubernetes StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) of Elasticsearch master-eligible pods. These pods also require a persistent volume to store global data such as index patterns. See [official Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/modules-node.html#master-node) for details.
 - a [Kubernetes deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) of Elasticsearch client pods. These pods expose the Elasticsearch REST API (see [official Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/modules-http.html) for details). The HTTP REST endpoint is protected by the Open Distro for Elasticsearch plugin, which provides HTTPS and basic authentication. These pods do not require a persistent volume. Note that on the data pods and on the master-eligibile pods [the HTTP module is disabled](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/modules-http.html#_disable_http) so that they do not expose the Elasticsearch REST API.
 - a [Kubernetes job](https://kubernetes.io/docs/concepts/workloads/controllers/job/), which initializes the Open Distro for Elasticsearch security plugin. For details, see [Open Distro for Elasticsearch security config](#open-distro-for-elasticsearch-security-config).
 
Kibana is deployed through a [Kubernetes deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/). Kibana pods are secured using standard Kibana settings and Open Distro for Elasticsearch to provide HTTPS and basic authentication.
Elasticsearch resource needs are entirely based on your environment. For helpful information to plan the necessary resources, read the [capacity planning guide](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/manage_metrics/capacity_planning.html).

## Prerequisites

* A Kubernetes cluster, version 1.11.0 or later
* Tiller 2.9.1 or later
* Persistent volumes for long-term storage
* amd64 Kubernetes nodes

## Resources Required

By default, this Helm chart requires the following minimum resources:

| Component | Number of replicas | CPU/pod   | Memory/pod (Gi)|
| --------- | ------------------ | --------- | -------------- |
| Master    | 1*                 | 0.1*      | 1*             |
| Client    | 1*                 | 0.1*      | 1*             |
| Data      | 1*                 | 0.1*      | 1*             |
| Kibana    | 1*                 | 0.1*      | 1*             |



The settings marked with an asterisk (*) can be configured.

The Elasticsearch pods (client, data, and master) require to be run in privileged mode. See the [official Kubernetes documentation](https://kubernetes.io/docs/concepts/workloads/pods/pod/#privileged-mode-for-pod-containers).

## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy resource to be bound to the target namespace before installation. To meet this requirement, you might have to scope a specific cluster and namespace.
The predefined PodSecurityPolicy resource named [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to it, you can proceed to install the chart.

Also, it is required that you also set up the proper PodSecurityPolicy, Role, ServiceAccount, and RoleBinding Kubernetes resources to allow the pods running Elasticsearch to run privileged containers. The reason for this requirement is to meet the [production settings stated officially by the Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.7/system-config.html). To achieve this, you must set up a Custom PodSecurityPolicy definition:

1- Adapt the following YAML content to reference your Kubernetes namespace and Business Automation Insights Helm release name, and save it to a file as `bai-psp.yml`, which sets up the Custom PodSecurityPolicy definition:
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is required to allow ibm-dba-ek pods running Elasticsearch to use privileged containers"
  name: <RELEASE_NAME>-bai-psp
spec:
  privileged: true
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  volumes:
  - '*'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: <RELEASE_NAME>-bai-role
  namespace: <NAMESPACE>
rules:
- apiGroups:
  - extensions
  resourceNames:
  - <RELEASE_NAME>-bai-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: <RELEASE_NAME>-bai-psp-sa  
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: <RELEASE_NAME>-bai-rolebinding
  namespace: <NAMESPACE>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: <RELEASE_NAME>-bai-role
subjects:
- kind: ServiceAccount
  name: <RELEASE_NAME>-bai-psp-sa
  namespace: <NAMESPACE>
```
2- execute:
```bash
kubectl create -f bai-psp.yaml -n <NAMESPACE>
```

This allows pods running Elasticsearch to execute `sysctl` commands to set:
- `max_map_count=262144`
- `vm.swappiness=1`

## Red Hat OpenShift SecurityContextConstraints Requirements

If you are installing the chart on Red Hat OpenShift or OKD, the [ibm-anyuid-scc](https://ibm.biz/cpkspec-scc) SecurityContextConstraint is required to install the chart. 

Also, it is required that you allow the pods running Elasticsearch to run privileged containers. The reason for this requirement is to meet the [production settings stated officially by the Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.7/system-config.html). To achieve this, you must  you must also create a service account that has the [ibm-privileged-scc](https://ibm.biz/cpkspec-scc) SecurityContextConstraint to allow running privileged containers:
```
$ oc create serviceaccount <RELEASE_NAME>-bai-psp-sa
$ oc adm policy add-scc-to-user ibm-privileged-scc -z <RELEASE_NAME>-bai-psp-sa
```

## Storage

### Elasticsearch data persistence

#### Enabling persistence of Elasticsearch data

The *ibm-dba-ek* subchart makes it possible not to use any persistent volume for data pods: set the `elasticsearch.data.storage.persistent` value to `false`. Use this option for a quick setup because it does not require any persistent volume. However, note that as soon as the Elasticsearch data pods is restarted, Elasticsearch data is lost. In most use cases, this practice is discouraged. The typical practice is to set `elasticsearch.data.storage.persistent` to `true` and take care of the prerequired provisioning of persistent volumes.

#### Setting up persistent volumes for Elasticsearch data
A persistent volume for each data and master node is required if no dynamic provisioning is set up. For more information, see IBM Cloud Private documentation at [Setting up dynamic provisioning](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_cluster/cluster_storage.html) and the [official Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). In the current section, `<nfs-shared-path>` is a path that is NFS-shared by the NFS server with IP equals to `<server-ip>`. You must ensure that your Kubernetes nodes have a very fast access to the NFS shared folders, otherwise Elasticsearch REST calls will fail on timeout. Usually, the NFS share is set up on the master node of your Kubernetes cluster. Here is an example.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ibm-bai-ek-pv-1
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  nfs:
    path: <nfs-shared-path>/ibm-bai-ek-pv1
    server: <server-ip>
  persistentVolumeReclaimPolicy: Retain
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ibm-bai-ek-pv-2
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  nfs:
    path: <nfs-shared-path>/ibm-bai-ek-pv2
    server: <server-ip>
  persistentVolumeReclaimPolicy: Retain
```

The persistent volume path must be readable and writable by the `elasticsearch` user and group under ID 1000. It is recommended to use the `Retain` reclaim policy to make sure data is kept on release.

The persistent volume must be accessed in `ReadWriteOnce` access mode.

#### Choosing the proper settings for the Elasticsearch data persistent volumes

The Helm values related to the persistent storage of Elasticsearch data cannot be updated after the initial deployment of the release. Therefore, be very careful with the values you choose, especially for the `elasticsearch.data.storage.size` value, which sets the size of the persistent volumes and defaults to 10Gi.

#### Persistent Volume Claims related to Elasticsearch data pods

When a Helm release is deployed for the first time, with persistence of Elasticsearch data enabled, the Kubernetes StatefulSets deploying the Elasticsearch data and master pods searches for available persistent volumes that match the criteria provided in the values.yaml configuration file (capacity, storage class name, selectors, ...) for each pod, and create the appropriate persistent volume claims. The names of persistent volume claim contain the Helm release name.

If you delete the Helm release, the persistent volume claim remains.

If later on, you redeploy the Helm release with the same release name in the same namespace, Kubernetes reuses the previous persistent volume claims and your previous Elasticsearch data is available again.

If at some point you want to completely delete the release and the persistent data, you must delete the Helm release, and then delete the corresponding persistent volume claims by using the kubectl CLI.

### Elasticsearch snapshots

To be able to use [the snapshot API of Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/modules-snapshots.html), you need to provide a persistent volume that will be used by all master and data pods. You can enable snapshot storage to the persistent volume by defining the values under `elasticsearch.data.snapshotStorage`.  

The persistent volume is locally mounted on pods at the following location: `/mnt/snapshots`

You can enable snapshot storage on an existing Helm release by using the appropriate `helm upgrade` command.

**_Note:_** Never perform a backup of the `.opendistro_security` index. See [the following section](#performing-a-backup-of-the-open-distro-security-configuration) which explains how to perform a backup of the Open Distro security configuration.

## Open Distro for Elasticsearch security configuration

The security of the Elasticsearch cluster deployed by this chart is managed by the [Open distro for Elasticsearch](https://opendistro.github.io/for-elasticsearch-docs/) security plugin v0.9.0.

The Open Distro for Elasticsearch security plugin stores its configuration — including users, roles, and permissions — in an index on the Elasticsearch cluster (`.opendistro_security`). Storing these settings in an index lets you change settings without restarting the cluster and eliminates the need to place configuration files on any node. And after the security config is initialized as you want it to be, you can later use Kibana to change users, roles, and permissions.

### Maintaining users and permissions 

By default, the `ibm-dba-ek` chart amends the Open Distro default configuration: 
- to set the `admin` user password to `passw0rd`
- to create a `demo` user (password:`demo`) which has the `kibanauser` and `readall` roles.

Internally: 
- A Kubernetes secret packages an `internal_users.yml` file which contains the above amendments. 
- A Kubernetes job overwrites the `plugins/opendistro_security/securityconfig/internal_users.yml` default file from Open Distro with the file from the secret and then runs `plugins/opendistro_security/tools/securityadmin.sh` to apply the configuration.

This Kubernetes job is created only if the `security.initOpenDistroConfig` Helm value is set to `true` (default value). Running the job initializes all the security configuration. Therefore, if you have already modified the security configuration by using the Kibana interface and you plan to upgrade the Helm chart deployment, set the `security.initOpenDistroConfig` value to `false` so that you do not lose all the changes you made through the Kibana interface. 

You can also set up your own security configuration instead by providing your Open Distro configuration files packaged in a secret which is referenced as `security.openDistroConfigSecret` Helm value. On all pods running Elasticsearch and on the pod running the job that initializes the security configuration:
 - All files ending with `.yml` that are packaged in this secret are copied to `/usr/share/elasticsearch/plugins/opendistro_security/securityconfig/`.
 - All other files that are packaged in this secret are copied to `/usr/share/elasticsearch/config/security/custom`.

#### Backing up the Open Distro security configuration
You can also back up the current Open Distro security configuration by running `scripts/sync_security_config.sh` from any of the pods running Elasticsearch and package the files in a secret. For example:
```
$ kubectl exec -it <RELEASE_NAME>-ibm-dba-ek-master-0 -- scripts/sync_security_config.sh
```
The above execution updates .yml files in `/usr/share/elasticsearch/plugins/opendistro_security/securityconfig`. Copy all the generated files from the pod to your local environment, and create a Kubernetes secret containing these files as in the following example.
```
$ mkdir odConfig
$ kubectl -n <NAMESPACE> cp <RELEASE_NAME>-ibm-dba-ek-master-0:/usr/share/elasticsearch/plugins/opendistro_security/securityconfig/config.yml ./odConfig/config.yml
$ kubectl -n <NAMESPACE> cp <RELEASE_NAME>-ibm-dba-ek-master-0:/usr/share/elasticsearch/plugins/opendistro_security/securityconfig/roles.yml ./odConfig/roles.yml
$ kubectl -n <NAMESPACE> cp <RELEASE_NAME>-ibm-dba-ek-master-0:/usr/share/elasticsearch/plugins/opendistro_security/securityconfig/roles.yml ./odConfig/roles_mapping.yml
$ kubectl -n <NAMESPACE> cp <RELEASE_NAME>-ibm-dba-ek-master-0:/usr/share/elasticsearch/plugins/opendistro_security/securityconfig/internal_users.yml ./odConfig/internal_users.yml
$ kubectl -n <NAMESPACE> cp <RELEASE_NAME>-ibm-dba-ek-master-0:/usr/share/elasticsearch/plugins/opendistro_security/securityconfig/action_groups.yml ./odConfig/action_groups.yml
$ kubectl -n <NAMESPACE> create secret generic odcfg --from-file ./odConfig
secret "odcfg" created
```
The secret `odcfg` can then be referenced under the `security.openDistroConfigSecret` Helm value. And if the `security.initOpenDistroConfig` Helm value is set to `true`, next time you install or upgrade the Helm release, the Open Distro configuration will be initialized based on the files from the secret.

### Maintaining Kibana security configuration

By default, the `ibm-dba-ek` chart amends the Open Distro default Kibana configuration.

Internally, a Kubernetes secret packages a `kibana.yml` file with 
- appropriate settings to enable or disable Kibana multitenancy feature and ensure connection to the Elasticsearch cluster using the Elasticsearch user credentials.
- readonly mode security roles set to ["kibana_read_only"]
- elasticsearch request headers white lis set to ["securitytenant","Authorization"]

#### Backing up the Open Distro security configuration for Kibana
You can also back up the current Open Distro security configuration for Kibana by running the following commands from the Kibana pod and package the file in a secret. For example:
```sh
$ mkdir odKibanaConfig
$ kubectl -n <NAMESPACE> cp <RELEASE_NAME>-ibm-dba-ek-kibana-<ID>:/usr/share/kibana/config/kibana.yml ./odKibanaConfig
$ kubectl -n <NAMESPACE> create secret generic odkibanacfg --from-file ./odKibanaConfig
secret "odkibanacfg" created
```

The secret `odkibanacfg` can then be referenced under the `security.openDistroKibanaConfigSecret` Helm value. When the release is upgraded, the Kibana configuration is updated regardless of the `security.initOpenDistroConfig` Helm value.

### Certificates

Open Distro uses certificates:
- to use TLS on the transport layer
- to use TLS on the REST layer
- to authenticate the administrators that will be allowed to execute `securityadmin.sh`

By default, the chart uses Open Distro for Elasticsearch demo certificates but you can also provide your own certificates.

The files packaged in the secret referenced as the `security.openDistroConfigSecret` Helm value are processed in this way:
- All files ending with `.yml` that are packaged in the secret are copied to `/usr/share/elasticsearch/plugins/opendistro_security/securityconfig/`,
- All other files that are packaged in the secret are copied to `/usr/share/elasticsearch/config/security/custom`.
 
Therefore, any `.jks` or `.pem` file from the secret is copied to `/usr/share/elasticsearch/config/security/custom`. For the certificates you provide to be taken into account by Open Distro, you must also:
- have them referenced as appropriate in the `elasticsearch.yml` configuration file.
- ensure that the certificates are also provided as arguments when the Kubernetes job that intitializes the security configuration invokes `securityadmin.sh` script. 

In addition to the certificates packaged in the secret, the following two specific entries are required in order to have the certificates taken into account:

key | Description |
--- | --- |
`opendistro-elasticsearch.yml` | Open Distro security properties that are merged into the `elasticsearch.yml` file to replace the default Open Distro configuration.
`security-admin-sh-args` | String containing the list of arguments to run the `securityadmin.sh` script

Here is the default Open Distro configuration in `elasticsearch.yml`:
```
opendistro_security.ssl.transport.pemcert_filepath: security/esnode.pem
opendistro_security.ssl.transport.pemkey_filepath: security/esnode-key.pem
opendistro_security.ssl.transport.pemtrustedcas_filepath: security/root-ca.pem
opendistro_security.ssl.transport.enforce_hostname_verification: false
opendistro_security.ssl.http.enabled: true
opendistro_security.ssl.http.pemcert_filepath: security/esnode.pem
opendistro_security.ssl.http.pemkey_filepath: security/esnode-key.pem
opendistro_security.ssl.http.pemtrustedcas_filepath: security/root-ca.pem
opendistro_security.allow_unsafe_democertificates: true
opendistro_security.allow_default_init_securityindex: true
opendistro_security.authcz.admin_dn:
  - CN=kirk,OU=client,O=client,L=test, C=de

opendistro_security.audit.type: internal_elasticsearch
opendistro_security.enable_snapshot_restore_privilege: true
opendistro_security.check_snapshot_restore_write_privileges: true
opendistro_security.restapi.roles_enabled: ["all_access", "security_rest_api_access"]
cluster.routing.allocation.disk.threshold_enabled: false
node.max_local_storage_nodes: 3
```

Considering that you want to use the following certificates to secure the transport layer:
- `truststore.jks` is a truststore that uses `changeit` as password and where `root-ca-chain` alias contains a root CA certificate.
- `keystore.jks` is a keystore that uses `changeit` as password and which contains a certificate signed by the root CA certificate from the truststore.
- `admin-keystore.jks` is a keystore that uses `changeit` as password and that contains a certificate with distinguished name `CN=Admin,OU=BAI,O=IBM,L=Gentilly,C=FR`. This certificate is used to authenticate the administrator user who is allowed to execute the `securityadmin.sh` script. This certificate must also be signed by the root CA certificate from the truststore.

1. Place all these `jks` files in a new folder named `odConfig`.

Then, in the `odConfig` folder, create a file named `opendistro-elasticsearch.yml` with the following content:
```
opendistro_security.ssl.transport.keystore_filepath: security/custom/keystore.jks
opendistro_security.ssl.transport.keystore_password: changeit
opendistro_security.ssl.transport.truststore_filepath: security/custom/truststore.jks
opendistro_security.ssl.transport.truststore_password: changeit
opendistro_security.ssl.transport.truststore_alias: root-ca-chain
opendistro_security.ssl.transport.enforce_hostname_verification: false
opendistro_security.ssl.http.enabled: true
opendistro_security.ssl.http.pemcert_filepath: security/esnode.pem
opendistro_security.ssl.http.pemkey_filepath: security/esnode-key.pem
opendistro_security.ssl.http.pemtrustedcas_filepath: security/root-ca.pem
opendistro_security.allow_unsafe_democertificates: true
opendistro_security.allow_default_init_securityindex: true
opendistro_security.authcz.admin_dn:
  - CN=Admin,OU=BAI,O=IBM,L=Gentilly,C=FR

opendistro_security.audit.type: internal_elasticsearch
opendistro_security.enable_snapshot_restore_privilege: true
opendistro_security.check_snapshot_restore_write_privileges: true
opendistro_security.restapi.roles_enabled: ["all_access", "security_rest_api_access"]
cluster.routing.allocation.disk.threshold_enabled: false
node.max_local_storage_nodes: 3
```

2. In the `odConfig` folder, create a file named `security-admin-sh-args` with the following content:
```
-nhnv
-ks /usr/share/elasticsearch/config/security/custom/admin-keystore.jks
-kspass changeit
-ksalias admin
-ts /usr/share/elasticsearch/config/security/custom/truststore.jks
-tspass changeit
-tsalias root-ca-chain
```

You must also back up the default Open Distro configuration as described in [the following section](#performing-a-backup-of-the-open-distro-security-configuration) and place all the generated files in the `odConfig` folder.

3. Create the secret: 
```
$ kubectl create secret generic odcfg --from-file ./odConfig
secret "odcfg" created
```

The secret `odcfg` can now be referenced under the `security.openDistroConfigSecret` Helm value. And if the `security.initOpenDistroConfig` Helm value is set to `true`, next time you install or upgrade the Helm release, the Open Distro configuration will be initialized based on the files from the secret.

_**Important:**_
_The capability to take snapshots and restore internal users database, action-groups, roles, and role mappings is supported by IBM Business Automation Insights 19.0.1. But alternative authentication methods (LDAP, ActiveDirectory, SAML, OpenID Connect ) and custom certificates are features that are provided as a technical preview, that is, without any support from IBM._

For more information, see the [Open Distro for Elasticsearch documentation](https://opendistro.github.io/for-elasticsearch-docs/).

### Kibana

The pods running Kibana also benefit from the Open Distro security plugin which provides a dedicated interface to manage your users, roles and permissions when logged in as an admin user. 

_**Limitation**: The configuration of Open Distro for Kibana does not enable multi tenancy support._

## Installing the Chart

To install the chart with release name `my-release`:

```console
$ helm install --name my-release ibm-dba-ek
```

The command deploys `ibm-dba-ek` on the Kubernetes cluster with default values. The configuration section lists the parameters that can be configured during installation.

_**Note**: If you are running on IBM Cloud Private, you must add `--tls` argument to all `helm`commands referenced in this README._

## Verifying the Chart
To verify the chart, see the instruction after the Helm installation completes. You can also execute the following command to retrieve the instruction of the Helm release:

```console
$ helm status my-release
```

_**Note**: If you are working on IBM Cloud Private, you can also display the instruction by viewing the installed Helm release under Menu -> Workloads -> Helm Releases._

## Upgrading the release

To upgrade the release, execute the following command, where `values.yaml` contains the Helm values that you want to add or override. If you don't want or don't need to add or override Helm values, do not provide the `--values values.yaml` argument:
 
```console
$ helm upgrade my-release ibm-dba-ek --reuse-values --values values.yaml
```

## Rolling back the release

You can roll back the Helm release to a previous revision.

To retrieve the release upgrade history, execute the following command: 
```console
$ helm history my-release
```

You can roll back the current release to a previous version by executing the following Helm command, where `<REVISION>` is the upgrade revision from the release upgrade history:
```console
$ helm rollback my-release <REVISION> 
```

## Uninstalling the Chart

To uninstall or delete the my-release deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


>**Note**: With Helm, deleting the release does not delete the persistent volume claims created by the StatefulSet. This allows you to deploy the chart again in te same namespace and with the same release name and keep your Elasticsearch data (indexes and documents). However, if you want to start from an empty Elasticsearch, delete the persistent volume claims manually in order to unbind the persistent volumes and make them available again for another release.

## Configuration

### General

Parameter | Description | Default
----------|-------------|--------
`image.pullPolicy` | The policy used by Kubernetes for images |
`image.credentials.registry` | Docker registry URL |
`image.credentials.username` | Docker registry username |
`image.credentials.password` | Docker registry password |
`image.imagePullSecret` | The secret for pulling for Docker images. Overrides `image.credentials.registry`, `image.credentials.username`, and `image.credentials.password`. Here is the command to create such secret: <ul><li>```kubectl create secret docker-registry regcred --docker-server=<docker_registry> --docker-username=<docker_username> --docker-password=<docker_password> --docker-email=<your email> -n <namespace>```</li></ul> |

### Security settings

Parameter | Description | Default
----------|-------------|--------
`security.initOpenDistroConfig`   | A Boolean value to state whether to create the security configuration job. See [the following section](#open-distro-for-elasticsearch-security-configuration) for details. | `true`
`security.openDistroConfigSecret`   |  Name of a secret that is already deployed to Kubernetes and contains the configuration files for the Open Distro for Elasticsearch security plugin. All the keys from this secret will be copied as files to the `plugins/opendistro_security/securityconfig/` directory. Set this parameter only if `security.initOpenDistroConfig` is set to `true` See [the following section](#open-distro-for-elasticsearch-security-configuration) for details. | 
`ekSecret`   | Name of a secret that is already deployed to Kubernetes and contains the following keys:<ul><li>`elasticsearch-username`: the username used by Kibana pods to authenticate against Elasticsearch</li><li>`elasticsearch-password`: the password used by Kibana pods to authenticate against Elasticsearch</li></ul> If `ekSecret` is defined, it overrides the `kibana.username` and `kibana.password` values. | `

### Elasticsearch&mdash;General settings

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.image.repository`       | The full repository and path to the image that provides Elasticsearch | `bai-elasticsearch`
`elasticsearch.image.tag`              | The version to deploy the image that provides Elasticsearch | 19.0.2`
`elasticsearch.init.image.repository`     | The Docker image for configuring the Elasticsearch system. | `bai-init`
`elasticsearch.init.image.tag`            | The Docker image version for configuring the Elasticsearch system. | `19.0.2`
`elasticsearch.probeInitialDelay`         | The initial delay for liveness and readiness probes of Elasticsearch pods | `90`

### Elasticsearch&mdash;Client node

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.client.replicas`     | The number of initial pods in the client cluster                   | `1`
`elasticsearch.client.serviceType`  | How to publish the client service. Can be `NodePort` or `ClusterIP`. If you want to expose the service on Ingress, choose `ClusterIP` and after the Helm chart is deployed, create your own Ingress Kubernetes resource manually. | `NodePort`
`elasticsearch.client.externalPort`     | The port to use to access the client REST API from the outside if `elasticsearch.client.serviceType` is set to `NodePort`.         |
`elasticsearch.client.heapSize`     | The JVM heap size to allocate to each Elasticsearch client pod     | `1024m`
`elasticsearch.client.resources.limits.memory`  | The maximum memory (including JVM heap and file system cache) to allocate to each Elasticsearch client pod | `2Gi`
`elasticsearch.client.resources.limits.cpu`  | The maximum amount of CPU to allocate to each Elasticsearch client pod | `1000m`
`elasticsearch.client.resources.requests.memory`  | The minimum memory required (including JVM heap and file system cache) to start an Elasticsearch client pod | `500Mi`
`elasticsearch.client.resources.requests.cpu`  | The minimum amount of CPU required to start an Elasticsearch client pod | `100m`
`elasticsearch.client.antiAffinity` | Whether Kubernetes "may" (`soft`) or "must not" (`hard`) [deploy client pods onto the same node](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `soft`



### Elasticsearch&mdash;Master node

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.master.replicas`     | The number of initial pods in the master cluster                   | `1`
`elasticsearch.master.heapSize`     | The JVM heap size to allocate to each Elasticsearch master pod     | `1024`
`elasticsearch.master.resources.limits.memory`  | The maximum memory (including JVM heap and file system cache) to allocate to each Elasticsearch master pod | `2Gi`
`elasticsearch.master.resources.limits.cpu`  | The maximum amount of CPU to allocate to each Elasticsearch master pod | `1000m`
`elasticsearch.master.resources.requests.memory`  | The minimum memory required (including JVM heap and file system cache) to start an Elasticsearch master pod | `500Mi`
`elasticsearch.master.resources.requests.cpu`  | The minimum amount of CPU required to start an Elasticsearch master pod | `100m`
`elasticsearch.master.antiAffinity` | Whether Kubernetes "may" (`soft`) or "must not" (`hard`) [deploy master pods onto the same node](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `soft`



### Elasticsearch&mdash;Data node

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.data.replicas`             | The number of initial pods in the data cluster                   | `1`
`elasticsearch.data.heapSize`             | The JVM heap size to allocate to each Elasticsearch data pod     | `1024m`
`elasticsearch.data.resources.limits.memory`  | The maximum memory (including JVM heap and file system cache) to allocate to each Elasticsearch data pod | `2Gi`
`elasticsearch.data.resources.limits.cpu`  | The maximum amount of CPU to allocate to each Elasticsearch data pod | `1000m`
`elasticsearch.data.resources.requests.memory`  | The minimum memory required (including JVM heap and file system cache) to start an Elasticsearch data pod | `500Mi`
`elasticsearch.data.resources.requests.cpu`  | The minimum amount of CPU required to start an Elasticsearch data pod | `100m`
`elasticsearch.data.antiAffinity`         | Whether Kubernetes "may" (`soft`) or "must not" (`hard`) [deploy data pods onto the same node](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) | `hard`
`elasticsearch.data.storage.size`         | The minimum [size of the persistent volume](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/scheduling/resources.md#resource-quantities)    | `10Gi`
`elasticsearch.data.storage.storageClass` | See the [official documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storageclasses). | `""`
`elasticsearch.data.storage.persistent`   | Set to `false` for non-production or trial-only deployment.                                                 | `true`
`elasticsearch.data.storage.useDynamicProvisioning` | Set to `true` to use GlusterFS or other dynamic storage provisioner.                               | `false`
`elasticsearch.data.snapshotStorage.size`         | The minimum [size of the persistent volume](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/scheduling/resources.md#resource-quantities)    | `30Gi`
`elasticsearch.data.snapshotStorage.storageClassName` | See the [official documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storageclasses). | `""`
`elasticsearch.data.snapshotStorage.existingClaimName` | By default, a new persistent volume claim is be created. Specify an existing claim here if one is available. | `""`
`elasticsearch.data.snapshotStorage.enabled`   | Set to `true` for production  deployment.                                                 | `false`
`elasticsearch.data.snapshotStorage.useDynamicProvisioning` | Set to `true` to use GlusterFS or other dynamic storage provisioner.                               | `false`



### Kibana

Parameter | Description | Default
----------|-------------|--------
`kibana.image.repository`   | The full repository and path to the image which provides Kibana | `bai-kibana`
`kibana.image.tag`       | The version to deploy the image that provides Elasticsearch | `19.0.2`
`kibana.replicas`           | The initial pod cluster size                 | `1`
`kibana.username`          | The name of the user that Kibana uses internally to authenticate against the Elasticsearch REST API | `"admin"`
`kibana.password`      | Password of the user that Kibana uses internally to authenticate against the Elasticsearch REST API | `"passw0rd"`       
`kibana.serviceType`  | How to publish the Kibana service. Can be `NodePort` or `ClusterIP`. If you want to expose the service on Ingress, choose `ClusterIP` and after the Helm chart is deployed, create your own Ingress Kubernetes resource manually. | `NodePort`
`kibana.externalPort`           | The port used by external users, exposed as a `NodePort` service             |
`kibana.probeInitialDelay`         | Initial delay for liveness and readiness probes of Kibana pods | `120`
`kibana.multitenancy` | Enables or disables usage of multiple tenants. | false
`kibana.resources.limits.memory`  | The maximum memory (including JVM heap and file system cache) to allocate to each Kibana pod | `2Gi`
`kibana.resources.limits.cpu`  | The maximum amount of CPU to allocate to each Kibana pod | `1000m`
`kibana.resources.requests.memory`  | The minimum memory required (including JVM heap and file system cache) to start a Kibana pod | `500Mi`
`kibana.resources.requests.cpu`  | The minimum amount of CPU required to start a Kibana pod | `100m`



### Configuration of the initialization image

Parameter | Description | Default
----------|-------------|--------
`initImage.image.repository`           | Docker image name for initialization containers. | `dba/bai-init`
`initImage.image.tag`           | Docker image version number for initialization containers | `19.0.2`

## Storage

### Elasticsearch data persistence

#### Enabling persistence of Elasticsearch data

The *ibm-dba-ek* subchart makes it possible not to use any persistent volume for data pods: set the `elasticsearch.data.storage.persistent` value to `false`. Use this option for a quick setup because it does not require any persistent volume. However, note that as soon as the Elasticsearch data pods is restarted, the Elasticsearch data is lost. In most use cases, this practice is discouraged. The typical practice is to set `elasticsearch.data.storage.persistent` to `true` and take care of the prerequired provisioning of persistent volumes.

#### Setting up persistent volumes for Elasticsearch data
A persistent volume per data and master node is required if no dynamic provisioning has been set up. For more information, see IBM Cloud Private documentation at [Setting up dynamic provisioning](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.0/manage_cluster/cluster_storage.html) and the [official Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). Here is an example.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ibm-bai-ek-pv-1
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  nfs:
    path: <nfs-shared-path>/ibm-bai-ek-pv1
    server: <server-ip>
  persistentVolumeReclaimPolicy: Retain
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ibm-bai-ek-pv-2
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 10Gi
  nfs:
    path: <nfs-shared-path>/ibm-bai-ek-pv2
    server: <server-ip>
  persistentVolumeReclaimPolicy: Retain
```

The persistent volume path must be readable and writable by the `elasticsearch` user and group under ID 1000. It is recommended to use the `Retain` reclaim policy to make sure data is kept on release.

The persistent volume must be accessed in `ReadWriteOnce` access mode.

#### Choosing the proper settings for the Elasticsearch data persistent volumes

You cannot update the Helm values related to the persistent storage of Elasticsearch data after the initial deployment of the release. Therefore be very careful with the values you choose, especially for the `elasticsearch.data.storage.size` value, which sets the size of the persistent volumes and defaults to 10Gi.

#### Persistent Volume Claims related to Elasticsearch data pods

When a Helm release is deployed for the first time, with persistence of Elasticsearch data enabled, the Kubernetes StatefulSets deploying the Elasticsearch data and master pods search for available persistent volumes that match the criteria provided in the values.yaml  configuration file (capacity, storage class name, selectors, ...) for each pod, and create the appropriate persistent volume claims. The  names of the persistent volume claim contain the Helm release name.

If you delete the Helm release, the persistent volume claim remain.

If, later on, you redeploy the Helm release with the same release name, Kubernetes will reuse the previous persistent volume claims and your previous Elasticsearch data will be available again.

If at some point you want to completely delete the release and the persistent data, you must delete the Helm release, and then delete the corresponding persistent volume claims by using the kubectl CLI.

### Elasticsearch snapshots

To be able to use [the snapshot API of Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/modules-snapshots.html), you need to provide a persistent volume that will be used by all master and data pods. You can enable a persistent volume for snapshot storage by defining the values under `elasticsearch.data.snapshotStorage`.  

The persistent volume is locally mounted on pods at the following location: `/mnt/snapshots`

You can enable snapshot storage on an existing Helm release by using the appropriate `helm upgrade` command.

### Operating the ibm-dba-ek chart

#### Changing the number of replicas

To change the number of replicas of Elasticsearch client pods, the number of replicas of the Elasticsearch data pods, the number of replicas of the Elasticsearch master pods, or the number of replicas of the Kibana pods on an already deployed Business Automation Insights Helm release, you can issue a Helm CLI `upgrade` command with the updated number of replicas in the values provided as arguments.

Changing the number of replicas of Elasticsearch client pods, Elasticsearch master pods, or Kibana pods makes some pods restart, which  causes some temporary interruption of service.

**Note:** If you decrease the number of replicas of the Elasticsearch data pods by more than one, ensure that data integrity is preserved. To do so, decrease the replicas number one at a time. Then, before proceeding with the next decrease of data pod replicas, monitor that all the shards of the index that were on the removed data pod get properly redistributed to the remaining running data pods.

#### Preventing "split-brain situations" when upgrading the chart

You must take care of preventing any [split brain](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html#split-brain) situation if you plan to perform a Helm upgrade that would change:
 - any value under `elasticsearch.master`,
 - any value under `elasticsearch.data.snapshotStorage`,
 - any value under `elasticsearch.init`,
 - any value under `elasticsearch.image`,
 - the `elasticsearch.probeInitialDelay` value,
 - any value under `image`.


While processing the Helm upgrade, Kubernetes might temporarily let some previous Elasticsearch master pods continue to run while starting a new set of Elasticsearch master pods. This behavior can lead to a split-brain situation. To avoid it, first manually delete the deployment of Elasticsearch master pods by using the following command:

```
kubectl delete deployment [RELEASE_NAME]-ibm-dba-ek-master
```

Then perform the Helm upgrade.

### Switching the service type of Business Automation Insights services.

If you want to change how the services are exposed (Elasticsearch REST API or Kibana), you can upgrade the existing Helm release by executing the appropriate Helm CLI `upgrade` command on the existing release. The Helm CLI `upgrade` command requires Helm values with the following properties updated to match your requirements:
    - `elasticsearch.cient.serviceType` for the Elasticsearch REST API
    - `kibana.serviceType` for Kibana

However, the Helm command may fail with messages such as this one:

- `Error: UPGRADE FAILED: Service "releasename-ibm-dba-ek-client" is invalid: spec.ports[0].nodePort: Forbidden: may not be used when ``type' is 'ClusterIP' && Service "releasename-ibm-dba-ek-kibana" is invalid: spec.ports[0].nodePort: Forbidden: may not be used when 'type' is 'ClusterIP'`

In this case, delete the Kubernetes service mentioned in the error message and repeat the Helm CLI `upgrade` command.

### Updating the resource requests and limits

You can update resource requests and limits of data, client, master and Kibana pods dynamically by using the Helm CLI `upgrade` command.

You can also update the `heapSize` attribute of data, client, and master pods.

Note that dynamically updating these settings causes the affected pods to be terminated and re-created.

## Limitations

The chart does not provide a way to use Ingest or Coordinating only nodes. For details on Elasticsearch node types, see the 
[Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.6/modules-node.html) 


