# ibm-kerify-dev

## Introduction

This chart provides end-to-end test suites to check/validate ICP installation/configuration. It can be used to validate the status of ICP after installation or upgrade. This chart will generate a report about the test result. The ICP cluster is healthy when the passing rate is 100%.

## Chart Details

This chart completes the following tasks:

- Create a deployment with one pod on the kubernetes cluster to run the end-to-end test cases.
- Create a service to connect to the allure server to generate report based on the test result

## Prerequisites

- A user with ClusterAdministrator role is required to install the chart.
- Kubernetes v1.13.5 or newer cluster with RBAC (Role-Based Access Control) enabled is required.
- Tiller v2.12.3 or newer is required

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.


* Custom PodSecurityPolicy definition:

```
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-kerify-psp
spec:
  allowedCapabilities:
  - AUDIT_WRITE
  - CHOWN
  forbiddenSysctls:
  - '*'
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - emptyDir
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-kerify-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-kerify-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
  ```

#### Configuration scripts can be used to create the required resources

  Download the following scripts located at [/ibm_cloud_pak/pak_extensions/pre-install](https://github.com/IBM/charts/tree/master/stable/ibm-kerify-dev/ibm_cloud_pak/pak_extensions/pre-install) directory.

  * The pre-install instructions are located at `clusterAdministration/createSecurityClusterPrereqs.sh` for cluster admins to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

  * The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team admin/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
    * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

  #### Configuration scripts can be used to clean up resources created

  Download the following scripts located at [/ibm_cloud_pak/pak_extensions/post-delete](https://github.com/IBM/charts/tree/master/stable/ibm-keirfy-dev/ibm_cloud_pak/pak_extensions/post-delete) directory.

  * The post-delete instructions are located at `clusterAdministration/deleteSecurityClusterPrereqs.sh` for cluster admins to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

  * The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team admin/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
    * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`

## Resources Required

The chart deploys pods that consume minimum resources as specified in the resources configuration parameter.

## Installing the Chart

   To install the ibm-kerify-dev chart with the release name `my-ibm-kerify` in namespace `kube-system`:
   ```
   $ helm install --tls stable/ibm-kerify-dev --name my-ibm-kerify --namespace kube-system
   ```
The command deploys the chart on the Kubernetes cluster with the default configuration.

Tip: Use the "helm list --tls" option to view a list of releases.

## Verifying the Chart

See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: ```helm status my-release --tls```.

## Configuration

The following table lists the configurable parameters of the ibm-kerify-dev chart and their default values. Specify each parameter using the "--set key=value[,key=value]" argument to the "helm install --tls" command.

Tip: Alternatively, provide a YAML file that specifies the values for the parameters while installing the chart. You can use the default values.yaml file.

| Parameter | Description | Default |
| --------- | ----------- |  ------- |
| `image.repository` | Specifies the image location | `ibmcom/bats-test` |
| `image.tag` | Specifies the image version | `3.2.0` |
| `image.pullPolicy` | Pull policy for the IBM Sert bats image | `IfNotPresent` |
| `resources.requests.cpu` | Initial CPU requested for deployment | `{requests.cpu: 100m}` |
| `resources.requests.memory` | Initial memory requested for deployment | `{requests.memory: 100Mi}` |
| `resources.limits.cpu` | CPU limit for deployment | `{requests.cpu: 512m}` |
| `resources.limits.memory` | Memory limit for the deployment | `{requests.memory: 1024Mi}` |


## Uninstalling the Chart

To uninstall/delete the `my-ibm-kerify` release, use the following command:
```
$ helm delete my-ibm-kerify --tls
```
The command removes all the Kubernetes components associated with the chart and deletes the release.

To uninstall/delete the `my-ibm-kerify` release completely and make its name free for later use:
```
$ helm delete my-ibm-kerify --purge --tls
```

## Limitations

- Currently, only one instance of ibm-kerify-dev can be installed on a cluster at a time
- Currently, the test report can be accessed only when all test are done .

## Troubleshooting
- If the passing rate is not 100% in the test report, please connect us through slack channel #ibm-icp-kerify-dev for further investigation.
