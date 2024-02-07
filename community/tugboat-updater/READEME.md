# About tugboat-updater

`tugboat-updater` is a service created to automate worker updates for IKS and ROKS clusters. The service runs as an agent inside the cluster and uses node data for minimal state management. The configuration for tugboat-updater is based around the idea that there are groups of worker pools within a cluster that have independent workloads with unique disruption budgets. `tugboat-updater` can be configured with a list of `groups`, each `group` has a name, a list of worker pools, and a concurrent update limit.

## Node Prioritization
When the updater finds a set of workers that are eligible for an update it sorts the nodes in order of priority. The comparison used to sort nodes is:

1. Nodes with a failed update are prioritized `AFTER` nodes with no failed updates
1. Nodes that are cordoned are prioritized `BEFORE` nodes that are not cordoned
1. Nodes with a pending update are prioritized `BEFORE` nodes with no pending update
1. The Node the updater is running on is prioritized `AFTER` other nodes
1. Nodes with an older version are prioritized `BEFORE` nodes with a newer version

## Usage

Tugboat-updater requires an API key with Kubernetes Service Manager permissions and Platform Viewer permissions. See [this documentation](https://cloud.ibm.com/docs/containers?topic=containers-access_reference#cluster_create_permissions) for details on the permissions needed to manage IKS clusters. IBM Cloud provides an integration between IKS and Secrets Manager for persisting an IAM credential in your cluster that can be used with tugboat-updater. See [this guide](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-iam-credentials&interface=ui) for details on creating a credential with Secrets Manager, and [this documentation](https://cloud.ibm.com/docs/containers?topic=containers-secrets#non-tls) for details on how to create a corresponding Kubernetes secret.

To use the example `values.yaml` file from this repo with the chart, ensure you replace `<< CLUSTER_ID >>` with the clusterID of the cluster you are deploying the chart to, and replace `<< REGION >>` with the region the cluster resides in. See the `tugboatUpdaterConfig` section of the `values.yaml` for details on how to configure maintenance windows or worker-pool group rules. 

