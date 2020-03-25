# Name

IBM&reg; Cloud Pak for Security

# Introduction

## Summary

IBM® Cloud Pak for Security provides a platform to quickly integrate your existing security tools to generate deeper insights into threats across hybrid, multicloud environments.

The IBM Cloud Pak for Security platform uses an infrastructure-independent common operating environment that can be installed and run anywhere. It comprises containerized software pre-integrated with Red Hat OpenShift enterprise application platform, which is trusted and certified by thousands of organizations around the world.

IBM Cloud Pak for Security can connect disparate data sources—to uncover hidden threats and make better risk-based decisions — while leaving the data where it resides. By using open standards and IBM innovations, IBM Cloud Pak for Security can securely access IBM and third-party tools to search for threat indicators across any cloud or on-premises location. Connect your workflows with a unified interface so you can respond faster to security incidents. Use IBM Cloud Pak for Security to orchestrate and automate your security response so that you can better prioritize your team's time.


## Chart details

The ibm-security-foundations-prod chart installs foundation elements of IBM Cloud Pak for Security, which include:

- **Middleware Operator**. Manages the install of data and platform assets used by IBM Cloud Pak for Security, including: CouchDB, ElasticSearch, Etcd, MinIO, Redis, OpenWhisk.
- **Sequences Operator**. Orchestrates the install of IBM Cloud Pak for Security components.
- **Ambassador**. Creates and manages the Envoy gateway service of IBM Cloud Pak for Security.
- **Custom Resource Definitions**. To enable management of these elements by IBM Cloud Pak for Security.

The Middleware and Sequence operator deployed as part of this chart are Namespace-scoped. They watch and manage resources within the namespace that IBM Cloud Pak for Security is installed.

## Prerequisites

- Red Hat OpenShift Container Platform 4.2 (or 3.11 on IBM Cloud)
- IBM Cloud Platform Common Services 3.2.4
- Cluster admin privileges


## PodDisruptionBudget

Pod disruption budget is used to maintain high availability during Node maintenance. Administrator role or higher is required to enable pod disruption budget on clusters with role based access control. The default is false. See `global.poddisruptionbudget` in the [configuration](#configuration) section.


## Red Hat OpenShift SecurityContextConstraints requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. 

The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart.

This chart also defines a custom SecurityContextConstraints object which is used to finely control the permissions/capabilities needed to deploy this chart, the definition of this SCC is shown below : 

 
 ```
 allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: []
allowedUnsafeSysctls:
  - net.core.somaxconn
apiVersion: v1
defaultAddCapabilities: []
fsGroup:
  ranges:
  - max: 5000
    min: 1000
  type: MustRunAs
groups: []
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: ibm-isc-scc is a copy of nonroot scc which allows somaxconn changes
  name: ibm-isc-scc
priority: 10
readOnlyRootFilesystem: false
requiredDropCapabilities:
- KILL
- MKNOD
- SETUID
- SETGID
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  ranges:
  - max: 5000
    min: 1000
  type: MustRunAs
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
```
The following script 
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-install/preInstall.sh 
```
is run at install time to set the SecurityContextConstraints required by the chart.


## Resources required

By default, `ibm-security-foundations` has the following resource request requirements per pod:

| Service   | Memory (GB) | CPU (cores) |
| --------- | ----------- | ----------- | 
| Ambassador|    256Mi    | 100m        |
| Sequences |    256Mi    | 250m        |
| Middleware|    256Mi    | 250m        |

See the [configuration](#configuration) section for how to configure these values.


## Installing the chart

### Run the pre-install script

The script `preInstall.sh`:
-  Enables the pods to execute with the correct security privileges
-  Creates an image pull secret to pull images from a repository

Before running the script, log in to the cluster.

Run the script as follows:
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-install/preInstall.sh [ arguments ] 
```

where arguments may be


| Argument| Description
|---------|-------------
| -n NAMESPACE | Change namespace from current
| -force | Force update of the existing cluster configuration
| -repo REPOSITORY REPO_USERNAME REPO_PASSWORD | Set the image repository and repository credentials as documented per install type (Entitled Registry or PPA)
| -sysctl | Enable net.core.somaxconn sysctl change
  
### Check prerequistes	

A script is provided which should be run to validate pre-requisites before beginning the install of `ibm-security-foundations-prod`. 	


This script is run with the following command : 	

```	
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-install/checkprereq.sh -n <NAMESPACE> 	
```	

Output will display the default storage class and when successfull will indicate : 	

```	
INFO: ibm-security-foundations prerequisites are OK	
```	

Any errors should be resolved before continuing.

### Install the chart

To install the chart, you must provide
- a release name (e.g. `ibm-security-foundations-prod`)
- namespace (as you selected above)
- required user-specified values

Important user-specified values are:

| Parameter | Note | 
| --- | --- |
| `global.helmUser` | Required |
| `global.repository` | Required if installing [using IBM Passport Advantage](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.2.0/docs/security-pak/ppa_download.html), you must specify a docker registry host (and path if relevant). Note that the repository you specify here must match the repository specified in [Run the pre-install script](#run-the-pre-install-script) above. |
| `global.repositoryType` | If installing from Passport Advantage archives, change to `local` |
| `global.cloudType` | Required if installing to a cloud platform such as IBM Cloud or AWS rather than a Red Hat OpenShift Container Platform |

The full set of configuration values are in the [Configuration table](#configuration).

To specify values for a command line installation, either edit the values file or pass the values on the command line.

To edit the values file
- Edit the `ibm-security-foundations-prod/values.yaml` file (or optionally copy the file to another directory)
- Run the helm command with the additional option `--values <PATH>/values.yaml`

To pass the values on the command line
- Run the helm command with an additional `--set <VARNAME>=<VALUE>` option for each value
- For example: `--set global.helmUser=my-rhel-admin [...]`

Before running the helm install, log in to the cluster and set the namespace.

To install the chart run the following command:
```
helm install --name <RELEASE_NAME> --namespace=<NAMESPACE>  ./ibm-security-foundations-prod --tls --values <PATH>/values.yaml [--set options]
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
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-upgrade/preUpgrade.sh [ -n <NAMESPACE> ]
```

Then run the command:
```
helm upgrade <RELEASE_NAME> --namespace=<NAMESPACE>  ./ibm-security-foundations-prod --tls --values <PATH>/values.yaml [--set options]
```

where passing `--values <PATH>/values.yaml` and `[--set options]` are as described in [Install the chart](#install-the-chart) above.


### Uninstalling the chart

Before running these steps log in to the cluster and set the namespace.

To uninstall and delete the `ibm-security-foundations-prod` release, run the following command:

```
helm delete <RELEASE_NAME> --purge --tls
```

Then the post-delete script must be run as follows:
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/post-delete/Cleanup.sh -n <NAMESPACE> --all --force
```

Any errors in the output of this script (other than a Usage error) can be safely ignored.


## Configuration

The following table lists the configurable parameters of the ibm-security-foundations-prod chart and their default values.

| Parameter | Description |Default |
|-----------|-------------|-------------|
|global.affinity| Pod affinity| hard |
|global.ambassador.replicaCount| Number of replicas for ambassador operator| 2 |
|global.cloudType| Cloud provider type. Options available are: ocp, ibmcloud, aws. Defaults to `ocp` for Red Hat OpenShift Container Platform  | `ocp` |
|global.helmUser| Cluster (ICP ADMIN) administrator username which will be used to provision charts | [Required] |
|global.imagePullPolicy| Image pull policy for operator images.| `IfNotPresent` |
|global.operator.ambassador.resources.requests.cpu | CPU requests for ambassador | 250m |
|global.operator.ambassador.resources.requests.memory | Memory requests for ambassador | 256Mi |
|global.operator.middleware.resources.requests.cpu | CPU requests for middleware operator | 250m |
|global.operator.middleware.resources.requests.memory | Memory requests for middleware operator | 256Mi |
|global.operator.sequence.resources.requests.cpu | CPU requests for sequence operator | 250m |
|global.operator.sequence.resources.requests.memory | Memory requests for sequence operator | 256Mi |
|global.poddisruptionbudget.enabled| Enables application availability during a cluster node maintenance. Administrator role or higher required to enable PDB. | false |
|global.poddisruptionbudget.minAvailable| Pod disruption minimum budget available| 1 |
|global.repository| Docker image registry from which images will be pulled. Use `cp.icr.io/cp/cp4s` for Entitled Registry or provide local registry host (and path if relevant) if installing using IBM Passport Advantage | cp.icr.io/cp/cp4s |
|global.repositoryType| Repository Type from which the images will be pulled. Options available are: entitled, local. Use `entitled` for Entitled Registry or `local`for all other repository types  | `entitled` |


## Limitations

This chart can only run on amd64 architecture type. 

## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.2.0)

