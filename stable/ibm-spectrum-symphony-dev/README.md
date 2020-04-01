# ibm-spectrum-symphony-dev

[![IBM Spectrum Symphony](https://developer.ibm.com/storage/wp-content/uploads/sites/91/2016/08/SpectrumSymphonyIcon-1.jpg)](https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=46ecec34-bd69-43f7-a627-7c469c1eddf8) IBM Spectrum Symphony is an enterprise-class workload manager for compute- and data-intensive workload on a scalable, shared grid. It provides an efficient computing environment for dozens of distributed parallel applications to deliver faster results and better resource utilization.

## Introduction

This chart deploys IBM Spectrum Symphony Community Edition on a Kubernetes cluster using the Helm package manager. It enables you to quickly configure and run IBM Spectrum Symphony as a Docker container application, which you can then manage from the cluster management console or the command line.

The IBM Spectrum Symphony Community Edition chart provides the full functionality of IBM Spectrum Symphony for a cluster of up to 64 cores. To scale your cluster beyond 64 cores and receive IBM Support tied to licensed software, consider deploying the "ibm-spectrum-symphony-prod" chart.

## Chart Details

This chart deploys IBM Spectrum Symphony Community Edition with the following standard configuration:
* Creates a deployment with one pod (one master, compute, and client container each) on the Kubernetes cluster.
* Provisions storage volumes dynamically based on storage class to automatically bind the PersistentVolume to the PersistentVolumeClaim.
* Creates a `webgui` service to connect to the application's cluster management console from a supported browser.
* Creates an `sshd` service to connect to the client over SSH and submit workload from the client to the cluster.

> **Note**: You cannot upgrade or roll back IBM Spectrum Symphony Helm release versions. To take advantage of a new release version, you must create a new cluster. 

## Prerequisites

- A user with operator role is required to install the chart.

- A default storage class must be set up by the system administrator for dynamic storage provisioning before this chart is deployed. With dynamic storage provisioning (default), storage volumes are provisioned on demand based on the storage class.
  - Set 'cluster.pvc.useDynamicProvisioning' to true (default).
  - Specify a custom 'storageClassName' per volume or leave the value empty to use the default storageClass or any available PersistentVolume that can satisfy the capacity request.

  Volumes that are dynamically provisioned inherit the reclaim policy of their storage class (which defaults to Delete).

- If you are not using dynamic storage provisioning, a PersistentVolumeClaim or PersistentVolume must be predefined before this chart is deployed.
  - Set 'cluster.pvc.useDynamicProvisioning' to false.
  - Specify the 'cluster.pvc.existingClaimName' per volume or leave the value empty and let the Kubernetes binding process select a pre-existing volume based on accessMode and size.
  - Use 'cluster.pvc.selector.label' to refine the binding process.

  Docker container processes for IBM Spectrum Symphony run as internal user egoadmin with ID 1000. When you use pre-existing volumes, ensure that the required permissions for user ID 1000 are set for the mounted volume.

- Review other requirements, such as supported browsers. For more information, refer to the [supported system configurations](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/sym_kc/sym_kc_system_configurations.html) topic in the online IBM Knowledge Center.

- For SSH access to the client host, an SSH public key must be encoded in base64 and saved into a Kubernetes secret. For SSH access from the client host to the management and compute hosts, the corresponding SSH private key must also be encoded. For more information, refer to the [Before Installing the Chart](#before-installing-the-chart) section.

## PodDisruptionBudget

Set to true to enable Pod Disruption Budget to maintain high availability during a node maintenance. Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control. The default is false.

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

Custom SecurityContextConstraints definition:
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
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: false
allowedCapabilities: null
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: null
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
  - "*"
fsGroup:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seccompProfiles:
- docker/default
# This can be customized for seLinuxOptions specific to your host machine
seLinuxContext:
  type: RunAsAny
# seLinuxOptions:
#   level:
#   user:
#   role:
#   type:
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
# This can be customized to host specifics
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## Resources Required

To control decisions about which nodes to place pods on, specify how much resources (CPU and memory) each container needs:

- The 'master.resources.requests.cpu' and 'master.resources.requests.memory' parameters define initial CPU and memory requests to create the master container. The default requests are 2 cores and 2048 MB memory, respectively. The same values are enforced in the 'master.resources.limits.cpu' and 'master.resources.limits.memory' parameters as limits for the master container.

- The 'compute.resources.requests.cpu' and 'compute.resources.requests.memory' parameters define the initial resources that each compute container requests. However, resources cannot grow beyond the limits of 'compute.resources.limits.cpu' and 'compute.resources.limits.memory'. The default requests are 1 core and 1024 MB memory for each compute container, with the same limits.

- The 'client.resources.requests.cpu' and 'client.resources.requests.memory' parameters define the initial resources that each client container requests. The default requests are 1 core and 1024 MB memory for each client container, with the same limits.

For CPU and memory values that you can set, refer to the [Kubernetes specification](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).

## Before Installing the Chart

- If you want to use scripts to configure your IBM Spectrum Symphony cluster before and/or after cluster startup, create scripts and package all the necessary files (including the scripts) as a .tar.gz file. Then, create a base64-encoded Kubernetes secret for the package before the chart is deployed. For more information, refer to the [Creating secrets](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/install_grid_sym/symphony_icp_creating_secrets.html) topic.

## Installing the Chart

To install the ibm-spectrum-symphony-dev chart with the release name "my-release", use the following command:

```bash
$ helm install --tls --name my-release stable/ibm-spectrum-symphony-dev
```

The command deploys the chart on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

You can use unique release names to create as many IBM Spectrum Symphony deployments as you want.

> **Tip**: Use the "helm list --tls" option to view a list of releases.

## Verifying the Chart

To verify the installation, run the following helm command: 

```bash
$ helm status my-release --tls
```

## Configuration

The following table lists the configurable parameters of the ibm-spectrum-symphony-dev chart and their default values. Specify each parameter using the "--set key=value[,key=value]" argument to the "helm install --tls" command.

> **Tip**: Alternatively, provide a YAML file that specifies the values for the parameters while installing the chart. You can use the default *values.yaml* file.

| Parameter                  | Description                         |  Default                  |
| -----------------------    | ---------------------------------   | -----------------------   |
| image.repository         | Docker repository for the IBM Spectrum Symphony image  | `ibmcom/spectrum-symphony` |
| image.tag                | Tag for the IBM Spectrum Symphony image | `7.2.1.1`  |
| image.pullPolicy         | Pull policy for the IBM Spectrum Symphony image | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| serviceAccountName         | Service Account Name to use for deployment, if empty one is created  | `""` |
| cluster.clusterName              | Name of the cluster. If "", the cluster takes the name '*release_name*-ibm-spectrum-symphony-dev'. | `""` |
| cluster.pvc.useDynamicProvisioning | Whether storage volumes must be dynamically provisioned. If true, the PersistentVolumeClaim uses the storageClassName to bind the volume. If false, the selector is used to refine the binding process. | `true` |
| cluster.pvc.storageClassName       | Storage class name for dynamic storage provisioning. Specify a custom storageClassName per volume, or leave the value empty to use the default storageClass or any available PersistentVolume that can satisfy the capacity request (for example, 5Gi).  | `""` |
| cluster.pvc.existingClaimName      | If not using dynamic provisioning, name of an existing PersistentVolumeClaim. Specify an existing claim name per volume or leave the value empty and let the Kubernetes binding process select a pre-existing volume based on accessMode and size. | `""` |
| cluster.pvc.selector.label         | When matching a pre-existing PersistentVolume, the label used to find a match on the keySelector label (see [Kubernetes - Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)).  | `""` |
| cluster.pvc.selector.value         | When matching a pre-existing PersistentVolume, the value used to find a match on the values (see [Kubernetes - Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)).  | `""` |
| cluster.pvc.size         | Size of the persistent storage | `5Gi` |
| cluster.enableSharedSubdir | Whether to create a subdirectory inside the shared volume mount, enabling the shared volume to be re-used in a single pod. If true, a subdirectory that takes the name of your Helm release is created inside the /shared directory. | `true` |
| cluster.logsOnShared | Whether component logs on management and compute hosts must be saved to the mounted shared directory to be shared by containers across multiple hosts. If true, resource manager logs (EGO) are saved at /shared/logs/kernel/logs/, workload logs (SOAM) at /shared/logs/soam/logs/,  cluster management console (WEBGUI) logs at /shared/logs/gui/logs/, and reporting logs (PERF) at /shared/logs/perf/logs/.      | `true` |
| cluster.scriptsSecretName | Name of the secret created to hold predefined scripts that configure your cluster before and/or after startup (see [Before Installing the Chart](#before-installing-the-chart)). | `""`|
| master.resources.requests.cpu      | Initial CPU requested for the master (see [Resources Required](#resources-required)). | `2` |
| master.resources.requests.memory   | Initial memory requested for the master (see [Resources Required](#resources-required)). | `2048Mi` |
| master.resources.limits.cpu        | CPU limit for the master (see [Resources Required](#resources-required)).| `2` |
| master.resources.limits.memory     | Memory limit for the master (see [Resources Required](#resources-required)).|  `2048Mi` |
| master.uiEnabled       | Whether the `webgui` service must be enabled to access the cluster management console | `true` |
| master.egoRestEnabled       | Whether the `egorest` service must be enabled to access the RESTful APIs for resource management | `false` |
| master.symRestEnabled       | Whether the `symrest` service must be enabled to access the RESTful APIs for client workload submission | `false` |
| compute.replicaCount     | Number of pod replicas for compute  | `1`  |
| compute.usePodAutoscaler      | Whether autoscaling must be enabled for compute host pods, enabling the number of compute pods to be automatically scaled based on a CPU utilization threshold. To use a set number of compute hosts, deselect this option.  | `true` |
| compute.resources.requests.cpu     | Initial CPU requested for compute (see [Resources Required](#resources-required)).  | `1` |
| compute.resources.requests.memory  | Initial memory requested for compute (see [Resources Required](#resources-required)).| `1024Mi` |
| compute.resources.limits.cpu       | CPU limit for compute (see [Resources Required](#resources-required)).| `1` |
| compute.resources.limits.memory    | Memory limit for compute (see [Resources Required](#resources-required)).| `1024Mi` |
| compute.minReplicas      | Minimum number of deployment replicas for compute | `1` |
| compute.maxReplicas      | Maximum number of deployment replicas for compute | `64` |
| compute.targetCPUUtilizationPercentage| When autoscaling is enabled ('compute.usePodAutoscaler' set to true), target CPU utilization threshold (in percentage) on compute host pods | `70` |

## Accessing IBM Spectrum Symphony

The IBM Spectrum Symphony application consists of the following key services on the master and client containers, through which you access the IBM Spectrum Symphony cluster and submit workload:

- The `webgui` service hosts the cluster management console at https://*webgui_node_ip*:*webgui_node_port*/platform.  When the login page appears, use the default credentials for the built-in cluster administrator to log in (user name 'Admin',  password 'Admin'). After logging in, explore and start using IBM Spectrum Symphony. For more information, see [Cluster management console](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/foundations_sym/platform_management_console_overview.html).

- The `egorest` service ('master.egoRestEnabled' set to true) hosts the REST APIs for resource management at https://*egorest_node_ip*:*egorest_node_port*/platform/rest/ego/v1/ and corresponds to the `REST` service in IBM Spectrum Symphony. For more information, see [RESTful API reference for EGO](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/development_sym/api_container_rest_ego.html).

- The `symrest` service ('master.symRestEnabled' set to true) hosts the REST APIs for client workload submission at the base URL https://*symrest_node_ip*:*symrest_node_port*/platform/rest/symrest/. Use any REST API client (for example, cURL or a browser-based plug-in) to submit API calls for authentication and to submit workload from the client to the cluster. For more information, see [RESTful API reference for client workload submission](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/api/rest/api_container_symrest.html).

- The `sshd` service ('client.enabled' set to true) enables SSH access to the client in order to submit and retrieve workload from the client to the cluster. Use any SSH client program to log in to the client host as the cluster administrator by using the command "ssh egoadmin@*sshd_node_ip* -p *sshd_node_port*". If you use a private key that is not your default (~/.ssh/id_rsa), add "-i *ssh_key*" to the command to explicitly specify the private key.

## Uninstalling the Chart

To uninstall or delete the "my-release" deployment, use the following command:

```bash
$ helm delete my-release --purge --tls
```

This command removes all the Kubernetes components associated with the chart and deletes the release.

**NOTE**: If you used pre-existing PersistentVolumes whose reclaim policy is set to Retain, deleting the deployment deletes the PersistentVolumeClaim but not the PersistentVolume. When you delete one IBM Spectrum Symphony deployment and subsequently deploy others, hosts associated with the deleted deployment show up as unavailable hosts in the IBM Spectrum Symphony console.

## Limitations
* Supported platforms are `amd64` and `ppc64le`.
* There is no limitation on number of Symphony deployments in the cluster
* PersistentVolumeClaim uses RWX (ReadWriteMany) permission
* For Symphony version upgrade and rollback it's recommended to re-deploy Symphony cluster
* Shared mount (PersistentVolumeClaim) could be reused for HA
* To backup or recovery Symphony, use data on allocated PersistentVolumeClaim

## Documentation
* [IBM Spectrum Symphony for analytic workload management](https://www.ibm.com/us-en/marketplace/analytics-workload-management)
* [IBM Spectrum Symphony in the online IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/install_grid_sym/symphony_icp.html)
