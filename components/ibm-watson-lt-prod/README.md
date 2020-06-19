# ibm-watson-lt-prod

[IBM Watson™ Language Translator](https://www.ibm.com/watson/services/language-translator/index.html#about) allows you to translate text programmatically from one language into another language.

# Introduction

Expand to new markets by instantly translating your documents, apps, and webpages. Create multilingual chatbots to communicate with your customers on their terms. What will you build with the power of language at your fingertips?

## Chart Details

This chart installs the Watson Language Translator as a **service for IBM Cloud Pak for Data** (https://www.ibm.com/products/cloud-pak-for-data).

After a successful installation, go to your Cloud Pak for Data UI and you will find the Language Translator service listed in the catalog.

This chart creates several pods, statefulsets, services, and secrets to create the Language Translator offering.

Deployments:

* `{release-name}-ibm-watson-lt-api` (api server)
* `{release-name}-ibm-watson-lt-documents` (document translation)
* `{release-name}-ibm-watson-lt-lid` (language identification backend)
* `{release-name}-ibm-watson-lt-segmenter` (sentence splitting backend)
* For each installed language pair `<source>-<target>` (e.g. `en-de`):
  * : `{release-name}-ibm-watson-lt-engine-<source>-<target>` (translation backend for a language pair)


Statefulsets:

* `{release-name}-ibm-minio` (S3-API compatible storage)
* `{release-name}-ibm-postgresql-keeper` (highly available PostgreSQL)

ConfigMaps:

* `{release-name}-ibm-minio`
* `{release-name}-ibm-watson-lt-api-config`
* `{release-name}-ibm-watson-lt-documents-config`
* `{release-name}-ibm-watson-lt-model-config`
* `{release-name}-ibm-watson-lt-language-translator-gateway`
* `stolon-cluster-{release-name}-postgres`


Secrets:

* `{release-name}-ibm-postgresql-auth-secret` (PostgreSQL authentication)
* `{release-name}-ibm-postgresql-tls-secret` (PostgreSQL TLS certs)
* `{release-name}-ibm-minio-auth` (MinIO authentication)
* `{release-name}-ibm-minio-tls` (MinIO TLS certs)

## Prerequisites

* IBM® Cloud Pak for Data V2.5.0.0 or V3.0.0.0
* Kubernetes V1.11.0 for IBM Cloud Pak for Data V2.5.0.0
* Kubernetes V1.16.2 for IBM Cloud Pak for Data V3.0.0.0
* Helm 2.9.0 or later
* For a production mode installation, persistent volumes are set up, prior to installation; see [Storage](#storage-class-and-persistent-volume-set-up) section.

## Language Support via separate *Language Paks*

Translation models are provided in three separate installation modules. You need to select at least one language pak module as a prerequisite to installing the Watson Language Translator service.

A language pak module has a collection of Docker images, one for each language pair that you might want to install. Each Docker image for a language pair (e.g. English to German translation) has a size between 1GB and 2.5GB on disk.

**Note**: Please see steps 5, 6 and 8 in the [Setting up the Environment](#setting-up-environment) section for more installation details.

Languages are grouped into the following modules:

### IBM Watson Language Translator Language Pak 1 (CC47TML) - Module watson-language-pak-1

For each of the following languages, the module contains a translation model for *English* to the language and a reverse translation model for the language into *English*:

| Language       | Language Code |
|----------------|---------------|
| Arabic         | `ar`          |
| Chinese (simplified)| `zh`     |
| Chinese (traditional)| `zh-TW` |
| French         | `fr`          |
| German         | `de`          |
| Hebrew         | `he`          |
| Italian        | `it`          |
| Portuguese (Brazilian)| `pt`   |
| Russian        | `ru`          |
| Spanish        | `es`          |
| Turkish        | `tr`          |


### IBM Watson Language Translator Language Pak 2 (CC47UML) - module watson-language-pak-2

For each of the following languages, the module contains a translation model for *English* to the language and a reverse translation model for the language into *English*:

| Language       | Language Code |
|----------------|---------------|
| Bengali        | `bn`          |
| Gujarati       | `gu`          |
| Hindi          | `hi`          |
| Indonesian     | `id`          |
| Japanese       | `ja`          |
| Korean         | `ko`          |
| Malay          | `ms`          |
| Malayalam      | `ml`          |
| Maltese        | `mt`          |
| Nepali         | `ne`          |
| Sinhala        | `si`          |
| Tamil          | `ta`          |
| Telugu         | `te`          |
| Thai           | `th`          |
| Urdu           | `ur`          |
| Vietnamese     | `vi`          |


### IBM Watson Language Translator Language Pak 3 (CC47VML) - module watson-language-pak-3

For each of the following languages, the package contains a translation model for *English* to the language and a reverse translation model for the language into *English*:

| Language       | Language Code |
|----------------|---------------|
| Bulgarian      | `bg`          |
| Croatian       | `hr`          |
| Czech          | `cs`          |
| Danish         | `da`          |
| Dutch          | `nl`          |
| Estonian       | `et`          |
| Finnish        | `fi`          |
| Greek          | `el`          |
| Hungarian      | `hu`          |
| Irish          | `ga`          |
| Latvian        | `lv`          |
| Lithuanian     | `lt`          |
| Norwegian Bokmål | `nb`        |
| Polish         | `pl`          |
| Romanian       | `ro`          |
| Slovak         | `sk`          |
| Slovenian      | `sl`          |
| Swedish        | `sv`          |

#### Extra Non-English Language Pairs in Language Pak 3:

| Language Pair  | Language Pair Codes   |
|----------------|-----------------------|
| Catalan <-> Spanish | `ca-es`, `es-ca` |
| German <-> French   | `de-fr`, `fr-de` |
| German <-> Italian  | `de-it`, `it-de` |
| French <-> Spanish  | `fr-es`, `es-fr` |

# PodSecurityPolicy Requirements

Not applicable for service.

# SecurityContextConstraints Requirements

If running in a Red Hat OpenShift cluster, this chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there is a cluster scoped as well as namespace scoped pre-install script that must be run. The predefined PodSecurityPolicy name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart. **If your target namespace is bound to this predefined policy, you can skip this section**.

The SecurityContextConstraint resource can also be created manually. A cluster admin can save this template to a yaml file and run the command below:

```bash
kubectl create -f ibm-lt-prod-scc.yaml
```

Template for a SecurityContextConstraints definition, currently equivalent `restricted`, to bind to your namespace.

* Custom SecurityContextConstraints definition:

```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    cloudpak.ibm.com/version: "1.1.2"
  name: ibm-lt-prod-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: false
allowedCapabilities: []
allowedFlexVolumes: []
allowedUnsafeSysctls: []
defaultAddCapabilities: []
defaultPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
fsGroup:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seccompProfiles:
- docker/default
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
priority: 0
```

After creating the scc, you can bind the SCC to the namespace with this command, replacing `$namespace` with the namespace you're deploying to:

```bash
oc adm policy add-scc-to-group ibm-lt-prod-scc system:serviceaccounts:$namespace
```

- `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally zen).
### Resources Required

In addition to the [general hardware requirements and recommendations](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/plan/rhos-reqs.html), the IBM Language Translator service has the following requirements:

| Resource       | Dev  | Prod (HA) |
|----------------|----- |-----------|
| Minimum CPU    | 8    | 16        |
| Minimum Memory | 30GB | 80GB      |


The dev requirements are based on:

* single replicas for service components
* 2 installed translation models

The prod (HA) requirements are based on:

* 2 replicas (highly available mode) for service components
* 6 installed translation models

## Storage Requirements

| Datastore      | Space per PVC | Storage type | Supported Storage Classes |
|----------------|---------------|--------------|---------------------------|
| PostgreSQL     | 10 GB | Block Storage | portworx, EBS, vsphere           |
| Minio          | 10 GB | Block Storage | portworx, EBS, vsphere           |

### Storage Class and Persistent Volume Set Up

A Persistent Volume (PV) is a unit of storage in the cluster. In the same way that a node is a cluster resource, a persistent volume is also a resource in the cluster. For an overview, see Persistent Volumes in the [Cloud Pak for data storage add-ons documentation](https://www.ibm.com/support/knowledgecenter/SSQNUZ_2.1.0/com.ibm.icpdata.doc/zen/admin/install-storage-add-ons.html).

You can use a Cloud Pak for Data storage add-on, or a storage option that is hosted outside the cluster, such as the [vSphere Cloud Provider](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/vsphere_land.html).

Note the storage class volume type requirements below when selecting your storage options.

To see the available storage classes in your cluster, or to verify that you have properly set up persistent volumes and storage classes, run the applicable command and confirm the storage class you configured is listed:

On ICP with Kubernetes:

```bash
kubectl get storageclass
```

On OpenShift:

```bash
oc get storageclass
```

## Pre-install steps

1. Obtain your entitlement license API key from the [Container software library on My IBM](https://myibm.ibm.com/products-services/containerlibrary) and your IBM ID. After you order IBM Cloud Pak for Data, an entitlement key for the software is associated with your My IBM account. To get the entitlement key:

   1. Log in to [Container software library on My IBM](https://myibm.ibm.com/products-services/containerlibrary) with the IBM ID and password that are associated with the entitled software.
   2. On the Get entitlement key tab, select Copy key to copy the entitlement key to the clipboard.
   3. Save the API key in a text file.

2. Prepare a Linux or Mac OS client workstation to run the installation from. The workstation does not have to be a node of the cluster, but must have internet access and be able to connect to the Red Hat OpenShift cluster.
3. If you don't have OpenShift CLI (`oc` command) on the same workstation, download and extract client tools from the [Download OKD](https://www.okd.io/download.html) web site.
4. If you don't have CP4D installer, download it from [here](http://www.ibm.com/support/knowledgecenter/SSQNUZ_3.0.0/cpd/install/install.html).
5. Edit the server definition file `repo.yaml` that you downloaded.

   `repo.yaml` file specifies the repositories for the cpd command to download the installation files from. Make the following changes to the file:

   | Parameter  | Value                                    |
   |------------|------------------------------------------|
   | `username` | Specify `cp`                             |
   | `apikey`   | Specify your entitlement license API key |


Run the following commands to do pre-installation set up of the cluster:

1.  Log into OpenShift:

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
    - `{cp4d_namespace}` is the namespace where CP4D is installed. In CP4D 2.5 or 3.0, you are able to install Watson Language Translator into only the namespace where CP4D is installed.

1.  Set up required labels.

    A label must be added to the namespace where IBM Cloud Pak for Data is installed (normally zen).

    ```bash
    oc label --overwrite namespace {namespace} ns={namespace}
    ```
    
    - `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally zen).

1.  Make sure you are pointing at the correct OpenShift project

    ```bash
    oc project {namespace}
    ```

    - `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally zen).


### Setting up Environment

1. **Initialize Helm**: Initialize the Helm client by running the following command. For further details of Helm CLI setup, see [Installing the Helm CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/app_center/create_helm_cli.html).

    ```bash
    export HELM_HOME={helm_home_dir}
    helm init --client-only
    ```

    * `{helm_home_dir}` is your Helm config directory. For example, `~/.helm`.

2. **Kubernetes/OpenShift Login**: Log into the Kubernetes cluster and target the namespace or project the chart will be deploy to. 

    ```bash
    oc login https://{cluster_hostname}:8443 -u {user} -p {password}
    ```
3.  Create a `lt-override.yaml` file and define any custom configuration settings.

    Here is an exemplary override file:
    
    ```yaml
    global:
      storageClassName: "{storage_class}"

      image:
        pullSecret: "docker-pull-{{ .Release.Namespace }}-cp-icr-io-lt-registry-registry"
        
    ```
    - `{storage_class}` is the StorageClass name specified in the StorageClass definition.

1.  If the <target_namespace> is different from `zen`, set the following parameter:

    ```bash
    gateway:
      addonService:
        zenNamespace: <target_namespace>
    ```

1.  If installing a production configuration (`ibm-watson-lt/prod-values-override.yaml`) and using persistent volumes for the data stores, set the storage class if it is different from `portworx-sc` (`portworx-sc` is the default in the production configuration):
    ```yaml
    global:
      storageClassName: "{storage_class}"
        
    ```
    - `{storage_class}` is the StorageClass name specified in the StorageClass definition.
    
    Enable persistent volume
    
    For MinIO (s3):

    ```bash
    s3:
      persistence:
        enabled: true
        size: 10Gi
    ```

    For PostgreSQL:

    ```bash
    postgres:
      persistence:
        enabled: true
        size: 10Gi
    ```

1. **Enabling Language Support**:

    You need to **enable at least one language pair** in the installation configuration before proceeding with the chart installation. In the predefined *development* and *production* configurations, all language pairs are disabled by default. To enable a language pair, add the desired language pair and set the `enabled` parameter to `true`. 

    ```bash
    translationModels:
      ...
      de-en:
        enabled: true  # <--- set this to true to enable the German to English translation model
      ...
    ```
1. **lt-override.yaml - Here is an exemplary override file for zen namespace and portworx-sc storageclass**:

    ```bash
    global:
      storageClassName: "portworx-sc"

      image:
        pullSecret: "docker-pull-zen-cp-icr-io-lt-registry-registry"

    gateway:
      addonService:
        zenNamespace: zen

    s3:
      persistence:
        enabled: true
        size: 10Gi

    postgres:
      persistence:
        enabled: true
        size: 10Gi

    translationModels:
      ar-en:
        enabled: true
      de-en:
        enabled: true
    ```

    **Important**: For every language pair that you enable in the configuration, please make sure that the module is included during deployment.

    Please note that the **CPU and memory requirements are based on installation of 2 language pairs for development and 6 language pairs for production** (also see section [Resources Required](#resources-required)).

    Further details are found in the **Configuration** section below.

1. Create a `lt-repo.yaml` file

   Here is an exemplary repo file:
   
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
        namespace: "cp/watson-lt"
        name: lt-registry
    fileservers:
      - url: https://raw.github.com/IBM/cloud-pak/master/repo/cpd3
   ```
   
   - `<entitlement-key>` is the key from [myibm.com](https://myibm.ibm.com/products-services/containerlibrary)

## Installing the Chart

### Installing the Assembly
  - Use `cpd-Operating_System` command. (e.g. cpd-linux, cpd-darwin)

  If deploying on CP4D 2.5
  ```bash
  cd bin/
  ./cpd-linux adm -s ../repo.yaml --assembly watson-language-translator --namespace {namespace} --apply
  ./cpd-linux --repo ../repo.yaml --assembly watson-language-translator --namespace {namespace} --storageclass {storage_class} -o ../lt-override.yaml
  ```

  If deploying on CP4D V3.0.1 there are 3 language module which can be selected based on models which are needed. see [Prerequisites](#Prerequisites) section.
  ```bash
  cd bin/
  ./cpd-linux adm -s ../repo.yaml --assembly watson-language-translator --namespace {namespace} --apply
  ./cpd-linux --repo ../repo.yaml --assembly watson-language-translator --optional-modules {modules} --namespace {namespace} --storageclass {storage_class} -o ../lt-override.yaml
  ``` 

- `{modules}` Select one or more module and they should be comma separated. 
  - `watson-language-pak-1,watson-language-pak-2,watson-language-pak-3`
- `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.
- `{assembly_version}` is the release version; currently it is 1.1.2
- `{storage_class}` is the StorageClass name specified in the StorageClass definition.

### Installing the Assembly on an air-gap cluster
The same version/build of `cpd-linux` is required throughout the process
1. Be sure you have completed the `Setting up the cluster` and `Creating files for installation` steps above

1. Download images and Assembly files

  The same version/build of `cpd-linux` is required throughout the process. This should be run in a location with access to internet and the `cpd-linux` tool

  If deploying on CP4D V2.5.0.0
  ```bash
  ./cpd-linux preloadImages --repo lt-repo.yaml --assembly watson-language-translator --version ${assembly_version} --action download --download-path ./lt-workspace
  ```

  If deploying on CP4D V3.0.1 there are 3 language module which can be selected based on models which are needed. see [Prerequisites](#Prerequisites) section.

  ```bash
  ./cpd-linux preloadImages --repo lt-repo.yaml --assembly watson-language-translator --optional-modules {modules}  --version ${assembly_version} --action download --download-path ./lt-workspace
  ```
  - `{modules}` Select one or more module and they should be comma separated. 
    - `watson-language-pak-1,watson-language-pak-2,watson-language-pak-3`
  - `{assembly_version}` is the release version; currently it is 1.1.2

1. Push the `lt-workspace` folder to a location with access to the OpenShift cluster to be installed and the same version of the `cpd-linux` tool used in the preloadImages step above

1. Login to the Openshift cluster 

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
    - `{cp4d_namespace}` is the namespace where CP4D is installed. In CP4D 2.5 or 3.0, you are able to install Watson Language Translator into only the namespace where CP4D is installed.

1. Push the Docker images to the internal docker registry 

  If deploying on CP4D V2.5.0.0
  ```bash
  ./cpd-linux preloadImages --action push --load-from ./lt-workspace --assembly watson-language-translator --version ${assembly_version} --transfer-image-to $(oc registry info)/zen --target-registry-username $(oc whoami) --target-registry-password $(oc whoami -t) --insecure-skip-tls-verify
  ```
  
  If deploying on CP4D V3.0.1
  ```bash
  ./cpd-linux preloadImages --action push --load-from ./lt-workspace --assembly watson-language-translator --optional-modules {modules} --version ${assembly_version} --transfer-image-to $(oc registry info)/zen --target-registry-username kubeadmin --target-registry-password $(oc whoami -t) --insecure-skip-tls-verify
  ```
 
  - `{assembly_version}` is the release version; currently it is 1.1.2
   
1. Run the following command
   
   ```bash
   oc get secrets | grep default-dockercfg
   ```
   
1. Modify `lt-override.yaml` file and update `global.image.pullSecret` with the name of the secret you discovered in the previous step. Modify any other values that need to be customized (dockerRegistryPrefix, storageClassName)
    ```bash
    global:
      image:
        pullSecret: "docker-pull-zen-cp-icr-io-lt-registry-registry" #<-- Following value
    ```

   
1. Install Watson Language Translator

   If deploying on CP4D V2.5.0.0
   ```bash
   ./cpd-linux --load-from ./lt-workspace --assembly watson-language-translator --version ${assembly_version} --namespace {namespace} --cluster-pull-prefix {docker-registry}/{namespace} --storageclass {storage_class} -o ../lt-override.yaml
   ```
   
   If deploying on CP4D V3.0.1
   ```bash
   ./cpd-linux --load-from ./lt-workspace --assembly watson-language-translator --optional-modules {modules} --version ${assembly_version} --namespace {namespace} --cluster-pull-prefix {docker-registry}/{namespace} --storageclass {storage_class}  -o ../lt-override.yaml
   ```
   
   - `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.
   - `{docker-registry}` is the address of the internal OpenShift docker registry. Normally 
      - docker-registry.default.svc:5000 for 3.x 
      - image-registry.openshift-image-registry.svc:5000 for 4.x
   - `{assembly_version}` is the release version; currently it is 1.1.2
   - `{storage_class}` is the StorageClass name specified in the StorageClass definition.

## Verifying the chart

1. Check the status of the assembly and modules

   ```bash
   ./cpd-linux status --namespace {namespace} --assembly watson-language-translator
   ```
    - `{namespace}` is the namespace IBM Cloud Pak for Data was installed into, normally `zen`.

1.  Setup your Helm environment: 

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
    Client: &version.Version{values}
    Server: &version.Version{values}
    ```

1. See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command:

   ```bash
   helm status {release-name} --tls
   ```
   
1.  Test the installation by running:

    ```bash
    helm test {release-name} --tls [--timeout=600] [--cleanup]
    ```
    
    - `--timeout={time}` waits for the time in seconds for the tests to run. Keep it above 600 as default
    - `--cleanup` deletes test pods upon completion
    - Remove the `--tls` flag for the described helm commands if your helm installation is not secured over tls.
    - Remove the `--cleanup` flag if you want to keep the test pod, e.g. to look at its logs.

1. Navigate to your Cloud Pak for Data home page and provision a Watson Language Translator service instance:

    Get the hostname of the remote cluster where Watson Language Translator is being installed:

    ```bash
    oc get routes -n ${TARGET_NAMESPACE}
    ```

    In a browser, enter `https://<hostname>:31843` in the address field and log in. Open the Add-ons page or Services page (located near the top right corner of the page) and select the Watson Language Translator tile. Select Provision instance in the menu.

### Uninstalling the Chart

### Uninstalling the chart

To uninstall and delete the `watson-language-translator` deployment, run the following command:

```bash
./cpd-linux uninstall --assembly watson-language-translator --namespace {namespace}
```

The uninstall won't delete the datastore resources; in order to delete the datastore resources you will need to run the following command:

```bash
oc delete job,deploy,replicaset,pod,statefulset,configmap,secret,ingress,service,serviceaccount,role,rolebinding,persistentvolumeclaim,poddisruptionbudget,horizontalpodautoscaler,networkpolicies,cronjob -l release=watson-language-translator
```

```bash
oc delete configmap stolon-cluster-{release-name}-postgres
```

If you used local-volumes, you also need to remove any persistent volumes, persistent volume claims and their contents.

## Helpful Hints

### Use Helm for a Remote Cluster

* Set the local environment variable export TILLER_NAMESPACE
* Run helm init --client-only
* Run helm list --tls to see the installed helm releases
* If certificates for helm are needed, try running:

    ```bash
    ca_pem_file_path="${HOME}/.helm/ca.pem"
    cert_pem_file_path="${HOME}/.helm/cert.pem"
    key_pem_file_path="${HOME}/.helm/key.pem"

    echo "write ca.pem file to ${ca_pem_file_path}"
    echo `oc get secret -n ${TARGET_NAMESPACE} helm-secret -o go-template --template='{{ index .data "ca.cert.pem"}}' |  base64 --decode > ${ca_pem_file_path}`
    oc get secret -n ${TARGET_NAMESPACE} helm-secret -o go-template --template='{{ index .data "ca.cert.pem"}}' |  base64 --decode > ${ca_pem_file_path}

    echo "write helm.key.pem to ${key_pem_file_path}"
    echo `oc get secret -n ${TARGET_NAMESPACE} helm-secret -o go-template --template='{{ index .data "helm.key.pem"}}' |  base64 --decode > ${key_pem_file_path}`
    oc get secret -n ${TARGET_NAMESPACE} helm-secret -o go-template --template='{{ index .data "helm.key.pem"}}' |  base64 --decode > ${key_pem_file_path}

    echo "write helm.cert.pem to ${cert_pem_file_path}"
    echo `oc get secret -n ${TARGET_NAMESPACE} helm-secret -o go-template --template='{{ index .data "helm.cert.pem"}}' |  base64 --decode > ${cert_pem_file_path}`
    oc get secret -n ${TARGET_NAMESPACE} helm-secret -o go-template --template='{{ index .data "helm.cert.pem"}}' |  base64 --decode > ${cert_pem_file_path}
    ```

### How to Remove a Watson Language Translator Installation

For example, in cases of misconfiguration, a Helm installation might fail or a Helm deinstallation might not proceed properly. To fully delete a Helm release, add the following function to .bashrc:

```bash
function helm_clean (){
  set -x
  helm delete "$@" --tls --purge
  kubectl delete jobs -l release="$@"
  kubectl delete deployments -l release="$@"
  kubectl delete replicaset -l release="$@"
  kubectl delete pod -l release="$@"
  kubectl delete serviceaccount -l release="$@"
  kubectl delete role -l release="$@"
  kubectl delete rolebindings -l release="$@"
  kubectl delete secret -l release="$@"
  kubectl delete service -l release="$@"
  kubectl delete configmaps -l release="$@"
  kubectl delete statefulsets -l release="$@"
  kubectl delete pvc -l release="$@"
  set +x
}
```

And then run:

```bash
. <path to your bashrc>
helm_clean <release-name>
```

# Limitations

* Watson Language Translator can currently run only on Intel 64-bit architecture.
* Datastores (PostgreSQL, MinIO) only support block storage for persistence.
* The chart must be installed by a cluster administrator. See [Pre-install steps](#pre-install-steps).
* Release names cannot be longer than 20 characters, should be lower case characters.

## Documentation

Find out more about IBM Watson Language Translator for Cloud Pak for Data by reading the [product documentation](https://cloud.ibm.com/docs/services/language-translator-data).

### Configuration

### Global parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.dockerRegistryPrefix` | When installing via the CLI, this value must be set to `cp.icr.io/cp/watson-lt` | `cp.icr.io/cp/watson-lt`|
| `global.storageClassName` | Storage class name of PVC | `portworx-sc`                                                   |

### Add-on parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
|`gateway.addonService.zenNamespace` | Namespace where the add-on is installed | `zen`|

### API parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `api.replicas` | number of replicas | `1` |
| `api.resources.cpuRequestMillis` | requested milli CPUs per pod | `200` |
| `api.resources.cpuLimitMillis` | not guaranteed maximum milli CPU limit per pod | `1000` |
| `api.resources.memoryRequestMB` | requested memory in MB per pod | `256` |
| `api.resources.memoryLimitMB` | not guaranteed maximum memory in MB per pod | `512` |
| `api.config.rootLogLevel` | log level, allowed values: `trace`, `debug`, `info`, `warn`, `error` | `error` |
| `api.config.request_throttling` | allowed requests/s per pod | `500` |

### Documents parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `documents.replicas` | number of replicas | `1` |
| `documents.resources.cpuRequestMillis` | requested milli CPUs per pod | `200` |
| `documents.resources.cpuLimitMillis` | not guaranteed maximum milli CPU limit per pod | `1000` |
| `documents.resources.memoryRequestMB` | requested memory in MB per pod | `500` |
| `documents.resources.memoryLimitMB` | not guaranteed maximum memory in MB per pod | `1000` |
| `documents.config.rootLogLevel` | log level, allowed values: `trace`, `debug`, `info`, `warn`, `error` | `warn` |

### Language ID (LID) parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `lid.replicas` | number of replicas | `1` |
| `lid.resources.cpuRequestMillis` | requested milli CPUs per pod | `250` |
| `lid.resources.cpuLimitMillis` | not guaranteed maximum milli CPU limit per pod | `750` |
| `lid.resources.memoryRequestMB` | requested memory in MB per pod | `2000` |
| `lid.resources.memoryLimitMB` | not guaranteed maximum memory in MB per pod | `2000` |

### Segmenter parameters (Sentence Splitting)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `segmenter.replicas` | number of replicas | `1` |
| `segmenter.resources.cpuRequestMillis` | requested milli CPUs per pod | `250` |
| `segmenter.resources.cpuLimitMillis` | not guaranteed maximum milli CPU limit per pod | `750` |
| `segmenter.resources.memoryRequestMB` | requested memory in MB per pod | `2500` |
| `segmenter.resources.memoryLimitMB` | not guaranteed maximum memory in MB per pod | `2500` |

### Translation backend parameters (applied to all configured language pairs)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `translation.replicas` | number of replicas | `1` |
| `translation.resources.cpuRequestMillis` | requested milli CPUs per pod | `1000` |
| `translation.resources.cpuLimitMillis` | not guaranteed maximum milli CPU limit per pod | `5000` |
| `translation.resources.memoryRequestMB` | requested memory in MB per pod | `3500` |
| `translation.resources.memoryLimitMB` | not guaranteed maximum memory in MB per pod | `5000` |

### MinIO parameters (S3 compatible object storage)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `s3.replicas` | Number of replicas of the pod, must be even number. | `4` |
| `s3.persistence.enabled` | Use persistent volume to store data | `false` |
| `s3.persistence.size` | Size of the persistent volume created. | `10Gi` |
| `s3.persistence.storageClassName` |  Storage class name for minio. `portworx-sc`, `vsphere-volume` and `glusterfs` are supported. | `""` |
| `s3.persistence.useDynamicProvisioning` | True to allow the cluster to automatically provision new storage resource and create PersistentVolume objects. | `true` |

### PostgreSQL parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgres.keeper.replicas` | Number of keeper pods in statefulset | `3` |
| `postgres.persistence.enabled` | Use persistent volume to store data | `false` |
| `postgres.persistence.size` | Size of the persistent volume created. | `10Gi` |
| `postgres.persistence.storageClassName` | Storage class name for PostgreSQL: `portworx-sc` and `vsphere-volume` are supported. | `""` |
| `postgres.persistence.useDynamicProvisioning` | True to allow the cluster to automatically provision new storage resource and create PersistentVolume objects. | `true` |

### Language Support Configuration

#### Language Pak1

| Parameter | Description | Default |
|-----------|-------------|---------|
| `translationModels.ar-en.enabled` | Toggle Arabic to English translation | `false` |
| `translationModels.de-en.enabled` | Toggle German to English translation | `false` |
| `translationModels.en-ar.enabled` | Toggle English to Arabic translation | `false` |
| `translationModels.en-de.enabled` | Toggle English to German translation | `false` |
| `translationModels.en-es.enabled` | Toggle English to Spanish translation | `false` |
| `translationModels.en-fr.enabled` | Toggle English to French translation | `false` |
| `translationModels.en-he.enabled` | Toggle English to Hebrew translation | `false` |
| `translationModels.en-it.enabled` | Toggle English to Italian translation | `false` |
| `translationModels.en-pt.enabled` | Toggle English to Portuguese (Brazilian) translation | `false` |
| `translationModels.en-ru.enabled` | Toggle English to Russian translation | `false` |
| `translationModels.en-tr.enabled` | Toggle English to Turkish translation | `false` |
| `translationModels.en-zh.enabled` | Toggle English to Chinese (Simplified) translation | `false` |
| `translationModels.en-zh-TW.enabled` | Toggle English to Chinese (Traditional) translation | `false` |
| `translationModels.es-en.enabled` | Toggle Spanish to English translation | `false` |
| `translationModels.fr-en.enabled` | Toggle French to English translation | `false` |
| `translationModels.he-en.enabled` | Toggle Hebrew to English translation | `false` |
| `translationModels.it-en.enabled` | Toggle Italian to English translation | `false` |
| `translationModels.pt-en.enabled` | Toggle Portuguese (Brazilian) to English translation | `false` |
| `translationModels.ru-en.enabled` | Toggle Russian to English translation | `false` |
| `translationModels.tr-en.enabled` | Toggle Turkish to English translation | `false` |
| `translationModels.zh-en.enabled` | Toggle Chinese (Simplified) to English translation | `false` |
| `translationModels.zh-TW-en.enabled` | Toggle Chinese (Traditional) to English translation | `false` |

#### Language Pak2

| Parameter | Description | Default |
|-----------|-------------|---------|
| `translationModels.en-bn.enabled` | Toggle English to Bengali translation | `false` |
| `translationModels.en-gu.enabled` | Toggle English to Gujarati translation | `false` |
| `translationModels.en-hi.enabled` | Toggle English to Hindi translation | `false` |
| `translationModels.en-id.enabled` | Toggle English to Indonesian translation | `false` |
| `translationModels.en-ja.enabled` | Toggle English to Japanese translation | `false` |
| `translationModels.en-ko.enabled` | Toggle English to Korean translation | `false` |
| `translationModels.en-ml.enabled` | Toggle English to Malayalam translation | `false` |
| `translationModels.en-ms.enabled` | Toggle English to Malay translation | `false` |
| `translationModels.en-mt.enabled` | Toggle English to Maltese translation | `false` |
| `translationModels.en-ne.enabled` | Toggle English to Nepali translation | `false` |
| `translationModels.en-si.enabled` | Toggle English to Sinhala translation | `false` |
| `translationModels.en-ta.enabled` | Toggle English to Tamil translation | `false` |
| `translationModels.en-th.enabled` | Toggle English to Thai translation | `false` |
| `translationModels.en-te.enabled` | Toggle English to Telugu translation | `false` |
| `translationModels.bn-en.enabled` | Toggle Bengali to English translation | `false` |
| `translationModels.gu-en.enabled` | Toggle Gujarati to English translation | `false` |
| `translationModels.hi-en.enabled` | Toggle Hindi to English translation | `false` |
| `translationModels.id-en.enabled` | Toggle Indonesian to English translation | `false` |
| `translationModels.ja-en.enabled` | Toggle Japanese to English translation | `false` |
| `translationModels.ko-en.enabled` | Toggle Korean to English translation | `false` |
| `translationModels.ml-en.enabled` | Toggle Malayalam to English translation | `false` |
| `translationModels.ms-en.enabled` | Toggle Malay to English translation | `false` |
| `translationModels.mt-en.enabled` | Toggle Maltese to English translation | `false` |
| `translationModels.ne-en.enabled` | Toggle Nepali to English translation | `false` |
| `translationModels.si-en.enabled` | Toggle Sinhala to English translation | `false` |
| `translationModels.ta-en.enabled` | Toggle Tamil to English translation | `false` |
| `translationModels.te-en.enabled` | Toggle Telugu to English translation | `false` |
| `translationModels.th-en.enabled` | Toggle Thai to English translation | `false` |

#### Language Pak3

| Parameter | Description | Default |
|-----------|-------------|---------|
| `translationModels.bg-en.enabled` | Toggle Bulgarian to English translation | `false` |
| `translationModels.ca-es.enabled` | Toggle Catalan to Spanish translation | `false` |
| `translationModels.cs-en.enabled` | Toggle Czech to English translation | `false` |
| `translationModels.da-en.enabled` | Toggle Danish to English translation | `false` |
| `translationModels.de-fr.enabled` | Toggle German to French translation | `false` |
| `translationModels.de-it.enabled` | Toggle German to Italian translation | `false` |
| `translationModels.el-en.enabled` | Toggle Greek to English translation | `false` |
| `translationModels.en-bg.enabled` | Toggle English to Bulgarian translation | `false` |
| `translationModels.en-cs.enabled` | Toggle English to Czech translation | `false` |
| `translationModels.en-da.enabled` | Toggle English to Danish translation | `false` |
| `translationModels.en-el.enabled` | Toggle English to Greek translation | `false` |
| `translationModels.en-et.enabled` | Toggle English to Estonian translation | `false` |
| `translationModels.en-fi.enabled` | Toggle English to Finnish translation | `false` |
| `translationModels.en-ga.enabled` | Toggle English to Irish translation | `false` |
| `translationModels.en-hr.enabled` | Toggle English to Croatian translation | `false` |
| `translationModels.en-hu.enabled` | Toggle English to Hungarian translation | `false` |
| `translationModels.en-lt.enabled` | Toggle English to Lithuanian translation | `false` |
| `translationModels.en-nb.enabled` | Toggle English to Norwegian Bokmål translation | `false` |
| `translationModels.en-nl.enabled` | Toggle English to Dutch translation | `false` |
| `translationModels.en-pl.enabled` | Toggle English to Polish translation | `false` |
| `translationModels.en-ro.enabled` | Toggle English to Romanian translation | `false` |
| `translationModels.en-sk.enabled` | Toggle English to Slovak translation | `false` |
| `translationModels.en-sl.enabled` | Toggle English to Slovenian translation | `false` |
| `translationModels.en-sv.enabled` | Toggle English to Swedish translation | `false` |
| `translationModels.es-ca.enabled` | Toggle Spanish to Catalan translation | `false` |
| `translationModels.es-fr.enabled` | Toggle Spanish to French translation | `false` |
| `translationModels.et-en.enabled` | Toggle Estonian to English translation | `false` |
| `translationModels.fi-en.enabled` | Toggle Finnish to English translation | `false` |
| `translationModels.fr-es.enabled` | Toggle French to Spanish translation | `false` |
| `translationModels.ga-en.enabled` | Toggle Irish to English translation | `false` |
| `translationModels.hr-en.enabled` | Toggle Croatian to English translation | `false` |
| `translationModels.hu-en.enabled` | Toggle Hungarian to English translation | `false` |
| `translationModels.it-de.enabled` | Toggle Italian to German translation | `false` |
| `translationModels.lt-en.enabled` | Toggle Lithuanian to English translation | `false` |
| `translationModels.nb-en.enabled` | Toggle Norwegian Bokmål to English translation | `false` |
| `translationModels.pl-en.enabled` | Toggle Polish to English translation | `false` |
| `translationModels.ro-en.enabled` | Toggle Romanian to English translation | `false` |
| `translationModels.sk-en.enabled` | Toggle Slovak to English translation | `false` |
| `translationModels.sl-en.enabled` | Toggle Slovenian to English translation | `false` |
| `translationModels.sv-en.enabled` | Toggle Swedish to English translation | `false` |
