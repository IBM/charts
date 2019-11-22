# IBM® Business Automation Content Analyzer Chart

## Introduction

This readme provide instruction to deploy IBM Business Automation Content Analyzer with IBM® Cloud Pak for Automation platform. IBM Business Automation Content Analyzer offers the power of intelligent capture with the flexibility of an API that enables you to extend the value of your core enterprise content management (ECM) technology stack and helps you rapidly accelerate extraction and classification of data in your documents. 


## Chart Details

This chart consists of IBM® Business Automation Content Analyzer. IBM® Business Automation Content Analyzer helps users rapidly accelerate extraction and classification of data in documents.

```
── ibm-dba-baca-prod
   ├── Chart.yaml
   ├── LICENSE
   ├── README.md
   ├── charts
   │   ├── rabbitmq-ha
   │   ├── redis-ha
   │   ├── mongo-ha
   │   ├── mongoadmin-ha
   ├── templates
   │   ├── NOTES.txt
   │   ├── deploy-callerapi.yaml
   │   ├── deploy-spfrontend.yaml
   │   ├── deploy-spfrontend.yaml
   │   ├── deploy-spbackend.yaml
   │   ├── deploy-workers.yaml
   │   ├── spbackend-ingress.yaml
   │   ├── svc-callerapi.yaml
   │   ├── svc-frontend.yaml
   │   ├── svc-spbackend.yaml
   ├── requirements.yaml
   ├── values.yaml
```

## Prerequisites
- IBM® Cloud Private 3.1.2 with a minimum of 3 worker nodes for Development environment.  Each worker nodes should have at least 8 CPUs, 16GB of RAM.
- NFS Server (Minimum required : 290 GB)
  - If you would like to increase the size of persistent volume except MongoDB, you may modify [sppersistent.yaml](https://github.com/icp4a/cert-kubernetes/blob/19.0.2/BACA/configuration-ha/sppersistent.yaml) after you download this file from Step 3 below. 
  - For MongoDB, you may modify values-base.yaml under configuration-ha/mongo and configuration-ha/mongoadmin from https://github.com/icp4a/cert-kubernetes/tree/19.0.2/BACA/configuration-ha  that you will perform in Step 3 below. 
- IBM DB2 version 11.1.1.1 with Redhat 7.3.x or Ubuntu 16.4
- Microsoft Active Directory or IBM Security Directory Server (formerly known as IBM Tivoli Directory Server)
   - An initial user is created in IBM Business Automation Content Analyzer when first creating the Tenant database in Step 2 below. The user name must match the LDAP user name when specified.

## Prepare environment

### Step 1 - Create Content Analyzer Base DB
1. Copy the DB2 folder from https://github.com/icp4a/cert-kubernetes/tree/19.0.2/BACA/configuration-ha/DB2  to your IBM DB2 server
2. cd to DB2 folder and run ./CreateBaseDB.sh script. (Ex. Please run with db2inst1 which has 'sudo' privileges)
3. As prompted, enter the following data:
  - Enter the name of the IBM® Business Automation Content Analyzer Base database – (enter a unique name of 8 characters or less and no special characters).
  - Enter the name of database user – (enter a database user name that has full permissions to the base database). This can be a new or an existing Db2 user.
  - Enter the password for the user – (enter a password) – each time when prompted. If this is an existing user, this prompt is skipped

### Step 2 - Create the Content Analyzer Tenant database
1. Still in the DB2 folder, Run ./AddTenant.sh script on the Db2 server.
For more information, see Creating Content Analyzer Tenant database.
2. As prompted, enter the following parameters:
  - Enter the tenant ID – (an alphanumeric value that is used by the user to reference the database)
  - Enter the name of the IBM® Business Automation Content Analyzer tenant database - (an alphanumeric value for the actual database name in Db2)
  - Enter the host/IP of the database server – (the IP address of the database server)
  - Enter the port of the database server – Press Enter to accept default of 50000 (or enter the port number if a different port is needed)
  - Do you want this script to create a database user – y (for yes)
  - Enter the name of database user – (this is the tenant database user - enter an alphanumeric user name with no special characters)
  - Enter the password for the user – (enter an alphanumeric password each time when prompted)
  - Enter the tenant ontology name – Press Enter to accept default (or enter a name to reference the ontology by if desired)
  - Enter the name of the Base Business Automation Content Analyzer database – (enter the database name given when you create the base database)
  - Enter the name of the database user for the Base Business Automation Content Analyzer database – (enter the base user name given when you create the base database)
  - Enter the company name – (enter your company name. This parameter and the remaining values are used to set up the initial user in Business Automation Content Analyzer)
  - Enter the first name - (enter your first name)
  - Enter the last name - (enter your last name)
  - Enter a valid email address - (enter your email address)
  - Enter the login name – (if you use LDAP authentication, enter your user name as it appears in the LDAP server)
  - Would you like to continue – y (for yes)
  - Save the tenantID and Ontology name for the later steps.

### Step 3 - download the configuration files
1. Download all the files and folders except DB2 folder from https://github.com/icp4a/cert-kubernetes/tree/19.0.2/BACA/configuration-ha to where you plan to install Content Analyzer. For example, to a system that can be connected to IBM Cloud Private.

### Step 4 - Edit common.sh
1. Edit and populate the /configuration-ha/common.sh that was downloaded from step 3 with the correct values from the [Prerequisite install parameters table](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_baca_common_params.html).

TODO: Need 19.0.2 KC link that has the 2 new param introduced in Q3

### Step 5 - Creates prerequisite resources for IBM Business Automation Content Analyzer
1. Run ./init_deployment.sh from /configuration-ha that was downloaded from step 3.
  - Required persistent volumes and volume claims, secrets are created during the preparation of the environment

### Step 6 - Update values.yaml
1. Download the Helm Chart to the master node from https://github.com/icp4a/cert-kubernetes/blob/19.0.2/BACA/helm-charts/ibm-dba-baca-prod-1.2.0_ha.tgz 
2. Extract the helm chart from ibm-dba-prod-1.2.0_ha.tgz.
3. Proceed to ibm-dba-baca-prod/ibm_cloud_pak/pak_extensions directory and copy template.yaml to ibm-dba-baca-prod/values.yaml
4. Edit the values.yaml file and complete the values mentioned in the [Helm Chart configuration parameter section](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.ref/topics/ref_baca_globaloptions_params.html) for options with the parameters and values. Note that anything not documented does not need to be changed.

NOTE: If you have your own storage class for PVC, you need to fill out the `global -  storageClass` name for Mongo HA dynamic storage provisioning.

### Step 7 - Obtain memory setting values for the IBM Business Automation Content Analyzer containers
1. Run ./generateMemoryValues.sh from /configuration-ha folder that was downloaded in Step 3 with "limited" or "distributed". For more information, see [Limiting the amount of available memory](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_preparing_baca_deploy_limitram.html).
2. Copy the values generated from running ./generateMemoryValues.sh in the values.yaml file.


### Step 8 - Download IBM Cloud Pak for Automation V19.0.2 and load IBM Business Automation Content Analyzer base image
1. Please follow the instruction in https://www-01.ibm.com/support/docview.wss?uid=ibm10878709 to download CC3HYML package to a server that is connected to your Docker registry.
2. Download the [loadimages.sh](https://github.com/icp4a/cert-kubernetes/blob/19.0.2/scripts/loadimages.sh) script from GitHub.
3. Login to the specified Docker registry with the docker login command. This command depends on the environment that you have.
4. Run the loadimages.sh script to load the images into your Docker registry. Specify the two mandatory parameters in the command line.
   - Note: The docker-registry value depends on the platform that you are using
   
   ```
   -p  PPA archive files location or archive filename
   -r  Target Docker registry and namespace
   -l  Optional: Target a local registry
   ```
  The following example shows the input values in the command line.
   ```
  # scripts/loadimages.sh -p /Downloads/PPA/ImageArchive.tgz -r <DOCKER-REGISTRY>/demo-project
   ```

## Additional customization parameter for sub-charts

#### Redis 
- You can change the `replicas` value in the `values.yaml` under global->redis to the desired value.  The default is 3, which means you must have 3 worker nodes.  
- You can also adjust the `quorum` value.  For more information on `quorum` can be found [here](https://redis.io/topics/sentinel)


#### RabbitMQ

- The `rabbitmq-ha` helm chart is installed as a subchart when installing the `ibm-dba-baca-prod` helm chart. That helm chart deploys RabbitMQ in HA (high-availability) mode for BACA to use.

- No changes are needed to deploy this subchart with the default parameters.  With the default parameters, there will be 3 RabbitMQ pods (this means for each BACA task queue, there will be 1 master queue and 2 mirrors).  If you want to increase or decrease the number of RabbitMQ pods, change the `replicas` value in the `values.yaml` under global->rabbitmq to the desired value 

- FYI regarding users in RabbitMQ. There is a `guest` user seeded initially in RabbitMQ, but will be removed by the RabbitMQ startup script.  The startup script creates a new user with a randomly generated username and password saved in a Kubernetes secret.

#### Mongo DBs

- Make sure the `common.sh` from the `configuration-ha` folder has been filled out properly.
- By default we have 3 replicas for Router, Shard, and Config.  You can increase or decrease these values (`ROUTER_REPLICA`, `SHARD_REPLICA`,`CONFIG_REPLICA`) in the pre-setup.sh and post-setup.sh.  The recommendation is that the number of replicas must match the number of nodes that have been labeled as `mongo<ns>=baca` and `mongo-admin<ns>=baca`.
In a distributed production environment, we recommend reserving 3 dedicated worker nodes for Mongo DB. So the `common.sh` should look something like:
```
CA_WORKERS=192.168.1.103,192.168.1.104,192.168.1.105
MONGO_WORKERS=192.168.1.100,192.168.1.101,192.168.1.102
MONGO_ADMIN_WORKERS=192.168.1.100,192.168.1.101,192.168.1.102
```

## Installing the Chart
To deploy Content Analyzer:  

From the ibm-dba-baca-prod directory:  
   ```console
   $ helm install . --name celery<namespace> -f values.yaml  --namespace <namespace> --tls
   ```
   Note: 
   - Due to the configuration of the readiness probes, after the pods start, it may take up to 10 or more minutes before the pods enter a ready state. 

Run the command:
```console
$ kubectl -n <namespace> get pods
```
To see that status of the pods. Wait until all pods are Running and Ready.

## Completing post deployment configuration

### Mongo DBs

1) When you see all the `mongodb-shard<x>-<x>` and `mongodb-admin-shard<x>-<x>` pods are in Running/Ready status (eg: 1/1), you need to run the `configuration-ha/mongo/post-setup.sh` and `configuration-ha/mongoadmin/post-setup.sh` respectively.


- Optional : Only perform this step if you are running IBM Cloud Private without Ingress. See [Completing post deployment tasks for Business Automation Content Analyzer](https://github.com/icp4a/cert-kubernetes/blob/master/BACA/docs/post-deployment.md)

## Verifying the Chart
Run the command `kubectl -n <namespace> get pods` to check the status of the pods and ensure they are all in a Running state and Ready (1/1).  Then attempt to access the Web UI at `https://proxy-ip/frontend<namespace>/?tid=<tenantid>&ont=<ontology>` (e.g. `https://myserver/frontendsp/?tid=baca&ont=default`)

## Uninstalling the Chart

To uninstall/delete the `celery<namespace>` deployment (e.g. celerysp):

$ helm delete celerysp --purge --tls

The command removes all the Kubernetes components such as pods, deployments, statefulsets and services associated with the chart and deletes the release.  It will not delete pvs, pvcs or imagestreams.

- If you would like to completely remove the deployment, please run [delete_ContentAnalyzer.sh](https://github.com/icp4a/cert-kubernetes/blob/19.0.2/BACA/configuration-ha/delete_ContentAnalyzer.sh) 

## Upgrade
- In order to upgrade from BACA 19.0.1 to 19.0.2, the following procedure must be performed:
  - Back up your ontology via the export functionality from the GUI
  - Back up your database.
  - Run the [UpgradeBaseDB.sh](https://github.com/icp4a/cert-kubernetes/blob/19.0.2/BACA/configuration-ha/DB2/UpgradeBaseDB.sh) from your database server as `db2inst1` user.
  - Run the [UpgradeTenantDB.sh](https://github.com/icp4a/cert-kubernetes/blob/19.0.2/BACA/configuration-ha/DB2/UpgradeTenantDB.sh) from your database server as `db2inst1` user.
  - Delete the previous BACA 19.0.1 instance by running [delete_ContentAnalyzer.sh](https://github.com/icp4a/cert-kubernetes/blob/19.0.2/BACA/configuration-ha/delete_ContentAnalyzer.sh), and follow the above instruction to deploy BACA 19.0.2 from Step 3 above.



## Resources Required
- Recommended resource limits are provided by this script. [generateMemoryValues.sh](https://github.com/icp4a/cert-kubernetes/blob/19.0.2/BACA/configuration-ha/generateMemoryValues.sh)  downloaded from "Prepare Envrionment"'s Step 3. 


## Configuration

The following link describes the configurable parameters for the helm chart and their default values:

[Preparing the configuration values.yaml file](https://www.ibm.com/support/knowledgecenter/SSYHZ8_19.0.x/com.ibm.dba.install/topics/tsk_preparing_baca_deploy_yaml_update.html?view=kc)

## Limitations
- This chart is not available as a catalog item inside IBM® Cloud Private 3.1.2. 
- Only IBM® Cloud Private 3.1.2 is supported.
- Dynamic Provisioning is not supported except for Mongos storage.

## Documentation

- For general IBM Business Automation Content Analyzer usage information, please reference [IBM Business Automation Content Analyzer Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSUM7G/com.ibm.bacanalyzertoc.doc/bacanalyzer_1.0.html)
