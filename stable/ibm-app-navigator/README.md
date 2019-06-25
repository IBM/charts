# IBM Application Navigator Helm Chart

## Introduction 

IBM Application Navigator is a tool that compliments the IBM Private Cloud console, providing visualization, inspection, and interaction with the deployed resources that comprise an application.

IBM Application Navigator is designed to satisfy a need identified by the Kubernetes Application Special Interest Group (SIG), who made the following observation and statement:  

```"Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications."```

The above description, from the [Kubernetes homepage](https://kubernetes.io/), is centered on containerized applications. Yet, the Kubernetes metadata, objects, and visualizations (e.g., within Dashboard) are focused on container infrastructure rather than the applications themselves. The Application CRD ([Custom Resource Definition](https://kubernetes.io/docs/concepts/api-extension/custom-resources/#customresourcedefinitions)) in the [Kubernetes Application](https://github.com/kubernetes-sigs/application) project aims to change that in a way that's interoperable between many supporting tools.

IBM Application Navigator provides visualization of all defined Applications, offering drill down into their respective comprised 'components'. Each component is a Kubernetes resource. Each Kubernetes resource has a 'Kind' - e.g. Deployment, Service, tWAS-App (a Kubernetes Custom Resource Definition), etc.. IBM Application Navigator offers action menu items by Kind. These menu items provide URLs and scripted commands that enable the user to navigate to, and operate, other tools in context - e.g. the log, monitor, trace, configuration page for the currently selected component.

### Resources Required

For each Docker container:
- CPU Requested : 500m (500 millicpu)
- Memory Requested : 512Mi (~ 537 MB)

Actual resource consumption will vary depending on usage. These numbers represent maximum requirements.  In practice, you will likely see lower consumption.  

### Storage

IBM Application Navigator is stateless and does not require any persistent volumes to operate.

### Chart Details

- Installs a `Deployment` running the IBM Application Navigator UI and REST API container as its backend.
- Installs a `Deployment` running the IBM Application Navigator Controller and REST API container as its backend.
- Installs a `Deployment` running the IBM Application Navigator WAS Controller.
- Installs a `Job` which executes the IBM Application Navigator Initialization container during chart installation.
- Installs a `Service` and optionally an `Ingress` to route traffic to the IBM Application Navigator UI.
- Installs multiple `ConfigMaps` that manage the configuration of IBM Application Navigator.

Note the IBM Application Navigator containers are configured to run on IBM Cloud Private's management node. 

### Prerequisites

- IBM Cloud Private 3.1.2 or greater.
- A user with Cluster administrator role is required to install the chart.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-app-navigator-psp
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-app-navigator-psp-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-app-navigator-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
  ```

#### Configuration scripts can be used to create the required resources

Download the following scripts located at /ibm_cloud_pak/pak_extensions/pre-install directory.

* The pre-install instructions are located at `clusterAdministration/createSecurityClusterPrereqs.sh` for cluster admins to create the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/createSecurityNamespacePrereqs.sh` for team admin/operator to create the RoleBinding for the namespace. This script takes one argument; the name of a pre-existing namespace where the chart will be installed.
  * Example usage: `./createSecurityNamespacePrereqs.sh myNamespace`

#### Configuration scripts can be used to clean up resources created

Download the following scripts located at /ibm_cloud_pak/pak_extensions/post-delete directory.

* The post-delete instructions are located at `clusterAdministration/deleteSecurityClusterPrereqs.sh` for cluster admins to delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

* The namespace scoped instructions are located at `namespaceAdministration/deleteSecurityNamespacePrereqs.sh` for team admin/operator to delete the RoleBinding for the namespace. This script takes one argument; the name of the namespace where the chart was installed.
  * Example usage: `./deleteSecurityNamespacePrereqs.sh myNamespace`

### Installing the Chart

To install the chart with the release name `app-nav`:
    
For example:
  ```bash
  helm install --tls ibm-charts/ibm-app-navigator --name app-nav --namespace <namespace>
  ```

To specify any extra parameters you can use the `--set` option or create a `yaml` file with the parameters and specify it using the `-f` option on the command line.

Alternatively, you can install the chart from the catalog in the IBM Cloud Private console. 

> For a complete list of supported parameters, please take a look at the table in the [Configuration](#configuration) section below.

It is recommended that the chart only be installed once per cluster. 

## Verifying the chart

To verify the chart, you need a system with kubectl and helm installed and configured.

1. Check for chart deployment information by issuing the following commands:
  ```bash
  helm list --namespace <namespace>
  helm status --tls app-nav --namespace <namespace>
  ```
    
2. Get the name of the pods that were deployed with ibm-app-navigator by issuing the following command:
  ```bash
  kubectl get pod -n <namespace>
  ```
    
3. For each of the pods, check under Events to see whether images were successfully pulled and that the containers were created and started by issuing the following command with the specific pod name:
  ```bash
  kubectl describe pod <pod name> -n <namespace>
  ```

## Uninstalling the chart

1. To uninstall the deployed chart from the IBM Cloud Private console, click Workloads -> Helm Releases.
- Find the release name and under action click delete.

2. To uninstall the deployed chart from the command line, issue the following command:
  ```bash
  helm delete --tls --purge app-nav --namespace <namespace>
  ```

### Configuration 

| Parameter | Description | Default |
|---|---|---|
| `appNavApi.repository` | Docker registry to pull the Application Navigator API image from. | `ibmcom/app-nav-api` |
| `appNavApi.tag` | Application Navigator API image tag. | `1.0.0` |
| `appNavApi.resources.constraints.enabled` | Specifies whether resource constraints are enabled for the Application Navigator API.  | `false` |
| `appNavApi.resources.requests.cpu` | The minimum required CPU core for the Application Navigator API. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavApi.resources.requests.memory` | Describes the minimum amount of memory required for the Application Navigator API. Corresponds to requests.memory in Kubernetes. If not specified it will default to maximum memory (if specified) or otherwise implementation-defined value. | `512Mi` |
| `appNavApi.resources.limits.cpu` | The upper limit of CPU core for the Application Navigator API. Specify integers, fractions (e.g. 0.5), or millicores values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavApi.resources.limits.memory` | The memory upper limit in bytes for the Application Navigator API. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `512Mi` |
| `appNavController.repository` | Docker registry to pull the Application Navigator Controller image from. | `ibmcom/app-nav-controller` |
| `appNavController.tag` | Application Navigator Controller image tag. | `1.0.0` |
| `appNavController.resources.constraints.enabled` | Specifies whether resource constraints are enabled for the Application Navigator Controller.  | `false` |
| `appNavController.resources.requests.cpu` | The minimum required CPU core for the Application Navigator Controller. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavController.resources.requests.memory` | Describes the minimum amount of memory required for the Application Navigator Controller. Corresponds to requests.memory in Kubernetes. If not specified it will default to maximum memory (if specified) or otherwise implementation-defined value. | `512Mi` |
| `appNavController.resources.limits.cpu` | The upper limit of CPU core for the Application Navigator Controller. Specify integers, fractions (e.g. 0.5), or millicores values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavController.resources.limits.memory` | The memory upper limit in bytes for the Application Navigator Controller. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `512Mi` |
| `appNavUI.repository` | Docker registry to pull the Application Navigator UI image from. | `ibmcom/app-nav-ui` |
| `appNavUI.tag` | Application Navigator UI image tag. | `1.0.0` |
| `appNavUI.service.type` | Service type (`ClusterIP` or `NodePort`) for access to the Application Navigator UI. Always use `ClusterIP` if authentication is required. | `ClusterIP` |
| `appNavUI.resources.constraints.enabled` | Specifies whether resource constraints are enabled for the Application Navigator UI.  | `false` |
| `appNavUI.resources.requests.cpu` | The minimum required CPU core for the Application Navigator UI. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavUI.resources.requests.memory` | Describes the minimum amount of memory required for the Application Navigator UI. Corresponds to requests.memory in Kubernetes. If not specified it will default to maximum memory (if specified) or otherwise implementation-defined value. | `512Mi` |
| `appNavUI.resources.limits.cpu` | The upper limit of CPU core for the Application Navigator UI. Specify integers, fractions (e.g. 0.5), or millicores values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavUI.resources.limits.memory` | The memory upper limit in bytes for the Application Navigator UI. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `512Mi` |
| `appNavWASController.repository` | Docker registry to pull the Application Navigator WAS Controller image from. | `ibmcom/app-nav-was-controller` |
| `appNavWASController.tag` | Application Navigator WAS Controller image tag. | `1.0.0` |
| `appNavWASController.resources.constraints.enabled` | Specifies whether resource constraints are enabled for the Application Navigator WAS Controller.  | `false` |
| `appNavWASController.resources.requests.cpu` | The minimum required CPU core for the Application Navigator WAS Controller. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavWASController.resources.requests.memory` | Describes the minimum amount of memory required for the Application Navigator WAS Controller. Corresponds to requests.memory in Kubernetes. If not specified it will default to maximum memory (if specified) or otherwise implementation-defined value. | `512Mi` |
| `appNavWASController.resources.limits.cpu` | The upper limit of CPU core for the Application Navigator WAS Controller. Specify integers, fractions (e.g. 0.5), or millicores values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavWASController.resources.limits.memory` | The memory upper limit in bytes for the Application Navigator WAS Controller. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `512Mi` |
| `appNavInit.repository` | Docker registry to pull the Application Navigator Init image from. | `ibmcom/app-nav-init` |
| `appNavInit.tag` | Application Navigator Init image tag. | `1.0.0` |
| `appNavInit.resources.constraints.enabled` | Specifies whether resource constraints are enabled for the Application Navigator Init.  | `false` |
| `appNavInit.resources.requests.cpu` | The minimum required CPU core for the Application Navigator Init. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavInit.resources.requests.memory` | Describes the minimum amount of memory required for the Application Navigator Init. Corresponds to requests.memory in Kubernetes. If not specified it will default to maximum memory (if specified) or otherwise implementation-defined value. | `512Mi` |
| `appNavInit.resources.limits.cpu` | The upper limit of CPU core for the Application Navigator Init. Specify integers, fractions (e.g. 0.5), or millicores values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavInit.resources.limits.memory` | The memory upper limit in bytes for the Application Navigator Init. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `512Mi` |
| `appNavCmds.repository` | Docker registry to pull the Application Navigator Commands image from. | `ibmcom/app-nav-cmds` |
| `appNavCmds.tag` | Application Navigator Commands image tag. | `1.0.0` |
| `appNavCmds.resources.constraints.enabled` | Specifies whether resource constraints are enabled for the Application Navigator Commands.  | `false` |
| `appNavCmds.resources.requests.cpu` | The minimum required CPU core for the Application Navigator Commands. Specify integers, fractions (e.g. 0.5), or millicore values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavCmds.resources.requests.memory` | Describes the minimum amount of memory required for the Application Navigator Commands. Corresponds to requests.memory in Kubernetes. If not specified it will default to maximum memory (if specified) or otherwise implementation-defined value. | `512Mi` |
| `appNavCmds.resources.limits.cpu` | The upper limit of CPU core for the Application Navigator Commands. Specify integers, fractions (e.g. 0.5), or millicores values(e.g. 100m, where 100m is equivalent to .1 core). | `500m` |
| `appNavCmds.resources.limits.memory` | The memory upper limit in bytes for the Application Navigator Commands. Specify integers with suffixes: E, P, T, G, M, K, or power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. | `512Mi` |
| `image.pullPolicy` | Image pull policy. `Always`, `Never`, or `IfNotPresent`. See Kubernetes - [Updating Images](https://kubernetes.io/docs/concepts/containers/images/#updating-images). | `Always` |
| `image.pullSecrets` | Pull secrets for private docker registries. | `[]` |
| `env.kubeEnv` | Specifies the Kubernetes environment (`icp` or `minikube`). | `icp` |
| `arch.amd64` | Scheduling priority for using the Intel 64-bit architecture for worker nodes. `0 - Do not use`, `1 - Least preferred`, `2 - No preference`, or `3 - Most preferred`. | `2 - No preference` |
| `arch.ppc64le` | Scheduling priority for using the PowerPC 64-bit LE architecture for worker nodes. `0 - Do not use`, `1 - Least preferred`, `2 - No preference`, or `3 - Most preferred`. | `2 - No preference` |
| `arch.s390x` | Scheduling priority for using s390x zLinux architecture for worker nodes. `0 - Do not use`, `1 - Least preferred`, `2 - No preference`, or `3 - Most preferred`. | `2 - No preference` |

## Limitations
See RELEASENOTES.md.

## Documentation
[Using the IBM Application Navigator](https://www.ibm.com/support/knowledgecenter/SSEQTP_9.0.5/com.ibm.websphere.base.doc/ae/ccld_appnav.html)
