# IBM® Cloud App Management

## Introduction

IBM® Cloud App Management offers a comprehensive infrastructure monitoring solution. It's a cloud-native platform built on modern technology and microservices architecture. If you're already using IBM Cloud APM, IBM Tivoli® Monitoring, or IBM Tivoli Composite Application Manager, Cloud App Management guides you forward.

With IBM® Cloud App Management you can:
  - Monitor Kubernetes-managed resources
  - View Java runtime metrics and usage analytics
  - Automatically group events for consolidated views and customize alerts so action can be taken quickly
  - Correlate the performance of your microservices, their dependencies, and the underlying core infrastructure over time to identify the root cause of  issues
  - Monitor the health of your service through availability metrics, user satisfaction scores, and throughput data as you roll out continuous updates.
  - Drill down into container-level metrics to understand if resources are impacting performance when issues arise.
  - Automatic instrumentation when you use Microservice Builder to create your Java-based microservice.
  - Quick instrumentation with the Cloud App Management Liberty data collector for monitoring of workloads and services
  - Create and manage baselines for resource metrics (technical preview)

## Resources Required
  - Minimum CPU - 12 Cores
  - Minimum Memory - 32Gi
  - Minimum Disk (Persistent Storage) - 75Gi

> **Note**: CPU(GHz) >= 2.4

> **Note**: These requirements are for IBM® Cloud App Management only and do not include any other workloads or the platform requirements.

The resource requirements differ depending on which size you use. To determine which size to use, please refer to detailed information found at [Planning hardware and sizing](https://ibm.biz/app-mgmt-hw-scale).

## Limitations
- amd64 is the only fully supported architecture
- ppc64le is a supported architecture when running with Cloud Pak for Multicloud Manager on Red Hat OpenShift 3.11

## Prerequisites

  - IBM® Cloud Private (ICP) 3.2
  - Kubernetes >=1.11.0
  - Tiller >=2.10.0

#### Red Hat OpenShift
  - Red Hat OpenShift Container Platform 3.11 or 4.2

#### Secrets Requirements

TLS secrets are required to authenticate communication between the server and its clients.
- TLS Secret (e.g. `icam-ingress-tls`)
- Client Secret (e.g. `icam-ingress-client`)
- Artifacts (e.g. `icam-ingress-artifacts`)

In order to create a self-signed certificate to validate the communication, one of the following may be done:
1) During installation, set the `createTLSCerts` key to `true`. When true, a Kubernetes job will run prior to the server installation which will create the self-signed certificate and required secrets.

or

2) Prior to install, an admin may create the certificate and secrets using the `make-ca-cert-icam.sh` script included in the ibm-cloud-appmgmt-prod chart. This script is located in the `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/lib` directory.


#### Elasticsearch vm.max_map_count requirements
Elasticsearch requires you to set a kernel parameter to run normally. This needs to be done on all worker nodes where the Elasticsearch pod may be scheduled. Persistent storage configuration for Elasticsearch may limit where the pods are able to be scheduled. You need to set the `vm.max_map_count` to a value of at least `1048575`.

For each applicable node, set the parameter with sysctl to ensure that the change takes effect immediately:

`sysctl -w vm.max_map_count=1048575`

For each applicable node, save the parameter in /etc/sysctl.conf to ensure that the change is still in effect after a node restart:

`vm.max_map_count=1048575`

### PodSecurityPolicy Requirements

**NOTE:** For OpenShift, see SecurityContextConstraints Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart. If your target namespace is not bound with this PodSecurityPolicy, then a binding must be made with the predefined PodSecurityPolicy or the `ibm-cloud-appmgmt-prod` custom PodSecurityPolicy below.

The custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart are found below. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the `pak_extension` pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-cloud-appmgmt-prod-psp
    spec:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      allowedCapabilities:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
      seLinux:
        rule: 'RunAsAny'
      supplementalGroups:
        rule: 'MustRunAs'
        ranges:
        - min: 1
          max: 65535
      runAsUser:
        rule: 'MustRunAsNonRoot'
      fsGroup:
        rule: 'MustRunAs'
        ranges:
        - min: 1
          max: 65535
      volumes:
      - configMap
      - secret
      - persistentVolumeClaim
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-cloud-appmgmt-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-cloud-appmgmt-prod-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
  - The ClusterRole must be applied to the target namespace's serviceaccount group through a RoleBinding.

- A cluster admin can use the cluster administration script located at:
  - `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration/createSecurityClusterPrereqs.sh`

- A team admin can use the namespace administration script located at:
  - `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh`

### Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation.

If IBM® Cloud App Management is *not* installed with the Cloud Pak, certain measures must be taken to provide the appropriate SecurityContextConstraints for the installation.

The predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if the service accounts for your target namespace have access to this SecurityContextConstraint resource, you can proceed to install the chart. If the service accounts for your target namespace do not have access to this SecurityContextConstraint resource, use `oc adm policy` to update the SCC to include the user or group for these service accounts.

This chart may also use a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy. You can enable this custom SecurityContextConstraints resource using the administrative scripts in the `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/pre-install` directory.

- To create the custom SecurityContextConstraints directly from the user interface, copy and paste the following snippets
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-cloud-appmgmt-prod-scc
    readOnlyRootFilesystem: false
    allowedCapabilities:
    - CHOWN
    - DAC_OVERRIDE
    - SETGID
    - SETUID
    - NET_BIND_SERVICE
    seLinux:
      rule: 'RunAsAny'
    supplementalGroups:
      rule: 'MustRunAs'
      ranges:
      - min: 1
        max: 65535
    runAsUser:
      rule: 'MustRunAsNonRoot'
    fsGroup:
      rule: 'MustRunAs'
      ranges:
      - min: 1
        max: 65535
    volumes:
    - configMap
    - secret
    - persistentVolumeClaim
    ```
  - Add the target namespace's serviceaccount group to this SCC

- To create and apply the custom SecurityContextConstraints from the command line, run the setup scripts included under `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/pre-install`

  For a cluster admin, use the cluster scoped administrative script:
  - `clusterAdministration/createSecurityClusterPrereqs.sh`

  or

  For a team admin, use the namespace scoped administrative script:
  - `namespaceAdministration/createSecurityNamespacePrereqs.sh`

### Internal (In Cluster) Network Encryption - Recommended
Use IPSec between the nodes in your cluster to ensure all internal connections are encrypted.
More details can be found at [Encrypting cluster data network traffic with IPsec](http://ibm.biz/icp-ipsec_mesh)

## Storage
IBM® Cloud App Management requires persistent storage. For more information, see [Planning hardware and sizing](https://ibm.biz/app-mgmt-hw-scale).

The recommended storage technologies are Local and vSphere. Block storage on bare metal may be applicable for certain use cases.

Persistent storage is required for each of the following stateful services: Cassandra, Kafka, ZooKeeper, CouchDB, and Datalayer, and Elasticsearch.


### Secure Encryption of Persistent Storage
Encryption of persistent storage can be achieved through encryption of the host file system upon which the persistent     volumes are created. For instructions on how to set up encryption using LUKS, refer to [these instructions](https://www.ibm.com/support/knowledgecenter/en/SS6PEW_10.0.0/com.ibm.help.security.dimeanddare.doc/security/t_security_settingupluksencryption.html).

## Configuration
More details can be found at
- [Installing IBM Cloud Application Management for IBM Multicloud Manager](http://ibm.biz/icam-mcm)
- [Installing IBM Cloud App Management on Red Hat Openshift](https://ibm.biz/app-mgmt-ocp-standalone)
- [Installing IBM Cloud App Management on IBM Cloud Private](https://ibm.biz/app-mgmt-icp-standalone)

## Installing the Chart
**NOTE:** The following instructions are for IBM® Cloud Application Management Base and Advanced only. To install IBM® Cloud App Management with the IBM Cloud Pak for Multicloud Management see [Installing IBM Cloud Application Management with IBM Cloud Pak for Multicloud Management](http://ibm.biz/icam-mcm).

### Upgrade from 2019.3.0

- For detailed instructions on upgrading from ICAM 2019.3.0 to ICAM 2019.4.0 go to [Upgrading the Cloud App Management server](https://ibm.biz/app-mgmt-server-upgrade)

### Install via CLI
**NOTE:** The following instructions are for IBM® Cloud Application Management Base and Advanced only. To install IBM® Cloud App Management with the IBM Cloud Pak for Multicloud Management see [Installing IBM Cloud Application Management with IBM Cloud Pak for Multicloud Management](http://ibm.biz/icam-mcm).

IBM® Cloud Application Management includes a `pre-install.sh` to prompt you through the Cloud App Management server preparation. Default values for most of the installation settings should be acceptable.

See [Installing IBM Cloud App Management on Red Hat Openshift](https://ibm.biz/app-mgmt-ocp-standalone) and [Installing IBM Cloud App Management on IBM Cloud Private](https://ibm.biz/app-mgmt-icp-standalone) for more detailed instructions.

The following values are required:
- The location of the Cloud App Management Passport Advantage Archive (PPA) installation image file. (Example: install_dir/app_mgmt_server_0000.0.0.tar.gz)
- The location of the Helm chart file. (Example install_dir/ibm-cloud-appmgmt-prod/ibm-cloud-appmgmt-prod-0.0.0.tgz)
- The Cassandra username value for `--cassandraUsername`. The value may only include alphanumeric characters, and should not be `cassandra`.
  - You will be prompted for a Cassandra password.
  - The characters you provide for the password will NOT be displayed on the terminal as you type them.
  - Default username and password of `cassandra/cassandra` will be used if the option is omitted. This is insecure and is NOT recommended.

Execute the `pre-install.sh` and follow the prompts to select the defaults or provide the desired configuration.


### Install via Management Console

##### Persistent Storage
A cluster administrator must provide certain Persistent Storage to be used. See the Storage section of the README for more details.

Additionally, IBM® Cloud App Management includes a `prepare-pv.sh` script in its chart. This script may be used by an admin to help prepare vSphere Storage or local-storage persistent storage for use by this chart. See the below instructions for using this option.
  - Obtain the IBM® Cloud App Management PPA
  - Extract the helm chart directory from the ppa:
    - Example: `cd install_dir && tar -xzf app_mgmt_server_0000.0.0.tar.gz charts`
  - Expand the files from our helm chart:
    - Example: `cd charts && tar -xzf ibm-cloud-appmgmt-prod-0.0.0.tgz`
    - `tar -xzf ibm-cloud-appmgmt-prod-0.0.0.tgz`
  - Use the `prepare-pv.sh` script to reate the persistent volume and storage class resource files :
    - Locate the script in the expanded helm chart directory at:`ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/prepare-pv.sh`
    - Execute the script without any arguments to see the usage instructions: `./ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/prepare-pv.sh`
    - Identify the appropriate argument values and execute the script with the argument set
      - Example: `./ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/prepare-pv.sh --size1_amd64 --releasename ibmcloudappmgmt --cassandraNode 10.10.10.1 --zookeeperNode 10.10.10.2 --kafkaNode 10.10.10.3 --couchdbNode 10.10.10.4 --datalayerNode 10.10.10.5 --local`.
  - Create the persistent volumes and storage classes from the resource files:
    - Example: `kubectl create -f ibm-cloud-appmgmt-prod/ibm_cloud_pak/yaml/`

##### TLS Ingress Secrets
The server needs to be provided with TLS certificates in the form of Kubernetes secrets for validating external traffic.
The IBM® Cloud App Management chart includes a script which can be used to generate self-signed certificates as Kubernetes secrets using OpenSSL.

To create TLS certificate secrets using this provided script, follow these instructions:
- Obtain the IBM® Cloud App Management PPA
- Extract the helm chart directory from the ppa:
  - Example: `cd install_dir && tar -xzf app_mgmt_server_0000.0.0.tar.gz charts`
- Expand the files from our helm chart:
  - Example: `cd charts && tar -xzf ibm-cloud-appmgmt-prod-0.0.0.tgz`
  - `tar -xzf ibm-cloud-appmgmt-prod-0.0.0.tgz`
- Execute the script without arguments to see the usage information:
  - Example: `./ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/lib/make-ca-cert-icam.sh`
- Determine the appropriate values and execute the script using these values:
  - Example: `./ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/lib/make-ca-cert-icam.sh proxyFQDN icamReleaseName icamNamespace`

##### Load PPA Archive
The IBM® Cloud App Management PPA must be loaded into the private registry to be installed through the Management Console.
**NOTE:** The PPA must be loaded into the appropriate namespace scope.
  - Login to to the server with cloudctl; for example: `cloudctl login -a https://mycluster.icp:8443 --skip-ssl-validation` and select the correct namespace.
  - Login to the private docker registry; for example: `docker login mycluster.icp:8500`
  - Load the IBM® Cloud App Management PPA into the private registry, for example: `cloudctl catalog load-archive --archive install_dir/app_mgmt_server_0000.0.0.tar.gz`

#### Install
Navigate to the Platform Management Console in a browser, open the Catalog, and click on the `ibm-cloud-appmgmt-prod` helm chart tile. This will bring you to the overview page for the chart.
**NOTE:** If the Load PPA Archive step has been completed and `ibm-cloud-appmgmt-prod` chart is not visible, you may need to sync the repositories.
  - Navigate to Menu -> Manage -> Helm Repositories and click `Sync Repositories`

Select the `Configuration` tab to begin the installation configuration.
  - Enter the primary release configuration (name, namespace, license accept, etc.)
  - Under Parameters, open the `All parameters` tab to ensure correct configuration.
    - **NOTE:** Verify the TLS Secret values are set to the appropriate secret names from the pre-install.
    - **NOTE:** Verify the Persistent storage values under `All parameter - Global configuration` are aligned with the Persistent Volume setup from the pre-install.
  - Install the release

## Verifying the Chart From the Command Line
The installation of IBM® Cloud App Management may take a while, and will be influenced by the network and system speed. It may take 15-30+ minutes to become ready.

- Verify the state of the release is *DEPLOYED*: run the following helm command: `helm list <release-name> --tls`
- Verfiy that all pods for the release are in a running state: `kubectl get pods --namespace <release-namespace> --selector release=<release-name>`
- To verify the installation after all pods are in the ready or completed state, run the following helm command: `helm test <release-name> --tls --cleanup`
- If there is no release matching the install, investigate the `tiller` pod logs in the `kube-system` namespace and look for the release and chart names. There should be an indication of why the release may have failed.

## Post installation
**NOTE:** The following instructions are for IBM® Cloud Application Management Base and Advanced. For use with Cloud Pak for Multicloud Management and IBM Multicloud Manager see [IBM Cloud Application Management for IBM Multicloud Manager](http://ibm.biz/icam-mcm).

All pods for the release must be ready or completed to proceed.

### OIDC registration and ServiceInstance creation
- A cluster administrator must run the `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/post-install-setup.sh` script in order to register the OIDC client and create a ServiceInstance to access the server.

### Additional ServiceInstance creation
- Locate the `ibm-cloud-appmgmt` *service* tile in the Catalog of the platform's Management Console (**NOTE:** This is not the *chart* tile `ibm-cloud-appmgmt-prod`)
- Select an appropriate plan (Base/Advanced) and click `Configure`
- Enter the required parameters and click `Install`.

## Accessing the server dashboard
**NOTE:** The following instructions are for IBM® Cloud Application Management Base and Advanced. For use with Cloud Pak for Multicloud Management and IBM Multicloud Manager see [IBM Cloud Application Management for IBM Multicloud Manager](http://ibm.biz/icam-mcm).

- Navigate to the Dashboard URL provided by the Service Instance created during the post-install stage. This will open the ICAM Dashboard for monitoring.
  - **NOTE:** To identify the Dashboard URL, use `kubectl` to describe the Service Instance. The output will contain the Dashboard URL property under `Status`.

## Uninstalling the Chart
**NOTE:** The following instructions are for IBM® Cloud Application Management Base and Advanced. For use with Cloud Pak for Multicloud Management and IBM Multicloud Manager see [IBM Cloud Application Management for IBM Multicloud Manager](http://ibm.biz/icam-mcm).

**NOTE:** Prior to deleting the IBM® Cloud App Management installation, you must delete the Service Instance(s) associated with it. Failing to do so may leave the Service Instance objects in a state where they are not easily deleted.

After all Service Instances have been cleaned up:
- Delete the IBM® Cloud App Management release using `helm delete $RELEASE_NAME --purge --tls`
- Delete the resources not managed by the helm release, but related to the ICAM release (**NOTE:** use label selectors on the release name to identify resources).
  - Type shortnames may include: SCC, PVC, PV, SC, secret, configmap, serviceinstance, clusterservicebroker, etc.

## Backup and Restore
### CouchDB backup and restore
An admin may use the `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/backupcouch.sh` and `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/restorecouch.sh` scripts to backup and restore the CouchDB data used in IBM® Cloud App Management. These should be run from a command-line shell on the master node. The CouchDB service must be restarted after restoring data for the changes to take effect.

1. Create a backup of the CouchDB service data in the specified output directory. If not specified, the output directory is /tmp.
    ```bash
    $ backupcouch.sh -r <release name> {-n <namespace>} {-o <output directory>}
    ```
2. Restore a backup of the CouchDB service data. Optionally, restart CouchDB with -s.
    ```bash
    $ restorecouch.sh -r <release name> -f <backup file> [-n <namespace>] [-s <y or n>]
    ```
### Elasticsearch restore
If data in Elasticsearch is out of sync with data in the Cassandra database, resynchronize it by calling the rebroadcast API of the topology service. This triggers the rebroadcast of all known resources on Kafka, and the Search service will then index those resources in Elasticsearch.

Run https://master_fqdn/1.0/topology/swagger#!/Crawlers/rebroadcastTopology

## Chart Details

This chart deploys an IBM® Cloud App Management server.

### Chart Resources:

#### Cluster Service Broker resources:
- ibm-cem-cemcsb

#### ConfigMap Resources:
- global-config               
- cassandra-bootstrap-config  
- couchdb-configmap
- global-config
- ibm-cem-cem-users           
- kafka                       
- zookeeper
- ui-api

#### Deployment Resources:
- agentbootstrap                   
- agentmgmt                        
- alarmeventsrc                    
- amui                             
- applicationmgmt
- applicationmgmt-mcm-hub-monitor
- applicationmgmt-mcm-event-forwarder                       
- event-observer                   
- eventevaluator-metric
- ibm-cem-brokers                  
- ibm-cem-cem-users                
- ibm-cem-channelservices          
- ibm-cem-event-analytics-ui       
- ibm-cem-eventpreprocessor        
- ibm-cem-incidentprocessor        
- ibm-cem-integration-controller   
- ibm-cem-normalizer               
- ibm-cem-notificationprocessor    
- ibm-cem-rba-as                   
- ibm-cem-rba-rbs                  
- ibm-cem-scheduling-ui   
- layout
- linking         
- metric
- metricenrichment
- metricprovider
- metricstorage
- metricsummarycreation
- metricsummarypolicy
- metricsummarystorage
- opentt-collector
- opent-query
- redis-sentinel
- redis-server
- search
- synthetic
- streamingservice
- temacomm                         
- temaconfig                       
- temasda                          
- threshold                        
- topology     
- ui-api                    

#### Horizontal Pod Autoscale Resources:
- agentbootstrap
- agentmgmt
- alarmeventsrc  
- amui           
- applicationmgmt
- event-evaluator-metric
- event-observer
- ibm-cem-rba-as                  
- ibm-cem-brokers                 
- ibm-cem-cem-users               
- ibm-cem-channelservices         
- ibm-cem-event-analytics-ui      
- ibm-cem-eventpreprocessor       
- ibm-cem-incidentprocessor       
- ibm-cem-integration-controller  
- ibm-cem-normalizer              
- ibm-cem-notificationprocessor   
- ibm-cem-rba-rbs                 
- ibm-cem-scheduling-ui  
- layout
- linking  
- metric
- metricenrichment
- metricprovider
- metricstorage
- metricsummarystorage
- opentt-collector
- opentt-query
- search
- streamingservice
- synthetic
- temacomm       
- temaconfig                     
- temasda
- threshold    
- ui-api

#### Ingress Resources:
- agentbootstrap
- agentmgmt      
- amui           
- amuirest       
- applicationmgmt
- cem-api        
- cem-ingress    
- metric
- opentt
- streamingservice
- synthetic
- temacomm       
- temaconfig     
- temasda        

#### PodDisruptionBudget Resources:
- agent-bootstrap-pdb
- agentmgmt-pdb
- alarmeventsrc-pdb
- amui-pdb
- applicationmgmt-pdb
- cassandra-pdb
- elasticsearch-pdb
- event-observer-pdb
- eventevaluator-aggregate-pdb
- eventevaluator-metric-pdb
- kafka-pdb
- layout-pdb
- linking-pdb
- metric-pdb
- metricenrichment-pdb
- metricsummarystorage-pdb
- metricstorage-pdb
- metricprovider-pdb
- opentt-collector-pdb
- opentt-query-pdb
- search-pdb
- streamingservice
- synthetic-pdb
- temacomm-pdb
- temaconfig-pdb
- temasda-pdb
- threshold-pdb
- topology-pdb
- zookeeper-pdb

#### Role Resources:
- get-endpoints     
- get-update-configmaps
- ibm-cem-cem-users
- redis
- secret-generator-role
- get-endpoints
- ibm-redis

#### RoleBinding Resources:
- get-endpoints   
- get-update-configmaps
- ibm-cem-cem-users
- ibm-redis
- secret-generator-rolebinding

#### Secret Resources:
- admintenants
- cassandra-auth-secret                   
- cem-auth-cred-secret                    
- cem-brokers-cred-secret                 
- cem-cemusers-cred-secret                
- cem-channelservices-cred-secret         
- cem-couchdb-cred-secret                 
- cem-download-secret                     
- cem-email-cred-secret                   
- cem-event-analytics-ui-session-secret   
- cem-intctl-hmac-secret                  
- cem-integrationcontroller-cred-secret   
- cem-model-secret                        
- cem-nexmo-cred-secret
- custom-secrets
- rba-devops-secret                       
- rba-jwt-secret                          

#### Service Resources:
- agentbootstrap                   
- agentmgmt                        
- alarmeventsrc                    
- amui                             
- applicationmgmt
- cassandra                          
- couchdb                          
- elasticsearch
- event-observer                   
- ibm-cem-brokers                  
- ibm-cem-cem-users                
- ibm-cem-channelservices          
- ibm-cem-datalayer                
- ibm-cem-event-analytics-ui       
- ibm-cem-eventpreprocessor        
- ibm-cem-incidentprocessor        
- ibm-cem-integration-controller   
- ibm-cem-normalizer               
- ibm-cem-notificationprocessor    
- ibm-cem-rba-as                   
- ibm-cem-rba-rbs                  
- ibm-cem-scheduling-ui
- ibm-redis-master-svc                 
- ibm-redis-sentinel                   
- ibm-redis-slave-svc
- kafka  
- layout
- linking                          
- metric
- metricenrichment
- metricprovider
- metricsummarypolicy
- opentt-collector
- opentt-query
- opentt-svc
- secret-manager
- search
- synthetic
- streamingservice
- temacomm                         
- temaconfig                       
- temasda                          
- threshold                        
- topology         
- ui-api                        
- zkensemble                       
- zookeeper                        

#### ServiceAccount Resources
- ibm-cem-cem-users
- ibm-redis

#### StatefulSet Resources
- cassandra           
- couchdb
- elasticsearch
- ibm-cem-datalayer
- ibm-redis-sentinel
- ibm-redis-server
- kafka               
- zookeeper           

#### CronJob Resources
- ibm-cem-datalayer-cron
- opentt-analyzer
- opentt-dependency
