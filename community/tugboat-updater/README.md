# About tugboat-updater

`tugboat-updater` is a service created to automate worker updates for IKS and ROKS clusters. The service runs as an agent inside the cluster and uses node data for minimal state management. The configuration for tugboat-updater is based around the idea that there are groups of worker pools within a cluster that have independent workloads with unique disruption budgets. `tugboat-updater` can be configured with a list of `groups`, each `group` has a name, a list of worker pools, and a concurrent update limit.

## Worker Groups
All workerpools of a cluster are assigned to a `group` by the updater on startup. If multiple group configurations match the same workerpool, the workerpool will be assigned to the first matching group in configuration order. All workerpools not assigned to configured groups will be added to a `Default` group that will have a concurrent update limit of `1`. 

If changes to the workerpool layout of the cluster are detected during runtime the updater will restart to pick up these changes. 

## Worker Selection
When the updater finds a set of workers that are eligible for an update it sorts the workers in order of priority. The comparison used to sort workers is:

1. (If configured) Workers with a lower value returned by their `node_priority_query` are prioritized `BEFORE` workers with a higher value
1. Workers with a failed update are prioritized `AFTER` workers with no failed updates
1. Workers that are cordoned are prioritized `BEFORE` workers that are not cordoned
1. Workers with a pending update are prioritized `BEFORE` workers with no pending update
1. The Worker the updater is running on is prioritized `AFTER` other workers
1. Workers with an older version are prioritized `BEFORE` workers with a newer version

### Availability Zones
Workers will only be considered eligible for an update if all workers in all other availability zones are available (workerpools are balanced and workers are `Ready` and not undergoing an update). The updater determines availability zones from the `topology.kubernetes.io/zone` node label or the `location` returned by the Container Service API if the label is not defined or set to an empty string `""`.

## Update Process
When `tugboat-updater` updates a worker it performs the following actions:
1. Cordons the worker
    - Equivalent of `kubectl cordon NODE_NAME` (applies the `node.kubernetes.io/unschedulable` taint)
1. Drains the worker
    - Equivalent of `kubectl drain NODE_NAME` (removes all pods from the node using the [Eviction API](https://kubernetes.io/docs/concepts/scheduling-eviction/api-eviction/))
1. (If Classic) Updates the worker
    - Calls the Container Service API `/v1/clusters/{idOrName}/workers/{workerId}`
1. (If Classic) Reloads the worker
    - Calls the Container Service API `/v1/clusters/{idOrName}/workers/{workerId}`
1. (If VPC) Replaces the worker
    - Calls the Container Service API `/v2/vpc/replaceWorker`
1. (If Classic) Wait for the reload to complete then Uncordon the worker
    - Equivalent of `kubectl uncordon NODE_NAME` (Removes the `node.kubernetes.io/unschedulable` taint)

## Usage

Tugboat-updater requires an API key with Kubernetes Service Manager permissions and Platform Viewer permissions. See [this documentation](https://cloud.ibm.com/docs/containers?topic=containers-access_reference#cluster_create_permissions) for details on the permissions needed to manage IKS clusters. IBM Cloud provides an integration between IKS and Secrets Manager for persisting an IAM credential in your cluster that can be used with tugboat-updater. See [this guide](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-iam-credentials&interface=ui) for details on creating a credential with Secrets Manager, and [this documentation](https://cloud.ibm.com/docs/containers?topic=containers-secrets#non-tls) for details on how to create a corresponding Kubernetes secret.

To use the example `values.yaml` file from this repo with the chart, ensure you replace `<< CLUSTER_ID >>` with the clusterID of the cluster you are deploying the chart to, and replace `<< REGION >>` with the region the cluster resides in. See the `tugboatUpdaterConfig` section of the `values.yaml` for details on how to configure maintenance windows or worker-pool group rules. 

