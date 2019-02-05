# IBM Security Access Manager 

## Introduction

In a world of highly fragmented access management environments, IBM Security Access Manager helps you simplify your users' access while more securely adopting web, mobile and cloud technologies. This solution helps you strike a balance between usability and security through the use of risk-based access, single sign-on, integrated access management control, identity federation and its mobile multi-factor authentication capability, IBM Verify. Take back control of your access management with IBM Security Access Manager.


## Chart Details

This chart will deploy an IBM Security Access Manager environment.  This environment will consist of a number of different containers, namely:

| Container  | Purpose 
| ---------  | -------------------
| isamconfig | This container provides the Web console which can be used to configure the environment.
| isamwrp    | This container provides a secure Web Reverse Proxy.  This should serve as the network entry point into the environment.
| isamrt     | This container provides the runtime services of the Advanced Access Control and Federation offerings.  This is an optional part of the environment and is only required if AAC or Federation capabilities are required.
| isamdsc    | This container provides the distributed session cache server.  It is an optional component and is only required if user sessions need to be shared across multiple containers.
| isampostgresql | This container provides a sample database which can be used by IBM Security Access Manager.  It is not designed to be used in production and should only ever be used in development or proof of concept environments.


## Prerequisites

### Docker Identity
The chart will make use of the ISAM docker image, which is available on Docker Store: [https://store.docker.com/images/ibm-security-access-manager](https://store.docker.com/images/ibm-security-access-manager).  

In order to be able to access the ISAM docker image in Docker Store:

1. A docker account (user identity and password) must be available.  A docker account can be created by following the instructions found at: [https://docs.docker.com/docker-id/](https://docs.docker.com/docker-id/).  
2. The docker account must be registered with the ISAM image in Docker Store.  This can be achieved by accessing the Web page for the ISAM docker image ([https://store.docker.com/images/ibm-security-access-manager](https://store.docker.com/images/ibm-security-access-manager)), selecting the 'Proceed to Checkout' link and then accepting the terms and conditions.
3. A secret must be created which contains the docker account information.  This secret should be supplied as the global.imageCredentials.dockerSecret configuration parameter.  The simplest way to create the secret is to use the kubectl command:
    
   ```
   kubectl create secret docker-registry <secret-name> \
              --docker-username=<username> --docker-password=<password> \
              --docker-email=<e-mail> 
   ```

### Administrator Password
The administrator password will reside within a Kubernetes secret, with a secret key of 'adminPassword'.  If no secret is supplied to the chart via the global.container.imageSecret configuration parameter a new secret will be automatically generated which contains a randomly generated password.

The simplest way to create the secret is to use the kubectl command:

   ```
   kubectl create secret generic <secret-name> --from-literal=adminPassword=<password> 
   ```
   
### PersistentVolume Requirements

A Persistent Volume is required if persistence is enabled and no dynamic provisioning has been set up. You can create a persistent volume through a yaml file. For example:

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

To create the persistent volume using a file called `pv.yaml`:

```bash
$ kubectl create -f pv.yaml
```

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator setup a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy allows pods to run with 
      any UID and GID, but preventing access to the host."
  name: isam-anyuid-psp
spec:
  allowPrivilegeEscalation: true
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities: 
  - MKNOD
  allowedCapabilities:
  - SETPCAP
  - AUDIT_WRITE
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - FSETID
  - KILL
  - SETUID
  - SETGID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETFCAP 
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
  forbiddenSysctls: 
  - '*' 
```

To create a security policy using a file called `sec_policy.yaml`:

```bash
$ kubectl create -f sec_policy.yaml
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
  name: isam-anyuid-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - isam-anyuid-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

To create a cluster role using a file called `cluster_role.yaml`:

```bash
$ kubectl create -f cluster_role.yaml
```

* Custom ClusterRoleBinding for the custom ClusterRole:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: isam-anyuid-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: isam-anyuid-clusterrole
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:{{ NAMESPACE }}
```

The '{{ NAMESPACE }}' string in the cluster role should be replaced with the namespace of the target environment.

To create a cluster role binding using a file called `cluster_role_binding.yaml`:

```bash
$ kubectl create -f cluster_role_binding.yaml
```

## Resources Required

The minimum resources required for each of the container types are:

|Container       | Minimum Memory | Minimum CPU
|---------       | -------------- | -----------
| isamconfig     | 1Gi            | 1000m
| isamwrp        | 512Mi          | 500m
| isamrt         | 1Gi            | 1000m
| isamdsc        | 512Mi          | 500m
| isampostgresql | 512Mi          | 500m

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --name my-release ibm-sam
```

This command deploys the ISAM image on the Kubernetes cluster using the default configuration. The configuration section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list --tls`

## Verifying the Chart

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release> --tls`.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all of the Kubernetes components associated with the chart and deletes the release.  

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  Execute the following command after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
``` 

## Configuration
The following tables list the configurable parameters of the ISAM chart, along with their default values.

### Global

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `global.image.repository` | The image repository. | `store/ibmcorp/isam` |
| `global.image.dbrepository` | The image repository for the postgresql server. | `ibmcom/isam-postgresql` |
| `global.image.tag` | The image version. | `9.0.6.0` |
| `global.image.pullPolicy` | The image pull policy. | `IfNotPresent` |
| `global.imageCredentials.dockerSecret` | The name of an existing secret which contains the Docker Store credentials. | (none) |
| `global.container.snapshot` | The name of the configuration data snapshot that is to be used when starting the container. This will default to the latest published configuration.| latest published snapshot
| `global.container.fixpacks` | A space-separated, ordered list of fix packs to be applied when starting the container. If this environment variable is not present, any fix packs present in the fixpacks directory of the configuration volume will be applied in alphanumeric order. | all available fix packs
| `global.container.adminSecret` | The name of an existing secret which contains the administrator password (key: adminPassword). If no secret is supplied a new secret will be created with a randomly generated password.| (none) |
| `global.container.autoReloadInterval` | The interval, in seconds, that the runtime containers will wait before checking to see if any new configuration is available. | disabled
| `global.persistence.enabled` | Whether to use a PVC to persist data. | `true` |
| `global.persistence.useDynamicProvisioning` | Whether the requested volume will be automatically provisioned if dynamic provisioning is available. | `true` |
| `global.dataVolume.existingClaimName` | The name of an existing PersistentVolumeClaim to be used.| empty |
| `global.dataVolume.storageClassName` | The storage class of the backing PVC. | empty |
| `global.dataVolume.accessModes` | The access mode for the PVC. | `ReadWriteMany` |
| `global.dataVolume.size` | The size of the data volume. | `20Gi` |

### Configuration Service

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `isamconfig.resources.requests.memory` | The amount of memory to be allocated to the configuration service. | `1Gi` |
| `isamconfig.resources.requests.cpu` | The amount of CPU to be allocated to the configuration service. | `1000m` |
| `isamconfig.resources.limits.memory` | The maximum amount of memory to be used by the configuration service. | `2Gi` |
| `isamconfig.resources.limits.cpu` | The maximum amount of CPU to be used by the configuration service. | `2000m` |
| `isamconfig.service.type` | The service type for the configuration service. | `NodePort` |

### Web Reverse Proxy Service

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `isamwrp.container.instances` | The number of unique secure Web Reverse Proxy instances to be created.  The instance name which should be used is of the format wrp_\<instance number> (where the instance number starts at 0). | `1` |
| `isamwrp.container.replicas` | The number of replicas to start for each unique secure Web Reverse Proxy instance. | `1` |
| `isamwrp.resources.requests.memory` | The amount of memory to be allocated to each Web Reverse Proxy instance. | `512Mi` |
| `isamwrp.resources.requests.cpu` | The amount of CPU to be allocated to each replica of each Web Reverse Proxy instance. | `500m` |
| `isamwrp.resources.limits.memory` | The maximum amount of memory to be used by each replica of each Web Reverse Proxy instance. | `1Gi` |
| `isamwrp.resources.limits.cpu` | The maximum amount of CPU to be used by each replica of each Web Reverse Proxy instance. | `1000m` |
| `isamwrp.service.type` | The service type for the Web Reverse Proxy instances. | `NodePort` |

### Runtime Service

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `isamruntime.container.enabled` | Whether the federation and advanced access control runtime is required. | `false`
| `isamruntime.container.replicas` | The number of replicas to start of the runtime service. | `1` |
| `isamruntime.resources.requests.memory` | The amount of memory to be allocated to the runtime service. | `1Gi` |
| `isamruntime.resources.requests.cpu` | The amount of CPU to be allocated to each replica of the runtime service. | `1000m` |
| `isamruntime.resources.limits.memory` | The maximum amount of memory to be used by each replica of the runtime service. | `2Gi` |
| `isamruntime.resources.limits.cpu` | The maximum amount of CPU to be used by each replica of the runtime service. | `2000m` |

### Distributed Session Cache

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `isamdsc.container.enabled` | Whether the distributed session cache service is required. | `false` |
| `isamdsc.container.useReplica` | Whether the distributed session cache service should be replicated for HA. | `true` |
| `isamdsc.resources.requests.memory` | The amount of memory to be allocated to the distributed session cache service. | `512Mi` |
| `isamdsc.resources.requests.cpu` | The amount of CPU to be allocated to each replica of the distributed session cache service. | `500m` |
| `isamdsc.resources.limits.memory` | The maximum amount of memory to be used by each replica of the distributed session cache service. | `1Gi` |
| `isamdsc.resources.limits.cpu` | The maximum amount of CPU to be used by each replica of the distributed session cache service. | `1000m` |

### Database

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `isampostgresql.container.enabled` | Whether the demonstration PostgreSQL service is required. | `false` |
| `isampostgresql.resources.requests.memory` | The amount of memory to be allocated to the demonstration PostgreSQL service. | `512Mi` |
| `isampostgresql.resources.requests.cpu` | The amount of CPU to be allocated to the demonstration PostgreSQL service. | `500m` |
| `isampostgresql.resources.limits.memory` | The maximum amount of memory to be used by the demonstration PostgreSQL service. | `1Gi` |
| `isampostgresql.resources.limits.cpu` | The maximum amount of CPU to be used by the demonstration PostgreSQL service. | `1000m` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.  For example:

```bash
$ helm install --tls --name my-release --set "isamruntime.container.enabled=true" ibm-sam
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.  For example:

```bash
$ helm install --tls --name my-release -f values.yaml ibm-sam
```

## Storage

Different types of persistent storage are supported by this chart:

- Persistent storage using Kubernetes dynamic provisioning. Uses the default storage class defined by the Kubernetes admin or by using a custom storage class which will override the default.
  - Set global values to:
    - persistence.enabled: true 
    - persistence.useDynamicProvisioning: true
  - Specify a custom storageClassName per volume or leave the value empty to use the default storage class.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart.
  - Set global values to:
    - persistence.enabled: true
    - persistence.useDynamicProvisioning: false (default)
  - Specify an existingClaimName per volume or leave the value empty and let the Kubernetes binding process select a pre-existing volume based on the access mode and size.


- No persistent storage. This mode will use emptyPath for any volumes referenced in the deployment.
  - enable this mode by setting the global values to:
    - persistence.enabled: false
    - persistence.useDynamicProvisioning: false


The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/). The volume is created using dynamic volume provisioning. If the PersistentVolumeClaim should not be managed by the chart, define `global.dataVolume.existingClaimName`.

### Existing PersistentVolumeClaims

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart
```bash
$ helm install --set global.dataVolume.existingClaimName=PVC_NAME
```

All containers within the chart will share the same persistent volume claim.  

## Limitations

* This helm chart is only supported on the amd64 architecture;
* The ISAM product does not encrypt the configuration data which is stored on disk and as such access to the disk should be restricted.

## Documentation
The official ISAM documentation can be located in the IBM knowledge centre: [https://www.ibm.com/support/knowledgecenter/en/SSPREK/welcome.html](https://www.ibm.com/support/knowledgecenter/en/SSPREK/welcome.html).

