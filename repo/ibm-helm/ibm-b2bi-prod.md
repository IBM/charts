# IBM Sterling B2B Integrator Enterprise Edition v6.2.0.3
## Introduction

IBM Sterling B2B Integrator helps companies integrate complex B2B EDI processes with their partner communities. Organizations get a single, flexible B2B platform that supports most communication protocols, helps secure your B2B network and data, and achieves high-availability operations. The offering enables companies to reduce costs by consolidating EDI and non-EDI any-to-any transmissions on a single B2B platform and helps automate B2B processes across enterprises, while providing governance and visibility over those processes.
To find out more, see [IBM Sterling B2B Integrator](https://www.ibm.com/us-en/marketplace/b2b-gateway-software) on IBM Marketplace.

## Chart Details

This chart deploys IBM B2BI Sterling Integrator cluster on a container management platform with the following resources
Deployments
* Application Server Independent (ASI) server with 1 replica by default
* Adapter Container (AC) server with 1 replica by default
* Liberty API server with 1 replica by default
Services
* ASI service - This service is used to access ASI servers using a consistent IP address
* AC service - This service is used to access AC servers using a consistent IP address
* Liberty API service - This service is used to access API servers using a consistent IP address


## Prerequisites

1. Red Hat OpenShift Container Platform 
   Version 4.14.0 or later fixes
   Version 4.15.0 or later fixes
   Version 4.16.0 or later fixes

2. Kubernetes version >= 1.28 and <= 1.30

3. Helm version >= 3.15.x

4. Ensure that the docker images for IBM Sterling B2B Integrator Software Enterprise Edition from IBM Entitled Registry are downloaded and pushed to an image registry accessible to the cluster.

5. Ensure that one of the supported database server (Oracle/DB2/MSSQL) is installed and the database is accessible from inside the cluster. 

6. In case required by an adapter service or Adapter Container server, ensure that a supported MQ Server version (IBM MQ or ActiveMQ Server) is installed and accessible from inside the cluster.

7. Provide external resource artifacts like the database driver jar, Key store and trust store files, Standards jar and so on using an init container for resources or a persistent volume for resources. Either of the option can be used but not both at the same time. 
  a. For using init container for resources when `resourcesInit.enabled` is `true`, create an init container image bundled with the required external resource artifacts and configure the image details in the `resourcesInit.image` section.
  b. For using persistent volume for resources when `appResourcesPVC.enabled` is `true`, create a persistent volume for application resources with access mode as 'Read Only Many' and place the required external resource artifacts in the mapped volume location.

8. When `appLogsPVC.enabled` is `true`, create a persistent volume for application logs with access mode as 'Read Write Many'.

9. When `appDocumentsPVC.enabled` is `true`, create a persistent volume for application document storage with access mode as 'Read Write Many'.

10. Create custom network policies to enable required ingress and egress endpoints for required external services like database server, MQ server, 3rd party integration services, protocol adapter endpoints and so on.

11. Create secrets with requisite confidential credentials for system passphrase, database, MQ server and Liberty. You can use the supplied configuration files under pak_extensions/pre-install/secret directory.

12. Create a secret to pull the image from a private registry or repository using following command
    ```
    kubectl create secret docker-registry <name of secret> --docker-server=<your-registry-server> --docker-username=<your-username> --docker-password=<your-password> --docker-email=<your-email>
    ```
    Configure this pull secret in the service account used for deployment using this command
    ```
    kubectl patch serviceaccount <service-account-name> -p '{"imagePullSecrets": [{"name": "<pull-secret-name>"}]}'
    ```
    It is recommended to configure the pull secret in the service account as it automatically binds as a pull secret for all application pods. If the pull secret is added to the service account then the image pullSecret configurations in the helm configuration file are not required.

13. If applicable, create secrets with confidential certificates required by Database, MQ or Liberty for SSL connectivity using below command
    ```
	kubectl create secret generic <secret-name> --from-file=/path/to/<certificate>
	```

14. When installing the chart on a new database which does not have IBM Sterling B2B Integrator Software schema tables and metadata, 
* ensure that `dataSetup.enable` parameter is set to `true` and `dataSetup.upgrade` parameter is set as `false`. This will create the required database tables and metadata in the database before installing the chart.

15. When installing the chart on a database on an older release version
* ensure that `dataSetup.enable` parameter is set to `true`,`dataSetup.upgrade` parameter is set as `true` and `env.upgradeCompatibilityVerified` is set as `true`. This will upgrade the given database tables and metadata to the latest version.

16. Automatically installing ibm-licensing-operator with a stand-alone IBM Containerized Software using Operator Lifecycle Manager (OLM) 
Use the automatic script to install License Service on any Kubernetes-orchestrated cloud. The script creates an instance and validates the steps. It was tested to work on OpenShift Container Platform 4.8+, vanilla Kubernetes custer, 
and is available at:
 - pre-install/license/ibm_licensing_operator_install.sh
 Post-installation steps: 
 - https://github.com/IBM/ibm-licensing-operator/blob/master/README.md#post-installation-steps

### Installation against a pre-loaded database
When installing the chart against a database which already has the Sterling B2B Integrator Software tables and factory meta data ensure that `datasetup.enable` parameter is set to `false`. This will avoid re-creating tables and overwriting factory data.

### Creating a Role Based Access Control (RBAC)
If you are deploying the application on a namespace other than the default namespace, and if you have not created Role Based Access Control (RBAC), create RBAC with the cluster admin role.

The following sample file illustrates RBAC for the default service account with the target namespace as `<namespace>`. The same can be applied to any existing or new service account created for the application by updating the service account name in the below RoleBinding template. 

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ibm-b2bi-role-<namespace>
  namespace: <namespace>
rules:
  - apiGroups: ['route.openshift.io']
    resources: ['routes','routes/custom-host']
    verbs: ['get', 'watch', 'list', 'patch', 'update']
  - apiGroups: ['','batch']
    resources: ['secrets','configmaps','persistentvolumes','persistentvolumeclaims','pods','services','cronjobs','jobs']
    verbs: ['create', 'get', 'list', 'delete', 'patch', 'update']

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ibm-b2bi-rolebinding-<namespace>
  namespace: <namespace>
subjects:
  - kind: ServiceAccount
    name: default
    namespace: <namespace>
roleRef:
  kind: Role
  name: ibm-b2bi-role-<namespace>
  apiGroup: rbac.authorization.k8s.io
```  

### PodSecurityPolicy Requirements

With Kubernetes v1.25, Pod Security Policy (PSP) API has been removed and replaced with Pod Security Admission (PSA) contoller. Kubernetes PSA conroller enforces predefined Pod Security levels at the namespace level. The Kubernetes Pod Security Standards defines three different levels: privileged, baseline, and restricted. Refer to Kubernetes [`Pod Security Standards`] (https://kubernetes.io/docs/concepts/security/pod-security-standards/) documentation for more details. This chart is compatible with the restricted security level. 

For users upgrading from older Kubernetes version to v1.25 or higher, refer to Kubernetes [`Migrate from PSP`](https://kubernetes.io/docs/tasks/configure-pod-container/migrate-from-psp/) documentation to help with migrating from PodSecurityPolicies to the built-in Pod Security Admission controller.

For users continuing on older Kubernetes versions (<1.25) and using PodSecurityPolicies, choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you. This chart is compatible with most restrictive policies.
Below is an optional custom PSP definition based on the IBM restricted PSP.

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
 
- From the user interface or command line, you can copy and paste the following snippets to create and enable the below custom PodSecurityPolicy based on IBM restricted PSP.
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
      - ALL
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

  - Custom Role for the custom PodSecurityPolicy:

    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
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

  - Custom Role binding for the custom PodSecurityPolicy:

    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: "ibm-b2bi-psp"
      labels:
        app: "ibm-b2bi-psp"
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: "ibm-b2bi-psp"
    subjects:
    - apiGroup: rbac.authorization.k8s.io
      kind: Group
      name: system:serviceaccounts
      namespace: {{ NAMESPACE }}
    ```

### SecurityContextConstraints Requirements

Red Hat OpenShift provides a pre-defined or default set of SecurityContextConstraints (SCC). These SCCs are used to control permissions for pods. These permissions include actions that a pod can perform and what resources it can access. You can use SCCs to define a set of conditions that a pod must run with to be accepted into the system. Refer to OpenShift [`Managing Security Context Constraints`](https://docs.openshift.com/container-platform/4.11/authentication/managing-security-context-constraints.html#default-sccs_configuring-internal-oauth) documentation for more details on the default SCCs. This chart is compatible with both restricted and resticted-v2 (added in OpenShift v4.11) default SCCs and does not require a custom SCC to be defined explicity.

For OpenShift, choose either a predefined SCC or have your cluster administrator create a custom SCC for you as per the security profile and policies adopted for all OpenShift deployments. This chart is compatible with most restrictive security context constraints.
Below is an optional custom SCC definition based on the IBM restricted SCC.

* Predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc)

- From the user interface or command line, you can copy and paste the following snippets to create and enable the below custom SCC based on IBM restricted SCC.

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
    - ALL
    runAsUser:
      type: MustRunAsRange
    # This can be customized for your host machine
    seLinuxContext:
      type: MustRunAs
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

    - Custom Role for the custom SecurityContextConstraints:
    
    ```
    apiVersion: rbac.authorization.k8s.io/v1
	  kind: Role
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

    - Custom Role binding for the custom SecurityContextConstraints:

    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: "ibm-b2bi-scc"
      labels:
        app: "ibm-b2bi-scc"
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: Role
      name: "ibm-b2bi-scc"
    subjects:
    - apiGroup: rbac.authorization.k8s.io
      kind: Group
      name: system:serviceaccounts
      namespace: {{ NAMESPACE }}
    ```

## Network Policy

  For Certified Container deployments, few default network policies are created out of the box as per mandatory security guidelines. By default all ingress and egress traffic are denied with few additional policies to allow communication within cluster and on ports configured in the helm charts configuration. 
  Additionally custom ingress and egress policies can be configured in values yaml to allow traffic from and to specific external service endpoints.

  Note: By default all ingress and egress traffic from or to external services are denied. You will need to create custom network policies to allow ingress and egress traffic from or to services outside of the cluster like database, MQ, protocol adapter endpoints, any other third party service integration and so on.

  Out of the box Ingress policies
  *	Deny all ingress traffic
  *	Allow ingress traffic from all pods in the current namespace in the cluster
  *	Allow ingress traffic on the additional configured ports in helm values
  
  Out of the box Egress policies
  *	Deny all egress traffic
  *	Allow egress traffic within the cluster

  
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
$ helm install my-release -f values.yaml ./ibm-b2bi-prod --timeout 3600s  --namespace <namespace>
```

Depending on the capacity of the kubernetes worker node and database network connectivity, chart deployment can take on average 
* 2-3 minutes for 'installation against a pre-loaded database' and 
* 20-30 minutes for 'installation against a fresh new or older release upgrade'

## Configuration

### The following table lists the configurable parameters for the chart


Parameter                                      | Description                                                          | Default 
-----------------------------------------------| ---------------------------------------------------------------------| -------------
`global.license`                               | Accept B2BI/SFG license                                              | `false`
`global.licenseType`                           | Specify the license edition as per license agreement.                | prod
`global.image.repository`                      | Repository for B2B docker images                                     | 
`global.image.tag          `                   | Docker image tag                                                     | `6.2.0.3`
`global.image.digest          `                | Docker image digest. Takes precedence over tag                       | 
`global.image.pullPolicy`                      | Pull policy for repository                                           | `IfNotPresent`
`global.image.pullSecret `         			   | Pull secret for repository access                                    | `ibm-entitlement-key`
`global.networkPolicies.ingress.enabled`       | Enable out of the box ingress network policies                       | true
`global.networkPolicies.ingress.customPolicies`| Configure custom ingress network policies                            |
`global.networkPolicies.egress.enabled`        | Enable out of the box egress network policies                        | true
`global.networkPolicies.egress.customPolicies` | Configure custom egress network policies                             |
`arch.amd64`                                   | Specify weight to be used for scheduling for architecture amd64      | `2 - No Preference`
`arch.ppc64le`                                 | Specify weight to be used for scheduling for architecture ppc64le    | `2 - No Preference`
`arch.s390x`                                   | Specify weight to be used for scheduling for architecture s390x      | `2 - No Preference`
`serviceAccount.name`                          | Existing service account name                                        | `default`
`resourcesInit.enabled`                        | Enable resource init containers                                      | false
`resourcesInit.image.repository`               | Repository for resource init container images                        |
`resourcesInit.image.tag`                      | Docker image tag                                                     |
`resourcesInit.image.digest`                   | Docker image digest. Takes precedence over tag                       |
`resourcesInit.image.pullPolicy`               | Pull policy for repository                                           | `IfNotPresent`
`resourcesInit.command`                        | Command to be executed in the resource init container                |
`persistence.enabled`                          | Enable storage access to persistent volumes                          | true
`persistence.useDynamicProvisioning`           | Enable dynamic provisioning of persistent volumes                    | false 
`appResourcesPVC.enabled`                      | Enable Application resource storage                                  | true 
`appResourcesPVC.storageClassName`             | Resources persistent volume storage class name                       | ``
`appResourcesPVC.selector.label`               | Resources persistent volume selector label                           | `intent`
`appResourcesPVC.selector.value`               | Resources persistent volume selector value                           | `resources`
`appResourcesPVC.accessMode`                   | Resources persistent volume access mode                              | `ReadOnlyMany`
`appResourcesPVC.size`                         | Resources persistent volume storage size                             | 100 Mi
`appResourcesPVC.preDefinedResourcePVCName`    | Predefined resources persistent volume name                          | 
`appLogsPVC.enabled`                           | Enable Application logs storage                                  | true 
`appLogsPVC.storageClassName`                  | Logs persistent volume storage class name                            | ``
`appLogsPVC.selector.label`                    | Logs persistent volume selector label                                | `intent`
`appLogsPVC.selector.value`                    | Logs persistent volume selector value                                | `logs`
`appLogsPVC.accessMode`                        | Logs persistent volume access mode                                   | `ReadWriteMany`
`appLogsPVC.size`                              | Logs persistent volume storage size                                  | 500 Mi
`appLogsPVC.preDefinedLogsPVCName`             | Predefined logs persistent volume name                               |   
`appDocumentsPVC.enabled`                      | Enable Application document storage                                  | false
`appDocumentsPVC.storageClassName`             | Documents persistent volume storage class name                       | ``
`appDocumentsPVC.selector.label`               | Documents persistent volume selector label                           | `intent`
`appDocumentsPVC.selector.value`               | Documents persistent volume selector value                           | `documents`
`appDocumentsPVC.accessMode`                   | Documents persistent volume access mode                              | `ReadWriteMany`
`appDocumentsPVC.size`                         | Documents persistent volume storage size                             | 1Gi
`appDocumentsPVC.enableVolumeClaimPerPod'      | Enable persistent volume for Documents at pod level                  | false
`appDocumentsPVC.preDefinedDocumentPVCName`    | Predefined document persistent volume name                           |
`extraPVCs`                                    | Extra volume claims shared across all deployments                    | 
`security.supplementalGroups`                  | Supplemental group id to access the persistent volume                | 0
`security.fsGroup`                             | File system group id to access the persistent volume                 | 0
`security.fsGroupChangePolicy`                 | File system group change policy for persistent volume                | `OnRootMismatch`
`security.runAsUser`                           | The User ID that needs to be run as by all containers                | 
`security.runAsGroup`                           | The Group ID that needs to be run as by all containers              | 
`ingress.enabled`                              | Enable ingress resource                                              | false
`ingress.controller`                           | Ingress controller class                                             | nginx
`ingress.annotations`                          | Additional annotations for the ingress resource                      |
`ingress.port`                                 | Ingress or router port if not 80 or 443                              |
`dataSetup.enabled`                            | Enable database setup job execution                                  | true
`dataSetup.upgrade`                            | Upgrade an older release                                             | false
`dataSetup.image.repository`                 | DB setup container image repository                                   | 
`dataSetup.image.tag`                         | DB setup container image tag                                          | `6.2.0.3`
`dataSetup.image.digest'                      | Docker image digest. Takes precedence over tag                       |
`dataSetup.image.pullPolicy`                 | Pull policy for repository                                           | `IfNotPresent`
`dataSetup.image.pullSecret`         		  | Pull secret for repository access                                    |  `ibm-entitlement-key` 
`dataSetup.extraLabels`                        | Extra labels                                                         |
`env.tz`                                       | Timezone for application runtime                                     | `UTC`
`env.upgradeCompatibilityVerified`             | Indicate release upgrade compatibility verification done             | `false`
`env.debugMode`                                | To view debug logs during pod startup                                | `false`
`env.extraEnvs`                                | Provide extra global environment variables                           |
`logs.enableAppLogOnConsole`                   | Enable application logs redirection to pod console                   | `true` 
`integrations.seasIntegration.isEnabled`       | Enable Seas integration. For more information, please refer to the product documentation           | false
`integrations.seasIntegration.seasVersion`     | Seas version                                                         | `1.0`
`integrations.itxIntegration.enabled`          | Enable ITX integration. For more information, please refer to the product documentation            | false
`integrations.itxIntegration.dataSetup.enabled`| Enable database setup job execution for itx                          | true
`integrations.itxIntegration.image.repository` | Repository for ITX docker images                                     | 
`integrations.itxIntegration.image.tag`        | Docker image tag                                                     | 
`integrations.itxIntegration.image.digest`     | Docker image digest. Takes precedence over tag                       | 
`integrations.itxIntegration.image.pullPolicy` | Pull policy for repository                                           | `IfNotPresent`
`integrations.itxIntegration.image.pullSecret` | Pull secret for repository access                                    |
`integrations.itxIntegration.dataPVC.name`                         | Application data persistent volume claim name                   | `itxdata`
`integrations.itxIntegration.dataPVC.useDynamicProvisioning`       | Enable dynamic provisioning of persistent volumes               | true 
`integrations.itxIntegration.dataPVC.storageClassName`             | Data persistent volume storage class name                       | ``
`integrations.itxIntegration.dataPVC.selector.label`               | Data persistent volume selector label                           | `intent`
`integrations.itxIntegration.dataPVC.selector.value`               | Data persistent volume selector value                           | `itxdata`
`integrations.itxIntegration.dataPVC.accessMode`                   | Data persistent volume access mode                              | `ReadWriteMany`
`integrations.itxIntegration.dataPVC.size`                         | Data persistent volume storage size                             | 100Mi
`integrations.itxIntegration.dataPVC.preDefinedDataPVCName`        | Predefined data persistent volume name                          | 
`integrations.itxIntegration.logsPVC.name`                         | Application Logs persistent volume claim name                   | `itxlogs`
`integrations.itxIntegration.logsPVC.useDynamicProvisioning`       | Enable dynamic provisioning of persistent volumes               | true 
`integrations.itxIntegration.logsPVC.storageClassName`             | Logs persistent volume storage class name                       | ``
`integrations.itxIntegration.logsPVC.selector.label`               | Logs persistent volume selector label                           | `intent`
`integrations.itxIntegration.logsPVC.selector.value`               | Logs persistent volume selector value                           | `itxlogs`
`integrations.itxIntegration.logsPVC.accessMode`                   | Logs persistent volume access mode                              | `ReadWriteMany`
`integrations.itxIntegration.logsPVC.size`                         | Logs persistent volume storage size                             | 100Mi
`integrations.itxIntegration.logsPVC.preDefinedLogsPVCName`        | Predefined Logs persistent volume name                          | 
`integrations.itxIntegration.log.includeHostInLogNames`            | Include hostname in log file name                               | true
`integrations.itxIntegration.log.jniLog.level`                     | JNI log level                                                   | `none`
`integrations.itxIntegration.log.cmgrLog.level`                    | Connections Manager log level                                   | `none`
`integrations.itxaIntegration.enabled`          | Enable ITXA integration. For more information, please refer to the product documentation            | false
`integrations.itxaIntegration.dataSetup.enabled`| Enable database setup job execution for itxa                         | true
`integrations.itxaIntegration.image.repository` | Repository for ITXA docker images                                    | 
`integrations.itxaIntegration.image.tag`        | Docker image tag                                                     | 
`integrations.itxaIntegration.image.digest`     | Docker image digest. Takes precedence over tag                       | 
`integrations.itxaIntegration.image.pullPolicy` | Pull policy for repository                                           | `IfNotPresent`
`integrations.itxaIntegration.image.pullSecret` | Pull secret for repository access                                    |
`integrations.itxaIntegration.appSecret`        | Name of DB secret                                                    | 
`integrations.itxaIntegration.secureDBConnection.enabled`                | TLS for DB connection                                                |  false
`integrations.itxaIntegration.secureDBConnection.dbservercertsecretname` | Secret for database server certificate                               | 
`integrations.itxaIntegration.persistence.claims.name`                   | Persistent volume name                                               | 
`integrations.itxaIntegration.sso.host`                                  | Host name for ITXA UI server                                         | 
`integrations.itxaIntegration.sso.port`                                  | Port on which ITXA UI server is accessible                           | 
`integrations.itxaIntegration.sso.ssl.enabled`                           | TLS for ITXA UI server                                               |  true
`integrations.itxaIntegration.resourcesInit.enabled`                        | Enable resource init container for ITXA                              | true
`integrations.itxaIntegration.resourcesInit.image.repository`               | Repository for resource init container images                        |
`integrations.itxaIntegration.resourcesInit.image.tag`                      | Docker image tag                                                     |
`integrations.itxaIntegration.resourcesInit.image.digest`                   | Docker image digest. Takes precedence over tag                       |
`integrations.itxaIntegration.resourcesInit.image.pullPolicy`               | Pull policy for repository                                           | `IfNotPresent`
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
`setupCfg.connectionpoolFailoverEnable`         | enable connection pool failover for HA databases                                       | 
`setupCfg.adminEmailAddress`                   | Administrator email address                                          | 
`setupCfg.smtpHost`                            | SMTP email server host                                               |
`setupCfg.terminationGracePeriod`              | Termination grace period for Containers                              | 30 
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
`setupCfg.libertyJvmOptions`                   | Liberty API server JVM option (will be deprecated in future release) |
`setupCfg.defaultDocumentStorageType`        | Default document storage type                                        | `DB`
`setupCfg.restartCluster`        | restartCluster can be set to true to restart the application cluster by cleaning up all previous node entries, locks and set the schedules to node1.                                        | false
`setupCfg.useSslForRmi`                        | Enable SSL over RMI calls                                            | true
`setupCfg.rmiTlsSecretName`                    | TLS secret name holding RMI certificate/key pair	              | 
`setupCfg.sapSncSecretName`                    | Name of the secret holding SAP SNC PSE file and password along with the sapgenpse utility      | 
`setupCfg.sapSncLibVendorName`                 | SAP SNC library vendor 
name	                                         | 
`setupCfg.sapSncLibVersion`                    | SAP SNC library 
version	                                       | 
`setupCfg.sapSncLibName`                       | SAP SNC library 
name	                                         | 
`setupCfg.launchClaServer`                     | Enable to launch CLA server in ASI                                   | false
`asi.replicaCount`                             | Application server independent(ASI) deployment replica count         | 1
`asi.env.jvmOptions`                           | JVM options for asi                                                  | 
`asi.env.extraEnvs`                            | Provide extra environment variables for ASI                          | 
`asi.frontendService.type`                             | Service type                                                         | `ClusterIP`
`asi.frontendService.sessionAffinityConfig.timeoutSeconds`  | Session affinity timeout in seconds                                  | 10800
`asi.frontendService.externalTrafficPolicy`                 | Route external traffic to node-local or cluster-wide endpoints       | `Cluster`
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
`asi.frontendService.ports.ops.name`                  | Ops Server port name                                               | `ops`
`asi.frontendService.ports.ops.port`                  | Ops Server port number                                             | 35008
`asi.frontendService.ports.ops.targetPort`            | Service target port number or name on pod                          | `ops`
`asi.frontendService.ports.ops.nodePort`              | Service node port                                                  | 30008
`asi.frontendService.ports.ops.protocol`              | Service port connection protocol                                   | `TCP`
`asi.frontendService.extraPorts`                       | Extra ports for service                                              |
`asi.frontendService.loadBalancerIP`                   | LoadBalancer IP for service                                          |
`asi.frontendService.loadBalancerSourceRanges`        | LoadBalancer IP Ranges for service                                          |
`asi.frontendService.annotations`                      | Additional annotations for the asi frontendService                   |
`asi.backendService.type`                             | Service type                                                         | `LoadBalancer`
`asi.backendService.sessionAffinity`                       | Used to maintain session affinity                                    | `None`
`asi.backendService.sessionAffinityConfig.timeoutSeconds`  | Session affinity timeout in seconds                                  | 10800
`asi.backendService.externalTrafficPolicy`                 | Route external traffic to node-local or cluster-wide endpoints       | `Cluster`
`asi.backendService.ports`                       | Ports for service                                              |  
`asi.backendService.portRanges`                       | Port ranges for service                                              |
`asi.backendService.loadBalancerIP`                   | LoadBalancer IP for service                                          |
`asi.backendService.loadBalancerSourceRanges`        | LoadBalancer IP Ranges for service                                          |
`asi.backendService.annotations`                      | Additional annotations for the asi backendService                    |
`asi.livenessProbe.initialDelaySeconds`        | Livenessprobe initial delay in seconds                               | 60
`asi.livenessProbe.timeoutSeconds`             | Livenessprobe timeout in seconds                                     | 30
`asi.livenessProbe.periodSeconds`              | Livenessprobe interval in seconds                                    | 60
`asi.readinessProbe.initialDelaySeconds`       | ReadinessProbe initial delay in seconds                              | 30
`asi.readinessProbe.timeoutSeconds`            | ReadinessProbe timeout in seconds                                    | 5
`asi.readinessProbe.periodSeconds`             | ReadinessProbe interval in seconds                                   | 60
`asi.readinessProbe.command`                   | ReadinessProbe command to be executed                                |
`asi.readinessProbe.arg`                       | ReadinessProbe command arguments                                     |
`asi.startupProbe.initialDelaySeconds`         | StartupProbe initial delay in seconds                                | 300
`asi.startupProbe.timeoutSeconds`              | StartupProbe timeout in seconds                                      | 30
`asi.startupProbe.periodSeconds`               | StartupProbe interval in seconds                                     | 60
`asi.startupProbe.failureThreshold`            | StartupProbe failure threshold                                       | 6
`asi.internalAccess.enableHttps`               | Enable https for internal traffic                                    | true
`asi.internalAccess.enableHttps.httpsPort`     | Application internal https port                                      | 
`asi.internalAccess.tlsSecretName`             | Application tls secret name for internal traffic                     |   
`asi.externalAccess.protocol`                  | Protocol for application client side components to access the application                    | `http`
`asi.externalAccess.address  `                 | External address (ip/host) for application client side components to access the application  | 
`asi.externalAccess.port`                      | External port for application client side components to access the application               | 
`asi.ingress.internal.host`                    | Internal Host name for ingress resource	                          |
`asi.ingress.internal.tls.enabled`             | Enable TLS for ingress                                               | true
`asi.ingress.internal.tls.secretName`          | TLS secret name                                                      |
`asi.ingress.internal.extraPaths`              | Extra paths for ingress resource                                     | 
`asi.ingress.external.host`                    | External Host name for ingress resource	                          |
`asi.ingress.external.tls.enabled`             | Enable TLS for ingress                                               | true
`asi.ingress.external.tls.secretName`          | TLS secret name                                                      |
`asi.ingress.external.extraPaths`              | Extra paths for ingress resource                                     |    
`asi.extraPVCs`                                | Extra volume claims                                                  | 
`asi.extraInitContainers`                      | Extra init containers                                                | 
`asi.resources`                                | CPU/Memory/Ephemeral Storage resource requests/limits                                  | 
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
`asi.hostAliases`                           | Host aliases to be added to pod /etc/hosts  |
`asi.performanceTuning.allocateMemToBI`     | `true` if memory to be allocated to BI else `false` | false
`asi.performanceTuning.allocateMemToSAP`    | `true` if memory to be allocated to SAP else `false` | false 
`asi.performanceTuning.allocateMemToCLA`    | `true` if memory to be allocated to CLA else `false` | false
`asi.performanceTuning.threadsPerCore`      | Number of threads per core | 4
`asi.performanceTuning.override`            | Override Performance tuning parameters with user specified value if required | 
`asi.networkPolicies.ingress.customPolicies`| Configure custom ingress network policies for asi pods                       |
`asi.networkPolicies.egress.customPolicies` | Configure custom egress network policies for asi pods                        |
`ac.replicaCount`                             | Adapter Container server (ac) deployment replica count               | 1
`ac.env.jvmOptions`                           | JVM options for ac                                                   |
`ac.env.extraEnvs`                            | Provide extra environment variables for AC                           | 
`ac.frontendService.type`                             | Service type                                                         | `ClusterIP`
`ac.frontendService.sessionAffinityConfig.timeoutSeconds`  | Session affinity timeout in seconds                                  | 10800
`ac.frontendService.externalTrafficPolicy`                 | Route external traffic to node-local or cluster-wide endpoints       | `Cluster`
`ac.frontendService.ports.http.name`                  | Service http port name                                               | `http`
`ac.frontendService.ports.http.port`                  | Service http port number                                             | 35001
`ac.frontendService.ports.http.targetPort`            | Service target port number or name on pod                            | `http`
`ac.frontendService.ports.http.nodePort`              | Service node port                                                    | 30001
`ac.frontendService.ports.http.protocol`              | Service port connection protocol                                     | `TCP`
`ac.frontendService.extraPorts`                       | Extra ports for service                                              | 
`ac.frontendService.loadBalancerIP`                   | LoadBalancer IP for service                                          | 
`ac.frontendService.loadBalancerSourceRanges`        | LoadBalancer IP Ranges for service                                          |
`ac.frontendService.annotations`                     | Additional annotations for the ac frontendService                     |
`ac.backendService.type`                              | Service type                                                         | `LoadBalancer`
`ac.backendService.sessionAffinity`                       | Used to maintain session affinity                                    | `None`
`ac.backendService.sessionAffinityConfig.timeoutSeconds`  | Session affinity timeout in seconds                                  | 10800
`ac.backendService.externalTrafficPolicy`                 | Route external traffic to node-local or cluster-wide endpoints       | `Cluster`
`ac.backendService.ports`                       | Ports for service                                              |  
`ac.backendService.portRanges`                       | Port ranges for service                                              |
`ac.backendService.loadBalancerIP`                  | LoadBalancer IP for service                                          |
`ac.backendService.loadBalancerSourceRanges`        | LoadBalancer IP Ranges for service                                          | 
`ac.backendService.annotations`                     | Additional annotations for the ac backendService                     |
`ac.livenessProbe.initialDelaySeconds`        | Livenessprobe initial delay in seconds                               | 60
`ac.livenessProbe.timeoutSeconds`             | Livenessprobe timeout in seconds                                     | 5
`ac.livenessProbe.periodSeconds`              | Livenessprobe interval in seconds                                    | 60
`ac.readinessProbe.initialDelaySeconds`       | ReadinessProbe initial delay in seconds                              | 60
`ac.readinessProbe.timeoutSeconds`             | ReadinessProbe timeout in seconds                                   | 5
`ac.readinessProbe.periodSeconds`             | ReadinessProbe interval in seconds                                   | 60
`ac.readinessProbe.command`                   | ReadinessProbe command to be executed                                |
`ac.readinessProbe.arg`                       | ReadinessProbe command arguments                                     |
`ac.internalAccess.enableHttps`               | Enable https for internal traffic                                    | true
`ac.internalAccess.tlsSecretName`             | Application tls secret name for internal traffic                     |  
`ac.ingress.internal.host`                    | Internal Host name for ingress resource	                             |
`ac.ingress.internal.tls.enabled`             | Enable TLS for ingress                                               | true
`ac.ingress.internal.tls.secretName`          | TLS secret name                                                      |
`ac.ingress.internal.extraPaths`              | Extra paths for ingress resource                                     | 
`ac.ingress.external.host`                    | External Host name for ingress resource	                          |
`ac.ingress.external.tls.enabled`             | Enable TLS for ingress                                               | true
`ac.ingress.external.tls.secretName`          | TLS secret name                                                      |
`ac.ingress.external.extraPaths`              | Extra paths for ingress resource                                     |    
`ac.extraPVCs`                                | Extra volume claims                                                  | 
`ac.extraInitContainers`                      | Extra init containers                                                | 
`ac.resources`                                | CPU/Memory/Ephemeral Storage resource requests/limits                                  | 
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
`ac.hostAliases`                               | Host aliases to be added to pod /etc/hosts  | 
`ac.performanceTuning.allocateMemToSAP`        | `true` if memory to be allocated to SAP else `false`                 | false
`ac.networkPolicies.ingress.customPolicies`| Configure custom ingress network policies for ac pods                       |
`ac.networkPolicies.egress.customPolicies` | Configure custom egress network policies for ac pods                        |
`api.replicaCount`                             | Liberty API server (API) deployment replica count                    | 1
`api.env.jvmOptions`                           | JVM options for api (will be deprecated in future release)           |
`api.env.extraEnvs`                            | Provide extra environment variables for API                          | 
`api.frontendService.type`                             | Service type                                                         | `ClusterIP`
`api.frontendService.sessionAffinityConfig.timeoutSeconds`  | Session affinity timeout in seconds                                  | 10800
`api.frontendService.externalTrafficPolicy`                 | Route external traffic to node-local or cluster-wide endpoints       | `Cluster`
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
`api.frontendService.loadBalancerSourceRanges`        | LoadBalancer IP Ranges for service                                          |
`api.frontendService.annotations`                      | Additional annotations for the api frontendService                   |
`api.livenessProbe.initialDelaySeconds`        | Livenessprobe initial delay in seconds                               | 60
`api.livenessProbe.timeoutSeconds`             | Livenessprobe timeout in seconds                                     | 5
`api.livenessProbe.periodSeconds`              | Livenessprobe interval in seconds                                    | 60
`api.readinessProbe.initialDelaySeconds`       | ReadinessProbe initial delay in seconds                              | 60
`api.readinessProbe.timeoutSeconds`            | ReadinessProbe timeout in seconds                                    | 5
`api.readinessProbe.periodSeconds`             | ReadinessProbe interval in seconds                                   | 60
`api.readinessProbe.command`                   | ReadinessProbe command to be executed                                |
`api.readinessProbe.arg`                       | ReadinessProbe command arguments                                     |
`api.internalAccess.enableHttps`               | Enable https for internal traffic                                    | true
`api.internalAccess.tlsSecretName`             | Application tls secret name for internal traffic                     |  
`api.externalAccess.protocol`                  | Protocol for application client side components to access the application                    | `http`
`api.externalAccess.address  `                 | External address (ip/host) for application client side components to access the application  | 
`api.externalAccess.port`                      | External port for application client side components to access the application               | 
`api.ingress.internal.host`                    | Internal Host name for ingress resource	                          |
`api.ingress.internal.tls.enabled`             | Enable TLS for ingress                                               | true
`api.ingress.internal.tls.secretName`          | TLS secret name                                                      |
`api.extraPVCs`                                | Extra volume claims                                                  | 
`api.extraInitContainers`                      | Extra init containers                                                | 
`api.resources`                                | CPU/Memory/Ephemeral Storage resource requests/limits                                  | 
`api.autoscaling.enabled`                      | Enable autoscaling                                                   | false
`api.autoscaling.minReplicas`                  | Minimum replicas for autoscaling                                     | 1
`api.autoscaling.maxReplicas`                  | Maximum replicas for autoscaling                                     | 2
`api.autoscaling.targetCPUUtilizationPercentage`| Target CPU utilization                                              | 60
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
`api.hostAliases`                              | Host aliases to be added to pod /etc/hosts  | 
`api.networkPolicies.ingress.customPolicies`| Configure custom ingress network policies for api pods                  |
`api.networkPolicies.egress.customPolicies` | Configure custom egress network policies for api pods                   |
`nameOverride`                                 | Chart resource short name override                                   | 
`fullnameOverride`                             | Chart resource full name override                                    | 
`test.image.repository`                        | Repository for docker image used for helm test and cleanup           | 'ibmcom/opencontent-common-utils'
`test.image.tag          `                     | helm test and cleanup docker image tag                               | `1.1.66`
`test.image.digest          `                  | helm test and cleanup docker image digest. Takes precedence over tag |
`test.image.pullPolicy`                        | Pull policy for helm test image repository                           | `IfNotPresent`
`test.extraLabels`                            | Extra labels                                                          |
`purge.enabled`                                | Enable external purge job                                            | 'false'
`purge.image.repository          `             | External purge docker image repository                               | `purge`
`purge.image.tag          `                    | External purge image tag                                             | `6.2.0.3`
`purge.image.digest          `                 | External purge image digest. Takes precedence over tag               |
`purge.image.pullPolicy`                       | Pull policy for external purge docker image                          | `IfNotPresent`
`purge.image.pullSecret`                       | Pull secret for repository access                                    | `ibm-entitlement-key`
'purge.extraLabels'                            | Extra labels                                                         |
`purge.schedule`                               | External purge job creation and execution schedule. Its a Cron format string such as 1 * * * * or 
@hourly as schedule day/time. Please refer [Kubernetes documentation](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/#schedule)  for further details on Cron string for schedule. Please specify the schedule value in quotes    | 
`purge.startingDeadlineSeconds`                | Deadline in seconds for starting the job if it misses its scheduled time for any reason | 
`purge.activeDeadlineSeconds`                  | Duration in seconds that the external purge job will be running. Once the job reaches activeDeadlineSeconds the external purge will stop and job will be marked as Completed    | 
`purge.concurrencyPolicy`                      | Specifies behavior for concurrent execution of external purge job. Valid values are Forbid - concurrent jobs are not allowed and Replace - If it is time for the new job run and previous job has not finished yet, the new job will replace the currently running job    | `Forbid`
`purge.suspend`                                | If it is set to true, all subsequent executions are suspended. This setting does not apply to already started executions    | false
`purge.successfulJobsHistoryLimit`             | Specify how many completed external purge jobs should be kept in history   | 3
`purge.failedJobsHistoryLimit`                 | Specify how many failed external purge jobs should be kept in history      | 1
`purge.env.jvmOptions`                         | JVM options for purge                                                      | 
`purge.env.extraEnvs`                          | Provide extra environment variables for Purge Job                          | 
`purge.internalAccess.enableHttps`               | Enable https for internal traffic                                    | true
`purge.internalAccess.tlsSecretName`             | Application tls secret name for internal traffic                     |
`purge.resources`                              | CPU/Memory/Ephemeral Storage resource requests/limits for the external purge job pod         | 1 CPU and 2Gi Memory
`purge.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`   | k8s PodSpec.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".       | 
`purge.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution`  | k8s PodSpec.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution. Refer section "Affinity".	    |
|`documentService.enabled`                                             | Enable integration with document service                                                              |false     |
|`documentService.sslEnabled`                                             | Enabling client SSL on the document service                                                              |true     |
|`documentService.useGrpc`                                             | Using gRPC connection with document service                                                              |true     |
|`documentService.readBufferSize`                                      | Read buffer size for Get document service                                                             |32768     |
|`documentService.grpcPoolSize`                                      | Maximum number of pool threads for gRPC connection                                                             |150     |
|`documentService.keepAliveGrpc`                                      | Keep alive time in seconds for threads in pool for gRPC connection                                                              |300     |
|`documentService.license`                                             | Document service license agreement                                                                    |false
|`documentService.replicaCount`                                        | 	Number of replicas for the document service                                                         |1
|`documentService.image.repository`                                    |  Document service image repository                                                                     |
|`documentService.image.pullPolicy`                                    |  Document service Image pull policy                                                                    |
|`documentService.image.tag`                                           |  Document service image tag                                                                            |
|`documentService.image.pullSecret`                                    | Secret used for pulling from repositories                                                             |
|`documentService.serviceAccount.name`                                 | User wishes to use own/already created service account                                                 | default
|`documentService.application.ssl.enabled`                             |  Enabling client SSL on the document service                                                            | true
|`documentService.application.ssl.tlsSecretName`                       |  Using the TLS secret name for communication between b2bi and the document service                      |
|`documentService.application.ssl.trustStoreSecretName`               |   Using the Trust store secret name for communication between b2bi and the document service            |
|`documentService.application.ssl.clientAuth`                        |   The server type of clientAuth for the document service                                                | want
|`documentService.application.logging.level`                         |   The logging level for the document service                                                            | ERROR
|`documentService.application.objecstore.name`                       |   The name of the cloud provider                                                                                                      |      |
|`documentService.application.objecstore.classname`                  |   Specific storage class name                                                                                                      |      |
|`documentService.application.objecstore.endpoint`                   |   Accessing the Cloud Storage specific endpoint                                                                                                      |      |
|`documentService.application.objecstore.namespace`                  |   	Namespace as the top-level container for all buckets                                                                                                      |      |
|`documentService.application.objecstore.region`                     |    Object Storage data centers are located in regions                                                                                                     |      |
|`documentService.application.objecstore.secretName`                 |   Secret is the object-storage-access-keys name                                                                                                      |      |
|`documentService.connectionPoolConfig.maxTotalConnections`          |   max Total Connections handle by documentService.                                                                                                                                                   | 250     |
|`documentService.connectionPoolConfig.maxConnectionsPerRoute`       |   want to use object store type using by documentService.                                                                                                                                                   | 100     |
|`documentService.connectionPoolConfig.connectTimeout`               |   set time of documentService connectTimeout.                                                                                                                                                   | 10000     |
|`documentService.connectionPoolConfig.readTimeout`                  |   read Timeout by documentService.                                                                                                                                                   | 60000     |
|`documentService.connectionPoolConfig.idleTimeout`                  |   idle Timeout for documentService.                                                                                                                                                   | 60000     |
|`documentService.connectionPoolConfig.idleMonitorThread`            |   idle Monitor Thread for documentService.                                                                                                                                                   | true     |
|`documentService.connectionPoolConfig.waitTimeout`                  |   wait Time out by documentService.                                                                                                                                                   | 30000     |
|`documentService.connectionPoolConfig.keepAlive`                    |   keep Alive for documentService Pod.                                                                                                                                                   | 300000     |
|`documentService.connectionPoolConfig.retryCount`                   |   number of re try documentService                                                                                                                                                   |  2    |
|`documentService.connectionPoolConfig.disableContentCompression`     |  disable Content compression for documentService                                                                                                                                                    | true     |

## Upgrading the Chart

You would want to upgrade your deployment when you have a new docker image or helm chart verison or a change in configuration, for e.g. new service ports to be exposed. 

1. Ensure that the chart is downloaded locally and available.

2. Before upgrading the release for any configurations change, set the `dataSetup.enabled` as `false`

3. Run the following command to upgrade your deployments. 

```sh
helm upgrade my-release -f values.yaml ./ibm-b2bi-prod --timeout 3600s
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
* ConfigMap - <release name>-b2bi-config
* PersistentVolumeClaim if persistence is enabled - <release name>-b2bi-resources-pvc
* PersistentVolumeClaim if persistence is enabled and appLogsPVC is enabled - <release name>-b2bi-logs-pvc

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
DESTCABUNDLE=$(awk '{printf "%s\\n", $0}' ${DEST_CABUNDLE_FN})

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
