# WebSphere Liberty Helm Chart
WebSphere Liberty is a fast, dynamic, easy-to-use Java EE application server. Ideal for developers but also ready for production, Liberty is a combination of IBM technology and open source software, with fast startup times (<2 seconds), and a simple XML configuration. All in a package that’s <70 MB to download. You can be developing applications in no time. With a flexible, modular runtime you can download additional features from the Liberty Repository or strip it back to the bare essentials for deployment into production environments. Everything in Liberty is designed to help you get your job done how you want to do it.

## Requirements

A persistent volume is required, if you plan on using the transaction service within Liberty. The server.xml Liberty configuration document must be configured to place the transaction log on this volume so that it will survive the server restarting upon failure.


## Accessing Liberty

From a browser, use http://*external ip*:*nodeport* to access the application.

## Configuration

### Parameters

The helm chart has the following values that can be overriden using the --set parameter. For example:

*    `helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/`
*    `helm install --name liberty2 --set resources.constraints.enabled=true --set autoscaling.enabled=true --set autoscaling.minReplicas=2 ibm-charts/ibm-websphere-liberty --debug`

##### Common Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| image     | pullPolicyImage | Image Pull Policy | Always, Never, or IfNotPresent. Defaults to Always if :latest tag is specified, or IfNotPresent otherwise  |
|           | name         | Name of image, including repository prefix (if required) | see Extended description of Docker tags |
|           | tag          | Docker image tag | see Docker tag description |
| tranlog.persistence | enabled | Specify whether a persistent volume claim is required to hold the WebSphere transaction log. To be use the volume name must by associated with the transaction logfile name in the server.xml for the server. See (See [transaction log](https://www.ibm.com/support/knowledgecenter/en/SSD28V_8.5.5/com.ibm.websphere.wlp.core.doc/autodita/rwlp_metatype_core.html#mtFile139) for how to configure the transaction log location.  |   false or true     |             
|           | existingClaimName | Name of specific pre-created Persistence Volume Claim (PVC) | |
|           | storageClassName  | StorageClass pre-created by the Kubernetes sysadmin. | |
|           | accessMode        | How many pods can be accessing the volume at once | The transaction log assumes that only a single pod can be reading and writing to it at once. "ReadWriteOnce"|
|           | size              | Size of the volume to hold the transaction log | Size in Gi (default is 1Gi) |
| service   | name         | the name of the service  | |
|           | type          | Specify type of service | Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. see Publishing services - service types |
|           | port          | The port that this container exposes.  |   |
|           | targetPort  | Port that will be exposed externally by the pod | |
| resources | constraints.enabled    | Specifies whether the resource constraints specified in this helm chart are enabled.   | false (default) or true  |
|  | limits.cpu    | Describes the maximum amount of CPU allowed. | Default is 500m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu)  |
|           | limits.memory | Describes the maximum amount of memory allowed. | Default is 512Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 500m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required - if not specified will default to limit (if specified) or otherwise implementation-defined value. | Default is 512Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
| replicaCount |     |  Describes the number of desired replica pods running at the same time | Default is 1.  See [Replica Sets](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset) |
| autoscaling | enabled | Specifies whether or not a horizontal pod autoscaler (HPA) is deployed.  Please note that enabling this field will disable the `replicaCount` field | false (default) or true |
|     |  minReplicas  | Lower limit for the number of pods that can be set by the autoscaler.   |  Positive integer (default to 1)  |
|     |  maxReplicas  | Upper limit for the number of pods that can be set by the autoscaler.  Cannot be lower than `minReplicas`.   |  Positive integer (default to 10)  |
|     |  targetCPUUtilizationPercentage  | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods.  |  Integer between 1 and 100 (default to 50)  |
| ingress  |  enabled        | Specifies whether or not to use ingress.        |  false (default) or true  |
|          |  rewriteTarget  | Specifies ingress.kubernetes.io/rewrite-target  | See Kubernetes ingress.kubernetes.io/rewrite-target - https://github.com/kubernetes/ingress/blob/master/controllers/nginx/configuration.md#rewrite  |
|          |  path           | Specifies the path for the ingress http rule    |  See Kubernetes - https://kubernetes.io/docs/concepts/services-networking/ingress/  |


##### Configuring Liberty within IBM Cloud Private

See [Liberty information center](https://www.ibm.com/support/knowledgecenter/en/SSD28V_8.5.5/com.ibm.websphere.wlp.core.doc/ae/cwlp_core_welcome.html) for configuration options for deploying the Liberty server, including things like configuring the transaction log for availability.
