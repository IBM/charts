# Jenkins

[Jenkins](https://jenkins.io/) is the leading open source automation server. Jenkins provides hundreds of plugins to support building, deploying and automating any project.

## Introduction

This chart bootstraps a [Jenkins](https://jenkins.io/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager. The Jenkins [Kubernetes Plugin](https://wiki.jenkins.io/display/JENKINS/Kubernetes+Plugin) is used to provision pods with Jenkins agents on them to perform work.

## Prerequisites

- Kubernetes 1.7 or later
- Tiller 2.6.0 or later
- To persist data, a PersistentVolume needs to be pre-created prior to installing the chart if `persistance.enabled=true` and `persistence.dynamicProvisioning=false` (default values, see [persistence](#persistence) section). It can be created by using the IBM Cloud Private UI or with the CLI. Create a `pv.yaml` file with the following content:
  ```bash
  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: my-release-jenkins
  spec:
    accessModes:
      - ReadWriteOnce
    capacity:
      storage: 1Gi
    hostPath:
      path: /var/data/my-release-jenkins
  ```
  From shell, run the following:
  ```bash
  $ kubectl create -f pv.yaml
  ```

## Installing the Chart

> This deploys Jenkins on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release stable/ibm-jenkins-dev
```

After the command runs, it will print the current status of the release and extra information such as how to access the RabbitMQ admin console with a browser. You can also access the admin console through the IBM Cloud Private UI:
1. From Menu navigate to **Workloads -> Deployments**
2. Click the deployment. The default from above is `my-release`
3. Click on Endpoint **"access http"**

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete --purge my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. It will delete Persistent Volume Claims but not Persistent Volumes.

## RBAC

If running upon a cluster with RBAC enabled you will need to do the following:

* Create the release with RBAC enabled: `helm install -n my-release stable/ibm-jenkins-dev --set rbac.install=true`
* In the Jenkins UI, create a Jenkins credential of type Kubernetes service account with service account name provided in the `helm status` output.
* In the Jenkins UI, go to Configure Jenkins and update the credentials config in the cloud section to use the service account credential you created in the step above.

## Configuration

The following tables lists the configurable parameters of the Jenkins chart and their default values.

|         Parameter          |                       Description                       |                         Default                          |
|----------------------------|---------------------------------------------------------|----------------------------------------------------------|
| `arch`                     | Architecture to run on                                  | `amd64`                                                  |
| `master.name`              | Component name used to label the Kubernetes resources   | `jenkins-master`                                         |
| `master.image.repository`  | Jenkins master image                                    | `ibmcom/cfc-jenkins-master`                              |
| `master.image.tag`         | Jenkins master image tag                                | `2.19.4-1.1`                                             |
| `master.image.pullPolicy`  | Image pull policy                                       | `Always` if `tag` is `latest`, else `IfNotPresent`.      |
| `master.adminUser`         | Jenkins default username                                | `admin`                                                  |
| `master.adminPassword`     | Jenkins default user password                           | `admin`                                                  |
| `master.service.name`      | Kubernetes service name                                 | `http`                                                   |
| `master.service.type`      | Kubernetes service type                                 | `NodePort`                                               |
| `master.service.internalPort` | Jenkins UI port                                      | `8080`                                                   |
| `master.service.externalPort` | Jenkins UI exposed port                              | `8080`                                                   |
| `master.agentListenerPort` | Jenkins agent listener port                             | `50000`                                                  |
| `master.resourceConstraints.enabled` | Enable resource constraints on the Jenkins master | `false`                                              |
| `master.resources.requests.cpu`    | Requested CPU                                   | `500m`                                                   |
| `master.resources.requests.memory` | Requested memory                                | `512Mi`                                                  |
| `master.resources.limits.cpu`      | CPU limit                                       | `500m`                                                   |
| `master.resources.limits.memory`   | Memory limit                                    | `512Mi`                                                  |
| `agent.image.repository`   | Jenkins agent image                                     | `ibmcom/cfc-jenkinsci-jnlp-slave`                        |
| `agent.image.tag`          | Jenkins agent image tag                                 | `2.52-2.1`                                               |
| `agent.resourceConstraints.enabled` | Enable resource constraints on the Jenkins agents | `false`                                               |
| `agent.resources.requests.cpu` | Requested CPU                                       | `200m`                                                   |
| `agent.resources.requests.memory` | Requested memory                                 | `256Mi`                                                  |
| `agent.resources.limits.cpu` | CPU limit                                             | `200m`                                                   |
| `agent.resources.limits.memory` | Memory limit                                       | `256Mi`                                                  |
| `persistence.enabled`      | Use a PVC to persist data                               | `true`                                                   |
| `persistence.useDynamicProvisioning` | Use dynamic provisioning                      | `false`                                                  |
| `homePVC.name`             | Name of the Persistent Volume Claim to create           | `jenkins-home-pvc`                                       |
| `homePVC.selector.label`   | Field to select the volume                              |                                                          |
| `homePVC.selector.value`   | Value of the field to select the volume                 |                                                          |
| `homePVC.storageClassName` | Storage class for dynamic provisioning                  |                                                          |
| `homePVC.existingClaimName`| Use an existing PVC to persist data                     |                                                          |
| `homePVC.accessMode`       | Use volume as ReadOnly or ReadWrite                     | `ReadWriteOnce`                                          |
| `homePVC.size`             | Size of data volume                                     | `1Gi`                                                    |
| `rbac.install`            | Install RBAC. Set to 'true' if using a namespace with RBAC. | `true`                                                |
| `rbac.serviceAccountName` | The name of an existing ClusterRoleBinding to use if not installing | `default`                                     |
| `rbac.apiVersion`         | Kubernetes RBAC API version (currently either v1beta1 or v1alpha1) | `v1beta1`                                      |
| `rbac.roleRef`            | Cluster role reference.                                  | `cluster-admin`                                          |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```bash
$ helm install --name my-release \
  --set master.adminPassword=itsasecret \
    stable/ibm-jenkins-dev
```

The above command sets the Jenkins admin password to `itsasecret`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/ibm-jenkins-dev
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

The image stores the Jenkins data and configurations at the `/var/jenkins_home` path of the container.

The chart mounts a [Persistent Volume](kubernetes.io/docs/user-guide/persistent-volumes/) volume at this location. By default, you must create the persistent volume ahead of time as shown in step 1 of the Installing the Chart section above. If you have dynamic provisioning set up, you can install the helm chart with persistence.useDynamicProvisioning=true. An existing PersistentVolumeClaim can also be defined.

### Using Existing PersistentVolumeClaims

1. Create the PersistentVolume
2. Create the PersistentVolumeClaim
3. Install the chart:
    ```bash
    $ helm install --set homePVC.existingClaimName=PVC_NAME stable/ibm-jenkins-dev
    ```

## Copyright
© Copyright IBM Corporation 2018. All Rights Reserved.