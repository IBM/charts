# WKC UG&I Base 2 Charts

# Introduction

## Chart Details

Responsible for laying down the core set of services for UG&I Base

1. Data Flows
2. Spark Cluster
3. Spark Engine
4. Recommendation Engine
5. Profiling
6. Policy UI
7. BG Services
8. Scheduling
9. Policy Service
10. Lineage


### Configuration


## Installing the Chart

To install, issue the following helm command with the appropriate release `release-name`


##### Single-node install:

```bash
$ helm upgrade wkc-base2 ./wkc-base2 --namespace wkc --install
```

##### Multi-node install:

```bash
$ helm upgrade wkc-base2 ./wkc-base2 --namespace wkc --install -f ./wkc-base2/values-multinode.yaml
```

## Configuration

You may change the default of each parameter using the `--set key=value[,key=value]`.

You can also change the default values.yaml and supply it with `-f`

The following tables lists the configurable parameters


| Parameter                           | Description                                         | Default                                                                         |
| ----------------------------------- | ----------------------------------------------------| --------------------------------------------------------------------------------|
| `enabled.spark-engine`              | Whether to install spark engine services            | `true`                                                                          |
| `enabled.dataflow`                  | Whether to install dataflow services                | `true`                                                                          |
| `enabled.policy-ui`                 | Whether to install policy ui services               | `true`                                                                          |
| `enabled.glossary`                  | Whether to install glossary services                | `true`                                                                          |
| `enabled.recommendation`            | Whether to install recommendation services          | `true`  
| `enabled.profiling`                 | Whether to install profling services                | `true`                                                                          |

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

