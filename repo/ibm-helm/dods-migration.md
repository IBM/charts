# Name

IBM Decision Optimization on IBM Cloud Pak for Data

# Introduction

## Summary

IBM Decision Optimization on IBM Cloud Pak for Data (DODS) is an add-on to Cloud Pack for Data that provides advanced decision capabilities.
You can use the IBM Decision Optimization service within IBM Cloud Pak for Data to capitalize on the power of prescriptive analytics. The IBM Decision Optimization service provides CPLEX optimization engines that enable your organization to make optimal business decisions by evaluating millions of possibilities to find the most appropriate prescriptive solutions.

You can develop optimal solutions that improve operational efficiency by combining data science capabilities, machine-learning techniques, model management, and deployment.

## Features

* Prepare data
* Import or create Decision Optimization models in
    * Python
    * OPL
    * Natural language (using the Modeling Assistant)
* Solve models and compare multiple scenarios
* Visualize data, solutions and produce reports
* Save models to deploy with Watson Machine Learning

## Prerequisites

This add-on pre-reqs Cloud Pack for Data, and the Watson Studio and Watson Machine Learning add-ons.

For information on prerequisites see [Planning installation] (https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_latest/cpd/plan/planning.html)

### Resources Required

For information on resources required see [System requirements for services] (https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_latest/sys-reqs/services_prereqs.html)

This service does not install a PodDisruptionBudget.

## PodSecurityPolicy Requirements

None.

## SecurityContextConstraints Requirements

This uses the Openshift built-in policy: `restricted` (default SCC)

Custom SecurityContextConstraints definition:
```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: >-
      Example DODS scc: this is the same as build-in openshift restricted-v2.
      It denies access to all host features and requires pods to be run
      with a UID, and SELinux context that are allocated to the namespace.  This
      is the most restrictive SCC and it is used by default for authenticated
      users.
  name: dods-scc
allowHostPorts: false
priority: null
requiredDropCapabilities:
  - ALL
allowPrivilegedContainer: false
runAsUser:
  type: MustRunAsRange
users: []
allowHostDirVolumePlugin: false
seccompProfiles:
  - runtime/default
allowHostIPC: false
seLinuxContext:
  type: MustRunAs
readOnlyRootFilesystem: false
fsGroup:
  type: MustRunAs
groups: []
defaultAddCapabilities: null
supplementalGroups:
  type: RunAsAny
volumes:
  - configMap
  - downwardAPI
  - emptyDir
  - persistentVolumeClaim
  - projected
  - secret
allowHostPID: false
allowHostNetwork: false
allowPrivilegeEscalation: false
allowedCapabilities:
  - NET_BIND_SERVICE
```

# Installing the Chart

The recommended way to install this product is using the cpd-cli utility shipped with Cloudpak for Data.

For information on installation see [Decision Optimization installation](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_latest/do/cpd_svc/do-install.html)

## Chart Details

For information on chart details see [Decision Optimization installation](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_latest/do/cpd_svc/do-install.html)

## Configuration

For information on installation and configuration see [Decision Optimization installation](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_latest/do/cpd_svc/do-install.html)

## Storage

This add-on does not create storage on its own, and rely on Cloud Pack for Data platform storage capabilities

## Limitations

* Platforms supported: RedHat OpenShift on Linux x86_64 or ppc64le
* Only one instance of this service can be installed per namespace.

## Documentation

For more information about IBM Decision Optimization, see [Decision Optimization on Cloud Pak for Data](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_latest/svc-welcome/do.html) 
