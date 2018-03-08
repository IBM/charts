# IBM Db2 Developer-C Helm Chart
  
[Db2 Developer-C Edition](http://www-03.ibm.com/software/products/sv/db2-developer-edition) enables you to develop, test, evaluate and demonstrate database and warehousing applications in a non-production environment.

## Introduction

This chart consist of IBM Db2 Developer-C Edition and is a persistent relational database intended to be deployed in IBM Cloud Private environments. For full step-by-step documentation for installing this chart click [Deploy Db2 Into IBM Cloud Private](https://developer.ibm.com/recipes/tutorials/db2-integration-into-ibm-cloud-private/) for the developerWorks recipe.

### New in this release
1. Migration to Docker Store for Db2 image
2. Multi-platform manifest support
3. Base OS with latest patches
4. Update to latest iFix002 of Db2 11.1.2.2

## Prerequisites

#### Using Docker-registry Secret(Prereq #1)
Docker-registry secret can be specified during install under Docker-registry secret. This is required for the chart to be able to pull the docker image from Docker Store.
Steps to obtaining the docker-registry secret
1. User must be subscribed to https://store.docker.com/images/db2-developer-c-edition so they can generate a key to access the image.
2. After doing so visit https://cloud.docker.com/swarm .. in upper right click on your userid drop down and select account settings. Scroll down to Add API key. After receiving your api key run `kubectl create secret docker-registry <secretname>  --docker-username=<userid> --docker-password=<API key> --docker-email=<email>` to generate your secret name. 

You now have two options of using your docker-registry secret.
1) You can enter the name of the secret in "Secret Name" box as described earlier. This will be specific to only your chart's deployment

   OR

2) You can patch your service account in the namespaces you desire to deploy your Db2 chart. The default service account name is default and the default namespace is default.
You can confirm by running
```bash
kubectl get serviceaccount; kubectl get namespace
```
If you want to switch namespaces prior to deploying your chart you may simply run `kubectl config set-context mycluster.icp-context --user=admin --namespace=<namespace>`

The command to patch the service account "default" for namespace "default" is:

  ```bash
  kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "secretname"}]}' --namespace=default
  ``` 
 After doing option 2, you may deploy the Db2 chart in namespace default without having to provide the "Secret Name" box. Namespace default is now patched so any succeeding Db2 deployments refering to the Docker Store image will use your secret to obtain the image.
 
#### Enabling Persistence(Prereq #2) 
A persistence method needs to be selected to ensure our data storage is not loss in the event we lose the node running the Db2 application. PersistentVolume needs to be pre-created prior to installing the chart if `Enable persistence for this deployment` is selected and `Use dynamic provisioning for persistent volume` is not (default values, see [persistence](#persistence) section). It can be created by using the IBM Cloud Private UI or via a yaml file as the following example:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: <PATH>
```

## Installing the Chart

You may install the chart by clicking `configure` on the bottom if using the IBM Cloud Private UI. 

or

To install via command line with the release name `my-release` if you do not have the helm repository:

```bash
# This will show the repositories
helm repo list

# Add the helm repository
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/

#This will show all the charts related to the repository
helm search <repo>

#Finally install the respective chart
$ helm install --name my-release local/ibm-db2oltp-dev:1.1.3
```

The command deploys ibm-db2oltp-dev on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Configuration

If installing via command line, you may change the default of each parameter using the `--set key=value[,key=value]`.
I.e `helm install --name my-release --set global.imagePullSecret.name=<secretname> local/ibm-db2oltp-dev:1.1.3`

> **Tip**: You can configure the default [values.yaml](values.yaml)


The following tables lists the configurable parameters of the ibm-db2oltp-dev chart and their default values when installing via IBM Cloud Private UI from clicking `configure`. They are a wrapper for the real values found in values.yaml

| Parameter                     | Description                                        | Default                                                                  |
| ---------------------------   | ---------------------------------------------      | -------------------------------------------------------------------------|
| `Worker node architecture`    | `Architecture chosen to deploy` | `nil/amd64/ppc64le/s390x`       |
| `imageRepository`             | `Db2 Developer-C Edition` image repository         | `na.cumulusrepo.com/hcicp_dev/`                                          |     
| `imageTag`                    | `Db2 Developer-C Edition` image tag                | `11.1.2.2b` - architecture will follow worker node architecture            |
| `imagePullPolicy`             | Image pull policy                                  | `IfNotPresent`                                                           |
| `Db2 instance name`            | `Db2` instance name                                | `nil`                                                                    | 
| `Password for Db2 instance`            | `Db2` instance password                            | `nil`                                                                    |  
| `Database Name`        | Create database with name provided                 | `nil`                                                                    |  
| `Enable Oracle Compatibility` | Enable compatibility with Oracle                   | `false`                                                                  |       
| `Enable persistence for this deployment`         | Use a PVC to persist data                          | `true`                                                                   |
| `Use dynamic provisioning for persistent volume`      | Specify a storageclass or leave empty  | `false`                                                                  |
| `Existing volume claim`    | Provide an existing PersistentVolumeClaim          | `nil`                                                                    |
| `Existing storage class name`     | Storage class of backing PVC                       | `nil`                                                                    |
| `Secret Name`             | Docker-registry secret name                             | `nil`                                                                   |
| `Size of the volume claim`             | Size of data volume                                | `20Gi`                                                                   |
| `Resource configuration`                   | CPU/Memory resource requests/limits                | Memory request/limit: `2Gi`/`16Gi`, CPU request/limit: `2000m`/`4000m`   |
| `Service Name`                | The name of the Service                                           | `ibm-db2oltp-dev` 
| `port`                | TCP port                                           | `50000`                                                                  |
| `tsport`              | Text search port                                   | `55000`                                                                  |
| `Service Type`                | k8s service type exposing ports, e.g.`ClusterIP`   | `NodePort`                                                               |

## Architecture

- Three major architectures are now available for Db2 Developer-C Edition on IBM Cloud Private worker nodes:
  - AMD64 / x86_64
  - s390x
  - ppc64le

An ‘arch’ field in values.yaml is required to specify supported architectures to be used during scheduling and includes ability to give preference to certain architecture(s) over another.

Specify architecture (amd64, ppc64le, s390x) and weight to be  used for scheduling as follows : 
   0 - Do not use
   1 - Least preferred
   2 - No preference
   3 - Most preferred

## Persistence

- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - Enable persistence for this deployment: selected (default)
    - Use dynamic provisioning for persistent volume: selected (non-default)
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - Enable persistence for this deployment: selected (default)
    - Use dynamic provisioning for persistent volume: non-selected (default)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.    


- No persistent storage. This mode with use emptyPath for any volumes referenced in the deployment
  - enable this mode by setting the global values to:
    - Enable persistence for this deployment: non-selected (non-default)
    - Use dynamic provisioning for persistent volume: non-selected (non-default)


### Existing PersistentVolumeClaims

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart
```bash
$ helm install --name my-release --set persistence.existingClaim=PVC_NAME
```

The volume defaults to mount at a subdirectory of the volume instead of the volume root to avoid the volume's hidden directories from interfering with database creation.

## Verifying the Chart

In the developerWorks recipe, visit step 4 `Confirming Db2 Application is Ready`
[Deploy Db2 Into IBM Cloud Private](https://developer.ibm.com/recipes/tutorials/db2-integration-into-ibm-cloud-private/)

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions additional commands required for clean-up.  

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
``` 




