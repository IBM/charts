# IBM Watson Studio Local

IBM Watson Studio Local provides a suite of tools for data scientists, application developers, subject matter experts and other teams in the organization so they can collaboratively connect to data, manipulate that data, and use it to build, train, and deploy models at scale.

IBM Watson Machine Learning accelerates the process of moving to deployment and integrate AI into their applications. Watson Studio along with Watson Machine Learning offers a single interface to manage the entire analytics lifecycle, from discovery to production.

IBM Watson Studio Local - SPSS Modeler Add On accelerate time to value and achieve desired outcomes by speeding up operational tasks for data scientists. SPSS Modeler now comes with many new features which includes Graph node to generate interactive charts and Text Analytics.

## Introduction

This chart deploys IBM Watson Studio Local.

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
* You must install IBM Cloud Pak for Data before installing Watson Studio Local.

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
