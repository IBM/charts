Knol Document Extract Feature

# metadata-api

## Installing the Chart

## Configuration

## Introduction

## Chart Details

## Resources Required

## Prerequisites

## SecurityContextConstraints Requirements

## PodSecurityPolicy Requirements

Custom PodSecurityPolicy definition:
Custom SecurityContextConstraints definition:

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

## Red Hat OpenShift SecurityContextConstraints Requirements

[`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)

[`nonroot`](https://ibm.biz/cpkspec-scc)

[`restricted`](https://ibm.biz/cpkspec-scc)

## Limitations


# Links

## Image Information

