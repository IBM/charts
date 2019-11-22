# MobileFirst Foundation Server Helm Chart

## Introduction
IBM MobileFirst™ Platform Foundation is an integrated platform that helps you extend your business to mobile devices.

IBM MobileFirst Platform Foundation includes a comprehensive development environment, mobile-optimized runtime middleware, a private enterprise application store, and an integrated management and analytics console, all supported by various security mechanisms.

For more information: [MobileFirst Server Documentation](https://www.ibm.com/support/knowledgecenter/en/SSNJXP/welcome.html)

## Chart Details

This chart will do the following:
- Deploys Mobile Foundation Server onto Kubernetes.
- This chart can be deployed more than once on the same namespace.
## Prerequisites

1. (Mandatory) A pre-configured DB2 database is required and this information will be supplied to server helm chart to create appropriate tables for Server.  For Oracle, MySQL or Postgres databases, the Mobile Foundation Server database tables have to created [manually](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/installation-configuration/production/prod-env/databases/) before the deployment of MFP Components.

	Note: The base docker image needs to be extended/customized for using databases other than IBM DB2

2. (Optional) You can provide your own keystore and truststore to the deployment by creating a secret with your own keystore and truststore.

Pre-create a secret with keystore.jks, keystore-password.txt, truststore.jks, truststore-password.txt and provide the secret name in the field keystores.keystoresSecretName.

Keep the files keystore.jks and its password in a file named keystore-password.txt, truststore.jks and its password in a file named truststore-password.jks.  
From the command line, execute:
*    `kubectl create secret generic mfpf-cert-secret --from-file keystore-password.txt --from-file truststore-password.txt --from-file keystore.jks --from-file truststore.jks`

Note that the names of the files should be the same as mentioned here: keystore.jks,keystore-password.txt, truststore.jks and truststore-password.txt.

Provide this secret name in keystoresSecretName to overide the default keystores.

If you plan to connect MobileFirst Server to Operational Analytics, then use the helm chart for MobileFirst Operational Analytics to create it first, before creating the Server.

## Resources Required

This chart uses the following resources by default:

- 1 CPU core
- 2 Gi memory

## PodSecurityPolicy Requirements 

NA

## Installing the Chart

You can install the chart with the release name `my-release` as follows:

```sh
helm install --name my-release stable/ibm-mfpf-server-prod --set <stringArray>
```

--set stringArray        set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
This command accepts the List of comma separated mandatory  values and deploys a Mobile Foundation Server on the Kubernetes cluster. The [configuration](#configuration) section lists the parameters that can be configured during installation.
> **Tip**: See all the resources deployed by the chart using `kubectl get all -l release=my-release`

### Uninstalling the Chart

You can uninstall/delete the `my-release` release as follows:

```sh
helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart, except any Persistent Volume Claims (PVCs).  This is the default behavior of Kubernetes, and ensures that valuable data is not deleted.

## Accessing MobileFirst Server

From a web browser, go to the IBM Cloud Private console page and navigate to the helm releases page as follows

1. Click on Menu on the Left Top of the Page
2. Select **Workloads** > **Helm Releases**
3. Click on the deployed *IBM MobileFoundation Server* helm release
4. Refer the **Notes** section for the procedure to access the MobileFoundation Operations Console

## Reference
[Setting up MobileFirst Server on IBM Cloud Private](https://mobilefirstplatform.ibmcloud.com/tutorials/fr/foundation/8.0/bluemix/mobilefirst-server-on-icp/)
   
## Configuration

### Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| arch |  amd64    | amd64 worker node scheduler preference in a hybrid cluster | 3 - Most preferred (Default) |
|      |  ppcle64  | ppc64le worker node scheduler preference in a hybrid cluster | 2 - No preference (Default) |
|      |  s390x    | S390x worker node scheduler preference in a hybrid cluster | 2 - No preference (Default) |
| image     | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Default: IfNotPresent |
|           | repository          | Docker image name | Name of the MobileFirst Server docker image |
|           | tag          | Docker image tag | See Docker tag description |
| scaling | replicaCount | The number of instances (pods) of MobileFirst Server that need to be created | Positive integer (Default: 3) |
| mobileFirstOperationsConsole | user | Username of the MobileFirst Server | Default: admin |
|                       | password | password of the MobileFirst Server | Default: admin |
|  existingDB2Details | db2Host | IP Address or HOST of the DB2 Database where MobileFirst Server tables need to be configured. | Only DB2 is supported. |
|                       | db2Port | 	Port where DB2 database is setup | |             
|                       | db2Database | Name of the database that is pre-configured in DB2 for use| |
|                       | db2Username  | DB2 User name to access the DB2 database | User should have access to create tables, and create schema if it does not already exist |
|                       | db2Password | DB2 password for the database supplied. | |
|                       | db2Schema | Server db2 schema to be created. | If the schema already present, it will be used. Otherwise, it will be created. |
|                       | db2ConnectionIsSSL | DB2 Connection type  | Specify if you Database connection has to be http or https. Default value is false (http). Make sure that the DB2 port is also configured for the same connection mode |
| existingMobileFirstAnalytics | analyticsEndpoint | URL of the analytics server. | For Ex. http://9.9.9.9:30400 . Do not specify the path to the console - it will be added during deployment|
|                       | analyticsAdminUser | Username of the analytics admin user | |
|                       | analyticsAdminPassword | Password of the analytics admin user | |
| keystores | keystoresSecretName | Refer the configuration section to pre-create the secret with keystores and their passwords.|
| jndiConfigurations | mfpfProperties | MobileFirst Server JNDI properties to customize deployment | Supply comma separated name value pairs |
| ingress | enabled | Enable ingress | Specifies whether to use Ingress. Default: false |
|         | hostname | Hostname of the Endpoint to be configured | The hostname of the Endpoint that has to be configured in the ingress definition. Mandatory if Ingress is enabled |
|         | tlsEnabled | Enable SSL/TLS | Specifies whether to enable TLS on the Ingress endpoint. Default: false |
|         | tlsSecretName | TLS secret name| Specifies the secret name for the certificate that has to be used in the Ingress definition. The secret has to be pre-created using the relevant certificate and key. Mandatory if SSL/TLS is enabled. Pre-create the secret with Certificate & Key before supplying the name here |
|         | sslPassThrough | Enable SSL passthrough | Specifies is the SSL request should be passed through to the MobileFirst service - SSL termination occurs in the MobileFirst service. Default: false |
| resources | limits.cpu  | Describes the maximum amount of CPU allowed.  | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|                  | limits.memory | Describes the maximum amount of memory allowed. | Default is 4096Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)|
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value.  | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value. | Default is 2048Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
| logs | consoleFormat | Specifies container log output format. | Default is **json**. |
|  | consoleLogLevel | Controls the granularity of messages that go to the container log. | Default is **info**. |
| | consoleSource | Specify sources that are written to the container log. Use a comma separated list for multiple sources. | Default is **message, trace, accessLog, ffdc**. |


## Limitations

For databases other than IBM DB2 following are mandatory requirements

1. The database and the relevant tables to be created before configuring/deploying the helm chart.
2. Make sure the docker image loaded via the PPA package (downloaded from IBM Passport Advantage) is extended to use the suitable database artifacts and the new docker tag is used to configure & deploy the helm chart.