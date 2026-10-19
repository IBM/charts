# Helm-based deployment of IBM Licensing Service (ILS) namespace-scoped resources

**Important:**
- If you are using the IBM Licensing Operator as part of an IBM Cloud Pak, see the documentation for that IBM Cloud Pak to learn more about how to install and use the operator service. For the link to your IBM Cloud Pak documentation, see [IBM Cloud Paks that use Common Services](https://ibm.biz/BdyGwb).
- If you are using a stand-alone IBM Container Software, you can use the IBM Licensing Operator directly. For more information, see [ibm-licensing-operator for stand-alone IBM Containerized Software](https://ibm.biz/BdyGwh).

## IBM Licensing Operator overview

IBM Licensing Operator installs License Service. You can use License Service to collect information about license usage of IBM Containerized products and IBM Cloud Paks per cluster. You can retrieve license usage data through a dedicated API call and generate an audit snapshot on demand.

## Supported platforms

Red Hat OpenShift Container Platform 4.10 or newer installed on Linux x86_64, Linux on Power (ppc64le), Linux on IBM Z and LinuxONE.

## Prerequisites

The cluster-scoped resources (CRDs, ClusterRoles, ClusterRoleBindings) must be installed first
via the companion `ibm-licensing-cluster-scoped` chart. For more information, see the applicable
IBM Cloud Pak documentation or [ibm-licensing-operator for stand-alone IBM Containerized Software](https://ibm.biz/BdyGwh).

---

## Chart contents

This chart installs **namespace-scoped resources** for the IBM Licensing Operator:

- **Deployment** – the operator pod
- **ServiceAccounts** – `ibm-licensing-operator`, `ibm-license-service`, `ibm-license-service-restricted`, `ibm-licensing-default-reader`
- **Roles / RoleBindings** – namespace-scoped RBAC for the operator and operand service accounts
- **Roles / RoleBindings in watched namespaces** – per-namespace watch RBAC when `nssEnabled` is true
- **IBMLicensing CR** – the operand configuration custom resource

## How to use

```bash
# Step 1 – cluster-scoped resources (install once per cluster)
helm install ibm-licensing-cluster-scoped ./helm-cluster-scoped --namespace ibm-licensing --create-namespace

# Step 2 – namespace-scoped resources (install per tenant namespace)
helm install ibm-licensing ./helm --namespace ibm-licensing
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imagePullPrefix` | Image registry prefix | `icr.io` |
| `global.imagePullSecret` | Image pull secret name | `ibm-entitlement-key` |
| `global.licenseAccept` | Accept IBM license agreement | `true` |
| `ibmLicensing.namespace` | Namespace where the operator and operand are installed | `ibm-licensing` |
| `ibmLicensing.watchNamespace` | Namespace the operator watches for IBMLicensing CRs | `ibm-licensing` |
| `ibmLicensing.excludeNamespace` | Comma-separated list of namespaces to exclude from license collection | `""` |
| `ibmLicensing.imageRegistryNamespaceOperator` | Operator image registry namespace | `cpopen` |
| `ibmLicensing.imageRegistryNamespaceOperand` | Operand image registry namespace | `cpopen/cpfs` |
| `ibmLicensing.createRBAC` | Create RBAC resources required by the chart | `true` |
| `ibmLicensing.createRBACInWatchedNamespaces` | Create RBAC resources in each watched namespace | `true` |
| `ibmLicensing.spec` | Custom IBMLicensing resource specification (merged into the CR) | `{}` |
| `ibmLicensing.spec.features.nssEnabled` | Enable namespace-scope support | `false` |
| `ibmLicensing.spec.features.nodeCpuCappingEnabled` | Enable node CPU capping | `true` |
| `ibmLicensing.spec.features.kubeRBACAuthEnabled` | Enable kube RBAC authentication | `true` |
| `ibmLicensing.spec.features.operandRequestsEnabled` | Enable operand requests | `true` |
| `ibmLicensing.spec.features.customResourcesEnabled` | Enable custom resources | `true` |
| `ibmLicensing.operator.podAnnotations` | Extra annotations added to the operator pod. IBM product annotations cannot be overridden | `{}` |
| `ibmLicensing.operator.podLabels` | Extra labels added to the operator pod. IBM selector labels cannot be overridden | `{}` |
| `ibmLicensing.operator.affinity` | Additional affinity rules merged with the IBM default `kubernetes.io/arch` node affinity | `{}` |
| `ibmLicensing.operator.nodeSelector` | Node selector for the operator pod | `{}` |
| `ibmLicensing.operator.serviceAccount.name` | Override the operator service account name. Use with `createRBAC: false` for pre-created service accounts | `""` |
| `ibmLicensing.operator.annotations` | *(Legacy)* Extra annotations for the operator pod — use `operator.podAnnotations` instead | `{}` |
| `ibmLicensing.operator.labels` | *(Legacy)* Extra labels for the operator pod — use `operator.podLabels` instead | `{}` |
| `ibmLicensing.operand.serviceAccount.name` | Override the active operand service account name (`ibm-license-service` or `ibm-license-service-restricted` depending on `nssEnabled`) | `""` |
| `ibmLicensing.operand.podAnnotations` | Extra annotations added to the operand pod. IBM product annotations cannot be overridden | `{}` |
| `ibmLicensing.operand.podLabels` | Extra labels added to the operand pod. IBM selector labels cannot be overridden | `{}` |
| `ibmLicensing.operand.affinity` | Additional affinity rules merged with the IBM default `kubernetes.io/arch` node affinity for the operand pod | `{}` |
| `ibmLicensing.operand.nodeSelector` | Node selector for the operand pod | `{}` |
