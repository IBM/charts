# IBM Spectrum Protect Plus

[IBM Spectrum Protect Plus](https://www.ibm.com/us-en/marketplace/ibm-spectrum-protect-plus) is a modern data protection solution that provides near-instant recovery, replication, retention, and reuse for VMs, databases, and containers in hybrid multicloud environments.

## Introduction

IBM Spectrum Protect Plus is a data protection and availability solution for virtual environments and database applications that can be rapidly deployed to protect your environment.

Container Backup Support is a feature of IBM Spectrum Protect Plus that extends data protection to containers in a Kubernetes or Red Hat OpenShift environment. Container Backup Support protects persistent volumes, namespace-scoped resources, and cluster-scoped resources that are associated with containers in Kubernetes or OpenShift clusters.  Snapshot backups of the persistent volumes are created and copied to IBM Spectrum Protect Plus vSnap servers.

[Product Documentation](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/welcome.html)

## Chart Details

This chart deploys the Container Backup Support component of IBM Spectrum Protect Plus that supports data protection in the Kubernetes or OpenShift environment.

## Prerequisites

To view the requirements and prerequisites, see [Container backup and restore requirements](https://www.ibm.com/support/pages/node/6325259).

## Resources Required

* The following system resources are based on the default install parameters.

By default, when you use this helm chart you start with the following number of containers and required resources:

* For Kubernetes:

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
  |baas-strimzi-cluster-operatior  | 1       | 200m         | 1            | 384Mi          | 384Mi
  |baas-zookeeper                  | 3       | 300m         | 2            | 400Mi          | 1Gi

* For OpenShift

  |Component                       | Replica | Request CPU  | Limit CPU    | Request Memory | Limit Memory
  |------------------------------  | --------| -------------| -------------| -------------  | -------------
  |baas-spp-agent                  | 1       | 2            | 3            | 800Mi          | 1000Mi
  |baas-datamover                  | 1       | 100m         | 500m         | 500Mi          | 1000Mi
  |baas-kafka                      | 1       | 500m         | 2            | 600Mi          | 2Gi
  |baas-scheduler                  | 1       | 100m         | 750m         | 150Mi          | 500Mi
  |baas-controller                 | 1       | 250m         | 1            | 50Mi           | 250Mi
  |baas-transaction-manager        | 3       | 200m         | 1            | 100Mi          | 500Mi
  |baas-transaction-manager-worker | 3       | 200m         | 2            | 250Mi          | 500Mi
  |baas-transaction-manager-redis  | 3       | 50m          | 200m         | 50Mi           | 250Mi
  |baas-zookeeper                  | 3       | 300m         | 2            | 400Mi          | 1Gi
  |baas-entity-operator            | 1       | 300m         | 2            | 400Mi          | 1Gi

* The CPU resource is measured in Kubernetes _cpu_ units. See Kubernetes documentation for details.
* Ensure that you have sufficient resources available on your worker nodes to support the deployment.

## Installing the Chart

You can install Container Backup Support by using one of the following methods:

* By downloading and installing the product package in an airgap environment

   The installation package from IBM Passport Advantage® Online is a larger but self-contained package. Internet access is not required at deployment time.
   For instructions, see [Installing Container Backup Support in an airgap environment](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/t_spp_cbs_install_proc.html).

* By fetching and installing the product package from IBM Helm Charts Repository and IBM Entitled Registry

  The Helm package is smaller in size and therefore takes less time to download. Internet access is required to pull containers at deployment time.
  For instructions, see [Installing Container Backup Support from IBM Helm Charts Repository and IBM Entitled Registry](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/t_cbs_inst_helmrepo.html).

### Setting up the installation variables

A script is used as part of the installation process for Container Backup Support. Set up the environment and installation variables that are used by the installation script. The variables are saved to the `baas-options.sh` and `baas-values.yaml` files.

#### `baas-options.sh` file

Contains the variables that are used to configure the prerequisites for Container Backup Support. Use this file to replace the sample `baas-options.sh` file that is provided in the installation package.

```bash
export DOCKER_REGISTRY_ADDRESS='your_docker_registry'
export DOCKER_REGISTRY_USERNAME='your_docker_username'
export DOCKER_REGISTRY_PASSWORD='your_docker_password'
export DOCKER_REGISTRY_NAMESPACE='your_docker_registry_namespace'
export SPP_ADMIN_USERNAME='your_protectplus_admin_username'
export SPP_ADMIN_PASSWORD='your_protectplus_admin_password'
export DATAMOVER_USERNAME='make_up_a_datamover_username'
export DATAMOVER_PASSWORD='make_up_a_datamover_password'
export PVC_NAMESPACES_TO_PROTECT='ns1 ns2'
export MINIO_USERNAME='make_up_a_minio_username'
export MINIO_PASSWORD='make_up_a_minio_password'
export BAAS_VERSION='10.1.7'
```

#### `baas-values.yaml` file

Contains the values that are used to install or upgrade Container Backup Support. Use this file to replace the sample `baas-values.yaml` file that is provided in the installation package.

```yaml
license: false | true
isOCP: false | true
clusterName: specify_a_cluster_name
networkPolicy:
  clusterAPIServerips:
    - kubernetes_host_ip1
    - kubernetes_host_ip2
    - kubernetes_host_ip3
  clusterAPIServerport: your_protectplus_server_port
  clusterCIDR: x.x.x.x/yy
SPPips: your_protectplus_server_ip
SPPport: your_protectplus_server_port
productLoglevel: INFO | WARNING | ERROR | DEBUG
imageRegistry: your_docker_registry
imageRegistryNamespace: your_docker_registry_namespace
minioStorageClass: name_of_storageclass_to_use_with_minio
veleroNamespace: ""
```

For detailed information, see [Setting up the installation variables](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/c_spp_cbs_prereq_set_vars.html).

### Installing Container Backup Support in an airgap environment

1. Download the SPP_V10.1.7_for_Containers.tar.gz package from the IBM Passport Advantage Online to your home folder (~).

    [For information about downloading files](https://www.ibm.com/support/pages/node/6330495)

2. Extract the installation package and the .tgz file that contains the Helm 3 chart by issuing the following commands:

   ```bash
   tar -xvf SPP_V10.1.7_for_Containers.tar.gz
   cd installer
   tar -xvf ibm-spectrum-protect-plus-prod-1.1.0.tgz
   ```

   Restriction: Ensure that you do not add any large files to the installer/ibm-spectrum-protect-plus-prod directory. The size of the contents in this directory, including files and subdirectories, must not exceed the limit set by Helm (3145728 bytes).

3. Copy the `baas-options.sh` and `baas-values.yaml` files that you created to the Helm chart
installation directory:

    ```bash
    cd ibm-spectrum-protect-plus-prod/ibm_cloud_pak/pak_extensions/install
    cp ~/install_vars_dir/baas-options.sh .
    cp ~/install_vars_dir/baas-values.yaml .
    chmod +x *.sh
    ```

    where install_vars_dir is the directory where you saved your custom `baas-options.sh` and baasvalues. yaml files.

4. Issue the following command to deploy Container Backup Support:

    ```text
    ./baas-install-ppa.sh
    ```

    For detailed information, see [Installing Container Backup Support in an airgap environment](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/t_spp_cbs_install_proc.html).

### Installing Container Backup Support from IBM Helm Charts Repository and IBM Entitled Registry

1. Complete this one-time preparation to add the IBM Helm Charts repository to the local repository list.
Issue the following commands:

    ```text
    helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm
    helm3 repo list
    helm3 repo update
    helm3 search repo spectrum
    ```

2. Fetch the Container Backup Support Helm package from the IBM Helm Charts Repository:

    ```text
    mkdir installer
    cd installer
    helm3 fetch ibm-helm/ibm-spectrum-protect-plus-prod --version "1.1.0"
    ```

3. Extract the Helm package:

    ```text
    tar -xvf ibm-spectrum-protect-plus-prod-1.1.0.tgz
    helm3 fetch ibm-helm/ibm-spectrum-protect-plus-prod --version "1.1.0"
    ```

    Restriction: Ensure that you do not add any large files to the installer/ibm-spectrum-protect-plus-prod directory. The size of the contents in this directory, including files and subdirectories, must not exceed the limit set by Helm (3145728 bytes).

4. Copy the `baas-options.sh` and `baas-values.yaml` files that you created to the Helm chart
installation directory:

    ```text
    cd ibm-spectrum-protect-plus-prod/ibm_cloud_pak/pak_extensions/install
    cp ~/install_vars_dir/baas-options.sh
    cp ~/install_vars_dir/baas-values.yaml
    chmod +x *.sh
    ```

    where install_vars_dir is the directory where you saved your custom `baas-options.sh` and baasvalues.yaml files.

5. Issue the following command to deploy Container Backup Support:

    ```bash
    ./baas-install-entitled-registry.sh
    ```

    For detailed information, see [Installing Container Backup Support from IBM Helm Charts Repository and IBM Entitled Registry](https://www.ibm.com/support/knowledgecenter/en/SSNQFQ_10.1.7/spp/t_cbs_inst_helmrepo.html).

## Uninstalling the Chart

You can uninstall Container Backup Support completely so that all components, including all configurations and backups, are removed from the Kubernetes or OpenShift environment.

Before you begin:

* Stop all scheduled backups. For instructions, see [Modifying parameters in a YAML file](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/t_spp_cbs_bup_scheduling.html#t_spp_cbs_bup_scheduling__mod_YAML).
* Wait for all running backup and restore jobs to finish.

To completely uninstall Kubernetes Backup Support from the cluster that you are logged in to, complete the following steps on the command line:

1. Destroy all snapshot and copy backups with a destroy request. For instructions, see [Deleting container backups](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/t_spp_cbs_deleting_bups.html).

2. Delete any persistent volume claims (PVCs) that were used for copy backups.
Tip: To determine which PVCs were used for copy backups, look for the names of the PVCs that were backed up.

3. Uninstall Container Backup Support by issuing the following commands:

    ```bash
    cd ~/installer/ibm-spectrum-protect-plus-prod/ibm_cloud_pak/pak_extensions/install
    ./baas-uninstall.sh
    ```

4. Optional: To verify the progress of the uninstallation, enter the following command:

    ```bash
    kubectl get pods -n baas
    ```

5. Optional: For OpenShift: If the amq-streams-cluster-operator pod is still running after the uninstallation is completed, you must manually uninstall it. To uninstall the amq-streams-cluster-operator pod, you must delete all ClusterServiceVersion (CSV) objects in the installation namespace. For example, issue the following command:

    ```bash
    oc delete csv --namespace baas --all
    ```

6. Unregister the Kubernetes or OpenShift cluster by using the IBM Spectrum Protect Plus user interface:

    1. In the navigation pane, take one of the following actions:
      *For Kubernetes: Click Manage Protection > Containers > Kubernetes.
      *For OpenShift: Click Manage Protection > Containers > OpenShift.
    2. Click Manage clusters.
    3. In the list of host addresses, click the deletion icon next the cluster that you want to unregister.
    4. In the Confirm window, enter the displayed confirmation code, and click Unregister.

7. Remove the account identity that is used to register the Kubernetes or OpenShift cluster:

    1. In the navigation pane, click Accounts > Identity.
    2. Click the deletion icon that is associated with the cluster.
    3. Click Yes to delete the identity.

8. Optional: Review the installation and configuration information and revert any prerequisite steps.

## Configuration parameters for Container Backup Support

The configuration parameters of the Container Backup Support Helm chart are provided.

The values for the parameters are specified in the following files:

### `baas-options.sh`

Contains the variables that are used to configure the prerequisites for Container Backup Support. Use this file to replace the sample
`baas-options.sh` file that is provided in the installation package.

### `baas-values.yaml`

Contains the values that are used to install or upgrade Container Backup Support. Use this file to replace the sample
`baas-values.yaml` file that is provided in the installation package.

For more information, see Setting up the installation variables.

The following table contains the descriptions for the environment variables in the `baas-options.sh` file. You must enclose the values with single quotation marks ('').

#### Table 1. Installation variables in the `baas-options.sh` file

<table>
<div>

<thead>
  <tr>
    <th Environment variable</th>
    <th Description</th>
  </tr>
</thead>

<tbody>
<tr>
  <td>DOCKER_REGISTRY_ADDRESS</td>
  <td>The address of the Docker registry where the container images are loaded.<p>To pull images
  from the IBM® Entitled Registry, you must specify <span>cp.icr.io/cp</span><p>The value for DOCKER_REGISTRY_ADDRESS must match the value
  for the <span>imageRegistry</span> parameter in the <span>baas-values.yaml</span>file.</p></td>
</tr>

<tr>
  <td>DOCKER_REGISTRY_USERNAME</td>
  <td>The user account for the Docker registry where the container images are loaded.<p>To pull images from the IBM Entitled Registry, you must specify '<span>cp</span>'.</p></td>
</tr>

<tr>
  <td>DOCKER_REGISTRY_PASSWORD</td>
  <td>The user password for the Docker registry where the container images are loaded.<p>To pull images from the IBM Entitled Registry, specify the entitlement key that you obtained from the <a href="https://myibm.ibm.com/products-services/containerlibrary" rel="noopener" target="_blank" title="(Opens in a new tab or window)">IBM Container software library</a>.</p>
  <p>You can optionally specify an environment variable for the password. For example: ${DOCKERUSER_PW} or ${IBMCLOUD_API_KEY}</p></td>
</tr>

<tr>
  <td>DOCKER_REGISTRY_NAMESPACE</td>
  <td>The namespace of the Docker registry where the container images are loaded.<p>To pull images from the IBM Entitled Registry, you must specify '<span>sppc</span>'.</p>
  <p>The value for DOCKER_REGISTRY_NAMESPACE must match the value for the <span>imageRegistryNamespace</span> parameter in the <span>baas-values.yaml</span> file.</p></td>
</tr>

<tr>
  <td>SPP_ADMIN_USERNAME</td>
  <td>The user ID of the <span>IBM Spectrum® Protect Plus</span> administrator.</td>
</tr>

<tr>
  <td>SPP_ADMIN_PASSWORD</td>
  <td>The <span>IBM Spectrum Protect Plus</span> password.<p>You can optionally specify an environment variable for the password. For example:
  ${PROTECTPLUS_ADMIN_PW}</p></td>
</tr>

<tr>
  <td>DATAMOVER_USERNAME</td>
  <td>The user ID to create for use with the data mover.</td>
</tr>

<tr>
  <td>DATAMOVER_PASSWORD</td>
  <td>The user password to create for use with the data mover.</td>
</tr>

<tr>
  <td>PVC_NAMESPACES_TO_PROTECT</td>
  <td>The list of namespaces that contain the persistent volume claims (PVCs) that you want to
  protect. Use this variable when you plan to pull images from an external Docker registry or
  repository. Separate the namespaces with intervening spaces. For example: 'namespace1 namespace2'<p>
  To obtain the values for PVC_NAMESPACES_TO_PROTECT, determine the PVCs that you want to protect by
  issuing the following command:</p>
  <code>kubectl get pvc --all-namespaces</code><p>Identify the PVCs that you
  want to protect and specify the unique set of namespaces that are associated with the PVCs.</p>
  <p>During the installation process, an image pull secret for the remote registry is created
  automatically and copied to the namespaces that are associated with the PVCs.</p></td>
</tr>

<tr>
  <td>MINIO_USERNAME</td>
  <td>The username of the MinIO user. MinIO object storage is used to store backups of cluster and namespace resources.</td>
</tr>

<tr>
  <td>MINIO_PASSWORD</td>
  <td>The password for the MinIO user.</td>
</tr>

</tbody>
</table>
</div>

<br /><p>The following table contains the descriptions and default values for the configuration parameters
in the <span>baas-values.yaml</span> file:</p><br />

<div>

<table>

Table 2. Configuration parameters in the <span>baas-values.yaml</span> file.

<thead>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Default value</th>
  </tr>
</thead>

<tbody>

<tr>
  <td><span>license</span></td>
  <td>The product license for <span>Container Backup Support</span>. The English license file is located in the <span>LICENSES/LICENSE-en</span> directory, which is
  included in the installation package. Versions of the license in other languages are available at <a href="http://www-03.ibm.com/software/sla/sladb.nsf/searchlis/?searchview&amp;searchorder=4&amp;searchmax=0&amp;query=(Spectrum+Protect+Plus)" rel="noopener" target="_blank" title="(Opens in a new tab or window)">License Information documents</a>.<p>Review the license information, and specify <span>true</span> to accept the license during installation without being prompted.</p></td>
  <td>false</td>
</tr>

<tr>
  <td><span>isOCP</span></td>
  <td>Sets the type of cluster that you are installing <span>Container Backup Support</span> on. Set <span>IS_OCP</span> to
  <span>true</span> for an OpenShift® cluster and <span>false</span> for a Kubernetes cluster.</td>
  <td>false</td>
</tr>

<tr>
  <td><span>clusterName</span></td>
  <td>The unique cluster name that is used to register the application host to the <span>IBM Spectrum Protect Plus</span> server.</td>
  <td>None</td>
</tr>

<tr>
  <td><span>clusterAPIServerips</span></td>
  <td >The IP address for the cluster API server. To obtain the cluster API server address, issue the following command:
  <pre><code>kubectl get endpoints -n default -o yaml kubernetes</code></pre>
  <div>Use all of the provided addresses listed under the <span>addresses</span> field in the output, or add or remove IP
  addresses as needed. Specify multiple addresses as follows:<pre><code>networkPolicy:
  clusterAPIServerips:
    - <var>x.x.x.x</var>
    - <var>y.y.y.y</var>
    - <var>z.z.z.z</var></code></pre></div></td>
  <td><var>x.x.x.x</var></td>
</tr>

<tr>
  <td><span>clusterAPIServerport</span></td>
  <td>The port address for the cluster API server.</td>
  <td>6443</td>
</tr>

<tr>
  <td><span>clusterCIDR</span></td>
  <td>The Classless Inter-Domain Routing (CIDR) value for the cluster. To obtain the CIDR, issue
  the following command:<div>For Kubernetes:
  <pre><code>kubectl cluster-info dump | grep -m 1 cluster-cidr</code></pre></div>
  Note: If the command does not return the CIDR value, change the<span>grep</span>
  expression to look for the combination of "cluster" and "CIDR" and run the command again.
  <div>For OpenShift:
  <pre><code>oc get network -o yaml | grep -A1 clusterNetwork:</code></pre></div>
  <p>Use the displayed IP
  address as the cluster CIDR address.</p></td>
  <td><code>192.168.0.0/16</code></td>
</tr>

<tr>
  <td><span>SPPips</span></td>
  <td>The <span>IBM Spectrum Protect Plus</span> server IP address.</td>
  <td><var>x.x.x.x</var></td>
</tr>

<tr>
  <td><span>SPPport</span></td>
  <td>The <span>IBM Spectrum Protect Plus</span> server port.</td>
  <td>443</td>
</tr>

<tr>
  <td><span>productLoglevel</span></td>
  <td>The trace levels for troubleshooting issues with the <span>Container Backup Support</span> transaction manager, controller, and
  scheduler components. The following trace levels are available: INFO, WARNING, DEBUG, and ERROR.</td>
  <td><code>INFO</code></td>
</tr>

<tr>
  <td><span>imageRegistry</span></td>
  <td>The address of the Docker registry where the container images are loaded.
  <p>To pull images from the IBM Entitled Registry, you must specify <span>cp.stg.icr.io/cp</span>.</p>
  <p>The value for the <span>imageRegistry</span> parameter must match the value for the
  DOCKER_REGISTRY_ADDRESS variable in the <span>baas-options.sh</span> file.</p></td>
  <td><var>&lt;docker-repo-hostname&gt;</var>:5000</td>
</tr>

<tr>
  <td><span>imageRegistryNamespace</span></td>
  <td>The namespace of the Docker registry where the container images are loaded.<p>To pull images from the IBM Entitled Registry,
  you must specify <span>sppc</span>.</p><p>The value for the <span>imageRegistryNamespace</span>
  parameter must match the value for the DOCKER_REGISTRY_NAMESPACE variable in the <span>baas-options.sh</span> file.</p></td>
  <td><cod>baas</code></td>
</tr>

<tr>
  <td><span>minioStorageClass</span></td>
  <td>The name of the storage class to use for the MinIO server. The MinIO server is used to store
  the backups of cluster and namespace resources.<p>If you do not specify a value for this parameter,
  the default storage class of your cluster is used. Ensure that a default storage class is
  defined.</p></td>
  <td>None</td>
</tr>

<tr>
  <td><span>veleroNamespace</span></td>
  <td>Specify the namespace of the Velero installation that is dedicated to <span>IBM Spectrum Protect Plus</span>
  <span>Container Backup Support</span>, for example,
  <code>spp-velero</code>.<p>If you do not specify a value for this parameter, Velero integration is disabled and you can use <span>Container Backup Support</span> to
  protect only persistent volume claims (PVCs).</p></td>
  <td>None</td>
</tr>

</tbody>
</table>
</div>

## Limitations

* You cannot deploy the product more than once
* A rollback to a previous version of the product is not supported. In other words, you cannot use Kubernetes Backup Support V10.1.5 to restore data that was backed up by Container Backup Support V10.1.7.

For more information, see [Additional limitations and known problems](https://www.ibm.com/support/pages/node/567387)

## Documentation

For more information about Container Backup Support, see the following resources in IBM Knowledge Center:

* [Protecting containers](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/c_spp_protecting_containers.html)
* [Container Backup Support requirements](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/r_spp_system_reqs_cbs.html)
* [Installing Container Backup Support](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/c_spp_cbs_installation.html)
* [Protecting containers by using the command line](https://www.ibm.com/support/knowledgecenter/SSNQFQ_10.1.7/spp/c_spp_cbs_using_cmdline.html)
