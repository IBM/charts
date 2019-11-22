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

- See [Details](https://www.ibm.com/support/knowledgecenter/SSHGWL_2.1.0/wsj/getting-started/overview-ws.html)

## Prerequisites

- See [Details](https://www.ibm.com/support/knowledgecenter/SSHGWL_2.1.0/local/installandsetup.html)

## Red Hat OpenShift SecurityContextConstraints Requirements

- See [Details](https://www.ibm.com/support/knowledgecenter/SSHGWL_2.1.0/local/installandsetup.html)

## Resources Required

- See [Details](https://www.ibm.com/support/knowledgecenter/SSHGWL_2.1.0/local/installandsetup.html)

## Installing the Chart

- See [Details](https://www.ibm.com/support/knowledgecenter/SSHGWL_2.1.0/local/installandsetup.html)

## Limitations

- You must create a pull secret if you are using external docker image registry.
- You must install IBM Cloud Pak for Data before installing IBM Watson Machine Learning.
- A truststore password is hard-coded, but these truststores are ephemeral and stored only in the pod in an empty directory.
- A SSL private key is also hard-coded, and is used for intra-cluster SSL communication with the scoring service.

## Configuration

- See [Details](https://www.ibm.com/support/knowledgecenter/SSHGWL_2.1.0/local/installandsetup.html)

## Requirements

- See [Details](https://www.ibm.com/support/knowledgecenter/SSHGWL_2.1.0/local/installandsetup.html)

## PodSecurityPolicy Requirements

- Cluster administrator role is required for installation.
