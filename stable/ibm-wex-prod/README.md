# IBM Watson Explorer Chart

## Introduction

IBM Watson Explorer is a cognitive exploration and content analysis platform that lets you listen to your data for advice. Explore and analyze structured, unstructured, internal, external and public content to uncover trends and patterns that improve decision-making, customer service and return on investment. Leverage built-in cognitive capabilities powered by machine learning models, natural language processing and next-generation APIs to unlock hidden value in all your data.

See also [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/explorer_onewex.html).

## Chart Details

This chart deploys IBM Watson Explorer. See [Architecture](https://www.ibm.com/support/knowledgecenter/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/c_arch_onewex.html) for its services to be deployed.

## Prerequisites

* IBM Cloud Private version 3.1.2 or 3.2

## Required Role
`Cluster Administrator` is required to create Persistent Volumes.
`Administrator` or `Cluster Administrator` is required to install the oneWEX chart.

## Resources Required

### CPU, memory and storage

Required CPU, memory and storage for default configuration are below. See Configuration section and [System requirements](https://www.ibm.com/support/knowledgecenter/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/c_plan_install_onewex.html) for detail.
* 12 CPU
* 30GB Memory
* 460GB Storage

### Persistent Volumes

If you don't use dynamic persistent volume provisioning,
8 persistent volumes (PVs) with the following specs are required at a minimal configuration. If you increase number of replicas of the services, more PVs need to be created. See following table which fields are corresponding to PV. For field of the service, refer to Configuration section.

| Service name | PV         |
| ------------ | ---------- |
| Config       | wex-config |
| Discovery    | wex-index  |
| HDP worker   | wex-hdp-dn |

Note that labels `assign-to: "wex-*"` are used to select a PV by a Pod of IBM Watson Explorer deployment. (e.g. a Pod of IBM Watson Explorer Config StatefulSet tries to use a PV with label `assign-to: "wex-config"`.) If you are deploying multiple instances, add an additional label to the PVs so that an IBM Watson Explorer instance can select proper PVs. (e.g. `deployment: "instance-1"`)

1. Three `wex-config` persistent volumes:
    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: wex-config-0
      labels:
        assign-to: "wex-config"
        # deployment: "instance-1"
    spec:
      capacity:
        storage: "10Gi"
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      nfs:
        server: <NFS Server>
        path: <NFS PATH>/wex-config-0
    ---
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: wex-config-1
      labels:
        assign-to: "wex-config"
        # deployment: "instance-1"
    spec:
      capacity:
        storage: "10Gi"
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      nfs:
        server: <NFS Server>
        path: <NFS PATH>/wex-config-1
    ---
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: wex-config-2
      labels:
        assign-to: "wex-config"
        # deployment: "instance-1"
    spec:
      capacity:
        storage: "10Gi"
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      nfs:
        server: <NFS Server>
        path: <NFS PATH>/wex-config-2
    ```

2. One `wex-data` persistent volume:
    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: wex-data
      labels:
        assign-to: "wex-data"
        # deployment: "instance-1"
    spec:
      capacity:
        storage: "100Gi"
      accessModes:
        - ReadWriteMany
      persistentVolumeReclaimPolicy: Retain
      nfs:
        server: <NFS Server>
        path: <NFS PATH>/wex-data
    ```

3. One `wex-index` persistent volume:
    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: wex-index-0
      labels:
        assign-to: "wex-index"
        # deployment: "instance-1"
    spec:
      capacity:
        storage: 100Gi
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      nfs:
        server: <NFS Server>
        path: <NFS PATH>/wex-index-0
    ```

4. One `wex-hdp-nn` persistent volume:
    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: wex-hdp-nn-0
      labels:
        assign-to: "wex-hdp-nn"
        # deployment: "instance-1"
    spec:
      capacity:
        storage: "10Gi"
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      nfs:
        server: <NFS Server>
        path: <NFS PATH>/wex-hdp-nn-0
    ```

5. Two `wex-hdp-dn` persistent volumes:
    ```yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: wex-hdp-dn-0
      labels:
        assign-to: "wex-hdp-dn"
        # deployment: "instance-1"
    spec:
      capacity:
        storage: "100Gi"
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      nfs:
        server: <NFS Server>
        path: <NFS PATH>/wex-hdp-dn-0
    ---
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: wex-hdp-dn-1
      labels:
        assign-to: "wex-hdp-dn"
        # deployment: "instance-1"
    spec:
      capacity:
        storage: "100Gi"
      accessModes:
        - ReadWriteOnce
      persistentVolumeReclaimPolicy: Retain
      nfs:
        server: <NFS Server>
        path: <NFS PATH>/wex-hdp-dn-1
    ```

**For NFS, you need to configure it as follows before deploying the PVs**
- Create each of the directories manually.
- Export the directories with `no_root_squash` option.
- Change their file permissions to `777`.

```
<NFS PATH>/wex-config-0
<NFS PATH>/wex-config-1
<NFS PATH>/wex-config-2
<NFS PATH>/wex-data
<NFS PATH>/wex-index-0
<NFS PATH>/wex-hdp-nn-0
<NFS PATH>/wex-hdp-dn-0
<NFS PATH>/wex-hdp-dn-1
```

An additional PV is needed if you are using File system crawler, or other crawlers which require external files. Create a PV with label `assign-to: "wex-userdata"` (default value). The label value can be specified when WEX is deployed.
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: wex-data-source
  labels:
    assign-to: "wex-userdata"
spec:
  capacity:
    storage: "10Gi"
  accessModes:
    - ReadOnlyMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: <NFS Server>
    path: <NFS PATH>/wex-data-source
```

You can create the PVs using the above templates by executing:

```
kubectl create -f <yaml-file>
```

### Secret for initial administrator password

Initial administrator password can be configured using `Secret` resource. If the password is not configured by `Secret`, default password is used. Steps to configure initial administrator password are following.

1. Prepare a `Secret` yaml file and execute `kubectl create -f <Secret yaml file>`. See [Secrets - Kubernetes](https://kubernetes.io/docs/concepts/configuration/secret/) for detail.

```yaml
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: ibm-wex-prod-admin-secret
data:
  password: YOUR_ADMINISTRATOR_PASSWORD_BASE64_ENCODED
```

2. When a `ibm-wex-prod` release is created, set `general.adminInitialPasswordSecret.create` to `true` and `general.adminInitialPasswordSecret.create` to your secret name (e.g. `ibm-wex-prod-admin-secret`).

## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: policy/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-wex-prod-psp
    spec:
      privileged: false
      allowPrivilegeEscalation: true
      allowedCapabilities:
      - CHOWN
      - AUDIT_WRITE
      - DAC_OVERRIDE
      - FOWNER
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
      - SYS_CHROOT
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      runAsUser:
        rule: RunAsAny
      fsGroup:
        rule: RunAsAny
      readOnlyRootFilesystem: false
      volumes:
      - configMap
      - emptyDir
      - persistentVolumeClaim
      - secret
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-wex-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-wex-prod-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```

- The cluster admin can either paste the above PSP and ClusterRole definitions into the create resource screen in the UI or run the following two commands:
  ```
  kubectl create -f <PSP yaml file>
  kubectl create clusterrole ibm-wex-prod-clusterrole --verb=use --resource=podsecuritypolicy --resource-name=ibm-wex-prod-psp
  ```

You can run the Pods with service account `default` of the namespace bound to `ibm-anyuid-psp` or a service account bound to the custom PodSecurityPolicy. Here is an example setup.

```
# Create a namespace.
kubectl create namespace wex

# Create serviceaccount "wex-sa" in the namespace.
kubectl create serviceaccount -n wex wex-sa

# Set up a Secret to pull docker images.
kubectl create secret docker-registry -n wex myregistrykey \
    --docker-server=mycluster.icp:8500 \
    --docker-username=DOCKER_REGISTRY_USER \
    --docker-password=DOCKER_REGISTRY_PASSWORD \
    --docker-email=wex@ibm
kubectl patch serviceaccount wex-sa -p '{"imagePullSecrets": [{"name":"myregistrykey"}]}'

# Bind the service account and the cluster role. You can also bind the service account and a role.
kubectl create rolebinding -n wex wex-sa-psp-rolebinding \
    --clusterrole=ibm-wex-prod-clusterrole \
    --serviceaccount=wex:wex-sa
```

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-wex-prod-scc
    allowPrivilegeEscalation: true
    allowedCapabilities:
    - AUDIT_WRITE
    - CHOWN
    - DAC_OVERRIDE
    - FOWNER
    - SETUID
    - SETGID
    - NET_BIND_SERVICE
    - SYS_CHROOT
    fsGroup:
      type: RunAsAny
    readOnlyRootFilesystem: false
    runAsUser:
      type: RunAsAny
    seLinuxContext:
      type: RunAsAny
    supplementalGroups:
      type: RunAsAny
    volumes:
    - configMap
    - emptyDir
    - persistentVolumeClaim
    - secret
    ```

For the installation procedure and further information, refer to [Installing Watson Explorer oneWEX on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/t_onewex_install_icp.html).

## Installing the Chart

IBM Watson Explorer can be installed using package from Passport Advantage. See [Installing Watson Explorer oneWEX on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/t_onewex_install_icp.html) for the procedure.

## Configuration

The following tables lists the configurable parameters and their default values.

### General parameters

| Parameter                                    | Label                                              | Description                                                                                                                                                                                              | Default   |
| -------------------------------------------- | -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| `general.service.externalPort`               | **External port**                                  | Port where Watson Explorer is exposed like `https://<externalIP>:<externalPort>`. Change the port number when multiple instances will be deployed. See Notes of instance for detail.                     | `30443`   |
| `general.persistence.useDynamicProvisioning` | **Dynamic Provisioning**                           | Flag to create persistent volumes by dynamic provisioning. Set this value to `true` if dynamic provisioning is enabled on your cluster and you want to create persistent volume by dynamic provisioning. | `false`   |
| `general.persistence.storageClassName`       | **Storage class name**                             | Class name of persistent volumes. If this value is empty, default storage class name is used.                                                                                                            | `<empty>` |
| `general.persistence.selector.label`         | **Name of the additional label**                   | Additional label for persistent volumes. Set a value when multiple instances will be deployed.                                                                                                           | `<empty>` |
| `general.persistence.selector.value`         | **Value of the additional label**                  | Value of additional label for persistent volumes. Set a value when multiple instances will be deployed.                                                                                                  | `<empty>` |
| `general.mount.enabled`                      | **User volume**                                    | Mount user volume (e.g. for File system crawler). Set this value to `true` when you want to use File system crawler.                                                                                     | `false`   |
| `general.serviceAccount.name`                | **Service Account name**                           | Service account name to run the Pods.                                                                                                                                                                    | `default` |
| `general.networkPolicy.enabled`              | **Network Policy**                                 | Enable Network Policy to limit traffic. Only Gateway pod can be accessed from outside of the cluster.                                                                                                    | `true`    |
| `general.adminInitialPasswordSecret.use`  | **Use administrator initial password Secret**      | Select this checkbox to use Secret for administrator initial password configuration.                                                                                                                     | `false`   |
| `general.adminInitialPasswordSecret.name`    | **Secret name for administrator initial password** | Input Secret name for administrator initial password configuration.                                                                                                                                      | `<empty>` |

### Persistence parameters

| Parameter                       | Service / Label                   | Description                         | Default |
| ------------------------------- | --------------------------------- | ----------------------------------- | ------- |
| `orchestrator.persistence.size` | **Orchestrator** / Storage size   | Storage size of home data store     | `100Gi` |
| `config.persistence.size`       | **Config** / Storage size         | Storage size of configuration store | `10Gi`  |
| `discovery.persistence.size`    | **Discovery** / Storage size      | Storage size of index data store    | `100Gi` |
| `hdp.nn.persistence.size`       | **HDP** / Name Node: Storage size | Storage size for Name Node          | `10Gi`  |
| `hdp.worker.persistence.size`   | **HDP** / Worker: Storage size    | Storage size for Worker             | `100Gi` |

### Resources parameters

In each service, request for CPU/memory and limit of CPU/memory can be configured. Change values of "CPU request", "Memory request", "CPU limit" and "Memory limit".

See [Kubernetes Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource/) for detail.

| Parameter                                | Service / Label                                  | Description                                                                                                                                      | Default |
| ---------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `gateway.resources.requests.cpu`         | **Gateway** / CPU request                        | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `1000m` |
| `gateway.resources.requests.memory`      | **Gateway** / Memory request                     | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`   |
| `gateway.resources.limits.cpu`           | **Gateway** / CPU limit                          | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `gateway.resources.limits.memory`        | **Gateway** / Memory limit                       | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `4Gi`   |
| `orchestrator.resources.requests.cpu`    | **Orchestrator** / CPU request                   | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `1000m` |
| `orchestrator.resources.requests.memory` | **Orchestrator** / Memory request                | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`   |
| `orchestrator.resources.limits.cpu`      | **Orchestrator** / CPU limit                     | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `orchestrator.resources.limits.memory`   | **Orchestrator** / Memory limit                  | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `4Gi`   |
| `database.resources.requests.cpu`        | **Database** / CPU request                       | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `750m`  |
| `database.resources.requests.memory`     | **Database** / Memory request                    | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`   |
| `database.resources.limits.cpu`          | **Database** / CPU limit                         | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `database.resources.limits.memory`       | **Database** / Memory limit                      | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `4Gi`   |
| `config.resources.requests.cpu`          | **Config** / CPU request                         | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `750m`  |
| `config.resources.requests.memory`       | **Config** / Memory request                      | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`   |
| `config.resources.limits.cpu`            | **Config** / CPU limit                           | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `config.resources.limits.memory`         | **Config** / Memory limit                        | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `4Gi`   |
| `nlp.resources.requests.cpu`             | **Natural Language Processing** / CPU request    | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `1000m` |
| `nlp.resources.requests.memory`          | **Natural Language Processing** / Memory request | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`   |
| `nlp.resources.limits.cpu`               | **Natural Language Processing** / CPU limit      | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `nlp.resources.limits.memory`            | **Natural Language Processing** / Memory limit   | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `4Gi`   |
| `discovery.resources.requests.cpu`       | **Discovery** / CPU request                      | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `1000m` |
| `discovery.resources.requests.memory`    | **Discovery** / Memory request                   | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `1Gi`   |
| `discovery.resources.limits.cpu`         | **Discovery** / CPU limit                        | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `discovery.resources.limits.memory`      | **Discovery** / Memory limit                     | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `6Gi`   |
| `hdp.nn.resources.requests.cpu`          | **HDP** / Name Node: CPU request                 | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `500m`  |
| `hdp.nn.resources.requests.memory`       | **HDP** / Name Node: Memory request              | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`   |
| `hdp.nn.resources.limits.cpu`            | **HDP** / Name Node: CPU limit                   | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `hdp.nn.resources.limits.memory`         | **HDP** / Name Node: Memory limit                | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `4Gi`   |
| `hdp.rm.resources.requests.cpu`          | **HDP** / Resource Manager: CPU request          | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `500m`  |
| `hdp.rm.resources.requests.memory`       | **HDP** / Resource Manager: Memory request       | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`   |
| `hdp.rm.resources.limits.cpu`            | **HDP** / Resource Manager: CPU limit            | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `hdp.rm.resources.limits.memory`         | **HDP** / Resource Manager: Memory limit         | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `4Gi`   |
| `hdp.worker.resources.requests.cpu`      | **HDP** / Worker: CPU request                    | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `500m`  |
| `hdp.worker.resources.requests.memory`   | **HDP** / Worker: Memory request                 | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`   |
| `hdp.worker.resources.limits.cpu`        | **HDP** / Worker: CPU limit                      | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `hdp.worker.resources.limits.memory`     | **HDP** / Worker: Memory limit                   | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `4Gi`   |
| `ingestion.resources.requests.cpu`       | **Ingestion** / CPU request                      | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `500m`  |
| `ingestion.resources.requests.memory`    | **Ingestion** / Memory request                   | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`   |
| `ingestion.resources.limits.cpu`         | **Ingestion** / CPU limit                        | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `ingestion.resources.limits.memory`      | **Ingestion** / Memory limit                     | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `4Gi`   |
| `wksml.resources.requests.cpu`           | **WKS ML Model Service** / CPU request           | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).      | `500m`  |
| `wksml.resources.requests.memory`        | **WKS ML Model Service** / Memory request        | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `2Gi`   |
| `wksml.resources.limits.cpu`             | **WKS ML Model Service** / CPU limit             | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core).        | `99`    |
| `wksml.resources.limits.memory`          | **WKS ML Model Service** / Memory limit          | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki.          | `4Gi`   |

### Replicas parameters

There are some services that offer the option to have several instances of the same service running for High Availability and performance. See [Architecture](https://www.ibm.com/support/knowledgecenter/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/c_arch_onewex.html) for detail.

| Parameter            | Service / Label                                      | Description                                                                                          | Default |
| -------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ------- |
| `gateway.replica`    | **Gateway** / Number of replicas                     | The number of replicas of Web UI and REST API services.                                              | `2`     |
| `nlp.replica`        | **Natural Language Processing** / Number of replicas | The number of replicas of realtime Natural Language Processing services.                             | `1`     |
| `config.replica`     | **Config** / Number of replicas                      | The number of replicas of configuration management services. An odd number (e.g. `3`) is acceptable. | `3`     |
| `discovery.replica`  | **Discovery** / Number of replicas                   | The number of replicas of Exploration and Discovery services.                                        | `1`     |
| `hdp.worker.replica` | **HDP worker** / Number of replicas                  | The number of replicas of Machine Learning and Data Enrichments services.                            | `2`     |
| `ingestion.replica`  | **Ingestion** / Number of replicas                   | The number of replicas of Ingestion services.                                                        | `1`     |
| `wksml.replica`      | **WKS ML Model Service** / Number of replicas        | The number of replicas of WKS ML model services.                                                     | `1`     |

### AntiAffinity parameters

**Gateway**, **Config**, **Natural Language Processing**, **Discovery**, **HDP worker**, **Ingestion** and **WKS ML Model Service** have `antiAffinity` parameter. Acceptable values and their effect are as follows. If you choose `hard`, number of nodes must be greater than largest number of replicas of the services.

| Parameter                 | Service / Label                                              | Description                                                                        | Default |
| ------------------------- | ------------------------------------------------------------ | ---------------------------------------------------------------------------------- | ------- |
| `gateway.antiAffinity`    | **Gateway** / AntiAffinity configuration                     | Anti-affinity policy for gateway pod. soft or hard can be set.                     | `soft`  |
| `config.antiAffinity`     | **Config** / AntiAffinity configuration                      | Anti-affinity policy for config pod. soft or hard can be set.                      | `soft`  |
| `nlp.antiAffinity`        | **Natural Language Processing** / AntiAffinity configuration | Anti-affinity policy for Natural Language Processing pod. soft or hard can be set. | `soft`  |
| `discovery.antiAffinity`  | **Discovery** / AntiAffinity configuration                   | Anti-affinity policy for discovery pod. soft or hard can be set.                   | `soft`  |
| `hdp.worker.antiAffinity` | **HDP** / Worker: AntiAffinity configuration                 | Anti-affinity policy for HDP worker pod. soft or hard can be set.                  | `soft`  |
| `ingestion.antiAffinity`  | **Ingestion** / AntiAffinity configuration                   | Anti-affinity policy for ingestion pod. soft or hard can be set.                   | `soft`  |
| `wksml.antiAffinity`      | **WKS ML Model Service** / AntiAffinity configuration        | Anti-affinity policy for WKS ML Model Service pod. soft or hard can be set.        | `soft`  |

| Value    | Description                                                                                                  |
| -------- | ------------------------------------------------------------------------------------------------------------ |
| **soft** | Tries to create the pods on nodes not to co-locate them, but it will not be guaranteed.                      |
| **hard** | Tries to create the pods on nodes not to co-locate them and will not create the pods in case of co-location. |

### Other parameters

Other parameters are as follows. Refer to [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/c_onewex_icp_helm.html) for detail.

| Parameter                              | Service /  Label                                                | Description                                                                                                                                                  | Default        |
| -------------------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------- |
| `config.minAvailable`                  | **Config** / Number of minimum available Pod                    | Minimum number of available Config pod. Set the value to the same number as **Number of replicas** for stability or a smaller number for your customization. | `3`            |
| `discovery.minAvailable`               | **Discovery** / Number of minimum available Pod                 | Minimum number of available Discovery pod. Set the value to the same number as **Number of replicas** for stability.                                         | `1`            |
| `nlp.minAvailable`                     | **NLP** / Number of minimum available Pod                       | Minimum number of available Natural Language Processing Pod.                                                                                                 | `1`            |
| `ingestion.minAvailable`               | **Ingestion** / Number of minimum available pod                 | Minimum number of available ingestion pod. Set the value to the same number as **Number of replicas** for stability.                                         | `1`            |
| `hdp.dfsReplication`                   | **HDP** / Number of replicas of saved data                      | Number of replicas of data saved on **HDP name node** and **HDP worker** pods. Set the value to a number greater than or equal to `2` to avoid data loss     | `2`            |
| `hdp.worker.nm.memoryMB`               | **HDP** / Available memory of HDP worker process                | Memory size used by a task executed on **HDP worker**                                                                                                        | `4096`         |
| `hdp.worker.nm.cpu`                    | **HDP** / Available CPU cores of HDP worker process             | Number of CPU cores used by a task executed on **HDP worker**                                                                                                | `8`            |
| `ingestion.mount.label`                | **Ingestion** / Label name of user volume                       | Label assigned to volume used for File system crawler. Set the value to a label of PV you created to crawl user data.                                        | `wex-userdata` |
| `ingestion.numberOfCrawlerInstances`   | **Ingestion** / Number of Crawler instances                     | Number of crawler process executed in an ingestion pod.                                                                                                      | `3`            |
| `gateway.server.maxMemory`             | **Gateway** / Max memory size of server                         | Max memory size of application server in an Gateway pod.                                                                                                     | `1024m`        |
| `orchestrator.docproc.maxMemory`       | **Orchestrator** / Max memory size of Document Processor worker | Max memory size of Document Processor worker                                                                                                                 | `2g`           |
| `orchestrator.docproc.driverMaxMemory` | **Orchestrator** / Max memory size of Document Processor driver | Max memory size of Document Processor driver                                                                                                                 | `1g`           |
| `orchestrator.docproc.workerNum`       | **Orchestrator** / Number of Document Processor worker          | Number of Document Processor worker                                                                                                                          | `2`            |
| `config.minMemory`                     | **Config** / Minimum memory size of Config server               | Minimum memory size of Config server                                                                                                                         | `1g`           |
| `config.maxMemory`                     | **Config** / Max memory size of Config server                   | Max memory size of Config server                                                                                                                             | `2g`           |
| `discovery.maxMemory`                  | **Discovery** / Max memory size of Discovery server             | Max memory size of Discovery server                                                                                                                          | `4g`           |
| `hdp.maxMemoryMB`                      | **HDP** / Max memory size of server                             | Max memory size of server in MB. If the value is `1024`, the size will be `1024MB`.                                                                          | `1024`         |
| `hdp.yMaxMemoryMB`                     | **HDP** / Max memory size of resource manager                   | Max memory size of resource manager in MB. If the value is `1024`, the size will be `1024MB`.                                                                | `1024`         |
| `wksml.minAvailable`                   | **WKS ML Model Service** / Minimum number of available Pods     | Minimum number of available WKS Model Service Pod.                                                                                                           | `1`            |

## Upgrade / Recovery

### Upgrade
Refer to How to apply the fix pack section at [Upgrading Watson Explorer oneWEX on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/c_onewex_upgrading.html)

### Backup / Restore
Refer to [Backing up and restoring Watson Explorer oneWEX on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/t_backup_onewex_icp.html)

### Rollback
Refer to How to rollback section at [Upgrading Watson Explorer oneWEX on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/c_onewex_upgrading.html)

## Security
### Encrypting Secret Data at Rest
For ICP 3.2, refer to [Encrypting volumes by using dm-crypt](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/installing/etcd.html)
For ICP 3.1.2, refer to [Encrypting volumes by using dm-crypt](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/installing/etcd.html)

## Limitations
For limitations of scaled down for discovery component, refer to [Product and system architecture overview for Watson Explorer oneWEX on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/c_arch_onewex.html#prod_arch_onewex)
For other limitations and known issues, refer to [Release Notes](http://www.ibm.com/support/docview.wss?uid=swg27050305).

## Troubleshooting
Refer to [Troubleshooting](https://www.ibm.com/support/knowledgecenter/SS8NLW_12.0.0/com.ibm.watson.wex.ee.doc/c_onewex_trbl.html).
