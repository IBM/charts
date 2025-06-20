# Cognos Analytics Certified Containers 12.1.0


## Introduction
This Chart configures 

* IBM Cognos Analytics is a business intelligence (BI) platform that helps organizations analyze and interpret data to make better decisions. It provides tools for reporting, dashboarding, analysis, and event management, allowing users to explore data, create visualizations, and share insights
* Product description - [https://www.ibm.com/products/cognos-analytics]

## Chart Details
Chart will deploy Cognos Analytics Certified Containers in a cluster namespace.
The Chart will create a number of Kubernetes objects such as:

```
Deployments
Configmaps
HPA
PVCs
Routes
ServiceMonitors
Services
Statefulsets
```

## Prerequisites
* Kubernetes Version - "1.31.0 and above"
* OpenShift Version - "4.16 and above"

* Helm Level:
	X86: " 3.17.0 and above"
	https://helm.sh/docs/intro/install/


* PersistentVolume requirements - requires one of the following:
	- NFS
	- IBM Cloud File Storage (gold storage class)
 	- Google Storage
  	- Amazon Storage
  	- Azure Storage
	- Red Hat OpenShift Container Storage 4.3 and above
	- or a hostPath PV that is a mounted clustered filesystem

* For a full list of Cognos settings and configurations see the Cognos Analytics documentation.

## CA Services

The following is a list of the Cognos Analytics services that will appear when Cognos is deployed.

- CA Ingress Service
- Content Manager Service
- Reporting Service
- Rest Service
- UI Service
- Smarts Service
- Data Service
       
## Resources Required 

The minimum required to deploy Cognos Analytics Certified containers is

- 3 worker nodes
- Cores: 16 
- Memory: 32 GiB 

The following is an estimation of the compute resources for each of the Cognos Analytics services

| Pod | Cpu | Memory |
| --- | ----| -------|
| CM | 6000m| 13Gi|
| RS | 2000m| 10Gi|
| Rest| 2000m| 8Gi|
| UI | 2000m| 8Gi|
| Smarts| 2000m| 12Gi|
| DSS | 5000m| 10Gi|
| Proxy | 10m| 100m|
| Pinger | 10m| 10m|


## Red Hat OpenShift SecurityContextConstraints Requirements
Custom SecurityContextConstraints definition:
   Not applicable


## Installing the Chart

IBM Cognos Analytics Certified Containers helm chart is located at https://github.com/IBM/charts/tree/master/repo/ibm-helm.  
The name of the chart is ibm-cacc-prod-{HELM_CHART_VERSION}.tgz where HELM_CHART_VERSION is ibm-cacc-prod chart version starting from 1.0.0

### 1. Pre-install cluster configuration

Create a namespace of your desired name

```
$ export NAMESPACE=<desired name>

$ kubectl create namespace ${NAMESPACE}
```

Create the required secrets (secrets are managed outside of Helm). These are the mandatory secrets. These secrets will contain the credentials to log into the Content Store, Audit Store and Noticecast Store
  
```
$ kubectl create secret generic ca-cs-credentials-secret    --from-literal=username="${CS_USERNAME}"    --from-literal=password="${CS_PASSWORD}"    --type=kubernetes.io/basic-auth -n ${NAMESPACE}
$ kubectl create secret generic ca-audit-credentials-secret --from-literal=username="${AUDIT_USERNAME}" --from-literal=password="${AUDIT_PASSWORD}" --type=kubernetes.io/basic-auth -n ${NAMESPACE}
$ kubectl create secret generic ca-nc-credentials-secret    --from-literal=username="${NC_USERNAME}"    --from-literal=password="${NC_PASSWORD}"    --type=kubernetes.io/basic-auth -n ${NAMESPACE}
```

If you plan on using an email server requiring credentials, create the following secret
  
```
$ kubectl create secret generic ca-mailserver-credentials-secret --from-literal=username="" --from-literal=password=""  --type=kubernetes.io/basic-auth -n ${NAMESPACE}
```

If you plan on using an LDAP store requiring credentials, create the following secret

```
$ kubectl create secret generic ca-ldapbind-credentials-secret --from-literal=username=""  --from-literal=password=""  --type=kubernetes.io/basic-auth -n ${NAMESPACE}
```

If you plan on using an OpenId identity provider, create the following secret

```
$ kubectl create secret generic ca-openid-credentials-secret   --from-literal=username=""  --from-literal=password=""  --type=kubernetes.io/basic-auth -n ${NAMESPACE}
```

Note for the OpenId secret, use the ClientId for the Username, and the ClientSecret as the password.

### 2. Accessing IBM Container Registry
You can pull Cognos Analytics Certified Container images from the IBM Cloud Container Registry. You need to setup the environment to be able to access IBM Cloud Registry for this deployment.

Procedure
To obtain your IBM entitlement API key:

Log in to https://myibm.ibm.com/products-services/containerlibrary with the IBMid and password that are associated with the entitled software.
On the Entitlement keys tab, select Copy to copy the entitlement key to the clipboard.
Save the API key in a text file.

Similar to Step 1., once the entitlement key has been download, proceed to create a secret name regcred. This secret will contain the repository, username and pull key. The secret will be used by the Helm installer to access the IBM repository and pull the 
CA Certified Containers during the deployment phase.

For an Internet deployment (non-air-gapped), the CA Certified Container images will be pulled from cp.icr.io/cp/cognos. The username for this repository is cp. The password will be the IBM entitlement key (API key) that was saved.
```
$ export DOCKER_REPOSITORY=cp.icr.io/cp/cognos
$ export DOCKER_REPO_USERNAME=cp
$ export DOCKER_REPO_PASSWORD=<IBM entitlement key>

$ kubectl create secret docker-registry regcred --docker-server=${DOCKER_REPOSITORY} --docker-username=${DOCKER_REPO_USERNAME} --docker-password=${DOCKER_REPO_PASSWORD} -n ${NAMESPACE}
```

For an air-gapped installation, a tool such as Skopeo or Crane can be (Docker cp can also work) used to pull the images from cp.icr.io/cp/cognos to a private repository. Once the Cognos Analytics Certified Containers have been pulled, the regcred secret can be populated using the 
credentials for the private repository.

```
https://www.redhat.com/en/topics/containers/what-is-skopeo
https://github.com/google/go-containerregistry/tree/main/cmd/crane
```

```
$ export DOCKER_REPOSITORY=<private repo>
$ export DOCKER_REPO_USERNAME=<private repo username>
$ export DOCKER_REPO_PASSWORD=<private repo password>

$ kubectl create secret docker-registry regcred --docker-server=${DOCKER_REPOSITORY} --docker-username=${DOCKER_REPO_USERNAME} --docker-password=${DOCKER_REPO_PASSWORD} -n ${NAMESPACE}
```

If doing an installation from private repository, you'll need to override the repository pull location. This can be achieved quite easily by including the following as part of the runtime context.

```
image:
  registry: <private repo>
```

This will inform Helm chart to pull from a different location. The regcred secret will be used for the credentials.


### 3. Chart installation

Before initiating a Helm installation, it is recommended to create a Helm override yaml file that contains the runtime context values for the Cognos Analytics deployment. An example of a simple Cognos Analytics deployment allowing anonymous. 

```
# 
# Sample CA Helm override yaml file
#
serviceMonitors:
  createMonitors: false

securityContext:
  openshiftContext: false

ingress:
  createRoute: false
  createLoadBalancer: true

#
# Cognos Services Section
# 
services:

  contentManagerService:
    aaaAllowAnonymous: true

    # CA Audit Store
    auditDbClass: "Microsoft" 
    auditDbName: "audit"
    auditDbSsl: false
    auditDbHostname: "ca-audit-store"
    auditDbPort: 1433
    auditAdvancedProperties: "securityMechanism=3"

    # CA Content Store 
    contentDbClass: "Microsoft"
    contentDbName: "cm"
    contentDboracle_specifier: " "
    contentDbSsl: false
    contentDbHostname: "ca-cs"
    contentDbPort: 1433
    contentAdvancedProperties: "securityMechanism=3" 

    # CA Notification Store (configured to use Content Store)
    ncDbClass: "Microsoft"
    ncDbName: "cm"
    ncDboracle_specifier: " "
    ncDbSsl: false
    ncDbHostname: "ca-cs"
    ncDbPort: 1433
    ncAdvancedProperties: "securityMechanism=3"

```
Copy and paste the sample yaml into a file named caConfiguration.yaml. The sample yaml file references the secrets that were created in Pre-installation steps.

```
$ export OVERRIDE_FILE=caConfiguration.yaml

In an editor, open the caConfiguration.yaml file and update the fields to represent your local infrastructure. Repeat the same steps for the other two databases (contentDb and ncDb).

    auditDbClass                 Acceptable values are "Microsoft", "Oracle", "DB2", "Informix", "PostgreSQL"
    auditDbName:                 Specify the name of an existing database where the audit information will be written to
    auditDbSsl:                  Set to true, if the database connection requires an SSL connection. The default value is false
    auditDbHostname:             Specify the hostname where the database server resides.
    auditDbPort: 1433            Specify the port number that the database server listens on
    auditAdvancedProperties:     Provide additional advanced properties. For example "securityMechanism=3" in the case of Microsoft MsSQL. Format is "name=value;name=value"

* Once you have cloned the IBM Charts repo, navigate to the Cognos Analytics helm chart folder and initiate the install

$ export HELM_CHART_VERSION=1.0.1
$ helm install -f ${OVERRIDE_FILE} https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/ibm-cacc-prod-{HELM_CHART_VERSION}.tgz  --version {HELM_CHART_VERSION} --namespace ${NAMESPACE}
```


## Verifying the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release.

## Uninstalling the Chart

To delete the deployment:

```
$ helm delete --purge <RELEASE-NAME>
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions with additional commands required for clean-up.


To delete the pre-install configuration objects (secrets):

```
$ kubectl delete secret regcred -n ${NAMESPACE}
$ kubectl delete secret ca-cs-credentials-secret    -n ${NAMESPACE}
$ kubectl delete secret ca-audit-credentials-secret -n ${NAMESPACE}
$ kubectl delete secret ca-nc-credentials-secret    -n ${NAMESPACE}
$ kubectl delete secret ca-mailserver-credentials-secret -n ${NAMESPACE}
$ kubectl delete secret ca-ldapbind-credentials-secret   -n ${NAMESPACE}
$ kubectl delete secret ca-openid-credentials-secret     -n ${NAMESPACE}
```


## Configuration

The following tables lists the configurable parameters of the ibm-cacc chart and their default values.

## License, Image, Mail server configuration and Global settings
&nbsp;
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|license.accept|License acceptance. Must be set to true to deploy CACC|false|
|image.registry|Repository where CA images will be pulled from. Can be set to reference private repository.|cp.icr.io/cp/cognos|
|imagePullSecrets.name|Kubernetes Secret used to pull images from repository.|regcred|
|configs.mailServerConfiguration|Mail Server Configuration|false|
|configs.mailServerHostPort|specify the location of the mail server: host:port|""|
|configs.mailServerUseSsl|Is SSL required|false|
|configs.mailServerDefaultSender|Specifies the email address for Reply-To|"notifications@cognos.ibm.com"|
|configs.gatewayUri|Default Gateway URI|"http://localhost:9300/bi/v1/disp"|
|global.globalDefaultFont|Default font to use|"Andale"|
|global.globalEmailEncoding|Default encoding used by the system|"UTF-8"|
|global.globalServerTimeZoneID|What timezone should be specified for the system|"America/New_York"|
|global.globalServerLocale|What Locale should be used|"en"|
|global.globalCookieDomain|Specifies valid domain and/or host name values for your configuration|""|
|global.globalCookiePath|Cookie Path|""|
|global.globalCookieSecure|Set secure cookie|""|
|global.globalHealthCheckDetails|Health Check details|false|
|serviceMonitors.createMonitors|Defines which services should be monitored and how|true|
|securityContext.openshiftContext|Defines the privileges and access control settings for a pod or container|true|

## Secrets configuration settings
These configuration settings serve as a mapping table for secrets. The default values for each of the secrets is in the table below. If Corporate standard is a different naming convention, you can create the appropriate the secret name (as per corporate standard) and set the secret to reflect the new secret name.

&nbsp;

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|secretNames.cs_creds|Description|ca-cs-credentials-secret|
|secretNames.audit_creds|Description|ca-audit-credentials-secret|
|secretNames.nc_creds|Description|ca-nc-credentials-secret|
|secretNames.openid_creds|Description|ca-openid-credentials-secret|
|secretNames.ldapbind_creds|Description|ca-ldapbind-credentials-secret|
|secretNames.mailserver_creds|Description|ca-mailserver-credentials-secret|


## Ingress configuration settings
These configuration settings serve as ...

&nbsp;
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|ingress.createRoute|If set to true will Helm will create a Route. Mainly for Openshift. If deploying in Kubernetes, set this setting to false|true|
|ingress.createLoadBalancer|If set to true, will create a load balancer object for route traffic in to CACC instance. Mainly for Kubernetes (IKS, EKS, AKS, GKE, ...)|false|
|ingress.overrideHost|If set to true, Helm will override the hostname with the value specified below. Mainly for Openshift. |false|
|ingress.routeDomain|Provide a domain name for the route. Mainly for Openshift.|" "
|ingress.routeEnableTLS|If set to true, will enable TLS route. Mainly for Openshift.|false|
|ingress.routeHost|If provide will set the host name. By default the route (hostname) will be automatically create. Mainly for Openshift.|" "|
|ingress.tlsSecret|If provide, the Helm chart will use the values in the secret for certificate|frontdoor-tls-cert|


## Role and Service Account settings
These configuration settings can be enabled if deployment with Kubeadmin role. The Helm chart will create the Cognos Role and Service Account.
If deploying CACC as a non admin user, will need to have the cluster administrator create the Role and Service account along with namespace.

&nbsp;

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|deploy.cognosRole|If deploying CACC with a less privileged cluster account, may need to create the CognosRole external to Helm.|cognos-role|
|deploy.createCognosRole|If set to true, Helm will create the CognosRole. To manage the Cognos Role creation outside of Helm, set the value to false|true|
|deploy.createServiceAccount|If set to true, Helm will create the ServiceAccount. To manage the Service Account creation outside of Helm, set the value to false|true|
|deploy.serviceAccount|Name of the service account. The default name is cognos-account|cognos-account|


## Content Manager Service configuration settings
These configuration settings can be enabled to configure the Content Manager service.

&nbsp;

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.contentManagerService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.contentManagerService.aaaAllowAnonymous|Specifies whether anonymous access is allowed|false|
|services.contentManagerService.aaaInactivityTimeout|Specifies the maximum number of seconds that a user's session can remain inactive before they must re-authenticate.|3600|
|services.contentManagerService.aaaAdvancedProperties|Specifies a set of advanced properties|""|


### Content Manager Service CJAP configuration settings

&nbsp;

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.contentManagerService.cjapConfiguration|Defines a group of properties that allow the product to use a custom Java authentication provider for user authentication|false|
|services.contentManagerService.cjapInstanceName|Namepace name|""|
|services.contentManagerService.cjapNamespaceID|Specifies a unique identifier for the authentication namespace|""|
|services.contentManagerService.cjapAuthModule|Specify which authentication module the CJAP uses|""|
|services.contentManagerService.cjapTenantIdMapping|Specifies how namespace users are mapped to tenant IDs|""|
|services.contentManagerService.cjapTenantBoundingSetMapping|Specifies how the tenant bounding set is determined for a user.|""|


### Content Manager Service LDAP configuration settings

&nbsp;

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.contentManagerService.ldapConfiguration|Defines a group of properties that allows the product to access an LDAP server for user authentication|false|
|services.contentManagerService.ldapInstanceName|Specifies the name of the LDAP instance|"LDAP"|
|services.contentManagerService.ldapNamespaceID|Specifies a unique identifier for the authentication namespace|"LDAP"|
|services.contentManagerService.ldapHostname|Specifies the host namedirectory server|"localhost"|
|services.contentManagerService.ldapPor|Specifies the port of the directory server|389|
|services.contentManagerService.ldapBaseDistinguishedName|Specifies the base distinguished name of the LDAP server|"dc=example,dc=com"|
|services.contentManagerService.ldapUserLookup|Specifies the user lookup used for binding to the LDAP directory server|"(uid=${userID})"|
|services.contentManagerService.ldapUseBindCredentialsForSearch|Specifies whether to use the bind credentials to perform a search|true|
|services.contentManagerService.ldapSecure|Enable or disable encryption for the LDAP connections|false|
|services.contentManagerService.ldapTimeout:|Specifies the number of seconds permitted to perform a search request|0|
|services.contentManagerService.ldapTenantIdMapping|Specifies how namespace users are mapped to tenant IDs|" "|
|services.contentManagerService.ldapTenantBoundingSetMapping|Specifies how the tenant bounding set is determined for a user|" "|
|services.contentManagerService.ldapAdvancedProperties|Specifies a set of advanced properties|" "|
|services.contentManagerService.ldapCustomProperties|Specifies a set of custom properties|" "|


### Content Manager Service OpenId configuration settings

&nbsp;

| Parameter                  | Description                                                        | Default                                                    |
| -----------------------    | ---------------------------------------------                      | ---------------------------------------------------------- |
|services.contentManagerService.openIdConfiguration|Defines a group of properties that allows the product to use an OpenID Connect identity provider for user authentication|false|
|services.contentManagerService.openIdAccountClaims|Specifies if the id_token contains all of the account claims|"userinfo"|
|services.contentManagerService.openIdAccountCamIdProperty|Specify a property that contains a unique identifier for the user account|"email"|
|services.contentManagerService.openIdAcBusinessPhone|Specifies the OIDC claim used for the "businessPhone" property for an account|" "|
|services.contentManagerService.openIdAcContentLocale|Specifies the OIDC claim used for the "contentLocale" property for an account|" "|
|services.contentManagerService.openIdAcDescription|Specifies the OIDC claim used for the "description" property for an account|" "|
|services.contentManagerService.openIdAcEmail|Specifies the OIDC claim used for the "email" property for an account|"email"|
|services.contentManagerService.openIdAcEncoding|Configure the character encoding of the account|" "|
|services.contentManagerService.openIdAcGivenName|Specifies the OIDC claim used for the "givenName" property for an account|"given_name"|
|services.contentManagerService.openIdAcHomePhone|Specifies the OIDC claim used for the "homePhone" property for an account|" "|
|services.contentManagerService.openIdAcMobilePhone|Specifies the OIDC claim used for the "mobilePhone" property for an account|" "|
|services.contentManagerService.openIdAcName|Specifies the OIDC claim used for the "name" property for an account|"name"|
|services.contentManagerService.openIdAcPostalAddr|Specifies the OIDC claim used for the "postalAddress" property for an account|" "|
|services.contentManagerService.openIdAcProductLocale|Specifies the OIDC claim used for the "productLocale" property for an account|" "|
|services.contentManagerService.openIdAcSurname|Specifies the OIDC claim used for the "surname" property for an account|"family_name"|
|services.contentManagerService.openIdAcUsername|Specifies the OIDC claim used for the "userName" property for an account|"email"|
|services.contentManagerService.openIdAdvancedProperties|Specifies a set of advanced properties. Format is "name=value;name=value"|" "|
|services.contentManagerService.openIdAuthEndpoint|Specifies the OpenID Connect discovery endpoint"|
|services.contentManagerService.openIdAuthScope|Specifies the scope parameter values provided to the authorize endpoint|"email"|
|services.contentManagerService.openIdCertificateFile|Specify the client certificate file for OpenID communication|" "|
|services.contentManagerService.openIdCustomProperties|Specifies a set of custom properties. Format is "name=value;name=value"|" "|
|services.contentManagerService.openIdDiscEndpoint|Specifies the OpenID Connect discovery endpoint|" "|
|services.contentManagerService.openIdInstanceName|Namepace name|" "|
|services.contentManagerService.openIdIssuer|Specifies the implementation of an OpenID Connect identity provider|" "|
|services.contentManagerService.openIdKeyLocation|Specify the location of the OpenID provider's public key|"jwks_uri"|
|services.contentManagerService.openIdNamespaceId|Specifies a unique identifier for the authentication namespace|" "|
|services.contentManagerService.openIdRegistrationEndpoint|Provide a registration endpoint URL for the OpenID connections|" "|
|services.contentManagerService.openIdReturnUrl|Return URL that is configured with the OpenID Connect identity provider|"https://localhost:443/bi/completeAuth.jsp"|
|services.contentManagerService.openIdTcAccountClaims|Specify claims that the user account information must include|"userinfo"|
|services.contentManagerService.openIdTcStrategy|Specify the token strategy for the OpenID connections|"refreshToken"|
|services.contentManagerService.openIdTenantBoundingSetMapping|Specifies how the tenant bounding set is determined for a user|" "|
|services.contentManagerService.openIdTenantIdMapping|Specifies how namespace users are mapped to tenant IDs|" "|
|services.contentManagerService.openIdTokenEndpoint|Specify the token endpoint URL for the OpenID connections|" "|
|services.contentManagerService.openIdTokenEndpointAuthStrategy|Configure the authentication strategy for the token endpoint in OpenID connections|"client_secret_post"|
|services.contentManagerService.openIdUserInfoEndpoint|Specify the user information endpoint URL for the OpenID connections|" "|
|services.contentManagerService.openIdUseDiscEndpoint|Specify whether to use the discovery endpoint for retrieving the OpenID provider's configuration information|false|

### Content Manager Service DB Store configuration settings

&nbsp;

| Parameter                  | Description                                                        | Default                                                    |
| -----------------------    | ---------------------------------------------                      | ---------------------------------------------------------- |
|services.contentManagerService.auditDbClass|Specify the audit database. Possible values are "Microsoft", "Oracle", "DB2", "Informix", "PostgreSQL"|"Microsoft"|
|services.contentManagerService.auditDbName|Provide a name for the audit database|"audit""
|services.contentManagerService.auditDboracleSpecifier|Configure settings specific to Oracle|" "|
|services.contentManagerService.auditDbSsl|Enable or disable the SSL/TLS encryption for connections to the audit database|false|
|services.contentManagerService.auditDbHostname|Specify the hostname for the audit database|"ca-audit-store"|
|services.contentManagerService.auditDbPort|Specify the port number for connections to the audit database|1433|
|services.contentManagerService.auditAdvancedProperties|Provide advanced settings for the audit database configuration. Format is "name=value;name=value"|"securityMechanism=3"|
|services.contentManagerService.contentDbClass|Specify the Content Store database. Possible values are "Microsoft", "Oracle", "DB2", "Informix", "PostgreSQL"|"Microsoft"|
|services.contentManagerService.contentDbName|Provide a name for the Content Store database|"cm"|
|services.contentManagerService.contentDboracle_specifier|Configure settings specific to Oracle|" "|
|services.contentManagerService.contentDbSsl|Enable or disable the SSL/TLS encryption for connections to the Content Store database|false|
|services.contentManagerService.contentDbHostname|Specify the hostname for the Content Store|"ca-cs"|
|services.contentManagerService.contentDbPort|Specify the port number for connections to the Content Store database|1433|
|services.contentManagerService.contentAdvancedProperties|Provide advanced settings for the Content Store database configuration. Format is "name=value;name=value"|"securityMechanism=3"|
|services.contentManagerService.ncDbClass|Specify the Notice Cast database. Possible values are "Microsoft", "Oracle", "DB2", "Informix", "PostgreSQL"|"Microsoft"|
|services.contentManagerService.ncDbName|Provide a name for the Novice Cast database|"cm"|
|services.contentManagerService.ncDboracle_specifier|Configure settings specific to Oracle|" "|
|services.contentManagerService.ncDbSsl|Enable or disable the SSL/TLS encryption for connections to the Novice Cast database|false|
|services.contentManagerService.ncDbHostname|Specify the hostname for the Novice Cast database|"ca-cs"|
|services.contentManagerService.ncDbPort|Specify the port number for connections to the Novice Cast database|1433|
|services.contentManagerService.ncAdvancedProperties|Provide advanced settings for the Novice Cast database configuration. Format is "name=value;name=value"|"securityMechanism=3"|
|services.contentManagerService.dispatcherMemory|Specify the maximum amount of memory in MB for the dispatcher service|6144|
|services.contentManagerService.dispatcherCoreThreads|Specify the number of core threads for the dispatcher service|200|
|services.contentManagerService.dispatcherExecutorThread|Specify the number of executor threads for the dispatcher service|-1|
|services.contentManagerService.requestsCpu|Set the CPU request for the container|"4000m"|
|services.contentManagerService.requestsMemory|Set the memory request for the container|4Gi|
|services.contentManagerService.requestsEphemeralStorage|Set the ephemeral storage request for the container|5Gi|
|services.contentManagerService.limitsCpu|Set the CPU limit for the container|"8000m"|
|services.contentManagerService.limitsMemory|Set the memory limit for the container|8Gi|
|services.contentManagerService.limitsEphemeralStorage|Set the ephemeral storage limit for the container|10Gi|
|services.contentManagerService.bootstrap_params|Configure bootstrap parameters to customize the behavior of the application server during startup|""|
|services.contentManagerService.noopStart|Decide whether the application server starts in a no-operation mode|false|
|services.contentManagerService.verboseStartupLogging|Enable or disable a detailed startup logging|false|
|services.contentManagerService.brsMaxProcesses|Specify the maximum number of processes for the background request service|8|
|services.contentManagerService.brsAffine|Specify the number of affine processes for the background request service|2|
|services.contentManagerService.brsNonAffine|Specify the number of non-affine processes for the background request service|8|
|services.contentManagerService.rsMaxProcesses|Specify the maximum number of processes for the request service|8|
|services.contentManagerService.rsAffine|Specify the number of affine processes for the request service|2|
|services.contentManagerService.rsNonAffine|Specify the number of non-affine processes for the request service|8|
|services.contentManagerService.tempDirPVCenabled|Set to true if wanting to mount temp location to a pvc|false|
|services.contentManagerService.tempDirPVCStorageClassName|Description|"default"|
|services.contentManagerService.tempDirPVCStorageAccessModes|Description|"ReadWriteOnce"|
|services.contentManagerService.tempDirPVCStorageSize|Description|10Gi|
|services.contentManagerService.dataDirPVCenabled|Set to true if wanting to mount data location to a pvc|false|
|services.contentManagerService.dataDirPVCStorageClassName|Description|"default"|
|services.contentManagerService.dataDirPVCStorageAccessModes|Description|"ReadWriteOnce"|
|services.contentManagerService.dataDirPVCStorageSize|Description|10Gi|
|services.contentManagerService.deploymentDirPVCenabled|Set to true if wanting to mount deployment location to a pvc|false|
|services.contentManagerService.deploymentDirPVCStorageClassName|Description|"default"|
|services.contentManagerService.deploymentDirPVCStorageAccessModes|Description|"ReadWriteOnce"|
|services.contentManagerService.deploymentDirPVCStorageSize|Description|10Gi|
|services.contentManagerService.deploymentDirGKECloudStorageEnabled|Set to true if wanting to mount deployment location to a Google Bucket. Only applicable for Google Cloud storage|false|
|services.contentManagerService.deploymentDirGKECloudStorageBucketName|Name of the Google bucket|eca_deployment|
|services.contentManagerService.deploymentDirGKECloudStorageVolumeName|Name of the volume to use. The default is deployment-volume|deployment-volume|
|services.contentManagerService.deploymentDirGKECloudStorageMountOptions|Storage Mount Options|"implicit-dirs"|


## Reporting Service configuration settings
These configuration settings can be enabled to configure the 

&nbsp;

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.reportingService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.reportingService.dispatcherMemory|Specifies the maximum amount of memory in MB that can be used by the process|6144|
|services.reportingService.dispatcherCoreThreads|represents the number of threads that the WLP server starts up with|200|
|services.reportingService.dispatcherExecutorThread|represents the maximum number of threads that can be associated with the WLP server|-1|
|services.reportingService.cgsMaxMemory|Specify the maximum memory for the Content Generator Service (CGS)|500m|
|services.reportingService.requestsCpu|Set the CPU request for the container|"2000m"|
|services.reportingService.requestsMemory|Set the memory request for the container.|4Gi|
|services.reportingService.requestsEphemeralStorage|Set the ephemeral storage request for the container|5Gi|
|services.reportingService.limitsCpu|Set the CPU limit for the container|"6000m"
|services.reportingService.limitsMemory|Set the memory limit for the container|10Gi|
|services.reportingService.limitsEphemeralStorage|Set the ephemeral storage limit for the container|10Gi|
|services.reportingService.verboseStartupLogging|Enable or disable detailed startup logging|false|
|services.reportingService.rsvpMode|Specifies the Report Server execution mode.|"64-bit"|
|services.reportingService.tempDirPVCenabled|Set to true if wanting to mount temp location to a pvc|false|
|services.reportingService.tempDirPVCStorageClassName|Description|"default"|
|services.reportingService.tempDirPVCStorageAccessModes|Acceptatble values are ReadWriteOnce, ReadOnlyMany, ReadWriteMany, or ReadWriteOncePod|"ReadWriteOnce"|
|services.reportingService.tempDirPVCStorageSize|Description|10Gi|
|services.reportingService.dataDirPVCenabled|Set to true if wanting to mount data location to a pvc|false|
|services.reportingService.dataDirPVCStorageClassName|Description|"default"|
|services.reportingService.dataDirPVCStorageAccessModes|Description|"ReadWriteOnce"|
|services.reportingService.dataDirPVCStorageSize|Description|10Gi|
|services.reportingService.replicas|Number of Reporting service replicas to use on startup|1|
|services.reportingService.enableAutoscaling|Enable auto Horizontal Pod Autoscaling (HPA)|false|
|services.reportingService.minReplicas|The minimum number of replicas to which the autoscaler may scale.|1|
|services.reportingService.maxReplicas|he maximum number of replicas to which the autoscaler may scale.|2|
|services.reportingService.enableStabilizationWindow|Enable HPA Stabilization window. The stabilization window is used to restrict the flapping of replica count when the metrics used for scaling keep fluctuating. The autoscaling algorithm uses this window to infer a previous desired state and avoid unwanted changes to workload scale.|false|
|services.reportingService.scaleDownWindowSelectPolicy|This policy defines how the HPA scales down pods. The default policy allows all replicas to be removed if the condition for scaling down is met, meaning it can scale down to the minimum number of replicas specified in the HPA.|Min|
|services.reportingService.scaleDownStabilizationWindowSeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|300|
|services.reportingService.scaleDownWindowPolicyValue|Refers to a scaling policy that allows you to configure how many pods can be removed based on a percentage of the total number of pods at each scaling iteration|20|
|services.reportingService.scaleDownWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|15|
|services.reportingService.scaleUpWindowSelectPolicy|This policy defines how the HPA scales down pods. The default policy allows all replicas to be removed if the condition for scaling down is met, meaning it can scale down to the minimum number of replicas specified in the HPA.|Min|
|services.reportingService.scaleUpStabilizationWindowSeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|0|
|services.reportingService.scaleUpWindowPolicyValue|Refers to a scaling policy that allows you to configure how many pods can be removed based on a percentage of the total number of pods at each scaling iteration|80|
|services.reportingService.scaleUpWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|30|


## Rest Service configuration settings
These configuration settings can be enabled to configure the 

&nbsp;

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.restService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.restService.dispatcherMemory|Description|6144|
|services.restService.dispatcherCoreThreads|Description|200|
|services.restService.dispatcherExecutorThread|Description|-1|
|services.restService.requestsCpu|Description|"2000m"|
|services.restService.requestsMemory|Description|4Gi|
|services.restService.requestsEphemeralStorage|Description|5Gi|
|services.restService.limitsCpu|Description|"4000m"
|services.restService.limitsMemory|Description|6Gi|
|services.restService.limitsEphemeralStorage|Description|10Gi|
|services.restService.verboseStartupLogging|Description|false|
|services.restService.replicas|Number of Rest service replicas to use on startup|1|
|services.restService.enableAutoscaling|Enable auto Horizontal Pod Autoscaling (HPA)|false|
|services.restService.minReplicas|The minimum number of replicas to which the autoscaler may scale.|1|
|services.restService.maxReplicas|he maximum number of replicas to which the autoscaler may scale.|2|
|services.restService.enableStabilizationWindow|Enable HPA Stabilization window. The stabilization window is used to restrict the flapping of replica count when the metrics used for scaling keep fluctuating. The autoscaling algorithm uses this window to infer a previous desired state and avoid unwanted changes to workload scale.|false|
|services.restService.scaleDownWindowSelectPolicy|This policy defines how the HPA scales down pods. The default policy allows all replicas to be removed if the condition for scaling down is met, meaning it can scale down to the minimum number of replicas specified in the HPA.|Min|
|services.restService.scaleDownStabilizationWindowSeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|300|
|services.restService.scaleDownWindowPolicyValue|Refers to a scaling policy that allows you to configure how many pods can be removed based on a percentage of the total number of pods at each scaling iteration|20|
|services.restService.scaleDownWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|15|
|services.restService.scaleUpWindowSelectPolicy|This policy defines how the HPA scales down pods. The default policy allows all replicas to be removed if the condition for scaling down is met, meaning it can scale down to the minimum number of replicas specified in the HPA.|Min|
|services.restService.scaleUpStabilizationWindowSeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|0|
|services.restService.scaleUpWindowPolicyValue|Refers to a scaling policy that allows you to configure how many pods can be removed based on a percentage of the total number of pods at each scaling iteration|80|
|services.restService.scaleUpWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|30|


## User Interface Service configuration settings
These configuration settings can be enabled to configure the 

&nbsp;

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.uiService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.uiService.dispatcherMemory|Description|6144|
|services.uiService.dispatcherCoreThreads|Description|200|
|services.uiService.dispatcherExecutorThread|Description|-1|
|services.uiService.requestsCpu|Description|"2000m"|
|services.uiService.requestsMemory|Description|4Gi|
|services.uiService.requestsEphemeralStorage|Description|5Gi|
|services.uiService.limitsCpu|Description|"4000m"
|services.uiService.limitsMemory|Description|6Gi|
|services.uiService.limitsEphemeralStorage|Description|10Gi|
|services.uiService.verboseStartupLogging|Description|false|
|services.uiService.replicas|Number of User Interface service replicas to use on startup|1|
|services.uiService.enableAutoscaling|Enable auto Horizontal Pod Autoscaling (HPA)|false|
|services.uiService.minReplicas|The minimum number of replicas to which the autoscaler may scale.|1|
|services.uiService.maxReplicas|he maximum number of replicas to which the autoscaler may scale.|2|
|services.uiService.enableStabilizationWindow|Enable HPA Stabilization window. The stabilization window is used to restrict the flapping of replica count when the metrics used for scaling keep fluctuating. The autoscaling algorithm uses this window to infer a previous desired state and avoid unwanted changes to workload scale.|false|
|services.uiService.scaleDownWindowSelectPolicy|This policy defines how the HPA scales down pods. The default policy allows all replicas to be removed if the condition for scaling down is met, meaning it can scale down to the minimum number of replicas specified in the HPA.|Min|
|services.uiService.scaleDownStabilizationWindowSeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|300|
|services.uiService.scaleDownWindowPolicyValue|Refers to a scaling policy that allows you to configure how many pods can be removed based on a percentage of the total number of pods at each scaling iteration|20|
|services.uiService.scaleDownWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|15|
|services.uiService.scaleUpWindowSelectPolicy|This policy defines how the HPA scales down pods. The default policy allows all replicas to be removed if the condition for scaling down is met, meaning it can scale down to the minimum number of replicas specified in the HPA.|Min|
|services.uiService.scaleUpStabilizationWindowSeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|0|
|services.uiService.scaleUpWindowPolicyValue|Refers to a scaling policy that allows you to configure how many pods can be removed based on a percentage of the total number of pods at each scaling iteration|80|
|services.uiService.scaleUpWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|30|

## Smarts Service configuration settings
These configuration settings can be enabled to configure the 

&nbsp; 

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.smartsService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.smartsService.dispatcherMemory|Description|6144|
|services.smartsService.dispatcherCoreThreads|Description|200|
|services.smartsService.dispatcherExecutorThread|Description|-1|
|services.smartsService.requestsCpu|Description|"2000m"|
|services.smartsService.requestsMemory|Description|5Gi|
|services.smartsService.requestsEphemeralStorage|Description|5Gi|
|services.smartsService.limitsCpu|Description|"6000m"
|services.smartsService.limitsMemory|Description|8Gi|
|services.smartsService.limitsEphemeralStorage|Description|10Gi|
|services.smartsService.verboseStartupLogging|Description|false|
|services.smartsService.replicas|Number of Smarts service replicas to use on startup|1|
|services.smartsService.enableAutoscaling|Enable auto Horizontal Pod Autoscaling (HPA)|false|
|services.smartsService.minReplicas|The minimum number of replicas to which the autoscaler may scale.|1|
|services.smartsService.maxReplicas|he maximum number of replicas to which the autoscaler may scale.|2|
|services.smartsService.enableStabilizationWindow|Enable HPA Stabilization window. The stabilization window is used to restrict the flapping of replica count when the metrics used for scaling keep fluctuating. The autoscaling algorithm uses this window to infer a previous desired state and avoid unwanted changes to workload scale.|false|
|services.smartsService.scaleDownWindowSelectPolicy|This policy defines how the HPA scales down pods. The default policy allows all replicas to be removed if the condition for scaling down is met, meaning it can scale down to the minimum number of replicas specified in the HPA.|Min|
|services.smartsService.scaleDownStabilizationWindowSeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|300|
|services.smartsService.scaleDownWindowPolicyValue|Refers to a scaling policy that allows you to configure how many pods can be removed based on a percentage of the total number of pods at each scaling iteration|20|
|services.smartsService.scaleDownWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|15|
|services.smartsService.scaleUpWindowSelectPolicy|This policy defines how the HPA scales down pods. The default policy allows all replicas to be removed if the condition for scaling down is met, meaning it can scale down to the minimum number of replicas specified in the HPA.|Min|
|services.smartsService.scaleUpStabilizationWindowSeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|0|
|services.smartsService.scaleUpWindowPolicyValue|Refers to a scaling policy that allows you to configure how many pods can be removed based on a percentage of the total number of pods at each scaling iteration|80|
|services.smartsService.scaleUpWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|30|


## Data Service configuration settings
These configuration settings can be enabled to configure the 

&nbsp;

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.dataService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.dataService.dispatcherMemory|Description|6144|
|services.dataService.dispatcherCoreThreads|Description|200|
|services.dataService.dispatcherExecutorThread|Description|-1|
|services.dataService.dqMaxMemory|Adjust memory for Dynamic Query process|5120|
|services.dataService.dqCoreThreads|Adjust core threads for Dynamic Query process|200|
|services.dataService.dqExecutorThreads|Adjust executor threads for Dynamic Query process|-1|
|services.dataService.flintMaxMemory|Adjust memory for Flint process|1024m|
|services.dataService.requestsCpu|Description|"2000m"|
|services.dataService.requestsMemory|Description|12Gi|
|services.dataService.requestsEphemeralStorage|Description|5Gi|
|services.dataService.limitsCpu|Description|"6000m"
|services.dataService.limitsMemory|Description|16Gi|
|services.dataService.limitsEphemeralStorage|Description|10Gi|
|services.dataService.verboseStartupLogging|Description|false|
|services.dataService.replicas|Number of Data service replicas to use on startup|1|
|services.dataService.enableAutoscaling|Enable auto Horizontal Pod Autoscaling (HPA)|false|
|services.dataService.minReplicas|The minimum number of replicas to which the autoscaler may scale.|1|
|services.dataService.maxReplicas|he maximum number of replicas to which the autoscaler may scale.|2|
|services.dataService.enableStabilizationWindow|Enable HPA Stabilization window. The stabilization window is used to restrict the flapping of replica count when the metrics used for scaling keep fluctuating. The autoscaling algorithm uses this window to infer a previous desired state and avoid unwanted changes to workload scale.|false|
|services.dataService.scaleDownWindowSelectPolicy|This policy defines how the HPA scales down pods. The default policy allows all replicas to be removed if the condition for scaling down is met, meaning it can scale down to the minimum number of replicas specified in the HPA.|Min|
|services.dataService.scaleDownStabilizationWindowSeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|300|
|services.dataService.scaleDownWindowPolicyValue|Refers to a scaling policy that allows you to configure how many pods can be removed based on a percentage of the total number of pods at each scaling iteration|20|
|services.dataService.scaleDownWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|15|
|services.dataService.scaleUpWindowSelectPolicy|This policy defines how the HPA scales down pods. The default policy allows all replicas to be removed if the condition for scaling down is met, meaning it can scale down to the minimum number of replicas specified in the HPA.|Min|
|services.dataService.scaleUpStabilizationWindowSeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|0|
|services.dataService.scaleUpWindowPolicyValue|Refers to a scaling policy that allows you to configure how many pods can be removed based on a percentage of the total number of pods at each scaling iteration|80|
|services.dataService.scaleUpWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|30|


## Limitations
