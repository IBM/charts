![IBM Watson Compare and Comply logo](https://raw.githubusercontent.com/IBM-Bluemix-Docs/images/master/cnc-prod-banner.png)

# IBM Watson Compare and Comply

## Introduction

IBM Watson&trade; Compare and Comply enables understanding of governing business documents with pre-trained models so enterprises can get started in minutes. The document conversion (programmatic and scanned PDF, TIFF, JPEG, Word) capabilities enable both machine-to-machine and machine-to-human readable formats. The table understanding, element classification, and comparison capabilities of Compare and Comply enable automation of complex business processes such as contract review and negotiation, invoice reconciliation, software entitlement verification, and more. Such automation of processes result in increased productivity, minimization of costs, and reduced exposure.

Compare and Comply provides:

  - Natural language understanding of contracts and other governing documents
  - Conversion of PDFs, images (PNG, TIFF, JPEG), and Word into HTML
  - Identification of parties in the contracts and the obligations and rights assigned to each
  - Automatic labeling of sentences in contracts with categories such as termination, privacy, payment terms, and more
  - A Compare API that analyzes two contracts, side-by-side, and highlights similarities and differences at the level of individual clauses
  - Table extraction, which parses each cell in the table and associates metadata such as row and column headers

## Chart Details

This chart deploys a single IBM Watson Compare and Comply node with a default pattern.

It includes the following endpoints:

  - A health-check endpoint accessible on `/api/health/check`
  - An element-classification endpoint accessible on `/api/v1/element_classification`
  - An HTML-conversion endpoint accessible on `/api/v1/html_conversion`
  - A table-analyzer endpoint accessible on `/api/v1/tables`
  - A file-comparison endpoint accessible on `/api/v1/comparison`


## Resources Required

  - Minimum CPU: 2200m
  - Minimum memory: 10.25Gi

## Prerequisites
   
  - IBM Cloud Pak for Data 2.1.0 or later
  - Kubernetes 1.11 or later
  - Tiller 2.9.0 or later

Required command-line tools include:

  - [cloudctl](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/manage_cluster/install_cli.html)
  - [kubectl](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/zen/install/kubectl-access.html)
  - [helm](https://helm.sh)
  - [docker](https://www.docker.com/)
  
### IBM Cloud Pak for Data 2.1.0 or later
For information on installing or upgrading to IBM Cloud Pak for Data, See [Installing IBM Cloud Pak for Data](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/zen/install/ovu.html).

## PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:
	```yaml
	apiVersion: extensions/v1beta1
	kind: PodSecurityPolicy
	metadata:
	  name: ibm-cnc-prod-psp
	  annotations:
	    apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
	    apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default 
	    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
	    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
	spec:
	  requiredDropCapabilities:
	  - ALL
	  volumes:
	  - configMap
	  - emptyDir
	  - projected
	  - secret
	  - downwardAPI
	  - persistentVolumeClaim
	  seLinux:
	    rule: RunAsAny
	  runAsUser:
	    rule: MustRunAsNonRoot
	  supplementalGroups:
	    rule: MustRunAs
	    ranges:
	    - min: 1
	      max: 65535
	  fsGroup:
	    rule: MustRunAs
	    ranges:
	    - min: 1
	      max: 65535
	  allowPrivilegeEscalation: false
	  forbiddenSysctls:
	  - "*"
	```
* Custom ClusterRole for the custom PodSecurityPolicy:
	```yaml
	apiVersion: rbac.authorization.k8s.io/v1
	kind: ClusterRole
	metadata:
	  name: ibm-cnc-prod-clusterrole
	rules:
	- apiGroups:
	  - extensions
	  resourceNames:
	  - ibm-cnc-prod-psp
	  resources:
	  - podsecuritypolicies
	  verbs:
	  - use
  ```
	
 From the command line, you can run the setup scripts included under `pak_extensions/pre-install`
  As a cluster admin the pre-install instructions are located at:
  * `pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`
  As team admin the namespace scoped instructions are located at:
  * `pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.
The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

This chart defines a custom `SecurityContextConstraints` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using the supplied instructions or scripts in the `pak_extensions/pre-install` directory.
* From the user interface, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`
  * Custom `SecurityContextConstraints` definition:
  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
    name: ibm-cnc-prod-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowedCapabilities: []
  allowedFlexVolumes: []
  defaultAddCapabilities: []
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

* From the command line, you can run the setup scripts included under `pak_extensions/pre-install`
  As a cluster admin the pre-install instructions are located at:
  * `pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`
  As team admin the namespace scoped instructions are located at:
  * `pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`

## Pre-install steps

See the [bundle installation](https://cloud.ibm.com/docs/services/compare-comply-data?topic=compare-comply-data-install#install) for more detail.

### Setting up Environment

1. Initialize Helm client by running the following command. For further details of Helm CLI setup, see [Installing the Helm CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.1.2/app_center/create_helm_cli.html).

    ```bash
    export HELM_HOME={helm_home_dir}
    helm init --client-only
    ```

     - `{helm_home_dir}` is your Helm config directory. For example, `~/.helm`.

2. Log into the Kubernetes cluster and target the namespace or project the chart will be deploy to. If you're deploying to an ICP cluster, use the `cloudctl` cli.

    ```bash
    cloudctl login -a https://{master_hostname}:8443 -u {user} -p {password}
    ```

    If you're deploying to an OpenShift cluster, use the `oc` cli.

    ```bash
    oc login https://{master_hostname}:8443 -u {user} -p {password}
    ```

3. Log into the cluster's docker registry.

    ICP cluster:

    ```bash
    docker login {master_hostname}:8500 -u {user} -p {password}
    ```

    OpenShift cluster:

    ```bash
    docker login docker-registry.default.svc:5000 -u {user} -p {password}
    ```

4. Download the PPA and create a directory to extract its content to:

    ```
    mkdir ibm-watson-cnc-ppa
    tar -xvf <ppa-archive>  -C ibm-watson-cnc-ppa
    cd ibm-watson-cnc-ppa
    ```

5. This pre-install script has to be run once per namespace by a cluster admin. It runs a kubectl command to add a label to the given namespace.

    From `deploy/pak_extensions/pre-install/clusterAdministration`, run  `./labelNamespace.sh ICP4D_NAMESPACE`, where `ICP4D_NAMESPACE` is the namespace where ICP4D is installed (usually `zen`).

    The namespace `ICP4D_NAMESPACE` **must** have a label for the `NetworkPolicy` to allow nginx and zen pods to communicate with the pods in the namespace where this chart is installed.

6. There are also pre-install scripts that need to be run to install the necessary security resources on the cluster, PSP for non OpenShift clusters, and SCC for OpenShift clusters. The cluster scoped script has to be run once by a cluster admin. The namespace scoped script must be run once for each namespace you're trying to install in and can be run by a team admin.

* From the command line, you can run the setup scripts included under `deploy/pak_extensions/pre-install`
  As a cluster admin the pre-install instructions are located at:
  * `clusterAdministration/createSecurityClusterPrereqs.sh`

  As team admin the namespace scoped instructions are located at:
  * `namespaceAdministration/createSecurityNamespacePrereqs.sh <namespace>`

## Installing the Chart

To deploy Watson Compare and Comply to your cluster, run the `deploy.sh` script included in your ICP4D cluster at `/ibm/InstallPackage/components/deploy.sh`.
Run `./deploy.sh  -h` for help.

The flags you most likely want to include:
```
 ./deploy.sh -d path/to/ibm-watson-compare-comply -O <override-file>.yaml -e <release-name-prefix>
```

In your deploy command `-d` should point to the `ibm-watson-compare-comply` directory or tar file.

By default, the script will look for the tiller pod in the `kube-system` namespace. If your tiller pod is located in a different namespace, you can override it with the `-w` flag. In Openshift, the tiller pod will be in `zen` namespace.

If you would like to change the value of a parameter from its default value, you must create a yaml file in `ibm-watson-compare-comply/`, overriding any values you want and then pass it in your command with `-O <override-file>.yaml`.

The name of the your helm release will be `<namespace>-<release-name-prefix>`. The total length of `<namespace>-<release-name-prefix>` must be [20 characters or less or the installation will fail](#limitations). If you do not pass in `-e flag`, `<release-name-prefix>` will be `wd`.


**NOTE: If you're deploying to an OpenShift cluster, you must**:

  1) Add `-o` flag to your `./deploy.sh` command

  2) Override two values `global.imagePullSecretName` and `global.icpDockerRepo`. In OpenShift, to get the Kubernetes secret that grants access to the cluster's docker registry, run `kubectl get secrets -o=jsonpath='{ range .items[*] }{@.metadata.name}{"\n"}{end}' | grep default-dockercfg`. If you already have an override.yaml file add these key and values to the file, if not, create one in `ibm-watson-compare-comply/`. Run the deploy script with `-O <override-file>.yaml`.

   ```
  global:
    imagePullSecretName: "<secret-name>"
    icpDockerRepo: "<DOCKER_REGISTRY>"
   ```

The rest of the flags can be filled in interactively by the terminal prompt:

`-c`. The console port of ICP4D. Most likely `31843`.

`-n`. The namespace you're deploying to.

`-r`. The registry prefix of the docker image used by the cluster to pull the images.

`-R`. The registry prefix of the docker image used to push the images to. It will be the same as the above when installing from a cluster node (recommended).

For ICP clusters, the values of `-r` and `-R` is `<master_hostname>:8500/<namespace>`.

For OpenShift clusters, the values of `-r` and `-R` is `docker-registry.default.svc:5000/<namespace>`.

## Verifying the Chart

See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command (replace `--tls` with `--tiller-namespace=<tiller namespace>` for OpenShift):

```bash
$ helm status my-release --tls.
```

## Uninstalling the chart

To uninstall and delete the `my-release` deployment, run the following command (replace `--tls` with `--tiller-namespace=<tiller namespace>` for OpenShift):

```bash
$ helm delete --tls my-release
```

To irrevocably uninstall and delete the `my-release` deployment, run the following command (replace `--tls` with `--tiller-namespace=<tiller namespace>` for OpenShift):

```bash
$ helm delete --purge --tls my-release
```

If you omit the `--purge` option, Helm deletes all resources for the deployment, but retains the record with the release name. This allows you to roll back the deletion. If you include the `--purge` option, Helm removes all records for the deployment, so that the name can be used for another installation.

## Post Uninstall Cleanup

Certain Kubernetes resources outside of a helm release may not be deleted from a `helm delete --purge`.
These should be deleted manually.

To delete these resources from the `my-release` deployment that had been deployed in `my-namespace`, run this command:

```bash
kubectl delete --namespace=my-namespace configmaps,jobs,pods,statefulsets,deployments,roles,rolebindings,secrets,serviceaccounts --selector=release=my-release
```

## Delete Instances on Cloud Pak for Data
Should be run before every installation
```sh
./ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration/deleteInstances.sh <ICP4D_NAMESPACE>
```
Where `<ICP4D_NAMESPACE>` is the namespace where ICP4D is installed (usually `zen`).
The scripts removes instances that were deleted as part of a previous installation

## Creating a Compare and Comply instance

1. After the Helm installation completes, log in to the IBM Cloud Pak for Data UI at `https://{hostname}:31843/`.

1. Click the **Add-on** icon at the upper right corner, then locate and click the **Watson Comply and Comply** tile.

1. Click **Provision Instance**.

1. When the instance is ready, click **Manage Instances**.

1. Click the **...** icon on the right, then click **View Details**. The UI displays the URL endpoint and access token for the instance.

Proceed as described in the [Compare and Comply documentation](https://cloud.ibm.com/docs/services/compare-comply-data?topic=compare-comply-data-getting-started).


## Configuration

The following table lists the configurable parameters of the IBM Watson Compare and Comply chart and their default values.

|         Parameter        |                       Description                       |                         Default                          |
|--------------------------|---------------------------------------------------------|----------------------------------------------------------|
| `workerSize`             | Size of the Worker processing a contract document       | `2Cores 10G 1 concurrent document (2 VPC)`               |
| `tls.enabled`            | If this value is false, `tls.cncTlsSecret` is ignored. If true, `tls.cncTlsSecret` should be provided | `false`    |
| `tls.cncTlsSecret`       | If you want to provide a TLS certificate create a secret containg a private key (key: `tls.key`) and a corresponding certificate (key: `tls.crt`) and CA certificate used to sign the certificate (or the cert itself for self-signed certificate; (key `ca.crt`) in base64 encoding and specify the name for the secret here. If empty, random keys are created in a new secret. | `` (empty value)    |

## Limitations

IBM Watson Compare and Comply can currently run only on Intel architecture nodes.

# Integrate with other IBM Watson services

Compare and Comply is one of many IBM Watson services. Additional Watson services on the IBM Cloud and IBM Cloud Private allow you to bring Watson's AI platform to your business application, and to store, train, and manage your data in the most secure cloud.

For the full list of available Watson services, see the IBM Watson catalog on the public IBM Cloud at [https://cloud.ibm.com/catalog/](https://cloud.ibm.com/catalog/?category=ai).

Watson services are currently organized into the following categories for different requirements and use cases:

  - **Assistant**: Integrate diverse conversation technology into your application
  - **Empathy**: Understand tone, personality, and emotional state
  - **Knowledge**: Get insights through accelerated data optimization capabilities
  - **Language**: Analyze text and extract metadata from unstructured content
  - **Speech**: Convert text and speech with the ability to customize models
  - **Vision**: Identify and tag content then analyze and extract detailed information found in images


_Copyright© IBM Corporation 2018, 2019. All Rights Reserved._
