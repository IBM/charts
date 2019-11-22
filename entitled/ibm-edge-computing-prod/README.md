# IBM Edge Computing

## Introduction

IBM Edge Computing for Devices provides an end-to-end **Application Management Platform** for applications deployed on Edge devices typical in IoT deployments. This platform completely automates, and frees up the application developers from the task of securely deploying the revisions of edge workloads on thousands of field deployed edge devices. The application developer can instead focus on the task of writing the application code in any programming language as an independently deployable docker container. This platform takes the burden of deploying the complete business solution as a multi-level orchestration of docker containers on all the devices securely and seamlessly.

## Prerequisites

* IBM Cloud Private v3.2.0 or higher
* Two instances of PostgreSQL database and an instance of MongoDB to store data for the IBM Edge Computing for Devices components. See the **Storage** section below for details.
* An Ubuntu Linux or macOS host to drive the installation from. This host must be able to `ssh` to the ICP kubernetes master node as root. It must have the following software installed:
  * [IBM Cloud Private CLI (cloudctl)](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.1/manage_cluster/install_cli.html)
  * [Kubernetes CLI (kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl/) version 1.13.1 or newer
  * [Helm CLI](https://helm.sh/docs/using_helm/#installing-the-helm-client) version 2.9.1 or newer
  * Other software packages:
    * jq
    * git
    * docker (version 18.06.01 or later)
    * make

## PodSecurityPolicy Requirements

The predefined PodSecurityPolicy name: [`ibm-privileged-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, this release is restricted to deployment into the `kube-system` namespace, which is bound by that PodSecurityPolicy.

## Chart Details

This helm chart installs and configures the IBM Edge Computing for Devices certified containers in your IBM Cloud Private (ICP) environment. The following components will be installed:

* IBM Edge Computing for Devices - Exchange
* IBM Edge Computing for Devices - AgBots
* IBM Edge Computing for Devices - Cloud Sync Service (part of the Model Management System)
* IBM Edge Computing for Devices - User Interface (management console)

## Resources Required

For information about resources required, see [Installation - Sizing](https://www.ibm.com/support/knowledgecenter/SSFKVV_3.2.1/devices/installing/install.html#size).

## Storage

You must provision 3 database instances to store the IBM Edge Computing for Devices component data:

* PostgreSQL: Stores Exchange and AgBot data
  * Need 2 separate instances, each with at least 10GB of storage
  * For production use, these instances should be highly available and:
    * The instance storing exchange data should support at least 100 connections
    * The instance storing agbot data should support at least 20 connections
* MongoDB: Stores Cloud Sync Service data
  * Need 1 instance with at least 50GB of storage. **Note:** the size required is highly dependent on the size and number of edge service models and files you store and use.
  * For production use, this instance should be highly available

**Note:** you are responsible for the backup/restore procedures for your databases.

## Monitoring resources

When IBM Edge Computing for Devices is installed, it automatically sets up monitoring of the product and the pods it runs on. The monitoring data can be viewed in the Grafana dashboard of the ICP management console at the following locations:

* `https://<ICP_HOST>:<ICP_PORT>/grafana/d/kube-system-edge-computing-overview/edge-computing-overview`
* `https://<ICP_HOST>:<ICP_PORT>/grafana/d/kube-system-edge-computing-pod-overview/edge-computing-pod-overview`

## Configuration

1. Create a file (named, for example, `dbinfo.yaml`) starting with this template content:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: edge-computing-remote-dbs
  labels:
    release: edge-computing
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

2. Edit `dbinfo.yaml` to supply the access information for the databases you provisioned. Fill out all the information in between the the double quotes (keeping the values quoted). When adding the trusted certs, be sure each line is indented 4 spaces to ensure proper reading of the yaml file. If 2 or more of the databases use the same cert, the cert does **not** need to be repeated in `dbinfo.yaml`. Save the file and then run:

```bash
kubectl --namespace kube-system apply -f dbinfo.yaml
```

3. If you are installing on ICP 3.2.0, it will be easier to find the Edge Computing management console if you search for the following helm configuration parameter in `values.yaml` and change its value to `true`:

```yaml
  uiMenu:
    enabled: false
```

4. If you are installing on ICP 3.2.1, typically you do not need to change any of the default helm configuration parameters. But if desired, you can review the parameters with their descriptions using the `grep` command below, and then view/edit the corresponding values in `values.yaml`:

```bash
grep -v -E '(^ *#|__metadata)' ibm_cloud_pak/values-metadata.yaml
vi values.yaml   # or use your preferred editor
```

## Installing the Chart

**Notes:**

* This is a CLI only installation, installation from the GUI is not supported

* You should have already completed the steps in [Installing IBM Edge Computing for Devices infrastructure - Installation process](https://www.ibm.com/support/knowledgecenter/SSFKVV_3.2.1/devices/installing/install.html#process)
* There can only be one instance of IBM Edge Computing for Devices installed per cluster, and it can only be installed to the `kube-system` namespace.
* Upgrade from IBM Edge Computing for Devices 3.2.0.1 is not supported

Run the installation script provided to install IBM Edge Computing for Devices. The major steps performed by the script are: install the helm chart, and configure the environment after installation (create agbot, org, and pattern/policy servicing).

```bash
ibm_cloud_pak/pak_extensions/full-install/install-edge-computing.sh
```

**Note:** it will take a few minutes for the images to download, for pods to transition into RUNNING state, and all of the services to become active.

### Verifying the Chart

* The script above verifies that the pods are running and the agbot and exchange are responding. Look for a "RUNNING" and "PASSED" message towards the end of the installation.
* If "FAILED", the output will ask you to look at specific logs for more information
* If "PASSED", the output will show details of tests that were run, and two more items to verify
  * Verify that the agbot heartbeat time displayed is recent.
  * Browse to the Edge Computing UI console at the URL given at the end of the log.
    * `https://<ICP_HOST>:<ICP_PORT>/edge`

## Post installation

Follow the steps in [Post installation configuration](https://www.ibm.com/support/knowledgecenter/SSFKVV_3.2.1/devices/installing/install.html#postconfig) .

## Uninstalling the Chart

Return to the location of this README.md and run the uninstall script provided to automate the un-installation tasks. Major steps covered by the script are: uninstall helm charts, removal of secrets. First, login to the cluster as a cluster administrator using `cloudctl`. Then:

```bash
ibm_cloud_pak/pak_extensions/uninstall/uninstall-edge-computing.sh <cluster-name>
```

**Note:** the separate databases you provisioned will remain. If you wish to delete that data, do it now.

## Role-Based Access

* Cluster administrator authority in the `kube-system` namespace is required to install and manage this product.
* Exchange authentication and roles:
  * Authentication of all exchange administrators and users is provided by ICP IAM through API keys generated with the `cloudctl` command
  * Exchange administrators should be given the `admin` privilege within the exchange. With that privilege they can manage all users, nodes, services, patterns, and policies within their exchange organization
  * Exchange non-administrator users can only manage users, nodes, services, patterns, and policies that they have created

## Security

* TLS is used for all data entering/leaving the kubernetes cluster. In this release TLS is not used **within** the kubernetes cluster for node to node communication. If needed, you can use IPSec to encrypt the internal traffic. See [Encrypting cluster data network traffic with IPSec](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/installing/ipsec_mesh.html?view=kc).
* Directories and volumes can be encrypted using the process outlined in [Encrypting volumes by using dm-crypt](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/installing/etcd.html).

## Limitations

* Installation limits: this product can be installed only once, and only into the `kube-system` namespace
* These charts run on IBM Private Cloud, but are not currently supported on Red Hat OpenShift
* Up to 3000 edge devices are supported in this release
* In this release there are not distinct authorization privileges for administration of the product and operating the product.

## Documentation

* Please see the [Installation](https://www.ibm.com/support/knowledgecenter/SSFKVV_3.2.1/devices/installing/install.html) Knowledge Center document for additional guidelines.

## Copyright

© Copyright IBM Corporation 2019. All Rights Reserved.
