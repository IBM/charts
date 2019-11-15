# secret-sync-operator

IBM [secret-sync-operator](https://github.com/IBM-Cloud/kube-samples/blob/master/secret-sync-operator/) is a K8s Operator that helps keep secrets in sync across multiple namespaces.

## Add repo

```console
$ helm repo add ibm-community https://raw.githubusercontent.com/IBM/charts/master/repo/community
```

## Install

```console
$ helm install secret-sync-operator ibm-community/secret-sync-operator --namespace default
```

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options:

```console
$ helm show values ibm-community/secret-sync-operator
```

## RBAC

The `rbac.create` default `true` will create RBAC resources:

- A ClusterRole that defines access to full access to Secrets resource type in the cluster and read access to Namespaces, Pods, and ReplicaSets. This is the minimum required access for the operator to do it's function
- A ClusterRoleBinding that binds the created ClusterRole to the operator's service account

If configured to `false`, you must manually ensure your configured service account has the required access above for the operator to function.

## Uninstall

```console
$ helm uninstall secret-sync-operator
```

## Support

- Application support: for [secret-sync-operator GitHub repo](https://github.com/IBM-Cloud/kube-samples/issues)
- Chart support: ping `maintainers` from [Chart.yaml](./Chart.yaml) in [IKS Slack](https://ibm-container-service.slack.com) `#secert-sync-operator` channel ([get invite here](https://cloud.ibm.com/kubernetes/slack))
