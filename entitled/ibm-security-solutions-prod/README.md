
## ibm-security-solutions-prod


## Introduction
IBM Cloud Pak for Security Shared Platform Services, `ibm-security-solutions-prod`, provides a shared platform that integrates your disconnected security systems for a complete view of all your security data, without moving the data. It turns individual apps, services, and capabilities into unified solutions to empower your teams to act faster, and improves your security posture with collective intelligence from a global community. Reduce complexity, expand your visibility and maximize your existing investments with a powerful, open, cloud security platform that connects your teams, tools and data. For further details see the [IBM Cloud Pak for Security Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0/docs/scp-core/overview.html).

## Chart details

This chart installs `ibm-security-solutions-prod`, providing the IBM Cloud Pak for Security Shared Core Services.

## Prerequisites

- The `ibm-security-foundations-prod` chart must be installed prior to this chart
- This chart must be installed into the same namespace as the `ibm-security-foundations-prod` chart
- Red Hat OpenShift Container Platform 3.11
  - Kubernetes 1.11.0
- IBM Cloud Private 3.2.1
  - Common Services 3.2.1
  - Tiller 2.12.3 or later
  - Helm 2.12.3
- Cluster admin privileges
- Crunchy Data Postgres 4.0.1, this [link](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0/docs/security-pak/postgrescerts.html) provides details on how the Postgres Service will be created.
- Persistent storage is configured



## PodDisruptionBudget
Pod disruption budget is used to maintain high availability during Node maintenance. Administrator role or higher is required to enable pod disruption budget on clusters with role based access control. The default is false. See `global.poddisruptionbudget` in the [configuration](#configuration) section.


## Red Hat OpenShift SecurityContextConstraints requirements

This chart requires a SecurityContextConstraints object to be bound to the target namespace prior to installation. 

The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart and is configured as required in the preinstallation of the ibm-security-foundations-prod chart.


## Resources required

By default, `ibm-security-solutions-prod` has the following resource requests requirements per pod:

| Service  | Memory (GB) | CPU (cores) 
| --------- | ----------- | ----------- |
| Cases  |    7780Mi   |  1400M  |
| Platform | 1996Mi | 1200M  |
| DE | 384Mi | 300M | 
| CAR | 128Mi | 100M |
| UDS | 250Mi | 50M |
| TIISearch | 128Mi | 100M |
| CSA Adapter| 256Mi | 200M | 

See the [configuration](#configuration) section for how to configure these values.


## Pre-install steps

### Log in to the cluster and set the namespace

The `ibm-security-solutions-prod` chart _must_ be installed into the same namespace as the `ibm-security-foundations-prod` chart. You must set the namespace when running commands such as `helm`, `oc` or `kubectl`. For example:

- Set the namespace on log in:
  ```
  cloudctl login -n <NAMESPACE>
  ```
- Set the namespace after log in:
  ```
  oc project <NAMESPACE>
  ```
- Specify the namespace in a command:
  ```
  kubectl -n namespace [command]

### Check persistent storage

This chart sets `global.useDynamicProvisioning` to true. Dynamic provisioning must not be disabled.

Verify that:
- A suitable storage class is created in the cluster
- The storage class is backed by suitably sized external storage
- The storage class is labelled as `default`
- No other storage class in the cluster is labelled as default

To check that the expected storage class is enabled and set as default, run:
```
oc get storageclass
```

The output may look something like this:
```
kubectl get storageclass
NAME                      PROVISIONER                                           AGE
glusterfs-storage         kubernetes.io/glusterfs                               27d
nfs-client (default)      cluster.local/quieting-hyena-nfs-client-provisioner   27d
```

To label the required storage class as `default`, run:
```
kubectl patch storageclass <STORAGE_CLASS_NAME> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

Ensure that no other storage class is set as `default`. To remove the default label from a storage class, run:

```
kubectl patch storageclass <STORAGE_CLASS_NAME> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

Ensure that one and only one storage class is labelled `(default)`.

## Installing the chart

### Fetch and extract the chart
To perform a command line installation, first fetch and extract the chart.

The helm repository from which to fetch the charts depends on whether you are installing using IBM Entitled Registry or IBM Passport Advantage. See the [IBM Cloud Pak for Security Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0/docs/security-pak/installation.html) for more details. The steps below assume you are installing using IBM Entitled Registry.

Check that `helm` has the entitled repository:
```
helm repo list entitled
```

If it does not, run the following command to add the entitled repository:
```
helm repo add entitled https://raw.githubusercontent.com/IBM/charts/master/repo/entitled/
```

You can now fetch and extract the chart:
```
helm fetch entitled/ibm-security-solutions-prod
tar xzf ibm-security-solutions-prod-<RELEASE>.tgz
```

Commands below starting with the relative path `ibm-security-solutions-prod/` must be run in the directory where you extracted the chart.


### Create platform secret

The script `createISCPlatformSecret.sh` stores cluster administrator credentials in a secret. These are used to invoke IBM Cloud Private administration APIs while this chart is installing.

Before run the script log in to the cluster.

The script is run as follows: 
```
ibm-security-solutions-prod/ibm_cloud_pak/pak_extensions/pre-install/createISCPlatformSecret.sh <NAMESPACE> <CLUSTER_USERNAME> <PASSWORD>
```

###  Create TLS certificates

A fully qualified domain name (FQDN) must be created for the Cloud Pak for Security application. It must not be same as the Red Hat OpenShift Container Platform (RHOCP) cluster FQDN or IBM Cloud Private FQDN or any other FQDN associated with the RHOCP cluster. The application FQDN must point to the RHOCP cluster public IP address.
 
A TLS certificate must be provided for the application FQDN, which may be either a certificate for a given domain (e.g. my.test.com) or a wildcard certificate (e.g. *.test.com). The certificate must be signed by a well-known certificate authority.
 
##### Certificate signed by a well-known certificate authority
To preload a certificate signed by the existing certificate authority (CA), the script `createTLSSecret.sh` is provided. 

If necessary, append the CA certificate, and any intermediate certificates, to the certificate file to create a valid certificate bundle. The certificate bundle must then be passed to the script as the cert file.

The script must be run as follows: 
```
ibm-security-solutions-prod/ibm_cloud_pak/pak_extensions/pre-install/createTLSSecret.sh <NAMESPACE> <PATH_TO_KEY_FILE> <PATH_TO_CERT_FILE>
```

### Labelling Nodes for OpenWhisk
In order to schedule OpenWhisk pods in your cluster, nodes need to be labelled as OpenWhisk Invokers. You may choose to label all of your compute nodes using the following command:
```
kubectl label nodes --selector='node-role.kubernetes.io/compute' openwhisk-role=invoker
```
This is recommended as it allows the workload of OpenWhisk to be balanced across the cluster.

You must specify the number of OpenWhisk invoker nodes you have enabled in the [configuration variable](#configuration) `global.invokerReplicaCount` when installing the chart. This will ensure that an invoker pod is scheduled on each labelled node.


Alternatively if you would like to selectively label your nodes, you may discover your workers by running `kubectl get nodes`, for example:
```
kubectl get nodes
NAME                STATUS   ROLES                                              AGE   VERSION
master-node         Ready    icp-management,icp-master,icp-proxy,infra,master   1d    v1.11.0+d4cacc0
worker-node-1       Ready    compute                                            1d    v1.11.0+d4cacc0
worker-node-2       Ready    compute                                            1d    v1.11.0+d4cacc0
worker-node-3       Ready    compute                                            1d    v1.11.0+d4cacc0
```

And then individually label nodes:
```
kubectl label node worker-node-1 openwhisk-role=invoker
kubectl label node worker-node-2 openwhisk-role=invoker
kubectl label node worker-node-3 openwhisk-role=invoker
```

To verify, you can get a list of nodes which have the labels applied by running:
```
kubectl get nodes --selector='openwhisk-role=invoker'
```

To remove the OpenWhisk Invoker label from a single node you can run:
```
kubectl label node worker-node-1 openwhisk-role-
```

And to remove the OpenWhisk Invoker label from all nodes you can run:
```
kubectl label nodes --all openwhisk-role-
```


### Set up service account for ElasticSearch
This chart requires a SecurityContextConstraints object to be bound to the target namespace prior to installation.
It is required that you allow the pods running Elasticsearch to run privileged containers. The reason for this requirement is to meet the [production settings stated officially by the Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.7/system-config.html). To achieve this, you must  you must also create a service account called `ibm-dba-ek-isc-cases-elastic-bai-psp-sa` that has the [ibm-privileged-scc](https://ibm.biz/cpkspec-scc) SecurityContextConstraint to allow running privileged containers:
```
oc create serviceaccount ibm-dba-ek-isc-cases-elastic-bai-psp-sa
oc adm policy add-scc-to-user ibm-privileged-scc -z ibm-dba-ek-isc-cases-elastic-bai-psp-sa
```

### Install the chart

To install the chart, you must provide
- release name
- namespace
- required user-specified values

A release name must be specified when installing the chart. It is suggested to use `ibm-security-solutions-prod` as the default/initial release name.

The `ibm-security-solutions-prod` chart _must_ be installed into the same namespace as the `ibm-security-foundations-prod` chart. Before running the helm installation, run the following command to enter that namespace
```
oc project <NAMESPACE>
```

Certain values _must_ be provided when installing the chart. 

| Parameter | Note |
| --- | --- |
| `global.storageClass` | Required |
| `global.cluster.hostname` | Required |
| `global.domain.default.domain` | Required|
| `global.repository` | Required if installing [using IBM Passport Advantage](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0/docs/security-pak/ppa_download.html), you must specify a docker registry host (and path if relevant). Note that the repository you specify here must match the repository specified during the pre-install of ibm-security-foundations-prod (which creates an image pull secret for that repository). |
| `global.repositoryType` | If installing from Passport Advantage archives, change to `local` |

The full set of configuration values are in the [configuration](#configuration) section below.

To specify these values for a command line installation, either edit the values file or pass the values on the command line.

To edit the values file
- Edit the `ibm-security-solutions-prod/values.yaml` file (or optionally copy the file to another directory)
- Run the helm command with the additional option `--values <PATH_TO_VALUES_YAML>`

To pass the values on the command line
- Run the helm command with an additional `--set <VARNAME>=<VALUE>` option for each value
- For example: `--set global.repository=cp.icr.io/cp/cp4s [...]`

Before running the helm install log in to the cluster and set the namespace.

To install the chart run the following command:

```
helm install --name <RELEASE_NAME> --namespace=<NAMESPACE>  ./ibm-security-solutions-prod --tls [--values or --set options]
```

### Verify the chart

For chart verification after the Helm installation completes, follow the instructions in the NOTES.txt which is packaged with the chart. For release `ibm-security-solutions-prod`, the instructions can also be viewed by running the command:
```
helm status <RELEASE_NAME> --tls
```

### Install IBM Cloud Security Advisor Adapter

After installing the ibm-security-solutions-prod chart, optionally install the [IBM Cloud Security Advisor Adapter](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0/docs/scp-core/security-advisor-cases.html).

To install the adapter, run the command:
```
helm upgrade <RELEASE_NAME> --tls --set global.ibm-isc-csaadapter-prod.enabled=true
```

Alternatively edit the values.yaml file and run the command:
```
helm upgrade <RELEASE_NAME> --tls --values <PATH_TO_VALUES_YAML>
```

#### Verify the IBM Cloud Security Advisor Adapter

To verify that the adapter installed succesfully, run the command:
```
kubectl get pod -lname isc-csaadapter
```

The output must be similar to the following example:
```
NAME                              READY   STATUS    RESTARTS   AGE
isc-csaadapter-68cdb8644c-2b4pd   1/1     Running   0          4d
```

### Upgrade or update the installation

If you have previously installed Cloud Pak for Security, you can upgrade to a later version of the software or apply updates to configuration values by running the helm `upgrade` command.

To upgrade the installation, first run the command:
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-upgrade/preUpgrade.sh <NAMESPACE>
```

The preUpgrade script is available in the ibm-security-foundations-prod chart. See the [ibm-security-foundations-prod chart README](https://github.com/IBM/charts/blob/master/entitled/ibm-security-foundations-prod/README.md) for details of how to fetch the chart.

Then run the command:
```
helm upgrade [OPTIONS]
```

where OPTIONS are as described in [Install the chart](#install-the-chart) above.


### Uninstall the chart

To uninstall the chart, run the following command:
```
helm delete --purge <RELEASE_NAME> --tls 
```

The following script must be run as follows: 
```
ibm-security-solutions-prod/ibm_cloud_pak/pak_extensions/post-delete/Cleanup.sh <NAMESPACE> --force --all
```

#### Uninstall the Postgres service
This [link](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0/docs/security-pak/postgrescerts.html) provides details on how the Postgres Service can be uninstalled.


#### Remove service account for ElasticSearch

The following command can be run to remove the `ibm-dba-ek-isc-cases-elastic-bai-psp-sa` service account that is created for Elasticsearch.
```
oc delete serviceaccount ibm-dba-ek-isc-cases-elastic-bai-psp-sa -n <NAMESPACE>
```

## Configuration

The following table lists the configurable parameters of the ibm-security-solutions-prod chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
|global.affinity|Enables the distribution of pods across nodes | hard |
|global.arangodb.agentConfiguration.storageClassName| Default storage class for arangodb agent| [Required] |
|global.arangodb.dbserverConfiguration.storageClassName| Default storage class for arangodb server| [Required] |
|global.cluster.hostname| Cluster Hostname | [Required] |
|global.domain.default.domain| Default ingress domain for the application |  [Required] |
|global.ibm-isc-car-prod.enabled | Optional Deployment of CAR  |true|
|global.ibm-isc-cases-prod.enabled | Optional Deployment of Cases  |true|
|global.ibm-isc-csaadapter-prod.enabled   | Optional Deployment of CSA adapter |true|
|global.ibm-isc-tii-prod.enabled | Optional Deployment of TII  |true|
|global.ibm-isc-uds-prod.enabled | Optional Deployment of UDS  |true|
|global.imagePullPolicy| Docker image pull policy |`IfNotPresent`  |
|global.invokerReplicaCount| Openwhisk Invoker Replicas | 3 |
|global.poddisruptionbudget| Enables application availability during a cluster node maintenance. Administrator role or higher required to enable PDB.| false |
|global.poddisruptionbudget.minAvailable| Minimum number of probe replicas that must be available during pod eviction| 1 |
|global.replicas| Number of Replicas | 2 |
|global.repository| Platform Repository | cp.icr.io/cp/cp4s |
|global.repositoryType| Repository Type from which the Images will pulled from. Options available are: entitled, local. Use `entitled` for Entitled Registry or `local`for all other repository types  | `entitled` |
|global.resources.activemq.memoryRequest | Memory requests for cases activemq service | 768Mi |
|global.resources.application.memoryRequest | Memory requests for cases application service | 3072Mi| 
|global.resources.car.car.requests.cpu | CPU requests for car ingestion service | 100m |
|global.resources.car.car.requests.memory | Memory requests for car ingestion service | 128Mi |
|global.resources.csa.csaadapter.requests.cpu | CPU requests for cloud security adviser adapter service | 200m |
|global.resources.csa.csaadapter.requests.memory | Memory requests for cloud security adviser adapter service |256Mi|
|global.resources.de.backend.requests.cpu | CPU requests for data explorer webui service | 100m |
|global.resources.de.backend.requests.memory | Memory requests for data explorer webui service | 128Mi |
|global.resources.de.webui.requests.cpu | CPU requests for data explorer webui service | 200m |
|global.resources.de.webui.requests.memory | Memory requests for data explorer webui service | 256Mi |
|global.resources.platform.aitkwebui.requests.cpu | CPU requests for aitkwebui service | 100m |
|global.resources.platform.aitkwebui.requests.memory | Memory requests for aitkwebui service | 128Mi |
|global.resources.platform.authsvc.requests.cpu | CPU requests for auth service | 200m |
|global.resources.platform.authsvc.requests.memory | Memory requests for auth service | 128Mi |
|global.resources.platform.console.requests.cpu | CPU requests for console service | 100m |
|global.resources.platform.console.requests.memory | Memory requests for console service | 200Mi |
|global.resources.platform.entitlements.requests.cpu | CPU requests for entitlements service | 100m |
|global.resources.platform.entitlements.requests.memory | Memory requests for entitlements service | 256Mi |
|global.resources.platform.iscauth.requests.cpu| CPU requests for isc auth service | 100m |
|global.resources.platform.iscauth.requests.memory | Memory requests for isc auth service | 128Mi |
|global.resources.platform.iscprofile.requests.cpu | CPU requests for isc profile service | 100m |
|global.resources.platform.iscprofile.requests.memory | Memory requests for isc profile service | 128Mi |
|global.resources.platform.orchestrator.celery.requests.cpu | CPU requests for aitk orchestrator celery service | 100m |
|global.resources.platform.orchestrator.celery.requests.memory | Memory requests for aitk orchestrator celery service | 300Mi |
|global.resources.platform.orchestrator.celerybeat.requests.cpu | CPU requests for aitk orchestrator celerybeat service | 100m |
|global.resources.platform.orchestrator.celerybeat.requests.memory | Memory requests for aitk orchestrator celerybeat service | 128Mi |
|global.resources.platform.orchestrator.orchestrator.requests.cpu | CPU requests for aitk orchestrator service | 100m |
|global.resources.platform.orchestrator.orchestrator.requests.memory | Memory requests for aitk orchestrator service | 300Mi |
|global.resources.platform.shell.requests.cpu | CPU requests for shell service | 100m |
|global.resources.platform.shell.requests.memory | Memory requests for shell service | 300Mi |
|global.resources.scripting.memoryRequest | Memory requests for cases scripting service | 768Mi |
|global.resources.tii.tiisearch.requests.cpu | CPU requests for threat intelligence search service | 100m |
|global.resources.tii.tiisearch.requests.memory | Memory requests for threat intelligence search service | 128Mi |
|global.resources.uds.udswebui.requests.cpu | CPU requests for unified data service webui | 50m |
|global.resources.uds.udswebui.requests.memory | Memory requests for unified data service webui | 250Mi |
|global.storageClass| Storage class for persistence | [Required] |


## Limitations

This chart can only run on amd64 architecture type.

This chart sets `global.useDynamicProvisioning` to `true`. Dynamic provisioning must not be disabled in the current version.


## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSMF6Q/docs/isc-core/isc-platform-overview.html)
