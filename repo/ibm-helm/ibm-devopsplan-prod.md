# DevOps Plan Helm Chart

## Introduction

[DevOps Plan](https://ibm.com/docs/en/devops-plan/3.0.4) is a change management platform designed for enterprise-level scalability, customizable processes, and enhanced project control. It accelerates project delivery and improves developer productivity.

## Chart Details

- This Helm chart deploys a single instance of DevOps Plan, which can be scaled to multiple instances.

## Product Documentation

- [DevOps Plan Product Documentation](https://ibm.com/docs/en/devops-plan/3.0.4)

## Prerequisites

1. **Kubernetes and CLI Tools**
   - Kubernetes 1.16.0+
   - OpenShift CLI (oc)
   - Helm 3

   Installation guides:
   - [kubectl CLI](https://kubernetes.io/docs/tasks/tools/)
   - [OpenShift CLI](https://docs.openshift.com/container-platform/4.18/cli_reference/openshift_cli/getting-started-cli.html)
   - [Helm 3 CLI](https://helm.sh/docs/intro/install/)

2. **Image and Helm Chart Access**
   - DevOps Plan images and Helm charts are available from the IBM Entitled Registry and public Helm repository.

     - Public Helm chart repository: [https://github.com/IBM/charts/tree/master/repo/ibm-helm](https://github.com/IBM/charts/tree/master/repo/ibm-helm)

     - Obtain an entitlement key:
       - Log in to [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary)
       - Copy your entitlement key from the *Entitlement keys* section

     - Create a secret (named `ibm-entitlement-key`) for authentication in `devopsplan` namespace:
       ```bash
       oc create secret docker-registry ibm-entitlement-key \
         --namespace devopsplan \
         --docker-username=cp \
         --docker-password=<EntitlementKey> \
         --docker-server=cp.icr.io
       ```
       - Secrets are namespace-scoped and must be created in each namespace where DevOps Plan will be installed.
       - Secrets configuration is needed in `global.imagePullSecret`.

3. **PostgreSQL Database**
   - DevOps Plan requires a PostgreSQL database to manage TeamSpaces and Applications.
   - You may use the built-in PostgreSQL provided by the Helm chart or disable it and configure your own external PostgreSQL instance.
   - Database connection parameters are required during installation if using an external database.

4. **Persistent Volumes**
   - Persistent storage is required for DevOps Plan data (`data`, `config`, `share`, `logs`).
   - If your Kubernetes cluster supports a default `StorageClass` and dynamic provisioning, no manual PV creation is needed.
   - DevOps Plan requires non-root access to persistent storage. When using IBM File Storage, you need to either use the IBM provided "gid" File storage class with default group ID 65531 or create your own customized storage class to specify a different group ID. Please follow the instructions at https://cloud.ibm.com/docs/containers?topic=containers-cs_storage_nonroot for more details.
   - The DevOps Plan persistent volumes has been tested with default StorageClass "ibmc-block-gold" for the persistence volume with no sharing the data, persistence.ccm.storageClass=ibmc-file-gold-gid for the persistence volume with sharing the data and securityContext.fsGroup=65531. The default setting for the StorageClass and fsGroup shown below and you can update based on your cluster environment.

     ```yaml
     persistence:
       storageClass: ''
       ccm:
         storageClass: ibmc-file-gold-gid
     securityContext:
       fsGroup: 65531
     ```
   - If default StorageClass is not set, then create a `StorageClass`, `PersistentVolume` and set the storage class name during the helm install.

   ```bash
   --set global.persistence.rwoStorageClass=<Your StorageClass>
   ```

   For RWX (ReadWriteMany) support:

   ```bash
   --set global.persistence.rwxStorageClass=<Your RWX StorageClass>
   ```

5. **Keycloak Single Sign-On**
   - The Helm chart installs Keycloak by default. You can disable this and use an external Keycloak instance instead.

6. **Licensing Requirements**
   - The DevOps Plan image uploads license metrics (Concurrent Users) to the IBM License Service.
   - Ensure IBM License Service is installed: [Install License Service](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.6?topic=service-installing-license)

   - Copy required secrets and config to your target namespace:
     ```bash
     oc get secret ibm-licensing-upload-token -n ibm-licensing -o yaml | sed 's/^.*namespace: ibm-licensing.*$//' | oc create -f -
     oc get configMap ibm-licensing-upload-config -n ibm-licensing -o yaml | sed 's/^.*namespace: ibm-licensing.*$//' | oc create -f -
     ```

   - Enable license metric upload during install:
     ```bash
     --set global.licenseMetric=true
     ```

   - Once metrics are uploaded (may take up to 24 hours), retrieve usage data: [License Service Usage](https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.6?topic=data-per-cluster-from-license-service)

7. **Helm Installation Timeout Recommendation**
   - In clusters with slow pod startup times, increase the default Helm timeout from 5 minutes to 10 minutes:
     ```bash
     helm install <release-name> <chart-path> --timeout=10m0s
     ```

## Installing the Chart

### Add the Helm Repository
```bash
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm/
```

### List Available Chart Versions
```bash
helm repo update
helm search repo ibm-helm/ibm-devopsplan
```

To find OpenShift DNS name for the domain name:
```bash
DOMAIN=$(oc get --namespace=openshift-ingress-operator ingresscontroller/default -ojsonpath='{.status.domain}')
```

### Install with Default Parameters
```bash
helm install ibm-devopsplan ibm-helm/ibm-devopsplan-prod \
  --namespace devopsplan \
  --set global.imagePullSecrets={ibm-entitlement-key} \
  --set global.domain=${DOMAIN} \
  --timeout 10m
```

> Note:
> - Ensure global.imagePullSecrets are formatted with braces: `{ibm-entitlement-key}`
> - To enable user invitation emails, set the `serverQualifiedUrlPath` to your DevOps Plan URL:

```bash
--set serverQualifiedUrlPath=<DevOps Plan URL>
```

### **Optional Installations**

- **External PostgreSQL**: See *Installing DevOps Plan with External Database and Optional Email Server Settings*
- **External Keycloak**: See *Installing DevOps Plan with External Keycloak Single Sign-On*
- **DevOps Control**: See *Installing with DevOps Control*
- **AI Assistant (Llama)**: See *AI Assistant Integration with Llama*
- **Self-Signed and Private CA**: See *Self-Signed and Private CA*

- If your cluster's default storage class does not support `ReadWriteMany` or `ibmc-file-gold-gid`, use:
```bash
--set global.persistence.rwoStorageClass=[default_storage_class] \
--set persistence.ccm.storageClass=[ReadWriteMany_storage_class] \
--set securityContext.fsGroup=65531
```

---

### **Install with Custom Parameter Settings**

1. **Inspect and Export Values**

```bash
helm inspect values devops-plan/ibm-devopsplan-prod > my_values.yaml
```

2. **Edit `my_values.yaml`**  
Update the file with custom values for your deployment.

3. **Install Using Custom Values**

```bash
helm install ibm-devopsplan ./ibm-devopsplan-prod \
  --namespace devopsplan \
  --values my_values.yaml \
  --timeout 10m
```

## Uninstalling the Chart
```bash
helm delete ibm-devopsplan --namespace devopsplan
```

---

## **Enable License Metrics**

The `global.licenseMetric` parameter is set to false by default. You must set it to true during Helm install or upgrade to enable license metrics:

```bash
--set global.licenseMetric=true 
```

Before enabling license metrics, ensure that the IBM License Service is installed in your OpenShift environment, and that you have copied the required license service upload secret and ConfigMap.

For more information, refer to the **Licensing Requirements** section in the Prerequisites.

---

## **Installing DevOps Plan with External Database and Optional Email Server Settings**

DevOps Plan requires a PostgreSQL database to manage TeamSpaces and Applications. You may use the default bundled PostgreSQL or configure an external database.

1. **Create a `devopsplan.yaml` file with the following content:**

```yaml
## Spring datastore settings (Only PostgreSQL)
spring:
  datastore:
    url: "jdbc:postgresql://<DATABASE_HOST>:<DATABASE_PORT>/<DATABASE_NAME>"
    username: <DATABASE_USERNAME>
    password: <DATABASE_PASSWORD>

## Tenant datastore settings (Only PostgreSQL)
tenant:
  datastore:
    server: <DATABASE_SERVER_NAME>
    dbname: <DATABASE_NAME>
    username: <DATABASE_USERNAME>
    password: <DATABASE_PASSWORD>

postgresql:
  enabled: false 

## SMTP settings (Optional)
global:
  platform:
    smtp:
      sender: <SENDER_EMAIL_ADDRESS>
      host: <SMTP_SERVER>
      port: <SMTP_PORT>
      username: <SMTP_USERNAME>
      password: <SMTP_PASSWORD>
```

---

## **Installing DevOps Plan with External Keycloak (Single Sign-On)**

The Helm chart supports disabling the internal Keycloak service and integrating with an external Keycloak instance.

1. **Create a `keycloak.json` ConfigMap**

```bash
mkdir /path/to/your/keycloak
# Place keycloak.json into this folder

kubectl create configmap keycloak-json \
  --from-file=/path/to/your/keycloak/keycloak.json \
  --namespace <namespace_name>

kubectl get configmap keycloak-json -o yaml --namespace <namespace_name>
```

2. **Create a `keycloak.yaml` file:**

```yaml
keycloak:
  enabled: true
  service:
    enabled: false
  urlMapping: <Keycloak_URL>
  username: <Keycloak_Admin_Username>
  password: <Keycloak_Admin_Password>
  realmName: <Keycloak_Realm_Name>
  dashboardsClientID: <Keycloak_Dashboards_Client_ID>
  dashboardsClientSecret: <Keycloak_Dashboards_Client_Secret>
  jsonFile:
    enabled: true
    configMapName: keycloak-json

keycloaksrv:
  enabled: false
```

3. **Install or Upgrade with External Keycloak Configuration**

Add `-f keycloak.yaml` to your `helm install` or `helm upgrade` command.

---

## **DevOps Plan install with DevOps Control**

DevOps Control offers Git hosting and collaboration features based on Gitea.

### **Steps**

1. **Create imagePullSecret**

Create an imagePullSecret named 'ibm-entitlement-key' as explained in Step 2 of Prerequisites section.

2. **Pull the Helm chart**
  
```bash
helm pull ibm-helm/ibm-devopsplan-prod --untar
```

3. **Install the helm chart**

Install the helm chart with the default parameters into namespace *devopsplan* with the release name *ibm-devopsplan*.

```bash
helm install ibm-devopsplan ./ibm-devopsplan-prod \
  -f ibm-devopsplan-prod/control-Openshift.yaml  \
  --namespace devopsplan \
  --set global.imagePullSecrets={ibm-entitlement-key} \
  --set global.domain=DOMAIN \
  --set control.enabled=true \
  --set control.gitea.config.webhook.SKIP_TLS_VERIFY=true \
  --timeout 10m
```

4. **Run *helm status ibm-devopsplan -n devopsplan* to retrieve URLs, username and password.**

Start the DevOps Plan home page in your browser by using https://devopsplan-control.$INGRESS_DOMAIN/control.

The DevOps Control is using the internal PostgreSQL database by default. If you plan to install/upgrade the helm charts with an external PostgreSQL database, then you need to add the following setting to *helm upgrade --install*.

  ```bash
  --set control.postgresql.host=[CONTROL_DATABASE_SERVER_NAME] \
  --set control.postgresql.dbName=[CONTROL_DATABASE_NAME] \
  --set control.postgresql.username=[CONTROL_DATABASE_USERNAME] \
  --set control.postgresql.password=[CONTROL_DATABASE_PASSWORD] 
  ```

## **AI Assistant Integration with Llama (Open-Source LLMs)**

Use [Ollama](https://ollama.com/) to run LLaMA models in DevOps Plan.

Supported models: `LLaMA 2`, `LLaMA 3`, `Mistral`, `Gemma`, `Code LLaMA`, and more.

### **Example Helm Values**

```yaml
llama:
  models:
    - name: <Model_Name>
  run:
    - name: <Model_Name>
```

### **API Call Example**

```bash
curl -k -s <Llama_URL>/api/generate -d '{
  "model": "<Model_Name>",
  "prompt": "<Your_Message>",
  "stream": false
}'
```

### **Enable via Helm**

```bash
--set llama.enabled=true
```

If the default storage class does not support the ReadWriteMany (RWX) accessMode or it does not support Storage Class ibmc-file-gold-gid, then an alternative class must be specified using the following additional helm values:

```bash
--set llama.persistence.ccm.storageClass=[ReadWriteMany_storage_class] \
```

### **Verify Installation**

```bash
helm status ibm-devopsplan -n $NAMESPACE
kubectl exec -it <devopsplan_pod_name> -- curl -ks <Llama_URL>
# Expected: Ollama is running
```

---

## **Certificates: Self-Signed and Private CAs**
Self-signed certificates and private Certificate Authorities (CAs) are essential for enabling TLS/SSL encryption and establishing mutual trust between services—especially within internal environments.

### **Create a Certificate**
You can create a valid certificate using either a self-signed certificate or a private CA. The example below shows how to generate a private key (key.pem) and a certificate (cert.pem) for your domain using OpenSSL:

```bash
DOMAIN=<Your_External_IP_Address>.nip.io

openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 365 \
  -subj "/CN=$DOMAIN" \
  -addext "subjectAltName = DNS:${DOMAIN},DNS:*.${DOMAIN}" \
  -addext "certificatePolicies = 1.2.3.4"
```

### **Use Self-Signed Cert**

1. Create a TLS secret.

```bash
kubectl create secret generic my-tls-secret \
  --from-file=tls.crt=./cert.pem \
  --from-file=tls.key=./key.pem \
  --from-file=ca.crt=./cert.pem \
  --namespace devopsplan
```

2. Set TLS secret name in Helm.

```bash
--set global.certSecretName=my-tls-secret
```

### **Use Private CA Bundle**

1. Create a private CA bundle secret.

```bash
kubectl create secret generic my-internal-ca-bundle \
  --from-file=ca.crt=./cert.pem \
  --namespace devopsplan
```

2. Set the private CA secret Name in Helm.

```bash
--set global.privateCaBundleSecretName=my-internal-ca-bundle
```

---

## **Install SSL Certificate in DevOpsPlan Container**

1. Create the keystore directory and add your `keystore.p12`:

```bash
mkdir /path/to/your/keystore
```

2. Create ConfigMap:

```bash
kubectl create cm keystore-file \
  --from-file=/path/to/your/keystore/keystore.p12 \
  --namespace <namespace_name>
```

3. Verify:

```bash
kubectl get cm keystore-file -o yaml --namespace <namespace_name>
```

4. Create `ssl.yaml`:

```yaml
ssl:
  enabled: true
  password: ""
  keyAlias: 1
  configMapName: keystore-file
```

5. Add to Helm command:

```bash
-f ssl.yaml
```

## Backup and Restore Openshift Cluster and PVC Using Velero and MinIO

This guide explains how to configure and use Velero and MinIO to back up and restore your Openshift cluster, including Persistent Volume Claims (PVCs). Velero manages backups while MinIO provides S3-compatible storage.

### Install Backup and Restore Helm Chart
**Steps 1.** Download ibm-devopsplan-prod chart from devops-plan repository and unpack it in local directory

  ```bash
  helm pull ibm-helm/ibm-devopsplan-prod --untar
  ```

**Step 2.** Install the Backup and Restore into namespace *backup* with the release name *backup*.

  ```bash
  helm install backup ./ibm-devopsplan-prod \
    -f ibm-devopsplan-prod/backup-openshift.yaml \
    --namespace backup --create-namespace  \
    --set global.imagePullSecrets={ibm-entitlement-key} \
    --timeout 10m
  ```

 Note: When you are setting the global.imagePullSecrets, make sure to properly format it within curly braces.

 If your Openshift Cluster does not have a default storage class set, you must explicitly specify the storage class when deploying:

    --set global.persistence.rwoStorageClass=[Your storage class name]

 Replace <your-storage-class-name> with the name of your desired storage class.


**Step 3.** Install the Velero client

    chmod +x  ibm-devopsplan-prod/files/ocbackup.sh && ibm-devopsplan-prod/files/ocbackup.sh backup

**Step 4.** Verify the Installation:

The BackupStorageLocation is ready to use when it has the phase Available. You can check the status with the following command:

    velero backup-location get -n backup

 Run **helm status backup -n backup**  to retrieve the URL, username and password for the MinIO Object Store to check list of the bucket of your backup.

### Backup and Restore Instructions for DevOps Plan

This section outlines the steps to backup and restore the DevOps Plan resources and persistent volumes deployed in the **devopsplan** namespace with the release name **ibm-devopsplan**.

**Step 1.** Annotate Pods for Backups

  - Run the following script. When prompted, enter the namespace as **devopsplan**.  This script annotate all pods in **devopsplan** namespace with their volume names for Velero backup:

    ```yaml
    read -p "Enter namespace: " ns; \
    oc get pods -n "$ns" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | \
    while read pod; do \
      vols=$(oc get pod "$pod" -n "$ns" -o jsonpath='{.spec.volumes[*].name}' | tr ' ' ','); \
      echo "Annotating $pod with volumes: $vols"; \
      oc annotate pod "$pod" -n "$ns" backup.velero.io/backup-volumes="$vols" --overwrite; \
    done
    ```

    Note: Failing to annotate pods will result in persistent volume claim (PVC) data not being backed up or restored when using storage classes that do not support CSI snapshots.

**Step 2.** Create a backup

  ```yaml
    velero backup create <Backup_Name> --include-namespaces devopsplan -n backup
  ```

Replace <Backup_Name> with a name of your choice for the backup.

**Step 3.** Verify the Backup

  ```yaml
    velero backup get -n backup
  ```

**Restore**

To restore the DevOps Plan resources and persistent volumes from the previously created backup:

  ```yaml
    velero restore create --from-backup <Backup_Name> -n backup
  ```

Replace <Backup_Name> with a name of your choice for the backup.

### Additional reference guide for managing backups and restores

This section provides quick reference guide for managing backups and restores in Openshift Cluster using Velero

```yaml
1. Create Backup of a Namespace

velero backup create <Backup_Name> --include-namespaces <Namespace> -n backup
velero backup get -n backup

    What it does: Creates a backup of all resources inside the specified namespace.
    When to use: To save the current state of all resources (pods, services, etc.) in a namespace.
    velero backup get lists all backups.

2. Restore Backup to the Same Namespace

velero restore create --from-backup <Backup_Name> -n backup
velero restore get -n backup

    What it does: Restores the backup to the original namespace.
    When to use: Recover or duplicate resources in the same namespace.
    velero restore get lists all restore jobs and their status.
    
Note : We are not supporting namespace mapping for Plan Application.

3. Backup All Cluster-Level Resources

velero backup create <Backup_Name> --include-cluster-resources=true -n backup
velero backup get -n backup

    What it does: Backs up cluster-wide resources like CRDs, roles, storage classes.
    When to use: To create a full backup of your Kubernetes cluster state.

4. Backup Only Specific Cluster Resources

velero backup create full-backup --include-resources='customresourcedefinitions,clusterroles,clusterrolebindings,namespaces,persistentvolumes,persistentvolumeclaims,storageclasses,mutatingwebhookconfigurations,validatingwebhookconfigurations' --include-cluster-resources=true -n backup
velero backup get -n backup

    What it does: Backs up only selected critical cluster-wide resources.
    When to use: When you want to back up just important cluster components.

5. Backup PersistentVolumeClaims (PVCs) Across Namespace

velero backup create <Backup_Name> --include-resources persistentvolumeclaims,persistentvolumes --include-namespaces <Namespace> -n backup
velero backup get -n backup

    What it does: Backs up PVCs in namespace.
    When to use: To protect storage claims separately from pods or other resources.

6. Backup PersistentVolumes (PVs) and PVCs Cluster-wide

velero backup create <Backup_Name> --include-resources=persistentvolumeclaims,persistentvolumes --include-namespaces '*' --include-cluster-resources=true -n backup
velero backup get -n backup

    What it does: Backs up both PVs and PVCs for the entire cluster.
    When to use: To have a full backup of storage resources.

7. Backup Namespace Without Pods

velero backup create <Backup_Name> --include-namespaces <Namespace> --exclude-resources pods -n backup

    What it does: Backs up everything except pods in the namespace.
    When to use: Pods are often recreated automatically; this saves space and time.

8. Create Backup with Expiration Time (TTL)

velero backup create <Backup_Name> --include-namespaces <Namespace> --ttl 90d -n backup
velero backup get -n backup

    What it does: Creates a backup that expires automatically after 90 days.
    When to use: To manage storage by keeping backups only for a limited time.

9. View Details of a Backup

velero backup describe <Backup_Name> --details -n backup

    What it does: Shows detailed info about what resources were backed up.
    When to use: To verify the contents of your backup.

10. View Logs for a Backup

velero backup logs <Backup_Name> -n backup

    What it does: Displays logs generated during backup creation.
    When to use: Troubleshoot backup failures or issues.

11. Schedule Backups Every Minute

velero schedule create <Schedule_Name> --schedule="*/1 * * * *" --include-namespaces <Namespace> -n backup
velero schedule get -n backup

    What it does: Creates an automatic backup schedule running every minute.
    velero schedule get lists all scheduled backups.
    When to use: For very frequent backups during testing or for critical workloads.

12. Delete Scheduled Backups

velero schedule delete <Schedule_Name> -n backup

13. Delete Backups

velero delete <Backup_Name> -n backup

 Note:
 If your application has been upgraded and you want to restore it to an older version from a Velero backup, use the --existing-resource-policy update flag. This ensures existing resources are updated to match the backup, even if they already exist.

    velero restore create --from-backup <backup_name> --existing-resource-policy update

```
### Uninstall Backup and Restore Helm Chart

To uninstall/delete the backup and restore Helm chart with namespace delete.

  ```bash
  helm delete backup -n backup
  helm delete ns backup
  ```

### Limitation:

Velero does not back up or restore hostPath volumes directly. If your Kubernetes setup uses hostPath volumes, you won't be able to use Velero's backup and restore functionality for those volumes.
Delete the backup namespace as well to prevent potential MinIO repository corruption after uninstallation of Velero/Minio.

---

## Devops Plan Scaling
You can manually scale the number of DevOps Plan Server, Analytics, and Search instances by updating the replicaCount values in your configuration:

  ```bash
  ## DevOps Plan Server
  ccm:
    replicaCount:

  ## Analytics
  analytics:
    replicaCount: 
    
  ## Search
  search:
    replicaCount:
  ```

## Horizontal Pod Autoscaler (HPA)
DevOps Plan supports Horizontal Pod Autoscaler (HPA) for the Server, Analytics, and Search pods.

By default, HPA is disabled for all components. You can enable it by setting the autoscaling.enabled flag:

```bash
  ## DevOps Plan Server
  ccm:
    autoscaling:
      enabled: true

  ## Analytics
  analytics:
    autoscaling:
      enabled: true 

  ## Search
  search:
    autoscaling:
      enabled: true
  ```

If you have enabled the Autoscaler, ensure that the storage class you configure supports RWX (ReadWriteMany) access mode.

```bash
  persistence:
    ccm:
      storageClass: <Your RWX StorageClass>
      data: 
        accessModes: 
          - ReadWriteMany
    analytics:
      storageClass: <Your RWX StorageClass>
      data: 
        accessModes: 
          - ReadWriteMany
    search:
      storageClass: <Your RWX StorageClass>
      data: 
        accessModes: 
          - ReadWriteMany
```

### HPA Coonfiguration
The following parameters can be customized for each component.

**Common Parameters**

| **Parameter**                                     | **Description**                                                                 | **Default** |
| ------------------------------------------------- | ------------------------------------------------------------------------------- | ----------- |
| `*.autoscaling.enabled`                           | Enables or disables HPA for the component                                       | `false`     |
| `*.autoscaling.minReplicas`                       | Minimum number of pod replicas maintained at all times                          | `1`         |
| `*.autoscaling.maxReplicas`                       | Maximum number of pod replicas allowed                                          | `3`         |
| `*.autoscaling.targetCPUUtilizationPercentage`    | Desired average CPU utilization across pods (percentage of requested CPU)       | `80`        |
| `*.autoscaling.targetMemoryUtilizationPercentage` | Desired average memory utilization across pods (percentage of requested memory) | `80`        |

**Component-Specific Examples**

| **Component**      | **Config Path**           | **Notes**                                     |
| ------------------ | ------------------------- | --------------------------------------------- |
| DevOps Plan Server | `ccm.autoscaling.*`       | Controls autoscaling of core DevOps Plan pods |
| Analytics          | `analytics.autoscaling.*` | Controls autoscaling of Analytics pods        |
| Search             | `search.autoscaling.*`    | Controls autoscaling of Search pods           |

---

## Update OpenSearch and OpenSearch Dashboards Password

By default, OpenSearch and OpenSearch Dashboards use the username admin. To change the default username and password, you can update the values.yaml file or use the --set flags during Helm installation.

- Option 1: Modify values.yaml

  ```bash
  opensearch:
    username: [USERNAME]
    password: [PASSWORD]
  ```

- Option 2: Use --set flags with Helm

  ```bash
  --set opensearch.username=[USERNAME]
  --set opensearch.password=[PASSWORD]

## Settings Feedback Email Address
To set email address for the feedback, the admin requires to set feedback.to.emailaddress and feedback.from.emailaddress during the Helm install/upgrade.
  ```bash
  feedback:
    toEmailaddress: [TO_EMAIL_ADDRESS]
    fromEmailaddress: [FROM_EMAIL_ADDRESS]
  ```

---

## Rolling upgrade release

You can upgrade DevOps Plan to the newest release using the helm upgrade command.

- Use Helm to install the DevOps Plan chart as described in section **Installing the Chart**.

- If you already installed with the internal PostgreSQL database, and you plan to upgrade with the latest release version without deleting the PostgreSQL PVC, then you need to get the existing password before uninstall/upgrade and set it during *helm upgrade --install*. Get the password for internal PostgreSQL database by running this command when namespace is set to *devopsplan*:
  ```bash
  export POSTGRES_PASSWORD=$(kubectl get secret --namespace devopsplan ibm-devopsplan-postgresql -o jsonpath="{.data.tenant-datastore-password}" | base64 -d)
  ```
  Set the password during the helm upgrade --install:
  ```bash
  --set postgresql.existingPassword=$POSTGRES_PASSWORD
  ```

- If you already installed with the internal Keycloak, and you plan to upgrade with the latest release version without deleting the Keycloak PVC, then you need to get the existing password before uninstall/upgrade and set it during *helm upgrade --install*. Get the password for internal Keycloak by running this command when namespace is set to *devopsplan*:
  ```bash
  export KEYCLOAK_PASSWORD=$(kubectl get secret --namespace devopsplan ibm-devopsplan-keycloak -o jsonpath="{.data.keycloak-password}" | base64 -d)
  ```
  Set the password during the helm upgrade --install:
  ```bash
  --set keycloak.existingPassword=$KEYCLOAK_PASSWORD
  ```

---

## Rolling rollback release
You can rollback to the previous release using *helm rollback* command.

**Before you begin**

1. Use Helm to install the chart as described in section **Installing the Chart**.
2. Use Helm to upgrade the chart to new release as described in section **Rolling upgrade release**.

**Procedure:**
1. Run *helm history* command to see revision numbers of your helm chart release. You should have min two revision numbers. revision 1 for install and revision 2 for the upgrade that you execute in **Before you begin** section. Example below shows you have a helm chart release name *ibm-devopsplan1* with revision 1 installed the helm chart *ibm-devopsplan1-3.0.3* for release 3.0.4 and revision 2 upgraded the helm chart *ibm-devopsplan2-3.0.4* to release 3.0.4.

  ```bash
  $ helm history ibm-devopsplan1 --namespace dev
  REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
  1               Thu Nov 20 21:58:13 2024        superseded      ibm-devopsplan1-3.0.3          Install complete
  2               Thu Nov 20 22:13:56 2024        deployed        ibm-devopsplan2-3.0.4          Upgrade complete
  ```

2. Rollback helm chart using *helm rollback* command. Example below will rollback helm chart release *ibm-devopsplan1* from revision 2 to revision 1.

  ```bash
  $ helm rollback ibm-devopsplan --namespace dev
  Rollback was a success! Happy Helming!
  ```

3. Run *helm history RELEASE* command again to see the new revision 3 has been created after rollback, and it rollbacked to revision 1 the helm chart release *ibm-devopsplan1*.

  ```bash
  $ helm history ibm-devopsplan1 --namespace dev
  REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
  1               Thu Nov 20 21:58:13 2024        superseded      ibm-devopsplan1-3.0.3          Install complete
  2               Thu Nov 20 22:13:56 2024        deployed        ibm-devopsplan2-3.0.4          Upgrade complete
  3               Thu Nov 20 22:30:32 2024        deployed        ibm-devopsplan1-3.0.3          Rollback to 1
  ```

- The OpenSearch version has been upgraded from 2.18.0 to 3.1.0 as part of the DevOps Plan 3.0.5 release. OpenSearch 2.18.0 is based on Lucene 9, whereas OpenSearch 3.1.0 is based on Lucene 10. This Rollback constitutes a major version change; therefore, in-place rolling back are not supported. To complete the rollback, either a full cluster restart or a migration involving reindexing is required. For detailed guidance, refer to the official OpenSearch documentation.

---

## **Configuration**

### Parameters
The Helm chart has the following values that can be overridden using the *--set parameter* or specified via *-f myvalues.yaml*.

### Common Parameters

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **global.imageRegistry** |  DevOps Plan docker image registry. | cp.icr.io |
| **global.imagePullSecret** | Your own secret with your credentials to IBM's docker repository. | "" |
| **global.imagePullSecrets** | Array of yYour own secret with your credentials to IBM's docker repository. | "" |
| **global.licenseMetric** | DevOps Plan license metrice for concurrent users. | false |
| **global.passwordSeed** | PasswordSeed for the Keycloak and PostgreSQL password | "" |
| **global.persistence.rwoStorageClass** | The global storageClassName with ReadWriteOnece access mode | "" |
| **global.persistence.rwxStorageClass** | The global storageClassName with ReadWriteMany access mode | "" |
| **replicaCount** | Number of replicas to deploy instances of DevOps Plan service. | 1 |
| **image.repository** | DevOps Plan docker Image repository path. | cp/devops-plan/devopsplan |
| **image.tag** | DevOps Plan Image tag or image digest. | See values.yaml |
| **image.pullPolicy** | DevOps Plan image pull policy.Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent |
| **hostname** | DevOps Plan Docker Container hostname. | devopsplan |
| **timeZone** | DevOps Plan server Time Zone. It can be set based on a list of supported timezones and abbreviations.| EST5EDT |
| **serverQualifiedUrlPath** | If defined, it overrides the mapping URL in DevOps Plan server application.properties file.<br>Example: "https://[MAPPING_NAME].com" | "" |
| **service.type** | Service type. It can be set to ClusterIP, LoadBalancer or NodePort | ClusterIP |
| **service.exposePort** | Service expose port  | "" |
| **ingress.enabled** | Ingress service. Accepted values are:<br> - *true* to enable the ingress service.<br> - *false* to disable the ingress service.| true |
| **ingress.type** | Ingress service type.. Accepted values are: nginx, route, mapping| route |
| **hosts** | List of hosts for the ingress. | devopsplan.ibm.com |
| **swagger.enabled** | This parameter enables or disables Swagger UI visibility. Accepted values are:<br>- *true* to enable Swagger UI visibility.<br>- *false* to disable Swagger UI visibility. | false |
| **auth.jwt.refreshTokenValiditySeconds** | Duration for which a JWT refresh token remains valid, in seconds. | `86400` (1 day) |

### Parameters for creating TeamSpace and Applications
The PostgreSQL database requires to create TeamSpace and Applications. The helm chart is installed with the internal PostgreSQL database by default. If you plan to install/upgrade the helm charts with an external database, then you need to set the *postgresql.enabled* to *false* and set the *spring.datastore* and *tenant.datastore* configuration settings based on your external database parameters. PostgreSQL database is supported for release 3.0.4.

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **spring.datastore.url** | postgresql JDBC URL with format *jdbc:postgresql://[host_address]:[port_number]/[database_name].* | jdbc:postgresql://devopsplan-postgresql:5432/postgres |
| **spring.datastore.username** | postgresql database username | postgres |
| **spring.datastore.password** | postgresql database password | See values.yaml |
| **tenant.datastore.vendor** | Tenant database vendor. The current supported database is PostgreSQL. * | PostgreSQL |
| **tenant.datastore.server** | Tenant database server | devopsplan-postgresql |
| **tenant.datastore.dbname** | Tenant database name | postgres |
| **tenant.datastore.username** | Tenant database username | postgres |
| **tenant.datastore.password** | Tenant database password | See values.yaml |
| **tenant.registration.code** | Tenant generate registration codes. Accepted values are:<br>- *NONE* no verification needed. Any verification code is ignored.<br>- *PROVIDED* the code supplied by the registration API call .<br>- *GENERATED* the server generates a random code (default 6 alphanumeric characters). | NONE |

### SMTP Server Parameters

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **global.platform.smtp.host** | SMTP server host  | "" |
| **global.platform.smtp.port** | SMTP server port number | "" |
| **global.platform.smtp.username** | SMTP server username | "" |
| **global.platform.smtp.password** | SMTP server password | "" |
| **global.platform.smtp.sender** | The SMTP sender email address has to delivered from on-boarding process | "" |
| **global.platform.smtp.startTLS** | This parameter sets the mail server to secure protocol using TLS or SSL. Accepted values are:<br>- *true* to set secure protocol using TLS or SSL.<br>- *false* to set unsecure protocol | false |
| **global.platform.smtp.smtps** | This parameter sets the mail server protocol. Accepted values are:<br>- *true* to set smtps protocol.<br>- *false* to set smtp protocol. | false |


### Analytics Parameters
The helm chart installs the Analytics feature on a separate pod by default. you can disabled/enabled the Analytics feature service by setting *analytics.service* to *false/true*. 

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **analytics.service** | This parameter enables or disables Analytics service. Accepted values are:<br>- *true* to enable Analytics service.<br>- *false* to disable Analytics service.<br>This parameter is needed if you plan to use Analytics features for the DevOps Plan. | true |
| **analytics.type** | Analytics service type  | LoadBalancer |
| **analytics.exposePort** | Analytics service port  | "" |
| **analytics.urlMapping** | URL mapping. <br>- The mapping URL format should be *https:[mapping-name].com*.  | "" |
| **analytics.replicaCount** | Number of replica Analytics Pods. This parameter is needed if analytics.service *=true.* | 1 |
| **analytics.image.repository** | Analytics docker Image repository path. This parameter is needed if analytics.service *=true.* | cp/devops-plan/devopsplan-analytics |
| **analytics.image.tag** | Analytics Image tag. This parameter is needed if *analytics.service=true.* | 3.0.4 |
| **analytics.image.pullPolicy** | Analytics image pull policy. This parameter is needed if *analytics.service=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent | 
| **analytics.hostname** | Analytics hostname | analytics |

### PostgreSQL Database Parameters
The helm chart is installed with the internal postgresql database by default.

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **postgresql.enabled** | This parameter enables or disables devopsplan-postgresql database service. Accepted values are:<br>- *true* to enable postgresql database service.<br>- *false* to disable postgresql database service. | true |
| **postgresql.repository** | Postgresql database docker Image repository path. This parameter is needed if *postgresql.enabled=true.* | cp/devops-plan/devopsplan-postgresql |
| **postgresql.tag** | Postgresql database Image tag.This parameter is needed if *postgresql.enabled=true.* | 3.0.4 |
| **postgresql.pullPolicy** | Postgresql database image pull policy.This parameter is needed if *postgresql.enabled=true*Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent |
 **postgresql.service.type** | postgresql service type  | LoadBalancer |
| **postgresql.service.exposePort** | postgresql service port  | "" |
| **postgresql.existingPassword** | postgresql existing password. It is needed if you uninstall and install the devopsplan without deleting the PostgreSQL PVC, then you need to set *postgresql.existingPassword* to the existing password before uninstalling. | "" |

### Dashboard Parameters
The dashboards analytics configuration setting options set by default for dashboard properties using Nginx, Opensearch and Opensearch-dashboards in Helm chart. It is strongly recommended to not modify the default values as shown in the below table. 

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **analyticsUserName** | Analytics UserName| SYSTEM_ANALYTICS1 |
| **analyticsBootstrapData** | Set number of the days of analytics data | 90 |
| **nginx.service** | This parameter enables or disables Nginx service. Accepted values are:<br>- *true* to enable Nginx service.<br>- *false* to disable Nginx service.<br>This parameter is needed if you plan to use Dashboard features for the Business Analytics. | true |
| **nginx.type** | Nginx service type  | LoadBalancer |
| **nginx.exposePort** | Nginx service port  | "" |
| **nginx.urlMapping** | URL mapping. <br>- The mapping URL format should be *https:[mapping-name].com*.  | "" |
| **nginx.replicaCount** | Number of replica nginx Pods. This parameter is needed if nginx.service *=true.* | 1 |
| **nginx.image.repository** | Nginx docker Image repository path. This parameter is needed if nginx.service *=true.* | cp/devops-plan/devopsplan-nginx |
| **nginx.image.tag** | Nginx Image tag. This parameter is needed if *nginx.service=true.* | 3.0.4 |
| **nginx.image.pullPolicy** | Nginx image pull policy. This parameter is needed if *nginx.service=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent | 
| **nginx.hostname** | Nginx hostname | nginx |
| **dashboards.service** | This parameter enables or disables dashboards service. Accepted values are:<br>- *true* to enable Nginx service.<br>- *false* to disable dashboards service.<br>This parameter is needed if you plan to use Dashboard features for Business Analytics. | true |
| **dashboards.replicaCount** | Number of replica dashboards Pods. This parameter is needed if dashboards.service *=true.* | 1 |
| **dashboards.image.repository** | Opensearch-dashboards docker Image repository path. This parameter is needed if dashboards.service *=true.* | cp/devops-plan/devopsplan-dashboards |
| **dashboards.image.tag** | Opensearch-dashboards Image tag. This parameter is needed if *dashboards.service=true.* | 3.0.4 |
| **dashboards.image.pullPolicy** | Opensearch-dashboards image pull policy. This parameter is needed if *dashboards.service=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent | 
| **dashboards.hostname** | Dashboards hostname | dashboards |
| **dashboards.username** | Opensearch Dashboards username | "admin" |
| **dashboards.password** | Opensearch Dashboards password | "admin" |
| **logstash.service** | This parameter enables or disables devopsplan-logstash service. Accepted values are:<br>- *true* to enable Nginx service.<br>- *false* to disable devopsplan-logstash service.<br>This parameter is needed if you plan to use Dashboard features for Business Analytics. | true |
| **logstash.replicaCount** | Number of replica devopsplan-logstash pods. This parameter is needed if logstash.service *=true.* | 1 |
| **logstash.image.repository** | logstash docker Image repository path. This parameter is needed if logstash.service *=true.* | cp/devops-plan/devopsplan-logstash |
| **logstash.image.tag** | devopsplan-logstash Image tag. This parameter is needed if *logstas.service=true.* | 3.0.4 |
| **logstash.image.pullPolicy** | Opensearch-logstash image pull policy. This parameter is needed if *logstas.service=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent | 
| **logstash.port** | logstash port | 5011 |
| **logstash.username** | logstash username | "logstash" |
| **logstash.password** | logstash password | "logstash" |
| **opensearch.service** | This parameter enables or disables opensearch service. Accepted values are:<br>- *true* to enable Nginx service.<br>- *false* to disable opensearch service.<br>This parameter is needed if you plan to use Dashboard features for Business Analytics. | true |
| **opensearch.replicaCount** | Number of replica opensearch pods. This parameter is needed if opensearch.service *=true.* | 1 |
| **opensearch.image.repository** | Opensearch docker Image repository path. This parameter is needed if opensearch.service *=true.* | cp/devops-plan/devopsplan-opensearch |
| **opensearch.image.tag** | Opensearch Image tag. This parameter is needed if *opensearch.service=true.* | 3.0.4 |
| **opensearch.image.pullPolicy** | Opensearch image pull policy. This parameter is needed if *opensearch.service=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent | 
| **opensearch.hostname** | Opensearch hostname | opensearch |
| **opensearch.hash** | Opensearch password hash | "" |
| **opensearch.discoveryType** | Eleasticsearch discoveryType  | single-node |

### Single-Sign-On (Keycloak) functionality Parameters
Single-Sign-On functionality by default is set to disable. If the admin plans to enable the Single-Sign-On functionality, then it need to modify the default values as shown in the below table. Refer to [Enabling the DevOps Plan Keycloak Single Sign On feature]() for more information.

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **keycloak.enabled** | This parameter enables or disables Single-Sign-On (Keycloak)  service. Accepted values are:<br>- *true* to enable Single-Sign-On service.<br>- *false* to disable Single-Sign-On service.<br>This parameter is needed if you plan to use Single-Sign-On feature. | false |
| **keycloak.service.enabled** | This parameter enables or disables Keycloak service in Helm Chart for Single-Sign-On service. Accepted values are:<br>- *true* to enable Keycloak service.<br>- *false* to disable Keycloak service.<br>This parameter is needed if you plan to use Single-Sign-On feature and deploy Keycloak with Helm chart. | false |
| **keycloak.service.ipAddress** | Cluster IP address or Hostname. | "" |
| **keycloak.service.clientName  | The ccn-client Id. | "ccm-client" |
| **keycloak.username** | Keycloak Administration Console username. | admin |
| **keycloak.password** | Keycloak Administration Console password. | admin |
| **keycloak.realmName** | The Realm name. | "CCM" |
| **keycloak.dashboardsClientID** | The dashboards-client Id. | "dashboards-client" |
| **keycloak.dashboardsClientSecret** | The secret for the dashboards-client. | "58846041-eb1e-46d8-bac4-b2ba541ff491" |
| **keycloak.urlMapping** | Keycloak URL | "" |
| **keycloak.jsonFile.enabled** | Enable installing keycloak.json file to the DevOps Plan servers /config folder.  Accepted values are:<br>- *true* to enable installing keycloak.json file <br>- *false* to disable installing keycloak.json file. | false |
| **keycloak.jsonFile.configMapName** | This is the configMap file name that contains the keycloak.json file. This parameter is needed if keycloak.jsonFile.enabled *=true.* | keycloak-json |
| **keycloaksrv.enabled** | This parameter enables or disables Keycloak service in Helm Chart for Single-Sign-On service. Accepted values are:<br>- *true* to enable Keycloak service.<br>- *false* to disable Keycloak service.<br>This parameter is needed if you plan to use Single-Sign-On feature and deploy Keycloak with Helm chart. | false |
| **keycloaksrv.image.repository** | keycloak docker Image repository path. | devops-plan/devopsplan-keycloak |
| **keycloaksrv.image.tag** | Keycloak Image tag. | 3.0.4 |
| **keycloaksrv.image.pullPolicy** | Keycloak image pull policy. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent |
| **keycloaksrv.service.type** | Specify the nodePort values for the LoadBalancer and NodePort service types. | LoadBalancer |
| **keycloaksrv.service.nodePorts.http** | Keycloak service HTTP port. | 30107 |
| **keycloaksrv.service.nodePorts.https** | Keycloak service HTTPS port. | 30104 |
| **keycloaksrv.auth.adminUser** | Keycloak administrator user | admin |
| **keycloaksrv.auth.adminPassword** | Keycloak administrator password for the new user | "" |
| **keycloaksrv.postgresql.auth.postgresPassword** | Password for the "postgres" admin user. | "" |
| **keycloaksrv.postgresql.auth.password** | Password for the non-root username for Keycloak | "" |
| **keycloaksrv.keycloakConfigCli.backoffLimit** | Specifies the number of retries before considering the Job as failed | 1 |

### SSL Parameters
You need to set the ssl parameters  in order to install SSL certificates.

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **ssl.enabled** | Enable installing SSL certificate.Accepted values are:<br>- *true* to enable installing SSL certificate <br>- *false* to disable installing SSL certificate. | false |
| **ssl.password** | Keystore password. This parameter is needed if ssl.enabled *=true.* | "" |
| **ssl.keyAlias** | keystore alias. | 1 |
| **ssl.configMapName** | This is the configMap file name that contains the SSL certificate keystore.p12 file.This parameter is needed if ssl.enabled *=true.* | keystore-file |

### Liveness & Readiness Parameters

  - **ibm-devopsplan pod**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **probes.liveness.ccm.enabled** | Enable liveness probe | true |
| **probes.liveness.ccm.initialDelaySeconds** | Delay in seconds for initial liveness probe | 90 |
| **probes.liveness.ccm.periodSeconds** | Duration in seconds between liveness probes | 10 |
| **probes.liveness.ccm.timeoutSeconds** | Liveness probe timeout | 3 |
| **probes.liveness.ccm.successThreshold** | Liveness probe success threshold | 1 |
| **probes.liveness.ccm.failureThreshold** | Liveness probe failure threshold | 5  |
| **probes.readiness.ccm.enabled** | Enable readiness probe | true |
| **probes.readiness.ccm.initialDelaySeconds** | Delay in seconds for initial readiness probe | 90 |
| **probes.readiness.ccm.periodSeconds** | Duration in seconds between readiness probes | 60 |
| **probes.liveness.ccm.timeoutSeconds** | Readiness probe timeout | 3 |
| **probes.readiness.ccm.successThreshold** | Readiness probe success threshold | 1 |
| **probes.readiness.ccm.failureThreshold** | Readiness probe failure threshold | 3 |

  - **ibm-devopsplan-analytics pod**
  
| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **probes.liveness.analytics.enabled** | Enable liveness probe | true |
| **probes.liveness.analytics.initialDelaySeconds** | Delay in seconds for initial liveness probe | 90 |
| **probes.liveness.analytics.periodSeconds** | Duration in seconds between liveness probes | 10 |
| **probes.liveness.analytics.timeoutSeconds** | Liveness probe timeout | 3 |
| **probes.liveness.analytics.successThreshold** | Liveness probe success threshold | 1 |
| **probes.liveness.analytics.failureThreshold** | Liveness probe failure threshold | 5  |
| **probes.readiness.analytics.enabled** | Enable readiness probe | true |
| **probes.readiness.analytics.initialDelaySeconds** | Delay in seconds for initial readiness probe | 90 |
| **probes.readiness.analytics.periodSeconds** | Duration in seconds between readiness probes | 60 |
| **probes.liveness.analytics.timeoutSeconds** | Readiness probe timeout | 3 |
| **probes.readiness.analytics.successThreshold** | Readiness probe success threshold | 1 |
| **probes.readiness.analytics.failureThreshold** | Readiness probe failure threshold | 3 |

  - **devopsplan-postgresql pod**
  
| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **probes.liveness.postgresql.enabled** | Enable liveness probe | true |
| **probes.liveness.postgresql.initialDelaySeconds** | Delay in seconds for initial liveness probe | 30 |
| **probes.liveness.postgresql.periodSeconds** | Duration in seconds between liveness probes | 10 |
| **probes.liveness.postgresql.timeoutSeconds** | Liveness probe timeout | 5 |
| **probes.liveness.postgresql.successThreshold** | Liveness probe success threshold | 1 |
| **probes.liveness.postgresql.failureThreshold** | Liveness probe failure threshold | 6  |
| **probes.readiness.postgresql.enabled** | Enable readiness probe | true |
| **probes.readiness.postgresql.initialDelaySeconds** | Delay in seconds for initial readiness probe | 5 |
| **probes.readiness.postgresql.periodSeconds** | Duration in seconds between readiness probes | 10 |
| **probes.liveness.postgresql.timeoutSeconds** | Readiness probe timeout | 5 |
| **probes.readiness.postgresql.successThreshold** | Readiness probe success threshold | 1 |
| **probes.readiness.postgresql.failureThreshold** | Readiness probe failure threshold | 6 |

### Persistence Volumes Parameters
The helm chart set to enable by default the persistent volumes (PVs) and persistent volumes claims (PVCs) for following mounted pods:

  - **ibm-devopsplan pod: data, config, share and logs folders**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.enabled** | Enable persistence volume claim. Accepted values are:<br>- true to enable the persistence volume.<br>- false to disable the persistence volume.<br>This parameter is needed if you plan to enable/disable the persistence volume. | true |
| **persistence.ccm.enabled** | Enable persistence volume claim for DevOps Plan server pod container. Accepted values are:<br>- true to enable the persistence volume for DevOps Plan server pod container folders.<br>- false to disable the persistence volume for DevOps Plan server pod container folder.<br>This parameter is needed if you plan to enable/disable the persistence volume for DevOps Plan server container folder. | true |
| **persistence.ccm.data.enabled** | Enable persistence volume claim for DevOps Plan server container data folder. Accepted values are:<br>- true to enable the persistence volume for DevOps Plan server data folders.<br>- false to disable the persistence volume for DevOps Plan server data folders.<br>This parameter is needed if you plan to enable/disable the persistence volume for DevOps Plan server data folders. | true |
| **persistence.ccm.data.accessModes** | Persistence Volume access modes. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | ReadWriteOnce |
| **persistence.ccm.data.size** | Persistence Volume size. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | 2Gi |
| **persistence.ccm.data.reclaimPolicy** | Persistence Volume reclaim policy. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | Retain |
| **persistence.ccm.data.existingClaim** | Persistence Volume existing claim. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | "" |
| **persistence.ccm.config.enabled** | Enable persistence volume claim for DevOps Plan server container config folder. Accepted values are:<br>- true to enable the persistence volume for DevOps Plan server config folders.<br>- false to disable the persistence volume for DevOps Plan server config folders.<br>This parameter is needed if you plan to enable/disable the persistence volume for DevOps Plan server config folders. | true |
| **persistence.ccm.config.accessModes** | Persistence Volume access modes. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | ReadWriteOnce |
| **persistence.ccm.config.size** | Persistence Volume size. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | 2Gi |
| **persistence.ccm.config.reclaimPolicy** | Persistence Volume reclaim policy. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | Retain |
| **persistence.ccm.config.existingClaim** | Persistence Volume existing claim. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | "" |
| **persistence.ccm.logs.enabled** | Enable persistence volume claim for DevOps Plan server container logs folder. Accepted values are:<br>- true to enable the persistence volume for DevOps Plan server logs folders.<br>- false to disable the persistence volume for DevOps Plan server logs folders.<br>This parameter is needed if you plan to enable/disable the persistence volume for DevOps Plan server folders. | true |
| **persistence.ccm.logs.accessModes** | Persistence Volume access modes. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | ReadWriteOnce |
| **persistence.ccm.logs.size** | Persistence Volume size. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | 2Gi |
| **persistence.ccm.logs.reclaimPolicy** | Persistence Volume reclaim policy. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | Retain |
| **persistence.ccm.logs.existingClaim** | Persistence Volume existing claim. This parameter is needed if persistence.enabled =true and persistence.ccm.enabled=true. | "" |
| **persistence.annotations** | If defined, It sets the annotations for PVC. This parameter is needed if persistence.enabled =true. | "" |
| **persistence.properties.application.enabled** | Enable the application.properties configmap. If it is set to true, then it will update the values of the application.properties based on setting in the DevOps Plan server /config/application.properties file. Accepted values are:<br>- true to enable application.properties configmap and updating the application.properties values based on setting in the DevOps Plan server /config/application.properties file.<br>- false to disable the application.properties configmap. | false |
| **persistence.properties.analytics.enabled** | Enable the analytics.properties configmap. If it is set to true, then it will update the values of the analytics.properties based on setting in the DevOps Plan server /config/analytics.properties file. Accepted values are:<br>- true to enable analytics.properties configmap and updating the analytics.properties values based on setting in the DevOps Plan server /config/analytics.properties file.<br>- false to disable the analytics.properties configmap. | false |

  - **ibm-devopsplan-analytics pod: data, config, share and logs folders**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.analytics.enabled** | Enable persistence.analytics volume claim. Accepted values are:<br>- true to enable the persistence.analytics volume.<br>- false to disable the persistence.analytics volume.<br>This parameter is needed if you plan to enable/disable the persistence.analytics volume. | true |
| **persistence.analytics.data.enabled** | Enable persistence.analytics volume claim for devopsplan-analytics server container data folder. Accepted values are:<br>- true to enable the persistence.analytics volume for devopsplan-analytics server data folders.<br>- false to disable the persistence.analytics volume for devopsplan-analytics server data folders.<br>This parameter is needed if you plan to enable/disable the persistence.analytics volume for devopsplan-analytics server data folders. | true |
| **persistence.analytics.data.accessModes** | persistence.analytics Volume access modes. This parameter is needed if persistence.analytics.enabled =true. | ReadWriteOnce |
| **persistence.analytics.data.size** | persistence.analytics Volume size. This parameter is needed if persistence.analytics.enabled =true. | 2Gi |
| **persistence.analytics.data.reclaimPolicy** | persistence.analytics Volume reclaim policy. This parameter is needed if persistence.analytics.enabled =true. | Retain |
| **persistence.analytics.data.existingClaim** | persistence.analytics Volume existing claim. This parameter is needed if persistence.analytics.enabled =true. | "" |
| **persistence.analytics.config.enabled** | Enable persistence.analytics volume claim for devopsplan-analytics server container config folder. Accepted values are:<br>- true to enable the persistence.analytics volume for devopsplan-analytics server config folders.<br>- false to disable the persistence.analytics volume for devopsplan-analytics server config folders.<br>This parameter is needed if you plan to enable/disable the persistence.analytics volume for devopsplan-analytics server config folders. | true |
| **persistence.analytics.config.accessModes** | persistence.analytics Volume access modes. This parameter is needed if persistence.analytics.enabled =true. | ReadWriteOnce |
| **persistence.analytics.config.size** | persistence.analytics Volume size. This parameter is needed if persistence.analytics.enabled =true. | 2Gi |
| **persistence.analytics.config.reclaimPolicy** | persistence.analytics Volume reclaim policy. This parameter is needed if persistence.analytics.enabled =true. | Retain |
| **persistence.analytics.config.existingClaim** | persistence.analytics Volume existing claim. This parameter is needed if persistence.analytics.enabled =true. | "" |
| **persistence.analytics.logs.enabled** | Enable persistence.analytics volume claim for devopsplan-analytics server container logs folder. Accepted values are:<br>- true to enable the persistence.analytics volume for devopsplan-analytics server logs folders.<br>- false to disable the persistence.analytics volume for devopsplan-analytics server logs folders.<br>This parameter is needed if you plan to enable/disable the persistence.analytics volume for devopsplan-analytics server folders. | true |
| **persistence.analytics.logs.accessModes** | persistence.analytics Volume access modes. This parameter is needed if persistence.analytics.enabled =true. | ReadWriteOnce |
| **persistence.analytics.logs.size** | persistence.analytics Volume size. This parameter is needed if persistence.analytics.enabled =true. | 2Gi |
| **persistence.analytics.logs.reclaimPolicy** | persistence.analytics Volume reclaim policy. This parameter is needed if persistence.analytics.enabled =true. | Retain |
| **persistence.analytics.logs.existingClaim** | persistence.analytics Volume existing claim. This parameter is needed if persistence.analytics.enabled =true. | "" |

  - **devopsplan-postgresql pod: data folder**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.postgresql.enabled** | Enable persistence.postgresql volume claim for postgresql pod container data folder. Accepted values are:<br>- true to enable the persistence.postgresql volume for postgresql data folder.<br>- false to disable the persistence.postgresql volume for postgresql folder.<br>This parameter is needed if you plan to enable/disable the persistence.postgresql volume for postgresql folder. | true |
| **persistence.postgresql.accessModes** | persistence.postgresql Volume access modes. This parameter is needed if persistence.postgresql.enabled =true. | ReadWriteOnce |
| **persistence.postgresql.size** | persistence.postgresql Volume size. This parameter is needed if persistence.postgresql.enabled =true. | 2Gi |
| **persistence.postgresql.reclaimPolicy** | persistence.postgresql Volume reclaim policy. This parameter is needed if persistence.postgresql.enabled =true. | Retain |
| **persistence.postgresql.existingClaim** | persistence.postgresql Volume existing claim. This parameter is needed if persistence.postgresql.enabled =true. | "" |

  - **ibm-devopsplan-opensearch pod: data folder**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.opensearch.enabled** | Enable persistence volume claim for opensearch pod container data folder. Accepted values are:<br>- true to enable the persistence volume for opensearch data folder.<br>- false to disable the persistence volume for opensearch folder.<br>This parameter is needed if you plan to enable/disable the persistence volume for opensearch folder. | true |
| **persistence.opensearch.accessModes** | Persistence Volume access modes. This parameter is needed if persistence.enabled =true. | ReadWriteOnce |
| **persistence.opensearch.size** | Persistence Volume size. This parameter is needed if persistence.enabled =true. | 2Gi |
| **persistence.opensearch.reclaimPolicy** | Persistence Volume reclaim policy. This parameter is needed if persistence.enabled =true. | Retain |
| **persistence.opensearch.existingClaim** | Persistence Volume existing claim. This parameter is needed if persistence.enabled =true. | "" |

  - **devopsplan-kycloak pod: data folder**

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.keycloak.enabled** | Enable persistence volume claim for keycloak pod container data folder. Accepted values are:<br>- true to enable the persistence volume for keycloak data folder.<br>- false to disable the persistence volume for keycloak folder.<br>This parameter is needed if you plan to enable/disable the persistence volume for keycloak folder. | true |
| **persistence.keycloak.accessModes** | Persistence Volume access modes. This parameter is needed if persistence.enabled =true. | ReadWriteOnce |
| **persistence.keycloak.size** | Persistence Volume size. This parameter is needed if persistence.enabled =true. | 2Gi |
| **persistence.keycloak.reclaimPolicy** | Persistence Volume reclaim policy. This parameter is needed if persistence.enabled =true. | Retain |
| **persistence.keycloak.existingClaim** | Persistence Volume existing claim. This parameter is needed if persistence.enabled =true. | "" |

### Storage Class Parameters

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **persistence.storageClass** | If defined, It sets the global storageClassName. This parameter is needed if persistence.enabled =true and Storage Class will be used. | "" |
| **persistence.ccm.storageClass** | It sets the storageClassName for the devopsplan pods. This parameter is needed if the default storage class does not support the ReadWriteMany (RWX) accessMode. | ibmc-file-gold-gid |
| **persistence.analytics.storageClass** | It sets the storageClassName for the devopsplan-analytics PVC. | "" |
| **persistence.postgresql.storageClass** | It sets the storageClassName for the devopsplan-postgresql PVC. | "" |
| **persistence.opensearch.storageClass** | It sets the storageClassName for the devopsplan-opensearch PVC. | "" |
| **persistence.keycloak.storageClass** | It sets the storageClassName for the devopsplan-keycloak PVC. | "" |


## Mount Windows package into the DevOps Plan Server
The following steps describe how enabled/disabled mounting the windows product package in DevOps Plan Server.

| **Parameter** | **Description** | **Default value** |
| --- | --- | --- |
| **winInstall.enabled** | This parameter enables or disables mounting the windows product package in DevOps Plan Server. Accepted values are:<br>- *true* to enable mounting the windows product package.<br>- *false* to disable mounting the windows product package. | true |
| **winInstall.image.repository** | win-install docker Image repository path. This parameter is needed if *winInstall.enabled=true*. | ibm-devopsplan-win-install |
| **winInstall.image.tag** | win-install image tag. This parameter is needed if *winInstall.enabled=*true* | 3.0.4 |
| **winInstall.image.pullPolicy** | win-install image pull policy. This parameter is needed if *winInstall.enabled=true*. Accepted values are:<br>- *IfNotPresent*<br>- *Always* | IfNotPresent |
| **winInstall.accessModes** | win-install persistence Volume access modes. This parameter is needed if *winInstall.enabled=rtue*. | ReadWriteOnce |
| **winInstall.size** | win-install persistence Volume size. This parameter is needed if *winInstall.enabled=true*. | 2Gi |
| **winInstall.reclaimPolicy** | win-install persistence Volume reclaim policy. This parameter is needed if *winInstall.enabled=true*. | Retain |
| **winInstall.existingClaim** | win-install persistence Volume existing claim. | "" |

   **Note:** The helm chart by default sets the persistent volume. If your Kubernetes environment does not provide with default StorageClass, then you need to create your own default StorageClass and set the StorageClass name to *persistence.storageClass*. Otherwise, you need to set *persistence.enabled=false*.

## Troubleshooting

### keycloak-config-cli Job Failure (Error Status)

The keycloak-config-cli Pod shows a status of Error, and the Job fails without applying the Keycloak configuration.

**Possible Cause**

The keycloak-config-cli Job may be starting before the Keycloak server is fully ready, resulting in a connection failure. Kubernetes will only retry the Job up to the number of times defined by backoffLimit. If the retry limit is too low, the Job may fail permanently before Keycloak becomes available. 

**Recommended Action: Increase backoffLimit**

By default, the backoffLimit set to 1. You can increase to 5:

- Option 1: Modify values.yaml

  ```bash
  keycloaksrv:
    keycloakConfigCli:
      backoffLimit: 5  # Try 5 retries instead of the default (usually 1)
  ```

- Option 2: Use --set flags with Helm

  ```bash
  --set keycloaksrv.keycloakConfigCli.backoffLimit=5
  ```

## **Additional Information**

<details><summary>Downloads and Useful Links</summary>
<p>

- [DevOps Plan](https://ibm.com/docs/en/devops-plan/3.0.4)
- [Getting started with DevOps Plan Helm Chart](https://www.ibm.com/docs/en/devops-plan/3.0.4?topic=plan-getting-started-devops-helm-chart-openshift)

</p>
</details>

<details><summary>Supported Environments</summary>
<p>

The helm chart was tested in Kubernetes environments:

  - [Red Hat OpenShift on IBM Cloud](https://cloud.ibm.com/docs/openshift)
  - [K8s](https://kubernetes.io/)

Supported Kubernetes Versions:

  - Kubernetes 1.16 and later

</p>
</details>
