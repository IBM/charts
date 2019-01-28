# IBM Mobile Foundation for Developers 8.0 Helm Chart

 IBM Mobile Foundation for Developers 8.0 enables you to develop, test, evaluate and demonstrate Mobile Foundation applications in a non-production environment with embedded derby database. It also provides IBM MobileFoundation Analytics which gives a rich view into both your mobile landscape and server infrastructure.
## Introduction
IBM Mobile Foundation is an integrated platform that helps you extend your business to mobile devices.

IBM Mobile Foundation includes a comprehensive development environment, mobile-optimized runtime middleware, a private enterprise application store, and an integrated management and analytics console, all supported by various security mechanisms.

For more information: [Mobile Foundation Documentation](https://www.ibm.com/support/knowledgecenter/en/SSNJXP/welcome.html)

## Chart Details

- Deploys Mobile Foundation Server with Analytics included onto Kubernetes.
- This chart can be deployed more than once on the same namespace.

## Prerequisites

If you prefer to install from the command prompt, you will need:

- The `cloudctl`, `kubectl` and `helm` commands available
- Your environment configured to connect to the target cluster

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

> Note: This PodSecurityPolicy only needs to be created once. If it already exist, skip this step.

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-mobilefoundation-dev-psp
  annotations:
    apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default 
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
spec:
  requiredDropCapabilities:
  - ALL
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
  seLinux:
    rule: RunAsAny
  runAsUser:
    rule: MustRunAsNonRoot
  supplementalGroups:
    rule: MustRunAs
    ranges:
    - min: 1
      max: 65535
  fsGroup:
    rule: MustRunAs
    ranges:
    - min: 1
      max: 65535
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - "*"
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-mobilefoundation-dev-psp-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-mobilefoundation-dev-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use

```
The cluster admin can either paste the above PSP and ClusterRole definitions into the create resource screen in the UI or run the following two commands:

- `kubectl create -f <PSP yaml file>`
- `kubectl create clusterrole ibm-mobilefoundation-dev-psp-clusterrole --verb=use --resource=podsecuritypolicy --resource-name=ibm-mobilefoundation-dev-psp`

In ICP 3.1, you also need to create the RoleBinding:

- `kubectl create rolebinding ibm-mobilefoundation-dev-psp-rolebinding --clusterrole=ibm-mobilefoundation-dev-psp-clusterrole --serviceaccount=<namespace>:default --namespace=<namespace>`

## Resources Required

This chart uses the following resources by default:

- 2 CPU core
- 2 Gi memory

## Installing the Chart

You can install the chart with the release name `my-release` as follows:

```sh
helm install --name my-release stable/ibm-mobilefoundation-dev --set <stringArray> --tls
```

--set stringArray        set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
This command accepts the List of comma separated mandatory  values and deploys a Mobile Foundation Server on the Kubernetes cluster. The [configuration](#configuration) section lists the parameters that can be configured during installation.
> **Tip**: See all the resources deployed by the chart using `kubectl get all -l release=my-release`

### Uninstalling the Chart

You can uninstall/delete the `my-release` release as follows:

```sh
helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the chart.

## Accessing Mobile Foundation Server

From a web browser, go to the IBM Cloud Private console page and navigate to the helm releases page as follows

1. Click on Menu on the Left Top of the Page
2. Select **Workloads** > **Helm Releases**
3. Click on the deployed *IBM MobileFoundation Server* helm release
4. Refer the **Notes** section for the procedure to access the MobileFoundation Operations Console

## Configuration

### Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| arch     |      | Worker node architecture | Worker node architecture to which this chart should be deployed. Only AMD64 platform is currently supported |
| image     | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Default: IfNotPresent |
|           | repository          | Docker image name | Name of the Mobile Foundation for Developers 8.0 docker image |
|           | tag          | Docker image tag | See Docker tag description |
| resources | limits.cpu  | Describes the maximum amount of CPU allowed.  | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|                  | limits.memory | Describes the maximum amount of memory allowed. | Default is 4096Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)|
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value.  | Default is 2000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value. | Default is 2048Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |
| logs | consoleFormat | Specifies container log output format. | Default is **json**. |
|  | consoleLogLevel | Controls the granularity of messages that go to the container log. | Default is **info**. |
| | consoleSource | Specify sources that are written to the container log. Use a comma separated list for multiple sources. | Default is **message, trace, accessLog, ffdc**. |


## Limitations
This Helm chart is provided only for development and testing purposes.
Data is stored in embedded derby database.
