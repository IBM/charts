# IBM Db2 Data Management Console Addon Helm Chart


This is a chart for IBM Db2 Data Management Console Addon on Cloud Pak for Data. IBM Db2 Data Management Console  is a browser-based tool that helps you administer, monitor, manage and optimize the performance of IBM Db2 databases. 

## Introduction

This is a chart for IBM Db2 Data Management Console Addon to manage service install and provision. IBM Db2 Data Management Console is a browser-based tool that helps you administer, monitor, manage and optimize the performance of IBM Db2 databases. 

### New in this release

1. First release

## Details
This chart will deploy on Cloud Pak for Data cluster. It's launched in service installation phase.

## Chart Details
This chart will do the following:

- Deploy several deployments and statefulset. 
- Create several services to connect to deployment.
- Deploy network policys and configmaps.
- Deploy secrets

## Prerequisites

- Kubernetes Level - ">=1.11.0"
- Architecture- amd64,ppc64le and s390x.
- PersistentVolume requirements- It don't need persistent volumes.


### PodSecurityPolicy Requirements
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-dmc-psp
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
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      runAsUser:
        rule: RunAsAny
      fsGroup:
        rule: RunAsAny
      volumes:
      - configMap
      - secret
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    We use the pre-defined role "cpd-editor-role" and "cpd-viewer-role" in CP4D, and created "dmc-clusterrole" to support cluster level operation.

    - From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
      - Custom SecurityContextConstraints definition:
        ```
        apiVersion: security.openshift.io/v1
        kind: SecurityContextConstraints
        metadata:
          name: ibm-dmc-scc
        readOnlyRootFilesystem: false
        allowedCapabilities:
        - CHOWN
        - DAC_OVERRIDE
        - SETGID
        - SETUID
        - NET_BIND_SERVICE
        seLinux:
          type: RunAsAny
        supplementalGroups:
          type: RunAsAny
        runAsUser:
          type: RunAsAny
        fsGroup:
          rule: RunAsAny
        volumes:
        - configMap
        - secret
        ```

- From the command line, you can run the setup scripts included under pak_extensions
  As a cluster admin the pre-install instructions are located at:
  - pre-install/clusterAdministration/< your scripts...>

  As team admin the namespace scoped instructions are located at:
  - pre-install/namespaceAdministration/< your scripts...>


### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc)  has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.



## Installing the Chart

To install the chart, you must through cp4d command line:

```bash
$ cpd-cli install -s repo.yaml -a dmc --namespace <cp4d-namespace>
```

The command deploys ibm-dmc-addon on cp4d cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

## Uninstalling the Chart

To uninstall/delete the deployment:

```bash
$ cpd-cli uninstall  -a dmc --namespace <cp4d-namespace>
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  If a delete can result in orphaned components include instructions additional commands required for clean-up.  


## Configuration

The following tables lists the configurable parameters of the ibm-unified-console chart and their default values.

| Parameter                             | Description                                                  | Default                                                    |
| ------------------------------        | ----------------------------------------------------------   | ---------------------------------------------------------- |
| `arch.amd64`                  | `Amd64 worker node scheduler preference in a hybrid cluster` | `2 - No preference` - worker node is chosen by scheduler       |
| `arch.ppc64le`                | `Ppc64le worker node scheduler preference in a hybrid cluster` | `2 - No preference` - worker node is chosen by scheduler       |
| `arch.s390x`                  | `S390x worker node scheduler preference in a hybrid cluster` | `2 - No preference` - worker node is chosen by scheduler       |
| `customNodeSelectorTerms`     | `custom nodeselector terms                                     | `nil`                                                      |
| `customTolerations`           | `custom tolerations                                          | `nil`                                                      |
| `<component>.image.repository`                | component image repository                                          | `<component>`                                                        |
| `<component>.image.tag`             | component image tag                                       | ``                                                     |
| `<component>.resources.limits.cpu`                | Pod CPU limit                                          | `4`                                                        |
| `<component>.resources.limits.memory`             | Pod memory limit                                       | `16Gi`                                                     |
| `<component>.resources.requests.cpu`              | Pod CPU requested                                      | `2`                                                        |
| `<component>.resources.requests.memory`           | Pod Memory requested                                   | `4Gi`                                                      |
| `<component>.service.replicas`                    | Pods replica number                                           | `2`                                                    |
| `<component>.service.name`                        | k8s service  name                         | `api`                                                  | 
| `global.dockerRegistryPrefix`      |  global docker registry to pull images | `` |
| `serviceAccountName`              | service account to run pods | `` |                        



Specify each parameter by change the values.yaml



## Resources Required

The default values in values.yaml defined the minimum resources required.

## Architecture

- Three major architectures are now available on worker nodes:
  - AMD64 / x86_64
  - s390x
  - ppc64le

An ‘arch’ field in values.yaml is required to specify supported architectures to be used during scheduling and includes ability to give preference to certain architecture(s) over another.

Specify architecture (amd64, ppc64le, s390x) and weight to be  used for scheduling as follows :
   0 - Do not use
   1 - Least preferred
   2 - No preference
   3 - Most preferred
   
## NodeSelector and Tolerations

Set values like :

```
customNodeSelectorTerms:
- key: icp4data
  operator: In
  values:
  - database-db2oltp

customTolerations:
- key: "icp4data"
  operator: "Equal"
  value: "database-db2oltp"
  effect: "NoSchedule"
```

## PodAffinity and PodAntiAffinity

Set values like :

```
customPodAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - topologyKey: "kubernetes.io/hostname"
    labelSelector:
      matchLabels:
        type: "engine"

customPodAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: security
          operator: In
          values:
          - S2
      topologyKey: failure-domain.beta.kubernetes.io/zone
```

## Storage
No data storage used.


## Filesystem permissions required 

No permission needed.

## Multiple instance support
IBM Db2 Data Management Console support provision multiple instances in a single kubernetes cluster, each instance must be deployed in a separate namespace.

## Limitations
You can not deploy multiple instances in a same namespace.

## Must gather process
If you hit any issue, please gather the following log, and contact IBM Support to begin diagnosing,
1. View details of the instance to identify your Deployment id.
2. On your Cloud Pak for Data master node, run this command to get your pod name
  oc get po|grep <Deployment id>
3. goto the pod
  oc exec -it <pod name>  bash
4. Run collect_logs.sh in the pod

## Documentation
KnowledgeCenter url: https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_3.0.1/svc-welcome/dmc.html




