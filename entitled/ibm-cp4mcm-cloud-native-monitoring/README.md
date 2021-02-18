# IBM® CP4MCM Cloud Native Monitoring

## Introduction

* IBM CP4MCM cloud native monitoring to configure and receive kubernetes cluster events, LWDC envents based on unified agent plugins, the events to be reported to Event Management and Monitoring services on CP4MCM hub clusters. 

## Prerequisites
  - Kubernetes >=1.11.0
  - Tiller >=2.11.0
  - Install the CP4MCM Monitoring Module server. 
  - Import a managed cluster. 

#### Red Hat OpenShift
  - Red Hat OpenShift Container Platform 4.2 or later

#### IBM® Cloud Private (ICP)
  - IBM® Cloud Private (ICP) >=3.1.1

#### CP4MCM Monitoring Requirements
* [IBM Cloud App Management server within CP4MCM installed on the hub cluster](https://www.ibm.com/support/knowledgecenter/SSFC4F_2.0.0/kc_welcome_cloud_pak.html)

#### CP4MCM managed Cluster Requirements

* [IBM Multicloud Manager klusterlet installed](https://www.ibm.com/support/knowledgecenter/SSFC4F_2.0.0/mcm/installing/install_k8s_cloud.html)


### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-cloud-appmgmt-prod-psp
    spec:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      allowedCapabilities:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
      seLinux:
        rule: 'RunAsAny'
      supplementalGroups:
        rule: 'MustRunAs'
        ranges:
        - min: 1
          max: 65535
      runAsUser:
        rule: 'MustRunAsNonRoot'
      fsGroup:
        rule: 'MustRunAs'
        ranges:
        - min: 1
          max: 65535
      volumes:
      - configMap
      - secret
      - persistentVolumeClaim
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-cloud-appmgmt-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-cloud-appmgmt-prod-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
  - The ClusterRole must be applied to the target namespace's serviceaccount group through a RoleBinding.


## Resources Required
#### System resources, based on default install parameters.
* Minimum: 300MB Memory and 4 CPU
* Recommended: 450MB Memory and .5 CPU

The CPU resource is measured in Kuberenetes _cpu_ units. See Kubernetes documentation for details.

#### Persistence:
* N/A

## Chart Details
This chart will install the following underlying charts:
* agentoperator
* ibm-sch
* icam-reloader
* k8sdc-operator
* ua-operator

For details of what each of charts do, look at the detailed documentation please.

Pods are spread across worker nodes using the Kubernetes anti-affinity feature.

## Installing the Chart
1. From the IBM Cloud Private dashboard console, open the Catalog.
2. Locate and select the `ibm-cp4mcm-cloud-native-monitoring` chart.
3. Review the provided instructions and select Configure.
4. Review and accept the license(s).
5. Using the Configuration table below, provide the required configuration based on requirements specific to your installation. Required fields are displayed with an asterisk.
6. Select the Install button to complete the helm installation.

For more information on installing, consult the [Installation](https://www.ibm.com/support/knowledgecenter/SS8G7U_19.4.0/com.ibm.app.mgmt.doc/content/install_mcm_klusterlet.html?cp=SSFC4F_1.2.0) documentation.

### Uninstalling the Chart:

1. Purge the Helm release, which deletes the Kubernetes custom resource definition:

```bash
helm delete my_release_name --purge -–tls
```

2. Clean K8sdc customer resources and customer resource definition

```bash
kubectl patch k8sdcs.ibmcloudappmgmt.com -p '{"metadata":{"finalizers":[]}}' --type=merge k8sdc-cr --namespace multicluster-endpoint
kubectl delete crd k8sdc --namespace multicluster-endpoint
```


3. Clean up the configuration secrets:

```bash
 kubectl delete secret dc-secret --namespace multicluster-endpoint
 kubectl delete secret ibm-agent-https-secret --namespace multicluster-endpoint
 ```

## Configuration

The following tables lists the global configurable parameters of the icam-clouddc-klusterlet chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `agent` | Configure the Agent Operator for auto configuration |  |
| `agent.clusterSize` | Number of pod replicas | 1 |
| `agent.klusterlet` | Multicloud Manager Klusterlet Configuration Configuration |  |
| `agent.klusterlet.cloud` | Cloud provider on which Kubernetes cluster is deployed | IBM |
| `agent.klusterlet.datacenter` | The datacenter name in which the managed cluster runs. | toronto |
| `agent.klusterlet.environment` | The type of cluster environment | Dev |
| `agent.klusterlet.owner` | The business owner of the cluster. | marketing |
| `agent.klusterlet.region` | The geographic region in which the managed cluster runs | US |
| `agent.klusterlet.vendor` | Vendor package of Kubernetes cluster software | ICP |
| `global` | Global configuration of the product |  |
| `global.clusterName` | Name that this cluster will be identified as on the Hub-Cluster |  |
| `global.environmentSize` | Determine cluster resource requests and limits for the product | size0 |
| `global.image.repository` | Docker registry to pull images from |  |
| `global.image.pullSecret` | The name of the image pull secret |  |
| `global.imageNamePrefix` | Prefix for docker images; applies after the image repository value and before the image names |  |
| `global.license` | Accepting the product license is required to deploy this chart |  |
| `global.namespace` | The namespace that MCM has created for the ICP cluster that is being configured |  |

_NOTE:_

1. Valid values for `global.environmentSize` are `size0` and `size1`. `size0` specifies a minimal resource footprint for development and test purposes, while `size1` is intended for production systems with a larger footprint.


## Limitations
None

## Documentation

[ICAM klusterlet installation and uninstallation instructions](https://www-ibm.ibm.com/support/knowledgecenter/SSFC4F_2.0.0/icam/install_mcm_klusterlet_no_helm.html).