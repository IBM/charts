# metadata-api

## Installing the Chart

TBD

## Configuration

TBD





## Introduction

This chart creates an Automated Metadata Generation deployment with a small (25) term set fronted with a REST API.

## Chart Details

This chart will do the following:

* Create a deployment of Automated Metadata Generation.
* Create a Service to export the Automated Metadata Generation service outside the cluster.
* Optionally, create an Ingress or Route to export the Automated Metadata Generation service outside the cluster.

## Resources Required

* REST API
  * Requests
    * 0.1 CPU
    * 32 MB of memory
  * Limits
    * 1 CPU
    * 64 MB of memory
* Engine
  * Requests
    * 0.5 CPU
    * 128 MB of memory
  * Limits
    * 8 CPU
    * 8 GB of memory

`emptyDir` volumes are used for temporary storage of files being processed.  The amount of storage required is relative to the volume of requests being serviced and the speed with which they are processed.  For typical workloads 5GB should be adequate.


## Prerequisites

This chart was tested with the following software and versions.

 Installing a PodDisruptionBudget

* Kubernetes 1.12 or later
* Tiller 2.9.1 or later

## PodSecurityPolicy Requirements

Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    helm.sh/hook: test-success
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

## Limitations


# Links

* [`nonroot`](https://ibm.biz/cpkspec-scc)

## Image Information

The following images are referenced in this chart:

* metadata-api:${VERSION_TAG}
* amg-standalone:${ENGINE_VERSION_TAG}
