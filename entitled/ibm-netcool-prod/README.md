# IBM Netcool Operations Insight

## Introduction

IBM® Netcool® Operations Insight enables you to monitor the health and performance of IT and network infrastructure across local, cloud and hybrid environments. It also incorporates strong event management capabilities, and leverages real-time alarm and alert analytics, combined with broader historic data analytics, to deliver actionable insight into the performance of services and their associated dynamic network and IT infrastructures.

## Contents

- [Chart Details](#chart-details)
- [Prerequisites](#prerequisites)
- [Resources Required](#resources-required)
- [Installing the chart](#installing-the-chart)
- [Storage](#storage)
- [Configuration](#configuration)
- [Limitations](#limitations)
- [Documentation](#documentation)

## Chart Details

The ibm-netcool-prod Helm chart and its dependent sub-charts provide the capability to deploy the following Operations Management applications from the IBM Netcool Operations Insight solution:

- Netcool/OMNIbus Core
- Netcool/OMNIbus WebGUI
- Netcool/Impact
- IBM Operations Analytics Log Analysis
- DB2 Enterprise Server Edition database
- Message Bus gateway to support interaction between the components
- Cloud Native Event Analytics 

The chart also deploys one of the following components required to enable Operations Management.

- openLDAP server - for use when no external LDAP connection is required.
- openLDAP proxy - to connect to an existing LDAP server outside of the deployment.

For more information on how these applications work together to provide Netcool Operations Insight functionality, see
[Netcool Operations Insight documentation: Operations Management data flow](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/concept/soc_int_dataflows_noi.html).

## Prerequisites

- [Basic prerequisites](basic_prerequisites)
- [Store passwords in secrets](store_passwords_in_secrets)
- [Role Based Access](role_based_access)
- [PodSecurityPolicy Requirements]([podSecurityPolicy_requirements)
- [Red Hat OpenShift SecurityContextConstraints Requirements](red_hat_openShift_securityContextConstraints_requirements)

### Basic prerequisites

The following prerequisites are required for a successful installation.

- A Kubernetes cluster. For more information on the cluster, see  [Netcool Operations Insight documentation: Operations Management deployment on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/concept/soc_int_noicontphysicaldeplexample.html).
- Kubernetes v1.11.0 or later, and Tiller v2.9.1 or later.
- Helm 2.9.1 and later version.
- PersistentVolume support on the cluster.
- Kubernetes command line interface (`kubectl`) installed and able to communicate with the cluster. For more information, including the required version of `kubectl`, see [Accessing your cluster using kubectl](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/manage_cluster/cfc_cli.html).
- Helm client. For more information, including the required version of the Helm command line interface, see [Setting up the Helm CLI](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/app_center/create_helm_cli.html).
- Helm charts and images loaded into your catalog. For more information, see [Loading the archive into IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_loading-into-icp.html).
- _Optional_: Custom passwords set for Netcool Operations Insight applications. For more information, see [Netcool Operations Insight documentation: Configuring passwords and secrets](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int-creating_passwords_and_secrets.html).

For more information on prerequisites, see  [Netcool Operations Insight Documentation: Preparing for installation on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/soc_int_preparing-icp-installation.html).

### Store passwords in secrets.
  Following our security requirements, we do not install with default passwords. There are two options for password generation. 
 - The install will generate random passwords and store these passwords in secrets, which you can extract after the install.  
 - You can create the passwords in secrets prior to install, where you choose the password [following these guidelines](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/soc_int_preparing-icp-installation.html).
  
### Role Based Access
  Our pods require access to information on kubernetes  resources(services, configmaps and pods). This access is granted using [Role Based Access (RBAC)](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int-configuring_pod_access_control.html).
   
  
    
### PodSecurityPolicy Requirements

This chart requires a pod security policy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator set up a custom pod security policy for you:

  - Using predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp).
  - [Configure PodSecurityPolicy](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int-configuring_pod_access_control.html).
  - Custom PodSecurityPolicy definition:
  
```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-privileged-psp
    spec:
      allowPrivilegeEscalation: true
      allowedCapabilities:
      - '*'
      allowedUnsafeSysctls:
      - '*'
      fsGroup:
        rule: RunAsAny
      hostIPC: true
      hostNetwork: true
      hostPID: true
      hostPorts:
      - max: 65535
        min: 0
      privileged: true
      runAsUser:
        rule: RunAsAny
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      volumes:
      - '*'
```

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. Choose either a predefined SecurityContextConstraints or have your cluster administrator set up a custom SecurityContextConstraints for you:
  - Use the predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.
  - [Configure SecurityContextConstraints](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int-configuring_pod_access_control.html).
  - Create a custom SecurityContextConstraints resource. From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints:  
  Custom SecurityContextConstraints definition:   
  
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      name: ibm-chart-dev-scc
    readOnlyRootFilesystem: false
    allowedCapabilities:
      - '*'
    allowedUnsafeSysctls:
    - '*'
    fsGroup:
      rule: RunAsAny
    hostIPC: true
    hostNetwork: true
    hostPID: true
    hostPorts:
    - max: 65535
      min: 0
    privileged: true
    runAsUser:
      rule: RunAsAny
    seLinux:
      rule: RunAsAny
    supplementalGroups:
      rule: RunAsAny
    volumes:
    - '*'
    ```   


## Resources Required

The ibm-netcool-prod Helm chart and its dependent sub-charts have the following minimum resource requirements.

**Note**: This bare minimum setup will not provide production-like
performance; however, it will be sufficient for demonstration purposes.

- 4 virtual machines in your Kubernetes cluster, assigned as follows:
    - 1 master/management/proxy/boot node.
    - 3 amd64 worker nodes.
- Master node and each worker node must meet the following resource requirements:
    - 8 CPUs.
    - 16 GB memory.
- vSphere or local storage are the currently supported storage classes.


## Installing the Chart

You can install the ibm-netcool-prod chart from the user interface or from the command line. Whenever you install the chart a new release is created. The chart can be installed multiple times into the same cluster. Each release can be independently managed and upgraded.

This section contains the following subsections:

- Installing from the GUI.
- Installing from the command line.
- Uninstalling the chart.

### Installing from the GUI

1. In the **IBM Cloud Private** banner at the top of the page, click **Catalog** on the right hand side of the banner.

2. Enter netcool in the **Filter** field.

3. Click the **ibm-netcool-prod** Helm chart.

4. To configure the installation, click **Configure** and complete the following fields:

  - **Configuration** section

      - **Helm release name**: Name your release. Make sure that the name does not start with a number or a capital letter.

      - **Target namespace**: Install into the `default` namespace, or into a prespecified custom namespace.

      - **Target Cluster**: Name of the cluster where you would like to deploy.

      - Click **I have read and agreed to the license agreement**.

      - Select **All parameters** to display the **Global** section.

  - **Parameters** section

    - **Master node**: Specify the fully qualified domain name (FQDN) of the master node on your network. This value will be used to construct ingress URLs to access NOI services. This field corresponds to the `global.cluster.fqdn` parameter in the ibm.netcool `values.yaml` file.  **Note**: The FQDN must match the value of the cluster_CA_domain (certificate authority domain) defined in the cluster/config.yaml file. This value must also be mapped to the master node IP address in the /etc/hosts file.
    
    - **Https port**: Port the cluster HTTPS ingress is running on .  This field corresponds to the `global.ingress.port` parameter in the ibm.netcool `values.yaml` file.
    
    - **Image repository**: Docker repository that all component images are pulled from.

    - **Docker image repository secret**: This secret must be created prior to install. Name of Kubernetes secret containing credentials to access Docker registry.  This field corresponds to the `global.image.secret` parameter in the ibm.netcool `values.yaml` file.

    - **ASM release name**: If you plan to install the optional Service Management extension, then specify the release name that you plan to use to deploy the Agile Service Manager solution extension. Make sure that the name does not start with a number or a capital letter. When you install Agile Service Manager on IBM Cloud Private you must make sure to use release name that you specified in this field.

    - **Enable ASM integration**: Enable to deploy the optional Agile Service Manager solution extension.

    - **Environment size**: Controls the resource sizes the value can be either 'size1' or 'size0'.Size0 is a minimal spec for evaluation or development purposes. This field corresponds to the `global.environmentSize` parameter in the ibm.netcool `values.yaml` file.
 
    - **ServiceAccount under which your pods will run**: This must match the serviceAccount setup in the PreReqs under the RBAC section .  This field corresponds to the `global.rbac.serviceAccountName` parameter in the ibm.netcool `values.yaml` file.

    - **Create required RBAC RoleBindings**: Enable to create required service account and role bindings. See http://ibm.biz/install_noi_icp. Enable only if a cluster admin is installing..  This field corresponds to the `global.rbac.create` parameter in the ibm.netcool `values.yaml` file.

    - **Use existing TLS certificate secrets**: To use your own TLS certificate secrets instead of automatically generated ones, select this option.  This field corresponds to the `global.tls.certificate.useExistingSecret` parameter in the ibm.netcool `values.yaml` file.
    
    - **Indicate that all password secrets have been created prior to install**: Click if you have already created secrets for all passwords. If this is false random passwords will be generated for secrets not created.  [Netcool Operations Insight Documentation: Configuring passwords and secrets ](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int-creating_passwords_and_secrets.html). This field corresponds to the `global.users.secretsCreatedPreInstall` parameter in the ibm.netcool `values.yaml` file.
  
    - **Enable sub-chart resource requests**: Choose whether to enable the sub-chart resource requests, or disable the requests so that there is no check on the resources required for the release. For example, to specify a small three worker node system, you must disable the sub-chart resource requests by setting this field to `false`. This field corresponds to the `global.resource.requests.enable` parameter in the ibm.netcool `values.yaml` file.

    - **Enable anti-affinity**: Enable this setting to prevent primary and backup server pods from being installed on the same worker node.

    - **Enable data persistence (Recommended)**: Enable this setting to ensure that data continues to be available if the pod needs to restart. If data persistence is disabled, data will be lost between pod restarts.

    - **Use dynamic provisioning**: Enable this setting to ensure that storage volumes are created automatically in the cluster as and when required.

    - **Number of Impact server instances**: Define the number of Impact server instances that are required.

    - **LDAP mode**: Choose whether to install the built-in LDAP server (openLDAP server) that comes with Netcool Operations Insight, or to install a proxy LDAP server and connect to your organization's LDAP server. This field corresponds to the `global.ldapservice.mode` parameter in the ibm.netcool `values.yaml` file.
      - `standalone`: install the built-in LDAP server.
      - `proxy`: install the proxy to connect to your organization's LDAP server. **Note**: If you select this option, then you must set custom values for all of the other LDAP parameters on this screen to match your organization's LDAP server.

    - **LDAP Server URL**: If you set **LDAP mode** to proxy, then you must configure the URL of your organization's LDAP server. Use the format `ldap://<IP address or hostname>:port`. This field corresponds to the `global.ldapservice.internal.url` parameter in the ibm.netcool `values.yaml` file.

    - **LDAP Server port**: If you set LDAP mode to proxy, then you must configure the port of your organization's LDAP server.  This field corresponds to the `global.ldapservice.internal.ldapPort` parameter in the ibm.netcool `values.yaml` file.

    - **LDAP Server SSL port**: If you set LDAP mode to proxy, then you must configure the SSL port of your organization's LDAP server.  This field corresponds to the `global.ldapservice.internal.ldapSSLPort` parameter in the ibm.netcool `values.yaml` file.

    - **LDAP Directory Information Tree top entry**: If you set LDAP mode to proxy, then you must configure the top entry in the LDAP Directory Information Tree (DIT). Use the standard domain settings as configured in your organization.  This field corresponds to the `global.ldapservice.internal.suffix` parameter in the ibm.netcool `values.yaml` file.

    - **LDAP base entry**: If you set LDAP mode to proxy, then you must configure the LDAP base entry by specifying the base distinguished name (base DN).  This field corresponds to the `global.ldapservice.internal.baseDN` parameter in the ibm.netcool `values.yaml` file.

    - **LDAP bind userid**: If you set LDAP mode to proxy, then you must configure the LDAP bind user identity by specifying the bind distinguished name (bind DN).  This field corresponds to the `global.ldapservice.internal.bindDN` parameter in the ibm.netcool `values.yaml` file.

        You must also create a Kubernetes secret containing password information for your organization's LDAP server, as described in [Netcool Operations Insight Documentation: Configuring passwords and secrets](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int-creating_passwords_and_secrets.html).

  - **Event Analytics settings** section

    - **Temporal Group Policies Deploy First**: Enables or Disable the deploy first / review first option for Temporal policies.

5. Do not change the values in any of the other fields.

6. Click **Install**. Monitor the progress of the installation, as described in [Netcool Operations Insight Documentation: Installing Operations Management on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_installing-opsmg-icpt.html).

7. Review the post-installation tasks, as described in [Netcool Operations Insight Documentation: Post-installation tasks](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_post-install-tasks-icp.html).

### Installing from the command line

The helm install command is a very powerful command with many capabilities. To learn more about it, refer to the [Using Helm Guide](https://docs.helm.sh/helm/#helm-install).

1. Configure the installation by editing the `values.yaml` file (or in the `custom-values.yaml` file, if you copied `values.yaml` to a custom file.

2. Run the following command to install  Netcool Operations Insight.
```
helm install ibm-netcool-prod -f values.yaml --tls --name <release_name>
```
Where:

 - `values.yaml` is the name of the configuration file containing the configuration parameters. The content of this file is described in the **Configuration** section.
 - `<release_name>` is an optional name for this release. If you do not specify a name, the system will assign a name.

3. Review the post-installation tasks, as described in [Netcool Operations Insight Documentation: Post-installation tasks](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_post-install-tasks-icp.html).

### Uninstalling the chart

Uninstall the chart by performing the following steps:

1. Run the following Helm command to determine which releases of Operations Management on IBM Cloud Private are installed.
```
helm ls --tls
```
2. Delete each release identified in the previous step by running the following Helm command against each release name in turn.
```
helm delete --purge --tls <release_name>
```
Where `<release_name>`  is the name of one of the releases identified in the previous step.

3. Repeat the previous step until all of the relevant releases are deleted.

4. Run the following command to delete the charts.
```
cloudctl catalog delete-chart --name ibm-netcool-prod --repo local-charts
```
**Note**: Persistent volumes (PVs) and persistent volume claims (PVCs) are not deleted. You must remove these manually, if desired. You can also opt to keep the data and redeploy using the existing PVCs, and they will bind.

## Configuration

The following tables lists the configuration parameters of the chart and the values to which they must be set. These parameters are defined in the `values.yaml` file (or in the `custom-values.yaml` file, if you copied `values.yaml` to a custom file).

### Required parameters
You must set values for these parameters.

| Parameter name                           | Description                                        | Default   |
|--------------------------------|----------------------------------------------------|-----------|
|`global.cluster.fqdn` | **Master node hostname or IP address** Hostname or IP address of the master node in your cluster               | No default value      |
|`global.license` | **Accept the license terms** Set to 'accept' if you agree with the license terms | not accepted  |
|`global.ingress.port` | **Https port** Port the cluster HTTPS ingress is running on | 443  |
|`global.environmentSize` | **Environment size** Controls the resource sizes the value can be either 'size1' or 'size0' | size0 |
|`global.rbac.serviceAccountName` | **ServiceAccount under which your pods will run** This must match the serviceAccount setup in the PreReqs under the RBAC section | noi-service-account      |
|`global.rbac.create`         | **Create necessary RBAC authorization** Setting `rbac.create` to true ensures that the service account in the namespace being deployed to has the minimum required authorization to install this product. This is achieved by creating two rolebindings in the namespace being deployed to. One binding ensures that the pods are allowed read/patch some of the kubernetes services created. The other binding ensures the privileged pod security policy can be used by the db2 pod. | false|
|`global.tls.certificate.useExistingSecret` | **Use existing TLS certificate secrets** To use your own TLS certificate secrets instead of automatically generated ones, select this option. | false      |
|`global.users.secretsCreatedPreInstall` | **Indicate that all password secrets have been created prior to install** Click if you have already created secrets for all passwords. If this is false random passwords will be generated for secrets not created. | false      |
|`global.resource.requests.enable`                     | **Enable sub-chart resource requests** Flag indicating whether to enable the sub-chart resource requests, or disable the requests so that there is no check on the resources required for the release. For example, to specify a small three worker node system, you must disable the sub-chart resource requests by setting this field to `false`.                | No default value         |
|`global.ldapservice.mode`         | **LDAP mode** Flag indicating whether to install the built-in standalone LDAP server (openLDAP server) that comes with Netcool Operations Insight, or to install a proxy LDAP server and connect to your organization's LDAP server.                      | standalone|
|`global.ldapservice.internal.url`         | **LDAP Server URL** If you set `global.ldapservice.mode` to proxy, then you must configure the URL of your organization's LDAP server. Use the format `ldap://<IP address or hostname>:port`.                      | No default value|
|`global.ldapservice.internal.ldapPort`         | **LDAP Server port** If you set`global.ldapservice.mode` to proxy, then you must configure the port of your organization's LDAP server.                      | 389|
|`global.ldapservice.internal.ldapSSLPort`         | **LDAP Server SSL port** If you set `global.ldapservice.mode` to proxy, then you must configure the SSL port of your organization's LDAP server.                      | 636|
|`global.ldapservice.internal.suffix`         | **LDAP Directory Information Tree top entry** If you set `global.ldapservice.mode` to proxy, then you must configure the top entry in the LDAP Directory Information Tree (DIT). Use the standard domain settings as configured in your organization.                      | dc=mycluster,dc=icp|
|`global.ldapservice.internal.baseDN`         | **LDAP base entry** If you set `global.ldapservice.mode` to proxy, then you must configure the LDAP base entry by specifying the base distinguished name (base DN).                      | dc=mycluster,dc=icp|
|`global.ldapservice.internal.bindDN`         | **LDAP bind userid** If you set `global.ldapservice.mode` to proxy, then you must configure the LDAP bind user identity by specifying the bind distinguished name (bind DN).  You must also create a Kubernetes secret containing password information for your organization's LDAP server, as described in the [Netcool Operations Insight documentation: Overwriting the LDAP password](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_overwriting-ldap-password.html)                     | cn=admin,dc=mycluster,dc=icp|
|`global.persistence.storageClassOption.cassandradata`   | **Cassandra Data Storage Class** The persistent volume storage class for the cassandra service. | local-storage-cassandra|
|`global.persistence.storageClassOption.cassandrabak`  | **Cassandra Backup Storage Class** The persistent volume storage class for the cassandra backup service. | local-storage-cassandra-bak|
|`global.persistence.storageClassOption.zookeeperdata` | **Zookeeper Data Storage Class** The persistent volume storage class for the zookeeper service.  | local-storage-zookeeper|
|`global.persistence.storageClassOption.kafkadata`     | **Kafka Data Storage Class** The persistent volume storage class for the kafka service.  | local-storage-kafka|
|`global.persistence.storageClassOption.couchdbdata`   | **CouchDB Data Storage Class** The persistent volume storage class for the couchDB service.  | local-storage-couchdb|
|`db2ese.pvc:storageClassName`  | **DB2 Data Storage Class** The storage class name for the DB2 service.   | local-storage-db2|
|`ncoprimary.pvc:storageClassName`   | **Primary Object Server Data Storage Class** The storage class name for the Primary Object Server. | local-storage-ncoprimary|
|`ncobackup.pvc:storageClassName`   | **Backup Object Server Data Storage Class** The storage class name for the Backup Object Server. | local-storage-ncobackup|
|`nciserver.pvc:storageClassName`   | **Primary Impact Server Data Storage Class** The storage class name for the Primary Impact Server. | local-storage-nciserver|
|`impactgui.pvc:storageClassName`   | **Impact GUI Data Storage Class** The storage class name for the Impact GUI. | local-storage-impactgui|
|`scala.pvc:storageClassName`   | **Log Analysis Data Storage Class** The storage class name for Log Analysis. | local-storage-scala|
|`openldap.pvc:storageClassName`  |**LDAP Authentication Storage Class** The storage class name for LDAP Authentication. | local-storage-openldap|


### Other parameters
Do not change the values of any of the other parameters.

## Storage

You must create storage prior to your installation of Operations Management on IBM Cloud Private.

Due to the high I/O bandwidth and low network latency that is required by Operations Management on IBM Cloud Private services, network-based storage options such as Network File System (NFS) and GlusterFS are not supported. vSphere or local storage are the currently supported storage classes.

For more information on storage requirements and the steps required to set up your storage, see [Netcool Operations Insight Documentation: Requirements for an installation on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/reference/soc_int_reqsforcloudinstallation.html).


## Limitations

* Platform limited, only supports `amd64` worker nodes.
* StatefulSet are not currently scalable.
* IBM Netcool Operations Insight has been tested on version 3.2.0 of IBM Cloud Private.
* IBM Netcool Operations Insight does not support IBM Kubernetes Service.

## Documentation

Full documentation on deploying the ibm-netcool-prod chart can be found in the [Netcool Operations Insight documentation](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/collaterals/soc_netops_kc_welcome.html).
