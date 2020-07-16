
## ibm-security-solutions-prod

## Introduction
IBM Cloud Pak&reg; for Security Shared Platform Services, `ibm-security-solutions-prod`, provides a shared platform that integrates your disconnected security systems for a complete view of all your security data, without moving the data. It turns individual apps, services, and capabilities into unified solutions to empower your teams to act faster, and improves your security posture with collective intelligence from a global community. Reduce complexity, expand your visibility and maximize your existing investments with a powerful, open, cloud security platform that connects your teams, tools and data. For further details see the [IBM Cloud Pak for Security Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.3.0/cp4s_v1r3/docs/scp-core/overview.html).

## Chart Details

This chart installs `ibm-security-solutions-prod`, providing the IBM Cloud Pak for Security Shared Core Services.

The Cases and Postgres operators deployed as part of this chart are Namespace-scoped. They watch and manage resources within the namespace that IBM Cloud Pak for Security is installed

## Prerequisites

- The `ibm-security-foundations-prod` chart must be installed prior to this chart
- This chart must be installed into the same namespace as the `ibm-security-foundations-prod` chart
- Red Hat OpenShift Container Platform 4.3 or 4.4
- IBM Cloud Platform Common Services 3.2.4
- Cluster Admin privileges
- Persistent storage is configured

## PodDisruptionBudget
Pod disruption budget is used to maintain high availability during Node maintenance. Administrator role or higher is required to enable pod disruption budget on clusters with role based access control. The default is false. See `global.poddisruptionbudget` in the [configuration](#configuration) section.


## SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints object to be bound to the target namespace prior to installation. 

The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, It is required that you allow the pods running Elasticsearch to run privileged containers. The reason for this requirement is to meet the production settings stated officially by the Elasticsearch documentation. To achieve this, you must you must also create a service account called ibm-dba-ek-isc-cases-elastic-bai-psp-sa that has the ibm-privileged-scc SecurityContextConstraint to allow running privileged containers.

## Resources Required

By default, `ibm-security-solutions-prod` has the following resource requests requirements per pod:

| Service  | Memory (GB) | CPU (cores) 
| --------- | ----------- | ----------- |
| Cases  |    9838Mi   |  1520M  |
| Platform | 2190Mi | 1225M  |
| DE | 512Mi | 300M |
| CAR | 128Mi | 100M | 
| Extensions | 128Mi | 100M |
| UDS | 250Mi | 50M |
| TII | 900Mi | 600M |
| TIS | 1536Mi | 600M |
| CSA Adapter| 256Mi | 200M |


See the [configuration](#configuration) section for how to configure these values.

## Storage
IBM Cloud Pak for Security requires specific persistent volumes and persistent volume claims. To provide the required storage, persistent volume claims are created automatically during the installation of IBM Cloud Pak for Security.

Persistent storage separates the management of storage from the management and lifecycle of compute. For example, persistent storage, allows data to persist across Kubernetes container and worker restarts.

For more details on the size of the persistent volume please refer to [persistent storage requirements](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.3.0/cp4s_v1r3/docs/security-pak/persistent_storage.html)

The persistent volume claim must have an access mode of ReadWriteOnce (RWO).

For volumes that support ownership management, specify the group ID of the group owning the persistent volumes' file systems using the `global.postgres.cases.installOptions.primary.fsGroup` and `global.postgres.cases.installOptions.backrest.fsGroup` parameters as described in [configuration](#configuration) below.


## Pre-install Steps

### Log in to the cluster and set the namespace

The `ibm-security-solutions-prod` chart _must_ be installed into the same namespace as the `ibm-security-foundations-prod` chart. 

- Set the namespace on log in:
  ```
  cloudctl login -n <NAMESPACE>
  ```

## Installing the Chart


### Execute Pre-Reqs for Cloud Pak for Security Solutions

A Fully Qualified Domain Name (FQDN) must be created for the Cloud Pak for Security application. It must not be same as the Red Hat OpenShift Container Platform (RHOCP) cluster FQDN or IBM Cloud Platform Common Services FQDN or any other FQDN associated with the RHOCP cluster. The application FQDN must point to the RHOCP cluster public IP address or hostname.

A Transport Layer Security (TLS) certificate must be provided for the application FQDN, which may be either a certificate for a given domain (e.g. my.test.com) or a wildcard certificate (e.g. *.test.com). 

The certificate may be: 
- Signed by a well-known Certificate of Authority (CA).
- Not signed by a well-known Certificate of Authority
   - The CA certificate must be passed to the script as [ -ca CACertFile ].
   - The combined certificate + CA certificate is passed as the [ -cert certfile ]. 

The script `preInstall.sh` is used to manage pre-requisite parameters.

The script performs the following actions:
- stores cluster IBM Cloud Platform Common Services administrator credentials in a secret
- configures provided TLS certificate for the application domain
- loads CA certificate when TLS certificate is generated by custom CA


The script possible parameters are:

|  Parameter                  | Comment 
| --------------------------- | -------------------------------------------
| -n NAMESPACE                | to use provided namespace instead of current |
| -force                      | to replace existing secrets | 
| -cluster username:password  | to create secret with IBM Cloud Platform Common Services cluster admin credentials |
| -cert certfile -key keyfile | to associate Cloud Pak for Security ingress with a provided TLS cert and key file | 
| -ca certfile                | to optionally provide certificate of CA if not well known |


#### Create cluster credentials
##### Create cluster credentials with customer provided Certificate and Key

```
ibm-security-solutions-prod/ibm_cloud_pak/pak_extensions/pre-install/preInstall.sh -cluster <ICPadmin>:<ICPpassword> -cert <CertFile> -key <KeyFile> [ -ca <CACertFile> ]
```

### Check Prerequisites

A script is provided in the `ibm-security-foundations-prod` chart which should be run to validate pre-requisites before beginning the install of `ibm-security-solutions-prod`. 

This script is run with the following command : 

```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-install/checkprereq.sh -n <NAMESPACE> --solutions
```

Output will display the default storage class and when successfull will indicate : 

```
INFO: ibm-security-solutions prerequisites are OK
```

Any errors should be resolved before continuing.


### Install the Chart

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
| `global.storageClass` | Required. Note, if the `global.storageClass` applies to all PVCs, including Postgres, it must support `fsGroup` so that mounted PVCs are writable. |
| `global.cluster.hostname` | Deprecated (Should only be used for upgrade scenarios when parameter was already defined) |
| `global.cluster.icphostname` | Required. FQDN of the ICP console |
| `global.domain.default.domain` | Required|
| `global.repository` | Required if installing [using IBM Passport Advantage](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.3.0/cp4s_v1r3/docs/security-pak/ppa_download.html), you must specify a docker registry host (and path if relevant). Note that the repository you specify here must match the repository specified during the pre-install of ibm-security-foundations-prod (which creates an image pull secret for that repository). |
| `global.repositoryType` | If installing from Passport Advantage archives, change to `local` |

The full set of configuration values are in the [configuration](#configuration) section below.

To specify these values for a command line installation, either edit the values file or pass the values on the command line.

To edit the values file
- Edit the `ibm-security-solutions-prod/values.yaml` file (or optionally copy the file to another directory)
- Run the helm command with the additional option `--values <PATH>/values.yaml`

To pass the values on the command line
- Run the helm command with an additional `--set <VARNAME>=<VALUE>` option for each value
- For example: `--set global.repository=cp.icr.io/cp/cp4s [...]`

#### Install IBM Cloud Security Advisor Adapter	
Optionally install the [IBM Cloud Security Advisor Adapter](https://www.ibm.com/support/knowledgecenter/en/SSTDPP_1.3.0/cp4s_v1r3/docs/scp-core/csa-adapter-cases.html) by adding this parameter as part of the install command ` --set global.ibm-isc-csaadapter-prod.enabled=true`.

Before running the helm install log in to the cluster and set the namespace.

**Start the installation process from the CLI:**

```
helm install --name <RELEASE_NAME> --namespace=<NAMESPACE>  ./ibm-security-solutions-prod --tls --values <PATH>/values.yaml [--set options]
```
   
### Verify the Chart

Once the install of `ibm-security-solutions-prod` has completed, to verify the outcome execute the following:

1. Using the <RELEASE_NAME> specified, the following commands can be used to view the status of the installation.

 


a. `helm ls <RELEASE_NAME> --tls`

__Expected Result:__ The `ibm-security-solutions-prod` should be in a `Deployed` state.

b. `helm status <RELEASE_NAME> --tls`

__Expected Result:__ The `ibm-security-solutions-prod` resources should listed as `STATUS: DEPLOYED` and list all resources deployed.

c. Execute the helm tests to verify installation `helm test <RELEASE_NAME> --cleanup --tls`

__Expected Result:__ All Helm Tests should have a status of `PASSED`


d. The [checkcr.sh](ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/support/checkcr.sh) script checks status of the CP4S installation process. The script should be executed specifying the namespace to which the CP4S was deployed by the customer.

`ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/support/checkcr.sh [ -n <NAMESPACE> ] --all`

__Expected Result:__ There are no  failures returned from executing  `checkcr.sh`



### Upgrade or update the installation

If you have previously installed Cloud Pak for Security, you can upgrade to a later version of the software or apply updates to configuration values by running the helm `upgrade` command.

To upgrade the installation, first run the command:
```
ibm-security-solutions-prod/ibm_cloud_pak/pak_extensions/pre-upgrade/preUpgrade.sh [ -n <NAMESPACE> ]
```


Prior to executing the `helm upgrade` command below complete the steps in [Check prerequisites](#check-prerequisites)

Then execute the following `getSetupParameters.sh` script to retrieve your environment specific values set in the previous install of Cloud Pak for Security:

```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/support/getSetupParameters.sh --solutions
```

**Trigger the upgrade process from the CLI:**

```
helm upgrade <RELEASE_NAME> --namespace=<NAMESPACE>  ./ibm-security-solutions-prod --tls --values <PATH>/values.yaml [--set options]
```
    
 where passing `--values <PATH>/values.yaml` and `[--set options]` retrieved from output of `getSetupParameters.sh` script above.

Once the helm upgrade has been completed, run the post-upgrade script:
```
ibm-security-solutions-prod/ibm_cloud_pak/pak_extensions/post-upgrade/postUpgrade.sh [ -n <NAMESPACE> ]
```
Validate the status of the upgrade by following the steps in [Verifying the Chart](#verifying-the-chart).


### Uninstall the Chart

To uninstall the chart, run the following command:
```
helm delete --purge <RELEASE_NAME> --tls --timeout 800
```

The following script must be run as follows: 
```
ibm-security-solutions-prod/ibm_cloud_pak/pak_extensions/post-delete/Cleanup.sh [ -n <NAMESPACE> ] --nowait --all 
```


## Configuration

The following table lists the configurable parameters of the ibm-security-solutions-prod chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
|global.affinity| Enables the distribution of pods across nodes | hard |
|global.arangodb.agentConfiguration.count| Number of ArangoDB deployment agent | 3 |
|global.arangodb.agentConfiguration.args| ArangoDB agent arguments |  `- "--rocksdb.block-cache-size=1073741824"`<br>`- "--cache.size=134217728"`<br>`- "--rocksdb.total-write-buffer-size=1073741824"`<br>`- "--agency.supervision-grace-period=30"` |
|global.arangodb.agentConfiguration.resources.requests.storage | Storage size of ArangoDB deployment agent | 20Gi |
|global.arangodb.agentConfiguration.resources.requests.cpu | CPU requested by ArangoDB deployment agent | 50m |
|global.arangodb.agentConfiguration.resources.requests.memory | Memory requested by ArangoDB deployment agent | 400Mi |
|global.arangodb.agentConfiguration.limits.requests.cpu | CPU limits of ArangoDB deployment agent | 400m |
|global.arangodb.agentConfiguration.limits.requests.memory | Memory limits of ArangoDB deployment agent | 2500Mi |
|global.arangodb.singleConfiguration.count| ArangoDB server replica count | 2 |
|global.arangodb.singleConfiguration.args| Deployment ArangoDB server arguments |  `- "--rocksdb.block-cache-size=1073741824"`<br>`- "--cache.size=134217728"`<br>`- "--rocksdb.total-write-buffer-size=1073741824"` |
|global.arangodb.singleConfiguration.resources.requests.storage | Storage size of ArangoDB deployment servers | 20Gi |
|global.arangodb.singleConfiguration.resources.requests.cpu | CPU requested by ArangoDB deployment servers | 25m |
|global.arangodb.singleConfiguration.resources.requests.memory | Memory requested by ArangoDB deployment servers | 580Mi |
|global.arangodb.singleConfiguration.limits.requests.cpu | CPU limits of ArangoDB deployment servers | 1 |
|global.arangodb.singleConfiguration.limits.requests.memory | Memory limits of ArangoDB deployment servers | 5Gi |
|global.cluster.hostname| Fully Qualified Domain Name(FQDN) of the cluster | Deprecated (Should only be used for upgrade scenarios when parameter was already defined) |
|global.cluster.icphostname| Fully Qualified Domain Name(FQDN) of ICP console (default icp-console.apps.<Cluster>). | Required |
|global.domain.default.domain| Fully Qualified Domain Name(FQDN) for the Cloud Pak for Security application domain |  [Required] |
|global.elastic.cases.installOptions.storageClassName| Storage class name for Cases elastic service | "" |
|global.elastic.cases.installOptions.storageSize| Storage size for Cases elastic service | 25Gi |
|global.ibm-isc-car-prod.enabled | Optional Deployment of CAR  |true|
|global.ibm-cp4s-extensions-prod.enabled | Optional Deployment of extension |true|
|global.ibm-isc-cases-prod.enabled | Optional Deployment of Cases  |true|
|global.ibm-isc-csaadapter-prod.enabled   | Optional Deployment of CSA adapter |false|
|global.ibm-isc-tii-prod.enabled | Optional Deployment of TII  |true|
|global.ibm-isc-uds-prod.enabled | Optional Deployment of UDS  |true|
|global.aitk.analyticsImageTag | Image version of the analytics to use  | release-amd64 |
|global.aitk.activeJobsLimit| Max allowed active analytic jobs | 100 |
|global.imagePullPolicy| Docker image pull policy |`IfNotPresent`  |
|global.invokerReplicaCount| Openwhisk Invoker Replicas | 3 |
|global.poddisruptionbudget| Enables application availability during a cluster node maintenance. Administrator role or higher required to enable PDB.| false |
|global.poddisruptionbudget.minAvailable| Minimum number of probe replicas that must be available during pod eviction| 1 |
|global.postgres.cases.installOptions.primary.limits.cpu | CPU limit for cases Postgresql cluster | 750m |
|global.postgres.cases.installOptions.primary.limits.memory | Memory limit for cases Postgresql cluster | 1Gi |
|global.postgres.cases.installOptions.primary.requests.cpu | CPU requests for cases Postgresql cluster | 300m |
|global.postgres.cases.installOptions.primary.requests.memory | Memory requests for cases Postgresql cluster | 500Mi |
|global.postgres.cases.installOptions.primary.storageClassName| Specify the Postgres storage class for cases Postgresql cluster. If unspecified, `global.storageClass` is used. The specified storage class must support fsGroup. | ""|
|global.postgres.cases.installOptions.primary.storageSize| Storage size for cases Postgresql cluster | 100Gi |
|global.postgres.cases.installOptions.primary.fsGroup| fsgroup for cases Postgresql cluster storage | 26 |
|global.postgres.cases.installOptions.primary.supplementalGroups| supplementalGroups for cases Postgresql cluster storage | ""|
|global.postgres.cases.installOptions.backrest.limits.cpu | CPU limit for pgbackrest service | 500m |
|global.postgres.cases.installOptions.backrest.limits.memory | Memory limit for pgbackrest service | 200Mi |
|global.postgres.cases.installOptions.backrest.requests.cpu | CPU requests for pgbackrest service | 20m |
|global.postgres.cases.installOptions.backrest.requests.memory | Memory requests for pgbackrest service | 48Mi |
|global.postgres.cases.installOptions.backrest.storageClassName| Specify the Postgres storage class for pgbackrest service. If unspecified, `global.storageClass` is used. The specified storage class must support fsGroup.| ""|
|global.postgres.cases.installOptions.backrest.storageSize| Storage size for pgbackrest service | 50Gi |
|global.postgres.cases.installOptions.backrest.fsGroup| fsgroup for backrest storage service | 26 |
|global.postgres.cases.installOptions.backrest.supplementalGroups| supplementalGroups for backrest storage service | ""|
|global.replicas| Number of Replicas | 2 |
|global.repository| Platform Repository | cp.icr.io/cp/cp4s |
|global.repositoryType| Repository Type from which the Images will pulled from. Options available are: entitled, local. Use `entitled` for Entitled Registry or `local`for all other repository types  | `entitled` |
|global.resources.cases.activemq.requests.cpu | CPU requests for cases activemq service | 100m|
|global.resources.cases.activemq.requests.memory | Memory requests for cases activemq service | 768Mi|
|global.resources.cases.application.requests.cpu | CPU requests for cases application service | 250m|
|global.resources.cases.application.requests.memory | Memory requests for cases application service | 3072Mi|
|global.resources.cases.elastic.client.heapsize | Heap size for cases elastic client service | 1024m|
|global.resources.cases.elastic.client.requests.cpu | CPU requests for cases elastic client service | 100m|
|global.resources.cases.elastic.client.requests.memory | Memory requests for cases elastic client service | 1Gi|
|global.resources.cases.elastic.data.heapsize | Heap size for cases elastic data service | 1024m|
|global.resources.cases.elastic.data.requests.cpu | CPU requests for cases elastic data service | 100m|
|global.resources.cases.elastic.data.requests.memory | Memory requests for cases elastic data service | 1Gi|
|global.resources.cases.elastic.master.heapsize | Heap size for cases elastic master service | 1024m|
|global.resources.cases.elastic.master.requests.cpu | CPU requests for cases elastic master service | 100m|
|global.resources.cases.elastic.master.requests.memory | Memory requests for cases elastic master service | 1Gi|
|global.resources.cases.loggingsidecars.requests.cpu | CPU requests which is applied to 7 cases logging sidecars | 10m|
|global.resources.cases.loggingsidecars.requests.memory | Memory requests which is applied to 7 cases logging sidecars | 100Mi|
|global.resources.cases.resutil.requests.cpu | Memory requests for cases resutil pod | 10m|
|global.resources.cases.resutil.requests.memory | Memory requests for cases resutil pod | 10Mi|
|global.resources.cases.scripting.requests.cpu | CPU requests for cases scripting service | 250m|
|global.resources.cases.scripting.requests.memory | Memory requests for cases scripting service | 768Mi|
|global.resources.car.car.requests.cpu | CPU requests for car ingestion service | 100m |
|global.resources.car.car.requests.memory | Memory requests for car ingestion service | 128Mi |
|global.resources.carConnectorTenable.carConnectorTenable.requests.cpu | CPU requests for car Tenable connector | 100m |
|global.resources.carConnectorTenable.carConnectorTenable.requests.memory | Memory requests for car Tenable connector | 128Mi |
|global.resources.carConnectorAzure.carConnectorAzure.requests.cpu | CPU requests for car Azure connector | 100m |
|global.resources.carConnectorAzure.carConnectorAzure.requests.memory | Memory requests for car Azure connector | 128Mi |
|global.resources.carConnectorATP.carConnectorATP.requests.cpu | CPU requests for car ATP connector | 100m |
|global.resources.carConnectorATP.carConnectorATP.requests.memory | Memory requests for car ATP connector | 128Mi |
|global.resources.carConnectorAWS.carConnectorAWS.requests.cpu | CPU requests for car AWS connector | 100m |
|global.resources.carConnectorAWS.carConnectorAWS.requests.memory | Memory requests for car AWS connector | 128Mi |
|global.resources.csa.csaadapter.requests.cpu | CPU requests for cloud security adviser adapter service | 200m |
|global.resources.csa.csaadapter.requests.memory | Memory requests for cloud security adviser adapter service |256Mi|
|global.resources.de.backend.requests.cpu | CPU requests for data explorer webui service | 100m |
|global.resources.de.backend.requests.memory | Memory requests for data explorer webui service | 256Mi |
|global.resources.de.webui.requests.cpu | CPU requests for data explorer webui service | 200m |
|global.resources.de.webui.requests.memory | Memory requests for data explorer webui service | 256Mi |
|global.resources.platform.aitkwebui.requests.cpu | CPU requests for aitkwebui service | 100m |
|global.resources.platform.aitkwebui.requests.memory | Memory requests for aitkwebui service | 128Mi |
|global.resources.platform.configstore.requests.cpu | CPU requests for configstore service | 25m |
|global.resources.platform.configstore.requests.memory | Memory requests for configstore service | 100Mi |
|global.resources.platform.authsvc.requests.cpu | CPU requests for auth service | 200m |
|global.resources.platform.authsvc.requests.memory | Memory requests for auth service | 128Mi |
|global.resources.platform.console.requests.cpu | CPU requests for console service | 100m |
|global.resources.platform.console.requests.memory | Memory requests for console service | 200Mi |
|global.resources.platform.pulse.requests.memory | Memory requests for pulse service | 200Mi |
|global.resources.platform.pulse.requests.cpu | CPU requests for pulse service | 100m |
|global.resources.platform.entitlements.requests.cpu | CPU requests for entitlements service | 100m |
|global.resources.platform.entitlements.requests.memory | Memory requests for entitlements service | 150Mi |
|global.resources.platform.entitlements_operator.requests.cpu | CPU requests for entitlements operator | 100m |
|global.resources.platform.entitlements_operator.requests.memory | Memory requests for entitlements operator | 100Mi |
|global.resources.platform.iscauth.requests.cpu| CPU requests for isc auth service | 100m |
|global.resources.platform.iscauth.requests.memory | Memory requests for isc auth service | 128Mi |
|global.resources.platform.iscprofile.requests.cpu | CPU requests for isc profile service | 100m |
|global.resources.platform.iscprofile.requests.memory | Memory requests for isc profile service | 128Mi |
|global.resources.platform.orchestrator.celery.requests.cpu | CPU requests for aitk orchestrator celery service | 100m |
|global.resources.platform.orchestrator.celery.requests.memory | Memory requests for aitk orchestrator celery service | 900Mi |
|global.resources.platform.orchestrator.celerybeat.requests.cpu | CPU requests for aitk orchestrator celerybeat service | 100m |
|global.resources.platform.orchestrator.celerybeat.requests.memory | Memory requests for aitk orchestrator celerybeat service | 128Mi |
|global.resources.platform.orchestrator.orchestrator.requests.cpu | CPU requests for aitk orchestrator service | 100m |
|global.resources.platform.orchestrator.orchestrator.requests.memory | Memory requests for aitk orchestrator service | 300Mi |
|global.resources.platform.shell.requests.cpu | CPU requests for shell service | 100m |
|global.resources.platform.shell.requests.memory | Memory requests for shell service | 300Mi |
|global.resources.tii.tiisearch.requests.cpu | CPU requests for threat intelligence search service | 100m |
|global.resources.tii.tiisearch.requests.memory | Memory requests for threat intelligence search service | 150Mi |
|global.resources.tii.tiiapp.requests.cpu | CPU requests for threat intelligence app service | 100m |
|global.resources.tii.tiiapp.requests.memory | Memory requests for threat intelligence app service | 150Mi |
|global.resources.tii.tiireports.requests.cpu | CPU requests for threat intelligence reports service | 100m |
|global.resources.tii.tiireports.requests.memory | Memory requests for threat intelligence reports service | 150Mi |
|global.resources.tii.tiithreats.requests.cpu | CPU requests for threat intelligence threat service | 100m |
|global.resources.tii.tiithreats.requests.memory | Memory requests for threat intelligence threat service | 150Mi |
|global.resources.tii.tiisettings.requests.cpu | CPU requests for threat intelligence settings | 100m |
|global.resources.tii.tiisettings.requests.memory | Memory requests for threat intelligence settings | 150Mi |
|global.resources.tii.tiixfeproxy.requests.cpu | CPU requests for threat intelligence proxy | 100m |
|global.resources.tii.tiixfeproxy.requests.memory | Memory requests for threat intelligence proxy | 150Mi |
|global.resources.tis.tisrfi.requests.memory | Memory requests for threat intelligence service rfi | 256Mi |
|global.resources.tis.tisrfi.requests.cpu | CPU requests for threat intelligence rfi | 100m |
|global.resources.tis.tisaia.requests.memory | Memory requests for threat intelligence am i affected service| 256Mi |
|global.resources.tis.tisaia.requests.cpu | CPU requests for threat intelligence am i affected service | 100m |
|global.resources.tis.tisdatagateway.requests.memory | Memory requests for threat intelligence datagateway service| 256Mi |
|global.resources.tis.tisdatagateway.requests.cpu | CPU requests for threat intelligence datagatewayd service | 100m |
|global.resources.tis.tisuserregistration.requests.memory | Memory requests for threat intelligence userregistration service| 256Mi |
|global.resources.tis.tisuserregistration.requests.cpu | CPU requests for threat intelligence userregistration service | 100m |
|global.resources.tis.tiscoordinator.requests.memory | Memory requests for threat intelligence tiscoordinator service| 256Mi |
|global.resources.tis.tiscoordinator.requests.cpu | CPU requests for threat intelligence tiscoordinator service | 100m |
|global.resources.tis.tisscoring.requests.memory | Memory requests for threat intelligence tiscoordinator service| 256Mi |
|global.resources.tis.tisscoring.requests.cpu | CPU requests for threat intelligence tiscoordinator service | 100m |
|global.resources.uds.udswebui.requests.cpu | CPU requests for unified data service webui | 50m |
|global.resources.uds.udswebui.requests.memory | Memory requests for unified data service webui | 250Mi |
|global.storageClass| Storage class for persistence | [Required] |




## Limitations

This chart can only run on amd64 architecture type.

This chart sets `global.useDynamicProvisioning` to `true`. Dynamic provisioning must not be disabled in the current version.


## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSTDPP_1.3.0/cp4s_v1r3/docs/scp-core/overview.html)
