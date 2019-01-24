# **IBM Cloud Charts** Helm Repository

## Overview

The `IBM/charts` repository provides [helm](https://github.com/kubernetes/helm) charts provided by IBM. 

The repository is organized as follows:

- The `master` branch serves as a landing ground for new `helm` charts.

## Development 

## Configure the `kubernetes` command line interface for IBM® Cloud private®

To access the kubernetes `apiserver`, you will need an authorization token and the `kubectl` as the access client. In IBM® Cloud private®, authorization tokens can be requested via the dashboard or the REST API.

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

_Copyright IBM Corporation 2017. All Rights Reserved._
