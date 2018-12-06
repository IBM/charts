# IBM Db2 Developer-C Helm Chart
  
[Db2 Developer-C Edition](http://www-03.ibm.com/software/products/sv/db2-developer-edition) enables you to develop, test, evaluate and demonstrate database and warehousing applications in a non-production environment.

## Introduction

This chart consist of IBM Db2 Developer-C Edition v11.1.4.4 and is a persistent relational database intended to be deployed in a kubernetes environments. For full step-by-step documentation for installing this chart click [here](https://developer.ibm.com/recipes/tutorials/db2-integration-into-ibm-cloud-private/) for the developerWorks recipe.

## Chart Details
This chart will do the following:

- Deploy Db2 using a [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/). A traditional deployment follows a replica set of 1, while an [HADR](#db2-hadr) deployment follows a replica set of 2.  
- Create a Db2 Service configured to connect to the available Db2 instance on the configured client port.
- Provide scripts to create a (or modify existing) namespace and apply either PodSecurityPolicy (for IBM Kubernetes implementations) or Security Context Constraint (for Red Hat OpenShift) to allow privileges needed by the Db2 deployment. 

## Prerequisites

Some prerequisites can be found under [Release Notes](ReleaseNotes.md) along with what's new.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: db2oltp-dev-psp
spec:
  allowPrivilegeEscalation: true
  privileged: false
  allowedCapabilities:
  - SETPCAP
  - MKNOD
  - AUDIT_WRITE
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - FSETID
  - KILL
  - SETGID
  - SETUID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETFCAP
  - SYS_RESOURCE
  - IPC_OWNER
  - SYS_NICE
  fsGroup:
    rule: RunAsAny
  hostIPC: true
  hostNetwork: false
  hostPID: false
  hostPorts:
  - max: 65535
    min: 1
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - '*'
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: db2oltp-dev-cr
rules:
- apiGroups:
  - extensions
  resources:
  - podsecuritypolicies
  resourceNames:
  - db2oltp-dev-psp
  verbs:
  - use
```

#### Configuration scripts can be used to create the required resources

- The Db2 chart requires a cluster administrator to apply the provided namespace and PodSecurityPolicy yaml files. The PodSecurityPolicy applies the required privileges to the new namespace where Db2 will be installed. A cluster administrator can run the following to apply the pod security policy. 

- The scripts are located in the chart's `ibm_cloud_pak/pak_extensions/prereqs` subdirectory. Since the chart is already imported into the default catalog, you can choose to clone the https://github.com/IBM/charts/tree/master/stable/ibm-db2oltp-dev repository to get access to the scripts. Once cloned, you can change directory to the `charts/stable/ibm-db2oltp-dev/ibm_cloud_pak/pak_extensions/prereqs` directory or `charts/stable/ibm-db2oltp-dev/ibm_cloud_pak/pak_extensions/prereqs/rhos` (for Red Hat OpenShift) and run the following script:

On IBM Kubernetes platforms, run:

`./createNSandSecurity.sh --namespace <NAMESPACE>`

On Red Hat OpenShift platforms, run:

`./createSCCandNS.sh --namespace <NAMESPACE>`

- If the namespace existed, only the PSP (or SCC for OpenShift) and role bindings will be applied. If the namespace did not exist, a new namespace will be created with the PSP (or SCC for OpenShift) and rolebindings applied.

- Remember to deploy Db2 in the namespace you have created with the respective privileges. This can be done by selecting the associated namespace in the `Target namespace` configuration panel. Or if installing by command line, you may specify `--namespace <namespace>`.

### Docker container (Prereq #1) 

- User must be subscribed to [Db2 Developer-C Editon on Docker Store](https://store.docker.com/images/db2-developer-c-edition) to access the image. 
- A Docker Api-Key is no longer required. Instead, the docker-password may be used.
- Create Docker Store registry secret must be pre-created via kubectl CLI:
  * `kubectl create secret docker-registry <secretname>  --docker-username=<userid> --docker-password=<pwd> --docker-email=<email> --namespace=default`
- Patch default serviceaccount in namespace services OR specify the name of the created secret on install:
  * To patch serviceaccount, run  `kubectl patch serviceaccount default -p ‘{“imagePullSecrets”: [{“name”: “<secretname>”}]}’ --namespace=default`
  * To specify the secret on install, you can enter it into the kube UI in the "Secret Name" box when you Click configure or if using helm CLI, use `--set global.image.secretName=<secretname>` on helm install. 

### Storage (Prereq #2) 

- Persistence method needs to be selected to ensure data is not lost in the event we lose the node running the Db2 application. 
PersistentVolume needs to be pre-created prior to installing the chart if `Enable persistence for this deployment` is selected and `Use dynamic provisioning for persistent volume` is not. For further details about the default values, see [persistence](#persistence) section.

#### Single Server Instance Storage
- 1 persistent volume is recommended. It can be created by using the kube UI or via a yaml file as the following example:

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
> If using NFS as means of storage, it is required to have no_root_squash.

#### HADR Instance Storage
- If deploying an HA service visit [Db2 HADR](#db2-hadr) section, 6 persistent volumes are recommended. NFS or dynamic provisioning of a shared storage type between the workernodes is recommended. They can be created by using a kube UI or via yaml files as the following examples:

> **Db2 data persistent volumes for data-stor (x2):**

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
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>
```

> **Db2 HADR config volume for hadr-stor - NFS recommended (x1):**

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>
```

> **etcd cluster persistent volumes for etcd-stor (x3):**

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    server: <NFS Server IP>
    path: <NFS PATH>
```

## Installing the Chart

To install via Helm command line with the release name `my-release` if you do not have the helm repository:

```bash
# This will show the repositories

helm repo list --tls

# Add the helm repository

helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/

# This will show all the charts related to the repository

helm search <repo> --tls

# Finally install the respective chart

$ helm install --name my-release local/ibm-db2oltp-dev:3.2.0 --tls
```

The command deploys ibm-db2oltp-dev on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

## Configuration

You may change the default of each parameter using the `--set key=value[,key=value]`.
I.e `helm install --name my-release --set global.image.secretName=<secretname> local/ibm-db2oltp-dev:3.2.0 --tls`

> **Tip**: You can configure the default [values.yaml](values.yaml)


The following tables lists the configurable parameters of the ibm-db2oltp-dev chart and their default values when installing via a kube UI from clicking `Configure`. They are a wrapper for the real values found in values.yaml

## Container image Configuration

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `global.image.secretName`           | Docker Store registry secret                        | `nil` - Enter a generated secret name as explained above or patch default serviceaccount |
| `arch`                              | Worker node architecture                            | `nil` - will try to detect it automatically based on the node deploying the chart. Or user can choose either amd64, s390x, or ppc64le |
| `imageRepository`                   | Db2 Developer-C Edition image repository            | `store/ibmcorp/db2_developer_c`                                                  |
| `imageTag`                          | Db2 Developer-C Edition image tag                   | `11.1.4.4` - will be suffixed with `-<arch>` once architecture is determined    |

## Service Configuration

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `service.name`                      | The name of the Service                             | `ibm-db2oltp-dev`                                                               |
| `service.port`                      | TCP port                                            | `50000`, immutable                                                              |
| `service.tsport`                    | Text search port                                    | `55000`, immutable                                                              |
| `service.type`                      | k8s service type exposing ports, e.g.`ClusterIP`    | `NodePort`                                                                      |

## Database Specific Configuration

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `db2inst.instname`                  | Db2 instance name                                   | `nil` - Default user will be created - db2inst1                                 |
| `db2inst.password`                  | Db2 instance password                               | `nil` - A 10 character random generated password. See below for instructions on how to retrieve it.|
| `options.databaseName`              | Create database with name provided                  | `nil` - No database will be created                                             |
| `options.oracleCompatibility`       | Enable compatibility with Oracle                    | `false` - Feature will not be activated. Set to true to enable it.              |
| `hadr.enabled`                      | Configure Db2 HADR                                  | `false` - If set to true, Db2 HADR will be configured. Read below for details.  |

## Storage Configuration

### Base Db2 Storage Configuration

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `persistence.enabled`               | Enable persistence for this install                 | `true`  - Recommended value. If set to false, Db2 HADR can not be configured.   |
| `peristence.useDynamicProvisioning` | Use dynamic provisioning for persistent volume      | `false` - Set to true if dynamic provisioning is available on the cluster.      |
| `dataVolume.name`                   | Name of the Db2 DB storage persistent volume claim  | `data-stor`                                                                     |
| `dataVolume.existingClaimName`      | Existing volume claim for data-stor                 | `nil` - Only supported in non-HADR scenarios.                                   |
| `dataVolume.storageClassName`       | Existing storage class name for data-stor           | `nil`                                                                           |
| `dataVolume.size`                   | Size of the volume claim for data-stor              | `20Gi`                                                                          |

### Db2 HADR feature Storage Configuration

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `hadr.useDynamicProvisioning`       | Dynamic provisioning for Db2 HADR shared volume     | `false` - Set to true if dynamic provisioning is available on the cluster.      |
| `hadrVolume.name`                   | Name of the Db2 HADR persistent volume claim        | `hadr-stor`                                                                     |
| `hadrVolume.existingClaimName`      | Existing volume claim for hadr-stor                 | `nil`                                                                           |
| `hadrVolume.storageClassName`       | Existing storage class name for hadr-stor           | `nil`                                                                           |
| `hadrVolume.size`                   | Size of the volume claim for hadr-stor              | `1Gi`                                                                           |

### Etcd Storage Configuration (when `hadr.enabled=true`)

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `etcdVolume.name`                   | Name of the Etcd persistent volume claim            | `etcd-stor`                                                                     |
| `etcdVolume.storageClassName`       | Existing storage class name for etcd-stor           | `nil`                                                                           |
| `etcdVolume.size`                   | Size of the volume claim for etcd-stor              | `1Gi`                                                                           |

## Resources Required

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `Resource configuration`            | CPU/Memory resource requests/limits                 | Memory request/limit: `2Gi`/`16Gi`, CPU request/limit: `2000m`/`4000m`          |

## Verifying the Chart

In the developerWorks recipe, visit step 4 [here](https://developer.ibm.com/recipes/tutorials/db2-integration-into-ibm-cloud-private/)  `Confirming Db2 Application is Ready`

> **Tip**: List all releases using `helm list --tls`

## Uninstalling the Chart

To uninstall/delete the `my-release` statefulset:

```bash
$ helm delete my-release --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions additional commands required for clean-up.  

For example :

When deleting a release with statefulsets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
``` 


# DOCUMENTATION AND ADDITIONAL INFORMATION

## Db2 HADR

High availability disaster recovery (HADR) provides a high availability solution for both partial and complete site failures. HADR protects against data loss by replicating data changes from a source database, called the primary database, to the target databases, called the standby databases.
Db2 HADR on a kubernetes cluster is currently supported to be deployed within the same data center, i.e. HA only. Future releases will address automatic deployment accross data centers and geographies. For more information about HADR, click on this [knowledge center link](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.ha.doc/doc/c0011267.html)  

- To deploy the Db2 chart with HADR enabled, select the `Enable Db2 HADR feature` in the kube UI, or if using helm CLI, `--set hadr.enabled=true`
- If Db2 HADR is enabled, there are a few prerequisites:
  * Data persistence MUST be enabled, i.e. make sure "Enable persistence for this install" is checked off in the kube UI, or if using helm CLI, make sure that `persistence.enabled=true` in values.yaml or `--set persistence.enabled=true` on the command line. 
  * User MUST have an HADR persistence volume pre-created. A single volume is needed - 1Gi in size, ReadWriteMany access mode. It is recommended that this volume is NFS accessible by all worker nodes. 
  * User MUST have an ETCD persistent volumes pre-created. Three volumes are needed as etcd is deployed in a 3-node cluster configuration. Each volume should be 1Gi in size and ReadWriteOnce access mode. 
  * Additional configuration options for these volumes are available in the table above - such as size, name, existing claim names, and storage class names.  
- Once Db2 HADR has been enabled, the install will kick off 2 replicas of the ibm-db2oltp-dev statefulset. Each pod in this set will be configured as a PRIMARY and a STANDBY database. The PRIMARY will be configured on ibm-db2oltp-dev-0 pod and STANDBY on the ibm-db2oltp-dev-1 pod. If takeover happens, the PRIMARY will get switched to the ibm-db2oltp-dev-1 pod and when STANDBY is restarted, it will be set up on the ibm-db2oltp-dev-0. This will get switched as roles change during takeovers. 
- An automatic client re-route [ACR](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.1.0/com.ibm.db2.luw.admin.ha.doc/doc/c0011976.html) is set up on each primary and standby pods so that applications can be directed to a standby server if a primary crash occurs. 
- Refer to the Db2 integration recipe for how to connect to your primary database - [here](https://developer.ibm.com/recipes/tutorials/db2-integration-into-ibm-cloud-private/)


## Architecture

- Three major architectures are now available for Db2 Developer-C Edition on kubernetes worker nodes:
  - AMD64 / x86_64
  - s390x
  - ppc64le

An `arch` field in values.yaml is recommended in order to guarantee that the chart has chosen the right architecture to deploy to and the right tagged container is pulled. If left blank, the chart will determine the architecture based on the master node architecture. 

## Retrieving the Db2 instance password

The Db2 instance password is either auto-generated to a 10 character random password or user-specified. To retrieve the Db2 instance password, the user can execute the following command, where <SECRET NAME> is the secret for the statefulset as retrieved by `kubectl get secrets`:

`kubectl get secret --namespace default <SECRET NAME> -o jsonpath="{.data.password}" | base64 --decode; echo`

The command will output the decoded secret. 

## Persistence

- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - Enable persistence for this deployment: selected (default) (persistence.enabled=true)
    - Use dynamic provisioning for persistent volume: selected (non-default) (persistence.useDynamicProvisioning=true)
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - Enable persistence for this deployment: selected (default) (persistence.enabled=true)
    - Use dynamic provisioning for persistent volume: non-selected (default) (persistence.useDynamicProvisioning=false)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.    


- No persistent storage. This mode with use emptyPath for any volumes referenced in the deployment
  - enable this mode by setting the global values to:
    - Enable persistence for this deployment: non-selected (non-default) (persistence.enabled=false)
    - Use dynamic provisioning for persistent volume: non-selected (non-default) (persistence.useDynamicProvisioning=false)


### Existing PersistentVolumeClaims

Example for specifying an existing PersistentVolumeClaim for the `data-stor` volume request (Only supported in non-HADR scenarios). For HADR scenarios, an existing PersistentVolumeClaim for `hadr-stor` is allowed but it must be RWX. 
1. Create the PersistentVolume 
1. Create the PersistentVolumeClaim
1. Install the chart
```bash
$ helm install --name my-release --set dataVolume.existingClaimName=PVC_NAME --tls
```

The volume defaults to mount at a subdirectory of the volume instead of the volume root to avoid the volume's hidden directories from interfering with database creation.


## Namespace Limitation

Since Db2 requires certain Linux capabilities exposed in a namespace, make sure to apply the SCC to the targeted namespace, prior to installing the chart:

- The scripts are located in the chart's `ibm_cloud_pak/pak_extensions/prereqs` subdirectory. Since the chart is already imported into the default catalog, you can choose to clone the https://github.com/IBM/charts/tree/master/stable/ibm-db2oltp-dev repository to get access to the scripts. Once cloned, you can change directory to the `charts/stable/ibm-db2oltp-dev/ibm_cloud_pak/pak_extensions/prereqs` directory or `charts/stable/ibm-db2oltp-dev/ibm_cloud_pak/pak_extensions/prereqs/rhos` (for Red Hat OpenShift) and run the following script:

On IBM Kubernetes platforms, run:

`./createNSandSecurity.sh --namespace <NAMESPACE>`

On Red Hat OpenShift platforms, run:

`./createSCCandNS.sh --namespace <NAMESPACE>`

- If the namespace existed, only the PSP (or SCC for OpenShift) and role bindings will be applied. If the namespace did not exist, a new namespace will be created with the PSP (or SCC for OpenShift) and rolebindings applied.

- Remember to deploy Db2 in the namespace you have created with the respective privileges. This can be done by selecting the associated namespace in the `Target namespace` configuration panel. Or if installing by command line, you may specify `--namespace <namespace>`.


## Limitations
- We do not want to scale our Db2 StatefulSets. This means we must leave the replica at 1 (itself) if for a single instance deployment and a replica of 2 if for a HADR deployment. If we scale it over 1 or 2, the Db2 instances will reference the same filesystem that consist of the instance, database directory, etc. This will cause Db2 to crash.
- Only supports storage options that have backends for persistent volume claims.
- ROLLING UPGRADES FROM PREVIOUS CHART RELEASES ARE NOT SUPPORTED
