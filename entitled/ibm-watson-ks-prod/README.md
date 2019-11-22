# IBM Watson Knowledge Studio

## Introduction

Use IBM Watson™ Knowledge Studio (WKS) to create a machine learning model that understands the linguistic nuances, meaning, and relationships specific to your industry or to create a rule-based model that finds entities in documents based on rules that you define.

To become a subject matter expert in a given industry or domain, Watson must be trained. You can facilitate the task of training Watson with Knowledge Studio.

## Chart Details

This chart installs an IBM Cloud Pak for Data (ICP4D) add-on of Watson Knowledge Studio. Once the installation is completed, Watson Knowledge Studio add-on becomes available on ICP4D console.

This chart deploys the following microservices per install:

- **Watson Knowledge Studio Front-end**: Provides the WKS tooling user interface.
- **Service Broker**: Manages provision/de-provision instances.
- **Dispatcher**: Dispatches requests from gateway to Watson Knowledge Studio Front-end.
- **SIREG**: Tokenizers/parsers by Statistical Information and Relation Extraction (SIRE).
- **SIRE Job queue**: Machine Learning Training framework that allows to queue and schedule jobs on Kubernetes.
- **SIRE Train Facade**: Manages interaction with the training framework and Minio storage.
- **Model Management API**: Manages interaction with WKS Front-end and Train Facade.
- **Watson Add-on**: Publishes WKS service as ICP4D add-on.

This chart installs the following stores:

- **PostgreSQL**: Stores training metadata.
- **MongoDB**: Stores WKS project data.
- **Minio**: Stores ML models and training data.

## Prerequisites

- IBM Cloud Pak for Data 2.1.0.1
- Kubernetes 1.11 or later
- Helm 2.9.0 or later

## PodSecurityPolicy Requirements

### ICP PodSecurityPolicy Requirements

This chart requires a `PodSecurityPolicy` to be bound to the target namespace prior to installation. The predefined `PodSecurityPolicy` name: `ibm-restricted-psp` has been verified for this chart, if your target namespace is bound to this `PodSecurityPolicy` resource you can proceed to install the chart.

- ICPv3.1 - Predefined  PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
- Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-watson-ks-psp
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

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` (SCC) to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The default `SecurityContextConstraints` name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

## Resources Required

In addition to the [general hardware requirements and recommendations](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_2.1.0/com.ibm.icpdata.doc/zen/install/reqs-ent.html), this chart has the following requirements:

- x86 is the only architecture supported.
- Minimum CPU - 10
- Minimum Memory - 80Gi

### Storage

[NFS](https://kubernetes.io/docs/concepts/storage/volumes/#nfs) and [Local volumes](https://kubernetes.io/docs/concepts/storage/volumes/#local) can be used as a storage type for this chart. Following numbers of persistent volumes are required by data stores. Note that Local volumes is supported only on IBM Cloud Private.

| Component  | Number of replicas | Space per PVC | Number of PVs |
| ---------- | :----------------: | ------------- | :-----------: |
| PostgreSQL |         2          | 10 Gi         |       2       |
| Minio      |         4          | 10 Gi         |       4       |
| MongoDB    |         2          | 20 Gi         |       2       |

## Installing the Chart into ICP4D on IBM Cloud Private

### Setup environment

1. SSH login to a master node

1. Login to your cluster.

    ```bash
    cloudctl login -a https://{cluster_CA_domain}:8443 -u {user} -p {password}
    ```

    See the [installation documentation](https://cloud.ibm.com/docs/services/watson-knowledge-studio-data?topic=watson-knowledge-studio-data-install) for more detail.

1. Create a Kubernetes namespace.

   - Create a Kubernetes namespace with [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) PSP. See the [installation documentation](https://cloud.ibm.com/docs/services/watson-knowledge-studio-data?topic=watson-knowledge-studio-data-install) for more detail.

1. Login to the docker registry like the following.

    ```bash
    docker login {cluster_CA_domain}:8500 -u {user} -p {password}
    ```

1. Change target namespace

    ```bash
    cloudctl target -n {namespace_name}
    ```

    - `{namespace_name}` is the namespace you created in Step 3.

1. Create a YAML file like the following, then run the apply command on the YAML file that you create. For example `kubectl apply -f image_policy.yaml`. For further details of ImagePolicy, see [Enforcing container image security](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/manage_images/image_security.html)

    ```yaml
    apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
    kind: ImagePolicy
    metadata:
      name: icp-image-policy
      namespace: {namespace_name}
    spec:
      repositories:
      - name: '{cluster_CA_domain}:8500/{namespace_name}/*'
    ```

    - `{namespace_name}`: your target namespace
    - `{cluster_CA_domain}`: your cluster CA domain name

1. To meet network security policy for ICP4D addon, update label of the namespaces by the following 2 commands.

    ```bash
    kubectl label --overwrite namespace zen ns=zen
    kubectl label --overwrite namespace {namespace_name} ns={namespace_name}
    ```

### Preparing persistent volumes for local-storage class
*You need this step only when you use local-storage as Persistent Volume.*

This chart uses persistent volumes for data stores. Local storage can be used for this chart. To create a persistent volume with `local-storage` storage class, you can define each volume configuration in a YAML file, and then use the `kubectl` command line to push the configuration changes to the cluster. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/volumes/#local) for more details about local storage.

1. Create a `local-storage` storage class on your cluster. See [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#local) for more detail.

    ```yaml
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: local-storage
    provisioner: kubernetes.io/no-provisioner
    volumeBindingMode: WaitForFirstConsumer
    ```

1. Prepare directories to be used by PVs on worker nodes.

1. Create 8 YAML files, one for each volume. The Number of required volumes can be different if you change the number of replicas of data stores. Default is 8.

    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: {name}
    spec:
      capacity:
        storage: {size}Gi
      accessModes:
      - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      storageClassName: local-storage
      local:
        path: {path}
      nodeAffinity:
        required:
          nodeSelectorTerms:
          - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
              - {ip}
    ```

    - `{name}`: The name of the PV to be created.
    - `{size}`: Reflect the size specified in the storage requirement table above.
    - `{path}`: Path on the worker node where you create in the previous step. For example, `/mnt/local-storage/storage/{dir_name}`. For `{dir_name}`, use the same value that you use for `{name}` so you can map the volume name to its physical location.
    - `{ip}`: IP address of the worker node where you create the persistent volume.

1. Run the apply command on each YAML file that you create.

    For example: `kubectl apply -f pv_001.yaml`. Rerun this command for each file up to `kubectl apply -f pv_07.yaml`.

See the [installation document](https://cloud.ibm.com/docs/services/watson-knowledge-studio-data?topic=watson-knowledge-studio-data-install) for more detail.

### Deployment

To install the addon, run the following command:

```bash
cd /ibm/InstallPackage/components/
./deploy.sh -d {compressed_file_name} -e {release_name_postfix}
```

- `{compressed_file_name}` is the name of the file that you downloaded from Passport Advantage.
- `{release_name_postfix}` is the postfix of Helm release name of this installation.

The command will interactively ask you the following information, so answer like the following.

| Question                                                      | Answer                                                                                                                                |
| ------------------------------------------------------------  | ------------------------------------------------------------------------------------------------------------------------------------- |
| Do you agree with the terms and conditions in {license_URL}?  | If you accept the license agreement, answer `a`. The chart can be installed without this acceptance.                                  |
| Which namespace do you want to install in?                    | Namespace name same as previous `{namespace_name}`                                                                                    |
| Where the Docker repository                                   | `{cluster_CA_domain}:8500/{namespace_name}`.                                                                                          |
| Which StorageClass do you want to use                         | `NFS` or `local-storage`                                                                                                              |
| [In using NFS only] NFS server IP or hostname, and mount path | Your NFS server IP or hostname, and mount path.                                                                                       |

## Installing the Chart into ICP4D on OpenShift

### Setup environment

1. SSH login to a master node

1. Login to your cluster.

    ```bash
    oc login -u {user} -p {password}
    ```
    See the [Basic Setup and Login](https://docs.openshift.com/container-platform/3.11/cli_reference/get_started_cli.html#basic-setup-and-login) for more detail

1. Create a new OpenShift project.

    Create a new project with [`restricted`](https://docs.openshift.com/enterprise/3.0/architecture/additional_concepts/authorization.html#security-context-constraints) SCC. For example, you can create the new project by the following command. No operation to change SCC is required because default SCC is `restricted`.
    ```bash
    oc new-project {namespace_name} --description="{description_text}" --display-name="{display_name}"
    ```
    - `{namespace_name}` is name of creating project. This command also creates namespace named same as the project.
    - `{description_text}` is text to set as description of this project.
    - `{display_name}` is string to set as display name of this project.

    See the [Projects](https://docs.openshift.com/container-platform/3.11/dev_guide/projects.html) and [Add an SCC to a User, Group, or Project](https://docs.openshift.com/container-platform/3.11/admin_guide/manage_scc.html#add-scc-to-user-group-project) for more detail.

1. Login to the docker registry like the following.

    ```bash
    docker login docker-registry.default.svc:5000 -u $(oc whoami) -p $(oc whoami -t)
    ```

1. Change target namespace

    ```bash
    oc project {namespace_name}
    ```

    - `{namespace_name}` is the namespace you created in Step 3.

1. To meet network security policy for ICP4D addon, update label of the namespaces by the following 2 commands.

    ```bash
    kubectl label --overwrite namespace zen ns=zen
    kubectl label --overwrite namespace {namespace_name} ns={namespace_name}
    ```

### Deployment

To install the addon, run the following command:

```bash
oc get secret | grep -Eo 'default-dockercfg[^ ]*' | xargs -n 1 oc get secret -o yaml | sed 's/default-dockercfg[^ ]*/sa-{namespace_name}/g' | oc create -f -
cd /ibm/InstallPackage/components/
./deploy.sh -o -d {compressed_file_name} -e {release_name_postfix}
```

- `{compressed_file_name}` is the name of the file that you downloaded from Passport Advantage.
- `{release_name_postfix}` is the postfix of Helm release name of this installation.

The first command line creates a copy of `default-dockercfg-****` secret named `sa-{namespace_name}` used in the installation.

`deploy.sh` command will interactively ask you the following information, so answer like the following.

| Question                                                     | Answer                                                                                                                                |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| Do you agree with the terms and conditions in {license_URL}? | If you accept the license agreement, answer `a`. The chart can be installed without this acceptance.                                  |
| Which namespace do you want to install in?                   | Namespace name same as previous `{namespace_name}`                                                                                    |
| Where the Docker repository                                  | `docker-registry.default.svc:5000/{namespace_name}`.                                                                                  |
| Which StorageClass do you want to use                        | `NFS`                                                                                                                                 |
| NFS server IP or hostname, and mount path                    | Your NFS server IP or hostname, and mount path.                                                                                       |


If you meet `ErrImagePull` error in the addon installation, try the followoing command to update the secret `sa-{namespace_name}`.

```bash
oc delete secret sa-{namespace_name}
oc get secret | grep -Eo 'default-dockercfg[^ ]*' | xargs -n 1 oc get secret -o yaml | sed 's/default-dockercfg[^ ]*/sa-{namespace_name}/g' | oc create -f -
```


## Verification of deployment

After installation completed successfully, you can verify the deployment by running `helm test`.

```bash
helm test {release_name} --cleanup --timeout 600 --tls
```

### Accessing WKS tooling UI

After the successful installation, a WKS add-on tile with the release name is shown up on your ICP4D console. You can provision a WKS instance and launch your WKS tooling application there.

1. Open `https://{cluster_CA_domain}:31843` by your web browser and login to ICP4D console.

1. Move to Add-on catalog. You can find the add-on of IBM Watson Knowledge Studio with the release name.

1. Click the Watson Knowledge Studio add-on tile and provision an instance.

1. Open the created instance and click `Launch Tool` button.

1. You can start using IBM Watson Knowledge Studio.

## Uninstalling the chart

1. Delete the existing WKS instances of the release on ICP4D console.

1. Run the following command to uninstall and delete the existing release.

    ```bash
    helm delete --tls {release_name}
    ```

    - `{release_name}` is the Helm release name of this installation.

    To irrevocably uninstall and delete the release, run the following command:

    ```bash
    helm delete --tls --no-hooks --purge {release_name}
    ```

If you omit the `--purge` option, Helm deletes all resources for the deployment but retains the record with the release name. This approach allows you to roll back the deletion. If you include the `--purge` option, Helm removes all records for the deployment so that the name can be used for another installation.

Before you can install a new version of the service on the same cluster, you must remove all content from any persistent volumes and persistent volume claims that were used for the previous deployment.

## Configuration

The following table lists the configurable parameters of the WKS chart and their default values.
These value can be changed on installation by specifying `-O` option of `deploy.sh`. For example, `./deploy.sh -O your_override_values.yaml`.

### Global parameters

|    Parameter    |                                              Description                                              |     Default     |
| --------------- | ----------------------------------------------------------------------------------------------------- | --------------- |
| `license`       | Set `accept` if you accept the license agreement. The chart can be installed without this acceptance. | `""`            |
| `global.clusterDomain` | Cluster domain used by Kubernetes Cluster (the suffix for internal KubeDNS names).                    | `cluster.local` |
| `cp4dConsolePort` | Port number of ICP4D console.                    | `31843` |

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
| `sireg.languages.en.enabled`                                | Toggle language support for English                                                                                                                                                            | `true`  |
| `sireg.languages.es.enabled`                                | Toggle language support for Spanish                                                                                                                                                            | `true`  |
| `sireg.languages.ar.enabled`                                | Toggle language support for Arabic                                                                                                                                                             | `true`  |
| `sireg.languages.de.enabled`                                | Toggle language support for German                                                                                                                                                             | `true`  |
| `sireg.languages.fr.enabled`                                | Toggle language support for French                                                                                                                                                             | `true`  |
| `sireg.languages.it.enabled`                                | Toggle language support for Italian                                                                                                                                                            | `true`  |
| `sireg.languages.ja.enabled`                                | Toggle language support for Japanese                                                                                                                                                           | `true`  |
| `sireg.languages.ko.enabled`                                | Toggle language support for Korean                                                                                                                                                             | `true`  |
| `sireg.languages.nl.enabled`                                | Toggle language support for Dutch                                                                                                                                                              | `true`  |
| `sireg.languages.pt.enabled`                                | Toggle language support for Portuguese                                                                                                                                                         | `true`  |
| `sireg.languages.zh.enabled`                                | Toggle language support for Chinese (simplified)                                                                                                                                               | `true`  |
| `sireg.languages.zht.enabled`                               | Toggle language support for Chinese (traditional)                                                                                                                                              | `true`  |

### MMA parameters

|   Parameter    |        Description         | Default |
| -------------- | -------------------------- | ------- |
| `mma.replicas` | Number of replicas for MMA | `2`     |

### MongoDB parameters

|                 Parameter                 |                                            Description                                             |      Default      |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------- | ----------------- |
| `mongodb.replicas`                        | Number of replicas for MongoDB StatefulSet.                                                       | `2`               |
| `mongodb.persistentVolume.enabled`        | If `true`, persistent volume claims are created for MongoDB.                                       | `true`            |
| `mongodb.persistenceVolume.useDynamicProvisioning` | If enabled, the PVC will use a storageClassName to bind the volume for MongoDB.                                                                                                                                                                         | `true`         |
| `mongodb.persistentVolume.storageClass`   | Persistent volume storage class for MongoDB.                                                       | `local-storage`              |
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
| `minio.persistence.size`                   | Size of persistent volume claim (PVC) for Minio.                                                                                                                                                                                                      | `10Gi`          |
| `minio.persistence.storageClass`           | Storage Class to bind PVC for Minio.                                                                                                                                 | `local-storage`          |
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
| `postgresql.persistence.storageClassName`       | Storage class name of backing PVC                                                                                                                                                                                                                                                | `local-storage` |
| `postgresql.persistence.accessMode`             | Persistent volume storage class for PostgreSQL.                                                                                                                                                                                                                                              | `ReadWriteOnce` |
| `postgresql.persistence.size`                   | Size of data volume                                                                                                                                                                                                                                                              | `10Gi`          |
| `postgresql.dataPVC.name`                       | Prefix that gets the created Persistent Volume Claims                                                                                                                                                                                                                            | `stolon-data`   |
| `postgresql.dataPVC.selector.label`             | In case the persistence is enabled and useDynamicProvisioning is disabled the labels can be used to automatically bound persistent volumes claims to precreated persistent volumes. The persistent volumes to be used must have the specified label. Disabled if label is empty. | `""`            |
| `postgresql.dataPVC.selector.value`             | In case the persistence is enabled and useDynamicProvisioning is disabled the labels can be used to automatically bound persistent volumes claims to precreated persistent volumes. The persistent volumes to be used must have label with the specified value.                  | `""`            |

## Limitations

- Only the `x86` architecture is supported.
- The chart must be installed by a cluster administrator.

## Documentation

Find out more about IBM Watson Knowledge Studio by reading the [product documentation](https://cloud.ibm.com/docs/services/watson-knowledge-studio-data?topic=watson-knowledge-studio-data-wks_overview_full).

**Note**: The documentation link takes you out of IBM Cloud Private to the public IBM Cloud.
