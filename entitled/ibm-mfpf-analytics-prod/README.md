# MobileFoundation Analytics Helm Chart

## Introduction
IBM MobileFoundation™ Analytics gives a rich view into both your mobile landscape and server infrastructure. Included are default reports of user retention, crash reports, device type and operating system breakdowns, custom data and custom charts, network usage, push notification results, in-app behavior, debug log collection, and beyond.

For more information: [MobileFirst Operational Analytics Documentation](https://www.ibm.com/support/knowledgecenter/en/SSHS8R_8.0.0/com.ibm.worklight.analytics.doc/analytics/c_introduction.html)

## Chart Details

This chart will do the following:
- Deploys Mobile Foundation Analytics onto Kubernetes.
- This chart can be deployed more than once on the same namespace.

## Prerequisites

1. (Mandatory) PersistentVolume needs to be pre-created prior to installing the chart if `persistance.enabled=true` and `persistence.dynamicProvisioning=false` (default values, see the parameter **persistence** under the [Configuration](#configuration) section). It can be created by using the Management console UI or via a yaml file as the following example:
The PVC will be used to store analytics data.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: <persistent volume name>
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: <PATH>
```

2. (Optional) You can provide your own keystore and truststore to the deployment by creating a secret with your own keystore and truststore.

Pre-create a secret with keystore.jks, keystore-password.txt, truststore.jks, truststore-password.txt and provide the secret name in the field keystores.keystoresSecretName.

Keep the files keystore.jks and its password in a file named keystore-password.txt, truststore.jks and its password in a file named truststore-password.jks.  
From the command line, execute:  
```
kubectl create secret generic mfpf-cert-secret --from-file keystore-password.txt \
--from-file truststore-password.txt --from-file keystore.jks --from-file truststore.jks
```

Note that the names of the files should be the same as mentioned here: keystore.jks,keystore-password.txt, truststore.jks and truststore-password.txt.

Provide this secret name in keystoresSecretName, and overide the default keystores.

## Resources Required

This chart uses the following resources by default:

- 1 CPU core
- 2 Gi memory
- 20 Gi persistent volume


## PodSecurityPolicy Requirements 

NA

## Installing the Chart

You can install the chart with the release name `my-release` as follows:

```sh
helm install --name my-release stable/ibm-mfpf-analytics-prod --set <stringArray>
```

--set stringArray        set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
This command accepts the List of comma separated mandatory  values and deploys a Mobile Foundation Analytics on the Kubernetes cluster. The [configuration](#configuration) section lists the parameters that can be configured during installation.
> **Tip**: See all the resources deployed by the chart using `kubectl get all -l release=my-release`

### Uninstalling the Chart

You can uninstall/delete the `my-release` release as follows:

```sh
helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart, except any Persistent Volume Claims (PVCs).  This is the default behavior of Kubernetes, and ensures that valuable data is not deleted.  In order to delete the Analytics data, you can delete the PVC using the following command:

```sh
kubectl delete pvc -l release=my-release
```

## Accessing MobileFoundation Analytics

From a web browser, go to the IBM Cloud Private console page and navigate to the helm releases page as follows

1. Click on Menu on the Left Top of the Page
2. Select **Workloads** > **Helm Releases**
3. Click on the deployed *IBM MobileFoundation Analytics* helm release
4. Refer the **Notes** section for the procedure to access the MobileFoundation Analytics Console

NOTE: The Port number 9600 is exposed internally in the Kubernetes service. This is used by the MobileFirst Analytics instances as the transport port 

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
|           | repository          | Docker image name | Name of the MobileFirst Operational Analytics docker image |
|           | tag          | Docker image tag | See Docker tag description |
| scaling | replicaCount | The number of instances (pods) of MobileFirst Operational Analytics that need to be created | Positive integer (Default: 2) |
| mobileFirstAnalyticsConsole | user | Username for MobileFirst Operational Analytics | Default: admin |
|                       | password | Password for MobileFirst Operational Analytics | Default: admin |
|  analyticsConfiguration | clusterName | Name of the MobileFirst Analytics cluster. | defaults to "mobilefirst"|
|                       | numberOfShards | Number of Elasticsearch shards for MobileFirst Analytics | default to 2|             
|                       | replicasPerShard | Number of Elasticsearch replicas to be maintained per each shard for MobileFirst Analytics | default to 2|             
|                          | analyticsDataDirectory | Path where analytics data is stored. ( It will also be the same path where the persistent volume claim is mounted inside the container) | defaults to "/analyticsData"|
| keystores | keystoresSecretName | Refer the configuration section to pre-create the secret with keystores and their passwords.|
| jndiConfigurations | mfpfProperties | MobileFirst JNDI properties to be specified to customize operational analytics| Supply comma separated name value pairs  |
| ingress | enabled | Enable ingress | Specifies whether to use Ingress. Default: false |
|         | hostname | Hostname of the Endpoint to be configured | The hostname of the Endpoint that has to be configured in the ingress definition. Mandatory if Ingress is enabled |
|         | tlsEnabled | Enable SSL/TLS | Specifies whether to enable TLS on the Ingress endpoint. Default: false |
|         | tlsSecretName | TLS secret name| Specifies the secret name for the certificate that has to be used in the Ingress definition. The secret has to be pre-created using the relevant certificate and key. Mandatory if SSL/TLS is enabled. Pre-create the secret with Certificate & Key before supplying the name here |
|         | sslPassThrough | Enable SSL passthrough | Specifies is the SSL request should be passed through to the MobileFirst service - SSL termination occurs in the MobileFirst service. Default: false |
| resources | limits.cpu  | Describes the maximum amount of CPU allowed.  | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|                  | limits.memory | Describes the maximum amount of memory allowed. | Default is 4096Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)|
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value.  | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value. | Default is 2048Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
| persistence | enabled         | Use a PVC to persist data                        | true                                                     |
|            |useDynamicProvisioning      | Specify a storageclass or leave empty  | false                                                    |
| dataVolume|existingClaimName| Provide an existing PersistentVolumeClaim          | nil                                                      |
|           |storageClass     | Storage class of backing PVC                       | nil                                                      |
|           |size             | Size of data volume                                | 20Gi        
| logs| consoleFormat | Specifies container log output format. | Default is **json** |
|  | consoleLogLevel | Controls the granularity of messages that go to the container log. | Default is **info** |
| | consoleSource | Specify sources that are written to the container log. Use a comma separated list for multiple sources. | Default is **message, trace, accessLog, ffdc** |                                             |


## Limitations

