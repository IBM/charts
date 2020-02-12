# IBM Edge Computing

## Introduction

IBM Edge Computing for Devices provides an end-to-end **Application Management Platform** for applications deployed on Edge devices typical in IoT deployments. This platform completely automates, and frees up the application developers from the task of securely deploying the revisions of edge workloads on thousands of field deployed edge devices. The application developer can instead focus on the task of writing the application code in any programming language as an independently deployable docker container. This platform takes the burden of deploying the complete business solution as a multi-level orchestration of docker containers on all the devices securely and seamlessly.

## Prerequisites

* IBM Cloud Private v3.2.0 or higher
* If hosting your own databases; two instances of PostgreSQL and an instance of MongoDB to store data for the IBM Edge Computing for Devices components. See the **Storage** section below for details.
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

## Storage and Database Requirements

Three database instances are necessary to store the IBM Edge Computing for Devices component data.

By default the chart will install three persistent databases with the sizings below.

**Note:** these default databases are not intended for production use. To utilize your own managed databases, see the requirements below and follow steps in the **Configure Remote Databases** section.

* PostgreSQL: Stores Exchange and AgBot data
  * Need 2 separate instances, each with at least 10GB of storage
  * For production use, these instances should be highly available and:
    * The instance storing exchange data should support at least 100 connections
    * The instance storing agbot data should support at least 20 connections
* MongoDB: Stores Cloud Sync Service data
  * Need 1 instance with at least 50GB of storage. **Note:** the size required is highly dependent on the size and number of edge service models and files you store and use.
  * For production use, this instance should be highly available

**Note:** You are responsible for the backup/restore procedures if using your own managed databases.
See the **Backup and Recovery** section for default database procedures.

## Monitoring resources

When IBM Edge Computing for Devices is installed, it automatically sets up monitoring of the product and the pods it runs on. The monitoring data can be viewed in the Grafana dashboard of the ICP management console at the following locations:

* `https://<ICP_HOST>:<ICP_PORT>/grafana/d/kube-system-edge-computing-overview/edge-computing-overview`
* `https://<ICP_HOST>:<ICP_PORT>/grafana/d/kube-system-edge-computing-pod-overview/edge-computing-pod-overview`

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

3. Edit `dbinfo.yaml` to supply the access information for the databases you provisioned. Fill out all the information in between the the double quotes (keeping the values quoted). When adding the trusted certs, be sure each line is indented 4 spaces to ensure proper reading of the yaml file. If 2 or more of the databases use the same cert, the cert does **not** need to be repeated in `dbinfo.yaml`. Save the file and then run:

```bash
kubectl --namespace kube-system apply -f dbinfo.yaml
```

#### Configure UI Menu

 If you are installing on ICP 3.2.0, it will be easier to find the Edge Computing management console if you search for the following helm configuration parameter in `values.yaml` and change its value to `true`:

```yaml
  uiMenu:
    enabled: false
```

#### Advanced Configuration

If you are installing on ICP 3.2.1, typically you do not need to change any of the default helm configuration parameters. But if desired, you can review the parameters with their descriptions using the `grep` command below, and then view/edit the corresponding values in `values.yaml`:

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

## Backup and Recovery

### Backup procedure

Ensure you are connected to your cluster and run the following commands in their entirety.

**Note:** The backups will be placed on the first worker node. Modify WORKER_IP if you want the backup to be stored on another worker

1. Run the following to set the required variables to perform the backup

```bash
export MASTER=$(kubectl get -n kube-public configmap -o jsonpath="{.items[]..data.cluster_address}") && \
WORKER_IP=$(kubectl get nodes -l node-role.kubernetes.io/worker | grep -m 1 Ready | awk '{print $1}') && \
TEMP_DIR=/tmp/edge-computing-secrets && \
EDGE_RELEASE_NAME=edge-computing && \
BACKUP_TIME=$(date +%Y%m%d_%H%M%S)
```

2. Run the following to backup authentication/secrets

```bash
ssh -t root@$MASTER "mkdir -p $TEMP_DIR; kubectl -n kube-system get secret edge-computing -o yaml > $TEMP_DIR/$EDGE_RELEASE_NAME-backup.yaml; \
kubectl -n kube-system get secret edge-computing-agbotdb-postgresql-auth-secret -o yaml > $TEMP_DIR/$EDGE_RELEASE_NAME-agbotdb-postgresql-auth-secret-backup.yaml; \
kubectl -n kube-system get secret edge-computing-css-db-ibm-mongodb-auth-secret -o yaml > $TEMP_DIR/$EDGE_RELEASE_NAME-css-db-ibm-mongodb-auth-secret-backup.yaml; \
kubectl -n kube-system get secret edge-computing-exchangedb-postgresql-auth-secret -o yaml > $TEMP_DIR/$EDGE_RELEASE_NAME-exchangedb-postgresql-auth-secret-backup.yaml; \
ssh -tt $(echo $WORKER_IP | awk '{print $1}') 'mkdir -p /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/css-backup; mkdir -p /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/secrets/'; \
scp $TEMP_DIR/*  $(echo $WORKER_IP | awk '{print $1}'):/mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/secrets/; \
rm -rf $TEMP_DIR" > /dev/null 2>&1
```

3. Run the following to backup database content

```bash
kubectl -n kube-system exec edge-computing-exchangedb-keeper-0 -- bash -c "export PGPASSWORD=$(kubectl -n kube-system get secret edge-computing -o jsonpath="{.data.exchange-db-pass}" | base64 --decode); pg_dump -U admin -h edge-computing-exchangedb-proxy-svc -F t postgres > /stolon-data/exchangedbbackup.tar" > /dev/null 2>&1;
kubectl -n kube-system exec edge-computing-agbotdb-keeper-0 -- bash -c "export PGPASSWORD=$(kubectl -n kube-system get secret edge-computing -o jsonpath="{.data.agbot-db-pass}" | base64 --decode); pg_dump -U admin -h edge-computing-agbotdb-proxy-svc -F t postgres > /stolon-data/agbotdbbackup.tar" > /dev/null 2>&1;
kubectl -n kube-system exec edge-computing-cssdb-server-0 -- bash -c "mkdir -p /data/db/backup; mongodump -u admin -p $(kubectl -n kube-system get secret edge-computing -o jsonpath="{.data.css-db-pass}" | base64 --decode) --out /data/db/backup" > /dev/null 2>&1;
```

4. Run the following to move the backups to a separate storage location

```bash
ssh -t root@$MASTER "ssh -tt $(echo $WORKER_IP | awk '{print $1}') 'mv /mnt/disk/${EDGE_RELEASE_NAME}/${EDGE_RELEASE_NAME}-exchange/exchangedbbackup.tar /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/'; \
ssh -tt $(echo $WORKER_IP | awk '{print $1}') 'mv /mnt/disk/${EDGE_RELEASE_NAME}/${EDGE_RELEASE_NAME}-agbot/agbotdbbackup.tar /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/'; \
ssh -tt $(echo $WORKER_IP | awk '{print $1}') 'mv /mnt/disk/${EDGE_RELEASE_NAME}/${EDGE_RELEASE_NAME}-css/backup/* /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/css-backup/';" > /dev/null 2>&1
```

### Restore Procedure

1. Delete any pre-existing secrets from your cluster
```bash
kubectl -n kube-system delete secret edge-computing edge-computing-agbotdb-postgresql-auth-secret edge-computing-exchangedb-postgresql-auth-secret edge-computing-css-db-ibm-mongodb-auth-secret;
```

2. Export these values to your local machine

_Note: Define BACKUP_TIME to match the datestamp from a previous backup in the format of YYYYMMDD_HHMMSS_

```bash
export MASTER=$(kubectl get -n kube-public configmap -o jsonpath="{.items[]..data.cluster_address}") && \
WORKER_IP=$(kubectl get nodes -l node-role.kubernetes.io/worker | grep -m 1 Ready | awk '{print $1}') && \
TEMP_DIR=/tmp/edge-computing-secrets && \
EDGE_RELEASE_NAME=edge-computing && \
BACKUP_TIME=<Insert Previous backup datestamp YYYYMMDD_HHMMSS> 
```

3. Run the following to restore authentication/secrets

```bash
ssh -t root@$MASTER "mkdir -p $TEMP_DIR; scp $WORKER_IP:/mnt/edge_backup/edge-computing_backup_${BACKUP_TIME}/secrets/* $TEMP_DIR; kubectl apply -f $TEMP_DIR; rm -rf $TEMP_DIR";
```

4. Reinstall Edge Computing before proceeding further, follow the instructions in the **Installing the Chart** section

5. Run the following to copy backups into the proper restoration locations

```bash
ssh -t root@$MASTER "ssh -tt $WORKER_IP 'cp -p /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/agbotdbbackup.tar /mnt/disk/${EDGE_RELEASE_NAME}/${EDGE_RELEASE_NAME}-agbot/agbotdbbackup.tar; \
cp -p /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/exchangedbbackup.tar /mnt/disk/${EDGE_RELEASE_NAME}/${EDGE_RELEASE_NAME}-exchange/exchangedbbackup.tar; \
cp -pR /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/css-backup/ /mnt/disk/${EDGE_RELEASE_NAME}/${EDGE_RELEASE_NAME}-css/'";
```

6. Run the following to restore database content

```bash
kubectl exec -n kube-system edge-computing-exchangedb-keeper-0 -- bash -c "export PGPASSWORD=$(kubectl get secret edge-computing -o jsonpath="{.data.exchange-db-pass}" | base64 --decode); pg_restore -U admin -h edge-computing-exchangedb-proxy-svc -d postgres -c /stolon-data/exchangedbbackup.tar";
kubectl exec -n kube-system edge-computing-agbotdb-keeper-0 -- bash -c "export PGPASSWORD=$(kubectl get secret edge-computing -o jsonpath="{.data.agbot-db-pass}" | base64 --decode); pg_restore -U admin -h edge-computing-agbotdb-proxy-svc -d postgres -c /stolon-data/agbotdbbackup.tar";
kubectl exec -n kube-system edge-computing-cssdb-server-0 -- bash -c "mongorestore -u admin -p $(kubectl get secret edge-computing -o jsonpath="{.data.css-db-pass}" | base64 --decode) /data/db/css-backup";
```

7. Run the following to refresh the kubernetes pod database connections
```bash
for POD in $(kubectl get pods -n kube-system | grep -E '\-agbot\-|\-css\-|\-exchange\-' | awk '{print $1}'); do kubectl delete pod $POD -n kube-system; done
```

## Limitations

* Installation limits: this product can be installed only once, and only into the `kube-system` namespace
* These charts run on IBM Private Cloud, but are not currently supported on Red Hat OpenShift
* Up to 3000 edge devices are supported in this release
* In this release there are not distinct authorization privileges for administration of the product and operating the product.

## Documentation

* Please see the [Installation](https://www.ibm.com/support/knowledgecenter/SSFKVV_3.2.1/devices/installing/install.html) Knowledge Center document for additional guidelines and updates.

## Copyright

© Copyright IBM Corporation 2019. All Rights Reserved.
