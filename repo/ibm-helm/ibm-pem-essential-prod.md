# IBM Partner Engagement Manager
## Introduction

## Chart Details

This chart deploys IBM Partner Engagement Manager Essential cluster on a container management platform with the following resources.

## Prerequisites

1. Kubernetes version >=1.31 and <=1.34

2. Red Hat OpenShift Container Platform Version 4.18, 4.19, 4.20 and 4.21 or later fixes

3. Helm version >= 3.19.x

4. Ensure that one of the supported database server (Oracle/DB2/MSSQL) is installed and the database is accessible from inside the cluster.

5. Ensure that the docker images for IBM Partner Engagement Manager Essential from Entitlement registry are loaded to an appropriate docker registry.

6. When `volumeClaims.resources.enabled` is `true`, create a persistent volume for application resources with access mode as 'ReadWriteMany' and place the database driver jar, SEAS jars and MQ jars in the mapped volume location.

7. When `volumeClaims.logs.enable` is `true`, create a persistent volume for application logs with access mode as 'Read Write Many' and create required subfolders for PEM Portal, PEM2.0, Partner Repository, Partner Provisioner. The subfolders must have the 755 permission to read and execute, to be accessible by the pemuser (id:1011) container.

8. Create secrets with requisite confidential credentials for passphrase.txt, Keystore.jks dbpasswords and keystore passwords. You can use the supplied configuration files under pak_extensions/pre-install/secret directory.

9. Create a secret from the provided syntax file included in helm charts /ibm-cloudpak-extensons/preinstall/secrets.yaml

    ```
      oc apply -f app-secrets.yaml
      ```

10. Create a secret to pull the image from a private registry or repository using following command:
    ```
    oc create secret docker-registry <name of secret> --docker-server=<your-registry-server> --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>
       ```

11. Create Secrets with SSL Certificates (Keystore / Truststore) for IBM Partner Engagement Manager

To enable SSL/TLS connectivity (Database, MQ, Ingress, etc.), generate certificates and create the required OpenShift secrets.

---

Step 1: Generate Self-Signed Certificate

```bash
openssl req -x509 -nodes -sha256 \
  -subj "/CN=<cluster-or-domain>" \
  -days 730 \
  -newkey rsa:2048 \
  -keyout tls.key \
  -out tlsocp.crt 
```

**Example:**

```bash
-addext "subjectAltName=DNS:newpemurl.apps.myocp.example.com"
```

---

Step 2: Extract Router CA Certificate

```bash
oc extract secret/router-ca --keys=tls.crt -n openshift-ingress-operator
```

This certificate will be imported into the truststore.

---

Step 3: Create PKCS12 Keystore

```bash
openssl pkcs12 -export \
  -name ocpconsole \
  -in tlsocp.crt \
  -inkey tls.key \
  -out togakeystore.p12 \
  -password pass:<password> \
  -noiter -nomaciter
```

---

Step 4: Convert PKCS12 → JKS

```bash
keytool -importkeystore \
  -srckeystore togakeystore.p12 \
  -srcstoretype pkcs12 \
  -destkeystore togakeystore.jks \
  -alias ocpconsole
```

---

Step 5: Import Router CA into Truststore

```bash
keytool -importcert \
  -keystore togakeystore.jks \
  -storepass <password> \
  -alias router-ca \
  -file tls.crt \
  -noprompt
```

---

Step 6: Create OpenShift Secrets

> **Important:**  
> For server keystore secrets, the **secret name and keystore filename must match**.

---

Create Keystore Secret

```bash
oc create secret generic togakeystore.jks \
  --from-file=togakeystore.jks=togakeystore.jks
```

---

Create Truststore Secret(s)

```bash
oc create secret generic togatruststore.jks \
  --from-file=togakeystore.jks=togakeystore.jks
```

**Optional (if additional truststore secret required):**

```bash
oc create secret generic togatruststoretest.jks \
  --from-file=togakeystore.jks
```

---

Create TLS Secret (Ingress / Route Usage)

```bash
oc create secret tls pem-tls-secret \
  --cert=tlsocp.crt \
  --key=tls.key
```

---

## Notes

- The keystore/truststore password must match the application configuration.
- `subjectAltName (SAN)` must include the route hostname.
- Secret names must align with Helm values / deployment YAML.
- Use separate keystore/truststore files if required by your security policy.

12. Create configmap with localtime file present in local machine using below command
    ```
     oc create configmap <configmap-name> --from-file=/etc/localtime
	   ```

13. When installing the chart on a new database which does not have IBM PEM Essential Software schema tables and metadata,
* ensure that `dbsetup.upgrade` parameter is set to `false` and `dbsetup.enabled` parameter is set to `true`. This will create the required database tables and metadata in the database before installing the chart.

14. When installing the chart on a database with new image upgrade,
* ensure that `dbsetup.upgrade` parameter is set to `true`.

15. Create service account and apply security context contraints to created service account.

    ```
     oc create sa <service account name>
	   ```

    ```
     oc adm policy add-scc-to-user ibm-pem-scc system:serviceaccount:<namespace>:<service account name>
	   ```
    Note: Avoid installing multiple charts on same namespace

16. Create a Role and RoleBinding to grant the service account the required permissions for managing resources during chart installation and runtime.

    Create Role:
    ```
    kind: Role
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: <role name>
      namespace: <namespace>
    rules:
      - apiGroups: ['route.openshift.io']
        resources: ['routes','routes/custom-host']
        verbs: ['get', 'watch', 'list', 'patch', 'update']
      - apiGroups: ['','batch']
        resources: ['secrets','configmaps','persistentvolumes','persistentvolumeclaims','pods','services','cronjobs','jobs']
        verbs: ['get', 'list', 'delete', 'create', 'update', 'patch']
      - apiGroups: ['apps']
        resources: ['deployments']
        verbs: ['get', 'list', 'patch', 'update']
    ```

    Create RoleBinding:
    ```
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: <rolebinding name>
      namespace: <namespace>
    subjects:
      - kind: ServiceAccount
        name: <service account name>
        namespace: <namespace>
    roleRef:
      kind: Role
      name: <role name>
      apiGroup: rbac.authorization.k8s.io
    ```

    Apply the Role and RoleBinding:
    ```
    oc apply -f role.yaml
    oc apply -f rolebinding.yaml
    ```

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)

This chart optionally defines a custom PodSecurityPolicy which is used to finely control the permissions/capabilities needed to deploy this chart. It is based on the predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/ibm-anyuid-psp.yaml) with extra required privileges. You can enable this policy by using the Platform User Interface or configuration file available under pak_extensions/pre-install/ directory
- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
Note: For kubernetes version 1.25 or higher apiVersion for the PodSecurityPolicy should be policy/v1
  - Custom PodSecurityPolicy definition:

    ```
    apiVersion: policy/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: "ibm-pem-psp"
      labels:
        app: "ibm-pem-psp"

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
      name: "ibm-pem-psp"
      labels:
        app: "ibm-pem-psp"
    rules:
    - apiGroups:
      - policy
      resourceNames:
      - "ibm-pem-psp"
      resources:
      - podsecuritypolicies
      verbs:
      - use
  - apiGroups:
      - ""
      resources:
      - secrets
      verbs:
      - get
      - list
      - patch
      - update
  - apiGroups:
      - apps
      resources:
      - deployments
      verbs:
      - get
      - list
      - patch
      - update
    ```
- Create a rolebinding for the above role and the service account:
    ```
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: <rolebinding name>
      namespace: <namespace>
    subjects:
      - kind: ServiceAccount
        name: <service account>
        namespace: <namespace>
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: ibm-pem-psp
    ```

### SecurityContextConstraints Requirements

* Predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc)

This chart optionally defines a custom SecurityContextConstraints (on Red Hat OpenShift Container Platform) which is used to finely control the permissions/capabilities needed to deploy this chart.  It is based on the predefined SecurityContextConstraint name: [`ibm-restricted-scc`](https://github.com/IBM/cloud-pak/blob/master/spec/security/scc/ibm-restricted-scc.yaml) with extra required privileges.

  - Custom SecurityContextConstraints definition:

    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-pem-scc
      labels:
       app: "ibm-pem-scc"
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
     name: "ibm-pem-scc"
     labels:
      app: "ibm-pem-scc"
	rules:
	- apiGroups:
  	  - security.openshift.io
  	  resourceNames:
      - "ibm-pem-scc"
      resources:
      - securitycontextconstraints
      verbs:
      - use
  - apiGroups:
      - ""
      resources:
      - secrets
      verbs:
      - get
      - list
      - patch
      - update
  - apiGroups:
      - apps
      resources:
      - deployments
      verbs:
      - get
      - list
      - patch
      - update
    ```
- Create a rolebinding for the above role and the service account:
    ```
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: <rolebinding name>
      namespace: <namespace>
    subjects:
      - kind: ServiceAccount
        name: <service account>
        namespace: <namespace>
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: ibm-pem-scc
    ```

## Resources Required
## Configuration
### The following table lists the configurable parameters for the chart

Pod                                       | Memory Requested  | Memory Limit | CPU Requested | CPU Limit
------------------------------------------| ------------------|--------------| --------------|----------
PEM Portal pod                            |       4 Gi        |     8 Gi     |      1        |    2
PEM2.0 Portal pod                         |       4 Gi        |     8 Gi     |      1        |    2
PP pod                                    |       2 Gi        |     4 Gi     |      1        |    2
PR pod                                    |       2 Gi        |     4 Gi     |      1        |    2
API Gateway pod                           |       2 Gi        |     4 Gi     |      1        |    2
Agent pod                                 |       2 Gi        |     4 Gi     |      1        |    2
Purge (API) pod                           |       0.5 Gi      |     1 Gi     |      0.1      |    0.5


## Installing the Chart
Prepare a custom values.yaml file based on the configuration section which will be present in chart_Directory/values.yaml.

## Configuration
The following table lists the configurable parameters of the Ibm-pem-essential chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `image.name` | Provide the value in double quotes | `"cp.icr.io/cp/ibm-pem/pem"` |
| `image.tag` | Specify the tag name | `"6.3.0.0"` |
| `image.pullPolicy` |  | `null` |
| `image.pullSecret` | Provide the pull secret name | `""` |
| `arch` | Specify architecture (amd64, s390x) | `"amd64"` |
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
| `volumeClaims.logs.capacity` |  | `"1Gi"` |
| `volumeClaims.logs.storageclass` |  | `null` |
| `volumeClaims.logs.accessModes` |  | `["ReadWriteMany"]` |
| `test.image.repository` |  | `"cp.icr.io/cp"` |
| `test.image.name` |  | `"opencontent-common-utils"` |
| `test.image.tag` |  | `"1.1.70"` |
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
| `dbsetup.setupfile.testmode_db_port` | Specify the database details for the test mode schema. These properties enable you to start the following docker containers: PEM Portal, Partner Provisioner, Migrator, Master key regenerator, and DBUtils. Specify the port | `null` |
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
| `pem.enable` | set to true to install PEM Portal | `true` |
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
| `pem.hostname` | specify the route dns host to access PEM Portal if not set default hostname will be generated | `null` |
| `pem.setupfile.servers.jvm_options` | Specify the list of JVM options for the servers, and separated by space. | `"-Xms4g -Xmx4g"` |
| `pem.setupfile.servers.keystore_password` | Specify the secret name | `null` |
| `pem.setupfile.servers.keystore_alias` | Specify the secret alias | `null` |
| `pem.setupfile.servers.keystore_filename` | Specify the secret name and key inside secret has to be same as secret name | `null` |
| `pem.setupfile.servers.max_file_size` | Specify the maximum size for the server log file in MB. | `100` |
| `pem.setupfile.servers.max_files` | Specify the maximum number of server log files. The default value is 20. | `20` |
| `pem.setupfile.servers.console_log_level` | Specify the console log level. For example, "INFO". | `"INFO"` |
| `pem.setupfile.servers.trace_specification` | Specify the trace specification. The default value is "*: info". | `"*: info"` |
| `pem.setupfile.cors.enabled` | Enable or disable CORS support for the PEM server. | `true` |
| `pem.setupfile.cors.allowedOrigins` | Specify the allowed CORS origins as a comma-separated list.  | `""` |
| `pem2.enable` | set to true to install PEM2.0 Portal | `true` |
| `pem2.replicas` | choose number of pods to be deployed | `1` |
| `pem2.resources.requests.memory` | specify the memory request as needed | `"2Gi"` |
| `pem2.resources.requests.cpu` | specify the cpu cores request as needed | `"250m"` |
| `pem2.resources.limits.memory` | specify the maximimum memory a pod can utilize | `"4Gi"` |
| `pem2.resources.limits.cpu` | specify the maximimum cpu a pod can utilize | `"500m"` |
| `pem2.autoscaling.enabled` | set to true if autoscaling of pods to be allowed | `false` |
| `pem2.autoscaling.minReplicas` | set the mimimun number of pods | `1` |
| `pem2.autoscaling.maxReplicas` | set the maximum number of pods to be scaled up | `2` |
| `pem2.autoscaling.targetCPUUtilizationPercentage` | set the limit of cpu utilization for autoscaling | `85` |
| `pem2.readinessProbe.initialDelaySeconds` | set the initial delay to start readiness testing of pod in seconds | `10` |
| `pem2.readinessProbe.periodSeconds` | set the time interval to perdorm readiness checks | `60` |
| `pem2.livenessProbe.initialDelaySeconds` | set the initial delay to start liveness testing of pod in seconds | `60` |
| `pem2.livenessProbe.timeoutSeconds` |  | `30` |
| `pem2.livenessProbe.periodSeconds` | set the time interval to perdorm liveness checks | `60` |
| `pem2.livenessProbe.successThreshold` |  | `1` |
| `pem2.livenessProbe.failureThreshold` |  | `3` |
| `pem2.service.type` | Specify the Kubernetes Service type (ClusterIP, NodePort, or LoadBalancer) | `ClusterIP` |
| `pem2.service.externalPort` | Specify the external Service port used to access the PEM2 application | `443` |
| `pem2.service.nodePort` | Specify the NodePort value when the Service type is set to NodePort | `null` |
| `pem2.service.externalIP` | Specify an external IP address to expose the PEM2 Service | `null` |
| `pem2.service.loadBalancerIP` | Specify a static IP address when the Service type is LoadBalancer | `null` |
| `pem2.service.annotations` | Specify additional annotations to be added to the PEM2 Service | `{}` |
| `pem2.hostname` | specify the route dns host to access PEM2.0 Portal if not set default hostname will be generated | `null` |
| `pem2.setupfile.servers.jvm_options` | Specify the list of JVM options for the servers, and separated by space. | `"-Xms4g -Xmx4g"` |
| `pem2.setupfile.servers.keystore_password` | Specify the secret name | `null` |
| `pem2.setupfile.servers.keystore_alias` | Specify the secret alias | `null` |
| `pem2.setupfile.servers.keystore_filename` | Specify the secret name and key inside secret has to be same as secret name | `null` |
| `pem2.setupfile.servers.max_file_size` | Specify the maximum size for the server log file in MB. | `100` |
| `pem2.setupfile.servers.max_files` | Specify the maximum number of server log files. The default value is 20. | `20` |
| `pem2.setupfile.servers.console_log_level` | Specify the console log level. For example, "INFO". | `"INFO"` |
| `pem2.setupfile.servers.trace_specification` | Specify the trace specification. The default value is "*: info". | `"*: info"` |
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
`identityService.enabled`                               | Enable integration with Identity Service                             |false  
`identityService.license`                               | Accept Identity/PEM license                                          |false
`identityService.replicaCount`                          | Identity Service deployment replica count            | 1
`identityService.image.repository`                      | Repository for Identity docker images                                     |
`identityService.image.tag          `                   | Docker image tag                                                     | `1.0.1.0`
`identityService.image.digest          `                | Docker image digest. Takes precedence over tag                       |
`identityService.image.pullPolicy`                      | Pull policy for repository                                      | `IfNotPresent`
`identityService.image.pullSecret `                     | Pull secret for repository access                              |
`identityService.serviceAccount.name`                          | Existing service account name                                        | `default`
`identityService.ingress.host`                          | Ingress host name for the Identity server  		|
`identityService.application.server.ssl.enabled`        |  Enabling SSL on the identity service                          | true
`identityService.application.server.ssl.tlsSecretName`  | TLS secret name which contains certificate            | 
`identityService.application.clientSecret`              | Client Secret             |  "identity-client-secret"
`identityService.application.dbVendor`                  | Database vendor |DB2/Oracle/MSSQL                                    | 
`identityService.application.dbHost`                    | Database host                                                        | 
`identityService.application.dbPort`                    | Database port                                                        | 
`identityService.application.dbData`                    | Database schema name                                                 | 
`identityService.application.dbDrivers`                 | Database driver jar name                                             | 
`identityService.application.dbSecret`                  | Database user secret name                                            | 
`identityService.resourcesInit.enabled`                 | Enable initialization of resources for Identity Service. Not supported in PEM; keep as false. | `false`


To install the chart with the release name `my-release`:
1. Ensure that the chart is downloaded locally and available.

2. Run the below command:
```sh
$ helm install my-release -f values.yaml ./ibm-pem-essential --timeout 3600s  --namespace <namespace>
```

Depending on the capacity of the OpenShift worker node and database network connectivity, chart deployment can take on average
* 2-3 minutes for 'installation against a pre-loaded database' and
* 10-20 minutes for 'installation against a new release or an older release upgrade'

## Limitations
Installation of IBM PEM on OpenShift Container Platform does not allow same Java KeyStore (JKS) file names to be used in the values.yaml file for the following properties:
* db_sslTrustStoreName
* testmode_db_sslTrustStoreName
* keystore_filename.

## Upgrading the Chart
You would want to upgrade your deployment when you have a new docker image or helm chart verison or a change in configuration, such as, new service ports to be exposed.

1. Ensure that the chart is downloaded locally and available.

2. Before upgrading the release for any configuration change, set the `dataSetup.upgrade` as `true`.

3. Run the following command to upgrade your deployments:
```sh
helm upgrade my-release -f values.yaml ./ibm-pem-essential --timeout 3600s
```

4. Run the following command to upgrade your deployments:
```
helm upgrade my-release -f values.yaml ./ibm-pem-essential --timeout 3600s --recreate-pods
```
For product release version upgrade, refer to the product documentation.
Pre-install SSL configuration (Create TLS Secret for OpenShift Routes)
This chart supports secure HTTPS routes.  
To enable SSL/TLS, you must create a TLS secret **before installing or upgrading** the Helm chart.

The TLS secret will be referenced in `values.yaml`.

---

### Prerequisites

Ensure you have:

- TLS certificate file: `tlsocp.crt`
- Private key file: `tls.key`

> The certificate must include valid **subjectAltName (SAN)** entries for the OpenShift route hostname.

---

### Steps to configure SSL

1. Create the TLS secret

```bash
oc create secret tls pem-tls-secret \
  --cert=tlsocp.crt \
  --key=tls.key
```

---

2. Verify the secret

```bash
oc get secret pem-tls-secret
```

---

3. Reference the TLS secret in `values.yaml`

```yaml
ingress:
  tls:
    secretName: pem-tls-secret
```

---

## Notes

- The TLS secret **must exist before Helm install/upgrade**.
- The secret **must be created in the same namespace** as PEM.
- If the secret name changes, update `values.yaml` accordingly.
- Incorrect SAN configuration may cause route/certificate validation errors.
- No manual route patching is required when TLS secrets are configured correctly.

## Rollback the Chart
If the upgraded environment is not working as expected or you made an error while upgrading, you can easily rollback the chart to a previous revision.

To rollback a chart with release name <my-release> to a previous revision, invoke the following command:
```sh
helm rollback my-release <previous revision number>
```

To get the revision number, execute the following command:
```sh
helm history my-release
```
Note : If the revision isn't specified, then by default it rolls back to the last revision.

## Uninstalling the Chart
To uninstall/delete the `my-release` deployment run the command:
```sh
 helm delete my-release  --purge
```
Since there are certain kubernetes resources created using the `pre-install` hook, helm delete command will try to delete them as a post delete activity. In case it fails to do so, you need to manually delete the following resources created by the chart:
* ConfigMap - <release-name>-Migrator-Setupfile
* ConfigMap - <release-name>-Dbutils-Setupfile
* PersistentVolumeClaim if persistence is enabled - <release-name>-resources-pvc  only if resources pv are enabled
* PersistentVolumeClaim if persistence is enabled - <release-name>-logs-pvc #enable logs for migrator and dbutils

Note: You may also consider deleting the secrets and peristent volumes created as part of prerequisites, after creating their backups.

## Changing the system passphrase (Master key regenerator)
This chart supports changing the system passphrase by regenerating the master key and updating it in the database. When the pod starts, it compares the old passphrase secret value with the system passphrase that is present in the database. If both the system passphrase match, the tool replaces the passphrase present in the database with the new passphrase secret value.
Once the passphrase is updated in the database, it patches the passphrase secret with the new passphrase secret value and restarts PEM, PR and PP pods if they were running.

1. Create a role for secret and deployment:
    ```
    kind: Role
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: <role name>
      namespace: <namespace>
    rules:
      - verbs: ['get', 'list', 'patch', 'update']
        apiGroups: ['','batch']
        resources: ['secrets']
      - verbs: ['get', 'list', 'patch', 'update']
        apiGroups: ['apps']
        resources: ['deployments']
    ```

2. Create a rolebinding for the above role and the service account:
    ```
    kind: RoleBinding
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      name: <rolebinding name>
      namespace: <namespace>
    subjects:
      - kind: ServiceAccount
        name: <service account>
        namespace: <namespace>
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: <role name>
    ```

3. Create secret for old and new passphrase.
Note: The secret created during helm install contains the keys for old and new passphrase. Update the old and new passphrase values for the corresponding secret key.

4. Configure the following values.yaml properties for master key regenerator
    - Values.license
    - Values.volumeClaims.resources.subpath.dbdrivers
    - Values.dbsetup.setupfile.proxy_host
    - Values.dbsetup.setupfile.proxy_port
    - Values.dbsetup.setupfile.customer_id
    - Values.dbsetup.setupfile.db_type
    - Values.dbsetup.setupfile.ssl_connection
    - Values.dbsetup.setupfile.db_port
    - Values.dbsetup.setupfile.db_host
    - Values.dbsetup.setupfile.db_name
    - Values.dbsetup.setupfile.db_schema
    - Values.dbsetup.setupfile.db_user
    - Values.dbsetup.setupfile.db_password
    - Values.dbsetup.setupfile.db_driver
    - Values.dbsetup.setupfile.db_max_pool_size
    - Values.dbsetup.setupfile.db_min_pool_size
    - Values.dbsetup.setupfile.db_aged_timeout
    - Values.dbsetup.setupfile.db_max_idle_time
    - Values.dbsetup.setupfile.db_sslTrustStoreName
    - Values.dbsetup.setupfile.db_sslTrustStorePassword
    - Values.dbsetup.setupfile.testmode_db_port
    - Values.dbsetup.setupfile.testmode_db_host
    - Values.dbsetup.setupfile.testmode_db_name
    - Values.dbsetup.setupfile.testmode_db_schema
    - Values.dbsetup.setupfile.testmode_db_user
    - Values.dbsetup.setupfile.testmode_db_password
    - Values.dbsetup.setupfile.testmode_db_driver
    - Values.dbsetup.setupfile.testmode_db_max_pool_size
    - Values.dbsetup.setupfile.testmode_db_min_pool_size
    - Values.dbsetup.setupfile.testmode_db_aged_timeout
    - Values.dbsetup.setupfile.testmode_db_max_idle_time
    - Values.dbsetup.setupfile.testmode_db_sslTrustStoreName
    - Values.dbsetup.setupfile.testmode_db_sslTrustStorePassword
    - Values.masterKeyRegenerator.enable
    - Values.masterKeyRegenerator.passphraseOldSecret
    - Values.masterKeyRegenerator.passphraseNewSecret

5. Run the following command to run the master key regenerator:
```
helm upgrade my-release -f values.yaml ./ibm-pem-essential --timeout 3600s
```
