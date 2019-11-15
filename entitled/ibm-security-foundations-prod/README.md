


## ibm-security-foundations-prod 
The ibm-security-foundations-prod consists of 
- Middleware operator
- Sequence operator
- A series of custom resource definitions to lay down the infrastructure for IBM Cloud Pak for Security

## Introduction
A middleware operator which deploys the following shared middleware services.

-   Redis
-   Etcd
-   Couch
-   Minio
-   Ambassador
-   Elastic
-   Openwhisk

The Definitions Chart defines the Custom resource definitions that will be deployed.

The Sequence Operator deploys  an Operator to manage the deployment of microservices including the ability to manage dependencies and prerequisites required by the microservices. 

## Chart Details

This chart deploys the Operators to a Kubernetes environment for IBM Cloud Pak for Security.

## Prerequisites
- Tiller 2.12.3 or later
- Helm 2.12.3
- Kubernetes 1.11.0 
- OpenShift 3.11
- Common Services 3.2.1
- Cluster Admin privileges

## PodDisruptionBudget
Set to true to enable Pod Disruption Budget to maintain high availability during a node maintenance. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control. The default is false.

### Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.


## Resources Required

By default, `ibm-security-foundations` has the following resource requirements per pod:

Sequence Operator Pod:

- 500m CPU core
- 512 Mi memory

Middleware Operator Pod:

- 1000m CPU core
- 1 Gi memory

Kube-arango Operator Pod:

- 250m CPU core
- 256 Mi memory

See the [configuration](#configuration) section for how to configure these values.

## Installing the Chart

### Fetch and extract the chart
To perform a command line installation, first fetch and extract the chart.

Check that `helm` has the entitled repository:
```
helm repo list entitled
```

If it does not, execute the following command to add the entitled repository:
```
helm repo add entitled https://raw.githubusercontent.com/IBM/charts/master/repo/entitled/
```

You can now fetch and extract the chart:
```
helm fetch entitled/ibm-security-foundations-prod
tar xzf ibm-security-foundations-prod-<RELEASE>.tgz
```

Commands below starting with the relative path `ibm-security-foundations-prod/` should be executed in the directory where you extracted the chart.

### Preinstallation steps

#### Preconfigure cluster

The default system limits for the Kubernetes cluster nodes and the individual pods are often too low, so the necessary parameters should be increased. 

To check the current values defined for the cluster nodes the following commands should be executed:
```
sysctl net.core.somaxconn
sysctl net.ipv4.tcp_max_syn_backlog
```

If these values are lower than required (4096) then they must be updated
```
cat <<EOF >/etc/sysctl.d/99-isc.conf
net.core.somaxconn = 4096
net.ipv4.tcp_max_syn_backlog = 4096
EOF
sysctl net.core.somaxconn=4096
sysctl net.ipv4.tcp_max_syn_backlog=4096
```
The operation has to be performed on ALL nodes of the Kubernetes cluster.

The following lines must be added to the 
            `/etc/origin/node/node-config.yaml`
```
kubeletArguments:
  .......
  .......
  allowed-unsafe-sysctls:
  - "net.core.somaxconn"
```
and the kubelet has to be restarted with the command 
          `systemctl restart atomic-openshift-node`

Note:The restart operation has to be performed on ALL  nodes of the cluster.

To verify the status: Execute `systemctl status atomic-openshift-node` to ensure the kubelet is reporting Active.

See https://docs.openshift.com/container-platform/3.11/admin_guide/sysctls.html for details.

#### Create a kubernetes namespace

From the Kubernetes command line tool, create the namespace in which to deploy the service. 

Note: The Namespace created  must be < 10 character length.
```
kubectl create namespace <NAMESPACE>
```

If you cannot access the Kubernetes command line tool, see Enabling access to kubectl CLI for instructions.

#### Execute the pre-installation script

The script `createSecurityClusterPrereqs.sh`:
-  Enables the pods to execute with the correct security privileges
-  Creates the image pull secret
  
 The script is executed as follows:
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/pre-install/clusterAdministration/createSecurityClusterPrereqs.sh <NAMESPACE> <REPOSITORY> <REPO_USERNAME> <REPO_PASSWORD>
```

If you need to change the image pull secret after it has been created, delete the secret before re-executing the script. To delete the secret:

```
kubectl delete secret ibm-isc-pull-secret
```

### Install the Chart

To install the chart, you must provide
- release name
- namespace
- required user-specified values

A release name must be specified when installing the chart. It is suggested to use `ibm-security-foundations-prod` as the default/initial release name.

Before executing the helm installation, run the following command to enter that namespace
```
oc project <NAMESPACE>
```

Certain values _must_ be provided when installing the chart. The full set of configuration values are in the Configuration section below. The values that must be explicitly provided are
- `global.repository`
- `global.helmUser`

To specify these values for a command line installation, either edit the values file or pass the values on the command line.

To edit the values file
- Edit the `ibm-security-foundations-prod/values.yaml` file (or optionally copy the file to another directory)
- Execute the helm command with the additional option `--values <PATH_TO_VALUES_YAML>`

To pass the values on the command line
- Execute the helm command with an additional `--set <VARNAME>=<VALUE>` option for each value
- For example: `--set global.repository=cp.icr.io [...]`

To install the chart run the following command:
```
helm install --name <RELEASE_NAME> --namespace=<NAMESPACE>  ./ibm-security-foundations-prod --tls [--values or --set options]
```

### Verifying the Chart

For chart verification after the Helm installation completes, follow the instructions in the NOTES.txt which is packaged with the chart. For the chart installed using the <RELEASE_NAME> specified, the following commands can be used for viewing the status of the installation.
```
helm ls <RELEASE_NAME> --tls
helm status <RELEASE_NAME> --tls
```

### Uninstalling the Chart

To uninstall and delete the `ibm-security-foundations-prod` release, run the following command:

```
helm delete <RELEASE_NAME> --purge --tls
```

Then the post-delete script should be executed as follows:
```
ibm-security-foundations-prod/ibm_cloud_pak/pak_extensions/post-delete/Cleanup.sh <namespace> --all --force
```

## Configuration

The following table lists the configurable parameters of the ibm-security-foundations-prod chart and their default values.

| Parameter | Description |Default |
|-----------|-------------|-------------|
|global.helmUser| Cluster Administrator |Cluster Admin Username which would be used to provision charts |
|global.repository| Docker image registry |IfNotPresent |
|global.poddisruptionbudget.enabled| Pod disruption budget enabler| false |
|global.poddisruptionbudget.minAvailable| Pod disruption minimum budget available| 1 |
|global.ambassador.replicaCount| Number of Replicas for Ambassador Operator| 2 |
|global.affinity| Pod Affinity| hard |
|global.imagePullPolicy| Image pull policy for Operator images.| `IfNotPresent` |


## Limitations

This chart can only run on amd64 architecture type. 

The authsvc component installed by this chart handles all authenticated HTTP requests for IBM Cloud Pak for Security and must be able to handle many requests quickly. To prevent this component refusing requests due to a backlog of closing requests, it is advisable to increase the `tcp_max_syn_backlog` and `somaxconn` kernel parameters. These settings should be applied on all nodes in the cluster. For example:

```
sysctl net.ipv4.tcp_max_syn_backlog=4096
sysctl net.core.somaxconn=4096
```

## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSTDPP_1.1.0)
