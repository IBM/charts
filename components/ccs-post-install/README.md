# Common Core Services - Post install module

# Introduction
Module responsible in performing post install initialization. 

1. Creates a Global Catalog


# Chart Details
## Installing the Chart

To install, issue the following helm command with the appropriate release `release-name`

##### Single-node install:

```bash
$ helm upgrade ccs-post-install ./ccs-post-install --namespace wkc --install
```

## Configuration


# Prerequisites
None

## Resources Required
## PodSecurityPolicy Requirements

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
## Red Hat OpenShift SecurityContextConstraints Requirements
This README does contain the right link: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)

This README does contain the right link: [`restricted`](https://ibm.biz/cpkspec-scc)

Custom SecurityContextConstraints definition:
```
...
```
# SecurityContextConstraints Requirements
## Limitations