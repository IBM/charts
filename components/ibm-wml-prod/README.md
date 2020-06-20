## IBM Watson Machine Learning

IBM Watson Machine Learning in IBM Cloud Pak for Data, you can build analytical models and neural networks, trained with your own data, that you can deploy for use in applications.

Depending on what is installed and configured for your deployment, you can:

- Build, train, and deploy models from notebooks using the Watson Machine Learning Python client library 

- Run experiments to train complex models in Experiment builder

- Build analytical models using the SPSS modeler

- Manage deployments


## Introduction

- This chart deploys IBM Watson Machine Learning addon for IBM Cloud Pak for Data.

## Chart Details

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/overview/overview.html)

## Prerequisites

- Install a PodDisruptionBudget.
- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/install/install.html)

## Resources Required

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/install/install.html)

## Installing the Chart

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/svc/services.html)

## Limitations

* You must create a pull secret if you are using external docker image registry.
* You must install IBM Cloud Pak for Data before installing IBM Watson Machine Learning.

## Configuration

* See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/install/install.html)

## Requirements

* See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/install/install.html)

### SecurityContextConstraints Requirements

* Cluster administrator role is required for installation.
* This chart references the [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
    annotations:
        kubernetes.io/description: "This policy is the most restrictive,
        requiring pods to run with a non-root UID, and preventing pods from accessing the host.
        The UID and GID will be bound by ranges specified at the Namespace level."
        cloudpak.ibm.com/version: "1.1.0"
    name: ibm-restricted-scc
    :
    ```