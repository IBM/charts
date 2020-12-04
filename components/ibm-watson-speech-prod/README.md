# IBM Watson™ Speech Services 1.2

## Introduction

This document contains installation instructions for both IBM Watson™ Speech to Text and Text to Speech solutions.

IBM Watson™ Speech to Text (*STT*) provides speech recognition capabilities for your solutions. The service leverages machine learning to combine knowledge of grammar, language structure, and the composition of audio and voice signals to accurately transcribe the human voice. It continuously updates and refines its transcription as it receives more speech.

IBM Watson™ Text to Speech (*TTS*) converts written text to natural-sounding speech to provide speech-synthesis capabilities for applications. It gives you the freedom to customize your own preferred speech in different languages.

## Chart Details

This chart can be used to install a single instance of both the *STT* and *TTS* solutions. The solutions can be installed separately. However, if both are installed together, they share datastores for a more efficient utilization of resources and simplified support.

## Prerequisites

In addition to the system requirements for the cluster (see [System requirements](https://www.ibm.com/support/knowledgecenter/SSQNUZ_2.5.0/cpd/plan/rhos-reqs.html)), the Watson Speech Services have their own requirements.

The systems that host a deployment must meet these requirements:

- IBM Watson Speech Services for IBM Cloud Pak for Data can run on the `x86-64` architecture only.
- CPUs must support the AVX2 instruction set extension. See the [AVX Wikipedia page](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions) for a list of CPUs that include this support. 

- For Speech-to-Text, 11 CPU cores and 40 GB of memory are required for the minimum configuration (development).
- For Text-to-Speech, 5 CPU cores and 8 GB of memory are required for the minimum configuration (development).

## Resources Required

The following resources are required in addition to the minimum platform requirements.

In *development*:

- Minimum worker nodes: 3
- Minimum CPU available: 11 for STT and 5 for TTS
- Minimum memory available: 60 GBs for STT and 20 GBs for TTS (it depends on the models/voices installed)
- Minimum disk per node available: 500 GBs

In *production*:

- Minimum worker nodes: 3
- Minimum CPU available: 19 for STT and 10 for TTS
- Minimum memory available: 90GBs for STT and 40 for TTS (it depends on the models/voices installed)
- Minimum disk per node available: 500 GBs

## Installing the chart on IBM Cloud Pak for Data with OpenShift

This Helm chart deploys a single installation of the IBM Watson Speech Services. A single installation can accommodate up to 30 service instances.

### OpenShift software prerequisites

- OpenShift v3.11 or OpenShift v4.3
- IBM Cloud Pak for Data V2.5.0.0 or V3.0.0.0
- Kubernetes V1.11.0 for IBM Cloud Pak for Data V2.5.0.0
- Kubernetes V1.16.2 for IBM Cloud Pak for Data V3.0.0.0
- Helm V2.14.3

### Red Hat OpenShift SecurityContextConstraints requirements

This chart has no Red Hat specific SecurityContextConstraints requirements. Follow the generic SecurityContextConstraints requirements below.

### SecurityContextConstraints requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement, cluster-scoped as well as namespace-scoped pre and post actions need to occur.

If you do not specify a security context, the OpenShift [`restricted`](https://ibm.biz/cpkspec-scc) security context constraint is applied by default. The predefined SecurityContextConstraints `restricted` has been verified for this chart.

If your target namespace is bound to this SecurityContextConstraints resource, you can skip the rest of this section and proceed to install the chart. Otherwise, run the following command to bind the `restricted` SecurityContextConstraints to your namespace:

```bash
oc adm policy add-scc-to-group restricted system:serviceaccounts:{namespace-name}
```

- `{namespace-name}` is the namespace where IBM Cloud Pak for Data is installed, normally zen.

See the standard definition of the following restricted SCC if you want to create a Custom SecurityContextConstraints definition:

```yaml
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
apiVersion: security.openshift.io/v1
defaultAddCapabilities: null
fsGroup:
  type: MustRunAs
groups:
- system:authenticated
- system:serviceaccounts:zen
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: restricted denies access to all host features and requires
      pods to be run with a UID, and SELinux context that are allocated to the namespace.  This
      is the most restrictive SCC and it is used by default for authenticated users.
  creationTimestamp: 2020-05-26T20:06:29Z
  name: restricted
  resourceVersion: "610956"
  selfLink: /apis/security.openshift.io/v1/securitycontextconstraints/restricted
  uid: 62cf9eba-9f8c-11ea-bf07-00163e01f134
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

### Setting up the cluster

The `cluster-admin` role is required to deploy IBM Watson Speech Services.

Before installation, verify that Portworx is installed and the `portworx-sc` storage class exists. For information about other supported storage solutions, see [Storage considerations](https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.0.0/cpd/plan/storage_considerations.html).

1. If the `portworx-sc` storageclass does not exist (you can check via `oc get sc portworx-sc`), create it by running `oc create -f {manifest-file}`, where `{manifest-file}` is the snippet below.

   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
      name: portworx-sc
   parameters:
      block_size: 64k
      io_profile: db
      priority_io: high
      repl: "3"
      snap_interval: "0"
   provisioner: kubernetes.io/portworx-volume
   reclaimPolicy: Delete
   volumeBindingMode: Immediate
   ```

Then verify it was properly created:

```bash
oc get storageclass | grep portworx-sc
```

Run the following commands to complete pre-installation setup of the cluster:

1.  Log into OpenShift.

    ```bash
    oc login
    ```

    For Openshift v4.3, you can navigate to the OpenShift console in your browser (use the `oc get routes -n openshift-console` command to get the URL) and select "kubeadmin" in the upper right. Then select "copy login command". Select" Display token" and paste the token in your favorite terminal window.

1.  Set up required labels.

    A label must be added to the namespace where IBM Cloud Pak for Data is installed, normally `zen`.

    ```bash
    oc label --overwrite namespace {namespace-name} ns={namespace-name}
    ```

    - `{namespace-name}` is the namespace where IBM Cloud Pak for Data is installed, normally `zen`.

1.  Make sure you are pointing at the correct OpenShift project.

    ```bash
    oc project {namespace-name}
    ```

    - `{namespace-name}` is the namespace where IBM Cloud Pak for Data is installed, normally `zen`.

1. Create secrets objects with credentials to access the datastores.

    Two secrets objects need to be created manually within the `{namespace-name}` namespace to set the access credentials for the Minio and PostgreSQL datastores.

    - Minio

      ```yaml
      apiVersion: v1
      kind: Secret
      metadata:
        name: minio
      type: Opaque
      data:
        accesskey: YWRtaW4=
        secretkey: YWRtaW4xMjM0
      ```

      where `accesskey` and `secretkey` are values of your choice encoded in base64. For example:

      ```sh
      echo -n "admin" | base64
      YWRtaW4=

      echo -n "admin1234" | base64
      YWRtaW4xMjM0
      ```

    - PostgreSQL

      ```yaml
      apiVersion: v1
      data:
        pg_repl_password: cmVwbHVzZXI=
        pg_su_password: c3RvbG9u
      kind: Secret
      metadata:
        name: user-provided-postgressql # this name can be anything you choose
      type: Opaque
      ```

      where both `pg_repl_password` and `pg_su_password` are again your choice and base64-encoded.

### Creating files for installation

1.  Create a `speech-override.yaml` file and define any custom configuration settings.

    Here is a sample file for reference:

    ```yaml
    tags:
      sttAsync: true
      sttCustomization: true
      ttsCustomization: true
      sttRuntime: true
      ttsRuntime: true

    affinity: {}

    global:
      dockerRegistryPrefix: "cp.icr.io/cp/watson-speech"
      image:
        pullSecret: "docker-pull-{{ .Release.Namespace }}-cp-icr-io-cp-spch-registry-registry"
        pullPolicy: "IfNotPresent"

      datastores:
        minio:
          secretName: "minio"
        postgressql:
          auth:
            authSecretName: "user-provided-postgressql"

      sttModels:
        enUsBroadbandModel:
          enabled: true
        enUsNarrowbandModel:
          enabled: true
        enUsShortFormNarrowbandModel:
          enabled: true

        nlNlBroadbandModel:
          enabled: false
        nlNlNarrowbandModel:
          enabled: false
        itItBroadbandModel:
          enabled: false
        itItNarrowbandModel:
          enabled: false
        jaJpBroadbandModel:
          enabled: false
        jaJpNarrowbandModel:
          enabled: false
        koKrBroadbandModel:
          enabled: false
        koKrNarrowbandModel:
          enabled: false
        esEsBroadbandModel:
          enabled: false
        esEsNarrowbandModel:
          enabled: false
        frFrBroadbandModel:
          enabled: false
        frFrNarrowbandModel:
          enabled: false
        arArBroadbandModel:
          enabled: false
        deDeBroadbandModel:
          enabled: false
        deDeNarrowbandModel:
          enabled: false
        enGbBroadbandModel:
          enabled: false
        enGbNarrowbandModel:
          enabled: false
        ptBrBroadbandModel:
          enabled: false
        ptBrNarrowbandModel:
          enabled: false
        zhCnBroadbandModel:
          enabled: false
        zhCnNarrowbandModel:
          enabled: false

      ttsVoices:
        enUSMichaelV3Voice:
          enabled: true
        enUSAllisonV3Voice:
          enabled: true
        enUSLisaV3Voice:
          enabled: true

        deDEBirgitV3Voice:
          enabled: false
        deDEDieterV3Voice:
          enabled: false
        enGBKateV3Voice:
          enabled: false
        esLASofiaV3Voice:
          enabled: false
        esUSSofiaV3Voice:
          enabled: false
        ptBRIsabelaV3Voice:
          enabled: false
        esESEnriqueV3Voice:
          enabled: false
        esESLauraV3Voice:
          enabled: false
        frFRReneeV3Voice:
          enabled: false
        itITFrancescaV3Voice:
          enabled: false
        jaJPEmiV3Voice:
          enabled: false
        deDEErikaV3Voice:
          enabled: false
        enUSEmilyV3Voice:
          enabled: false
        enUSHenryV3Voice:
          enabled: false
        enUSKevinV3Voice:
          enabled: false
        enUSOliviaV3Voice:
          enabled: false
    ```

    Further details are found in the following sections. See the section *Select the components to install* for information about how to select the components to install. Additionally, read the *Installation appendix* and *Configuration* section to learn more about the installation configuration.

1. Create a `speech-repo.yaml` file.

   Here is a sample file for reference:

   ```yaml
   # registries to pull images from
   registry:
     - url: cp.icr.io/cp
       username: "iamapikey"
       apikey: {entitlement-key}
       namespace: "watson-speech"
       name: spch-registry
   # cpd will search the module/assembly yaml files from the file servers, from top to bottom
   fileservers:
     - url: https://raw.github.com/IBM/cloud-pak/master/repo/cpd3
     - url: https://raw.github.com/IBM/cloud-pak/master/repo/cpd3/assembly/watson-speech     
   ```

   - `{entitlement-key}` is the key from [myibm.com](https://myibm.ibm.com/products-services/containerlibrary).
   - For the fileserver URL, use https://raw.github.com/IBM/cloud-pak/master/repo/cpd for 2.5 and https://raw.github.com/IBM/cloud-pak/master/repo/cpd3 for 3.0.

### Installing the Assembly

Use the following command to install the Assembly.

```bash
./{cpd-tool} --repo speech-repo.yaml --assembly watson-speech --version ${assembly-version} --namespace {namespace-name} -o speech-override.yaml
```

- `{cpd-tool}` can be `cpd-linux` if running from a Linux terminal, `cpd-darwin` if running from Mac, etc.
- `{namespace-name}` is the namespace into which IBM Cloud Pak for Data was installed, normally `zen`.
- `{assembly-version}` is the release version.

### Installing the Assembly on an air-gap cluster

The same version/build of `cpd-linux` is required throughout the process.

1. Be sure you have completed the `Setting up the cluster` and `Creating files for installation` steps shown earlier.

1. Download images and Assembly files.

   Run this command in a location with access to the internet and to the `cpd-linux` tool.

   ```bash
   ./cpd-linux preloadImages --repo speech-repo.yaml --assembly watson-speech --version ${assembly-version} --action download --download-path ./{speech-workspace}
   ```

   - `{assembly-version}` is the release version; currently it is 1.2
   - `{speech-workspace}` is the directory where the images are to be downloaded.

1. Push the `{speech-workspace}` folder to a location with access to the OpenShift cluster to be installed and the same version of the `cpd-linux` tool used in the preloadImages step above.

1. Log into the Openshift cluster.

   ```bash
   oc login
   ```

1. Push the Docker images to the internal docker registry.

   ```bash
   ./cpd-linux preloadImages --action push --load-from ./{speech-workspace} --assembly watson-speech --version ${assembly-version} --transfer-image-to $(oc registry info)/{namespace-name} --target-registry-username kubeadmin --target-registry-password $(oc whoami -t) --insecure-skip-tls-verify
   ```

   - `{speech-workspace}` is the directory where the images are to be downloaded.
   - `{assembly-version}` is the release version; currently it is 1.2
   - `{namespace-name}` is the namespace into which IBM Cloud Pak for Data was installed, normally `zen`.

1. Run the following command.

   ```bash
   oc get secrets | grep default-dockercfg
   ```

1. Modify the `speech-override.yaml` file and update `global.image.pullSecret` with the name of the secret you discovered in the previous step. Modify any other values that need to be customized

1. Install Watson Speech Services.

   ```bash
   ./cpd-linux --load-from ./{speech-workspace} --assembly watson-speech --version ${assembly-version} --namespace {namespace-name} --cluster-pull-prefix {docker-registry}/{namespace} -o speech-override.yaml
   ```

   - `{namespace-name}` is the namespace where IBM Cloud Pak for Data was installed into, normally `zen`.
   - `{docker-registry}` is the address of the internal OpenShift docker registry, normally:
      - `docker-registry.default.svc:5000` for OpenShift 3.X
      - `image-registry.openshift-image-registry.svc:5000` for OpenShift 4.X
   - `{assembly_version}` is the release version; currently it is 1.2.

## Verifying the chart

1. Check the status of the assembly and modules.

   ```bash
   ./cpd-linux status --namespace {namespace-name} --assembly watson-speech [--patches]
   ```

   - `{namespace-name}` is the namespace into which IBM Cloud Pak for Data was installed, normally `zen`.
   - `--patches` displays additional applied patches.

1. Set up your Helm environment.

   ```bash
   export TILLER_NAMESPACE=zen
   oc get secret helm-secret -n $TILLER_NAMESPACE -o yaml|grep -A3 '^data:'|tail -3 | awk -F: '{system("echo "$2" |base64 --decode > "$1)}'
   export HELM_TLS_CA_CERT=$PWD/ca.cert.pem
   export HELM_TLS_CERT=$PWD/helm.cert.pem
   export HELM_TLS_KEY=$PWD/helm.key.pem
   helm version --tls
   ```

   You should see output like this:

   ```bash
   Client: &version.Version{SemVer:"v2.14.3", GitCommit:"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085", GitTreeState:"clean"}
   Server: &version.Version{SemVer:"v2.14.3", GitCommit:"0e7f3b6637f7af8fcfddb3d2941fcc7cbebb0085", GitTreeState:"clean"}
   ```

1. Check the status of resources.

   ```bash
   helm status watson-speech --tls
   ```

1. Run Helm tests.

   ```bash
   helm test watson-speech --tls [--timeout=18000] [--cleanup]
   ```

   - `--timeout={time}` waits for the time in seconds for the tests to run.
   - `--cleanup` deletes test pods upon completion.

## Deploying a patch

To deploy a patch, run the following command:

```bash
./{cpd-tool} patch --namespace {namespace} --assembly watson-speech --patch-name {patch} --repo speech-repo.yaml
```

- `{cpd-tool}` can be `cpd-linux` if running from a Linux terminal, `cpd-darwin` if running from Mac, etc.
- `{namespace}` is the namespace into which IBM Cloud Pak for Data was installed, normally `zen`.
- `{patch}` is the name of the patch or fix.

### Uninstalling the chart

To uninstall and delete the `watson-speech` deployment, run the following command:

```bash
./cpd-linux uninstall --assembly watson-speech --namespace {namespace-name}
```

The uninstall does not delete the datastore resources. To delete the datastore resources, run the following commands:

```bash
oc delete job,deploy,replicaset,pod,statefulset,configmap,secret,ingress,service,serviceaccount,role,rolebinding,persistentvolumeclaim,poddisruptionbudget,horizontalpodautoscaler,networkpolicies,cronjob -l release=watson-speech
```

```bash
oc delete configmap stolon-cluster-watson-speech
```

If you used local-volumes, you also need to remove any persistent volumes, persistent volume claims, and their contents. Make sure you back up all the necessary data beforehand.

## Installation appendix

### Select the components to install

The following tags, which you can set in the `speech-override.yaml` file, can be used to enable/disable the installation of each of the components that are included in this solution:

```yaml
tags:
  sttAsync: true
  sttCustomization: true
  ttsCustomization: true
  sttRuntime: true
  ttsRuntime: true
```

- `sttAsync` enables installation of the asynchronous API to access the STT service, which corresponds to the `/recognitions` API endpoints.
- `sttCustomization` enables installation of the STT customization functionality, which lets you customize the STT base models for improved accuracy and corresponds to the `/customizations` API endpoints.
- `ttsCustomization` enables installation of the TTS customization functionality, which lets you customize the TTS base voices for improved voice quality and corresponds to the `/customizations` API endpoints.
- `sttRuntime` enables installation of the core STT functionality, which lets you convert speech into text by using the `/recognize` endpoint. This component is installed if any of the `sttRuntime`, `sttCustomization`, or `sttAsync` tags are set to `true`.
- `ttsRuntime` enables installation of the core TTS functionality, which lets you convert text into speech by using the `/synthesize` endpoint. This component is installed if either the `ttsRuntime` or `ttsCustomization` tags are set to `true`.

By default, all of the components are enabled, but each of them can be enabled/disabled separately. If you want to install *STT* only, you need to set `ttsRuntime` and `ttsCustomization` to `false`. Similarly, if you want to install *TTS* only, you need to set `sttRuntime`, `sttCustomization`, and `sttAsync` to `false`. For example, if you want to install *STT* and *TTS* but do not want customization capabilities, you need to set `sttCustomization` and `ttsCustomization` to `false`.

### Affinity specification

This is the node/pod affinity specification for the Speech-to-Text and Text-to-Speech pods. If specified, it overrides the default affinity (found in the template file `\_sch-chart-config.tpl`, which overrides `sch.affinity.nodeAffinity` within the `sch` subchart) to run on any amd64 node. You can pass your own affinity specification by using the `affinity` value in the `speech-overrides.yaml` file. For example:

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/e2e-az-name
          operator: In
          values:
          - e2e-az1
          - e2e-az2
```

### Configure Minio object storage

Minio object storage is used for storing persistent data that is needed by speech service components.

#### Secrets

Before you install *STT* or *TTS*, you need to provide a secret object that is used by Minio itself and by other service components that interact with Minio. This secret contains the security keys to access Minio.

The secret must contain the items `accesskey` (5 - 20 characters) and `secretkey` (8 - 40 characters) in base64 encoding. Therefore, before creating the secret, you need to perform the base64 encoding.

The following commands encode the `accesskey` and `secretkey` in base64. **Important:** For security reasons, you are strongly encouraged to create an `accesskey` and a `secretkey` that are different from the sample keys (`admin` and `admin1234`) that are shown in the following examples.

```sh
echo -n "admin" | base64
YWRtaW4=

echo -n "admin1234" | base64
YWRtaW4xMjM0
```

Create a file named `minio.yaml` with the following secret object definition:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: minio
type: Opaque
data:
  accesskey: YWRtaW4=
  secretkey: YWRtaW4xMjM0
```

```bash
kubectl create -f minio.yaml
```

#### Mode of operation

By default, Minio operates in `distributed` mode, which means that Minio is scheduled to run multiple instances on every worker node to ensure high availability of storage.

To use high availability optimally, you must specify an appropriate number of replicas. Set the number of replicas for distributed mode by running `external.minio.replicas={number-of-cluster-nodes}`, where `{number-of-cluster-nodes}` is `4 <= x <= 32`. The default value is `4` replicas.

Minio can also operate in `standalone` mode, which means that only one instance of Minio runs on an arbitrary worker node. Its failure means that the service becomes unavailable until a new instance is running and healthy. This option is sufficient for testing purposes but not for production.

If you want to run Minio in `standalone` mode, you can do it by setting the value `external.minio.mode=standalone`. In this case, you do not have to set the `external.minio.replicas` value.

#### Storage size calculation guidelines

Object storage is used for storing binary data from the following sources:

- Base models (for example, `en-US_NarrowbandModel`).

  On average, base models are each `1.5 GB`. Because models are updated regularly, you need to multiply that amount by three to make room for at least three different versions of each model.

- Customization data (audio files and training snapshots).

  The storage that is required for customization data depends on how many hours of audio you use for training your custom models. On average, one hour of audio data needs `0.5 GB` of storage space. You can have multiple customizations, so you must factor in additional space.

- Audio files from recognition jobs that are processed asynchronously, in case they need to be queued.

  The storage required for asynchronous jobs depends on the use case. If you plan to submit large batches of audio files, expect the service to queue some jobs temporarily. This means that some audio files are held temporarily in binary storage. The amount of storage required for this purpose does not exceed the size of the largest batch of jobs that you plan to submit in parallel.

A few examples of how to calculate storage size (in gigabytes) follow:

- 6 models, 3 versions, 50 hours audio = `6 * 1.5 * 3 + 50 * 0.5 = 52`
- 2 models, 3 versions, 20 hours audio = `2 * 1.5 * 3 + 20 * 0.5 = 19`

The default storage size, `100 GB`, is a minimum starting point and is typically enough for operations with two to six models and about 50 hours of audio for the purpose of training custom models. But it is always a good idea to be generous in anticipation of future storage needs.

### Configuration of the PostgreSQL and RabbitMQ installation

#### Setting access credentials for PostgreSQL

The Postgres chart reads the credentials to access the Postgres database from the following secret file, which needs to be created before installing the chart. You need to set the attribute `data.pg_su_password` to the Postgres password that you want (base64 encoded). You also need to set the attribute `pg_repl_password`, which is the replication password and is also base64 encoded, to the value you want.

```yaml
apiVersion: v1
data:
  pg_repl_password: cmVwbHVzZXI=
  pg_su_password: c3RvbG9u
kind: Secret
metadata:
  name: user-provided-postgressql # this name can be anything you choose
type: Opaque
```

To create the secret object, run the `kubectl create -f {secrets_file}` command.

Finally, when installing the chart, you need to set the following two values to the name of the secret created previously (`user-provided-postgressql`): `global.datastores.postgressql.auth.authSecretName` and `postgressql.auth.authSecretName`.

If you do not create the secret object, the installation creates a secret object that contains randomly generated passwords when the Helm chart is installed. For security reasons, you need to change the automatically generated passwords when the deployment is complete.

## Resources Required

In addition to the general requirements listed in [Pre-installation tasks](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/zen/install/preinstall-overview.html), the IBM Watson Speech to Text service has its own requirements:

- `x86_64` is the only architecture supported at this time.
- If you need a highly available installation, a minimum of three worker nodes are needed for the installation.
- The resources required for the installation, in terms of CPUs and memory, depend on the configuration that you select. There are two typical installation configurations:

  - The **development configuration**, which is the configuration that is used in the default installation, has a minimal footprint and is meant for development purposes and as a proof of concept. It can only handle several concurrent recognition sessions, and it is not highly available because some of the core component have no redundancy (single replica).
  - The **production configuration** is a highly available solution that is intended to run production workloads. This configuration can be achieved by scaling up the **development configuration** after installation, as described in the following section.

### Scaling up the **development configuration** to obtain a **production configuration**

The default installation of the solution comes with the **development configuration**. You can update it to the **production configuration** by scaling up the number of pods and replicas of the deployment objects after installing the solution. How much to scale up each of the components depends on the degree of concurrency you need. It is limited by the amount of hardware resources that are available in your Kubernetes cluster/namespace.

#### Scaling up the PostgreSQL and RabbitMQ datastores

By default, both PostgreSQL and RabbitMQ are installed with three replicas for high availability reasons. Each replica is typically scheduled within a different Kubernetes worker node if resources allow. Before performing the installation, you can configure the number of replicas and the CPU and memory resources for each replica by using Helm values (see the *Options* section).

You can also scale up the datastores on an already running solution by changing the number of replicas in the Deployment or StatefulSet objects. For example, you can scale up RabbitMQ as follows:

1. Edit the StatefulSet object by running `kubectl edit statefulsets {release}-ibm-rabbitmq`.
1. Change the value of the `spec.replicas:` attribute.
1. Save and close the StatefulSet object.

In the case of PostgreSQL, there are two deployment objects (`{release}-ibm-postgresql-proxy` and `{release}-ibm-postgresql-sentinel`) and a StatefulSet (`ibm-wc-ibm-postgresql-keeper`). The deployment objects can be scaled up by running `kubectl scale --replicas={n} {deployment_object}`, where `{n}` is the new number of replicas; for example, `kubectl scale --replicas=3 deployment ibm-wc-ibm-postgresql-proxy`. The StatefulSet object can be scaled up by following the process described previously for PostgreSQL.

Note that a sufficient number of Persistent Local Volumes need to be created before scaling up the number of replicas (in the case of the StatefulSets) so that the newly created pods can mount their volumes.

#### Scaling up the rest of the solution

You can learn about the list of deployments (Kubernetes `Deployment` objects) by running the `kubectl get deployment` command. You can then scale up the number of pods on each of the deployment objects to match the number of pods in the production configuration, as shown in the following table. You can do this by using the following command:

```bash
kubectl scale --replicas={n} deployment {deployment_object}
```

where `{n}` is the desired number of replicas for the given deployment (`{deployment_object}`).

| Deployment              | Default number of replicas |
|-------------------------|-------------------|
| `{release-name}-speech-to-text-stt-runtime`          |  1 |
| `{release-name}-speech-to-text-stt-customization`    |  1 |
| `{release-name}-speech-to-text-stt-am-patcher`       |  1 |
| `{release-name}-speech-to-text-stt-async`            |  1 |
| `{release-name}-speech-to-text-gdpr-data-deletion`   |  1 |
| `{release-name}-minio`                               |  1 |
| `{release-name}-rabbitmq`                            |  1 |
| `{release-name}-ibm-postgressql-proxy`               |  2 |
| `{release-name}-ibm-postgressql-sentinel`            |  3 |
| `{release-name}-ibm-postgressql-keeper`              |  3 |

| Statefulset                  | Number of replicas |
|-------------------------|-------------------|
| `{release-name}-ibm-postgresql-keeper` | 3          |
| `{release-name}-ibm-rabbitmq `         | 3          |

The standard installation (*development configuration*) requires a total of **14.75** CPUs and **38.5** GB of memory. These numbers are based on a standard installation that includes the US English models only. In general, the memory requirements vary depending on which models you include in the installation.

### Setting the sessions/CPU ratio

The meaning of a **session** in this context is one of the following:

- `recognize` request to the STT runtime
- `synthesize` request to the TTS runtime
- `train` request to the STT Customization back end (STT AM patcher)

To choose resources for each of the session types, perform the following calculations.

#### STT runtime (recognize)

STT runtime requires `R=0.6` CPUs per recognize session. The calculation is done as follows:

1. Set the maximum number of sessions (`S`) you want to run in parallel; for example, `S=13`.
2. Calculate the number of CPUs (`N`) needed to process `S` sessions as follows: `N = S * R = S * 0.6`.
3. Round up `N` to the closest integer.

**Example**

Assume that you want to run up to `13` recognize sessions in parallel:

```
N = S * R = 13 * 0.6 = 7.8 ~= 8 [CPUs]
```

You then need to set the value `sttRuntime.groups.sttRuntimeDefault.resources.requestsCpu=8` during installation.

#### TTS runtime (synthesize)

TTS runtime requires `R=0.4` CPUs per synthesis session. The calculation is done as follows:

1. Set the maximum number of sessions (`S`) you want to run in parallel; for example, `S=13`.
2. Calculate the number of CPUs (`N`) needed to process `S` sessions as follows: `N = S * R`.
3. Round up `N` to the closest integer.

**Example**

Assume that you want to run up to `13` synthesize sessions in parallel:

```
N = S * R = 13 * 0.4 = 5.2 ~= 6 [CPUs]
```

You need to set the value `ttsRuntime.groups.ttsRuntimeDefault.resources.requestsCpu=6` during installation.

With the TTS Runtime, it is also possible to change `R` by setting `global.ttsVoiceMarginalCPU` to achieve a better *session:CPU* ratio without endangering *Real Time Factor*.

#### STT Customization back end (train)

The STT Customization back end requires at least 1 CPU per training session. However, a training session can be parallelized on its own because most of the calculations in the back end can run on multiple CPUs. One training session can use multiple threads (`T`) for processing, which means that one training session requires `T` CPUs per session. It is basically the same as setting `R=T` for STT runtime. Choosing `T>1` means faster training to some extent.

The following table shows the relation between the number of threads and processing time (done with 112 minute of audio data):

Threads | Training duration [minutes] | Speed up (compared to 1 thread) |
--------|-----------------------------|---------------------------------|
1       | 118.6                       | 1.00                            |
2       | 65.8                        | 1.80                            |
3       | 49.2                        | 2.41                            |
4       | 40.6                        | 2.92                            |
5       | 37.6                        | 3.15                            |
6       | 37.2                        | 3.19                            |

As you can see, *speed up* starts slowing down with `T=4`, so using more than 4 threads per session does not improve performance.

The overall calculation of CPU requirements for the STT Customization back end is done as follows. All input values must be whole numbers (for example, 1, 2, 3, 4, and so on).

1. Set the number of parallel training sessions (`S`) you want to run; for example, `S=2`.
1. Set the number of parallel threads per session (`T`) you want to utilize; for example, `T=2`.
1. Calculate the number of CPUs (`N`) needed to process `S` sessions as follows: `N = S * T`.

**Example**

Assume that you want to run `2` training sessions in parallel and utilize `3` threads per session to achieve reasonable performance:

```
N = S * T = 2 * 3 = 6 [CPUs]
```

You need to set the following values:

```
sttAMPatcher.groups.sttAMPatcher.resources.requestsCpu=6
sttAMPatcher.groups.sttAMPatcher.resources.threads=3
```

### Dynamic resource calculation

The STT runtime, TTS runtime, and STT Customization back end support automatic required memory resource calculation, which is based on the selected number of CPUs and the selected language models. Automatic resource calculation is enabled by default. You can modify this behavior by setting the following values to `true` or `false` as needed:

```
sttRuntime.groups.sttRuntimeDefault.resources.dynamicMemory
ttsRuntime.groups.ttsRuntimeDefault.resources.dynamicMemory
sttAMPatcher.groups.sttAMPatcher.resources.dynamicMemory
```

When you set any of the previous values to `false`, you must specify the required memory yourself (see *Options* section below).

**Important**: Disabling automatic resource calculation is not recommended and can cause undesired service behavior.

## Configuration

The Helm chart has the following values that you can override by using the `--set` parameter with the `install` command.

### Language model selection

You can perform an installation that includes only a subset of the language models and voices in the catalog. Installing all of the models and voices in the catalog substantially increases the memory requirements. Therefore, it is strongly recommended that you install only those languages that you intend to use.

You can select the languages to be installed by checking or unchecking each of the models and voices in the `global.sttModels.*` or `global.ttsVoices.*` values. By default, the dynamic resource calculation feature is enabled. It automatically computes the exact amount of memory that is required for the selected models and voices.

It is also possible to install ad hoc models and voices that were not released with this version of the services. You need to download a special package that contains data for the models and voices, upload it into the cluster the same way as the main package, and specify the following options during installation.

| Value                                           | Description                                             |
|-------------------------------------------------|---------------------------------------------------------|
| `global.sttModels.$modelName.catalogName`       | Model name as it is found in the catalog.                   |
| `global.sttModels.$modelName.size`              | Memory footprint used to calculate memory requirements. |
| `global.ttsVoices.$voiceName.catalogName`       | Voice name as it is found in the catalog.                   |
| `global.ttsVoices.$voiceName.size`              | Memory footprint used to calculate memory requirements. |

*Example:*

Assume that there is a new broadband model for the Czech language that was released as an ad hoc model for the current Speech on IBM Cloud Pak for Data release. To enable it during update, specify the following options during installation. In this example, `$modelName` is `csCSBroadbandModel`, and `$catalogName` is `cs-CS_BroadBandModel`.

```bash
helm upgrade RELEASE CHART --set global.sttModels.csCSBroadbandModel.catalogName=cs-CS_BroadBandModel --set global.sttModels.csCSBroadbandModel.size=500 [OTHER-FLAGS]
```

### Storage of customer data (STT runtime and AM patcher)

By default, payload data, including audio files, recognition hypotheses, and annotations, are temporarily stored in the running container. You can disable this behavior by checking the `STT Runtime | Disable storage of customer data` option. Checking this option also removes sensitive information from container logs.

### Options

The following options apply to an IBM Watson™ Speech Services runtime configuration.

#### Components

There are five components that can be enabled or disabled according to your needs. The main components are **Speech-to-Text runtime** and **Text-to-Speech runtime**. Additional components are **Speech-to-Text Customization**, **Text-to-Speech Customization**, and **Speech-to-Text Async**.

| Value                           | Description                                                                                                                                                                       | Default |
|---------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------|
| `tags.sttRuntime`               | Speech-to-Text Runtime that is the base component for recognition. If you check any of the Speech-to-Text additional components, the Speech-to-Text runtime is enabled automatically. | `true`  |
| `tags.ttsRuntime`               | Text-to-Speech Runtime that is the base component for synthesis. If you check any of the Text-to-Speech additional components, the Text-to-Speech runtime is enabled automatically. | `true`  |
| `tags.sttCustomization`         | Speech-to-Text Customization component. Enabling it also enables the Speech-to-Text runtime if `tags.sttRuntime=false`.                                                               | `true`  |
| `tags.ttsCustomization`         | Text-to-Speech Customization component. Enabling it also enables the Text-to-Speech runtime if `tags.sttRuntime=false`.                                                               | `true`  |
| `tags.sttAsync`                 | Speech-to-Text Async component.                                                                                                                                                   | `true`  |

#### Datastores

| Value                                               | Description                                                                                                                     | Default                      |
|-----------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|------------------------------|
| `external.minio.mode`                               | Minio server mode (`standalone`, `distributed`).                                                                                | `distributed`                |
| `external.minio.persistence.size`                   | Size of persistent volume claim (PVC).                                                                                          | `100Gi`                      |
| `external.minio.replicas`                           | Number of nodes (applicable only for Minio distributed mode). Must be 4 <= x <= 32.                                             | `4`                          |
| `external.minio.minioAccessSecret`                  | Create a secret that contains base64-encoded accesskey (5 - 20 characters) and secretkey (8 - 40 characters). The keys are used to access the Minio Object Server. You need to create the secret in the same namespace in which you deploy the chart. | `minio`                                                   |
| `global.datastores.minio.secretName`                | Minio object storage access secret name created as an installation prerequisite.                                                | `minio`                      |
| `global.datastores.postgressql.auth.authSecretName` | PostgresSQL name of the secrets object that contains the credentials to access the datastore.                                   | `user-provided-postgressql`  |
| `postgressql.auth.authSecretName`                   | PostgresSQL name of the secrets object that contains the credentials to access the datastore.                                   | `user-provided-postgressql`  |

#### Anonymize logs and audio data

| Value                               | Description                                      | Default  |
|-------------------------------------|--------------------------------------------------|----------|
| `sttRuntime.anonymizeLogs`          | Opt out of runtime logs and audio data.          | `False`  |
| `ttsRuntime.anonymizeLogs`          | Opt out of runtime logs and audio data.          | `False`  |
| `sttAMPatcher.anonymizeLogs`        | Opt out of runtime logs and audio data.          | `False`  |

#### Resources

##### Speech-to-Text runtime

| Value                                                          | Description                                                                                                                              | Default   |
|----------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| `sttRuntime.groups.sttRuntimeDefault.resources.dynamicMemory`  | Calculate memory requirements for STT runtime according to selected models. For more information, see the chart overview.                | `True`    |
| `sttRuntime.groups.sttRuntimeDefault.resources.requestsCpu`    | Requested CPUs for STT runtime. Minimum value is 4.                                                                                      | `8`       |
| `sttRuntime.groups.sttRuntimeDefault.resources.requestsMemory` | Calculation of the memory requirements can be found in the chart overview. When dynamic memory is enabled, this option has no effect.    | `22000Mi` |

##### Speech-to-Text runtime

| Value                                                          | Description                                                                                                                              | Default   |
|----------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| `ttsRuntime.groups.ttsRuntimeDefault.resources.dynamicMemory`  | Calculate memory requirements for the TTS runtime according to the selected models. For more information, see the chart overview.                | `True`    |
| `ttsRuntime.groups.ttsRuntimeDefault.resources.requestsCpu`    | Requested CPUs for the TTS runtime. Minimum value is 4.                                                                                      | `8`       |
| `ttsRuntime.groups.ttsRuntimeDefault.resources.requestsMemory` | Calculation of the memory requirements can be found in the chart overview. When dynamic memory is enabled, this option has no effect.    | `22000Mi` |
| `global.ttsVoiceMarginalCPU`                                   | TTS Voice marginal CPU used for synthesis. The value is in milli-CPUs.                                                                    | `400`     |

##### Speech-to-Text customization back end (Acoustic Model patcher)

| Value                                                          | Description                                                                                                                              | Default   |
|----------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|-----------|
| `sttAMPatcher.groups.sttAMPatcher.resources.dynamicMemory`     | Calculate memory requirements for STT AM patcher according to the selected models. For more information, see the chart overview.            | `True`    |
| `sttAMPatcher.groups.sttAMPatcher.resources.requestsCpu`       | Each customization session needs 4 CPUs.                                                                                                | `8`       |
| `sttAMPatcher.groups.sttAMPatcher.resources.requestsMemory`    | The amount of memory depends on the number of CPUs. Size can be calculated as the number of CPUs * 3 GB.                                                      | `22000Mi` |
| `sttAMPatcher.groups.sttAMPatcher.resources.threads`           | Number of parallel-processing threads for AM customization. Note that fewer threads means longer training time.                                       | `4`       |

#### Speech-to-text models

| Value                                                     | Description                                                                               | Default |
|-----------------------------------------------------------|-------------------------------------------------------------------------------------------|---------|
| `global.sttModels.enUsBroadbandModel.enabled`             | Whether to include the en-US Broadband Model in the installation.                         | `True`  |
| `global.sttModels.enUsNarrowbandModel.enabled`            | Whether to include the en-US Narrowband Model in the installation.                        | `True`  |
| `global.sttModels.enUsShortFormNarrowbandModel.enabled`   | Whether to include the en-US ShortForm Narrowband Model in the installation.         | `True`  |
| `global.sttModels.nlNlBroadbandModel.enabled`             | Whether to include the nl-NL Broadband Model in the installation.                         | `False` |
| `global.sttModels.nlNlNarrowbandModel.enabled`            | Whether to include the nl-NL Narrowband Model in the installation.                        | `False` |
| `global.sttModels.itItBroadbandModel.enabled`             | Whether to include the it-IT Broadband Model in the installation.                         | `False` |
| `global.sttModels.itItNarrowbandModel.enabled`            | Whether to include the it-IT Narrowband Model in the installation.                        | `False` |
| `global.sttModels.jaJpBroadbandModel.enabled`             | Whether to include the ja-JP Broadband Model in the installation.                         | `False` |
| `global.sttModels.jaJpNarrowbandModel.enabled`            | Whether to include the ja-JP Narrowband Model in the installation.                        | `False` |
| `global.sttModels.koKrBroadbandModel.enabled`             | Whether to include the ko-KR Broadband Model in the installation.                         | `False` |
| `global.sttModels.koKrNarrowbandModel.enabled`            | Whether to include the ko-KR Narrowband Model in the installation.                        | `False` |
| `global.sttModels.esEsBroadbandModel.enabled`             | Whether to include the es-ES Broadband Model in the installation.                         | `False` |
| `global.sttModels.esEsNarrowbandModel.enabled`            | Whether to include the es-ES Narrowband Model in the installation.                        | `False` |
| `global.sttModels.frFrBroadbandModel.enabled`             | Whether to include the fr-FR Broadband Model in the installation.                         | `False` |
| `global.sttModels.frFrNarrowbandModel.enabled`            | Whether to include the fr-FR Narrowband Model in the installation.                        | `False` |
| `global.sttModels.arArBroadbandModel.enabled`             | Whether to include the ar-AR Broadband Model in the installation                          | `False` |
| `global.sttModels.deDeBroadbandModel.enabled`             | Whether to include the de-DE Broadband Model in the installation                          | `False` |
| `global.sttModels.deDeNarrowbandModel.enabled`            | Whether to include the de-DE Narrowband Model in the installation                         | `False` |
| `global.sttModels.enGbBroadbandModel.enabled`             | Whether to include the en-GB Broadband Model in the installation                          | `False` |
| `global.sttModels.enGbNarrowbandModel.enabled`            | Whether to include the en-GB Narrowband Model in the installation                         | `False` |
| `global.sttModels.ptBrBroadbandModel.enabled`             | Whether to include the pt-BR Broadband Model in the installation                          | `False` |
| `global.sttModels.ptBrNarrowbandModel.enabled`            | Whether to include the pt-BR Narrowband Model in the installation                         | `False` |
| `global.sttModels.zhCnBroadbandModel.enabled`             | Whether to include the zh-CN Broadband Model in the installation                          | `False` |
| `global.sttModels.zhCnNarrowbandModel.enabled`            | Whether to include the zh-CN Narrowband Model in the installation                         | `False` |

#### Text-to-speech voices

| Value                                           | Description                                                               | Default |
|-------------------------------------------------|---------------------------------------------------------------------------|---------|
| `global.ttsVoices.enUSMichaelV3Voice.enabled`   | Whether to include the en-US Michael Neural Voice in the installation    | `True`  |
| `global.ttsVoices.enUSAllisonV3Voice.enabled`   | Whether to include the en-US Allison Neural Voice in the installation    | `True`  |
| `global.ttsVoices.enUSLisaV3Voice.enabled`      | Whether to include the en-US Lisa Neural Voice in the installation       | `True`  |
| `global.ttsVoices.enUSEmilyV3Voice.enabled`     | Whether to include the en-US Emily Neural Voice in the installation      | `False` |
| `global.ttsVoices.enUSHenryV3Voice.enabled`     | Whether to include the en-US Henry Neural Voice in the installation      | `False` |
| `global.ttsVoices.enUSKevinV3Voice.enabled`     | Whether to include the en-US Kevin Neural Voice in the installation      | `False` |
| `global.ttsVoices.enUSOliviaV3Voice.enabled`    | Whether to include the en-US Olivia Neural Voice in the installation     | `False` |
| `global.ttsVoices.deDEBirgitV3Voice.enabled`    | Whether to include the de-DE Birgit Neural Voice in the installation     | `False` |
| `global.ttsVoices.deDEDieterV3Voice.enabled`    | Whether to include the de-DE Dieter Neural Voice in the installation     | `False` |
| `global.ttsVoices.deDeErikaV3Voice.enabled`     | Whether to include the de-DE Erika Neural Voice in the installation      | `False` |
| `global.ttsVoices.enGBKateV3Voice.enabled`      | Whether to include the en-GB Kate Neural Voice in the installation       | `False` |
| `global.ttsVoices.esLASofiaV3Voice.enabled`     | Whether to include the es-LA Sofia Neural Voice in the installation      | `False` |
| `global.ttsVoices.esUSSofiaV3Voice.enabled`     | Whether to include the es-US Sofia Neural Voice in the installation      | `False` |
| `global.ttsVoices.ptBRIsabelaV3Voice.enabled`   | Whether to include the pt-BR Isabela Neural Voice in the installation    | `False` |
| `global.ttsVoices.esESEnriqueV3Voice.enabled`   | Whether to include the es-ES Enrique Neural Voice in the installation    | `False` |
| `global.ttsVoices.esESLauraV3Voice.enabled`     | Whether to include the es-ES Laura Neural Voice in the installation      | `False` |
| `global.ttsVoices.frFRReneeV3Voice.enabled`     | Whether to include the fr-FR Renee Neural Voice in the installation      | `False` |
| `global.ttsVoices.itITFrancescaV3Voice.enabled` | Whether to include the it-IT Francesca Neural Voice in the installation  | `False` |
| `global.ttsVoices.jaJPEmiV3Voice.enabled`         | Whether to include the ja-JP Emi Neural Voice in the installation                | `False` |

## Limitations

The product supports only:

-   The `x86_64` architecture
-   IBM Cloud Pak for Data version `2.5` or `3.0.1`

## Integrate with other IBM Watson services

IBM Watson™ Speech Services is one of many IBM Watson services that are available on the IBM Cloud. Additional Watson services on the IBM Cloud allow you to bring Watson's AI platform to your business applications and to store, train, and manage your data in the most secure cloud.

For the full list of available Watson services, see the IBM Watson catalog on the public IBM Cloud at [https://cloud.ibm.com/catalog/](https://cloud.ibm.com/catalog/).

Watson services are currently organized into the following categories for different requirements and use cases:

-   **Assistant**: Integrate diverse conversation technology into your applications.
-   **Empathy**: Understand tone, personality, and emotional state.
-   **Knowledge**: Get insights through accelerated data optimization capabilities.
-   **Language**: Analyze text and extract metadata from unstructured content.
-   **Speech**: Convert text and speech with the ability to customize models.
-   **Vision**: Identify and tag content, and then analyze and extract detailed information that is found in images.

_Copyright© IBM Corporation 2018, 2020. All Rights Reserved._
