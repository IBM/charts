-![IBM Watson Assistant logo](https://raw.githubusercontent.com/IBM-Bluemix-Docs/images/master/assistant-prod-banner.png)

# IBM Watson Assistant

IBM Watson™ Assistant adds a natural language interface to your application that automates conversational interactions with your customers. Common applications include virtual agents and chat bots that can integrate and communicate on any channel or device. Train the Watson Assistant service through a graphical web application, so you can quickly build natural conversation flows between your apps and users, and deploy scalable, cost-effective solutions.

## Introduction

This chart deploys a single IBM Watson Assistant slot that can accommodate up to 30 IBM Watson Assistant service instances. You choose whether to install a development or production deployment type.

- Development: Deploys a single pod of each microservice.
- Production: Deploys two pods of each microservice.

## Chart Details

This chart installs the following microservices:

- **NLU (Natural Language Understanding)**: Interface for store to communicate with the back-end to initiate ML training.
- **Dialog**: Dialog runtime, or user-chat capability.
- **ed-mm**: Manages contextual entity capabilities.
- **Master**: Controls the lifecycle of underlying intent and entity models.
- **Recommends**: Supports recommendations from Watson, such as dictionary-based entity synonyms and intent conflicts.
- **SIREG** - Manages tokenization and system entity capabilities for some languages.
- **skill-search**: Manages search skills.
- **SLAD**: Manages service training capabilities.
- **Store**: API endpoints.
- **TAS**: Manages services model inferencing.
- **UI**: Provides the developer user interface.
- **Spellchecker**: Provides the spelling corrections, so called "Autocorrect" feature.
- **CLU Embedding**: Serves word embeddings for CLU

This Helm chart installs the following stores:

- **PostgreSQL**: Stores training data.
- **MongoDB**: Stores word vectors.
- **Redis**: Caches data.
- **etcd**: Manages service registration and discovery.
- **Minio**: Stores CLU models.

## Prerequisites

In addition to the system requirements for the cluster (see [System requirements](https://www.ibm.com/support/knowledgecenter/SSQNUZ_2.5.0/cpd/plan/rhos-reqs.html)), the Watson Assistant services have their own requirements.

The systems that host a deployment must meet these requirements:

- Watson Assistant for IBM Cloud Pak for Data can run on Intel 64-bit architecture nodes only.
- CPUs must have 2.4 GHz or higher clock speed
- CPUs must support Linux SSE 4.2
- CPUs must support the AVX2 instruction set extension. See the [AVX Wikipedia page](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions) for a list of CPUs that include this support. The `ed-mm` microservice cannot function properly without AVX support.

## Resources Required

The following resources are required in addition to the minimum platform requirements.

In development:

    Minimum worker nodes: 3
    Minimum CPU available: 7
    Minimum memory available: 100Gi
    Storage required for Physical Volumes : 326Gi
    Minimum disk per node available: 500 GB

In production:

    Minimum worker nodes: 5
    Minimum CPU available: 10
    Minimum memory available: 150Gi
    Storage required for Physical Volumes : 326Gi
    Minimum disk per node available: 500 GB

## Storage

| Component | Number of replicas | Space per pod | Storage type |
|-----------|--------------------|---------------|--------------|
| Postgres  |                  3 |         10 GB | portworx-assistant |
| etcd      |                  5 |         10 GB | portworx-assistant |
| Minio     |                  4 |          5 GB | portworx-assistant |
| MongoDB   |                  3 |         75 GB | portworx-assistant |
| backup    |                  1 |          1 GB | portworx-assistant |

## Installing the chart on IBM Cloud Pak for Data with OpenShift
This chart deploys a single IBM Watson Assistant slot that can accommodate up to 30 IBM Watson Assistant service instances.

### OpenShift software prerequisites

- IBM Cloud Pak for Data V2.5.0.0 or V3.0.1
- Kubernetes V1.11.0 for IBM Cloud Pak for Data V2.5.0.0
- Kubernetes V1.16.2 for IBM Cloud Pak for Data V3.0.1
- Helm V2.14.3

Before running `helm tests` you must install and configure [`helm`](https://helm.sh/docs/using_helm/#installing-the-helm-client)

### Red Hat OpenShift SecurityContextConstraints Requirements
This chart has no Red Hat specific SecurityContextConstraints requirements. Follow the generic SecurityContextConstraints requirements below.

### SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart.
Please use the standard definition of the restricted SCC below if you would like to create a Custom SecurityContextConstraints definition:
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: restricted
  annotations:
    kubernetes.io/description: restricted denies access to all host features and requires
      pods to be run with a UID, and SELinux context that are allocated to the namespace.  This
      is the most restrictive SCC and it is used by default for authenticated users.
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

You must install Watson Assistant into the same namespace as IBM Cloud Pak for Data which is normally `zen`.

Run this command to bind the `restricted` SecurityContextConstraint to the IBM Cloud Pak for Data namespace:

```bash
oc adm policy add-scc-to-group restricted system:serviceaccounts:{namespace}
```

- `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally zen).

### Setting up the cluster
Before installation, verify that Portworx is installed and the `portworx-assistant` storage class exists. For information about other supported storage solutions, see [Storage considerations](https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.0.0/cpd/plan/storage_considerations.html).

1. If `portworx-assistant` storageclass does not preexist, create the `portworx-assistant` storageclass
   
   ```yaml
   oc apply -f - << EOF
   kind: StorageClass
   apiVersion: storage.k8s.io/v1
   metadata:
     name: portworx-assistant
   provisioner: kubernetes.io/portworx-volume
   parameters:
     repl: "3"
     priority_io: "high"
     snap_interval: "0"
     io_profile: "db"
     block_size: "64k"
   EOF
   ```

1. Verify it has been properly created

   ```bash
   oc get storageclass |grep portworx-assistant
   ```

Run the following commands to do pre-installation set up of the cluster:

1.  Log into OpenShift

    ```bash
    oc login
    ```

1.  Set up required label

    A label must exist on the namespace where IBM Cloud Pak for Data is installed (normally zen). Check for the label `ns={namespace}` in the output of this command:

    ```bash
    oc get ns {namespace} --show-labels --label-columns=ns

    ```
    - `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally zen).
    
    Create the label if does not already exist:

    ```bash
    oc label --overwrite namespace {namespace} ns={namespace}
    ```

    - `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally zen).

1.  Make sure you are pointing at the correct OpenShift project

    ```bash
    oc project {namespace}
    ```

    - `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally zen).

### Creating files for installation
The ‘cluster-admin’ role is required to deploy IBM Watson Assistant.

1.  Create a `wa-override.yaml` file and define any custom configuration settings

    Here is a sample file for reference:
    
    ```yaml
    global:
      # The storage class used for datastores
      storageClassName: "portworx-assistant"
  
      # Choose between "Development" and "Production"
      deploymentType: "Production"
 
      # The name of the secret for pulling images.
      # The value for "global.image.pullSecret" below does not need to be changed for Development
      # installations where pods will pull docker images directly from the Entitled Docker Registry.
      # For Production installations where docker images will be pulled locally to the Openshift
      # Docker Registry, "global.image.pullSecret" will need to be set to the value obtained by
      # running oc get secrets | grep default-dockercfg in the namespace where IBM Cloud
      # Pak for Data is installed.
      
      image:
        pullSecret: "docker-pull-{{ .Release.Namespace }}-cp-icr-io-wa-registry-registry"
  
      # global.languages.[language] - Specifies whether [language] should be installed or not.
      languages:
        english: true
        german:  false
        arabic: false
        spanish: false
        french: false
        italian: false
        japanese: false
        korean: false
        portuguese: false
        czech: false
        dutch: false
        chineseTraditional: false
        chineseSimplified: false
    
    # the storageclass used for postgres backup
    postgres:
      backup:
        dataPVC:
          storageClassName: portworx-assistant
    
    # use "2.5.0.0" for CP4D 2.5.0 (carbon 9) and "3.0.0.0" for CP4D 3.0.0 and 3.0.1 (carbon 10)
    ingress:
      wcnAddon:
        addon:
          platformVersion: "3.0.0.0"
    ```
    
    Further details are found in the **Configuration** section below.

1. Create a `wa-repo.yaml` file

   Here is a sample file for reference:
   
   ```yaml
   registry:
     - url: cp.icr.io/cp/cpd
       username: "cp"
       apikey: <entitlement-key>
       namespace: ""
       name: base-registry
     - url: cp.icr.io
       username: "cp"
       apikey: <entitlement-key>
       namespace: "cp/watson-assistant"
       name: wa-registry
   fileservers:
     - url: https://raw.github.com/IBM/cloud-pak/master/repo/cpd3
   ```
   
   - `<entitlement-key>` is the key from [myibm.com](https://myibm.ibm.com/products-services/containerlibrary)
   - For the fileserver url, use "https://raw.github.com/IBM/cloud-pak/master/repo/cpd for 2.5.0 and https://raw.github.com/IBM/cloud-pak/master/repo/cpd3 for 3.0.1

### Installing the Assembly

1. Run the following command

   ```bash
   oc get secrets | grep default-dockercfg
   ```

1. Modify `wa-override.yaml` file and update **global.image.pullSecret** with the name of the secret you discovered in the previous step. Modify any other values that need to be customized

1. Install Watson Assistant

   ```bash
   ./cpd-linux --repo wa-repo.yaml --assembly ibm-watson-assistant --version {assembly_version} --namespace {namespace} --transfer-image-to $(oc registry info)/{namespace} --target-registry-username={openshift_username} --target-registry-password=$(oc whoami -t) --insecure-skip-tls-verify --cluster-pull-prefix {docker-registry}/{namespace} -o wa-override.yaml
   ```

   - `{assembly_version}` is the release version; currently it is 1.4.2
   - `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.
   - `{openshift_username}` is the Openshift username. Normally:
      - ocadmin for OpenShift 3.X
      - kubeadmin for OpenShift 4.x
   - `{docker-registry}` is the address of the internal OpenShift docker registry. Normally:
      - docker-registry.default.svc:5000 for OpenShift 3.X
      - image-registry.openshift-image-registry.svc:5000 for OpenShift 4.X

### Installing the Assembly on an air-gap cluster
The same version/build of `cpd-linux` is required throughout the process

1. Be sure you have completed the `Setting up the cluster` and `Creating files for installation` steps above

1. Download images and Assembly files

   This should be run in a location with access to internet and the `cpd-linux` tool
   
   ```bash
   ./cpd-linux preloadImages --repo wa-repo.yaml --assembly ibm-watson-assistant --version {assembly_version} --action download --download-path ./wa-workspace
   ```
   
   - `{assembly_version}` is the release version; currently it is 1.4.2

1. Push the `wa-workspace` folder to a location with access to the OpenShift cluster to be installed and the same version of the `cpd-linux` tool used in the preloadImages step above

1. Login to the Openshift cluster 

   ```bash
   oc login
   ```

1. Push the Docker images to the internal docker registry 

   ```bash
   ./cpd-linux preloadImages --action push --load-from ./wa-workspace --assembly ibm-watson-assistant --version {assembly_version} --transfer-image-to $(oc registry info)/zen --target-registry-username {openshift_username} --target-registry-password $(oc whoami -t) --insecure-skip-tls-verify
   ```
   
   - `{assembly_version}` is the release version; currently it is 1.4.2
   - `{openshift_username}` is the Openshift username. Normally:
      - ocadmin for OpenShift 3.X
      - kubeadmin for OpenShift 4.x

1. Run the following command

   ```bash
   oc get secrets | grep default-dockercfg
   ```

1. Modify `wa-override.yaml` file and update **global.image.pullSecret** with the name of the secret you discovered in the previous step. Modify any other values that need to be customized

1. Install Watson Assistant

   ```bash
   ./cpd-linux --load-from ./wa-workspace --assembly ibm-watson-assistant --version {assembly_version} --namespace {namespace} --cluster-pull-prefix {docker-registry}/{namespace} -o wa-override.yaml
   ```
   
   - `{assembly_version}` is the release version; currently it is 1.4.2
   - `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.
   - `{docker-registry}` is the address of the internal OpenShift docker registry. Normally:
      - docker-registry.default.svc:5000 for OpenShift 3.X
      - image-registry.openshift-image-registry.svc:5000 for OpenShift 4.X

### Installing the Assembly with images directly from the Entitled Registry

1. Install Watson Assistant

   ```bash
   ./cpd-linux --repo wa-repo.yaml --assembly ibm-watson-assistant --version {assembly_version} --namespace {namespace} -o wa-override.yaml
   ```
   
   - `{assembly_version}` is the release version; currently it is 1.4.2
   - `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.

## Verifying the chart

1. Check the status of the assembly and modules

   ```bash
   ./cpd-linux status --namespace {namespace} --assembly ibm-watson-assistant [--patches]
   ```
    - `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.
    - `--patches` additionally display applied patches

1.  Setup your Helm environment

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

1. Check the status of resources

   ```bash
   helm status watson-assistant --tls
   ```
   
1.  Run Helm tests

    ```bash
    helm test watson-assistant --tls --timeout=18000 [--cleanup]
    ```
    
    - `--timeout={time}` waits for the time in seconds for the tests to run
    - `--cleanup` deletes test pods upon completion

## Deploying a patch

    ```bash
    ./cpd-linux patch --namespace {namespace} --assembly ibm-watson-assistant --patch-name {patch} --repo wa-repo.yaml
    ```

    - `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.
    - `{patch}` is the name of the patch or fix.

### Uninstalling the chart

To uninstall and delete the `ibm-watson-assistant` deployment, run the following command:

```bash
./cpd-linux uninstall --assembly ibm-watson-assistant --namespace {namespace}
```

The uninstall won't delete the datastore resources; in order to delete the datastore resources you will need to run the following command:

```bash
oc delete job,deploy,replicaset,pod,statefulset,configmap,secret,ingress,service,serviceaccount,role,rolebinding,persistentvolumeclaim,poddisruptionbudget,horizontalpodautoscaler,networkpolicies,cronjob -l release=watson-assistant
```

```bash
oc delete configmap stolon-cluster-watson-assistant
```

If you used local-volumes, you also need to remove any persistent volumes, persistent volume claims and their contents.

## Configuration
The following tables lists the configurable parameters of the IBM Watson Assistant chart and their default values.

### Global parameters

| Parameter                     | Description     | Default |
|-------------------------------|-----------------|---------|
| `global.deploymentType`       | Options are `Development` or `Production`. Select `Production` for a scaled up deployment | `Production` |
| `global.podAntiAffinity`      | Options are `Default`, `Enable` or `Disable`. If `global.deploymentType` is set to `Production` then by default Pod AntiAffinity will be used to ensure each datastores pods will deploy to seperate nodes. If it is set to `Development` then by default Pod AntiAffinity won't be used. The default settings can be overridden here by selecting `Enable` or `Disable` as required. | `Default` |
| `global.keepDatastores`      | Options are `true` or `false`. If `global.keepDatastores` is set to `true` then the datastore objects won't be deleted when running a `helm delete`. | `true` |
| `global.image.pullSecret`     | Name of the (manually created) imagePullSecret used to pull docker images. If empty, the default image pull secret for the IBM Cloud Pak for Data internal Docker repository ( sa-{{ .Release.Name }} ) will be used. | `` (empty value) <UPDATE> |
| `global.icp.masterHostname`   | Required value. Hostname (including the domain parts) of the IBM Cloud Pak for Data cluster Master node. The name where you login to your cluster (at the  https://{{ masterHostname }}:8443). | `` (empty value) |
| `global.icp.masterIP`         | IP(v4) address of the master node. It has to be specified if `global.icp.masterHostname` cannot be resolved inside the pods (i.e., if the `global.icp.masterHostname` is not a valid DNS entry). This IP address has to be accessible from inside of the cluster. | `` (empty value) |
| `global.icp.proxyHostname`    | The hostname of the proxy node inside IBM Cloud Pak for Data cluster (i.e., where the ingress/services are exposed). Used only for documentation purposes. Unlike masterHostname, the IP address is permitted. Defaults to the value specified in `global.icp.masterHostname` if not provided. | `` (empty value) |
| `global.languages.{language}` | Boolean value indicate whether the language is supported. Specify `true` for each language you want to support. English is required. Each language you add increases the number of system resources needed to support it. | `global.languages.english: true`. All other languages are false. For example, `global.languages.italian: false` |
| `global.autoscaling.enabled` | Boolean value to indicate whether Horizontal Pod Autoscaling is enabled for the Watson Assistant deployments.  If enabled, each deployment defaults to 2 min replicas and 10 max replicas with a target CPU utilization of 100% | `true`|
| `global.apiV2.enabled` | Enables V2 API in the Watson Assistant. | `true`|
| `global.clusterDomain` | Specifies the suffix for KubeDNS name. Has to be specified if you cluster is using non-default domain name (i.e., different from `cluster.local`). | `cluster.local` |
| `global.zenNamespace` | Specifies the namespace where IBM Cloud Pak for Data is running. | `zen` |
| `global.topologySpreadConstraints.enabled` | Specifies if the topology spread contraints should be added to deployments | `true` |
| `global.topologySpreadConstraints.maxSkew` | How much the available zone can differ in number of pods | `1` |
| `global.topologySpreadConstraints.topologyKey` | Label on nodes defining failure zone; the nodes with the same values of the label are consider to belong to the same failure zone. | `failure-domain.beta.kubernetes.io/zone` |
| `global.topologySpreadConstraints.whenUnsatisfiable` | Specifies action in case new pod cannot be scheduled because topology contraints. Possible values are `DoNotSchedule` and `ScheduleAnyway` | `ScheduleAnyway`|
| `global.affinity.nodeAffinity. requiredDuringSchedulingIgnoredDuringExecution. nodeSelectorTerms.matchExpressions` | The yaml array specifies additional LabelSelectorRequirements (i.e., key,operator,values triple) on the node labels that needs to be satisfied in order to schedule the pods of Watson assistant on a node. The basic requirement of amd64 architecure label is always added automatically. | `[]` |
| `global.tests.bdd.{test}` | specifies whether each test should be run as a part of the helm test (healthcheck, checkLangs, callouts, dialogs, dialogErrors, dialogV1, dialogV1errors, slots, folders, generic, prebuilt, workspaces, entities, openentities, fuzzy, intents, pattern, spellcheck, oldse, accuracy, authorwksp, cognease, v2snapshots, v1skillscp4d, v2assistcp4d, v2authorskillcp4d, v2authorwksp, v2skillrefcp4d) | `true` for all except callouts which requires internet access |

### Cloud Object Store (COS) parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.cos.create`      | Boolean. Indicates whether you want to provide your own cloud object store or have one created for you. If `true`, a Minio cloud object store is created. Do not set to false. The service does not currently support providing your own store. | `true` |
| `global.cos.bucket`      | Prefix of the bucket names to be used. | `icp` |
| `global.cos.schema`      | Only used if `global.cos.create` is `false`. Schema specifies the protocol used to connect to COS. Options are `http` and `https`. Typical schema is `http`. | `` (empty value) |
| `global.cos.hostname`    | Only used if `global.cos.create` is `false`. Hostname to connect to the store. Typical hostname when COS is running in the cluster is `cos.namespace.svc.cluster.local`. | `` (empty value) |
| `global.cos.port`        | Only used if global.cos.create is false. Port where COS is listening. Typical port is `443`. | `443` |
| `global.cos.auth.secretName` | If you want custom keys to access the store, create a secret containing `accesskey` (5 - 20 characters) and `secretkey` (8 - 40 characters) in base64 encoding and specify the name for that secret here. If empty, random keys are created in a new secret. | `` (empty value) |
| `global.cos.sse.secretName` | If you want a custom key for server side encryption, create a secret containing `sseMasterKey` (32 bytes long HEX value in the format `KEY_NAME:HEX_VALUE`) in base64 encoding and specify the name for that secret here. If empty, a random key is created in a new secret. | `` (empty value) |
| `global.cos.tls.secretName` | If you want to provide a TLS certificate to be used by COS (or to specify certificate authority/Certificate used by provided COS) create a secret containg a private key (key: `tls.key`) and a corresponding certificate (key: `tls.crt`) and CA certificate used to sign the certificate (or the cert itself for self-signed certificate; key `ca.crt`) in base64 encoding  and specify the name for the secret here. If empty, random keys are created in a new secret. Private key is needed only if `global.cos.create` is set to true. | `` (empty value) |

### etcd parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.etcd.create` | Boolean. Specify `true` to have the etcd cluster for the Watson Assistant service created for you. Specifying `false` means you want to provide your own etcd instance and the associated credentials. Do not set to false. The service does not currently support providing your own store. | `true` |
| `global.etcd.connection` | Used only if `global.etcd.create` is `false`. Specifies the connection details to etcd. Follows the format used by `etcdctl` - e.g., `http://etcd-ibm-wcd-etcd.default.svc.cluster.local:2379` | `` (empty value) |
| `global.etcd.auth.user` | User ID used to access etcd. | `root` |
| `global.etcd.auth.authSecretName` | Name of manually created secret that holds password (in key `password`) for the etcd (super) user. If empty a random password is generated. If you use your own etcd instance, then you have to create the secret with proper password. | `` (empty value) |
| `global.etcd.tls.enabled` | Specifies if secured (schema `https`) if set to `true` or plain-text (`http`) communication with etcd is used (for value `false`) | `true` |
| `global.etcd.tlsSecretName` | Name of manually created secret that holds CA certificate ( key `tls.cacrt`) and cert/key pair (signed by CA, keys `tls.crt` and `tls.key`). If `global.etcd.create` is set to `false` only `tls.cakey` is required. If empty (the default value) the CA and keys are automatically generated. | `` (empty value) |
| `etcd.config.dataPVC.size` | Size of the etcd store. | `10Gi` |
| `etcd.config.dataPVC.storageClassName` | Storage class for the etcd store. | `portworx-assistant` |
| `etcd.config.persistence.useDynamicProvisioning` | Boolean. Enables dynamic provisioning. Volumes are dynamically created (if the storage class can be created automatically). If disabled, either dataPVC.selector.label must be specified for the persistent volume claim to be bound to the precreated persistent volume based on labels or dataPVC.storageClassName must be empty and the cluster administrator must bind the persistent volume claims to the existing persistent volumes manually. | `true` |
| `etcd.config.dataPVC.selector.label` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The label specifies the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `etcd.config.dataPVC.selector.value` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The value specifies the value for the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |

### Minio parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cos.minio.replicas`     | Only if the mode is `distributed`. The number of pods used to store the data. Have to be 4<= replicas <=32 | `4` |
| `cos.minio.persistence.size`         | Size of the PVC to be used or created. | `5Gi` |
| `cos.minio.persistence.storageClass` | Storage class for the created persistent volume claim. | `portworx-assistant` |
| `cos.minio.persistence.selector.label` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The label specifies the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `cos.minio.persistence.selector.value` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The value specifies the value for the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `cos.minio.persistence.useDynamicProvisioning` | Boolean. Enables dynamic provisioning. Volumes are dynamically created (if the storage class can be created automatically). If disabled, either persistence.selector.label must be specified for the persistent volume claim to be bound to the precreated persistent volume based on labels or persistence.storageClass must be empty and the cluster administrator must bind the persistent volume claims to the existing persistent volumes manually. | `true` |

### MongoDB parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.mongodb.create` | Boolean. Specify `true` to have a MongoDB database created for you. Specify `false` to provide your own instance. Do not set to false. The service does not currently support providing your own instance. | `true` |
| `global.mongodb.hostname` | Used only if `global.mongodb.create` is `false`. Specifies the hostname of the running MongoDB database service.  | `` (empty value) |
| `global.mongodb.port` | Used only if `global.mongodb.create` is `false`. Specifies the port from which the running MongoDB database service can be accessed. | `27017`|
| `global.mongodb.auth.enabled` | Boolean. Indicates whether to enable authenticateion to MongoDB. | `true` |
| `global.mongodb.auth.existingAdminSecret` | Manually created secret with MongoDB admin `user` and `password`. Leave empty to autogenerate the secret with a random password and the admin user will be taken from global.mongodb.auth.adminUser  |`` (empty value) |
| `global.mongodb.tls.enabled` | Boolean. Indicates whether to enable MongoDB TLS support. | `true` |
| `global.mongodb.tls.existingCaSecret` | Manually created secret containing your own TLS CA. Leave empty to autogenerate the secret with a new self signed cert. The secret must contain `tls.cert` and `tls.key` | `` (empty value) |
| `global.mongodb.replicaSetName` | The mongodb replicaset to use in connection string | `rs0` |
| `mongodb.config.auth.keySecretName` | Manually created secret containing MongoDB Keyfile `key.txt`. Leave empty to autogenerate the secret with a random key.  | `` (empty value) |
| `mongodb.config.persistentVolume.useDynamicProvisioning` | Boolean. Enables dynamic provisioning. Volumes are dynamically created (if the storage class can be created automatically). If disabled, either persistentVolume.selector.label must be specified for the persistent volume claim to be bound to the precreated persistent volume based on labels or persistentVolume.storageClass must be empty and the cluster administrator must bind the persistent volume claims to the existing persistent volumes manually. | `true` |
| `mongodb.config.persistentVolume.storageClass` | Storage class for the created persistent volume claim. | `portworx-assistant` |
| `mongodb.config.persistentVolume.selector.label` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The label specifies the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `mongodb.config.persistentVolume.selector.value` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The value specifies the value for the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |

### MongoDB for Recommends parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `recommendsMongodbLoadEmbeddings.dataPVC.selector.label` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The label specifies the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `recommendsMongodbLoadEmbeddings.dataPVC.selector.value` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The value specifies the value for the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `recommendsMongodbLoadEmbeddings.dataPVC.size` | Size of the etcd store. | `50Gi` |
| `recommendsMongodbLoadEmbeddings.dataPVC.storageClassName` | Storage class for the MongoDB store. | `portworx-assistant` |
| `recommendsMongodbLoadEmbeddings.persistence.enabled` | Indicates whether persistence using Persistent Volume Claims occurs. Otherwise, the empty-dir is used. | `false` |
| `recommendsMongodbLoadEmbeddings.persistence.useDynamicProvisioning` | Boolean. Enables dynamic provisioning. Volumes are dynamically created (if the storage class can be created automatically). If disabled, either dataPVC.selector.label must be specified for the persistent volume claim to be bound to the precreated persistent volume based on labels or dataPVC.storageClassName must be empty and the cluster administrator must bind the persistent volume claims to the existing persistent volumes manually. | `true` |

### Postgres parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.postgres.create` | Boolean. Specify `true` to have a Postgres store created for you. Specify `false` to provide your own instance. Do not set to false. The service does not currently support providing your own store. | `true` |
| `global.postgres.hostname` | Used only if `global.postgres.create` is `false`. Specifies the hostname of the running Postgres service.  | `` (empty value) |
| `global.postgres.port` | Used only if `global.postgres.create` is `false`. Specifies the port from which the running Postgres service can be accessed. | `5432`|
| `global.postgres.auth.user` | User ID for a Postgres super user with rights to create databases and users in the Postgres database. If you use your own instance, then you must change this name and its associated password. |`admin` |
| `global.postgres.auth.authSecretName` | Name of manually created secret that holds password (in key `password`) for the super user. If empty a random password is generated. If you use your own postgres instance, then you have to create the secret with proper password. | `` (empty value) |
| `global.postgres.adminDatabase` | Name of the database to connect to. | `postgres` |
| `global.postgres.sslMode` | SSL mode to use for connection. Options such as `verify-ca` or `verify-full` are not currently supported by the store microservice. Currently, only SSL is supported. Do not change from the default value. | `allow` |
| `global.postgres.sslSecretName` | Name of manually created secret having either certificate (key `tls.crt`) to provided postgres database or certificate and private key (key `tls.key`) for postgres installed by this chart. If empty the self signed cert/key is automatically created. | `` (empty value) |
| `global.postgres.database.create` | Boolean. Specify `true` to have the database (`global.postgres.store.database`) and database user (`global.postgres.store.user`) created for you. If you specify `false`, then you must create the database and database user yourself. | `true` |
| `global.postgres.database.createSchema` | Boolean. Specify `true` to have the required tables, functions, and so on applied to the database that is created for you. | `true` |
| `global.postgres.store.database` | Database name that the store microservice uses. If left empty, the default value  "conversation_icp_{{ .Release.Name }}" is used.| `` (empty value)  |
| `global.postgres.store.auth.user` | User name that the store miroservice uses to connect to the Postgres database. If left empty, the default value "store_icp_{{ .Release.Name }}" is used. | `` (empty value) |
| `global.postgres.store.auth.authSecretName` | Name of the manually created secret that holds password (key `password`) associated with the user ID specified in `global.postgres.store.auth.user`. If empty random password is generated. | `` (empty value) |
| `postgres.config.persistence.storageClassName` | Defines the type of persistent volume class for Postgres to use. Do not specify a value. | `portworx-assistant` |
| `postgres.config.persistence.size` | Size of the persistent volume claim to use. | `10Gi`|
| `postgres.config.persistence.useDynamicProvisioning` | Boolean. Enables dynamic provisioning. Volumes are dynamically created (if the storage class can be created automatically). If disabled, either dataPVC.selector.label must be specified for the persistent volume claim to be bound to the precreated persistent volume based on labels or persistence.storageClassName must be empty and the cluster administrator must bind the persistent volume claims to the existing persistent volumes manually. | `true` |
| `postgres.config.dataPVC.selector.label` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The label specifies the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `postgres.config.dataPVC.selector.value` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The value specifies the value for the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `postgres.backup.suspend` | If set to true, the backup cronjob will be suspended and won't launch any backup jobs. | `false` |
| `postgres.backup.schedule` | The backup schedule in cron format. | `0 23 * * *` |
| `postgres.backup.history.jobs.success` | Defines the number of successful backup jobs to keep. | `30` |
| `postgres.backup.history.jobs.failed` | Defines the number of failed backup jobs to keep. | `10` |
| `postgres.backup.history.files.weeklyBackupDay` | Defines the day of the week to perform a weekly backup. Sunday=0, Monday=1, Tuesday=2 etc. | `0` |
| `postgres.backup.history.files.weekly` | Defines the number of weekly backups to keep i.e. the backups taken on `weeklyBackupDay`. | `4` |
| `postgres.backup.history.files.daily` | Defines the number of daily backups to keep. i.e. the backups taken on days other than ` | `6` |
| `postgres.backup.dataPVC.storageClassName` | Defines the type of persistent volume class for Postgres backups to use. For example, you may  prefer to stores your backups in local-storage. | `portworx-assistant` |
| `postgres.backup.dataPVC.size` | Size of the persistent volume claim to use. | `1Gi`|
| `postgres.backup.dataPVC.selector.label` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The label specifies the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `postgres.backup.dataPVC.selector.value` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The value specifies the value for the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `postgres.backup.persistence.enabled` | Boolean. If set to false, the Postgres dumps will be written to the backup jobs log. | `true` |
| `postgres.backup.persistence.useDynamicProvisioning` | Boolean. Enables dynamic provisioning. Volumes are dynamically created (if the storage class can be created automatically). If disabled, either dataPVC.selector.label must be specified for the persistent volume claim to be bound to the precreated persistent volume based on labels or dataPVC.storageClassName must be empty and the cluster administrator must bind the persistent volume claims to the existing persistent volumes manually. | `true` |

### Redis parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.redis.create` | Boolean. Specify `true` to have a Redis store created for you. Specify `false` to provide your own instance. Do not set to false. The service does not currently support providing your own store. | `true` |
| `global.redis.auth.authSecretName` | If you want to specify a custom password for Redis, create a secret with the password and specify the name of the secret. To create the secret, you can use the command `kubectl create --namespace "{{ .Release.Namespace }}" secret generic customsecrets-redis-password --from-literal=password=YOUR_REDIS_PASSWORD`.  If the name of the secret is empty (the default) a random password is generated. | `` (empty value) |
| `global.redis.hostname` | Used only if `global.redis.create` is `false`. Specifies the hostname of the running Redis service. | `` (empty value) |
| `global.redis.port` | Used only if `global.redis.create` is `false`. Specifies the port from which the running Redis service can be accessed. | `6379` |

### Skill Search parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.skillSearch.encryptionKey.existingSecretName` |  The name of the secret that holds the 128bit AES encryption key (under `authorization_encryption_key`) used to encrypt/decrypt credentials for the Discovery service. If empty, a secret with a random password is generated. | `` (empty value) |

## Limitations

- Only the Intel 64-bit architecture is supported.

## Documentation

Find out more about IBM Watson Assistant by reading the [product documentation](https://cloud.ibm.com/docs/services/assistant-data?topic=assistant-data-index).

**Note**: The documentation link takes you out of IBM Cloud Pak for Data to the public IBM Cloud.

## Integrate with other IBM AI and Watson services

Watson Assistant is one of many IBM Watson services. Additional Watson services on the IBM Cloud allow you to bring Watson's AI platform to your business application, and to store, train, and manage your data in the most secure cloud.

For the full list of available AI and Watson services, see the [IBM Cloud catalog](https://cloud.ibm.com/catalog?category=ai) on the public cloud. (**Note**: This link takes you out of IBM Cloud Pak for Data to the public IBM Cloud.)

Watson services are currently organized into the following categories for different requirements and use cases:

- **Empathy**: Understand tone, personality, and emotional state
- **Knowledge**: Get insights through accelerated data optimization capabilities
- **Language**: Analyze text and extract metadata from unstructured content
- **Speech**: Convert text and speech with the ability to customize models
- **Vision**: Identify and tag content then analyze and extract detailed information found in images

_Copyright©  IBM Corporation 2020, 2021. All Rights Reserved._
