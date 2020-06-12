# IBM Spectrum Protect Plus

[IBM Spectrum Protect Plus](https://www.ibm.com/us-en/marketplace/ibm-spectrum-protect-plus) is a modern data protection solution that provides near-instant recovery, replication, retention, and reuse for VMs, databases, and containers in hybrid multicloud environments.

## Introduction

IBM Spectrum Protect Plus is a data protection and availability solution for virtual environments and database applications that can be rapidly deployed to protect your environment.

Kubernetes Backup Support is a feature of IBM Spectrum Protect Plus that extends data protection to containers in Kubernetes clusters. Kubernetes Backup Support protects persistent volumes that are attached to containers in Kubernetes clusters. Snapshot backups of the persistent volumes are created and copied to IBM Spectrum Protect Plus vSnap servers.

[Product Documentation](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/welcome.html)

## Chart Details

This chart deploys the Kubernetes Backup Support component of IBM Spectrum Protect Plus that supports data protection in the Kubernetes environment.

## Prerequisites

* Cluster prerequisites:
  * Kubernetes 1.16.0 or later, with beta APIs enabled.
  * Helm versions >= 2.16.0 < 3.0.0
  * Ceph Container Storage Interface (CSI) driver 1.2 or 2.0 with Rados Block Device (RBD) storage.
  * You must be running a Kubernetes cluster with CSI support.
  * Persistent storage must be provided by the CSI driver, which must support CSI snapshot capabilities.
  * A storage class must be defined for the persistent volumes that are being protected.
  * The Kubernetes command-line tool kubectl must be accessible on the installation host and in the local path.
  * CSI snapshot support must be enabled on the kubectl command line.
  * The target image registry must be accessible from the Kubernetes cluster. The target image registry can be a local image registry or an external image registry. For an external image registry, you can configure the image pull secret to secure your environment.
  * To create new cluster-wide resources, you must be logged in to the target cluster as a user with cluster-admin privileges.
  * Ensure that Kubernetes Backup Support secrets that include user IDs, passwords, and keys are encrypted at rest in the etcd distributed key-value store. For more information, see [Encrypting Secret Data at Rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/).
  * Kubernetes Backup Support protects only persistent storage that was allocated by a storage plug-in that supports the CSI interface.
  * Only formatted volumes are supported. Raw block volumes are not supported.
  * For Kubernetes 1.16 only: The VolumeSnapshotDataSource feature gate must be enabled. For instructions, see [Enabling the VolumeSnapshotDataSource feature](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/r_spp_cbs_prereqs.html#r_spp_cbs_prereqs__enable_volsnapdatasource).
  * Optional: To help optimize product performance and scalability, ensure that Kubernetes Metrics Server v0.3.5 or later is installed and running. For instructions, see [Verifying whether the Metrics Server is running](https://www.ibm.com/support/knowledgecenterSSNQFQ_10.1.6/spp/r_spp_cbs_prereqs.html#r_spp_cbs_prereqs__install_metrics_server).

* IBM Spectrum Protect prerequisites:
  * External, non-container components such as IBM Spectrum Protect Plus and the IBM Spectrum Protect Plus vSnap server must be provisioned and configured by the IBM Spectrum Protect Plus administrator. For instructions, see [Installing IBM Spectrum Protect Plus](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/c_spp_installation.html).
  * An IBM Spectrum Protect Plus instance must be deployed and licensed as a VMware virtual appliance. Network connectivity must exist to and from the target cluster. 
  * An IBM Spectrum Protect Plus vSnap instance must be deployed as a VMware virtual appliance. The vSnap instance must be configured as an external vSnap server for storing backups. For instructions, see [Installing vSnap servers](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/c_vsnap_installation.html).

For the most current requirements and prerequisites, see https://www.ibm.com/support/pages/node/2489223.

## Resources Required

- The following system resources are based on the default install parameters.

By default, when you use this helm chart you start with the following number of Containers and required resources:  

  |Component                       | Replica | Request CPU  | Limit CPU    | Request Memory | Limit Memory
  |------------------------------  | --------| -------------| -------------| -------------  | -------------
  |baas-spp-agent                  | 1       | 2            | 3            | 800Mi          | 1000Mi
  |baas-cert-monitor               | 1       | 250m         | 1            | 50Mi           | 250Mi
  |baas-datamover                  | 1       | 100m         | 500m         | 500Mi          | 1000Mi
  |baas-kafka                      | 1       | 500m         | 2            | 600Mi          | 2Gi
  |baas-scheduler                  | 1       | 100m         | 750m         | 150Mi          | 500Mi
  |baas-controller                 | 1       | 250m         | 1            | 50Mi           | 250Mi
  |baas-transaction-manager        | 3       | 200m         | 1            | 100Mi          | 500Mi
  |baas-transaction-manager-worker | 3       | 200m         | 2            | 250Mi          | 500Mi
  |baas-transaction-manager-redis  | 3       | 50m          | 200m         | 50Mi           | 250Mi

   - The CPU resource is measured in Kubernetes _cpu_ units. See Kubernetes documentation for details.
   - Ensure that you have sufficient resources available on your worker nodes to support the deployment.

## Installing the Chart

You can install Kubernetes Backup Support by using one of the following methods:

* By downloading and installing the Helm package from IBM Helm Chart Repository and IBM Entitled Registry. 

   The Helm package is smaller in size and therefore takes less time to download. Internet access is required to pull containers at deployment time. For instructions, see "Preparing for installation using package from IBM Helm Chart Repository and IBM Entitled Registry".

* By downloading and installing the product package from IBM Passport Advantage. 

   The package from IBM Passport Advantage is a larger but self-contained package. Internet access is not required at deployment time. For instructions on downloading and installing the package from IBM Passport Advantage, see [Installing and deploying Kubernetes Backup Support images in the Kubernetes environment](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/t_spp_cbs_install_proc.html).

### Preparing for installation using package from IBM Helm Chart Repository and IBM Entitled Registry

Before you begin, ensure that your cluster can connect to the internet to pull images from the registry during the installation.

The Helm chart for Kubernetes Backup Support is available in the IBM Helm Chart Repository. The Helm package contains links to the IBM Entitled Registry. 

When the Helm chart is installed using the baas-install.sh script, links to the entitled registry are constructed based on the values in the baas_config.cfg configuration file. When Kubernetes starts to provision the pods for Kubernetes Backup Support, the containers specified in the links will be pulled from the entitled registry.

#### Step 1. Obtain a key to the IBM Entitled Registry

Before you can pull docker images from the IBM Entitled Registry, you must obtain a key from the IBM Container Library.

To obtain an entitlement key:

1. Log in to the [IBM Container Library](https://myibm.ibm.com/products-services/containerlibrary). Specify your IBMid and password when prompted.
2. In the Access your container software page, click **Copy key** to copy your entitlement key.
3. Save the key to a secure location. You will use the key in "Step 4. Create an image pull secret that contains the entitlement key". For example, save the following information to a file:

   ```text
   dockerRegistryKey: <your_entitlement_key>
   ```

#### Step 2. Obtain the package from IBM Helm Chart Repository and IBM Entitled Registry

To review the product README and related files in the IBM Helm Chart Repository, navigate to https://github.com/IBM/charts/tree/master/entitled/ibm-spectrum-protect-plus-prod.

To download the Helm package file named **ibm-spectrum-protect-plus-prod-1.0.0.tgz**, navigate to https://github.com/IBM/charts/tree/master/repo/entitled.

During deployment, the container images will be pulled from the IBM Entitled Registry.

After the download is completed, expand the .tgz file and cd to the ibm_cloud_pak/pak_extensions/install directory. 

The **baas_install.sh** script in the **install** directory is used for installing Kubernetes Backup Support.

#### Step 3. Review the baas_config.cfg configuration file for use with IBM Entitled Registry

Review the baas_config.cfg configuration file, which is used to configure the baas_install.sh installation script to run the product installation from the IBM Entitled Registry.

Complete the following steps:

1. cd to the **install** directory.
2. Review the ./baas_config.cfg file.
3. If necessary, edit and modify the value in the PRODUCT_IMAGE_REGISTRY_SECRET_NAME parameter. By default, it is set to "baas-registry-secret".
   
   The PRODUCT_IMAGE_REGISTRY_SECRET_NAME parameter in the baas_config.cfg configuration file specifies the name of the image pull secret to use. Be sure to use the same value as the secret name when you create the secret in "Step 4. Create an image pull secret that contains the entitlement key".
 

#### Step 4. Create an image pull secret that contains the entitlement key

The image pull secret is used to provide the credentials that are needed by Kubernetes to pull docker images from the IBM Entitled Registry.

Use the value provided for PRODUCT_IMAGE_REGISTRY_SECRET_NAME as the name of your secret. The image pull secret must be in every namespace of the PVCs that will be protected by Kubernetes Backup Support.

Before you begin:

* Ensure that you obtained a key to the IBM Entitled Registry as described in "Step 1. Obtain a key to the entitled staging registry".
* Ensure that the product namespace "baas" exists by issuing the following command:
  ```text
  kubectl get namespace baas
  ```
  If the "baas" namespace does not exist, issue the following command to create it:
  ```text
  kubectl create namespace baas
  ```

To create an image pull secret for the IBM Entitled Registry:

1. Issue the following command to create an image pull secret called "baas-registry-secret" for namespace "baas", using the entitlement key that you obtained:

   ```text
   kubectl create secret docker-registry "baas-registry-secret" --namespace "baas" --docker-server="cp.icr.io/cp/sppc" --docker-username="cp" --docker-password="<your_entitlement_key>" --docker-email=yourname@your.company.com
   ```

2. Determine the namespaces of any PVCs that you want to protect by issuing the following command:

   ```text
   kubectl get pvc --all-namespaces
   ```

3. For each PVC that you want to protect, copy the secret to that PVC's namespace by issuing the following command. For example, to copy the secret that you created for the **baas** namespace to **namespace1**:
   ```text
   kubectl get secret "baas-registry-secret" --namespace="baas" --export -o yaml | kubectl apply --namespace="namespace1" -f -
   ```

### Installing the product

To install Kubernetes Backup Support using the ibm-spectrum-protect-plus-prod chart:

1. Log in to the target cluster as a user with cluster-admin privileges.
2. cd to the install directory.
3. Obtain the CIDR method for the cluster by issuing the following command:
   ```text
   kubectl cluster-info dump | grep -m 1 cluster-cidr
   ```
   The CIDR is provided in the output in the following format:
   ```text
   --cluster-cidr=xxx.yyy.0.0/zz
   ```  
4. Obtain the IP address and server port for the cluster API server by issuing the following command:
   ```text
   kubectl config view|awk '/cluster\:/,/server\:/' | grep server\: | awk '{print $2}'
   ```
   The result is a URL that is composed of an IP address and port number, as shown in the following example:
   ```text
   https://192.0.2.0:6443
   ```
   where 192.0.2.0 is the cluster API server IP address and 6443 is the port address.


5. Edit the **baas_config.cfg** configuration file and modify the configuration parameters by providing the appropriate values for your environment. Enclose the values in quotation marks, as shown in the following example:

   ```text
   BAAS_ADMIN="sppadmin"
   ```

   The following table contains the parameters that you must modify:
   
   <table>
    Table 1. Specifications for the baas_config.cfg configuration file
    <tr>
        <th>Parameter</th>
        <th>Description</th>
        <th>Default Value</th>
    </tr>
    <tr>
        <td>BAAS_ADMIN</td>
        <td>The user ID of the IBM Spectrum Protect Plus administrator.</td>
        <td>isppadmin</td>
    </tr>
    <tr>
        <td>BAAS_PASSWORD</td>
        <td>
            The IBM Spectrum Protect Plus password. For increased security, specify an empty string "". You are
            prompted for the password when you run the deployment script. If you must specify a password in the
            configuration file for automated test deployments, ensure that the file is stored in a secure
            location.
        </td>
        <td>None</td>
    </tr>
    <tr>
        <td>CLUSTER_NAME</td>
        <td>
            The unique cluster name that is used to register the application host to the IBM Spectrum Protect
            Plus server.
        </td>
        <td>None</td>
    </tr>
    <tr>
        <td>CLUSTER_CIDR</td>
        <td>The CIDR for the cluster. Enter the CDIR that was obtained in Step 3 of the "Installing the product" section.</td>
        <td>192.168.0.0/16</td>
    </tr>
    <tr>
        <td>CLUSTER_API_SERVER_IP_ADDRESS</td>
        <td>The IP address for the cluster API server. Enter the IP address that was obtained in Step 4 of the "Installing the product" section.</td>
        <td>x.x.x.x</td>
    </tr>
    <tr>
        <td>CLUSTER_API_SERVER_PORT</td>
        <td>The port address for the cluster API server. Enter the port address that was obtained in Step 4 of the "Installing the product" section.
        <td>6443</td>
    </tr>
    <tr>
        <td>LICENSE</td>
        <td>
            The product license for Kubernetes Backup Support. The
            English license file is located in the LICENSES/LICENSE-en directory that
            is included in the installation package. Versions of the license in other languages are available at https://www-03.ibm.com/software/sla/sladb.nsf/searchlis/?searchview&searchorder=4&searchmax=0&query=(5737-F11).
            <p>Review the license information, and specify ACCEPTED to accept the license during installation
                without being prompted.</p>
            <p>If you do not change the default value, you are prompted to accept the license during installation.
                Otherwise, the installation fails.</p>
        </td>
        <td>NOTACCEPTED</td>
    </tr>
    <tr>
        <td>SPP_AGENT_SERVICE_NODEPORT</td>
        <td>
            The SSH port for the connection from IBM Spectrum Protect Plus from to the Kubernetes Backup Support
            agent container service.
            <p>If you do not specify a value for this port, a random port within the NodePort range is assigned by
                the NodePort service in Kubernetes. The default range is 30000 - 32767.</p>
            <p>If you specify a value for this port, use a port number within the NodePort range that is set up by
                the Kubernetes administrator.
                Ensure that the port is not already in use by the cluster. If the port is already in use, the
                installation process fails with an
                error that shows which NodePorts are already in use.</p>
        </td>
        <td>None</td>
    </tr>
    <tr>
        <td>SPP_IP_ADDRESSES</td>
        <td>The IBM Spectrum Protect Plus server IP address.</td>
        <td>x.x.x.x</td>
    </tr>
    <tr>
        <td>PRODUCT_IMAGE_REGISTRY_SECRET_NAME</td>
        <td>
            The name of the Kubernetes image-pull secret that contains the credentials for the registry.
            The secret must be in the namespace that is specified by the PRODUCT_IMAGE_REGISTRY_NAMESPACE
            parameter.
            <p>For the data mover container to run, the image-pull secret must be in
            every namespace of each persistent volume claim (PVC) to be backed up and restored.
            </p>
        </td>
        <td>baas-registry-secret</td>
    </tr>
    <tr>
        <td>PRODUCT_LOGLEVEL</td>
        <td>
            The trace levels for troubleshooting issues with the Kubernetes Backup Support transaction manager,
            controller, and
            scheduler components. The following trace levels are available: INFO, WARNING, DEBUG, or ERROR.
        </td>
        <td>INFO</td>
    </tr>
   </table>

   The following parameters and values are reserved for Kubernetes Backup Support and for pulling images from the IBM Entitled Registry. Keep them as is.

   * PRODUCT_NAMESPACE="baas"
   * PRODUCT_TARGET_PLATFORM="K8S"
   * PRODUCT_IMAGE_REGISTRY="cp.icr.io"
   * PRODUCT_IMAGE_REGISTRY_NAMESPACE="cp/sppc"

   The SPP_PORT value specifies the port for the Kubernetes Backup Support user interface. Do not change the default value of 443.
   Kubernetes Backup Support is available only in English in IBM Spectrum Protect Plus Version 10.1.6. For this reason, do not change the PRODUCT_LOCALIZATION="en_US" setting.

   The most commonly used parameters are specified in baas_config.cfg. There are other parameters, such as liveness and readiness probes, in the values.yaml file.  If you need to adjust one of these values, you can update the values.yaml file and run the baas_install.sh with the upgrade (-u) option.

6. Start the installation and deployment by issuing the following command:
   ```text
   ./baas_install.sh -i
   ```
   When prompted, enter yes to continue.

   This command deploys the ibm-spectrum-protect-plus-prod chart using the configuration that you specified in the **baas_config.cfg** file.

   Depending on your environment, it might take several minutes to load and deploy the package.

7. To verify that the Kubernetes Backup Support components are properly installed, issue the following command:
   ```text
   ./baas_install.sh -s
   ```
   If the installation fails, the missing components are listed in the MISSING section of the output.
   
   When all pods are running, the deployment is completed.

   For detailed installation instructions, see [Installing and deploying Kubernetes Backup Support images](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/t_spp_cbs_install_proc.html).

   If you want to update the existing configuration, modify the parameters in the baas_config.cfg file as required for your environment, and issue the following command:
   ```text
   ./baas_install.sh -u
   ```

### Uninstalling the Chart

You can uninstall Kubernetes Backup Support completely so that all components, including all configurations and backups, are removed from the Kubernetes environment.

Before you begin:

* Stop all scheduled backups. For instructions, see [Modifying parameters in a YAML file](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/t_spp_cbs_bup_scheduling.html#t_spp_cbs_bup_scheduling__mod_YAML).
* Wait for all running backup and restore jobs to finish.

To completely uninstall Kubernetes Backup Support from the cluster that you are logged in to, complete the following steps on the command line:

1. Destroy all snapshot and copy backups with a destroy request. For instructions, see Deleting container backups.
2. Delete any persistent volume claims (PVCs) that were used for copy backups.
    Tip You can look for the names of the PVCs that were backed up.
3. Delete the baas custom resource definition (CRD) by issuing the following command:
   ```text
   kubectl delete crd baasreqs.baas.io
   ```
   This command also deletes all BaasReq request objects.
    
4. Uninstall Kubernetes Backup Support by issuing the following command from the installer directory:
   ```text
   ./baas_install.sh -d
   ```    
   When prompted, enter yes to continue.

   This command removes all data mover pods, deployments, and network policies. The Kubernetes secret for Kubernetes Backup Support is also removed.

5. Optional: To verify the progress of the uninstallation, enter the following command:
   ```text
   kubectl get pod -n baas
   ```
   or
   ```text
   watch kubectl get pod -n baas
   ```
6. Unregister the Kubernetes cluster by using the IBM Spectrum Protect Plus user interface:
    1. In the navigation pane, click Manage Protection > Containers > Kubernetes.
    2. In the Kubernetes page, click Manager clusters.
    3. In the list of host addresses, click the deletion icon next the cluster that you want to unregister.
    4. In the Confirm window, enter the displayed confirmation code and click Unregister.
    
    The cluster host is removed from the IBM Spectrum Protect Plus user interface.
    
7. Remove the account identity that is used to register the Kubernetes cluster:
    1. In the navigation pane, click Accounts > Identity.
    2. Click the deletion icon that is associated with the cluster.
    3. Click Yes to delete the identity.
    
8. If you are running Kubernetes 1.16, disable the VolumeSnapshotDataSource feature if you no longer require it.
9. Delete the service level agreement (SLA) policies and any other customizations by deleting the baas namespace. Issue the following command:
   ```text
   kubectl delete namespace baas
   ```    
10. Remove the manually created image-pull secret for the IBM Entitled Registry with the **kubectl delete secret** command in all the namespaces that the secret existed in.
11. Optional: Review the installation and configuration information and revert any prerequisite steps.


## Configuration

The configuration table in Step 5 of the "Installing the product" section lists the configurable parameters of the ibm-spectrum-protect-plus-prod chart and their default values. You can configure the parameters in the baas_config.cfg configuration file. 


## Limitations

* You cannot deploy the product more than once
* A rollback to a previous version of Kubernetes Backup Support is not supported. In other words, you cannot use Kubernetes Backup Support V10.1.5 to restore data that was backed up by Kubernetes Backup Support V10.1.6.
* Additional limitations and known problems are available at https://www.ibm.com/support/pages/node/6209657. 

## Documentation

For more information about Kubernetes Backup Support, see the following resources in IBM Knowledge Center:

* [Protecting containers](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/c_spp_protecting_containers.html)
* [Kubernetes Backup Support requirements](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/r_spp_system_reqs_cbs.html)
* [Installing Kubernetes Backup Support](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/c_spp_cbs_installation.html)
* [Protecting containers by using the command line](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.6/spp/c_spp_cbs_using_cmdline.html)
