# Cognos Analytics Certified Containers 12.1.3


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
* Kubernetes Version - "1.27.0 and above"
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

- CA Proxy Service
- Content Manager Service
- Reporting Service
- Rest Service
- UI Service
- Smarts Service
- Data Service
- Agentic Service(optional) 
       
## Resources Required 

The minimum required to deploy Cognos Analytics Certified containers is

- 3 worker nodes
- Cores: 16 
- Memory: 32 GiB 

## The following is an estimation of the compute resources for each of the Cognos Analytics services
|  Pod Name              | Cpu Requests | Cpu Limits | Mem Requests | Mem Limits |
|:---|---:|---:|---:|---:|
| ca-cm                  |     4,200m    |   8,400m    |    4,200Mi    |  8,800Mi    |
| ca-reporting           |     2,200m    |   6,400m    |    4,200Mi    | 11,800Mi    |
| ca-rest                |     2,200m    |   4,400m    |    4,200Mi    |  6,800Mi    |
| ca-ui                  |     3,200m    |   3,400m    |    4,200Mi    |  6,800Mi    |
| ca-smarts              |     2,200m    |   5,400m    |    5,200Mi    |  8,800Mi    |
| ca-dss                 |     2,200m    |   6,400m    |    6,200Mi    | 11,800Mi    |
| caproxy                |      400m    |   1,000m    |     200Mi    |   8,00Mi    |
| ca-agentic-ai (optional)|    2,000m    |   5,000m    |    5,120Mi    | 10,240Mi    |
|              |              |            |              |            |
| Total (Required)       |    16,300m    |  35,400m    |   28,400Mi    | 53,600Mi    |
| Total (with Agentic AI)        |    18,300m    |  40,400m    |   33,520Mi    | 63,840Mi    |

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

If you plan on plan have Agentic-AI service, create the following secret

```
kubectl create secret generic ca-opensearch-credentials-secret --from-literal=username="admin" --from-literal=password="YourSecurePassword123!" --type=kubernetes.io/basic-auth -n ${NAMESPACE}
```

Note for the OpenSearch secret: users can modify the password, but it must be sufficiently complex; otherwise, OpenSearch will report an error.

#### TLS Certificate Setup for HTTPS Deployment (Optional)

If you plan to enable HTTPS and agentic serivce, you need to configure TLS certificates using your own certificate and key:

Step 1: Export Certificate and Key Paths

```bash
export TLS_CERT_PATH="<path_to_your_certificate_file>"
export TLS_KEY_PATH="<path_to_your_private_key_file>"
```

Step 2: Create TLS Secret for caproxy-frontdoor Service

This secret is used by the caproxy-frontdoor service to enable HTTPS connections:

```bash
kubectl delete secret frontdoor-tls-cert -n ${NAMESPACE} 2>/dev/null || true
kubectl create secret tls frontdoor-tls-cert \
    --cert="${TLS_CERT_PATH}" \
    --key="${TLS_KEY_PATH}" \
    -n ${NAMESPACE}

if [ $? -eq 0 ]; then
    echo "✓ TLS secret 'frontdoor-tls-cert' created successfully"
else
    echo "Error: Failed to create TLS secret"
    exit 1
fi
```

Step 3: Create CA Bundle ConfigMap for Agentic AI Pod

This ConfigMap allows the ca-agentic-ai pod to trust the custom certificate chain when making HTTPS requests to CA services:
```bash
kubectl delete configmap ca-certificates -n ${NAMESPACE} 2>/dev/null || true
kubectl create configmap ca-certificates \
    --from-file=ca-bundle.crt="${TLS_CERT_PATH}" \
    -n ${NAMESPACE}

if [ $? -eq 0 ]; then
    echo "✓ ConfigMap 'ca-certificates' created successfully"
    echo "Note: ca-agentic-ai pod will mount this to trust the custom certificate chain"
else
    echo "Warning: Failed to create CA bundle ConfigMap"
fi
```

Certificate Requirements:
- Certificate must include all necessary SANs (Subject Alternative Names) for your services, including the caproxy-frontdoor-service hostname
- Certificate should contain the full chain: server cert + intermediate CA + root CA
- This works with any enterprise or customer-signed certificates (IBM, DigiCert, etc.)
- Ensure the certificate is in PEM format
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
Before initiating a Helm installation, it is recommended to create a Helm override yaml file that contains the runtime context values for the Cognos Analytics deployment. An example of a simple Cognos Analytics deployment allowing anonymous. The following example is for a Kubernetes deployment (createMonitors: false, openshiftContext: false, createRoute: false). If deploying on Openshift the serviceMonitors, securityContext and ingress do not need to be specified as the default configuration is for Openshift platform.
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

  # CA Agentic AI service
  agenticAIService:
    enabled: true

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

$ export NAMESPACE=ns1
$ export HELM_CHART_VERSION=1.1.0

$ helm install -f ${OVERRIDE_FILE} ca-instance https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/ibm-cacc-prod-{HELM_CHART_VERSION}.tgz  --version {HELM_CHART_VERSION} --namespace ${NAMESPACE}
```
## Verifying the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release.
## Uninstalling the Chart
To delete the deployment:
```
$ helm delete --purge <RELEASE-NAME> -n <NAMESPACE>
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
## Configuration Data PVC
The Configuration data is an optional PVC. When enabled, it will persist the configuration/data. The PVC must be created with an accessMode of ReadWriteMany. Note if a PVC is specified, and the PVC doesn't not exist, Helm will stop the deployment and report an error. 

Note if a PVC is specified, and the PVC doesn't not exist, Helm will stop the deployment and report an error, similar to the following

Error: INSTALLATION FAILED: execution error at (ibm-cacc-prod/templates/checks/configDataCheck.yaml:24:10): The provided PVC configdata-pvc does NOT exist in the namespace <namespace>

When the Configuration PVC is provided, the configuration0.properties file, which holds advanced properties set via the "Manage > Configuration > System" UI (Glass URI) in Cognos Analytics and facilitates synchronization across distributed servers, will be persisted. If the Configuration PVC is not configured, the CM configuration data will NOT be persisted and will be lost when the CM pod restarts.
```
configs:
  pvcConfigData:
```
## Deployment PVC
The Deployment PVC is an optional PVC. The PVC can be preloaded with Cognos Analytics deployment file and will available to import into CA content store. In addition, CA content can also be exported and the resultant file will be written to the deployment folder. The PVC must be created with an accessMode of ReadWriteMany.

Note if a PVC is specified, and the PVC doesn't not exist, Helm will stop the deployment and report an error, similar to the following

Error: INSTALLATION FAILED: execution error at (ibm-cacc-prod/templates/checks/deploymentCheck.yaml:24:10): The provided PVC deployment-pvc does NOT exist in the namespace cacc <namespace>

The Cognos Analytics PVC is the designated repository for importing and exporting content archives (compressed .zip files) between environments. It serves as the central bridge for content mobility, enabling the transfer of packages, reports, folders, and configuration data across environments, such as from development to testing or production.
```
configs:
  pvcDeployment:
``` 
## External Object Storage PVC
The External Object Storage (EOS) is an optional PVC. You can configure Content Manager to store report output and datasets to a Network drive (is NFS) or S3 storage via a PVC. Report output is available through the portal and IBM® Cognos® SDK, but the report output is not stored in the content store database. The PVC must be created with an accessMode of ReadWriteMany

Note if a PVC is specified, and the PVC doesn't not exist, Helm will stop the deployment and report an error, similar to the following

Error: INSTALLATION FAILED: execution error at (ibm-cacc-prod/templates/checks/eosCheck.yaml:24:10): The provided PVC eos-pvc does NOT exist in the namespace <namespace>
```
configs:
  pvcExternalObjectStorage:
```
## Powercube PVC
The Powercube is an optional PVC. You can provide Cognos Powercubes (*.mdc) which be made available to the Reporting service. Note, the Report Service will need to be configured to 32-bit.
The PVC must be created with an accessMode of ReadWriteOnce

Note if a PVC is specified, and the PVC doesn't not exist, Helm will stop the deployment and report an error, similar to the following

Error: INSTALLATION FAILED: execution error at (ibm-cacc-prod/templates/checks/powercubeObjectCheck.yaml:25:10): The provided PVC powercubes-pvc does NOT exist in the namespace <namespace>

Cognos Analytics supports external object storage (such as Amazon S3, Azure Blob Storage, or IBM Cloud Object Storage) to manage data and optimize performance. Users can create connections, store uploaded files, save data sets as parquet files, store SSL certificates for data servers, and archive report outputs. It enhances scalability and reduces content store size.
```
configs:
  pvcPowercubes:
```
## Artifacts PVC
The Artifacts PVC is an optional PVC that provides JDBC drivers, certificates, fonts, images, templates, UDFs, webcontent, and other resources to CACC services. When configured, artifacts are automatically mounted to Content Manager, DSS, Reporting, Smarts, and UI services at `/opt/ibm/cognos/artifacts/`.

**Access Mode:** The PVC can be created with either `ReadWriteOnce` (RWO) or `ReadWriteMany` (RWX) access mode. Use RWX for multi-node deployments with block storage, or RWO for single-node or NFS-based storage.
https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes

**Note:** If a PVC is specified and does not exist, Helm will stop the deployment and report an error:
```
Error: INSTALLATION FAILED: execution error at (ibm-cacc-prod/templates/checks/artifactsObjectCheck.yaml:24:10): The provided PVC artifact-pvc does NOT exist in the namespace <namespace>
```

To register the Artifacts PVC with your CACC instance, provide the PVC name in the `configs.pvcArtifactsRootFolder` setting. When CACC deploys, the artifacts will be automatically ingested into the services.

### Required Folder Structure
The artifacts PVC must contain the following directories:
```
/artifacts/certs            # Certificate files (*.arm, *.cer, *.pem, *.crt)
/artifacts/cjap             # Custom Java Authentication Provider (*.jar)
/artifacts/configuration    # Configuration folders/files (*.properties, *.json)
/artifacts/pre-config-scripts  # Executable scripts for CM that run before Cognos configuration
/artifacts/post-config-scripts # Executable scripts for CM that run after Cognos configuration
/artifacts/csdrivers        # Content Store Drivers (*.jar)
/artifacts/dsdrivers        # Data Store Drivers (*.jar)
/artifacts/fonts            # Fonts for Reporting Service (*.ttf)
/artifacts/images           # Images for Reporting Service (*.gif, *.jpg, *.jpeg, *.png, *.svg, *.svgz, *.ico)
/artifacts/templates        # Custom templates (all folders and files copied to analytics/templates)
/artifacts/udfs             # User Defined Functions for DSS Service (*.jar)
/artifacts/webcontent       # Custom webcontent (all folders and files copied to analytics/webcontent)
```
### Quick Setup
1. Create the PVC (choose RWO or RWX based on your storage and deployment architecture):
```bash
kubectl create -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: artifact-pvc
  namespace: <namespace>
spec:
  accessModes:
    - ReadWriteMany  # Use ReadWriteOnce for single-node or NFS; ReadWriteMany for multi-node with block storage
  storageClassName: <storage-class>
  resources:
    requests:
      storage: 5Gi
EOF
```
2. Create Artifacts Manager Deployment:
```bash
kubectl create -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: artifacts-manager
  namespace: <namespace>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: artifacts-manager
  template:
    metadata:
      labels:
        app: artifacts-manager
    spec:
      containers:
      - name: artifacts-container
        image: icr.io/cp/cognos/ubi:latest
        command: ["/bin/sh", "-c", "sleep infinity"]
        volumeMounts:
        - name: artifact-volume
          mountPath: /artifacts
      volumes:
      - name: artifact-volume
        persistentVolumeClaim:
          claimName: artifact-pvc
EOF
```
3. Create folder structure and populate artifacts:
```bash
# Wait for pod to be ready
kubectl wait --for=condition=ready pod -l app=artifacts-manager -n <namespace> --timeout=120s

# Get pod name
POD_NAME=$(kubectl get pods -n <namespace> -l app=artifacts-manager -o jsonpath='{.items[0].metadata.name}')

# Create folder structure
for dir in certs cjap configuration csdrivers dsdrivers fonts images templates udfs webcontent; do
  kubectl exec ${POD_NAME} -n <namespace> -- mkdir -p /artifacts/${dir}
done

# Populate the artifact pvc with various objects(examples) 
kubectl cp ./drivers/db2jcc4.jar ${POD_NAME}:/artifacts/dsdrivers/db2jcc4.jar -n <namespace>
kubectl cp ./fonts/custom.ttf ${POD_NAME}:/artifacts/fonts/custom.ttf -n <namespace>
```
4. Configure Helm values:
```yaml
configs:
  pvcArtifactsRootFolder: artifact-pvc
```
5. Deploy/upgrade CACC - artifacts will be automatically ingested into services.
```bash
helm upgrade -f ${OVERRIDE_FILE} ca-instance \
https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/ibm-cacc-prod-{HELM_CHART_VERSION}.tgz \
--version {HELM_CHART_VERSION} \
--namespace ${NAMESPACE}
```
## Temporary Storage PVC
Cognos Analytics services generate temporary files during operation (session data, report outputs, data processing). By default, these files use ephemeral container storage, which can lead to:
- Excessive ephemeral storage consumption
- Pod evictions due to storage pressure
- Loss of temporary data during pod restarts

To address these issues, you can configure persistent temporary storage using the following optional PVC parameters. All temporary storage PVCs must be created with an accessMode of ReadWriteOnce.
### Content Manager Temporary Storage (pvcCmTmp)
Optional PVC for Content Manager temporary storage (session data, temp files). When not configured, temporary files use ephemeral container storage.
- **Mount Path:** `/opt/ibm/cognos/analytics/temp`
- **Access Mode:** ReadWriteOnce
- **Recommended Size:** 10-20Gi

Note if a PVC is specified, and the PVC doesn't not exist, Helm will stop the deployment and report an error, similar to the following

Error: INSTALLATION FAILED: execution error at (ibm-cacc-prod/templates/checks/tmpPvcChecks.yaml:24:10): The provided PVC cm-tmp-pvc does NOT exist in the namespace <namespace>

```
configs:
  pvcCmTmp:
```
### Reporting Service Temporary Storage (pvcReportingTmp)
Optional PVC for Reporting Service temporary storage (report outputs, temp processing). Recommended for high-volume reporting environments. Fast SSD storage recommended.
- **Mount Path:** `/opt/ibm/cognos/analytics/temp`
- **Access Mode:** ReadWriteOnce
- **Recommended Size:** 20-50Gi

Note if a PVC is specified, and the PVC doesn't not exist, Helm will stop the deployment and report an error, similar to the following

Error: INSTALLATION FAILED: execution error at (ibm-cacc-prod/templates/checks/tmpPvcChecks.yaml:24:10): The provided PVC reporting-tmp-pvc does NOT exist in the namespace <namespace>
```
configs:
  pvcReportingTmp:
```
### Dataset Service Temporary Storage (pvcDssTmp)
Optional PVC for Dataset Service temporary storage (data processing, temp datasets). Recommended for high-volume data processing. Fast SSD storage recommended.
- **Mount Path:** `/opt/ibm/cognos/analytics/temp`
- **Access Mode:** ReadWriteOnce
- **Recommended Size:** 20-50Gi

Note if a PVC is specified, and the PVC doesn't not exist, Helm will stop the deployment and report an error, similar to the following

Error: INSTALLATION FAILED: execution error at (ibm-cacc-prod/templates/checks/tmpPvcChecks.yaml:24:10): The provided PVC dss-tmp-pvc does NOT exist in the namespace <namespace>
```
configs:
  pvcDssTmp:
```
**Benefits of Persistent Temporary Storage:**
- Better storage management and monitoring
- Persistent temporary storage across pod restarts
- Reduced ephemeral storage pressure
- Easier maintenance and cleanup operations

## Additional Olap Properties
> **⚠️ DEPRECATION NOTICE:** Using ConfigMap for configuration properties is deprecated. ConfigMap does not support subfolders and has limitations with complex configurations. **It is recommended to use the Artifacts PVC `/artifacts/configuration` folder instead**, which supports both files and subfolders. See the [Artifacts PVC](#artifacts-pvc) section for details.

The Olap Properties is an optional ConfigMap (deprecated - use Artifacts PVC instead). For example, if additional configuration properties are required to query to Planning Analytics (TM1), a configmap can be created. Here's an example of passing specific properties to

Include the properties in a properties file (tm1RestCustom.properties)
```
# Force MDX operators like FilterSet to be processed by the Database/Native MDX engine even when Local processing LOLAP is turned on
v5.enableFilterSetOptimization=true

# If the dataset size exceeds the configurable threshold then allow the MDX operator to be processed by the 
# Database/Native MDX engine even when Local processing LOLAP is turned on
v5.topCountFunctionsOptimization.datasetSize=10000
```
```
kubectl create configmap customproperties --from-file=tm1RestCustom.properties -n <namespace>
```
Once the configmap is created, provide the configmap name in the override yaml file.

Note if a configmap is specified, and the configmap doesn't not exist, Helm will stop the deployment and report an error, similar to the following

Error: INSTALLATION FAILED: execution error at (ibm-cacc-prod/templates/checks/customConfigCheck.yaml:24:10): The provided ConfigMap customproperties does NOT exist in the namespace <namespace>
```
configs:
  configMapCustomProperties:
```
## Configuration

The following tables lists the configurable parameters of the ibm-cacc chart and their default values.
## License, Image, Mail server configuration and Global settings
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|license.accept|License acceptance. Must be set to true to deploy CACC|false|
|image.registry|Repository where CA images will be pulled from. Can be set to reference private repository.|cp.icr.io/cp/cognos|
|imagePullSecrets.name|Kubernetes Secret used to pull images from repository.|regcred|
|              |              |            |
|configs.mailServerConfiguration|Mail Server Configuration|false|
|configs.mailServerHostPort|Specify the location of the mail server: host:port|""|
|configs.mailServerUseSsl|Is SSL required|false|
|configs.mailServerDefaultSender|Specifies the email address for Reply-To|"notifications@cognos.ibm.com"|
|configs.gatewayUri|Default Gateway URI|"http://localhost:9300/bi/v1/disp"|
|configs.enableCustomConfigScripts|Enable execution of CM custom pre/post configuration scripts from `/opt/ibm/cognos/artifacts/pre-config-scripts` and `/opt/ibm/cognos/artifacts/post-config-scripts`|false|
|configs.pvcArtifactsRootFolder|Specify a PVC that references an artifact endpoint. Used to pass in JDBC Drivers, Fonts, Images, ...|""|
|configs.pvcExternalObjectStorage|Specify a PVC that references external storage where CA objects will be stored|""|
|configs.pvcDeployment|Specify a PVC that references where Cognos Analytics deployments can be read/written to|""|
|configs.pvcPowercubes|Specify a PVC that references where Cognos Powercubes can be read from|""|
|configs.pvcConfigData|Specify a PVC that references where Cognos Configuration data can be persisted to|""|
|configs.pvcCmTmp|Specify a PVC for Content Manager temporary storage (session data, temp files). Optional. Recommended size: 10-20Gi|""|
|configs.pvcReportingTmp|Specify a PVC for Reporting Service temporary storage (report outputs, temp processing). Optional. Recommended size: 20-50Gi. Fast SSD recommended|""|
|configs.pvcDssTmp|Specify a PVC for Dataset Service temporary storage (data processing, temp datasets). Optional. Recommended size: 20-50Gi. Fast SSD recommended|""|
## Advanced Properties Configuration
Advanced Cognos properties can be configured for Content Manager Service, Reporting Service, and Data Service. These properties are injected into the cogstartup.xml configuration file as advancedSettings parameters during container startup.
### Content Manager Service Advanced Properties
Configure advanced settings for the Content Manager Service using the `configs.contentManagerService.advancedProperties` section:
```yaml
configs:
  contentManagerService:
    advancedProperties:
      CM.CMSERVERBENCHMARKING: "false"
      CM.DBMAXUPDATECMIDS: "1000"
      CM.DBMAXUPDATECMPROPS: "1000"
      CM.DBMAXUPDATECMREFNOORD: "1000"
      CM.DBMAXUPDATECMREFNOORD2: "1000"
      CM.DBMAXUPDATECMREFNOORD3: "1000"
```
### Reporting Service Advanced Properties
Configure advanced settings for the Reporting Service using the `configs.reportService.advancedProperties` section:
```yaml
configs:
  reportService:
    advancedProperties:
      RSVP.BURST_DISTRIBUTION: "true"
      RSVP.CSV.ENCODING: "UTF-8"
      RSVP.CSV.QUALIFIER: '"'
      RSVP.CSV.SEPARATOR: ","
      RSVP.EXCEL.MAXROWSPERSHEET: "65536"
      RSVP.EXCEL.MAXWORKSHEETS: "255"
      RSVP.EXCEL.WORKBOOKTYPE: "singleSheet"
      RSVP.EXCEL2007.MAXROWSPERSHEET: "1048576"
      RSVP.EXCEL2007.MAXWORKSHEETS: "255"
      RSVP.EXCEL2007.WORKBOOKTYPE: "singleSheet"
      RSVP.REPORT_TIMEOUT: "0"
      RSVP.XSLFO.ENCODING: "UTF-8"
      RSVP.XSLFO.FORMATTER: "FOP"
      RSVP.XSLFO.VERSION: "1.1"
```
### Data Service Advanced Properties
Configure advanced settings for the Data Service using the `configs.dataService.advancedProperties` section:
```yaml
configs:
  dataService:
    advancedProperties:
      qs.queryExecution.flintServer.maxHeap: "8192"
      qs.queryExecution.flintServer.minHeap: "1024"
      qs.queryExecution.cgsServer.maxHeap: "4096"
      qs.queryExecution.cgsServer.minHeap: "512"
      qs.queryExecution.dqServer.maxHeap: "4096"
      qs.queryExecution.dqServer.minHeap: "512"
```
### How Advanced Properties Work
1. Properties are defined in the Helm values.yaml file under the respective service section
2. During Helm deployment, properties are converted to environment variables with prefixes:
   - Content Manager: `CM_ADV_` prefix
   - Reporting Service: `RS_ADV_` prefix  
   - Data Service: `DS_ADV_` prefix
3. At container startup, a processing script reads these environment variables
4. The script generates XSLT transformations to inject the properties into cogstartup.xml
5. Properties appear in the `<advancedSettings>` section of cogstartup.xml
### Property Naming Convention
- Use dot notation for property names (e.g., `CM.DBMAXUPDATECMIDS`)
- Dots in property names are automatically converted to underscores in environment variables
- Property values can be strings, numbers, or booleans
- All properties are validated against the JSON schema
### Example: Complete Configuration
```yaml
configs:
  contentManagerService:
    advancedSettings:
      CM.CMSERVERBENCHMARKING: "false"
      CM.DBMAXUPDATECMIDS: "1000"
  
  reportService:
    advancedSettings:
      RSVP.REPORT_TIMEOUT: "0"
      RSVP.CSV.ENCODING: "UTF-8"
  
  dataService:
    advancedSettings:
```
## IPF Logging Configuration
The IBM Product Framework (IPF) logging properties control how Cognos Analytics services log messages. These properties can be configured independently for Content Manager Service, Reporting Service, and Data Service.

### IPF Logging Properties
| Parameter | Description | Default | Valid Range |
|-----------|-------------|---------|-------------|
| `ipfEnableTCPConnection` | Use TCP (`true`) or UDP (`false`) for communication between product components and the log server. | `false` | boolean |
| `ipfWorkerThreads` | Maximum number of threads on the local log server for processing incoming log messages. More threads = more memory used. | `10` | 1-20 |
| `ipfFile.appenderMaxSize` | Maximum log file size in MB. When exceeded, a new backup file is created. | `10` | 1-50 |
| `ipfFile.appenderRollOver` | Maximum number of backup log files. When exceeded, the oldest is deleted. Backups use sequential extensions. | `20` | 1+ |
| `ipfFile.useUTF8Encoding` | Use UTF-8 encoding for log messages (`true`). If `false`, native encoding is used. | `false` | boolean |

### Configuration Examples

#### Content Manager Service Logging
```yaml
configs:
  contentManagerService:
    ipfEnableTCPConnection: false
    ipfWorkerThreads: 10
    ipfFile.appenderMaxSize: 10
    ipfFile.appenderRollOver: 20
    ipfFile.useUTF8Encoding: false
```
#### Reporting Service Logging
```yaml
configs:
  reportService:
    ipfEnableTCPConnection: false
    ipfWorkerThreads: 15
    ipfFile.appenderMaxSize: 25
    ipfFile.appenderRollOver: 30
    ipfFile.useUTF8Encoding: true
```
#### Data Service Logging
```yaml
configs:
  dataService:
    ipfEnableTCPConnection: false
    ipfWorkerThreads: 10
    ipfFile.appenderMaxSize: 20
    ipfFile.appenderRollOver: 25
    ipfFile.useUTF8Encoding: false
```
### Use Cases
**High-Volume Production Environment:**
```yaml
ipfWorkerThreads: 20              # Maximum threads for log processing
ipfFile.appenderMaxSize: 50       # Maximum 50MB per log file
ipfFile.appenderRollOver: 10      # Keep 10 backup files
# Total log storage: 50MB × 11 files = 550MB maximum
```
**Debugging with Complete History:**
```yaml
ipfEnableTCPConnection: true      # Use TCP for guaranteed delivery
ipfWorkerThreads: 15              # More threads for processing
ipfFile.appenderMaxSize: 25       # 25MB per file
ipfFile.appenderRollOver: 50      # Keep 50 backups
ipfFile.useUTF8Encoding: true     # UTF-8 for international characters
# Total log storage: 25MB × 51 files = 1.275GB maximum
```
**Low-Resource Environment:**
```yaml
ipfWorkerThreads: 5               # Fewer threads to save memory
ipfFile.appenderMaxSize: 10       # Smaller log files
ipfFile.appenderRollOver: 5       # Fewer backups
# Total log storage: 10MB × 6 files = 60MB maximum
```
### TCP vs UDP Considerations
**Use TCP (`ipfEnableTCPConnection: true`) when:**
- Critical logging where message loss is unacceptable
- Debugging scenarios requiring complete log capture
- Network environments with high packet loss
- Compliance requirements mandate complete audit trails

**Use UDP (`ipfEnableTCPConnection: false`) when:**
- Performance is critical (UDP has lower overhead)
- Occasional log message loss is acceptable
- Network is reliable
- Default production scenarios

For a complete list of available advanced properties, refer to the IBM Cognos Analytics documentation.
| Parameter | Description | Default |
|-----------|-------------|---------|
|configs.configMapCustomProperties|Specify a ConfigMap that references additional configuration properties for CA services|""|
|configs.brsAuditLevel|Audit level for Batch Report Service (BRS). Valid values: basic, full, minimal, request, trace|basic|
|configs.brsAuditNativeQuery|Audit the native query for Batch Report Service (BRS). When true, the native SQL sent to data sources is included in audit records.|false|
|configs.brsAffineConnections|Maximum number of affine connections for Batch Report Service (BRS). Affine connections maintain session affinity to a specific BRS process.|4|
|configs.brsMaximumProcesses|Maximum number of BRS processes that can run concurrently for batch report generation.|2|
|configs.brsNonAffineConnections|Maximum number of non-affine connections for Batch Report Service (BRS). Non-affine connections can be routed to any available BRS process.|10|
|configs.brsExecutionTimeLimit|Execution time limit for BRS (0 = unlimited).|0|
|configs.brsMaximumEMailAttachmentSize|Maximum email attachment size for BRS (MB).|15|
|configs.brsChartHotspotLimit|Chart hotspot limit for Batch Report Service. `-1` = unlimited (process all hotspots); `0` = no hotspots; any positive integer = exact limit (e.g. `5000`).|5000|
|configs.aasAuditLevel|Audit level for Agentic AI Service (AAS). Valid values: basic, full, minimal, request, trace|basic|
|configs.asAuditLevel|Audit level for Agent Service (AS). Valid values: basic, full, minimal, request, trace|basic|
|configs.aasAffineConnections|Maximum number of affine connections for Agentic AI Service (AAS).|1|
|configs.aasNonAffineConnections|Maximum number of non-affine connections for Agentic AI Service (AAS).|4|
|configs.ansAuditLevel|Audit level for Annotation Service (ANS). Valid values: basic, full, minimal, request, trace|basic|
|configs.periodicalDocumentVersionRetentionAge|Retention age for periodical document versions. Must be a valid ISO 8601 duration string beginning with 'P'. Valid examples: P1D (1 day), P7D (7 days), P14D|P1D|
|configs.temporaryObjectLifetime|Lifetime for temporary objects. Must be a valid ISO 8601 duration string beginning with 'P'. Valid examples: PT1H (1 hour), PT4H (4 hours). Temporary objects older than this age are eligible for cleanup.|"PT4H"|
|configs.cmsAuditLevel|Audit level for Content Manager Service (CMS). Valid values: basic, full, minimal, request, trace|basic|
|configs.cmsConnections|Maximum number of connections for Content Manager Service during normal periods.|4|
|configs.dasAuditLevel|Audit level for Data Access Service (DAS). Valid values: basic, full, minimal, request, trace|basic|
|configs.dimsAuditLevel|Audit level for Data Integration Metadata Service (DIMS). Valid values: basic, full, minimal, request, trace|basic|
|configs.disAuditLevel|Audit level for Dispatcher Service (DIS). Valid values: basic, full, minimal, request, trace|basic|
|configs.disConnections|Maximum number of connections for Dispatcher Service during normal periods.|4|
|configs.dsAuditLevel|Audit level for Delivery Service (DS). Valid values: basic, full, minimal, request, trace|basic|
|configs.dmsAuditLevel|Audit level for Data Movement Service (DMS). Valid values: basic, full, minimal, request, trace|basic|
|configs.emsAuditLevel|Audit level for Event Management Service (EMS). Valid values: basic, full, minimal, request, trace|basic|
|configs.emsConnections|Maximum number of connections for Event Management Service during normal periods.|4|
|configs.evsAuditLevel|Audit level for Event Viewer Service (EVS). Valid values: basic, full, minimal, request, trace|basic|
|configs.htsAuditLevel|Audit level for Human Task Service (HTS). Valid values: basic, full, minimal, request, trace|basic|
|configs.idVizAuditLevel|Audit level for Interactive Data Visualization Service (idViz). Valid values: basic, full, minimal, request, trace|basic|
|configs.issAuditLevel|Audit level for Index Search Service (ISS). Valid values: basic, full, minimal, request, trace|basic|
|configs.iusAuditLevel|Audit level for Index Update Service (IUS). Valid values: basic, full, minimal, request, trace|basic|
|configs.jsAuditLevel|Audit level for Job Service (JS). Valid values: basic, full, minimal, request, trace|basic|
|configs.gsAuditLevel|Audit level for Graphics Service (GS). Valid values: basic, full, minimal, request, trace|basic|
|configs.idsAuditLevel|Audit level for Index Data Service (IDS). Valid values: basic, full, minimal, request, trace|basic|
|configs.jsConnections|Maximum number of connections for Job Service during normal periods.|20|
|configs.jsPeakConnections|Maximum number of connections for Job Service during peak demand period.|20|
|configs.qsAuditLevel|Audit level for Query Service (QS). Valid values: basic, full, minimal, request, trace|basic|
|configs.qsDiagnosticsEnabled|Enable diagnostics for Query Service.|false|
|configs.qsMetricsEnabled|Enable metrics collection for Query Service.|false|
|configs.qsQueryExecutionTrace|Enable query execution tracing for Query Service.|false|
|configs.qsQueryPlanningTrace|Enable query planning tracing for Query Service.|false|
|configs.qsIdleConnectionTimeout|Idle connection timeout in seconds for Query Service.|300|
|configs.qsDisableQueryPlanCache|Disable query plan caching for Query Service.|false|
|configs.qsDumpModelToFile|Dump model to file for debugging in Query Service.|false|
|configs.qsGenerateCommentsInNativeSQL|Generate comments in native SQL for Query Service.|false|
|configs.qsGCPolicy|Garbage collection policy for Query Service. Valid values: Generational, Balanced|Generational|
|configs.qsAdditionalJVMArguments|Additional JVM arguments for the Query Service (Requires QueryService restart).||
|configs.qsInitialJVMHeapSize|Initial JVM heap size for Query Service in MB.|1024|
|configs.qsJVMHeapSizeLimit|JVM heap size limit for Query Service in MB.|8192|
|configs.mdsAuditLevel|Audit level for Metadata Service (MDS). Valid values: basic, full, minimal, request, trace|basic|
|configs.cmcsAuditLevel|Audit level for Content Manager Cache Service (CMCS). Valid values: basic, full, minimal, request, trace|basic|
|configs.ppsAuditLevel|Audit level for PowerPlay Service (PPS). Valid values: basic, full, minimal, request, trace|basic|
|configs.prsAuditLevel|Audit level for Presentation Service (PRS). Valid values: basic, full, minimal, request, trace|basic|
|configs.ssAuditLevel|Audit level for System Service (SS). Valid values: basic, full, minimal, request, trace|basic|
|configs.pdsAuditLevel|Audit level for Planning Data Service (PDS). Valid values: basic, full, minimal, request, trace|basic|
|configs.pdsConnections|Maximum number of connections for Planning Data Service (PDS) during normal periods.|4|
|configs.dispatcherAuditLevel|Audit level for Dispatcher. Valid values: basic, full, minimal, request, trace|basic|
|configs.msAuditLevel|Audit level for Migration Service (MS). Valid values: basic, full, minimal, request, trace|basic|
|configs.pacsAuditLevel|Audit level for Planning Analytics Cube Service (PACS). Valid values: basic, full, minimal, request, trace|basic|
|configs.psAuditLevel|Audit level for Presentation Service (PS). Valid values: basic, full, minimal, request, trace|basic|
|configs.ptsAuditLevel|Audit level for Planning Task Service (PTS). Valid values: basic, full, minimal, request, trace|basic|
|configs.reposAuditLevel|Audit level for Repository Service (REPOS). Valid values: basic, full, minimal, request, trace|basic|
|configs.saCAMAuditLevel|Audit level for SA CAM Service. Valid values: basic, full, minimal, request, trace|basic|
|configs.lsAuditNativeQuery|Audit the native query for Log Service (LS). When true, the native SQL sent to data sources is included in audit records.|false|
|configs.rdsAuditLevel|Audit level for Report Data Service (RDS). Valid values: basic, full, minimal, request, trace|basic|
|configs.mbsAuditLevel|Audit level for Mobile Service (MBS). Valid values: basic, full, minimal, request, trace|basic|
|configs.mmsAuditLevel|Audit level for Monitor Service (MMS). Valid values: basic, full, minimal, request, trace|basic|
|configs.mmsConnections|Maximum number of connections for Monitor Service during normal periods.|4|
|configs.misAuditLevel|Audit level for Metadata Integration Service (MIS). Valid values: basic, full, minimal, request, trace|basic|
|configs.rmdsAffineConnections|Maximum number of affine connections for Relational Metadata Service (RMDS).|1|
|configs.rmdsAuditLevel|Audit level for Relational Metadata Service (RMDS). Valid values: basic, full, minimal, request, trace|basic|
|configs.rmdsExecutionTimeLimit|Execution time limit for Relational Metadata Service (RMDS) in seconds. 0 means no limit.|0|
|configs.rmdsNonAffineConnections|Maximum number of non-affine connections for Relational Metadata Service (RMDS).|4|
|configs.rmdsPeakAffineConnections|Maximum number of affine connections for Relational Metadata Service (RMDS) during peak demand period.|1|
|configs.rmdsPeakNonAffineConnections|Maximum number of non-affine connections for Relational Metadata Service (RMDS) during peak demand period.|4|
|configs.cmsPeakConnections|Maximum number of connections for Content Manager Service during peak demand period.|4|
|configs.defaultProcessUseLimit|Default process use limit before recycling.|100|
|configs.dispatcherAffineConnections|Maximum number of affine connections for Dispatcher Service. Affine connections maintain session affinity to a specific dispatcher process.|null|
|configs.dispatcherMaximumProcesses|Maximum number of Dispatcher Service processes that can run concurrently.|null|
|configs.dispatcherNonAffineConnections|Maximum number of non-affine connections for Dispatcher Service. Non-affine connections can be routed to any available dispatcher process.|null|
|configs.dispatcherPeakAffineConnections|Maximum number of affine connections for Dispatcher Service during peak demand period.|null|
|configs.dispatcherPeakMaximumProcesses|Maximum number of Dispatcher Service processes during peak demand period.|null|
|configs.dispatcherPeakNonAffineConnections|Maximum number of non-affine connections for Dispatcher Service during peak demand period.|null|
|configs.dispatcherPeakPeriodEndHour|Peak period end hour for Dispatcher (0-23).|null|
|configs.dispatcherPeakPeriodEndMinute|Peak period end minute for Dispatcher (0-59).|null|
|configs.dispatcherPeakPeriodStartHour|Peak period start hour for Dispatcher (0-23).|null|
|configs.dispatcherPeakPeriodStartMinute|Peak period start minute for Dispatcher (0-59).|null|
|configs.dispatcherPeakPeriodWeekdayMask|Weekday mask for Dispatcher peak period (bit mask: Sun=1, Mon=2, Tue=4, Wed=8, Thu=16, Fri=32, Sat=64).|null|
|configs.idleProcessCheckIntervalMs|Interval in milliseconds to check for idle processes.|60000|
|configs.idleProcessMaxIdleTicks|Maximum number of idle ticks before process termination.|10|
|configs.p2pdDeployDefaultsDispatcherCmPoolsize|Dispatcher CM pool size for deployment defaults.|30|
|configs.p2pdDeployDefaultsWpCacheSize|WP cache size for deployment defaults.|30|
|configs.rsAuditLevel|Audit level for Report Service (RS). Valid values: basic, full, minimal, request, trace|basic|
|configs.rsAuditNativeQuery|Audit the native query for Report Service (RS). When true, the native SQL sent to data sources is included in audit records.|false|
|configs.rsAffineConnections|Maximum number of affine connections for Report Service (RS). Affine connections maintain session affinity to a specific RS process.|4|
|configs.rsExecutionTimeLimit|Execution time limit for RS (0 = unlimited).|0|
|configs.rsMaximumEMailAttachmentSize|Maximum email attachment size for RS (MB).|15|
|configs.rsChartHotspotLimit|Chart hotspot limit for Report Service. `-1` = unlimited (process all hotspots); `0` = no hotspots; any positive integer = exact limit (e.g. `5000`).|5000|
|configs.rsMaximumProcesses|Maximum number of RS processes that can run concurrently for report generation.|2|
|configs.rsNonAffineConnections|Maximum number of non-affine connections for Report Service (RS). Non-affine connections can be routed to any available RS process.|10|
|configs.gsMaximumProcesses|Maximum number of Graphics Service processes.|2|
|configs.gsAffineConnections|Maximum number of affine connections for Graphics Service.|1|
|configs.gsNonAffineConnections|Maximum number of non-affine connections for Graphics Service.|50|
|configs.gsPeakMaximumProcesses|Maximum number of Graphics Service processes during peak demand period.|2|
|configs.gsPeakAffineConnections|Maximum number of affine connections for Graphics Service during peak demand period.|1|
|configs.gsPeakNonAffineConnections|Maximum number of non-affine connections for Graphics Service during peak demand period.|50|
|configs.gsExecutionTimeLimit|Execution time limit for Graphics Service (0 = unlimited).|0|
|configs.dsMaximumEMailSize|Maximum email size in KB that Delivery Service can send. 0 = unlimited.|0|
|configs.dsCompressAttachmentLimit|Size threshold in KB for compressing email attachments sent by Delivery Service. 0 = no compression, positive value = compress attachments larger than this size.|0|
|configs.xtsPropertiesFunctionCacheSize|Function cache size for XTS properties.|30|
|configs.xtsPropertiesLogicSheetCacheSize|Logic sheet cache size for XTS properties.|60|
|configs.xtsPropertiesNodeopCacheSize|Nodeop cache size for XTS properties.|30|
|configs.xtsPropertiesRequestCacheSize|Request cache size for XTS properties.|30|
|configs.xtsPropertiesTemplateCacheSize|Template cache size for XTS properties.|100|
|configs.xtsPropertiesTransformCacheSize|Transform cache size for XTS properties.|45|
|global.globalDefaultFont|Default font to use|"Andale"|
|global.globalEmailEncoding|Default encoding used by the system|"UTF-8"|
|global.globalServerTimeZoneID|What timezone should be specified for the system|"America/New_York"|
|global.globalServerLocale|What Locale should be used|"en"|
|global.globalCookieDomain|Specifies valid domain and/or host name values for your configuration|""|
|global.globalCookiePath|Cookie Path|""|
|global.globalCookieSecure|Set secure cookie|""|
|global.cookieCAMPassportHttpOnly|Set HTTP-only flag for CAM Passport cookie to prevent client-side script access.|false|
|global.globalHealthCheckDetails|Health Check details|false|

## Service Monitors and Openshift Security Context Constraints (SCC)
OpenShift Security Context Constraints (SCCs) are critical objects that define policies controlling pod/container permissions and security settings, such as running as root, accessing host volumes, or using specific user IDs.
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|serviceMonitors.createMonitors|The ServiceMonitor specifies how groups of application services should be monitored and scraped for metrics by Prometheus.|true|
|securityContext.openshiftContext|Defines the privileges and access control settings for a pod or container. Set to false if deploying in a Kubernetes environment.|true|
## Secrets configuration settings
These configuration settings serve as a mapping table for secrets. The default values for each of the secrets is in the table below. If Corporate standard is a different naming convention, you can create the appropriate the secret name (as per corporate standard) and set the secret to reflect the new secret name.
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|secretNames.cs_creds|Secret that contains Content Store Credentials|ca-cs-credentials-secret|
|secretNames.audit_creds|Secret that contains Audit Store Credentials|ca-audit-credentials-secret|
|secretNames.nc_creds|Secret that contains NoticeCast Credentials|ca-nc-credentials-secret|
|secretNames.openid_creds|Secret that contains ClientId and Client Secret for OpenId provider|ca-openid-credentials-secret|
|secretNames.ldapbind_creds|Secret that contains LDAP Bind Credentials|ca-ldapbind-credentials-secret|
|secretNames.mailserver_creds|Secret that contains MailServer credentials|ca-mailserver-credentials-secret|

Note if a secret is specified, and the secret doesn't not exist, Helm will stop the deployment and report an error
## Ingress configuration settings
These configuration settings serve as ...
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
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|deploy.cognosRole|If deploying CACC with a less privileged cluster account, may need to create the CognosRole external to Helm.|cognos-role|
|deploy.createCognosRole|If set to true, Helm will create the CognosRole. To manage the Cognos Role creation outside of Helm, set the value to false|true|
|deploy.createServiceAccount|If set to true, Helm will create the ServiceAccount. To manage the Service Account creation outside of Helm, set the value to false|true|
|deploy.serviceAccount|Name of the service account. The default name is cognos-account|cognos-account|

## Content Manager Service configuration settings
These configuration settings can be enabled to configure the Content Manager service.
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.contentManagerService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.contentManagerService.digest|Modify only if asked to do so by Cognos Support person|Current image digest is included in the Helm chart|
|services.contentManagerService.aaaAllowAnonymous|Specifies whether anonymous access is allowed|false|
|services.contentManagerService.aaaInactivityTimeout|Specifies the maximum number of seconds that a user's session can remain inactive before they must re-authenticate.|3600|
|services.contentManagerService.aaaAdvancedProperties|Specifies a set of advanced properties|""|

## Content Manager Service CJAP configuration settings
These configuration settings can be provided to enable a Custom Java Authentication Provider (CJAP) as an authentication source. Refer to the Artifact section on how to 
include the CJAP implementation (*.jar) and configuration files.
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.contentManagerService.cjapConfiguration|Defines a group of properties that allow the product to use a custom Java authentication provider for user authentication|false|
|services.contentManagerService.cjapAdvancedProperties|Specifies a set of advanced properties|" "|
|services.contentManagerService.cjapInstanceName|Namepace name|""|
|services.contentManagerService.cjapNamespaceID|Specifies a unique identifier for the authentication namespace|""|
|services.contentManagerService.cjapAuthModule|Specify which authentication module the CJAP uses|""|
|services.contentManagerService.cjapTenantIdMapping|Specifies how namespace users are mapped to tenant IDs|""|
|services.contentManagerService.cjapTenantBoundingSetMapping|Specifies how the tenant bounding set is determined for a user.|""|

## Content Manager Service CJAP Adapter configuration settings
These configuration settings can be provided to enable a Custom Java Authentication Provider (CJAP) Adapter service as an authentication source. Refer to the Artifact section on how to 
include the CJAP implementation (*.jar) and configuration files. The CJAP Adapter provides a mechanism to export a CJAP as an OpenId provider.

## Content Manager Service LDAP configuration settings
These configuration settings can be provided to enable a Lightweight Directory Access Protocol (LDAP) V3 as an authentication source.
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.contentManagerService.ldapConfiguration|Defines a group of properties that allows the product to access an LDAP server for user authentication|false|
|services.contentManagerService.ldapInstanceName|Specifies the name of the LDAP instance|"LDAP"|
|services.contentManagerService.ldapNamespaceID|Specifies a unique identifier for the authentication namespace|"LDAP"|
|services.contentManagerService.ldapHostname|Specifies the hostname directory server|"localhost"|
|services.contentManagerService.ldapPort|Specifies the port of the directory server|389|
|services.contentManagerService.ldapBaseDistinguishedName|Specifies the base distinguished name of the LDAP server|"dc=example,dc=com"|
|services.contentManagerService.ldapUserLookup|Specifies the user lookup used for binding to the LDAP directory server|"(uid=${userID})"|
|services.contentManagerService.ldapUseBindCredentialsForSearch|Specifies whether to use the bind credentials to perform a search|true|
|services.contentManagerService.ldapSecure|Enable or disable encryption for the LDAP connections|false|
|services.contentManagerService.ldapTimeout|Specifies the number of seconds permitted to perform a search request|0|
|services.contentManagerService.ldapTenantIdMapping|Specifies how namespace users are mapped to tenant IDs|" "|
|services.contentManagerService.ldapTenantBoundingSetMapping|Specifies how the tenant bounding set is determined for a user|" "|
|services.contentManagerService.ldapAdvancedProperties|Specifies a set of advanced properties|" "|
|services.contentManagerService.ldapCustomProperties|Specifies a set of custom properties|" "|
|services.contentManagerService.ldapUserExternalIdentity|Specifies whether to use the identity from an external source for user authentication.| false|
|services.contentManagerService.ldapExternalIdentityMapping|Specifies the mapping pattern for external identity when ldapUserExternalIdentity is enabled.| " "|
|services.contentManagerService.ldapSizeLimit|Specifies the maximum number of responses permitted for a search request.| 1|
|services.contentManagerService.ldapAllowEmptyPassword|Specifies whether empty passwords are allowed for user authentication.| false|
|services.contentManagerService.ldapCamIdAttribute|Specifies the value used to uniquely identify objects stored in the LDAP directory server.| "dn"|
|services.contentManagerService.ldapDataEncoding|Specifies the encoding of the data stored in the LDAP directory server.| "UTF-8"|
|services.contentManagerService.ldapSelectableForAuth|Specifies whether the namespace is selectable for authentication.| true|
|services.contentManagerService.ldapAccountObjectClass|Specifies the name of the LDAP object class used to identify an account.| "inetorgperson"|
|services.contentManagerService.ldapAccountBusinessPhone|Specifies the LDAP attribute used for the "businessPhone" property for an account.| "telephonenumber"|
|services.contentManagerService.ldapAccountContentLocale|Specifies the LDAP attribute used for the "contentLocale" property for an account.| "preferredlanguage"|
|services.contentManagerService.ldapAccountDescription|Specifies the LDAP attribute used for the "description" property for an account.| "description"|
|services.contentManagerService.ldapAccountEmail|Specifies the LDAP attribute used for the "email" address of the account.| "mail"|
|services.contentManagerService.ldapAccountFaxPhone|Specifies the LDAP attribute used for the "faxPhone" property for an account.| "facsimiletelephonenumber"|
|services.contentManagerService.ldapAccountGivenName|Specifies the LDAP attribute used for the "givenName" property for an account.| "givenname"|
|services.contentManagerService.ldapAccountHomePhone|Specifies the LDAP attribute used for the "homePhone" property for an account.| "homephone"|
|services.contentManagerService.ldapAccountMobilePhone|Specifies the LDAP attribute used for the "mobilePhone" property for an account.| "mobile"|
|services.contentManagerService.ldapAccountName|Specifies the LDAP attribute used for the "name" property for an account.| "cn"|
|services.contentManagerService.ldapAccountPagerPhone|Specifies the LDAP attribute used for the "pagerPhone" property for an account.| "pager"|
|services.contentManagerService.ldapAccountPassword|Specifies the LDAP attribute used for the "password" property for an account.| "userPassword"|
|services.contentManagerService.ldapAccountPostalAddress|Specifies the LDAP attribute used for the "postalAddress" property for an account.| "postaladdress"|
|services.contentManagerService.ldapAccountProductLocale|Specifies the LDAP attribute used for the "productLocale" property for an account.| "preferredlanguage"|
|services.contentManagerService.ldapAccountSurname|Specifies the LDAP attribute used for the "surname" property for an account.| "sn"|
|services.contentManagerService.ldapAccountUserName|Specifies the LDAP attribute used for the "userName" property for an account.| "uid"|
|services.contentManagerService.ldapFolderObjectClass|Specifies the name of the LDAP object class used to identify a folder.| "organizationalunit"|
|services.contentManagerService.ldapFolderDescription|Specifies the LDAP attribute used for the "description" property of a folder.| "description"|
|services.contentManagerService.ldapFolderName|Specifies the LDAP attribute used for the "name" property of a folder.| "ou"|
|services.contentManagerService.ldapGroupObjectClass|Specifies the name of the LDAP object class used to identify a group.| "groupofuniquenames"|
|services.contentManagerService.ldapGroupDescription|Specifies the LDAP attribute used for the "description" property of a group.| "description"|
|services.contentManagerService.ldapGroupMembers|Specifies the LDAP attribute used to identify the members of a group.| "uniquemember"|
|services.contentManagerService.ldapGroupName|Specifies the LDAP attribute used for the "name" property of a group.| "cn"|
|services.contentManagerService.ldapSslCertificateDatabase|Specifies the path to the SSL certificate database for secure LDAP connections.| ""|
|services.contentManagerService.ldapWorkerThreadCount|Specifies the number of worker threads for LDAP operations. Can be tuned based on expected load.| 512|

## Content Manager Service OpenId configuration settings
These configuration settings can be provided to enable an OpenID Provider as an authentication source.
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
|services.contentManagerService.openIdAcFaxPhone|Specifies the OIDC claim used for the "faxPhone" property for an account.|No Default|
|services.contentManagerService.openIdAcGivenName|Specifies the OIDC claim used for the "givenName" property for an account|"given_name"|
|services.contentManagerService.openIdAcHomePhone|Specifies the OIDC claim used for the "homePhone" property for an account|" "|
|services.contentManagerService.openIdAcMemberOf|Specifies the OIDC claim used for the "memberOf" property for an account.|No Default|
|services.contentManagerService.openIdAcMobilePhone|Specifies the OIDC claim used for the "mobilePhone" property for an account|" "|
|services.contentManagerService.openIdAcName|Specifies the OIDC claim used for the "name" property for an account|"name"|
|services.contentManagerService.openIdAcPagerPhone|Specifies the OIDC claim used for the "pagerPhone" property for an account|"name"|
|services.contentManagerService.openIdAcPostalAddr|Specifies the OIDC claim used for the "postalAddress" property for an account|" "|
|services.contentManagerService.openIdAcProductLocale|Specifies the OIDC claim used for the "productLocale" property for an account|" "|
|services.contentManagerService.openIdAcSurname|Specifies the OIDC claim used for the "surname" property for an account|"family_name"|
|services.contentManagerService.openIdAcUsername|Specifies the OIDC claim used for the "userName" property for an account|"email"|
|services.contentManagerService.openIdAdvancedProperties|Specifies a set of advanced properties. Format is "name=value;name=value"|" "|
|services.contentManagerService.openIdAuthEndpoint|Specifies the OpenID Connect discovery endpoint"|
|services.contentManagerService.openIdAuthScope|Specifies the scope parameter values provided to the authorize endpoint|"email"|
|services.contentManagerService.openIdCertificateFile|Specify the client certificate file for OpenID communication|" "|
|services.contentManagerService.openIdCustomProperties|Specifies a set of custom properties. Format is "name=value;name=value"|" "|
|services.contentManagerService.openIdDiscEndpoint|Specifies the OpenID Connect discovery endpoint. Provides automatic discovery of authorization endpoints, token endpoints, supported scopes, and public keys for signing, eliminating manual configuration. |" "|
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
|services.contentManagerService.openIdProxyAccountClaims|Specify claims that the user account information must include for OpenID Proxy|"userinfo"|
|services.contentManagerService.openIdProxyCustomProperties|Specify custom properties for OpenID Proxy connections|" "|
|services.contentManagerService.openIdProxyAuthScope|Specify the authentication scope for OpenID Proxy connections|"email"|
|services.contentManagerService.openIdProxyClaimName|Specify the claim name for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyClass|Specify the class for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyClientId|Specify the client ID for OpenID Proxy connections|" "|
|services.contentManagerService.openIdProxyClientSecret|Specify the client secret for OpenID Proxy connections|" "|
|services.contentManagerService.openIdProxyConfiguration|Enable or disable OpenID Proxy configuration|false|
|services.contentManagerService.openIdProxyId|Specify the ID for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyIdentityProviderType|Specify the identity provider type for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyCertificateFile|Specify the IDP certificate file for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyIssuer|Specify the issuer for OpenID Proxy connections|" "|
|services.contentManagerService.openIdProxyJwksEndpoint|Specify the JWKS endpoint URL for OpenID Proxy connections|" "|
|services.contentManagerService.openIdProxyKeyLocation|Specify the key location for OpenID Proxy connections|"jwks_uri"|
|services.contentManagerService.openIdProxyName|Specify the name for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyNamespaceId|Specify the namespace ID for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyOidcAuthEndpoint|Specify the OIDC authentication endpoint URL for OpenID Proxy connections|" "|
|services.contentManagerService.openIdProxyDiscEndpoint|Specify the OIDC discovery endpoint URL for OpenID Proxy connections|" "|
|services.contentManagerService.openIdProxyPgAddParams|Specify any additional parameters that are required for the password grant flow for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyPgInclScope|Specify that the scope should be included when using the password grant flow for OpenID Proxy|true|
|services.contentManagerService.openIdProxyPgStrategy|Specify how to get the user's identity when using the password grant flow for OpenID Proxy|"idToken"|
|services.contentManagerService.openIdProxyPrivateKeyFile|Specify the file that contains the private signing key for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyPrivateKeyId|Specify the key identifier that should be placed in the JWT header for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyPrivateKeyPassword|Specify the private key password for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyRedirectNsID|Specify the redirect namespace ID for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyReturnUrl|Specify the return URL for OpenID Proxy connections|"https://localhost:443/bi/completeAuth.jsp"|
|services.contentManagerService.openIdProxySelectableForAuth|Specify whether OpenID Proxy is selectable for authentication|true|
|services.contentManagerService.openIdProxyTcAccountClaims|Specify claims that the user account information must include for OpenID Proxy|"userinfo"|
|services.contentManagerService.openIdProxyTcStrategy|Specify the token strategy for OpenID Proxy connections|"refreshToken"|
|services.contentManagerService.openIdProxyTokenEndpoint|Specify the token endpoint URL for OpenID Proxy connections|" "|
|services.contentManagerService.openIdProxyTokenEndpointAuth|Configure the authentication strategy for the token endpoint in OpenID Proxy connections|"client_secret_post"|
|services.contentManagerService.openIdProxyTrustedEnvName|Specify the trusted environment name for OpenID Proxy|" "|
|services.contentManagerService.openIdProxyUseDiscEndpoint|Specify whether to use the discovery endpoint for retrieving the OpenID Proxy provider's configuration information|false|
|services.contentManagerService.openIdProxyVersion|Specify the version for OpenID Proxy|" "|
|services.contentManagerService.openIdPrivateKeyFile|Specifies the file that contains the private signing key. The file that contains the private signing key in PKCS8 format. It must contain a single private RSA key of length 2048 bit|No Default|
|services.contentManagerService.openIdPrivateKeyId|Specifies the key identifier that should be placed in the JWT header. The key identifier that will be set in the JWT 'kid' header. Use this configuration item if your identity provider requires a 'kid'. Leave this value blank if your identity provider does not require a 'kid'.|No Default|
|services.contentManagerService.openIdPgStrategy|Specifies how to get the user's identity when using the password grant flow. Set this value to 'ID token' if all user claims are returned in the id_token. Set this value to 'ID token and userinfo endpoint' if an id_token is returned from the password grant flow but does not contain all of the user claims. Set this value to 'Userinfo endpoint' if the id_token does not contain any user claims and if the user claims should be retrieved from the userinfo endpoint. Set this value to 'Unsupported' if the Identity Provider does not support the password grant flow.|idToken / idTokenUserinfo / unsupported / userinfo|
|services.contentManagerService.openIdPgInclScope|Specifies that the scope should be included when using the password grant flow. Set this value to true to indicate that the scope parameter should be included as part of the query string for the password grant flow. Set this value to false to indicate that the scope should be omitted from the query string for the password grant flow|True / False|
|services.contentManagerService.openIdPgAddParams|Specifies any additional parameters that are required for the password grant flow.|No Default|
|services.contentManagerService.openIdCertUri|Specifies the OpenID Connect endpoint for retrieving JWT signing keys. The JWKS endpoint is a URL that your OpenID Connect identity provider uses to provide signing key data. In most cases, the URL should use the https scheme. The JWKS endpoint is invoked when validating an id_token returned from the identity provider.|No Default|
|services.contentManagerService.openIdPkceStrategy|Specifies what proof of key exchange (PKCE) algorithm to use. The default of S256 is appropriate in most cases unless the Identity Provider requires plain or does not support proof of key exchange at all.|S256 / plain / unsupported|
|services.contentManagerService.restrictAccessToCRN|Allows administrators to restrict user access to the application. When this parameter is enabled, users can only access the application if they belong to at least one group or role within the built-in namespace (does not include the group "All Authenticated Users").|False / True|

## Content Manager Service DB Store configuration settings
These configuration settings are required to deploy CACC.
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

## Content Manager additional content configuration properties
These configuration settings are optional to deploy CACC.
| Parameter                  | Description                                                        | Default                                                    |
| -----------------------    | ---------------------------------------------                      | ---------------------------------------------------------- |
|services.contentManagerService.p2pdDeployDefaultsDispatcherCmPoolsize|Configure the Dispatcher CM Pool size|30|
|services.contentManagerService.p2pdDeployDefaultsWpCacheSize|Configure the WP Cache size|30|
|services.contentManagerService.xtsPropertiesFunctionCacheSize|Configure the XTS Function Cache size|30|
|services.contentManagerService.xtsPropertiesLogicSheetCacheSize|Configure the XTS Logic Sheet Cache size |60|
|services.contentManagerService.xtsPropertiesNodeopCacheSize|Configure the XTS NodeOp Cache size|30|
|services.contentManagerService.xtsPropertiesRequestCacheSize|Configure the XTS Request Cache size |30|
|services.contentManagerService.xtsPropertiesTemplateCacheSize|Configure the XTS Template Cache size |100|
|services.contentManagerService.xtsPropertiesTransformCacheSize|Configure the XTS Transform Cache size |45|
|services.contentManagerService.enableExternalObjectStore|Enable External Object Storage. Requires associated PVC configs.pvcExternalObjectStorage to be provided|false|
|services.contentManagerService.pdb.minAvailable|Minimum number of pods that must be available during voluntary disruptions (e.g., node drains, upgrades). Ensures high availability.|1|

|services.contentManagerService.removeDeploymentSamples|If enabled, will removed the CA provided samples from deployment folder|false|

## Reporting Service configuration settings
These configuration settings can be enabled to modify the execution profile of the Reporting Service
| Parameter                  |                                      | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.reportingService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.reportingService.digest|Modify only if asked to do so by Cognos Support person|Current image digest is included in the Helm chart|
|services.reportingService.dispatcherMemory|Specify the maximum amount of memory in MB for the dispatcher service|6144|
|services.reportingService.dispatcherCoreThreads|Specify the number of core threads for the dispatcher service|200|
|services.reportingService.dispatcherExecutorThread|Specify the number of executor threads for the dispatcher service|-1|
|services.reportingService.cgsMaxMemory|Specify the maximum memory for the Content Generator Service (CGS)|500m|
|services.reportingService.requestsCpu|Set the CPU request for the container|"2000m"|
|services.reportingService.requestsMemory|Set the memory request for the container|4Gi|
|services.reportingService.requestsEphemeralStorage|Set the ephemeral storage request for the container|5Gi|
|services.reportingService.limitsCpu|Set the CPU limit for the container|"6000m"|
|services.reportingService.limitsMemory|Set the memory limit for the container|10Gi|
|services.reportingService.limitsEphemeralStorage|Set the ephemeral storage limit for the container|10Gi|
|services.reportingService.verboseStartupLogging|Enable or disable detailed startup logging|false|
|services.reportingService.rsvpMode|Specifies the Report Server execution mode. Value can be either 32-bit or 64-bit|"64-bit"|
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
|services.reportingService.rsvpPropertiesLocalCacheOutputSize|Configure RSVP Local Cache Output size |70|
|services.reportingService.rsvpPropertiesSessionCacheSize|Configure RSVP Session Cache Size |70|
|services.reportingService.rsAsyncWaitTimeoutMs|Configure RSVP Asynchronous Wait Timeouts (Milliseconds)|120000|
|services.reportingService.rsMaxProcesses|Configure RSVP Max Processes |16|
|services.reportingService.rsAffine|Specify the number of affine processes for the report service|2|
|services.reportingService.rsNonAffine|Specify the number of non-affine processes for the report service|8|
|services.reportingService.brsMaxProcesses|Configure RSVP Batch Max Processes |16|
|services.reportingService.brsAffine|Specify the number of affine processes for the batch report service|2|
|services.reportingService.brsNonAffine|Specify the number of non-affine processes for the batch report service|8|
|services.reportingService.idleProcessCheckIntervalMs|Interval in milliseconds to check for idle processes|60000|
|services.reportingService.idleProcessMaxIdleTicks|Maximum number of idle ticks before a process is considered idle|10|
|services.reportingService.pdb.minAvailable|Minimum number of pods that must be available during voluntary disruptions (e.g., node drains, upgrades). Ensures high availability.|1|

|services.reportingService.defaultProcessUseLimit|Default limit for process usage|100|
|services.reportingService.doReportSpecUpgrade|Enable automatic report specification upgrade. When set to true, report specifications are automatically upgraded to the current version format|false|

## Rest Service configuration settings
These configuration settings can be enabled to modify the execution profile of the Rest Service
| Parameter                  |                                      | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.restService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.restService.digest|Modify only if asked to do so by Cognos Support person|Current image digest is included in the Helm chart|
|services.restService.dispatcherMemory|Specify the maximum amount of memory in MB for the dispatcher service|6144|
|services.restService.dispatcherCoreThreads|Specify the number of core threads for the dispatcher service|200|
|services.restService.dispatcherExecutorThread|Specify the number of executor threads for the dispatcher service|-1|
|services.restService.requestsCpu|Set the CPU request for the container|"2000m"|
|services.restService.requestsMemory|Set the memory request for the container|4Gi|
|services.restService.requestsEphemeralStorage|Set the ephemeral storage request for the container|5Gi|
|services.restService.limitsCpu|Set the CPU limit for the container|"4000m"|
|services.restService.limitsMemory|Set the memory limit for the container|6Gi|
|services.restService.limitsEphemeralStorage|Set the ephemeral storage limit for the container|10Gi|
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
|services.restService.pdb.minAvailable|Minimum number of pods that must be available during voluntary disruptions (e.g., node drains, upgrades). Ensures high availability.|1|

|services.restService.scaleUpWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|30|

## User Interface Service configuration settings
These configuration settings can be enabled to modify the execution profile of the User Interface Service
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.uiService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.uiService.digest|Modify only if asked to do so by Cognos Support person|Current image digest is included in the Helm chart|
|services.uiService.dispatcherMemory|Specify the maximum amount of memory in MB for the dispatcher service|6144|
|services.uiService.dispatcherCoreThreads|Specify the number of core threads for the dispatcher service|200|
|services.uiService.dispatcherExecutorThread|Specify the number of executor threads for the dispatcher service|-1|
|services.uiService.requestsCpu|Set the CPU request for the container|"2000m"|
|services.uiService.requestsMemory|Set the memory request for the container|4Gi|
|services.uiService.requestsEphemeralStorage|Set the ephemeral storage request for the container|5Gi|
|services.uiService.limitsCpu|Set the CPU limit for the container|"4000m"|
|services.uiService.limitsMemory|Set the memory limit for the container|6Gi|
|services.uiService.limitsEphemeralStorage|Set the ephemeral storage limit for the container|10Gi|
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
|services.uiService.pdb.minAvailable|Minimum number of pods that must be available during voluntary disruptions (e.g., node drains, upgrades). Ensures high availability.|1|

|services.uiService.scaleUpWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|30|

## Smarts Service configuration settings
These configuration settings can be enabled to modify the execution profile of the Smarts Service
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.smartsService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.smartsService.digest|Modify only if asked to do so by Cognos Support person|Current image digest is included in the Helm chart|
|services.smartsService.dispatcherMemory|Specify the maximum amount of memory in MB for the dispatcher service|6144|
|services.smartsService.dispatcherCoreThreads|Specify the number of core threads for the dispatcher service|200|
|services.smartsService.dispatcherExecutorThread|Specify the number of executor threads for the dispatcher service|-1|
|services.smartsService.requestsCpu|Set the CPU request for the container|"2000m"|
|services.smartsService.requestsMemory|Set the memory request for the container|5Gi|
|services.smartsService.requestsEphemeralStorage|Set the ephemeral storage request for the container|5Gi|
|services.smartsService.limitsCpu|Set the CPU limit for the container|"6000m"|
|services.smartsService.limitsMemory|Set the memory limit for the container|8Gi|
|services.smartsService.limitsEphemeralStorage|Set the ephemeral storage limit for the container|10Gi|
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
|services.smartsService.pdb.minAvailable|Minimum number of pods that must be available during voluntary disruptions (e.g., node drains, upgrades). Ensures high availability.|1|

|services.smartsService.scaleUpWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|30|

## Agentic AI Service configuration settings
These configuration settings can be enabled to configure the BA Agentic AI Service with OpenSearch and Redis sidecars.
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.agenticAIService.enabled|Enable or disable the Agentic AI Service|true|
|services.agenticAIService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.agenticAIService.name|Name of the Agentic AI service container|ba-agentic-ai|
|services.agenticAIService.digest|Modify only if asked to do so by Cognos Support person|Current image digest is included in the Helm chart|
|services.agenticAIService.tag|Image tag for the Agentic AI service|12.1.2|
|services.agenticAIService.requestsCpu|Set the CPU request for the container|"500m"|
|services.agenticAIService.requestsMemory|Set the memory request for the container|2Gi|
|services.agenticAIService.requestsEphemeralStorage|Set the ephemeral storage request for the container|2Gi|
|services.agenticAIService.limitsCpu|Set the CPU limit for the container|"2"|
|services.agenticAIService.limitsMemory|Set the memory limit for the container|4Gi|
|services.agenticAIService.limitsEphemeralStorage|Set the ephemeral storage limit for the container|4Gi|
|services.agenticAIService.replicas|Number of Agentic AI service replicas to use on startup|1|
|services.agenticAIService.servicePort|Service port for the Agentic AI service|9000|
|services.agenticAIService.targetPort|Target port for the Agentic AI service container|8000|
|services.agenticAIService.logLevel|Log level for the Agentic AI service (debug, info, warning, error)|info|
|services.agenticAIService.workers|Number of worker processes for the Agentic AI service|4|

## Agentic AI Service - OpenSearch Sidecar configuration settings
These configuration settings control the OpenSearch sidecar container that provides search capabilities for the Agentic AI service.
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.agenticAIService.useOpenSearchSidecar|Enable or disable the OpenSearch sidecar container|true|
|services.agenticAIService.openSearchName|Name of the OpenSearch sidecar container|opensearch|
|services.agenticAIService.openSearchDigest|Image digest for the OpenSearch container|Current image digest is included in the Helm chart|
|services.agenticAIService.openSearchTag|Image tag for the OpenSearch container|3.4.0|
|services.agenticAIService.openSearchDisableSecurity|Disable OpenSearch security features (set to "true" or "false")|"false"|
|services.agenticAIService.openSearchUseSSL|Enable SSL for OpenSearch connections (set to "true" or "false")|"true"|
|services.agenticAIService.openSearchVerifyCerts|Verify SSL certificates for OpenSearch (set to "true" or "false")|"false"|
|services.agenticAIService.openSearchUser|Default admin user for OpenSearch|"admin"|
|services.agenticAIService.openSearchJavaHeapSize|Java heap size for OpenSearch (e.g., "2g", "4g")|"2g"|
|services.agenticAIService.openSearchRequestsCpu|Set the CPU request for the OpenSearch sidecar|"1"|
|services.agenticAIService.openSearchRequestsMemory|Set the memory request for the OpenSearch sidecar|2Gi|
|services.agenticAIService.openSearchLimitsCpu|Set the CPU limit for the OpenSearch sidecar|"2"|
|services.agenticAIService.openSearchLimitsMemory|Set the memory limit for the OpenSearch sidecar|4Gi|
|services.agenticAIService.openSearchPvcEnabled|Enable persistent storage for OpenSearch data|false|
|services.agenticAIService.openSearchPvcStorageClassName|Storage class name for OpenSearch PVC|"default"|
|services.agenticAIService.openSearchPvcStorageSize|Storage size for OpenSearch PVC|10Gi|

## Agentic AI Service - External OpenSearch configuration settings

The Agentic AI service can be configured to use an external OpenSearch instance instead of the built-in OpenSearch sidecar. This is useful for production deployments where you want to use a managed OpenSearch service or your own OpenSearch cluster.


### Configuration Parameters

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.agenticAIService.enableExternalOpenSearch|Enable external OpenSearch instead of sidecar|false|
|services.agenticAIService.openSearchVerifyCerts|Verify SSL certificates for the external OpenSearch connection (set to "true" or "false")|"false"|
|services.agenticAIService.openSearchUseSSL|Enable SSL for the external OpenSearch connection (set to "true" or "false")|"true"|


### Prerequisites

Before enabling external OpenSearch, you must create a Kubernetes Secret containing the connection details:

```bash
kubectl create secret generic ca-external-opensearch-credentials-secret \
  --from-literal=url='https://hostname:9200' \
  --from-literal=username=admin \
  --from-literal=password=your-password \
  -n <namespace>
```

**Important Notes:**
- The secret name must be `ca-external-opensearch-credentials-secret` (or the value specified in `secretNames.external_opensearch_creds`)
- The `url` field is required and must include the scheme (`https://` or `http://`) and port
- The `username` and `password` fields are read from the secret and injected as `OPENSEARCH_USER` / `OPENSEARCH_PASSWORD` environment variables
- When `enableExternalOpenSearch` is `true`, the OpenSearch sidecar container is **not** started even if `useOpenSearchSidecar` is `true`


### Enabling External OpenSearch

Update your Helm values file or use `--set` during installation/upgrade:

```yaml
services:
  agenticAIService:
    enabled: true
    enableExternalOpenSearch: true
    openSearchUseSSL: "true"
    openSearchVerifyCerts: "false"
```

Or via command line:

```bash
helm upgrade <release-name> ibm-cacc-prod \
  --set services.agenticAIService.enableExternalOpenSearch=true \
  -n <namespace>
```


### Verification

After deployment, verify the configuration:

```bash
# Check that the secret exists
kubectl get secret ca-external-opensearch-credentials-secret -n <namespace>

# Verify environment variables in the pod
kubectl exec -it deployment/ca-agentic-ai -n <namespace> -- env | grep OPENSEARCH

# Expected output:
# OPENSEARCH_URL=https://...
# OPENSEARCH_USER=admin
# OPENSEARCH_PASSWORD=...
# OPENSEARCH_USE_SSL=true
# OPENSEARCH_VERIFY_CERTS=false

# Check pod logs for OpenSearch connection
kubectl logs -l app=ca-agentic-ai -n <namespace> --tail=50 | grep -i opensearch
```


## Agentic AI Service - Redis Sidecar configuration settings
These configuration settings control the Redis sidecar container that provides caching capabilities for the Agentic AI service.
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.agenticAIService.redisName|Name of the Redis sidecar container|redisearch|
|services.agenticAIService.redisDigest|Image digest for the Redis container|Current image digest is included in the Helm chart|
|services.agenticAIService.redisTag|Image tag for the Redis container|2.6.0|
|services.agenticAIService.redisRequestsCpu|Set the CPU request for the Redis sidecar|"500m"|
|services.agenticAIService.redisRequestsMemory|Set the memory request for the Redis sidecar|1Gi|
|services.agenticAIService.redisLimitsCpu|Set the CPU limit for the Redis sidecar|"1"|
|services.agenticAIService.redisLimitsMemory|Set the memory limit for the Redis sidecar|2Gi|
|services.agenticAIService.redisPvcEnabled|Enable persistent storage for Redis data|false|
|services.agenticAIService.redisPvcStorageClassName|Storage class name for Redis PVC|"default"|
|services.agenticAIService.redisPvcStorageSize|Storage size for Redis PVC|5Gi|
|services.agenticAIService.labels|Used to add any labels to agenticAIService deployment only|No default|
|services.agenticAIService.annotations|Used to add any annotations to agenticAIService deployment only|No default|
|services.agenticAIService.pdb.minAvailable|Minimum number of pods that must be available during voluntary disruptions (e.g., node drains, upgrades). Ensures high availability.|1|

|services.agenticAIService.extraEnv|Used to add any extra environment variables to agenticAIService deployment|No default|
## Agentic AI Service - External Redis configuration settings

The Agentic AI service can be configured to use an external Redis instance instead of the built-in Redis sidecar. This is useful for production deployments where you want to use a managed Redis service (such as IBM Cloud Databases for Redis) or your own Redis cluster.


### Configuration Parameters

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.agenticAIService.enableExternalRedis|Enable external Redis instead of sidecar|false|


### Prerequisites

Before enabling external Redis, you must create a Kubernetes Secret containing the Redis connection details:

```bash
# For Redis without TLS
kubectl create secret generic ca-external-redis-credentials-secret \
  --from-literal=url='redis://username:password@hostname:6379/0' \
  -n <namespace>

# For Redis with TLS (e.g., IBM Cloud Redis)
# Step 1: Create CA bundle with all required certificates
cat redis-ca.crt > ca-bundle.crt
cat openshift-ca.crt >> ca-bundle.crt  # Add OpenShift CA if needed

# Step 2: Base64 encode the bundle
CERT_B64=$(cat ca-bundle.crt | base64 -w 0)

# Step 3: Create secret
kubectl create secret generic ca-external-redis-credentials-secret \
  --from-literal=url='rediss://username:password@hostname:6380/0' \
  --from-literal=certificate="$CERT_B64" \
  -n <namespace>
```

**Important Notes:**
- The secret name must be `ca-external-redis-credentials-secret` (or the value specified in `secretNames.external_redis_creds`)
- The `url` field is required and supports both `redis://` (no TLS) and `rediss://` (with TLS)
- The `certificate` field is optional but required for `rediss://` connections
- The certificate must be a base64-encoded CA bundle containing all required CA certificates
- **The `REDIS_CERT_B64` environment variable will override all certificates in the Agentic AI pod**, so the CA bundle must include:
  - Redis server CA certificate
  - OpenShift service CA certificate (for OpenShift clusters with TLS)
  - Any other CA certificates needed for HTTPS connections


### Getting OpenShift CA Certificate

For OpenShift clusters with TLS, extract the OpenShift service CA:

```bash
oc get configmap -n openshift-service-ca openshift-service-ca.crt \
  -o jsonpath='{.data.service-ca\.crt}' > openshift-ca.crt
```


### Enabling External Redis

Update your Helm values file or use `--set` during installation/upgrade:

```yaml
services:
  agenticAIService:
    enabled: true
    enableExternalRedis: true
```

Or via command line:

```bash
helm upgrade <release-name> ibm-cacc-prod \
  --set services.agenticAIService.enableExternalRedis=true \
  -n <namespace>
```


### Verification

After deployment, verify the configuration:

```bash
# Check that the secret exists
kubectl get secret ca-external-redis-credentials-secret -n <namespace>

# Verify environment variables in the pod
kubectl exec -it deployment/ca-agentic-ai -n <namespace> -- env | grep REDIS

# Expected output:
# REDIS_URL=rediss://...
# REDIS_CERT_B64=LS0tLS1CRUdJTi...

# Check pod logs for Redis connection
kubectl logs -l app=ca-agentic-ai -n <namespace> --tail=50 | grep -i redis
```


### Example: IBM Cloud Databases for Redis

```bash
#!/bin/bash

NAMESPACE="eca1"
REDIS_URL="rediss://admin:longpassword@abc123.databases.appdomain.cloud:32658/0"

# Step 1: Get OpenShift CA
oc get configmap -n openshift-service-ca openshift-service-ca.crt \
  -o jsonpath='{.data.service-ca\.crt}' > openshift-ca.crt

# Step 2: Create CA bundle
cat ibm-cloud-redis-ca.crt > ca-bundle.crt
cat openshift-ca.crt >> ca-bundle.crt

echo "CA bundle contains $(grep -c 'BEGIN CERTIFICATE' ca-bundle.crt) certificates"

# Step 3: Create secret
CERT_B64=$(cat ca-bundle.crt | base64 -w 0)
kubectl create secret generic ca-external-redis-credentials-secret \
  --from-literal=url="$REDIS_URL" \
  --from-literal=certificate="$CERT_B64" \
  -n "$NAMESPACE"

# Step 4: Enable external Redis
helm upgrade ca-instance ibm-cacc-prod \
  --set services.agenticAIService.enableExternalRedis=true \
  -n "$NAMESPACE"

# Step 5: Wait for rollout
kubectl rollout status deployment/ca-agentic-ai -n "$NAMESPACE"

echo "External Redis configured successfully!"
```


## Agentic AI Service - Bring Your Own LLM (BYO-LLM) with LiteLLM

The Agentic AI service supports **Bring Your Own LLM (BYO-LLM)** functionality through LiteLLM proxy integration. This allows you to use external LLM providers (such as IBM watsonx.ai, AWS Bedrock, OpenAI, Azure AI Foundry, and Anthropic.) instead of or in addition to the default models.

LiteLLM acts as a unified proxy that translates requests to different LLM providers into a consistent OpenAI-compatible API format, making it easy to switch between providers or use multiple models simultaneously.


### Architecture

The BYO-LLM implementation includes:
- **LiteLLM Proxy**: A lightweight proxy service that routes requests to configured LLM providers
- **PostgreSQL Database**: Stores LiteLLM configuration, model definitions, API keys, and usage tracking
- **Agentic AI Integration**: The Agentic AI service connects to LiteLLM via environment variables
- **UI-Based Model Management**: Configure LLM connections directly through the Cognos Analytics UI


### Configuration Parameters

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|litellm.enabled|Enable or disable LiteLLM proxy service|false|
|litellm.image.name|LiteLLM proxy container image name|litellm|
|litellm.image.tag|Image tag for LiteLLM proxy|non-root|
|litellm.image.pullPolicy|Image pull policy|IfNotPresent|
|litellm.replicas|Number of LiteLLM proxy replicas|1|
|litellm.service.port|Service port for LiteLLM proxy|4000|
|litellm.resources.requests.cpu|CPU request for LiteLLM container|"500m"|
|litellm.resources.requests.memory|Memory request for LiteLLM container|512Mi|
|litellm.resources.limits.cpu|CPU limit for LiteLLM container|"2000m"|
|litellm.resources.limits.memory|Memory limit for LiteLLM container|2Gi|
|litellm.masterKey|LiteLLM master key for authentication (must start with 'sk-')|"sk-litellm-master-key-change-me"|
|litellm.saltKey|LiteLLM salt key for encryption (must start with 'sk-')|"sk-litellm-salt-key-change-me"|
|litellm.database.dbHostname|PostgreSQL hostname|litellm-postgres|
|litellm.database.dbPort|PostgreSQL port|5432|
|litellm.database.dbName|PostgreSQL database name|litellm|
|litellm.logLevel|Log level (DEBUG, INFO, WARNING, ERROR)|ERROR|


### Prerequisites

Before enabling BYO-LLM, you need:

1. **A running PostgreSQL database** - Either deploy the included PostgreSQL chart or use an existing PostgreSQL instance
2. **LLM provider API credentials** - Obtain API keys from your chosen LLM provider(s) (e.g., IBM watsonx.ai, AWS Bedrock, OpenAI, Azure OpenAI)

**Note**: Model configuration is done through the Cognos Analytics UI after deployment, not in Helm values.


### Step 1: Create Kubernetes Secrets

Create the three required secrets for LiteLLM. You need to provide your own authentication keys and database credentials.

**Secret 1: LiteLLM Authentication Keys**
```bash
NAMESPACE="your-namespace"
LITELLM_MASTER_KEY="sk-your-master-key"  # Must start with 'sk-'
LITELLM_SALT_KEY="sk-your-salt-key"      # Must start with 'sk-'

kubectl create secret generic litellm-secrets \
    --from-literal=LITELLM_MASTER_KEY="${LITELLM_MASTER_KEY}" \
    --from-literal=LITELLM_SALT_KEY="${LITELLM_SALT_KEY}" \
    -n ${NAMESPACE}
```

**Secret 2: PostgreSQL Password**
```bash
LITELLM_DB_PASSWORD="your-db-password"

kubectl create secret generic litellm-postgres-secret \
    --from-literal=password="${LITELLM_DB_PASSWORD}" \
    -n ${NAMESPACE}
```

**Secret 3: Database Connection URL**
```bash
# Use your PostgreSQL connection URL
# Format: postgresql://username:password@hostname:port/database
DATABASE_URL="postgresql://your-db-username:your-db-password@your-postgres-host:5432/litellm"

kubectl create secret generic litellm-db-url \
    --from-literal=DATABASE_URL="${DATABASE_URL}" \
    -n ${NAMESPACE}
```

**Important Notes**:
- Both `LITELLM_MASTER_KEY` and `LITELLM_SALT_KEY` **must start with 'sk-'**
- Save the master key securely - you'll need it to access the LiteLLM UI
- The `DATABASE_URL` must point to your actual PostgreSQL instance with valid credentials
- Ensure the PostgreSQL database exists and is accessible from the Kubernetes cluster


### Step 2: Update Helm Values

Configure LiteLLM in your Helm values file or override file:

```yaml
litellm:
  enabled: true
  masterKey: "sk-your-master-key"  # Must match the secret
  saltKey: "sk-your-salt-key"      # Must match the secret
```


### Step 3: Deploy or Upgrade CACC

Deploy or upgrade your CACC instance with LiteLLM enabled:

```bash
helm upgrade ca-instance ./ibm-cacc-prod \
  -f your-values.yaml \
  -n ${NAMESPACE}
```


### Step 4: Configure LLM Models via UI

After deployment, configure your LLM connections through the Cognos Analytics UI:

1. Navigate to **Manage** → **API keys**
2. Click **Create connection**
3. Select your LLM provider:
   - IBM watsonx.ai
   - AWS Bedrock
   - OpenAI
   - Azure AI Foundry
   - Anthropic
4. Enter your provider's API credentials
5. Save the configuration
6. Click **Test connection** to verify the connection works
7. If successful, click **Set as AI agent Connection**

After successfully setting the AI agent connection, a new item **"LiteLLM Model Gateway"** will appear in the UI, indicating that BYO-LLM is properly configured.

All model configurations are stored in the PostgreSQL database and managed through the UI.






## Data Service configuration settings
These configuration settings can be enabled to modify the execution profile of the DataSet Service 
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.dataService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.dataService.digest|Modify only if asked to do so by Cognos Support person|Current image digest is included in the Helm chart|
|services.dataService.dispatcherMemory|Specify the maximum amount of memory in MB for the dispatcher service|6144|
|services.dataService.dispatcherCoreThreads|Specify the number of core threads for the dispatcher service|200|
|services.dataService.dispatcherExecutorThread|Specify the number of executor threads for the dispatcher service|-1|
|services.dataService.dqMaxMemory|Adjust memory for Dynamic Query process|5120|
|services.dataService.dqCoreThreads|Adjust core threads for Dynamic Query process|200|
|services.dataService.dqExecutorThreads|Adjust executor threads for Dynamic Query process|-1|
|services.dataService.flintMaxMemory|Adjust memory for Flint process|1024m|
|services.dataService.requestsCpu|Set the CPU request for the container|"2000m"|
|services.dataService.requestsMemory|Set the memory request for the container|12Gi|
|services.dataService.requestsEphemeralStorage|Set the ephemeral storage request for the container|5Gi|
|services.dataService.limitsCpu|Set the CPU limit for the container|"6000m"|
|services.dataService.limitsMemory|Set the memory limit for the container|16Gi|
|services.dataService.limitsEphemeralStorage|Set the ephemeral storage limit for the container|10Gi|
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
|services.dataService.pdb.minAvailable|Minimum number of pods that must be available during voluntary disruptions (e.g., node drains, upgrades). Ensures high availability.|1|

|services.dataService.scaleUpWindowPolicySeconds|This helps prevent unnecessary scaling if metrics are fluctuating. For example, a stabilizationWindowSeconds of 300 means the HPA will wait 300 seconds before scaling down pods to the new, desired number of replicas.|30|

## Data Service additional configuration settings
These additional parameters are available to modify the execution/connectity profile (query execution, timeout properties and enabling diagnostics) when connecting to DSS Olap/PA Features
| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|services.dataService.pullPolicy|Configure the update policy for the container images. Acceptable values are Always, Never, or IfNotPresents.|IfNotPresent|
|services.dataService.enableDiagnosticsLogging|    |false|
|services.dataService.loadHierarchyNamedSets| |true|
|services.dataService.paUseFillerMember|Configure to determine whether filler members (often indicated by a caret symbol ^ in data trees) are shown when dealing with parent members that do not have direct children, or when a user lacks access to specific root members.|true|
|services.dataService.paUseRootMembers|Configuration setting used to ensure that the root members in a Planning Analytics (TM1) data source match those shown in the TM1 client|false|
|services.dataService.paEnableHierarchyLocalization| |true|
|services.dataService.paUseStreamsForSetFunctions| |false|
|services.dataService.paAsyncWaitTimeoutSeconds|This parameter defines the maximum number of seconds XQE waits (seconds) for a response from backend systems, such as TM1 instances. |32|
|services.dataService.paAsyncRequestTimeoutSeconds|This parameter define the default asynchronous request timeout (seconds) specifically for the proxy waiting on backend services |300|
|services.dataService.tm1RestClientSocketTimeout|If Cognos Analytics is the client experiencing the timeout, the default timeout seconds) |300| 
|services.dataService.tm1RestClientIdleConnectionTimeout|Specifies a timeout limit for idle client connections (milliseconds).|200|  
|services.dataService.tm1RestClientConnectionTimeout|The tm1RestClientConnectionTimeout parameter sets the timeout value (milliseconds) for authentication sessions for the Planning Analytics REST API. |5000|
|services.dataService.trustAllTm1RestCertificates| |false|
|services.dataService.useProviderCrossJoinThreshold|Enabling useProviderCrossJoinThreshold controls whether combinations of members on an edge, which have no measure values, are retrieved from the Planning Analytics database. UseProviderCrossJoinThreshold is enabled when it has a value greater than 0. |10000|
|services.dataService.useFiddlerProxyForTm1RestClient|Enable to monitor and debug traffic between a TM1 REST Client |false|
|services.dataService.validateTm1RestPaSubsets|Enable to validate subsets in IBM Planning Analytics (TM1) via the REST API involves querying the TM1 REST API endpoint to check for the existence of a subset within a dimension, or validating its MDX definition. |true|
|services.dataService.validateTm1RestSelfSignedCertificates|To validate TM1 REST API self-signed certificates in Planning Analytics, you must import the TM1 server's self-signed certificate into the trust stores of the applications or clients connecting to it.|true|

## CA Proxy Sidecar Timeout Configuration Settings
These configuration settings control timeout values for the CA Proxy sidecar container that handles HTTP request routing and proxying for Cognos Analytics services. Adjusting these timeouts can help accommodate long-running operations such as large report generation or complex data queries.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
|sidecars.caproxySidecar.timeouts.httpRequestTimeout|Maximum duration for completing an HTTP request. Increase this value for long-running reports or queries. Format: duration string (e.g., "60s", "5m", "300s")|"60s"|
|sidecars.caproxySidecar.timeouts.server.readTimeout|Maximum duration for reading the entire request, including the body. Format: duration string|"30s"|
|sidecars.caproxySidecar.timeouts.server.readHeaderTimeout|Maximum duration for reading request headers. Format: duration string|"30s"|
|sidecars.caproxySidecar.timeouts.server.writeTimeout|Maximum duration for writing the response. Increase for large response payloads. Format: duration string|"60s"|
|sidecars.caproxySidecar.timeouts.server.idleTimeout|Maximum duration to wait for the next request when keep-alives are enabled. Format: duration string|"2m"|
|sidecars.caproxySidecar.timeouts.upstreamTimeoutMs|Maximum duration in milliseconds to wait for upstream service responses. Increase for long-running backend operations|35000|

**Note:** For production environments with long-running reports or complex queries, consider increasing `httpRequestTimeout` to "300s" (5 minutes) and `upstreamTimeoutMs` to 300000 (5 minutes) to prevent timeout errors.

**Example Configuration:**
```yaml
sidecars:
  caproxySidecar:
    timeouts:
      httpRequestTimeout: "300s"
      server:
        readTimeout: "300s"
        readHeaderTimeout: "300s"
        writeTimeout: "300s"
        idleTimeout: "300s"
      upstreamTimeoutMs: 300000
```
## Limitations
