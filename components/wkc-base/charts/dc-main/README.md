# DataCatalog Charts

## Introduction

The Data Catalog microservice that is responsible for the data manager offering in WDP.

There are two main purposes for this microservice:
1) Serve as the leader in authentication. All other followers will redirect to this microservice for authentication
2) Serve common pages for the data catalog offering such as pre-auth and post-auth pages.
3) Serve up WKC roles API.
4) Serve up WKC manage catalogs UIs.

## Prerequisites

- Kubernetes 1.8+ with Beta APIs enabled

## Chart Details

## Resources Required

## Installing the Chart

## Uninstalling the Chart

To uninstall/delete the deployment:

```bash
$ helm delete dc-main
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

## Limitations

# PodSecurityPolicy Requirements

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

# Red Hat OpenShift SecurityContextConstraints Requirements

This README does contain the right link: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
This README does contain the right link: [`ibm-privileged-scc`](https://ibm.biz/cpkspec-scc)

Custom SecurityContextConstraints definition:

```
...
```

