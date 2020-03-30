# IBM Cloud Pak for Integration Asset Repository

## Introduction

IBM Cloud Pak for Integration Asset Repository is an add-on to the IBM Cloud Pak for Integration (ICP4I) that allows the user to store, manage, retrieve and search integration assets within the IBM Cloud Pak for Integration and its capabilities.

Users of the Cloud Pak are able to utilise the Asset Repository to share integration assets across the platform capabilities. Storing assets, e.g. JSON schemas, within this repository allows them to be accessed directly within the user interface of certain Integration capabilities. For example, an OpenAPI specification asset stored in the repository can be directly imported within the IBM API Connect user interface. 

The installation of the ICP4I Asset Repository is carried out through the ICP4I Navigator. See the IBM Cloud Pak for Integration Knowledge Center for details on how to perform this install.

## Chart Details
This is a Helm chart for the IBM Cloud Pak for Integration Asset Repository. It provides the ability to centrally store and manage integration assets across the platform capabilities.

## Prerequisites
* OpenShift 4.2 or 4.3 with Kubernetes 1.14 or greater, with beta APIs enabled
* A user with cluster administrator role is required to install the chart.
* A storage provider that supports Read Write Many (RWX) persistent volumes


### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster-scoped, as well as namespace-scoped, pre- and post-actions that need to occur.

The predefined SecurityContextConstraints [`privileged`](https://ibm.biz/cpkspec-scc) has been verified for this chart; if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

Run the following command to add the service account of the Integration server to the privileged scc:

```
oc adm policy add-scc-to-group privileged system:serviceaccounts:<namespace>
```

Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-asset-repo-scc
spec:
  allowHostNetwork: true
  allowHostPorts: true
  allowHostPID: true
  allowHostIPC: true
  allowPrivileged: true
  allowPrivilegeEscalation: true
  allowedCapabilities:
  - '*'
  allowedUnsafeSysctls:
  - '*'
  defaultCapabilities: null
  fsGroup:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  runAsUser:
    rule: RunAsAny
  priority: null
  readOnlyRootFilesystem: false
  requiredDropCapabilities: null
  seccompProfiles:
  - '*'
  volumes:
  - '*'
```
## Resources Required
This chart deploys in a HA configuration by default which has the following resource requirements:
* 4.25 CPUs
* 8.5 GB Memory

The number of replicas for certain components can be configured during install which would alter these requirements.

## Installing the Chart

**Important:** If you are using a private Docker registry (including an ICP Docker registry), an [image pull secret](https://docs.openshift.com/container-platform/4.2/openshift_images/managing-images/using-image-pull-secrets.html) needs to be created before installing the chart. Supply the name of the secret as the value for `image.pullSecret`.

**Limitation:** The current version of this chart only supports Helm release names of 28 characters or less. The Helm release name must not exceed 28 characters.

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --namespace <your pre-created namespace> --name my-release stable/ibm-icp4i-asset-repo-prod
```

The command deploys `ibm-icp4i-asset-repo-prod` on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the ICP4I Asset Repository chart and their default values.

| Parameter                                                                     | Description                                       | Default                      |
| ----------------------------------------------------------------------------- | --------------------------------------------------| -----------------------------|
| `arch`                                                                        | Architecture scheduling preference                | `amd64`                      |
| `global.images.pullSecret`                                                    | Pull secret for registry containing chart images  | ``                           |
| `global.images.registry`                                                      | Registry containing chart images                  | ``                           |
| `global.images.pullPolicy`                                                    | Image pull policy for chart images                | `IfNotPresent`               |
| `couchdb.persistentVolume.storageClass`                                       | Storage class for the CouchDB metadata store      | ``                           |
| `couchdb.replicas`                                                            | Number of replicas for the CouchDB metadata store | `3`                          |
| `prereqs.redis-ha.replicas.servers`                                           | Redis server replicas                             | `3`                          |
| `prereqs.redis-ha.replicas.sentinels`                                         | Redis sentinel replicas                           | `3`                          |
| `couchdb.persistentVolume.size`                                               | CouchDB metadata store size                       | `1Gi`                        |
| `couchdb.dns.clusterDomainSuffix`                                             | Cluster DNS subdomain for CouchDB                 | `cluster.local`              |
| `assetUI.replicas`                                                            | Asset repository UI replicas                      | `3`                          |
| `assetSync.replicaCount`                                                      | Asset remotes replicas                            | `3`                          |
| `assetSync.storageClassName`                                                  | Asset remotes storage class                       | ``                           |
| `assetSync.storage`                                                           | Asset remotes size                                | `2Gi`                        |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.


## Storage
* Storage is required by the microservices installed by this chart.
* The following file systems are supported: 
 - A RWX file system for asset storage and asset remote storage 
 - A RWO file system or block storage for CouchDB metadata storage

## Limitations
* Chart can only run on amd64 architecture type.

## Documentation
[IBM Cloud Pak for Integration Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSGT7J/welcome.html)

_Copyright IBM Corporation 2019. All Rights Reserved._
