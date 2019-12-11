## Introduction

IBM® Cloud Pak for Security provides a platform to quickly integrate your existing security tools to generate deeper insights into threats across hybrid, multicloud environments.

The IBM Cloud Pak for Security platform uses an infrastructure-independent common operating environment that can be installed and run anywhere. It comprises containerized software pre-integrated with Red Hat OpenShift enterprise application platform, which is trusted and certified by thousands of organizations around the world.

IBM Cloud Pak for Security can connect disparate data sources—to uncover hidden threats and make better risk-based decisions — while leaving the data where it resides. By using open standards and IBM innovations, IBM Cloud Pak for Security can securely access IBM and third-party tools to search for threat indicators across any cloud or on-premises location. Connect your workflows with a unified interface so you can respond faster to security incidents. Use IBM Cloud Pak for Security to orchestrate and automate your security response so that you can better prioritize your team's time.


## Chart details

The ibm-security-foundations-prod chart installs foundation elements of IBM Cloud Pak for Security, which include:

- **Middleware Operator**. Manages the install of data and platform assets used by IBM Cloud Pak for Security, including: CouchDB, ElasticSearch, Etcd, MinIO, Redis, OpenWhisk.
- **Sequences Operator**. Orchestrates the install of IBM Cloud Pak for Security components.
- **Arango Operator**. Manages the install of ArangoDB for IBM Cloud Pak for Security.
- **Ambassador**. Creates and manages the Envoy gateway service of IBM Cloud Pak for Security.
- **Custom Resource Definitions**. To enable management of these elements by IBM Cloud Pak for Security.


## Prerequisites

- Red Hat OpenShift Container Platform 3.11
  - Kubernetes 1.11.0
- IBM Cloud Private 3.2.1
  - Common Services 3.2.1
  - Tiller 2.12.3 or later
  - Helm 2.12.3
- Cluster Admin privileges


## PodDisruptionBudget

Pod disruption budget is used to maintain high availability during Node maintenance. Administrator role or higher is required to enable pod disruption budget on clusters with role based access control. The default is false. See `global.poddisruptionbudget` in the [configuration](#configuration) section.


## Red Hat OpenShift SecurityContextConstraints requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. 

The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart.

The following script 
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration/createSecurityClusterPrereqs.sh 
```
is run at install time to set the SecurityContextConstraints required by the chart.


## Resources required

By default, `ibm-security-foundations` has the following resource request requirements per pod:

| Service   | Memory (GB) | CPU (cores) |
| --------- | ----------- | ----------- | 
| Ambassador|    256Mi    | 100m        |
| Sequences |    256Mi    | 250m        |
| Middleware|    256Mi    | 250m        |
| Kube-arangodb|   256Mi    | 250m   |

See the [configuration](#configuration) section for how to configure these values.


## Installing the chart


### Kubernetes namespace

Select or create a custom namespace in which you will deploy the Cloud Pak for Security charts. 

The namespace name must be less than 10 characters in length.

To create a namespace you must first log in to the cluster.

```
cloudctl login
kubectl create namespace <NAMESPACE>
```


### Log in to the cluster and set the namespace

You must set the namespace when running commands such as `helm`, `oc` or `kubectl`. For example:

- Set the namespace on log in:
  ```
  cloudctl login -n <NAMESPACE>
  ```
- Set the namespace after log in:
  ```
  oc project <NAMESPACE>
  ```
- Specify the namespace in a command:
  ```
  kubectl -n namespace [command]
  ```


### Fetch and extract the chart

To perform a command line installation, first fetch and extract the chart.

The helm repository from which to fetch the charts depends on whether you are installing using IBM Entitled Registry or IBM Passport Advantage. See the [IBM Cloud Pak for Security Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0/docs/security-pak/installation.html) for more details. The steps below assume you are installing using IBM Entitled Registry.

Check that `helm` has the entitled repository:
```
helm repo list
```

Check that the output contains the line:
```
entitled  https://raw.githubusercontent.com/IBM/charts/master/repo/entitled/
```

If it does not, run the following command to add the entitled repository:
```
helm repo add entitled https://raw.githubusercontent.com/IBM/charts/master/repo/entitled/
```

You can now fetch and extract the chart:
```
helm fetch entitled/ibm-security-foundations-prod
tar xzf ibm-security-foundations-prod-<RELEASE>.tgz
```

Commands below starting with the relative path `ibm-security-foundations-prod/` must be run in the directory where you extracted the chart.


### Run the pre-install script

The script `createSecurityClusterPrereqs.sh`:
-  Enables the pods to execute with the correct security privileges
-  Creates an image pull secret to pull images from a repository

Using the IBM Entitled Registry repository, the parameters are:
```
REPOSITORY=cp.icr.io
REPO_USERNAME=cp
REPO_PASSWORD=<YOUR_ENTITLEMENT_KEY>
```

Before running the script, log in to the cluster.

Run the script as follows:
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration/createSecurityClusterPrereqs.sh <NAMESPACE> <REPOSITORY> <REPO_USERNAME> <REPO_PASSWORD>
```

If you need to change the image pull secret, delete the secret before re-running the script. To delete the secret:

```
kubectl delete secret ibm-isc-pull-secret -n <NAMESPACE>
```


### Install the chart

To install the chart, you must provide
- a release name (e.g. `ibm-security-foundations-prod`)
- namespace (as you selected above)
- required user-specified values

Important user-specified values are:

| Parameter | Note | 
| --- | --- |
| `global.helmUser` | Required |
| `global.repositoryType` | If installing from Passport Advantage archives, change to `local` |
| `global.cloudType` | Required if installing to a cloud platform such as IBM Cloud or AWS rather than a Red Hat OpenShift Container Platform |

The full set of configuration values are in the [Configuration table](#configuration).

To specify values for a command line installation, either edit the values file or pass the values on the command line.

To edit the values file
- Edit the `ibm-security-foundations-prod/values.yaml` file (or optionally copy the file to another directory)
- Run the helm command with the additional option `--values <PATH_TO_VALUES_YAML>`

To pass the values on the command line
- Run the helm command with an additional `--set <VARNAME>=<VALUE>` option for each value
- For example: `--set global.helmUser=my-rhel-admin [...]`

Before running the helm install, log in to the cluster and set the namespace.

To install the chart run the following command:
```
helm install --name <RELEASE_NAME> --namespace=<NAMESPACE>  ./ibm-security-foundations-prod --tls [--values or --set options]
```

### Verifying the chart

For chart verification after the helm installation completes, follow the instructions in the NOTES.txt which is packaged with the chart. For the chart installed using the <RELEASE_NAME> specified, the following commands can be used for viewing the status of the installation.
```
helm ls <RELEASE_NAME> --tls
helm status <RELEASE_NAME> --tls
```

### Upgrade or update the installation

If you have previously installed Cloud Pak for Security, you can upgrade to a later version of the software or apply updates to configuration values by running the helm `upgrade` command.

To upgrade the installation, first run the command:
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-upgrade/preUpgrade.sh <NAMESPACE>
```

Then run the command:
```
helm upgrade [OPTIONS]
```

where OPTIONS are as described in [Install the chart](#install-the-chart) above.


### Uninstalling the chart

Before running these steps log in to the cluster and set the namespace.

To uninstall and delete the `ibm-security-foundations-prod` release, run the following command:

```
helm delete <RELEASE_NAME> --purge --tls
```

Then the post-delete script must be run as follows:
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/post-delete/Cleanup.sh <NAMESPACE> --all --force
```

Any errors in the output of this script (other than a Usage error) can be safely ignored.


## Configuration

The following table lists the configurable parameters of the ibm-security-foundations-prod chart and their default values.

| Parameter | Description |Default |
|-----------|-------------|-------------|
|global.affinity| Pod affinity| hard |
|global.ambassador.replicaCount| Number of replicas for ambassador operator| 2 |
|global.cloudType| Cloud provider type. Options available are: ocp, ibmcloud, aws. Defaults to `ocp` for Red Hat OpenShift Container Platform  | `ocp` |
|global.helmUser| Cluster administrator username which will be used to provision charts | [Required] |
|global.imagePullPolicy| Image pull policy for operator images.| `IfNotPresent` |
|global.kubearangodb.operator.resources.requests.cpu | CPU requests for kubearangodb operator | 250m |
|global.kubearangodb.operator.resources.requests.memory | Memory requests for kubearangodb operator | 256Mi |
|global.operator.ambassador.resources.requests.cpu | CPU requests for ambassador | 250m |
|global.operator.ambassador.resources.requests.memory | Memory requests for ambassador | 256Mi |
|global.operator.middleware.resources.requests.cpu | CPU requests for middleware operator | 250m |
|global.operator.middleware.resources.requests.memory | Memory requests for middleware operator | 256Mi |
|global.operator.sequence.resources.requests.cpu | CPU requests for sequence operator | 250m |
|global.operator.sequence.resources.requests.memory | Memory requests for sequence operator | 256Mi |
|global.poddisruptionbudget.enabled| Enables application availability during a cluster node maintenance. Administrator role or higher required to enable PDB. | false |
|global.poddisruptionbudget.minAvailable| Pod disruption minimum budget available| 1 |
|global.repository| Docker image registry | cp.icr.io/cp/cp4s |
|global.repositoryType| Repository Type from which the Images will pulled from. Options available are: entitled, local. Use `entitled` for Entitled Registry or `local`for all other repository types  | `entitled` |


## Limitations

This chart can only run on amd64 architecture type. 

## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0)
