# IBM MQ Advanced for Developers

## Introduction

This chart deploys a single IBM® MQ Advanced for Developers version 9.1.4 server (Queue Manager).  IBM MQ is messaging middleware that simplifies and accelerates the integration of diverse applications and business data across multiple platforms.  It uses message queues to facilitate the exchanges of information and offers a single messaging solution for cloud, mobile, Internet of Things (IoT) and on-premises environments.

## Chart Details

This chart will do the following:

* Create a single MQ server (Queue Manager) using a [Stateful Set](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with one or two replicas depending on whether multi-instance queue managers are enabled.  Kubernetes will ensure that if it fails for some reason, it will be restarted, possibly on a different worker node.
* Create a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).  This is used to ensure that MQ client applications have a consistent IP address to connect to, regardless of where the Queue Manager is actually running.
* Create an [OpenShift Route](https://docs.openshift.com/container-platform/3.9/architecture/networking/routes.html) for the web console.
* Create an [OpenShift Route](https://docs.openshift.com/container-platform/3.9/architecture/networking/routes.html) for the queue manager.
* [Optional] Create additional [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) for use with a multi-instance Queue Manager.
* [Optional] Create a metrics [Service](https://kubernetes.io/docs/concepts/services-networking/service/) for accessing Queue Manager metrics.

## Prerequisites

* Kubernetes 1.11.0 or greater, with beta APIs enabled.
* You must create a [Secret](https://kubernetes.io/docs/concepts/configuration/secret/) in the target namespace (see the **Creating a Secret to store queue manager credentials** section).  This must contain the 'admin' user password and optionally the 'app' user password to use for messaging.
* If persistence is enabled (see the **configuration** section), then you either need to create a PersistentVolume, or specify a Storage Class if classes are defined in your cluster.

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre-install actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied scripts in the `pak_extensions` pre-install directory.

  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-mq-dev-scc
    allowHostDirVolumePlugin: false
    allowHostIPC: false
    allowHostNetwork: false
    allowHostPID: false
    allowHostPorts: false
    allowPrivilegedContainer: false
    allowedCapabilities:
    - CHOWN
    - FOWNER
    - SETGID
    - SETUID
    - AUDIT_WRITE
    - DAC_OVERRIDE
    allowedFlexVolumes: []
    defaultAddCapabilities: []
    fsGroup:
      type: RunAsAny
    readOnlyRootFilesystem: false
    requiredDropCapabilities:
    - MKNOD
    runAsUser:
      type: RunAsAny
    seLinuxContext:
      type: RunAsAny
    supplementalGroups:
      type: RunAsAny
    volumes:
    - secret
    - persistentVolumeClaim
    users: []
    priority: 0
    ```

- From the command line, you can run the setup scripts included under [pak_extensions](https://github.com/IBM/charts/tree/master/stable/ibm-mqadvanced-server-dev/ibm_cloud_pak/pak_extensions/)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

### Creating a Secret to store queue manager credentials

When using the IBM MQ Advanced for Developers certified container, you must create a Secret in the target namespace. This must contain the 'admin' user password and optionally the 'app' user password to use for messaging.

#### Before you begin

The secret will be a key: value pair with the value being a base64 encoded password string. Before you begin, convert your admin user password, and optionally your app user password, to base64 as follows:

```
$ echo -n 'my-admin-password' | base64  
bXktYWRtaW4tcGFzc3dvcmQ=
```
```
$ echo -n 'my-app-password' | base64  
bXktYXBwLXBhc3N3b3Jk
```

#### Creating a Secret

Before you begin you should make sure you have a command prompt open which has been configured to access your cluster at your target namespace:

1. Create secret file `mq-secret.yaml` containing your base64 encoded password(s) as follows:

```
apiVersion: v1
kind: Secret
metadata:  
    name: mq-secret
type: Opaque
data:  
    adminPassword: bXktYWRtaW4tcGFzc3dvcmQ=
    appPassword: bXktYXBwLXBhc3N3b3Jk
```

2. Create the secret:

```
$ oc create -f mq-secret.yaml
```

## Resources Required

This chart uses the following resources by default:

* 0.5 CPU core
* 0.5 Gi memory
* 2 Gi persistent volume.

See the **configuration** section for how to configure these values.

## Installing the Chart

Install the chart, specifying the release name (for example `foo`) and Helm repository name (for example `mylocal-repo`) with the following command:

```sh
helm install --name foo mylocal-repo/ibm-mqadvanced-server-dev --set license=accept --set queueManager.dev.secret.name=mysecret --set queueManager.dev.secret.adminPasswordKey=adminPassword --tls
```

This example assumes that you have a local Helm repository configured, called `mylocal-repo`.  You could alternatively reference a local directory containing the Helm chart code.

This example also assumes that you have created a Secret `mysecret`, containing a key `adminPassword` with your admin password.  

This command accepts the [IBM MQ Advanced for Developers license](http://www14.software.ibm.com/cgi-bin/weblap/lap.pl?la_formnum=Z125-3301-14&li_formnum=L-APIG-BBZHCQ) and deploys an MQ Advanced for Developers server on the Kubernetes cluster. The **configuration** section lists the parameters that can be configured during installation.

> **Tip**: See all the resources deployed by the chart using `kubectl get all -l release=foo`

### Uninstalling the Chart

You can uninstall/delete the `foo` release as follows:

```sh
helm delete foo --tls
```

The command removes all the Kubernetes components associated with the chart, except any Persistent Volume Claims (PVCs).  This is the default behavior of Kubernetes, and ensures that valuable data is not deleted.

## Configuration

The following table lists the configurable parameters of the `ibm-mqadvanced-server-dev` chart and their default values.

| Parameter                       | Description                                                     | Default                                    |
| ------------------------------- | --------------------------------------------------------------- | ------------------------------------------ |
| `license`                       | Set to `accept` to accept the terms of the IBM license          | `"not accepted"`                           |
| `image.repository`              | Image full name including repository                            | `ibmcom/mq`                                |
| `image.tag`                     | Image tag                                                       | `9.1.4.0-r1`                               |
| `image.pullPolicy`              | Image pull policy                                               | `IfNotPresent`                             |
| `image.pullSecret`              | Image pull secret, if you are using a private Docker registry   | `nil`                                      |
| `arch.amd64`                    | Preference for installation on worker nodes with the `amd64` CPU architecture.  One of: "0 - Do not use", "1 - Least preferred", "2 - No preference", "3 - Most preferred" | `2 - No preference` - worker node is chosen by scheduler |
| `arch.ppc64le`                  | Preference for installation on worker nodes with the `ppc64le` CPU architecture.  One of: "0 - Do not use", "1 - Least preferred", "2 - No preference", "3 - Most preferred" | `2 - No preference` - worker node is chosen by scheduler |
| `arch.s390x`                    | Preference for installation on worker nodes with the `s390x` CPU architecture.  One of: "0 - Do not use", "1 - Least preferred", "2 - No preference", "3 - Most preferred" | `2 - No preference` - worker node is chosen by scheduler |
| `metadata.labels`               | Additional labels to be added to resources                      | `{}`                                       |
| `persistence.enabled`           | Use persistent volumes for all defined volumes                  | `true`                                     |
| `persistence.useDynamicProvisioning` | Use dynamic provisioning (storage classes) for all volumes | `true`                                     |
| `dataPVC.name`                  | Suffix for the PVC name for main MQ data (under `/var/mqm`)     | `"data"`                                   |
| `dataPVC.storageClassName`      | Storage class of volume for main MQ data (under `/var/mqm`)     | `""`                                       |
| `dataPVC.size`                  | Size of volume for main MQ data (under `/var/mqm`)              | `2Gi`                                      |
| `logPVC.enabled`                | Whether or not to use separate storage for transaction logs     | `false`                                    |
| `logPVC.name`                   | Suffix for the PVC name for transaction logs                    | `"log"`                                    |
| `logPVC.storageClassName`       | Storage class of volume for transaction logs                    | `""`                                       |
| `logPVC.size`                   | Size of volume for transaction logs                             | `2Gi`                                      |
| `qmPVC.enabled`                 | Whether or not to use separate storage for queue manager data   | `false`                                    |
| `qmPVC.name`                    | Suffix for the PVC name for queue manager data                  | `"qm"`                                     |
| `qmPVC.storageClassName`        | Storage class of volume for queue manager data                  | `""`                                       |
| `qmPVC.size`                    | Size of volume for queue manager data                           | `2Gi`                                      |
| `metrics.enabled`               | Enable Prometheus metrics for the Queue Manager                 | `true`                                     |
| `resources.limits.cpu`          | Kubernetes CPU limit for the Queue Manager container            | `500m`                                     |
| `resources.limits.memory`       | Kubernetes memory limit for the Queue Manager container         | `512Mi`                                    |
| `resources.requests.cpu`        | Kubernetes CPU request for the Queue Manager container          | `500m`                                     |
| `resources.requests.memory`     | Kubernetes memory request for the Queue Manager container       | `512Mi`                                    |
| `security.context.fsGroup`      | File system group ID (if required by storage provider)          | `nil`                                      |
| `security.context.supplementalGroups` | List of supplemental groups (if required by storage provider) | `nil`                                  |
| `security.initVolumeAsRoot`     | Whether or not storage provider requires root permissions to initialize | `false`                            |
| `queueManager.name`             | MQ Queue Manager name                                           | Helm release name                          |
| `queueManager.multiInstance`    | Whether to run in multi-instance mode with an active and standby queue manager | `false`                     |
| `queueManager.dev.secret.name`  | Secret that contains the 'admin' user password and optionally the 'app' user password to use for messaging | Mandatory - a secret name must be set |
| `queueManager.dev.secret.adminPasswordKey` | Secret key that contains the 'admin' user password    | Mandatory - a key must be set              |
| `queueManager.dev.secret.appPasswordKey` | Secret key that contains the 'app' user password        | `nil` (no password required to connect an MQ client) |
| `pki.keys`                      | An array of YAML objects that detail Kubernetes secrets containing TLS Certificates with private keys. See section titled "Supplying certificates to be used for TLS" for more details  | `[]` |
| `pki.trust`                     | An array of YAML objects that detail Kubernetes secrets containing TLS Certificates. See section titled "Supplying certificates to be used for TLS" for more details  | `[]` |
| `nameOverride`                  | Set to partially override the resource names used in this chart | `ibm-mq`                                   |
| `livenessProbe.initialDelaySeconds` | The initial delay before starting the liveness probe. Useful for slower systems that take longer to start the Queue Manager. | 60 |
| `livenessProbe.periodSeconds`   | How often to run the probe                                      | 10                                         |
| `livenessProbe.timeoutSeconds`  | Number of seconds after which the probe times out               | 5                                          |
| `livenessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded | 1               |
| `readinessProbe.initialDelaySeconds` | The initial delay before starting the readiness probe      | 10                                         |
| `readinessProbe.periodSeconds`  | How often to run the probe                                      | 5                                          |
| `readinessProbe.timeoutSeconds` | Number of seconds after which the probe times out               | 3                                          |
| `readinessProbe.failureThreshold` | Minimum consecutive failures for the probe to be considered failed after having succeeded | 1              |
| `log.format`                    | Error log format on container's console.  Either `json` or `basic` | `basic`                                 |
| `log.debug`                     | Enables additional log output for debug purposes. | `false` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

> **Tip**: You can use the default values.yaml

## Storage

The chart mounts [Persistent Volumes](http://kubernetes.io/docs/user-guide/persistent-volumes/) for the storage of MQ configuration data and messages.  By using Persistent Volumes based on network-attached storage, Kubernetes can re-schedule the MQ server onto a different worker node.  You should not use "hostPath" or "local" volumes, because this will not allow moving between nodes.

Performance requirements will vary widely based on workload, but as a guideline, use a Storage Class which allows for at least 200 IOPS (based on 16 KB block size with a 50/50 read/write mix).

Deployments of multi-instance queue managers and queue managers with separate storage (for transaction logs and/or queue manager data) require that all Persistent Volumes be located in the same zone.  If you have a multi-zone cluster, and the storage provider does not replicate Persistent Volumes across failure domains (availability zones), then your cluster administrator will need to create a set of customized storage classes.

- A customized storage class will be required for each zone in which you wish to deploy an MQ instance.
- Each customized storage class should specify zone/region information as documented by your cloud provider.
- When deploying a queue manager you need to specify the storage class name for each Persistent Volume Claim. This must be set to the name of the customized storage class for your chosen zone.  For example, for a multi-instance queue manager you must set `dataPVC.storageClassName`, `logPVC.storageClassName` and `qmPVC.storageClassName`.

## Limitations

You must not manually change the number of replicas in the StatefulSet.  The number of replicas controls whether or not multi-instance queue managers are used, and are changed in conjunction with other settings.

The recommended way to scale MQ is by deploying this chart multiple times and connecting the Queue Managers together using MQ configuration, such as MQ clusters — see [Architectures based on multiple queue managers](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_9.0.0/com.ibm.mq.pla.doc/q004720_.htm).

## Documentation

### JSON log output

By default, the MQ container output for the MQ Advanced for Developers image is in a basic human-readable format.  You can change this to JSON format, to better integrate with log aggregation services.

### Connecting to the web console

The MQ Advanced for Developers image includes the MQ web server.  The web server runs the web console, and the MQ REST APIs.  By default, the MQ server deployed by this chart is accessible via a `ClusterIP` [Service](https://kubernetes.io/docs/concepts/services-networking/service/), which is only accessible from within the Kubernetes cluster.  An OpenShift Route is provided to connect to the web console from outside a Red Hat OpenShift cluster.

### Supplying certificates to be used for TLS

The `pki.trust` and `pki.keys` allow you to supply details of Kubernetes secrets that contain TLS certificates. By doing so the TLS certificates will be imported into the container at runtime and MQ will be configured to use them. You can supply both certificates which contain only a public key and certificates that contain both public and private keys.

If you supply invalid files or invalid YAML objects then the container will terminate with an appropriate termination message. The next 2 sections will detail the requirements for supplying each type of certificate.

#### Supplying certificates which contain the public and private keys

When supplying a Kubernetes secret that contains a certificate files for both the public and private key you must ensure that the secret contains a file that ends in `.crt` and a file that ends in `.key` named the same. For example: `tls.crt` and `tls.key`. The extension of the file denotes whether the file is the public key (`.crt`) or the private key (`.key`) and must be correct. If your certificate has been issued by a Certificate Authority, then the certificate from the CA must be included as a seperate file with the `.crt` extension. For example: `ca.crt`.

The format of the YAML objects for `pki.keys` value is as follows:

```YAML
- name: mykeys
  secret:
    secretName: mykeysecret
    items:
      - tls.key
      - tls.crt
      - ca.crt
```

or alternatively in a single line you can supply the following: `- name: mykeys, secret: {secretName: mykeysecret, items: [tls.key, tls.crt, ca.crt]}`

`name` must be set to a lowercase alphanumeric value and will be used as the label for the certificate in the keystore and queue manager.

`secret.secretName` must match the name of a Kubernetes secret that contains the TLS certificates you wish to import

`secret.items` must list the TLS certificate files contained in `secret.secretName` you want to import.

To supply the YAML objects when deploying via Helm you should use the following: `--set pki.keys[0].name=mykeys,pki.keys[0].secret.secretName=mykeysecret,pki.keys[0].secret.items[0]=tls.key,pki.keys[0].secret.items[1]=tls.crt,pki.keys[0].secret.items[2]=ca.crt`

If you supply multiple YAML objects then the queue manager will use the first object chosen by the label name alphabetically. For example if you supply the following labels: `alabel`, `blabel` and `clabel`. The queue manager and MQ Console will use the certificate with the label `alabel` for its identity. In this queue manager this can be changed by running the MQSC command: `ALTER QMGR CERTLABL('<new label>')`.

#### Supplying certficates which contain only the public key
When supplying a Kubernetes secret that contains a certificate file with only the public key you must ensure that the secret contains files that have the extension `.crt`. For example: `tls.crt` and `ca.crt`.

The format of the YAML objects for `pki.trust` value is as follows:

```YAML
- secret:
    secretName: mycertificate
    items:
      - tls.crt
```

or alternatively in a single line you can supply the following: `- secret: {secretName: mycertificate, items: [tls.crt]}`

`secret.secretName` must match the name of a Kubernetes secret that contains the TLS certificates you wish to add.

`secret.items` must list the TLS certificate files contained in `secret.secretName` you want to add.

To supply the YAML objects when deploying via Helm you should use the following: `--set pki.trust[0].secret.secretName=mycertificate,pki.trust[0].secret.items[0]=tls.crt`

If you supply multiple YAML objects then all of the certificates specified will be added into the queue manager and MQ Console Truststores.


## Copyright

© Copyright IBM Corporation 2017, 2019
