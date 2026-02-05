# Name

IBM&reg; MQ

# Introduction

## Summary

[IBM MQ](https://www.ibm.com/products/mq) is messaging middleware that simplifies and accelerates
the integration of diverse applications and business data across multiple platforms.
It uses message queues to facilitate the exchanges of information and offers
a single messaging solution for cloud, mobile, Internet of Things (IoT) and on-premises
environments.

The IBM MQ Operator for Amazon Elastic Kubernetes Service (Amazon EKS) provides
an easy way to manage the life cycle of IBM MQ queue managers.

# Chart Details

This chart deploys an IBM MQ Operator Deployment. The QueueManager CRD will be deployed from this
chart, if and only if, a version of it does not already exist in the cluster. The IBM MQ Operator
needs to be installed by a cluster administrator.

## Prerequisites

* Helm v3 or v4
* Amazon EKS cluster versions 1.29 onwards
* If persistence is enabled you need to ensure a Storage Class is defined in your cluster

### Resources Required

* The IBM MQ Operator deploys by default with 1 CPU core and 1 GB memory. It has not been tested with fewer resources, but may still work.
* Each IBM MQ Queue Manager defaults to 1 CPU core and 1 GB memory, but can be run with fewer resources with lower performance
* The IBM Licensing Operator needs to be [installed separately](https://www.ibm.com/docs/en/cloud-paks/cp-integration/latest?topic=administration-deploying-license-service)

## Installing the Chart

See [Installing and uninstalling the IBM MQ Operator on Amazon EKS](https://ibm.biz/BdbUmT)

## Chart Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| operator.env | object | `{}` | Environment variables to pass to the IBM MQ Operator  (e.g. `{env1: "value1",env2: "value2"}`) |
| operator.deployment.repository | string | `"cpopen/ibm-mq-operator"` | Remote repository for the IBM MQ Operator image |
| operator.deployment.sha | string | `"sha256:68b733aecb0a3a447d4853a2394f06655f4cacc59401e3e6ddf340de2017523e"` | SHA value of the IBM MQ Operator image |
| operator.deployment.tag | string | `nil` | Tag value for the IBM MQ Operator image (`optional - ignored when a SHA value is provided`) |
| operator.deployment.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the IBM MQ Operator (`"IfNotPresent"`/ `"Always"` / `"Never"`)) |
| operator.deployment.resources.requests.cpu | string | `"1"` | CPU requests setting for the IBM MQ Operator |
| operator.deployment.resources.requests.memory | string | `"1Gi"` | Memory requests setting for the IBM MQ Operator |
| operator.deployment.resources.limits.cpu | string | `"1"` | CPU limits setting for the IBM MQ Operator |
| operator.deployment.resources.limits.memory | string | `"1Gi"` | Memory limits setting for the IBM MQ Operator |
| operator.installMode | string | `"OwnNamespace"` | Install mode for the IBM MQ Operator to determine at what scope it operates (`"OwnNamespace"` / `"AllNamespaces"`) |
| operator.imagePullSecrets | list | `[]` | Image pull secrets for the IBM MQ Operator to allow pulling from authenticated registries (e.g. `["secret1","secret2"]`) |
| operand.repositories.integration | string | `"cp/ibm-mqadvanced-server-integration"` | Remote repository for the IBM MQ integration queue manager image |
| operand.repositories.production | string | `"cp/ibm-mqadvanced-server"` | Remote repository for the IBM MQ production queue manager image |
| operand.repositories.developer | string | `"ibm-messaging/mq"` | Remote repository for the IBM MQ developer queue manager image |
| privateRegistry | string | `""` | Private registry allowing pulling of IBM MQ Operator and Queue Manager images from an alternative private registry |

## Deploying an IBM MQ Queue Manager

### Prerequisites

The IBM MQ Operator deploys queue manager images that are pulled from a container registry that performs a license entitlement check. Follow [these instructions](https://www.ibm.com/docs/en/ibm-mq/9.4.x?topic=upgrading-preparing-use-kubernetes-by-creating-pull-secret) to get an entitlement key and create a pull secret.

> **Note**: The entitlement key is not required if only IBM MQ Advanced for Developers (Non-Warranted) queue managers are going to be deployed.

### Creating an IBM MQ Queue Manager

To deploy a queue manager, see [Deploying and configuring queue managers using the IBM MQ Operator](https://www.ibm.com/docs/en/ibm-mq/9.4.x?topic=configuring-deploying-queue-managers-using-mq-operator).  Queue managers can be installed by a namespace administrator.

**Important:** When deploying an IBM MQ queue manager on Amazon Elastic Kubernetes Service (Amazon EKS), all Red Hat OpenShift Container Platform features **MUST** be explicitly disabled as follows:

```
# QueueManager YAML snippet
...
spec:
  queueManager:
    ...
    route:
      enabled: false
    metrics:
      serviceMonitor:
        enabled: false
  web:
    ...
    route:
      enabled: false
```

### Upgrading an IBM MQ Queue Manager

To upgrade an installed and running queue manager, update the following field of the Queue Manager YAML:
- `spec.version`

For some upgrades, you may also need to update the license:
- `spec.license.license`

See [Current license versions](https://www.ibm.com/docs/en/ibm-mq/9.4.x?topic=reference-licensing-api-references-mq-operator) for more details.

To upgrade, update the field(s) in the Queue Manager yaml by, for example, running: 

```
kubectl edit queuemanager <Queue Manager's metadata.name> -n <namespace>
```

## Storage

MQ is configured to use dynamic provisioning of ReadWriteOnce (RWO) Persistent Volumes (typically block storage) when using MQ Native HA or single instances.

MQ can optionally be configured to use dynamic provisioning of ReadWriteMany (RWX) Persistent Volumes, which use a shared filesystem, when using multi-instance queue managers. In this case, MQ is affected by other limits applied to the file system (such as limiting the number of file locks in AWS EFS). See [testing statement](https://www.ibm.com/support/pages/testing-statement-ibm-mq-multi-instance-queue-manager-file-systems).

## Limitations

* Works only on the `amd64`, `s390x` & `ppc64le` CPU architectures. All Nodes in the cluster must use the same CPU architecture.
* Do not edit the availability type of a QueueManager after initial creation
* Do not edit the storage settings of a QueueManager after initial creation
* The following alpha and beta APIs and features are used by the MQ operator:
  * `operator.ibm.com/v1alpha1` for installation of additional IBM common operators

## Documentation

* [IBM MQ Documentation](https://ibm.biz/BdPZqj)
* [License reference for mq.ibm.com/v1beta1](https://ibm.biz/Bdm9be)
