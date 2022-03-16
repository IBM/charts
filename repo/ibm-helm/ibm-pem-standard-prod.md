# IBM Partner Engagement Manager
## Introduction

## Chart Details

This chart deploys IBM Partner Engagement Manager Standard cluster on a container management platform with the following resources.


## Prerequisites

1. Kubernetes version >= 1.20 with beta APIs enabled

2. ocp version >= 4.0 with beta APIs enabled

3. Helm version >= 3.2

4. Ensure that one of the supported database server (Oracle/DB2) is installed and the database is accessible from inside the cluster.

5. Ensure that the docker images for IBM Partner Engagement Manager Standard from Entitlement registry are loaded to an appropriate docker registry.

6. When `volumeClaims.resources.enabled` is `true`, create a persistent volume for application resources with access mode as 'ReadWriteMany' and place the database driver jar , SEAS jars and MQ jars in the mapped volume location.

7. When `volumeClaims.logs.enable` is `true`, create a persistent volume for application logs with access mode as 'Read Write Many' and create required subfolders for IBM PEM Partner Repository Partner Provisioner PCM_prod and PCM_nonProd must have the 755 permission to read and execute for accessing all subfolders by the pemuser (id:1011) container..

8. When `communitymanager.prod.archive.enabled` is `true`, create a persistent volume for prod pcm archive document storage with access mode as 'Read Write Many'.

9. When `communitymanager.nonprod.archive.enabled` is `true`, create a persistent volume for non-prod pcm archive document storage with access mode as 'Read Write Many'.

    Mount the archive persistent volume to pem server

9. Create secrets with requisite confidential credentials for passphrase.txt, Keystore.jks dbpasswords and keystore passwords. You can use the supplied configuration files under pak_extensions/pre-install/secret directory.


10. Create a secret from the provided syntax file included in helm charts /ibm-cloudpak-extensons/preinstall/secrets.yaml

    ```
      oc apply -f app-secrets.yaml

      ```

11. Create a secret to pull the image from a private registry or repository using following command
    ```
    oc create secret docker-registry <name of secret> --docker-server=<your-registry-server> --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>

       ```

12. create secrets with confidential certificates (Keystore files for both Partner Engagement Manager and Community Manger) required by Database, MQ for SSL connectivity using below command.

     Note: Name of the secret and the keystore filename must be same for server keystore secret
    ```
     oc create secret generic <secret-name> --from-file=/path/to/<Keystore.jks>

	   ```
13. create configmap with localtime file present in local machine using below command
    ```
     oc create configmap <configmap-name> --from-file=/etc/localtime

	   ```

14. When installing the chart on a new database which does not have IBM PEM standard Software schema tables and metadata,
* ensure that `dbsetup.upgrade` parameter is set to `false' and `dbsetup.enabled` parameter is set to `true' This will create the required database tables and metadata in the database before installing the chart.

15. When installing the chart on a database with new image upgrade
* ensure that `dbsetup.upgrade` parameter is set to `true`

16. Apply security context contraints to created service account .

    ```
     oc adm policy add-scc-to-user ibm-pem-scc system:serviceaccount:<namespace>:<service account name>

	   ```
* Note: Avoid installing multiple charts on same namespace

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)

This chart optionally defines a custom PodSecurityPolicy which is used to finely control the permissions/capabilities needed to deploy this chart. It is based on the predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/ibm-anyuid-psp.yaml) with extra required privileges. You can enable this policy by using the Platform User Interface or configuration file available under pak_extensions/pre-install/ directory
- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:

    ```

    apiVersion: policy/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: "ibm-b2bi-psp"
      labels:
        app: "ibm-b2bi-psp"

    spec:
      privileged: false
      allowPrivilegeEscalation: false
      hostPID: false
      hostIPC: false
      hostNetwork: false
      allowedCapabilities:
      requiredDropCapabilities:
      - MKNOD
      - AUDIT_WRITE
      - KILL
      - NET_BIND_SERVICE
      - NET_RAW
      - FOWNER
      - FSETID
      - SYS_CHROOT
      - SETFCAP
      - SETPCAP
      - CHOWN
      - SETGID
      - SETUID
      - DAC_OVERRIDE
      allowedHostPaths:
      runAsUser:
        rule: MustRunAs
        ranges:
        - min: 1
          max: 4294967294
      runAsGroup:
        rule: MustRunAs
        ranges:
        - min: 1
          max: 4294967294
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: MustRunAs
        ranges:
        - min: 1
          max: 4294967294
      fsGroup:
        rule: MustRunAs  
        ranges:
        - min: 1
          max: 4294967294
      volumes:
      - configMap
      - emptyDir
      - projected
      - secret
      - downwardAPI
      - persistentVolumeClaim
      - nfs
      forbiddenSysctls:
      - '*'
    ```

  - Custom ClusterRole for the custom PodSecurityPolicy:

    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: "ibm-b2bi-psp"
      labels:
        app: "ibm-b2bi-psp"
    rules:
    - apiGroups:
      - policy
      resourceNames:
      - "ibm-b2bi-psp"
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```


### SecurityContextConstraints Requirements

* Predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc)

This chart optionally defines a custom SecurityContextConstraints (on Red Hat OpenShift Container Platform) which is used to finely control the permissions/capabilities needed to deploy this chart.  It is based on the predefined SecurityContextConstraint name: [`ibm-restricted-scc`](https://github.com/IBM/cloud-pak/blob/master/spec/security/scc/ibm-restricted-scc.yaml) with extra required privileges.

  - Custom SecurityContextConstraints definition:

    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-b2bi-scc
      labels:
       app: "ibm-b2bi-scc"
    allowHostDirVolumePlugin: false
    allowHostIPC: false
    allowHostNetwork: false
    allowHostPID: false
    allowHostPorts: false
    privileged: false
    allowPrivilegeEscalation: false
    allowPrivilegedContainer: false
    allowedCapabilities:
    allowedFlexVolumes: []
    allowedUnsafeSysctls: []
    defaultAddCapabilities: []
    defaultAllowPrivilegeEscalation: false
    forbiddenSysctls:
      - "*"
    fsGroup:
      type: MustRunAs
      ranges:
      - min: 1
        max: 4294967294
    readOnlyRootFilesystem: false
    requiredDropCapabilities:
    - MKNOD
    - AUDIT_WRITE
    - KILL
    - NET_BIND_SERVICE
    - NET_RAW
    - FOWNER
    - FSETID
    - SYS_CHROOT
    - SETFCAP
    - SETPCAP
    - CHOWN
    - SETGID
    - SETUID
    - DAC_OVERRIDE
    runAsUser:
      type: MustRunAsRange
    # This can be customized for your host machine
    seLinuxContext:
      type: RunAsAny
    # seLinuxOptions:
    #   level:
    #   user:
    #   role:
    #   type:
    supplementalGroups:
      type: MustRunAs
      ranges:
      - min: 1
        max: 4294967294
    # This can be customized for your host machine
    volumes:
    - configMap
    - downwardAPI
    - emptyDir
    - persistentVolumeClaim
    - projected
    - secret
    - nfs
    priority: 0
    ```
    - Custom ClusterRole for the custom SecurityContextConstraints:

    ```
    apiVersion: rbac.authorization.k8s.io/v1
	kind: ClusterRole
	metadata:
     name: "ibm-b2bi-scc"
     labels:
      app: "ibm-b2bi-scc"
	rules:
	- apiGroups:
  	  - security.openshift.io
  	  resourceNames:
      - "ibm-b2bi-scc"
      resources:
      - securitycontextconstraints
      verbs:
      - use

    ```

## Resources Required

## Configuration
### The following table lists the configurable parameters for the chart


Pod                                       | Memory Requested  | Memory Limit | CPU Requested | CPU Limit
------------------------------------------| ------------------|--------------| --------------|----------
PEM Portal pod                            |       4 Gi        |     8 Gi     |      1        |    2
PP pod                                    |       2 Gi        |     4 Gi     |      1        |    2
PR pod                                    |       2 Gi        |     4 Gi     |      1        |    2
API Gateway pod                           |       2 Gi        |     4 Gi     |      1        |    2
PCM Prod pod                              |       2 Gi        |     4 Gi     |      1        |    2
PCM Non Prod pod                          |       2 Gi        |     4 Gi     |      1        |    2
Agent pod                                 |       2 Gi        |     4 Gi     |      1        |    2
Purge (API) pod                           |       0.5 Gi      |     1 Gi     |      0.1      |    0.5



## Installing the Chart

Prepare a custom values.yaml file based on the configuration section which will be present in chart_Directory/valus.yaml.
## Configuration

The following table lists the configurable parameters of the Ibm-pem-standard chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `image.name` | Provide the value in double quotes | `"cp.icr.io/cp/ibm-pem/pem"` |
| `image.tag` | Specify the tag name | `"6.2.0.2"` |
| `image.pullPolicy` |  | `null` |
| `image.pullSecret` | Provide the pull secret name | `""` |
| `arch` |  | `"amd64"` |
| `serviceAccountName` | specify the service account name which has required permissions | `null` |
| `timezone.configmapname` | specify the timezone configmap | `null` |
| `volumeClaims.resources.enabled` | if enabled persistent volume will be used | `true` |
| `volumeClaims.resources.capacity` |  | `"100Mi"` |
| `volumeClaims.resources.storageclass` |  | `"slow"` |
| `volumeClaims.logs.enabled` | Specify the values to true or false based on requriement The logs directory and all sub-directories must have the 755 permission to read and execute for accessing all MountFiles by the pemuser (id:1011) container. | `true` |
| `volumeClaims.logs.subpath.migrator` | specify the directory for migrator logs inside a persistent volume for logs with required permissions | `"migrator"` |
| `volumeClaims.logs.subpath.dbutils` | specify the directory for dbutils logs inside a persistent volume for logs with required permissions | `"dbutil"` |
| `volumeClaims.logs.subpath.pem` | specify the directory for pem logs inside a persistent volume for logs with required permissions | `"pem"` |
| `volumeClaims.logs.subpath.pp` | specify the directory for pp logs inside a persistent volume for logs with required permissions | `"pp"` |
| `volumeClaims.logs.subpath.pr` | specify the directory for pr logs inside a persistent volume for logs with required permissions | `"pr"` |
| `volumeClaims.logs.subpath.apigateway` | specify the directory for apigateway logs inside a persistent volume for logs with required permissions | `"apigateway"` |
| `volumeClaims.logs.subpath.ssoMigrator` | specify the directory for ssoMigrator logs inside a persistent volume for logs with required permissions | `"ssomigration"` |
| `volumeClaims.logs.subpath.purge` | specify the directory for purge logs inside a persistent volume for logs with required permissions | `"purge"` |
| `volumeClaims.logs.subpath.agent` | specify the directory for agent logs inside a persistent volume for logs with required permissions | `"agent"` |
| `volumeClaims.logs.subpath.pcmProd` | specify the directory for pcmProd logs inside a persistent volume for logs with required permissions | `"PCM_prod"` |
| `volumeClaims.logs.subpath.pcmNonProd` | specify the directory for pcmNonProd logs inside a persistent volume for logs with required permissions | `"PCM_nonProd"` |
| `volumeClaims.logs.capacity` |  | `"1Gi"` |
| `volumeClaims.logs.storageclass` |  | `null` |
| `volumeClaims.logs.accessModes` |  | `["ReadWriteMany"]` |
| `test.image.repository` |  | `"cp.icr.io/cp"` |
| `test.image.name` |  | `"opencontent-common-utils"` |
| `test.image.tag` |  | `"1.1.11"` |
| `test.image.pullPolicy` |  | `"IfNotPresent"` |
| `dbsetup.enabled` | If it is first installation specify the values true | `false` |
| `dbsetup.upgrade` | If it is upgrade Specify the values to true | `true` |
| `dbsetup.resources.requests.memory` |  | `"2Gi"` |
| `dbsetup.resources.requests.cpu` |  | `"250m"` |
| `dbsetup.resources.limits.memory` |  | `"4Gi"` |
| `dbsetup.resources.limits.cpu` |  | `"500m"` |
| `dbsetup.setupfile.passphrasesecret` |  | `null` |
| `dbsetup.setupfile.migrator.default_sponsor` |  | `true` |
| `dbsetup.setupfile.accept_license` | Valid values are true or false | `true` |
| `dbsetup.setupfile.proxy_host` | Provide your network's forward proxy machine's host name or IP. | `null` |
| `dbsetup.setupfile.proxy_port` | Provide your network's forward proxy's port. | `null` |
| `dbsetup.setupfile.proxy_user_name` | Provide your network's forward proxy's user name. If the proxy does not require authentication, leave the field blank. | `null` |
| `dbsetup.setupfile.proxy_password` | Provide the secret name | `null` |
| `dbsetup.setupfile.proxy_protocol` |  | `null` |
| `dbsetup.setupfile.customer_id` | Specify the customer ID. Ensure that the customer ID that you specify matches with your Bluemix ID that you have registered to download IBM PEM image | `null` |
| `dbsetup.setupfile.db_type` | Specify the database type which you are using either DB2 or Oracle. | `null` |
| `dbsetup.setupfile.ssl_connection` | Set the value to true if your using SSL connection between the application servers and database | `null` |
| `dbsetup.setupfile.db_port` | specify the port | `null` |
| `dbsetup.setupfile.db_host` | specify the host | `null` |
| `dbsetup.setupfile.db_name` | Specify the DATABASE Name | `null` |
| `dbsetup.setupfile.db_schema` | Specify the Schema name | `null` |
| `dbsetup.setupfile.db_user` | Specify the DB username | `null` |
| `dbsetup.setupfile.db_password` | Specify the secret | `null` |
| `dbsetup.setupfile.db_driver` | Sepcify the corresponfing driver details for oracle or DB2 dpending on the db_tpe that is selected For example, for ORacle, set the values of db_driver to oracle.jdbc.OracleDriver.For DB2, set com.ibm.db2.jcc.DB2Driver. | `null` |
| `dbsetup.setupfile.db_max_pool_size` | Specify the maximum pool size of the master schema's database connection. | `500` |
| `dbsetup.setupfile.db_min_pool_size` |  | `5` |
| `dbsetup.setupfile.db_aged_timeout` | Specify the maximum time after which the physical connection is discarded by pool maintenance of the master schema's database connection. | `"1440m"` |
| `dbsetup.setupfile.db_max_idle_time` | Specify the maximum idle time for the master schema's database connection | `"1440m"` |
| `dbsetup.setupfile.db_sslTrustStoreName` | specify the truststore name | `null` |
| `dbsetup.setupfile.db_sslTrustStoresecret` | Provide the secret name | `null` |
| `dbsetup.setupfile.db_sslTrustStorePassword` | Provide the password secret name | `null` |
| `dbsetup.setupfile.testmode_db_port` | Specify the database details for the test mode schema. These properties enable you to start the following docker containers: IBM PEM, Partner Provisioner, Migrator, Master key regenerator, and DBUtils. Specify the port | `null` |
| `dbsetup.setupfile.testmode_db_host` | Specify the database host | `null` |
| `dbsetup.setupfile.testmode_db_name` | Specify the Database Name | `null` |
| `dbsetup.setupfile.testmode_db_schema` | Specify the Database Schema | `null` |
| `dbsetup.setupfile.testmode_db_user` | Specify the databse user name | `null` |
| `dbsetup.setupfile.testmode_db_password` | Provide the secret name | `null` |
| `dbsetup.setupfile.testmode_db_driver` | Specify the database driver Name | `null` |
| `dbsetup.setupfile.testmode_db_max_pool_size` | Specify the maximum number of database pool connections. | `500` |
| `dbsetup.setupfile.testmode_db_min_pool_size` | Specify the minimum number of database pool connections. | `5` |
| `dbsetup.setupfile.testmode_db_aged_timeout` | Specify the interval in minutes before a physical connection is discarded. | `"1440m"` |
| `dbsetup.setupfile.testmode_db_max_idle_time` | Specify the interval in minutes after which an unused or idle connection is discarded. | `"1440m"` |
| `dbsetup.setupfile.testmode_db_sslTrustStoreName` | Specify the SSL Keystore  file name for the test mode database schema. | `null` |
| `dbsetup.setupfile.testmode_db_sslTrustStoresecret` | Specify the SSL Keystore secret for the test mode database schema. | `null` |
| `dbsetup.setupfile.testmode_db_sslTrustStorePassword` | Provide the secret name | `null` |
| `security.runAsUser` | specify the custom user to run the container | `1011` |
| `security.supplementalGroups` |  | `[555]` |
| `security.fsGroup` | specify the custom group to run the container | `1011` |
| `ssoSeas.enable` | set the property to true to enable ssl connection | `false` |
| `ssoSeas.truststoreName` | Specify the secret name for truststorefile | `null` |
| `ssoSeas.truststoreSecret` | Provide the secret name | `null` |
| `ssoSeas.truststorePassword` | specify the secret name for truststore password | `null` |
| `ssoSeas.truststoreAlias` | Specify the SEAS truststore alias | `null` |
| `ssoSeas.truststoreType` | Specify the SEAS truststore type. | `null` |
| `ssoSeas.keystoreName` | Specify the secret name for keystore file | `null` |
| `ssoSeas.keystoreSecret` | Provide the secret name | `null` |
| `ssoSeas.keystorePassword` | specify the secret name for keystore password | `null` |
| `ssoSeas.keystoretype` | Specify the SEAS keystore type. | `null` |
| `ssoSeas.keystoreAlias` | Specify the SEAS keystore alias | `null` |
| `ssomigration.enable` | if enabled resources volume must be enabled to generate data files | `false` |
| `ssomigration.migrationAction` | specify the action to be performed by the migrator EXPORT MIGRATE REPORT | `null` |
| `ssomigration.sponsorContext` | specify the sponsor which wanted to be migrated | `null` |
| `ssomigration.orgDataFilename` | specify the name of file to be genarated for sponsor for export or as a input file for migration | `null` |
| `ssomigration.userDataFilename` | specify the name of file to be genarated for users for export or as a input file for migration | `null` |
| `pem.enable` | set to true to install IBM PEM | `true` |
| `pem.replicas` | choose number of pods to be deployed | `1` |
| `pem.resources.requests.memory` | specify the memory request as needed | `"2Gi"` |
| `pem.resources.requests.cpu` | specify the cpu cores request as needed | `"250m"` |
| `pem.resources.limits.memory` | specify the maximimum memory a pod can utilize | `"4Gi"` |
| `pem.resources.limits.cpu` | specify the maximimum cpu a pod can utilize | `"500m"` |
| `pem.autoscaling.enabled` | set to true if autoscaling of pods to be allowed | `false` |
| `pem.autoscaling.minReplicas` | set the mimimun number of pods | `1` |
| `pem.autoscaling.maxReplicas` | set the maximum number of pods to be scaled up | `2` |
| `pem.autoscaling.targetCPUUtilizationPercentage` | set the limit of cpu utilization for autoscaling | `85` |
| `pem.readinessProbe.initialDelaySeconds` | set the initial delay to start readiness testing of pod in seconds | `10` |
| `pem.readinessProbe.periodSeconds` | set the time interval to perdorm readiness checks | `60` |
| `pem.livenessProbe.initialDelaySeconds` | set the initial delay to start liveness testing of pod in seconds | `60` |
| `pem.livenessProbe.timeoutSeconds` |  | `30` |
| `pem.livenessProbe.periodSeconds` | set the time interval to perdorm liveness checks | `60` |
| `pem.livenessProbe.successThreshold` |  | `1` |
| `pem.livenessProbe.failureThreshold` |  | `3` |
| `pem.hostname` | specify the route dns host to access IBM PEM if not set default hostname will be generated | `null` |
| `pem.setupfile.servers.jvm_options` | Specify the list of JVM options for the servers, and separated by space. | `"-Xms4g -Xmx4g"` |
| `pem.setupfile.servers.keystore_password` | Specify the secret name | `null` |
| `pem.setupfile.servers.keystore_alias` | Specify the secret alias | `null` |
| `pem.setupfile.servers.keystore_filename` | Specify the secret name and key inside secret has to be same as secret name | `null` |
| `pem.setupfile.servers.max_file_size` | Specify the maximum size for the server log file in MB. | `100` |
| `pem.setupfile.servers.max_files` | Specify the maximum number of server log files. The default value is 20. | `20` |
| `pem.setupfile.servers.console_log_level` | Specify the console log level. For example, "INFO". | `"INFO"` |
| `pem.setupfile.servers.trace_specification` | Specify the trace specification. The default value is "*: info". | `"*: info"` |
| `pp.enable` | set to true to install Partner Provisioner | `true` |
| `pp.replicas` | choose number of pods to be deployed | `1` |
| `pp.resources.requests.memory` | specify the memory request as needed | `"2Gi"` |
| `pp.resources.requests.cpu` | specify the cpu cores request as needed | `"250m"` |
| `pp.resources.limits.memory` | specify the maximimum memory a pod can utilize | `"4Gi"` |
| `pp.resources.limits.cpu` | specify the maximimum cpu a pod can utilize | `"500m"` |
| `pp.autoscaling.enabled` | set to true if autoscaling of pods to be allowed | `false` |
| `pp.autoscaling.minReplicas` | set the mimimun number of pods | `1` |
| `pp.autoscaling.maxReplicas` | set the maximum number of pods to be scaled up | `2` |
| `pp.autoscaling.targetCPUUtilizationPercentage` | set the limit of cpu utilization for autoscaling | `85` |
| `pp.readinessProbe.initialDelaySeconds` | set the initial delay to start readiness testing of pod in seconds | `10` |
| `pp.readinessProbe.periodSeconds` | set the time interval to perdorm readiness checks | `60` |
| `pp.livenessProbe.initialDelaySeconds` | set the initial delay to start liveness testing of pod in seconds | `60` |
| `pp.livenessProbe.timeoutSeconds` |  | `30` |
| `pp.livenessProbe.periodSeconds` | set the time interval to perdorm liveness checks | `60` |
| `pp.livenessProbe.successThreshold` |  | `1` |
| `pp.livenessProbe.failureThreshold` |  | `3` |
| `pp.hostname` | specify the route dns host to access Partner Provisioner if not set default hostname will be generated | `null` |
| `pp.setupfile.servers.jvm_options` | Specify the list of JVM options for the servers, and separated by space. | `"-Xms4g -Xmx4g"` |
| `pp.setupfile.servers.keystore_password` | Specify the secret name | `null` |
| `pp.setupfile.servers.keystore_alias` | Specify the secret alias | `null` |
| `pp.setupfile.servers.keystore_filename` | Specify the secret name and key inside secret has to be same as secret name | `null` |
| `pp.setupfile.servers.max_file_size` | Specify the maximum size for the server log file in MB. | `100` |
| `pp.setupfile.servers.max_files` | Specify the maximum number of server log files. The default value is 20. | `20` |
| `pp.setupfile.servers.console_log_level` | Specify the console log level. For example, "INFO". | `"INFO"` |
| `pp.setupfile.servers.trace_specification` | Specify the trace specification. The default value is "*: info". | `"*: info"` |
| `pp.setupfile.servers.enable_jms_features` |  | `"embdServerAndClientOnly"` |
| `pp.setupfile.servers.provisioner_request_queue` | Specify the request queue name, which is used for communication between PEM Partner Provisioner and PEM Partner Repository using embedded JMS. Ensure that the queue name is same for both the service components. | `"PEM_request"` |
| `pp.setupfile.servers.provisioner_response_queue` | Specify the response queue name, which is used for communication between PEM Partner Provisioner and PEM Partner Repository using embedded JMS. Ensure that the queue name is same for both the service components. | `"PEM_response"` |
| `pp.setupfile.servers.remote_server_ssl` | Specify true for SSL (BootstrapSecureMessaging) and false for non-SSL (BootstrapBasicMessaging). | `false` |
| `pp.setupfile.servers.remote_server_host` | service hostname of jms service releasename-pp-jms-service.namespace.domain.com | `null` |
| `pp.setupfile.servers.remote_server_port` |  | `80` |
| `pr.enable` | set to true to install Partner Repository | `true` |
| `pr.replicas` | choose number of pods to be deployed | `1` |
| `pr.resources.requests.memory` | specify the memory request as needed | `"2Gi"` |
| `pr.resources.requests.cpu` | specify the cpu cores request as needed | `"250m"` |
| `pr.resources.limits.memory` | specify the maximimum memory a pod can utilize | `"4Gi"` |
| `pr.resources.limits.cpu` | specify the maximimum cpu a pod can utilize | `"500m"` |
| `pr.autoscaling.enabled` | set to true if autoscaling of pods to be allowed | `false` |
| `pr.autoscaling.minReplicas` | set the mimimun number of pods | `1` |
| `pr.autoscaling.maxReplicas` | set the maximum number of pods to be scaled up | `2` |
| `pr.autoscaling.targetCPUUtilizationPercentage` | set the limit of cpu utilization for autoscaling | `85` |
| `pr.readinessProbe.initialDelaySeconds` | set the initial delay to start readiness testing of pod in seconds | `10` |
| `pr.readinessProbe.periodSeconds` | set the time interval to perdorm readiness checks | `60` |
| `pr.livenessProbe.initialDelaySeconds` | set the initial delay to start liveness testing of pod in seconds | `60` |
| `pr.livenessProbe.timeoutSeconds` |  | `30` |
| `pr.livenessProbe.periodSeconds` | set the time interval to perdorm liveness checks | `60` |
| `pr.livenessProbe.successThreshold` |  | `1` |
| `pr.livenessProbe.failureThreshold` |  | `3` |
| `pr.hostname` | specify the route dns host to access Partner Provisioner if not set default hostname will be generated | `null` |
| `pr.setupfile.servers.jvm_options` | Specify the list of JVM options for the servers, and separated by space. | `"-Xms4g -Xmx4g"` |
| `pr.setupfile.servers.keystore_password` | Specify the secret name | `null` |
| `pr.setupfile.servers.keystore_alias` | Specify the secret alias | `null` |
| `pr.setupfile.servers.keystore_filename` | Specify the secret name and key inside secret has to be same as secret name | `null` |
| `pr.setupfile.servers.max_file_size` | Specify the maximum size for the server log file in MB. | `100` |
| `pr.setupfile.servers.max_files` | Specify the maximum number of server log files. The default value is 20. | `20` |
| `pr.setupfile.servers.console_log_level` | Specify the console log level. For example, "INFO". | `"INFO"` |
| `pr.setupfile.servers.trace_specification` | Specify the trace specification. The default value is "*: info". | `"*: info"` |
| `pr.setupfile.servers.enable_jms_features` |  | `"embdClientOnly"` |
| `pr.setupfile.servers.provisioner_request_queue` | Specify the request queue name, which is used for communication between PEM Partner Provisioner and PEM Partner Repository using embedded JMS. Ensure that the queue name is same for both the service components. | `"PEM_request"` |
| `pr.setupfile.servers.provisioner_response_queue` | Specify the response queue name, which is used for communication between PEM Partner Provisioner and PEM Partner Repository using embedded JMS. Ensure that the queue name is same for both the service components. | `"PEM_response"` |
| `pr.setupfile.servers.remote_server_ssl` | Specify true for SSL (BootstrapSecureMessaging) and false for non-SSL (BootstrapBasicMessaging). | `false` |
| `pr.setupfile.servers.remote_server_host` | service hostname of jms service releasename-pp-jms-service.namespace.domain.com | `null` |
| `pr.setupfile.servers.remote_server_port` |  | `80` |
| `wmq.channel` | Specify the WebSphere MQ channel name | `null` |
| `wmq.connection_name_list` | Specify the WebSphere MQ connection list separated by comma. For example, 9.89.31.226 (19443), 9.77.53.126 (17286). This example is valid for a WebSphere MQ setup with HA (High Availability).For WMQ without HA, it can be a single <host_name or IP>:<port_number>. | `null` |
| `wmq.queue_manager` | Specify the WebSphere MQ queue manager. | `null` |
| `wmq.username` | Specify the WebSphere MQ user name. | `null` |
| `wmq.password` | Provide the secret name | `null` |
| `wmq.wmq_provisioner_request_queue_manager` | Specify the WebSphere MQ request queue manager. | `null` |
| `wmq.wmq_provisioner_response_queue_manager` | Specify the WebSphere MQ response queue manager. | `null` |
| `wmq.wmq_provisioner_request_queue_name` | Specify the WebSphere MQ request queue name. | `null` |
| `wmq.wmq_provisioner_response_queue_name` | Specify the WebSphere MQ response queue name. | `null` |
| `wmq.ssl_cipher_suite` | Specify a valid SSL cipher suite.If SSL is enabled on the WebSphere MQ connection channel, provide the SSL cipher suite corresponding to the SSL cipher specifications configured on the WebSphere MQ connection channel. | `null` |
| `purge.enable` |  | `false` |
| `purge.schedule` |  | `"0 9 * * 1"` |
| `purge.resources.requests.memory` | specify the memory request as needed | `"2Gi"` |
| `purge.resources.requests.cpu` | specify the cpu cores request as needed | `"250m"` |
| `purge.resources.limits.memory` | specify the maximimum memory a pod can utilize | `"4Gi"` |
| `purge.resources.limits.cpu` | specify the maximimum cpu a pod can utilize | `"500m"` |
| `purge.setupfile.purge.name` | 	Specify the purge tool name.This property prevents two users who specify the same purge name from purging the records simultaneously. This property is mandatory. So, ensure that the value is not blank. | `null` |
| `purge.setupfile.purge.number_of_purge_days` | Specify the number of retention days before the current date for which the records need to be purged. Only those records that qualify are purged. For example, if you specify 60 days, records that are present before 60 days from the current date and satisfy the purge criteria are purged. | `180` |
| `purge.setupfile.purge.purge_count` | Specify the number of records to be purged in a batch. IMPORTANT: Please do not modify this value. | `1` |
| `purge.setupfile.purge.sponsor_context` | Specify the Sponsor context or * where * takes all the sponsors in the system | `null` |
| `purge.setupfile.purge.no_of_db_connections` | Specify the maximum number of pooled connections allowed for the | `50` |
| `purge.setupfile.purge.resource_to_purge` | Default value for resource_to_purge is set to . For more information, refer to Configuring the properties of Setup.cfg | `"SPONSOR"` |
| `purge.setupfile.purge.resource_to_purge_key` | Specify the resource key for Sponsor / Sponsor user / Partner / Partner user / Third party processor / Third party processor user. | `null` |
| `purge.setupfile.purge.purge_strategy` | To enable purge, purge_strategy: "DELETE". This will only delete data from source database. To enable archive, purge_strategy: "ARCHIVE". This will delete data from source database and copies to target database. | `"ARCHIVE"` |
| `purge.setupfile.purge.target_db_is_same_as_source_db` |  | `false` |
| `purge.setupfile.purge.target_db_port` | Specify the database port | `null` |
| `purge.setupfile.purge.target_db_host` | Specify the database host | `null` |
| `purge.setupfile.purge.target_db_name` | Specify the database name | `null` |
| `purge.setupfile.purge.target_db_schema` | Specify the database schema | `null` |
| `purge.setupfile.purge.target_db_user` | Specify the database user | `null` |
| `purge.setupfile.purge.target_db_password` | Specify database secret | `null` |
| `purge.setupfile.purge.target_db_driver` | Specify the database driver | `null` |
| `purge.setupfile.purge.target_ssl_connection` | Enable or disable the SSL connection for purge target database schema. Valid values are true and false and the default value is set to false. | `false` |
| `purge.setupfile.purge.target_db_sslTrustStoreName` |  | `null` |
| `purge.setupfile.purge.target_db_sslTrustStoreSecret` |  | `null` |
| `purge.setupfile.purge.target_db_sslTrustStorePassword` | Provide the keystore name | `null` |
| `purge.setupfile.purge.target_db_type` | Specify the type of purge target database, either DB2 or Oracle. | `null` |
| `purge.setupfile.purge.jvm_options` | Specify the list of JVM options for purge separated by space. | `null` |
| `purge.setupfile.purge.java_util_logging_file_handler_level` | Specify the log level, either FINE, INFO, or SEVERE. | `"INFO"` |
| `purge.setupfile.purge.java_util_logging_file_handler_limit` | Specify the file size limit, in MB for each log file. | `null` |
| `purge.setupfile.purge.java_util_logging_file_handler_count` | Specify the number of log files. | `null` |
| `agent.replicas` |  | `1` |
| `agent.enable` |  | `false` |
| `agent.resources.requests.memory` |  | `"1Gi"` |
| `agent.resources.requests.cpu` |  | `"250m"` |
| `agent.resources.limits.memory` |  | `"2Gi"` |
| `agent.resources.limits.cpu` |  | `"500m"` |
| `agent.setupfile.agent.type` | Specify the type of agent, scanagent or certificateupdate. If you want to run both Scan Agent and certificate update, specify both the value separated by commas. For example, "scanagent,certificateupdate". | `null` |
| `agent.setupfile.agent.jvm_options` | Specify the list of JVM options for the scan agent separated by space. | `null` |
| `agent.setupfile.agent.antivirus_server_host` | Set the host or IP of the antivirus server. | `null` |
| `agent.setupfile.agent.antivirus_server_port` | Enter a port number of the antivirus server. | `null` |
| `agent.setupfile.agent.no_of_db_connections` | Specify the maximum number of pooled connections allowed to the database. | `50` |
| `agent.setupfile.agent.retry_interval_in_sec` | Specify the time interval between retries for connection failure with antivirus server. and accepts only numeric values. | `21600` |
| `agent.setupfile.agent.max_retry_count` | Specify the maximum number of times the agent must retry scanning a file, in case the scan fails for some reason. and accepts only numeric values. | `1460` |
| `agent.setupfile.agent.com_ibm_vch_identity_security_limit` | Specify the limit, in MB for each log file. | `100` |
| `agent.setupfile.agent.com_ibm_vch_identity_security_level` | Specify the log level, either FINE, INFO, or SEVERE. | `"INFO"` |
| `agent.setupfile.agent.com_ibm_vch_identity_security_count` | Specify the number of log file counts. | `20` |
| `agent.setupfile.agent.scan_extensibility_class` | Specify the class to enable antivirus extensibility. | `null` |
| `gateway.enable` | set to true to install Partner Repository | `true` |
| `gateway.replicas` | choose number of pods to be deployed | `1` |
| `gateway.resources.requests.memory` | specify the memory request as needed | `"2Gi"` |
| `gateway.resources.requests.cpu` | specify the cpu cores request as needed | `"250m"` |
| `gateway.resources.limits.memory` | specify the maximimum memory a pod can utilize | `"4Gi"` |
| `gateway.resources.limits.cpu` | specify the maximimum cpu a pod can utilize | `"500m"` |
| `gateway.readinessProbe.initialDelaySeconds` | set the initial delay to start readiness testing of pod in seconds | `10` |
| `gateway.readinessProbe.periodSeconds` | set the time interval to perdorm readiness checks | `60` |
| `gateway.livenessProbe.initialDelaySeconds` | set the initial delay to start liveness testing of pod in seconds | `60` |
| `gateway.livenessProbe.timeoutSeconds` |  | `30` |
| `gateway.livenessProbe.periodSeconds` | set the time interval to perdorm liveness checks | `60` |
| `gateway.livenessProbe.successThreshold` |  | `1` |
| `gateway.livenessProbe.failureThreshold` |  | `3` |
| `gateway.hostname` | specify the route dns host to access gateway IMPORTANT in order to enable api this property must be set | `null` |
| `gateway.setupfile.servers.jvm_options` | Specify the list of JVM options for the servers, and separated by space. For example, jvm_options: "-Xms4g -Xmx4g". | `null` |
| `gateway.setupfile.servers.keystore_password` | Specify the secret name | `null` |
| `gateway.setupfile.servers.keystore_alias` | Specify the secret alias | `null` |
| `gateway.setupfile.servers.keystore_filename` | Specify the secret name and key inside secret has to be same as secret name | `null` |
| `gateway.setupfile.servers.max_file_size` | Specify the maximum size for the server log file in MB. | `100` |
| `gateway.setupfile.servers.max_files` | Specify the maximum number of server log files. The default value is 20. | `20` |
| `gateway.setupfile.servers.console_log_level` | Specify the console log level. For example, "INFO". | `"INFO"` |
| `gateway.setupfile.servers.trace_specification` | Specify the trace specification. The default value is "*: info". | `"*: info"` |
| `gateway.setupfile.gateway.pem_servers` | This field is important to specify a list of PEM containers to which API calls are sent by the Gateway. If more than one container address is specified, then the Gateway load balances. | `null` |
| `gateway.setupfile.gateway.pr_servers` | This field is important to specify a list of PR containers to which API calls are sent by the Gateway. If more than one container address is specified, then the Gateway load balances. | `null` |
| `gateway.setupfile.gateway.max_file_size` | This value sets the limit to the size of the file that is uploaded via Gateway. | `null` |
| `gateway.setupfile.gateway.max_request_size` | This value sets the limit to the size of request that is uploaded via Gateway. | `null` |
| `gateway.setupfile.gateway.hostname_validation_required` | This flag is provided to enable/disable certificate hostname validation for API Gateway. | `true` |
| `communitymanager.install` |  | `true` |
| `communitymanager.image.repository` | Specify the repository | `"cp.icr.io/cp/ibm-pem/pem"` |
| `communitymanager.image.pullPolicy` | Specify te image pull policy | `null` |
| `communitymanager.image.tag` | Specify the tag name | `"6.2.0.2"` |
| `communitymanager.image.pullSecret` | Provide the pull secret name | `null` |
| `communitymanager.prod.enable` | If you are want to proceed for prod pcm installation then you have to mention it as true or else false | `true` |
| `communitymanager.prod.setupfile.acceptLicence` | We should make accept-license should be true for pcm installation | `true` |
| `communitymanager.prod.setupfile.cm.color` | This will enable the black theme in UI, PCM colores. red, green, grey, yellow, black | `"black"` |
| `communitymanager.prod.setupfile.cm.cmks` | Provide the password secret | `null` |
| `communitymanager.prod.setupfile.server.ssl.enabled` | Application will try to enable SSL if it is true | `false` |
| `communitymanager.prod.setupfile.server.ssl.key_store` | Application will try to load the key-store from this location if ssl enabled. | `"keystore.p12"` |
| `communitymanager.prod.setupfile.server.ssl.keystoresecret` | secret for keystore | `null` |
| `communitymanager.prod.setupfile.server.ssl.key_store_password` | keystorepass_secret | `null` |
| `communitymanager.prod.setupfile.server.ssl.key_store_type` | Here we need to provide keystore type | `"PKCS12"` |
| `communitymanager.prod.setupfile.server.serverHeader` | Default server header i,.e IBM Partner Engagement Manager Community Manager | `"IBM Partner Engagement Manager Community Manager"` |
| `communitymanager.prod.setupfile.server.compression.enabled` | Defualt is set to true  , Please don't change | `true` |
| `communitymanager.prod.setupfile.server.compression.min_response_size` | Default size is 1024 , Constant value please dont change | `1024` |
| `communitymanager.prod.setupfile.server.ajp.enabled` |  | `false` |
| `communitymanager.prod.setupfile.server.ajp.port` |  | `8585` |
| `communitymanager.prod.setupfile.spring.liquibase.enabled` | If you want to run Database script along with code deployment then make it as true or else false | `true` |
| `communitymanager.prod.setupfile.spring.liquibase.liquibase_tablespace` |  | `null` |
| `communitymanager.prod.setupfile.spring.datasource.type` | This should be constant, please dont change | `"com.zaxxer.hikari.HikariDataSource"` |
| `communitymanager.prod.setupfile.spring.datasource.url` | Specify the database url  example for jdbc:oracle:thin:@localhost:1521/XE | `"jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCPS)(HOST=DB_Host)(PORT=2484))(CONNECT_DATA=(SID=ORCL)))"` |
| `communitymanager.prod.setupfile.spring.datasource.username` | Specify the database user naem | `"Username"` |
| `communitymanager.prod.setupfile.spring.datasource.dbpassword` | secretName | `null` |
| `communitymanager.prod.setupfile.spring.datasource.driver_class_name` | Specify the dirver class name | `"oracle.jdbc.driver.OracleDriver"` |
| `communitymanager.prod.setupfile.spring.datasource.hikari.connection_timeout` | Connection timeout | `60000` |
| `communitymanager.prod.setupfile.spring.datasource.hikari.maximum_pool_size` | this actually depends on no of users access the application | `40` |
| `communitymanager.prod.setupfile.spring.datasource.hikari.auto_commit` |  | `false` |
| `communitymanager.prod.setupfile.spring.datasource.ssl.enabled` |  | `false` |
| `communitymanager.prod.setupfile.spring.datasource.ssl.trust_store` | truststore name | `null` |
| `communitymanager.prod.setupfile.spring.datasource.ssl.trustStoreSecret` | secret for keystore | `null` |
| `communitymanager.prod.setupfile.spring.datasource.ssl.trust_store_type` |  | `"PKCS12"` |
| `communitymanager.prod.setupfile.spring.datasource.ssl.trust_store_cmks` | truststore password secret | `null` |
| `communitymanager.prod.setupfile.spring.jpa.show_sql` | Default value is true | `true` |
| `communitymanager.prod.setupfile.spring.jpa.open_in_view` | Default value is true | `false` |
| `communitymanager.prod.setupfile.spring.jpa.database_platform` | Default value | `"com.pe.pcm.config.database.dialect.Oracle12cExtendedDialect"` |
| `communitymanager.prod.setupfile.spring.jpa.properties.id.new_generator_mappings` | Default value is true | `true` |
| `communitymanager.prod.setupfile.spring.jpa.hibernate.naming.physical_strategy` |  | `"com.pe.pcm.config.database.PhysicalNamingStrategy"` |
| `communitymanager.prod.setupfile.spring.mail.host` |  | `"smtp.hostname.com"` |
| `communitymanager.prod.setupfile.spring.mail.port` | 25 | `587` |
| `communitymanager.prod.setupfile.spring.mail.username` | Specify the username exmaple: username@compnay.com | `"UserName@company.com"` |
| `communitymanager.prod.setupfile.spring.mail.cmks` | Provde the password secret | `"Mailpassword"` |
| `communitymanager.prod.setupfile.spring.mail.from` |  | `"from_mailid@company.com"` |
| `communitymanager.prod.setupfile.spring.mail.app_contact_mail` |  | `"app_contact_mailid@company.com"` |
| `communitymanager.prod.setupfile.spring.mail.mail_signature` |  | `"Community Manager Portal support team."` |
| `communitymanager.prod.setupfile.spring.mail.properties.mail.smtp.auth` | If you want to send a mail with ssl authentication then make it as true or elase false | `true` |
| `communitymanager.prod.setupfile.spring.mail.properties.mail.smtp.starttls.enable` | If you want to send a mail with ssl authentication then make it as true or else false | `true` |
| `communitymanager.prod.setupfile.spring.mail.properties.mail.smtp.ssl.trust` |  | `"*"` |
| `communitymanager.prod.setupfile.spring.thymeleaf.cache` | this is constant, please dont change | `true` |
| `communitymanager.prod.setupfile.login.sm.enable` | If the customer has Siteminder login then make it as true or else false | `false` |
| `communitymanager.prod.setupfile.login.sm.param_name` | Provide the username | `"SM_USER"` |
| `communitymanager.prod.setupfile.login.max_false_attempts` | Maximum attempts | `5` |
| `communitymanager.prod.setupfile.login.reset_false_attempts` | Minutes | `3` |
| `communitymanager.prod.setupfile.login.user_cmks_expire` | days | `30` |
| `communitymanager.prod.setupfile.basic.auth.username` | Specifythe user name | `"pemuser"` |
| `communitymanager.prod.setupfile.basic.auth.cmks` | specify the secret | `null` |
| `communitymanager.prod.setupfile.jwt.secretkey` |  | `"CACE9E5A149ED201C4033C1A1E02C9BE"` |
| `communitymanager.prod.setupfile.jwt.session_expire` | Minutes (Token session Expiry) | `60` |
| `communitymanager.prod.setupfile.sterling_b2bi.core_bp.inbound` | CM_MailBox_GET_RoutingRule_Inbound , Inbound mailbox bootstrap business process | `"CM_MailBox_GET_RoutingRule_Inbound"` |
| `communitymanager.prod.setupfile.sterling_b2bi.core_bp.outbound` | CM_MailBox_GET_RoutingRule_Outbound , Outbound mailbox bootstrap business process | `"CM_MailBox_GET_RoutingRule_Outbound"` |
| `communitymanager.prod.setupfile.sterling_b2bi.user.cmks` | This passphrase will be used while creating profile in SI create a scret and with SI password. provide the secret | `null` |
| `communitymanager.prod.setupfile.sterling_b2bi.user.cmks_validation` | If you want to validate aboove passphrase when applicaton get starts then make this value as true or else false | `true` |
| `communitymanager.prod.setupfile.sterling_b2bi.user.cmks_validation_profile` | TestProfile, We have to provide the SFTP profile which is available in SI with password as Expl@re | `"CM_Profile"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.active` | This will say whether B2Bi API available or not | `true` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.auth_host.host1.name` | Sterling integrator authentication host name | `"[SEAS Authentication]"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.auth_host.host1.value` |  | `1` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.api.username` | user name to authenticate the API | `"cm_user"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.api.cmks` | Password secret | `null` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.api.baseUrl` |  | `null` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.b2bi_sfg_api.active` | If we say true then SFG Apis available along with B2Bi APIs | `true` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.b2bi_sfg_api.community_name` | SFG Community Name, which will be used while creating profile in SFG through APIs | `"CM_PEMCommunity"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.sfg_api.active` |  | `true` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.sfg_api.api.username` |  | `"cm_user"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.sfg_api.api.cmks` | ENC(KKtUwo6lrp1At7pa/fUn4g==) | `"password"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.sfg_api.api.baseUrl` |  | `null` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.as2.active` |  | `false` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.net_map_name` |  | `"prodCD"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.server_host` | Specify the server host | `null` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.server_port` |  | `1364` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.secure_plus_option` |  | `"ENABLED"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.ca_cert` |  | `"CA_cd_0099"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.system_certificate` |  | `"B2BHttp"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.security_protocol` |  | `"TLS 1.2"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.cipher_suites` |  | `"ECDHE_RSA_WITH_3DES_EDE_CBC_SHA"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.server_host` |  | `null` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.server_port` |  | `1364` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.secure_plus_option` |  | `"ENABLED"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.ca_cert` |  | `"CA_cd_0099"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.system_certificate` |  | `"B2BHttp"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.security_protocol` |  | `"TLS 1.2"` |
| `communitymanager.prod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.cipher_suites` |  | `"ECDHE_RSA_WITH_3DES_EDE_CBC_SHA"` |
| `communitymanager.prod.setupfile.ssp.active` | if we have SSP APIs enable then make it as true or else false | `true` |
| `communitymanager.prod.setupfile.ssp.api.username` | User name to authenticate the API | `"ssp_user"` |
| `communitymanager.prod.setupfile.ssp.api.cmks` | Password or Secret of the above user | `"SSP_Password"` |
| `communitymanager.prod.setupfile.ssp.api.baseUrl` | Provide  Base URL of the SSP API | `null` |
| `communitymanager.prod.setupfile.adapters.ftpServerAdapterName` | Specify the respective adapter name | `"CM_FTPServerAdapter"` |
| `communitymanager.prod.setupfile.adapters.ftpsClientAdapterName` | Specify the respective adapter name | `"FTP Client Adapter"` |
| `communitymanager.prod.setupfile.adapters.ftpClientAdapterName` | Specify the respective adapter name | `"CDServrAdapter"` |
| `communitymanager.prod.setupfile.adapters.ftpsServerAdapterName` | Specify the respective adapter name | `"CM_FTPS_ServerAdapter"` |
| `communitymanager.prod.setupfile.adapters.sftpServerAdapterName` | Specify the respective adapter name | `"CM_SFTPServerAdapter"` |
| `communitymanager.prod.setupfile.adapters.sftpClientAdapterName` | Specify the respective adapter name | `"CM_SFTPClientAdapter"` |
| `communitymanager.prod.setupfile.adapters.as2ServerAdapterName` | Specify the respective adapter name | `"CM_AS2ServerAdapter"` |
| `communitymanager.prod.setupfile.adapters.as2ClientAdapterName` | Specify the respective adapter name | `"CM_AS2ClientAdapter"` |
| `communitymanager.prod.setupfile.adapters.as2HttpClientAdapter` | Specify the respective adapter name | `"HTTPClientAdapter"` |
| `communitymanager.prod.setupfile.adapters.cdClientAdapterName` | Specify the respective adapter name | `"CM_CDClientAdapter"` |
| `communitymanager.prod.setupfile.adapters.httpServerAdapterName` | Specify the respective adapter name | `"CM_HTTPServerSync"` |
| `communitymanager.prod.setupfile.adapters.httpsServerAdapterName` | Specify the respective adapter name | `"CM_HTTPSServerSync"` |
| `communitymanager.prod.setupfile.adapters.mqAdapterName` | Specify the respective adapter name | `"CM_MQAdapter"` |
| `communitymanager.prod.setupfile.adapters.wsServerAdapterName` | Specify the respective adapter name | `"CM_HTTPSServerSync"` |
| `communitymanager.prod.setupfile.adapters.fsAdapter` | Specify the respective adapter name | `"CMFileSystem"` |
| `communitymanager.prod.setupfile.adapters.sfgSftpClientAdapterName` | Specify the respective adapter name | `"CM_SFTPClientAdapter"` |
| `communitymanager.prod.setupfile.adapters.sfgSftpServerAdapterName` | Specify the respective adapter name | `"CM_SFTPServerAdapter"` |
| `communitymanager.prod.setupfile.adapters.sfgFtpClientAdapterName` | Specify the respective adapter name | `"CM_FTPClientAdapter"` |
| `communitymanager.prod.setupfile.adapters.sfgFtpServerAdapterName` | Specify the respective adapter name | `"CM_FTPServerAdapter"` |
| `communitymanager.prod.setupfile.adapters.sfgFtpsClientAdapterName` | Specify the respective adapter name | `"CM_FTPSClientAdapter"` |
| `communitymanager.prod.setupfile.adapters.sfgFtpsServerAdapterName` | Specify the respective adapter name | `"CM_FTPS_ServerAdapter"` |
| `communitymanager.prod.setupfile.alerts.email.enable.create` | enable to receive creation alerts | `false` |
| `communitymanager.prod.setupfile.alerts.email.enable.update` | enable to receive update alerts | `false` |
| `communitymanager.prod.setupfile.alerts.email.enable.delete` | enable to receive delete alerts | `false` |
| `communitymanager.prod.setupfile.alerts.email.enable.reports` | enable to receive report alerts | `false` |
| `communitymanager.prod.setupfile.workFlow.duplicate.mft` | If you want to allow Duplicate MFT Transactions with in the flow then update true or else make it false. | `true` |
| `communitymanager.prod.setupfile.workFlow.duplicate.docHandling` | If you want to allow Duplicate DH Transactions with in the application then update true or else make it false. | `true` |
| `communitymanager.prod.setupfile.file_transfer.search.time_range` | Minutes | `30` |
| `communitymanager.prod.setupfile.saml.jwt.secret_key` | jwt token | `"yeWAgVDfb$!MFn@MCJVN7uqkznHbDLR#"` |
| `communitymanager.prod.setupfile.saml.jwt.session_expire` | Minutes | `60` |
| `communitymanager.prod.setupfile.saml.idp.metadata` | Provide the IDP metadata file location. | `null` |
| `communitymanager.prod.setupfile.saml.idp.entity_id` | .Provide the Entity name whic we provide in IDP | `"PcmEntityIdp"` |
| `communitymanager.prod.setupfile.saml.scheme` | Provide the PCM deployed protocol name. | `"https"` |
| `communitymanager.prod.setupfile.saml.host` | Provide the saml Application deployed host. | `null` |
| `communitymanager.prod.setupfile.saml.url.client` | Provide the Application Access URL | `null` |
| `communitymanager.prod.setupfile.saml.url.entity` | Provide the Application Access URL | `null` |
| `communitymanager.prod.setupfile.saml.ssl.key_store` | Absolute path of the JKS file | `null` |
| `communitymanager.prod.setupfile.saml.ssl.key_cmks` | specify the secret | `null` |
| `communitymanager.prod.setupfile.saml.ssl.store_cmks` | specify the secret | `null` |
| `communitymanager.prod.setupfile.saml.ssl.key_alias` | specify the alias name | `null` |
| `communitymanager.prod.setupfile.pem.remote.server.enabled` | enable to use pem key | `false` |
| `communitymanager.prod.setupfile.pem.remote.server.pem_key` | Provide the pemKey | `null` |
| `communitymanager.prod.setupfile.pem.remote.server.pemKeySecret` | secret for pemkey | `null` |
| `communitymanager.prod.setupfile.pem.remote.server.base_directory.path` | Provide the base directory path | `null` |
| `communitymanager.prod.setupfile.pem.remote.server.session_timeout` | Time in milliseconds | `5000` |
| `communitymanager.prod.setupfile.pem.datasource.url` | Datbase url example jdbc:oracle:thin:@DBHostname:1521/DBName | `"jdbc:oracle:thin:@DBHostname:1521/DBName"` |
| `communitymanager.prod.setupfile.pem.datasource.username` | Specify the database username | `"USERNAME"` |
| `communitymanager.prod.setupfile.pem.datasource.cmks` | Provide the sceret name | `null` |
| `communitymanager.prod.setupfile.pem.datasource.driver_class_name` | Provide db driver class name Ex: oracle.jdbc.driver.OracleDriver | `"oracle.jdbc.driver.OracleDriver"` |
| `communitymanager.prod.setupfile.pem.api_ws.active` |  | `true` |
| `communitymanager.prod.setupfile.pem.api_ws.base_url` | specify the url | `null` |
| `communitymanager.prod.setupfile.pem.api_ws.username` |  | `"PEMUsername"` |
| `communitymanager.prod.setupfile.pem.api_ws.cmks` | specify the secret name | `"PEMPassword"` |
| `communitymanager.prod.setupfile.file.archive.scheduler.cron` | "0 0 0 ? * * *" #At 00:00:00am every day, "* * * * * ? *" Every second | `"0 0 0 ? * * *"` |
| `communitymanager.prod.setupfile.file.archive.scheduler.delete_files_job.active` |  | `false` |
| `communitymanager.prod.setupfile.file.archive.scheduler.delete_files_job.script_file_loc` | Absolute path of Delete script file | `"/usr/CMArchiveDelete.sh"` |
| `communitymanager.prod.setupfile.file.archive.pgp.enabled` | enable to use pgp key | `false` |
| `communitymanager.prod.setupfile.file.archive.pgp.private_key` | provide the pgp key name | `null` |
| `communitymanager.prod.setupfile.file.archive.pgp.privateKeySecret` | specify the pgp secret | `null` |
| `communitymanager.prod.setupfile.file.archive.pgp.cmks` | PGP key passphrase secret | `null` |
| `communitymanager.prod.setupfile.file.archive.aes.secret_key` |  | `"3p+KB8sEYgX7R6Jh0MJRSQ=="` |
| `communitymanager.prod.setupfile.file.archive.aes.salt` |  | `"9XboGbY6CkAqYi6WB2tTiQ=="` |
| `communitymanager.prod.setupfile.ssomigration.enable` | enbale to start the migration | `false` |
| `communitymanager.prod.setupfile.ssomigration.data.action` | Actions:  EXPORT, MIGRATE, REPORT | `"EXPORT"` |
| `communitymanager.prod.setupfile.ssomigration.data.file_name` | File name which will be used in EXPORT, MIGRATE, and REORT Actions | `"pcm_user"` |
| `communitymanager.prod.setupfile.loggerLevel` | set the value to generate logs accepted values INFo , ERROR, DEBUG | `"INFO"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.enable` |  | `false` |
| `communitymanager.prod.setupfile.sso_ssp_seas.ssp.logout_endpoint` | SSP Logout endpoint ,default value is : /Signon/logout.html | `"/Signon/logout.html"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.ssp.user_header_name` | User header name config in SSP, default value is : SM_USER | `"SM_USER"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.ssp.token_cookie_name` | Token cookie name config in SSP, default value is : SSOTOKENS | `"SSOTOKEN"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.auth_profile` | Authentication Profile Name in SEAS | `"communityManager"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.host` | SEAS Host Name | `"SEAS_Host"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.port` | SEAS Port | `"SEAS_Port"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.enabled` | SSL enable or not in SEAS | `false` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.protocol` | SEAS Protocol (Optional) | `null` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.cipher_suits` | SEAS Cipher Suits (Optional) | `null` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.trust_store.name` | SEAS truststore file name | `"keystore.p12"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.trust_store.secretName` | secret for truststore | `null` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.trust_store.cmks` | truststore_Password secret #SEAS truststore password | `null` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.trust_store.alias` | SEAS truststore alias | `"seasssl_sso"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.trust_store.type` | SEAS truststore type | `"PKCS12"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.key_store.name` | SEAS keystore file name | `"keystore.p12"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.key_store.secretName` | secret for truststore | `null` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.key_store.cmks` | keystore_Password secret #SEAS keystore password. | `null` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.key_store.alias` | SEAS keystore alias | `"community_manager"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.seas.ssl.key_store.type` | SEAS keystore type | `"PKCS12"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user.email` | Email property name config in SEAS | `"email"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user.role` | Role property name config in SEAS | `"role"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user.first_name` | FirstName property name config in SEAS | `"firstName"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user.last_name` | LastName property name config in SEAS | `"lastName"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user.phone` | Phone property name config in SEAS | `"phone"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user.external_id` | FirstName property name config in SEAS | `"externalId"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user.preferred_language` | Language property name config in SEAS(Optional) | `"prefferedLanguage"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user_roles.super_admin` | specify the ldap role name for super_admin | `"superAdmin"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user_roles.admin` | specify the ldap role name for super_admin | `"admin"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user_roles.on_boarder` | specify the ldap role name for admin | `"creator"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user_roles.business_admin` | specify the ldap role name for on_boarder | `"bAdmin"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user_roles.business_user` | specify the ldap role name for business_user | `"bUser"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user_roles.data_processor` | specify the ldap role name for data_processor | `"processor"` |
| `communitymanager.prod.setupfile.sso_ssp_seas.user_request.user_roles.data_processor_restricted` | specify the ldap role name for data_processor_restricted | `"processorRes"` |
| `communitymanager.prod.replicacount` | specify the number of pods to be deployed | `1` |
| `communitymanager.prod.autoscaling.enabled` | set to true if autoscaling of pods to be allowed | `false` |
| `communitymanager.prod.autoscaling.minReplicas` | set the mimimun number of pods | `1` |
| `communitymanager.prod.autoscaling.maxReplicas` | set the maximum number of pods to be scaled up | `2` |
| `communitymanager.prod.autoscaling.targetCPUUtilizationPercentage` | set the limit of cpu utilization for autoscaling | `85` |
| `communitymanager.prod.resources.requests.memory` | specify the memory request as needed | `"2Gi"` |
| `communitymanager.prod.resources.requests.cpu` | specify the cpu cores request as needed | `"250m"` |
| `communitymanager.prod.resources.limits.memory` | specify the maximimum memory a pod can utilize | `"4Gi"` |
| `communitymanager.prod.resources.limits.cpu` | specify the maximimum cpu a pod can utilize | `"500m"` |
| `communitymanager.prod.readinessProbe.initialDelaySeconds` | set the initial delay to start readiness testing of pod in seconds | `10` |
| `communitymanager.prod.readinessProbe.periodSeconds` | set the time interval to perdorm readiness checks | `60` |
| `communitymanager.prod.livenessProbe.initialDelaySeconds` | set the initial delay to start liveness testing of pod in seconds | `60` |
| `communitymanager.prod.livenessProbe.timeoutSeconds` |  | `30` |
| `communitymanager.prod.livenessProbe.periodSeconds` | set the time interval to perdorm liveness checks | `60` |
| `communitymanager.prod.livenessProbe.successThreshold` |  | `1` |
| `communitymanager.prod.livenessProbe.failureThreshold` |  | `3` |
| `communitymanager.prod.hostname` | specify the route dns host to access Partner Provisioner if not set default hostname will be generated | `null` |
| `communitymanager.prod.archive.enable` | set to true to enable persistent volume for archive | `false` |
| `communitymanager.prod.archive.capacity` |  | `"100Mi"` |
| `communitymanager.prod.archive.storageclass` |  | `"slow"` |
| `communitymanager.nonprod.enable` | set to true to deploy non prod pcm | `false` |
| `communitymanager.nonprod.setupfile.acceptLicence` | We should make accept-license should be true for pcm installation | `true` |
| `communitymanager.nonprod.setupfile.cm.color` | This will enable the black theme in UI, PCM colores. red, green, grey, yellow, black | `"black"` |
| `communitymanager.nonprod.setupfile.cm.cmks` | Provide the password secret | `null` |
| `communitymanager.nonprod.setupfile.server.ssl.enabled` | Application will try to enable SSL if it is true | `false` |
| `communitymanager.nonprod.setupfile.server.ssl.key_store` | Application will try to load the key-store from this location if ssl enabled. | `"keystore.p12"` |
| `communitymanager.nonprod.setupfile.server.ssl.keystoresecret` | secret for keystore | `null` |
| `communitymanager.nonprod.setupfile.server.ssl.key_store_password` | keystorepass_secret | `null` |
| `communitymanager.nonprod.setupfile.server.ssl.key_store_type` | Here we need to provide keystore type | `"PKCS12"` |
| `communitymanager.nonprod.setupfile.server.serverHeader` | Default server header i,.e IBM Partner Engagement Manager Community Manager | `"IBM Partner Engagement Manager Community Manager"` |
| `communitymanager.nonprod.setupfile.server.compression.enabled` | Defualt is set to true  , Please don't change | `true` |
| `communitymanager.nonprod.setupfile.server.compression.min_response_size` | Default size is 1024 , Constant value please dont change | `1024` |
| `communitymanager.nonprod.setupfile.server.ajp.enabled` |  | `false` |
| `communitymanager.nonprod.setupfile.server.ajp.port` |  | `8585` |
| `communitymanager.nonprod.setupfile.spring.liquibase.enabled` | If you want to run Database script along with code deployment then make it as true or else false | `true` |
| `communitymanager.nonprod.setupfile.spring.liquibase.liquibase_tablespace` |  | `null` |
| `communitymanager.nonprod.setupfile.spring.datasource.type` | This should be constant, please dont change | `"com.zaxxer.hikari.HikariDataSource"` |
| `communitymanager.nonprod.setupfile.spring.datasource.url` | Specify the database url  example for jdbc:oracle:thin:@localhost:1521/XE | `"jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCPS)(HOST=DB_Host)(PORT=2484))(CONNECT_DATA=(SID=ORCL)))"` |
| `communitymanager.nonprod.setupfile.spring.datasource.username` | Specify the database user naem | `"Username"` |
| `communitymanager.nonprod.setupfile.spring.datasource.dbpassword` | secretName | `null` |
| `communitymanager.nonprod.setupfile.spring.datasource.driver_class_name` | Specify the dirver class name | `"oracle.jdbc.driver.OracleDriver"` |
| `communitymanager.nonprod.setupfile.spring.datasource.hikari.connection_timeout` | Connection timeout | `60000` |
| `communitymanager.nonprod.setupfile.spring.datasource.hikari.maximum_pool_size` | this actually depends on no of users access the application | `40` |
| `communitymanager.nonprod.setupfile.spring.datasource.hikari.auto_commit` |  | `false` |
| `communitymanager.nonprod.setupfile.spring.datasource.ssl.enabled` |  | `false` |
| `communitymanager.nonprod.setupfile.spring.datasource.ssl.trust_store` | truststore name | `null` |
| `communitymanager.nonprod.setupfile.spring.datasource.ssl.trustStoreSecret` | secret for keystore | `null` |
| `communitymanager.nonprod.setupfile.spring.datasource.ssl.trust_store_type` |  | `"PKCS12"` |
| `communitymanager.nonprod.setupfile.spring.datasource.ssl.trust_store_cmks` | truststore password secret | `null` |
| `communitymanager.nonprod.setupfile.spring.jpa.show_sql` | Default value is true | `true` |
| `communitymanager.nonprod.setupfile.spring.jpa.open_in_view` | Default value is true | `false` |
| `communitymanager.nonprod.setupfile.spring.jpa.database_platform` | Default value | `"com.pe.pcm.config.database.dialect.Oracle12cExtendedDialect"` |
| `communitymanager.nonprod.setupfile.spring.jpa.properties.id.new_generator_mappings` | Default value is true | `true` |
| `communitymanager.nonprod.setupfile.spring.jpa.hibernate.naming.physical_strategy` |  | `"com.pe.pcm.config.database.PhysicalNamingStrategy"` |
| `communitymanager.nonprod.setupfile.spring.mail.host` |  | `"smtp.hostname.com"` |
| `communitymanager.nonprod.setupfile.spring.mail.port` | 25 | `587` |
| `communitymanager.nonprod.setupfile.spring.mail.username` | Specify the username exmaple: username@compnay.com | `"UserName@company.com"` |
| `communitymanager.nonprod.setupfile.spring.mail.cmks` | Provde the password secret | `"Mailpassword"` |
| `communitymanager.nonprod.setupfile.spring.mail.from` |  | `"from_mailid@company.com"` |
| `communitymanager.nonprod.setupfile.spring.mail.app_contact_mail` |  | `"app_contact_mailid@company.com"` |
| `communitymanager.nonprod.setupfile.spring.mail.mail_signature` |  | `"Community Manager Portal support team."` |
| `communitymanager.nonprod.setupfile.spring.mail.properties.mail.smtp.auth` | If you want to send a mail with ssl authentication then make it as true or elase false | `true` |
| `communitymanager.nonprod.setupfile.spring.mail.properties.mail.smtp.starttls.enable` | If you want to send a mail with ssl authentication then make it as true or else false | `true` |
| `communitymanager.nonprod.setupfile.spring.mail.properties.mail.smtp.ssl.trust` |  | `"*"` |
| `communitymanager.nonprod.setupfile.spring.thymeleaf.cache` | this is constant, please dont change | `true` |
| `communitymanager.nonprod.setupfile.login.sm.enable` | If the customer has Siteminder login then make it as true or else false | `false` |
| `communitymanager.nonprod.setupfile.login.sm.param_name` | Provide the username | `"SM_USER"` |
| `communitymanager.nonprod.setupfile.login.max_false_attempts` | Maximum attempts | `5` |
| `communitymanager.nonprod.setupfile.login.reset_false_attempts` | Minutes | `3` |
| `communitymanager.nonprod.setupfile.login.user_cmks_expire` | days | `30` |
| `communitymanager.nonprod.setupfile.basic.auth.username` | Specifythe user name | `"pemuser"` |
| `communitymanager.nonprod.setupfile.basic.auth.cmks` | specify the secret | `null` |
| `communitymanager.nonprod.setupfile.jwt.secretkey` |  | `"CACE9E5A149ED201C4033C1A1E02C9BE"` |
| `communitymanager.nonprod.setupfile.jwt.session_expire` | Minutes (Token session Expiry) | `60` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.core_bp.inbound` | CM_MailBox_GET_RoutingRule_Inbound , Inbound mailbox bootstrap business process | `"CM_MailBox_GET_RoutingRule_Inbound"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.core_bp.outbound` | CM_MailBox_GET_RoutingRule_Outbound , Outbound mailbox bootstrap business process | `"CM_MailBox_GET_RoutingRule_Outbound"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.user.cmks` | This passphrase will be used while creating profile in SI create a scret and with SI password. provide the secret | `null` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.user.cmks_validation` | If you want to validate aboove passphrase when applicaton get starts then make this value as true or else false | `true` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.user.cmks_validation_profile` | TestProfile, We have to provide the SFTP profile which is available in SI with password as Expl@re | `"CM_Profile"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.active` | This will say whether B2Bi API available or not | `true` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.auth_host.host1.name` | Sterling integrator authentication host name | `"[SEAS Authentication]"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.auth_host.host1.value` |  | `1` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.api.username` | user name to authenticate the API | `"cm_user"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.api.cmks` | Password secret | `null` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.api.baseUrl` |  | `null` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.b2bi_sfg_api.active` | If we say true then SFG Apis available along with B2Bi APIs | `true` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.b2bi_sfg_api.community_name` | SFG Community Name, which will be used while creating profile in SFG through APIs | `"CM_PEMCommunity"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.sfg_api.active` |  | `true` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.sfg_api.api.username` |  | `"cm_user"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.sfg_api.api.cmks` | ENC(KKtUwo6lrp1At7pa/fUn4g==) | `"password"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.sfg_api.api.baseUrl` |  | `null` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.as2.active` |  | `false` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.net_map_name` |  | `"prodCD"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.server_host` | Specify the server host | `null` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.server_port` |  | `1364` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.secure_plus_option` |  | `"ENABLED"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.ca_cert` |  | `"CA_cd_0099"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.system_certificate` |  | `"B2BHttp"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.security_protocol` |  | `"TLS 1.2"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.internal.cipher_suites` |  | `"ECDHE_RSA_WITH_3DES_EDE_CBC_SHA"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.server_host` |  | `null` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.server_port` |  | `1364` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.secure_plus_option` |  | `"ENABLED"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.ca_cert` |  | `"CA_cd_0099"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.system_certificate` |  | `"B2BHttp"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.security_protocol` |  | `"TLS 1.2"` |
| `communitymanager.nonprod.setupfile.sterling_b2bi.b2bi_api.cd.proxy.external.cipher_suites` |  | `"ECDHE_RSA_WITH_3DES_EDE_CBC_SHA"` |
| `communitymanager.nonprod.setupfile.ssp.active` | if we have SSP APIs enable then make it as true or else false | `true` |
| `communitymanager.nonprod.setupfile.ssp.api.username` | User name to authenticate the API | `"ssp_user"` |
| `communitymanager.nonprod.setupfile.ssp.api.cmks` | Password or Secret of the above user | `"SSP_Password"` |
| `communitymanager.nonprod.setupfile.ssp.api.baseUrl` | Provide  Base URL of the SSP API | `null` |
| `communitymanager.nonprod.setupfile.adapters.ftpServerAdapterName` | Specify the respective adapter name | `"CM_FTPServerAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.ftpsClientAdapterName` | Specify the respective adapter name | `"FTP Client Adapter"` |
| `communitymanager.nonprod.setupfile.adapters.ftpClientAdapterName` | Specify the respective adapter name | `"CDServrAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.ftpsServerAdapterName` | Specify the respective adapter name | `"CM_FTPS_ServerAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.sftpServerAdapterName` | Specify the respective adapter name | `"CM_SFTPServerAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.sftpClientAdapterName` | Specify the respective adapter name | `"CM_SFTPClientAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.as2ServerAdapterName` | Specify the respective adapter name | `"CM_AS2ServerAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.as2ClientAdapterName` | Specify the respective adapter name | `"CM_AS2ClientAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.as2HttpClientAdapter` | Specify the respective adapter name | `"HTTPClientAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.cdClientAdapterName` | Specify the respective adapter name | `"CM_CDClientAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.httpServerAdapterName` | Specify the respective adapter name | `"CM_HTTPServerSync"` |
| `communitymanager.nonprod.setupfile.adapters.httpsServerAdapterName` | Specify the respective adapter name | `"CM_HTTPSServerSync"` |
| `communitymanager.nonprod.setupfile.adapters.mqAdapterName` | Specify the respective adapter name | `"CM_MQAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.wsServerAdapterName` | Specify the respective adapter name | `"CM_HTTPSServerSync"` |
| `communitymanager.nonprod.setupfile.adapters.fsAdapter` | Specify the respective adapter name | `"CMFileSystem"` |
| `communitymanager.nonprod.setupfile.adapters.sfgSftpClientAdapterName` | Specify the respective adapter name | `"CM_SFTPClientAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.sfgSftpServerAdapterName` | Specify the respective adapter name | `"CM_SFTPServerAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.sfgFtpClientAdapterName` | Specify the respective adapter name | `"CM_FTPClientAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.sfgFtpServerAdapterName` | Specify the respective adapter name | `"CM_FTPServerAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.sfgFtpsClientAdapterName` | Specify the respective adapter name | `"CM_FTPSClientAdapter"` |
| `communitymanager.nonprod.setupfile.adapters.sfgFtpsServerAdapterName` | Specify the respective adapter name | `"CM_FTPS_ServerAdapter"` |
| `communitymanager.nonprod.setupfile.alerts.email.enable.create` | enable to receive creation alerts | `false` |
| `communitymanager.nonprod.setupfile.alerts.email.enable.update` | enable to receive update alerts | `false` |
| `communitymanager.nonprod.setupfile.alerts.email.enable.delete` | enable to receive delete alerts | `false` |
| `communitymanager.nonprod.setupfile.alerts.email.enable.reports` | enable to receive report alerts | `false` |
| `communitymanager.nonprod.setupfile.workFlow.duplicate.mft` | If you want to allow Duplicate MFT Transactions with in the flow then update true or else make it false. | `true` |
| `communitymanager.nonprod.setupfile.workFlow.duplicate.docHandling` | If you want to allow Duplicate DH Transactions with in the application then update true or else make it false. | `true` |
| `communitymanager.nonprod.setupfile.file_transfer.search.time_range` | Minutes | `30` |
| `communitymanager.nonprod.setupfile.saml.jwt.secret_key` | jwt token | `"yeWAgVDfb$!MFn@MCJVN7uqkznHbDLR#"` |
| `communitymanager.nonprod.setupfile.saml.jwt.session_expire` | Minutes | `60` |
| `communitymanager.nonprod.setupfile.saml.idp.metadata` | Provide the IDP metadata file location. | `null` |
| `communitymanager.nonprod.setupfile.saml.idp.entity_id` | .Provide the Entity name whic we provide in IDP | `"PcmEntityIdp"` |
| `communitymanager.nonprod.setupfile.saml.scheme` | Provide the PCM deployed protocol name. | `"https"` |
| `communitymanager.nonprod.setupfile.saml.host` | Provide the saml Application deployed host. | `null` |
| `communitymanager.nonprod.setupfile.saml.url.client` | Provide the Application Access URL | `null` |
| `communitymanager.nonprod.setupfile.saml.url.entity` | Provide the Application Access URL | `null` |
| `communitymanager.nonprod.setupfile.saml.ssl.key_store` | Absolute path of the JKS file | `null` |
| `communitymanager.nonprod.setupfile.saml.ssl.key_cmks` | specify the secret | `null` |
| `communitymanager.nonprod.setupfile.saml.ssl.store_cmks` | specify the secret | `null` |
| `communitymanager.nonprod.setupfile.saml.ssl.key_alias` | specify the alias name | `null` |
| `communitymanager.nonprod.setupfile.pem.remote.server.enabled` | enable to use pem key | `false` |
| `communitymanager.nonprod.setupfile.pem.remote.server.pem_key` | Provide the pemKey | `null` |
| `communitymanager.nonprod.setupfile.pem.remote.server.pemKeySecret` | secret for pemkey | `null` |
| `communitymanager.nonprod.setupfile.pem.remote.server.base_directory.path` | Provide the base directory path | `null` |
| `communitymanager.nonprod.setupfile.pem.remote.server.session_timeout` | Time in milliseconds | `5000` |
| `communitymanager.nonprod.setupfile.pem.datasource.url` | Datbase url example jdbc:oracle:thin:@DBHostname:1521/DBName | `"jdbc:oracle:thin:@DBHostname:1521/DBName"` |
| `communitymanager.nonprod.setupfile.pem.datasource.username` | Specify the database username | `"USERNAME"` |
| `communitymanager.nonprod.setupfile.pem.datasource.cmks` | Provide the sceret name | `null` |
| `communitymanager.nonprod.setupfile.pem.datasource.driver_class_name` | Provide db driver class name Ex: oracle.jdbc.driver.OracleDriver | `"oracle.jdbc.driver.OracleDriver"` |
| `communitymanager.nonprod.setupfile.pem.api_ws.active` |  | `true` |
| `communitymanager.nonprod.setupfile.pem.api_ws.base_url` | specify the url | `null` |
| `communitymanager.nonprod.setupfile.pem.api_ws.username` |  | `"PEMUsername"` |
| `communitymanager.nonprod.setupfile.pem.api_ws.cmks` | specify the secret name | `"PEMPassword"` |
| `communitymanager.nonprod.setupfile.file.archive.scheduler.cron` | "0 0 0 ? * * *" #At 00:00:00am every day, "* * * * * ? *" Every second | `"0 0 0 ? * * *"` |
| `communitymanager.nonprod.setupfile.file.archive.scheduler.delete_files_job.active` |  | `false` |
| `communitymanager.nonprod.setupfile.file.archive.scheduler.delete_files_job.script_file_loc` | Absolute path of Delete script file | `"/usr/CMArchiveDelete.sh"` |
| `communitymanager.nonprod.setupfile.file.archive.pgp.enabled` | enable to use pgp key | `false` |
| `communitymanager.nonprod.setupfile.file.archive.pgp.private_key` | provide the pgp key name | `null` |
| `communitymanager.nonprod.setupfile.file.archive.pgp.privateKeySecret` | specify the pgp secret | `null` |
| `communitymanager.nonprod.setupfile.file.archive.pgp.cmks` | PGP key passphrase secret | `null` |
| `communitymanager.nonprod.setupfile.file.archive.aes.secret_key` |  | `"3p+KB8sEYgX7R6Jh0MJRSQ=="` |
| `communitymanager.nonprod.setupfile.file.archive.aes.salt` |  | `"9XboGbY6CkAqYi6WB2tTiQ=="` |
| `communitymanager.nonprod.setupfile.ssomigration.enable` | enbale to start the migration | `false` |
| `communitymanager.nonprod.setupfile.ssomigration.data.action` | Actions:  EXPORT, MIGRATE, REPORT | `"EXPORT"` |
| `communitymanager.nonprod.setupfile.ssomigration.data.file_name` | File name which will be used in EXPORT, MIGRATE, and REORT Actions | `"pcm_user"` |
| `communitymanager.nonprod.setupfile.loggerLevel` | set the value to generate logs accepted values INFo , ERROR, DEBUG | `"INFO"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.enable` |  | `false` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.ssp.logout_endpoint` | SSP Logout endpoint ,default value is : /Signon/logout.html | `"/Signon/logout.html"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.ssp.user_header_name` | User header name config in SSP, default value is : SM_USER | `"SM_USER"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.ssp.token_cookie_name` | Token cookie name config in SSP, default value is : SSOTOKENS | `"SSOTOKEN"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.auth_profile` | Authentication Profile Name in SEAS | `"communityManager"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.host` | SEAS Host Name | `"SEAS_Host"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.port` | SEAS Port | `"SEAS_Port"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.enabled` | SSL enable or not in SEAS | `false` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.protocol` | SEAS Protocol (Optional) | `null` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.cipher_suits` | SEAS Cipher Suits (Optional) | `null` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.trust_store.name` | SEAS truststore file name | `"keystore.p12"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.trust_store.secretName` | secret for truststore | `null` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.trust_store.cmks` | truststore_Password secret #SEAS truststore password | `null` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.trust_store.alias` | SEAS truststore alias | `"seasssl_sso"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.trust_store.type` | SEAS truststore type | `"PKCS12"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.key_store.name` | SEAS keystore file name | `"keystore.p12"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.key_store.secretName` | secret for truststore | `null` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.key_store.cmks` | keystore_Password secret #SEAS keystore password. | `null` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.key_store.alias` | SEAS keystore alias | `"community_manager"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.seas.ssl.key_store.type` | SEAS keystore type | `"PKCS12"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user.email` | Email property name config in SEAS | `"email"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user.role` | Role property name config in SEAS | `"role"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user.first_name` | FirstName property name config in SEAS | `"firstName"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user.last_name` | LastName property name config in SEAS | `"lastName"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user.phone` | Phone property name config in SEAS | `"phone"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user.external_id` | FirstName property name config in SEAS | `"externalId"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user.preferred_language` | Language property name config in SEAS(Optional) | `"prefferedLanguage"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user_roles.super_admin` | specify the ldap role name for super_admin | `"superAdmin"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user_roles.admin` | specify the ldap role name for super_admin | `"admin"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user_roles.on_boarder` | specify the ldap role name for admin | `"creator"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user_roles.business_admin` | specify the ldap role name for on_boarder | `"bAdmin"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user_roles.business_user` | specify the ldap role name for business_user | `"bUser"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user_roles.data_processor` | specify the ldap role name for data_processor | `"processor"` |
| `communitymanager.nonprod.setupfile.sso_ssp_seas.user_request.user_roles.data_processor_restricted` | specify the ldap role name for data_processor_restricted | `"processorRes"` |
| `communitymanager.nonprod.replicacount` | specify the number of pods to be deployed | `1` |
| `communitymanager.nonprod.autoscaling.enabled` | set to true if autoscaling of pods to be allowed | `false` |
| `communitymanager.nonprod.autoscaling.minReplicas` | set the mimimun number of pods | `1` |
| `communitymanager.nonprod.autoscaling.maxReplicas` | set the maximum number of pods to be scaled up | `2` |
| `communitymanager.nonprod.autoscaling.targetCPUUtilizationPercentage` | set the limit of cpu utilization for autoscaling | `85` |
| `communitymanager.nonprod.resources.requests.memory` | specify the memory request as needed | `"2Gi"` |
| `communitymanager.nonprod.resources.requests.cpu` | specify the cpu cores request as needed | `"250m"` |
| `communitymanager.nonprod.resources.limits.memory` | specify the maximimum memory a pod can utilize | `"4Gi"` |
| `communitymanager.nonprod.resources.limits.cpu` | specify the maximimum cpu a pod can utilize | `"500m"` |
| `communitymanager.nonprod.readinessProbe.initialDelaySeconds` | set the initial delay to start readiness testing of pod in seconds | `10` |
| `communitymanager.nonprod.readinessProbe.periodSeconds` | set the time interval to perdorm readiness checks | `60` |
| `communitymanager.nonprod.livenessProbe.initialDelaySeconds` | set the initial delay to start liveness testing of pod in seconds | `60` |
| `communitymanager.nonprod.livenessProbe.timeoutSeconds` |  | `30` |
| `communitymanager.nonprod.livenessProbe.periodSeconds` | set the time interval to perdorm liveness checks | `60` |
| `communitymanager.nonprod.livenessProbe.successThreshold` |  | `1` |
| `communitymanager.nonprod.livenessProbe.failureThreshold` |  | `3` |
| `communitymanager.nonprod.hostname` | specify the route dns host to access Partner Provisioner if not set default hostname will be generated | `null` |
| `communitymanager.nonprod.archive.enable` | set to true to enable persistent volume for archive | `false` |
| `communitymanager.nonprod.archive.capacity` |  | `"100Mi"` |
| `communitymanager.nonprod.archive.storageclass` |  | `"slow"` |

To install the chart with the release name `my-release`:
1. Ensure that the chart is downloaded locally and available.

2. Run the below command
```sh
$ helm install my-release -f values.yaml ./ibm-pem-standard --timeout 3600s  --namespace <namespace>
```

Depending on the capacity of the openshift worker node and database network connectivity, chart deployment can take on average
* 2-3 minutes for 'installation against a pre-loaded database' and
* 10-20 minutes for 'installation against a fresh new or older release upgrade'
## Upgrading the Chart

You would want to upgrade your deployment when you have a new docker image or helm chart verison or a change in configuration, for e.g. new service ports to be exposed.

1. Ensure that the chart is downloaded locally and available.

2. Before upgrading the release for any configurations change, set the `dataSetup.type` as `upgrade`

3. Run the following command to upgrade your deployments.

```sh
helm upgrade my-release -f values.yaml ./ibm-pem-standard --timeout 3600s
```

4. Run the following command to upgrade your deployments

```
helm upgrade my-release -f values.yaml ./ibm-pem-standard --timeout 3600s --recreate-pods
```
For product release version upgrade, please refer product documentation.


## Post install/upgrade patching the routes (Configure SSL for OpenShift Route)
This chart supports re-encrypt routes and requires the destination CA certificate to be configured in the route.

After installing/upgrading, you must patch the routes manually for PEM, PR, PP, and API Gateway server with the CA certified TLS certificate. The routePatch.sh script allows you to patch all the routes created through the helm install with the certificate information based on the <Release_name>. 

To patch the routes, download the ibm_cloud_pak/pak_extensions/post-install/routePatch.sh script file, update the file with the following values and run the script:
* RELEASE_NAME= #Provide the release name
* PEM_DEST_CABUNDLE_FN= #Provide the Destination CA certificate name with path for PEM server
* PR_DEST_CABUNDLE_FN= #Provide the Destination CA certificate name with path for PR server
* PP_DEST_CABUNDLE_FN= #Provide the Destination CA certificate name with path for PP server
* AG_DEST_CABUNDLE_FN= #Provide the Destination CA certificate name with path for API Gateway server

The routePatch.sh file and all destination CA certificates must have the 755 permission to read and execute the script for patching the routes.

## Rollback the Chart
If the upgraded environment is not working as expected or you made an error while upgrading, you can easily rollback the chart to a previous revision.
Procedure
To rollback a chart with release name <my-release> to a previous revision invoke the following command:


```sh
helm rollback my-release <previous revision number>
```

To get the revision number execute the following command:

```sh
helm history my-release
```
Note : If the revision isn't specified then by default rolls back to the last revision.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment run the command:


```sh
 helm delete my-release  --purge
```
Since there are certain kubernetes resources created using the `pre-install` hook, helm delete command will try to delete them as a post delete activity. In case it fails to do so, you need to manually delete the following resources created by the chart:
* ConfigMap - <release name>-Migrator-Setupfile
* ConfigMap - <release name>-Dbutils-Setupfile
* PersistentVolumeClaim if persistence is enabled - <release name>-resources-pvc  only if resources pv are enabled
* PersistentVolumeClaim if persistence is enabled - <release name>-logs-pvc #enable logs for migrator and dbutils

Note: You may also consider deleting the secrets and peristent volumes created as part of prerequisites, after creating their backups.
