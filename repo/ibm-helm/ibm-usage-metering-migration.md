# OLM-based deployment to a Helm-based deployment migration chart

To facilitate the migration from an OLM-based deployment to a Helm-based deployment, a dedicated migration Helm chart is introduced. It runs a job that removes the following resources:
- Subscriptions,
- CSVs,
- Operator Deployment
- Roles, RoleBindings, ServiceAccounts

Note: Migration from multiple instances is not supported. If you have UMS instances deployed across multiple namespaces (e.g. `product-namespace-1` and `product-namespace-2`), migration to a Helm-based deployment is not possible.

## How to use

```bash
helm install ibm-usage-metering ./helm-migration --namespace ibm-usage-metering --take-ownership # Run migration job, that will remove OLM resources
helm install ibm-usage-metering-cluster-scoped ./helm-cluster-scoped --namespace ibm-usage-metering --take-ownership # Install UMS cluster scoped resources
helm upgrade ibm-usage-metering ./helm --namespace ibm-usage-metering --take-ownership # Install UMS
```
