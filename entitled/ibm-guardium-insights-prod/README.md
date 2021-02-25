# IBM Security Guardium Insights

## Introduction
IBM Security Guardium Insights simplifies your organization's Data Security architecture and enables access to long-term data security and compliance data. It provides security teams with risk-based views and alerts, as well as advanced analytics based on proprietary ML technology to uncover hidden threats. Guardium Insights gives security professionals the ability to quickly create data security and audit reports, monitor activity in on-prem and DBaaS sources, and take action from a central location.

For more information about the product, please visit the <a href="https://www.ibm.com/support/knowledgecenter/SSWSZ5" target="_blank">product Knowledge Center</a>.

## Chart Details

The ibm-guardium-insights-prod chart installs IBM Guardium Insights.

## Prerequisites

- Red Hat OpenShift Container Platform 4.3.x
- IBM Cloud Platform Common Services 3.2.4
- Cluster admin privileges
- helm 2.12x to 2.17x
- cloudctl 3.2.4 or later
- oc cli tool 4.3.x or later
- kubectl cli tool 1.16 or later
- docker 17.03 or later (only required if deploying via an air-gapped workflow)
- openssl cli tool 1.1.1h or later
- ssh-keygen cli tool

### SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement, you may need to take actions to prepare your cluster and namespace.

The predefined SecurityContextConstraints named [ibm-restricted-scc](https://ibm.biz/cpkspec-scc), [ibm-privileged-scc](https://ibm.biz/cpkspec-scc), and [restricted](https://ibm.biz/cpkspec-scc) have been verified for this chart. If your target namespace is bound to these SecurityContextConstraints, you can proceed with chart installation.

Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "[DEPRECATED] This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host.
      The UID and GID will be bound by ranges specified at the Namespace level."
    cloudpak.ibm.com/version: "1.2.0"
    cloudpak.ibm.com/deprecated: true
  name: ibm-restricted-scc
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
# This can be customized for seLinuxOptions specific to your host machine
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
  - max: 65535
    min: 1
# This can be customized to host specifics
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## Resources Required

Refer to https://www.ibm.com/support/knowledgecenter/SSWSZ5_2.5.x/sys_req_hardware_cluster.html for resource requirements.

## Installing the Chart

This step requires:

- IBM Security Guardium Insights entitlement.
- Access to Guardium Insights images and charts.
- That you choose an installation method (online vs offline).

This table depicts the difference between online and offline deployment:

| Method | Registry | High level steps |
| --- | --- | --- |
| Online | IBM Entitled Registry | <ol><li> Download IBM Guardium Insights chart. </li><li> Deploy chart. </li></ol> |
| Offline/air-gapped | OpenShift Internal Registry or your enterprise's secured registry | <ol><li> Download chart and all images from IBM Passport Advantage. </li><li> Load image. </li> <li> Push image. </li> <li> Deploy chart. </li> </ol>  |


### Method 1 - Online deployment

To install IBM Security Guardium Insights in an environment online, access the software directly through the IBM Security Guardium Insights Helm charts and the IBM Entitled Registry images. 

#### Before You Begin

Before you install the charts, ensure that you have an entitlement key for IBM Guardium Insights. The entitled key is required during a pre-installation step of the IBM Security Guardium Insights chart deployment, which creates an image pull secret. To obtain an entitlement key from the IBM Entitled Registry, complete these steps:

1. Log in to the [IBM Container software library](https://myibm.ibm.com/products-services/containerlibrary) using your IBMid.
2. Select Get **Entitlement key** in the navigation panel on the left.
3. Click **Copy key** in the **Access your container software** page.
4. Store the key in a safe location.

To confirm that your entitlement key is valid for IBM Security Guardium Insights, select **View library** in the left navigation panel of the Container software library. This shows you a list of products that you are entitled to. If IBM Security Guardium Insights is not listed, or if the **View library** link is not available, the username with which you are logged in to the container library does not have entitlement for IBM Security Guardium Insights. In this case, the entitlement key will not be valid for installing the software.


#### Installing the IBM Security Guardium Insights Chart

1- Download the IBM Security Guardium Insights Helm chart using one of these methods:<br/>

a. In [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/), locate your subscription to IBM Security Guardium Insights and download the archive file from there. The chart will be located within the archive file.<br/>
b. Download the chart from the [IBM Charts Helm Repository](https://github.com/IBM/charts).

2- Extract the archive file.

3- Ensure that you can use the OpenShift client (**oc**) command to connect to your OpenShift Cluster, and that you have **openssl** version 1.1.1h or later, **kubectl** version 1.16 or later, and **ssh-keygen** installed on your machine.

4- Collect the parameter values that are required for the **preInstall** and **install** scripts. Refer to [Parameters for preInstall.sh](#parameters-for-pre-install) and [Parameters for install.sh](#parameters-for-install).

5- To ensure that the correct storage class is used, set it in the **helm_options** file. This file is located in the same folder as **installer.sh** and it contains properties that must be set prior to deployment. Open the file in an editor such as **vi** and then specify the storage class according to your target (on-prem, IBM Cloud, or AWS). The setting in the file initially looks like this:

```
global.storageClass="value"
ibm-db2u.storage.storageLocation.dataStorage.pvc.claim.storageClassName="Value"
ibm-db2u.storage.storageLocation.metaStorage.pvc.claim.storageClassName="Value"
ticketing.persistentVolumesClaims.ticketing-keystore.storageClassName="Value"
```

An example of how this might be edited is:

```
global.storageClass="rook-ceph-block-internal"
ibm-db2u.storage.storageLocation.dataStorage.pvc.claim.storageClassName="rook-ceph-block-internal"
ibm-db2u.storage.storageLocation.metaStorage.pvc.claim.storageClassName="rook-ceph-cephfs-internal"
ticketing.persistentVolumesClaims.ticketing-keystore.storageClassName="rook-ceph-cephfs-internal"
```
The **installer.sh** script reads the entries in the **helm_options** file, validates the storage class existence on the
target cluster, and then passes them to the helm chart deployment. If these property values are not set, the installer
will omit this step and continue the deployment assuming the storageClass specifications are set in the **values.yaml**
file.

6- Run the **preInstall.sh** script for installing the prerequisites of the IBM Security Guardium Insights deployment. This script will create all prerequisites for the system, including:

   - Namespace (if it does not already exist)
   - Roles and role bindings
   - Security Context Constraints (SCC)
   - Service accounts
   - Secrets, including the registry pull secret
   - Certificates

```
$ ./ibm_cloud_pak/pak_extensions/pre-install/preInstall.sh
```

If you run the **preInstall.sh** script without parameters, instructions for using the script will be returned. The script is not interactive script and the parameters must be passed properly. The mandatory and optional parameters are described in this [table](#parameters-for-preinstall).

This example demonstrates mandatory parameter usage:

```
$ ./ibm_cloud_pak/pak_extensions/pre-install/preInstall.sh -n staging -a icp-admin -p <icp-admin-password> -h worker2.samplecluster.ibm.com -t true -i cp.icr.io/cp/ibm-guardium-insights -w cp -x <entitlement-key-from https://myibm.ibm.com/products-services/containerlibrary >  
```

And this example demonstrates both mandatory and optional parameter usage:

```
$ ./ibm_cloud_pak/pak_extensions/pre-install/preInstall.sh -n staging -a icp-admin -p <icp-admin-password> -h worker2.samplecluster.ibm.com -t true -i cp.icr.io/cp/ibm-guardium-insights -w cp -x <entitlement-key-from https://myibm.ibm.com/products-services/containerlibrary >  -s true -k none -f none -c none
```

Running the preInstall.sh script generates secrets that you can override with your own secrets. To see the secrets that were created by the script so that you can override them, issue this command: `oc get secrets -n <Guardium Insights Openshift Namespace>`. To see the contents of a secret, run this command: `oc get secret -n <Guardium Insights Openshift Namespace> <secret name> -o yaml`

Please see the [Knowledge Center documentation](https://www.ibm.com/support/knowledgecenter/SSWSZ5_2.5.x/install_prep_insights.html) for more information on this.

7- Run **installer.sh**  to deploy the IBM Security Guardium Insights helm chart. Parameters for this script are described [here](#parameters-for-install) (all of the parameters are mandatory).

```
$ ./installer.sh
```

The installer.sh script can be run interactively (this is the default behavior) or non-interactively.

For example, this would run the script non-interactively since all parameters are specified:

```
$ ./installer.sh -n staging -h staging.apps.samplecluster.ibm.com -l true -i cp.icr.io/cp/ibm-guardium-insights -o values-small.yaml -y L-TESX-BTCSA5
```

8- After running installer.sh, it may take another 15 to 25 minutes for all pods in the Guardium Insights namespace to reach the **Running** state. When the pods are running and your application is ready to be used, the configmap will be available. Use this command to determine if the configmap exists:

```
$ oc get cm -n <Guardium Insights Namespace> | grep tenant-postdeploy-ready
```

If the configmap does not yet exist, repeat the command until it does. When you have determined that the configmap is present, Guardium Insights is ready to be used.

Make note of the **access endpoint** URL in the installer message copy and paste it in a browser (the URL will be **https://\<access endpoint\>**). Log in with the same tenant user <icp-admin> and <icp-admin-password> that was used in step 6 above.


### Method 2 - Offline/air-gapped deployment
With this method, you download IBM Security Guardium Insight images from IBM Passport Advantage and then store them in an intermediate registry (Openshift Internal Registry or your enterprise's secured registry). A registry pull secret will be created by the installer to pull images from your desired registry for the deployment.


#### Before you Begin 

With this method, you will choose a registry for the deployment and download IBM Security Guardium Insights images and charts from [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/). The registry can be one of the following:

1. OpenShift Internal Registry
2. Your enterprise's secured registry (with valid CA certificate installed)

During installation, a registry image pull secret will be created for whichever method you choose. Note that, for offline deployments, there are some extra steps for loading and pushing images that are not required for online deployments. 


#### Unzip, load, and push images

1- Ensure that you are logged in to the Openshift command line interface (CLI).

2- Extract the downloaded Guardium Insights archive to a folder of your choice. After extracting the file, you will find several folders, including these two:

```
insights_images
insights_chart
```

3- Navigate to the insights_images directory and run dockerLoad.sh to load all images to your local system. Then run the `docker images` command to see the images that were loaded.

``` 
$./dockerLoad.sh
$ docker images
```

4- If you are deploying with the **OpenShift Internal Registry**: Prepare the Guardium Insights namespace for setting up the image stream by issuing this command:

```
$ oc create namespace <Guardium Insights Openshift Namespace>  
```

Note: The namespace must be 10 or fewer characters.


5- If you are deploying with the **OpenShift Internal Registry**: Run this command to patch the image registry to allow the images to be pushed:

```
$ oc patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'
```

6- If you are deploying with the **OpenShift Internal Registry**: Run these commands to prepare the docker login flow:

```
$ NAMESPACE=<Guardium Insights Openshift Namespace>
$ OC_REGISTRY_NAMESPACE=$(oc get route --all-namespaces | grep "image-registry" | awk '{print $1}')
$ export REPOSITORY=$(oc get route default-route -n=$OC_REGISTRY_NAMESPACE --template '{{.spec.host}}')/$NAMESPACE
$ export REPO_LOAD_USERNAME=$(oc whoami)
$ export REPO_LOAD_PASSWORD=$(oc whoami -t)
```
After you run the commands, run 'echo $REPOSITORY'. The result should be similar to this:


`default-route-openshift-image-registry.apps.<cluster domain>/<Guardium Insights Openshift Namespace>`


This is the OpenShift docker registry external access endpoint that you will use with docker login and the docker push operation.

7- If you are deploying with your **Enterprise's Secured Registry**: Run these commands:

```
$ export REPOSITORY="your-docker-registry"
$ export REPO_LOAD_USERNAME="Your username"
$ export REPO_LOAD_PASSWORD="Your password"
```

8- Log in to the registry by running this command:

```
$ docker login -u $REPO_LOAD_USERNAME -p $REPO_LOAD_PASSWORD $REPOSITORY
```

If you are using self-signed certificates and receive this error:

```
Error response from daemon: Get https://default-route-openshift-image-registry.apps.<cluster domain>/v2/: x509: certificate signed by unknown authority
```

You can work around the error by adding the OpenShift cluster docker registry to the list of trusted insecure registries in your docker client (see <https://docs.docker.com/registry/insecure>).


9- Push the IBM Guardium Insights images to your chosen docker registry by issuing this command:
 
```
$ ./dockerPush.sh $REPOSITORY
```

Note: Issuing this command will tag and push Guardium Insights images to the selected docker registry. This will take a long time (if this is the first time you are doing this, the approximate time for completion is between 30 and 40 minutes).

#### Installing the IBM Security Guardium Insights chart

The instructions for installing the chart are the same as they are for an online deployment. See [Installing the IBM Security Guardium Insights Chart](#installing-the-ibm-security-guardium-insights-chart), and follow step 3 and on.


## Parameters for Pre-Install

| Name | Description| Type |
| --- | --- | --- |
| -n or <br> --i-namespace | IBM Security Guardium Insights Openshift namespace (this value must be 10 or fewer characters and it is the same value as is used for the Helm Release). | Mandatory |
| -a or <br> --icp-authadmin | IBM Cloud Platform Common Services admin user. | Mandatory |
| -p or <br> --icp-authpwd | IBM Cloud Platform Common Services admin password. | Mandatory |
| -h or <br> --host-datanodes | Hostpath of the data node or nodes (comma delimited). | Mandatory |
| -t or <br> --taint-datanodes | If you specify 'true', data nodes will be tainted and dedicated for data service usage. If you specify 'false', tainting will be skipped (do not use 'false' to skip tainting for production deployments). | Mandatory |
| -i or <br> --registry  | Image registry from which the images will be pulled. Specify 'cp.icr.io/cp/ibm-guardium-insights' to pull from the IBM Entitled Registry. Otherwise, specify a private docker registry or OpenShift internal registry (image-registry.openshift-image-registry.svc:5000/<insights openshift namespace>). Both cases require the images to be pushed manually. | Mandatory |
| -w or <br> --registry-user | Image registry authentication user. If this is the IBM Entitled Registry, the user should be 'cp'. | Mandatory for IBM Entitled Registry <br> Optional for Openshift Internal registry |
| -x or <br> --registry-pwd | Image registry authentication password or API key. | Mandatory for IBM Entitled Registry <br> Optional for Openshift Internal registry |
| -s or <br> --secret-replace | Force replace existing secrets (true/false). By default, this is 'false'. This option supports special scenario to get data reused with existing secret. | Optional |
| -k or <br> --ingress-keystore | If you will supply a custom Ingress [Recommended], provide the path to its key file. If you do not include this, a default of 'none' will be assumed (this is not recommended). | Optional |
| -f or <br> --ingress-cert | If you will supply a custom Ingress [Recommended], provide the path to its cert file. If you do not include this, a default of 'none' will be assumed (this is not recommended). | Optional |
| -c or <br> --ingress-ca | If you will supply a custom Ingress [Recommended], provide the path to its certificate authority (CA) file. If you do not include this, a default of 'none' will be assumed (this is not recommended). | Optional |

## Parameters for Install

The installer.sh script supports both interactive and non-interactive mode. If you are running the script in non-interactive mode, these are the parameters you will need to include. All parameters are **mandatory**.

| Name | Description|
| --- | --- |
| -n | IBM Security Guardium Insights Openshift namespace (this value must be 10 or fewer characters and it is the same value as is used for the Helm Release). |
| -h | global.insights.ingress.hostName for Ingress user interface access (for example, insight.apps.new-coral.plum-sofa.com). |
| -l | global.licenseAccept (true/false). Review the license files (LICENSE_en, LICENSE_notices and LICENSE_non_ibm_license) within the licenses/Licenses/L-TESX-XXXXXX folder and specify true to agree to them them. If you specify false, the installation will not proceed. This parameter is not case-sensitive. |
| -i | Image registry from which images will be pulled. Specify "cp.icr.io/cp/ibm-guardium-insights" to pull from the IBM Entitled Registry. Otherwise, use a private docker registry or OpenShift internal registry (`image-registry.openshift-image-registry.svc:5000/<insights openshift namespace>`). Both cases require the images to be pushed manually. |
| -o | Override YAML (examples include values-small.yaml, values-med.yaml, and values-xxx.yaml) |
| -y | This is the license that you accept corresponding to the version of Guardium Insights you wish install. Select the version by selecting the corresponding license in the 'licenses/Licenses' folder (for example, L-TESX-XXXXXX). |

## Configuration

This table lists the configurable properties of the ibm-guardium-insights-prod chart.

| Option | Type| Description |
| --- | --- | --- |
| `global.storageClass` |  Mandatory | Storage class of type block storage, for example `rook-ceph-block-internal`. |
| `ibm-db2u.storage.storageLocation.dataStorage.pvc.claim.storageClassName` |  Mandatory | Storage class of type block storage, for example `rook-ceph-block-internal`. |
| `ibm-db2u.storage.storageLocation.metaStorage.pvc.claim.storageClassName` |  Mandatory | Storage class of type file storage, for example `rook-ceph-cephfs-internal`. |
| `ticketing.persistentVolumesClaims.ticketing-keystore.storageClassName` |  Mandatory | Storage class of type file storage, for example `rook-ceph-cephfs-internal`. |
| `global.insights.ingress.hostName` |  Mandatory <br> Set by the installer| Must be set to the reachable hostname, for example `<your namespace>.apps.<openshift host>` |
| `global.licenseAccept=true` |  Mandatory <br> Set by the installer | Review the license files (LICENSE_en, LICENSE_notices and LICENSE_non_ibm_license) in the licenses/Licenses/L-TESX-XXXXXX folder. |
| `global.license`| Mandatory <br> Set by the installer | Set to true to confirm that you have read and agreed to the license agreements : http://ibm.biz/oms-license & http://ibm.biz/oms-apps-license |
| `global.insights.licenseType`| Mandatory <br> Set by the installer | Enter the product license to accept. This license corresponds to the version of Guardium Insights you wish install. These are found in the licenses/Licenses folder, and should be in the form "L-TESX-XXXXXX" corresponding to one of the several Guardium Insights Versions available. |
| `global.image.repository=<PathToRegistry>` | Mandatory <br> Set by the installer | Image registry from which images will be pulled. Specify "cp.icr.io/cp/ibm-guardium-insights" to pull from the IBM Entitled Registry. Otherwise, use a private docker registry or OpenShift internal registry (`image-registry.openshift-image-registry.svc:5000/<insights openshift namespace>`). Both cases require the images to be pushed manually. |
| `global.imageRegistry=<PathToRegistry>` | Mandatory <br> Set by the installer | Same as above (required by different subcharts). |
| `global.insights.icp.authEndpoint=https://icp-console.apps.<openshift host>"` |  Optional | IBM Cloud Platform Common Service authEndpoint. |
| `mongodb.existingClaim`| Optional | Supply an existing persistent volume claim (PVC) for reusing tenant data from a previous installation. If this option is enabled, you must also ensure that file paths and permissions are correctly set within the existing volume being reused. |

## Storage

This table depicts the storage specifications required for a small tier installation. To see the storage specifications for larger installations, see the <a href="https://www.ibm.com/support/knowledgecenter/SSWSZ5_2.5.x/sys_req_hardware_cluster.html" target="_blank">product hardware requirements page</a>.

| Components | Storage type (block/file) | Access mode (RWO/RWX) | Deployment replicas | Recommended storage |
| :---: | :---:| :---: | :---: | :---: |
| Kafka | Block | RWO | 3 | 250 GB |
| Zookeeper | Block | RWO | 3 | 20 GB |
| MongoDB | Block | RWO | 2 | 50 GB |
| DB2 WH (data) | Block | RWO | 1 | 5 TB |
| DB2 WH (metadata), Datamart Landing Zone, CSV Export | File | RWX | 1 | 1 TB |
| Ticketing Keystore | File | RWX | 1 | 2 MB |

## Upgrading Insights

There is no direct upgrade path available from previous release. However, you can back up an older version of Guardium Insights and then restore it. This will be documented separately.


## Uninstalling Guardium Insights Chart

To delete the helm deployment, issue this command:

```
$ helm delete --purge --tls <Guardium Insights Release name> 
```

To delete the namespace, issue this command (this action will remove all objects from the namespace):

```
$ oc delete namespace <Guardium Insights namespace>
```

To delete the remaining pre-install configuration objects from the cluster, run these commands:

```
$ oc delete scc db2wh-scc 
$ INSIGHTS_NAMESPACE=<Guardium Insights Release name> 
$ oc adm policy remove-scc-from-user ibm-restricted-scc system:serviceaccount:${INSIGHTS_NAMESPACE}:insights-sequencersa
$ oc adm policy remove-scc-from-user ibm-restricted-scc system:serviceaccount:${INSIGHTS_NAMESPACE}:insights-sa
$ oc adm policy remove-scc-from-user ibm-privileged-scc system:serviceaccount:${INSIGHTS_NAMESPACE}:bitnami-sa 
```
## Limitations

- Only one instance of IBM Guardium Insights can reside on a cluster.
- The chart can only run on amd64 architecture type.

## Refreshing certificates

By default, all certificates and TLS secrets in Guardium Insights (excluding Db2 Warehouse) are valid for 365 days after installation and will automatically be refreshed during the last 10 days.
However, the certificates and secrets can be refreshed manually be running this script:

```
./ibm_cloud_pak/pak_extensions/support/regenerateCerts.sh
```

## Refreshing the registry pull secret

A registry pull secret will be created by the **preInstall.sh** script using the supplied registry, username, and API-Key/password. If the API-key/Password is changed, or if you want to use a separate registry user and password combination, the registry pull secret will need to be refreshed. Use this script to refresh the registry pull secret:

```
./ibm_cloud_pak/pak_extensions/support/registryPullSecret.sh
```

## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSWSZ5).
