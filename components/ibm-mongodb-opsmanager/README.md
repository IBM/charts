# MongoDB Ops Manager

[MongoDB Ops Manager](https://www.mongodb.com/products/ops-manager) is a package for managing MongoDB deployments. Ops Manager provides Ops Manager Monitoring and Ops Manager Backup, which helps users optimize clusters and mitigate operational risk.

## Introduction

This chart is a generic chart for persistent relational and non-relational databases intended to be deployed in IBM Cloud environments.  Both IBM and open source databases are supported.

## Chart Details

This chart will do the following:

Deploy MongoDB Ops Manager in a single server deployment and optionally enable TLS. 
A traditional deployment follows a replica set of 1.
Create a service configured to connect to the available MongoDB Ops Manager instance on the configured client port.


### Prerequisites

- Persistent Volume is required if persistance is enabled and no dynamic provisioning has been set up. You can create a persistent volume through a yaml file. For example:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
  labels:
    assign-to: "data-stor"
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>
```

- To enable TLS you must have a valid tls.crt and tls.key available.  You can create them using the following command:

```
openssl req -new -x509 -days 365 -nodes -text -out yourserver.crt  -keyout yourserver.key -subj '/CN=yourserver.domain.com'
```

### Resources Required

Required minimum Persistence Storage volume size of 20Gi.

Default settings for:
Memory: 512Mi
CPU: 0.25m

## Installing the Chart

You may install the chart by clicking `Configure` on the bottom if using the IBM Cloud Private UI.

OR

To install via command line with the release name `my-release` if you do not have the helm repository:

```bash
#This will show the repositories
helm repo list

# Add the helm repository
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/

#This will show all the charts related to the repository
helm search <repo>

#Finally install the respective chart
$ helm install --name my-release local/ibm-mongodb-opsmanager:1.0.0
```

The command deploys MongoDB Ops Manager on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

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
The following tables lists the configurable parameters of the IBM MongoDB Ops Manager chart and their default values.

| Parameter                            | Description                                     | Default                                                                    |
| ----------------------------------   | ---------------------------------------------   | -------------------------------------------------------------------------- |
| `global.image.secretName`            | A Kubernetes secret                             | `nil`                                                                      
| `arch.amd64`                         | `Amd64 worker node scheduler preference in a hybrid cluster` | `2 - No preference` - worker node is chosen by scheduler      |
| `arch.ppc64le`                       | `Ppc64le worker node scheduler preference in a hybrid cluster` | `2 - No preference` - worker node is chosen by scheduler    |
| `arch.s390x`                         | `S390x worker node scheduler preference in a hybrid cluster` | `2 - No preference` - worker node is chosen by scheduler      |
| `image.repository`                   | `postgresql` image repository                   | `ibmcom/postgresql`                                                        |
| `image.tag`                          | `postgresql` image tag                          | `10.3`                                                                     |
| `image.pullPolicy`                   | Image pull policy                               | `Always` if `imageTag` is `latest`, else `IfNotPresent`                    |
| `persistence.enabled`                | Use a PVC to persist data                       | `true`                                                                     |
| `persistence.useDynamicProvisioning` | Specify a storageclass or leave empty           | `false`                                                                    |
| `dataVolume.existingClaim`           | Provide an existing PersistentVolumeClaim       | `nil`                                                                      |
| `dataVolume.storageClass`            | Storage class of backing PVC                    | `nil`                                                                      |
| `dataVolume.size`                    | Size of data volume                             | `20Gi`                                                                     |
| `resources.requests.memory`          | Memory resource request                         | `256Mi`                                                                      |
| `resource.requests.cpu`              | CPU resource request                            | `200m`                                                                     |
| `resources.limits.memory`            | Memory limit                                    | `16Gi`                                                                     |
| `resource.limits.cpu`                | CPU resource limit                              | `16000m`                                                                   |
| `database.user`                      | Username of new user to create.                 | `nil` - postgres user automatically created if one not chosen              |
| `database.password`                  | Password for the new user.                      | custom or random 10 characters                                             |
| `database.name`                      | Name for new database to create.                | `nil` - postgres database automatically created if value is not provided   |
| `database.dbcmd`                     | Database command for helm test                  | `nil`                                                                      |
| `service.port`                       | TCP port                                        | `5432`                                                                     |
| `service.type`                       | k8s service type exposing ports, e.g. `NodePort`| `NodePort`                                                                 |
| `tls.enabled`                        | Enable TLS                                      | `false`                                                    |
| `tls.key`                            | Private key for TLS use, must be base64 encoded.| ``                                                         |
| `tls.crt`                            | Private crt for TLS use, must be base64 encoded.| ``                                                         |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default [values.yaml](values.yaml)

## Architecture

- Three major architectures are now available for worker nodes:
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

## Retrieving the PostgreSQL user password

The PostgreSQL user password is either auto-generated to a 10 character random password or user-specified. To retrieve the PostgreSQL user password, the user can execute the following command, where <SECRET NAME> is the secret for the deployment as retrieved by `kubectl get secrets`:

`kubectl get secret --namespace default <SECRET NAME> -o jsonpath="{.data.password}" | base64 --decode; echo`

The command will output the decoded secret. 

## Limitations

None
