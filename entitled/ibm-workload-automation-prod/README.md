# IBM Workload Automation containers - Helm Chart

This chart helps you deploy and configure IBM Workload Automation containers.

## Introduction

IBM Workload Automation containers are: IBM Workload Automation Agent, IBM Workload Automation Server, and IBM Workload Automation Console.
To deploy and configure IBM Workload Automation containers, see also [Installing IBM Workload Automation](https://www.ibm.com/support/knowledgecenter/en/SSGSPN_9.5.0/com.ibm.tivoli.itws.doc_9.5/distr/src_pi/awspipartdepcont.htm).
 

## Chart Details

The following is deployed as the standard configuration:

|                     | **Agent**               | **Console**                | **Server**               |
| -----------------   | ----------------------  | -------------------------- | ------------------------ |
| Headless Service    | release_name-waagent-h  | release_name-waconsole-h   | release_name-waserver-h  |
| Service             | release_name-waagent    | release_name-waconsole     | release_name-waserver    |
| StatefulSet         | release_name-waagent    | release_name-waconsole     | release_name-waserver    |
    

where `release_name` is the custom release name (for further details, see the Installing the Chart section).

The workload is composed of a StatefulSet including a single image container for the IBM Workload Automation containers.


## Prerequisites

*  Docker version 18.03.1 or later
*  Kubernetes 1.11.1 with Beta APIs enabled
*  IBM Workload Automation containers run on amd64 systems
*  If you want to deploy multiple instances of the Server, you must give additional authorities by creating Role and RoleBinding (for further details, refer to PodSecurityPolicy Requirements section)
*  If dynamic provisioning is not being used, a Persistent Volume must be created and setup with labels that can be used to refine the Kubernetes PVC bind process
*  If dynamic provisioning is being used, specify a storageClass per Persistent Volume provisioner to support dynamic volume provisioning
*  A default storageClass is setup during the cluster installation or created prior to the deployment by the Kubernetes administrator
*  To reach the Server and Console services from outside the cluster, you need to configure your DNS defining a virtual hostname that points to the cluster proxy for each service            
*  Create a DB instance and schema (Server and Console only)

   Use the following command to create a DB2 instance and schema for the IBM Workload Automation Console:   

       CREATE DATABASE DWC
       USING CODESET UTF-8 TERRITORY US
       COLLATE USING IDENTITY
       WITH 'DWC Database';

   Use the following command to create a DB2 instance and schema for the IBM Workload Automation Server:
   
       CREATE DATABASE TWS
       USING CODESET UTF-8 TERRITORY US
       COLLATE USING IDENTITY
       WITH 'TWS Database';
       
       UPDATE DB CFG FOR TWS USING LOGBUFSZ 512;
       UPDATE DB CFG FOR TWS USING LOGFILSIZ 1000;
       UPDATE DB CFG FOR TWS USING LOGPRIMARY 40;
       UPDATE DB CFG FOR TWS USING LOGSECOND 20;
       UPDATE DB CFG FOR TWS USING LOCKTIMEOUT 180;
       UPDATE DB CFG FOR TWS USING APP_CTL_HEAP_SZ 1024;
       UPDATE DB CFG FOR TWS USING DFT_QUERYOPT 3;
       UPDATE DB CFG FOR TWS USING AUTO_MAINT ON;
       UPDATE DB CFG FOR TWS USING AUTO_TBL_MAINT ON;
       UPDATE DB CFG FOR TWS USING AUTO_RUNSTATS ON;
       UPDATE DB CFG FOR TWS USING STMT_CONC LITERALS;
       UPDATE DB CFG FOR TWS USING CATALOGCACHE_SZ -1;
       UPDATE DB CFG FOR TWS USING PAGE_AGE_TRGT_MCR 120;
       UPDATE DB CFG FOR TWS USING LOCKLIST AUTOMATIC;       

*  Create a mysecret.yaml file to store passwords (Server and Console only; for further details, refer to Secrets section)  


## Resources Required

Requested amount of resources:

|                      | **Agent**     | **Console**  | **Server**   |
| -------------------- | ----------    | -----------  | -----------  |
| CPU                  | 200m          | 1            | 1            |
| Memory               | 200Mi         | 4Gi          | 4Gi          |
| Storage requirements | 2Gi           | 5Gi          | 10Gi         |

Resources limit:

|                      | **Agent**     | **Console**  | **Server**   |
| -------------------- | ----------    | -----------  | -----------  |
| CPU                  | 1             | 4            | 4            |
| Memory               | 2Gi           | 16Gi         | 16Gi         |


## PodSecurityPolicy Requirements

This chart requires a Pod Security Policy to be bound to the target namespace prior to the installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [ibm-restricted-psp](https://ibm.biz/cpkspec-psp) has been verified for this chart when deploying Agents, Consoles and a single instance of the Server (ReplicaCount=1). In these cases, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

If you want to deploy multiple instances of the Server, you must give additional authorities to this chart to read and write pod labels; thus you need to create additional role and rolebinding described below.

- From the user interface, you can copy and paste the following snippets to enable additional authorities needed to deploy multiple instances of the Server:			
			
  - Role: 
      
         kind: Role
         apiVersion: rbac.authorization.k8s.io/v1
         metadata:
           name: wa-pod-label
           namespace: <your_namespace>
         rules:
         - apiGroups: [""] # "" indicates the core API group
           resources: ["pods"]
           verbs: ["get", "list", "update", "patch"]
         - apiGroups: ["policy"]
           resources: ["podsecuritypolicies"]
           verbs: ["use"]   
        
  - RoleBinding:
      
         kind: RoleBinding
         apiVersion: rbac.authorization.k8s.io/v1
         metadata:
           name: wa-pod-label-rb
           namespace: <your_namespace>
         subjects:
         - kind: Group
           name: system:serviceaccounts:<your_namespace>
           apiGroup: rbac.authorization.k8s.io
         roleRef:
           kind: Role
           name: wa-pod-label
           apiGroup: rbac.authorization.k8s.io
	
- From the command line, you can run the setup scripts included under pak_extensions.

As a cluster admin the pre-install instructions are located at:

      ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

As team admin the namespace scoped instructions are located at:

      ibm_cloud_pak/pak_extensions/pre-install/namespaceAdministration/createRoleBindingPrereqs.sh	

Pod Security Policies can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the user interface or the supplied instructions/scripts in the ibm_cloud_pak/pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy:

  - Custom PodSecurityPolicy definition:
          
         apiVersion: extensions/v1beta1
         kind: PodSecurityPolicy
         metadata:
           annotations:
             kubernetes.io/description: "This policy is the most restrictive, 
               requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
             #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
             #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
             seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
             seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
           name: ibm-workload-automation-prod-psp
         spec:
           allowPrivilegeEscalation: false
           forbiddenSysctls:
           - '*'
           fsGroup:
             ranges:
             - max: 65535
               min: 1
             rule: MustRunAs
           requiredDropCapabilities:
           - ALL
           runAsUser:
             rule: MustRunAsNonRoot
           seLinux:
             rule: RunAsAny
           supplementalGroups:
             ranges:
             - max: 65535
               min: 1
             rule: MustRunAs
           volumes:
           - configMap
           - emptyDir
           - projected
           - secret
           - downwardAPI
           - persistentVolumeClaim
      
  - Custom ClusterRole for the custom PodSecurityPolicy:
      
         apiVersion: rbac.authorization.k8s.io/v1
         kind: ClusterRole
         metadata:
           name: ibm-workload-automation-prod-clusterrole
         rules:
         - apiGroups:
           - extensions
           resourceNames:
           - ibm-workload-automation-prod-psp
           resources:
           - podsecuritypolicies
           verbs:
           - use
			 
- From the command line, you can run the setup scripts included under pak_extensions.

As a cluster admin the pre-install instructions are located at:

     ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

As team admin the namespace scoped instructions are located at:

     ibm_cloud_pak/pak_extensions/pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

## Installing the Chart

To install the chart with the release name of your choice `release_name`, run:

  ```bash
  $ helm install --name release_name stable/ibm-workload-automation-prod --tls
  ```

The command deploys the `ibm-workload-automation-prod` chart on the Kubernetes cluster in the default configuration. The Configuration section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list` 


### Verifying the Chart

See NOTES.txt associated with this chart for verification instructions


## Upgrading the Chart

To upgrade the release `release_name` to a new version of the chart, run: 

  ```bash
  $ helm upgrade release_name stable/ibm-workload-automation-prod --tls
  ```

Before you perform the upgrade of a chart, if you have jobs that are currently running, the related processes must be stopped manually or you must wait until the jobs are complete.


### Uninstalling the Chart

To uninstall/delete the `ibm-workload-automation-prod` deployment, run:

  ```bash
  $ helm delete release_name --purge --tls
  ```

The command removes all the Kubernetes components associated with the chart and deletes the release.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes:

  ```bash
  $ kubectl delete pvc -l release=release_name
  ```

  
## Configuration

The following table lists the configurable parameters of the chart and an example of their values:


| **Parameter**                           | **Description**                                                                                                                                                                                                                                                              | **Mandatory**  | **Example**                      | **Default**                      |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------  | -------------------------------- | -------------------------------- |
| global.license                          | Use ACCEPT to agree to the license agreement                                                                                                                                                                                                                                 | yes            | not accepted                     | not accepted                     |
| global.enableServer                     | If enabled, the Server application is deployed                                                                                                                                                                                                                               | no             | true                             | true                             |
| global.enableConsole                    | If enabled, the Console application is deployed                                                                                                                                                                                                                              | no             | true                             | true                             |
| global.enableAgent                      | If enabled, the Agent application is deployed                                                                                                                                                                                                                                | no             | true                             | true                             |
| global.serviceAccountName               | The name of the serviceAccount to use                                                                                                                                                                                                                                        | no             | default                          | leave it empty                   |
| global.language                         | The language of the container internal system. The supported language are: en (English), de (German), es (Spanish), fr (French), it (Italian), ja (Japanese), ko (Korean), pt_BR (Portuguese (BR)), ru (Russian), zh_CN (Simplified Chinese) and zh_TW (Traditional Chinese) | yes            | en                               | en                               | 

- **Agent**

| **Parameter**                                    | **Description**                                                                                                                                                                                                                                                      | **Mandatory**  | **Example**                      | **Default**                      |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  | -------------  | -------------------------------- | -------------------------------- |
| waagent.fsGroupId                                | The secondary group ID of the user                                                                                                                                                                                                                                   | no             | 999                              |                                  |
| waagent.supplementalGroupId                      | Supplemental group id of the user                                                                                                                                                                                                                                    | no             |                                  |                                  |
| waagent.replicaCount                             | Number of replicas to deploy                                                                                                                                                                                                                                         | yes            | 1                                | 1                                |
| waagent.image.repository                         | IBM Workload Automation Agent image repository                                                                                                                                                                                                                                | yes            | ibm-workload-automation-agent-dynamic        | ibm-workload-automation-agent-dynamic        |
| waagent.image.tag                                | IBM Workload Automation Agent image tag                                                                                                                                                                                                                                       | yes            | 9.5.0.00                        | 9.5.0.00                        |
| waagent.image.pullPolicy                         | image pull policy                                                                                                                                                                                                                                                    | yes            | Always                           | Always                           |
| waagent.agent.name                               | Agent display name                                                                                                                                                                                                                                                   | yes            | WA_AGT                           | WA_AGT                           |
| waagent.agent.tz                                 | If used, it sets the TZ operating system environment variable                                                                                                                                                                                                        | no             | America/Chicago                  |                                  |
| waagent.agent.dynamic.server.mdmhostname         | Hostname or IP address of the master domain manager                                                                                                                                                                                                                  | yes            | wamdm.demo.com                   |                                  |
| waagent.agent.dynamic.server.port                | The HTTPS port that the dynamic agent must use to connect to the master domain manager                                                                                                                                                                               | no             | 31116                            | 31116                            |
| waagent.agent.dynamic.pools                      | The static pools of which the Agent should be a member                                                                                                                                                                                                               | no             | Pool1, Pool2                     |                                  |
| waagent.agent.dynamic.useCustomizedCert          | If true, customized SSL certificates are used to connect to the master domain manager                                                                                                                                                                                | no             | false                            | false                            |
| waagent.agent.dynamic.certSecretName             | The name of the secret to store customized SSL certificates                                                                                                                                                                                                          | no             | waagent-cert-secret              |                                  |
| waagent.agent.containerDebug                     | The container is executed in debug mode                                                                                                                                                                                                                              | no             | no                               | no                               |
| waagent.agent.livenessProbe.initialDelaySeconds  | The number of seconds after which the liveness probe starts checking if the server is running                                                                                                                                                                        | yes            | 60                               | 60                               | 
| waagent.resources.requests.cpu                   | The minimum CPU requested to run                                                                                                                                                                                                                                     | yes            | 200m                             | 200m                             | 
| waagent.resources.requests.memory                | The minimum memory requested to run                                                                                                                                                                                                                                  | yes            | 200Mi                            | 200Mi                            | 
| waagent.resources.limits.cpu                     | The maximum CUP requested to run                                                                                                                                                                                                                                     | yes            | 1                                | 1                                | 
| waagent.resources.limits.memory                  | The maximum memory requested to run                                                                                                                                                                                                                                  | yes            | 2Gi                              | 2Gi                              | 
| waagent.persistence.enabled                      | If true, persistent volumes for the pods are used                                                                                                                                                                                                                    | no             | true                             | true                             |
| waagent.persistence.useDynamicProvisioning       | If true, StorageClasses are used to dynamically create persistent volumes for the pods                                                                                                                                                                               | no             | true                             | true                             | 
| waagent.persistence.dataPVC.name                 | The prefix for the Persistent Volumes Claim name                                                                                                                                                                                                                     | no             | data                             | data                             |
| waagent.persistence.dataPVC.storageClassName     | The name of the Storage Class to be used. Leave empty to not use a storage class                                                                                                                                                                                     | no             | nfs-dynamic                      |                                  |
| waagent.persistence.dataPVC.selector.label       | Volume label to bind (only limited to single label)                                                                                                                                                                                                                  | no             | my-volume-label                  |                                  |
| waagent.persistence.dataPVC.selector.value       | Volume label value to bind (only limited to single value)                                                                                                                                                                                                            | no             | my-volume-value                  |                                  |
| waagent.persistence.dataPVC.size                 | The minimum size of the Persistent Volume                                                                                                                                                                                                                            | no             | 2Gi                              | 2Gi                              |

- **Console** 

| **Parameter**                                       | **Description**                                                                                                                                                                                                                                                        | **Mandatory** | **Example**                      | **Default**                                        |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   | ------------- | -------------------------------- | ------------------------------------------         |
| waconsole.fsGroupId                                 | The secondary group ID of the user                                                                                                                                                                                                                                     | no            | 999                              |                                                    |
| waconsole.supplementalGroupId                       | Supplemental group id of the user                                                                                                                                                                                                                                      | no            |                                  |                                                    |
| waconsole.replicaCount                              | Number of replicas to deploy                                                                                                                                                                                                                                           | yes           | 1                                | 1                                                  |
| waconsole.image.repository                          | IBM Workload Automation Console image repository                                                                                                                                                                                                                                | yes           | ibm-workload-automation-console      | ibm-workload-automation-console                        |
| waconsole.image.tag                                 | IBM Workload Automation Console image tag                                                                                                                                                                                                                                       | yes           | 9.5.0.00                        | 9.5.0.00                                          |
| waconsole.image.pullPolicy                          | Image pull policy                                                                                                                                                                                                                                                      | yes           | Always                           | Always                                             |
| waconsole.console.containerDebug                    | The container is executed in debug mode                                                                                                                                                                                                                                | no            | no                               | no                                                 |
| waconsole.console.db.type                           | The preferred remote database server type (e.g. DERBY, DB2, ORACLE, MSSQL, IDS). Use Derby database only for demo or test purposes.                                                                                                                                    | yes           | DB2                              | DB2                                                |
| waconsole.console.db.hostname                       | The Hostname or the IP Address of the database server                                                                                                                                                                                                                  | yes           | <dbhostname>                     |                                                    |
| waconsole.console.db.port                           | The port of the database server                                                                                                                                                                                                                                        | yes           | 50000                            | 50000                                              |
| waconsole.console.db.name                           | Depending on the database type, the name is different; enter the name of the Server's database for DB2/Informix/MSSQL, enter the Oracle Service Name for Oracle                                                                                                        | yes           | TWS                              | TWS                                                |
| waconsole.console.db.tsName                         | The name of the DATA table space                                                                                                                                                                                                                                       | no            | TWS_DATA                         |                                                    |
| waconsole.console.db.tsPath                         | The path of the DATA table space                                                                                                                                                                                                                                       | no            | TWS_DATA                         |                                                    |
| waconsole.console.db.tsTempName                     | The name of the TEMP table space (Valid only for Oracle)                                                                                                                                                                                                               | no            | TEMP                             | leave it blank                                     |
| waconsole.console.db.tssbspace                      | The name of the SB table space (Valid only for IDS).                                                                                                                                                                                                                   | no            | twssbspace                       | twssbspace                                         |
| waconsole.console.db.user                           | The database user who accesses the Console tables on the database server. In case of Oracle, it identifies also the database. It can be specified in a secret too                                                                                                      | yes           | db2inst1                         |                                                    |
| waconsole.console.db.adminUser                      | The database user administrator who accesses the Console tables on the database server. It can be specified in a secret too                                                                                                                                            | yes           | db2inst1                         |                                                    |
| waconsole.console.db.sslConnection                  | If true, SSL is used to connect to the database (Valid only for DB2)	                                                                                                                                                                                               | no            | false                            | false                                              |
| waconsole.console.db.usepartitioning                | Enable the Oracle Partitioning feature. Valid only for Oracle. Ignored for other databases                                                                                                                                                                             | no            | true                       	  | true                                               |
| waconsole.console.pwdSecretName                     | The name of the secret to store all passwords                                                                                                                                                                                                                          | yes           | wa-pwd-secret                    | wa-pwd-secret                                      |
| waconsole.console.livenessProbe.initialDelaySeconds | The number of seconds after which the liveness probe starts checking if the server is running                                                                                                                                                                          | yes           | 100                              | 100                                                | 
| waconsole.console.useCustomizedCert                 | If true, customized SSL certificates are used to connect to the Dynamic Workload Console                                                                                                                                                                               | no            | false                            | false                                              |
| waconsole.console.certSecretName                    | The name of the secret to store customized SSL certificates                                                                                                                                                                                                            | no            | waconsole-cert-secret            |                                                    |
| waconsole.console.libConfigName                     | The name of the ConfigMap to store all custom liberty configuration                                                                                                                                                                                                    | no            | libertyConfigMap                 |                                                    |
| waconsole.console.ingress.enabled                   | If true, the ingress controller rules is enabled                                                                                                                                                                                                                       | no            | true                             | true                                               |
| waconsole.console.ingress.hostname                  | The virtual hostname defined in the DNS used to reach the Console                                                                                                                                                                                                      | no            | console.mycluster.proxy          | <helmrelease>-waconsole.mycluster.proxy            |
| waconsole.console.ingress.secretName                | The name of the secret to store certificates used by the ingress. If not used, leave it empty                                                                                                                                                                          | no            | waconsole-ingress-secret         |                                                    |
| waconsole.resources.requests.cpu                    | The minimum CPU requested to run                                                                                                                                                                                                                                       | yes           | 1                                | 1                                                  | 
| waconsole.resources.requests.memory                 | The minimum memory requested to run                                                                                                                                                                                                                                    | yes           | 4Gi                              | 4Gi                                                | 
| waconsole.resources.limits.cpu                      | The maximum CUP requested to run                                                                                                                                                                                                                                       | yes           | 4                                | 4                                                  | 
| waconsole.resources.limits.memory                   | The maximum memory requested to run                                                                                                                                                                                                                                    | yes           | 16Gi                             | 16Gi                                               | 
| waconsole.persistence.enabled                       | If true, persistent volumes for the pods are used                                                                                                                                                                                                                      | no            | true                             | true                                               |
| waconsole.persistence.useDynamicProvisioning        | If true, StorageClasses are used to dynamically create persistent volumes for the pods                                                                                                                                                                                 | no            | true                             | true                                               |
| waconsole.persistence.dataPVC.name                  | The prefix for the Persistent Volumes Claim name                                                                                                                                                                                                                       | no            | data                             | data                                               |
| waconsole.persistence.dataPVC.storageClassName      | The name of the StorageClass to be used. Leave empty to not use a storage class                                                                                                                                                                                        | no            | nfs-dynamic                      |                                                    |
| waconsole.persistence.dataPVC.selector.label        | Volume label to bind (only limited to single label)                                                                                                                                                                                                                    | no            | my-volume-label                  |                                                    |
| waconsole.persistence.dataPVC.selector.value        | Volume label value to bind (only limited to single label)                                                                                                                                                                                                              | no            | my-volume-value                  |                                                    |
| waconsole.persistence.dataPVC.size                  | The minimum size of the Persistent Volume                                                                                                                                                                                                                              | no            | 5Gi                              | 5Gi                                                |
| waconsole.engine.hostname                           | The hostname or IP address of the engine where the server is installed. Configuring this setting, the engine hostname field on the UI is automatically filled in                                                                                                       | no            | wa-server                        |                                                    |
| waconsole.engine.port                               | The port on which the engine - where the server is installed - is contacted by the console. Configuring this setting, the engine port field on the UI is automatically filled in                                                                                       | no            | 31116                            |                                                    |
| waconsole.engine.user                               | The user who accesses the engine where the server is installed. Configuring this setting, the engine user field on the UI is automatically filled in                                                                                                                   | no            | wauser                           |                                                    |

- **Server**

| **Parameter**                                       | **Description**                                                                                                                                                                                                                                                        | **Mandatory** | **Example**                      | **Default**                                      |
| -------------------------------------------------   | -----------------------------------------------------------------------------------------------------------------------------------------------------------------                                                                                                      | ------------- | -------------------------------- | -------------------------------------------      |
| waserver.fsGroupId                                  | The secondary group ID of the user                                                                                                                                                                                                                                     | no            | 999                              |                                                  |
| waserver.supplementalGroupId                        | Supplemental group id of the user                                                                                                                                                                                                                                      | no            |                                  |                                                  |
| waserver.replicaCount                               | Number of replicas to deploy                                                                                                                                                                                                                                           | yes           | 1                                | 1                                                |
| waserver.image.repository                           | IBM Workload Automation Server image repository                                                                                                                                                                                                                                 | yes           | ibm-workload-automation-server       | ibm-workload-automation-server                       |
| waserver.image.tag                                  | IBM Workload Automation Server image tag                                                                                                                                                                                                                                        | yes           | 9.5.0.00                        | 9.5.0.00                                        |
| waserver.image.pullPolicy                           | Image pull policy                                                                                                                                                                                                                                                      | yes           | Always                           | Always                                           |
| waserver.server.company                             | The name of your Company                                                                                                                                                                                                                                               | no            | my-company                       | my-company                                       |
| waserver.server.agentName                           | The name to be assigned to the dynamic agent of the Server                                                                                                                                                                                                             | no            | WA_SAGT                          | WA_AGT                                           |
| waserver.server.dateFormat                          | The date format defined in the plan                                                                                                                                                                                                                                    | no            | MM/DD/YYYY                       | MM/DD/YYYY                                       |
| waserver.server.startOfDay                          | The start time of the plan processing day in 24 hour format: hhmm                                                                                                                                                                                                      | no            | 0000                       	  | 0600                                             |
| waserver.server.timezone                            | The timezone used in the create plan command                                                                                                                                                                                                                           | no            | America/Chicago                  |                                                  |
| waserver.server.tz                                  | If used, it sets the TZ operating system environment variable                                                                                                                                                                                                          | no            | America/Chicago                  |                                                  |
| waserver.server.createPlan                          | If true, an automatic JnextPlan is executed at the same time of the container deployment                                                                                                                                                                               | no            | no                               | no                                               |
| waserver.server.containerDebug                      | The container is executed in debug mode                                                                                                                                                                                                                                | no            | no                               | no                                               |
| waserver.server.db.type                             | The preferred remote database server type (e.g. DERBY, DB2, ORACLE, MSSQL, IDS)                                                                                                                                                                                        | yes           | DB2                              | DB2                                              |
| waserver.server.db.hostname                         | The Hostname or the IP Address of the database server                                                                                                                                                                                                                  | yes           | <dbhostname>                     |                                                  |
| waserver.server.db.port                             | The port of the database server                                                                                                                                                                                                                                        | yes           | 50000                            | 50000                                            |
| waserver.server.db.name                             | Depending on the database type, the name is different; enter the name of the Server's database for DB2/Informix/MSSQL, enter the Oracle Service Name for Oracle                                                                                                        | yes           | TWS                              | TWS                                              |
| waserver.server.db.tsName                           | The name of the DATA table space                                                                                                                                                                                                                                       | no            | TWS_DATA                         |                                                  |
| waserver.server.db.tsPath                           | The path of the DATA table space                                                                                                                                                                                                                                       | no            | TWS_DATA                         |                                                  |
| waserver.server.db.tsLogName                        | The name of the LOG table space                                                                                                                                                                                                                                        | no            | TWS_LOG                          |                                                  |
| waserver.server.db.tsLogPath                        | The path of the LOG table space                                                                                                                                                                                                                                        | no            | TWS_LOG                          |                                                  |
| waserver.server.db.tsPlanName                       | The name of the PLAN table space                                                                                                                                                                                                                                       | no            | TWS_PLAN                         |                                                  |
| waserver.server.db.tsPlanPath                       | The path of the PLAN table space                                                                                                                                                                                                                                       | no            | TWS_PLAN                         |	                                                 |
| waserver.server.db.tsTempName                       | The name of the TEMP table space (Valid only for Oracle)                                                                                                                                                                                                               | no            | TEMP                             | leave it empty                                   |
| waserver.server.db.tssbspace                        | The name of the SB table space (Valid only for IDS)                                                                                                                                                                                                                    | no            | twssbspace                       | twssbspace                                       |
| waserver.server.db.usepartitioning                  | Enable the Oracle Partitioning feature. Valid only for Oracle. Ignored for other databases                                                                                                                                                                             | no            | true                       	  | true                                             |
| waserver.server.db.user                             | The database user who accesses the Server tables on the database server. In case of Oracle, it identifies also the database. It can be specified in a secret too                                                                                                       | yes           | db2inst1                         |                                                  |
| waserver.server.db.adminUser                        | The database user administrator who accesses the Server tables on the database server. It can be specified in a secret too                                                                                                                                             | yes           | db2inst1                         |                                                  |
| waserver.server.db.sslConnection                    | If true, SSL is used to connect to the database (Valid only for DB2)	                                                                                                                                                                                               | no            | false                            | false                                            |
| waserver.server.pwdSecretName                       | The name of the secret to store all passwords                                                                                                                                                                                                                          | yes           | wa-pwd-secret                    | wa-pwd-secret                                    |
| waserver.server.livenessProbe.initialDelaySeconds   | The number of seconds after which the liveness probe starts checking if the server is running                                                                                                                                                                          | yes           | 600                              | 600                                              |  
| waserver.server.useCustomizedCert                   | If true, customized SSL certificates are used to connect to the master domain manager                                                                                                                                                                                  | no            | false                            | false                                            |
| waserver.server.certSecretName                      | The name of the secret to store customized SSL certificates                                                                                                                                                                                                            | no            | waserver-cert-secret             |	                                                 |
| waserver.server.libConfigName                       | The name of the ConfigMap to store all custom liberty configuration                                                                                                                                                                                                    | no            | libertyConfigMap                 |                                                  |
| waserver.server.ingress.enabled                     | If true, the ingress controller rules is enabled                                                                                                                                                                                                                       | no            | true                             | true                                             |
| waserver.server.ingress.hostname                    | The virtual hostname defined in the DNS used to reach the Server                                                                                                                                                                                                       | no            | server.mycluster.proxy           | <helmrelease>-waserver.mycluster.proxy           |
| waserver.server.ingress.secretName                  | The name of the secret to store certificates used by the ingress. If not used, leave it empty                                                                                                                                                                          | no            | waserver-ingress-secret          |                                                  |
| waserver.resources.requests.cpu                     | The minimum CPU requested to run                                                                                                                                                                                                                                       | yes           | 1                                | 1                                                | 
| waserver.resources.requests.memory                  | The minimum memory requested to run                                                                                                                                                                                                                                    | yes           | 4Gi                              | 4Gi                                              | 
| waserver.resources.limits.cpu                       | The maximum CUP requested to run                                                                                                                                                                                                                                       | yes           | 4                                | 4                                                | 
| waserver.resources.limits.memory                    | The maximum memory requested to run                                                                                                                                                                                                                                    | yes           | 16Gi                             | 16Gi                                             | 
| waserver.persistence.enabled                        | If true, persistent volumes for the pods are used                                                                                                                                                                                                                      | no            | true                             | true                                             |
| waserver.persistence.useDynamicProvisioning         | If true, StorageClasses are used to dynamically create persistent volumes for the pods                                                                                                                                                                                 | no            | true                             | true                                             |
| waserver.persistence.dataPVC.name                   | The prefix for the Persistent Volumes Claim name                                                                                                                                                                                                                       | no            | data                             | data                                             |
| waserver.persistence.dataPVC.storageClassName       | The name of the StorageClass to be used. Leave empty to not use a storage class                                                                                                                                                                                        | no            | nfs-dynamic                      |                                                  |
| waserver.persistence.dataPVC.selector.label         | Volume label to bind (only limited to single label)                                                                                                                                                                                                                    | no            | my-volume-label                  |                                                  |
| waserver.persistence.dataPVC.selector.value         | Volume label value to bind (only limited to single value)                                                                                                                                                                                                              | no            | my-volume-value                  |                                                  |
| waserver.persistence.dataPVC.size                   | The minimum size of the Persistent Volume                                                                                                                                                                                                                              | no            | 10Gi                             | 10Gi                                             |

(*) Note: for details about static workstation pools, see: 
[Workstation](https://www.ibm.com/support/knowledgecenter/en/SSGSPN_9.5.0/com.ibm.tivoli.itws.doc_9.5/distr/src_ref/awsrgworkstationconcept.htm).

(**) Note: if you set `useCustomizedCert:true`, you must create a secret containing the following customized files:

- Agent (standalone or included with server):
    * TWSClientKeyStoreJKS.sth
    * TWSClientKeyStore.kdb
    * TWSClientKeyStore.sth
    * TWSClientKeyStoreJKS.jks

- Server and Console:
    * TWSServerTrustFile.jks
    * TWSServerKeyFile.jks
    * ltpa.keys	

   that will replace the default ones. For detailed instructions, see the Secrets section.
   
(***) Note: if you set `db.sslConnection:true` you must set to be true the `useCustomizeCert` setting too (on both server and console charts); more, you must add the following certificates in the customized SSL certificates secret on both server and console charts:

    * TWSServerTrustFile.jks
    * TWSServerKeyFile.jks
    * TWSServerTrustFile.jks.pwd
    * TWSServerKeyFile.jks.pwd
	
   For detailed instructions, see the Secrets section.

(****) Note: if you want to use custom Liberty configuration, add the xml configuration file in the ConfigMap. For further details about ConfigMap, see the "Creating ConfigMaps" chapter on the cloud platform documentation.
 
Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example:

   ```bash
   $ helm install --name release_name stable/ibm-workload-automation-prod --set license=accept --tls
   ```

> **Tip**: You can use the default values.yaml


## Secrets

1. Passwords Secret:

    This secret is valid for Console and Server only.
	
    Manually create a mysecret.yaml file to store passwords. In the mysecret.yaml file, hidden passwords must be entered; to hide them, run the following command:

	    echo -n 'mypassword' | base64
		
	> **Note**: The command must be launched three times, once for each password that must be entered in the mysecret.yaml
		
	The mysecret.yaml file must contain the following parameters:

        apiVersion: v1
        kind: Secret
        metadata:
         name: <secret_name>
         namespace: <your_namespace>
        type: Opaque
        data:
          WA_PASSWORD: <hidden password>
          DB_ADMIN_PASSWORD: <hidden password>
          DB_PASSWORD: <hidden password>
     
     where:
     
     - **<secret_name>** is the value of the pwdSecretName parameter defined in the Configuration section;    
     - **<your_namespace>** is the namespace where you are going to deploy the chart.  

    Once the file has been created and filled in, it must be imported; to import it, log in to your namespace and launch the following command:
	
	    kubectl create -f <my_path>/mysecret.yaml
	  
	  where **<my_path>** is the location path of mysecret.yaml file.
	  
2. Certificates Secret:

    If you want to use custom certificates, set `useCustomizedCert:true` and use kubectl to create the secret in the same namespace where you want to deploy the chart:   
    
      ```bash
      $ kubectl create secret generic release_name-secret --from-file=TWSClientKeyStoreJKS.sth --from-file=TWSClientKeyStore.kdb --from-file=TWSClientKeyStore.sth --from-file=TWSClientKeyStoreJKS.jks --from-file=TWSServerTrustFile.jks --from-file=TWSServerKeyFile.jks --namespace=chart_namespace
      ```
    
    where TWSClientKeyStoreJKS.sth, TWSClientKeyStore.kdb, TWSClientKeyStore.sth, TWSClientKeyStoreJKS.jks, TWSServerTrustFile.jks and TWSServerKeyFile.jks are the Container keystore and stash file containing your customized certificates.
    For details about custom certificates, see the [online](https://www.ibm.com/support/knowledgecenter/en/SSGSPN_9.5.0/com.ibm.tivoli.itws.doc_9.5/distr/src_ad/awsadsslddmda.htm) documentation.
    
    See an example where `release_name` = myname and `namespace` = default: 
    
      ```bash
      $ kubectl create secret generic myname-secret --from-file=TWSClientKeyStore.kdb --from-file=TWSClientKeyStore.sth --namespace=default
      ```
    
    If you want to use SSL connection to DB, set `db.sslConnection:true` and `useCustomizedCert:true`, then use kubectl to create the secret in the same namespace where you want to deploy the chart:

      ```bash
      $ kubectl create secret generic release_name-secret --from-file=TWSServerTrustFile.jks --from-file=TWSServerKeyFile.jks --from-file=TWSServerTrustFile.jks.pwd --from-file=TWSServerKeyFile.jks.pwd --namespace=chart_namespace
      ```    

    > **Note**: Passwords for "TWSServerTrustFile.jks" and "TWSServerKeyFile.jks" files must be entered in the respective "TWSServerTrustFile.jks.pwd" and "TWSServerKeyFile.jks.pwd" files.

	
## Single Sign-On (SSO) configuration

To enable SSO between console and server, LTPA tokens must be the same. The following procedure explains how to create LTPA tokens to be shared between server and console (this procedure must be run only once and not on both systems). 

Access the container by launching the following command:

     kubectl exec -it <server_pod_name> /bin/bash

Create new LTPA token, by launching the following command:

     /opt/wautils/wa_create_ltpa_keys.sh -p <keys_password> -o /home/wauser

  where:

  - **<keys_password>** is LTPA keys password ( for further details, see the [online](https://www.ibm.com/support/knowledgecenter/en/SSGSPN_9.5.0/com.ibm.tivoli.itws.doc_9.5/distr/src_ad/awsadshareltpa.htm) documentation).
	
The "ltpa.keys" and "wa_ltpa.xml" files are created in /home/wauser.

Exit from the container by launching the "exit" command.

Copy the just created files in the local machine, by launching the following command:

     kubectl cp <server_pod_name>:/home/wauser/ltpa.keys <host_dir>
	 kubectl cp <server_pod_name>:/home/wauser/wa_ltpa.xml <host_dir>
	 
  where:

  - **<host_dir>** is an existing folder on the local machine where kubectl runs
  
The "ltpa.keys" file must be placed into the secret that stores customized SSL certificates (on both server and console charts); to place it into the secret, launch the following command:

     kubectl create secret generic <secret_name> --from-file=<host_dir>/ltpa.keys --namespace=<your_namespace>

The "wa_ltpa.xml" file must be placed in the ConfigMap that stores all custom liberty configurations (on both server and console charts); to place it into the ConfigMap, launch the following command:

     kubectl create configmap <configmap_name> --from-file=<host_dir>/wa_ltpa.xml --namespace=<your_namespace>

For further details about ConfigMap, see the "Creating ConfigMaps" chapter on the cloud platform documentation.

In both server and console charts, useCustomizedCert property must set to be "true", the libConfigName and certSecretName properties must be configured with the related name defined in the commands previously launched.
 

## Storage

To make persistent all configuration and runtime data, the Persistent Volume you specify is mounted in the container folder:

- Agent: /home/wauser

- Console: /home/wauser
		   
- Server: /home/wauser

The Pod is based on a StatefulSet. This is to guarantee that each Persistent Volume is mounted in the same Pod when it is scaled up or down.  

Only for test purposes, you can configure the chart in a way not to use persistence.

You can pre-create Persistent Volumes to be bound to the StatefulSet using Label or StorageClass. Anyway, it is highly suggested to use persistence with dynamic provisioning. In this case you must have defined your own Dynamic Persistence Provider.

The Helm chart is written so that it can support several different **storage** **use cases**:

 **1. Persistent storage using kubernetes dynamic provisioning** 
 
  It uses the default storageClass defined by the kubernetes admin or by using a custom storageClass which overrides the default.
  Set the values as follows:
 
  *   `persistence.enabled:true (default)` 
  *   `persistence.useDynamicProvisioning:true(default)`
  
  Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.    
 
 **2. Persistent storage using a predefined PersistentVolume setup prior to the deployment of this chart**
 
  Set global values to:
  
  *  `persistence.enabled:true` 
  *  `persistence.useDynamicProvisioning:false`
 
  Let the Kubernetes binding process select a pre-existing volume based on the accessMode and size. Use selector labels to refine the binding process.

 **3. No persistent storage** 
 
  The entire storage is within the container and will be lost when pod terminates. 
  Enable this mode by setting the global values to:
  
  *  `persistence.enabled:false` 
  *  `persistence.useDynamicProvisioning:false` 


## Limitations

*  Limited to amd64 platforms  


## Documentation

For a description of IBM Workload Automation functionalities, see the [online](https://www.ibm.com/support/knowledgecenter/en/SSGSPN_9.5.0/com.ibm.tivoli.itws.doc_9.5/twa_landing.html) documentation.

## Troubleshooting

In case of issues, see the [online](https://www.ibm.com/support/knowledgecenter/en/SSGSPN_9.5.0/com.ibm.tivoli.itws.doc_9.5/distr/src_pi/troubleshootingforcontainers.htm) documentation.
