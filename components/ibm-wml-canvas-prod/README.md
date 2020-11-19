# IBM Watson Studio Local

IBM Watson Studio Local provides a suite of tools for data scientists, application developers, subject matter experts and other teams in the organization so they can collaboratively connect to data, manipulate that data, and use it to build, train, and deploy models at scale.

IBM Watson Machine Learning accelerates the process of moving to deployment and integrate AI into their applications. Watson Studio along with Watson Machine Learning offers a single interface to manage the entire analytics lifecycle, from discovery to production.

IBM Watson Studio Local - SPSS Modeler Add On accelerate time to value and achieve desired outcomes by speeding up operational tasks for data scientists.  SPSS Modeler now comes with many new features which includes Graph node to generate interactive charts and Text Analytics.

## Introduction

This chart deploys IBM Watson Studio Local.

## Chart Details

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/overview/overview.html)

## Prerequisites

- Install a PodDisruptionBudget.
- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/install/install.html)

## Resources Required

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/install/install.html)

## Installing the Chart

- See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/svc/services.html)

## Limitations

* You must create a pull secret if you are using external docker image registry.
* You must install IBM Cloud Pak for Data before installing Watson Studio Local.

## Configuration

* See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/install/install.html)

## Requirements

* See [Details](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/install/install.html)

### Red Hat OpenShift SecurityContextConstraints Requirements

* Custom SecurityContextConstraints definition
You can copy and paste the following snippets to enable the custom PodSecurityPolicy Custom PodSecurityPolicy definition:

```
apiVersion: app/v1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive,
      requiring pods to run with a non-root UID, and preventing pods from accessing the host."
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
  name: ibm-restricted-psp-minio
spec:
  allowPrivilegeEscalation: false
  forbiddenSysctls:
  - '*'
  fsGroup:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  requiredDropCapabilities:
  - ALL
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
    - max: 65535
      min: 1
    rule: MustRunAs
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim

  ```

* The predefined SecurityContextConstraints name: `restricted` has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This README does contain the right link: [`hostmount-anyuid`](https://ibm.biz/cpkspec-scc)

```
        securityContext:
          runAsUser: {{ .Values.global.runAsUser }}
          capabilities:
            drop:
            - ALL
          allowPrivilegeEscalation: false
          privileged: false
          runAsNonRoot: true
```          
