# IBM PowerAI Vision Helm Chart

PowerAI Vision provides a complete ecosystem for labeling datasets, training, and deploying deep learning models for computer vision. IBM PowerAI Vision introduces “Deep Learning on Data Labeling” where a model trained from a smaller dataset is engaged to automatically detect labels on a larger training set. When compared to manual methods of labeling datasets, semi-auto labeling reduces the laborious and expensive effort by 10x.

## Introduction

This chart deploys PowerAI Vision in a Kubernetes environment.  The entire application runs on Power Systems, and can operate on any ppc64le (POWER8 and later) server, VM, or Partition.  At least one node in your Kubernetes cluster must be a Power System (ppc64le) with a supported GPU.

## Chart Details

* Ingress: Enables access to the WEB UI and API via https://<IP>/powerai-vision-<RELEASE>/
* Numerous static deployments and services to enable the PowerAI Vision application.
* Dynamic deployments, services, and ingress' that are created by the application for Training and Inferencing of the models.

## Chart Versioning

IBM PowerAI Vision is versioned using a 4 part V.R.M.F nomenclature (e.g. 1.1.0.1).  This chart is versioned using a 3 part nomenclature that corresponds directly to the R.M.F of the application.  For example, version 1.1.0.1 of PowerAI Vision will use a chart with a version of 1.0.1.  The chart and the application should always be kept in sync - you should never use an old version of the chart with a new version of the docker containers (*image.releaseTag*) or visa versa.

## Prerequisites

* Kubernetes v1.8.3 or later with GPU scheduling enabled, and Tiller v2.60 or later
* The entire application must run on *Power System ppc64le* nodes.  The training and inferencing portions will run on ppc64le nodes with *supported GPUs* (see PowerAI V5.2 release notes).  That is, at least one worker node must be a ppc64le node with a GPU.

### Resources Required

* GPU - At least one GPU with at least 4GB of memory (>= 4 are recommended)
* CPU - A minimum of 8 ppc64le (POWER8 or greater) hardware cores
* Memory - A minimum of 16 GB
* Storage - 40GB minimum persistent storage

#### Persistent Storage
The persistent volume is used to allow data sharing between portions of the application, and to allow for persistence should the server restart.  This volume must be accessible in *ReadWriteMany* mode.  That is, it needs to be shared across nodes in your cluster.  Do not use HostPath unless you have only one node in your cluster.

If your Kubernetes environment supports dynamic provisioning of storage, set `Use dynamic provisioning for persistent volume` to true.  Otherwise, it can be created by using the IBM Cloud Private UI or via a yaml file as in the following example (using an NFS server to host the volumes):

```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: powerai-vision-data
  labels:
    type: nfs
    assign-to: "powerai-vision-<RELEASE_NAME>-data"
spec:
  capacity:
    storage: 40Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /opt/powerai-vision/
    server: mynfsserver.example.com
```
*NOTE:*  Replace the <RELEASE_NAME> in the `assign-to` label with the release name you assign when deploying the chart.

## Installing the Chart

If your using IBM Cloud Private, you may install the chart by clicking `configure` on the bottom if using the IBM Cloud Private UI.

or

To install via command line with the release name `prod` from the chart bundle named `ibm-powerai-vision-prod-1.0.1.tgz`.

```bash
$ helm install --name prod ibm-powerai-vision-prod-1.0.1.tgz
```

The command deploys PowerAI Vision on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Configuration

If installing via command line, you may change the default of each parameter in a values.yaml file (`-f values.yaml`) or using the `--set key=value[,key=value]`.I.e `helm install --name vision --set image.releaseTag=<rel_name> ibm-powerai-vision-prod-1.0.1.tgz`

See the values.yaml file for a description of configuration items.                                                         |

## Securing PowerAI Vision - Setting Usernames & Passwords

PowerAI Vision uses Keycloak for user management and authentication. A default username of `admin` will be created with a password of `passw0rd`.  All users and passwords are maintained by Keycloak and stored in a Postgres database.

After installation, you can add, remove, and list users as well as modify a user's password by using the kubectl command.  To issue user management commands, run the following: kubectl run --rm -i --restart=Never usermgt --image=powerai-vision-usermgt:<version> -- <args> .  If running in the non-default namespace, make sure to specify the --namespace option.  The 'version' tag on the container should match image.releaseTag that is in the values.yaml file.

### Add, Remove, List and Modify a User Arguments

- To create a user:  `create --user <username> --password <password> --release <release>`
- To delete a user:  `delete --user <username> --release <release>`
- To modify a user:  `modify --user <username> --password <password> --release <release>`
- To list all users: `list   --release <release>`

The argument 'release' should match the release name you assigned when deploying the chart.  

If you do not wish to specify the user's password with the --password argument, you can use the --env option for kubectl and set the VISION_USER_PASSWORD environment variable.  For example, add --env="VISION_USER_PASSORD=${MY_PASS}", where MY_PASS is any environment variable which contains the password, to the kubectl run command.

### Invalid Release Name Provided

If an invalid release name is given, the kubectl command will hang.  <ctrl>-c the command and issue the following: kubectl delete pod usermgt.  Retry the initial kubectl command with the correct release name.


## Uninstalling the Chart

To uninstall/delete the `vision` deployment:

```bash
$ helm delete vision --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

The persistent volume you created will not be deleted assuming you set the `persistentVolumeReclaimPolicy` accordingly.  We recommend a value of `Retain`, which will make sure your data is not deleted.  If you wish to re-install later, you can delete and recreate the volume without losing the data.

## Configuration

The following table lists the configurable parameters of the chart and their default values.

| Parameter                  | Description                                      | Default                                                    |
| -----------------------    | ------------------------------------------------ | ---------------------------------------------------------- |
| `image.releaseTag`         | PowerAI Vision Release number - used to match the docker container tags | The release associated with the chart. |
| `image.repoPrefix`         | The prefix for the docker image repository       | eg: mycluster.icp:8500/default/                            |
| `image.pullPolicy`         | Docker image pull policy                         | IfNotPresent                                               |
| `image.secretName`         | Enter the Image Pull Secret Name to pull images from a private docker registry. | nil (generally leave this empty) |
| `persistence.useDynamicProvisioning` | Use dynamic provisioning for persistent volume | false                                              |
| `poweraiVisionDataPvc.name`          | Data PVC name                          | powerai-vision-<RELEASE_NAME>-data-pvc                     |
| `poweraiVisionDataPvc.persistence.existingClaimName` | Data PVC existing claim name | nil (will create a new claim by default)             |
| `poweraiVisionDataPvc.persistence.storageClassName`  | Data PVC storage class | nil (uses default cluster storage class for dynamic provisioning) |
| `poweraiVisionDataPvc.persistence.size` | Data PVC size                       | 40Gi                                                       |
| `ingress.enabled`          | Enable the ingress                               | true (changing this will prevent access to the UI and API) |
| `ingress.hosts`            | List of hosts (proxy servers) for the ingress    | - "" (empty string enables all proxy servers as hosts)            |
| `ingress.tls.secretName`   | Secret holding the TLS certificate               | nil (creates a self-signed cert by default)                |
| `poweraiVisionMongodb.mongodbAdminUsername` | Admin username for Mongodb | admin                                                      |
| `poweraiVisionMongodb.mongodbAdminPassword` | Admin password for Mongodb | ibmpassw0rd                                                |
| `poweraiVisionVideoRabbitmq.rabbitmqUsername` | Admin username for RabbitMQ   | hightall                                                   |
| `poweraiVisionVideoRabbitmq.rabbitmqPassword` | Admin password for RabbitMQ   | mamboserver                                                |
| `poweraiVisionVideoRabbitmq.rabbitmqVhost`    | vhost for RabbitMQ            | classify                                                   |
| `poweraiVisionPostgres.postgresPassword` | Root password for postgres         | dlaaspassw0rd                                              |
| `poweraiVisionDevicePlugins.enableFpgaDaemon` | Enable supported FPGA card scheduling. Daemon should be enabled only once per cluster and will affect all PowerAI Vision instances installed in the cluster. Requires Kubernetes v1.10 or greater.       | false                                              |

## Limitations

You can deploy this application multiple times, regardless of the namespace.  However, please ensure that your persistent volume is unique for each deploy (for example, don't try and share the same path on an NFS server) otherwise database writes will conflict.

While PowerAI Vision is supported running on IBM Cloud Private 2.1.0.2 or later.  There is also a single-server standalone model which leverages the same chart.

## Documentation

Additional documentation can be found here:
https://www.ibm.com/support/knowledgecenter/SSRU69
