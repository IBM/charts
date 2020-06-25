# WKC Cloudpaks / Uber Helm Charts

## Introduction

## Chart Details

### wkc pro-prereqs
Responsible for installing all the pro-prereqs for WKC Pro.  Currently it will lay down the following pro-prereqs
1. DB2 


### Prerequisites

## Resources Required


### Installing the Chart

- Register `dataconn` helm repository `helm repo add dataconn `<Link to helm repository>--username xxx@xx.ibm.com --password xxx`


- Update dependencies using `helm dep update /wkc-cloudpaks/wkc-pro-prereqs`


- Install/upgrade with


#### Single-node install:

```bash
$ helm upgrade --install wkc-pro-prereqs ./wkc-pro-prereqs --set wdp-db2.dataVolume.host=<myhost>,wdp-db2.dataVolume.path=</var/lib/db2> --namespace wkc
```

#### Multi-node install:

```bash
$ helm upgrade --install wkc-pro-prereqs ./wkc-pro-prereqs --set wdp-db2.dataVolume.host=<myhost>,wdp-db2.dataVolume.path=</var/lib/db2> --namespace wkc -f ./wkc-pro-prereqs/values-multinode.yaml
```

## Configuration

You may change the default of each parameter using the --set key=value[,key=value].

You can also change the default values.yaml and supply it with -f


The following table lists some of configurable parameters of the DB2 chart and their default values.

| Parameter                                      | Description                                                      | Default                             |
|------------------------------------------------|------------------------------------------------------------------|-------------------------------------|
| `wdp-db2.dataVolume.host`               | dataVolume.host must be specified      | Required             |
| `wdp-db2.dataVolume.path`               | dataVolume.path must be specified     | `Required`                                |
| `wdp-db2.dataVolume.storageClassName`           | dataVolume.storageClassName               | `wdp-db2-class`                                   |
| `global.images.secretName`                 | Docker image pull secret                              | `None`                             |

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
