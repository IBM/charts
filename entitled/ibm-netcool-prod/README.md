IBM Netcool Operations Insight enables you to monitor the health and performance of IT and network infrastructure across local, cloud and hybrid environments.

# IBM Netcool Operations Insight

## Introduction

IBM Netcool Operations Insight enables you to monitor the health and performance of IT and network infrastructure across local, cloud and hybrid environments. It also incorporates strong event management capabilities, and leverages real-time alarm and alert analytics, combined with broader historic data analytics, to deliver actionable insight into the performance of services and their associated dynamic network and IT infrastructures.

## Contents

- [Details](#details)
- [Prerequisites](#prerequisites)
- [Resources Required](#resources-required)
- [Installing the operator from olm](#to-install-the-operator-via-olm)
- [Storage](#storage)
- [Configuration](#configuration)
- [Limitations](#limitations)
- [Documentation](#documentation)

# Details

The ibm-netcool-prod operator and its dependent sub operators provide the capability to deploy the following Operations Management applications and capabilities from the IBM Netcool Operations Insight solution:

- Netcool/OMNIbus Core
- Netcool/OMNIbus WebGUI
- Netcool/Impact
- DB2 Enterprise Server Edition database
- Message Bus gateway to support interaction between the components
- Cloud Native Event Analytics
- Event management
- Topology management

The operator also deploys one of the following components required to enable Operations Management.

- openLDAP server - for use when no external LDAP connection is required.
- openLDAP proxy - to connect to an existing LDAP server outside of the deployment.

For more information on how these applications work together to provide Netcool Operations Insight functionality, see
[Netcool Operations Insight documentation: Deployment modes](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/operations/task/ops_operations.html).

For more information on event management, see [Configuring integrations](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/operations/task/ops_resolving-alerts.html)

For more information on topology management, see [Working with topology](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/asm/doc/Using/c_asm_using.html)

## Prerequisites

- [Basic prerequisites](#basic-prerequisites)
- [Store passwords in secrets](#store-passwords-in-secrets)
- [Red Hat OpenShift SecurityContextConstraints Requirements](#red-hat-openshift-securitycontextconstraints-requirements)

### Basic prerequisites

The following prerequisites are required for a successful installation.

- A Red Hat OpenShift Kubernetes cluster v4.5 or later. For more information on the cluster, see [OpenShift Container Platform 4.5 Documentation](https://docs.openshift.com/container-platform/4.5/welcome/index.html)
- OpenShift CLI (oc), see [Getting started with the CLI](https://docs.openshift.com/container-platform/4.5/cli_reference/openshift_cli/getting-started-cli.html).
- PersistentVolume support on the cluster.

For more information on prerequisites, see  [Netcool Operations Insight Documentation: Preparing for installation](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/task/soc_int_preparing-rhocp-installation.html).

### Store passwords in secrets.
  Following our security requirements, we do not install with default passwords. There are two options for password generation.
 - The install will generate random passwords and store these passwords in secrets, which you can extract after the install.  
 - You can create the passwords in secrets prior to install, where you choose the password [following these guidelines](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/task/int-creating_passwords_and_secrets-rhocp.html).

### Red Hat OpenShift Security Context Constraints Requirements

The operator requires a Security Context Constraints (SCC) to be bound to the target service account prior to installation. All pods will use this SCC. An SCC constrains the actions a pod can perform. Actions such as Host IPC access. Host IPC access is required by our Db2 pod.  The SCC will be created
automatically but can be created manually if cluster permissions require it. See [Preparing your cluster](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/task/soc_int_preparing-rhocp-cluster.html) for more information.

## Ingress Controller Configuration

Your Openshift environment may need to be updated to allow network policies to function correctly. To determine if your OpenShift environment is affected, view the default ingresscontroller and locate the property `endpointPublishingStrategy.type`. If it is set to `HostNetwork`, the network policy will not work against routes unless the default namespace contains the selector label.

```
  endpointPublishingStrategy:
    type: HostNetwork
```
To set the selector label within the default namespace, run the following command:

```
kubectl patch namespace default --type=json -p '[{"op":"add","path":"/metadata/labels","value":{"network.openshift.io/policy-group":"ingress"}}]'
```

## Resources Required

- For information about sizing, see [Hardware sizing for a full deployment on Red Hat OpenShift](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/reference/soc_sizing_full.html)

- For information about supported storage, see [Storage](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/concept/soc_int_storage_rhocp.html)

# Installing

## Prerequisites

- A PodDisruptionBudget will be automatically enabled for applicable components of the chart.
- For more information on prerequisites, see [Preparing your cluster](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/task/soc_int_preparing-rhocp-cluster.html)

## Installing the operator with the Operator Lifecycle Management console

For more information on installing, see [Installing Netcool Operations Insight](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/task/soc_int_preparing-rhocp-cluster.html)

### Create a Catalog source
  - Within the OpenShift Console (4.5 or higher), select the menu navigation Administration -> Cluster Settings
  - Under the Global Settings tab, select OperatorHub configuration resource
  - Under the Sources tab, click the Create Catalog Source button
  - Provide a catalog source name and the image URL: docker.io/ibmcom
  - If a specific version is required, change the latest tag to the version. Select the Create button.
  - The catalog source appears, after a few minutes refresh the screen to see the number of operators count become 1.

### Create Operator
  - Select the menu navigation OperatorHub and search for the NOI operator. Select the operator card, then the Install button.
  - Select a custom namespace to install the operator. Do not use namespaces that are kubernetes or openshift owned like kube-system or default. If you don't already have a project, create a project under the navigation menu Home -> Projects.
  - Select the Subscribe button.
  - Under the navigation menu Operators -> Installed Operators, view the NOI operator. It may take a few minutes to install. View the status at the bottom of the installed NOI operator page which should reflect Succeeded.
  - Determine if installing Cloud (Full NOI) or Hybrid.  Select Create Instance link under the correct custom resource.
  - Use the Yaml or Form view and provide the required values to install NOI. See [Operator Properties](#operator-properties)  Select the Create button.
  - Under the All Instances tab, a NOI formation and NOI (Cloud/Hybrid) instance should appear. View the status of each of those for updates on the installation. When the instances state shows OK then NOI is fully installed and ready.


## Uninstalling the Operator with the Operator Lifecycle Management console

### Remove NOI deployments

  **Warning** Removing a NOI deployment is a destructive action that can result in loss of persisted data.  Consult the documentation and ensure you have backed up persisted data prior to deleting a deployment.  For more information on backup and restore see [Backup and restore](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/task/backup_restore_hybrid.html)

  - Select the menu navigation Operators -> Installed Operators then select Netcool Operations Insight
  - Select All Instances tab and review and delete each deployment using the vertical ellipsis menu and Delete NOI menu item

### Uninstall NOI operator

  - Select the menu navigation Operators -> Installed Operators then select Netcool Operations Insight
  - Select the Netcool Operations Insight operator vertical ellipsis menu -> Uninstall Operator

### Remove the NOI operator catalog

  - Within the OpenShift Console (4.5 or higher), select the menu navigation Administration -> Cluster Settings
  - Under the Global Settings tab, select OperatorHub configuration resource
  - Under the Sources tab, select the vertical ellipsis menu for the ibm-noi-catalog -> Delete CatalogSource

## Uninstalling the operator using the CLI

  ```
  oc delete deployment noi-operator
  oc delete role noi-operator
  oc delete rolebinding noi-operator
  oc delete clusterrole noi-operator
  oc delete clusterrolebinding noi-operator
  oc delete serviceaccount noi-operator
  oc delete crd noiformations.noi.ibm.com
  oc delete crd noiconnectionlayers.noi.ibm.com
  oc delete crd noihybrids.noi.ibm.com
  oc delete crd nois.noi.ibm.com
  ```
Search for the Custom Resource Definitions (CRD) created by the Netcool Operations Insight installation and delete them by running the commands:
```
oc get crd | egrep "noi|cem|asm"
oc delete crd <crd-name>
```
For more information, see [Preparing your cluster](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/task/int_uninstalling-noi-on-rhocp.html)

## Operator Properties

For more information on the properties used to configure a Netcool Operations Insight deployment, see [Operator properties](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/reference/int_installing-opsmg-rhocp-params.html)

## Storage

You must create storage prior to your installation of Netcool Operations Insight on OpenShift.

For more information on storage requirements and the steps required to set up your storage, see [Netcool Operations Insight Documentation: Storage](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/integration/concept/soc_int_storage_rhocp.html).

## Limitations

* Platform limited, only supports `amd64` worker nodes.
* StatefulSet are not currently scalable.
* IBM Netcool Operations Insight has been tested on version 4.5 and 4.6 of OpenShift.

## Documentation

Full documentation on deploying the ibm-netcool-prod chart can be found in the [Netcool Operations Insight documentation](https://www.ibm.com/support/knowledgecenter/SSTPTP_1.6.3/com.ibm.netcool_ops.doc/soc/collaterals/soc_netops_kc_welcome.html).


## Configuration

## SecurityContextConstraints Requirements
