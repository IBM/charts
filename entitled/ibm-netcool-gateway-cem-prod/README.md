# IBM Netcool/OMNIbus Gateway for IBM Cloud Event Management

This Helm chart deploys IBM Netcool/OMNIbus Gateway for Cloud Event Management
onto Kubernetes. This gateway processes events and alerts from
IBM Netcool/OMNIbus ObjectServer and forwards them to IBM Cloud Event Management (CEM) dashboard.

## Introduction

IBM® Netcool® Operations Insight (NOI) enables IT and network operations teams to increase effectiveness, efficiency
and reliability by leveraging cognitive analytics capabilities to identify, isolate and resolve problems before
they impact your business. It provides a consolidated view across your local, cloud and hybrid environments and
delivers actionable insight into the health and performance of services and their associated dynamic network and
IT infrastructures. More information can be seen here: [IBM Marketplace - IT Operations Management](https://www.ibm.com/uk-en/marketplace/it-operations-management)

## Chart Details

- Deploys IBM Netcool/OMNIbus Gateway for IBM Cloud Event Management (CEM) onto Kubernetes to forward NOI events into CEM dashboard.
- This chart can be deployed more than once on the same namespace.

## Prerequisites

- Kubernetes 1.11
- Tiller 2.9.1
- IBM Netcool Operations Insight 1.6.0.1 Helm Chart version 2.1.1. This solution requires IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the chart. To create and run the IBM Tivoli Netcool/OMNIbus ObjectServer, see installation instructions at [IBM Knowledge Center - Installing on IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/en/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/integration/task/int_installing-on-icp.html).
- IBM Cloud Event Management Helm Chart version 2.4.0
- The Administrator role is the minimum role required to install this chart in order to.
    - Retrieve and edit sensitive information from a secret such as the credentials to use to authenticate with the ObjectServer or replace the Key database files for secure communications with the ObjectServer.
  - The chart must be installed by a Cluster Administrator to perform the following tasks in addition to those listed above:
    - Create a new namespace with custom PodSecurityPolicy if necessary. See PodSecurityPolicy Requirements [section](#podsecuritypolicy-requirements) for more details.
- A custom service account must be created in the namespace for this chart. Perform one of the following actions:
  - Have the Cluster Administrator pre-create the custom service account in the namespace. This installation requires the service account name to specified to install the chart and can be done by an Administrator.
  - Have the Cluster Administrator perform the installation without specifying a service account name so that the chart generates a service account and use it. When the Helm release is deleted, the service account will also be deleted.
- If secured communication is required or enabled on your Netcool/OMNIbus ObjectServer, a pre-created secret is required for this chart to establish a secured connection with the ObjectServer.
- Additional ObjectServer fields required in the `alerts.status` table for IBM CEM integration. Refer to [Integrating IBM Cloud Event Management (CEM) with Netcool Operations Insight section](#integrating-ibm-cloud-event-management-cem-with-netcool-operations-insight) for the SQL (Structured Query Language) to add the required fields. For NOI on ICP, the required fields are already added.
- The Cloud Event Management must have a valid signed certificate. Refer to [add Ingress TLS secret](https://www.ibm.com/support/knowledgecenter/SSURRN/com.ibm.cem.doc/em_cem_install_configuration.html#reference_c3y_xhq_22b).
- The secured communication between Cloud Event Management and the gateway is required. If the CEM is using a self-signed certificate then a pre-created secret is required for this chart to establish a secure trusted connection with the Cloud Event Management. The secret must contain `tls.crt` which is the CEM TLS certificate file in PEM format. You must set `cemgateway.cemTlsSecretName` parameter to this secret name.
- You must store CEM gateway sensitive information in a pre-created secret. The secret contains CEMWebhookURL, NewKeystorePassword and HttpAuthenticationPassword. You must set cemgateway.cemSecretName to this secret name.
  - CEMWebhookURL is the CEM webhook URL.
  - HttpAuthenticationPassword is the HTTP basic authentication password string which is required by the test pod (`helm test`). This is only used by an internal API to check the liveness of the CEM Gateway.
  - NewKeystorePassword is the new password to access truststore used by the gateway. This is an optional key in the secret.


### Resources Required

- CPU Requested : 100m (100 millicpu)
- Memory Requested : 128Mi (~ 134 MB)

### PodSecurityPolicy Requirements

On non-Red Hat OpenShift Container Platform, this chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart. The predefined PodSecurityPolicy definitions can be viewed [here](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/README.md).

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory. Detailed steps to create the PodSecurityPolicy is documented [here](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_common_psp.html).

* From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  * Custom PodSecurityPolicy definition:
    ```
    apiVersion: policy/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is the most restrictive,
          requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
        cloudpak.ibm.com/version: "1.1.0"
      name: ibm-netcool-gateway-cem-prod-psp
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
      runAsGroup:
        rule: MustRunAs
        ranges:
        - min: 1
          max: 65535
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

    ```
  * Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-netcool-gateway-cem-prod-clusterrole
    rules:
    - apiGroups:
      - policy
      resourceNames:
      - ibm-netcool-gateway-cem-prod-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
  * RoleBinding for all service accounts in the current namespace. Replace `{{ NAMESPACE }}` in the template with the actual namespace.
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: ibm-netcool-gateway-cem-prod-rolebinding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ibm-netcool-gateway-cem-prod-clusterrole
    subjects:
    - apiGroup: rbac.authorization.k8s.io
      kind: Group
      name: system:serviceaccounts:{{ NAMESPACE }}
    ```
* From the command line, you can run the setup scripts included under pak_extensions.
  
  As a cluster administrator, the pre-install scripts and instructions are located at:
  * pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin/operator the namespace scoped scripts and instructions are located at:
  * pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

### Red Hat OpenShift SecurityContextConstraints Requirements

On Red Hat OpenShift Container Platform, this chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
      annotations:
        kubernetes.io/description: "This policy is the most restrictive,
          requiring pods to run with a non-root UID, and preventing pods from accessing the host.
          The UID and GID will be bound by ranges specified at the Namespace level."
        cloudpak.ibm.com/version: "1.1.0"
      name: ibm-netcool-gateway-cem-prod-scc
    allowHostDirVolumePlugin: false
    allowHostIPC: false
    allowHostNetwork: false
    allowHostPID: false
    allowHostPorts: false
    allowPrivilegedContainer: false
    allowPrivilegeEscalation: false
    allowedCapabilities: null
    allowedFlexVolumes: null
    allowedUnsafeSysctls: null
    defaultAddCapabilities: null
    defaultAllowPrivilegeEscalation: false
    forbiddenSysctls:
      - "*"
    fsGroup:
      type: MustRunAs
      ranges:
      - max: 65535
        min: 1
    readOnlyRootFilesystem: false
    requiredDropCapabilities:
    - ALL
    runAsUser:
      type: MustRunAsNonRoot
    seccompProfiles:
    - docker/default
    seLinuxContext:
      type: RunAsAny
    supplementalGroups:
      type: MustRunAs
      ranges:
      - max: 65535
        min: 1
    volumes:
    - configMap
    - downwardAPI
    - emptyDir
    - persistentVolumeClaim
    - projected
    - secret
    ```
- From the command line, you can run the setup scripts included under pak_extensions
  As a cluster admin the pre-install instructions are located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped instructions are located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

## Securing Gateway and ObjectServer Communication

There are several mechanisms to secure Netcool/OMNIbus system. Authentication can be used to
restrict user access while Secure Sockets Layer (SSL) protocol can be used for different levels of encryption.

The gateway connection mode is dependant on the server component configuration. 
Check with your Netcool/OMNIbus Administrator whether the server is configured 
with either secured mode enabled without SSL, SSL enabled with secured mode disabled, 
or secured mode enabled with SSL protected communications.

The chart must be configured according to the server components setup in order to 
establish a secured connection with or without SSL. 
This can be configured by setting the `netcool.connectionMode` chart parameter with one of these options:

* `AuthOnly` - Use this mode when the ObjectServer is configured to run in secured mode without SSL. This is the default mode.
* `SSLAndAuth` - Use this mode the ObjectServer is configured with SSL and secure mode.

To secure the communications between gateway clients and the ObjectServer, there are several tasks 
that must be completed before installing the chart. Please refer to [Pre-installation Tasks section](#pre-installation-tasks) for details.

**Note** There are several known limitations listed in the [Limitations section](#limitations) when securing communications.

## Role-Based Access Control

Role-Based Access Control (RBAC) is applied to the chart by using a custom service account having a specific role binding. RBAC provides greater security by ensuring that the chart operates within the specified scope. Refer to [Role-Based Access Control page](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_role_based_access.html) in IBM Knowledge Center for more details to create the RBAC resources.

## Pre-installation Tasks

### 1. Gathering ObjectServer Details

For the gateway to successfully connect to ObjectServer, the gateway must be configured with:
  1. ObjectServer host or service details
  2. ObjectServer TLS certificate if SSL protected communication is enabled.
  3. Credentials to authenticate with the ObjectServer.

Note: In production environments, it is recommended to use TLS/SSL enabled communications with the ObjectServer.

Follow these steps to obtain the required details for the ObjectServer:

1. Contact your administrator to find out the ObjectServer that the CEM Gateway should connect to. Note the NOI release name and namespace as `NOI_RELEASE_NAME` and `NOI_NAMESPACE` respectively. This information will be used when preparing the ObjectServer communication Kubernetes secret later.
2. Determine the ObjectServer NodePort service name and port number. Refer to the [Connecting with the ObjectServer NodePort](https://www.ibm.com/support/knowledgecenter/en/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/config/task/cfg_configuring-os-direct.html) for more info on identifying the ObjectServer NodePort and note down the service names and the NodePort number as `NOI_OBJECT_SERVER_PRIMARY_SERVICE` and `NOI_OBJECT_SERVER_PRIMARY_PORT` respectively. You may also note the backup ObjectServer service if you wish to connect to the backup ObjectServer too as `NOI_OBJECT_SERVER_BACKUP_SERVICE` and `NOI_OBJECT_SERVER_BACKUP_PORT` respectively . This information will be used when configuring the chart.
3. Determine the TLS Proxy listening port by following the steps in [Identifying the proxy listening port](https://www.ibm.com/support/knowledgecenter/en/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/config/concept/cfg_configuring-event-sources.html) page and note down the TLS proxy Common Name (CN) and port number as `NOI_TLS_PROXY_CN` and `NOI_TLS_PROXY_PORT` respectively. This information will be used when configuring the chart.
4. Determine the TLS Proxy certificate Kubernetes secret that should be used by the CEM Gateway. This is usually set in `{{ Release.Name}}-proxy-tls-secret` secret, where  `{{ Release.Name }}` is the NOI release name. Note down the secret name and namespace. This information will be used when preparing the ObjectServer communication Kubernetes secret later.
5. Get the ObjectServer user password which is required by the Gateway when creating and Insert, Delete, Update, or Control (IDUC) communication protocol connection. The credential is provided in the `{{ Release.Name }}-omni-secret`, where `{{ Release.Name }}` is the NOI release name.
6. Obtain the cluster proxy IP address 

The "Gathered Facts" table below lists the details that is gathered from the above steps. These items will be referenced in the following sections.

| Item | Description and sample value |
| ---- | ---------------------------- | 
| CLUSTER_MASTER_IP | The cluster master node IP address. This should be set as the `netcool.primaryIP` and optionally `netcool.backupIP` to also connect to the backup ObjectServer. |
| CLUSTER_MASTER_HOST | The cluster master node hostname. This should be set as the `netcool.primaryHost` and optionally `netcool.backupHost` to also connect to the backup ObjectServer. |
| NOI_RELEASE_NAME | The NOI release name. For example, `noi-m76` |
| NOI_NAMESPACE | Namespace where NOI is installed. For example, `default` |
| NOI_OBJECT_SERVER_PRIMARY_SERVICE | The primary ObjectServer Nodeport service. For example, `noi-m76-objserv-agg-primary-nodeport`. This should be set as the `netcool.primaryIDUCHost` parameter.  |
| NOI_OBJECT_SERVER_PRIMARY_PORT | The primary ObjectServer Nodeport number. This should be set as the `netcool.primaryPort` parameter. |
| NOI_OBJECT_SERVER_BACKUP_SERVICE | (Optional) The backup ObjectServer Nodeport service. For example `noi-m76-objserv-agg-backup-nodeport`. This should be set as the `netcool.backupIDUCHost` parameter. |
| NOI_OBJECT_SERVER_BACKUP_PORT | (Optional) The backup ObjectServer Nodeport number |
| NOI_TLS_PROXY_CN | The NOI TLS certificate subject Common Name. For example `proxy.noi-m76.mycluster.icp`. This should be set as the `netcool.primaryHost` (and optionally `netcool.backupHost`). For more details on how to obtain the Subject Common Name, refer to [Configuring TLS encryption with the default certificate](https://www.ibm.com/support/knowledgecenter/en/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/config/task/cfg_configuring_tls_encryption.html) or [Configuring TLS encryption with a custom certificate](https://www.ibm.com/support/knowledgecenter/en/SSTPTP_1.6.0/com.ibm.netcool_ops.doc/soc/config/task/cfg_configuring_tls_encryption_custom.html) pages.| 
| NOI_TLS_PROXY_PORT_1 | The NOI TLS Proxy service port number (first port). |
| NOI_TLS_PROXY_PORT_2 | (Optional) The NOI TLS Proxy service port number (second port), required to connect to backup ObjectServer. |
| NOI_TLS_SECRET_NAME | Secret name containing the TLS certificate of the TLS Proxy. For example `noi-m76-proxy-tls-secret` |
| NOI_OMNI_USER | Username for IDUC connection. |
| NOI_OMNI_PASSWORD | Password for IDUC connection. |


### 2. Preparing ObjectServer communication secret

The secret can be created using the utility script ("create-noi-secret.sh") provided in the `pak_extensions/pre-install` directory. Before running this script, several information must be gathered and then configured in the script's configuration file ("create-noi-secret.config") which should be obtained following the steps in "Gathering ObjectServer Details" section above.

For this task, you will need the CEM Gateway image in your local file system because the script requires several utility commands such as `nco_gskcmd` and `nco_aes_crypt` to add the ObjectServer certificate into the key database.

1. Follow the steps in [Pushing and pulling images](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/manage_images/using_docker_cli.html) to pull the CEM Gateway image `netcool-gateway-cem` into your local file system. The following steps uses `netcool-gateway-cem:latest` as the image name and image tag for simplicity.
2. From the command line, review and update the create-noi-secret.sh utility script configuration file (`create-noi-secret.config`) file provided in the `pak_extensions/pre-install` directory. Several items from the "Gathered Facts" table above is required when configuring the script.
3. Run the "create-noi-secret.sh" to create the Gateway-ObjectServer communication secret. The script should be run as an administrator or a user with read permissions to the NOI TLS secret so that the script can retrieve the TLS certificate file.
4. Optionally, verify that the secret is successfully created using the `kubectl describe secret <secret name> --namespace <namespace>` command.

```
kubectl describe secret cem-gw-noi-secret --namespace cemgw-ns
Name:         cem-gw-noi-secret
Namespace:    cemgw-ns
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
omni.sth:            193 bytes
AuthPassword:        70 bytes
AuthUserName:        4 bytes
encryption.keyfile:  36 bytes
omni.kdb:            10088 bytes
```

### 3. Preparing the Cloud Event Management (CEM) Incoming Integration

To forward events from IBM Netcool Operations Insight (NOI) to IBM CEM, the `ibm-cem` chart can be installed in the same cluster as NOI or in another cluster. NOI and the CEM Gateway need to be installed in the same cluster. Detailed steps to install and configure IBM CEM in IBM Cloud Private (ICP) can be found on this [page](https://www.ibm.com/support/knowledgecenter/en/SSURRN/com.ibm.cem.doc/em_cem_install_configuration.html).

The CEM Gateway requires the CEM webhook URL from the Netcool/OMNIbus Incoming Integration in CEM. Follow the steps below to create the incoming integration.

1. Login to the CEM User Interface as an administrator.
2. Click **Integrations** on the CEM **Administration** page.
3. Click **New integration**.
4. Go to the **Netcool/OMNIbus** tile and click **Configure**.
5. Enter a name for the integration and click **Copy** to add the generated webhook URL to the clipboard. Ensure you save the generated webhook to a file. The CEM webhook URL is required when creating CEM Gateway secret.
7. Enable this integration.
8. Click the **Save** button.

### 4. Preparing the Cloud Event Management (CEM) Gateway Secret

The chart requires several information stored in a secret called CEM Gateway Secret to establish a connection with CEM. This secret contains sensitive information such as CEMWebhookURL, NewKeystorePassword and HttpAuthenticationPassword.
- CEMWebhookURL is the CEM webhook URL and it is a required secret key.
- HttpAuthenticationPassword is the HTTP basic authentication password string which is required by the test pod (`helm test`). This is only used by an internal API to check the liveness of the CEM Gateway and it is an optional key in the secret.
- NewKeystorePassword is the new password to access cacerts in gateway and it is an optional key in the secret.

You can refer to the example below to create the secret. In the example, `cem-gateway-secret` is the secret name. `cemgw-ns` is the namespace where the CEM gateway will be installed. `cem-webhook-url` is CEM webhook URL. `http-basic-authentication-password` is HTTP basic authentication password. `new-keystore-password` is the new password to access cacerts in gateway. The secret and chart must reside in the same namespace.

```
kubectl create secret generic cem-gateway-secret --namespace cemgw-ns \
--from-literal=CEMWebhookURL=cem-webhook-url \
--from-literal=HttpAuthenticationPassword=http-basic-authentication-password \
--from-literal=NewKeystorePassword=new-keystore-password
```

Optionally, verify that the secret is successfully created using the `kubectl describe secret cem-gateway-secret --namespace cemgw-ns` command.

```
kubectl describe secret cem-gateway-secret --namespace cemgw-ns
Name:         cem-gateway-secret
Namespace:    cemgw-ns
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
CEMWebhookURL:               60 bytes
NewKeystorePassword:         10 bytes
HttpAuthenticationPassword:  10 bytes
```

### 5. Preparing the Cloud Event Management (CEM) TLS Secret

To allow the CEM Gateway to send events to CEM in IBM Cloud Private (ICP), a Transport Layer Security (TLS) certificate for Fully Qualified Domain Name (FQDN) of the CEM must be obtained to establish a secure trusted connection between the CEM Gateway and CEM. You must create the secret, if the TLS certificate is not signed by a well known certificate authority. Follow these steps to obtain the CEM TLS certificate from the CEM Ingress TLS secret.

  1. Login to the cluster where CEM installed.
  2. Obtain the CEM TLS certificate from the CEM Ingress TLS secret. The sample command below can be used to obtain the CEM TLS certificate from the CEM Ingress TLS secret. In the sample command below, `cem-tls-secret-name` is the CEM Ingress TLS secret name, `cem-tls-secret-namespace` is the namespace where the secret created, and `tls.crt` is the file contains the command output.
  ```
    kubectl get secret cem-tls-secret-name \
    --namespace cem-tls-secret-namespace \
    -o json | grep tls.crt | cut -d : -f2 | cut -d '"' -f2 | base64 --decode > tls.crt
  ```
  3. Login to the cluster where the CEM Gateway will be installed and create CEM TLS secret. The sample command below can be used to create CEM TLS secret. In the sample command below, `cem-tls-secret` is the secret name, `cemgw-ns` is the namespace where the CEM gateway will be installed and `tls.crt` is CEM TLS certificate file. The CEM TLS certificate filename must be `tls.crt`.
  ```
    kubectl create secret generic cem-tls-secret \
    --namespace cemgw-ns \
    --from-file=tls.crt
  ```

### 6. Pre-creating a Persistent Volume (PV)

The chart requires a Persistent Volume (PV) to store Store and Forward (SAF) files. You can opt to use dynamic provisioing and skip this step, if your cluster supports dynamic provisioning. Otherwise, to pre-create a PV or you want the chart Persistent Volume Claim (PVC) to bind to a pre-created PV. You should only perform one of the following steps to pre-create a PV.

- Refer to [Creating a Persistent Volume](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/manage_cluster/create_volume.html) to pre-create a PV of your choice.
- If your cluster supports Network File System (NFS) PV. Refer to the sample YAML file of creating NFS PV in `pak_extensions/pre-install/clusterAdministration/ibm-netcool-gateway-cem-prod-nfs-pv.yaml` to pre-create a NFS PV. Refer to comments in `ibm-netcool-gateway-cem-prod-nfs-pv.yaml` and update the YAML file accordingly. Then, run this command `kubectl create -f ibm-netcool-gateway-cem-prod-nfs-pv.yaml` as a cluster administrator to provision a NFS PV. The details of creating NFS PV are available in [Creating a NFS Persistent Volume](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/manage_cluster/create_nfs.html).

## Installing the Chart

You only perform one of the following actions to install the Chart.
### Install the Chart via IBM Cloud Private dashboard console
  1. From the IBM Cloud Private dashboard console, open the **Catalog**.
  2. Locate and select the `ibm-netcool-gateway-cem-prod` chart.
  3. Review the provided instructions and click **Configure**.
  4. Provide a release name and select the namespace and cluster.
  5. Review and accept the license(s).
  6. Refer to the [Configuration](#Configuration) table below, provide the required configuration based on requirements specific to your installation. Required fields are displayed with an asterisk.
  7. Click the **Install** button to complete the helm installation.
### Install the Chart via command line
  1. Extract the helm chart archive and customize the `values.yaml`. The [Configuration](#configuration) section lists the parameters that can be configured during installation.
  2. Refer to [Configuring ObjectServer Connection Parameters](#configuring-objectserver-connection-parameters).
  3. The command below shows how to install the chart with the release name `my-gateway` in `cemgw-ns` namespace using the configuration specified in the customized `values.yaml`. Helm searches for the `ibm-netcool-gateway-cem` chart in the helm repository called `stable`. This assumes that the chart exists in the `stable` repository. You may need to fetch the chart using `helm fetch` command beforehand to obtain a copy of the default `values.yaml` file.

  ```sh
  helm install --tls --namespace cemgw-ns --name my-gateway -f values.yaml stable/ibm-netcool-gateway-cem-prod
  ```

  > **Tip**: List all releases using `helm list --tls` or search for a chart using `helm search`.


## Verifying the Chart

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release> --tls`.

## Improving the performance of the Cloud Event Management (CEM) Gateway

You can increase the number of simultaneous connections between CEM Gateway and CEM to improve the performance. In general, the more connections specified, the faster the gateway can create requests in CEM from alerts sent by the ObjectServer. You can change this parameter before or after installing the chart by referring to the following steps.
### Edit the parameter before installing the chart
  1. Update `cemgateway.connections` in `values.yaml`. Then, save `value.yaml`.
  2. Proceed to chart installation.
### Edit the parameter after installing the chart
  1. Obtain the ConfigMap name for the current CEM Gateway Helm release. Use the sample command below to query the ConfigMap and write the output into a file. In the sample command below, `<release>-gateway-cem-config` is the CEM Gateway ConfigMap name, `cemgw-ns` is namespace where the chart is installed and `cemgw-configmap.yaml` is YAML file contains output of the command.
  ```
  kubectl get configmap <release>-gateway-cem-config -n cemgw-ns -o yaml > cemgw-configmap.yaml
  ```
  2. Update the related parameter in the ConfigMap to increase the number of connections. Open `cemgw-configmap.yaml` and update the `Gate.CEM.Connections` value. Then, save `cemgw-configmap.yaml`.
  3. Replace the CEM Gateway ConfigMap with the modified ConfigMap. Use the sample command below to replace the CEM Gateway ConfigMap with the modified ConfigMap. In the sample command below, `<release>-gateway-cem-config` is the CEM Gateway ConfigMap name, `cemgw-ns` is namespace where the chart is installed and `cemgw-configmap.yaml` is the modified YAML file in the step above.
  ```
  kubectl replace configmap <release>-gateway-cem-config -n cemgw-ns -f cemgw-configmap.yaml
  ```
  4. Restart the CEM Gateway StatefulSet with the modified ConfigMap in the step above. Use the sample commands below to scale down CEM Gateway StatefulSet to 0 then scale up CEM Gateway StatefulSet to 1. In the sample commands below, `<cem-gateway-statefulset>` is CEM Gateway StatefulSet name and `cemgw-ns` is namespace where the chart is installed.
  ```
  kubectl scale statefulset/<cem-gateway-statefulset> -n cemgw-ns --replicas=0
  kubectl scale statefulset/<cem-gateway-statefulset> -n cemgw-ns --replicas=1
  ```

## Uninstalling the Chart

1. To uninstall the chart with the release name `my-gateway`:

```bash
$ helm delete my-gateway --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

2. Access the storage via UI, select the Menu -> Platform -> Storage. Review any orphaned Persistent Volume Claims (PVC) and delete if necessary. Otherwise, run `pak_extensions/post-delete/clusterAdministration/deletePersistentVolume.sh` as a cluster administrator to delete the PVC and Persistent Volume (PV) for the release. The script takes two arguments which are the namespace and the release name that has been uninstalled. Example usage:
  `bash deletePersistentVolume.sh namespace chartReleaseName`


## Clean up any prerequisites that were created

As a Cluster Administrator, run the cluster administration clean up script included under pak_extensions to clean up cluster scoped resources when appropriate.

- post-delete/clusterAdministration/deleteSecurityClusterPrereqs.sh

As a Cluster Administrator, run the namespace administration clean up script included under pak_extensions to clean up namespace scoped resources when appropriate.

- post-delete/namespaceAdministration/deleteSecurityNamespacePrereqs.sh

As a Cluster Administrator, run the cluster administration clean up script included under pak_extensions to delete Persistent Volume Claim (PVC) and Persistent Volume (PV) for the release.

- post-delete/clusterAdministration/deletePersistentVolume.sh


## Configuration

The following table lists the configurable parameters of this chart and their default values.


|Parameter|Description
|--|--|
| **license** | The license state of the image being deployed. Enter `accept` to install and use the image. The default is `not accepted`. |
| **image.repository** | Image repository. Update this repository name to pull from a private image repository. The image name must be `netcool-gateway-cem`. The default is `netcool-gateway-cem`. |
| **image.tag** | Specific gateway image tag to use. A tag is a label applied to a image in a repository. Tags are how various images in a repository are distinguished from each other. The default is `2.0.5.3-amd64`. |
| **image.pullPolicy** | Image pull policy. The default is `Always`. |
| **global.image.secretName** | Name of the Secret containing the Docker Config to pull image from a private repository. Leave blank if the gateway image already exists in the local image repository or the Service Account has been assigned with an Image Pull Secret. The default is `nil`. |
| **global.serviceAccountName** | Name of the service account to be used by the helm chart. If the Cluster Administrator has already created a service account in the namespace, specify the name of the service account here. If left blank, the chart will automatically create a new service account in the namespace when it is deployed. This new service account will be removed from the namespace when the chart is removed. The default is `nil`. |
| **global.persistence.useDynamicProvisioning** | Use Storage Class to dynamically create Persistent Volume and Persistent Volume Claim. The default is `true`. |
| **global.persistence.storageClassName** | Storage Class for dynamic provisioning. The default is `""`. |
| **global.persistence.selector.label** | The Persistent Volume Claim Selector label key to refine the binding process when dynamic provisioning is not used.  The default is `""`. |
| **global.persistence.selector.value** | The Persistent Volume Claim Selector label value related to the Persistent Volume Claim Selector label key. The default is `""`. |
| **global.persistence.storageSize** | Storage size to store CEM Gateway Store and Forward Files. The default is `3Gi`. |
| **global.persistence.supplementalGroups** | Provide the gid of the volumes as list (required for NFS). The default is `[]`. |
| **netcool.connectionMode** | The connection mode to use when connecting to the Netcool/OMNIbus ObjectServer. Refer to [Secure Gateway and ObjectServer Communication Requirement section](#securing-gateway-and-objectserver-communication) for more details. **Note**: Refer to limitations section for more details on available connection modes for your environment. Requires a pre-created secret containing files/values for secured communication. The default is `AuthOnly`. |
| **netcool.primaryServer** | The primary Netcool/OMNIbus server the gateway should connect to (required). Usually set to NCOMS or AGG_P. The default is `nil`. |
| **netcool.primaryHost** | The host of the primary Netcool/OMNIbus Objsect Server hostname (required). Specify the  ObjectServer Hostname. The default is `nil`. |
| **netcool.primaryIP** | The primary Netcool/OMNIbus ObjectServer IP address. If specified along with primaryHost, a host alias entry will be added. The default is `nil`. |
| **netcool.primaryPort** | The port number of the primary Netcool/OMNIbus ObjectServer (required). The default is `nil`. |
| **netcool.primaryIDUCHost** | The primary Netcool/OMNIbus ObjectServer IDUC Host or Service name. Should be set if the primary IDUC host is different from the primary ObjectServer hostname.When connecting to NOI on ICP/OCP, this should be set to the primary ObjectServer NodePort service name. The default is `nil`. |
| **netcool.backupServer** | The backup Netcool/OMNIbus ObjectServer to connect to. If the backupServer, backupHost and backupPort parameters are defined in addition to the primaryServer, primaryHost, and primaryPort parameters, the gateway will be configured to connect to a virtual ObjectServer pair called `AGG_V`. The default is `nil`. |
| **netcool.backupHost** | The host of the backup Netcool/OMNIbus ObjectServer. Specify the backup ObjectServer Hostname. The default is `nil`. |
| **netcool.backupIP** | The backup Netcool/OMNIbus ObjectServer IP address. If specified along with primaryHost, a host alias entry will be added. The default is `nil`. |
| **netcool.backupPort** | The port of the backup Netcool/OMNIbus ObjectServer. The default is `nil`. |
| **netcool.backupIDUCHost** | The backup Netcool/OMNIbus ObjectServer IDUC Host or Service name. Should be set if the primary IDUC host is different from the primary ObjectServer hostname. When connecting to NOI on ICP/OCP, this should be set to the primary ObjectServer NodePort service name. The default is `nil`. |
| **netcool.secretName** | A pre-created secret for AuthOnly, SSLOnly or SSLAndAuth connection mode. Certain fields are required depending on the connection mode. The default is `nil`. |
| **cemgateway.messageLevel** | The gateway log message level. The default value is `debug` |
| **cemgateway.connections** | The number of simultaneous connections the gateway makes with the Cloud Event Management. The default value is `3` |
| **cemgateway.connectionTimeout** | The interval (in seconds) that the gateway allows for HTTP connections and responses to HTTP requests. The default value is `15` |
| **cemgateway.retryLimit** | The maximum number of retries the gateway should make on an operation (for example, forwarding an event to the Event Source instance) that failed. The default value of 0 (zero) means there is no limit to the number of retries that the gateway makes on a failed operation. The default value is `0` |
| **cemgateway.retryWait** | The number of seconds the gateway should wait before retrying an operation (for example, forwarding an event to the Event Source instance) that failed. The default value is `7` |
| **cemgateway.reconnectTimeout** | The time (in seconds) between each reconnection poll attempt that the gateway makes if the connection to the ObjectServer is lost. The default value is `30` |
| **cemgateway.locale** | Environment locale setting. Used as the LC_ALL environment variable. The default is `en_US.utf8`. |
| **cemgateway.setUIDandGID** | When set to true, the helm chart will specify the UID and GID values for the netcool user else the netcool user will not be assigned any UID or GID by the helm chart. |
| **cemgateway.cemTlsSecretName** | A pre-created secret name to store CEM certificate. In the secret, the key must be tls.crt which holds the certificate file in PEM format. |
| **cemgateway.cemSecretName** | A pre-created secret to store CEMWebhookURL, NewKeystorePassword and HttpAuthenticationPassword. CEMWebhookURL is the CEM webhook URL to send notification from gateway to CEM and the required key in the secret. NewKeystorePassword is the new password to access cacerts in gateway and the optional key in the secret. HttpAuthenticationPassword is the HTTP basic authentication password string which is required by the test pod (helm test) and only used by an internal API to check the liveness of the CEM Gateway. HttpAuthenticationPassword is the optional key in the secret|
| **resources.requests.cpu** | The minimum required CPU core. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core). The default is `100m`. |
| **resources.requests.memory** | The minimum memory in bytes. Specify integers with one of these suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. The default is `128Mi`. |
| **resources.limits.cpu** | The upper limit of CPU core. Specify integers, fractions (e.g. 0.5), or millicores values(e.g. 100m, where 100m is equivalent to .1 core). The default is `500m`. |
| **resources.limits.memory** | The memory upper limit in bytes. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. The default is `512Mi`. |
| **arch** | Worker node architecture to deploy. (Supports AMD64 architecture only) Fixed to `amd64`. |


You can specify each parameter using the `--set key=value[,key=value]` argument to `helm install` to override any of the parameter value from the command line. For example `helm install --tls --namespace <namespace> --name my-gateway --set license=accept,gateway.messageLevel=debug` to set the `license` parameter to `accept` and `gateway.messageLevel` to `debug`.

## Configuring ObjectServer Connection Parameters

After performing the steps in [Pre-installation Task, Gathering ObjectServer Details](#1-gathering-objectserver-details) and [Pre-installation Task, Preparing ObjectServer communication secret](#2-preparing-objectserver-communication-secret), you can configure the Netcool/OMNIbus parameters as the following:

```yaml
netcool:
  # (Required) The connection mode to use.
  connectionMode: "SSLAndAuth"

  # (Required) ObjectServer Name that the gateway should connect to. (Usually set to NCOMS or AGG_P)
  primaryServer: "AGG_P"

  # (Required) Hostname of the primary ObjectServer. Set to "<NOI_TLS_PROXY_CN>"
  primaryHost: "noi-m76-proxy-tls-secret"

  # IP address of the primary ObjectServer host. This should be the set to the 
  # ICP Master node IP address for NOI on ICP/Openshift.
  # If both host and IP parameters are specified,
  # and entry will be added as host alias.
  primaryIP: "9.30.117.58"

  # (Required) ObjectServer Port. Set to "<NOI_TLS_PROXY_PORT_1>", 3XXXX.
  primaryPort: 30135

  # For NOI on ICP/Openshift, set to the primary ObjectServer 
  # nodeport service name "<NOI_OBJECT_SERVER_PRIMARY_SERVICE>"
  primaryIDUCHost: "noi-m76-objserv-agg-primary-nodeport"

  # (Optional) Backup ObjectServer Name that the gateway should connect to.
  backupServer: "AGG_B"

  # (Optional) Hostname of the backup ObjectServer. Set to <NOI_TLS_PROXY_CN>
  backupHost: "noi-m76-proxy-tls-secret"

  # (Optional) IP address of the backup ObjectServer host. This should be the set to the 
  # ICP Master node IP address for NOI on ICP/Openshift.
  # If both host and IP parameters are specified,
  # and entry will be added as host alias. Set to "<CLUSTER_MASTER_IP>", same as 'primaryIP'
  backupIP: "9.30.117.58"

  # (Optional) Backup ObjectServer Port, set to "<NOI_TLS_PROXY_PORT_2>", 3XXXX 
  backupPort: 30456

  # (Optional) For NOI on ICP/Openshift, set to the backup ObjectServer nodeport
  # service name "<NOI_OBJECT_SERVER_BACKUP_SERVICE>"
  backupIDUCHost: "noi-m76-objserv-agg-backup-nodeport"

  # (Required) A pre-created secret for AuthOnly or SSLAndAuth connection mode.
  # This is the secret name configured in the create-noi-secret.sh script configuration file.
  # It should contain several fields required for securing the connection between the gateway
  # and ObjectServer.
  secretName: "cemgw-noi-secret"

```

## Storage

The CEM Gateway uses Persistent Volume (PV) to store Store and Forward files (SAF). The SAF files are used to keep track of the events already sent to CEM so that the CEM Gateway will not resend the same events to CEM to avoid event duplications in CEM. When the CEM Gateway Pod is restarted, it will access the SAF to check the last event sent to CEM and start forwarding the next events to CEM.
You can opt to use Kubernetes dynamic provisioning to create both PV and Persistent Volume Claim (PVC) or pre-create a PV with label for the chart to perform the binding process. The PV must have access mode of `ReadWriteOnce` and minimum of `3 GiB` storage capacity. You can update `global.persistence.storageSize` to change the storage capacity. Kubernetes dynamic provisioning is the default option to provision the PV and PVC dynamically.

* To provision PV and PVC dynamically
  * Set the following `global` values:
    * `persistence.useDynamicProvisioning` to `true`. The default is `true`.
    * `persistence.storageClassName` to custom Storage Class name or leave the value empty to use default Storage Class. The default is `""`.

* To bind to a pre-created PV
  * Set the following `global` values:
    * `persistence.useDynamicProvisioning` to `false`. The default is `true`.
    * `persistence.storageClassName` to custom Storage Class name or leave the value empty to use default Storage Class. The default is `""`.
    * `persistence.selector.label` to target PV label for PV and PVC binding process. The default is `""`.
    * `persistence.selector.value` to the value related `persistence.selector.label`. The default is `""`.
  * The chart deployment will unintentionally attempt to do dynamic provisioning, if `global.persistence.storageClassName` is set to a valid Storage Class name without specifying `global.persistence.selector.label` and `global.persistence.selector.value`. To avoid this case, `global.persistence.selector.label` and `global.persistence.selector.value` must be specified with non-empty values.

## Limitations

- Only the AMD64 / x86_64 architecture is supported.
- This chart is verified to run on IBM Cloud Private 3.2.0 and IBM Cloud Private 3.2.0 on Red Hat OpenShift Container Platform 3.11.
- There are several known limitations when enabling secure connection between gateway clients and server:
  - The required files in the secret must be created using the `nc_gskcmd` utility.
  - If your ObjectServer is configured with FIPS 140-2, the password for the key database file (`omni.kdb`) must meet the requirements stated in this [page](https://www.ibm.com/support/knowledgecenter/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ssl_creatingkeydatabasefips.html).
  - When encrypting a string value using the encryption config key file (`encryption.keyfile`), you must use the `AES_FIPS` as the cipher algorithm. `AES` algorithm is not supported.
  - When connecting to an ObjectServer in the same IBM Cloud Private cluster, you may connect the gateway to the secure connection proxy which is deployed with the IBM Netcool Operations Insight chart to encrypt the communication using TLS but the TLS termination is done at the proxy. It is recommended to enable IPSec on IBM Cloud Private to secure cluster data network communications.
  - Only one active CEM Gateway pod can use the Store-and-Forward (SAF) directory which is stored in the Persistent Volume. It is advised to scale down the StatefulSet to 0 and then back to 1 in order to properly start the CEM Gateway during a node maintenance and it should be able to resume processing the last known SAF file.

## Documentation

- IBM Netcool/OMNIbus Gateway for IBM Cloud Event Management Helm Chart Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/cloud_event_management/wip/concept/ceminth_intro.html)

## Troubleshooting

Describes potential issues and resolution steps when deploying the chart.

| Problem                                                                                                                                         | Cause                                                                                                        | Resolution                                                                          |
|-------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| Pod failed to mount to the Config Maps or some object name appear to be some what random. | If a long release name is used, the chart will generate a random suffix for objects that exceeds the character limit. This may cause mapping issues between the Kubernetes objects. | Use a shorter release name, below 20 characters. |
| Warning messages eg. `This chart requires a namespace with a ibm-restricted-psp pod security policy` are always displayed when installing the chart using the Catalog on ICP on OCP platforms. | Support for SCCs is not currently implemented for the Catalog. | These warning messages are to be ignored. The chart is still allowed to be installed using the Catalog and will apply SCCs instead of PSPs on ICP on OCP platforms. The Catalog will add support for SCCs in a future release of ICP. |
