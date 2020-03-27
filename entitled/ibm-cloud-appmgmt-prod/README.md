# Performance Monitoring module for IBM® Cloud Pak for Multicloud Management

## Introduction

The Performance Monitoring module for IBM® Cloud Pak for Multicloud Management offers a comprehensive infrastructure monitoring solution. It's a cloud-native platform built on modern technology and microservices architecture. If you're already using IBM® Cloud APM, IBM® Tivoli Monitoring, or IBM® Tivoli Composite Application Manager, this Performance Monitoring module guides you forward.

With the Performance Monitoring module you can:
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

> **Note**: These requirements are for the Performance Monitoring module only and do not include any other workloads or the platform requirements.

The resource requirements differ depending on which size you use. To determine which size to use, please refer to detailed information found at [Planning hardware and sizing](https://www.ibm.com/support/knowledgecenter/SSFC4F_1.3.0/icam/planning_scaling.html).

## Limitations
- amd64 is the only fully supported architecture
- ppc64le is a supported architecture when running with Cloud Pak for Multicloud Management on Red Hat OpenShift 3.11

## Prerequisites

  - IBM® Cloud Pak for Multicloud Management 1.3
  - Kubernetes >=1.11.0
  - Tiller >=2.10.0

#### Red Hat OpenShift
  - Red Hat OpenShift Container Platform 3.11, 4.2 and 4.3

#### Secrets Requirements

TLS secrets are required to authenticate communication between the server and its clients.
- TLS Secret (e.g. `icam-ingress-tls`)
- Client Secret (e.g. `icam-ingress-client`)
- Artifacts (e.g. `icam-ingress-artifacts`)

In order to create a self-signed certificate to validate the communication, one of the following may be done:
1) During installation, set the `createTLSCerts` key to `true` (default). When true, a Kubernetes job will run prior to the server installation which will create the self-signed certificate and required secrets.

or

2) Prior to install, an admin may create the certificate and secrets using the `make-ca-cert-icam.sh` script included in the `ibm-cloud-appmgmt-prod` chart. This script is located in the `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/lib` directory.


#### Elasticsearch vm.max_map_count requirements
For Red Hat OpenShift 4.2 and 4.3, the tuned operator will be used by default to enable Elasticsearch kernel requirements.

For Red Hat OpenShift 3.11, or clusters without the tuned operator, a cluster administrator must satisfy these requirements.

Elasticsearch requires you to set a kernel parameter to run normally. This needs to be done on all worker nodes where the Elasticsearch pod may be scheduled. Persistent storage configuration for Elasticsearch may limit where the pods are able to be scheduled. You need to set the `vm.max_map_count` to a value of at least `1048575`.

For each applicable node, set the parameter with sysctl to ensure that the change takes effect immediately:

`sysctl -w vm.max_map_count=1048575`

For each applicable node, save the parameter in /etc/sysctl.conf to ensure that the change is still in effect after a node restart:

`vm.max_map_count=1048575`

### Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation.

When installing the Performance Monitoring module with IBM® Cloud Pak for Multicloud Management, these requirements are already satisfied.

The predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart.

### Internal (In Cluster) Network Encryption - Recommended
Use IPSec between the nodes in your cluster to ensure all internal connections are encrypted.
More details can be found at [Encrypting cluster data network traffic with IPsec](http://ibm.biz/icp-ipsec_mesh)

## Storage
The Performance Monitoring module requires persistent storage. For more information, see [Planning hardware and sizing](https://www.ibm.com/support/knowledgecenter/SSFC4F_1.3.0/icam/planning_scaling.html).

The recommended storage technologies are Local and vSphere. Block storage on bare metal may be applicable for certain use cases.

Persistent storage is required for each of the following stateful services: Cassandra, Kafka, ZooKeeper, CouchDB, and Datalayer, and Elasticsearch.


### Secure Encryption of Persistent Storage
Encryption of persistent storage can be achieved through encryption of the host file system upon which the persistent     volumes are created. For instructions on how to set up encryption using LUKS, refer to [these instructions](https://www.ibm.com/support/knowledgecenter/en/SS6PEW_10.0.0/com.ibm.help.security.dimeanddare.doc/security/t_security_settingupluksencryption.html).

## Configuration
More details can be found at
- [Installing and configuring the Performance Monitoring module](https://www.ibm.com/support/knowledgecenter/SSFC4F_1.3.0/install/install_pm.html)


## Installing the Chart

### Upgrade from 2019.4.0

- For detailed instructions on upgrading from 2019.4.0, 2019.4.0.1, and 2019.4.0.2 follow the instructions at [Upgrading Performance Monitoring](https://www.ibm.com/support/knowledgecenter/SSFC4F_1.3.0/icam/upgrade_server.html)

### Install via Management Console

##### Persistent Storage
A cluster administrator must provide certain Persistent Storage to be used. See the Storage section of the README for more details.

##### TLS Ingress Secrets
The Performance Monitoring module needs to be provided with TLS certificates in the form of Kubernetes secrets for validating external traffic over its exposed routes.

By default, self-signed secrets will be generated during the installation of the chart.

For information on how to use your own certificates, see [Configuring certificates for HTTPS communications](https://www.ibm.com/support/knowledgecenter/SSFC4F_1.3.0/icam/install_certs.html)

#### Install

Select the `Configuration` tab to begin the installation configuration.
  - Enter the primary release configuration (name, namespace, license accept, etc.)
  - Under Parameters, open the `All parameters` tab to ensure correct configuration.
    - **Note:** Verify the Persistent storage values are aligned with the local storage Persistent Volume setup, or use the appropriate storage classes for dynamic provisioning.
    - **Note:** Verify the ingress configuration parameters are correct.
  - Install the release

## Verifying the Chart From the Command Line
The installation of the Performance Monitoring module may take a while, and will be influenced by the network and system speed. It may take 15-30+ minutes to become ready.

- Verify the state of the release is *DEPLOYED*: run the following helm command: `helm list <release-name> --tls`
- Verify that all pods for the release are in a running or completed state: `kubectl get pods --namespace <release-namespace> --selector release=<release-name>`
- To verify the installation after all pods are in the ready or completed state, run the following helm command: `helm test <release-name> --tls --cleanup`
- If there is no release matching the install, investigate the `tiller` pod logs in the `kube-system` namespace and look for the release and chart names. There should be an indication of why the release may have failed.

## Post installation
When the release is deployed and all pods are in the running or completed state, two tasks must be performed:
 1. OIDC registration
 2. Service Policy registration

The helm release status includes instructions for executing these post-installation tasks.

## Uninstalling the Chart
**Note:** It is recommended to uninstall the Performance Monitoring module using the CLI instead of the Catalog. For more information see [Uninstalling the Performance Monitoring module](https://www.ibm.com/support/knowledgecenter/SSFC4F_1.3.0/icam/uninstall_mcm_icam_intro.html)

- Delete the Performance Monitoring module release using `helm delete $RELEASE_NAME --purge --tls`
- Delete the resources not managed by the helm release, but related to the Performance Monitoring module's release
  - Instructions for cleaning up these resources is provided at [Uninstalling the Performance Monitoring module](https://www.ibm.com/support/knowledgecenter/SSFC4F_1.3.0/icam/uninstall_mcm_icam_intro.html)

## Backup and Restore
### CouchDB backup and restore
An admin may use the `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/backupcouch.sh` and `ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/restorecouch.sh` scripts to backup and restore the CouchDB data used in the Performance Monitoring module. These should be run from a command-line shell where kubectl is configured with the cluster. The CouchDB service must be restarted after restoring data for the changes to take effect.

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

This chart deploys the Performance Monitoring module for IBM® Cloud Pak for Multicloud Management.

### Chart Resources
**Note:** These resources will include the helm release name in their name.

#### ClusterRole Resources
- ibm-cem-cem-users

#### ClusterRoleBinding Resources
- ibm-cem-cem-users

#### ConfigMap Resources
- cassandra-bootstrap-config  
- couchdb-configmap
- global-config
- ibm-cem-cem-users
- ibm-cloud-appmgmt-prod-cacerts
- kafka
- service-ca
- ui-api
- zookeeper

#### CronJob Resources
- applicationmgmt-auth-cj
- ibm-cem-datalayer-cron
- ibm-cloud-appmgmt-prod-autoconfig

#### CustomResourceDefinition Resources
- alerttargets.alerttargetcontroller.omaas.ibm.com

#### Deployment Resources
- agentbootstrap                   
- agentmgmt                        
- alarmeventsrc                    
- amui                             
- applicationmgmt-consumer
- applicationmgmt-legacy
- applicationmgmt-mcm-monitor
- applicationmgmt-rest
- baselineconfiguration
- event-observer                   
- eventevaluator-metric
- geolocation
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
- ibm-hdm-analytics-dev-inferenceservice
- ibm-hdm-analytics-dev-policyregistryservice
- ibm-hdm-analytics-dev-trainer
- layout
- linking         
- metric
- metricenrichment
- metricprovider
- metricstorage
- metricsummarycreation
- metricsummarypolicy
- metricsummarystorage
- opentt-analyzer
- opentt-collector
- opentt-ingester
- opentt-query
- search
- spark-master
- spark-slave
- synthetic-playback-http
- synthetic-playback-javascript
- synthetic-playback-selenium
- synthetic-pop-agent
- synthetic-service
- temacomm                         
- temaconfig                       
- temasda                          
- threshold                        
- topology     
- ui-api                    

#### Horizontal Pod Autoscale Resources
- agentbootstrap
- agentmgmt
- alarmeventsrc  
- amui           
- applicationmgmt-consumer
- applicationmgmt-legacy
- applicationmgmt-rest
- baselineconfiguration
- event-observer
- eventevaluator-metric
- geolocation
- ibm-cem-brokers                 
- ibm-cem-cem-users               
- ibm-cem-channelservices              
- ibm-cem-eventpreprocessor       
- ibm-cem-incidentprocessor       
- ibm-cem-integration-controller  
- ibm-cem-normalizer              
- ibm-cem-notificationprocessor   
- ibm-cem-rba-as
- ibm-cem-rba-rbs                 
- ibm-cem-scheduling-ui  
- ibm-hdm-analytics-dev-inferenceservice
- ibm-hdm-analytics-dev-policyregistryservice
- layout
- linking  
- metric
- metricenrichment
- metricprovider
- metricstorage
- metricsummarystorage
- opentt-analyzer
- opentt-collector
- opentt-ingester
- opentt-query
- search
- synthetic-playback-http
- synthetic-playback-javascript
- synthetic-playback-selenium
- synthetic-pop-agent
- synthetic-service
- temacomm       
- temaconfig                     
- temasda
- threshold
- topology   
- ui-api

#### Ingress Resources
- agentbootstrap
- agentmgmt      
- amui           
- amuirest       
- applicationmgmt
- cem-api        
- cem-ingress   
- ibm-hdm-analytics-dev-backend-ingress
- metric
- opentt
- synthetic-service
- temacomm       
- temaconfig     
- temasda  

#### Job Resources
- ibm-hdm-analytics-dev-setup      

#### NetworkPolicy Resources
- couchdb-network-policy
- ibm-cem-cem-brokers-network-policy
- ibm-cem-cem-network-policy

#### PersistentVolumeClaim Resources
**Note:** One persistent volume claim per statefulset replica, where `n` is the ordinal index
- data-icam-cassandra-n
- data-icam-couchdb-n
- data-icam-elasticsearch-n
- data-icam-kafka-n
- data-icam-zookeeper-n
- jobs-icam-ibm-cem-datalayer-n

#### PodDisruptionBudget Resources
- agentbootstrap-pdb
- agentmgmt-pdb
- alarmeventsrc-pdb
- amui-pdb
- applicationmgmt-pdb
- baselineconfiguration-pdb
- cassandra-pdb
- eventevaluator-metric-pdb
- geolocation-pdb
- kafka-pdb
- linking-pdb
- metric-pdb
- metricenrichment-pdb
- metricprovider-pdb
- metricstorage-pdb
- metricsummarystorage-pdb
- opentt-analyzer-pdb
- opentt-collector-pdb
- opentt-ingester-pdb
- opentt-query-pdb
- synthetic-service-pdb
- temacomm-pdb
- temaconfig-pdb
- temasda-pdb
- threshold-pdb
- zookeeper-pdb

#### Role Resources
- get-endpoints     
- get-update-configmaps
- ibm-cem-cem-users
- ibm-cloud-appmgmt-prod-cacerts
- ibm-redis
- opentt
- secret-generator-role

#### RoleBinding Resources
- get-endpoints   
- get-update-configmaps
- ibm-cem-cem-users
- ibm-cloud-appmgmt-prod-cacerts
- ibm-cloud-appmgmt-prod-view
- ibm-redis
- opentt
- secret-generator-rolebinding

#### Secret Resources
- admintenants
- asm-credentials
- ca-secret
- cassandra-auth-secret                                     
- cem-brokers-cred-secret                 
- cem-cemusers-cred-secret                
- cem-channelservices-cred-secret         
- cem-couchdb-cred-secret                 
- cem-download-secret                     
- cem-email-auth-secret                   
- cem-event-analytics-ui-session-secret   
- cem-ibm-redis-cred-secret
- cem-intctl-hmac-secret                  
- cem-integrationcontroller-cred-secret   
- cem-model-secret                        
- cem-nexmo-cred-secret
- cem-service-secret
- custom-secrets
- ingress-artifacts
- ingress-client
- ingress-tls
- rba-devops-secret                       
- rba-jwt-secret     
- kafka-client-secret                     

#### Service Resources
- agentbootstrap                   
- agentmgmt                        
- alarmeventsrc                    
- amui                             
- applicationmgmt
- applicationmgmt-legacy
- baselineconfiguration
- cassandra                          
- couchdb                          
- elasticsearch
- event-observer
- geolocation                   
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
- ibm-hdm-analytics-dev-inferenceservice
- ibm-hdm-analytics-dev-policyregistryservice
- ibm-hdm-analytics-dev-trainer
- ibm-redis-master-svc                 
- ibm-redis-sentinel-svc                   
- ibm-redis-slave-svc
- kafka  
- layout
- linking                          
- metric
- metricenrichment
- metricprovider
- metricsummarypolicy
- opentt-collector
- opentt-ingester
- opentt-query
- opentt-svc
- search
- spark-master
- spark-slave
- synthetic
- synthetic-playback-javascript
- synthetic-playback-selenium
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
- ibm-cloud-appmgmt-prod-cacerts
- ibm-redis
- opentt

#### StatefulSet Resources
- cassandra           
- couchdb
- elasticsearch
- ibm-cem-datalayer
- ibm-redis-sentinel
- ibm-redis-server
- kafka               
- zookeeper           
