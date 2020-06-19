# ds-cloudpaks
# IBM  DataStage Enterprise Add-On  Helm Chart

IBM DataStage Enterprise enables you to transform, integrate, and move data from various sources and targets. Using an intuitive Flow Designer with wide range of transformers and stages enables you to design simple and complex jobs and efficiently integrate data with a powerful parallel engine.

## Introduction

This chart consists of IBM DataStage Enterprise intended to be deployed in production environments.

## Chart Details

This chart will do the following
- It will deploy DataStage Enterprise service.  

## Prerequisites
- Information Server will need to be deployed before deploying DataStage Enterprise. 

## Installing the Chart

> **Tip**: List all releases using `helm list`

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```
helm delete --purge my-release --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the 0074-datastage chart and their default values.

### Common Parameters

| Parameter                                 | Description                       | Default Value                |
|-------------------------------------------|-----------------------------------|------------------------------|
| release.image.pullPolicy                  | Image Pull Policy                 | IfNotPresent                 |
| release.image.repository                  | Image Repository                  | N/A                          |
| release.image.tag                         | Image Tag                         | 11.7.1.1                     |
| persistence.enabled                       | Enable persistence                | true                         |
| persistence.useDynamicProvisioning        | Use Dynamic PV Provisioning       | true                         |

### Containers Parameters


#### Resources Required

Default parameters values for the cpu and memory to use in each container in the format `<prefix>.<suffix>`

|  Prefix/Suffix                |resources.requests.cpu|resources.requests.memory|
|-------------------------------|----------------------|-------------------------|
|**ds-compute**	                |2000m                 |6000Mi                   |

> **Tip**: You can use the default [values.yaml](values.yaml)

## Persistence

- Persistent storage configured for the engine conductor pod is shared by the ds-compute pods.

## Resources Required
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
