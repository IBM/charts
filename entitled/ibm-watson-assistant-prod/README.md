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
- **skill-conversation**: Manages dialog skills.
- **skill-search**: Manages search skills.
- **SLAD**: Manages service training capabilities.
- **Store**: API endpoints.
- **TAS**: Manages services model inferencing.
- **UI**: Provides the developer user interface.

This Helm chart installs the following stores:

- **PostgreSQL**: Stores training data.
- **MongoDB**: Stores word vectors.
- **Redis**: Caches data.
- **etcd**: Manages service registration and discovery.
- **Minio**: Stores CLU models.

## Prerequisites

In addition to the system requirements for the cluster (see [System requirements](https://www.ibm.com/support/knowledgecenter/SSQNUZ_2.1.0/com.ibm.icpdata.doc/zen/install/reqs-ent.html)), the Watson Assistant services have their own requirements.

The systems that host a deployment must meet these requirements:

- Watson Assistant for IBM Cloud Pak for Data can run on Intel 64-bit architecture nodes only.
- CPUs must have 2.4 GHz or higher clock speed
- CPUs must support Linux SSE 4.2
- CPUs must support the AVX instruction set extension. See the [AVX Wikipedia page](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions) for a list of CPUs that include this support. The `ed-mm` microservice cannot function properly without AVX support.
- Minimum CPU 10
- Minimum Memory 150 Gi

## Resources Required

The following resources are required in addition to the minimum platform requirements.

In development:

    Minimum worker nodes: 3
    Minimum CPU available: 7
    Minimum memory available: 75Gi
    Minimum disk per node available: 500 GB

In production:

    Minimum worker nodes: 4
    Minimum CPU available: 10
    Minimum memory available: 120Gi
    Minimum disk per node available: 500 GB

## Storage

| Component | Number of replicas | Space per pod | Storage type |
|-----------|--------------------|---------------|--------------|
| Postgres  |                  3 |         10 GB | local-storage |
| etcd      |                  3 |         10 GB | local-storage |
| Minio     |                  4 |         5  GB | local-storage |
| MongoDB   |                  3 |         80 GB | local-storage |

## Installing the chart on IBM Cloud Pak for Data with OpenShift
You can use the Helm chart to deploy up to 30 instances of IBM Watson Assistant.

### OpenShift software prerequisites

- IBM Cloud Pak for Data V2.1.0.1 or V2.1.0.2.
- Kubernetes V1.11.0
- Helm V2.9.0

Before installing Watson Assistant, you must install and configure [`helm`](https://helm.sh/docs/using_helm/#installing-the-helm-client) and [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl).

### Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`nonroot`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

Run this command to bind the SecurityContextConstraints to your namespace:
	
```bash
oc adm policy add-scc-to-group nonroot system:serviceaccounts:{namespace-name}
```

### Installing the Chart
The ‘cluster-admin’ role is required to deploy IBM Watson Assistant.

1.  Log into OpenShift and docker:

    ```bash
    oc login
    docker login -u $(oc whoami) -p $(oc whoami -t) {docker-registry} 
    ```

    - `{docker-registry}` is the address of the internal OpenShift docker registry. For example `docker-registry.default.svc:5000`.

1.  From the OpenShift command line tool, create the namespace in which to deploy the service. Use the following command to create the namespace:

    ```bash
    oc new-project {namespace-name}
    ```

1.  Make sure you are pointing at the correct OpenShift project:

    ```bash
    oc project {namespace-name}
    ```

    - `{namespace-name}` is the Docker namespace that hosts the Docker image. This is the namespace you created in Step 1.

1.  Extract the PPA archive contents:

    ```bash
    cd {compressed-file-dir}
    tar xvfz {compressed-file-name}
    cd charts
    tar xvfz ibm-watson-assistant-prod-1.3.0.tgz
    ```

    - `{compressed-file-dir}` is the name of the dir that you downloaded {compressed_file-name} to.
    - `{compressed-file-name}` is the name of the file that you downloaded from Passport Advantage.

1.  Load the docker images into the OpenShift docker registry:

    ```bash
    cd {compressed-file-dir}/charts/ibm-watson-assistant-prod/ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration
    ./loadImagesOpenShift.sh --path {compressed_file_dir} --namespace {namespace-name} --registry {docker-registry}
    ```

    - `{docker-registry}` is the address of the internal OpenShift docker registry. For example docker-registry.default.svc:5000

    If successful, the docker images should now exist in the OpenShift docker registry.

    If you cannot access the Kubernetes command line tool, see [Enabling access to kubectl CLI](https://www.ibm.com/support/knowledgecenter/SSQNUZ_2.1.0/com.ibm.icpdata.doc/zen/install/kubectl-access.html) for instructions.

1.  Create persistent volumes for the service.

    - For a production deployment, consider using an IBM Cloud Pak for Data storage add-on or a storage option that is hosted outside the cluster, such as vSphere Cloud Provider. 
    - For a development deployment, you can use the `createLocalVolumePV.sh` script that is provided in the archive to create the local storage volumes.

    For more details, see [Creating persistent volumes](https://cloud.ibm.com/docs/services/assistant-data?topic=assistant-data-install-130#install-130-create-pvs).

    **Note**: The documentation link takes you out of IBM Cloud Pak for Data to the public IBM Cloud.

1.  Set up required labels. 

    A label must be added to the namespace where IBM Cloud Pak for Data is installed (usually zen). To meet this requirement there are cluster-scoped pre and post actions that need to occur. Run the script that is provided with the archive to add the label.

    ```bash
    cd {compressed-file-dir}/charts/ibm-watson-assistant-prod/ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration
    ./labelNamespace.sh {namespace}
    ```

    where `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally `zen`).

1.  Edit values in the `values.yaml` file, which is stored in the `{compressed-file-dir}/charts/ibm-watson-assistant-prod` directory. 

    1.  At a minimum, you must provide your own values for the following configurable settings:

        - `global.deploymentType`: Specify whether you want to set up a development or production instance.

        - `global.image.repository`: Specify your docker registry url, including the {namespace}. For example docker-registry.default.svc:5000/{namespace}

        - `global.icp.masterHostname`: Specify the hostname of the master node of your private cloud instance. Do not include the protocol prefix (`https://`) or port number (`:8443`).  For example: `my.company.name.icp.net`.

        - `global.icp.masterIP`: If you did not define a domain name for the master node of your private cloud instance, you are using the default hostname `mycluster.icp`, for example, then you must also specify this IP address.

        - `global.icp.proxyHostname`: Specify the hostname (or IP address) of the proxy node of your private cloud instance.

        - `license`: Read the license files that are provided in the LICENSES directory within the archive package. If you agree to the terms, change this configuration setting from `not accepted` to `accept`. 

        **Attention**: Currently, the service does not support the ability to provide your own instances of resources, such as Postgres or MongoDB. The values YAML file has `{resource-name}.create` settings that suggest you can do so. However, do not change these settings from their default value of `true`.

1.  Fetch the imagePullSecret to be used for training:
    ```bash
    oc get secrets | grep default-dockercfg
    ```

1.  After you define any custom configuration settings, you can install the chart from the Helm command line interface. Enter the following command from the directory where the package was loaded in your local system:

    ```bash
    helm install --set master.slad.dockerRegistryPullSecret={training-secret} --values {compressed-file-dir}/charts/ibm-watson-assistant-prod/values.yaml --namespace {namespace-name} --name {my-release} {compressed-file-dir}/charts/ibm-watson-assistant-prod
    ```

    - `{training-secret}` is the name of the secret from the previous step.
    - `{my-release}` is the name of the helm release.

## Installing the Chart on standalone IBM Cloud Pak for Data
You can use the Helm chart to deploy up to 30 instances of IBM Watson Assistant.

### Standalone IBM Cloud Pak for Data software prerequisites

- IBM Cloud Pak for Data V2.1.0.1 or V2.1.0.2
- Kubernetes V1.11.0
- Helm V2.9.1

### PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```yaml
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is the most restrictive,
          requiring pods to run with a non-root UID, and preventing pods from accessing the host."
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
      name: ibm-restricted-psp-custom-wa
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
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-restricted-clusterrole-custom-wa
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-restricted-psp-custom-wa
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
- Alternatively, you can go to `ibm_cloud_pak/pak_extensions/pre-install/namespaceAdministration` in your chart directory and run ```./createSecurityNamespacePrereqs.sh {namespace-name}```

### Installing the Chart

The ‘cluster-admin’ role is required to deploy IBM Watson Assistant.

1.  From the Kubernetes command line tool, create the namespace in which to deploy the service. Use the following command to create the namespace:

    ```bash
    kubectl create namespace {namespace-name}
    ```

    If you cannot access the Kubernetes command line tool, see [Enabling access to kubectl CLI](https://www.ibm.com/support/knowledgecenter/SSQNUZ_2.1.0/com.ibm.icpdata.doc/zen/install/kubectl-access.html) for instructions.

1.  To load the file from Passport Advantage into IBM Cloud Pak for Data, enter the following command in the IBM Cloud Private command line interface.

    ```bash
    cloudctl catalog load-archive --registry {cluster4d-master-node}:8500/{namespace-name} --archive {compresse-file-name} --repo local-charts
    ```

    - `{compressed-file-name}` is the name of the file that you downloaded from Passport Advantage.
    - `{cluster4d-master-node}` is the IBM Cloud Pak for Data cluster master node url.
    - `{namespace-name}` is the Docker namespace that hosts the Docker image. This is the namespace you created earlier.

1.  If you have a pre-existing version of the service on your cluster, remove the associated ibm-watson-assistant-prod-{release_number}.tgz file.

1.  Run this command to download the chart from the IBM Cloud Pak for Data repository:

    ```bash
    wget https://{cluster_CA_domain}:8443/helm-repo/requiredAssets/ibm-watson-assistant-prod-1.3.0.tgz --no-check-certificate
    ```

1.  Extract the TAR file from the TGZ file, and then extract files from the TAR file by using the following command:

    ```bash
    tar -xvzf /path/to/ibm-watson-assistant-prod-1.3.0.tgz
    ```

1.  Create persistent volumes for the service.

    - For a production deployment, consider using an IBM Cloud Pak for Data storage add-on or a storage option that is hosted outside the cluster, such as vSphere Cloud Provider. 
    - For a development deployment, you can use the `createLocalVolumePV.sh` script that is provided in the archive to create the local storage volumes.

    For more details, see [Creating persistent volumes](https://cloud.ibm.com/docs/services/assistant-data?topic=assistant-data-install-130#install-130-create-pvs).

    **Note**: The documentation link takes you out of IBM Cloud Pak for Data to the public IBM Cloud.

1.  Set up required security policies and labels.
    
    A set of scripts is provided with the Watson Assistant archive package. Use the scripts to set up the appropriate security policies. The provided scripts include:

    - createSecurityNamespacePrereqs.sh: Creates a role binding in the namespace specified and prevents pods that don't meet the ibm-restricted-psp pod security policy from being started. The policy named ibm-restricted-psp is the most restrictive policy. It requires pods to run with a non-root user ID and prevents pods from accessing the host. The role binding rules are defined in the ibm-watson-assistant-prod-roldebinding.tpl file, which is also provided in the archive.
    - labelNamespace.sh: Adds the cluster namespace label to your namespace. The label is needed to permit communication between your application's namespace and the IBM Cloud Pak for Data namespace using a network policy.

    You can add these necessary labels by using the scripts that are provided in the archive. Follow the instructions that are provided with the scripts.

    ```bash
    cd {compressed-file-dir}/charts/ibm-watson-assistant-prod/ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration
    ```

1.  Create the image policy.

    For each image in a repository, an image policy scope of either cluster or namespace is applied. When you deploy an application, IBM Container Image Security Enforcement checks whether the Kubernetes namespace that you are deploying to has any policy regulations that must be applied.

    - Create an image_policy.yaml file with the following content:

      ```
      apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
      kind: ClusterImagePolicy
      metadata:
       name: watson-assistant-{name}-policy
      spec:
       repositories:
          - name: "{cluster4d-master-node}:8500/*"
            policy:
              va:
                enabled: false
      ```

    - Replace the following variables with the appropriate values for your cluster:

      - {cluster4d-master-node}: Specify the hostname for the master node of the IBM Cloud Pak for Data cluster
      - {name}: Specify a name that helps you identify this deployment. You can use the version number of the product, such as 130, for example.

    - Apply the policy by running the following command:

      ```
      kubectl apply -f ./image_policy.yaml
      ```

1.  Edit values in the `values.yaml` file.

    1.  Make a copy of the values.yaml. The `values.yaml` file is stored in the `{compressed-file-dir}/charts/ibm-watson-assistant-prod` directory.  Rename the file. For example, `my-override.yaml`.

    1.  In your copy of the file, remove all but the configuration settings that you want to replace with your own values.

    1.  Edit the Docker image repository values in the file with values that reflect your environment. 
    
        At a minimum, you must provide your own values for the following configurable settings:
	
        - `global.image.repository`: Specify your docker registry url, including the {namespace}. For example `{icp_url}:8500/{namespace}/`.

        - `global.deploymentType`: Specify whether you want to set up a development or production instance.

        - `global.icp.masterHostname`: Specify the hostname of the master node of your private cloud instance. Do not include the protocol prefix (`https://`) or port number (`:8443`).  For example: `my.company.name.icp.net`.

        - `global.icp.masterIP`: If you did not define a domain name for the master node of your private cloud instance, you are using the default hostname `mycluster.icp`, for example, then you must also specify this IP address.

        - `global.icp.proxyHostname`: Specify the hostname (or IP address) of the proxy node of your private cloud instance.

        - `license`: Read the license files that are provided in the LICENSES directory within the archive package. If you agree to the terms, change this configuration setting from `not accepted` to `accept`.

        **Attention**: Currently, the service does not support the ability to provide your own instances of resources, such as Postgres or MongoDB. The values YAML file has `{resource-name}.create` settings that suggest you can do so. However, do not change these settings from their default value of `true`.

1.  After you define any custom configuration settings, you can install the chart from the Helm command line interface. Enter the following command from the directory where the package was loaded in your local system:

    ```bash
    helm install --tls --values {override-file-name} --namespace {namespace-name} --name {my-release} ibm-watson-assistant-prod-1.3.0.tgz
    ```

    - Replace `{my-release}` with a name for your release.
    - Replace `{override-file-name}` with the path to the file that contains the values that you want to override from the values.yaml file provided with the chart package. If you are using local storage, include `wa-persistence.yaml` also. For example: `ibm-watson-assistant-prod/my-override.yaml,wa-persistence.yaml`.
    - Replace `{namespace-name}` with the namespace you created for the service.
    - The `ibm-watson-assistant-prod-1.3.0.tgz` parameter represents the name of the downloaded file that contains the Helm chart.

## Verifying the chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --tls.

### Uninstalling the chart

To uninstall and delete the `my-release` deployment, run the following command:

```bash
$ helm delete --tls my-release
```

To irrevocably uninstall and delete the `my-release` deployment, run the following command:

```bash
$ helm delete --tls --no-hooks --purge my-release
```

If you omit the `--purge` option, Helm deletes resources (except for datastore resources) for the deployment but retains the record with the release name. This approach allows you to roll back the deletion. If you include the `--purge` option, Helm removes all records for the deployment so that the name can be used for another installation.

The `helm delete` won't delete the datstore resources, in order to delete the datastore resources you will need to run the following command:

```bash
$ kubectl delete certificate,networkpolicy,secret,deployment,statefulset,configmap,service,serviceaccount,role,rolebinding,poddisruptionbudget,persistentvolumeclaim,horizontalpodautoscaler -l release=my-release
```

Before you can install a new version of the service on the same cluster, you must remove all content from any persistent volumes and persistent volume claims that were used for the previous deployment.

## Configuration
The following tables lists the configurable parameters of the IBM Watson Assistant chart and their default values.

### Global parameters

| Parameter                     | Description     | Default |
|-------------------------------|-----------------|---------|
| `global.deploymentType`       | Options are `Development` or `Production`. Select `Production` for a scaled up deployment | `Development` |
| `global.podAntiAffinity`      | Options are `Default`, `Enable` or `Disable`. If `global.deploymentType` is set to `Production` then by default Pod AntiAffinity will be used to ensure each datastores pods will deploy to seperate nodes. If it is set to `Development` then by default Pod AntiAffinity won't be used. The default settings can be overridden here by selecting `Enable` or `Disable` as required. | `Default` |
| `global.keepDatastores`      | Options are `true` or `false`. If `global.keepDatastores` is set to `true` then the datastore objects won't be deleted when running a `helm delete`. | `true` |
| `global.image.pullSecret`     | Name of the (manually created) imagePullSecret used to pull docker images. If empty the default image pull secret for internal ICP Docker repository ( sa-{{ .Release.Name }} ) will be used. | `` (empty value) |
| `global.icp.masterHostname`   | Required value. Hostname (including the domain parts) of the ICP cluster Master node. The name where you login to your cluster (at the  https://{{ masterHostname }}:8443). | `` (empty value) |
| `global.icp.masterIP`         | IP(v4) address of the master node. It has to be specified if `global.icp.masterHostname` cannot be resolved inside the pods (i.e., if the `global.icp.masterHostname` is not a valid DNS entry). This IP address has to be accessible from inside of the cluster. | `` (empty value) |
| `global.icp.proxyHostname`    | The hostname of the proxy node inside ICP cluster (i.e., where the ingress/services are exposed). Used only for documentation purposes. Unlike masterHostname, the IP address is permitted. Defaults to the value specified in `global.icp.masterHostname` if not provided. | `` (empty value) |
| `global.languages.{language}` | Boolean value indicate whether the language is supported. Specify `true` for each language you want to support. English is required. Czech is enabled by default. Each language you add increases the number of system resources needed to support it. | `global.languages.english: true` and `global.languages.czech: true`. All other languages are false. For example, `global.languages.italian: false` |
| `global.autoscaling.enabled` | Boolean value to indicate whether Horizontal Pod Autoscaling is enabled for the Watson Assistant deployments.  If enabled, each deployment defaults to 2 min replicas and 10 max replicas with a target CPU utilization of 100% | `true`|
| `global.apiV2.enabled` | Enables V2 API in the Watson Assistant. | `true`|
| `global.clusterDomain` | Specifies the suffix for KubeDNS name. Has to be specified if you cluster is using non-default domain name (i.e., different from `cluster.local`). | `cluster.local` |

### License parameters
| Parameter | Description | Default |
|-----------|-------------|---------|
| `license`      | Must be set to `accept` in order to accept the terms of the IBM license for Helm CLI install | `not accepted` |

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
| `etcd.config.dataPVC.size` | Size of the etcd store. | `1Gi` |
| `etcd.config.dataPVC.storageClassName` | Storage class for the etcd store. Do not specify a value. `local-storage` is used by default, and is the only supported storage type. | `` (empty value) |
| `etcd.config.persistence.useDynamicProvisioning` | Boolean. Enables dynamic provisioning. Volumes are dynamically created (if the storage class can be created automatically). If disabled, either dataPVC.selector.label must be specified for the persistent volume claim to be bound to the precreated persistent volume based on labels or dataPVC.storageClassName must be empty and the cluster administrator must bind the persistent volume claims to the existing persistent volumes manually. | `true` |
| `etcd.config.dataPVC.selector.label` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The label specifies the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `etcd.config.dataPVC.selector.value` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The value specifies the value for the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |

### Minio parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cos.minio.mode`         | The mode in which Minio COS is running. Standalone (i.e., 1 pod) or distributed (4 pods). Distributed mode is suggested for production deployments. | `distributed` |
| `cos.minio.replicas`     | Only if the mode is `distributed`. The number of pods used to store the data. Have to be 4<= replicas <=32 | `4` |
| `cos.minio.persistence.size`         | Size of the PVC to be used or created. | `5Gi` |
| `cos.minio.persistence.storageClass` | Storage class for the created persistent volume claim. Specify `local-storage`; it is the only supported storage type. | `local-storage` |
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
| `global.mongodb.tls.existingCaSecret` | Manually created secret containing your own TLS CA. Leave empty to autogenerate the secret with a new self signed cert. The secret must contain `tls.cert. and `tls.key` |`` (empty value) |
| `mongodb.config.auth.keySecretName` | Manually created secret containing MongoDB Keyfile `key.txt`. Leave empty to autogenerate the secret with a random key.  | `` (empty value) |
| `mongodb.config.persistentVolume.useDynamicProvisioning` | Boolean. Enables dynamic provisioning. Volumes are dynamically created (if the storage class can be created automatically). If disabled, either persistentVolume.selector.label must be specified for the persistent volume claim to be bound to the precreated persistent volume based on labels or persistentVolume.storageClass must be empty and the cluster administrator must bind the persistent volume claims to the existing persistent volumes manually. | `true` |
| `mongodb.config.persistentVolume.storageClass` | Storage class for the created persistent volume claim. Specify `local-storage`; it is the only supported storage type. | `local-storage` |
| `mongodb.config.persistentVolume.selector.label` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The label specifies the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `mongodb.config.persistentVolume.selector.value` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The value specifies the value for the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |

### MongoDB for Recommends parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `recommendsMongodbLoadEmbeddings.dataPVC.selector.label` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The label specifies the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `recommendsMongodbLoadEmbeddings.dataPVC.selector.value` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The value specifies the value for the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `recommendsMongodbLoadEmbeddings.dataPVC.size` | Size of the etcd store. | `50Gi` |
| `recommendsMongodbLoadEmbeddings.dataPVC.storageClassName` | Storage class for the MongoDB store. | `local-storage` |
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
| `postgres.config.persistence.storageClassName` | Defines the type of persistent volume class for Postgres to use. Do not specify a value. `local-storage` is used by default, and is the only supported storage type. | `` (empty value) |
| `postgres.config.persistence.size` | Size of the persistent volume claim to use. | `10Gi`|
| `postgres.config.persistence.useDynamicProvisioning` | Boolean. Enables dynamic provisioning. Volumes are dynamically created (if the storage class can be created automatically). If disabled, either dataPVC.selector.label must be specified for the persistent volume claim to be bound to the precreated persistent volume based on labels or persistence.storageClassName must be empty and the cluster administrator must bind the persistent volume claims to the existing persistent volumes manually. | `true` |
| `postgres.config.dataPVC.selector.label` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The label specifies the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |
| `postgres.config.dataPVC.selector.value` | If `useDynamicProvisioning` is set to false, then the selector label and value settings are used. The value specifies the value for the label that the persistent volume should have to be boundable to created persistent volume claims. | `` (empty value) |

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
| `global.skillSearch.encryptionKey` |  The name of the secret that holds the 128bit AES encryption key (under `authorization_encryption_key`) used to encrypt/decrypt credentials for the Discovery service. If empty, a secret with a random password is generated. | `` (empty value) |

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

_Copyright©  IBM Corporation 2018, 2019. All Rights Reserved._
