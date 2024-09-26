# **DevOps Plan Helm Chart**

## **Introduction**

[DevOps Plan](httpsibmibm.com/docs/en/devops-plan/3.0.0) is a change management software platform for enterprise level scaling, process customization, and control to accelerate project delivery and increase developer productivity.

## **Chart Details**
- This chart deploys a single instance of DevOps Plan that may be scaled to multiple instances.

## **Product Documentation**

- [DevOps Plan Product Documentation](https://ibm.com/docs/en/devops-plan/3.0.0)

## **Prerequisites**

1. Kubernetes 1.16.0+, OpenShift CLI (oc), and Helm 3.

    * [Install and setup kubectl CLI](https://kubernetes.io/docs/tasks/tools/).

    * [Install and setup OpenShift CLI](https://docs.openshift.com/container-platform/4.14/cli_reference/openshift_cli/getting-started-cli.html)

    * [Install and setup the Helm 3 CLI](https://helm.sh/docs/intro/install/).

2. Image and Helm Chart - The DevOps Plan images, and helm chart can be accessed via the Entitled Registry and public Helm repository.

    * The public Helm chart repository can be accessed at https://github.com/IBM/charts/tree/master/repo/ibm-helm and directions for accessing the DevOps Plan chart will be discussed later in this README.
    * Get a key to the entitled registry
      * Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary) with the IBMid and password that are associated with the entitled software.
      * In the Entitlement keys section, select Copy key to copy the entitlement key to the clipboard.
      * An imagePullSecret must be created to be able to authenticate and pull images from the Entitled Registry.  If the secret is named ibm-entitlement-key it will be used as the default pull secret, no value needs to be specified in the global.imagePullSecret field.  Once this secret has been created you will specify the secret name as the value for the global.imagePullSecret parameter in the values.yaml you provide to 'helm install ...'  Note: Secrets are namespace scoped, so they must be created in every namespace you plan to install DevOps Plan into.  Following is an example command to create an imagePullSecret named 'ibm-entitlement-key'.

      ```
      oc create secret docker-registry ibm-entitlement-key \
        --namespace [namespace_name] \
        --docker-username=cp \
        --docker-password=<EntitlementKey> \
        --docker-server=cp.icr.io
      ```

3. PostgreSQL Database

     - DevOps Plan requires a PostgreSQL database to create TeamSpace and Applications. The PostgreSQL database may be running in your cluster or on hardware that resides outside of your cluster. The values used to connect to the database are required when installing the DevOps Plan. The DevOps Plan helm chart provides the PostgreSQL database by default settings. You can disable it and use your own PostgreSQL database.
     
     - If you already installed with internal PostgreSQL database, and you plan to upgrade with latest release version, then you need to set the internal PostgreSQL database password during helm upgrade. Get the password for internal PostgreSQL database by running this command:
        ```bash
        export POSTGRES_PASSWORD=$(kubectl get secret --namespace devopsplan ibm-devopsplan-ibm-devopsplan-prod-db-secret -o jsonpath="{.data.tenant-datastore-password}" | base64 -d)
        ```
       Set the password during the upgrade:
        ```bash
        --set spring.datastore.password=$POSTGRES_PASSWORD \
        --set tenant.datastore.password=$POSTGRES_PASSWORD
        ```

4. Persistent Volumes

     - Persistent Volumes that will hold the devopsplan data, config, share and logs folders for the DevOps Plan are required. If your cluster supports default StoreageClass (SC) and dynamic volume provisioning, you will not need to create a SC and PersistentVolume (PV) before installing DevOps Plan. If your cluster does not support default SC and dynamic volume provisioning, you will need to either ensure a SC and PV is available or disable the persistent volume by setting *persistence.enabled* to *false* before installing DevOps Plan.

     - DevOps Plan requires non-root access to persistent storage. When using IBM File Storage, you need to either use the IBM provided "gid" File storage class with default group ID 65531 or create your own customized storage class to specify a different group ID. Please follow the instructions at https://cloud.ibm.com/docs/containers?topic=containers-cs_storage_nonroot for more details.

     - The DevOps Plan persistent volumes has been tested with default StorageClass "ibmc-block-gold" for the persistence volume with no sharing the data, persistence.ccm.storageClass=ibmc-file-gold-gid for the persistence volume with sharing the data and securityContext.fsGroup=65531. The default setting for the StorageClass and fsGroup shown as below and you can updated based on your cluster environment.

        ```bash
        persistence:
          storageClass= ''
          ccm:
            storageClass=ibmc-file-gold-gid
        securityContext:
          fsGroup: 65531
        ```
5. Keycloak Single Sign On feature.

    - The helm chart enables the Keycloak Single Sign On feature installed with helm chart. You can disable the Keycloak installed with the helm chart and using an external Keycloak instance installed outside of the helm chart.

6. Licensing Requirements

    - The DevOps Plan docker image will attempt to upload DevOps Plan license metrics for the Concurrent User count to the IBM License service. For the upload to be successful, this chart needs IBM License Service on the OpenShift. Please follow [Installing License Service](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.6?topic=service-installing-license) instructions to install IBM License service.

    - Once the IBM License Service is installed, you need to copy the license service upload secret(ibm-licensing-upload-token) and configmap(ibm-licensing-upload-config) to the namespace/project the DevOps Plan server will be installed in. Be sure that the current namespace/project is the one that DevOps Plan will be installed into, before running the following commands.

    ```bash
    oc get secret ibm-licensing-upload-token -n ibm-licensing -o yaml | sed 's/^.*namespace: ibm-licensing.*$//' | oc create -f -
    oc get configMap ibm-licensing-upload-config -n ibm-licensing -o yaml | sed 's/^.*namespace: ibm-licensing.*$//' | oc create -f -
    ```
    - You also need to set global.licenseMetric to "true" during the helm install/upgrade.
    ```bash
    --set global.licenseMetric=true 
    ```

    - Once the DevOps Plan server has started Concurrent User license metrics to the IBM License service (this can take up to 24 hours), you can retrieve license usage data by following these [instructions](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.6?topic=data-per-cluster-from-license-service).

## **Installing the Chart**

Add the DevOps Plan helm chart repository to the local client.

  ```
  $ helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/
  ```

Tip: You can list all supported Helm chart version and Application versions for the DevOps Plan using:

  ```
  $ helm repo update
  $ helm search repo ibm-helm/ibm-devopsplan
  ```

You can see the list of the **ibm-helm/ibm-devopsplan-prod** Helm chart and DevOps Plan release versions. The Helm install will install the latest stable release version, unless you specify **--version [CHART VERSION]** to the helm install command.

Get the _default_ `openshift-cluster-dns-name` and set it in the *global.domain* during the install:

  ```bash
  oc get --namespace=openshift-ingress-operator ingresscontroller/default -ojsonpath='{.status.domain}'
  ```

### **Install with default parameters settings**

1. Install the helm chart with the default parameters into namespace *devopsplan* with the release name *ibm-devopsplan*.

  ```bash
  helm install ibm-devopsplan ibm-helm/ibm-devopsplan-prod \
    --version [CHART VERSION] \
    --namespace devopsplan \
    --set global.imagePullSecret=ibm-entitlement-key \
    --set global.domain=[openshift-cluster-dns-name]
  ```

  If you plan to install the latest version of the DevOps Plan, then you don't need to add **--version [CHART VERSION]**.

  If you plan to use external PostgreSQL database, refer to [Installing DevOps Plan with External Database and Optional email server settings](https://www.ibm.com/docs/devops-plan/3.0.0?topic=gsdphc-installing-devops-plan-external-databases-optional-email-server-settings).

  If you plan to use External Keycloak, refer to [Installing DevOps Plan with External Keycloak Single Sign On feature](https://www.ibm.com/docs/en/devops-plan/3.0.0?topic=openshift-enabling-devops-plan-keycloak-single-sign-feature).

  When providing your own cluster if the default storage class does not support the ReadWriteMany (RWX) accessMode or it does not support Storage Class ibmc-file-gold-gid, then an alternative class must be specified using the following additional helm values:

  ```bash
    --set persistence.storageClass=[default_storage_class] \
    --set persistence.ccm.storageClass=[ReadWriteMany_storage_class] \
    --set securityContext.fsGroup=65531
  ```

2. Start Keycloak home page by using https://ibm-devopsplan-keycloak.[openshift-cluster-dns-name]/ and trust keycloak certificate (Username: *admin* and Password: *admin*).

3. Start the DevOps Plan home page in your browser by using https://ibm-devopsplan.[openshift-cluster-dns-name]


### **Install with Customize parameters settings**

1. Get a copy of the values.yaml file from the helm chart so you can update it with values used by the install.

  ```
  $ helm inspect values ibm-helm/ibm-devopsplan-prod --version [CHART VERSION] > myvalues.yaml
  ```

2. Edit the file myvalues.yaml to specify the parameter values to use when installing the DevOps Plan instance. The **Configuration** section lists the parameter values that can be set.

3. Install the chart into namespace *devopsplan* with the release name *ibm-devopsplan* and use the values from myvalues.yaml:

  ```bash
  helm install ibm-devopsplan ibm-helm/ibm-devopsplan-prod \
    --version [CHART VERSION] \
    --namespace devopsplan \
    --values myvalues.yaml
  ```

Tip: List all releases using *helm list*.

If you plan to install the latest version of the DevOps Plan, then you don't need to add **--version [CHART VERSION]**.

## **Uninstalling the Chart**

To uninstall/delete the ibm-devopsplan deployment.

  ```bash
  helm delete ibm-devopsplan \
    --namespace devopsplan 
  ```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## **Installing DevOps Plan with License Metric Enabled**
The global.licenseMetric is set to false by default. You need to set it to true during the helm install/upgrade

  ```bash
  --set global.licenseMetric=true 
  ```

## **Installing DevOps Plan with External Database and Optional email server settings**
DevOps Plan requires a PostgreSQL database to create TeamSpace and Applications. The PostgreSQL database may be running in your cluster or on hardware that resides outside of your cluster. The values used to connect to the database are required when installing the DevOps Plan. The DevOps Plan helm chart provides the PostgreSQL database by default settings. You can disable it and use your own PostgreSQL database.

1. Create a file named devopsplan.yaml. Add database connection data and disable PostgreSQL service.

```yaml
## Spring datastore settings (Only PostgreSQL)
spring:
  datastore:
    url: "jdbc:postgresql://[DATABASE_HOST]:[DATABASE_PORT]/[DATABASE_NAME]"
    username: [DATABASE_USERNAME]
    password: [DATABASE_PASSWORD]

## Email server settings (0ptional)
  mail:
    host: [MAIL_SERVER]
    port: [MAIL_PORT]    username: [YOUR_MAIL_USERNAME]
    password: [YOUR_MAIL_PASSWORD]

## Tenant datastore settings (Only PostgreSQL)
tenant:
  datastore:
    server: [DATABASE_SERVER_NAME]
    dbname: [DATABASE_NAME]
    username: [DATABASE_USERNAME]
    password: [DATABASE_PASSWORD]

## The email has to delivered from (optional)
  email:
    fromaddress: [FROM_EMAIL_ADDRESS]

postgresql:
  enabled: false
```

2. Add -f devopsplan.yaml to *helm install* or *helm upgrade* command.

## **Installing DevOps Plan with External Keycloak Single Sign On feature**
The helm chart enables the Keycloak Single Sign On feature installed with helm chart. You can disable the Keycloak installed with the helm chart and using an external Keycloak instance installed outside of the helm chart.

1. Setting up keycloak-json configmap for keycloak.json file
      - Create a new folder named *path/to/your/keycloak* that contains the *keycloak.json* file for installing configuring Keycloak on ibm-devopsplan pod container:
      ```bash
      $ mkdir /path/to/your/keycloak
      ```
      - Add the *keycloak.json* from */path/to/your/keycloak* folder to configMap called *keycloak-json*.
      ```bash
      $ kubectl create cm keycloak-json --from-file /path/to/your/keystore/keycloak.json --namespace [namespace_name]
      ```
      - Check configMap *keycloak-json* is created and it has the *keycloak.json* file contains from */path/to/your/keycloak/* path.
      ```bash
      $ kubectl get cm keycloak-json -o yaml --namespace [namespace_name]
      ```

2. Create a file called *keycloak.yaml*. Enable the Keycloak and SSO configuration for ibm-devopsplan pod container and keycloak.json file.

    ```yaml
    keycloak:
      enabled: true
      service:
        enabled: false
      urlMapping: [Keycloak_URL]
      username: [Keycloak_Admin_Usename]
      password: [Keycloak_Admin_Password]
      realmName: [Keycloak_Realm_Name]
      dashboardsClientID: [Keycloak_Dashboards_Client_ID]
      dashboardsClientSecret: [Keycloak_Dashboards_Client_Secret]
      jsonFile:
        enabled: true
        configMapName: keycloak-json
    ```

3. add *-f keycloak.yaml* to *helm install* or *helm upgrade* command.

### Install the SSL certificate:
Follow these instructions to install SSL certificates in the devopsplan container:
  1. Create a new folder named *path/to/your/keystore* that contains the *keystore.p12* file for installing an SSL Certificates on devopsplan pod container:
    ```bash
    $ mkdir /path/to/your/keystore
    ```
  2. Add the *keystore.p12* from */path/to/your/keystore* folder to configMap called *keystore-file*.

    ```bash
    $ kubectl create cm keystore-file --from-file /path/to/your/keystore/keystore.p12 --namespace [namespace_name]
    ```
  3. Check configMap *keystore-file* is created and it has the *keystore.p12* file contains from */path/to/your/keystore/* path.

    ```bash
    $ kubectl get cm keystore-file -o yaml --namespace [namespace_name]
    ```
  4. Create a file called *ssl.yaml*. Set the SSL password, key-aliasMount and configMapName to *keystore-file*.

    ```yaml
    ssl:
      enabled: true
      password: ""
      keyAlias:  1
      configMapName: keystore-file
    ```
  5. add *-f ssl.yaml* to *helm install* or *helm upgrade* command.

## **Configuration**

### Parameters
The Helm chart has the following values that can be overridden using the *--set parameter* or specified via *-f myvalues.yaml*.

### Common Parameters

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **global.imagePullSecret** | Your own secret with your credentials to IBM's docker repository. Required when deploying Helm Chart in your own cluster. | "" |
| **global.imageRegistry** |  DevOps Plan docker image registry. | cp.icr.io |
| **global.licenseMetric** | DevOps Plan license metrice for concurrent user. | false |
| **replicaCount** | Number of replicas to deploy instance of DevOps Plan service. | 1 |
| **image.repository** | DevOps Plan docker Image repository path. | cp/devops-plan/devopsplan |
| **image.tag** | DevOps Plan Image tag or image digest. | See values.yaml |
| **image.pullPolicy** | DevOps Plan image pull policy.Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent |
| **hostname** | DevOps Plan Docker Container hostname. | devopsplan |
| **timeZone** | DevOps Plan server Time Zone. It can set based on list of supported time zones and abbreviations.| EST5EDT |
| **serverQualifiedUrlPath** | If defined, it overrides the mapping URL in DevOps Plan server application.properties file.<br>Example: "https://[MAPPING_NAME].com" | "" |
| **service.type** | Service type. It can be set to ClusterIP, LoadBalancer or NodePort | ClusterIP |
| **service.exposePort** | Service expose port  | "" |
| **ingress.enabled** | Ingress service. Accepted values are:<br> - *true* to enable the ingress service.<br> - *false* to disable the ingress service.| true |
| **ingress.type** | Ingress service type.. Accepted values are: nginx, route, mapping| route |
| **hosts** | List of hosts for the ingress. | devopsplan.ibm.com |

### Parameters for creating TeamSpace and Applications
The PostgreSQL database requires to create TeamSpace and Applications. The helm chart is installed with internal PostgreSQL database by default. If you plan to install/upgrade the helm charts with external database, then you need to set the *postgresql.enabled* to *false* and set the *spring.datastore* and *tenant.datastore* configuration settings based on your external database parameters. PostgreSQL database is supported database for release 3.0.0.

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **spring.datastore.url** | postgresql JDBC URL with format *jdbc:postgresql://[host_address]:[port_number]/[database_name].* | jdbc:postgresql://devopsplan-postgresql:5432/postgres |
| **spring.datastore.username** | postgresql database username | postgres |
| **spring.datastore.password** | postgresql database password | See values.yaml |
| **tenant.datastore.vendor** | Tenant database vendor. The current supported database PostgreSQL. * | PostgreSQL |
| **tenant.datastore.server** | Tenant database server | devopsplan-postgresql |
| **tenant.datastore.dbname** | Tenant database name | postgres |
| **tenant.datastore.username** | Tenant database username | postgres |
| **tenant.datastore.password** | Tenant database password | See values.yaml |
| **tenant.registration.code** | Tenant generate registration codes. Accepted values are:<br>- *NONE* no verification needed. Any verification code is ignored.<br>- *PROVIDED* the use the code supplied by the registration API call .<br>- *GENERATED* the server generates a random code (default 6 alphanumeric characters). | NONE |
| **tenant.email.fromaddress** | The email address has to delivered from on-boarding process | "" |

### Mail Server Parameters

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **spring.mail.host** | Mail server host  | "" |
| **spring.mail.port** | Mail server port number | "" |
| **spring.mail.username** | Mail server username | "" |
| **spring.mail.password** | Mail server password | "" |


### Analytics Parameters
The helm chart installs Analytics feature on a separate pod by default. you can disabled/enabled the Analytics feature service by setting *analytics.service* to *false/true*. 

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **analytics.service** | This parameter enables or disable Analytics service. Accepted values are:<br>- *true* to enable Analytics service.<br>- *false* to disable Analytics service.<br>This parameter is needed if you plan to use Analytics features for the DevOps Plan. | true |
| **analytics.type** | Analytics service type  | LoadBalancer |
| **analytics.exposePort** | Analytics service port  | "" |
| **analytics.urlMapping** | URL mapping. <br>- The mapping URL format should be *https:[mapping-name].com*.  | "" |
| **analytics.replicaCount** | Number of replica Analytics Pods. This parameter is needed if analytics.service *=true.* | 1 |
| **analytics.image.repository** | Analytics docker Image repository path. This parameter is needed if analytics.service *=true.* | cp/devops-plan/devopsplan-analytics |
| **analytics.image.tag** | Analytics Image tag. This parameter is needed if *analytics.service=true.* | 3.0.0 |
| **analytics.image.pullPolicy** | Analytics image pull policy. This parameter is needed if *analytics.service=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent | 
| **analytics.hostname** | Analytics hostname | analytics |

### PostgreSQL Database Parameters
The helm chart is installed with internal postgresql database by default.

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **postgresql.enabled** | This parameter enables or disable devopsplan-postgresql database service. Accepted values are:<br>- *true* to enable postgresql database service.<br>- *false* to disable postgresql database service. | true |
| **postgresql.repository** | Postgresql database docker Image repository path. This parameter is needed if *postgresql.enabled=true.* | cp/devops-plan/devopsplan-postgresql |
| **postgresql.tag** | Postgresql database Image tag.This parameter is needed if *postgresql.enabled=true.* | 3.0.0 |
| **postgresql.pullPolicy** | Postgresql database image pull policy.This parameter is needed if *postgresql.enabled=true*Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent |
 **postgresql.service.type** | postgresql service type  | LoadBalancer |
| **postgresql.service.exposePort** | postgresql service port  | "" |

### Dashboard Parameters
The dashboards analytics configuration setting options set by default for dashboard properties using Nginx, Opensearch and Opensearch-dashboards in Helm chart. It is strongly recommended to not modify the default values as shown in the below table. 

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **analyticsUserName** | Analytics UserName| SYSTEM_ANALYTICS1 |
| **analyticsBootstrapData** | Set number of the days of analytics data | 90 |
| **nginx.service** | This parameter enables or disable Nginx service. Accepted values are:<br>- *true* to enable Ngnix service.<br>- *false* to disable Nginx service.<br>This parameter is needed if you plan to use Dashboard features for the Business Analytics. | true |
| **nginx.type** | Nginx service type  | LoadBalancer |
| **nginx.exposePort** | Nginx service port  | "" |
| **nginx.urlMapping** | URL mapping. <br>- The mapping URL format should be *https:[mapping-name].com*.  | "" |
| **nginx.replicaCount** | Number of replica nginx Pods. This parameter is needed if nginx.service *=true.* | 1 |
| **nginx.image.repository** | Nginx docker Image repository path. This parameter is needed if nginx.service *=true.* | cp/devops-plan/devopsplan-nginx |
| **nginx.image.tag** | Nginx Image tag. This parameter is needed if *nginx.service=true.* | 2.2.2 |
| **nginx.image.pullPolicy** | Nginx image pull policy. This parameter is needed if *nginx.service=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent | 
| **nginx.hostname** | Nginx hostname | nginx |
| **dashboards.service** | This parameter enables or disable dashboards service. Accepted values are:<br>- *true* to enable Ngnix service.<br>- *false* to disable dashboards service.<br>This parameter is needed if you plan to use Dashboard features for Business Analytics. | true |
| **dashboards.replicaCount** | Number of replica dashboards Pods. This parameter is needed if dashboards.service *=true.* | 1 |
| **dashboards.image.repository** | Opensearch-dashboards docker Image repository path. This parameter is needed if dashboards.service *=true.* | cp/devops-plan/devopsplan-dashboards |
| **dashboards.image.tag** | Opensearch-dashboards Image tag. This parameter is needed if *dashboards.service=true.* | 3.0.0 |
| **dashboards.image.pullPolicy** | Opensearch-dashboards image pull policy. This parameter is needed if *dashboards.service=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent | 
| **dashboards.hostname** | Dashboards hostname | dashboards |
| **dashboards.username** | Opensearch Dashboards username | "admin" |
| **dashboards.password** | Opensearch Dashboards password | "admin" |
| **logstash.service** | This parameter enables or disable devopsplan-logstash service. Accepted values are:<br>- *true* to enable Ngnix service.<br>- *false* to disable devopsplan-logstash service.<br>This parameter is needed if you plan to use Dashboard features for Business Analytics. | true |
| **logstash.replicaCount** | Number of replica devopsplan-logstash pods. This parameter is needed if logstash.service *=true.* | 1 |
| **logstash.image.repository** | logstash docker Image repository path. This parameter is needed if logstash.service *=true.* | cp/devops-plan/devopsplan-logstash |
| **logstash.image.tag** | devopsplan-logstash Image tag. This parameter is needed if *logstas.service=true.* | 3.0.0 |
| **logstash.image.pullPolicy** | Opensearch-logstash image pull policy. This parameter is needed if *logstas.service=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent | 
| **logstash.port** | logstash port | 5011 |
| **logstash.username** | logstash username | "logstash" |
| **logstash.password** | logstash password | "logstash" |
| **opensearch.service** | This parameter enables or disable opensearch service. Accepted values are:<br>- *true* to enable Ngnix service.<br>- *false* to disable opensearch service.<br>This parameter is needed if you plan to use Dashboard features for Business Analytics. | true |
| **opensearch.replicaCount** | Number of replica opensearch pods. This parameter is needed if opensearch.service *=true.* | 1 |
| **opensearch.image.repository** | Opensearch docker Image repository path. This parameter is needed if opensearch.service *=true.* | cp/devops-plan/devopsplan-opensearch |
| **opensearch.image.tag** | Opensearch Image tag. This parameter is needed if *opensearch.service=true.* | 3.0.0 |
| **opensearch.image.pullPolicy** | Opensearch image pull policy. This parameter is needed if *opensearch.service=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent | 
| **opensearch.hostname** | Opensearch hostname | opensearch |
| **opensearch.hash** | Opensearch password hash | "" |
| **opensearch.discoveryType** | Eleasticsearch discoveryType  | single-node |

### Single-Sign-On (Keycloak) functionality Parameters
Single-Sign-On functionality by default is sets to disable. If the admin plan to enable the Single-Sign-On functionality, then it need to modify the default values as shown in the below table. Refer to [Enabling the DevOps Plan Keycloak Single Sign On feature]() for more information.

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **keycloak.enabled** | This parameter enables or disable Single-Sign-On (Keycloak)  service. Accepted values are:<br>- *true* to enable Single-Sign-On service.<br>- *false* to disable Single-Sign-On service.<br>This parameter is needed if you plan to use Single-Sign-On feature. | false |
| **keycloak.service.enabled** | This parameter enables or disable Keycloak service in Helm Chart for Single-Sign-On service. Accepted values are:<br>- *true* to enable Keycloak service.<br>- *false* to disable Keycloak service.<br>This parameter is needed if you plan to use Single-Sign-On feature and deploy Keycloak with Helm chart. | false |
| **keycloak.service.replicaCount** | Number of replica keycloak Pods. This parameter is needed if *keycloak.service.enabled=true*. | 1 |
| **keycloak.service.image.repository** | keycloak docker Image repository path. This parameter is needed if *keycloak.service.enabled=true*. | cp/devops-plan/devopsplan-keycloak |
| **keycloak.service.image.tag** | Keycloak Image tag. This parameter is needed if *keycloak.service.enabled=true*. | 3.0.0 |
| **keycloak.service.image.pullPolicy** | Keycloak image pull policy. This parameter is needed if *keycloak.service.enabled=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent |
| **keycloak.service.hostname** | Keycloak hostname. | keycloak |
| **keycloak.service.type** | Keycloak service type. | ClusterIP |
| **keycloak.service.exposePort** | Keycloak service port. | "" |
| **keycloak.service.ipAddress** | Cluster IP address or Hostname. | "" |
| **keycloak.service.tls.enabled** | Enable installing Keycloak tls certificate and private key files. Accepted values are:<br>- *true* to enable installing tls files <br>- *false* to disable installing tls files. | true |
| **keycloak.service.tls.configMapName** | This is configMap file name that contains the tls certificate and tls private key files. This parameter is needed if keycloak.service.enabled *=true.* | keycloak-tls |
| **keycloak.service.importRealm.enabled** | Enable importing Keycloak realm configuration file. Accepted values are:<br>- *true* to enable importing  Keycloak realm configuration file<br>- *false* to disable importing Keycloak realm configuration file. | false |
| **keycloak.service.importRealm.fileName** | This is configMap file name that contains the realm configuration file. This parameter is needed if keycloak.service.enabled *=true.*  and *keycloak.service.importRealm.enabled*| realm.json |
| **keycloak.service.configMapName.fileName** | This is configMap file name that contains the realm configuration file. This parameter is needed if keycloak.service.enabled *=true.* and *keycloak.service.importRealm.enabled* | realm-json |
| **keycloak.username** | Keycloak Administration Console username. | admin |
| **keycloak.password** | Keycloak Administration Console password. | admin |
| **keycloak.realmName** | The Realm name. | "CCM" |
| **keycloak.dashboardsClientID** | The dashboards-client Id. | "dashboards-client" |
| **keycloak.dashboardsClientSecret** | The secret for the dashboards-client. | "58846041-eb1e-46d8-bac4-b2ba541ff491" |
| **keycloak.urlMapping** | Keycloak URL | "" |
| **keycloak.jsonFile.enabled** | Enable installing keycloak.json file to the DevOps Plan servers /config folder.  Accepted values are:<br>- *true* to enable installing keycloak.json file <br>- *false* to disable installing keycloak.json file. | false |
| **keycloak.jsonFile.configMapName** | This is configMap file name that contains the keycloak.json file. This parameter is needed if keycloak.jsonFile.enabled *=true.* | keycloak-json |

### SSL Parameters
You need to set the ssl parmeters in order to install SSL certificates.

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **ssl.enabled** | Enable installing SSL certificate.Accepted values are:<br>- *true* to enable installing SSL certificate <br>- *false* to disable installing SSL certificate. | false |
| **ssl.password** | Keystore password. This parameter is needed if ssl.enabled *=true.* | "" |
| **ssl.keyAlias** | keystore alias. | 1 |
| **ssl.configMapName** | This is configMap file name that contains the SSL certificate keystore.p12 file.This parameter is needed if ssl.enabled *=true.* | keystore-file |

### Liveness & Readiness Parameters

  - **ibm-devopsplan pod**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **probes.liveness.ccm.enabled** | Enable liveness probe | true |
| **probes.liveness.ccm.initialDelaySeconds** | Delay in seconds for initial liveness probe | 90 |
| **probes.liveness.ccm.periodSeconds** | Duration in seconds between liveness probes | 10 |
| **probes.liveness.ccm.timeoutSeconds** | Liveness probe timeout | 3 |
| **probes.liveness.ccm.successThreshold** | Liveness probe success threshold | 1 |
| **probes.liveness.ccm.failureThreshold** | Liveness probe failure threshold | 5  |
| **probes.readiness.ccm.enabled** | Enable readiness probe | true |
| **probes.readiness.ccm.initialDelaySeconds** | Delay in seconds for initial readiness probe | 90 |
| **probes.readiness.ccm.periodSeconds** | Duration in seconds between readiness probes | 60 |
| **probes.liveness.ccm.timeoutSeconds** | Readiness probe timeout | 3 |
| **probes.readiness.ccm.successThreshold** | Readiness probe success threshold | 1 |
| **probes.readiness.ccm.failureThreshold** | Readiness probe failure threshold | 3 |

  - **ibm-devopsplan-analytics pod**
  
| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **probes.liveness.analytics.enabled** | Enable liveness probe | true |
| **probes.liveness.analytics.initialDelaySeconds** | Delay in seconds for initial liveness probe | 90 |
| **probes.liveness.analytics.periodSeconds** | Duration in seconds between liveness probes | 10 |
| **probes.liveness.analytics.timeoutSeconds** | Liveness probe timeout | 3 |
| **probes.liveness.analytics.successThreshold** | Liveness probe success threshold | 1 |
| **probes.liveness.analytics.failureThreshold** | Liveness probe failure threshold | 5  |
| **probes.readiness.analytics.enabled** | Enable readiness probe | true |
| **probes.readiness.analytics.initialDelaySeconds** | Delay in seconds for initial readiness probe | 90 |
| **probes.readiness.analytics.periodSeconds** | Duration in seconds between readiness probes | 60 |
| **probes.liveness.analytics.timeoutSeconds** | Readiness probe timeout | 3 |
| **probes.readiness.analytics.successThreshold** | Readiness probe success threshold | 1 |
| **probes.readiness.analytics.failureThreshold** | Readiness probe failure threshold | 3 |

  - **devopsplan-postgresql pod**
  
| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **probes.liveness.postgresql.enabled** | Enable liveness probe | true |
| **probes.liveness.postgresql.initialDelaySeconds** | Delay in seconds for initial liveness probe | 30 |
| **probes.liveness.postgresql.periodSeconds** | Duration in seconds between liveness probes | 10 |
| **probes.liveness.postgresql.timeoutSeconds** | Liveness probe timeout | 5 |
| **probes.liveness.postgresql.successThreshold** | Liveness probe success threshold | 1 |
| **probes.liveness.postgresql.failureThreshold** | Liveness probe failure threshold | 6  |
| **probes.readiness.postgresql.enabled** | Enable readiness probe | true |
| **probes.readiness.postgresql.initialDelaySeconds** | Delay in seconds for initial readiness probe | 5 |
| **probes.readiness.postgresql.periodSeconds** | Duration in seconds between readiness probes | 10 |
| **probes.liveness.postgresql.timeoutSeconds** | Readiness probe timeout | 5 |
| **probes.readiness.postgresql.successThreshold** | Readiness probe success threshold | 1 |
| **probes.readiness.postgresql.failureThreshold** | Readiness probe failure threshold | 6 |

### Persistence Volumes Parameters
The helm chart set to enable by default the persistent volumes (PVs) and persistent volumes claims (PVCs) for following mounted pods:

  - **ibm-devopsplan pod: data, config, share and logs folders**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.enabled** | Enable persistence volume claim. Accepted values are:<br>- true to enable the persistence volume.<br>- false to disable the persistence volume.<br>This parameter is needed if you plan to enable/disable the persistence volume. | true |
| **persistence.ccm.enabled** | Enable persistence volume claim for DevOps Plan server pod container. Accepted values are:<br>- true to enable the persistence volume for DevOps Plan server pod container folders.<br>- false to disable the persistence volume for DevOps Plan server pod container folder.<br>This parameter is needed if you plan to enable/disable the persistence volume for DevOps Plan server container folder. | true |
| **persistence.ccm.data.enabled** | Enable persistence volume claim for DevOps Plan server container data folder. Accepted values are:<br>- true to enable the persistence volume for DevOps Plan server data folders.<br>- false to disable the persistence volume for DevOps Plan server data folders.<br>This parameter is needed if you plan to enable/disable the persistence volume for DevOps Plan server data folders. | true |
| **persistence.ccm.data.accessModes** | Persistence Volume access modes. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | ReadWriteOnce |
| **persistence.ccm.data.size** | Persistence Volume size. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | 2Gi |
| **persistence.ccm.data.reclaimPolicy** | Persistence Volume reclaim policy. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | Retain |
| **persistence.ccm.data.existingClaim** | Persistence Volume existing claim. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | "" |
| **persistence.ccm.config.enabled** | Enable persistence volume claim for DevOps Plan server container config folder. Accepted values are:<br>- true to enable the persistence volume for DevOps Plan server config folders.<br>- false to disable the persistence volume for DevOps Plan server config folders.<br>This parameter is needed if you plan to enable/disable the persistence volume for DevOps Plan server config folders. | true |
| **persistence.ccm.config.accessModes** | Persistence Volume access modes. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | ReadWriteOnce |
| **persistence.ccm.config.size** | Persistence Volume size. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | 2Gi |
| **persistence.ccm.config.reclaimPolicy** | Persistence Volume reclaim policy. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | Retain |
| **persistence.ccm.config.existingClaim** | Persistence Volume existing claim. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | "" |
| **persistence.ccm.logs.enabled** | Enable persistence volume claim for DevOps Plan server container logs folder. Accepted values are:<br>- true to enable the persistence volume for DevOps Plan server logs folders.<br>- false to disable the persistence volume for DevOps Plan server logs folders.<br>This parameter is needed if you plan to enable/disable the persistence volume for DevOps Plan server folders. | true |
| **persistence.ccm.logs.accessModes** | Persistence Volume access modes. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | ReadWriteOnce |
| **persistence.ccm.logs.size** | Persistence Volume size. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | 2Gi |
| **persistence.ccm.logs.reclaimPolicy** | Persistence Volume reclaim policy. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | Retain |
| **persistence.ccm.logs.existingClaim** | Persistence Volume existing claim. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | "" |
| **persistence.annotations** | If defined, it set the annotations for PVC. This parameter is needed if persistence.enabled =true. | "" |
| **persistence.properties.application.enabled** | Enable the application.properties configmap. If it is set to true, then it will update the values of the application.properties based on setting in the DevOps Plan server /config/application.properties file. Accepted values are:<br>- true to enable application.properties configmap and updating the application.properties values based on setting in the DevOps Plan server /config/application.properties file.<br>- false to disable the application.properties configmap. | false |
| **persistence.properties.analytics.enabled** | Enable the analytics.properties configmap. If it is set to true, then it will update the values of the analytics.properties based on setting in the DevOps Plan server /config/analytics.properties file. Accepted values are:<br>- true to enable analytics.properties configmap and updating the analytics.properties values based on setting in the DevOps Plan server /config/analytics.properties file.<br>- false to disable the analytics.properties configmap. | false |

  - **ibm-devopsplan-analytics pod: data, config, share and logs folders**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.analytics.enabled** | Enable persistence.analytics volume claim. Accepted values are:<br>- true to enable the persistence.analytics volume.<br>- false to disable the persistence.analytics volume.<br>This parameter is needed if you plan to enable/disable the persistence.analytics volume. | true |
| **persistence.analytics.data.enabled** | Enable persistence.analytics volume claim for devopsplan-analytics server container data folder. Accepted values are:<br>- true to enable the persistence.analytics volume for devopsplan-analytics server data folders.<br>- false to disable the persistence.analytics volume for devopsplan-analytics server data folders.<br>This parameter is needed if you plan to enable/disable the persistence.analytics volume for devopsplan-analytics server data folders. | true |
| **persistence.analytics.data.accessModes** | persistence.analytics Volume access modes. This parameter is needed if persistence.analytics.enabled =true. | ReadWriteOnce |
| **persistence.analytics.data.size** | persistence.analytics Volume size. This parameter is needed if persistence.analytics.enabled =true. | 2Gi |
| **persistence.analytics.data.reclaimPolicy** | persistence.analytics Volume reclaim policy. This parameter is needed if persistence.analytics.enabled =true. | Retain |
| **persistence.analytics.data.existingClaim** | persistence.analytics Volume existing claim. This parameter is needed if persistence.analytics.enabled =true. | "" |
| **persistence.analytics.config.enabled** | Enable persistence.analytics volume claim for devopsplan-analytics server container config folder. Accepted values are:<br>- true to enable the persistence.analytics volume for devopsplan-analytics server config folders.<br>- false to disable the persistence.analytics volume for devopsplan-analytics server config folders.<br>This parameter is needed if you plan to enable/disable the persistence.analytics volume for devopsplan-analytics server config folders. | true |
| **persistence.analytics.config.accessModes** | persistence.analytics Volume access modes. This parameter is needed if persistence.analytics.enabled =true. | ReadWriteOnce |
| **persistence.analytics.config.size** | persistence.analytics Volume size. This parameter is needed if persistence.analytics.enabled =true. | 2Gi |
| **persistence.analytics.config.reclaimPolicy** | persistence.analytics Volume reclaim policy. This parameter is needed if persistence.analytics.enabled =true. | Retain |
| **persistence.analytics.config.existingClaim** | persistence.analytics Volume existing claim. This parameter is needed if persistence.analytics.enabled =true. | "" |
| **persistence.analytics.logs.enabled** | Enable persistence.analytics volume claim for devopsplan-analytics server container logs folder. Accepted values are:<br>- true to enable the persistence.analytics volume for devopsplan-analytics server logs folders.<br>- false to disable the persistence.analytics volume for devopsplan-analytics server logs folders.<br>This parameter is needed if you plan to enable/disable the persistence.analytics volume for devopsplan-analytics server folders. | true |
| **persistence.analytics.logs.accessModes** | persistence.analytics Volume access modes. This parameter is needed if persistence.analytics.enabled =true. | ReadWriteOnce |
| **persistence.analytics.logs.size** | persistence.analytics Volume size. This parameter is needed if persistence.analytics.enabled =true. | 2Gi |
| **persistence.analytics.logs.reclaimPolicy** | persistence.analytics Volume reclaim policy. This parameter is needed if persistence.analytics.enabled =true. | Retain |
| **persistence.analytics.logs.existingClaim** | persistence.analytics Volume existing claim. This parameter is needed if persistence.analytics.enabled =true. | "" |

  - **devopsplan-postgresql pod: data folder**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.postgresql.enabled** | Enable persistence.postgresql volume claim for postgresql pod container data folder. Accepted values are:<br>- true to enable the persistence.postgresql volume for postgresql data folder.<br>- false to disable the persistence.postgresql volume for postgresql folder.<br>This parameter is needed if you plan to enable/disable the persistence.postgresql volume for postgresql folder. | true |
| **persistence.postgresql.accessModes** | persistence.postgresql Volume access modes. This parameter is needed if persistence.postgresql.enabled =true. | ReadWriteOnce |
| **persistence.postgresql.size** | persistence.postgresql Volume size. This parameter is needed if persistence.postgresql.enabled =true. | 2Gi |
| **persistence.postgresql.reclaimPolicy** | persistence.postgresql Volume reclaim policy. This parameter is needed if persistence.postgresql.enabled =true. | Retain |
| **persistence.postgresql.existingClaim** | persistence.postgresql Volume existing claim. This parameter is needed if persistence.postgresql.enabled =true. | "" |

  - **ibm-devopsplan-opensearch pod: data folder**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.opensearch.enabled** | Enable persistence volume claim for opensearch pod container data folder. Accepted values are:<br>- true to enable the persistence volume for opensearch data folder.<br>- false to disable the persistence volume for opensearch folder.<br>This parameter is needed if you plan to enable/disable the persistence volume for opensearch folder. | true |
| **persistence.opensearch.accessModes** | Persistence Volume access modes. This parameter is needed if persistence.enabled =true. | ReadWriteOnce |
| **persistence.opensearch.size** | Persistence Volume size. This parameter is needed if persistence.enabled =true. | 2Gi |
| **persistence.opensearch.reclaimPolicy** | Persistence Volume reclaim policy. This parameter is needed if persistence.enabled =true. | Retain |
| **persistence.opensearch.existingClaim** | Persistence Volume existing claim. This parameter is needed if persistence.enabled =true. | "" |

  - **devopsplan-kycloak pod: data folder**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.keycloak.enabled** | Enable persistence volume claim for keycloak pod container data folder. Accepted values are:<br>- true to enable the persistence volume for keycloak data folder.<br>- false to disable the persistence volume for keycloak folder.<br>This parameter is needed if you plan to enable/disable the persistence volume for keycloak folder. | true |
| **persistence.keycloak.accessModes** | Persistence Volume access modes. This parameter is needed if persistence.enabled =true. | ReadWriteOnce |
| **persistence.keycloak.size** | Persistence Volume size. This parameter is needed if persistence.enabled =true. | 2Gi |
| **persistence.keycloak.reclaimPolicy** | Persistence Volume reclaim policy. This parameter is needed if persistence.enabled =true. | Retain |
| **persistence.keycloak.existingClaim** | Persistence Volume existing claim. This parameter is needed if persistence.enabled =true. | "" |

### Storage Class Parameters

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.storageClass** | If defined, it set the global storageClassName. This parameter is needed if persistence.enabled =true and Storage Class will be used. | "" |
| **persistence.ccm.storageClass** | It set the storageClassName for the devopsplan pods. This parameter is needed if the default storage class does not support the ReadWriteMany (RWX) accessMode. | ibmc-file-gold-gid |
| **persistence.analytics.storageClass** | It set the storageClassName for the devopsplan-analytics PVC. | "" |
| **persistence.postgresql.storageClass** | It set the storageClassName for the devopsplan-postgresql PVC. | "" |
| **persistence.opensearch.storageClass** | It set the storageClassName for the devopsplan-opensearch PVC. | "" |
| **persistence.keycloak.storageClass** | It set the storageClassName for the devopsplan-keycloak PVC. | "" |


## Mount Windows package into the DevOps Plan Server
The following steps describe how enabled/disabled mounting the windows product package in DevOps Plan Server.

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **winInstall.enabled** | This parameter enables or disable mounting the windows product package in DevOps Plan Server. Accepted values are:<br>- *true* to enable mounting the windows product package.<br>- *false* to disable mounting the windows product package. | true |
| **winInstall.image.repository** | win-install docker Image repository path. This parameter is needed if *winInstall.enabled=true*. | ibm-devopsplan-win-install |
| **winInstall.image.tag** | win-install image tag. This parameter is needed if *winInstall.enabled=*true* | 3.0.0 |
| **winInstall.image.pullPolicy** | win-install image pull policy. This parameter is needed if *winInstall.enabled=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent |
| **winInstall.accessModes** | win-install persistence Volume access modes. This parameter is needed if *winInstall.enabled=rtue*. | ReadWriteOnce |
| **winInstall.size** | win-install persistence Volume size. This parameter is needed if *winInstall.enabled=true*. | 2Gi |
| **winInstall.reclaimPolicy** | win-install persistence Volume reclaim policy. This parameter is needed if *winInstall.enabled=true*. | Retain |
| **winInstall.existingClaim** | win-install persistence Volume existing claim. | "" |

   **Note:** The helm chart by default sets the persistent volume. If your Kubernetes environment does not provide with default StorageClass, then you need to create your own default StorageClass and set the StorageClass name to *persistence.storageClass*. Otherwise, you need to set *persistence.enabled=false*.

## Scaling
To increase or decrease the number of DevOps Plan Server instances issue the following command:

  ```bash
  kubectl scale --replicas=2 statefulset/ibm-devopsplan
  ```

## Update OpenSearch and OpenSearch Dashboards Password

The default OpenSearch and OpenSearch Dashboards Password is set to **admin**. You can update the default password using the following steps:

  1. Create a new password hash for OpenSearch.

  ```bash
    $ docker run -d --name devopsplan-opensearch --env "discovery.type=single-node" icr.io/cp/devops-plan/devopsplan-opensearch:3.0.0
    $ docker exec -it  devopsplan-opensearch /bin/bash -c /usr/share/opensearch/plugins/opensearch-security/tools/hash.sh
  ```

  - You see prompt for the new password. Enter the new password. You should see the password hash is generated.
    Example:

  ```bash
    [Password:] myNewPassword
    $2y$12$3UScOsDk1bCjHk4Jd/p9vuCzgVqrU05h1w4F5VFZCCFhgoF1/vwvO
  ```

  - You can stop and remove the devopsplan-opensearch container after you generated password hash.

  ```bash
    $ docker stop devopsplan-opensearch
    $ docker rm devopsplan-opensearch
  ```

  2. Create a file called *openseach-user.yaml*. Set the new OpenSearch Dashboards password and new OpenSearch password hash.

    ```yaml
    dashboards:
      password: [NEW_OPENSEARCH_DASHBOARDS_PASSWORD]
    opensearch:
      hash: [NEW_OPENSEARCH_HASH_PASSWORD]
    ```

  5. add *-f openseach-user.yaml* to *helm upgrade --install* command.

## Settings Feedback Email Address
To set email address for the feedback, the admin requires to set feedback.to.emailaddress and feedback.from.emailaddress during the Helm install/upgrade.
  ```bash
  feedback:
    toEmailaddress: [TO_EMAIL_ADDRESS]
    fromEmailaddress: [FROM_EMAIL_ADDRESS]
  ```

## Rolling upgrade release

You can upgrade DevOps Plan to the newest release using the helm upgrade command.

Before you perform the upgrade, you must first do the following:
  - Use Helm to install the DevOps Plan chart as described in section **Installing the Chart**.

Rolling upgrades utilize the helm upgrade command. For more information, see Helm [Upgrade](https://helm.sh/docs/helm/helm_upgrade/) in the Helm documentation.

**Case 1: Upgrade the Chart**

  ```bash
  helm upgrade ibm-devopsplan ibm-helm/ibm-devopsplan-prod \
    --namespace [namespace] \
    --set global.imagePullSecret=ibm-entitlement-key \
    --set global.domain=[openshift-cluster-dns-name]

  ```

**Case 2: Upgrade the Docker image**

  ```bash
  helm upgrade ibm-devopsplan ibm-helm/ibm-devopsplan-prod \
    --namespace [namespace] \
    --set global.imagePullSecret=ibm-entitlement-key \
    --set global.domain=[openshift-cluster-dns-name]
    --set image.tag=[image-tag]
  ```

## Rolling rollback release
You can rollback to the previous release using *helm rollback* command.

**Before you begin**

1. Use Helm to install the chart as described in section **Installing the Chart**.
2. Use Helm to upgrade the chart to new release as described in section **Rolling upgrade release**.

**Procedure:**
1. Run *helm history* command to see revision numbers of your helm chart release. You should have min two revision numbers. revision 1 for install and revision 2 for the upgrade that you execute in **Before you begin** section. Example below shows you have a helm chart release name *ibm-devopsplan1* with revision 1 installed the helm chart *ibm-devopsplan1-3.0.0* for release 3.0.0 and revision 2 upgraded the helm chart *ibm-devopsplan2-3.0.1* to release 3.0.0.
  ```bash
  $ helm history ibm-devopsplan1 --namespace dev  REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
  1               Thu Jan 20 21:58:13 2024        superseded      ibm-devopsplan1-3.0.0          Install complete  2               Thu Jan 20 22:13:56 2024        deployed        ibm-devopsplan2-3.0.0          Upgrade complete  ```
2. Rollback helm chart using *helm rollback* command. Example below will rollback helm chart release *ibm-devopsplan1* from revision 2 to revision 1.

  ```bash  $ helm rollback ibm-devopsplan --namespace dev  Rollback was a success! Happy Helming!
  ```
3. Run *helm history RELEASE* command again to see the new revision 3 has been created after rollback, and it rollbacked to revision 1 the helm chart release *ibm-devopsplan1*.
  ```bash  $ helm history ibm-devopsplan1 --namespace dev
  REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION  1               Thu Jan 20 21:58:13 2024        superseded      ibm-devopsplan1-ibm.0          Install complete  2               Thu Jan 20 22:13:56 2024        deployed        ibm-devopsplan2-3.0.0          Upgrade complete
  3               Thu Jan 20 22:30:32 2024        deployed        ibm-devopsplan1-3.0.0          Rollback to 1
  ```
 
 ## **Additional Information**

<details><summary>Downloads and Useful Links</summary>
<p>

- [DevOps Plan](https://ibm.com/docs/en/devops-plan/3.0.0)
- [Getting started with DevOps Plan Helm Chart](https://www.ibm.com/docs/en/devops-plan/3.0.0?topic=plan-getting-started-devops-helm-chart-openshift)

</p>
</details>

<details><summary>Supported Environments</summary>
<p>

The helm chart was tested in Kubernetes environments:

  - [Red Hat OpenShift on IBM Cloud](https://cloud.ibm.com/docs/openshift)

Supported Kubernetes Versions:

  - Kubernetes 1.16 and later

</p>
</details>
