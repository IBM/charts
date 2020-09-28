# Introduction

Kubernetes ArangoDB Operator.

# Chart Details

Chart will install fully operational ArangoDB Kubernetes Operator.

# Prerequisites

To be able to work with Operator, Custom Resource Definitions needs to be installed. More details can be found in `kube-arangodb-crd` chart.

* Tiller 2.12.3 or later
* Helm 2.12.3
* Kubernetes 1.11.0
* OpenShift 4.2
* Cluster Admin privileges


# Resources Required

In default installation deployment with 2 pods will be created. Each default pod require 256MB of ram and 250m of CPU.


# Configuration

The following table lists the configurable parameters of the ibm-security-foundations-prod chart and their default values.

| Parameter | Description |Default |
|-----------|-------------|-------------|
|global.kubearangodb.operator.imagePullPolicy| Image pull policy for Operator images.| `IfNotPresent` |
|global.kubearangodb.operator.service.type   | Type of the Operator service.         | `ClusterIP` |
|global.kubearangodb.operator.annotations    | Annotations passed to the Operator Deployment definition.| `[]string` |
|global.kubearangodb.operator.resources.limits.cpu | CPU limits for operator pods.| `1` |
|global.kubearangodb.operator.resources.limits.memory| Memory limits for operator pods.| `256Mi` |
|global.kubearangodb.operator.resources.requests.cpu   | Requested CPI by Operator pods.| `250m` |
|global.kubearangodb.operator.resources.requests.memory| Requested memory for operator pods.| `256Mi` |
|global.kubearangodb.operator.replicaCount   | Replication count for Operator deployment.| `2` |
|global.kubearangodb.operator.updateStrategy      | Update strategy for operator pod. | `Recreate` |
|global.kubearangodb.operator.features.deployment | Define if ArangoDeployment Operator should be enabled.| `true` |
|global.kubearangodb.operator.features.deploymentReplications |  Define if ArangoDeploymentReplications Operator should be enabled.| `false` |
|global.kubearangodb.operator.features.storage   | Define if ArangoLocalStorage Operator should be enabled. | `false` |
|global.kubearangodb.operator.features.backup    | Define if ArangoBackup Operator should be enabled.| `false` |
|global.kubearangodb.rbac.enabled | Define if RBAC should be enabled.| `true` |


# Limitations

This chart can only run on amd64 architecture type. 

## Backup and restore

ArangoDB backup and restore is implemented as part of `cp4s-toolbox`. Please refer to [cp4s-toolbox knowledge center]( https://www.ibm.com/support/knowledgecenter/SSTDPP_1.3.0/docs/scp-core/backup-intro.html) for details.

## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.3.0)