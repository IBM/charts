# IBM Sterling External Authentication Server v6.1.0.0

## Introduction

IBM Sterling External Authentication Server allows you to implement extended authentication and validation services for IBM products, called client applications. Sterling External Authentication Server includes a server that client applications connect to and a GUI to configure Sterling External Authentication Server requirements. To find out more, see the Knowledge Center for [IBM SEAS](https://www.ibm.com/docs/en/external-auth-server/6.1.0).

## Chart Details

This chart deploys IBM Sterling External Authentication Server on a container management platform with the following resources deployments

- a statefulset pod `<release-name>-ibm-seas` with 1 replica.
- a configMap `<release-name>-ibm-seas`. This is used to provide default configuration in seas_config_file.
- a service `<release-name>-ibm-seas`. This is used to expose the SEAS services for accessing using clients.
- a service-account `<release-name>-ibm-seas-serviceaccount`. This service will not be created if `serviceAccount.create` is `false`.
- a persistence volume claim `<release-name>-ibm-seas`.

## Prerequisites

Please refer to [Planning](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=software-planning) and [Pre-installation tasks](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=installing-pre-installation-tasks) section in the online Knowledge Center documentation. 

### SecurityContextConstraints Requirements

The IBM Sterling External Authentication Server chart requires an SecurityContextConstraints (SCC) to be tied to the target namespace prior to deployment. This chart defines a custom SCC which is the minimum set of permissions/capabilities needed to deploy this chart and the Sterling External Authentication Server container to function properly. It is based on the predefined restricted SCC with extra required privileges. This is the recommended SCC for this chart and it can be created on the cluster by cluster administrator. The SCC and cluster role for this chart is defined below. The cluster administrator can either use the snippets given below or the scripts provided in the Helm chart to create the SCC, cluster role and tie it to the project where deployment will be performed. In both the cases, same SCC and cluster role will be created. It is recommended to use the scripts in the Helm chart so that required SCC and cluster role is created without any issue.

* Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata: 
  name: ibm-seas-scc
  labels:
    app.kubernetes.io/name: ibm-seas-scc
    app.kubernetes.io/instance: ibm-seas-scc
    app.kubernetes.io/managed-by: IBM
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
privileged: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: true
requiredDropCapabilities:
- KILL
- MKNOD
- SETFCAP
- FSETID
- NET_BIND_SERVICE
- SYS_CHROOT
- SETPCAP
- NET_RAW
allowedCapabilities:
- DAC_OVERRIDE 
- SETGID
defaultAddCapabilities: []
defaultAllowPrivilegeEscalation: false
forbiddenSysctls:
- "*"
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1
    max: 4294967294
readOnlyRootFilesystem: false
runAsUser:
  type: MustRunAsRange 
  uidRangeMin: 1 
  uidRangeMax: 1000639999
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
  ranges:
  - min: 1
    max: 4294967294
volumes:
- configMap
- downwardAPI
- persistentVolumeClaim
- projected
- secret
- nfs
```

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - chmod +x pre-install/clusterAdministration/createSecurityClusterPrereqs.sh
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - chmod +x pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh <Namespace/Project>
  
### PodSecurityPolicy Requirements

In Kubernetes the Pod Security Policy (PSP) control is implemented as optional (but recommended). [Click here](https://kubernetes.io/docs/concepts/security/pod-security-policy/) for more information on Pod Security Policy. Based on your organization security policy, you may need to decide the pod security policy for your Kubernetes cluster. The IBM Sterling External Authentication Server chart defines a custom Pod Security Policy which is the minimum set of permissions/ capabilities needed to deploy this chart and the Sterling External Authentication Server container to function properly. This is the recommended PSP for this chart and it can be created on the cluster by cluster administrator. The PSP and cluster role for this chart is defined below. The cluster administrator can either use the snippets given below or the scripts provided in the Helm chart to create the PSP, cluster role and tie it to the namespace where deployment will be performed. In both the cases, same PSP and cluster role will be created. It is recommended to use the scripts in the Helm chart so that required PSP and cluster role is created without any issue.

* Custom PodSecurityPolicy definition:  

```
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-seas-psp
  labels:
    app: "ibm-seas-psp"
spec:
  privileged: false
  allowPrivilegeEscalation: true
  hostPID: false
  hostIPC: false
  hostNetwork: false
  requiredDropCapabilities:
  - KILL
  - MKNOD
  - SETFCAP
  - FSETID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETPCAP
  - NET_RAW
  allowedCapabilities:
  - DAC_OVERRIDE
  - FOWNER
  allowedHostPaths:
  runAsUser:
    rule: MustRunAsNonRoot
  runAsGroup:
    rule: MustRunAs
    ranges:
    - min: 1
      max: 4294967294
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: MustRunAs
    ranges:
    - min: 1
      max: 4294967294
  fsGroup:
    rule: MustRunAs
    ranges:
    - min: 1
      max: 4294967294
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
  - nfs
  forbiddenSysctls:
  - '*'
```

- Custom ClusterRole for the custom PodSecurityPolicy:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: "ibm-seas-psp"
  labels:
    app: "ibm-seas-psp"
rules:
- apiGroups:
  - policy
  resourceNames:
  - ibm-seas-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - chmod +x  pre-install/clusterAdministration/createSecurityClusterPrereqs.sh
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - chmod +x  pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh 
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh <Namespace/Project>

## Resources Required

Please refer [Verification of system requirements](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=planning-verification-system-requirements) section in the online Knowledge Center documentation.

## Agreement to IBM SEAS License

You must read the IBM Sterling External Authentication Server License agreement terms before installation, using the below link:
[License] http://www-03.ibm.com/software/sla/sladb.nsf (L/N: L-KNAN-CHKAUA)

## Installing the Chart

Please refer [Installing](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=installing-sterling-external-authentication-server-using-helm-chart) section in the online Knowledge Center documentation.

## Configuration

Please refer the [Configuring - Understanding values.yaml](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=tasks-configuring-understanding-valuesyaml) section in the online Knowledge Center documentation.

## Verifying the Chart

Please refer the [Validating the Installation](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## Upgrading the Chart

Please refer the [Upgrade - Upgrading a Release](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=uninstall-upgrading-release) section in the online Knowledge Center documentation.

## Rollback the Chart

Please refer the [Rollback - Recovering a Failure](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=uninstall-rollback-recovering-failure) section in the online Knowledge Center documentation.

## Uninstalling the Chart

Please refer the [Uninstall – Uninstalling a Release](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=uninstall-uninstalling-release) section in the online Knowledge Center documentation.

## Backup & Restore

**To Backup:**

You need to take backup of configuration data which are present in the persistent volume by following the below steps:

1. Go to mount path of Persistent Volume.

2. Make copy of all of the directories listed below and store them at your desired and secured place.
   * `SEAS`
  
> **Note**:In case of traditional installation of SEAS, you should take the backup of the installation directory and save them at your desired location:
   * `SEAS`

**To Restore:**

Restoring the data in new deployment, it can be achieved by following steps

1. Create a Persistent Volume.

2. Copy all the backed up directories to the mount path of Persistent Volume.

3. Create a new deployment using the helm CLI command. The pod would come up with desired data.

## Exposing Services

Please refer to [Exposed Services](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## DIME and DARE

Please refer to [DIME and DARE Security Considerations](https://www.ibm.com/docs/en/external-auth-server/6.1.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## Limitations

- High availability and scalability are supported in traditional way of SEAS deployment using Kubernetes load balancer service.
- IBM Sterling External Authentication Server chart is supported with only 1 replica count.
- IBM Sterling External Authentication Server chart supports only amd64 architecture.
- Non-persistence mode is not supported.
- The rollback support is not available from 6.1.0.0 to 6.0.3.0 due to some structural changes in IBM Sterling External Authentication Server.

