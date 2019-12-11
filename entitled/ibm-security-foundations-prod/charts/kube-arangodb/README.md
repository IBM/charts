# Introduction

Kubernetes ArangoDB Operator.

# Chart Details

Chart will install fully operational ArangoDB Kubernetes Operator.

# Prerequisites

To be able to work with Operator, Custom Resource Definitions needs to be installed. More details can be found in `kube-arangodb-crd` chart.

* Tiller 2.12.3 or later
* Helm 2.12.3
* Kubernetes 1.11.0
* OpenShift 3.11
* Cluster Admin privileges


# Resources Required

In default installation deployment with 2 pods will be created. Each default pod require 256MB of ram and 250m of CPU.


# Configuration

The following table lists the configurable parameters of the ibm-security-foundations-prod chart and their default values.

| Parameter | Description |Default |
|-----------|-------------|-------------|
|global.kube-arangodb.operator.imagePullPolicy| Image pull policy for Operator images.| `IfNotPresent` |
|global.kube-arangodb.operator.service.type   | Type of the Operator service.         | `ClusterIP` |
|global.kube-arangodb.operator.annotations    | Annotations passed to the Operator Deployment definition.| `[]string` |
|global.kube-arangodb.operator.resources.limits.cpu | CPU limits for operator pods.| `1` |
|global.kube-arangodb.operator.resources.limits.memory| Memory limits for operator pods.| `256Mi` |
|global.kube-arangodb.operator.resources.requested.cpu   | Requested CPI by Operator pods.| `250m` |
|global.kube-arangodb.operator.resources.requested.memory| Requested memory for operator pods.| `256Mi` |
|global.kube-arangodb.operator.replicaCount   | Replication count for Operator deployment.| `2` |
|global.kube-arangodb.operator.updateStrategy      | Update strategy for operator pod. | `Recreate` |
|global.kube-arangodb.operator.features.deployment | Define if ArangoDeployment Operator should be enabled.| `true` |
|global.kube-arangodb.operator.features.deploymentReplications |  Define if ArangoDeploymentReplications Operator should be enabled.| `true` |
|global.kube-arangodb.operator.features.storage   | Define if ArangoLocalStorage Operator should be enabled. | `false` |
|global.kube-arangodb.operator.features.backup    | Define if ArangoBackup Operator should be enabled.| `false` |
|global.kube-arangodb.rbac.enabled | Define if RBAC should be enabled.| `true` |


# Limitations

This chart can only run on amd64 architecture type. 

## Backup and restore

TBD

## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSMF6Q/docs/isc-core/isc-platform-overview.html)