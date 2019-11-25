# IBM Unified Console Helm Chart


This is a chart for IBM Unified Console. IBM Unified Console is console across IBM database products. 

## Introduction

This is a chart for IBM Data Server Manager. IBM Data Server Manager which is a database management tool. 

### New in this release

1. Multi-platform manifest support
2. Base OS with latest patches
3. PostgreSQL and MongoDB beta support

## Chart Details
This chart will do the following:

- Deploy a deployment. In deployment there are 2 containers-dsm and dsm-sidecar. 
- Create a service to connect to deployment.

## Prerequisites

* See the [IBM Cloud Pak Dependency Management Guidance](http://ibm.biz/icppbk-depmgt) for help with this section.
* Kubernetes Level - indicate if specific APIs must be enabled (i.e. Kubernetes 1.6 with Beta APIs enabled)
* PersistentVolume requirements (if persistence.enabled) - PV provisioner support, StorageClass defined, etc. (i.e. PersistentVolume provisioner support in underlying infrastructure with ibmc-file-gold StorageClass defined if persistance.enabled=true)
* Simple bullet list of CPU, MEM, Storage requirements
* Even if the chart only exposes a few resource settings, this section needs to be inclusive of all / total resources of all charts and subcharts.
* Describe any custom image policy requirements if using a non-whitelisted image repository.
* Describe the permissions that the installer needs. E.g. Cluster Admin, Team Admin or Team Operator
  * If the installer is Team Admin or Team Operator and using ICP 3.1.2 or later, set the HELM_HOME variable prior to calling any Helm CLI command:
    `eval $(cloudctl helm-init)`
* Describe any [IBM Platform Core Service Names](http://ibm.biz/icppbk-coresvcs) that are required.  Some common dependencies include:  `auth-idp`, `secret-watcher`, `tiller`
* Additional pre and post configuration scripts, instructions, files, samples... should be placed in the ibm_cloud_pak/pak_extensions folder. The pak_extension folder is further broken into several defined subdirectories that you can use for your extensions. The current structure is:

  * ibm_cloud_pak
    - pak_extensions
      - common 
        - Scripts that may be used by other scripts (e.g. includes, libraries...)
      - dashboards (Reserved for future use)
      - logo (Reserved for future use)
      - post-delete
        - clusterAdministration
          - < your scripts...>
        - namespaceAdministration
          - < your scripts.. >
      - post-install
        - clusterAdministration
          - < your scripts...>
        - namespaceAdministration
          - < your scripts.. >
      - pre-delete
        - clusterAdministration
          - < your scripts...>
        - namespaceAdministration
          - < your scripts.. >
      - pre-install
        - clusterAdministration
          - < your scripts...>
        - namespaceAdministration
          - < your scripts.. >
      - samples
        - < your samples...>
      - support
        - < your support/mustgather ....>                

  * ```IMPORTANT:``` The pak_extensions folder IS NOT packaged in the helm chart.tgz file and IS NOT automatically included by the PPA offline packaging tool or the current version of the cloudctl tool. (There is an open git issue to add this support to cloudctl).
    
    * For a PPA chart:
      - You must MANUALLY modify the tgz file created by either the offline packager or cloudctl and include the pak_extensions folder.
      - You must also include instructions on how a user can access the pak_extensions content. These instructions can be as simple as telling the user to untar the ppa archive and where to locate the pak_extension folder.

    * For a non-PPA chart:
      - You must include instructions on how a user can access the pak_extensions content. Published dev charts are available on github.com/ibm/charts. Here is an example:
      Download pak_extensions from [here](https://github.com/IBM/charts/tree/master/stable/YOUR-CHART-NAME/ibm_cloud_pak/pak_extensions/)
      ```Note:``` The current github.com repo only contains the most recent chart source. We are working to improve versioning support.


### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-chart-dev-psp
    spec:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      allowedCapabilities:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      runAsUser:
        rule: RunAsAny
      fsGroup:
        rule: RunAsAny
      volumes:
      - configMap
      - secret
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-chart-dev-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-chart-dev-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
- From the command line, you can run the setup scripts included under pak_extensions
  As a cluster admin the pre-install instructions are located at:
  - pre-install/clusterAdministration/< your scripts...> 

  As team admin the namespace scoped instructions are located at:
  - pre-install/namespaceAdministration/< your scripts...>
### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-chart-dev-scc
    readOnlyRootFilesystem: false
    allowedCapabilities:
    - CHOWN
    - DAC_OVERRIDE
    - SETGID
    - SETUID
    - NET_BIND_SERVICE
    seLinux:
      type: RunAsAny
    supplementalGroups:
      type: RunAsAny
    runAsUser:
      type: RunAsAny
    fsGroup:
      rule: RunAsAny
    volumes:
    - configMap
    - secret
    ```
- From the command line, you can run the setup scripts included under pak_extensions
  As a cluster admin the pre-install instructions are located at:
  - pre-install/clusterAdministration/< your scripts...> 

  As team admin the namespace scoped instructions are located at:
  - pre-install/namespaceAdministration/< your scripts...>

### Other
- Kubernetes 1.8 with Beta APIs enabled or above
- Helm 2.3.1 and later version
- Retrieve image pull secret by accepting the terms and conditions here - http://ibm.biz/db2-dsm-license (set in global.image.secret)
- Two PersistentVolume(s) need to be pre-created prior to installing the chart if `persistance.enabled=true` and `persistence.dynamicProvisioning=false` (default values, see [persistence](#persistence) section). It can be created by using a yaml file as the following example:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0001
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: anything
    storage: 4Gi
  hostPath:
    path: /data/pv0001/
EOF
```

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0002
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: anything
    storage: 20Gi
  hostPath:
    path: /data/pv0002/
EOF
```

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release --set license=accept --set global.image.secret=<SECRET> stable/ibm-unifiedconsole-prod
```

The command deploys ibm-unified-console-prod on  the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions additional commands required for clean-up.  

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.


```console
$ kubectl delete pvc -l release=my-release
``` 

## Configuration

The following tables lists the configurable parameters of the ibm-unified-console-prod chart and their default values.

| Parameter                             | Description                                                  | Default                                                    |
| ------------------------------        | ----------------------------------------------------------   | ---------------------------------------------------------- |
| `arch.amd64`                  | `Amd64 worker node scheduler preference in a hybrid cluster` | `2 - No preference` - worker node is chosen by scheduler       |
| `arch.ppc64le`                | `Ppc64le worker node scheduler preference in a hybrid cluster` | `2 - No preference` - worker node is chosen by scheduler       |
| `arch.s390x`                  | `S390x worker node scheduler preference in a hybrid cluster` | `2 - No preference` - worker node is chosen by scheduler       |
| `customNodeSelectorTerms`     | `custom nodeselector terms                                     | `nil`                                                      |
| `customTolerations`           | `custom tolerations                                          | `nil`                                                      |
| `image.repository`                    | `DSM` image                                                  | `store/ibmcorp/data_server_manager_dev`                         | 
| `image.tag`                           | `DSM` image tag                                              | `2.1.4.1`                                                    |	
| `imageSidecar.Tag`                    | `DSM` sidecar image tag                                      | `0.4.0`                                                    |
| `image.pullPolicy`                    | `DSM` image pull policy                                      | `Always` if `imageTag` is `latest`, else `IfNotPresent`    |
| `imageSidecar.pullPolicy`             | `DSM` sidecar image pull policy                              | `Always` if `imageTag` is `latest`, else `IfNotPresent`    |
| `global.image.secret`                 | `DSM` and repository image secret                            | `VISIT http://ibm.biz/db2-dsm-license TO RETRIEVE IMAGE SECRET`|
| `login.user`                          | `DSM` admin user name                                        | `admin`                                                    |              
| `login.password`                      | `DSM` admin password                                         | `nil`                                                      |                       
| `dataVolume.name`                      | The PVC name to persist data                                 | `datavolume`                                                |     
| `persistence.enabled`                 | Use a PVC to persist data                                    | `true`                                                     |
| `persistence.useDynamicProvisioning`  | Dynamic provision persistent volume or not                   | `false`				                                            |
| `dataVolume.persistence.existingClaim` | Provide an existing PersistentVolumeClaim                    | `nil`                                                      |
| `dataVolume.persistence.storageClass`  | Storage class of backing PVC                                 | `nil`                                                      |
| `dataVolume.persistence.size`          | Size of data volume                                          | `4Gi`                                                      |
| `resources.limits.cpu`                | Container CPU limit                                          | `4`                                                        |
| `resources.limits.memory`             | Container memory limit                                       | `16Gi`                                                     |
| `resources.requests.cpu`              | Container CPU requested                                      | `2`                                                        |
| `resources.requests.memory`           | Container Memory requested                                   | `4Gi`                                                      |
| `service.httpsPort`                    | Internal https port                                           | `443`                                                    |
| `service.httpsPort2`                    | Interal https port 2                                           | `8443`                                                    |
| `service.type`                        | k8s service type exposing ports, e.g.`ClusterIP`             | `NodePort`                                                 |  
| `service.name`                        | k8s service type exposing ports name                         | `console`                                                  | 
| `repository.image.repository`         | Repository image                                             | `db2server_dec`               |
| `repository.image.tag`                | Repository image tag                                         | `11.1.2.2b`                                                 | 
| `repository.image.pullPolicy`         | Repository image pull policy                                 | `Always` if `imageTag` is `latest`, else `IfNotPresent`    | 
| `repository.persistence.useDynamicProvisioning`  | Dynamic provision persistent volume or not        | `false`	                                                  |
| `repository.dataVolume.persistence.storageClass`  | Storage class of backing PVC                      | `nil`                                                      |   
| `repository.dataVolume.persistence.size`          | Size of data volume                               | `20Gi` 					                                          |	
| `repository.resources.limits.cpu`                | Repository container CPU limit                    | `4000m`                                                    |
| `repository.resources.limits.memory`             | Repository container memory limit                 | `16Gi`                                                     |
| `repository.resources.requests.cpu`              | Repository container CPU requested                | `1000m`                                                    |
| `repository.resources.requests.memory`           | Repository container Memory requested             | `2Gi`                                                      |

                                 



Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. 
> **Tip**: You can use the default [values.yaml](values.yaml)

The volume defaults to mount at a subdirectory of the volume instead of the volume root to avoid the volume's hidden directories from interfering with database creation.

## Resources Required

| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `Resource configuration`            | CPU/Memory resource requests/limits                 | Memory request/limit: `2Gi`/`16Gi`, CPU request/limit: `1000m`/`4000m`          |

## Architecture

- Three major architectures are now available on worker nodes:
  - AMD64 / x86_64
  - s390x
  - ppc64le

An ‘arch’ field in values.yaml is required to specify supported architectures to be used during scheduling and includes ability to give preference to certain architecture(s) over another.

Specify architecture (amd64, ppc64le, s390x) and weight to be  used for scheduling as follows :
   0 - Do not use
   1 - Least preferred
   2 - No preference
   3 - Most preferred
## NodeSelector and Tolerations

Set values like :

```
customNodeSelectorTerms:
- key: icp4data
  operator: In
  values:
  - database-db2oltp

customTolerations:
- key: "icp4data"
  operator: "Equal"
  value: "database-db2oltp"
  effect: "NoSchedule"
```

## PodAffinity and PodAntiAffinity

Set values like :

```
customPodAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - topologyKey: "kubernetes.io/hostname"
    labelSelector:
      matchLabels:
        type: "engine"

customPodAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: security
          operator: In
          values:
          - S2
      topologyKey: failure-domain.beta.kubernetes.io/zone
```

## Persistence

- Persistent storage using kubernetes dynamic provisioning. Uses the default storageclass defined by the kubernetes admin or by using a custom storageclass which will override the default.
  - Set global values to:
    - persistence.enabled: true (default)
    - persistence.useDynamicProvisioning: true
    - repository.persistence.useDynamicProvisioning: true
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart
  - Set global values to:
    - persistence.enabled: true
    - persistence.useDynamicProvisioning: false (default)
    - repository.persistence.useDynamicProvisioning: false (default)
  - Specify an existingClaimName per volume or leave the value empty and let the kubernetes binding process select a pre-existing volume based on the accessMode and size.


- No persistent storage. This mode with use emptyPath for any volumes referenced in the deployment
  - enable this mode by setting the global values to:
    - persistence.enabled: false
    - persistence.useDynamicProvisioning: false
    - repository.persistence.useDynamicProvisioning: false


The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) volume. The volume is created using dynamic volume provisioning. If the PersistentVolumeClaim should not be managed by the chart, define `persistence.existingClaim`.


## Automatically connect and manage Db2


If you have Db2 created in your namespace (no matter created before or after DSM), DSM will automatically connect to it and start to manage it.

A repository DB is created automatically to store your monitor and administration metadata. The minimum resource requied: 1 CPU 2G memory and 8G storage. It may need a long time when DSM deploy, creat repository DB and bind to it. If you delete DSM, its repository DB will also be deleted automatically. 

You can only run one DSM per namespace. If you deploy the second DSM, it will be deleted silently in a while in backend. 


## Limitations
- ROLLING UPGRADES FROM PREVIOUS CHART RELEASES ARE NOT SUPPORTED

