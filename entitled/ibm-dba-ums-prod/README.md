# User Management Service

![DBA-MC Logo](https://raw.githubusercontent.com/IBM/charts/master/logo/dba_multicloud.svg?sanitize=true)

The IBM Cloud Pak for Automation uses the User Management Service (UMS) as a central component for authenticating users and managing user and group information.

## Introduction

The User Management Service provides users of multiple IBM Cloud Pak for Automation components with a single sign-on experience.

In addition, it provides REST APIs to create, retrieve, update, and delete (CRUD) users and groups in the IBM Cloud Pak for Automation.

## Chart Details

This chart deploys the User Management Service as a deployment with associated service and ingress components.

In the standard configuration, it includes the following:

- A ServiceAccount with a Role and a RoleBinding.
- Two Configmaps, one for configuration values and one for custom binaries.
- An Ingress and a service.
- A Deployment including two initContainers to prepare the UMS configuration.
- A HorizontalPodAutoscaler that targets the Deployment.

## Prerequisites

### Helm Tiller, kubernetes versions
helm tiller version: 2.9.1
Kubernetes version: >=1.11.0

### Database Requirements

A mandatory prerequisite for UMS is at least one database server hosting the OAuth and the Team Server database. See [Configuration](#Configuration) for a list of parameters that you must pass in the `values.yaml` file. Supported databases include Derby, DB2, and Oracle. The workload validates the setup of the database and the required tables/indexes during startup.

A database can become unusable because of hardware or software failures, or both. You could encounter storage problems, power interruptions, or application failures, and each failure scenario requires a different recovery action. Protect your data against the possibility of loss by having a well rehearsed backup and recovery strategy in place. Ensure that you follow the database procedures for backup/recovery for the database that you use.

You can set up JDBC encryption between the UMS server and your database so that your data is transmitted securely over the network.

In addition, you can encrypt your database to protect the stored data from being accessed by unauthorized entities.

To get up and running quickly, you can use the Derby database that is included in the chart (see the necessary configuration below). However this option is only suitable for non-production environments because it results in each container having its own database that is not persistent and cannot be shared across UMS instances.

### Sensitive Configuration

Because sensitive configuration settings must not be passed in the `values.yaml` file, you must create three secrets manually before you install the chart as shown below. Do not specify any data in the ibm-dba-ums-ltpa-creation-secret because it will be populated by the LTPA creation job.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ibm-dba-ums-secret
type: Opaque
stringData:
  adminUser: "umsadmin"
  adminPassword: "password"
  sslKeystorePassword: "sslPassword"
  jwtKeystorePassword: "jwtPassword"
  teamserverClientID: "ts"
  teamserverClientSecret: "tsSecret"
  ltpaPassword: "ltpaPassword"
---
apiVersion: v1
kind: Secret
metadata:
  name: ibm-dba-ums-ltpa-creation-secret
type: Opaque
data:
---     
apiVersion: v1
kind: Secret
metadata:
  name: ibm-dba-ums-db-secret
type: Opaque
stringData:
  oauthDBUser: "oauthdbusr"
  oauthDBPassword: "oauthdbpwd"
  tsDBUser: "tsdbusr"
  tsDBPassword: "tsdbpwd"
```

| Parameter                          | Description                                     |
| -------------------------------    | ---------------------------------------------   |
| `adminUser`                        | User ID of the UMS admin user                   |
| `adminPassword`                    | Password for the UMS admin user                 |
| `sslKeystorePassword`              | Password for the internal UMS SSL keystore      |
| `jwtKeystorePassword`              | Password for the internal UMS JWT keystore      |
| `teamserverClientID`               | ID for the Team Server's OIDC client            |
| `teamserverClientSecret`           | Secret for the Team Server's OIDC client        |
| `ltpaPassword`                     | Password for the internal LTPA key	             |
| `oauthDBUser`                      | User ID for the OAuth database                  |
| `oauthDBPassword`                  | Password for the OAuth database                 |
| `tsDBUser`                         | User ID for the Team Server database            |
| `tsDBPassword`                     | Password for the Team Server database           |

You only need to specify the database settings if you aren't using the internal Derby databases. If you want to use one database for the whole UMS workload, you should provide the same configuration values for both databases.

Apart from the database values (which relate to your specific database setup), you can choose all secret values freely, but make sure that the names of the secrets do not end with `-config` because that is reserved for internal use.

After modifying the values (and, if you want to, the names of the secrets), you can create the secrets. The following command assumes that the previous sample is in a file named `ums-secret.yaml` and that the installation target namespace is the one you created first.

```kubectl create -f ums-secret.yaml --namespace <namespace>```

You must then pass the names to the chart in the `global.ums.adminSecretName` and `global.ums.dbSecretName` properties as shown [below](#Configuration).

### Sensitive Configuration for Liberty in XML format

Because sensitive configuration settings for Liberty, such as LDAP configurations including the bind password, should not be passed using `customXml` in a customized `values.yaml`, you must create one secret manually before you install the chart as illustrated in the following sample. You can provide the advanced configuration settings as a multiline string value for the `customSecretConfig` parameter.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ums-liberty-secret
type: Opaque
stringData:
  sensitiveCustomConfig: |
  <server>

    <ldapRegistry id="myRegistry" ...>
      baseDN="cn=users,dc=adtest,dc=mycity,dc=mycompany,dc=com"
      bindDN="cn=testuser,cn=users,dc=adtest,dc=mycity,dc=mycompany,dc=com"
      bindPassword="testuserpwd"
      <ldapEntityType ...>
        ...
      </ldapEntityType>
      <attributeConfiguration>
        ...
      </attributeConfiguration>
    </ldapRegistry>

  </server>
```

Note that the secret for sensitive liberty configuration settings is optional.

After adding the multiline string value (and, if you want to, the names of the secrets), you can create the secret. The following command assumes that `ums-liberty-secret.yaml` contains the previous sample and that the installation target namespace is your namespace.

```kubectl create -f ums-liberty-secret.yaml --namespace <namespace>```

You pass the name of the secret to the chart in the `customSecretName` property as shown [below](#Configuration).

### Docker Secret

If you're pulling Docker images from a private registry, you must provide a secret that contains the credentials for it - for details about how to create this secret, see the [Kubernetes docs on private registries](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line). After it has been created, you must pass its name to the Helm chart in the [configuration](#Configuration) property `global.imagePullSecrets`.

### Certificate Secrets

#### TLS

To ensure that the internal communications are secure, you must provide a TLS secret. And if you intend to deploy the UMS chart in an environment with services that rely on it, make sure that the certificate is signed by a trusted CA. You can generate the secret manually by using the following command:

```bash
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt
```

Make sure that you provide a common name that matches the UMS host name (`global.ums.hostName` in the [configuration](#Configuration)). You can then use the following command to create a secret using the two generated files:

```bash
kubectl create secret tls ibm-dba-ums-tls --key tls.key --cert tls.crt --namespace <namespace>
```

Choose an appropriate name and ensure that the files inside are called `tls.key` and `tls.crt`. You must pass the name of the secret to the chart in the `tls.tlsSecretName` property as shown [below](#Configuration).

#### JWT/JWK

To be able to validate ID Tokens (which are provided as JWTs), the workload offers a JWK endpoint that provides the key that is necessary for validation. For a quick setup, `oauth.jwtSecretName` can be set to the same value as `tls.tlsSecretName` - it will then reuse the same secret and certificate. Otherwise, you must create a separate secret (following the [same instructions as for the TLS secret](#TLS)) and references as `oauth.jwtSecretName`. Make sure that you also set the `jwtKeystorePassword` in the [secret above](#sensitive-configuration) - and do not use the same password that you used for `sslKeystorePassword`!

#### Db2 SSL Configuration

To ensure that all communications between UMS and Db2 are encrypted, you must import the database CA Certificate to UMS. To do so, you must create a secret to store the certificate:

```bash
kubectl create secret generic ibm-dba-ums-db2-cacert --from-file=cacert.crt=<path-to-certificate-file>
```

Note: The certificate must be in PEM format. You must modify the part `<path-to-certificate-file>` to point to the certificate file. Do not change the part `--from-file=cacert.crt=`.

You can then use the resulting secret to set the `oauth.database.sslSecretName: ibm-dba-ums-db2-cacert` and `teamserver.database.sslSecretName: ibm-dba-ums-db2-cacert` configuration parameters, while setting `oauth.database.ssl: true` and `teamserver.database.ssl: true`.

### Persistent Volume

In some cases, the chart also requires a PersistentVolume to be set up in advance (with a minimum size: 1 GB), along with a PersistentVolumeClaim, whose name has to be passed via the `values.yaml` (see the `global.existingClaimName` property in the [configuration](#Configuration)).

You only need to set up a PersistentVolume if any of the following conditions apply:

- You want to use a database other than Derby or DB2 (i.e. Oracle).
- You want to use a Db2 database, but you want to use your own JDBC driver.
- You want to use custom binaries inside the UMS.

If none of the above conditions apply, set `useCustomJDBCDrivers` and `useCustomBinaries` to `false`. To use the embedded Db2 JDBC driver, make sure that the `driverfiles` property is set to `"db2jcc4.jar db2jcc_license_cu.jar"` then continue with [the next section](#service-type).

Otherwise, create a PersistentVolume like this:

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: ibm-dba-ums-pv
  labels:
    type: binaries
    owner: ums
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: standard
  # example setup for nfs server - for other setups, see the Kubernetes Docs on PersistentVolumes
  nfs:
    server: "1.2.3.4"
    path: "/binaries"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ibm-dba-ums-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  selector:
    matchLabels:
      type: binaries
      owner: ums
```

There are two purposes for the PersistentVolume:

#### JDBC Drivers

The volume can hold JDBC driver files that do not come packaged with the chart. When you create the PersistentVolume, make sure that you add the following structure to the mounted directory (which in this example is called `binaries`):

```
/binaries
  /jdbc
    /db2
      /db2.jar
    /oracle
      /oracle.jar
```

The `/jdbc` folder and its contents depend on the configuration: If you activate this feature, the chart expects you to provide the JDBC driver files as shown above.

Subdirectories under `/jdbc` must be named one of the following: `db2`, `oracle` or `mssql`. This must match the `oauth.database.type`/`teamserver.database.type` property in the [configuration](#Configuration) below.

You also need to tell the chart which files you want to use in a blank-separated list (see the `oauth.database.driverfiles`/`teamserver.database.driverfiles` property in the [configuration](#Configuration)).

To activate this feature, set `useCustomJDBCDrivers` to `true`.
A default JDBC driver for Db2 is included in the docker image. If you use Db2, you do not need a persistent volume for hosting JDBC drivers.

#### Custom Binaries

If you want to use custom binaries in the server, you need a separate directory in the PersistentVolume:

```
/binaries
  /custom-binaries
    /...
```

It can contain code that is explicitly loaded by a Liberty server feature using the `<library>` configuration element. You can refer to any files in this repository by using the following path `/opt/ibm/wlp/usr/shared/resources/custom-binaries`.

To activate this feature, set `useCustomBinaries` to `true`.

### Service Type

The UMS Helm chart offers two ways of accessing the workload, which you can set up as shown in the [configuration](#Configuration) below.

- If the Kubernetes cluster supports Ingress, you can set `global.ums.serviceType` to `Ingress` or `ClusterIP`. Note that `global.ums.port` is ignored in favor of the standard Ingress port, which is 443.
- Otherwise, you can set `global.ums.serviceType` to `NodePort`. Then you must provide `global.ums.port` - which can be a port between 30000 and 32767.

### Resources Required
The minimum hardware requirements for the User Management Service are 250m vCPU and 500 MB of memory per replica.

### Limitations
User Management Service is currently supported on amd64 architecture only.

## Secure Deployment Guidelines
When storing configuration files on a persistent volume, host the volume on an encrypted file system to protect any sensitive information (such as credentials) that might be included in the configuration files.
The same applies for databases: Because the User Management Service persists authentication tokens and other credentials in a database, the databse should be hosted on an encrypted file system.

When connecting to your database and LDAP server, make sure that the connections are encrypted.

Some kubernetes platforms do not protect against the BREACH attack. Disable HTTP-level compression in the ingress-controller-leader-nginx configmap by seting "use-gzip" to false: `kubectl edit configmap ingress-controller-leader-nginx --namespace=kube-system`

```yaml
apiVersion: v1
data:
  use-gzip: "false"
kind: ConfigMap
metadata:
  name: ingress-controller-leader-nginx
  ...
```

### Network security
Installing User Management Service implies installing a set of _network security policies_ in the namespace. Most importantly, you should have a deny-all policy that prevents all incoming and outgoing network traffic unless specifically whitelisted. This policy applies to all pods in the namespace, hence it is recommended to install User Management Service into a dedicated namespace or ensure that all required network traffic for unrelated pods is already whitelisted.
The following network traffic is whitelisted for UMS pods:
* Outgoing connections to DNS.
* Outgoing connections to LDAP ports 389 and 636. You can remove unused ports and further restrict target network IPs by editing the ums-ldap policy: `kubectl edit networkpolicy ums-ldap`.
* Outgoing connections to database ports as specified in values.yaml. You can further restrict target network IPs by editing the ums-database policy: `kubectl edit networkpolicy ums-database`.
* Incomming connections to the exposed HTTPS port.

For two temporary pods (...-ltpa-creation-job and ...-test), there are additional network policies to enable the initial setup of the environment.

### Role Based Access Control (RBAC) requirements
If you choose to install UMS in _IBM Cloud Private_ without Tiller, you can run `helm template ...` to create YAML files that are then applied to your cluster using `kubectl apply -f ...`. This requires the `Administrator` role for the given namespace in order to create and assign RBAC roles. For daily operations, the `Editor` role is sufficient to scale up and down as well as viewing logs and modifying the configuration.

### Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: '[`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc)'  has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

* From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  * Custom SecurityContextConstraints definition:
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-ums-scc
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

### PodSecurityPolicy Requirements
This chart does not require elevated privileges to run. The predefined PodSecurityPolicy [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart.

This chart also defines a custom PodSecurityPolicy that can be used to finely control the permissions/capabilities that are necessary to deploy this chart.

From the user interface, you can copy and paste the following snippet to enable the Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-ums-psp
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

Save the snippet in a local file (for example in `ibm-psp.yaml`) and run the following command:

```kubectl create -f ibm-psp.yaml```

Add a custom ClusterRole for the custom PodSecurityPolicy:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-chart-dev-clusterrole
rules:
- apiGroups:
  - policy
  resourceNames:
  - ibm-ums-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

### Using custom certificates for HTTPS
The UMS pod must be secured with a TLS certificate to allow HTTPS traffic from a kubernetes ingress (or OpenShift route). Private key and certificate must be configured in a kubernetes secret of type TLS as described for `tls.tlsSecretName` in [TLS](#TLS).
This certificate is only visible to the ingress or route. The certificate that is presented to external clients, such as web browsers, can be configured using `ingressSecretName`, see [TLS in kubernetes ingress documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) or [key, certificate, caCertificate in OpenShift re-encrypt route documentation](https://docs.openshift.com/container-platform/3.11/architecture/networking/routes.html#re-encryption-termination).

## Installing the Chart

Installing the chart does not require any special permissions - any user that can work with Helm and Tiller can install the chart. Installation is only supported using the command line, not via the Platform Catalog User Experience.

Before installing, ensure that the [prerequisites](#Prerequisites) have been fulfilled.

Then copy the existing `values.yaml` file and fill it with your data - then install the chart using the following command (using your customized `myvalues.yaml`):

```bash
helm install --namespace <namespace> --name ibm-dba-ums-prod -f myvalues.yaml ibm-dba-ums-prod --debug --tls
```

To find out more about how to set up SSL/TLS connections between Helm and Tiller, see [the Helm/Tiller docs](https://github.com/helm/helm/blob/master/docs/tiller_ssl.md).

### Configuration

The following table lists the configurable parameters of the chart and their default values. All properties are required - unless they have a default or are explicitly optional. Note that although the chart may seem to install correctly when omitting some parameters, such configurations are not supported.

| Parameter                              | Description                                           | Default                                              |
| -------------------------------------- | ----------------------------------------------------- | ---------------------------------------------------- |
| `global.imagePullSecrets`              | Existing UMS docker image secret                      |                                                      |
| `global.existingClaimName`             | Existing UMS persistent volume claim name             |                                                      |
| `global.isOpenShift`                   | Specifies if the target platform is OpenShift (controlling container runAsUser definition) | true            |
| `global.ums.serviceType`               | UMS service type: `NodePort`, `ClusterIP`, `Ingress`  | Ingress                                              |
| `global.ums.port`                      | UMS port (only effective when using NodePort service) |                                                      |
| `global.ums.hostName`                  | UMS external host name                                |                                                      |
| `global.ums.adminSecretName`           | Existing UMS administrative secret for sensitive configuration |                                             |
| `global.ums.dbSecretName`              | Existing UMS database connection secret for sensitive configuration |                                        |
| `global.ums.ltpaSecretName`            | Secret for storing LTPA keys (prerequisite)           |                                                      |
| `images.ums`                           | Image name for UMS container                          | `docker.registry:8500/default/ums/ums:19.0.2`           |
| `images.initTLS`                       | Image name for TLS init container                     | `docker.registry:8500/default/dba-keytool-initcontainer:19.0.2`|
| `images.ltpa`                          | Image name for LTPA key bootstrap job container       | `docker.registry:8500/default/dba-keytool-jobcontainer:19.0.2`|
| `images.pullPolicy`                    | Pull policy for all containers                        | `IfNotPresent`                                       |
| `ingressSecretName`                    | TLS secret to secure channel from client (optional)   |                                                      |
| `tls.tlsSecretName`                    | Existing TLS secret containing `tls.key` and `tls.crt` |                                                     |
| `useCustomJDBCDrivers`                 | Toggle for custom JDBC drivers (instead of embedded DB2 drivers) | `false`                                   |
| `oauth.database.type`                  | OAuth database type: `derby`, `db2`, `mssql`, `oracle` |                                                     |
| `oauth.database.name`                  | OAuth database name (not needed for type `derby`)     |                                                      |
| `oauth.database.host`                  | OAuth database host (not needed for type `derby`)     |                                                      |
| `oauth.database.port`                  | OAuth database port (not needed for type `derby`)     |                                                      |
| `oauth.database.ssl`                   | OAuth database SSL enablement (true or false, Db2 only) |                                                    |
| `oauth.database.sslSecretName`         | OAuth database SSL CA certificate secret              |                                                      |
| `oauth.database.driverfiles`           | OAuth database user JDBC driver files (not needed for type `derby`) |                                        |
| `oauth.database.alternateHosts`        | Comma-separated list of Db2 HADR failover servers     |                                                      |
| `oauth.database.alternatePorts`        | Comma-separated list of Db2 HADR failover server ports|                                                      |
| `oauth.clientManagerGroup`             | Group authorized to register OAuth clients (optional) |                                                      |
| `oauth.jwtSecretName`                  | Existing TLS secret containing `tls.key` and `tls.crt` |                                                     |
| `teamserver.database.type`             | Team Server database type: `derby`, `db2`, `mssql`, `oracle` |                                               |
| `teamserver.database.name`             | Team Server database name (not needed for type `derby`) |                                                    |
| `teamserver.database.host`             | Team Server database host (not needed for type `derby`) |                                                    |
| `teamserver.database.port`             | Team Server database port (not needed for type `derby`) |                                                    |
| `teamserver.database.ssl`              | Team Server database SSL enablement (true or false, Db2 only) |                                              |
| `teamserver.database.sslSecretName`    | Team Server database SSL CA Certificate secret          |                                                    |
| `teamserver.database.driverfiles`      | Team Server database user JDBC driver files (not needed for type `derby`) |                                  |
| `teamserver.database.alternateHosts`   | Comma-separated list of Db2 HADR failover servers     |                                                      |
| `teamserver.database.alternatePorts`   | Comma-separated list of Db2 HADR failover server ports|                                                      |
| `logs.consoleFormat`                   | UMS logs console format                               | `json`                                               |
| `logs.consoleLogLevel`                 | UMS logs console log level                            | `INFO`                                               |
| `logs.consoleSource`                   | UMS logs console source                               | `message,trace,accessLog,ffdc,audit`                 |
| `logs.traceFormat`                     | UMS logs trace format                                 | `ENHANCED`                                           |
| `logs.traceSpecification`              | UMS logs trace spec                                   | `*=info`                                             |
| `replicaCount`                         | Number of deployment replicas                         | `1`                                                  |
| `autoscaling.enabled`                  | UMS autoscaling (overrides static replicaCount)       | `true`                                               |
| `autoscaling.minReplicas`              | UMS autoscaling minimum number of replicas            | `1`                                                  |
| `autoscaling.maxReplicas`              | UMS autoscaling maximum number of replicas            | `5`                                                  |
| `autoscaling.targetAverageUtilization` | UMS autoscaling CPU utilization                       | `80`                                                 |
| `resources.limits.cpu`                 | CPU resource limits                                   | `500m`                                               |
| `resources.limits.memory`              | Memory resource limits                                | `512Mi`                                              |
| `resources.requests.cpu`               | CPU resource requests                                 | `200m`                                               |
| `resources.requests.memory`            | Memory resource requests                              | `256Mi`                                              |
| `customXml`                            | UMS complex config settings (optional, multiline value) |                                                    |
| `customSecretName`                     | Existing secret for sensitive Liberty configuration in XML format |                                          |
| `useCustomBinaries`                    | Toggle for custom binaries                            | `false`                                              |

#### Storage

As was described in [prerequisites](#Persistent-volume), the chart requires a pre-created PersistentVolume of any type - the minimum supported size is 1 GB. Additionally, a PersistentVolumeClaim must be created and referenced in the [configuration](#Configuration). The mounted directory must contain a `jdbc` sub-directory, which in turn holds subdirectories with the necessary JDBC driver files (which must be referenced by the `oauth.database.driverfiles` property in the [configuration](#Configuration)).

#### ConfigMap

You can provide advanced configuration settings, such as LDAP configurations, as a multiline string value in the `customXml` parameter.
To provide advanced sensitive configuration settings as a multiline string value see [above](#Sensitive-Configuration-for-Liberty-in-XML-format)

In your customized `myvalues.yaml`, set the `customXml` parameter value as follows:

```yaml
...

customXml: |+
  <server>

    <ldapRegistry id="myRegistry" ...>
      <ldapEntityType ...>
        ...
      </ldapEntityType>
      <attributeConfiguration>
        ...
      </attributeConfiguration>
    </ldapRegistry>

  </server>
```

If you want to reference a custom file that you mounted using the `custom-binaries` volume (see [above](#persistent-volume)), the path should be based off `/opt/ibm/wlp/usr/shared/resources/custom-binaries`.

### Verifying the Chart

After the helm installation completes perform chart verification as described in `[NOTES.txt](./templates/Notes.txt)`. You can also view the instructions by running the command: `helm status my-release --tls`.

## Upgrading the Chart

To upgrade the release, execute the following command, where your customized `myvalues.yaml` contains the Helm values that you want to add or override. If you don't want or don't need to add or override any Helm values, do not provide the --values `myvalues.yaml` argument:

```bash
helm upgrade --namespace <namespace> --name ibm-dba-ums-prod -f myvalues.yaml ibm-dba-ums-prod --reuse-values --tls
```
**Important**: If the release upgrade also includes a new Helm chart version, do not pass the `--reuse-values` argument.

**Limitation**: Helm upgrade is only available on the Helm command line.

## Rollback the Chart

You can roll back the Helm release to a previous revision.

To retrieve the release upgrade history, execute the following command:
```bash
helm history ibm-dba-ums-prod
```
To roll back the current release to a previous version, execute the following helm command where `<REVISION>` is the upgrade revision from the release upgrade history:

```bash
helm rollback ibm-dba-ums-prod <REVISION> --tls
```
**Limitation**: Helm rollback is only available on the Helm command line.

### Uninstalling the Chart

To uninstall/delete the ibm-dba-ums-prod deployment:

```bash
helm delete ibm-dba-ums-prod --purge --tls
```

## Documentation

For more details, consult the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_19.0.x/com.ibm.dba.offerings/topics/con_ums.html)
