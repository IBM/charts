# IBM Sterling Secure Proxy Perimeter Server v6.2.0.3

## Introduction
  
A perimeter server is used by Sterling Secure Proxy to manage inbound and outbound TCP communication. This software tool enables you to manage the communications flow between outer layers of your network and the TCP-based transport adapters. Perimeter servers can be used to restrict areas where TCP connections are initiated from more secure areas to less secure areas. To find out more, see the Knowledge Center for [IBM Sterling Secure Proxy Perimeter Server](https://www.ibm.com/docs/en/secure-proxy/6.2.0).


## Chart Details

This chart deploys IBM Sterling Secure Proxy Perimeter Server on a container management platform with the following resources deployments

- a statefulset pod `<release-name>-ibm-ssp-ps` with 1 replica by default.
- a configMap `<release-name>-ibm-ssp-ps`. This is used to provide default configuration in ps_config_file.
- a service `<release-name>-ibm-ssp-ps`. This is used to expose the PS services for accessing using clients.
- a service-account `<release-name>-ibm-ssp-ps-serviceaccount`. This service will not be created if `serviceAccount.create` is `false`.


## Prerequisites

Please refer to [Planning](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=software-planning) and [Pre-installation tasks](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=installing-pre-installation-tasks) section in the online Knowledge Center documentation. 

### SecurityContextConstraints Requirements

The IBM Sterling Secure Proxy PS chart requires an SecurityContextConstraints (SCC) to be tied to the target namespace prior to deployment. This chart defines a custom SCC which is the minimum set of permissions/capabilities needed to deploy this chart and the Sterling Secure Proxy PS container to function properly. It is based on the predefined restricted SCC with extra required privileges. This is the recommended SCC for this chart and it can be created on the cluster by cluster administrator. The SCC and cluster role for this chart is defined below. The cluster administrator can either use the snippets given below or the scripts provided in the Helm chart to create the SCC, cluster role and tie it to the project where deployment will be performed. In both the cases, same SCC and cluster role will be created. It is recommended to use the scripts in the Helm chart so that required SCC and cluster role is created without any issue.

* Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-ssp-ps-scc 
  labels:
    app: "ibm-ssp-ps-scc"
    app.kubernetes.io/instance: "ibm-ssp-ps-scc"
    app.kubernetes.io/managed-by: "IBM"
    app.kubernetes.io/name: "ibm-ssp-ps-scc"
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

## Exposing Services

Please refer to [Exposed Services](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## DIME and DARE

Please refer to [DIME and DARE Security Considerations](https://www.ibm.com/docs/en/secure-proxy/6.2.0?topic=installing-validating-installation) section in the online Knowledge Center documentation.

## Limitations

- High availability and scalability are supported in traditional way of Sterling Secure Proxy Perimeter Server deployment using Kubernetes load balancer service.
- IBM Sterling Secure Proxy Perimeter Server chart is supported with only 1 replica count.
- IBM Sterling Secure Proxy Perimeter Server chart supports only amd64 architecture.

