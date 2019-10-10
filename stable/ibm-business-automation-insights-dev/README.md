# IBM Business Automation Insights Helm Chart, developer edition

## Introduction

This Helm chart deploys IBM Business Automation Insights, developer edition. IBM Business Automation Insights is a platform-level component that provides visualization insights to business owners and that feeds a data lake to infuse artificial intelligence into IBM Digital Business Automation.

You can read specific instructions for the installation on Minikube at https://github.com/icp4a/cert-kubernetes/blob/19.0.1/BAI/platform/minikube/README.md .

## Chart Details

This chart deploys:
  - An Apache Flink processing engine, which includes:
    - A [Kubernetes deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) which creates a pod running Flink job manager
    - A [Kubernetes statefulset](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) which creates pods running Flink task managers
    - A [Kubernetes statefulset](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) which creates pods running Apache Zookeeper
    - [Kubernetes jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) to register Flink jobs to the Flink job manager:
 
        - A processor for IBM Business Automation Workflow BPMN events
        - A processor for IBM Business Automation Workflow Advanced events
        - A processor for IBM Case Manager events
        - A processor for IBM Operational Decision Manager events
        - A processor for IBM Content Platform Engine events
  - A [Kubernetes job](https://kubernetes.io/docs/concepts/workloads/controllers/job/) which initializes Kafka topics and Elasticsearch/Kibana data.
  - A [Kubernetes deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) which creates pods running the administration REST API.


## Prerequisites

* A Kubernetes cluster, version 1.11 or later
* Tiller 2.9.1 or later
* Persistent volumes for long-term storage
* Ideally, at least 3 amd64 Kubernetes nodes
* Elasticsearch resource needs are entirely based on your environment. For helpful information to plan the necessary resources, read the [capacity planning guide](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.0/manage_metrics/capacity_planning.html).
* An Apache Kafka cluster, version 1.0.x, 1.1.x, or 2.0.x


## Resources Required




By default, this Developer Edition of the Helm chart requires the following minimum resources:

| Component                                  | Number of replicas  | CPU/pod | Memory/pod (Mi) |
| ------------------------------------------ | ------------------- | ------- | --------------- |
| Flink task managers                        | 2**                 | 1       | 1280            |
| Flink job manager                          | 1                   | 0.1*    | 256*            |
| ZooKeeper                                  | 1                   | 0.1     | 640             |
| Administration REST API                    | 1                   | 0.003*  | 50*             |
| Setup Job                                  | 1                   | 0.2*    | 50*             |


The settings marked with an asterisk (*) can be configured.

(**) TaskManager replicas are added or removed depending on the number of installed processing jobs and their parallelism.


## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy resource to be bound to the target namespace before installation. To meet this requirement, you might have to scope a specific cluster and namespace.
The predefined PodSecurityPolicy resource named [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. If your target namespace is bound to it, you can proceed to install the chart.


However, since with this Developer Edition you have no other choice than to install Elasticsearch and Kibana as part of IBM Business Automation Insights through the `ibm-dba-ek` subchart, you must also set up the proper PodSecurityPolicy, Role, ServiceAccount, and RoleBinding Kubernetes resources to allow the pods running Elasticsearch to run privileged containers. The reason for this requirement is to meet the [production settings stated officially by the Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.7/system-config.html). To achieve this, you must set up a Custom PodSecurityPolicy definition:


1- Adapt the following YAML content to reference your Kubernetes namespace and Business Automation Insights Helm release name, and save it to a file as `bai-psp.yml`, which sets up the Custom PodSecurityPolicy definition:
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is required to allow `ibm-dba-ek` pods running Elasticsearch to use privileged containers."
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

If you cannot or do not want to allow running privileged Elasticsearch containers, you can still install IBM Business Automation Insights but you must configure it to use an external Elasticsearch (in the Helm values, set `elasticsearch.install: false`).

Note also that when deploying IBM Business Automation Insights on IBM Cloud, the Flink init container needs to be run as privileged, such that it can
change the ownership and permissions of its storage directory. For details, see https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot_storage#file_app_failures
and https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot_storage#cs_storage_nonroot. As it is not needed on other deployment platforms, the
initialization is not done by default. If required by the deployment platform, specify `flink.initStorageDirectory: true` in the Helm values.

_**If you are upgrading from a previous version of IBM Business Automation Insights, undo the previous security policy changes:**_
   - _If you are upgrading from 18.0.0, roll back the changes that you made through the `kubectl edit clusterrolebinding privileged-psp-users` command when you installed IBM Business Automation Insights 18.0.0. To achieve this, you must call again `kubectl edit clusterrolebinding privileged-psp-users` to edit the ClusterRoleBinding and delete the following lines:_

   ```
   - apiGroup: rbac.authorization.k8s.io
     kind: Group
     name: system:serviceaccounts:<NAMESPACE>
   ```

   - _If you are upgrading from IBM Business Automation Insights 18.0.1 or 18.0.2 , remove the ClusterRole and ClusterRoleBinding resources._

     ```
     kubectl delete clusterrole <your-clusterrole>     
     kubectl delete clusterrolebinding <your-clusterrole-binding>
     ```

## Network Policy

The deployment of IBM Business Automation Insights includes a default Kubernetes network policy which allows all ingress and egress traffic.
You can deploy more restrictive policies. For further information on network policies, see https://kubernetes.io/docs/concepts/services-networking/network-policies/.

## Red Hat OpenShift SecurityContextConstraints Requirements

If you are installing the chart on Red Hat OpenShift or OKD, the [ibm-anyuid-scc](https://ibm.biz/cpkspec-scc) SecurityContextConstraint is required to install the chart.

If you are planning to install Elasticsearch and Kibana as part of IBM Business Automation Insights on Red Hat OpenShift or OKD, you must also create a service account that has the [ibm-privileged-scc](https://ibm.biz/cpkspec-scc) SecurityContextConstraint to allow running privileged containers:
```
$ oc create serviceaccount <RELEASE_NAME>-bai-psp-sa
$ oc adm policy add-scc-to-user ibm-privileged-scc -z <RELEASE_NAME>-bai-psp-sa
```

If you cannot or do not want to allow running privileged containers, you can still install IBM Business Automation Insights but you must configure it to use an external Elasticsearch (in the Helm values, set `elasticsearch.install: false`).

## Storage

In the current section, `<nfs-shared-path>` is a path that is NFS-shared by the NFS server with IP equals to `<server-ip>`. You must ensure that your Kubernetes nodes have a very fast access to the NFS shared folders. Usually, the NFS share is set up on the master node of your Kubernetes cluster.

### IBM Business Automation Insights required storage
A persistent volume is required if no dynamic provisioning has been set up. It must provide enough space to fit the
`flinkPv.capacity` requirement in `values.yaml` (20Gi by default).

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ibm-bai-pv
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 20Gi
  nfs:
    path: <nfs-shared-path>/ibm-bai-pv
    server: <server-ip>
  persistentVolumeReclaimPolicy: Retain
  claimRef:
    namespace: <my-namespace>
    name: <my-pvc-name>
```

The persistent volume path must be readable and writable by the `bai` user and group under ID 9999. It is recommended to use the `Retain`
reclaim policy to make sure data is kept on release.

The chart automatically picks a volume that matches its requirements, which should be sufficient for evaluation purposes.

The `claimRef` section is optional but you must use it in production mode to make sure your release will always use the same
volume and not lose your data. The `claimRef` section and the `flinkPv.existingClaimName` property must then reference a
specific claim created as follows:

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: <my-pvc-name>
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: <storage_size>
```

### Setting up persistent volumes for Elasticsearch data
If you plan to install Elasticsearch and Kibana as part of IBM Business Automation Insights through the `ibm-dba-ek` subchart and if no dynamic provisioning has been set up, it is required that you create a persistent volume per data and master pods. For details, see the official documentation describing [how to setup Elasticsearch storage](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_preparing_bai_prereq_es.html)

## Documentation

The IBM Business Automation Insights online documentation is [here](https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_19.0.x/com.ibm.dba.bai/topics/con_bai_intro.html).

## Installing the Chart

To install the chart with release name `my-release`:

```console
$ helm install --name my-release ibm-business-automation-insights-dev -f my-values.yaml
```

The command deploys `ibm-business-automation-insights-dev` onto the Kubernetes cluster, based on the values specified in `my-values.yaml` file. The configuration section lists the parameters that can be configured during installation.

_**Note**: If you are running on IBM Cloud Private, you must add `--tls` argument to all `helm` commands referenced in this README._

## Verifying the Chart
See the instruction after the Helm installation completes for chart verification. You can also execute the following command to retrieve the instruction of the Helm release:

```console
$ helm status my-release
```

_**Note**: If you are running on IBM Cloud Private, you can also display the instruction by viewing the installed Helm release under Menu -> Workloads -> Helm Releases._

## Upgrading or rolling back the release

### Prerequisite

Before upgrading or rolling back the release, you must first delete all the Kubernetes jobs that are running:
- To retrieve the job names, run the Kubernetes get command:
```console
$ kubectl get jobs -–selector=release=<release-name> --namespace <my-namespace>
```
- Run the Kubernetes delete command on each job in the list.
```console
$ kubectl delete job <job-name> --namespace <my-namespace>
```

### Upgrading the release

To upgrade the release, execute the following command where `bai-values.yaml` contains the Helm values that you want to add or override. If you don't want or don't need to add or override Helm values, do not provide the `--values bai-values.yaml` argument:

```console
$ helm upgrade my-release ibm-business-automation-insights-dev --reuse-values --values bai-values.yaml
```


_**Important**: If the release upgrade also includes a new Helm chart version, **do not pass** the `--reuse-values` argument._

### Rolling back the release

You can roll back the Helm release to a previous revision.

To retrieve the release upgrade history, execute the following command:
```console
$ helm history my-release
```

You can roll back the current release to a previous version by executing the following helm command where `<REVISION>` is the upgrade revision from the release upgrade history:
```console
$ helm rollback my-release <REVISION>
```

## Uninstalling the Chart

To uninstall or delete the `my-release` deployment:

```console
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## Configuration

### General Configurations

Parameter                            | Description                        | Default value                     |
-------------------------------------|------------------------------------|-----------------------------------|
`persistence.useDynamicProvisioning` | Use Dynamic Provisioning           | `true`                            |
`settings.egress`                    | Enable Data Egress to Apache Kafka | `true`                            |
`settings.ingressTopic`              | Apache Kafka ingress topic         | `[Release name]-ibm-bai-ingress`   |
`settings.egressTopic`               | Apache Kafka egress topic          | `[Release name]-ibm-bai-egress`   |
`settings.serviceTopic`              | Apache Kafka service topic         | `[Release name]-ibm-bai-service`  |
`baiSecret`   | Name of a secret that is already deployed to Kubernetes. See below for details.  | `None` |

#### baiSecret

A secret which contains the following keys:

- `admin-username`: the username to authenticate against the admin REST API
- `admin-password`: the password to authenticate against the admin REST API
- `admin-key`: the private key in PEM format for secure communications with the administration service
- `admin-cert`: the certificate in PEM format for secure communications with the administration service
- `kafka-username`: the username to authenticate against Kafka
- `kafka-password`: the password to authenticate against Kafka
- `flink-ssl-keystore`: the keystore for secure communications with the Flink REST API
- `flink-ssl-truststore`:  the truststore for secure communications with the Flink REST API
- `flink-ssl-internal-keystore`: the keystore for inter-node communications in the Flink cluster
- `flink-ssl-password`: the password of Flink keystore and truststore
- `kafka-server-cert`: the certificate in PEM format for secure communication with Kafka  
- `kafka-ca-cert`: the CA certificate in PEM format for secure communication with Kafka
- `flink-security-krb5-keytab`: the Kerberos Keytab
- `elasticsearch-username`: the username for connection to the non-embedded Elasticsearch
- `elasticsearch-password`: the password for connection to the non-embedded Elasticsearch
- `elasticsearch-server-cert`: the certificate in PEM format for secure communication with Elasticsearch

_Note: The secret must hold a key for each of these keys, even if they are provided with no value in case they were not relevant in your Business Automation Insights configuration.
When calling `kubectl` to create a secret with empty values, you must turn validation off with the ` --validate=false` argument. For example:_
```
kubectl create -f bai-prereq-secret.yaml --validate=false
```

If `baiSecret` is defined, it overrides the following values:
- `admin.username`
- `admin.password`
- `kafka.username`
- `kafka.password`
- `kafka.serverCertificate`
- `kerberos.keytab`
- `elasticsearch.username`
- `elasticsearch.password`
- `elasticsearch.serverCertificate`

### Docker registry details

Parameter                   | Description              | Default value  |
----------------------------|--------------------------|----------------|
`imageCredentials.registry` | Docker registry URL      |     None       |
`imageCredentials.username` | Docker registry username |     None       |
`imageCredentials.password` | Docker registry password |     None       |
`imageCredentials.imagePullSecret` | The imagePullSecret for Docker images. See below for details. | None
`imagePullPolicy` | The pull policy for Docker images | None |

#### imageCredentials.imagePullSecret

An imagePullSecret for Docker images which overrides:
- `imageCredentials.registry`
- `imageCredentials.username`
- `imageCredentials.password`

Here is the command to create such secret:

```
kubectl create secret docker-registry regcred --docker-server=<docker_registry> --docker-username=<docker_username> --docker-password=<docker_password> --docker-email=<your email> -n <namespace>
```

### Apache Kafka

Parameter                         | Description                     | Default
----------------------------------|---------------------------------|--------
`kafka.bootstrapServers`          | Apache Kafka Bootstrap Servers. | `kafka.bootstrapserver1.hostname:9093,kafka.bootstrapserver2.hostname:9093,kafka.bootstrapserver3.hostname:9093`
`kafka.securityProtocol`          | Apache Kafka security.protocol property value | `SASL_SSL`
`kafka.saslKerberosServiceName`   | Apache Kafka sasl.kerberos.service.name property value |
`kafka.serverCertificate`         | Apache Kafka server certificate for SSL communications (base64 encoded) |
`kafka.username`                  | Apache Kafka username |
`kafka.password`                  | Apache Kafka password |
`kafka.propertiesConfigMap`       | Name of a ConfigMap already deployed to Kubernetes and containing Kafka consumer and producer properties. For details, see [Specifying a configuration map for Kafka properties](https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_19.0.x/com.ibm.dba.bai/topics/tsk_bai_flink_kub_config_maps_kafka.html) |


**Note: Kerberos is not available with the Developer Edition. It ignores the value of the `kafka.saslKerberosServiceName` parameter.**


### Elasticsearch settings

Parameter | Description | Default
----------|-------------|--------
`elasticsearch.install`                   | Whether Elasticsearch and Kibana should be deployed by using the `ibm-dba-ek` subchart. | `true`
`elasticsearch.url`       | Elasticsearch URL. This attribute is relevant only if you don't use the `ibm-dba-ek` subchart to install Elasticsearch.  |
`elasticsearch.username`       | Elasticsearch username. This attribute is relevant only if you don't use the `ibm-dba-ek` subchart to install Elasticsearch.  |
`elasticsearch.password`       | Elasticsearch password. This attribute is relevant only if you don't use the `ibm-dba-ek` subchart to install Elasticsearch.  |
`elasticsearch.version`       | _[deprecated as of 18.0.2]_ Elasticsearch version. This attribute is relevant only if you don't use the `ibm-dba-ek` subchart to install Elasticsearch.  |
`elasticsearch.serverCertificate` | Elasticsearch server certificate for SSL communications (base64 encoded). This attribute is relevant only if you set `Install Elasticsearch` to false.  |


**Note: The Developer Edition forces the `elasticsearch.install` value to `true`.**


### Setup job

Parameter | Description | Default
----------|-------------|--------
`setup.image.repository`           | Docker image name for the setup job | `bai-setup`
`setup.image.tag`           | Docker image version for the setup job | `19.0.2`

### Administration service
Parameter | Description | Default
----------|-------------|--------
`admin.image.repository`           | Docker image name for the Administration Service | `bai-admin`
`admin.image.tag`           | Docker image version for the Administration Service | `19.0.2`
`admin.replicas`          | Number of Administration Service replicas | `1`
`admin.username`           | Sets the user name to the Administration Service | `admin`
`admin.password`           | Sets the password to the Administration Service API | `passw0rd`
`admin.serviceType`           | The way in which the Administration Service API should be exposed. Can be `NodePort` or `ClusterIP`. If you want to expose the service on Ingress, choose `ClusterIP` and after the Helm chart is deployed, create your own Ingress Kubernetes resource manually. | `NodePort`
`admin.externalPort`           | The port to which the Administration Service API will be exposed externally. Relevant only if `serviceType` is set to `NodePort`. |


**Note: The Developer Edition forces the `admin.replicas` value to `1`.**


### Apache Flink persistent volume

Parameter | Description | Default
----------|-------------|--------
`flinkPv.capacity`         | Persistent volume capacity                       | `20Gi`
`flinkPv.storageClassName` | Storage class name to be used if `persistence.useDynamicProvisioning` is `true`                      |
`flinkPv.existingClaimName`| By default, a new persistent volume claim is be created. Specify an existing claim here if one is available.                       |

### Apache Flink

Parameter | Description | Default
----------|-------------|--------
`flink.image.repository`         | Docker image name for Apache Flink | `bai-flink`
`flink.image.tag`                | Docker image version for Apache Flink | `19.0.2`
`flink.taskManagerHeapMemory`    | Apache Flink task manager heap memory (in megabytes). | 1024
`flink.taskManagerMemory`        | Apache Flink task manager total memory (in megabytes). It has to be greater than `flink.taskManagerHeapMemory`. | 1536
`flink.jobManagerMemoryRequest`  | The minimum memory required (including JVM heap and file system cache) to start the Apache Flink job manager (in megabytes). | 256
`flink.jobManagerCPURequest`     | The minimum amount of CPU required to start the Apache Flink job manager. | 100
`flink.jobManagerMemoryLimit`    | The maximum memory (including JVM heap and file system cache) for the Apache Flink job manager (in megabytes). | 1280
`flink.initStorageDirectory   `  | Whether the Flink storage directory needs to be initialized. When BAI is deployed on IBM Cloud, needs to be set to true to make possible the change of ownership and permissions for the storage directory using an init container running as privileged. | false
`flink.jobCheckpointingInterval` | Interval between checkpoints of Apache Flink jobs | `5000`
`flink.batchSize` | Batch size for bucketing sink storage | `268435456`
`flink.checkInterval` | How frequently (in ms) the job checks for inactive buckets | `300000`
`flink.bucketThreshold` | The minimum time (in ms) after which a bucket that doesn't receive new data is considered inactive | `900000`
`flink.storageBucketUrl` | The HDFS URL for long-term storage (e.g. `hdfs://<node_name>:<port>/bucket_path`) |
`flink.rocksDbPropertiesConfigMap` | Name of a ConfigMap already deployed to Kubernetes that contains advanced RocksDB properties |
`flink.log4jConfigMap` | Name of a configMap already deployed to Kubernetes that overrides the default bai-flink-log4j configMap |
`flink.hadoopConfigMap` | Name of a ConfigMap already deployed to Kubernetes that contains HDFS configuration (core-site.xml and hdfs-site.xml) |
`flink.zookeeper.image.repository`    | Docker image name for Apache Zookeeper | `bai-flink`
`flink.zookeeper.image.tag` | Docker image version for Apache Zookeeper | `19.0.2`
`flink.zookeeper.replicas`     | Number of Apache Zookeeper replicas | `1`


**Note: The Developer Edition always forces `flink.taskManagerHeapMemory` to 1024, `flink.taskManagerMemory` to 1536 and `flink.zookeeper.replicas` to `1`, and ignores the `flink.storageBucketUrl` value.**


### IBM Business Automation Workflow - BPMN Processing

Parameter | Description | Default
----------|-------------|--------
`bpmn.install`                   | Whether to enable processing of Business Process Model & Notation (BPMN) events. | `true`
`bpmn.image.repository`           | Docker image name for BPMN event processing. | `bai-bpmn`
`bpmn.image.tag`           | Docker image version for BPMN event processing | `19.0.2`
`bpmn.recoveryPath`           | The path to the savepoint or checkpoint from which a job will recover. You can use this path to restart the job from a previous state in case of failure. To use the default workflow of the job, leave this option empty. |
`bpmn.endAggregationDelay` | The delay in milliseconds before clearing the states used for summary transformation. | `10000`
`bpmn.parallelism` | The number of parallel instances (task managers) to use for running the processing job. |


**Note: The Developer Edition always forces the `bpmn.parallelism` value to 1.**


### IBM Business Automation Workflow - Advanced Processing

Parameter | Description | Default
----------|-------------|--------
`bawadv.install`                   | Whether to enable processing of Business Automation Workflow Advanced (BAW) events (for BPEL processes, human tasks...). | `true`
`bawadv.image.repository`           | Docker image name for BAW Advanced event processing. | `bai-bawadv`
`bawadv.image.tag`           | Docker image version for BAW Advanced event processing | `19.0.2`
`bawadv.recoveryPath`           | The path to the savepoint or checkpoint from which a job will recover. You can use this path to restart the job from a previous state in case of failure. To use the default workflow of the job, leave this option empty. |
`bawadv.parallelism` | The number of parallel instances (task managers) to use for running the processing job. |


**Note: The Developer Edition always forces the `bawadv.parallelism` value to 1.**


### IBM Business Automation Workflow - Case Processing

Parameter | Description | Default
----------|-------------|--------
`icm.install`                   | Whether to enable processing of IBM Case Manager (ICM) events. | `true`
`icm.image.repository`           | Docker image name for ICM events processing. | `bai-icm`
`icm.image.tag`           | Docker image version for ICM events processing | `19.0.2`
`icm.recoveryPath`           | The path to the savepoint or checkpoint from which a job will recover. You can use this path to restart the job from a previous state in case of failure. To use the default workflow of the job, leave this option empty. |
`icm.parallelism` | The number of parallel instances (task managers) to use for running the processing job. |


**Note: The Developer Edition always forces the `icm.parallelism` value to 1.**


### IBM Operational Decision Manager Processing

Parameter | Description | Default
----------|-------------|--------
`odm.install`                   | Whether to enable processing of IBM Operational Decision Manager (ODM) events. | `true`
`odm.image.repository`           | Docker image name for ODM event processing. | `bai-odm`
`odm.image.tag`           | Docker image version for ODM event processing | `19.0.2`
`odm.recoveryPath`           | The path to the savepoint or checkpoint from which a job will recover. You can use this path to restart the job from a previous state in case of failure. To use the default workflow of the job, leave this option empty. |
`odm.parallelism` | The number of parallel instances (task managers) to use for running the processing job. |


**Note: The Developer Edition always forces the `odm.parallelism` value to 1.**


### IBM Content Platform Engine Processing

Parameter | Description | Default
----------|-------------|--------
`content.install`                   | Whether to enable processing of IBM Content Platform Engine (Content) events. | `true`
`content.image.repository`           | Docker image name for Content event processing. | `bai-content`
`content.image.tag`           | Docker image version for Content event processing | `19.0.2`
`content.recoveryPath`           | The path to the savepoint or checkpoint from which a job will recover. You can use this path to restart the job from a previous state in case of failure. To use the default workflow of the job, leave this option empty. |
`content.parallelism` | The number of parallel instances (task managers) to use for running the processing job. |


**Note: The Developer Edition always forces the `content.parallelism` value to 1.**



### BAIW Processing

Parameter | Description | Default
----------|-------------|--------
`baiw.install`                   | Whether to enable processing of BAIW Platform Engine events. | `true`
`baiw.image.repository`           | Docker image name for BAIW event processing. | `bai-baiw`
`baiw.image.tag`           | Docker image version for BAIW event processing | `19.0.2`
`baiw.recoveryPath`           | The path to the savepoint or checkpoint from which a job will recover. You can use this path to restart the job from a previous state in case of failure. To use the default workflow of the job, leave this option empty. |
`baiw.parallelism` | The number of parallel instances (task managers) to use for running the processing job. |

**Note: The developer edition always forces `baiw.parallelism` to 1.**


### Raw Events Processing

Parameter | Description | Default
----------|-------------|--------
`ingestion.install`                   | Whether to enable processing of raw events. | `false`
`ingestion.image.repository`           | Docker image name for raw event processing. | `bai-ingestion`
`ingestion.image.tag`           | Docker image version for raw event processing | `19.0.2`
`ingestion.recoveryPath`           | The path to the savepoint or checkpoint from which a job will recover. You can use this path to restart the job from a previous state in case of failure. To use the default workflow of the job, leave this option empty. |
`ingestion.parallelism` | The number of parallel instances (task managers) to use for running the processing job. |


**Note: Raw event processing is not available with the Developer Edition. The `ingestion.install` value is always forced to `false`.**


### Kerberos Configuration

Parameter | Description | Default
----------|-------------|--------
`kerberos.enabledForKafka` | Set to true to enable Kerberos authentication to the Kafka server | `false`
`kerberos.enabledForHdfs` | Set to true to enable Kerberos authentication to the HDFS server | `false`
`kerberos.realm`      | Kerberos default realm name |
`kerberos.kdc`        | Kerberos key distribution center host |
`kerberos.principal`  | Sets the Kerberos principal to authenticate with |
`kerberos.keytab`     | Sets the Kerberos Keytab (base64 encoded) |


**Note: Kerberos is not available with the Developer Edition. `kerberos` parameter values are ignored.**


### Init Image Configuration

Parameter | Description | Default
----------|-------------|--------
`initImage.image.repository`           | Docker image name for initialization containers. | `bai-init`
`initImage.image.tag`           | Docker image version for initialization containers | `19.0.2`


### Elasticsearch-Kibana subchart
If `elasticsearch.install` is set to `true`, Elasticsearch and Kibana are deployed as the `ibm-dba-ek` subchart.

If you use the default setup, you can access Kibana by using the following credentials:
- admin:passw0rd
- demo:demo

You can set value definitions for the `ibm-dba-ek` subchart under the `ibm-dba-ek:` key. These attributes are relevant only if you 
use the `ibm-dba-ek` subchart to install Elasticsearch into Kubernetes (see `elasticsearch.install`). You can adapt the values for 
this subchart if you want to set up your own set of users or to update the deployment topology or persistent storage management.

For details, regarding the `ibm-dba-ek` subchart Helm values:
- [Elasticsearch parameters](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_bai_k8s_es_params.html)
- [Kibana parameters](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_bai_k8s_kibana_params.html)

## Limitations

Defining a high number of fields in an Elasticsearch index might lead to a so-called _mappings explosion_ which might cause
out-of-memory errors and difficult situations to recover from. The maximum number of fields in Elasticsearch indexes created
by IBM Business Automation Insights is set to 1000. Field and object mappings, and field aliases, count towards this limit.
Ensure that the various documents that are stored in Elasticsearch indexes do not lead to reaching this limit.


## Additional features in the production version

Additional features that are not available in the Developer Edition, are available in the production version of the charts:
* A raw events ingester, to store events in Hadoop Distributed File System (HDFS).
* Kerberos authentication to Kafka.
* The ability to use an external Elasticsearch and Kibana installation instead of installing them as part of
IBM Business Automation Insights through the `ibm-dba-ek` subchart.
* The ability to increase the number of replicas for the administration REST API and setup.

