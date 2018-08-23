THIS CHART IS NOW DEPRECATED
=============================
As of September 1, 2018, the ibm-spectrum-symphony Helm chart for IBM Spectrum Symphony Community Edition will no longer be supported. This chart will be removed from the IBM public Helm repository on github.com and will no longer show in the Catalog. Existing deployments of the Helm chart, however, will not be affected. To deploy IBM Spectrum Symphony Community Edition afresh, use the ibm-spectrum-symphony-dev replacement chart.



[![IBM Spectrum Symphony](https://developer.ibm.com/storage/wp-content/uploads/sites/91/2016/08/SpectrumSymphonyIcon-1.jpg)](https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=46ecec34-bd69-43f7-a627-7c469c1eddf8).

IBM Spectrum Symphony is an enterprise-class workload manager for compute- and data-intensive applications on a scalable, shared grid. It accelerates dozens of distributed parallel applications for faster results and better utilization of all available resources.
## Introduction

IBM Spectrum Symphony provides a fast, efficient grid and analytic computing environment. Within IBM Cloud Private, IBM Spectrum Symphony is available as a no-charge customer-managed Community Edition. The Community Edition provides the full functionality of IBM Spectrum Symphony for a cluster of up to 64 cores.

You can deploy IBM Spectrum Symphony as a Helm Chart in IBM Cloud Private to quickly configure and run IBM Spectrum Symphony as a Docker container application in a Kubernetes cluster. You can then manage the IBM Spectrum Symphony application from the cluster management console or the CLI in IBM Cloud Private.

> **Tip**: The Community Edition of IBM Spectrum Symphony is restricted to 64 cores. To scale your cluster beyond 64 cores and receive IBM Support tied to licensed software, consider upgrading your entitlement to IBM Spectrum Symphony Advanced Edition. For more information, see [IBM Spectrum Symphony for analytic workload management](https://www.ibm.com/us-en/marketplace/analytics-workload-management).

## Prerequisites

- A default storageClass is set up during the IBM Cloud Private installation or created before deployment by the Kubernetes System Administrator.
- If not using dynamic provisioning, Persistent Volumes must be re-created and set up with labels that can be used to refine the Kubernetes PVC bind proc.

This ibm-spectrum-symphony chart is written to support the following storage use cases:
- Persistent storage using Kubernetes dynamic provisioning. Uses the default storageclass defined by the Kubernetes System Administrator or uses a custom storageclass which will override the default.
  - Set global values to cluster.pvc.useDynamicProvisioning: true (default).
  - Specify a custom storageClassName per volume or leave the value empty to use the default storageClass.
- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume set up before deployment of this chart.
  - Set global values to cluster.pvc.useDynamicProvisioning: false.
  - Specify an existingClaimName per volume or leave the value empty and let the Kubernetes binding process select a pre-existing volume based on the accessMode and size. Use selector labels to refine the binding process.

For other requirements (such as browsers), see [supported systems configurations](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.0/sym_kc/sym_kc_system_configurations.html) in the online IBM Knowledge Center.

## Installing the Chart

To install IBM Spectrum Symphony as a chart with the release name "my-release", use the following command:

```bash
$ helm install --name my-release stable/ibm-spectrum-symphony
```

> **Tip**: Use the "helm list" option to view a list of releases.

The install command deploys ibm-spectrum-symphony in the Kubernetes cluster with the default configuration; customize these parameters as required during installation. For more information, see the [configuration](#configuration) section.

After deployment, you can access the IBM Spectrum Symphony cluster management console (webgui) from a browser; use the default credentials (Admin/Admin) for login. Refer to the *NOTES.txt* file to determine the webgui URL.

To learn more about using IBM Spectrum Symphony, see the online [IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.0/sym_kc_welcome.html).

## Accessing IBM Spectrum Symphony

IBM Spectrum Symphony in IBM Cloud Private uses the following key HTTPS services:

- The `webgui` service hosts the cluster management console (available at https://*host_master*:*port*/platform). For more information, see [Cluster management console](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.0/foundations_sym/platform_management_console_overview.html).

  After logging in to the cluster management console, if you encounter an error in a pop-up window, safely ignore the error to continue.

- The `egorest` service in the IBM Spectrum Symphony application corresponds to the `REST` service in IBM Spectrum Symphony. It hosts the REST APIs for resource management (available at https://*host_master*:*port*/platform/rest/ego/v1/). For more information, see [RESTful API reference for EGO](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.0/development_sym/api_container_rest_ego.html).
- The `symrest` service hosts the REST APIs used to submit workload from an IBM Spectrum Symphony client (available at https://*host_master*:*port*/platform/rest/symrest/v1/clientapi/). For more information, see [RESTful API reference for client workload submission](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.0/api/rest/api_container_symrest.html).
- The `ssh` service allows access to an IBM Spectrum Symphony client host in order to run client applications from within the cluster.

## Verifying the Chart

For verification instructions, see the *NOTES.txt* file associated with this chart.

## Uninstalling the Chart

To uninstall or delete the "my-release" deployment, use the following command:

```bash
$ helm delete my-release
```

This command removes all Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the parameters configurable for the ibm-spectrum-symphony chart. To modify the default values, specify each parameter using the "--set key=value[,key=value]" argument to "helm install". 

> **Tip**: Alternatively, provide a YAML file that specifies the values for the parameters while installing the chart. You can use the default *values.yaml* file.


| Parameter                  | Description                                     |
| -----------------------    | ---------------------------------------------   |
| image.repository         | Repository for the IBM Spectrum Symphony image        |
| image.pullPolicy         | Policy used to pull the image; Always if image.Tag is latest, otherwise IfNotPresent.      |
| image.tag                | Tag for the IBM Spectrum Symphony image               |
| clusterName              | Name of the IBM Spectrum Symphony cluster             | 
| enableSSHD               | Enable the SSH daemon on management and compute nodes |
| cluster.pvc.size         | Size of the shared storage                       |
| cluster.pvc.useDynamicProvisioning | Use Dynamic provisioning for shared storage                       |
| cluster.pvc.storageClassName       | Storage class name                       |
| cluster.pvc.existingClaimName      | Existing claim name                      |
| cluster.pvc.selector.label         | Selector label for shared storage    |
| cluster.pvc.selector.value         | Selector name for shared storage     |
| master.replicaCount      | Number of deployment replicas for master        | 
| regenSSLCert           | Regenerate SSL certificate using a new host name and domain |                     
| master.uiEnabled       | Enable WEB GUI service |
| master.egoRestEnabled       | Enable EGO REST service |
| master.symRestEnabled       | Enable SYM REST service |
| master.resources.requests.memory   | Memory resource requests on master              |
| master.resources.requests.cpu      | CPU resource requests on master                 |
| master.resources.limits.memory     | Memory resource limits on master                |
| master.resources.limits.cpu        | CPU resource limits on master                   |
| compute.replicaCount     | Number of deployment replicas for compute       |
| compute.resources.requests.memory  | Memory resource requests on compute             |
| compute.resources.requests.cpu     | CPU resource requests on compute                |
| compute.resources.limits.memory    | Memory resource limits on compute               |
| compute.resources.limits.cpu       | CPU resource limits on compute                  |
| compute.minReplicas      | Minimum number of replicas on compute           |
| compute.maxReplicas      | Maximum number of replicas on compute           |
| compute.usePodAutoscaler      | Enable horizontal autoscaling of compute host pods           |
| compute.targetCPUUtilizationPercentage| Target CPU utilization percentage on compute host pods |
| client.replicaCount      | Number of deployment replicas for client        |
