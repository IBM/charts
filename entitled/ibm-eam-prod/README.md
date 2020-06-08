# IBM&reg; Edge Application Manager

## Introduction

IBM Edge Application Manager provides an end-to-end **Application Management Platform** for applications deployed on edge devices typical in IoT deployments. This platform completely automates, and frees up the application developers from the task of securely deploying the revisions of edge workloads on thousands of field deployed edge devices. The application developer can instead focus on the task of writing the application code in any programming language as an independently deployable docker container. This platform takes the burden of deploying the complete business solution as a multi-level orchestration of docker containers on all the devices securely and seamlessly.

https://www.ibm.com/cloud/edge-application-manager

## Prerequisites

See the following for [Prerequisites](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.1/hub/offline_installation.html#prereq).

## Red Hat OpenShift SecurityContextConstraints Requirements

The default `SecurityContextConstraints` name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart. This release is limited to deployment into the `kube-system` namespace and creates service accounts for the main chart, and additional service accounts for the default local database subcharts.

## Chart Details

This helm chart installs and configures the IBM Edge Application Manager certified containers onto an OpenShift environment. The following components will be installed:

* IBM Edge Application Manager - Exchange
* IBM Edge Application Manager - AgBots
* IBM Edge Application Manager - Cloud Sync Service (part of the Model Management System)
* IBM Edge Application Manager - User Interface (management console)

## Resources Required

See the following for [Sizing](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.1/hub/cluster_sizing.html).

## Storage and Database Requirements

Three database instances are necessary to store the IBM Edge Application Manager component data.

By default the chart will install three persistent databases with the volume sizings below, using a defined default (or user configured) kubernetes dynamic storage class. If using a storage
class that doesn't allow for volume expansion, be sure to allow for expansion appropriately.

**Note:** these default databases are not intended for production use. To utilize your own managed databases, see the requirements below and follow steps in the **Configure Remote Databases** section.

* PostgreSQL: Stores Exchange and AgBot data
  * Need 2 separate instances, each with at least 20GB of storage
  * The instance should support at least 100 connections
  * For production use, these instances should be highly available
* MongoDB: Stores Cloud Sync Service data
  * Need 1 instance with at least 50GB of storage. **Note:** the size required is highly dependent on the size and number of edge service models and files you store and use.
  * For production use, this instance should be highly available

**Note:** You are responsible for the backup cadence/procedures for these default databases, as well as your own managed databases.
See the **Backup and Recovery** section for default database procedures.

## Monitoring resources

When IBM Edge Application Manager is installed, it automatically sets up some basic monitoring of the product resources running in kubernetes. The monitoring data can be viewed in the Grafana dashboard of the management console at the following location:

* `https://<MANAGEMENT_URL:PORT>/grafana/d/kube-system-ibm-edge-overview/ibm-edge-overview`

## Configuration

#### Configure remote databases

1. To use your own managed databases, search for the following helm configuration parameter in `values.yaml` and change its value to `false`:

```yaml
localDBs:
  enabled: true
```

2. Create a file (named, for example, `dbinfo.yaml`) starting with this template content:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ibm-edge-remote-dbs
  labels:
    release: ibm-edge
type: Opaque
stringData:
  # agbot postgresql connection settings
  agbot-db-host: "Single hostname of the remote database"
  agbot-db-port: "Single port the database runs on"
  agbot-db-name: "The name of the database to utilize on the postgresql instance"
  agbot-db-user: "Username used to connect"
  agbot-db-pass: "Password used to connect"
  agbot-db-ssl: "SSL Options: <disable|require|verify-full>"

  # exchange postgresql connection settings
  exchange-db-host: "Single hostname of the remote database"
  exchange-db-port: "Single port the database runs on"
  exchange-db-name: "The name of the database to utilize on the postgresql instance"
  exchange-db-user: "Username used to connect"
  exchange-db-pass: "Password used to connect"
  exchange-db-ssl: "SSL Options: <disable|require|verify-full>"

  # css mongodb connection settings
  css-db-host: "Comma separate <hostname>:<port>,<hostname2>:<port2>"
  css-db-name: "The name of the database to utilize on the mongodb instance"
  css-db-user: "Username used to connect"
  css-db-pass: "Password used to connect"
  css-db-auth: "The name of the database used to store user credentials"
  css-db-ssl: "SSL Options: <true|false>"

  trusted-certs: |-
    -----BEGIN CERTIFICATE-----
    ....
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    ....
    -----END CERTIFICATE-----
```

3. Edit `dbinfo.yaml` to supply the access information for the databases you provisioned. Fill out all the information in between the double quotes (keeping the values quoted). When adding the trusted certs, be sure each line is indented 4 spaces to ensure proper reading of the yaml file. If 2 or more of the databases use the same cert, the cert does **not** need to be repeated in `dbinfo.yaml`. Save the file and then run:

```bash
oc --namespace kube-system apply -f dbinfo.yaml
```


#### Advanced Configuration

To change any of the default helm configuration parameters, review the parameters and their descriptions using the `grep` command below, and then view/edit the corresponding values in `values.yaml`:

```bash
grep -v -E '(^ *#|__metadata)' ibm_cloud_pak/values-metadata.yaml
vi values.yaml   # or use any editor
```

## Installing the Chart

**Notes:**

* This is a CLI only installation, installation from the GUI is not supported

* Ensure the steps in [Installing IBM Edge Application Manager infrastructure - Installation process](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.1/hub/offline_installation.html#process) have been completed.
* There can only be one instance of IBM Edge Application Manager installed per cluster, and it can only be installed to the `kube-system` namespace.
* Upgrade from IBM Edge Application Manager 4.0 is not supported

Run the installation script provided to install IBM Edge Application Manager. The major steps performed by the script are: install the helm chart, and configure the environment after installation (create agbot, org, and pattern/policy servicing).

```bash
ibm_cloud_pak/pak_extensions/support/ieam-install.sh
```

**Note:** Depending on network speeds it will take a few minutes for the images to download, and for all of the chart resources to be deployed.

### Verifying the Chart

* The script above verifies that the pods are running and the agbot and exchange are responding. Look for a "RUNNING" and "PASSED" message towards the end of the installation.
* If "FAILED", the output will ask you to look at specific logs for more information
* If "PASSED", the output will show details of tests that were run, and the URL for the management UI
  * Browse to the IBM Edge Application Manager UI console at the URL given at the end of the log.
    * `https://<MANAGEMENT_URL:PORT>/edge`

## Post installation

Follow the steps in [Post installation configuration](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.1/hub/post_install.html).

## Uninstalling the Chart

Follow the steps to [Uninstall the management hub](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.1/hub/uninstall.html).

## Role-Based Access

* Cluster administrator authority in the `kube-system` namespace is required to install and manage this product.
* Service accounts, roles, and rolebindings are created for this chart and subcharts based on the release name.
* Exchange authentication and roles:
  * Authentication of all exchange administrators and users is provided by IAM through API keys generated with the `cloudctl` command
  * Exchange administrators should be given the `admin` privilege within the exchange. With that privilege they can manage all users, nodes, services, patterns, and policies within their exchange organization
  * Exchange non-administrator users can only manage users, nodes, services, patterns, and policies that they have created

## Security

* TLS is used for all data entering/leaving the OpenShift cluster through ingress. In this release TLS is not used **within** the OpenShift cluster for node to node communication. If desired, configure Red Hat OpenShift service mesh for communication between microservices. See [Understanding Red Hat OpenShift Service Mesh](https://docs.openshift.com/container-platform/4.4/service_mesh/service_mesh_arch/understanding-ossm.html#understanding-ossm).
* No encryption of the data at rest is provided by this chart.  It is up to the administrator to configure storage at rest encryption.

## Backup and Recovery

Follow the steps in [Backup and recovery](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.1/admin/backup_recovery.html).

## Limitations

* Installation limits: this product can be installed only once, and only into the `kube-system` namespace

## Documentation

* Please see the [Installation](https://www.ibm.com/support/knowledgecenter/SSFKVV_4.1/hub/hub.html) Knowledge Center documentation for additional information.

## Copyright

© Copyright IBM Corporation 2020. All Rights Reserved.
