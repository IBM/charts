# Microclimate

## Introduction

Microclimate is an end to end development environment that lets you rapidly create, edit, and deploy applications.

This chart can be used to install Microclimate into an IBM Cloud Private or Kubernetes environment.

Visit the [Microclimate landing page](https://microclimate-dev2ops.github.io/) to learn more or visit our [Slack channel](https://ibm-cloud-tech.slack.com/messages/C8RS7HBHV/) to ask any Microclimate questions you may have.

## Prerequisites

- An IBM Cloud Private or other Kubernetes cluster
- Ensure [socat](https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.1/cam_installing_cam.html) is available on all IBM Cloud Private/Kubernetes worker nodes

## Installing the Chart

**IMPORTANT** - For Microclimate to function correctly, you must first create a Kubernetes secret containing the credentials to be used to access the Docker registry and patch the service account to use this secret.

#### Create secret

Create a Docker registry secret in the default namespace:
```
kubectl create secret docker-registry microclimate-icp-secret \
  --docker-server=mycluster.icp:8500 \
  --docker-username=<account-name> \
  --docker-password=<account-password> \
  --docker-email=<account-email>
```

For example, to create the secret using the default admin account:
```
kubectl create secret docker-registry microclimate-icp-secret \
  --docker-server=mycluster.icp:8500 \
  --docker-username=admin \
  --docker-password=admin \
  --docker-email=null
```

#### Patch service account

After creating the secret, patch the service account using the following command, specifying the name of the service account (called "default" in IBM Cloud Private).

```
kubectl patch serviceaccount <svc-account-name> -p '{"imagePullSecrets": [{"name": "microclimate-icp-secret"}]}'
```

Note: If there are other secrets that need to be associated to this service account, they should be included in the imagePullSecrets array in the command above e.g. `... '{"imagePullSecrets": [{"name": "microclimate-icp-secret"}, {"name": "secret-1"}, ...., {"name": "secret-n"} ]}'`

#### Installing from the command line

**IMPORTANT** - Microclimate must be installed in to the default namespace. Deployment into other namespaces is currently not supported.

To install the chart from the command line with the release name `microclimate`:
```
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
helm install --name microclimate --set jenkins.Master.HostName=<JENKINS_INGRESS> ibm-charts/ibm-microclimate
```

See the Jenkins section below for how to determine a suitable value for `<JENKINS_INGRESS>`.

This command deploys Microclimate on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Verifying the Chart
Once the Helm install has completed successfully, the Microclimate Portal can be accessed by opening the `portal-http` endpoint which can be found in the Microclimate service or deployment. The deployment and service can be found by finding the Microclimate release in Helm Releases via your IBM Cloud Private/Kubernetes interface.

If you are using Helm to install Microclimate, you can enter the commands provided at the end of the Helm installation to retrieve the portal URL and open the URL in your web browser.

## Uninstalling the Chart

To uninstall/delete the `microclimate` release:

```bash
helm delete --purge microclimate
```

The command removes all the Kubernetes resources associated with the chart and deletes the release.

## Configuration

#### Persistent Storage

Microclimate requires two persistent volumes to function correctly: one for storing project workspaces and one for the Jenkins pipeline. Persistent storage is enabled by default with a storage size of 2GB for the Microclimate workspace. This size should be configured by using the `persistence.size` option to scale with the number and size of projects expected to be created in Microclimate. As a rough guide, a generated Java project is approximately 128MB, a generated Swift project is approximately 100MB and a generated Node.js project is below 1 MB.

Jenkins requires an 8GB persistent volume which currently isn't configurable.

Both Microclimate and Jenkins can use existing Persistent Volume Claims (which should follow the guidelines above for storage size). These names can be passed into the following chart values: `persistence.existingClaimName` and `jenkins.Persistence.ExistingClaim`. NOTE: If you want to use Dynamic Provisioning or you want Microclimate to create its own PersistentVolumeClaim, these values MUST be left blank.

Dynamic Provisioning is enabled by default (`persistence.useDynamicProvisioning`) and uses the default storage class set up in the given IBM Cloud Private instance. A different storage class can be used by editing the `persistence.storageClassName` option in the configuration (see below).

Microclimate attempts to create its own persistent volume claim by using the `persistence.storageClassName` and `persistence.size` options if Dynamic Provisioning isn't enabled and if PVCs aren't provided by name.

**Warning:** Microclimate stores any projects created by users in whichever Persistent Volume it gets mounted to. Uninstalling Microclimate may cause data to be lost if the PersistentVolume and PersistentVolumeClaim aren't configured correctly. To avoid losing data, we recommend having the correct Reclaim Policy set in a provided PersistentVolumeClaim or in the provided StorageClass if using Dynamic Provisioning. The same practice should be applied to the Jenkins persistent volume.

Visit the following pages for more information about creating Persistent Storage and enabling Dynamic Provisioning:  
[Cluster Storage](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/manage_cluster/cluster_storage.html)
[Working with storage](https://www.ibm.com/developerworks/community/blogs/fe25b4ef-ea6a-4d86-a629-6f87ccf4649e/entry/Working_with_storage)
[Dynamic Provisioning](https://www.ibm.com/support/knowledgecenter/SSBS6K_2.1.0/installing/storage_class_all.html)


#### Resource requests and limits

Each Microclimate container has a set of default requests and limits for CPU and Memory usage. These are set at recommended values but should be configured to suit the needs of your IBM Cloud Private instance. See below for how to configure these values.

#### Configuring Microclimate
Microclimate provides a number of configuration options to customise its installation. Below are a list of configurable parameters.

If you are installing in IBM Cloud Private, then these can be configured through the Configuration page when installing Microclimate from the catalog.

If you are installing using the Helm CLI then values can be set using one or more `--set` arguments when doing `helm install`. For example, to configure persistent storage options, you can use the following:

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
| `persistence.existingClaimName`        | Name of an existing PVC to be used with Microclimate - Should be left blank if using Dynamic Provisioning or if you want Microclimate to make it's own PVC     | `""` |
| `persistence.useDynamicProvisioning`      | Use dynamic provisioning | `true` |
| `persistence.size`         | Storage size allowed for microclimate workspace   | `2Gi` |
| `persistence.storageClassName`        | Storage class name for microclimate workspace     | `""` |
| `jenkins.Master.HostName`      | Host name used for Ingress for the Jenkins component of Microclimate | `jenkins.192.168.99.100.nip.io` |
| `jenkins.Persistence.ExistingClaim`    | Name of an existing PVC to be used for Jenkins - Should be left blank if using Dynamic Provisioning or if you want Microclimate to make it's own PVC | `""` |
| `gitlab.url`               | Optionally, the URL of a Gitlab instance | `""`
| `gitlab.apiToken`          | Optionally, an API token for the Gitlab instance specified in `gitlab.url` | `""` |


Jenkins also has a number of other configurable options not listed here. These can be viewed in the following 'Configure' page if you are viewing this in the IBM Cloud Private catalog or through the `values,yaml` file otherwise.

Resource limits can also be configured for each of the `theia`, `filewatcher` and `portal` containers using the options below (e.g. `theia.resources.request.cpu`):

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `<containerName>.resources.requests.cpu`         | CPU Request size for a given container  | View the ICP configuration page for Microclimate or the values.yaml file to view default values for each container|
| `<containerName>.resources.limits.cpu`         | CPU Limit size for a given container  | View the ICP configuration page for Microclimate or the values.yaml file to view default values for each container|
| `<containerName>.resources.requests.memory`         | Memory Request size for a given container  | View the ICP configuration page for Microclimate or the values.yaml file to view default values for each container|
| `<containerName>.resources.limits.memory`         | Memory Limit size for a given container  | View the ICP configuration page for Microclimate or the values.yaml file to view default values for each container|


#### Jenkins

Access to Jenkins is provided via Kubernetes Ingress. The parameter `jenkins.Master.HostName` should consist of a fully-qualified domain name that resolves to the IP address of the IBM Cloud Private proxy node, with a unique sub-domain that is used to route to the Jenkins UI. For example, if `example.com` resolved to the proxy node, then `jenkins.example.com` could be used. Where a domain name is not available, the service `nip.io` can be used to provide resolution based on IP address. For example, `jenkins.<IP>.nip.io` where `<IP>` would be replaced with the IP address of your IBM Cloud Private proxy node.

Note that the Jenkins pod takes a while to start as it is installing plugins.

#### GitLab

The Microclimate chart may optionally be configured with details of a GitLab instance. Repositories contained in this instance will automatically have webhooks created when a pipeline is created on a project associated with the repository.

## Limitations

Microclimate must be deployed in to the ```default``` namespace. Microclimate deploys its own Helm Tiller in to that namespace. As a consequence, Helm releases deployed by Microclimate do not appear in the IBM Cloud Private dashboard. The Microclimate Helm Tiller and portal do not currently have access control and consequently Microclimate should not be deployed in to a production environment.

See the [product documentation](https://microclimate-dev2ops.github.io/knownissues) for other known issues and limitations.

## Documentation

The Microclimate [landing page](https://microclimate-dev2ops.github.io) provides additional learning resources and documentation.