# IBM® IoT MessageSight™ Developer Edition
IBM IoT MessageSight is a messaging application that is designed to process large volumes of events in near real-time and to handle
many concurrently connected devices, such as sensors or mobile devices.

IBM IoT MessageSight (MessageSight) provides secure, rapid, bidirectional messaging for the Internet of Things (IoT) 
and mobile environments. MessageSight delivers the performance, value, and simplicity you need to accommodate the 
growing number of mobile devices and sensors. MessageSight helps you to open new mobile use cases with low 
latency, bidirectional control. You can push secure information to mobile apps and enable a more interactive, immersive
experience.

For more information about IBM IoT MessageSight, see the [IBM IoT MessageSight product documentation](https://www.ibm.com/support/knowledgecenter/en/SSWMAJ_2.0.0/WelcomePage/ic-homepage.html).

## Introduction

This chart deploys the following two applications:
- The MessageSight messaging server.
- The MessageSight Web UI which provides a convenient graphical interface for managing one or more MessageSight servers, and
visualization utilities for monitoring the server.

## Chart Details
- The chart consists of IBM IoT MessageSight V2.0 Developer Edition.
- The chart is only for IBM IoT MessageSight developer deployments.
- The chart can install both the MessageSight server and Web UI in a single helm release. Alternatively, each subchart can be installed in its own helm release.
- The chart can be installed in any namespace.
- More than one release can be created for this chart. However, you must take care to avoid port conflicts if you reference
the same proxy node in more than one release.
- By default, the following ports are exposed externally:

  **MessageSight Server**
  - 9089 - The MessageSight server port for the REST API.
  - 1883, 16102 - The MessageSight server messaging ports for two demo messaging endpoints.
  These messaging endpoints are preconfigured in the MessageSight server.
  
  **MessageSight Web UI**
  - 9087 - The port for accessing the MessageSight Web UI.

## Before you Begin

You should install MessageSight in a non-default namespace. When you install in non-default namespaces, the charts assume 
that you have created default non-privileged and privileged ServiceAcccounts to install MessageSight.  You can find yaml
configuration files and scripts to set up these default objects in the [ibm_cloud_pak](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev/ibm_cloud_pak) for MessageSight under pak_extensions/prereqs. 

_Note: The ibm_cloud_pak is located with the [MessageSight chart content on github](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev)._

### For Clusters with LDAP configured
---

If LDAP is configured in your cluster, there are a few additional steps to perform to allow authenticated users to
install MessageSight.  The steps in this section must be performed by a cluster administrator and describe the general
process for creating a team and assigning users and resources to the team.  For more details about creating and configuring
teams, see [Managing access to your platform](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0.3/user_management/teams.html).

**1.** Use the ICP UI or REST API to create a team for MessageSight.  For example, create a team called messagesight-team.

**2.** Use the ICP UI or REST API to add one or more individual users or groups to the team created in step 1.

**3.** Create one or more namespaces where MessageSight will be installed.
```
kubectl create namespace <namespace_name>
```

Example:
```
kubectl create namespace messagesight
```

**4.** Use the ICP UI or REST API to add the namespace(s) created in step 3 to the team created in step 1.

### One-time configuration steps
---

To install MessageSight into non-default namespaces, you must create pod security policies (PSPs) and 
roles that are used to grant service accounts access to install MessageSight.  These configuration actions 
require cluster administrator access.

Download the following files and script:
Configuration files:
  - [messagesight-cr-psp.yaml](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev/ibm_cloud_pak/pak_extensions/prereqs/messagesight-cr-psp.yaml) 
  - [messagesight-priv-cr-psp.yaml](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev/ibm_cloud_pak/pak_extensions/prereqs/messagesight-priv-cr-psp.yaml) 

Script:
  - [createDefaultPSPAndRole.sh](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev/ibm_cloud_pak/pak_extensions/prereqs/createDefaultPSPAndRole.sh)
  
Run the createDefaultPSPAndRole.sh script to create the PSPs that are used to grant install access to the 
service accounts that are created in the next section.


### Steps for each namespace where MessageSight is installed
---

If the namespace has not been created, use the following command to create the namespace. This command requires cluster
administrator access.
```
kubectl create namespace <namespace_name>
```

Example:
```
kubectl create namespace messagesight
```

If LDAP is configured for your cluster, see the **For Clusters with LDAP configured** section for information 
about namespace resources for teams.

Download the following files and scripts:
- Configuration files:
  - [messagesight-sa-rb.yaml](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev/ibm_cloud_pak/pak_extensions/prereqs/messagesight-sa-rb.yaml) 
  - [messagesight-priv-sa-rb.yaml](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev/ibm_cloud_pak/pak_extensions/prereqs/messagesight-priv-sa-rb.yaml) 

- Scripts:
  - [createDefaultSvcAcctsAndRoleBindings.sh](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev/ibm_cloud_pak/pak_extensions/prereqs/createDefaultPSPAndRole.sh)
  - [addPullSecretToSvcAccts.sh](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev/ibm_cloud_pak/pak_extensions/prereqs/addPullSecretToSvcAccts.sh)

Run the createDefaultSvcAcctsAndRoleBindings.sh script to create service accounts, messagesight-sa and messagesight-priv-sa.
These accounts are the default service accounts that are used to install MessageSight. The script takes one required argument
and one optional argument. The first (required) argument is the namespace name.  The second (optional) argument is the name 
of an image pull secret that the service accounts can use to retrieve the MessageSight Docker images.  You only need to
specify an image pull secret if your cluster is not connected to the Internet and cannot retrieve the Docker images from
ibmcom. (_Note: These instructions assume that you have completed the tasks that are required to retrieve and store the 
Docker images in a repository that your cluster can access._)

You can optionally add an image pull secret to your default service accounts later.  Run the
addPullSecretToSvcAccts.sh script to add an image pull secret to your service accounts.  This script 
takes two arguments; the namespace where the service accounts were created and the name of the of an image pull secret for
your Docker repository.  

_Note: If you specify an image pull secret for your service accounts, you must ensure that the secret exists in the 
namespace where you create or update the service accounts._


## Prerequisites
- At least one proxy node with an external IP address is required to install this chart. This must be an IP address that is
reachable by the IoT devices that send messages to and receive messages from the MessageSight server.
- _**Recommended**_ Create non-default namespaces for your MessageSight chart installations.
- Pod security policies, roles, service accounts, and role bindings must be created for non-default namespaces where the
MessageSight chart is installed. See the **Before you Begin** section for steps, configuration files, and scripts.

## Resources Required
__MessageSight Server__

By default, the MessageSight Server subchart uses the following resources:
- Minimum: 4 CPU core and 4Gi memory
- Recommended: 8 CPU core and 8Gi memory

_**Note: When configuring storage for the MessageSight server, it must be at least four times the amount of memory configured.  Therefore, a minimum of 16Gi storage is required and 32Gi storage is recommended.**_  

__MessageSight Web UI__

By default, the MessageSight Web UI subchart uses:
- Minimum: 2 CPU core and 2Gi memory
- Recommended: 4 CPU core and 4Gi memory

## Installing the Chart

Complete the following steps to install MessageSight:

**1.** (_**Required for the MessageSight server subchart**_) Create the MessageSight admin secret.

The admin endpoint in the MessageSight server requires a secret that stores the superuser ID and password. Follow these steps
to deploy the default secret.

Download the following file and script:
- Configuration file:
  - [messagesight-secret.yaml](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev/ibm_cloud_pak/pak_extensions/prereqs/messagesight-secret.yaml)
  
- Script:
  - [createMessageSightSecretForRelease.sh](https://github.com/IBM/charts/tree/master/stable/ibm-messagesight-dev/ibm_cloud_pak/pak_extensions/prereqs/createMessageSightSecretForRelease.sh)
  
Run the createMessageSightSecretForRelease.sh script to create the secret for the release that you want to install.
This script takes two arguments; the release name that you want to use to install MessageSight, and the namespace where you
want to install this release.

**2.** Find the external IP address for a  proxy node in your cluster.

There might be more than one proxy node.  An external IP address for at least one proxy node is required.

You can use this command to get a list of external IP addresses for proxy nodes in your cluster.  Note that this
command fails if there are no proxy nodes with external IPs assigned.  This command might fail for some cluster 
configurations that provide external IPs for proxy nodes.  Consult with your cluster administrator for assistance in 
this case.
```
kubectl get nodes --selector=proxy=true \
-o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}'
```

**3.** Install the chart.

- To install both the MessageSight server and Web UI with release name `msightrel1` in namespace `messagesight` where the external IP for the proxy node is `12.3.4.56`, use the following command:
  ```
  helm install --name msightrel1 ibm-messagesight-dev --namespace messagesight \
  --set global.license=accept --set global.virtualIP=12.3.4.56 \
  --set messagesight.enabled=true --set messagesightui.enabled=true 
  ```

- To install only the MessageSight server with release name `msightrel1s` in namespace `messagesight` where the external IP for the proxy node is `12.3.4.56`, use the following command: 
  ```
  helm install --name msightrel1s ibm-messagesight-dev --namespace messagesight \
  --set global.license=accept --set global.virtualIP=12.3.4.56 \
  --set messagesight.enabled=true --set messagesightui.enabled=false 
  ```
_(**Note:** Remember, the MessageSight admin secret for release `msightrel1s` must be created first.)_

- To install only the MessageSight Web UI with release name `msightrel1w` in namespace `messagesight` where the external IP for the proxy node is `12.3.4.56`, use the following command:
  ```
  helm install --name msightrel1w ibm-messagesight-dev --namespace messagesight \
  --set global.license=accept --set global.virtualIP=12.3.4.56 \
  --set messagesight.enabled=false --set messagesightui.enabled=true 
  ```

## Verifying the Chart
See the NOTES.txt file that is associated with this chart for verification instructions.

## Uninstalling the Chart

You can uninstall the chart by using the following command:
```
helm delete <release_name> --purge
```

For example, use the following command to delete release, `msightrel1`:
```
helm delete msightrel1 --purge
```


## Configuration
The following table lists the configurable parameters of the ibm-messagesight-dev chart and their default values.

###### Global Configuration
---
| Parameter | Description     | Default          |
| --------- | --------------- | ---------------- |
| `global.license` | _**Required**_ Set to `accept` to accept the terms of the IBM license | `not accepted` |
| `global.virtualIP` | _**Required**_ The proxy node external IP address for accessing MessageSight | |


###### MessageSight Server Configuration
---
| Parameter | Description     | Default          |
| --------- | --------------- | ---------------- |
| `messagesight.enabled` | _**Required**_ Set `true` to install MessageSight server (`true` or `false`) | |
| `messagesight.serviceAccount` | The service account that installs the server.  If not set, the chart uses either messagesight-sa or messagesight-priv-sa depending on whether privileged install is specified. See the **Steps for each namespace where MessageSight is installed** section for information about creating these default service accounts. | |
| `messagesight.image.repository` | MessageSight server image repository | `ibmcom/imaserver` |
| `messagesight.image.tag` | MessageSight server image tag | `2.0.0.2.20180618-2257` |
| `messagesight.image,pullPolicy` | MessageSight server image pull policy | `IfNotPresent` |
| `messagesight.adminPort` | The server admin port for the MessageSight REST API | `9089` |
| `messagesight.messagingPorts` | The server messaging endpoint ports | "1883,16102" |
| `messagesight.resources.memory.requests` | Server memory resource requests | `4Gi` |
| `messagesight.resources.cpu.requests` | Server CPU resource requests | `4` |
| `messagesight.resources.memory.limits` | Server memory resource limits | `8Gi` |
| `messagesight.resources.cpu.limits` | Server CPU resource limits | `8` |
| `messagesight.privilegedInstall` | Set to `true` to do a privileged install of the server\* | `false` |
| `messagesight.persistence.enabled` | Use a PVC to persist server data | `false` |
| `messagesight.persistence.useDynamicProvisioning` | Whether to use dynamic provisioning to create a PV (ignored if persistence is disabled) | `false` |
| `messagesight.dataPVC.existingClaimName` | Name of an existing volume claim to use |  |
| `messagesight.dataPVC.storageClass` | Set to limit the server PVC to bind _only_ to a volume with the specified storage class name. |  |
| `messagesight.dataPVC.selector.label` | The label to use when selecting a volume (ignored if dynamic provisioning is enabled) |  |
| `messagesight.dataPVC.selector.value` | The label value to match when selecting a volume (ignored if dynamic provisioning is enabled) |  |
| `messagesight.dataPVC.size` | The size of the server data volume | `32Gi` |

\* If you choose to install in the default namespace (_not recommended_) as the cluster administrator, you must set
privilegedInstall to `true` for the server.

###### MessageSight Web UI Configuration
---
| Parameter | Description     | Default          |
| --------- | --------------- | ---------------- |
| `messagesightui.enabled` | _**Required**_ Set `true` to install MessageSight Web UI | |
| `messagesightui.serviceAccount` | The service account that installs the Web UI.  If not set, the chart uses either messagesight-sa or messagesight-priv-sa depending on whether privileged install is specified. See the **Steps for each namespace where MessageSight is installed** section for information about creating these default service accounts.| |
| `messagesightui.image.repository` | MessageSight Web UI image repository | `ibmcom/imawebui` |
| `messagesightui.image.tag` | MessageSight Web UI image tag | `2.0.0.2.20180618-2257` |
| `messagesightui.image,pullPolicy` | MessageSight Web UI image pull policy | `IfNotPresent` |
| `messagesightui.webuiPort` | The port for the MessageSight Web UI | `9087` |
| `messagesightui.resources.memory.requests` | Web UI memory resource requests | `2Gi` |
| `messagesightui.resources.cpu.requests` | Web UI CPU resource requests | `2` |
| `messagesightui.resources.memory.limits` | Web UI memory resource limits | `4Gi` |
| `messagesightui.resources.cpu.limits` | Web UI CPU resource limits | `4` |
| `messagesightui.privilegedInstall` | Set to `true` to do a privileged install of the Web UI | `false` |
| `messagesightui.persistence.enabled` | Use a PVC to persist Web UI data | `false` |
| `messagesightui.persistence.useDynamicProvisioning` | Whether to use dynamic provisioning to create a PV (ignored if persistence is disabled) | `false` |
| `messagesightui.dataPVC.existingClaimName` | Name of an existing volume claim to use |  |
| `messagesightui.dataPVC.storageClass` | Set to limit the Web UI PVC to bind _only_ to a volume with the specified storage class name. |  |
| `messagesightui.dataPVC.selector.label` | The label to use when selecting a volume (ignored if dynamic provisioning is enabled) |  |
| `messagesightui.dataPVC.selector.value` | The label value to match when selecting a volume (ignored if dynamic provisioning is enabled) |  |
| `messagesightui.dataPVC.size` | The size of the Web UI data volume | `8Gi` |


## Limitations
- The IBM IoT MessageSight chart is supported only on Linux® 64-bit nodes. It is not supported on Linux® on Power® 64-bit LE or IBM® Z nodes.
- IBM IoT MessageSight for ICP does not support HA deployments.
- IBM IoT MessageSight for ICP does not support clustering of MessageSight servers.

## Usage Notes

There are some cases where additional actions are required for correct function of MessageSight in ICP.

### Adding Messaging Endpoints
---

If you add messaging endpoints to your MessageSight server after you have installed MessageSight in ICP, you must complete
an additional step to access the port for the new endpoint.  

- Steps:

  **1. Add the new messaging endpoint in MessageSight.**

     a. Use these instructions if you want to add a new endpoint by using the REST API:
     
     - [Create or update an endpoint by using the REST API](https://www.ibm.com/support/knowledgecenter/SSWMAJ_2.0.0/com.ibm.ism.doc/Reference/MsgHubCmd/cmd_create_update_endpoint.html)
     
     b. Use these instructions if you want to add a new endpoint by using the Web UI:
     
     - [Configuring message hubs by using the Web UI](https://www.ibm.com/support/knowledgecenter/SSWMAJ_2.0.0/com.ibm.ism.doc/Administering/ad00361_.html). 
     - For details about the configuration settings for a messaging endpoint, see [Configuring message hubs](https://www.ibm.com/support/knowledgecenter/SSWMAJ_2.0.0/com.ibm.ism.doc/Administering/ad00360_.html).

  **2. Make the port for the new messaging endpoint available outside the ICP cluster.**

     a. Add a new port to the list of messaging endpoint ports by using the following helm CLI command:
     ```
     helm upgrade <helm_release> ibm-messagesight-dev --namespace <namespace> \
     --set global.license=accept --set global.virtualIP=<proxy_ip> --set messagesight.enabled=true \
     --set messagesightui.enabled=<true/false> --set messagesight.messagingPorts="<port1>\, ... \,<portN>"
     ```
   
     The following example uses the following settings for an _**existing**_ release where _**both**_ the MessageSight 
     server and the Web UI are installed:
     - Release name: `msightrel1`
     - Namespace: `messagesight`
     - Proxy IP: `12.3.4.56`
   
     To add port 8883 to the default list of ports (1883,16102), use the following helm command: 
     ```
     helm upgrade `msightrel1` ibm-messagesight-dev --namespace `messagesight` \
     --set global.license=accept --set global.virtualIP=`messagesight` --set messagesight.enabled=true \
     --set messagesightui.enabled=`true` --set messagesight.messagingPorts="1883\,16102\,8883"
     ```
     
     b. Optionally, you can add a new port to the list of messaging endpoint ports by using the
     ICP UI.
     - Navigate to helm releases.
     - Select the MessageSight release that you want to upgrade.
     - On the release page, click the upgrade button.
     - In the upgrade panel, select the version that is currently installed.
     - _**Ensure that all the configuration values in the upgrade panel match the values that you used at installation time**_.
     If you changed any default values at installation time, you must update the values in the upgrade panel.
     - If you used the default _**Messaging endpoint ports**_ setting at installation time, and you want to add
     port 8883 to that list, complete the following changes:
       - Change: 1883,16102
       - To: 1883,16102,8883

### Changing the admin endpoint username or password

---
If you change the user name and/or the password for the MessageSight admin endpoint, then you must also update 
the <helm_release>-messagesight-admin secret that you created in order to install MessageSight. 

- Steps:

  **1. Change the default admin user name or password in MessageSight.**
  
     a. Use the following instructions to change the admin user name or password by using the MessageSight REST API:
     
     - [Setting the admin superuser ID by using the REST API](https://www.ibm.com/support/knowledgecenter/SSWMAJ_2.0.0/com.ibm.ism.doc/Administering/ad00395_.html)
     - [Setting the admin superuser password by using the REST API](https://www.ibm.com/support/knowledgecenter/SSWMAJ_2.0.0/com.ibm.ism.doc/Administering/ad00396_.html)

  **2. Update the <helm_release>-messagesight-admin secret to match the new admin user name and password settings.**
  
     a. Get a base64 encoding for the new user name and password values by using the following command: 
     ```
     echo -n <new_value> | base64
     ```
     _Note:_Ensure that you use the -n option so that your base64 encoding does not include a newline character. 
     
     The following example changes the user name to `nimda` and the password to `nimda` by using the following command:
     ```
     echo -n nimda | base64
     ```
     
     The result of this command is the string `bmltZGE=`.
             
     b. You can update the <helm_release>-messagesight-admin secret by using kubectl CLI to edit it.
     
     Use the following command to open the secret in the kubectl editor:
     ```
     kubectl edit secrets <helm_release>-messagesight-admin --namespace <namespace>
     ```
     
     The following example opens the secret for release `msightrel1` in namespace `messagesight` by using the following command:
     ```
     kubectl edit secrets msightrel1-messagesight-admin --namespace messagesight
     ```
        
     - When the editor is open, change the appropriate values to match the output from the command in step 2a.
 
     c. Complete the following steps to update the <helm_release>-messagesight-admin secret by using the ICP UI:
     - Navigate to Configuration -> Secrets.
     - Locate the correct <helm_release>-messagesight-admin for your release.
     - Right click at the end of the line to open the editor.
     - Change the appropriate values to match the output from the command in step 2a.
