# IBM Mobile Foundation for Developers 8.0 Helm Chart

 IBM Mobile Foundation for Developers 8.0 enables you to develop, test, evaluate and demonstrate Mobile Foundation applications in a non-production environment with embedded derby database. It also provides IBM MobileFoundation Analytics which gives a rich view into both your mobile landscape and server infrastructure.
 
## Introduction
IBM Mobile Foundation is an integrated platform that helps you extend your business to mobile devices.

IBM Mobile Foundation includes a comprehensive development environment, mobile-optimized runtime middleware, a private enterprise application store, and an integrated management and analytics console, all supported by various security mechanisms.

For more information: 
- [Mobile Foundation Documentation](https://www.ibm.com/support/knowledgecenter/en/SSNJXP/welcome.html)
- [Mobile Foundation on IBM Cloud Private Documentation](http://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/ibmcloud/mobilefirst-server-on-icp/)

## Features

* Mobile Foundation Server
* Mobile Foundation Push
* Mobile Foundation Liveupdate
* Mobile Foundation Analytics
* Mobile Foundation Analytics Receiver
* Mobile Foundation Application Center

## Chart Details

- Deploys Mobile Foundation Server with Analytics included onto Kubernetes.
- This chart can be deployed more than once on the same namespace.

## Prerequisites

If you prefer to install from the command prompt, you will need:

- The `cloudctl`, `kubectl` and `helm` commands available
- Your environment configured to connect to the target cluster

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

#### Predefined PodSecurityPolicy

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)

#### Custom PodSecurityPolicy

* Custom PodSecurityPolicy definition:

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
> Note: This PodSecurityPolicy only needs to be created once. If it already exists, skip this step.

The cluster admin can either paste the above PSP and ClusterRole definitions into the create resource screen in the UI or run the following two commands:

- `kubectl create -f <PSP yaml file>`
- `kubectl create clusterrole ibm-mobilefoundation-dev-psp-clusterrole --verb=use --resource=podsecuritypolicy --resource-name=ibm-mobilefoundation-dev-psp`

In ICP 3.1, you also need to create the RoleBinding:

- `kubectl create rolebinding ibm-mobilefoundation-dev-psp-rolebinding --clusterrole=ibm-mobilefoundation-dev-psp-clusterrole --serviceaccount=<namespace>:default --namespace=<namespace>`

## Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a `SecurityContextConstraints` to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined `SecurityContextConstraints` name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this `SecurityContextConstraints` resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions.

- From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
  - Custom SecurityContextConstraints definition:
    ```
    apiVersion: security.openshift.io/v1
    kind: SecurityContextConstraints
    metadata:
    annotations:
        kubernetes.io/description: "This policy is requiring pods to run with a non-root UID, and allow host path access."
    name: ibm-mobilefoundation-scc-{{ .Release.Namespace }}
    allowHostDirVolumePlugin: true
    allowHostIPC: false
    allowHostNetwork: false
    allowHostPID: false
    allowHostPorts: false
    allowPrivilegedContainer: false
    allowPrivilegeEscalation: true
    allowedCapabilities:
    - SETPCAP
    - AUDIT_WRITE
    - CHOWN
    - NET_RAW
    - DAC_OVERRIDE
    - FOWNER
    - FSETID
    - KILL
    - SETUID
    - SETGID
    - NET_BIND_SERVICE
    - SYS_CHROOT
    - SETFCAP
    allowedFlexVolumes: []
    allowedUnsafeSysctls: []
    defaultAddCapabilities: []
    defaultPrivilegeEscalation: true
    forbiddenSysctls:
    - "*"
    fsGroup:
    type: MustRunAs
    ranges:
    - max: 1111
        min: 999
    readOnlyRootFilesystem: false
    requiredDropCapabilities:
    - MKNOD
    runAsUser:
    type: MustRunAsNonRoot
    seccompProfiles:
    - docker/default
    seLinuxContext:
    type: RunAsAny
    supplementalGroups:
    type: MustRunAs
    ranges:
    - max: 1111
        min: 999
    volumes:
    - configMap
    - downwardAPI
    - emptyDir
    - persistentVolumeClaim
    - projected
    - secret
    - nfs
    groups:
    - system:serviceaccounts:{{ .Release.Namespace }}
    priority: 0
    ```
## Resources Required

This chart uses the following resources by default:

- 1 CPU core
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
3. Click on the deployed *IBM Mobile Foundation* helm release
4. Refer the **Notes** section for the procedure to access the MobileFoundation Operations Console

## Configuration

### Parameters

| Qualifier | Parameter  | Definition | Allowed Value |
|---|---|---|---|
| arch |  amd64    | amd64 worker node scheduler preference in a hybrid cluster | 3 - Most preferred (Default) |
|      |  ppcle64  | ppc64le worker node scheduler preference in a hybrid cluster | 2 - No preference (Default) |
|      |  s390x    | S390x worker node scheduler preference in a hybrid cluster | 2 - No preference (Default) |
| image     | pullPolicy | Image Pull Policy | Always, Never, or IfNotPresent. Default: IfNotPresent |
|           | repository          | Docker image name | Name of the Mobile Foundation for Developers 8.0 docker image |
|           | tag          | Docker image tag | See Docker tag description |
| ingress | hostname | The external hostname or IP address to be used by external clients | Leave blank to default to the IP address of the cluster proxy node|
|         | secret | TLS secret name| Specifies the name of the secret for the certificate that has to be used in the Ingress definition. The secret has to be pre-created using the relevant certificate and key. Mandatory if SSL/TLS is enabled. Pre-create the secret with Certificate & Key before supplying the name here |
|         | sslPassThrough | Enable SSL passthrough | Specifies is the SSL request should be passed through to the Mobile Foundation service - SSL termination occurs in the Mobile Foundation service. Default: false |
| https     |  | https communication | false (default) or true |
| replicas |  | The number of instances (pods) of Mobile Foundation that need to be created | Positive integer (Default: 1) |
| keystoreSecret |   | Refer the configuration section to pre-create the secret with keystores and their passwords.|
| resources | limits.cpu  | Describes the maximum amount of CPU allowed.  | Default is 1000m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|                  | limits.memory | Describes the maximum amount of memory allowed. | Default is 2048Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory)|
|           | requests.cpu  | Describes the minimum amount of CPU required - if not specified will default to limit (if specified) or otherwise implementation-defined value.  | Default is 750m. See Kubernetes - [meaning of CPU](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu) |
|           | requests.memory | Describes the minimum amount of memory required. If not specified, the memory amount will default to the limit (if specified) or the implementation-defined value. | Default is 1024Mi. See Kubernetes - [meaning of Memory](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-memory) |


## Limitations
This Mobile Foundation chart restricts the deployment to a single pod. This Helm chart is provided only for development and testing purposes. Mobile Foundation data is stored in embedded derby database. This data is not persisted to any other location and will be lost if the helm deployment is deleted.
