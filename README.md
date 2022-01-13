# **IBM Charts** Helm Repository

## Overview

The `IBM/charts` git repository provides several [Helm](https://github.com/helm/helm#helm) chart repositories and is organized as follows:

## Helm 3
The `repo/ibm-helm` directory contains packaged Helm chart binaries.  Installation of a chart from the ibm-helm repo may require a docker-registry secret containing an entitlement key from [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary).  See [obtaining your entitlement key](https://www.ibm.com/support/knowledgecenter/SSFC4F_1.3.0/readmes/GA/red_hat_getting_started.html#entitlement) for step by step instructions on retrieving an entitlement key if required.  

To add the ibm-helm repo to local helm chart repository list run the following command : 
```
helm repo add ibm-helm https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm
```

To add the ibm-helm repo to a OCP 4.6+ helm chart repository list run the following command : 
```
cat <<EOF | kubectl apply -f -
apiVersion: helm.openshift.io/v1beta1
kind: HelmChartRepository
metadata:
  name: ibm-helm-repo
spec:
  connectionConfig:
    url: https://raw.githubusercontent.com/IBM/charts/master/repo/ibm-helm
EOF
```

### Getting Started
If you are new to Helm 3 on OpenShift Container Platform, information on getting started can be found [here](https://docs.openshift.com/container-platform/4.6/cli_reference/helm_cli/getting-started-with-helm-on-openshift-container-platform.html).


## Helm 2 

The `stable` directory contains Helm chart source provided by IBM, while the `repo/stable` directory contains the packaged Helm chart binaries.  To add the stable repo to local repository list run the following command : 
```
helm repo add stable https://raw.githubusercontent.com/IBM/charts/master/repo/stable
```

**Note:** [Helm stable and incubator charts have moved locations](https://helm.sh/blog/new-location-stable-incubator-charts) causing older helm clients to fail when adding the IBM stable repo as listed above.  If using a helm client older then v2.17, please run `helm init --client-only --stable-repo-url https://charts.helm.sh/stable` first to establish new location.

The entitled directory contains Helm chart source provided by IBM for commercial use, while the repo/entitled directory contains the packaged Helm chart binaries.  Installation of a chart from the entitled helm repo requires a docker-registry secret containing an entitlement key from [MyIBM Container Software Library](https://myibm.ibm.com/products-services/containerlibrary).  See [installing entitled IBM Software onto IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/installing/install_entitled_workloads.html) for step by step instructions on obtaining an entitlement key and creating the required secrets.  To add the entitled repo to local repository list run the following command :
```
helm repo add entitled https://raw.githubusercontent.com/IBM/charts/master/repo/entitled
```
**Note:** [Helm stable and incubator charts have moved locations](https://helm.sh/blog/new-location-stable-incubator-charts) causing older helm clients to fail when adding the IBM entitled repo as listed above.  If using a helm client older then v2.17, please run `helm init --client-only --stable-repo-url https://charts.helm.sh/stable` first to establish new location.


The `community` directory contains Helm chart source provided by the wider community, while the `repo/community` directory contains the packaged Helm chart binaries.  To add the community repo to local repository list run the following command : 
```
helm repo add community https://raw.githubusercontent.com/IBM/charts/master/repo/community
```
**Note:** [Helm stable and incubator charts have moved locations](https://helm.sh/blog/new-location-stable-incubator-charts) causing older helm clients to fail when adding the IBM community repo as listed above.  If using a helm client older then v2.17, please run `helm init --client-only --stable-repo-url https://charts.helm.sh/stable` first to establish new location.


The repo/stable, repo/entitled, and repo/community directories are Helm repositories, and their index.yaml file is built automatically based on the MASTER branch. As of IBM Cloud Private version 3.2,  all three repositories are part of the default configuration of IBM Cloud Private, and as such, all charts in those repository will be displayed by default in the IBM Cloud Private catalog.

### Getting Started

#### IBM Cloud Kubernetes Service
If you are new to the IBM Cloud Kubernetes Service platform, information on how to deploy can be found in [this tutorial.](https://cloud.ibm.com/docs/containers?topic=containers-getting-started#getting-started)

#### IBM Cloud Private
If you are new to IBM Cloud Private, information on getting started can be found [here](https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.0/getting_started/overview.html).

_Copyright IBM Corporation 2020. All Rights Reserved._

