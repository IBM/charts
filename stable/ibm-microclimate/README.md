# Microclimate

## Introduction

Microclimate is an end to end development environment that lets you rapidly create, edit, and deploy applications.

This chart can be used to install Microclimate into a Kubernetes environment.

Visit the [Microclimate landing page](https://microclimate-dev2ops.github.io/) to learn more, or visit our [Slack channel](https://ibm-cloud-tech.slack.com/messages/C8RS7HBHV/) to ask any Microclimate questions you might have.

For more information about what's new in the latest chart, see [Release notes](https://github.com/IBM/charts/blob/master/stable/ibm-microclimate/RELEASENOTES.md).

## Chart details
Installing the chart will:

- Create the specified target namespace for deployments created by using Microclimate's pipelines
- Deploy Microclimate
- Deploy Jenkins, used by Microclimate's pipelines
- Create services for Microclimate and Jenkins
- Create Ingress points for Microclimate
- Create an optional Jenkins Ingress
- Create Persistent Volume Claims if they aren't provided, see [configuration](#configuration) for more details.
- Create service accounts, roles, and bindings if service account names are specified (advised for installations into a non-default namespace)

## Prerequisites
- An Ubuntu 16.04 operating system.
- IBM Cloud Private version 3.1. Older versions of IBM Cloud Private are supported by chart versions v1.5.0 and earlier only. Version support information can be found in the release notes of each chart release.
- Ensure [socat](http://www.dest-unreach.org/socat/doc/README) is available on all worker nodes in your cluster. Microclimate uses Helm internally and both the Helm Tiller and client require socat for port forwarding.
- Download the IBM Cloud Private CLI, cloudctl, from your cluster at the `https://<your-cluster-ip>:8443/console/tools/cli` URL.

## Resources Required

The Microclimate containers have the following resource requests and limits:

| Container                  | Memory Request        | Memory Limit          | CPU Request           | CPU Limit             |
| -----------------------    | ------------------    | ------------------    | ------------------    | ------------------    |
| theia                      | 350Mi                 | 1Gi                   | 30m                   | 500m                  |
| file-watcher               | 128Mi                 | 2Gi                   | 100m                  | 300m                  |
| portal                     | 128Mi                 | 2Gi                   | 100m                  | 500m                  |
| beacon                     | 128Mi                 | 2Gi                   | 100m                  | 500m                  |
| loadrunner                 | 128Mi                 | 2Gi                   | 100m                  | 1000m                 |
| devops                     | 128Mi                 | 2Gi                   | 100m                  | 1000m                 |
| jenkins - Master           | 1500Mi                | -                     | 200m                  | -                     |
| jenkins - Agent            | 600Mi                 | -                     | 200m                  | -                     |

See [configuration](#configuration) for details on how to configure these values.

## Installing the Chart

**IMPORTANT**

We strongly recommend that Microclimate is installed into a non-default namespace. You should make the decision where to install Microclimate first as some of the steps provided below might not be required.

For Microclimate to function correctly, you must:

- Prepare for a non-default namespace installation (optional)
- Create a namespace for the Microclimate pipeline
- Check that the cluster's image pull policy permits additional repositories
- Create the Microclimate registry secret
- Create the Microclimate pipeline secret in the microclimate-pipeline-deployments namespace
- Create a secret so Microclimate can securely use Helm
- Determine Microclimate and Jenkins hostname values
- Ensure Microclimate is configured correctly to use persistent storage

These steps are detailed below and should be completed in order.

#### Prepare for a non-default namespace installation (optional)

`kubectl create namespace <target namespace for Microclimate>`

Set your kubectl context so that any subsequent kubectl commands you do are for the target namespace. This ensures that any resources you create, such as secrets, exist in the correct namespace.  

`kubectl config set-context $(kubectl config current-context) --namespace=<target namespace for Microclimate>`

Follow the remaining steps outlined here, the important part is the use of three additional properties when installing the chart: the names of the two service accounts that are created, and the namespace to install Microclimate into.

When installing the chart, you must set the `global.rbac.serviceAccountName` and `jenkins.rbac.serviceAccountName` values to two different service account names, for example `micro-sa` and `pipeline-sa`. Microclimate will create these two service accounts as well as the associated ClusterRoles and ClusterRoleBindings for the service accounts to use. 

#### Create a namespace for the Microclimate pipeline

The Microclimate pipeline needs a namespace to deploy applications into. Create the namespace with the following:

`kubectl create namespace microclimate-pipeline-deployments`

This is the default target namespace that the Microcliamte pipeline expects to deploy into. If you want to call the namespace a different name, you must set the `jenkins.Pipeline.TargetNamespace` value to match the name of your namespace when installing the chart.


#### Check that the cluster's image pull policy permits additional repositories

Microclimate pipelines use images from repositories other than `docker.io/ibmcom`. To use Microclimate pipelines you must ensure you have a cluster image policy that permits the following repositories so that these images can be pulled and used.

```
  - name: docker.io/maven:*
  - name: docker.io/lachlanevenson/k8s-helm:*
  - name: docker.io/jenkins/*
```

Modify your cluster image policy with `kubectl edit clusterimagepolicy <policy name>`.

Add the repositories, save your changes and they are applied. You need to add any other additional repositories here if you wish to pull images from any other locations, such as your own third party Docker registry.


#### Create the Microclimate registry secret

This secret is used by both Microclimate and Microclimate's pipelines. It allows images to be pushed and pulled from the private registry on your Kubernetes cluster.

Use the following code to create a Docker registry secret: 

```
kubectl create secret docker-registry microclimate-registry-secret \
  --docker-server=mycluster.icp:8500 \
  --docker-username=<account-username> \
  --docker-password=account-password> \
  --docker-email=<account-email>
```

Verify that the secret was created successfully and exists in the target namespace for Microclimate before you continue. This secret does not need to be patched to a service account as the Microclimate installation will manage this step.

#### Create the Microclimate pipeline secret in the microclimate-pipeline-deployments namespace

Microclimate needs a second secret to allow the pipeline to deploy applications into the `microclimate-pipeline-deployments` namespace created previously. You can create this with the following:

```
kubectl create secret docker-registry microclimate-pipeline-secret \
  --docker-server=mycluster.icp:8500 \
  --docker-username=admin \
  --docker-password=admin \
  --docker-email=null \
  --namespace=microclimate-pipeline-deployments
```


The key difference here is the usage of `--namespace microclimate-pipeline-deployments`: this is for the service account that sits in this particular namespace. Pods in this namespace will pull images from the IBM Cloud Private image registry. The secret name here is arbitrary; so long as the service account is patched to use it.

You will now need to patch the default service account in this namesapce to use the secret.

First, check if the default service account has `imagePullSecrets` associated with it already:
```
kubectl describe serviceaccount default --namespace microclimate-pipeline-deployments
```
If it does not contain any other secrets, patch the service account by using the following command:
```
kubectl patch serviceaccount default --namespace microclimate-pipeline-deployments -p '{"imagePullSecrets": [{"name": "microclimate-pipeline-secret"}]}'
```

If it does contain other secrets, you need to include these in the patch command to ensure they don't get overwritten. Inlcude these secrets in the command like so:
```
kubectl patch serviceaccount default --namespace microclimate-pipeline-deployments -p '{"imagePullSecrets": [{"name": "microclimate-pipeline-secret"}, {"name": "secret-1"}, ...., {"name": "secret-n"} ]}'
```

#### Create a secret so Microclimate can securely use Helm

Microclimate pipelines deploy applications by using the Tiller at `kube-system`. Establish secure communication with this Tiller and configure it by creating a Kubernetes secret that contains the required certificate files.

Complete the following steps to create the Kubernetes secret:
1. Set the `$HELM_HOME` environment variable to a `.helm` folder on your system. The default value is usually `~/.helm`.
2. Navigate to the IBM Cloud Private dashboard. From the menu, click **command line tools**.
3. Choose a platform and run the `curl` command to download the application.
4. Choose the file with the name that matches your platform.
5. Log in to your cluster with the `cloudctl login -a https://<your-cluster-ip>:8443 --skip-ssl-validation` command. This command downloads the `cert.pem`, `ca.pem`, and `key.pem` files in the `$HELM_HOME` directory.
6. To create the secret with the certificate files, enter the following command:
```
kubectl create secret generic microclimate-helm-secret --from-file=cert.pem=$HELM_HOME/cert.pem --from-file=ca.pem=$HELM_HOME/ca.pem --from-file=key.pem=$HELM_HOME/key.pem
```

The name of the secret that you have created is printed by the Microclimate pipeline when you run a Jenkins job against your project. With this secret present, your deployed applications appear as a Helm release alongside any others that were deployed from `kube-system`.

**Note:** You need to ensure that the certificate and the secret remain valid.

#### Determine Microclimate and Jenkins hostname values

Access to Microclimate and Jenkins is provided via two Kubernetes Ingresses which are created by using the `hostName` and `jenkins.Master.Hostname` parameters respectively. Each of these parameters should consist of a fully-qualified domain name that resolves to the IP address of your cluster's proxy node, with a unique sub-domain that is used to route to the Microclimate and Jenkins user interfaces. 

For example, if `example.com` resolved to the proxy node, then `microclimate.example.com` and `jenkins.example.com` could be used. 

When a domain name is not available, the service `nip.io` can be used to provide a resolution based on an IP address. For example, `microclimate.<IP>.nip.io` and `jenkins.<IP>.nip.io` where `<IP>` would be replaced with the IP address of your cluster's proxy node.

The IP address of your cluster's proxy node can be found by using the following command:

`kubectl get nodes -l proxy=true -o yaml | grep -B 1 ExternalIP`

If no result is provided from this command and you have a cluster where the master and proxy node run on the same worker, you should use the IP address that you use to access the IBM Cloud Private dashboard.

NOTE: Kubernetes allows multiple Ingresses to be created with the same hostname and one of the Ingresses only is accessible via that hostname. When you install multiple instances of Microclimate, different hostname values must be used for each instance to ensure that each is accessible.

You need these two values when you install the chart.

#### Ensure Microclimate is configured correctly to use persistent storage

When installing the chart, you must ensure sufficient persistent storage is provided to the Microclimate installation. see the [configuration](#configuration) section for more details.

## Installing from the command line

When the above pre-requisities are satisfied and you are confident each resource has been created in the target namespace, you can proceed with the installation process.

Before installing the chart, you must add the IBM charts repo to your Helm repositories:

`helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/`

You can then install the chart using the [hostname](#determine-microclimate-and-jenkins-hostname-values) and [service account name](#determine-microclimate-and-jenkins-hostname-values):  

`helm install --name microclimate --namespace <target namespace> --set global.rbac.serviceAccountName=micro-sa,jenkins.rbac.serviceAccountName=pipeline-sa,hostName=microclimate.<icp-proxy>.nip.io,jenkins.Master.HostName=jenkins.<icp-proxy>.nip.io ibm-charts/ibm-microclimate --tls`.

This command deploys Microclimate on the Kubernetes cluster in the default configuration.

The [configuration](#configuration) section lists the additional parameters that can be configured during installation.

## Verifying the Chart
You can verify the chart by accessing the Microclimate Portal, use your IBM Cloud Private credentials to log in.

When the Helm install has completed successfully, the Microclimate Portal can be accessed via the Microclimate ingress hostname. This can be found by passing the name of your Microclimate release into the following command:

`kubectl get ingress -l release=<release_name>`

If you are using Helm to install Microclimate, you can access the Microclimate Portal by using the URL printed at the end of the installation.

Use the following command to view all resources created by this chart, replacing `x.y.z` with the version number of the installed chart, for example `1.0.0`:

`kubectl get all -l chart=ibm-microclimate-x.y.z`

## Uninstalling the Chart

To uninstall or delete the `microclimate` release:

```bash
helm delete --purge microclimate
```

The command removes all the Kubernetes resources that are associated with the chart and deletes the release.

## Configuration

#### Persistent Storage

Microclimate requires two persistent volumes to function correctly: one for storing project workspaces and one for the Jenkins pipeline. The persistent volume used for project workspaces is shared by all users of the Microclimate instance and must be defined with an access mode of ReadWriteMany (RWX). The volume for Jenkins should be ReadWriteOnce (RWO). The default size of the persistent volume claim for the project workspaces is 8Gi. Configure this size with the `persistence.size` option to scale with the number of users and the number and size of the projects they are expected to create or import into Microclimate. As a rough guide, a generated Java project is approximately 128Mi, a generated Swift project is approximately 100Mi, and a generated Node.js project is approximately 1Mi. Therefore, the default size of 8Gi allows space for approximately 64 Java projects.

The Jenkins pipeline requires an 8GB persistent volume, which currently isn't configurable.

Both Microclimate and Jenkins can use existing Persistent Volume Claims, which should follow these guidelines for storage size. These names can be passed into the `persistence.existingClaimName` and `jenkins.Persistence.ExistingClaim` chart values.

If you want to use Dynamic Provisioning, or you want Microclimate to create its own `PersistentVolumeClaim`, these values must be left blank.

Dynamic Provisioning is enabled by default, `persistence.useDynamicProvisioning`, and uses the default storage class set up in your cluster. A different storage class can be used by editing the `persistence.storageClassName` option for Microclimate and the `jenkins.Persistence.StorageClass` option for Jenkins in the configuration.

Microclimate attempts to create its own persistent volume claim by using the `persistence.storageClassName` and `persistence.size` options if Dynamic Provisioning isn't enabled and if PVCs aren't provided by name.

**Warning:** Microclimate stores any projects that are created by users in whichever Persistent Volume it gets mounted to. Uninstalling Microclimate might cause data to be lost if the `PersistentVolume` and `PersistentVolumeClaim` aren't configured correctly. To avoid losing data, we recommend that you have the correct Reclaim Policy set in a provided `PersistentVolumeClaim` or in the provided `StorageClass` if you are using Dynamic Provisioning. The same practice should be applied to the Jenkins persistent volume.

**Warning:** Avoid using hostPath persistent volumes. A hostPath volume sets up a file system on a single node of a cluster. The portal, file-watcher, and editor pods need access to the same file system, and these pods can start on different nodes. If the pods start on different nodes, pods that are started on one node are unable to access the hostPath volume that is created on a different node.

For more information about creating Persistent Storage and enabling Dynamic Provisioning, see [Cluster Storage](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/manage_cluster/cluster_storage.html),
[Working with storage](https://www.ibm.com/developerworks/community/blogs/fe25b4ef-ea6a-4d86-a629-6f87ccf4649e/entry/Working_with_storage), and 
[Dynamic Provisioning](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/installing/storage_class_all.html).


#### Resource requests and limits

Each Microclimate container has a set of default requests and limits for CPU and Memory usage. These are set at recommended values but should be configured to suit the needs of your cluster. 

#### Configuring Microclimate
Microclimate provides a number of configuration options to customise its installation. Below are a list of configurable parameters.

If you are installing by using the Helm CLI then values can be set by using one or more `--set` arguments when doing `helm install`. For example, to configure persistent storage options, you can use the following:

`helm install --name microclimate --set persistence.useDynamicProvisioning=false,persistence.size=16Gi,<any additional options> ibm-charts/ibm-microclimate`


#### Additional Pull Secrets

If you wish to use more registry secrets for Microclimate to use, `global.additionalImagePullSecrets` can be set when installing installs the chart to use a YAML array of ImagePullSecrets. For example, you can include the following if installing using the catalog:

```
- artifactory
- myregistry
- dockerhub
```

From the command line instead, the following option can be specified:
```
--set global.additionalImagePullSecrets[0]=<secret>,global.additionalImagePullSecrets[1]=<secret2>
```

#### Configuration parameters

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `hostName`                 | URL to the Ingress point for Microclimate       | **MUST BE SET BY USER**     |
| `theia.repository`         | Image repository for theia                      | `ibmcom/microclimate-theia` |
| `theia.tag`                | Tag for theia image                             | `latest` |
| `filewatcher.repository`   | Image repository for file-watcher               | `ibmcom/microclimate-file-watcher` |
| `filewatcher.tag`          | Tag for file-watcher image                      | `latest` |
| `portal.repository`        | Image repository for portal                     | `ibmcom/microclimate-portal` |
| `portal.tag`               | Tag for portal image                            | `latest`|
| `beacon.repository`        | Image repository for beacon                     | `ibmcom/microclimate-beacon` |
| `beacon.tag`               | Tag for beacon image                            | `latest`|
| `imagePullPolicy`          | Image pull policy used for all images           | `Always`    |
| `persistence.enabled`      | Use persistent storage for Microclimate workspace | `true` |
| `persistence.existingClaimName`        | Name of an existing PVC to be used with Microclimate - should be left blank if you use Dynamic Provisioning or if you want Microclimate to make it's own PVC     | `""` |
| `persistence.useDynamicProvisioning`      | Use dynamic provisioning | `true` |
| `persistence.size`         | Storage size allowed for Microclimate workspace   | `8Gi` |
| `persistence.storageClassName`        | Storage class name for Microclimate workspace     | `""` |
| `jenkins.Master.HostName`      | Host name used for Ingress for the Jenkins | `""` |
| `jenkins.Persistence.StorageClass`    | Storage class name for Microclimate workspace | `""` |
| `jenkins.Persistence.ExistingClaim`    | Name of an existing PVC to be used for Jenkins - should be left blank if you use Dynamic Provisioning or if you want Microclimate to make it's own PVC | `""` |
| `jenkins.rbac.serviceAccountName`    | Name of a existing service account to create for Jenkins and the DevOps component to use | `"default"` |
| `global.helm.tlsSecretName`    | Name of the Kubernetes secret to be used by the Microclimate pipeline: must be provided in order to use Tiller securely | `""` |
| `global.rbac.serviceAccountName`    | Name of a service account to create for Microclimate's Portal and File Watcher components to use | `"default"` |


Jenkins also has a number of other configurable options not listed here. These can be viewed in the chart's `values.yaml` file or in your cluster's dashboard page for this chart.

Resource requests and limits can also be configured for each of the `theia`, `filewatcher`, and `portal` containers by using the options below, for example, `theia.resources.request.cpu`:

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `<containerName>.resources.requests.cpu`          | CPU Request size for a given container      | View the [Resources Required](#ResourcesRequired) section for default values  |
| `<containerName>.resources.limits.cpu`            | CPU Limit size for a given container        | View the [Resources Required](#ResourcesRequired) section for default values  |
| `<containerName>.resources.requests.memory`       | Memory Request size for a given container   | View the [Resources Required](#ResourcesRequired) section for default values  |
| `<containerName>.resources.limits.memory`         | Memory Limit size for a given container     | View the [Resources Required](#ResourcesRequired) section for default values  |

#### Replacing TLS certificates

The default installation of Microclimate on an IBM Cloud Private cluster configures a secure TLS endpoint through Ingress for both the Microclimate and Jenkins user interfaces.  If customization of the certificates used to secure these TLS endpoints is required, follow this procedure.

These commands can be run from any host that has a kubectl client with access to the IBM Cloud Private cluster that is the target of the changes.

1. Generate or acquire a new certificate for Microclimate

  Substituting your own TLS certificate for encrypting Microclimate communications requires a certificate and key file.  If you are not using an existing certificate, a new certificate needs to be generated. The following command creates a new certificate for this purpose:

  `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=microclimate.myhost.com"`

  Note: Replace `microclimate.myhost.com` with your unique Microclimate ingress endpoint.

2. Replace the Microclimate TLS certificate

  The next step is to take the certificate acquired in step 1 and replace the existing certificate being used for Microclimate TLS communications.  The default installation of Microclimate creates a Kubernetes secret named `microclimate-mc-tls-secret` which contains this certificate.  Use the following command to replace that secret with your new certificate:

  `kubectl create secret tls microclimate-mc-tls-secret  --key tls.key --cert tls.crt --dry-run  -o yaml | kubectl replace --force -f -`

3. Generate or acquire a new certificate for Microclimate Jenkins

  Substituting your own TLS certificate for encrypting Microclimate Jenkins communications requires a certificate and key file.  If you are not using an existing certificate, a new certificate needs to be generated.  The following command creates a suitable new certificate for this purpose:

  `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=jenkins.myhost.com"`

  Note: Replace `jenkins.myhost.com` with your unique Microclimate Jenkins ingress endpoint.

4. Replace the Microclimate Jenkins TLS certificate

  The last step is to take the certificate acquired in step 3 and replace the existing certificate being used for Microclimate Jenkins TLS communications.  The default installation of Microclimate creates a Kubernetes secret named `microclimate-tls-secret` which contains this certificate.  Use the following command to replace that secret with your new certificate:

  `kubectl create secret tls microclimate-tls-secret  --key tls.key --cert tls.crt --dry-run  -o yaml | kubectl replace --force -f -`


## Limitations

- This chart should only use the default image tags provided with the chart. Different image versions might not be compatible with different versions of this chart.

- An IBM Cloud Private Administrator role is required to install into a non-default namespace. This is because two service accounts will be created if you specify the global.rbac.serviceAccountName and jenkins.rbac.serviceAccountName properties when installing the chart, which are used to allow Microclimate pods to function correctly in a non-default namespace.

See the [product documentation](https://microclimate-dev2ops.github.io/knownissues) for other known issues and limitations.

## Documentation

The Microclimate [landing page](https://microclimate-dev2ops.github.io) provides additional learning resources and documentation.
