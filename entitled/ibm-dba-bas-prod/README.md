# IBM-DBA-BAS-PROD

IBM Business Automation Studio

## Introduction

This Business Automation Studio Helm chart deploys an IBM Business Automation Studio environment for authoring and managing applications (apps) for the IBM Cloud Pak for Automation platform.

## Chart Details

This chart deploys several services and components.

In the standard configuration, it includes these components:

* IBM Resource Registry component
* IBM Business Automation Application Engine (App Engine) component
* IBM Business Automation Studio component

To support those components for a standard installation, it generates:

* 4 ConfigMaps that manage the configuration of Business Automation Studio server
* 2 deployments running the Business Automation Studio server
* 1 StatefulSet running Resource Registry
* 4 or more jobs for Business Automation Studio and Resource Registry
* 3 service accounts with related roles and role bindings
* 3 secrets to get access during chart installation
* 5 services to route the traffic to Business Automation Studio server

## Prerequisites

  * [OpenShift 3.11](https://docs.openshift.com/container-platform/3.11/welcome/index.html) or later
  * [Helm and Tiller 2.9.1](https://github.com/helm/helm/releases) or later
  * [Cert Manager 0.8.0](https://cert-manager.readthedocs.io/en/latest/getting-started/install/openshift.html) or later
  * [IBM DB2 11.1.2.2](https://www.ibm.com/products/db2-database) or later
  * [IBM Cloud Pack For Automation - User Management Service](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.offerings/topics/con_ums.html)
  * Persistent volume support

### Prepare the environment

1. Log in to OC (the OpenShift command line interface (CLI)) by running the following command. You are prompted for the password.

  ``` 
    oc login <OpenShift-URL> -u <username>
  ``` 

2. Create a project (namespace) for App Engine by running the following command:

    ```
    oc new-project <namespace> 
    ```

3. Save and exit.

4. To deploy the service account, role, and role binding successfully, assign the administrator role to the user for this namespace by running the following command:

  ```
  oc project <project-name>
  oc adm policy add-role-to-user admin <deploy-user-name>
  ```

5. If you want to operate persistent volumes (PVs), you must have the storage-admin cluster role, because PVs are a cluster resource in OpenShift. Add the role by running the following command:

  ```
  oc adm policy add-cluster-role-to-user storage-admin <deploy-user-name>
  ```

### Database Requirements

You must create two databases for the installation.

#### 1. Database for App Engine
App Engine requires a database server. The workload validates the setup of the database and the required tables and indexes during startup. DB2 is supported. To create the database, run the following command:
```
db2 create db APPDB
```

#### 2. Database for Business Automation Studio
Create the database for Business Automation Studio by running the following script:
```sql
create database <DBName> automatic storage yes  using codeset UTF-8 territory US pagesize 32768;

-- connect to the created database:
connect to <DBName>;

-- A user temporary tablespace is required to support stored procedures in BPM.
CREATE USER TEMPORARY TABLESPACE USRTMPSPC1;

UPDATE DB CFG FOR <DBName> USING LOGFILSIZ 16384 DEFERRED;
UPDATE DB CFG FOR <DBName> USING LOGSECOND 64 IMMEDIATE;

-- The following grant is used for databases without enhanced security.
-- For more information, review the IBM Knowledge Center for Enhancing Security for DB2.
grant dbadm on database to user <USER_NAME>;

connect reset;
```

* Replace `<DBName>`  with the name you want, for example, BPMDB.
* Replace `<USER_NAME>` with the user name you will use for the database.

### Protecting sensitive configuration data

You must create the following secrets manually before you install the chart.

Resource Registry:

```yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: resource-registry-admin-secret
  type: Opaque
  stringData:
    rootPassword: "passw0rd"
    readUser: "reader"
    readPassword: "readerpwd"
    writeUser: "writer"
    writePassword: "writerpwd"
```

App Engine:

```yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: ae-secret-credential
  type: Opaque
  stringData:
    AE_DATABASE_PWD: <Your AE database password>
    AE_DATABASE_USER: <Your AE database username>
    OPENID_CLIENT_ID: "<OIDC ID for App Engine sample: ae-client-id>"
    OPENID_CLIENT_SECRET: "<OIDC password for App Engine sample: ae-client-secret>"
    SESSION_SECRET: "bigblue123solutionserver"
    SESSION_COOKIE_NAME: "nsessionid"
    REDIS_PASSWORD: "password"
```

Business Automation Studio:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: bastudio-admin-secret
type: Opaque
stringData:
  adminUser: "<Your BAStudio admin username>"
  adminPassword: "<Your BAStudio admin password>"
  sslKeystorePassword: "change-it-to-any-password"
  dbUsername: "<Your BAStudio database username>"
  dbPassword: "<Your BAStudio database password>"
  oidcClientId: "<OIDC ID for BAStudio sample: bastudio-client-id>"
  oidcClientSecret: "<OIDC password for BAStudio sample: bastudio-client-secret>"
```

Update the values with your user name and secrets.

### Configuring the secret for pulling Docker images

If you're pulling Docker images from a private registry, you must provide a secret containing credentials for it. For instructions, see the [Kubernetes information about private registries](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line). 

This command can be used for one repository only. If your Docker images come from different repositories, you can create multiple image pull secrets and add the names in global.imagePullSecrets. Or you can create secrets by using the custom docker config file.

The following sample shows the Docker auth file `config.json`:

```
{
  "auths": {
    "url1.xx.xx.xx.xx": {
      "auth": "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    },
    "url2.xx.xx.xx.xx": {
      "auth": "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    },
    "url3.xx.xx.xx.xx": {
      "auth": "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    },
    "url4.xx.xx.xx.xx": {
      "auth": "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    }
  }
}
```

The key under auths is the link to the Docker repository, and the value inside that repository name is the authentication string that is used for that repository. You can create the auth string with base64 by running the following command:

```
  # echo -n <username>:<password> | base64
```

You can replace the auth string by running the previous command with your config.json file. Then, create the image pull secret by running the following command:

```
  kubectl create secret generic image-pull-secret --from-file=.dockerconfigjson=<path to config.json> --type=kubernetes.io/dockerconfigjson
```


### Configuring TLS key and certificate secrets

To ensure internal communication is secure, you must provide a Transport Layer Security (TLS) secret. If you intend to deploy the App Engine Helm chart in an environment with services that rely on it, make sure the certificate is signed by a trusted Certificate Authority (CA). You can use [`cert-manager`](https://docs.cert-manager.io/en/latest/) or generate the key and certification manually using SSL tools. The following example uses cert-manager.

1. Generate a root CA.
   - a. Generate a self-signed issuer to issue a self-signed CA.

```yaml
  apiVersion: certmanager.k8s.io/v1alpha1
  kind: Issuer
  metadata:
    name: self-signed-issuer
  spec:
    selfSigned: {}
```
   - b. Create the CA certificate to generate the CA key pair and certificate.
    
```yaml
  apiVersion: certmanager.k8s.io/v1alpha1
  kind: Certificate
  metadata:
    name: ca-tls-certificate
  spec:
    # name of the tls secret to store
    # the generated certificate/key pair
    secretName: ca-tls-secret
    isCA: true
    issuerRef:
      name: self-signed-issuer
      kind: Issuer
    commonName: "rootCA"
```
   - c. Generate the CA issuer to sign other components' certificates.

```yaml
  apiVersion: certmanager.k8s.io/v1alpha1
  kind: Issuer
  metadata:
    name: ca-tls-issuer
  spec:
    ca:
      # The ca tls secret name generated in above definition
      secretName: ca-tls-secret
```

2. Generate the Resource Registry TLS key and certificate.

The Resource Registry is exposed by NodePort, so the certificate should contain all possible IPs included in this cluster. Within the pod, the server is configured with localhost. Include localhost in alternative names.

```yaml
  apiVersion: certmanager.k8s.io/v1alpha1
  kind: Certificate
  metadata:
    name: rr-service-tls-certificate
  spec:
    # name of the tls secret to store
    # the generated certificate/key pair
    secretName: rr-service-tls-secret
    issuerRef:
      name: ca-tls-issuer
      kind: Issuer
    # Usually we will fill the proxy node hostname
    # or IP with nip.io here
    commonName: "rr.<proxy_node_ip>.nip.io"
    dnsNames:
    - "rr.<proxy_node_ip>.nip.io"
    # This entry is used by init process.
    - "localhost"
    ipAddresses:
    - "<proxy_node_ip>"
    - "<Other_node_ips>"
```

3. Generate the App Engine TLS server key and certificate.

```yaml
  apiVersion: certmanager.k8s.io/v1alpha1
  kind: Certificate
  metadata:
    name: ae-ingress-tls-certificate
  spec:
    # name of the tls secret to store
    # the generated certificate/key pair
    secretName: ae-ingress-tls-secret
    issuerRef:
      name: ca-tls-issuer
      kind: Issuer
    # The IP used here is for proxy server
    # The common name should be same as the ingress host value
    commonName: "ae.<proxy_node_ip>.nip.io"
    dnsNames:
    - "ae.<proxy_node_ip>.nip.io"
    - "*"
```

4. Generate the Business Automation Studio TLS server key and certificate.

```yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: bastudio-ingress-tls-certificate
spec:
  # name of the tls secret to store
  # the generated certificate/key pair
  secretName: bastudio-ingress-tls-secret
  issuerRef:
    name: ca-tls-issuer
    kind: Issuer
  # The IP used here is for proxy server.
  # The common name should be same as the ingress host value
  commonName: "bastudio.<proxy_node_ip>.nip.io"
  dnsNames:
  # You can include the UMS service name and full dns name here
  - "<release-name>-bastudio-service"
  - "<release-name>-bastudio-service.<name_space>.svc.cluster.local"
```

You must update the value in `<>` with the value you use. For example, if you install the chart with base as the release name, the service name is base-ibm-dba-ae-service.

### Preparing UMS-related configuration and TLS certificates (optional)

You must do this configuration if you have an existing UMS that is in a different namespace from the Business Automation Studio Helm chart.

Create the UMS secret to store the UMS administrator user name and password, then fill in the `value global.ums.adminSecretName` in the configuration.

```yaml
  apiVersion: v1
  kind: Secret
  metadata:
    name: ibm-dba-ums-secret
  type: Opaque
  stringData:
    adminUser: "umsadmin"
    adminPassword: "password"
```

If the UMS certificate is not signed by the same root CA, you must add the root CA as trusted instead of the UMS certificate. You can save the root CA certificate file as ums-cert.crt, then create the secret by running the following command:

    ```
      kubectl create secret generic ums-tls-crt-secret --from-file=tls.crt=./ums-cert.crt
    ```

You will get a secret named ums-tls-crt-secret. Enter this secret value in every TLS section for Business Automation Studio, Resource Registry, and App Engine. The components will trust this certificate and communicate with UMS successfully.

  ```
    tls:
        tlsSecretName: <Your component tls secret>
        tlsTrustList:
        - ums-tls-crt-secret
   ```

## Implementing storage

This chart requires an existing persistent volume of any type. The minimum supported size is 1GB. Additionally, a persistent volume claim must be created and referenced in the configuration.

### Persistent volume for JDBC Drivers (optional)

If you don't create this persistent volume and related claim, leave `global.existingClaimName` empty. And set `appengine.useCustomJDBCDrivers` to `false`.

The persistent volume should be shareable by pods across the whole cluster. For a single-node Kubernetes cluster, you can use HostPath to create it. For multiple nodes in a cluster, use shareable storage, such as NFS or GlusterFS, for the persistent volume. It must be passed in the values.yaml files (see the global.existingClaimName property in the configuration).

The following example shows the HostPath type of persistent volume.

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: jdbc-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mnt/data"
```

The following example shows the NFS type of persistent volume.

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: jdbc-pv-volume
  labels:
    type: nfs
spec:
  storageClassName: manual
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
  nfs:
    path: /tmp
    server: 172.17.0.2
```

After you create a persistent volume, you can create a persistent volume claim to bind the correct persistent volume with the selector. Or, if you are using GlusterFS with dynamic allocation, create the persistent volume claim with the correct storageClassName to allow the persistent volume to be created automatically.

The following example shows a persistent volume claim.

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: jdbc-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 2Gi
```

The mounted directory must contain a jdbc sub-directory, which in turn holds subdirectories with the required JDBC driver files. Add the following structure to the mounted directory (which in this case is called binaries):

```
/binaries
  /jdbc
    /db2
      /db2jcc4.jar
      /db2jcc_license_cu.jar
```

The /jdbc folder and its contents depend on the configuration. Copy the JDBC driver files to the mounted directory as shown in the previous example. Make sure those files have the correct access. For IBM Cloud Pack for Automation products, on OpenShift an arbitrary UID is used to run the applications, so make sure those files have read access for root(0) group. Enter the persistent volume claim name in the `global.existingClaimName` field.

### Persistent volume for etcd data for Resource Registry (optional)

Without a persistent volume, the Resource Registry cluster might be broken during pod relocation.
If you don't need data persistence for Resource Registry, you can skip this section by setting resourceRegistry.persistence.enabled to false in the configuration. Otherwise, you must create a persistent volume.

The following example shows a persistent volume definition using NFS.

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: etcd-data-volume
  labels:
    type: nfs
spec:
  storageClassName: manual
  capacity:
    storage: 3Gi
  accessModes:
    - ReadWriteOnce
  nfs:
    path: /nfs/general/rrdata
    server: 172.17.0.2
```

You don't need to create a persistent volume claim for Resource Registry. Resource Registry is a StatefulSet, so it creates the persistent volume claim based on the template in the chart. See the [Kubernetes StatefulSets document](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) for more details.

Notes:

* You must give root(0) group read/write access to the mounted directories. Use the following command:

  ```text
  chown -R 50001:0 <directory_path>
  chmod g+rw <directory_path>
  ```

* Each Resource Registry server uses its own persistent volume. Create persistent volumes based on the replicas (resourceRegistry.replicaCount in the configuration).

### Persistent volume for sharing toolkit storage (optional)

If you don't want Business Automation Studio to import the shared toolkit automatically, leave the `global.contributorToolkitsPVC` field  empty.

To integrate contributors, toolkit (twx) files can be imported into Business Application Studio. Place the toolkit package in shared storage and create the persistent volume for that storage by referring to the following example files. Then enter the persistent volume claim name in `global.contributorToolkitsPVC`.

```yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: toolkit-pv-volume
  labels:
    type: nfs
spec:
  storageClassName: toolkit-pv
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteMany
  nfs:
    path: /mptest/toolkit
    server: 9.111.101.131
------------------------    
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: shared-storage-pvc
spec:
  storageClassName: toolkit-pv
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 2Gi
```

Notes:

* You must give root(0) group read/write access to the mounted directories. Use the following command:

  ```text
  chown -R 50001:0 <directory_path>
  chmod g+rw <directory_path>
  ```

### Setting the service type
You can expose the services using Route on OpenShift.

#### On OpenShift
For Business Automation Studio:
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: bastudio-route
spec:
  host: <designed-bastudio-hostname>
  port:
    targetPort: https
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: passthrough
  to:
    kind: Service
    name: <releaseName>-bastudio-service
    weight: 100
  wildcardPolicy: None
```

For App Engine:
```yaml
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: appengine-route
spec:
  host: <designed-appengine-hostname>
  port:
    targetPort: https
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: passthrough
  to:
    kind: Service
    name: <release-name>-ibm-dba-ae-service
    weight: 100
  wildcardPolicy: None
```

### Configure Redis for App Engine (optional)

You can configure the App Engine with Remote Dictionary Server (Redis), which provide more reliable service.

1. Update the Redis host, port and ttl setting in `values.yaml`

    ```yaml
    redis:
      host: <Your redis cluster host IP/name>
      port: <Your redis cluster port>
      ttl: 1800
    ```

2. Set `.Values.appengine.session.useExternalStore` to `true`.
3. If Redis is protected by a password, enter the password in the `REDIS_PASSWORD` field in the `ae-secret-credential` secret that you created in [Protecting sensitive configuration data](#Protecting-sensitive-configuration-data).

4. If you want to protect Redis communication with TLS, you have the following options:

    * Sign the Redis certificate with a well-known CA.
    * Sign the Redis certificate with the same root CA used by this installation.
    * Use a zero depth self-signed certificate or sign the certificate with another root CA. Then save the certificate or root CA in secret. And enter the secret name in `.Values.appengine.tls.tlsTrustList`

## Red Hat OpenShift SecurityContextConstraints Requirements

The predefined SecurityContextConstraints name [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart. If your target namespace is bound to this SecurityContextConstraints resource, you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints definition that can be used to finely control the permissions and capabilities needed to deploy this chart.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints.
  - Custom SecurityContextConstraints definition:
   
   ```yaml
      apiVersion: security.openshift.io/v1
      kind: SecurityContextConstraints
      metadata:
      annotations:
        kubernetes.io/description: "This policy is the most restrictive, 
          requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
          cloudpak.ibm.com/version: "1.0.0"
      name: ibm-dba-bas-scc
      allowHostDirVolumePlugin: false
      allowHostIPC: false
      allowHostNetwork: false
      allowHostPID: false
      allowHostPorts: false
      allowPrivilegedContainer: false
      allowPrivilegeEscalation: false
      allowedCapabilities: []
      allowedFlexVolumes: []
      allowedUnsafeSysctls: []
      defaultAddCapabilities: []
      defaultPrivilegeEscalation: false
      forbiddenSysctls:
        - "*"
      fsGroup:
        type: MustRunAs
        ranges:
          - max: 65535
            min: 1
      readOnlyRootFilesystem: false
      requiredDropCapabilities:
      - ALL
      runAsUser:
        type: MustRunAsNonRoot
      seccompProfiles:
      - docker/default
      seLinuxContext:
        type: RunAsAny
      supplementalGroups:
        type: MustRunAs
        ranges:
        - max: 65535
          min: 1
      volumes:
      - configMap
      - downwardAPI
      - emptyDir
      - persistentVolumeClaim
      - projected
      - secret
      priority: 0
    ```

## Resources Required

Follow the instructions in [Planning Your Installation](https://docs.openshift.com/container-platform/3.11/install/index.html#single-master-single-box). Then, based on your environment, check the required resources in [System and Environment Requirements](https://docs.openshift.com/container-platform/3.11/install/prerequisites.html) and set up your environment.

| Component name | Container | CPU | Memory |
| --- | --- | --- | --- |
| Business Automation Studio | BAStudio container | 2 | 3Gi |
| Business Automation Studio | Init containers | 200m | 128Mi |
| Business Automation Studio | JMS containers | 500m | 512Mi |
| App Engine | App Engine container | 1 | 512Mi |
| App Engine | Init Containers | 200m | 128Mi |
| Resource Registry | Resource Registry container | 200m | 256Mi |
| Resource Registry | Init containers | 200m | 256Mi |

## Installing the Chart

1. To install the chart with release name `my-release`, run the following command:

  ```
  helm install --tls --name my-release ibm-dba-bas-prod -f my-values.yaml --namespace <namespace>`
  ```

  The command deploys `ibm-dba-bas-prod` onto the Kubernetes cluster, based on the values specified in the `my-values.yaml` file. The configuration section lists the parameters that can be configured during installation.

2. Alternatively, to use the Kubernetes command line to install the chart with release name `my-release`

* Run the following command:

  ```
  helm template --name my-release ibm-dba-bas-prod --namespace <namespace> --output-dir ./yamls -f my-values.yaml
  ```

  If the directory `/yamls` does not exist, you can create it by running `mkdir yamls`.

* Customize the yamls directory by running the following commands:

  ```
  rm -rf ./yamls/ibm-dba-bas-prod/charts/appengine/templates/tests
  rm -rf ./yamls/ibm-dba-bas-prod/charts/baStudio/templates/tests
  rm -rf ./yamls/ibm-dba-bas-prod/charts/resourceRegistry/templates/tests
  ```

* Search `runAsUser: 50001` in the generated contents. And delete them all. (This step can be avoid after helm new feature added).

* Apply the customization to the server by running the following command:

    kubectl apply -R -f ./yamls

### Verifying the Chart

1. After the installation is finished, see the instructions for verifying the chart by running the following command: 

    `helm status my-release --tls`

2. Get the name of the pods that were deployed with ibm-dba-bas-prod by running the following command:

    `kubectl get pod -n <namespace>`

3. For each pod, check under Events to see that the images were successfully pulled and the containers were created and started, by running the following command with the specific pod name:

    `kubectl describe pod <pod name> -n <namespace>`

4. Go to `https://<hostname>/BAStudio` in your browser (if you set up Business Automation Studio with Route) or `https://<hostname>:<NodePort>/BAStudio` (if you set up Business Automation Studio with NodePort).

### Uninstalling the Chart
To uninstall and delete the my-release deployment, run the following command:

    helm delete my-release --purge --tls

If you used the Kubernetes command line to create the chart, use the following command to uninstall and delete the my-release deployment:

    kubectl delete -R -f ./yamls

This command removes all the Kubernetes components associated with the chart and deletes the release. If deletion can result in orphaned components, you must delete them manually.

For example, when you delete a release with stateful sets, the associated persistent volume must be deleted. Run the following command after deleting the chart release to clean up orphaned persistent volumes:

    kubectl delete pvc -l release=my-release

## Configuration
 | Parameter                              | Description                                           | Default             |
| -------------------------------------- | ----------------------------------------------------- | ---------------------------------------------------- |
| `global.existingClaimName`             | Existing persistent volume claim name for JDBC and ODBC library |                                                      |
| `global.nonProductionMode`             | Production mode. This value must be false.             | `false`    |
| `global.imagePullSecrets`              | Existing Docker image secret                          | `image-pull-secret`                                                     |
| `global.caSecretName`                  | Existing CA secret                                    | `ca-tls-secret`                                                   |
| `global.dnsBaseName`                   | Kubernetes Domain Name Server (DNS) base name                              | `svc.cluster.local`                                                     |
| `global.contributorToolkitsPVC`        | Persistent volume for contributor toolkits storage         | ``                                            |
| `global.image.keytoolInitcontainer`    | Image name for TLS init container                     | `dba-keytool-initcontainer:19.0.2`                                                     |
| `global.ums.serviceType`               | UMS service type: `NodePort`, `ClusterIP`, or `Ingress`  |                                                      |
| `global.ums.hostname`                  | UMS external host name                                |                                                      |
| `global.ums.port`                      | UMS port (only effective when using NodePort service) |                                                      |
| `global.ums.adminSecretName`                      | Existing UMS administrative secret for sensitive configuration data |                                                      |
| `global.baStudio.serviceType`               | Business Automation Studio service type: `NodePort`, `ClusterIP`, or `Ingress`  |                                                      |
| `global.baStudio.hostname`                  | Business Automation Studio external host name                                |                                                      |
| `global.baStudio.port`                      | Business Automation Studio port (only effective when using NodePort service) |                                                      |
| `global.baStudio.adminSecretName`                      | Business Automation Studio Secret for administration |                                                      |
| `global.baStudio.jmsPersistencePVC`                      | Business Automation Studio JMS persistent volume claim |                                                      |
| `global.resourceRegistry.hostname`     | Resource Registry external host name                  |                                                      |
| `global.resourceRegistry.port`         | Resource Registry port for using NodePort Service      |                                                      |
| `global.resourceRegistry.adminSecretName` | Existing Resource Registry administrative secret for sensitive configuration |                                             |
| `global.appEngine.serviceType`         | App Engine service type: `NodePort`, `ClusterIP`, or `Ingress`  |                                                      |
| `global.appEngine.hostname`            | App Engine external host name                         |                                                      |
| `global.appEngine.port`                | App Engine port (only effective when using NodePort service) |                                                      |
| `baStudio.install`                    | Switch for installing Business Automation Studio                        | `true`                                                     |
| `baStudio.replicaCount`               | Number of deployment replicas                         | `1`                                                  |
| `baStudio.images.baStudio`           | Image name for Business Automation Studio container                   | `20190624-064834.0.linux:19.0.0.1`                                                  |
| `baStudio.images.tlsInitContainer`    | Image name for TLS init container                     | `dba-keytool-initcontainer:19.0.2`     |
| `baStudio.images.ltpaInitContainer`               | Image name for job container      | `dba-keytool-jobcontainer:19.0.2`     |
| `baStudio.images.umsInitRegistration`             | Image name for UMS container        | `dba-umsregistration-initjob:19.0.2` |
| `baStudio.images.jmsContainer` | Image name for JMS container                  | `baw-jms-server:19.0.2`            |
| `baStudio.images.pullPolicy`          | Pull policy for all containers                        | `IfNotPresent`                       |
| `baStudio.tls.tlsSecretName`          | Existing TLS secret containing `tls.key` and `tls.crt`|                                                  |
| `baStudio.tls.tlsTrustList`           | Existing TLS trust secret                             | `[]`                                                  |
| `baStudio.database.name`              | Business Automation Studio database name                              |                                                  |
| `baStudio.database.host`              | Business Automation Studio database host                              |                                                 |
| `baStudio.database.port`              | Business Automation Studio database port                              |                                                 |
| `baStudio.database.type`              | Business Automation Studio database type: `db2`                       |                                                 |
| `baStudio.autoscaling.enabled`       | Enable the Horizontal Pod Autoscaler for Business Automation Studio                       | `false`                                                |
| `baStudio.autoscaling.minReplicas`       | Minimum limit for the number of pods for Business Automation Studio                       | `2`                                                |
| `baStudio.autoscaling.maxReplicas`       | Maximum limit for the number of pods for Business Automation Studio                       | `5`                                                |
| `baStudio.autoscaling.targetAverageUtilization`       | Target average CPU utilization over all the pods for Business Automation Studio                       | `80`                                                |
| `baStudio.contentSecurityPolicy`       | ContentSecurityPolicy for Business Automation Studio                       | `upgrade-insecure-requests`                                                |
| `baStudio.resources.bastudio.limits.cpu`       |  Maximum amount of CPU that is required for Business Automation Studio             | `4`                                                |
| `baStudio.resources.bastudio.limits.memory`       | Maximum amount of memory that is required for Business Automation Studio                    | `3Gi`                                                |
| `baStudio.resources.bastudio.requests.cpu`       | Minimum amount of CPU that is required for Business Automation Studio                   | `2`                                                |
| `baStudio.resources.bastudio.requests.memory`       | Minimum amount of memory that is required for Business Automation Studio                     | `2Gi`                                                |
| `baStudio.resources.initProcess.limits.cpu`       |  Maximum amount of CPU that is required for Business Automation Studio init processes           | `500m`                                                |
| `baStudio.resources.initProcess.limits.memory`       | Maximum amount of memory that is required for Business Automation Studio init processes                   | `512Mi`                                                |
| `baStudio.resources.initProcess.requests.cpu`       | Minimum amount of CPU that is required for Business Automation Studio init processes                  | `200m`                                                |
| `baStudio.resources.initProcess.requests.memory`       | Minimum amount of memory that is required for Business Automation Studio init processes                    | `256Mi`                                                |
| `baStudio.resources.jms.limits.cpu`       |  Maximum amount of CPU that is required for Business Automation Studio Jms Server            | `1`                                                |
| `baStudio.resources.jms.limits.memory`       | Maximum amount of memory that is required for Business Automation Studio Jms Server                   | `1Gi`                                                |
| `baStudio.resources.jms.requests.cpu`       | Minimum amount of CPU that is required for Business Automation Studio Jms Server                  | `500m`                                                |
| `baStudio.resources.jms.requests.memory`       | Minimum amount of memory that is required for Business Automation Studio Jms Server                    | `512Mi`                                                |
| `appEngine.install`                    | Switch for installing App Engine                        | `true`                                                     |
| `appEngine.replicaCount`               | Number of App Engine deployment replicas                         | `1`                                                  |
| `appEngine.probes.initialDelaySeconds` | Number of seconds after the App Engine container has started before liveness or readiness probes are initiated | `5`                   |
| `appEngine.probes.periodSeconds`       | How often (in seconds) to perform the probe. The default is 10 seconds. Minimum value is 1. | `10`                                                  |
| `appEngine.probes.timeoutSeconds`      | Number of seconds after which the probe times out. The default is 1 second. Minimum value is 1. | `5`                                                  |
| `appEngine.probes.successThreshold`    | Minimum consecutive successes for the probe to be considered successful after failing. Minimum value is 1.   | `5`                                                  |
| `appEngine.probes.failureThreshold`    | When a pod starts and the probe fails, Kubernetes will try failureThreshold times before giving up. Minimum value is 1. | `3`                                                  |
| `appEngine.images.appEngine`           | Image name for App Engine container                   | `solution-server:19.0.2`                                                  |
| `appEngine.images.tlsInitContainer`    | Image name for TLS init container                     | `dba-keytool-initcontainer:19.0.2`     |
| `appEngine.images.dbJob`               | Image name for App Engine database job container      | `solution-server-helmjob-db:19.0.2`     |
| `appEngine.images.oidcJob`             | Image name for OpenID Connect (OIDC) registration job container        | `dba-umsregistration-initjob:19.0.2` |
| `appEngine.images.dbcompatibilityInitContainer` | Image name for database compatibility init container          | `dba-dbcompatibility-initcontainer:19.0.2`            |
| `appEngine.images.pullPolicy`          | Pull policy for all App Engine containers                        | `IfNotPresent`                       |
| `appEngine.tls.tlsSecretName`          | Existing TLS secret containing `tls.key` and `tls.crt`|                                                  |
| `appEngine.tls.tlsTrustList`           | Existing TLS trust secret                             | `[]`                                                  |
| `appEngine.database.name`              | App Engine database name                              |                                                  |
| `appEngine.database.host`              | App Engine database host                              |                                                 |
| `appEngine.database.port`              | App Engine database port                              |                                                 |
| `appEngine.database.type`              | App Engine database type: `db2`                       |                                                 |
| `appEngine.database.currentSchema`     | App Engine database Schema                            |                                                 |
| `appEngine.database.initialPoolSize`   | Initial pool size of the App Engine database      | `1`                                                |
| `appEngine.database.maxPoolSize`       | Maximum pool size of the App Engine database          | `10`                                                |
| `appEngine.database.uvThreadPoolSize`  | UV thread pool size of the App Engine database    | `4`                                                |
| `appEngine.database.maxLRUCacheSize`   | Maximum Least Recently Used (LRU) cache size of the App Engine database     | `1000`                                                |
| `appEngine.database.maxLRUCacheAge`    | Maximum LRU cache age of the App Engine database      | `600000`                                                |
| `appEngine.useCustomJDBCDrivers`       | Toggle for custom JDBC drivers                        | `false`                                                |
| `appEngine.adminSecretName`            | Existing App Engine administrative secret for sensitive configuration data |                                                 |
| `appEngine.logLevel.node`              | Log level for output from the App Engine server    | `trace`                                                |
| `appEngine.logLevel.browser`           | Log level for output from the web browser            | `2`                                                |
| `appEngine.contentSecurityPolicy.enable`| Enables the content security policy for the App Engine  | `false`                                                |
| `appEngine.contentSecurityPolicy.whitelist`|  Configuration of the App Engine content security policy whitelist | `""`                                                |
| `appEngine.session.duration`           | Duration of the session                           | `1800000`                            |
| `appEngine.session.resave`             | Enables session resaves                               | `false`                                                |
| `appEngine.session.rolling`            | Send cookie every time                                | `true`                                                |
| `appEngine.session.saveUninitialized`  | Uninitialized sessions will be saved if checked       | `false`                                                |
| `appEngine.session.useExternalStore`   | Use an external store for storing sessions            | `false`                                                |
| `appEngine.redis.host`                 | Host name of the Redis database that is used by the App Engine |                                            |
| `appEngine.redis.port`                 | Port number of the Redis database that is used by the App Engine |                                                 |
| `appEngine.redis.ttl`                  | Time to live for the Redis database connection that is used by the App Engine |                                                 |
| `appEngine.maxAge.staticAsset`         | Maximum age of a static asset                     | `2592000`                                                |
| `appEngine.maxAge.csrfCookie`          | Maximum age of a Cross-Site Request Forgery (CSRF) cookie                      | `3600000`                                                |
| `appEngine.maxAge.authCookie`          | Maximum age of an authentication cookie           | `900000`                                                |
| `appEngine.env.serverEnvType`          | App Engine server environment type | `development`                                                |
| `appEngine.env.maxSizeLRUCacheRR`      | Maximum size of the LRU cache for the Resource Registry | `1000`                                                |
| `appEngine.resources.ae.limits.cpu`    | Maximum amount of CPU that is required for the App Engine container | `1`                                                |
| `appEngine.resources.ae.limits.memory` | Maximum amount of memory that is required for the App Engine container | `1024Mi`                                                |
| `appEngine.resources.ae.requests.cpu`  | Minimum amount of CPU that is required for the App Engine container    | `500m`                                                |
| `appEngine.resources.ae.requests.memory` | Minimum amount of memory that is required for the App Engine container    | `512Mi`                                                |
| `appEngine.resources.initContainer.limits.cpu`    | Maximum amount of CPU that is required for the App Engine init container | `500m`                                                |
| `appEngine.resources.initContainer.limits.memory` | Maximum amount of memory that is required for the App Engine init container | `256Mi`                                                |
| `appEngine.resources.initContainer.requests.cpu`  | Minimum amount of CPU that is required for the App Engine init container    | `200m`                                                |
| `appEngine.resources.initContainer.requests.memory` | Minimum amount of memory that is required for the App Engine init container    | `128Mi`                                                |
| `appEngine.autoscaling.enabled` | Enable the Horizontal Pod Autoscaler for App Engine init container    | `false`                                                |
| `appEngine.autoscaling.minReplicas` | Minimum limit for the number of pods for the App Engine    | `2`                                                |
| `appEngine.autoscaling.maxReplicas` | Maximum limit for the number of pods for the App Engine    | `5`                                                |
| `appEngine.autoscaling.targetAverageUtilization` | Target average CPU utilization over all the pods for the App Engine init container    | `80`                                                |
| `resourceRegistry.install`             | Switch for installing Resource Registry                  | `true`                                                     |
| `resourceRegistry.images.resourceRegistry` | Image name for Resource Registry container        | `dba-etcd:19.0.2`                                                  |
| `resourceRegistry.images.pullPolicy`   | Pull policy for all containers                        | `IfNotPresent`                       |
| `resourceRegistry.tls.tlsSecretName`   | Existing TLS secret containing `tls.key` and `tls.crt`|                                                  |
| `resourceRegistry.replicaCount`        | Number of etcd nodes in cluster                       | `3`                                                 |
| `resourceRegistry.resources.limits.cpu`    | CPU limit for Resource Registry configuration | `500m`                                                |
| `resourceRegistry.resources.limits.memory` | Memory limit for Resource Registry configuration | `512Mi`                                                |
| `resourceRegistry.resources.requests.cpu`  | Requested CPU for Resource Registry configuration | `200m`                                                |
| `resourceRegistry.resources.requests.memory` | Requested memory for Resource Registry configuration   | `256Mi`                                                |
| `resourceRegistry.persistence.enabled` | Enables this deployment to use persistent volumes     | `false`                                                |
| `resourceRegistry.persistence.useDynamicProvisioning` | Enables dynamic binding of persistent volumes to created persistent volume claims     | `true`                                                |
| `resourceRegistry.persistence.storageClassName` | Storage class name                           |                                                 |
| `resourceRegistry.persistence.accessMode` | Access mode as ReadWriteMany ReadWriteOnce         |                                                 |
| `resourceRegistry.persistence.size`    | Storage size                                          |                                                 |
| `resourceRegistry.livenessProbe.enabled` | Liveness probe configuration enabled                | `true`                                   |
| `resourceRegistry.livenessProbe.initialDelaySeconds` | Number of seconds after the container has started before liveness is initiated | `120`                   |
| `resourceRegistry.livenessProbe.periodSeconds`       | How often (in seconds) to perform the probe         | `10`                                                  |
| `resourceRegistry.livenessProbe.timeoutSeconds`      | Number of seconds after which the probe times out    | `5`                                                  |
| `resourceRegistry.livenessProbe.successThreshold`    | Minimum consecutive successes for the probe to be considered successful after failing. Minimum value is 1.   | `1`                                                  |
| `resourceRegistry.livenessProbe.failureThreshold`    | When a pod starts and the probe fails, Kubernetes will try failureThreshold times before giving up. Minimum value is 1. | `3`                                                  |
| `resourceRegistry.readinessProbe.enabled` | Readiness probe configuration enabled               | `true`                                   |
| `resourceRegistry.readinessProbe.initialDelaySeconds` | Number of seconds after the container has started before readiness is initiated | `15`                   |
| `resourceRegistry.readinessProbe.periodSeconds`       | How often (in seconds) to perform the probe          | `10`                                                  |
| `resourceRegistry.readinessProbe.timeoutSeconds`      | Number of seconds after which the probe times out    | `5`                                                  |
| `resourceRegistry.readinessProbe.successThreshold`    | Minimum consecutive successes for the probe to be considered successful after failing. Minimum value is 1.   | `1`                                                  |
| `resourceRegistry.readinessProbe.failureThreshold`    | When a pod starts and the probe fails, Kubernetes will try failureThreshold times before giving up. Minimum value is 1. | `6`                                                  |
| `resourceRegistry.logLevel`    | Log level of the resource registry server. Available options: `debug` `info` `warn` `error` `panic` `fatal` | `info`                                                  |

## Limitations

* The solution server image only trusts CA due to the limitation of the Node.js server. For example, if external UMS is used and signed with another root CA, you must add the root CA as trusted instead of the UMS certificate.

  * The certificate can be self-signed, or signed by a well-known CA.
  * If you're using a depth zero self-signed certificate, it must be listed as a trusted certificate.
  * If you're using a certificate signed by a self-signed CA, the self-signed CA must be in the trusted list. Using a leaf certificate in the trusted list is not supported.

* The Business Automation Studio components support IBM DB2 only for this release.
* The JMS statefulset doesn't support scale. You must leave the replicate size of JMS statefulset to 1 by default.
* The helm upgrade and rollback operations are supported by helm command line instead of UI.

## Documentation

* [Using the IBM Cloud Pak for Automation](https://www.ibm.com/support/knowledgecenter/en/SSYHZ8_19.0.x/welcome/kc_welcome_dba_distrib.html)
* [Content Security Policy(CSP)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
