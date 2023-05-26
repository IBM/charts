# IBM Connect Direct for Unix v6.3.0

## Introduction
  
IBM® Connect:Direct® for UNIX links technologies and moves all types of information between networked systems and computers. It manages high-performance transfers by providing such features as automation, reliability, efficient use of resources, application integration, and ease of use. Connect:Direct (C:D) for UNIX offers choices in communications protocols, hardware platforms, and operating systems. It provides the flexibility to move information among mainframe systems, midrange systems, desktop systems, LAN-based workstations and cloud based storage providers (Amazon S3 Object Store for current release). To find out more, see the Knowledge Center for [IBM Connect:Direct](https://www.ibm.com/support/knowledgecenter/SS4PJT_6.3.0/cd_unix_63_welcome.html).

## Chart Details

This chart deploys IBM Connect Direct on a container management platform with the following resources deployments

- a statefulset pod `<release-name>-ibm-connect-direct` with 1 replica by default.
- a configMap `<release-name>-ibm-connect-direct`. This is used to provide default configuration in cd_param_file.
- a service `<release-name>-ibm-connect-direct`. This is used to expose the C:D services for accessing using clients.
- a service-account `<release-name>-ibm-connect-direct-serviceaccount`. This service will not be created if `serviceAccount.create` is `false`.
- a persistence volume claim `<release-name>-ibm-connect-direct`.
- a monitoring dashboard `<release-name>-ibm-connect-direct`. This will not be created if `dashboard.enabled` is `false`.

## Prerequisites

Please refer to [Planning](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=software-planning) and [Pre-installation tasks](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-pre-installation-tasks) section in the online Knowledge Center documentation. 

### PodSecurityPolicy Requirements

In Kubernetes the Pod Security Policy (PSP) control is implemented as optional (but recommended). Click here for more information on Pod Security Policy. Based on your organization security policy, you may need to decide the pod security policy for your Kubernetes cluster. The IBM Connect Direct for UNIX chart defines a custom Pod Security Policy which is the minimum set of permissions/ capabilities needed to deploy this chart and the Connect Direct for Unix container to function properly. This is the recommended PSP for this chart and it can be created on the cluster by cluster administrator. The PSP and cluster role for this chart is defined below. The cluster administrator can either use the snippets given below or the scripts provided in the Helm chart to create the PSP, cluster role and tie it to the namespace where deployment will be performed. In both the cases, same PSP and cluster role will be created. It is recommended to use the scripts in the Helm chart so that required PSP and cluster role is created without any issue.

* Custom PodSecurityPolicy definition:
```
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: ibm-connect-direct-psp
  labels:
    app: "ibm-connect-direct-psp"
spec:
  privileged: false
  allowPrivilegeEscalation: true
  hostPID: false
  hostIPC: false
  hostNetwork: false
  requiredDropCapabilities:
  allowedCapabilities:
  - CHOWN
  - SETGID
  - SETUID
  - DAC_OVERRIDE
  - FOWNER
  - AUDIT_WRITE
  - SYS_CHROOT
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
  name: "ibm-connect-direct-psp"
  labels:
    app: "ibm-connect-direct-psp"
rules:
- apiGroups:
  - policy
  resourceNames:
  - ibm-connect-direct-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```
- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh <NAMESPACE>

### SecurityContextConstraints Requirements

The IBM Connect:Direct for Unix chart requires an SecurityContextConstraints (SCC) to be tied to the target namespace prior to deployment.
Based on your organization security policy, you may need to decide the security context constraints for your OpenShift cluster.
This chart has been verified on privileged SCC which comes with Redhat OpenShift. For more info, please refer this link. This chart defines a custom SCC which is the minimum set of permissions/capabilities needed to deploy this chart and the Connect Direct for Unix container to function properly. It is based on the predefined restricted SCC with extra required privileges. This is the recommended SCC for this chart and it can be created on the cluster by cluster administrator. The SCC and cluster role for this chart is defined below. The cluster administrator can either use the snippets given below or the scripts provided in the Helm chart to create the SCC, cluster role and tie it to the project where deployment will be performed. In both the cases, same SCC and cluster role will be created. It is recommended to use the scripts in the Helm chart so that required SCC and cluster role is created without any issue.

* Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-connect-direct-scc
  labels:
    app: "ibm-connect-direct-scc"
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
privileged: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: true
allowedCapabilities:
- FOWNER
- CHOWN
- SETGID
- SETUID
- DAC_OVERRIDE
- AUDIT_WRITE
- SYS_CHROOT
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
requiredDropCapabilities: 
- ALL
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: MustRunAs
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
priority: 0
```

- Custom ClusterRole for the custom SecurityContextConstraints:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: "ibm-connect-direct-scc"
  labels:
    app: "ibm-connect-direct-scc"
rules:
- apiGroups:
  - security.openshift.io
  resourceNames:
  - ibm-connect-direct-scc
  resources:
  - securitycontextconstraints
  verbs:
  - use
```

- From the command line, you can run the setup scripts included under pak_extensions (untar the downloaded archive to extract the pak_extensions directory)

  As a cluster admin the pre-install script is located at:
  - pre-install/clusterAdministration/createSecurityClusterPrereqs.sh

  As team admin the namespace scoped pre-install script is located at:
  - pre-install/namespaceAdministration/createSecurityNamespacePrereqs.sh <NAMESPACE>

## Resources Required

This chart uses the following resources by default:

* 100Mi of persistent volume
* 1 GB Disk space
* 500m CPU
* 2000MB Memory

## Agreement to IBM Connect:Direct for Unix License

You must read the IBM Connect:Direct for Unix License agreement terms before installation, using the below link:
[License](http://www-03.ibm.com/software/sla/sladb.nsf) (L/N:  L-FYHF-K7J2TN)

## Installing the Chart

Please refer [Installing](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=software-installing) section in the online Knowledge Center documentation.

## Configuration

Please refer the [Configuring - Understanding values.yaml](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=tasks-configuring-understanding-valuesyaml) section in the online Knowledge Center documentation.

## Verifying the Chart

Please refer the [Validating the Installation](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## Upgrading the Chart

Please refer the [Upgrade - Upgrading a Release](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=uninstall-upgrade-upgrading-release) section in the online Knowledge Center documentation.

## Uninstalling the Chart

Please refer the [Uninstall – Uninstalling a Release](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=uninstall-uninstalling-release) section in the online Knowledge Center documentation.

## Backup & Restore

**To Backup:**

You need to take backup of configuration data and other information like stats and TCQ which are present in the persistent volume by following the below steps:

1. Go to mount path of Persistent Volume. 

2. Make copy of all of the directories listed below and store them at your desired and secured place.
   * `WORK`
   * `CFG`
   * `SECPLUS`
   * `SECURITY`
   * `PROCESS`
   * `FACONFIG`
   * `FALOG`

> **Note**:In case of traditional installation of Connect:Direct for Unix, you should take the backup of the below directories and save them at your desired location:
   * `<installDir>/work`
   * `<installDir>/ndm/cfg`
   * `<installDir>/ndm/secure+`
   * `<installDir>/ndm/security`
   * `<installDir>/process`
   * `<installDir>/file_agent/config`
   * `<installDir>/file_agent/log`
   

**To Restore:**

Restoring the data in new deployment, it can be achieved by following steps

1. Create a Persistent Volume.

2. Copy all the backed up directories to the mount path of Persistent Volume.

3. Create a new deployment using the above Persistent Volume using variable `persistentVolume.name` in helm cli command. The pod would come up with desired data.

## Exposing Services

Please refer to [Exposed Services](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## DIME and DARE

Please refer to [DIME and DARE Security Considerations](https://www.ibm.com/docs/en/connect-direct/6.3.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## Limitations

- High availability and scalability are supported in traditional way of Connect:Direct deployment using Kubernetes load balancer service.
- IBM Connect:Direct for Unix chart is supported with only 1 replica count.
- IBM Connect:Direct for Unix chart supports x64 architecture only.
- Interaction with IBM Control Center Director is not supported.
- Non-persistence mode is not supported
