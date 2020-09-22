# IBM UrbanCode Deploy - Helm Chart

## Introduction

[UrbanCode Deploy](https://www.urbancode.com/product/deploy/) is a tool for automating application deployments through your environments. It is designed to facilitate rapid feedback and continuous delivery in agile development while providing the audit trails, versioning and approvals needed in production.

## Chart Details

* This chart deploys a single server instance of IBM UrbanCode Deploy that may be scaled to multiple instances.
* Includes two statefulSet workload objects, one for server instances and one for distributed front end instances, and corresponding services for them.

## Prerequisites

1. Kubernetes 1.11.0+; kubectl and oc CLI; Helm 3; 
* [Install and setup oc/kubectl CLI](https://docs.okd.io/latest/cli_reference/get_started_cli.html#installing-the-cli)
* [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Image and Helm Chart - The UCD server image and helm chart can be accessed via the Entitled Registry and public Helm repository.
* Entitled Registry
    * The public Helm chart repository can be accessed at https://github.com/IBM/charts/tree/master/repo/ibm-helm and directions for accessing the UrbanCode Deploy server chart will be discussed later in this README.
    * Get a key to the entitled registry
        * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
        * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
        * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  Once this secret has been created you will specify the secret name as the value for the image.secret parameter in the values.yaml you provide to 'helm install ...'  Note: Secrets are namespace scoped, so they must be created in every namespace you plan to install UCD into.  Example Docker registry secret to access Entitled Registry with an Entitlement key. 

```
oc create secret docker-registry entitledregistry-secret --docker-username=cp --docker-password=<EntitlementKey> --docker-server=cp.icr.io
```

3. Database - UrbanCode Deploy requires a database.  The database may be running in your cluster or outside of your cluster.  This database  must be configured as described in [Installing the server database](https://www.ibm.com/support/knowledgecenter/SS4GSP_7.0.5/com.ibm.udeploy.install.doc/topics/DBinstall.html) before installing this Helm chart.  The database parameters used to connect to the database are required properties of this Helm chart.  The Apache Derby database type is not supported when running the UrbanCode Deploy server in a Kubernetes cluster.

4. Secret - A Kubernetes Secret object must be created to store the initial UCD administrator password, the password used to access the database mentioned above, and the password for all keystores used by the product.  These passwords are retrieved during Helm chart installation.  The secret can be named 'HelmReleaseName-secrets' where 'HelmReleaseName' is the release name you give when installing this Helm chart or you can create a secret with any name and pass the name as the Helm Chart parameter value 'secret.name'.

* Through the oc/kubectl CLI, create a Secret object in the target namespace.
    Generate the base64 encoded values for the initial UCD admin password, database password, and the password for all keystores used by the product.

```
echo -n 'admin' | base64
YWRtaW4=
echo -n 'MyDbpassword' | base64
TXlEYnBhc3N3b3Jk
echo -n 'MyKeystorePassword' | base64
TXlLZXlzdG9yZVBhc3N3b3Jk
```

Create a file named secret.yaml with the following contents, using your Helm Relese name and base64 encoded values.

```
apiVersion: v1
kind: Secret
metadata:
  name: MyRelease-secrets
type: Opaque
data:
  initpassword: YWRtaW4=
  dbpassword: TXlEYnBhc3N3b3Jk
  keystorepassword: TXlLZXlzdG9yZVBhc3N3b3Jk
```

Create the Secret using oc apply

```
oc apply -f ./secret.yaml
```

Delete or shred the secret.yaml file.

5. JDBC drivers - A PersistentVolume (PV) that contains the JDBC driver(s) required to connect to the database configured above must be created.  You must either:

  * Create Persistence Storage Volume - Create a PV, copy the JDBC drivers to the PV, and create a PersistentVolumeClaim (PVC) that is bound to the PV. For more information on Persistent Volumes and Persistent Volume Claims, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes). Sample YAML to create the PV and PVC are provided below.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ucd-ext-lib
  labels:
    volume: ucd-ext-lib-vol
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadOnlyMany
  nfs:
    server: 192.168.1.17
    path: /volume1/k8/ucd-ext-lib
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ucd-ext-lib-volc
spec:
  storageClassName: ""
  accessModes:
    - "ReadOnlyMany"
  resources:
    requests:
      storage: 1Gi
  selector:
    matchLabels:
      volume: ucd-ext-lib-vol
```
  * Dynamic Volume Provisioning - If your cluster supports [dynamic volume provisioning](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/), you may use it to create the PV and PVC. However, the JDBC drivers will still need to be copied to the PV. To copy the JDBC drivers to your PV during the chart installation process, first write a bash script that copies the JDBC drivers from a location accessible from your cluster to `${UCD_HOME}/ext_lib/`. Next, store the script, named `script.sh`, in a yaml file describing a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/).  Finally, create the ConfigMap in your cluster by running a command such as `oc create configmap <map-name> <data-source>`.  Below is an example ConfigMap yaml file that copies a MySQL .jar file from a web server using wget.

```
kind: ConfigMap
apiVersion: v1
metadata:
  name: user-script
data:
  script.sh: |
    #!/bin/bash
    echo "Running script.sh..."
    if [ ! -f ${UCD_HOME}/ext_lib/mysql-jdbc.jar ] ; then
      echo "Copying file(s)..."    
      wget http://hostname/ucd-extlib/mysql-jdbc.jar
      mv mysql-jdbc.jar ${UCD_HOME}/ext_lib/
      echo "Done copying."
    else
      echo "File ${UCD_HOME}/ext_lib/mysql-jdbc.jar already exists."
    fi
```
Note the script must be named `script.sh`.

Additionally, you may manually create a PersistentVolume/PersistentVolumeClaim and use a script contained in a ConfigMap to copy drivers into the PersistentVolume.

Example setup scripts to create the Persistent Volume, Persistent Volume Claim and configMap are included in the Helm chart under pak_extensions/pre-install/persistentStorageAdministration directory.

6. A PersistentVolume that will hold the appdata directory for the UrbanCode Deploy server is required.  If your cluster supports dynamic volume provisioning you will not need to create a PersistentVolume (PV) or PersistentVolumeClaim (PVC) before installing this chart.  If your cluster does not support dynamic volume provisioing, you will need to either ensure a PV is available or you will need to create one before installing this chart.  You can optionally create the PVC to bind it to a specific PV, or you can let the chart create a PVC and bind to any available PV that meets the required size and storage class.  Sample YAML to create the PV and PVC are provided below.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ucd-appdata-vol
  labels:
    volume: ucd-appdata-vol
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 192.168.1.17
    path: /volume1/k8/ucd-appdata
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ucd-appdata-volc
spec:
  storageClassName: ""
  accessModes:
    - "ReadWriteMany"
  resources:
    requests:
      storage: 20Gi
  selector:
    matchLabels:
      volume: ucd-appdata-vol
```

Example setup scripts to create the Persistent Volume and Persistent Volume Claim are included in the Helm chart under pak_extensions/pre-install/persistentStorageAdministration directory.

Following storage options have been tested with IBM UrbanCode Deploy

### IBM Block Storage

Supports IBM Block storage with ReadWriteOnce access mode. ReadWriteMany is not supported for this storage.

### IBM File Storage

IBM File Storage storage supports ReadWriteMany which is required for Distributed Front End(DFE). 

IBM UrbanCode Deploy requires non-root access to persistent storage. You need to either use the IBM provided “gid” File storage class with default group ID 65531 or create your own customized storage class to specify a different group ID. Please follow the below IBM Cloud document for more details.
https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot_storage#cs_storage_nonroot

Then you can use either one of the storage class to create a PersistentVolumeClaim for ext-lib and appdata with non-root access. Specify the names of those in values.yaml file to use in installing UCD server.

7.  If ingress controller is used to access the wss port from an UrbanCode Deploy Agent or the jms port from an UrbanCode Deploy Agent Relay, then port 443 should be specified along with the configured host name to access the proper service port defined for the UrbanCode Deploy Server.

### PodSecurityPolicy Requirements

If you are running on OpenShift, skip this section and continue to the [SecurityContextConstraints Requirements](#securitycontextconstraints-requirements) section below.

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you.

The predefined PodSecurityPolicy named [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the Cluster Console user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

* From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  * Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is based on the most restrictive policy,
        requiring pods to run with a non-root UID, and preventing pods from accessing the host."
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
      name: ibm-ucd-prod-psp
    spec:
      allowPrivilegeEscalation: false
      forbiddenSysctls:
      - '*'
      fsGroup:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      hostNetwork: false
      hostPID: false
      hostIPC: false
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
  * Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-ucd-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-ucd-prod-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
  * RoleBinding for all service accounts in the current namespace. Replace `{{ NAMESPACE }}` in the template with the actual namespace.
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: ibm-ucd-prod-rolebinding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ibm-ucd-prod-clusterrole
    subjects:
    - apiGroup: rbac.authorization.k8s.io
      kind: Group
      name: system:serviceaccounts:{{ NAMESPACE }}
    ```
* From the command line, you can run the setup scripts included under pak_extensions.

  As a cluster administrator, the pre-install scripts and instructions are located at:
  * pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin/operator the namespace scoped scripts and instructions are located at:
  * pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

### SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

This chart defines a custom `SecurityContextConstraints` which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom `SecurityContextConstraints` resource using the supplied instructions or scripts in the `pak_extensions/pre-install` directory.

* From the user interface, you can copy and paste the following snippets to enable the custom `SecurityContextConstraints`
  * Custom SecurityContextConstraints definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  metadata:
    annotations:
    name: ibm-ucd-prod-scc
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegedContainer: false
  allowedCapabilities: []
  allowedFlexVolumes: []
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

* From the command line, you can run the setup scripts included under `pak_extensions/pre-install`
  As a cluster admin the pre-install instructions are located at:
  * `pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`

  As team admin the namespace scoped instructions are located at:
  * `pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`


## Resources Required

* 4GB of RAM, plus 4MB of RAM for each agent
* 2 CPU cores, plus 2 cores for each 500 agents

## Installing the Chart

Add the IBM helm chart repository to the local client.
```bash
$ helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/
```

Get a copy of the values.yaml file from the helm chart so you can update it with values used by the install.
```bash
$ helm inspect values ibm-helm/ibm-ucd-prod > myvalues.yaml
```

Edit the file myvalues.yaml to specify the parameter values to use when installing the UCD server instance.  The [configuration](#Configuration) section lists the parameter values that can be set.

To install the chart into namespace 'ucdtest' with the release name `my-ucd-release` and use the values from myvalues.yaml:

```bash
$ helm install --namespace ucdtest --name my-ucd-release --values myvalues.yaml ibm-helm/ibm-ucd-prod
```

> **Tip**: List all releases using `helm list`.

## Verifying the Chart

See the instructions (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-ucd-release --tls.

## Upgrading the Chart

Check [here](https://developer.ibm.com/urbancode/docs/running-urbancode-deploy-container-kubernetes/#upgrading-ucd-chart) for information about ugrading the chart.

## Uninstalling the Chart

To uninstall/delete the `my-ucd-release` release:

```bash
$ helm delete my-ucd-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.


## Configuration

### Parameters

The Helm chart has the following values that can be overriden using the --set parameter.

##### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| image | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to Always |
|       | repository | Name of image, including repository prefix (if required) | See [Extended description of Docker tags](https://docs.docker.com/engine/reference/commandline/tag/#extended-description) |
|       | tag | Docker image tag | See [Docker tag description](https://docs.docker.com/engine/reference/commandline/tag/) |
|       | secret |  An image pull secret used to authenticate with the image registry | Empty (default) if no authentication is required to access the image registry. |
| service | type | Specify type of service | Valid options are NodePort and LoadBalancer (for clusters that support LoadBalancer). Default is NodePort |
| database | type | The type of database UCD will connect to | Valid values are db2, mysql, mariadb, oracle, and sqlserver |
|          | name | The name of the database to use |  |
|          | hostname | The hostname/IP of the database server | |
|          | port | The database port to connect to | |
|          | username | The user to access the database with | |
|          | jdbcConnUrl | The JDBC Connection URL used to connect to the database used by the UCD server. This value is normally constructed using the database type and other database field values, but must be specified here when using Oracle RAC/ORAAS or SQL Server with Integrated Security. | |
| secureConnections  | required | Specify whether UCD server connections are required to be secure | Default value is "true" |
| secret | name | Kubernetes secret which defines required UCD passwords. | You may leave this blank to use default name of 'HelmReleaseName-secrets' where HelmReleaseName is the name of your Helm Release. |
| ucdLicense | serverURL | Information required to connect to the UCD license server. | Empty (default) to begin a 60-day evaluation license period.|
| extLibVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the extlib directory is created by the chart. | Default value is "ext-lib" |
|              | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true". |  |
|              | size | Size of the volume used to hold the JDBC driver .jar files |  |
|              | existingClaimName | Persistent volume claim name for the volume that contains the JDBC driver file(s) used to connect to the UCD database. |  |
|              | configMapName | Name of an existing ConfigMap which contains a script named script.sh. This script is run before UrbanCode Deploy server installation and is useful for copying database driver .jars to a Persistent Volume. |  |
| persistence | enabled | Determines if persistent storage will be used to hold the UCD server appdata directory contents. This should always be true to preserve server data on container restarts. | Default value "true" |
|             | useDynamicProvisioning | Set to "true" if the cluster supports dynamic storage provisoning | Default value "false" |
|             | fsGroup | fsGroup value to use for gid when accessing persistent storage | Default value is "0" |
| appDataVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the UCD server appdata directory is created by the chart. | Default value is "appdata" |
|               | existingClaimName | The name of an existing Persistent Volume Claim that references the Persistent Volume that will be used to hold the UCD server appdata directory. |  |
|               | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true". |  |
|               | size | Size of the volume to hold the UCD server appdata directory |  |
| ingress | host | Hostname used to access UrbanCode Deploy Server admin via Ingress (e.g. application.<proxy node address>.nip.io). | |
|         | dfehost | Hostname used to access UrbanCode Deploy DFE Server admin via Ingress (e.g. application.<proxy node address>.nip.io). | |
|         | wsshost | Hostname used to access UrbanCode Deploy Server wss port via Ingress (e.g. application.<proxy node address>.nip.io:443). See chart readme documentation for more details | |
|         | jmshost | Hostname used to access UrbanCode Deploy Server jms port via Ingress (e.g. application.<proxy node address>.nip.io:443). See chart readme documentation for more details | |
| resources | constraints.enabled | Specifies whether the resource constraints specified in this helm chart are enabled.   | false (default) or true  |
|           | limits.cpu  | Describes the maximum amount of CPU allowed | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed | Default is 2Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value | Default is 1Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|      readinessProbe     | initialDelaySeconds | Number of seconds after the container has started before the readiness probe is initiated | Default is 30 |
|           | periodSeconds | How often (in seconds) to perform the readiness probe | Default is 30 |
|           | failureThreshold | When a Pod starts and the probe fails, Kubernetes will try this number times before giving up. In the case of the readiness probe, the Pod will be marked Unready. | Default is 10 |
|      livenessProbe     | initialDelaySeconds | Number of seconds after the container has started before the liveness probe is initiated | Default is 300 |
|           | periodSeconds | How often (in seconds) to perform the liveness probe | Default is 300 |
|           | failureThreshold | When a Pod starts and the probe fails, Kubernetes will try this number times before giving up. Giving up in the case of the liveness probe means restarting the Pod. | Default is 3 |


## Storage
See the Prerequisites section of this page for storage information.

## Limitations

The Apache Derby database type is not supported when running the UrbanCode Deploy server in a Kubernetes cluster. This is because the containerized version is running in UCD HA mode, which does not support Derby.

