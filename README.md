# **IBM Cloud Charts** Helm Repository

## Overview

The `IBM/charts` repository provides [Helm](https://github.com/kubernetes/helm) charts for use with IBM Cloud Private.

This repository is organized as follows:

The `stable` directory contains Helm chart source provided by IBM, while the `repo/stable` directory contains the packaged Helm chart binaries.  To add the stable repo to local repository list run the following command : 
```
helm repo add stable https://raw.githubusercontent.com/IBM/charts/master/repo/stable
```

The entitled directory contains Helm chart source provided by IBM for commercial use, while the repo/entitled directory contains the packaged Helm chart binaries.  Installation of a chart from the entitled helm repo requires a docker-registry secret containing an entitlement key from [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary).  See [Installing entitled IBM Software onto IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/installing/install_entitled_workloads.html) for step by step instructions on obtaining an entitlement key and creating the required secret.  To add the entitled repo to local repository list run the following command :
```
helm repo add entitled https://raw.githubusercontent.com/IBM/charts/master/repo/entitled
```

The `community` directory contains Helm chart source provided by the wider community, while the `repo/community` directory contains the packaged Helm chart binaries.  To add the community repo to local repository list run the following command : 
```
helm repo add community https://raw.githubusercontent.com/IBM/charts/master/repo/community
```

The repo/stable, repo/entitled, and repo/community directories are Helm repositories, and their index.yaml file is built automatically based on the MASTER branch. As of IBM Cloud Private version 3.2,  all three repositories are part of the default configuration of IBM Cloud Private, and as such, all charts in those repository will be displayed by default in the IBM Cloud Private catalog.

## Getting Started

### IBM Cloud Kubernetes Service
If you are new to the IBM Cloud Kubernetes Service platform, information on how to deploy can be found in [this tutorial.](https://cloud.ibm.com/docs/containers?topic=containers-getting-started#getting-started)

### IBM Cloud Private
There are a number of ways to start using IBM Cloud Private today, including these offerings:
- [IBM Cloud Private Hosted Trial](https://www.ibm.com/cloud/garage/dte/tutorial/ibm-cloud-private-hosted-trial)
- [A Two-Week Trial on IBM Power Development Cloud](https://developer.ibm.com/linuxonpower/ibm-cloud-private-on-power/)
- [IBM Cloud Private on AWS Quick Start](https://aws.amazon.com/quickstart/architecture/ibm-cloud-private/)
- [Deploy IBM Cloud Private CE Using Vagrant](https://github.com/IBM/deploy-ibm-cloud-private/blob/master/docs/deploy-vagrant.md)
- [IBM Cloud Private with OpenShift](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.1.2/supported_environments/openshift/overview.html)

## Configure the `kubernetes` command line interface for IBM Cloud Private

To access the kubernetes `apiserver`, you will need an authorization token and the `kubectl` as the access client. In IBM Cloud Private, authorization tokens can be requested via the dashboard or the REST API.

- Dashboard: [Get authorization tokens via Dashboard](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/manage_cluster/cfc_cli.html)

- KnowledgeCenter: [APIs](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/apis/cfc_api.html).

Once you have an authorization token, you can configure `kubectl`:

```shell
export MASTER_IP=10.x.x.x
export CLUSTER_NAME=cloud-private
export AUTH_TOKEN=$(curl -k -u admin:admin https://$MASTER_IP:8443/acs/api/v1/auth/token)

kubectl config set-cluster $CLUSTER_NAME --server=https://$MASTER_IP:8001 --insecure-skip-tls-verify=true
kubectl config set-context $CLUSTER_NAME --cluster=$CLUSTER_NAME
kubectl config set-credentials user --token=$AUTH_TOKEN
kubectl config set-context $CLUSTER_NAME --user=user --namespace=default
kubectl config use-context $CLUSTER_NAME
```

Then [configure your helm command line interface](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_2.1.0/app_center/create_helm_cli.html) to work with `helm`.

_Copyright IBM Corporation 2019. All Rights Reserved._

