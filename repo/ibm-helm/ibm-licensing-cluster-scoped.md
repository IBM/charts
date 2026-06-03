# OLM-based deployment to a Helm-based deployment migration chart

**Important:**
- If you are using the IBM Licensing Operator as part of an IBM Cloud Pak, see the documentation for that IBM Cloud Pak to learn more about how to install and use the operator service. For the link to your IBM Cloud Pak documentation, see [IBM Cloud Paks that use Common Services](https://ibm.biz/BdyGwb).
- If you are using a stand-alone IBM Container Software, you can use the IBM Licensing Operator directly. For more information, see [ibm-licensing-operator for stand-alone IBM Containerized Software](https://ibm.biz/BdyGwh).

**IBM Licensing Operator overview**

IBM Licensing Operator installs License Service. You can use License Service to collect information about license usage of IBM Containerized products and IBM Cloud Paks per cluster. You can retrieve license usage data through a dedicated API call and generate an audit snapshot on demand.

**Supported platforms**

Red Hat OpenShift Container Platform 4.10 or newer installed on Linux x86_64, Linux on Power (ppc64le), Linux on IBM Z and LinuxONE.

**Prerequisites**

Prerequisites depend on the integration of the License Service with an IBM Cloud Pak or IBM Containerized Software. For more information, see the applicable IBM Cloud Pak documentation or [ibm-licensing-operator for stand-alone IBM Containerized Software](https://ibm.biz/BdyGwh).

---

To facilitate the migration from an OLM-based deployment to a Helm-based deployment, a dedicated migration Helm chart is introduced. It runs job that removes following resources:
- Subscriptions,
- CSVs,
- OperatorGroups
- Roles, RoleBindings, ServiceAccounts

## How to use

```bash
helm install ibm-licensing ./helm-migration --namespace ibm-licensing --take-ownership # Run migration job, that will remove OLM resources
helm upgrade ibm-licensing ./deploy/argo-cd/components/license-service/helm-cluster-scoped --namespace ibm-licensing --take-ownership # Install LS using helm charts
```
