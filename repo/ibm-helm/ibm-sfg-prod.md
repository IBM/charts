# IBM Sterling File Gateway Enterprise Edition v6.1.0.2
## Introduction

IBM Sterling File Gateway lets organizations transfer files between partners by using different protocols, conventions for naming files, and file formats. A scalable and security-enabled gateway, Sterling File Gateway enables companies to consolidate all their internet-based file transfers on a single edge gateway, which helps secure your B2B collaboration network and the data flowing through it. To find out more, see [IBM Sterling File Gateway](https://www.ibm.com/products/file-gateway) on IBM Marketplace.

## Chart Details

This chart deploys IBM Sterling File Gateway cluster on a container management platform with the following resources
Deployments
* Application Server Independent (ASI) server with 1 replica by default
* Adapter Container (AC) server with 1 replica by default
* Liberty API server with 1 replica by default
Services
* ASI service - This service is used to access ASI servers using a consistent IP address
* AC service - This service is used to access AC servers using a consistent IP address
* Liberty API service - This service is used to access API servers using a consistent IP address


## Prerequisites

1. Kubernetes version >= 1.14.6 with beta APIs enabled

2. Helm version >= 3.2

3. Ensure that one of the supported database server (Oracle/DB2/MSSQL) is installed and the database is accessible from inside the cluster. 

4. Ensure that the docker images for IBM Sterling File Gateway Software Enterprise Edition from Passport Advantage are loaded to an appropriate docker registry.

5. In case required by an adapter service or Adapter Container server, ensure that a supported MQ Server version (IBM MQ or ActiveMQ Server) is installed and accessible from inside the cluster.

6. When `appResourcesPVC.enabled` is `true`, create a persistent volume for application resources with access mode as 'Read Only Many' and place the database driver jar, JCE policy file, Key store and trust store files in case of SSL connection to database or MQ server in the mapped volume location.

7. When `logs.enableAppLogOnConsole` is `false`, create a persistent volume for application logs with access mode as 'Read Write Many'.

8. When `appDocumentsPVC.enabled` is `true`, create a persistent volume for application document storage with access mode as 'Read Write Many'.

9. Create secrets with requisite confidential credentials for system passphrase, database, MQ server and Liberty. You can use the supplied configuration files under pak_extensions/pre-install/secret directory. 

10. Create a secret to pull the image from a private registry or repository using following command
    ```
    kubectl create secret docker-registry <name of secret> --docker-server=<your-registry-server> --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>
    ```

11. If applicable, create secrets with confidential certificates required by Database, MQ or Liberty for SSL connectivity using below command
    ```
	kubectl create secret generic <secret-name> --from-file=/path/to/<certificate>
	```

12. When installing the chart on a new database which does not have IBM Sterling B2B Integrator Software schema tables and metadata, 
* ensure that `dataSetup.enable` parameter is set to `true` and `dataSetup.upgrade` parameter is set as `false`. This will create the required database tables and metadata in the database before installing the chart.

13. When installing the chart on a database on an older release version
* ensure that `dataSetup.enable` parameter is set to `true`,`dataSetup.upgrade` parameter is set as `true` and `env.upgradeCompatibilityVerified` is set as `true`. This will upgrade the given database tables and metadata to the latest version.

14. Automatically installing ibm-licensing-operator with a stand-alone IBM Containerized Software using Operator Lifecycle Manager (OLM) 
Use the automatic script to install License Service on any Kubernetes-orchestrated cloud. The script creates an instance and validates the steps. It was tested to work on OpenShift Container Platform 4.2+, vanilla Kubernetes custer, 
and is available at:
 - pre-install/license/ibm_licensing_operator_install.sh
 Post-installation steps: 
 - https://github.com/IBM/ibm-licensing-operator/blob/master/README.md#post-installation-steps

### Installation against a pre-loaded database
When installing the chart against a database which already has the Sterling B2B Integrator Software tables and factory meta data ensure that `datasetup.enable` parameter is set to `false`. This will avoid re-creating tables and overwriting factory data.



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
        rule: MustRunAsNonRoot
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

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

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
      type: MustRunAsNonRoot
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

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

## Network Policy

  * Kubernetes Network Policy is a specification of how groups of pods are allowed to communicate with each other and other network endpoints.

  * The Kubernetes Network Policy resource provides firewall capabilities to pods, similar to AWS Security groups, and it programs the software defined networking infrastructure (OpenShift Default, Flannel, etc...). You can implement sophisticated network access policies to control ingress access to your workload pods.

  * The default Network Policy <Release-name>-network-policy is provided that allows all ingress traffic. For e.g.

   ```  
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-ingress
spec:
  podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
   ```
  * To implement your own Network Policy, you can follow the steps documented here [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies)

## Resources Required

The following table describes the default usage and limits per pod

Pod                                       | Memory Requested  | Memory Limit | CPU Requested | CPU Limit
------------------------------------------| ------------------|--------------| --------------|----------
Application Server Independent (ASI) pod  |       4 Gi        |     8 Gi     |      2        |    4
Adapter Container (AC) pod                |       4 Gi        |     8 Gi     |      2        |    4
Liberty API server (API) pod              |       2 Gi        |     4 Gi     |      2        |    4
External Purge (API) pod                  |       0.5 Gi      |     1 Gi     |      0.1      |    0.5

## Installing the Chart

Prepare a custom values.yaml file based on the configuration section.

To install the chart with the release name `my-release`:
1. Ensure that the chart is downloaded locally and available.

2. Run the below command
```sh
$ helm install my-release -f values.yaml ./ibm-sfg-prod --timeout 3600s  --namespace <namespace>
```

Depending on the capacity of the kubernetes worker node and database network connectivity, chart deployment can take on average 
* 2-3 minutes for 'installation against a pre-loaded database' and 
* 20-30 minutes for 'installation against a fresh new or older release upgrade'

## Configuration

### The following table lists the configurable parameters for the chart


Parameter                                      | Description                                                          | Default 
-----------------------------------------------| ---------------------------------------------------------------------| -------------
`global.image.repository`                      | Repository for B2B docker images                                     | 
`global.image.tag          `                   | Docker image tag                                                     | `6.1.0.2`
`global.image.pullPolicy`                      | Pull policy for repository                                           | `IfNotPresent`
`global.image.pullSecret `         			   | Pull secret for repository access                                    | 
`arch`                                         | Compatible platform architecture                                     | `x86_64`
`serviceAccount.create`                        | Create custom defined service account                                | false
`serviceAccount.name`                          | Existing service account name                                        | `default`
`persistence.enabled`                          | Enable storage access to persistent volumes                          | true
`persistence.useDynamicProvisioning`           | Enable dynamic provisioning of persistent volumes                    | false 
`appResourcesPVC.enabled`                      | Enable Application resource storage                                  | true 
`appResourcesPVC.name`                         | Application resources persistent volume claim name                   | `resources`
`appResourcesPVC.storageClassName`             | Resources persistent volume storage class name                       | ``
`appResourcesPVC.selector.label`               | Resources persistent volume selector label                           | `intent`
`appResourcesPVC.selector.value`               | Resources persistent volume selector value                           | `resources`
`appResourcesPVC.accessMode`                   | Resources persistent volume access mode                              | `ReadOnlyMany`
`appResourcesPVC.size`                         | Resources persistent volume storage size                             | 100 Mi
`appLogsPVC.name`                              | Application logs persistent volume claim name                        | `logs`
`appLogsPVC.storageClassName`                  | Logs persistent volume storage class name                            | ``
`appLogsPVC.selector.label`                    | Logs persistent volume selector label                                | `intent`
`appLogsPVC.selector.value`                    | Logs persistent volume selector value                                | `logs`
`appLogsPVC.accessMode`                        | Logs persistent volume access mode                                   | `ReadWriteMany`
`appLogsPVC.size`                              | Logs persistent volume storage size                                  | 500 Mi
`appDocumentsPVC.enabled`                      | Enable Application document storage                                  | false
`appDocumentsPVC.name`                         | Application document storage persistent volume claim name            | `documents`
`appDocumentsPVC.storageClassName`             | Documents persistent volume storage class name                       | ``
`appDocumentsPVC.selector.label`               | Documents persistent volume selector label                           | `intent`
`appDocumentsPVC.selector.value`               | Documents persistent volume selector value                           | `documents`
`appDocumentsPVC.accessMode`                   | Documents persistent volume access mode                              | `ReadWriteMany`
`appDocumentsPVC.size`                         | Documents persistent volume storage size                             | 1Gi
`extraPVCs`                                    | Extra volume claims shared across all deployments                    |
`security.supplementalGroups`                  | Supplemental group id to access the persistent volume                | 5555
`security.fsGroup`                             | File system group id to access the persistent volume                 | 1010
`security.runAsUser`                           | The User ID that needs to be run as by all containers                | 1010
`ingress.enabled`                              | Enable ingress resource                                              | false
`ingress.controller`                           | Ingress controller class                                             | nginx
`ingress.annotations`                          | Additional annotations for the ingress resource                      |
`ingress.port`                                 | Ingress or router port if not 80 or 443                              |
`dataSetup.enabled`                            | Enable database setup job execution                                  | true
`dataSetup.upgrade`                            | Upgrade an older release                                             | false  
`env.tz`                                       | Timezone for application runtime                                     | `UTC`
`env.license`                                  | view or accept license                                               | `accept`
`env.upgradeCompatibilityVerified`             | Indicate release upgrade compatibility verification done             | `false`
`logs.enableAppLogOnConsole`                   | Enable application logs redirection to pod console                   | `true` 
`integrations.seasIntegration.isEnabled`       | Enable Seas integration. For more information, please refer to the product documentation           | false
`integrations.seasIntegration.seasVersion`     | Seas version                                                         | `1.0`
`setupCfg.basePort`                            | Base/initial port for the application                                | 50000
`setupCfg.licenseAcceptEnableSfg`              | Consent for accepting license for Sterling File Gateway module       | false
`setupCfg.licenseAcceptEnableEbics`            | Consent for accepting license for EBICs module                       | false
`setupCfg.licenseAcceptEnableFinancialServices`| Consent for accepting license for EBICs client module                | false
`setupCfg.licenseAcceptEnableFileOperation`    | Consent for accepting license to enable File Operation               | false
`setupCfg.systemPassphraseSecret`              | System passphrase secret name                                        | 
`setupCfg.enableFipsMode`                      | Enable FIPS mode                                                     | false
`setupCfg.nistComplianceMode`                  | NIST 800-131a compliance mode                                        | `off`
`setupCfg.dbVendor`                            | Database vendor - DB2/Oracle/MSSQL                                   | 
`setupCfg.dbHost`                              | Database host                                                        | 
`setupCfg.dbPort`                              | Database port                                                        | 
`setupCfg.dbUser`                              | Database user                                                        | 
`setupCfg.dbData`                              | Database schema name                                                 | 
`setupCfg.dbDrivers`                           | Database driver jar name                                             | 
`setupCfg.dbCreateSchema`                      | Create/update database schema on install/upgrade                     | true
`setupCfg.oracleUseServiceName`                | Use service name applicable if db vendor is Oracle                   | false
`setupCfg.usessl`                              | Enable SSL for database connection                                   | false
`setupCfg.dbTruststore`                        | Database truststore file name including it's path relative to the mounted resources volume location. When `dbTruststoreSecret` is mentioned, provide the name of the key holding the certificate data.                         | 
`setupCfg.dbTruststoreSecret`                  | Name of the Database truststore secret containing the certificate, if applicable.                      | 
`setupCfg.dbKeystore`                          | Database keystore file name including it's path relative to the mounted resources volume location, if applicable. When `dbKeystoreSecret` is mentioned, provide the name of the key holding the certificate data.                         |
`setupCfg.dbKeystoreSecret`                    | Name of the Database keystore secret containing the certificate, if applicable.                       | 
`setupCfg.dbSecret`                            | Database user secret name                                            | 
`setupCfg.adminEmailAddress`                   | Administrator email address                                          | 
`setupCfg.smtpHost`                            | SMTP email server host                                               |
`setupCfg.softStopTimeout`                     | Timeout for soft stop                                                | 
`setupCfg.jmsVendor`                           | JMS MQ Vendor                                                        | 
`setupCfg.jmsConnectionFactory`                | MQ connection factory class name                                     | 
`setupCfg.jmsConnectionFactoryInstantiator`    | MQ connection factory creator class name                             |
`setupCfg.jmsQueueName`                        | Queue name                                                           | 
`setupCfg.jmsHost`                             | MQ Server host                                                       |
`setupCfg.jmsPort`                             | MQ Server port                                                       | 
`setupCfg.jmsUser`                             | MQ user name                                                         | 
`setupCfg.jmsConnectionNameList`               | MQ connection name list                                              | 
`setupCfg.jmsChannel`                          | MQ channel name                                                      |  
`setupCfg.jmsEnableSsl`                        | Enable SSL for MQ server connection                                  | 
`setupCfg.jmsKeystorePath`                     | MQ keystore file name including it's path relative to the mounted resources volume location, if applicable. When `jmsKeystoreSecret` is mentioned, provide the name of the key holding the certificate data.                                   | 
`setupCfg.jmsKeystoreSecret`                   | Name of the JMS keystore secret containing the certificate, if applicable.                                   | 
`setupCfg.jmsTruststorePath`                   | MQ truststore file name including it's path relative to the mounted resources volume location, if applicable. When `jmsTruststoreSecret` is mentioned, provide the name of the key holding the certificate data.                                 |  
`setupCfg.jmsTruststoreSecret`                 | Name of the JMS truststore secret containing the certificate, if applicable.                                  | 
`setupCfg.jmsCiphersuite`                      | MQ SSL connection ciphersuite                                        | 
`setupCfg.jmsProtocol`                         | MQ SSL connection protocol                                           | `TLSv1.2` 
`setupCfg.jmsSecret`                           | MQ user secret name                                                  |
`setupCfg.libertyKeystoreLocation`             | Liberty keystore file name including it's path relative to the mounted resources volume location, if applicable. If `libertyKeystoreSecret` is mentioned, provide the name of the key holding the certificate data.                                  | 
`setupCfg.libertyKeystoreSecret`               | Name of Liberty keystore secret containing the certificate, if applicable.                                  | 
`setupCfg.libertyProtocol`                     | Liberty API server SSL connection protocol                           | `TLSv1.2` 
`setupCfg.libertySecret`                       | Liberty API server SSL connection secret name                        | 
`setupCfg.libertyJvmOptions`                   | Liberty API server JVM option                                        |
`setupCfg.updateJcePolicyFile`                 | Enable JCE policy file update                                        | false
`setupCfg.jcePolicyFile`                       | JCE policy file name                                                 |
`asi.replicaCount`                             | Application server independent(ASI) deployment replica count         | 1
`asi.env.jvmOptions`                           | JVM options for asi                                                  | 
`asi.frontendService.type`                             | Service type                                                         | `NodePort`
`asi.frontendService.ports.http.name`                  | Service http port name                                               | `http`
`asi.frontendService.ports.http.port`                  | Service http port number                                             | 35000
`asi.frontendService.ports.http.targetPort`            | Service target port number or name on pod                            | `http`
`asi.frontendService.ports.http.nodePort`              | Service node port                                                    | 30000
`asi.frontendService.ports.http.protocol`              | Service port connection protocol                                     | `TCP`
`asi.frontendService.ports.https.name`                  | Service https port name                                             | `https`
`asi.frontendService.ports.https.port`                  | Service https port number                                           | 35001
`asi.frontendService.ports.https.targetPort`            | Service target port number or name on pod                           | `https`
`asi.frontendService.ports.https.nodePort`              | Service node port                                                   | 30001
`asi.frontendService.ports.https.protocol`              | Service port connection protocol                                    | `TCP`
`asi.frontendService.ports.soa.name`                  | Service soa port name                                                 | `soa`
`asi.frontendService.ports.soa.port`                  | Service soa port number                                               | 35002
`asi.frontendService.ports.soa.targetPort`            | Service target port number or name on pod                             | `soa`
`asi.frontendService.ports.soa.nodePort`              | Service node port                                                     | 30002
`asi.frontendService.ports.soa.protocol`              | Service port connection protocol                                      | `TCP`
`asi.frontendService.ports.soassl.name`                  | Service soassl port name                                           | `soassl`
`asi.frontendService.ports.soassl.port`                  | Service soassl port number                                         | 35003
`asi.frontendService.ports.soassl.targetPort`            | Service target port number or name on pod                          | `soassl`
`asi.frontendService.ports.soassl.nodePort`              | Service node port                                                  | 30003
`asi.frontendService.ports.soassl.protocol`              | Service port connection protocol                                   | `TCP`
`asi.frontendService.ports.restHttpAdapter.name`                  | Service restHttpAdapter port name                                           | `rest-adapter`
`asi.frontendService.ports.restHttpAdapter.port`                  | Service restHttpAdapter port number                                         | 35007
`asi.frontendService.ports.restHttpAdapter.targetPort`            | Service target port number or name on pod                          | `rest-adapter`
`asi.frontendService.ports.restHttpAdapter.nodePort`              | Service node port                                                  | 30007
`asi.frontendService.ports.restHttpAdapter.protocol`              | Service port connection protocol                                   | `TCP`
`asi.frontendService.extraPorts`                       | Extra ports for service                                              |
`asi.frontendService.loadBalancerIP`                   | LoadBalancer IP for service                                          |
`asi.frontendService.annotations`                      | Additional annotations for the asi frontendService                   |
`asi.backendService.type`                             | Service type                                                         | `NodePort`
`asi.backendService.ports`                       | Ports for service                                              |  
`asi.backendService.portRanges`                       | Port ranges for service                                              |
`asi.backendService.loadBalancerIP`                   | LoadBalancer IP for service                                          |
`asi.backendService.annotations`                      | Additional annotations for the asi backendService                    |
`asi.livenessProbe.initialDelaySeconds`        | Livenessprobe initial delay in seconds                               | 60
`asi.livenessProbe.timeoutSeconds`             | Livenessprobe timeout in seconds                                     | 30
`asi.livenessProbe.periodSeconds`              | Livenessprobe interval in seconds                                    | 60
`asi.readinessProbe.initialDelaySeconds`       | ReadinessProbe initial delay in seconds                              | 120
`asi.readinessProbe.timeoutSeconds`            | ReadinessProbe timeout in seconds                                    | 5
`asi.readinessProbe.periodSeconds`             | ReadinessProbe interval in seconds                                   | 60
`asi.internalAccess.enableHttps`               | Enable https for internal traffic                                    | false
`asi.internalAccess.enableHttps.httpsPort`     | Application internal https port                                      | 
`asi.externalAccess.protocol`                  | Protocol for application client side components to access the application                    | `http`
`asi.externalAccess.address  `                 | External address (ip/host) for application client side components to access the application  | 
`asi.externalAccess.port`                      | External port for application client side components to access the application               | 
`asi.ingress.internal.host`                    | Internal Host name for ingress resource	                          |
`asi.ingress.internal.tls.enabled`             | Enable TLS for ingress                                               | false
`asi.ingress.internal.tls.secretName`          | TLS secret name                                                      |
`asi.ingress.internal.extraPaths`              | Extra paths for ingress resource                                     | 
`asi.ingress.external.host`                    | External Host name for ingress resource	                          |
`asi.ingress.external.tls.enabled`             | Enable TLS for ingress                                               | false
`asi.ingress.external.tls.secretName`          | TLS secret name                                                      |
`asi.ingress.external.extraPaths`              | Extra paths for ingress resource                                     |    
`asi.extraPVCs`                                | Extra volume claims                                                  | 
`asi.extraInitContainers`                      | Extra init containers                                                | 
`asi.resources`                                | CPU/Memory resource requests/limits                                  | 
`asi.autoscaling.enabled`                      | Enable autoscaling                                                   | false
`asi.autoscaling.minReplicas`                  | Minimum replicas for autoscaling                                     | 1
`asi.autoscaling.maxReplicas`                  | Maximum replicas for autoscaling                                     | 2
`asi.autoscaling.targetCPUUtilizationPercentage`| Target CPU utilization                                              | 60
`asi.defaultPodDisruptionBudget.enabled`       | Enable default pod disruption budget                                 | false
`asi.defaultPodDisruptionBudget.minAvailable`  | Minimum available for pod disruption budget                          | 1
`asi.extraLabels`                              | Extra labels                                                         | 
`asi.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`    | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".       | 
`asi.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`   | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    | 
`asi.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    | 
`asi.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`    | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    | 
`asi.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	|
`asi.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`| k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	|
`asi.topologySpreadConstraints`    | Topology spread constraints to control how Pods are spread across your cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains.      |
`asi.tolerations`                             | Tolerations to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints  |  
`asi.extraSecrets`                 | Extra secrets. `mountAsVolume` if `true`, the secrets will be mounted as a volume on `/ibm/resources/<secret-name>` folder else they will be exposed as environment variables.  | 
`asi.extraConfigMaps`              | Extra configmaps. `mountAsVolume` if `true`, the configmap will be mounted as a volume on `/ibm/resources/<configmap-name>` folder else they will be exposed as environment variables.  | 
`asi.myFgAccess.myFgPort`          | If myFG is hosted on HTTP Server adapter on ASI server, provide the internal port used while configuring that.  | 
`asi.myFgAccess.myFgProtocol`      | If myFG is hosted on HTTP Server adapter on ASI server, provide the internal protocol used while configuring that.  | 
`ac.replicaCount`                             | Adapter Container server (ac) deployment replica count               | 1
`ac.env.jvmOptions`                           | JVM options for ac                                                   | 
`ac.frontendService.type`                             | Service type                                                         | `NodePort`
`ac.frontendService.ports.http.name`                  | Service http port name                                               | `http`
`ac.frontendService.ports.http.port`                  | Service http port number                                             | 35001
`ac.frontendService.ports.http.targetPort`            | Service target port number or name on pod                            | `http`
`ac.frontendService.ports.http.nodePort`              | Service node port                                                    | 30001
`ac.frontendService.ports.http.protocol`              | Service port connection protocol                                     | `TCP`
`ac.frontendService.extraPorts`                       | Extra ports for service                                              | 
`ac.frontendService.loadBalancerIP`                   | LoadBalancer IP for service                                          | 
`ac.frontendService.annotations`                     | Additional annotations for the ac frontendService                     |
`ac.backendService.type`                             | Service type                                                         | `NodePort`
`ac.backendService.ports`                       | Ports for service                                              |  
`ac.backendService.portRanges`                       | Port ranges for service                                              |
`ac.backendService.loadBalancerIP`                  | LoadBalancer IP for service                                          |
`ac.backendService.annotations`                     | Additional annotations for the ac backendService                     |
`ac.livenessProbe.initialDelaySeconds`        | Livenessprobe initial delay in seconds                               | 60
`ac.livenessProbe.timeoutSeconds`             | Livenessprobe timeout in seconds                                     | 5
`ac.livenessProbe.periodSeconds`              | Livenessprobe interval in seconds                                    | 60
`ac.readinessProbe.initialDelaySeconds`       | ReadinessProbe initial delay in seconds                              | 120
`ac.readinessProbe.timeoutSeconds`             | ReadinessProbe timeout in seconds                                   | 5
`ac.readinessProbe.periodSeconds`             | ReadinessProbe interval in seconds                                   | 60
`ac.ingress.internal.host`                    | Internal Host name for ingress resource	                          |
`ac.ingress.internal.tls.enabled`             | Enable TLS for ingress                                               | false
`ac.ingress.internal.tls.secretName`          | TLS secret name                                                      |
`ac.ingress.internal.extraPaths`              | Extra paths for ingress resource                                     | 
`ac.ingress.external.host`                    | External Host name for ingress resource	                          |
`ac.ingress.external.tls.enabled`             | Enable TLS for ingress                                               | false
`ac.ingress.external.tls.secretName`          | TLS secret name                                                      |
`ac.ingress.external.extraPaths`              | Extra paths for ingress resource                                     |    
`ac.extraPVCs`                                | Extra volume claims                                                  | 
`ac.extraInitContainers`                      | Extra init containers                                                | 
`ac.resources`                                | CPU/Memory resource requests/limits                                  | 
`ac.autoscaling.enabled`                      | Enable autoscaling                                                   | false
`ac.autoscaling.minReplicas`                  | Minimum replicas for autoscaling                                     | 1
`ac.autoscaling.maxReplicas`                  | Maximum replicas for autoscaling                                     | 2
`ac.autoscaling.targetCPUUtilizationPercentage`| Target CPU utilization                                              | 60
`ac.defaultPodDisruptionBudget.enabled`       | Enable default pod disruption budget                                 | false
`ac.defaultPodDisruptionBudget.minAvailable`  | Minimum available for pod disruption budget                          | 1
`ac.extraLabels`                              | Extra labels                                                         | 
`ac.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`    | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".       | 
`ac.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`   | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    | 
`ac.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    | 
`ac.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`    | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    | 
`ac.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	|
`ac.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`| k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	| `api.replicaCount`                             | k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity". | 
`ac.topologySpreadConstraints`    | Topology spread constraints to control how Pods are spread across your cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains.      | 
`ac.tolerations`                             | Tolerations to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints  | 
`ac.extraSecrets`                 | Extra secrets. `mountAsVolume` if `true`, the secrets will be mounted as a volume on `/ibm/resources/<secret-name>` folder else they will be exposed as environment variables.  | 
`ac.extraConfigMaps`              | Extra configmaps. `mountAsVolume` if `true`, the configmap will be mounted as a volume on `/ibm/resources/<configmap-name>` folder else they will be exposed as environment variables.  | 
`ac.myFgAccess.myFgPort`          | If myFG is hosted on HTTP Server adapter on AC server, provide the internal port used while configuring that.  | 
`ac.myFgAccess.myFgProtocol`      | If myFG is hosted on HTTP Server adapter on AC server, provide the internal protocol used while configuring that.  | 
`api.replicaCount`                             | Liberty API server (API) deployment replica count                    | 1
`api.env.jvmOptions`                           | JVM options for api                                                  | 
`api.frontendService.type`                             | Service type                                                         | `NodePort`
`api.frontendService.ports.http.name`                  | Service http port name                                               | `http`
`api.frontendService.ports.http.port`                  | Service http port number                                             | 35002
`api.frontendService.ports.http.targetPort`            | Service target port number or name on pod                            | `http`
`api.frontendService.ports.http.nodePort`              | Service node port                                                    | 30002
`api.frontendService.ports.http.protocol`              | Service port connection protocol                                     | `TCP`
`api.frontendService.ports.https.name`                 | Service http port name                                               | `https`
`api.frontendService.ports.https.port`                 | Service http port number                                             | 35003
`api.frontendService.ports.https.targetPort`           | Service target port number or name on pod                            | `https`
`api.frontendService.ports.https.nodePort`             | Service node port                                                    | 30003
`api.frontendService.ports.https.protocol`             | Service port connection protocol                                     | `TCP`
`api.frontendService.extraPorts`                       | Extra ports for service                                              | 
`api.frontendService.loadBalancerIP`                   | LoadBalancer IP for service                                          |
`api.frontendService.annotations`                      | Additional annotations for the api frontendService                   |
`api.livenessProbe.initialDelaySeconds`        | Livenessprobe initial delay in seconds                               | 120
`api.livenessProbe.timeoutSeconds`             | Livenessprobe timeout in seconds                                     | 5
`api.livenessProbe.periodSeconds`              | Livenessprobe interval in seconds                                    | 60
`api.readinessProbe.initialDelaySeconds`       | ReadinessProbe initial delay in seconds                              | 120
`api.readinessProbe.timeoutSeconds`            | ReadinessProbe timeout in seconds                                    | 5
`api.readinessProbe.periodSeconds`             | ReadinessProbe interval in seconds                                   | 60
`api.internalAccess.enableHttps`               | Enable https for internal traffic                                    | false
`api.externalAccess.protocol`                  | Protocol for application client side components to access the application                    | `http`
`api.externalAccess.address  `                 | External address (ip/host) for application client side components to access the application  | 
`api.externalAccess.port`                      | External port for application client side components to access the application               | 
`api.ingress.internal.host`                    | Internal Host name for ingress resource	                          |
`api.ingress.internal.tls.enabled`             | Enable TLS for ingress                                               | false
`api.ingress.internal.tls.secretName`          | TLS secret name                                                      |
`api.extraPVCs`                                | Extra volume claims                                                  | 
`api.extraInitContainers`                      | Extra init containers                                                | 
`api.resources`                                | CPU/Memory resource requests/limits                                  | 
`api.defaultPodDisruptionBudget.enabled`       | Enable default pod disruption budget                                 | false
`api.defaultPodDisruptionBudget.minAvailable`  | Minimum available for pod disruption budget                          | 1
`api.extraLabels`                              | Extra labels                                                         | 
`api.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`    | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".       | 
`api.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`   | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    | 
`api.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`     | k8s PodSpec.podAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    | 
`api.podAffinity.preferredDuringSchedulingIgnoredDuringExecution`    | k8s PodSpec.podAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    | 
`api.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` | k8s PodSpec.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	|
`api.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution`| k8s PodSpec.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity and Tolerations".	|
`api.topologySpreadConstraints`    | Topology spread constraints to control how Pods are spread across your cluster among failure-domains such as regions, zones, nodes, and other user-defined topology domains.      | 
`api.tolerations`                              | Tolerations to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints  |  
`api.extraSecrets`                 | Extra secrets. `mountAsVolume` if `true`, the secrets will be mounted as a volume on `/ibm/resources/<secret-name>` folder else they will be exposed as environment variables.  | 
`api.extraConfigMaps`              | Extra configmaps. `mountAsVolume` if `true`, the configmap will be mounted as a volume on `/ibm/resources/<configmap-name>` folder else they will be exposed as environment variables.  | 
`nameOverride`                                 | Chart resource short name override                                   | 
`fullnameOverride`                             | Chart resource full name override                                    | 
`dashboard.enabled`                            | Enable sample Grafana dashboard                                      | false
`test.image.repository`                        | Repository for docker image used for helm test and cleanup           | 'ibmcom'
`test.image.name          `                    | helm test and cleanup docker image name                              | `opencontent-common-utils`
`test.image.tag          `                     | helm test and cleanup docker image tag                               | `1.1.4`
`test.image.pullPolicy`                        | Pull policy for helm test image repository                           | `IfNotPresent`
`purge.enabled`                                | Enable external purge job                                            | 'false'
`purge.image.repository          `             | External purge docker image repository                               | `purge`
`purge.image.tag          `                    | External purge image tag                                             | `6.1.0.2`
`purge.image.pullPolicy`                       | Pull policy for external purge docker image                          | `IfNotPresent`
`purge.image.pullSecret`                       | Pull secret for repository access                                    | 
`purge.schedule`                               | External purge job creation and execution schedule. Its a Cron format string such as 1 * * * * or 
@hourly as schedule day/time. Please refer [Kubernetes documentation](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/#schedule)  for further details on Cron string for schedule. Please specify the schedule value in quotes    | 
`purge.startingDeadlineSeconds`                | Deadline in seconds for starting the job if it misses its scheduled time for any reason | 
`purge.activeDeadlineSeconds`                  | Duration in seconds that the external purge job will be running. Once the job reaches activeDeadlineSeconds the external purge will stop and job will be marked as Completed    | 
`purge.concurrencyPolicy`                      | Specifies behavior for concurrent execution of external purge job. Valid values are Forbid - concurrent jobs are not allowed and Replace - If it is time for the new job run and previous job has not finished yet, the new job will replace the currently running job    | `Forbid`
`purge.suspend`                                | If it is set to true, all subsequent executions are suspended. This setting does not apply to already started executions    | false
`purge.successfulJobsHistoryLimit`             | Specify how many completed external purge jobs should be kept in history   | 3
`purge.failedJobsHistoryLimit`                 | Specify how many failed external purge jobs should be kept in history      | 1
`purge.env.jvmOptions`                         | JVM options for purge                                                      | 
`purge.resources`                              | CPU/Memory resource requests/limits for the external purge job pod         | 1 CPU and 2Gi Memory
`purge.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`    | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".       | 
`purge.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`   | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    |

## Upgrading the Chart

You would want to upgrade your deployment when you have a new docker image or helm chart verison or a change in configuration, for e.g. new service ports to be exposed. 

1. Ensure that the chart is downloaded locally and available.

2. Before upgrading the release for any configurations change, set the `dataSetup.enabled` as `false`

3. Run the following command to upgrade your deployments. 

```sh
helm upgrade my-release -f values.yaml ./ibm-sfg-prod --timeout 3600s
```

4. Run the following command to upgrade your deployments with recreation of pods after 
* changing configurations in properties files available inside `ibm-b2bi-prod/properties`,for example, modifying `asi-tuning.properties` file.
* changing configurations in `setupCfg` section

```
helm upgrade my-release -f values.yaml ./ibm-b2bi-prod --timeout 3600s --recreate-pods
```
For product release version upgrade, please refer product documentation.

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
* ConfigMap - <release name>-sfg-config
* PersistentVolumeClaim if persistence is enabled - <release name>-sfg-resources-pvc
* PersistentVolumeClaim if persistence is enabled and enableAppLogOnConsole is disabled - <release name>-sfg-logs-pvc

Note: You may also consider deleting the secrets and peristent volumes created as part of prerequisites, after creating their backups.

## Affinity
The chart provides various ways in the form of node affinity, pod affinity and pod anti-affinity to configure advance pod scheduling in kubernetes. Refer the kubernetes documentation for details on usage and specifications for the below features.

* Node affinity - This can be configured using parameters `asi.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `asi.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the asi server, and parameters `ac.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ac.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the ac servers, , and parameters `api.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `api.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the api servers.
Depending on the architecture preference selected for the parameter `arch`, a suitable value for node affinity is automatically appended in addition to the user provided values.

* Pod affinity - This can be configured using parameters `asi.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `asi.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the asi server, and parameters `ac.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ac.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the ac servers, , and parameters `api.podAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `api.podAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the api servers.

* Pod anti-affinity - This can be configured using parameters `asi.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `asi.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the asi server, and parameters `ac.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `ac.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the ac servers, , and parameters `api.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`, `api.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` for the api servers.
Depending on the value of the parameter `podAntiAffinity.replicaNotOnSameNode`, a suitable value for pod anti-affinity is automatically appended in addition to the user provided values. This is to configure whether replicas of a pod should be scheduled on the same node. If the value is `prefer` then `podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution` is automatically appended whereas if the value is `require` then `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` is appended. If the value is blank, then no pod anti-affinity value is automatically appended. If the value is `prefer` then the weighting for the preference is set using the parameter `podAntiAffinity.weightForPreference` which should be specified in the range 1-100.

## Accessing Application

### Accessing application Frontend/User Interface (HTTP/HTTPS) endpoints
The application frontend or user interface endpoints can be accessed through the frontend service by configuring either of the below options:
1.	Enabling and configuring ingress or routes (for OpenShift) on the applicable endpoints and setting the service type to ClusterIP. This is the recommended way and enabled by default. 
2.	Enabling and configuring frontend service by setting the service type to LoadBalancer or NodePort. In case of service type as LoadBalancer an instance of the cloud provider’s Load balancer is configured and public IP is assigned for external access. In case of service type NodePort the application can be accessed using the node IP and node port configured by the service. Please note that using the NodePort service is not recommended particularly for production environments and should be avoided. 

With Kubernetes Ingress/OpenShift Route Configurations
*	ingress.enabled - Ingress can be enabled by setting this parameter as true. If ingress is enabled asi.frontendService.type/ac.frontendService.type and api.frontendService.type are always set to ClusterIP.

*	asi.frontendService.type/ac.frontendService.type and api.frontendService.type – It can be set to any valid Kubernetes service type supported by the platform – ClusterIP/LoadBalancer/NodePort/ExternalName. By default it is set to CluserIP.

*	asi.frontendService.extraPorts/ac.frontendService.extraPorts and api.frontendService.extraPorts
Additional ports could be configured for the frontend service as individual port mappings with the following port configuration options in values yaml:
	
    - name: Name for the port mapping
	
    - port: service port number
	
    - targetPort: target pod port name or number
	
    - nodePort: service node port number. Applicable only for service type node port
	
    - protocol: valid protocol for the container environment. Defaults to TCP
	
*	asi.ingress.internal.host/ac.ingress.internal.host/api.ingress.internal.host -  Fully qualified private or internal  virtual domain names for asi/ac/api servers that resolves to the IP address of your cluster’s proxy node or router. Based on your network settings it may be possible that multiple virtual domain names resolve to the same IP address of the proxy node or router. Any of those domain names can be used. For example "example.com" or "test.example.com" or “apps.openshift4.example.com” etc.

*	asi.ingress.internal.extraPaths/ac.ingress.internal.extraPaths - The additional internal context paths to be configured on the respective servers. Custom context paths could be configured on the asi or ac servers using HTTP server adapter. You could configure the below options for each extra path specified
	
    - routePrefix: The route prefix to be added to the route name
	
    - path: The context path for the user web application
	
    - servicePort: The service port name or number for the application
	
    - enableHttps: true or false based on whether SSL is enabled for the application

*	asi.ingress.internal.tls.enabled/ac.ingress.internal.tls.enabled/api.ingress.internal.tls.enabled  - Enable or disable TLS for internal routes. It is strongly recommended to enable TLS. 

*	asi.ingress.external.host/ac.ingress.external.host/api.ingress.external.host -  Fully qualified public or external virtual domain names for asi/ac/api servers that resolves to the IP address of your cluster’s proxy node or router. Based on your network settings it may be possible that multiple virtual domain names resolve to the same IP address of the proxy node or router. Any of those domain names can be used. For example "example.com" or "test.example.com" or “apps.openshift4.example.com” etc.

*	asi.ingress.external.extraPaths/ac.ingress.external.extraPaths - The additional external or public context paths configured on the respective servers. Custom context paths could be configured on the asi or ac servers using HTTP server adapter. You could configure the below options for each extra path specified
	
    - routePrefix: The route prefix to be added to the route name
	
    - path: The context path for the user web application
	
    - servicePort: The service port name or number for the application
	
    - enableHttps: true or false based on whether SSL is enabled for the application

*	asi.ingress.external.tls.enabled/ac.ingress.external.tls.enabled/api.ingress.external.tls.enabled  - Enable or disable TLS for external routes. It is strongly recommended to enable TLS. 

*	asi.externalAccess/api.externalAccess – This is used to configure external access for the application from within client side tools like Graphic Process Modeler and other user interfaces. With ingress enabled, the externalAccess configurations get auto configured by the application with the ingress/route protocol, host names and ports taking into consideration the ingress SSL settings as well. The following configurations can be left as blank or with their default values in values yaml :
	
    - asi/api.externalAccess.protocol:
	
    - asi/api.externalAccess.address:
	
    - asi/api.externalAccess.port:

*	asi.internalAccess/api.internalAccess – This is used to access the application endpoint with SSL configured on the respective application https port through ingress or route. This ensures end to end secure access to the application particularly for OpenShift routes. The following configurations need to set as below
	
    - asi/api.internalAccess.enableHttps: Enable this configuration to access the application on the https port
	
    - asi.internalAccess.httpsPort: If not specified it defaults to  .Values.setupCfg.basePort + 1. In case the application war files are deployed on HTTP Server Adapter with SSL enabled on the ASI server, this can be set to the service port configured for the adapter.
	 

Note: 
The application installation will automatically create some default internal routes on 
*	Internal asi route host for these web contexts – /, /dashboard, /filegateway, /myfilegateway, /myfg, /ebicsClient, /mailbox, /queueWatch, /wsdl, /soap* 

*	Internal api route host for these web contexts – /, /B2BAPIs, /propertyUI
The application installation will automatically create some default external routes on 

*	Internal asi route host for these web contexts – /myfilegateway, /myfg, /ebicsClient, /mailbox 

Any additional custom web context path can be configured using the “extraPaths” configurations available for both internal and external route hosts.

#### Configure SSL for OpenShift Route
If SSL is enabled by setting asi.ingress.ssl.enabled/ ac.ingress.ssl.enabled/ api.ingress.ssl.enabled parameter to true, routes are created with https URL. Also, the routes will be exposed with the cluster's default certificate.
However, for production environments it is strongly recommended to obtain a CA certified TLS certificate and update the routes manually as below.
1.	Obtain a CA certified TLS certificate for the given asi.ingress.host/ ac.ingress.host/api.ingress.host in the form of key and certificate files.

2.	The below script will allow patching all the routes created through the helm install with the certificate information based on the <Release_name>.

```
CRT_FN=<Path to Certificate>
KEY_FN=<Path to Private Key>
CABUNDLE_FN=<Path to CA Bundle File>

CERTIFICATE="$(awk '{printf "%s\\n", $0}' ${CRT_FN})"
KEY="$(awk '{printf "%s\\n", $0}' ${KEY_FN})"
CABUNDLE=$(awk '{printf "%s\\n", $0}' ${CABUNDLE_FN})

oc patch route $(oc get routes -l release=<Release_name> -o jsonpath="{.items[*].metadata.name}") -p '{"spec":{"tls":{"certificate":"'"${CERTIFICATE}"'", "key":"'"${KEY}"'" ,"caCertificate":"'"${CABUNDLE}"'"}}}'
```

3.	If internal access for the application is https enabled, then you can specify the destination certificate for the application

```
DEST_CABUNDLE_FN=<Path to Destination CA Bundle File>
DESTCABUNDLE=$(awk '{printf "%s\\n", $0}' ${ DEST_CABUNDLE_FN })

oc patch route $(oc get routes -l release=<Release_name> -o jsonpath="{.items[*].metadata.name}") -p '{"spec":{"tls":{"certificate":"'"${CERTIFICATE}"'", "key":"'"${KEY}"'" ,"caCertificate":"'"${CABUNDLE}"'", "destinationCACertificate":"'"${DESTCABUNDLE}"'"}}}'
```

#### Configure SSL for Kubernetes Ingress
If SSL is enabled by setting asi.ingress.ssl.enabled/ ac.ingress.ssl.enabled/ api.ingress.ssl.enabled parameter to true, a secret is needed to hold the TLS certificate and the secret name needs to be configured for each of these parameters asi.ingress.ssl.secretname/ ac.ingress.ssl.secretname/ api.ingress.ssl.secretname.
For production environments it is strongly recommended to obtain                    a CA certified TLS certificate and create a secret for each of the host manually            as below. 
1.	Obtain a CA certified TLS certificate for the given host  asi.ingress.host in the form of key and certificate files.

2.	Create a secret from the above key and certificate files by running below command

```
kubectl create secret tls <Release-name>-asi-ingress-secret --key <file containing key> --cert <file containing certificate> -n <namespace>
```

3.	Use the above created secret as the value of the parameter asi.ingress.ssl.secretname.

4.	Repeat the steps for ac.ingress.host and api.ingress.host

### With Kubernetes Service
*	ingress.enabled – Disable ingress by setting this parameter as false. 

*	asi.frontendService.type/ac.frontendService.type /api.frontendService.type -  This needs to be set to a valid external service type Load Balancer, Node Port or ExternalName, if supported by the platform. NodePort is not a recommended option and should be avoided particularly for production environments. 

*	asi.frontendService.extraPorts /ac.frontendService.extraPorts /api.frontendService.extraPorts
Additional ports could be configured for the frontend service as individual port mappings with the following port configuration options in values yaml :
	
    - name: Name for the port mapping
    	
    - port: service port number
	
    - targetPort: target pod port name or number
	
    - nodePort: service node port number. Applicable only for service type node port
	
    - protocol: valid protocol for the container environment. Defaults to TCP

*	asi.externalAccess/api.externalAccess – This is used to configure application external access from within application client side tools like GBM and user interfaces. With ingress disabled, the externalAccess configurations need to configured with the load balancer or node port public IP. The following configurations need to be configured in in values yaml :
	
    - asi/api.externalAccess.protocol: http or https based on load balancer and application internalAccess configurations
    	
    - asi/api.externalAccess.address: Load Balancer public IP or Node Port IP
	
    - asi/api.externalAccess.port: It defaults to the frontendService http or https port if not specified

*	asi.internalAccess/api.internalAccess – This is used to access the application endpoint on the https port through load balancer. This ensures end to end secure access to the application. The following configurations need to be set as below
	
    - asi/api.internalAccess.enableHttps: Enable this configuration to access the application on the https port
    	
    - asi.internalAccess.httpsPort: If not specified it defaults to  .Values.setupCfg.basePort + 1. In case the application war files are deployed on HTTP Server Adapter with SSL enabled, this can be set to the port configured for the adapter. 

### Accessing Application Backend (Non HTTP) endpoints
The application backend or non-http endpoints, configured primarily for services and adapters, can be accessed through the backend service by configuring either of the below options:
1.	Enabling and configuring cloud provider’s Load balancer by setting the service type to LoadBalancer. 

2.	Using node IP and node port by setting the service type to NodePort. Please note that using the NodePort service is not recommended for production environments and should be avoided. 

The backend service configurations are available for the following deployment services:
1.	asi backend service – This maps to the asi deployment pods

2.	ac backend service – This maps to the ac deployment pods              

Configurations: 
1.	asi.backendService.type/ac.backendService.type -  This needs to be set to a valid external service type Load Balancer or Node Port. NodePort is not a recommended option and should be avoided particularly for production environments. 

2.	asi.backendService.ports/ac.backendService.ports
External ports could be configured as individual port mappings with the following port configuration options in values yaml :
	
    - name: Name for the port mapping
	
    - port: service port number
	
    - targetPort: target pod port name or number
	
    - nodePort: service node port number. Applicable only for service type node port
	
    - protocol: valid protocol for the container environment. Defaults to TCP

3.	asi.backendService.portRanges/ac.backendService.portRanges
External ports could be configured as port range mappings with the following port range configuration options in values yaml :
	
    - name: Name for the port range mapping
	
    - portRange: service port number range
	
    - targetPortRange: target pod port number range
	
    - nodePortRange: service node port number range. Applicable only for service type node port
	
    - protocol: valid protocol for the container environment. Defaults to TCP


## Limitations

* If user wishes to use fluentd log collector, it needs to run with root user to access the /var/log/ directories.

* In case the data setup job takes more than 3600 seconds due to database server connectivity, please edit the kube-apiserver.yaml to increase request timeout to 3600 or more. Example : `- --min-request-timeout=3600`

* On certain Helm versions and environment you may observe this error while trying to install or upgrade the helm charts - "Error: create: failed to create: Secret "sh.helm.release.v1.<release-name>.v1" is invalid: data: Too long: must have at most 1048576 bytes". This is an issue with Helm. Till it is fixed for good in an upcoming helm release, you can add an entry "ibm_cloud_pak" in <chart location>/.helmignore file.  

## PodDisruptionBudget Resources:

- defaultPodDisruptionBudget.api.enabled
If true, It will create a pod disruption budget for api pods.
- defaultPodDisruptionBudget.api.minAvailable
It will specify Minimum number / percentage of pods that should remain scheduled for api pod.
- defaultPodDisruptionBudget.ac.enabled
If true, It will create a pod disruption budget for ac pods.
- defaultPodDisruptionBudget.ac.minAvailable
It will specify Minimum number / percentage of pods that should remain scheduled for ac pod.
- defaultPodDisruptionBudget.asi.enabled
If true, It will create a pod disruption budget for asi pods.
- defaultPodDisruptionBudget.asi.minAvailable
It will specify Minimum number / percentage of pods that should remain scheduled for asi pod.
