# IBM Watson Assistant Operator

Operator chart that manages IBM Watson Assistant installations.

TODO: Fill in reasonable content

## Introduction

## Chart Details

## Prerequisites

This operator does not require a PodDisruptionBudget to be created as short outages during pod maintenances can be tolerated (in case of operators).

## Resources Required

## Installing the Chart

## Configuration

## Limitations

## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the web interface of your cluster or the supplied instructions/scripts in the pak_extension pre-install directory.

-   From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
    -   Custom PodSecurityPolicy definition:
        ```yaml
        apiVersion: extensions/v1beta1
        kind: PodSecurityPolicy
        metadata:
            annotations:
                kubernetes.io/description: "This policy is the most restrictive,
                    requiring pods to run with a non-root UID, and preventing pods from accessing the host."
                seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
                seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
            name: ibm-restricted-psp-custom-wa-operator
        spec:
            allowPrivilegeEscalation: false
            forbiddenSysctls:
                - "*"
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
    -   Custom ClusterRole for the custom PodSecurityPolicy:
        ```yaml
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRole
        metadata:
            name: ibm-restricted-clusterrole-custom-wa
        rules:
            - apiGroups:
                  - extensions
              resourceNames:
                  - ibm-restricted-psp-custom-wa-operator
              resources:
                  - podsecuritypolicies
              verbs:
                  - use
        ```

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart has no Red Hat specific SecurityContextConstraints requirements. Follow the generic SecurityContextConstraints requirements below.

### SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart.
Please use the standard definition of the restricted SCC below if you would like to create a Custom SecurityContextConstraints definition:

```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
    name: restricted
    annotations:
        kubernetes.io/description:
            restricted denies access to all host features and requires
            pods to be run with a UID, and SELinux context that are allocated to the namespace.  This
            is the most restrictive SCC and it is used by default for authenticated users.
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
defaultAddCapabilities: null
fsGroup:
    type: MustRunAs
groups:
    - system:authenticated
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
    - KILL
    - MKNOD
    - SETUID
    - SETGID
runAsUser:
    type: MustRunAsRange
seLinuxContext:
    type: MustRunAs
supplementalGroups:
    type: RunAsAny
users: []
volumes:
    - configMap
    - downwardAPI
    - emptyDir
    - persistentVolumeClaim
    - projected
    - secret
```

You must install Watson Assistant Operator into the same namespace as IBM Cloud Pak for Data which is normally `zen`.

Run this command to bind the `restricted` SecurityContextConstraint to the IBM Cloud Pak for Data namespace:

```bash
oc adm policy add-scc-to-group restricted system:serviceaccounts:{namespace}
```

-   `{namespace}` is the namespace where IBM Cloud Pak for Data is installed (normally zen).
