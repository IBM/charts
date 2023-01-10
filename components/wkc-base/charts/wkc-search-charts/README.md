This chart is used to install the wkc-search service.

## Introduction


## Chart Details


## Prerequisites


## Resources Required


## Installing the Chart


## Configuration


## Limitations


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
This README does contain the right link: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc)

Custom SecurityContextConstraints definition:

```
...
```