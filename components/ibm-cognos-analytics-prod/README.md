# Cognos Analytics

IBM® Cognos® Analytics (formerly IBM Cognos Business Intelligence)
provides reports, analysis, dashboards and scoreboards to help support
the  way people think and work when they are trying to understand
business performance. You can freely explore information, analyze key
facts and quickly collaborate to align decisions with key stakeholders.

* Reports equip users with the information they need to make fact-based
  decisions.
* Dashboards help users access, interact and personalize
  content in a way that supports how they make decisions.
* Analysis capabilities provide access to information from multiple angles and
  perspectives so you can view and analyze it to make informed
  decisions.
* Collaboration capabilities include communication tools and
  social networking to fuel the exchange of ideas during the
  decision-making process.
* Scorecarding capabilities automate the
  capture, management and monitoring of business metrics so you can
  compare them with your strategic and operational objectives.


## Introduction
This chart can be used to launch the Cognos Analytics Application in a Kubernetes cluster.

## Chart Details
* Simple bullet list of what is deployed as the standard config
* General description of the topology of the workload
* Keep it short and specific with items such as : ingress, services, storage, pods, statefulsets, etc.

## Prerequisites
* Kubernetes Level - indicate if specific APIs must be enabled (i.e. Kubernetes 1.6 with Beta APIs enabled)
* PersistentVolume requirements (if persistence.enabled) - PV
  provisioner support, StorageClass defined, etc. (i.e. PersistentVolume
  provisioner support in underlying infrastructure with ibmc-file-gold
  StorageClass defined if persistance.enabled=true)
* Simple bullet list of CPU, MEM, Storage requirements
* Even if the chart only exposes a few resource settings, this section
  needs to inclusive of all / total resources of all charts and
  subcharts.

### PodSecurityPolicy Requirements
  [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp)

  - Custom PodSecurityPolicy definition: 
    ```
     Use 'Cluser-Admin' role to perform the following actions: cloudctl as admin
     1. This step is needed only once in a cluster. Install a custom Pod Security Policy (ibm-cognos-analytics-prod-psp) and ClusterRole (ibm-cognos-analytics-prod-cr).  
         a. execute the following script which will create a custom PSP and a ClusterRole for RBAC.  
         - pak_extensions/pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

     2. Create a namespace and associate the new custom PSP.  
         a. from ICP console: Manage - Namespaces -> Create Namespaces   
         b. select 'ibm-cognos-analytics-prod-psp' from Pod Security Policy dropdown.  
         c. optional: note that you can also apply the PSP from command-line by executing the following script:
          - execute: pak_extensions/pre-install/clusterAdministration/createSecurityNamespacePrereqs.sh <namespace>

## Resources Required
* Describes Minimum System Resources Required


## Installing the Chart
* Include at the basic things necessary to install the chart from the Helm CLI - the general happy path
* Include setup of other items required
* Security privileges required to deploy chart
* Include verification of the chart
* Ensure CLI only and avoid any ICP or ICS language used

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release ibm-cognos-analytics-prod [--tls]
```

The command deploys <Chart name> on the Kubernetes cluster in the
default configuration. The [configuration](#configuration) section lists
the parameters that can be configured during installation.


> **Tip**: List all releases using `helm list [--tls]`

* Generally teams have subsections for :
   * Verifying the Chart
   * Uninstalling the Chart

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge [--tls]
```

The command removes all the Kubernetes components associated with the
chart and deletes the release. If a delete can result in orphaned
components include instructions with additional commands required for
clean-up.

For example :

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
```

## Configuration
* Define all the parms in the values.yaml
* Include "how used" information
* If special configuration impacts a "set of values", call out the set
  of values required (a = true, y = abc_value, c = 1) to get a desired
  outcome. One example may be setting on multiple values to turn on or
  off TLS.

The following tables lists the configurable parameters of the `cognos-analysis` chart and their default values.


| Parameter                              | Description                                                                                     | ICP Default                      | OS Default                       |
|:---------------------------------------|:------------------------------------------------------------------------------------------------|:---------------------------------|:---------------------------------|
| cs.pvc.enabled                         | Provision a persistent volume claim                                                             | true                             | true                             |
| cs.pvc.pvProvisioning                  | What provisioning class to use; one of DefaultStorageClass, NamedStorageClass or NoStorageClass | DefaultStorageClass              | DefaultStorageClass              |
| cs.pvc.storageClassName                | Name of storage class if using `NamedStorageClass`                                              | empty                            | empty                            |
| cs.pvc.selector.label                  | If using `NoStorageClass`, use selectors to refine the binding process                          | empty                            | empty                            |
| cs.pvc.selector.value                  | If using `NoStorageClass`, use selectors to refine the binding process                          | empty                            | empty                            |
| cs.pvc.size                            | If using `DefaultStorageClass` or `NamedStorageClass` this is the size of the storage volume    | 10Gi                             | 10Gi                             |
|                                        |                                                                                                 |                                  |                                  |
| ds.ingress.enabled                     | Is the dataset ingress enabled, needed for load balancing and routing                           | true                             | false                            |
| ds.route.enabled                       | Is the dataset route enabled, needed for load balancing and routing                             | false                            | true                             |
|                                        |                                                                                                 |                                  |                                  |
| rs.ingress.enabled                     | Is the report ingress enabled, needed for load balancing and routing                            | true                             | false                            |
| rs.route.enabled                       | Is the report route enabled, needed for load balancing and routing                              | false                            | true                             |
|                                        |                                                                                                 |                                  |                                  |
| nginx-ns.serviceNginxIngress.enabled   | Is the service to the Nginx Ingress controller enabled                                          | true                             | false                            |
|                                        |                                                                                                 |                                  |                                  |
| global.ppaChart                        | Will we be generating a Passport Advantage chart                                                | false                            | false                            |
|                                        |                                                                                                 |                                  |                                  |
| global.arch.amd64                      | Used when `ppaChart=false`.  Specifies node architecture affinity                               | 3 - Most preferred               | 3 - Most preferred               |
| global.arch                            | Used when `ppaChart=true`. Specifies node architecture affinity                                 | empty                            | empty                            |
|                                        |                                                                                                 |                                  |                                  |
| global.image.repository                | The docker image registry                                                                       | registry.local:5000              | registry.local:5000              |
|                                        |                                                                                                 |                                  |                                  |
| global.filebeat.output.logstashEnabled | Is the logstash logging sink enabled                                                            | true                             | false                            |
| global.filebeat.output.consoleEnabled  | Logging to filebeat console                                                                     | false                            | true                             |
| global.filebeat.image.repository       | Filebeat image repository                                                                       | docker.elastic.co/beats/filebeat | docker.elastic.co/beats/filebeat |
| global.filebeat.image.tag              | Filebeat image tag                                                                              | 5.5.1                            | 5.5.1                            |
| global.filebeat.image.pullPolicy       | Filebeat image pull policy                                                                      | IfNotPresent                     | IfNotPresent                     |
|                                        |                                                                                                 |                                  |                                  |
| global.logstash.ip                     | Logstash service IP                                                                             | logstash.kube-system             | logstash.kube-system             |
| global.logstash.port                   | Logstash service port                                                                           | 5044                             | 5044                             |
|                                        |                                                                                                 |                                  |                                  |


A subset of the above parameters map to the env variables defined in
[(PRODUCTNAME)](PRODUCTDOCKERURL). For more information please refer to
the [(PRODUCTNAME)](PRODUCTDOCKERURL) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default values.yaml

## Tests

You can use Helm to run tests against the service that this chart provides.  After you've installed the application:

```bash
helm install waca/daas --name my-release
```

you can run tests like this:

```bash
helm test my-release --cleanup
```

The `--cleanup` option deletes the test pods after they are finished - which means the logs of the tests will be unavailable.

## Making Helm Wait Until Cognos Analysis is Ready

The [Helm docs](https://docs.helm.sh/using_helm/#helpful-options-for-install-upgrade-rollback) show a way you can
make the `helm install ...` and `helm upgrade ...` command wait for all the resources described by this chart to become ready.

The `--wait` and `--timeout` options can be used to make the `helm` command block until the application is ready.

For example, the following command will install the waca/daas chart and wait up to 600 seconds for all the pods that make up the daas application to become ready.

```bash
helm install waca/daas --name my-release --wait --timeout 600
```

Note that this `--wait` flag is only useful if the [`DeploymentStrategy`](https://v1-8.docs.kubernetes.io/docs/api-reference/v1.8/#deploymentstrategy-v1beta2-apps) resources described in the charts can tell Kubernetes the minimum number of pods a deployment should have.

For example, if the deployment strategy is [`RollingUpdate`](https://v1-8.docs.kubernetes.io/docs/api-reference/v1.8/#rollingupdatedeployment-v1beta2-apps) the chart must include a value for the `maxUnavailable` field.

```yaml
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
```

## MongoDB and Redis dependencies

In developer K8s environments the MongoDB and Redis services will be provided by the community [MongoDB](https://github.com/kubernetes/charts/tree/master/stable/mongodb) & [Redis](https://github.com/kubernetes/charts/tree/master/stable/redis) charts.

This is done for the following reasons.

* This ensures dev environments won't trample on each others data.
* We need to learn more about Helm chart conditional dependencies.

## Running DAAS in BlueMix

```bash
eval $(bx cs cluster-config endor --export) && \
helm install -n foo . \
  --set \
  proxy.image=registry.ng.bluemix.net/daas/daas-sb-proxy,\
  server.image=registry.ng.bluemix.net/daas/daas_server,\
  ingress.hosts={"daas.us-south.containers.mybluemix.net"},\
  ingress.tls.hosts={"daas.us-south.containers.mybluemix.net"},\
  mongodb.persistence.enabled=false,\
  redis.persistence.enabled=false \
  --wait && helm test foo --cleanup
```

### TLS Certificates

A TLS certificate is required enable SSL traffic with DaaS.

The TLS parameters for this chart can be set in `helm` values files or via the `helm` command line via `--set` options like this:

```bash
helm install -n bar waca/daas \
   -f ../../daas-pipe-releases/configs/datacenter/bluemix-common.yml \
   -f ../../daas-pipe-releases/configs/environment/integration.yaml \
   -f ../../daas-pipe-releases/configs/release/daas-release.yaml \
   --set ingress.tls[0].secretName=bar-daas-self-signed-cert,ingress.tls[0].hosts="{daas.endor.us-south.containers.mybluemix.net}" \
   --wait --timeout 500
```

This example overrides the [tls  settings](https://v1-8.docs.kubernetes.io/docs/api-reference/v1.8/#ingresstls-v1beta1-extensions) for the ingress.

The Kubernetes secret named `bar-daas-self-signed-cert` is a secret of
type [kubernetes.io/tls](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls)
and will be used for requests directed to host `daas.endor.us-south.containers.mybluemix.net`.  This implies that
 this secret contains a TLS certificate that is valid for the specified host.

It is possible to use the name of a pre-existing secret as well (this
will likely be the general use case for the near future).

## Storage
* Define how storage works with the workload
* Dynamic vs PV pre-created
* Considerations if using hostpath, local volume, empty dir
* Loss of data considerations
* Any special quality of service or security needs for storage

## Limitations
* Deployment limits - can you deploy more than once, can you deploy into different namespace
* List specific limitations such as platforms, security, replica's, scaling, upgrades etc.. - noteworthy limits identified
* List deployment limitations such as : restrictions on deploying more than once or into custom namespaces.
* Not intended to provide chart nuances, but more a state of what is supported and not - key items in simple bullet form.
* Does it work on IBM Container Services, IBM Private Cloud ?

## Documentation
* Can have as many supporting links as necessary for this specific workload however don't overload the consumer with unnecessary information.
* Can be links to special procedures in the knowledge center.

