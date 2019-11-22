# IBM® IoT MessageSight™
_THIS CHART IS NOW DEPRECATED. On November 30th, 2019 the helm chart for IBM IoT Messagesight will no longer be supported and will be removed from Passport Advantage._

IBM IoT MessageSight is a messaging application that is designed to process large volumes of events in near real-time and to handle
many concurrently connected devices, such as sensors or mobile devices.

IBM IoT MessageSight (MessageSight) provides secure, rapid, bidirectional messaging for the Internet of Things (IoT) 
and mobile environments. MessageSight delivers the performance, value, and simplicity you need to accommodate the 
growing number of mobile devices and sensors. MessageSight helps you to open new mobile use cases with low 
latency, bidirectional control. You can push secure information to mobile apps and enable a more interactive, immersive
experience.

For more information about IBM IoT MessageSight, see the [IBM IoT MessageSight product documentation](https://www.ibm.com/support/knowledgecenter/en/SSWMAJ_2.0.0/WelcomePage/ic-homepage.html).
_**For important ICP usages notes, see [IBM IoT MessageSight in the IBM Cloud Private Environment](https://www.ibm.com/support/knowledgecenter/en/SSWMAJ_2.0.0/com.ibm.ism.doc/Overview/ov60001_.html).**_

## Introduction

This chart deploys the following two applications:
- The MessageSight messaging server.
- The MessageSight Web UI which provides a convenient graphical interface for managing one or more MessageSight servers, and
visualization utilities for monitoring the server.

## Chart Details
- The chart consists of IBM IoT MessageSight V2.0.
- The chart is only for IBM IoT MessageSight stand-alone server (non-HA) deployments.
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


## PodSecurityPolicy Requirements
---

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator set up a custom PodSecurityPolicy for you:

- Predefined PodSecurityPolicy name: ibm-anyuid-hostaccess-psp

- Custom PodSecurityPolicy definition
```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: messagesight-psp
spec:
  allowPrivilegeEscalation: false
  fsGroup:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  hostPorts:
  - max: 65535
    min: 1
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
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
  - nfs
  - vsphereVolume
  ```

- Custom ClusterRole
```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: messagesight-cr
rules:
- apiGroups:
  - extensions
  resources:
  - podsecuritypolicies
  resourceNames:
  - messagesight-psp
  verbs:
  - use
```

- Custom ServiceAccount Definition
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: messagesight-sa
```

- Custom RoleBinding Definition
```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: messagesight-rb
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: messagesight-cr
subjects:
- kind: ServiceAccount
  name: messagesight-sa
```

If you use the custom security configuration  provided here, you must specify messagesight-sa as the service account
for your charts.

### For Clusters with LDAP configured
---

If LDAP is configured in your cluster, there are a few additional steps to perform to allow authenticated users to
install MessageSight.  The steps in this section must be performed by a cluster administrator and describe the general
process for creating a team and assigning users and resources to the team.  For more details about creating and configuring
teams, see [Managing access to your platform](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.1/user_management/teams.html).

**1.** Use the ICP UI or REST API to create a team for MessageSight.  For example, create a team called messagesight-team.

**2.** Use the ICP UI or REST API to add one or more individual users or groups to the team created in step 1.

**3.** Create one or more namespaces where MessageSight will be installed.

> _**NOTE:** If you plan to rely on the ibm-anyuid-hostaccess-psp PSP for your Messagesight installs, you must associate this PSP with the namespaces you create._

**4.** Use the ICP UI or REST API to add the namespace(s) created in step 3 to the team created in step 1.

###  For namespaces without the ibm-anyuid-hostaccess-psp pod security policy
---

To install MessageSight into namespaces with default PSPs that are more restrictive than 
ibm-anyuid-hostaccess-psp, follow the steps outlined here.  Use these steps to deploy the custom configuration 
content that appears in the **PodSecurityPolicy Requirements** section.

**1. One-time configuration steps**

You must create the pod security policies (PSPs) and roles that are used to grant service accounts access to install MessageSight.  These configuration actions require cluster administrator access.

Use the following files from the downloaded archive:

Configuration file:
  - pak_extensions/samples/custom_psp/messagesight-cr-psp.yaml 

Script:
  - pak_extensions/samples/createMessageSightPSPAndRole.sh
  
Run the createMessageSightPSPAndRole.sh script to create the PSP that is used to grant install access 
to the service account that is created in the next section.


**2. Steps for each namespace where MessageSight is installed**

If LDAP is configured for your cluster, see the **For Clusters with LDAP configured** section for information 
about namespace resources for teams.

Use the following files from the downloaded archive:
- Configuration file:
  - pak_extensions/samples/custom_psp/messagesight-sa-rb.yaml 

- Scripts:
  - pak_extensions/samples/custom_psp/createMessageSightSvcAcctAndRoleBinding.sh
  - pak_extensions/samples/custom_psp/addPullSecretToSvcAcct.sh

Run the createMessageSightSvcAcctAndRoleBinding.sh script to create the namespace and service account, messagesight-sa.
Specify this service account when you install MessageSight. The script takes one required argument
and one optional argument. The first (required) argument is the namespace name.  The second (optional) argument is the name 
of an image pull secret that the service account can use to retrieve the MessageSight Docker images.
> _**Note:** These instructions assume that you have completed the tasks that are required to retrieve and store the Docker images in a repository that your cluster can access._

You can optionally add an image pull secret to your custom service account later.  Run the
addPullSecretToSvcAcct.sh script to add an image pull secret to your service accounts.  This script 
takes two arguments; the namespace where the service account was created and the name of the of an image pull secret for your Docker repository.  

> _**Note:** If you specify an image pull secret for your service account, you must ensure that the secret exists in the namespace where you create or update the service account._

---
## Prerequisites
- At least one proxy node with an external IP address is required to install this chart. This must be an IP address that is
reachable by the IoT devices that send messages to and receive messages from the MessageSight server.
- _**Recommended**_ Create non-default namespaces for your MessageSight chart installations.
- If the default PSP for your namespace is more restrictive than ibm-anyuid-hostaccess-psp, a pod security policy, role, service account, 
and role binding must be created. See the **For namespaces without the ibm-anyuid-hostaccess-psp pod security policy** section for details.

## Resources Required
__MessageSight Server__

Only one instance of the MessageSight server can be installed on a node.  If you plan to install more
than one MessageSight server in your cluster, you must ensure there is a node available for each 
server instance.

By default, the MessageSight Server subchart uses the following resources:
- Minimum: 4 CPU core and 16Gi memory
- Recommended: 8 CPU core and 32Gi memory

> _**Note: Storage for the MessageSight server, it must be at least four times the amount
of memory configured.**  Therefore, a minimum of 64Gi storage is required and 128Gi storage is recommended. See [Capacity planning](https://www.ibm.com/support/knowledgecenter/en/SSWMAJ_2.0.0/com.ibm.ism.doc/Planning/pl00002_.html) in the IBM IoT MessageSight product documentation for additional for 
more information._  

__MessageSight Web UI__

By default, the MessageSight Web UI subchart uses:
- Minimum: 2 CPU core and 4Gi memory
- Recommended: 4 CPU core and 8Gi memory

## Installing the Chart

Complete the following steps to install MessageSight:

**1.** (_**Required for the MessageSight server subchart**_) Create the MessageSight admin secret.

The admin endpoint in the MessageSight server requires a secret that stores the superuser ID and password. Follow these steps to deploy the default secret.

Use the following files from the downloaded archive:
- Configuration file:
  - pak_extensions/prereqs/messagesight-secret.yaml
  
- Script:
  - pak_extensions/prereqs/createMessageSightSecretForRelease.sh
  
Run the createMessageSightSecretForRelease.sh script to create the secret for the release that you want to install.
This script takes two arguments; the release name that you want to use to install MessageSight, and the namespace where you want to install this release.

**2.** Find the external IP address for a  proxy node in your cluster.

An external IP address for a proxy node is required.

You can use this command to get an external IP address for the proxy node in your cluster. 
```
kubectl get configmap ibmcloud-cluster-info -n kube-public -o jsonpath={.data.proxy_address}
```

**3.** Install the chart.

> _**Note:** Because server security is not configured after the server is installed, **you should specify Non-Production licensed usage at install time**.  Once server security is configured, you can use helm upgrade to
change the licensed usage to Production._

- To install both the MessageSight server and Web UI with release name `msightrel1` and licensed usage `Non-Production` in namespace `messagesight` where the external IP for the proxy node is `12.3.4.56` use the following command:
  ```
  helm install --name msightrel1 ibm-messagesight-prod --namespace messagesight \
  --set global.license=accept --set global.virtualIP={12.3.4.56} \
  --set global.messagesightEnabled=true --set global.messagesightuiEnabled=true \
  --set messagesight.licensedUsage=Non-Production --tls
  ```

- To install only the MessageSight server with release name `msightrel1s` and licensed usage `Non-Production` in namespace `messagesight` where the external IP for the proxy node is `12.3.4.56`, use the following command: 
  ```
  helm install --name msightrel1s ibm-messagesight-prod --namespace messagesight \
  --set global.license=accept --set global.virtualIP={12.3.4.56} \
  --set global.messagesightEnabled=true --set messagesight.licensedUsage=Non-Production --tls
  ```

> _**Note:** Remember, the MessageSight admin secret for release `msightrel1s` must be created first._

- To install only the MessageSight Web UI with release name `msightrel1w` in namespace `messagesight` where the external IP for the proxy node is `12.3.4.56`, use the following command:
  ```
  helm install --name msightrel1w ibm-messagesight-prod --namespace messagesight \
  --set global.license=accept --set global.virtualIP={12.3.4.56} \
  --set global.messagesightuiEnabled=true --tls
  ```

## Verifying the Chart
See the NOTES.txt file that is associated with this chart for verification instructions.

## Uninstalling the Chart

You can uninstall the chart by using the following command:
```
helm delete <release_name> --purge --tls
```

For example, use the following command to delete release, `msightrel1`:
```
helm delete msightrel1 --purge --tls
```


## Configuration
The following table lists the configurable parameters of the ibm-messagesight-prod chart and their default values.

###### Global Configuration
---
| Parameter | Description     | Default          |
| --------- | --------------- | ---------------- |
| `global.license` | _**Required**_ Set to `accept` to accept the terms of the IBM license | `not accepted` |
| `global.virtualIP` | _**Required**_ The proxy node external IP address for accessing MessageSight | |
| `global.messagesightEnabled` | Set `true` to install MessageSight server (`true` or `false`) | `false` |
| `global.messagesightuiEnabled` | Set `true` to install MessageSight Web UI (`true` or `false`) | `false` |

###### MessageSight Server Configuration
---
| Parameter | Description     | Default          |
| --------- | --------------- | ---------------- |
| `messagesight.licensedUsage` | The licensed usage setting for the server. | `Non-Production` |
| `messagesight.serviceAccount` | The service account that installs the server. | `default` |
| `messagesight.image.repository` | MessageSight server image repository | `MessageSight server image in your registry` |
| `messagesight.image.tag` | MessageSight server image tag | `2.0.0.2.20181003-1858` |
| `messagesight.image,pullPolicy` | MessageSight server image pull policy | `IfNotPresent` |
| `messagesight.adminPort` | The server admin port for the MessageSight REST API | `9089` |
| `messagesight.messagingPorts` | The server messaging endpoint ports | "1883,16102" |
| `messagesight.resources.memory.requests` | Server memory resource requests | `16Gi` |
| `messagesight.resources.cpu.requests` | Server CPU resource requests | `4` |
| `messagesight.resources.memory.limits` | Server memory resource limits | `32Gi` |
| `messagesight.resources.cpu.limits` | Server CPU resource limits | `8` |
| `messagesight.persistence.enabled` | Use a PVC to persist server data | `true` |
| `messagesight.persistence.useDynamicProvisioning` | Whether to use dynamic provisioning to create a PV (ignored if persistence is disabled) | `true` |
| `messagesight.persistence.fsGroup` | The owner group ID for a mounted NFS persistent volume | |
| `messagesight.dataPVC.existingClaimName` | Name of an existing volume claim to use |  |
| `messagesight.dataPVC.storageClass` | Set to limit the server PVC to bind _only_ to a volume with the specified storage class name. |  |
| `messagesight.dataPVC.selector.label` | The label to use when selecting a volume (ignored if dynamic provisioning is enabled) |  |
| `messagesight.dataPVC.selector.value` | The label value to match when selecting a volume (ignored if dynamic provisioning is enabled) |  |
| `messagesight.dataPVC.size` | The size of the server data volume | `64Gi` |
| `messagesight.nodeAffinity.required` | Whether the specified node label is _**required**_ for the server install. (If false, the specified label is preferred but not required.)* | `false` |
| `messagesight.nodeAffinity.key` | The node label key used for node affinity. (If no value is specified, `messagesight` is the default.) | `messagesight` |
| `messagesight.nodeAffinity.value` | The node label value used for node affinity. (If no value is specified, `server` is the default.) | `server` |
| `messagesight.tolerations` | Array of JSON objects representing node taints that are permitted for server installs.  | `{- {key:dedicated,value:messagesight,operator:Equal,effect:NoSchedule}}`** |

\* If you want to _**require**_ the default node label, you must apply the label. You can use the applyMessageSightNodeLabels.sh script under pak_extensions/prereqs/optional_scheduling 
from the downloaded archive to apply default labels for both the server and the Web UI.

\*\* By default, the server contains a single element in the array of tolerations.  If you prefer to use different tolerations, 
you can specify them in array form in messagesight.tolerations.  In order to use the default, you must apply the taint to the
appropriate node or nodes in your cluster.  You can use the applyMessageSightServerTaint.sh script under pak_extensions/prereqs/optional_scheduling 
from the downloaded archive to apply this taint.


###### MessageSight Web UI Configuration
---
| Parameter | Description     | Default          |
| --------- | --------------- | ---------------- |
| `messagesightui.serviceAccount` | The service account that installs the Web UI. | `default` |
| `messagesightui.image.repository` | MessageSight Web UI image repository | `MessageSight Web UI image in your registry` |
| `messagesightui.image.tag` | MessageSight Web UI image tag | `2.0.0.2.20181003-1858` |
| `messagesightui.image,pullPolicy` | MessageSight Web UI image pull policy | `IfNotPresent` |
| `messagesightui.webuiPort` | The port for the MessageSight Web UI | `9087` |
| `messagesightui.resources.memory.requests` | Web UI memory resource requests | `4Gi` |
| `messagesightui.resources.cpu.requests` | Web UI CPU resource requests | `2` |
| `messagesightui.resources.memory.limits` | Web UI memory resource limits | `8Gi` |
| `messagesightui.resources.cpu.limits` | Web UI CPU resource limits | `4` |
| `messagesightui.persistence.enabled` | Use a PVC to persist Web UI data | `true` |
| `messagesightui.persistence.useDynamicProvisioning` | Whether to use dynamic provisioning to create a PV (ignored if persistence is disabled) | `true` |
| `messagesightui.persistence.fsGroup` | The owner group ID for a mounted NFS persistent volume | |
| `messagesightui.dataPVC.existingClaimName` | Name of an existing volume claim to use |  |
| `messagesightui.dataPVC.storageClass` | Set to limit the Web UI PVC to bind _only_ to a volume with the specified storage class name. |  |
| `messagesightui.dataPVC.selector.label` | The label to use when selecting a volume (ignored if dynamic provisioning is enabled) |  |
| `messagesightui.dataPVC.selector.value` | The label value to match when selecting a volume (ignored if dynamic provisioning is enabled) |  |
| `messagesightui.dataPVC.size` | The size of the Web UI data volume | `16Gi` |
| `messagesightui.nodeAffinity.required` | Whether the specified node label is _**required**_ for the Web UI install. (If false, the specified label is preferred but not required.)* | `false` |
| `messagesightui.nodeAffinity.key` | The node label key used for node affinity. (If no value is specified, `messagesight` is the default.) | `messagesight` |
| `messagesightui.nodeAffinity.value` | The node label value used for node affinity. (If no value is specified, `webui` is the default.) | `webui` |
| `messagesightui.tolerations` | Array of JSON objects representing node taints that are permitted for Web UI installs.  | |

\* If you want to _**require**_ the default node label, you must apply the label. You can use the applyMessageSightNodeLabels.sh script under pak_extensions/prereqs/optional_scheduling 
from the downloaded archive to apply default labels for both the server and the Web UI.


## Limitations
- The IBM IoT MessageSight chart is supported only on Linux® 64-bit nodes. It is not supported on Linux® on Power® 64-bit LE or IBM® Z nodes.
- IBM IoT MessageSight for ICP does not support HA deployments.
- IBM IoT MessageSight for ICP does not support clustering of MessageSight servers.
