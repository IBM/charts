# IBM Sterling Secure Proxy Engine v6.2.0.1

## Introduction
  
IBM® Sterling Secure Proxy acts as an application proxy between Connect:Direct® nodes or between a client application and a Sterling B2B Integrator server. It provides a high level of data protection between external connections and your internal network. Define an inbound node definition for each trading partner connection from outside the company and an outbound node definition for every company server to which Secure Proxy will connect. To find out more, see the Knowledge Center for [IBM Sterling Secure Proxy Engine](https://www.ibm.com/docs/en/secure-proxy/6.2.0).


## Chart Details

This chart deploys IBM Sterling Secure Proxy Engine on a container management platform with the following resources deployments 

- a statefulset pod `<release-name>-ibm-ssp-engine` with 1 replica.
- a configMap `<release-name>-ibm-ssp-engine`. This is used to provide default configuration in engine_config_file.
- a service `<release-name>-ibm-ssp-engine`. This is used to expose the engine services for accessing using clients.
- a service-account `<release-name>-ibm-ssp-engine-serviceaccount`. This service will not be created if `serviceAccount.create` is `false`.
- a persistence volume claim `<release-name>-ibm-ssp-engine-pvc`.


## Prerequisites

Please refer to [Planning](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=software-planning) and [Pre-installation tasks](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=installing-pre-installation-tasks) section in the online Knowledge Center documentation. 

### SecurityContextConstraints Requirements

The IBM Sterling Secure Proxy Engine chart requires an SecurityContextConstraints (SCC) to be tied to the target namespace prior to deployment. This chart defines a custom SCC which is the minimum set of permissions/capabilities needed to deploy this chart and the Sterling Secure Proxy Engine container to function properly. It is based on the predefined restricted SCC with extra required privileges. This is the recommended SCC for this chart and it can be created on the cluster by cluster administrator. The SCC and cluster role for this chart is defined below. The cluster administrator can either use the snippets given below or the scripts provided in the Helm chart to create the SCC, cluster role and tie it to the project where deployment will be performed. In both the cases, same SCC and cluster role will be created. It is recommended to use the scripts in the Helm chart so that required SCC and cluster role is created without any issue.

* Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-ssp-engine-scc 
  labels:
    app: "ibm-ssp-engine-scc"
    app.kubernetes.io/instance: "ibm-ssp-engine-scc"
    app.kubernetes.io/managed-by: "IBM"
    app.kubernetes.io/name: "ibm-ssp-engine-scc"
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: false
allowPrivilegedContainer: false
allowedCapabilities:
defaultAddCapabilities: null
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1
    max: 4294967294
priority: 0
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsRange
  uidRangeMin: 1
  uidRangeMax: 4294967294
seLinuxContext:
  type: MustRunAs
seccompProfiles:
- runtime/default
supplementalGroups:
  type: MustRunAs
  ranges:
  - min: 1
    max: 4294967294
users: []
volumes:
- configMap
- downwardAPI
- emptyDir
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
  

## Resources Required

Please refer [Verification of system requirements](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=planning-verification-system-requirements) section in the online Knowledge Center documentation.

## Agreement to IBM SSP License

You must read the IBM Sterling Secure Proxy License agreement terms before installation, using the below link:
[License] http://www-03.ibm.com/software/sla/sladb.nsf (L/N: L-NKDT-7M46YH)

## Installing the Chart

Please refer [Installing](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=installing-sterling-secure-proxy-using-helm-chart) section in the online Knowledge Center documentation.

## Configuration

Please refer the [Configuring - Understanding values.yaml](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=tasks-configuring-understanding-valuesyaml) section in the online Knowledge Center documentation.

## Verifying the Chart

Please refer the [Validating the Installation](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## Upgrading the Chart

Please refer the [Upgrade - Upgrading a Release](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=uninstall-upgrading-release) section in the online Knowledge Center documentation.

## Rollback the Chart

Please refer the [Rollback - Recovering a Failure](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=uninstall-rollback-recovering-failure) section in the online Knowledge Center documentation.

## Uninstalling the Chart

Please refer the [Uninstall – Uninstalling a Release](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=uninstall-uninstalling-release) section in the online Knowledge Center documentation.

## Backup & Restore

**To Backup:**

You need to take backup of configuration data which are present in the persistent volume by following the below steps:

1. Go to mount path of Persistent Volume. 

2. Make copy of all of the directories listed below and store them at your desired and secured place.
   * `ENGINE`

> **Note**:In case of traditional installation of Sterling Secure Proxy Engine, you should take the backup of the installation directory and save them at your desired location:
   * `ENGINE`
   
**To Restore:**

Restoring the data in new deployment, it can be achieved by following steps

1. Create a Persistent Volume.

2. Copy all the backed up directories to the mount path of Persistent Volume.

3. Create a new deployment using the helm CLI command. The pod would come up with desired data.

## Exposing Services

Please refer to [Exposed Services](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## DIME and DARE

Please refer to [DIME and DARE Security Considerations](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## Limitations

- High availability and scalability are supported in traditional way of Sterling Secure Proxy Engine deployment using Kubernetes load balancer service.
- IBM Sterling Secure Proxy Engine chart is supported with only 1 replica count.
- IBM Sterling Secure Proxy Engine chart supports only amd64 architecture.
- Non-persistence mode is not supported.
