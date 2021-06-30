# Enabling the IBM Operator Catalog

The IBM Operator Catalog is an index of operators available to automate deployment and maintenance of IBM Software products into Red Hat&reg; OpenShift&reg; clusters.  Operators within this catalog have been built following Kubernetes best practices and IBM standards to provide a consistent integrated set of capabilities.

## Introduction

This chart deploys the IBM Operator Catalog for Cluster Administrators to discover and install IBM operators via the OperatorHub embedded in OpenShift.

- IBM Operator Catalog : curated catalog of operators to deploy select [IBM Cloud Paks](https://www.ibm.com/support/knowledgecenter/en/cloudpaks) and standalone container software

For step by step operator installation instruction, including options, see ['Installing Operators from the OperatorHub'](https://docs.openshift.com/container-platform/4.4/operators/olm-adding-operators-to-cluster.html#olm-installing-operators-from-operatorhub_olm-adding-operators-to-a-cluster)

**Please note:** The operators are publicly available, but products they install may require purchase and entitlement keys from IBM.

In addition to the Operator Catalogs, the helm chart can optionally deploy a Image Mirror with a `ImageContentSourcePolicy` Kubernetes resource.
This config will make the any image pulls by digest occur from icr.io/cpopen instead of docker.io/ibmcom.

**Please note:** If you choose to deploy the image mirror, the nodes have to either reboot or drain, depending on cluster version.

## Chart Details

Deploys the IBM Operator Catalog custom `catalogsource` resources whose content will appear under "Custom" or "IBM Operator Catalog" named catalog(s) depending on target cluster version.  Once created the catalogs will be updated on a regular polling frequency if connected to internet.

## Prerequisites

- HELM 3
- Kubernetes 1.17 or later
- Cluster Administrator access
- OpenShift Container Platform 4.4 or later

## SecurityContextConstraints Requirements

The Operator Lifecycle Manager (OLM), running by default, uses CatalogSources to query for available operators.  To ensure catalog functionality, no custom SCC with priority > 0 should be installed as they may be selected incorrectly.

## Resources Required

Minimum resources per operator catalog pod: 0.01 CPU and 0.05 GB Memory

## Pre-install Steps

- Create any user defined namespace
- (If using CLI Install) Retrieve chart from <https://redhat-developer.github.io/redhat-helm-charts/>

## Installing the Chart

Users installing this chart must have Cluster Administrator permissions.

The chart can perform two separate cluster configurations:

- Operator Catalogs
- Image Mirror
  
To install the chart with the release name `my-release`:

```
helm install my-release redhat-charts/ibm-operator-catalog-enablement --namespace <your pre-created namespace> --set license=true
```

The command deploys ibm-operator-catalog-enablement on the Kubernetes cluster.

To install the chart with the release name `my-release` and also the Image Mirror config:

```
helm install my-release redhat-charts/ibm-operator-catalog-enablement --namespace <your pre-created namespace> --set license=true --set mirrorConfig=true
```

### Verifying the Chart

See the instructions (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: helm status my-release --namespace <your pre-created namespace>.

#### Using Helm Test to Verify the Chart

The Helm chart contains a Helm test that will automate the validation process. This test requires the creation of a ServiceAccount, Role, and RoleBinding to allow the test to access the `openshift-marketplace` namespace. Replace `{{ NAMESPACE }}` with the namespace where you installed the IBM Operator Catalog.


Create a ServiceAccount
```
apiVersion: v1
kind: ServiceAccount
metadata: 
  name: ibm-operator-catalog-enablement-service-account
  namespace: {{ NAMESPACE }}
```

Create a RoleBinding
```
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata: 
  name: ibm-operator-catalog-enablement-rb
  namespace: openshift-marketplace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ibm-operator-catalog-enablement-role
subjects:
- kind: ServiceAccount
  name: ibm-operator-catalog-enablement-service-account
  namespace: {{ NAMESPACE }}
```

Create a Role
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata: 
  name: ibm-operator-catalog-enablement-role
  namespace: openshift-marketplace
rules: 
- apiGroups: 
  - ""
  resources: 
  - pods
  verbs: 
  - get
  - list
- apiGroups:
  - "operators.coreos.com"
  resources:
  - catalogsources
  verbs:
  - get
  - list
```

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```
helm uninstall my-release --namespace <your pre-created namespace>
```  

## Configuration

The following table lists the configurable parameters of the `ibm-operator-catalog-enablement` chart and their default values.

| Parameter                       | Description                                                     | Default                                    |
| ------------------------------- | --------------------------------------------------------------- | ------------------------------------------ |
| `license`                       | Set to `true` to accept the terms of the license                | `false`                                  |
| `mirrorConfig` | Set to `true` to deploy the `imagecontentsourcepolicy` resource | `false` |

## Limitations

- This chart can only be installed once per cluster.
- The CatalogSource resources created will not show in Topology as they don't fall under workload catalog.  Future releases may show reference with regard to helm install.
- The Image Mirror config cannot be deployed without deploying the CatalogSource resources

## Documentation

- [Learn about IBM Cloud Paks](http://www.ibm.com/cloud/paks)
