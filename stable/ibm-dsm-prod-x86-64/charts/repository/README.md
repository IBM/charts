# IBM Db2 Direct Advanced Edition

[IBM Db2 Direct Advanced Edition](https://www.ibm.com/us-en/marketplace/db2-advanced-enterprise) provides advanced data management and analytics capabilities for both transactional and warehousing workloads. 

## Introduction

This chart is consist of IBM Db2 Direct Advanced Edition and is a persistent relational database intended to be deployed in IBM Cloud Private environments. 

### New in this version
- Multi-architecture support
- Uplift of base operating system

## Chart Details
This chart will do the following:

- Deploy Db2 using a deployment.  
- Create a Db2 Service configured to connect to the available Db2 instance on the configured client port.

## Prerequisites

- PersistentVolume needs to be pre-created prior to installing the chart if `persistance.enabled=true` and `persistence.dynamicProvisioning=false` (default values, see [persistence](#persistence) section). It can be created by using the IBM Cloud Private UI or via a yaml file as the following example:

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

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release local/ibm-db2oltp-dae:1.1.0
```

The command deploys ibm-db2oltp-prod on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

For full step-by-step documentation for installing this chart click [Deploy Db2 Into IBM Cloud Private](https://developer.ibm.com/recipes/tutorials/db2-integration-into-ibm-cloud-private/) for the developerWorks recipe.

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

The following tables lists the configurable parameters of the ibm-db2oltp-dae chart and their default values.

| Parameter                     | Description                                        | Default                                                    |
| ---------------------------   | ---------------------------------------------      | ---------------------------------------------------------- |
| `arch`                        | `Change to desired worker node architecture`       | `nil` - will try to be detected automatically              | 
| `imageRepository`             | `Db2 Direct Advanced ` image repository | `db2server_dae`                                           |     
| `imageTag`                    | `Db2 Direct Advanced ` image tag                   | `11.1.2.2b-x86_64` |
| `imagePullPolicy`             | Image pull policy                                  | `IfNotPresent`                                             |
| `db2inst.instname`            | `Db2` instance name                                | `nil`                                                      | 
| `db2inst.password`            | `Db2` instance password                            | `nil`                                                      |  
| `options.databaseName`        | Create database with name provided                 | `nil`                                                      |  
| `options.oracleCompatibility` | Enable compatibility with Oracle                   | `false`                                                    |       
| `persistence.enabled`         | Use a PVC to persist data                          | `true`                                                     |
| `persistence.useDynamicProvisioning`      | Specify a storageclass or leave empty  | `false`                                                    |
| `dataVolume.existingClaim`    | Provide an existing PersistentVolumeClaim          | `nil`                                                      |
| `dataVolume.storageClass`     | Storage class of backing PVC                       | `nil`                                                      |
| `dataVolume.size`             | Size of data volume                                | `20Gi`                                                     |
| `resources`                   | CPU/Memory resource requests/limits                | Memory: `2Gi`, CPU: `1000m`                                |
| `service.port`                | TCP port                                           | `50000`                                                    |
| `service.port`                | Text search TCP port                               | `55000`                                                    |
| `service.type`                | k8s service type exposing ports, e.g.`ClusterIP`   | `ClusterIP`                                                |

The above parameters map to the env variables defined in Db2 Direct Advanced Edition.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default [values.yaml](values.yaml)

## Resources Required

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `Resource configuration`            | CPU/Memory resource requests/limits                 | Memory request/limit: `2Gi`/`16Gi`, CPU request/limit: `2000m`/`4000m`          |

## Persistence

- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - persistence.enabled: true (default)
    - persistence.useDynamicProvisioning: true (non-default)
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - persistence.enabled: true (default)
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
$ helm install --name my-release --set persistence.existingClaim=PVC_NAME
```

The volume defaults to mount at a subdirectory of the volume instead of the volume root to avoid the volume's hidden directories from interfering with database creation.

## Limitations
- Only supports storage options that have backends for persistent volume claims.
- ROLLING UPGRADES FROM PREVIOUS CHART RELEASES ARE NOT SUPPORTED

