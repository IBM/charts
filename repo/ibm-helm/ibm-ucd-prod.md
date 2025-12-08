# IBM DevOps Deploy - Helm Chart

## Introduction

[IBM DevOps Deploy](https://www.ibm.com/cloud/urbancode/deploy) is a tool for automating application deployments through your environments. It is designed to facilitate rapid feedback and continuous delivery in agile development while providing the audit trails, versioning and approvals needed in production.

## Chart Details

* This chart deploys a single server instance of IBM DevOps Deploy that may be scaled to multiple instances.
* The Persistent Volume access modes ReadWriteOnce (RWO) and ReadWriteMany (RWX) are both supported for use with IBM DevOps Deploy server.  However, ReadWriteMany is required to successfully scale to more than one replica/instance of the server.
* Includes two statefulSet workload objects, one for server instances and one for distributed front end instances, and corresponding services for them.
* Support has been validated on OpenShift clusters running onPrem, in IBM Satellite, and IBM ROKS.

## Prerequisites

1. Kubernetes 1.19.0+/OpenShift 4.12.0+; kubectl and oc CLI; Helm 3;
  * Install and setup oc/kubectl CLI depending on your architecture.
    * [ppc64le](https://mirror.openshift.com/pub/openshift-v4/ppc64le/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [s390x](https://mirror.openshift.com/pub/openshift-v4/s390x/clients/ocp/stable/openshift-client-linux.tar.gz)
    * [x86_64](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz)
  * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Image and Helm Chart - The DevOps Deploy server image and helm chart can be accessed via the Entitled Registry and public Helm repository.
  * The public Helm chart repository can be accessed at https://github.com/IBM/charts/tree/master/repo/ibm-helm and directions for accessing the DevOps Deploy server chart will be discussed later in this README.
  * Get a key to the entitled registry
    * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
    * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
    * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  If the secret is named ibm-entitlement-key it will be used as the default pull secret, no value needs to be specified in the image.secret field.  Once this secret has been created you will specify the secret name as the value for the image.secret parameter in the values.yaml you provide to 'helm install ...'  Note: Secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Deploy into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

```
oc create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password=<EntitlementKey> --docker-server=cp.icr.io
```

3. Database - DevOps Deploy requires a database.  The database may be running in your cluster or on hardware that resides outside of your cluster.  This database  must be configured as described in [Installing the server database](https://www.ibm.com/docs/en/devops-deploy/8.1.0?topic=installing-server-database) before installing the containerized DevOps Deploy server.  The values used to connect to the database are required when installing the DevOps Deploy server.

> **NOTE:** You have the option of automatically installing MySQL V8.0 during deployment of the DevOps Deploy server.  This can be done by specifying the "database.createDatabase: true" in the values.yaml settings used during deployment.  If this setting is specified, then a database will be created using the database name and database username specified in your settings.  The database password will be obtained from the Kubernetes secret object that is used during deployment of the DevOps Deploy server.

4. Secret - A Kubernetes Secret object must be created to store the initial DevOps Deploy server administrator password, the password used to access the database mentioned above, and the password for all keystores used by the DevOps Deploy server.  The name of the secret you create must be specified in the property 'secret.name' in your values.yaml.

* Through the oc/kubectl CLI, create a Secret object in the target namespace.

```bash
oc create secret generic ucd-secrets \
  --from-literal=initpassword=admin \
  --from-literal=dbpassword=MyDbpassword \
  --from-literal=keystorepassword=MyKeystorePassword

```

> **NOTE:** If you need to change the keystorepassword after the initial server deployment, follow the instructions shown here: [Changing Password For Keystore Files](#changing-password-for-keystore-files).

> **NOTE:** If you do not create a Kubernetes Secret object prior to deployment, a secret will be created for you with randomized values for the passwords. The name of the secret will be `<helmReleaseName>-secrets` and will be created in the namespace of the Helm release. Follow the instructions provided in the output of the `helm get notes <helmReleaseName>` command to access the the contents of the auto-generated secret.

5. A PersistentVolume that will hold the appdata directory for the DevOps Deploy server is required.  If your cluster supports dynamic volume provisioning you will not need to manually create a PersistentVolume (PV) or PersistentVolumeClaim (PVC) before installing this chart.  If your cluster does not support dynamic volume provisioning, you will need to either ensure a PV is available or you will need to create one before installing this chart.  You can optionally create the PVC to bind it to a specific PV, or you can let the chart create a PVC and bind to any available PV that meets the required size and storage class.  Sample YAML to create the PV and PVC are provided below.

  * Ensure that the spec.persistentVolumeReclaimPolicy parameter is set to Retain on the application data persistent volume. By default, the value is Delete for dynamically created persistent volumes. Setting the value to Retain ensures that the persistent volume is not freed or deleted if its associated persistent volume claim is deleted.

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
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
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
    - "ReadWriteOnce"
  resources:
    requests:
      storage: 20Gi
  selector:
    matchLabels:
      volume: ucd-appdata-vol
```

  * The following storage options have been tested with IBM DevOps Deploy

    * IBM Block Storage supports the ReadWriteOnce access mode.  ReadWriteMany is not supported.

    * IBM File Storage supports ReadWriteMany which is required for Distributed Front End(DFE).

  * IBM DevOps Deploy requires non-root access to persistent storage. When using IBM File Storage you need to either use one of the IBM provided “gid” file storage classes (ie. ibmc-file-gold-gid) with default group ID 65531 or create your own customized storage class to specify a different group ID. See the information at https://cloud.ibm.com/docs/containers?topic=containers-cs_storage_nonroot for more details.  Once you know the correct group ID, set the persistence.fsGroup property in the values.yaml to that group ID.

6. JDBC drivers - DevOps Deploy is not packaged with the required JDBC driver(s) needed to access your database instance.  Multiple methods are available to add the required JDBC drivers(s) to your deployment:

* If "fetchDriver" is set to true in values.yaml, then the latest available JDBC driver version will be automatically downloaded for you from a maven repository based on the database type that you specified.  You also have the option of specifying the specific driverVersion that you wish to have downloaded if the latest version is not compatible with the database that is being used.

* If you want to download the JDBC driver(s) from a location that you define and you are using Dynamic Volume Provisioning to create the persistent storage that DevOps Deploy requires, then you can create a Kubernetes ConfigMap resource to copy the JDBC driver(s) to your PV during the chart installation process.  First write a bash script that copies the JDBC driver(s) from a location accessible from your cluster to `${UCD_HOME}/ext_lib/`. Next, store the script, named `script.sh`, in a yaml file describing a [ConfigMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/).  Finally, create the ConfigMap in your cluster by running a command such as `oc create configmap <map-name> <data-source>`.  Below is an example ConfigMap yaml file that copies a MySQL .jar file from a web server using wget.

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
      wget -L -O mysql-jdbc.jar http://webserver-example/mysql-jdbc.jar
      mv mysql-jdbc.jar ${UCD_HOME}/ext_lib/
      echo "Done copying."
    else
      echo "File ${UCD_HOME}/ext_lib/mysql-jdbc.jar already exists."
    fi
```
* If you statically provision the persistent storage required by DevOps Deploy server to hold the appdata directory, then you can create a "ext_lib" subdirectory in that preallocated storage and copy the required JDBC driver(s) into that location prior to installing the server.

7.  If a route or ingress is used to access the WSS port of the DevOps Deploy server from an DevOps Deploy agent, then port 443 should be specified along with the configured URL to access the proper service port defined for the DevOps Deploy Server.

### SecurityContextConstraints Requirements

This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation.  The default `SecurityContextConstraints` named restricted has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

  * Custom SecurityContextConstraints definition:

  ```yaml
  apiVersion: security.openshift.io/v1
  kind: SecurityContextConstraints
  allowHostDirVolumePlugin: false
  allowHostIPC: false
  allowHostNetwork: false
  allowHostPID: false
  allowHostPorts: false
  allowPrivilegeEscalation: false
  allowPrivilegedContainer: false
  allowedCapabilities: null
  defaultAddCapabilities: null
  fsGroup:
    type: MustRunAs
  metadata:
    annotations:
      kubernetes.io/description: restricted denies access to all host features and requires
        pods to be run with a UID, and SELinux context that are allocated to the namespace.  This
        is the most restrictive SCC and it is used by default for authenticated users.
    name: ucd-restricted
  priority: null
  readOnlyRootFilesystem: false
  requiredDropCapabilities:
  - ALL
  runAsUser:
    type: MustRunAsRange
  seLinuxContext:
    type: MustRunAs
  supplementalGroups:
    type: RunAsAny
  users: []
  volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
  ```

### Licensing Requirements

The DevOps Deploy server image will attempt to upload DevOps Deploy license metrics(agent high-water mark) to the IBM Lcense service. For the upload to be successful, this chart needs IBM Licensing operator (a component of IBM Foundational/Common Services) to be installed in the Openshift cluster. Please follow these [instructions](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.6?topic=service-installing-license) to install IBM License service.

Once the IBM License service is installed, you need to copy the license service upload secret(ibm-licensing-upload-token) and configmap(ibm-licensing-upload-config) to the namespace/project the DevOps Deploy server will be installed in. Be sure that the current namespace/project is the one that DevOps Deploy will be installed into, before running the following commands.

```bash
oc get secret ibm-licensing-upload-token -n ibm-licensing -o yaml | sed 's/^.*namespace: ibm-licensing.*$//' | oc create -f -
oc get configMap ibm-licensing-upload-config -n ibm-licensing -o yaml | sed 's/^.*namespace: ibm-licensing.*$//' | oc create -f -

```

Once the Deploy server has started emitting license metrics to the IBM License service (this can take up to 24 hours), you can retrieve license usage data by following these [instructions](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.6?topic=data-per-cluster-from-license-service).

## Resources Required

* 4GB of RAM, plus 4MB of RAM for each agent
* 2 CPU cores, plus 2 cores for each 500 agents

## Client Data Storage Locations

All client data is stored in either the user specified database or the appdata persistent volume.  DevOps Deploy does not do any active encryption of these data locations.  These locations should be included in whatever backup plans the user chooses to implement.

## Installing the Chart

Add the IBM helm chart repository to the local client.
```bash
$ helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/
```

Get a copy of the values.yaml file from the helm chart so you can update it with values used by the install.
```bash
$ helm inspect values ibm-helm/ibm-ucd-prod > myvalues.yaml
```

Edit the file myvalues.yaml to specify the parameter values to use when installing the DevOps Deploy server instance.  The [configuration](#Configuration) section lists the parameter values that can be set.

To install the chart into namespace 'deploytest' with the release name `my-deploy-release` and use the values from myvalues.yaml:

```bash
$ helm install my-deploy-release ibm-helm/ibm-ucd-prod --namespace deploytest --values myvalues.yaml
```

> **Tip**: List all releases using `helm list`.

## Verifying the Chart

See the instructions (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-deploy-release

## Upgrading the Chart

Check [here](https://community.ibm.com/community/user/wasdevops/blogs/laurel-dickson-bull1/2022/07/08/container-upgrade) for information about ugrading the chart.

## Uninstalling the Chart

To uninstall/delete the `my-deploy-release` release:

```bash
$ helm delete my-deploy-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Changing Password For Keystore Files

To change the password used by the DevOps Deploy Server keystore files, follow these steps:

1. Scale the statefulset resource to 0 to shutdown the DevOps Deploy server.

2. Update the Kubernetes secret used to define the server passwords to set the **keystorepassword** to the new value.

3. **IMPORTANT:** Update the Kubernetes secret used to define the server passwords to set the **previouskeystorepassword** to the existing keystore password being used.

4. Scale the statefulset resource to 1 to restart the DevOps Deploy server.

5. When the server is restarted, the keystore passwords will be updated to the new value during pod initialization.

## Disaster Recovery

Backup product data and essential Kubernetes resources so that you can recover your DevOps Deploy server instance after a disaster.

### Backup Kubernetes Resources

Backup the Kubernetes resoures required to redeploy the DevOps Deploy server after a disaster.  Follow these steps to save the configuration of essential Kubernetes resources.

1. Save Helm values
   Run the following command to save a local copy of the Helm values file
```bash
helm get values <Helm-release-name> --namespace <deploy_namespace> --all >savedHelmValues.yaml
```
2. Save secret containing DevOps Deploy server product passwords
   Find the value for the Values.secret.name property in the saved Helm values file above.  If the Values.secret.name is not specified, then use the auto-generated secret named `<helmReleaseName>-secrets`.  This is the name of the secret we want to save a local copy of.  Run the following command, replacing **deploysecrets_name** with the name of the secret that is being used by the DevOps Deploy server install.
```bash
oc get secret <deploysecrets_name> -n <deploy_namespace> -o yaml > <deploysecrets_name>.yaml
```
3. Save image pull secret
   Find the value for the Values.image.secret property in the saved Helm values file above.  This is the name of the secret used to pull images from the IBM Entitled Registry.  Run the following command, replacing **ibm-entitlement-key** with the value from the Values.image.secret property.
```bash
oc get secret <ibm-entitlement-key> -n <deploy_namespace> -o yaml > <ibm-entitlement-key>.yaml
```
4. Save ext-lib configmap
   If a configmap was used to load the JDBC driver file into the ext-lib Persistent Volume, you will need to save a local copy of it.
   Find the value for the Values.extLibVolume.configMapName property in the saved Helm values file above.
   Run the following command, replacing **configMapName** with the value from the Values.extLibVolume.configMapName property.
```bash
oc get configmap <configMapName> -n <deploy_namespace> -o yaml > <configMapName>.yaml
```

### Backup Product Data

Backup the database and appdata directory used by the DevOps Deploy server.  To ensure the most accurate saving of data, no deployments should be active.  Follow these steps to take a backup of the server.

1. Scale the statefulset resource to 0 to shutdown the DevOps Deploy server.
2. Create a full backup of the database.  For instructions on backing up the database, see the documentation from your database vendor.
3. Backup the appdata Persistent Volume.
4. Backup the ext-lib Persistent Volume (if created).
5. Scale the statefulset resource to 1 to restart the DevOps Deploy server.

### Recover from a disaster

If you have successfully backed up the resources and data as described in [Backup Kubernetes Resources](#backup-kubernetes-resources) and [Backup Product Data](#backup-product-data) you can recreate an instance of DevOps Deploy server using that data.  Follow these steps to recreate your DevOps Deploy server instance.

1. Create a new project/namespace to hold the Kubernetes resources associated with the DevOps Deploy server instance.
2. Create the Kubernetes secret that contains the DevOps Deploy server product passwords by running the following command.
```bash
oc apply -n <deploy_namespace> -f <deploysecrets_name>.yaml
```
3. Create the image pull secret needed to access images in the IBM Entitled Registry by running the following command.
```bash
oc apply -n <deploy_namespace> -f <ibm-entitlement-key>.yaml
```
4. If your original DevOps Deploy server instance used a configMap resource to load the JDBC driver file into the ext-lib Persistent Volume, then recreate that configMap resource by running the following command.
```bash
oc apply -n <deploy_namespace> -f <configMapName>.yaml
```
If ext-lib Persistent Volume is being used, then create it so that the JDBC driver file can be loaded into it.  Also create a Persistent Volume Claim that references the ext-lib Persistent Volume.  If you are not using a configMap to load the JDBC driver file into the ext-lib Persistent Volume, you will need to manually copy the JDBC driver file into the Persistent Volume.

5. Create the appdata Persistent Volume and associated Persistent Volume Claim and load the saved appdata directory contents into the Persistent Volume.

6. Follow the directions from your database vendor to create a new database from the backup/clone.

7. Create a values.yaml file that contains the properties and values from your savedHelmValues.yaml file.  Be sure that the Values.extLibVolume.existingClaimName and Values.appDataVolume.existingClaimName fields are set to the Persistent Volume Claims for the new ext-lib and appdata Persistent Volumes.  Also be sure that the database fields Values.database.* refer to the new database instance created in the step above.

8. Create the new DevOps Deploy server instance by running the following command.

```bash
helm install my-recovered-release ibm-helm/ibm-ucd-prod --namespace <deploy_namespace> --values myRecoveredValues.yaml
```

## Configuration

### Parameters

The Helm chart has the following values.

##### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| version |  | DevOps Deploy product version | Defaults to latest product version |
| replicas | server | Number of DevOps Deploy server replicas | Non-zero number of replicas.  Defaults to 1 |
|          | dfe | Number of DFE replicas | Number of Distributed Front End replicas.  Defaults to 0 |
| image | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to IfNotPresent |
|       | secret |  An image pull secret used to authenticate with the image registry | If no value is specified we will look for a pull secret named ibm-entitlement-key. |
| service | type | Specify type of service | Valid options are ClusterIP, NodePort and LoadBalancer (for clusters that support LoadBalancer). Default is ClusterIP |
|         | annotations | Annotations for the service | Default value is "" |
|         | loadBalancerClass | https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-class | Default value is "" |
|         | loadBalancerSourceRanges | https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service | Default value is none |
| database | type | The type of database DevOps Deploy will connect to | Valid values are db2, mysql, oracle, and sqlserver.  Default is mysql. This value is ignored if database.createDatabase=true. |
|          | name | The name of the database to use | Default is "deploydb" |
|          | hostname | The hostname/IP of the database server. This value is ignored if database.createDatabase=true. | |
|          | port | The database port to connect to. This value is ignored if database.createDatabase=true. |  |
|          | username | The user to access the database with | Default is "dbuser" |
|          | jdbcConnUrl | The JDBC Connection URL used to connect to the database used by the DevOps Deploy server. This value is normally constructed using the database type and other database field values, but must be specified here when using Oracle RAC/ORAAS or SQL Server with Integrated Security.  If a value is specified here, the other database properties are ignored.| |
|          | fetchDriver | Boolean specifying whether to fetch JDBC driver from well-known location.  Suppported for db2, mysql, oracle, and sqlserver. This setting will be ignored if extLibVolume.configMapName is specified. | Default value true |
|          | driverVersion | Version of JDBC driver to fetch from well-known location.  This value is optional.  If not specified, the latest jdbc driver for the database type will be fetched. | |
|          | createDatabase | Automatically create a MySQL 8.0 Database | Default is false |
|          | dbVolume.storageClassName | If createDatasbase equals "true", specifies the name of the storageclass to use. | |
|          | dbVolume.size | If createDatasbase equals "true", specifies the size of the persistent volume used by the database. | |
| secureConnections  | required | Specify whether DevOps Deploy server connections are required to be secure | Default value is "true" |
|                    | tlsSecret | Name of Kubernetes TLS secret that contains the signed certificate for the Deploy server | |
| secret | name | Kubernetes secret which defines required DevOps Deploy passwords. | You may leave this blank to use default name of HelmReleaseName-secrets where HelmReleaseName is the name of your Helm Release, otherwise specify the secret name here. If name is left blank and HelReleaseName-secrets does not exist in the namepace, then a default secret will be automatically created with randomized values for the passwords. |
| license | accept | Set to true to indicate you have read and agree to license agreements : https://ibm.biz/devops-deploy-license | false |
|  | serverURL | Information required to connect to the DevOps Deploy license server. | Empty (default) to begin a 60-day evaluation license period.|
| statefulset | annotations | Annotations for statefulset | Default value is "" |
|             | topologySpreadConstraints.enabled | Determines if topologySpreadConstraints are defined for the agent statefulset | Default value is false |
|             | topologySpreadConstraints.maxSkew | Describes the degree to which Pods may be unevenly distributed | Default value is 1 |
|             | topologySpreadConstraints.topologyKey | The key of node labels. Nodes that have a label with this key and identical values are considered to be in the same topology. | Default value is "kubernetes.io/arch" |
|             | topologySpreadConstraints.whenUnsatisfiable | Indicates how to deal with a Pod if it doesn't satisfy the spread constraint. | Default value is ScheduleAnyway |
| persistence | enabled | Determines if persistent storage will be used to hold the DevOps Deploy server appdata directory contents. This should always be true to preserve server data on container restarts. | Default value "true" |
|             | useDynamicProvisioning | Set to "true" if the cluster supports dynamic storage provisoning | Default value "false" |
|             | fsGroup | The group ID to use to access persistent volumes | Default value "1001" |
| extLibVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the extlib directory is created by the chart. | Default value is "ext-lib" |
|              | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true" and existingClaimName is empty. |  |
|              | size | Size of the volume used to hold the JDBC driver .jar files. If size is left blank and no existingClaimName is specified, then the extLib peristent volume is not created and the jdbc driver will be saved in the appDataVolume |  |
|              | existingClaimName | Persistent volume claim name for the volume that contains the JDBC driver file(s) used to connect to the DevOps Deploy database. |  |
|              | configMapName | Name of an existing ConfigMap which contains a script named script.sh. This script is run during DevOps Deploy server initialization and is useful for copying database driver .jars to the ext-lib persistent volume. |  |
|              | accessMode | Persistent storage access mode for the ext-lib persistent volume. | ReadWriteOnce |
| appDataVolume | name | The base name used when the Persistent Volume and/or Persistent Volume Claim for the DevOps Deploy server appdata directory is created by the chart. | Default value is "appdata" |
|               | existingClaimName | The name of an existing Persistent Volume Claim that references the Persistent Volume that will be used to hold the DevOps Deploy server appdata directory. |  |
|               | storageClassName | The name of the storage class to use when persistence.useDynamicProvisioning is set to "true" and existingClaimName is empty. |  |
|               | size | Size of the volume to hold the DevOps Deploy server appdata directory | Default is 20Gi |
|              | accessMode | Persistent storage access mode for the appdata persistent volume. | ReadWriteOnce |
| ingress | host | Host name used to access the DevOps Deploy server UI. Leave blank on OpenShift to create default route. |  |
|               | dfehost | Host name used to access the DevOps Deploy server distributed front end (DFE) UI. Leave blank on OpenShift to create default route. |  |
|               | wsshost | Host name used to access the DevOps Deploy server WSS port. Leave blank on OpenShift to create default route. |  |
|               | tlsSecret | Name of Kubernetes TLS secret containing certificate for Edge TLS termination by the ingress/route. | |
| resources | constraints.enabled | Specifies whether the resource constraints specified in this helm chart are enabled.   | true (default) or false  |
|           | limits.cpu  | Describes the maximum amount of CPU allowed | Default is 4000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed | Default is 8Gi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | limits.ephemeral-storage | Describes the maximum amount of ephemeral storage allowed | Default is 2Gi. See Kubernetes - [ephemeral storage](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#setting-requests-and-limits-for-local-ephemeral-storage) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 200m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value | Default is 600Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.ephemeral-storage | Describes the minimum amount of ephemeral storage required. If not specified, the amount will default to the limit (if specified) or the implementation-defined value  | Default is 500Mi. See Kubernetes - [ephemeral storage](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#setting-requests-and-limits-for-local-ephemeral-storage) |
| javaContainerOptions | activeProcessorCount | JVM argument used to explicitly specify the number of CPU cores that the Java Virtual Machine (JVM) should consider as available. | Default is 2 |
|                      | maxRAMPercentage | Allows the Java Virtual Machine (JVM) to automatically determine the maximum heap size as a percentage of the container's allocated memory limit, rather than the total physical RAM of the host system. | Default is 70 |
| readinessProbe | initialDelaySeconds | Number of seconds after the container has started before the readiness probe is initiated | Default is 30 |
|           | periodSeconds | How often (in seconds) to perform the readiness probe | Default is 30 |
|           | failureThreshold | When a Pod starts and the probe fails, Kubernetes will try this number times before giving up. In the case of the readiness probe, the Pod will be marked Unready. | Default is 10 |
| livenessProbe | initialDelaySeconds | Number of seconds after the container has started before the liveness probe is initiated | Default is 179 |
|           | periodSeconds | How often (in seconds) to perform the liveness probe | Default is 800 |
|           | failureThreshold | When a Pod starts and the probe fails, Kubernetes will try this number times before giving up. Giving up in the case of the liveness probe means restarting the Pod. | Default is 3 |

## Storage
See the Prerequisites section of this page for storage information.

## Limitations

The Apache Derby database type is not supported when running the DevOps Deploy server in a Kubernetes cluster. This is because the containerized version is running in DevOps Deploy HA mode, which does not support Derby.
