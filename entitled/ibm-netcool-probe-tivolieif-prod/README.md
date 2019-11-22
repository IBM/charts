# IBM Tivoli Netcool/OMNIbus Tivoli EIF Probe Helm Chart

This helm chart deploys the IBM Netcool/OMNIbus Tivoli EIF Probe onto Kubernetes. This probe processes EIF events from Tivoli 
devices to a Netcool Operations Insight operational dashboard.

## Introduction

IBM® Netcool® Operations Insight enables IT and network operations teams to increase effectiveness, efficiency
and reliability by leveraging cognitive analytics capabilities to identify, isolate and resolve problems before
they impact your business. It provides a consolidated view across your local, cloud and hybrid environments and
delivers actionable insight into the health and performance of services and their associated dynamic network and
IT infrastructures. More information can be seen here: [IBM Marketplace - IT Operations Management](https://www.ibm.com/uk-en/marketplace/it-operations-management)

## Chart Details

- Deploys a Tivoli Netcool/OMNIbus Tivoli EIF probe onto Kubernetes that can receive Event Integration Facility (EIF) messages from a range of Tivoli products.

- Each probe deployment is fronted by a service.

- This chart can be deployed more than once on the same namespace.

## Prerequisites

- This solution requires a IBM Tivoli Netcool/OMNIbus ObjectServer to be created and running prior to installing the probe. To create and run the IBM Tivoli Netcool/OMNIbus ObjectServer, see installation instructions at [IBM Knowledge Center - Creating and running ObjectServers](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_creatingsettingupobjserv.html).

- Scope-based Event Grouping automation is installed and enabled, see installation instructions at [IBM Knowledge Center - Installing scope-based event grouping](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ_8.1.0/com.ibm.netcool_OMNIbus.doc_8.1.0/omnibus/wip/install/task/omn_con_ext_installingscopebasedegrp.html)

- Kubernetes 1.11.1.

- Operator role is the minimum role required to install this chart.
  - Administrator role is required in order to:
    - Enable Pod Disruption Budget policy when installing the chart.
  - The chart must be installed by a Cluster Administrator to perform the following tasks in addition to those listed above:
    - Obtain the Node IP using `kubectl get nodes` command if using the NodePort service type.
    - Create a new namespace with custom PodSecurityPolicy if necessary. See PodSecurityPolicy Requirements [section](#podsecuritypolicy-requirements) for more details.

## Resources Required

- CPU Requested : 250m (250 millicpu)
- Memory Requested : 256Mi (~ 268 MB)

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart. The predefined PodSecurityPolicy definitions can be viewed [here](https://github.com/IBM/cloud-pak/blob/master/spec/security/psp/README.md).

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory. Detailed steps to create the PodSecurityPolicy is documented [here](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/all_helms/wip/reference/hlm_common_psp.html).

* From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  * Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is based on the most restrictive policy,
        requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
      name: ibm-netcool-probe-tivolieif-prod-psp
    spec:
      allowPrivilegeEscalation: false
      forbiddenSysctls:
      - '*'
      fsGroup:
        ranges:
        - max: 65535
          min: 1
        rule: MustRunAs
      hostNetwork: false
      hostPID: false
      hostIPC: false
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
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-netcool-probe-tivolieif-prod-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-netcool-probe-tivolieif-prod-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
  * RoleBinding for all service accounts in the current namespace. Replace `{{ NAMESPACE }}` in the template with the actual namespace.
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: ibm-netcool-probe-tivolieif-prod-rolebinding
    roleRef:
      apiGroup: rbac.authorization.k8s.io
      kind: ClusterRole
      name: ibm-netcool-probe-tivolieif-prod-clusterrole
    subjects:
    - apiGroup: rbac.authorization.k8s.io
      kind: Group
      name: system:serviceaccounts:{{ NAMESPACE }}
    ```
* From the command line, you can run the setup scripts included under pak_extensions.
  
  As a cluster administrator, the pre-install scripts and instructions are located at:
  * pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin/operator the namespace scoped scripts and instructions are located at:
  * pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh

## Installing the Chart

To install the chart with the release name `my-tivolieif-probe`:

1. Extract the helm chart archive and customize `values.yaml`. The [configuration](#configuration) section lists the parameters that can be configured during installation.

2. The command below shows how to install the chart with the release name `my-tivolieif-probe` using the configuration specified in the customized `values.yaml`. Helm searches for the `ibm-netcool-probe-tivolieif-prod` chart in the helm repository called `stable`. This assumes that the chart exists in the `stable` repository.

```sh
helm install --name my-tivolieif-probe -f values.yaml stable/ibm-netcool-probe-tivolieif-prod
```
> **Tip**: List all releases using `helm list --tls` or search for a chart using `helm search`.

## Verifying the Chart

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release> --tls`.

## Uninstalling the Chart

To uninstall/delete the `my-tivolieif-probe` deployment:

```sh
$ helm delete my-tivolieif-probe --purge
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Clean up any prerequisites that were created

As a Cluster Administrator, run the cluster administration clean up script included under pak_extensions to clean up cluster scoped resources when appropriate.

- post-delete/clusterAdministration/deleteSecurityClusterPrereqs.sh

As a Cluster Administrator, run the namespace administration clean up script included under pak_extensions to clean up namespace scoped resources when appropriate.

- post-delete/namespaceAdministration/deleteSecurityNamespacePrereqs.sh


## Configuration

The following table lists the configurable parameters of the `ibm-netcool-probe-tivolieif-prod` chart and their default values.

| Parameter                          | Description                                                                                                                                                                                                                                                                               | Default                                                        |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `license`                          | The license state of the image being deployed. Enter `accept` to install and use the image.                                                                                                                                                                                               | `not accepted`                                                 |
| `replicaCount`                     | Number of deployment replicas. Omitted when `autoscaling.enabled` set to `true`                                                                                                                                                                                                           | `1`                                                            |
| `global.image.secretName`          | Name of the Secret containing the Docker Config to pull the image from a private repository. Leave blank if the probe image already exists in the local image repository or the Service Account has a been assigned with an Image Pull Secret.                                            | `nil`                                                          |
| `image.repository`                 | Probe image repository. Update this repository name to pull from a private image repository. See default value as example. The image name should be set to `netcool-probe-tivolieif`.                                                                                                     | `netcool-probe-tivolieif`                                      |
| `image.testRepository`             | Utility image repository. Update this repository name to pull the test image from a private image repository. The test image name should be set to `busybox`.                                                                                                                             | `busybox`                                                      |
| `image.testImageTag`               | Utility image tag.                                                                                                                                                                                                                                                                        | `1.28.4`                                                       |
| `image.pullPolicy`                 | Image pull policy                                                                                                                                                                                                                                                                         | Set to `Always` if `imageTag` is `latest`, else `IfNotPresent` |
| `image.tag`                        | The `netcool-probe-tivolieif` image tag                                                                                                                                                                                                                                                   | `13.0.7_4`                                                     |
| `netcool.primaryServer`            | The primary Netcool/OMNIbus server the probe should connect to (required). Usually set to NCOMS or AGG_P.                                                                                                                                                                                 | `nil`                                                          |
| `netcool.primaryHost`              | The hostname or IP address of the primary Netcool/OMNIbus server (required).                                                                                                                                                                                                              | `nil`                                                          |
| `netcool.primaryPort`              | The port number of the primary Netcool/OMNIbus server (required).                                                                                                                                                                                                                         | `nil`                                                          |
| `netcool.backupServer`             | The backup Netcool/OMNIbus server to connect to. If the backupServer, backupHost and backupPort parameters are defined in addition to the primaryServer, primaryHost, and primaryPort parameters, the probe will be configured to connect to a virtual object server pair called `AGG_V`. | `nil`                                                          |
| `netcool.backupHost`               | The hostname or IP address of the backup Netcool/OMNIbus server.                                                                                                                                                                                                                          | `nil`                                                          |
| `netcool.backupPort`               | The port of the backup Netcool/OMNIbus server                                                                                                                                                                                                                                             | `nil`                                                          |
| `probe.messageLevel`               | Probe log message level.                                                                                                                                                                                                                                                                  | `warn`                                                         |
| `probe.rulesFile.taddm`            | Set to `true` to enable the TADDM rules file, otherwise false.                                                                                                                                                                                                                            | `false`                                                        |
| `probe.rulesFile.tpc`              | Set to `true` to enable the TPC rules file, otherwise false.                                                                                                                                                                                                                              | `false`                                                        |
| `probe.rulesFile.tsm`              | Set to `true` to enable the TSM rules file, otherwise false.                                                                                                                                                                                                                              | `false`                                                        |
| `service.probe.type`               | Tivoli EIF Probe k8 service type exposing ports, e.g. `ClusterIP` or `NodePort`                                                                                                                                                                                                           | `ClusterIP`                                                    |
| `service.probe.externalPort`       | External TCP Port for this service                                                                                                                                                                                                                                                        | `9998`                                                         |
| `autoscaling.enabled`              | Set to `false` to disable auto-scaling                                                                                                                                                                                                                                                    | true                                                           |
| `autoscaling.minReplicas`          | Minimum number of probe replicas                                                                                                                                                                                                                                                          | `2`                                                            |
| `autoscaling.maxReplicas`          | Maximum number of probe replicas                                                                                                                                                                                                                                                          | `5`                                                            |
| `autoscaling.cpuUtil`              | Target average CPU utilization (represented as a percentage of requested CPU) over all the pods. Eg: Set to 60 for 60% target utilization.                                                                                                                                                | `60`                                                           |
| `poddisruptionbudget.enabled`      | Set to `true` to enable Pod Disruption Budget to maintain high availability during a node maintenance.Administrator role or higher is required to enable Pod Disruption Budget on clusters with Role Based Access Control.                                                                | `false`                                                        |
| `poddisruptionbudget.minAvailable` | The number of minimum available number of pods during node drain. Can be set to a number or percentage, eg: 1 or 10%. Caution: Setting to 100% or equal to the number of replicas) may block node drains entirely.                                                                        | `1`                                                            |
| `resources.limits.cpu`             | CPU resource limits                                                                                                                                                                                                                                                                       | `250m`                                                         |
| `resources.limits.memory`          | Memory resource limits                                                                                                                                                                                                                                                                    | `256Mi`                                                        |
| `resources.requests.cpu`           | CPU resource requests                                                                                                                                                                                                                                                                     | `250m`                                                         |
| `resources.requests.memory`        | Memory resource requests                                                                                                                                                                                                                                                                  | `256Mi`                                                        |
| `arch`                             | Worker node architecture. Fixed to `amd64`.                                                                                                                                                                                                                                               | `amd64`                                                        |



Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```sh
$ helm install --name my-tivolieif-probe -f my_values.yaml stable/ibm-netcool-probe-tivolieif-prod
```

## Limitations

- In addition to the default Rules files, the probe only supports the rules files for TADDM, TPC and TSM. Other rules files that require the extension 
of the ObjectServer tables are not supported. 
- Validated to run on IBM Cloud Private 3.1.0 and 3.1.1.

## Documentation

- IBM Tivoli Netcool/OMNIBus Probe for Tivoli EIF (Helm Chart) Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/helms/tivoli_eif/wip/concept/tveif_intro.html)
- IBM Tivoli Netcool/OMNIBus Probe for Tivoli EIF (Probe) Knowledge Center [page](https://www.ibm.com/support/knowledgecenter/SSSHTQ/omnibus/probes/tivoli_eif_v11/wip/reference/tveifv11_intro.html)
- [IBM Tivoli Netcool OMNIbus Probes and Gateways Helm Charts](https://www.ibm.com/support/knowledgecenter/en/SSSHTQ/omnibus/helms/common/Helms.html)
- [Init container: Understanding Pod status](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-init-containers/#understanding-pod-status)
- [Using helm CLI](https://github.com/helm/helm/blob/master/docs/using_helm.md)

## Troubleshooting

Describes potential issues and resolution steps when deploying the probe chart.

| Problem                                                                                                                                         | Cause                                                                                                        | Resolution                                                                          |
|-------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
