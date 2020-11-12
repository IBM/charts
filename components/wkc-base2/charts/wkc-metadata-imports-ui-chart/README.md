# wkc-metadata-imports-ui Chart

## Introduction

This chart is used to deploy the WKC Metadata Imports UI service in the IBM Cloud Private production environments.

## Chart Details

## Prerequisites

### PodSecurityPolicy Requirements

Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive, requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    #apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    #apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-restricted-psp
```

### Red Hat OpenShift SecurityContextConstraints Requirements

This README does contain the right link: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)

This README does contain the right link: [`restricted`](https://ibm.biz/cpkspec-scc)

Custom SecurityContextConstraints definition:
```
...
```

## Resources Required

## Installing the Chart

## Configuration

## Limitations

