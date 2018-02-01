This repository is the home directory of IBM Operational Decision Manager for Developers Helm chart, where you can find early access material for this program.

# ODM for developers Helm chart (ibm-odm-dev)(Beta Version)

The [IBM® Operational Decision Manager](https://www.ibm.com/hr-en/marketplace/operational-decision-management) (ODM) chart (`ibm-odm-dev`) is used to deploy a cluster for evaluation purposes on IBM Cloud Private or other Kubernetes environments.

## Introduction

ODM is a tool for capturing, automating, and governing repeatable business decisions. You identify situations about your business and then automate the actions to take as a result of the insight you gained about your policies and customers. For more information, see [ODM in knowledge center](https://www.ibm.com/support/knowledgecenter/SSQP76_8.9.2/welcome/kc_welcome_odmV.html).

The `ibm-odm-dev` chart bootstraps a deployment of ODM on a Kubernetes cluster by using the Helm package manager.

The following options are supported for ODM persistence:

- H2 as an internal database. This is the **default** option.
- PostgreSQL as an external database. Before you select this option, you must have an external PostgreSQL database up and running.

## Prerequisites

- Kubernetes 1.7.5+ with beta APIs enabled.
- Persistent Volume (PV) provisioner support in the underlying infrastructure. A PV in Kubernetes represents an underlying storage capacity in the infrastructure. PV must be created with accessMode ReadWriteOnce and storage capacity of 2Gi or more. You create a persistent volume in the IBM Cloud Private interface or with a .yaml file.

## Installing ODM releases

A release must be configured before it is installed. For information about the parameters to configure ODM for installation, see [Configuration parameters](#configuration-parameters). Click **Configure**, enter the parameter values in the deployment configuration, and then click **Install**.

A release can also be installed from the Helm command-line. To install a release with the default configuration and a release name of `my-odm-dev-release`, use the following command:

```console
$ helm install --name my-odm-dev-release stable/ibm-odm-dev
```

> **Tip**: List all existing releases with the `helm list` command.

Using Helm, you specify each parameter with a `--set key=value` argument in the `helm install` command.
For example:

```console
$ helm install --name my-odm-dev-release --set internalDatabase.databaseName=my-db --set internalDatabase.user=my-user --set internalDatabase.password=my-password stable/ibm-odm-dev
```

It is also possible to use a custom-made .yaml file to specify the values of the parameters when you install the chart.
For example:

```console
$ helm install --name my-odm-dev-release -f values.yaml stable/ibm-odm-dev
```

> **Tip**: The default values are in the `values.yaml` file of the `ibm-odm-dev` chart.

If the Docker images are pulled from a private registry, you must [specify an image pull secret](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

1. [Create an image pull secret](https://kubernetes.io/docs/concepts/containers/images/#creating-a-secret-with-a-docker-config) in the namespace. For information about setting an appropriate secret, see the documentation of your image registry.

2. To set the secret in the `values.yaml` file, add the SECRET_NAME to the `pullSecrets` parameter.

   ```yaml
   image:
     pullSecrets: SECRET_NAME
   ```
   To install the chart from the Helm command line, add the `--set image.pullSecrets` parameter.

   ```console
   $ helm install --name my-odm-dev-release --set image.pullSecrets=admin.registryKey --set image.repository=mycluster.icp:8500/ibmcom stable/ibm-odm-dev
   ```

## Uninstalling ODM releases

To uninstall and delete a release with a name `my-odm-dev-release`, use the following command:

```console
$ helm delete my-odm-dev-release
```

The command removes all of the Kubernetes components that are associated with the chart, and deletes the release.

## Configuration parameters

The following table shows the available parameters to configure the `ibm-odm-dev` chart.

| Parameter                                   | Description                             | Default value                                   |
| ------------------------------------------- | --------------------------------------- | ----------------------------------------------- |
| `decisionCenter.persistenceLocale`   | The persistence locale for Decision Center. This parameter is not taken into account when the database contains some sample data. | `en_US` |
| `externalDatabase.databaseName`             | The name of the external database used for ODM | `""` (empty) |
| `externalDatabase.password`                 | The password of the user used to connect to the external database | `""` (empty) |
| `externalDatabase.port`                     | The port used to connect to the external database | `5432` |
| `externalDatabase.serverName`               | The name of the server running the database used for ODM. Only PostgreSQL is supported as external database. | `""` (empty) |
| `externalDatabase.user`                     | The name of the user used to connect to the external database | `""` (empty) |
| `image.pullPolicy`                          | The image pull policy         | `IfNotPresent`                                  |
| `image.pullSecrets`                         | The image pull secrets        | `nil` (does not add image pull secrets to deployed pods) |
| `image.repository`                          | The repository                | `ibmcom`                                        |
| `image.tag`                                 | The image tag version                   | `8.9.2`                                         |
| `internalDatabase.persistence.enabled`      | To use a Persistent Volume Claim (PVC) to persist data | `true` |
| `internalDatabase.persistence.useDynamicProvisioning` | To use dynamic provisioning for Persistent Volume Claim. If this parameter is set to `false`, the Kubernetes binding process selects a pre-existing volume. Ensure, in this case, that there is a remaining volume that is not already bound before installing the chart. | `false` |
| `internalDatabase.persistence.storageClassName`       | The storage class name for Persistent Volume  | `""` (empty) |
| `internalDatabase.persistence.resources` | The requested storage size for Persistent Volume | `requests`: `storage` `2Gi`  |
| `internalDatabase.populateSampleData`       | To use a H2 database containing some sample data or not. If it is set to `true`, the database contains some sample data and uses `en_US` as persistence locale for Decision Center. | `true` |
| `resources`                                 | The CPU/Memory resource requests/limits     | `requests`: `cpu` `1`, `memory` `1024Mi`; `limits`: `cpu` `2`, `memory` `2048Mi` |
| `service.type`                              | The Kubernetes Service type   | `NodePort`                                   |
