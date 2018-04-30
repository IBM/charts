# Microclimate

## Introduction

Microclimate is an end to end development environment that lets you rapidly create, edit, and deploy applications.

This chart can be used to install Microclimate into a Kubernetes environment.

Visit the [Microclimate landing page](https://microclimate-dev2ops.github.io/) to learn more, or visit our [Slack channel](https://ibm-cloud-tech.slack.com/messages/C8RS7HBHV/) to ask any Microclimate questions you might have.

## Chart details
This chart will do the following:
- Deploy Microclimate
- Deploy Jenkins, used by the Microclimate pipeline
- Create services for Microclimate and Jenkins
- Create an optional Jenkins ingress
- Create Persistent Volume Claims if they aren't provided, see [configuration](#configuration) for more details

## Prerequisites

- Ensure [socat](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.1/cam_installing_cam.html) is available on all worker nodes in your cluster


## Resources Required

The Microclimate containers have the following resource requests and limits:

| Container                  | Memory Request        | Memory Limit          | CPU Request           | CPU Limit             |
| -----------------------    | ------------------    | ------------------    | ------------------    | ------------------    |
| theia                      | 350Mi                 | 1Gi                   | 30m                   | 500m                  |
| file-watcher               | 128Mi                 | 2Gi                   | 100m                  | 300m                  |
| portal                     | 128Mi                 | 2Gi                   | 100m                  | 500m                  |
| devops                     | 128Mi                 | 2Gi                   | 100m                  | 1000m                 |
| jenkins - Master           | 1500Mi                | -                     | 200m                  | -                     |
| jenkins - Agent            | 600Mi                 | -                     | 200m                  | -                     |

See [configuration](#configuration) for details on how to configure these values

## Installing the Chart

**IMPORTANT** - For Microclimate to function correctly, you must first:

1. Create a Docker registry secret for Microclimate.
2. Patch this secret to a service account.
3. Set the Jenkins hostname value.
4. Ensure Microclimate is configured correctly to use persistent storage, see the [configuration](#configuration) section below for more details.

#### Create secret

Create a Docker registry secret in the default namespace:
```
kubectl create secret docker-registry microclimate-registry-secret \
  --docker-server=mycluster.icp:8500 \
  --docker-username=<account-name> \
  --docker-password=<account-password> \
  --docker-email=<account-email>
```

For example, to create the secret for an account named 'admin' with the password 'admin':
```
kubectl create secret docker-registry microclimate-registry-secret \
  --docker-server=mycluster.icp:8500 \
  --docker-username=admin \
  --docker-password=admin \
  --docker-email=null
```

#### Patch service account

After creating the secret, patch the service account by using the following command, specifying the name of the service account. For example, to patch to the service account named `default`:

```
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "microclimate-registry-secret"}]}'
```

Note: If there are other secrets that need to be associated to this service account, they should be included in the `imagePullSecrets` array in the command above, for example, `... '{"imagePullSecrets": [{"name": "microclimate-registry-secret"}, {"name": "secret-1"}, ...., {"name": "secret-n"} ]}'`

#### Set Jenkins hostname

Access to Jenkins is provided via Kubernetes Ingress. The parameter `jenkins.Master.HostName` should consist of a fully-qualified domain name that resolves to the IP address of your cluster's proxy node, with a unique sub-domain that is used to route to the Jenkins UI. For example, if `example.com` resolved to the proxy node, then `jenkins.example.com` could be used. When a domain name is not available, the service `nip.io` can be used to provide a resolution based on an IP address. For example, `jenkins.<IP>.nip.io` when `<IP>` would be replaced with the IP address of your cluster's proxy node.

The IP address of your cluster's proxy node can be found by using the following command:

`kubectl get nodes -l proxy=true`

#### Installing from the command line

**IMPORTANT** - Microclimate must be installed into the default namespace. Deployment into other namespaces is currently not supported.

To install the chart from the command line with the release name `microclimate`:
```
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
helm install --name microclimate --set jenkins.Master.HostName=<JENKINS_INGRESS> ibm-charts/ibm-microclimate
```

See the Jenkins section below for how to determine a suitable value for `<JENKINS_INGRESS>`.

This command deploys Microclimate on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Verifying the Chart
When the Helm install has completed successfully, the Microclimate Portal can be accessed by opening the `portal-http` endpoint which can be found in the Microclimate service or deployment.

If you are using Helm to install Microclimate, you can enter the commands provided at the end of the Helm installation to retrieve the portal URL and open the URL in your web browser.

Use the following command to view all resources created by this chart, replacing `x.y.z` with the version number of the installed chart (e.g. 1.0.0):

`kubectl get all -l chart=ibm-microclimate-x.y.z`

## Uninstalling the Chart

To uninstall or delete the `microclimate` release:

```bash
helm delete --purge microclimate
```

The command removes all the Kubernetes resources that are associated with the chart and deletes the release.

## Configuration

#### Persistent Storage

Microclimate requires two persistent volumes to function correctly: one for storing project workspaces and one for the Jenkins pipeline. Persistent storage is enabled by default with a storage size of 2GB for the Microclimate workspace. This size should be configured by using the `persistence.size` option to scale with the number and size of projects expected to be created in Microclimate. As a rough guide, a generated Java project is approximately 128MB, a generated Swift project is approximately 100MB and a generated Node.js project is below 1 MB.

Jenkins requires an 8GB persistent volume which currently isn't configurable.

Both Microclimate and Jenkins can use existing Persistent Volume Claims, which should follow the guidelines above for storage size. These names can be passed into the following chart values: `persistence.existingClaimName` and `jenkins.Persistence.ExistingClaim`. NOTE: If you want to use Dynamic Provisioning or you want Microclimate to create its own `PersistentVolumeClaim`, these values MUST be left blank.

Dynamic Provisioning is enabled by default (`persistence.useDynamicProvisioning`) and uses the default storage class set up in your cluster. A different storage class can be used by editing the `persistence.storageClassName` option in the configuration, see below.

Microclimate attempts to create its own persistent volume claim by using the `persistence.storageClassName` and `persistence.size` options if Dynamic Provisioning isn't enabled and if PVCs aren't provided by name.

**Warning:** Microclimate stores any projects that are created by users in whichever Persistent Volume it gets mounted to. Uninstalling Microclimate might cause data to be lost if the `PersistentVolume` and `PersistentVolumeClaim` aren't configured correctly. To avoid losing data, we recommend that you have the correct Reclaim Policy set in a provided `PersistentVolumeClaim` or in the provided `StorageClass` if you are using Dynamic Provisioning. The same practice should be applied to the Jenkins persistent volume.

For more information about creating Persistent Storage and enabling Dynamic Provisioning, see   
[Cluster Storage](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/manage_cluster/cluster_storage.html)
[Working with storage](https://www.ibm.com/developerworks/community/blogs/fe25b4ef-ea6a-4d86-a629-6f87ccf4649e/entry/Working_with_storage)
[Dynamic Provisioning](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/installing/storage_class_all.html).


#### Resource requests and limits

Each Microclimate container has a set of default requests and limits for CPU and Memory usage. These are set at recommended values but should be configured to suit the needs of your cluster. See below for how to configure these values.

#### Configuring Microclimate
Microclimate provides a number of configuration options to customise its installation. Below are a list of configurable parameters.

If you are installing by using the Helm CLI then values can be set by using one or more `--set` arguments when doing `helm install`. For example, to configure persistent storage options, you can use the following:

`helm install --name myMicroclimate --set persistence.useDynamicProvisioning=false --set persistence.size=2Gi ibm-charts/ibm-microclimate`

#### Configuration parameters

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `theia.repository`         | Image repository for theia                      | `ibmcom/microclimate-theia` |
| `theia.tag`                | Tag for theia image                             | `latest` |
| `filewatcher.repository`   | Image repository for file-watcher               | `ibmcom/microclimate-file-watcher` |
| `filewatcher.tag`          | Tag for file-watcher image                      | `latest` |
| `portal.repository`        | Image repository for portal                     | `ibmcom/microclimate-portal` |
| `portal.tag`               | Tag for portal image                            | `latest`|
| `imagePullPolicy`          | Image pull policy used for all images           | `Always`    |
| `persistence.enabled`      | Use persistent storage for microclimate workspace | `true` |
| `persistence.existingClaimName`        | Name of an existing PVC to be used with Microclimate - Should be left blank if you use Dynamic Provisioning or if you want Microclimate to make it's own PVC     | `""` |
| `persistence.useDynamicProvisioning`      | Use dynamic provisioning | `true` |
| `persistence.size`         | Storage size allowed for microclimate workspace   | `2Gi` |
| `persistence.storageClassName`        | Storage class name for microclimate workspace     | `""` |
| `jenkins.Master.HostName`      | Host name used for Ingress for the Jenkins component of Microclimate | `""` |
| `jenkins.Persistence.ExistingClaim`    | Name of an existing PVC to be used for Jenkins - Should be left blank if you use Dynamic Provisioning or if you want Microclimate to make it's own PVC | `""` |
| `gitlab.url`               | Optionally, the URL of a Gitlab instance | `""`
| `gitlab.apiToken`          | Optionally, an API token for the Gitlab instance specified in `gitlab.url` | `""` |


Jenkins also has a number of other configurable options not listed here. These can be viewed in the chart's `values,yaml` file or in your cluster's dashboard page for this chart.

Resource requests and limits can also be configured for each of the `theia`, `filewatcher`, and `portal` containers by using the options below, for example, `theia.resources.request.cpu`:

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `<containerName>.resources.requests.cpu`          | CPU Request size for a given container      | View the [Resources Required](#ResourcesRequired) section for default values  |
| `<containerName>.resources.limits.cpu`            | CPU Limit size for a given container        | View the [Resources Required](#ResourcesRequired) section for default values  |
| `<containerName>.resources.requests.memory`       | Memory Request size for a given container   | View the [Resources Required](#ResourcesRequired) section for default values  |
| `<containerName>.resources.limits.memory`         | Memory Limit size for a given container     | View the [Resources Required](#ResourcesRequired) section for default values  |


#### GitLab

The Microclimate chart might optionally be configured with details of a GitLab instance by setting the `gitlab.url` and `github.apiToken` values. Repositories contained in this instance automatically have webhooks created when a pipeline is created on a project associated with the repository.

## Limitations

- Microclimate must be deployed in to the ```default``` namespace. Microclimate deploys its own Helm Tiller into that namespace. As a consequence, Helm releases deployed by Microclimate will not appear in your cluster dashboard. The Microclimate Helm Tiller and portal do not currently have access control and consequently Microclimate should not be deployed into a production environment.

- This chart should only use the default image tags provided with the chart. Different image versions might not be compatible with different versions of this chart

- Note that the Jenkins pod takes a while to start as it installs a number of plugins.

See the [product documentation](https://microclimate-dev2ops.github.io/knownissues) for other known issues and limitations.

## Documentation

The Microclimate [landing page](https://microclimate-dev2ops.github.io) provides additional learning resources and documentation.
