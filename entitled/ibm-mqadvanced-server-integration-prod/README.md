# IBM MQ Advanced

## Introduction

This chart deploys a single IBM® MQ version 9.1.4 Advanced server (Queue Manager).  IBM MQ is messaging middleware that simplifies and accelerates the integration of diverse applications and business data across multiple platforms.  It uses message queues to facilitate the exchanges of information and offers a single messaging solution for cloud, mobile, Internet of Things (IoT) and on-premises environments.

## Chart Details

This chart will do the following:

* Create a single MQ server (Queue Manager) using a [Stateful Set](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/) with one or two replicas depending on whether multi-instance queue managers are enabled.  Kubernetes will ensure that if it fails for some reason, it will be restarted, possibly on a different worker node.
* Create a [Service](https://kubernetes.io/docs/concepts/services-networking/service/).  This is used to ensure that MQ client applications have a consistent IP address to connect to, regardless of where the Queue Manager is actually running.
* Create a [Job](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/) to register the Queue Manager with the IBM Identity and Access Manager, for single sign-on.
* Create a [Service Account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/), [Role and Role Binding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) to secure what permissions the running container has.
* Create a pre-upgrade and a post-delete Job, Role and Role Binding.
* Create an [OpenShift Route](https://docs.openshift.com/container-platform/3.11/architecture/networking/routes.html) for the web console.
* Create an [OpenShift Route](https://docs.openshift.com/container-platform/3.11/architecture/networking/routes.html) for the queue manager.
* [Optional] Create additional [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) for use with a multi-instance Queue Manager.
* [Optional] Create a metrics [Service](https://kubernetes.io/docs/concepts/services-networking/service/) for accessing Queue Manager metrics.
* [Optional] Create a Job to register the Queue Manager with the Operations Dashboard.

## Prerequisites

* OpenShift Container Platform v4.2 and v4.3 (Kubernetes 1.14 & 1.16)
* If persistence is enabled (see the **configuration** section), then you either need to create a Persistent Volume, or specify a Storage Class if classes are defined in your cluster.
* Administrator is the minimum role required to install this chart.
* The following IBM Platform Core Services are required: `tiller` & `auth-idp`.

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre-install actions that need to occur.

The predefined SecurityContextConstraints name: [`anyuid`](https://ibm.biz/cpkspec-scc) has been verified for this chart when `security.initVolumeAsRoot=false`, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

The predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart when `security.initVolumeAsRoot=true`, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used when `security.initVolumeAsRoot=true` to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied scripts in the `pak_extensions` pre-install directory.

  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-mq-init-volume-as-root-scc
    allowHostDirVolumePlugin: false
    allowHostIPC: false
    allowHostNetwork: false
    allowHostPID: false
    allowHostPorts: false
    allowPrivilegeEscalation: true
    allowPrivilegedContainer: false
    allowedCapabilities:
    - CHOWN
    - FOWNER
    - DAC_OVERRIDE
    defaultAddCapabilities: null
    fsGroup:
      type: RunAsAny
    readOnlyRootFilesystem: false
    requiredDropCapabilities:
    - MKNOD
    runAsUser:
      type: RunAsAny
    seLinuxContext:
      type: MustRunAs
    supplementalGroups:
      type: RunAsAny
    volumes:
    - secret
    - configMap
    - downwardAPI
    - emptyDir
    - persistentVolumeClaim
    - projected
    users: []
    priority: 0
    ```

- From the command line, you can run the setup scripts included under [pak_extensions](https://github.com/IBM/charts/tree/master/entitled/ibm-mqadvanced-server-integration-prod/ibm_cloud_pak/pak_extensions)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

## Resources Required

This chart uses the following resources by default:

* 1 CPU core
* 1 Gi memory
* 2 Gi persistent volume.

See the **configuration** section for how to configure these values.

## Installing the Chart

Install the chart, specifying the release name (for example `foo`) and Helm repository name (for example `mylocal-repo`) with the following command:

```sh
helm install --name foo mylocal-repo/ibm-mqadvanced-server-integration-prod --set license=accept --tls
```

This example assumes that you have a local Helm repository configured, called `mylocal-repo`.  You could alternatively reference a local directory containing the Helm chart code.

This command accepts the [IBM MQ Advanced license](http://www14.software.ibm.com/cgi-bin/weblap/lap.pl?la_formnum=Z125-3301-14&li_formnum=L-APIG-BGMHFW) and deploys an MQ Advanced server on the Kubernetes cluster. The **configuration** section lists the parameters that can be configured during installation.

> **Tip**: See all the resources deployed by the chart using `kubectl get all -l release=foo`

### Uninstalling the Chart

You can uninstall/delete the `foo` release as follows:

```sh
helm delete foo --tls
```

The command removes all the Kubernetes components associated with the chart, except any Persistent Volume Claims (PVCs).  This is the default behavior of Kubernetes, and ensures that valuable data is not deleted.

## Configuration

The following table lists the configurable parameters of the `ibm-mqadvanced-server-integration-prod` chart and their default values.

| Parameter                       | Description                                                     | Default                                    |
| ------------------------------- | --------------------------------------------------------------- | ------------------------------------------ |
| `license`                       | Set to `accept` to accept the terms of the IBM license          | `"not accepted"`                           |
| `productionDeployment`          | Whether the application is running production workloads         | `true`                                     |
| `image.repository`              | Image full name including repository                            | `MQ image`                                 |
| `image.tag`                     | Image tag                                                       | `Tag of MQ image`                          |
| `image.pullPolicy`              | Image pull policy (for all images)                              | `IfNotPresent`                             |
| `image.pullSecret`              | Image pull secret, if you are using a private Docker registry   | `nil`                                      |
| `icp4i.namespace`               | Namespace where the platform navigator is installed             | `integration`                              |
| `sso.registrationImage.repository` | Single sign-on registration image name including repository  | `SSO registration image`                   |
| `sso.registrationImage.tag`     | Single sign-on registration image tag                           | `Tag of SSO registration image`            |
| `tls.generate`                  | Whether to generate a new certificate or use an existing certificate | `true`                                |
| `tls.hostname`                  | The hostname of the cluster                                     | Mandatory - a hostname must be set         |
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
| `resources.limits.cpu`          | Kubernetes CPU limit for the Queue Manager container            | `1`                                        |
| `resources.limits.memory`       | Kubernetes memory limit for the Queue Manager container         | `1Gi`                                      |
| `resources.requests.cpu`        | Kubernetes CPU request for the Queue Manager container          | `1`                                        |
| `resources.requests.memory`     | Kubernetes memory request for the Queue Manager container       | `1Gi`                                      |
| `security.context.fsGroup`      | File system group ID (if required by storage provider)          | `nil`                                      |
| `security.context.supplementalGroups` | List of supplemental groups (if required by storage provider) | `nil`                                  |
| `security.initVolumeAsRoot`     | Whether or not storage provider requires root permissions to initialize | `true` - when set to true, you may need a custom SecurityContextConstraints (see the section on Red Hat OpenShift SecurityContextConstraints requirements) |
| `queueManager.name`             | MQ Queue Manager name                                           | Helm release name                          |
| `queueManager.multiInstance`    | Whether to run in multi-instance mode with an active and standby queue manager | `false`                     |
| `queueManager.terminationGracePeriodSeconds` | The duration in seconds the Queue Manager needs to terminate gracefully | `30`                  |
| `pki.keys`                      | An array of YAML objects that detail Kubernetes secrets containing TLS Certificates with private keys for use by the queue manager. See section titled "Supplying certificates to be used for TLS" for more details  | `[]` |
| `pki.trust`                     | An array of YAML objects that detail Kubernetes secrets containing trusted TLS Certificates for use by the queue manager and MQ Console. See section titled "Supplying certificates to be used for TLS" for more details  | `[]` |
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
| `log.debug`                     | Enables additional log output for debug purposes                | `false`                                    |
| `trace.strmqm`                  | Whether to enable MQ trace on queue manager start, i.e. `strmqm` | `false` |
| `odTracingConfig.enabled`       | Whether or not to enable the OD for this release                | `false`                                    |
| `odTracingConfig.odAgentImageRepository` | Repository where the OD agent image is located         | `OD agent image`                           |
| `odTracingConfig.odAgentImageTag` | The tag for the Docker image for the OD agent                 | `Tag of OD agent image`                    |
| `odTracingConfig.odAgentLivenessProbe.initialDelaySeconds` | How long to wait before starting the probe | `10`                                 |
| `odTracingConfig.odAgentReadinessProbe.initialDelaySeconds` | How long to wait before the probe is ready | `10`                                |
| `odTracingConfig.odCollectorImageRepository` | Repository where the OD collector image is located | `OD collector image`                       |
| `odTracingConfig.odCollectorImageTag` | The tag for the Docker image for the OD collector         | `Tag of OD collector image`                |
| `odTracingConfig.odCollectorLivenessProbe.initialDelaySeconds` | How long to wait before starting the probe | `10`                             |
| `odTracingConfig.odCollectorReadinessProbe.initialDelaySeconds` | How long to wait before the probe is ready | `10`                            |
| `odTracingConfig.odTracingNamespace` | Namespace where the Operation Dashboard was released       | `""`                                       |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

> **Tip**: You can use the default values.yaml

## Single sign-on

Authorization for the MQ Web Console is controlled by IAM roles.  To access the MQ Web Console you must either have the `administrator` role for the namespace where MQ is deployed or have the cluster-administrator role.

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

### Configuring MQ objects

You have the following major options for configuring the MQ queue manager itself:

1. Use the MQ web console interactively
2. Create a new image layer with your configuration baked-in
3. Configure remote administration over messaging, and use existing tools, such as `runmqsc`, MQ Explorer or the MQ Command Server.

The REST administrative API is not currently supported.

#### Configuring MQ using a new image layer

You can create a new container image layer, on top of the IBM MQ Advanced base image.  You can add MQSC files to define MQ objects such as queues and topics, and place these files into `/etc/mqm` in your image.  When the MQ pod starts, it will run any MQSC files found in this directory (in sorted order).

#### Example Dockerfile and MQSC script for creating a new image

In this example you will create a Dockerfile that creates two users:

* `admin` - Administrator user which is a member of the `mqm` group
* `app` - Client application user which is a member of the `mqclient` group. (You will also create this group)

You will also create a MQSC Script file called `config.mqsc` that will be run automatically when your container starts. This script will do the following:

* Create default local queues for my applications
* Create channels for use by the `admin` and `app` users
* Configure security to allow use of the channels by remote applications
* Create authority records to allow members of the `mqclient` group to access the Queue Manager and the default local queues.

First create a file called `config.mqsc`. This the MQSC file that will be run when an MQ container starts. It should contain the following:

```
* Create Local Queues that my application(s) can use.
DEFINE QLOCAL('EXAMPLE.QUEUE.1') REPLACE
DEFINE QLOCAL('EXAMPLE.QUEUE.2') REPLACE

* Create a Dead Letter Queue for undeliverable messages and set the Queue Manager to use it.
DEFINE QLOCAL('EXAMPLE.DEAD.LETTER.QUEUE') REPLACE
ALTER QMGR DEADQ('EXAMPLE.DEAD.LETTER.QUEUE')

* Set ADOPTCTX to YES so we use the same userid passed for authentication as the one for authorization and refresh the security configuration
ALTER AUTHINFO(SYSTEM.DEFAULT.AUTHINFO.IDPWOS) AUTHTYPE(IDPWOS) ADOPTCTX(YES)
REFRESH SECURITY(*) TYPE(CONNAUTH)

* Create a entry channel for the Admin user and Application user
DEFINE CHANNEL('EXAMP.ADMIN.SVRCONN') CHLTYPE(SVRCONN) REPLACE
DEFINE CHANNEL('EXAMP.APP.SVRCONN') CHLTYPE(SVRCONN) MCAUSER('app') REPLACE

* Set Channel authentication rules to only allow access through the two channels we created and only allow admin users to connect through EXAMPLE.ADMIN.SVRCONN
SET CHLAUTH('*') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(NOACCESS) DESCR('Back-stop rule - Blocks everyone') ACTION(REPLACE)
SET CHLAUTH('EXAMP.APP.SVRCONN') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) DESCR('Allows connection via APP channel') ACTION(REPLACE)
SET CHLAUTH('EXAMP.ADMIN.SVRCONN') TYPE(ADDRESSMAP) ADDRESS('*') USERSRC(CHANNEL) DESCR('Allows connection via ADMIN channel') ACTION(REPLACE)
SET CHLAUTH('EXAMP.ADMIN.SVRCONN') TYPE(BLOCKUSER) USERLIST('nobody') DESCR('Allows admins on ADMIN channel') ACTION(REPLACE)

* Set Authority records to allow the members of the mqclient group to connect to the Queue Manager and access the Local Queues which start with "EXAMPLE."
SET AUTHREC OBJTYPE(QMGR) GROUP('mqclient') AUTHADD(CONNECT,INQ)
SET AUTHREC PROFILE('EXAMPLE.**') OBJTYPE(QUEUE) GROUP('mqclient') AUTHADD(INQ,PUT,GET,BROWSE)
```

Next create a `Dockerfile` that expands on the MQ Advanced Server image to create the users and groups. It should contain the following, replacing `<IMAGE NAME>` with the MQ image you want to use as a base:

```dockerfile
FROM <IMAGE NAME>
# Add the admin user as a member of the mqm group and set their password
USER root
RUN useradd admin -G mqm \
    && echo admin:passw0rd | chpasswd \
# Create the mqclient group
    && groupadd mqclient \
# Create the app user as a member of the mqclient group and set their password
    && useradd app -G mqclient \
    && echo app:passw0rd | chpasswd
# Copy the configuration script to /etc/mqm where it will be picked up automatically
USER mqm
COPY config.mqsc /etc/mqm/
```

Finally, build and push the image to your registry.

You can then use the new image when you deploy MQ into your cluster. You will find that once you have run the image you will be able to see your new default objects and users.

### JSON log output

By default, the MQ container output is in JSON format, to better integrate with log aggregation services.  On the command line, you can use utilities like 'jq' to format this output, for example:

```sh
kubectl logs foo-ibm-mq-0 | jq -r '.ibm_datetime + " " + .message'
```

### Supplying certificates to be used for TLS

The `pki.trust` and `pki.keys` allow you to supply details of Kubernetes secrets that contain TLS certificates. By doing so the TLS certificates will be imported into the container at runtime and MQ will be configured to use them. You can supply both certificates which contain only a public key and certificates that contain both public and private keys.

If you supply invalid files or invalid YAML objects then the container will terminate with an appropriate termination message. The next 2 sections will detail the requirements for supplying each type of certificate.

#### Supplying certificates which contain the public and private keys

When supplying a Kubernetes secret that contains a certificate files for both the public and private key you must ensure that the secret contains a file that ends in `.crt` and a file that ends in `.key` named the same. For example: `tls.crt` and `tls.key`. The extension of the file denotes whether the file is the public key (`.crt`) or the private key (`.key`) and must be correct. If your certificate has been issued by a Certificate Authority, then the certificate from the CA must be included as a seperate file with the `.crt` extension. For example: `ca.crt`.

The format of the YAML objects for `pki.keys` value is as follows:

```YAML
- name: mykey
  secret:
    secretName: mykeysecret
    items:
      - tls.key
      - tls.crt
      - ca.crt
```

or alternatively in a single line you can supply the following: `- name: mykey, secret: {secretName: mykeysecret, items: [tls.key, tls.crt, ca.crt]}`

`name` must be set to a lowercase alphanumeric value and will be used as the label for the certificate in the keystore and queue manager.

`secret.secretName` must match the name of a Kubernetes secret that contains the TLS certificates you wish to import

`secret.items` must list the TLS certificate files contained in `secret.secretName` you want to import.

To supply the YAML objects when deploying via Helm you should use the following: `--set pki.keys[0].name=mykey,pki.keys[0].secret.secretName=mykeysecret,pki.keys[0].secret.items[0]=tls.key,pki.keys[0].secret.items[1]=tls.crt,pki.keys[0].secret.items[2]=ca.crt`

If you supply multiple YAML objects then the queue manager will use the first object chosen by the label name alphabetically. For example if you supply the following labels: `alabel`, `blabel` and `clabel`. The queue manager will use the certificate with the label `alabel` for its identity. This can be changed at runtime by executing the MQSC command: `ALTER QMGR CERTLABL('<new label>')`.

#### Supplying certificates which contain only the public key

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

### Configuring Operations Dashboard (OD)

You can enable this feature by setting `odTracingConfig.enabled=true` option. By default, this feature will be disabled.  

Users may note that this feature when enabled will run two sidecar containers [Agent and Collector containers] additionally with the queue manager container in the pod. These sidecar containers will be available in same repository as the MQ's image and will use same pull policy/secret as the MQ's image. These sidecar containers will have following resource limits and requests, users must ensure to make the neccessary resources available.
- CPU Limit : 500m
- Memory Limit: 512Mi
- CPU Request: 256m
- Memory Request: 128Mi

Users will also notice an additional `odtracing-registration` job that performs registration of current queue manager as a service with the Operations Dashboard. Administrators will have additional steps to execute once the `odtracing-registration` job shows its status as completed:

1. Log into Operations Dashboard UI and go to Menu --> Manage settings

2. Manage setting displays all the registration requests, find your request based on the `odtracing-registration` job name. This name can be found from the pod list of current deployment in your namespace.

3. Approve the registration request. This brings up a popup window with `kubectl` command to create a secret required by the Operations Dashboard collector for sending logs to Operations Dashboard server.

4. Copy the commands and execute them against the namespace running your queue manager pod in your cluster.

5. Registration activity is required once per namespace and will remain valid for any number of queue manager deployments within the namespace.

This completes the configuration of MQ for Operations Dashboard. Messaging operations with the queue manager will now be traced and activity can be visualized on your Operations Dashboard UI.

## Copyright

© Copyright IBM Corporation 2017, 2019
