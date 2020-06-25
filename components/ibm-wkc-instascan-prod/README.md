# instascan-charts
Helm charts for wkc-instascan

# IBM Watson Knowledge Catalog InstaScan

Identify risk hot spots and assess compliance with regulatory requirements for cloud data sources

With IBM Watson Knowledge Catalog InstaScan, you can manage unstructured data in cloud data sources. Define policies for placement of sensitive data that reflect regulatory requirements or your organisation’s directives. Connect to various cloud data sources and assign such policies to those data sources. Then, run risk assessments on the data sources to identify high risk areas. After you remediate the risks uncovered, assess compliance of your data sources with your policies for placement of sensitive data.

## Introduction

This chart deploys IBM Watson Knowledge Catalog InstaScan for IBM Cloud Pak for Data.

## Chart Details

This chart contains following components:
 - instascan-api-server
 - instascan-ds-manager
 - instascan-nginx
 - instascan-vault
 - instascan-postgres
 - ap-service
 - ap-analysis-service
 - ap-tika
 - doc-preview-service

## Prerequisites

IBM&reg; Cloud Pak for Data version 3.0.0.0

## Resources Required

* In addition to the Cloud Pak for Data resources, the following minimum resources are required for scheduling IBM&reg; Watson Knowledge Catalog InstaScan.

Minimum scheduling capacity:

| Software  | Memory (GB) | CPU (cores) | Disk (GB) | Nodes |
| --------- | ----------- | ----------- | --------- | ----- |
| WKC-InstaScan |   8     |    8        |     500   |  2    |
| **Total** |       8     |    8        |     500   |  2    |

Recommended scheduling capacity for production:

| Software  | Memory (GB) | CPU (cores) | Disk (GB) | Nodes |
| --------- | ----------- | ----------- | --------- | ----- |
| WKC-InstaScan |   16     |    16        |     500   |  4    |
| **Total** |       16     |    16        |     500   |  4    |

## Installing the Chart

The recommended way to install this chart is using the `cpd` install utility shipped with Cloudpak for Data parent product.
see the [IBM Cloud Pak for Data documentation](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ)

## Limitations

* Works only with IBM Cloud Pak for Data
* Only one installation of Watson Knowledge Catalog InstaScan per Cloud Pak for Data instance is supported at this time.

## Configuration

The following tables lists the configurable parameters of the chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `global.storageClassName` | Storage class for pvc | `` |
| `global.dockerRegistryPrefix` | Docker resistry | `` |
| `serviceAccount` | Service account to run the services | `cpd-viewer-sa` |
| `imagePullSecrets` | Secrets for pulling images | `` |
| `imagePullPolicy` | Pull policy for images | `Always` |

# SecurityContextConstraints Requirements

The predefined SCC name [`cpd-user-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart. If your target namespace is bound to this SCC, you can proceed to install the chart.
