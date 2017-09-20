# IBM Db2 Developer-C Helm Chart - BETA

[Db2 Developer-C Edition](http://www-03.ibm.com/software/products/sv/db2-developer-edition) enables you to develop, test, evaluate and demonstrate database and warehousing applications in a non-production environment. 

## Introduction

This chart is consist of IBM Db2 Developer-C Edition and is a persistent relational database intended to be deployed in IBM Cloud-Private environments. 

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release --set license=accept stable/ibm-db2oltp-dev
```

The command deploys ibm-db2oltp-dev on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

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

## Configuration

The following tables lists the configurable parameters of the db2-oltp-prod chart and their default values.

| Parameter                     | Description                                     | Default                                                    |
| ---------------------------   | ---------------------------------------------   | ---------------------------------------------------------- |
| `image`                       | `Db2 Developer-C` image repository              | `db2server_dec-ma`                                         |
| `imageRepository`             | `Db2 Developer-C` image repository              | `na.cumulusrepo.com/db2dg/`                                |                    
| `imageTag`                    | `Db2 Developer-C` image tag                     | `11.1.2.2`                                                 |
| `imagePullPolicy`             | Image pull policy                               | `Always` if `imageTag` is `latest`, else `IfNotPresent`    |
| `db2inst.instname`            | `Db2` instance name                             | `nil`                                                      |                     
| `db2inst.password`            | `Db2` instance password                         | `nil`                                                      |                  
| `options.databaseName`        | Create database with name provided              | `nil`                                                      |                 
| `options.oracleCompatibility` | Enable compatibility with Oracle                | `false`                                                    |                      
| `persistence.enabled`         | Use a PVC to persist data                       | `true`                                                     |
| `persistence.useDynamicProvisioning`      | Specify a storageclass or leave empty           | `false`                                        |
| `dataVolume.existingClaim`    | Provide an existing PersistentVolumeClaim       | `nil`                                                      |
| `dataVolume.storageClass`     | Storage class of backing PVC                    | `nil`                                                      |
| `dataVolume.size`             | Size of data volume                             | `200Gi`                                                    |
| `resources`                   | CPU/Memory resource requests/limits             | Memory: `1Gi`, CPU: `1000m`                                |
| `persistence.subPath`         | Subdirectory of the volume to mount at          | `nil`                                                      |
| `service.port`                | TCP port                                        | `50000`                                                    |
| `service.type`                | k8s service type exposing ports, e.g.`ClusterIP`| `NodePort`                                                 |

The above parameters map to the env variables defined in [Db2 Developer-C Edition](DATABASEDOCKERURL). For more information please refer to the [Db2 Developer-C Edition](DATABASEDOCKERURL) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - persistence.enabled: true (default)
    - persistence.useDynamicProvisioning: true
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - persistence.enabled: true
    - persistence.useDynamicProvisioning: false (default)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.    


- No persistent storage. This mode with use emptyPath for any volumes referenced in the deployment
  - enable this mode by setting the global values to:
    - persistence.enabled: false
    - persistence.useDynamicProvisioning: false


The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) volume. The volume is created using dynamic volume provisioning. If the PersistentVolumeClaim should not be managed by the chart, define `persistence.existingClaim`.

### Existing PersistentVolumeClaims

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart
```bash
$ helm install --set persistence.existingClaim=PVC_NAME
```

The volume defaults to mount at a subdirectory of the volume instead of the volume root to avoid the volume's hidden directories from interfering with database creation.
