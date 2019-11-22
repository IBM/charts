# IBM Agile Lifecycle Manager

## Introduction
[IBM Agile Lifecycle Manager](https://www.ibm.com/marketplace/agile-lifecycle-manager) (ALM) provides users with a toolkit to manage the lifecycle of both virtual and physical network services. This includes the design, test, deployment, monitoring and healing of services. Agile Lifecycle Manager lets you design and integrate external resources into virtual production environments and then automate the management of end-to-end lifecycle processes.

## Chart Details
This chart will deploy the ALM application into your cluster, and includes:
* Cassandra, Elasticsearch, Kafka and Zookeeper are deployed as StatefulSet objects.
* Apollo, Conductor, Daytona, Galileo, Ishtar, Nimrod, Talledega and Watchtower make up the core ALM components.
* Vault is deployed for secure storage of secrets and configuration.
* (Optional) OpenLDAP can be installed to store user credentials.
* Secrets can be pre-created, or some defaults will be generated

## Prerequisites
* Kubernetes v1.12.4+
* A minimum of three worker nodes with adequate storage volumes
* Some kernel parameters will need tuning on each worker node
* Each worker node must have a minimum of 16 cpu, 32Gi memory and 500Gi storage
* (Optional) Provide your own secrets for certificates, credentials and LDAP configuration

### PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

  ```yaml
  apiVersion: extensions/v1beta1
  kind: PodSecurityPolicy
  metadata:
    annotations:
      kubernetes.io/description: "This policy defines the minimum security settings required to run IBM Agile Lifecycle Manager."
    name: ibm-alm-prod-psp
  spec:
    allowPrivilegeEscalation: true
    forbiddenSysctls:
    - '*'
    fsGroup:
      ranges:
      - max: 65535
        min: 1
      rule: MustRunAs
    requiredDropCapabilities:
    - ALL
    allowedCapabilities:
    - SETGID
    - SETUID
    - AUDIT_WRITE
    - DAC_OVERRIDE
    - NET_BIND_SERVICE
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
  ```

* Custom ClusterRole for the custom PodSecurityPolicy:

    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-alm-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-alm-prod-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```

#### Prereq configuration scripts can be used to create and delete required resources:
Find the following scripts in `ibm_cloud_pak/pak_extensions/prereqs` directory of the downloaded archive.

##### createSecurityClusterPrereqs.sh
This script can be used to create the PodSecurityPolicy and ClusterRole for all releases of this chart.
```
./createSecurityClusterPrereqs.sh
```

##### deleteSecurityClusterPrereqs.sh
This script can be used to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
```
./deleteSecurityClusterPrereqs.sh
```

##### createSecurityNamespacePrereqs.sh
This script can be used to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed. Example usage:
```
./createSecurityNamespacePrereqs.sh myNamespace
```

##### deleteSecurityNamespacePrereqs.sh
This script can be used to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed. Example usage:
```
./deleteSecurityNamespacePrereqs.sh myNamespace
```

##### createStorageVolumes.sh
This script can be used to create the required storage volumes for a single deployment of the chart.
Before running the script you must add the required configuration to `storageConfig.env`. You need
to specify the worker nodes, disk locations and capacity per service e.g.
```
WORKER1=172.99.0.1
WORKER2=172.99.0.2
WORKER3=172.99.0.3
FS_ROOT=/opt/ibm/alm
CAPACITY_CASSANDRA=130
CAPACITY_KAFKA=295
CAPACITY_ELASTICSEARCH=50
CAPACITY_ZOOKEEPER=25
```
The script takes two arguments;  the namespace where the chart will be installed, and the release name
that will be used for the install. Example usage:
```
./createStorageVolumes.sh myNamespace myReleaseName
```
**You need to make sure the disk locations exist before the volumes can be used.**

##### deleteStorageVolumes.sh
This script can be used to remove the persistent storage volumes and claims for a release, once you
have uninstalled. The script takes one argument; the release name that has been uninstalled.
Example usage:
```
./deleteStorageVolumes.sh myReleaseName
```
**You need to manually clean the data from the worker nodes**

##### createSecrets.sh
This step is optional. This script can be used to generate your own secrets for ALM if you wish.
If you do not generate your own secrets, the installation will generate the secrets for you.
This script requires:
* openssl
* keytool

The script takes two arguments; the namespace where the chart will be installed, and the release name
that will be used for the install. Example usage:
```
./createSecrets.sh myNamespace myReleaseName
```
The script will output the names of the secrets that can be used for a subsequent install.

##### deleteSecrets.sh
This script can be used to remove the secrets generated by `createSecrets.sh`, once you
have uninstalled. The script takes two arguments; the namespace where the chart was installed,
and the release name that has been uninstalled. Example usage:
```
./deleteSecrets.sh myNamespace myReleaseName
```

## Resources Required
* A minimal production deployment requires 3 workers, each of which has 24 cores, 32GB of RAM and 500GB storage

## Installing the Chart
Here is an example command for installing the ALM chart into a namespace called `lifecycle-manager` with a release name of `alm`:
```bash
$ helm install --name alm --namespace lifecycle-manager ibm-alm-prod-2.0.0.tgz --tls
```

#### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions.
* From the ICP UI you can view the NOTES from `Workloads > Helm Releases` then open the release, e.g. `alm`
* From the command line you can also re-view the NOTES with `helm status alm --tls` where `alm` is the release name.



#### Uninstalling the Chart
To delete the release, use the `helm delete <name> --tls` command. For example:
```bash
$ helm delete alm --tls
```
The command removes all the Kubernetes components associated with the chart and deletes the release.  
Note: You can use the `--purge` option to remove the release from the store and make its name free for later use.

If persistence was enabled you will need to remove the persistent storage volumes and claims. Please refer to the `deleteStorageVolumes.sh` script above.



## Configuration
This table summarises the configuration options available when installing the chart:

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| global.image.repository | The location of the ALM images (should be auto completed) |   
| global.ingress.domain | Optional hostname to bind to the ingress rules, which must resolve to a proxy node. Multiple deployments of this chart will need to specify different values. |  |
| global.ingress.tlsSecret | Optional TLS secret for the ingress hostname. |  |
| global.persistence.enabled | Option to disable the requests for PersistentVolumes, for test and demo only. | true
| global.persistence.storageSize.cassandradata | Option to configure the requested amount of storage for Cassandra | 130Gi
| global.persistence.storageSize.kafkadata | Option to configure the requested amount of storage for Kafka | 295Gi
| global.persistence.storageSize.zookeeperdata | Option to configure the requested amount of storage for Zookeeper | 25Gi
| global.persistence.storageSize.elasticdata | Option to configure the requested amount of storage for Elasticsearch | 50Gi
| global.environmentSize | 'size0' requests fewer resources and is suitable for test and demo. Choose 'size1' for a production deployment. | size1
| global.security.almCerts.secretName | Name of a pre-created secret containing the ALM certificates. | |
| global.security.almCredentials.secretName | Name of a pre-created secret containing the ALM credentials. | |
| global.security.ldapConfig.secretName | Name of a pre-created secret containing the LDAP configuration for connecting to an existing LDAP service. | |
| global.security.vaultCerts.secretName | Name of a pre-created secret containing the Vault certificates. | |



Further configuration options are covered in the [IBM Agile Lifecycle Manager Knowledge Center](https://www.ibm.com/support/knowledgecenter/SS8HQ3_2.0.0/Installing/t_alm_icp_configuring.html)

## Storage
It is recommended to use [local storage](https://kubernetes.io/docs/concepts/storage/volumes/#local) volumes for the ALM StatefulSet applications. Dynamic provisioning is not yet supported for local volumes, and so these volumes must be created before installing ALM. There are some scripts provided to assist the cluster administrator.

Please see the Knowledge Center topic on [creating persistent volumes](https://www.ibm.com/support/knowledgecenter/SS8HQ3_2.0.0/Installing/c_alm_icp_preinstall.html)

## Limitations
* This chart must be installed by a team administrator
* You can only deploy a single instance per namespace
* This chart only supports the amd64 architecture
* This chart requires IBM Cloud Private version 3.1.2 or later
* If you want to ensure all data in motion is encrypted, then IPsec needs to be enabled in the cluster.

## Documentation
For more information, see the [IBM Agile Lifecycle Manager Knowledge Center](https://www.ibm.com/support/knowledgecenter/SS8HQ3_2.0.0/welcome_page/kc_welcome-444.html)
