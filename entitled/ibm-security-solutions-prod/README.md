
## ibm-security-solutions-prod

## Introduction
IBM Cloud Pak For Security Shared Platform Services, `ibm-security-solutions-prod`, provides shared platform that integrates your disconnected security systems for a complete view of all your security data, without moving the data. It turns individual apps, services, and capabilities into unified solutions to empower your teams to act faster, and improves your security posture with collective intelligence from a global community. Reduce complexity, expand your visibility and maximize your existing investments with a powerful, open, cloud security platform that connects your teams, tools and data.

The chart deploys:
- Platform Services: Comprise of a Common UX - CLX is a common initiative across IBM cloud offerings to create a more integrated and meaningful experience for our clients, and make application development simpler and more agile
Also includes Profile and Entitlement Services.

- Analytics Toolkit: Common analytics pipeline and API allowing analytics creation and re-usability as assets across the platform. Allows composable pipelines of analytics (output from one fed into the next) based on a simple syntax. Allows analytics modules in the pipeline to be developed in the form of docker containers.  Allows analytics to be executed both on-demand, as well as scheduled for building of ML models. Allows analytics to be built based on the UDS, allowing common input data formats (STIX).

- Unified Data Services: Universal Data Service to provide the ability for applications to query and combine security data from any data source (QRadar, Splunk, ELK, BigFix, Carbon Black, etc.), either in the cloud or on-premise, using a standards-compliant STIX query language and syntax. Access data and insights across all data lakes and ponds via a simple STIX API

- Data Explorer: Searches across your data sources to help you identify indicators of compromise that may be found in your environment. Query all of your security intelligence data and instantly retrieve contextual details from one unified interface, regardless of where that data lives.

- CAR: Graph database that links all tenant asset and user information, and allows risk calculations for said assets and risks. “Assets” include information on endpoints, databases, vulnerabilities. “Users” includes User/Group information, entitlements, and LDAP/AD attributes, and are mapped to assets based on access by the user. Services for importing data info this database as well as APIs.

- TII: Threat intelligence Insights search functionality allows users to query potential threat indicators  vulnerabilities,malware,botnets on the ISC.

- Cases: Provides organizations with the clarity and context they need to resolve cybersecurity incidents. With the increasing scope, scale, and frequency of security incidents, companies of all sizes must be able to rapidly assess a situation, follow a plan of action, and confidently recover from a cybersecurity attack. With Cases, Security and IT teams can draw on depth of expertise of IBM Security, automate enrichment and remediation, and collaborate across their organizations.

## Chart Details

This chart installs the `ibm-security-solutions-prod` for the  IBM Cloud Pak For Security Shared Platform Services

## Prerequisites

- The `ibm-security-foundations-prod` chart must be installed prior to this chart
- This chart _must_ be installed into the same namespace as the `ibm-security-foundations-prod`
- Tiller 2.12.3 or later
- Helm 2.12.3
- Kubernetes 1.11.0 
- OpenShift 3.11
- Common Services 3.2.1
- Cluster Admin privileges
- Crunchy Data Postgres 4.0.1, this [link](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0/docs/security-pak/postgrescerts.html) provides details on how the Postgres Service will be created.
- LDAP Configuration

## PodDisruptionBudget
No pod distribution pre install is required as it has been defined in as part of the deployment.

### SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.
## Resources Required

By default, `ibm-security-solutions` has the following resource requirements per pod:

- 500m CPU core
- 512 Mi memory

Cases Application Pod:
- 3072Mi memory

Cases Scripting Pod:
- 1024Mi memory

Cases ActiveMq Pod:
- 1024Mi memory

See the [configuration](#configuration) section for how to configure these values.

## Installing the Chart

### Fetch and extract the chart
To perform a command line installation, first fetch and extract the chart.

Check that `helm` has the entitled repository:
```
helm repo list entitled
```

If it does not, execute the following command to add the entitled repository:
```
helm repo add entitled https://raw.githubusercontent.com/IBM/charts/master/repo/entitled/
```

You can now fetch and extract the chart:
```
helm fetch entitled/ibm-security-solutions-prod
tar xzf ibm-security-solutions-prod-<RELEASE>.tgz
```

Commands below starting with the relative path `ibm-security-solutions-prod/` should be executed in the directory where you extracted the chart.


### Pre-install steps

#### Check persistent storage

This chart sets `global.useDynamicProvisioning` to true. Dynamic provisioning must not be disabled in the current version.

The installation of this chart has been verified with the nfs-client storage class, backed with NFS version 4 storage. (NFS version 3 is not suitable.)

Verify that:
- A suitable storage class is created in the cluster
- The storage class is backed by suitably sized external storage
- The storage class is labelled as `default`
- No other storage class in the cluster is labelled as default

To check that the expected storage class is enabled and set as default, execute:
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

To label the required storage class as `default`, execute:
```
kubectl patch storageclass <STORAGE_CLASS_NAME> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

Ensure that no other storage class is set as `default`. To remove the default label from a storage class, execute:
```
kubectl patch storageclass <STORAGE_CLASS_NAME> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

Ensure that one and only one storage class is labelled `(default)`.


#### Create platform secret

The script `createISCPlatformSecret.sh` creates secret required for the platform services.

The script is executed as follows: 
```
ibm-security-solutions-prod/ibm_cloud_pak/pak_extensions/pre-install/createISCPlatformSecret.sh <NAMESPACE> <CLUSTER_USERNAME> <PASSWORD>
```

#### Create TLS certificates

A fully qualified domain name (FQDN) should be created for the Cloud Pak for Security application. It should not be same as the RHOCP cluster FQDN or IBM Cloud Private FQDN or any other FQDN associated with the RHOCP cluster. The application FQDN should point to the RHOCP cluster public IP.
 
A TLS certificate should be provided for the application FQDN, which may be either a certificate for a given domain (e.g. my.test.com) or a wildcard certificate (e.g. *.test.com). The certificate must be signed by a well-known certificate authority.
 
##### Certificate signed by a well-known certificate authority
To preload a certificate signed by the existing certificate authority (CA), the script `createTLSSecret.sh` is provided. The script should be executed as follows: 
 
```
ibm-security-solutions-prod/ibm_cloud_pak/pak_extensions/pre-install/createTLSSecret.sh <NAMESPACE> <PATH_TO_KEY_FILE> <PATH_TO_CERT_FILE>
```

The CA certificate has to be appended to the certificate file so the certificate to load looks like
```
-----BEGIN CERTIFICATE-----
......
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
......
-----END CERTIFICATE-----
```

#### Labelling Nodes for OpenWhisk
In order to schedule OpenWhisk pods in your cluster, nodes need to be labelled as OpenWhisk Invokers. You may choose to label all of your non-master nodes using the following command:
```
kubectl label nodes --selector='!node-role.kubernetes.io/master' openwhisk-role=invoker
```
This is recommended as it allows the workload of OpenWhisk to be balanced across the cluster.

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

To remove the OpenWhisk Invoker label from a sinlge node you can run:
```
kubectl label node worker-node-1 openwhisk-role-
```

And to remove the OpenWhisk Invoker label from all nodes you can run:
```
kubectl label nodes --all openwhisk-role-
```


#### Setting up Service Account for ElasticSearch
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation.
It is required that you allow the pods running Elasticsearch to run privileged containers. The reason for this requirement is to meet the [production settings stated officially by the Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/6.7/system-config.html). To achieve this, you must  you must also create a service account called `ibm-dba-ek-isc-cases-elastic-bai-psp-sa` that has the [ibm-privileged-scc](https://ibm.biz/cpkspec-scc) SecurityContextConstraint to allow running privileged containers:
```
oc create serviceaccount ibm-dba-ek-isc-cases-elastic-bai-psp-sa
oc adm policy add-scc-to-user ibm-privileged-scc -z ibm-dba-ek-isc-cases-elastic-bai-psp-sa
```


### Install ibm-security-solutions-prod Chart

To install the chart, you must provide
- release name
- namespace
- required user-specified values

A release name must be specified when installing the chart. It is suggested to use `ibm-security-solutions-prod` as the default/initial release name.

The `ibm-security-solutions-prod` chart _must_ be installed into the same namespace as the `ibm-foundations-prod` chart.

Before executing the helm installation, run the following command to enter that namespace
```
oc project <NAMESPACE>
```

Certain values _must_ be provided when installing the chart. The full set of configuration values are in the Configuration section below. The values that must be explicitly provided are
- `global.repository`
- `global.cluster.hostname`
- `global.domain.default.domain`

To specify these values for a command line installation, either edit the values file or pass the values on the command line.

To edit the values file
- Edit the `ibm-security-solutions-prod/values.yaml` file (or optionally copy the file to another directory)
- Execute the helm command with the additional option `--values <PATH_TO_VALUES_YAML>`

To pass the values on the command line
- Execute the helm command with an additional `--set <VARNAME>=<VALUE>` option for each value
- For example: `--set global.repository=cp.icr.io [...]`

To install the chart run the following command:
NOTE: <RELEASE_NAME> is the name of the chart. Default name is ibm-security-solutions-prod.
```
helm install --name <RELEASE_NAME> --namespace=<NAMESPACE>  ./ibm-security-solutions-prod --tls [--values or --set options]
```

### Verifying the Chart

For chart verification after the Helm installation completes, follow the instructions in the NOTES.txt which is packaged with the chart. For release `ibm-security-solutions-prod`, the instructions can also be viewed by running the command:
```
helm ls <RELEASE_NAME> --tls
helm status <RELEASE_NAME> --tls
```

### Uninstalling the Chart

To uninstall the chart, run the following command:

```
helm delete --purge <RELEASE_NAME> --tls 
```
The following script should be executed as follows:
 
```
ibm-security-solutions-prod/ibm_cloud_pak/pak_extensions/post-delete/Cleanup.sh <NAMESPACE> --force --all
```

#### Uninstalling the Postgres Service
This [link](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0/docs/security-pak/postgrescerts.html) provides details on how the Postgres Service can be uninstalled.


#### Uninstalling Service Account for ElasticSearch

The following command can be run to remove the `ibm-dba-ek-isc-cases-elastic-bai-psp-sa` service account that is created for Elasticsearch.
```
oc delete serviceaccount ibm-dba-ek-isc-cases-elastic-bai-psp-sa -n <NAMESPACE>
```

## Configuration

The following table lists the configurable parameters of the ibm-security-solutions-prod chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
|global.repository| Platform Repository |  |
|global.imagePullPolicy| Docker image pull policy |  |
|global.replicas| Number of Replicas | 2 |
|global.cluster.hostname| Cluster Hostname | User must provide a value. |
|global.domain.default.domain| Default Domain |  User must provide a ingress domain. |
|global.storageClass| Default storage class for persistence | nfs|
|global.affinity|Enables the distribution of pods across nodes | hard |
|global.poddisruptionbudget| Enables application protection availability during a cluster node maintenance. Administrator role or higher required to enable PDB.| true |
|global.poddisruptionbudget.minAvailable| Minimum number of probe replicas that must be available during pod eviction| 1 |
|global.invokerReplicaCount| Openwhisk Invoker Replicas | 3 |
|imageRepositories.registry| Image Repositories Registry | |
|imageRepositories.registry.username| Image Repositories Registry Username  | |
|imageRepositories.registry.password| Image Repositories Registry Password | |


## Limitations

This chart can only run on amd64 architecture type.

This chart sets `global.useDynamicProvisioning` to `true`. Dynamic provisioning must not be disabled in the current version.

Ensure only and only one storage class is labelled `(default)`.



## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSMF6Q/docs/isc-core/isc-platform-overview.html)
