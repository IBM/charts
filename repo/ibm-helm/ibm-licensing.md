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
