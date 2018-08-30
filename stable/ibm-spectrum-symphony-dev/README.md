# ibm-spectrum-symphony-dev

[![IBM Spectrum Symphony CE](https://developer.ibm.com/storage/wp-content/uploads/sites/91/2016/08/SpectrumSymphonyIcon-1.jpg)](https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=46ecec34-bd69-43f7-a627-7c469c1eddf8) IBM Spectrum Symphony is an enterprise-class workload manager for compute- and data-intensive workload on a scalable, shared grid. It provides an efficient computing environment for dozens of distributed parallel applications to deliver faster results and better resource utilization.

## Introduction

This chart deploys IBM Spectrum Symphony Community Edition on a Kubernetes cluster using the Helm package manager. It enables you to quickly configure and run IBM Spectrum Symphony as a Docker container application, which you can then manage from the cluster management console or the command line.

The IBM Spectrum Symphony Community Edition chart provides the full functionality of IBM Spectrum Symphony for a cluster of up to 64 cores. To scale your cluster beyond 64 cores and receive IBM Support tied to licensed software, consider deploying the "ibm-spectrum-symphony-prod" chart.

## Chart Details

This chart deploys IBM Spectrum Symphony Community Edition with the following standard configuration:
* Creates a deployment with one pod (one master, compute, and client container each) on the Kubernetes cluster.
* Provisions storage volumes dynamically based on storage class to automatically bind the PersistentVolume to the PersistentVolumeClaim.
* Creates a `webgui` service to connect to the application's cluster management console from a supported browser. 
* Creates an `sshd` service to connect to the client over SSH and submit workload from the client to the cluster.  

## Prerequisites

- A default storage class must be set up by the system administrator for dynamic storage provisioning before this chart is deployed. With dynamic storage provisioning (default), storage volumes are provisioned on demand based on the storage class. 
  - Set 'cluster.pvc.useDynamicProvisioning' to true (default).
  - Specify a custom 'storageClassName' per volume or leave the value empty to use the default storageClass or any available PersistentVolume that can satisfy the capacity request.
  
  Volumes that are dynamically provisioned inherit the reclaim policy of their storage class (which defaults to Delete). 

- If you are not using dynamic storage provisioning, a PersistentVolumeClaim or PersistentVolume must be predefined before this chart is deployed.
  - Set 'cluster.pvc.useDynamicProvisioning' to false.
  - Specify the 'cluster.pvc.existingClaimName' per volume or leave the value empty and let the Kubernetes binding process select a pre-existing volume based on accessMode and size. 
  - Use 'cluster.pvc.selector.label' to refine the binding process.
  
  Docker container processes for IBM Spectrum Symphony run as internal user egoadmin with ID 1000. When you use pre-existing volumes, ensure that the required permissions for user ID 1000 are set for the mounted volume. 

- Review other requirements, such as supported browsers. For more information, refer to the [supported system configurations](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/sym_kc/sym_kc_system_configurations.html) in the online IBM Knowledge Center.

## Resources Required

To control decisions about which nodes to place pods on, specify how much resources (CPU and memory) each container needs:  

- The 'master.resources.requests.cpu' and 'master.resources.requests.memory' parameters define initial CPU and memory requests to create the master container. The default requests are 2 cores and 2048 MB memory, respectively. The same values are enforced in the 'master.resources.limits.cpu' and 'master.resources.limits.memory' parameters as limits for the master container.

- The 'compute.resources.requests.cpu' and 'compute.resources.requests.memory' parameters define the initial resources that each compute container requests. However, resources cannot grow beyond the limits of 'compute.resources.limits.cpu' and 'compute.resources.limits.memory'. The default requests are 1 core and 1024 MB memory for each compute container, with the same limits.

- The 'client.resources.requests.cpu' and 'client.resources.requests.memory' parameters define the initial resources that each client container requests. The default requests are 1 core and 1024 MB memory for each client container, with the same limits. 

For CPU and memory values that you can set, refer to the [Kubernetes specification](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu).
     
## Installing the Chart

To install the ibm-spectrum-symphony-dev chart with the release name "my-release", use the following command:

```bash
$ helm install --name my-release stable/ibm-spectrum-symphony-dev
```

The command deploys the chart on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

You can use unique release names to create as many IBM Spectrum Symphony deployments as you want. 

> **Tip**: Use the "helm list" option to view a list of releases.

## Verifying the Chart

For verification instructions, see the *NOTES.txt* file associated with this chart.

## Configuration

The following table lists the configurable parameters of the ibm-spectrum-symphony-dev chart and their default values. Specify each parameter using the "--set key=value[,key=value]" argument to the "helm install" command. 

> **Tip**: Alternatively, provide a YAML file that specifies the values for the parameters while installing the chart. You can use the default *values.yaml* file.

| Parameter                  | Description                         |  Default                  |
| -----------------------    | ---------------------------------   | -----------------------   |
| image.repository         | Docker repository for the IBM Spectrum Symphony image  | `ibmcom/spectrum-symphony` |
| image.tag                | Tag for the IBM Spectrum Symphony image | `latest`  |
| image.pullPolicy         | Pull policy for the IBM Spectrum Symphony image | `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| cluster.clusterName              | Name of the cluster       | `Symphony` |
| cluster.enableSSHD               | Whether the SSH daemon must be enabled internally on management and compute containers to access these  hosts from the client host when a client deployment is enabled ('client.enabled' set to true). | `false` |
| cluster.generateClusterAdminPassword | Whether a new password must be generated for the built-in cluster administrator user ('egoadmin') on each host with the SSH daemon enabled ('cluster.enableSSHD' set to true, 'client.enabled' set to true, or both). If true, a random password is generated during cluster startup and printed to the container logs. If false, the default password is 'Admin'. | `false` |
| cluster.pvc.size         | Size of the persistent storage | `5Gi` |
| cluster.pvc.useDynamicProvisioning | Whether storage volumes must be dynamically provisioned. If true, the PersistentVolumeClaim uses the storageClassName to bind the volume. If false, the selector is used to refine the binding process. | `true` |
| cluster.pvc.storageClassName       | Storage class name for dynamic storage provisioning. Specify a custom storageClassName per volume, or leave the value empty to use the default storageClass or any available PersistentVolume that can satisfy the capacity request (for example, 5Gi).  | `""` |
| cluster.pvc.existingClaimName      | If not using dynamic provisioning, name of an existing PersistentVolumeClaim. Specify an existing claim name per volume or leave the value empty and let the Kubernetes binding process select a pre-existing volume based on accessMode and size. | `""` |
| cluster.pvc.selector.label         | When matching a pre-existing PersistentVolume, the label used to find a match on the keySelector label (see [Kubernetes - Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)).  | `""` |
| cluster.pvc.selector.value         | When matching a pre-existing PersistentVolume, the value used to find a match on the values (see [Kubernetes - Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)).  | `""` | 
| master.replicaCount      | Number of deployment replicas for the master. If more than 1 master is defined, your deployment includes 1 master container and other master-candidate containers. | `1` |
| master.logsOnShared | Whether component logs must be saved to the mounted shared directory to be shared by containers across multiple worker nodes. If true, resource manager logs (EGO) are saved at /shared/logs/kernel/logs/, workload logs (SOAM) at /shared/logs/soam/logs/,  cluster management console (WEBGUI) logs at /shared/logs/gui/logs/, and reporting logs (PERF) at /shared/logs/perf/logs/.      | `true` |
| master.resources.requests.cpu      | Initial CPU requested for the master (see [Resources Required](#resources-required)). | `2` |
| master.resources.requests.memory   | Initial memory requested for the master (see [Resources Required](#resources-required)). | `2048Mi` |
| master.resources.limits.cpu        | CPU limit for the master (see [Resources Required](#resources-required)).| `2` |
| master.resources.limits.memory     | Memory limit for the master (see [Resources Required](#resources-required)).|  `2048Mi` |
| master.regenSSLCert           | Whether the SSL certificate must be regenerated using a new host name and domain | `false` |  
| master.uiEnabled       | Whether the `webgui` service must be enabled to access the cluster management console | `true` |
| master.egoRestEnabled       | Whether the `egorest` service must be enabled to access the RESTful APIs for resource management | `false` |
| master.symRestEnabled       | Whether the `symrest` service must be enabled to access the RESTful APIs for client workload submission | `false` |
| compute.replicaCount     | Number of pod replicas for compute  | `1`  |
| compute.resources.requests.cpu     | Initial CPU requested for compute (see [Resources Required](#resources-required)).  | `1` |
| compute.resources.requests.memory  | Initial memory requested for compute (see [Resources Required](#resources-required)).| `1024Mi` |
| compute.resources.limits.cpu       | CPU limit for compute (see [Resources Required](#resources-required)).| `1` |
| compute.resources.limits.memory    | Memory limit for compute (see [Resources Required](#resources-required)).| `1024Mi` |
| compute.minReplicas      | Minimum number of deployment replicas for compute | `1` |
| compute.maxReplicas      | Maximum number of deployment replicas for compute | `64` |
| compute.usePodAutoscaler      | Whether autoscaling must be enabled for compute host pods, enabling the number of compute pods to be automatically scaled based on a CPU utilization threshold. To use a set number of compute hosts, deselect this option.  | `true` |
| compute.targetCPUUtilizationPercentage| When autoscaling is enabled ('compute.usePodAutoscaler' set to true), target CPU utilization threshold (in percentage) on compute host pods | `70` |
| client.enabled | Whether a client must be deployed, enabling access to the cluster from the client node | `true`|
| client.resources.requests.cpu     | Initial CPU requested for client (see [Resources Required](#resources-required)).| `1` |
| client.resources.requests.memory  | Initial memory requested for client (see [Resources Required](#resources-required)).| `1024Mi` |
| client.resources.limits.cpu       | CPU limit for client (see [Resources Required](#resources-required)). | `1` |
| client.resources.limits.memory    | Memory limit for client (see [Resources Required](#resources-required)). |`1024Mi` |
| client.sshdPort | When client deployment is enabled ('client.enabled' set to true), port on which to expose the client's SSH daemon. If 'image.tag' is set to `7.2.0.2`, set this value to 22 for backwards compatibility. | `2222` |  

A subset of the preceding parameters map to the env variables defined in IBM Spectrum Symphony Community Edition. For more information, refer to [IBM Spectrum Symphony](https://hub.docker.com/r/ibmcom/spectrum-symphony/) image documentation.

## Accessing IBM Spectrum Symphony

The IBM Spectrum Symphony application consists of the following key services on the master and client containers, through which you access the IBM Spectrum Symphony cluster and submit workload:

- The `webgui` service hosts the cluster management console at https://*webgui_node_ip*:*webgui_node_port*/platform.  When the login page appears, use the default credentials for the built-in cluster administrator to log in (user name 'Admin',  password 'Admin'). After logging in, explore and start using IBM Spectrum Symphony. For more information, see [Cluster management console](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/foundations_sym/platform_management_console_overview.html).

- The `egorest` service ('master.egoRestEnabled' set to true) hosts the REST APIs for resource management at https://*egorest_node_ip*:*egorest_node_port*/platform/rest/ego/v1/ and corresponds to the `REST` service in IBM Spectrum Symphony. For more information, see [RESTful API reference for EGO](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/development_sym/api_container_rest_ego.html).

- The `symrest` service ('master.symRestEnabled' set to true) hosts the REST APIs for client workload submission at the base URL https://*symrest_node_ip*:*symrest_node_port*/platform/rest/symrest/. Use any REST API client (for example, cURL or a browser-based plug-in) to submit API calls for authentication and to submit workload from the client to the cluster. For more information, see [RESTful API reference for client workload submission](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/api/rest/api_container_symrest.html).

- The `sshd` service ('client.enabled' set to true) enables SSH access to the client in order to submit and retrieve workload from the client to the cluster. Use any SSH client program to log in to the client host as the cluster administrator by using the command "ssh egoadmin@*sshd_node_ip* -p *sshd_node_port*". When prompted for the password, use the default password 'Admin'. If you chose to generate a random password ('cluster.generateClusterAdminPassword' set to true), look for the 'egoadmin' password in the container logs.

## Uninstalling the Chart

To uninstall or delete the "my-release" deployment, use the following command:

```bash
$ helm delete my-release --purge
```

This command removes all the Kubernetes components associated with the chart and deletes the release.

**NOTE**: If you used pre-existing PersistentVolumes whose reclaim policy is set to Retain, deleting the deployment deletes the PersistentVolumeClaim but not the PersistentVolume. When you delete one IBM Spectrum Symphony deployment and subsequently deploy others, hosts associated with the deleted deployment show up as unavailable hosts in the IBM Spectrum Symphony console.  

## Limitations
* Supported platforms are `amd64` and `ppc64le`.
* Can be deployed only to the `default` namespace.
* Upgrading the Helm release version after chart deployment is not supported.

## Documentation
* [IBM Spectrum Symphony for analytic workload management](https://www.ibm.com/us-en/marketplace/analytics-workload-management)
* [IBM Spectrum Symphony in the online IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/install_grid_sym/symphony_icp.html)
