# IBM Watson Knowledge Studio

IBM Watson Knowledge Studio is an application that enables developers and domain experts to collaborate on the creation of custom annotator components that can be used to identify mentions and relations in unstructured text.

# Introduction

## Summary

Use IBM Watson™ Knowledge Studio (WKS) to create a machine learning model that understands the linguistic nuances, meaning, and relationships specific to your industry or to create a rule-based model that finds entities in documents based on rules that you define.

To become a subject matter expert in a given industry or domain, Watson must be trained. You can facilitate the task of training Watson with Knowledge Studio.

## Features

- Intuitive: Use a guided experience to teach Watson nuances of natural language without writing a single line of code
- Collaborative: SMEs work together to infuse domain knowledge in cognitive applications
- Cost effective: Create and deploy domain knowledge infused annotators faster than ever before using an integrated development environment

## Details

This CASE provides a helm chart of IBM Watson Knowledge Studio.

## Chart Details

This chart installs an IBM Cloud Pak for Data (CP4D) add-on of Watson Knowledge Studio. Once the installation is completed, Watson Knowledge Studio add-on becomes available on CP4D console.

This chart deploys the following microservices per install:

- **Watson Knowledge Studio Front-end**: Provides the WKS tooling user interface.
- **Service Broker**: Manages provision/de-provision instances.
- **Dispatcher**: Dispatches requests from gateway to Watson Knowledge Studio Front-end.
- **SIREG**: Tokenizers/parsers by Statistical Information and Relation Extraction (SIRE).
- **SIRE Job queue**: Machine Learning Training framework that allows to queue and schedule jobs on Kubernetes.
- **SIRE Train Facade**: Manages interaction with the training framework and Minio storage.
- **Model Management API**: Manages interaction with WKS Front-end and Train Facade.
- **Watson Gateway**: Publishes WKS service as CP4D add-on and handles incoming requests.
- **Glimpse**: Provides dictionary suggestions feature with model builder and serve runtime.
- **Advanced Rule Editor**: Provides Advanced Rule Editor (ARE) UI and runtime.

This chart installs the following stores:

- **PostgreSQL**: Stores training metadata.
- **MongoDB**: Stores WKS project data.
- **Minio**: Stores ML models and training data.
- **etcd**: Stores Glimpse model state. This is not deployed when dictionary suggestions feature is disabled.

## Prerequisites

- IBM Cloud Pak for Data 2.5 or 3.0
- Red Hat OpenShift Container Platform 3.11 or 4.3
- Kubernetes 1.11 or later
- Helm 2.9.0 or later
- [`PodDisruptionBudgets`](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) are recommended for high resiliency in an application during risky operations, such as draining a node for maintenance or scaling down a cluster.

### PodSecurityPolicy Requirements

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` (SCC) to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The default `SecurityContextConstraints` name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

- Custom SecurityContextConstraints definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
      kubernetes.io/description: "restricted denies access to all host features and requires
        pods to be run with a UID, and SELinux context that are allocated to the namespace.  This
        is the most restrictive SCC and it is used by default for authenticated users."
    name: ibm-watson-ks-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegeEscalation: true
  allowPrivilegedContainer: false
  allowedCapabilities: null
  defaultAddCapabilities: null
  fsGroup:
    type: MustRunAs
  groups:
  - system:authenticated
  priority: null
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - KILL
  - MKNOD
  - SETUID
  - SETGID
  runAsUser:
    type: MustRunAsRange
  seLinuxContext:
    type: MustRunAs
  supplementalGroups:
    type: RunAsAny
  users: []
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  ```

### Resources Required

In addition to the [general hardware requirements and recommendations](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_2.1.0/com.ibm.icpdata.doc/zen/install/reqs-ent.html), this chart has the following requirements:

- x86 is the only architecture supported.
- Minimum CPU - 11
- Minimum Memory - 100Gi

## Storage

NFS volumes, Local volumes and Portworx can be used as a storage type for this chart. Following numbers of persistent volumes are required by data stores.

| Component  | Number of replicas | Space per PVC | Number of PVs |
| ---------- | :----------------: | ------------- | :-----------: |
| PostgreSQL |         3          | 10 Gi         |       3       |
| Minio      |         4          | 50 Gi         |       4       |
| MongoDB    |         3          | 20 Gi         |       3       |
| etcd       |         5          | 10 Gi         |       5       |
| ARE        |         2          | 20 Gi         |       1       |

## Storage Class
### NFS volumes
A NFS volume allows an existing NFS (Network File System) share to be mounted into Kubernetes Pod.

https://kubernetes.io/docs/concepts/storage/volumes/#nfs

Note: Dynamic Volume Provisioner is not automatically installed in CP4D 2.5 or 3.0. [NFS Client Provisioner](https://github.com/helm/charts/tree/master/stable/nfs-client-provisioner) needs to be manually installed.

### Portworx

Portworx is a persistent storage for stateful containers including HA, snapshots, backup & encryption.

https://portworx.com/

A `StorageClass` for Portworx needs to be created. A dynamic provisioner is automatically enabled. See [online document](https://docs.portworx.com/portworx-install-with-kubernetes/storage-operations/kubernetes-storage-101/volumes/#storageclass) for more details.

Note: `ReadWriteMany` mode is required for ARE to share a mounted volume between multiple replicas. See [online document](https://docs.portworx.com/portworx-install-with-kubernetes/storage-operations/kubernetes-storage-101/volumes/#readwritemany-and-readwriteonce) to enable `ReadWriteMany` mode.

# Installing IBM Watson Knowledge Studio
## Installing the Chart into CP4D 2.5 or 3.0 on OpenShift
### Preparation

1. Obtain your entitlement license API key from the [Container software library on My IBM](https://myibm.ibm.com/products-services/containerlibrary) and your IBM ID. After you order IBM Cloud Pak for Data, an entitlement key for the software is associated with your My IBM account. To get the entitlement key:

   1. Log in to [Container software library on My IBM](https://myibm.ibm.com/products-services/containerlibrary) with the IBM ID and password that are associated with the entitled software.
   2. On the Get entitlement key tab, select Copy key to copy the entitlement key to the clipboard.
   3. Save the API key in a text file.

2. Prepare a Linux or Mac OS client workstation to run the installation from. The workstation does not have to be a node of the cluster, but must have internet access and be able to connect to the Red Hat OpenShift cluster.
3. If you don't have OpenShift CLI (`oc` command) on the same workstation, download and extract client tools from the [Download OKD](https://www.okd.io/download.html) web site.
4. If you don't have CP4D installer, download it from [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/pao_customer.html), extract the archive.
5. Edit the server definition file `repo.yaml` that you downloaded.

   This file specifies the repositories for the cpd command to download the installation files from. Make the following changes to the file:

   | Parameter  | Value                                    |
   |------------|------------------------------------------|
   | `username` | Specify `cp`                             |
   | `apikey`   | Specify your entitlement license API key |

### Log in to cluster

Log in to the OpenShift cluster by the following commands.

On OpenShift 3.11:
```bash
oc login -u {admin_username} -p {admin_password} https://{cluster_CA_domain}:8443
oc project {cp4d_namespace}
```
On OpenShift 4.3:
```
oc login --token={admin_apitoken} --server=https://api.{cluster_CA_domain}:6443
oc project {cp4d_namespace}
```

- `{cluster_CA_domain}` is your cluster CA domain name.
- `{admin_username}` is a username of the OpenShift administrator.
- `{admin_password}` is the password of the administrator user.
- `{admin_apitoken}` is the API token of the administrator user. You can obtain it in OpenShift Web UI https://oauth-openshift.apps.{cluster_CA_domain}/oauth/token/display.
- `{cp4d_namespace}` is the namespace where CP4D is installed. In CP4D 2.5 or 3.0, you are able to install Watson Knowledge Studio into only the namespace where CP4D is installed.

To meet network security policy for CP4D addon, update label of the namespaces by the following command.

```bash
oc label --overwrite namespace {cp4d_namespace} ns={cp4d_namespace}
```
- `{cp4d_namespace}` is the namespace where CP4D is installed. In CP4D 2.5 or 3.0, you are able to install Watson Knowledge Studio into only the namespace where CP4D is installed.

### Deploy Watson Knowledge Studio

Create an override YAML file `your_override_values.yaml` before installation.

```yaml
global:
  persistence:
    storageClassName: "${storage_class}"
awt:
  persistentVolume:
    storageClassName: "{storage_class_shared}"
```

- `{storage_class}` is the name of the storage class to use for ReadWriteOnce storage. When using Portworx, `portworx-db-gp3` is recommended.
- `{storage_class_shared}` is the name of the storage class to use for ReadWriteMany storage. When using Portworx, `portworx-shared-gp3` is recommended.

After then, you can deploy Watson Knowledge Studio by the following commands.

```bash
cd bin/
./cpd-linux adm -s ../repo.yaml --assembly watson-ks --namespace {cp4d_namespace} --apply
./cpd-linux --repo ../repo.yaml --assembly watson-ks --namespace {cp4d_namespace} --storageclass {storage_class} --override your_override_values.yaml \
  --transfer-image-to {registry_location}/{cp4d_namespace} \
  --target-registry-username {admin_username} \
  --target-registry-password {admin_token} \
  --cluster-pull-prefix {registry_from_cluster}/{cp4d_namespace}
```

- `{cp4d_namespace}` is the namespace where CP4D is installed.
- `{storage_class}` is the name of the storage class to use for ReadWriteOnce storage.
- `{registry_location}` - is the location to store the images in the registry server. You can run the following command to find the route to the registry:
  ```bash
  oc get routes --all-namespaces
  ```
- `{admin_username}` is a username of the OpenShift administrator.
- `{admin_token}` is a token of the OpenShift administrator. You can run the following command to obtain it:
  ```bash
  oc whoami -t
  ```
- `{registry_from_cluster}` is the location from which pods on the cluster can pull images. The default value is:
  - OpenShift 3.11:
    ```
    docker-registry.default.svc:5000
    ```
  - OpenShift 4.3:
    ```
    image-registry.openshift-image-registry.svc:5000
    ```
- Note: If you are using the default self-signed certificate, specify the `--insecure-skip-tls-verify` flag to prevent x509 errors.

## Verification of deployment

After installation completed successfully, you can verify the deployment by running `helm test`.

```bash
helm test wks --timeout 600 --tls
```

If a part of test fails, you can delete the pod for the test (ex. `wks-ibm-watson-ks-dvt-job`) then execute `helm test` again.

```bash
oc delete pod wks-ibm-watson-ks-dvt-job
helm test wks --timeout 600 --tls
```

### Accessing WKS tooling UI

After the successful installation, a WKS add-on tile with the release name is shown up on your CP4D console. You can provision a WKS instance and launch your WKS tooling application there.

1. Open `https://{cp4d_namespace}-cpd-{cp4d_namespace}.apps.{cluster_CA_domain}` by your web browser and login to CP4D console.

  - `{cp4d_namespace}` is the namespace where CP4D is installed.
  - `{cluster_CA_domain}` is your cluster CA domain name.

1. Move to Add-on catalog. You can find the add-on of IBM Watson Knowledge Studio with the release name.

1. Click the Watson Knowledge Studio add-on tile and provision an instance.

1. Open the created instance and click `Launch Tool` button.

1. You can start using IBM Watson Knowledge Studio.

## Uninstalling the chart

1. Delete the existing WKS instances of the release on CP4D console.

1. Run the following command to uninstall and delete the existing release.

    ```bash
    ./cpd-linux uninstall --assembly watson-ks --namespace {cp4d_namespace}
    ```

    - `{cp4d_namespace}` is the namespace where CP4D is installed.

Before you can install a new version of the service on the same cluster, you must remove all content from any persistent volumes and persistent volume claims that were used for the previous deployment.

## Configuration

The following table lists the configurable parameters of the WKS chart and their default values.
These value can be changed on installation by specifying `-o` option of `cpd-linux`.

1. Create your own override YAML file `your_override_values.yaml`. Below example is to extend Minio storage size and maximum amount of training jobs running in parallel.

    ```yaml
    global:
      persistence:
        storageClassName: "${storage_class}"
    minio:
      persistence:
        size: 100Gi
    sire:
      jobq:
        tenants:
          train:
            max_active_per_user: 4
    awt:
      persistentVolume:
        storageClassName: "{storage_class_shared}"
    ```
    
    Below is another example to run Watson Knowledge Studio with minimum CPU and memory resource. This can be used for a PoC（Proof of Concept).
    
    ```yaml
    global:
      persistence:
        storageClassName: "${storage_class}"
      highAvailabilityMode: false
    replicaCount: 1
    broker:
      replicas: 1
    dispatcher:
      replicas: 1
    mma:
      replicas: 1
    glimpse:
      builder:
        replicas: 1
      query:
        replicas: 1
    awt:
      replicas: 1
      persistentVolume:
        storageClassName: "{storage_class_shared}"
    ```

1. Install Watson Knowledge Studio with `--override` option.

    ```bash
    ./cpd-linux adm -s ../repo.yaml --assembly watson-ks --namespace {cp4d_namespace} --apply
    ./cpd-linux --repo ../repo.yaml --assembly watson-ks --namespace {cp4d_namespace} --storageclass {storage_class} --override your_override_values.yaml
    ```

### Global parameters

|    Parameter    |                                              Description                                              |     Default     |
| --------------- | ----------------------------------------------------------------------------------------------------- | --------------- |
| `global.clusterDomain` | Cluster domain used by Kubernetes Cluster (the suffix for internal KubeDNS names).                    | `cluster.local` |
| `global.dockerRegistryPrefix` | Prefix of docker registry image is pulled from                    | `cp.icr.io/cp/knowledge-studio` |
| `global.storageClassName` | Storage class name for persistent volumes.                    | `nfs-client` |

### Affinity parameters

Following table lists the affinity parameters for the components in the WKS chart. See [Affinity and anti-affinity](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity) for the details of arguments.

|     Parameter     |                                    Description                                     |     Default     |
| ----------------- | ---------------------------------------------------------------------------------- | --------------- |
| `affinity` | Node/pod affinities for WKS Frontend/Broker/Dispatcher pods. If specified overrides default affinity to run on any amd64 node. | `{}` |
| `mongodb.affinityMongodb` | Node/pod affinities for Mongodb statefulset only. If specified overrides default affinity to run on any amd64 node. | `{}` |
| `minio.affinityMinio` | Node/pod affinities for Minio statefulset only. If specified overrides default affinity to run on any amd64 node. | `{}` |
| `postgresql.sentinel.affinity` | Affinity settings for sentinel pod assignment. | `{}` |
| `postgresql.proxy.affinity` | Affinity settings for proxy pod assignment. | `{}` |
| `postgresql.keeper.affinity` | Affinity settings for keeper pod assignment. | `{}` |
| `etcd.affinityEtcd` | Affinities for Etcd stateful set. Overrides the generated affinities if provided. | `{}` |
| `glimpse.affinity`  | Node/pod affinities for Glimpse pods. If specified overrides default affinity to run on any amd64 node. | `{}`    |
| `sire.affinity`  | Node/pod affinities for SIRE pods. If specified overrides default affinity to run on any amd64 node. | `{}`    |
| `wcn.affinity`  | Node/pod affinities for Watson Gateway pods. If specified overrides default affinity to run on any amd64 node. | `{}`    |

### WKS Front-end parameters

|       Parameter        |                                                           Description                                                            | Default |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `replicaCount`         | Number of replicas for WKS Front-end deployment.                                                                                  | `2`     |

### Service Broker parameters

|       Parameter        |                                                           Description                                                            | Default |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `replicas`         | Number of replicas for Service Broker deployment.                                                                                  | `2`     |

### Dispatcher parameters

|       Parameter        |                                                           Description                                                            | Default |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `replicas`         | Number of replicas for Dispatcher deployment.                                                                                  | `2`     |

### SIRE parameters

|                          Parameter                          |                                                                                          Description                                                                                           | Default |
| ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `global.highAvailabilityMode`                               | It this values is `true`, multiple replicas are created for SIRE training service (SIREG, SIRE Job queue, SIRE Train Facade). If set `false`, a single replica is created for each deployment. | `true`  |
| `sire.jobq.tenants.train.max_queued_and_active_per_user`    | Maximum amount of queued and active training jobs, any additional jobs will be rejected with an error.                                                                                        | `10`    |
| `sire.jobq.tenants.train.max_active_per_user`               | Maximum amount of training jobs running in parallel even if enough cpu/mem quota available.                                                                                                    | `2`     |
| `sire.jobq.tenants.evaluate.max_queued_and_active_per_user` | Maximum amount of queued and active evaluate jobs, any additional jobs will be rejected with an error.                                                                                        | `10`    |
| `sire.jobq.tenants.evaluate.max_active_per_user`            | Maximum amount of evaluate jobs running in parallel even if enough cpu/mem quota available.                                                                                                    | `2`     |
| `sire.sireg.languages.en.enabled`                                | Toggle language support for English                                                                                                                                                            | `true`  |
| `sire.sireg.languages.es.enabled`                                | Toggle language support for Spanish                                                                                                                                                            | `true`  |
| `sire.sireg.languages.ar.enabled`                                | Toggle language support for Arabic                                                                                                                                                             | `true`  |
| `sire.sireg.languages.de.enabled`                                | Toggle language support for German                                                                                                                                                             | `true`  |
| `sire.sireg.languages.fr.enabled`                                | Toggle language support for French                                                                                                                                                             | `true`  |
| `sire.sireg.languages.it.enabled`                                | Toggle language support for Italian                                                                                                                                                            | `true`  |
| `sire.sireg.languages.ja.enabled`                                | Toggle language support for Japanese                                                                                                                                                           | `true`  |
| `sire.sireg.languages.ko.enabled`                                | Toggle language support for Korean                                                                                                                                                             | `true`  |
| `sire.sireg.languages.nl.enabled`                                | Toggle language support for Dutch                                                                                                                                                              | `true`  |
| `sire.sireg.languages.pt.enabled`                                | Toggle language support for Portuguese                                                                                                                                                         | `true`  |
| `sire.sireg.languages.zh.enabled`                                | Toggle language support for Chinese (simplified)                                                                                                                                               | `true`  |
| `sire.sireg.languages.zht.enabled`                               | Toggle language support for Chinese (traditional)                                                                                                                                              | `true`  |

### MMA parameters

|   Parameter    |        Description         | Default |
| -------------- | -------------------------- | ------- |
| `mma.replicas` | Number of replicas for MMA | `2`     |

### MongoDB parameters

|                 Parameter                 |                                            Description                                             |      Default      |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------- | ----------------- |
| `mongodb.replicas`                        | Number of replicas for MongoDB StatefulSet.                                                        | `3`               |
| `mongodb.persistentVolume.enabled`        | If `true`, persistent volume claims are created for MongoDB.                                       | `true`            |
| `mongodb.persistenceVolume.useDynamicProvisioning` | If enabled, the PVC will use a storageClassName to bind the volume for MongoDB.                                                                                                                                                                         | `true`         |
| `mongodb.persistentVolume.accessMode`     | Persistent volume access modes for MongoDB.                                                        | `[ReadWriteOnce]` |
| `mongodb.persistentVolume.size`           | Persistent volume size for MongoDB.                                                                | `20Gi`            |
| `mongodb.persistentVolume.selector.label` | Label for persistent volume claim selectors to control how pvc's bind/reserve storage for MongoDB. | `""`              |
| `mongodb.persistentVolume.selector.value` | Value for persistent volume claim selectors to control how pvc's bind/reserve storage for MongoDB. | `""`              |
| `mongodb.persistentVolume.annotations`    | Persistent volume annotations for MongoDB.                                                         | `{}`              |

### Minio (Object Storage) parameters

|                 Parameter                  |                                                                                                                      Description                                                                                                                      |     Default     |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `minio.replicas`                           | Number of nodes. Must be 4 <= x <= 32                                                                                                                                                                     | `4`             |
| `minio.persistence.enabled`                | Use PV to store data on Minio.                                                                                                                                                                                                                        | `true`          |
| `minio.persistence.size`                   | Size of persistent volume claim (PVC) for Minio.                                                                                                                                                                                                      | `50Gi`          |
| `minio.persistence.accessMode`             | Persistent volume storage class for Minio.                                                                                                                                                                               | `ReadWriteOnce` |
| `minio.persistence.subPath`                | Mount a sub directory of the persistent volume for Minio, if a sub directory is set.                                                                                                                                                                  | `""`            |

### PostgreSQL parameters

|              Parameter               |                                                                                                                                   Description                                                                                                                                    |     Default     |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `postgresql.sentinel.replicas`                  | Number of sentinel nodes                                                                                                                                                                                                                                                         | `2`             |
| `postgresql.proxy.replicas`                     | Number of proxy nodes                                                                                                                                                                                                                                                            | `2`             |
| `postgresql.keeper.replicas`                    | Number of keeper nodes                                                                                                                                                                                                                                                           | `2`             |
| `postgresql.persistence.enabled`                | Use a PVC to persist data                                                                                                                                                                                                                                                        | `true`          |
| `postgresql.persistence.useDynamicProvisioning` | Enables dynamic binding of Persistent Volume Claims to Persistent Volumes                                                                                                                                                                                                        | `true`          |
| `postgresql.persistence.accessMode`             | Persistent volume storage class for PostgreSQL.                                                                                                                                                                                                                                              | `ReadWriteOnce` |
| `postgresql.persistence.size`                   | Size of data volume                                                                                                                                                                                                                                                              | `10Gi`          |
| `postgresql.dataPVC.name`                       | Prefix that gets the created Persistent Volume Claims                                                                                                                                                                                                                            | `stolon-data`   |
| `postgresql.dataPVC.selector.label`             | In case the persistence is enabled and useDynamicProvisioning is disabled the labels can be used to automatically bound persistent volumes claims to precreated persistent volumes. The persistent volumes to be used must have the specified label. Disabled if label is empty. | `""`            |
| `postgresql.dataPVC.selector.value`             | In case the persistence is enabled and useDynamicProvisioning is disabled the labels can be used to automatically bound persistent volumes claims to precreated persistent volumes. The persistent volumes to be used must have label with the specified value.                  | `""`            |

### etcd parameters

| Parameter                            | Description                                                                                                                                                                                                                                                                      | Default         |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `etcd.replicaCount`                  | Number of etcd nodes                                                                                                                                                                                                                                                             | `5`             |
| `etcd.maxEtcdThreads`                | Maximum Number of Threads Etcd Can Use                                                                                                                                                                                                                                           | `2`             |
| `etcd.persistence.enabled`           | Enables use of Persistent Volumes                                                                                                                                                                                                                                                | `true`          |
| `etcd.dataPVC.accessMode`            | Access Mode for the Persistent Volume                                                                                                                                                                                                                                            | `ReadWriteOnce` |
| `etcd.dataPVC.name`                  | Prefix that gets the created Persistent Volume Claims                                                                                                                                                                                                                            | `data`          |
| `etcd.dataPVC.selector.label`        | In case the persistence is enabled and useDynamicProvisioning is disabled the labels can be used to automatically bound persistent volumes claims to precreated persistent volumes. The persistent volumes to be used must have the specified label. Disabled if label is empty. | `""`            |
| `etcd.dataPVC.selector.value`        | n case the persistence is enabled and useDynamicProvisioning is disabled the labels can be used to automatically bound persistent volumes claims to precreated persistent volumes. The persistent volumes to be used must have label with the specified value.                   | `""`            |
| `etcd.dataPVC.size`                  | Size of the Persistent Volume Claim                                                                                                                                                                                                                                              | `10Gi`          |

### Glimpse parameters

|              Parameter               |                                                                                                                                   Description                                                                                                                                    |     Default     |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| `glimpse.create`                  | If true, Glimpse services and etcd is deployed and dictionary suggestions feature gets available on WKS UI. If false, they are not deployed, and dictionary suggestions feature doens't become available on WKS UI. | `true`             |
| `glimpse.builder.replicas`                          | Number of replicas for Glimpse builder.                  | `2`                             |
| `glimpse.builder.resources.requests.cpu`            | CPU resource request for Glimpse builder. To reduce processing time to build Glimpse model, increasing this can be a good idea. | `100m`                         |
| `glimpse.builder.resources.requests.memory`         | Memory resource request for Glimpse builder. It is recommended to increase this value to get suggestions from large corpus. Typically `8000M` is enough. | `1000M`                         |
| `glimpse.builder.resources.limits.cpu`             | CPU resource limit for Glimpse builder. To reduce processing time to build Glimpse model, increasing this can be a good idea. | `4000m`                         |
| `glimpse.builder.resources.limits.memory`           | Memory resource limit for Glimpse builder.             | `8000M`                         |
| `glimpse.query.replicas`                                          | Number of replicas for Glimpse query server.                                                    | `2`                             |
| `glimpse.query.glimpse.resources.requests.cpu`                    | CPU resource request for Glimpse query server.                                             | `150m`                         |
| `glimpse.query.glimpse.resources.requests.memory`                 | Memory resource request for Glimpse query server.                                          | `1000M`                         |
| `glimpse.query.glimpse.resources.limits.cpu`                      | CPU resource limit for Glimpse query server.                                               | `4000m`                         |
| `glimpse.query.glimpse.resources.limits.memory`                   | Memory resource request for Glimpse query server.                                          | `8000M`                         |

### Advanced Rule Editor parameters

| Parameter                                     | Description                                                                                                                                                                                            | Default   |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------- |
| `awt.create`                                  | If true, Advaned Rule Editor service is deployed, and you can select project type for Advanced Rules on WKS UI. If false, they are not deployed, and you cannot select Advanced Rules projects.        | `true`    |
| `awt.replicas`                                | Number of replicas for Advanced Rule Editor                                                                                                                                                            | `2`       |
| `awt.persistentVolume.useDynamicProvisioning` | Enables dynamic binding of Persistent Volume Claims to Persistent Volumes                                                                                                                              | `false`   |
| `awt.persistentVolume.storageClassName`       | Storage class name of backing PVC                                                                                                                                                                      | `""`      |
| `awt.persistentVolume.size`                   | Size of data volume                                                                                                                                                                                    | `20Gi`    |

## Storage

Please refer to the section "Resources Required".

## Limitations

- Only the `x86` architecture is supported.
- The chart must be installed by a cluster administrator.

## Documentation

Find out more about IBM Watson Knowledge Studio by reading the [product documentation](https://cloud.ibm.com/docs/services/watson-knowledge-studio-data?topic=watson-knowledge-studio-data-wks_overview_full).

**Note**: The documentation link takes you out of IBM Cloud Pak for Data to the public IBM Cloud.
