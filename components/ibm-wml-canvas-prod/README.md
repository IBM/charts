# wml-canvas helm chart

Use the SPSS® Modeler service to create SPSS Modeler flows in IBM Cloud™ Pak™ for Data. You can quickly develop predictive models using business expertise and deploy them into business operations to improve decision making. Designed around the long-established SPSS Modeler client software and the industry-standard CRISP-DM model it uses, the flows interface in Cloud Pak for Data supports the entire data mining process, from data to better business results.

## Objectives
- Be a *top-level* helm chart under which all the other helm charts for canvas can exist.
- Be a single point such that installing this helm chart will install all the others to make the wml-canvas work.
- Provide a modular structure so we can add/remove subcharts as our mix of docker images changes
- Provide any over-all cross-canvas values which will over-ride the sub-chart values
- Provide any global values which the sub-charts can use

## Introduction
This helm chart deploy spss modeler add-on

## Chart Details
- See [Details](http://rhea.svl.ibm.com:9081/support/knowledgecenter/SSQNUZ_2.5.0/cpd/svc/spss/spss-install-svc.html)

## Resources Required
- See [Details](http://rhea.svl.ibm.com:9081/support/knowledgecenter/SSQNUZ_2.5.0/cpd/svc/spss/spss-install-svc.html)


## Prerequisites
* Kubernetes 1.11.0 or later / Openshift 3.11, with beta APIs enabled.
* A user with cluster administrator role is required to install the chart.

	  
## Installing the Chart

* Use cp4d installer command: 
 See [Details](http://rhea.svl.ibm.com:9081/support/knowledgecenter/SSQNUZ_2.5.0/cpd/svc/spss/spss-install-svc.html)

* Use helm install command

```
	helm install --name ibm-wml-canvas-prod --tls
```

## Configuration
- See [Details](http://rhea.svl.ibm.com:9081/support/knowledgecenter/SSQNUZ_2.5.0/cpd/svc/spss/spss-install-svc.html)

## Limitations
- See [Details](http://rhea.svl.ibm.com:9081/support/knowledgecenter/SSQNUZ_2.5.0/cpd/svc/spss/spss-install-svc.html)

## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:
* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
  - Custom PodSecurityPolicy definition:
    ```yaml
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy is the most restrictive,
          requiring pods to run with a non-root UID, and preventing pods from accessing the host."
        seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
        seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
      name: ibm-restricted-psp-custom-wa
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
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```yaml
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-restricted-clusterrole-custom-wa
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-restricted-psp-custom-wa
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```
- Alternatively, you can go to `ibm_cloud_pak/pak_extensions/pre-install/namespaceAdministration` in your chart directory and run ```./createSecurityNamespacePrereqs.sh {namespace-name}```

## Red Hat OpenShift SecurityContextConstraints Requirements
- This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

## Limitations
- Linux on Power (ppc64le) is not supported.
- Mixed worker node architecture deployments are not supported.

## Documentation

Find out more about [Creating SPSS Modeler Flows](http://rhea.svl.ibm.com:9081/support/knowledgecenter/SSQNUZ_2.5.0/wsd/spss-modeler.html).

_Copyright© IBM Corporation 2018, 2019. All Rights Reserved._
