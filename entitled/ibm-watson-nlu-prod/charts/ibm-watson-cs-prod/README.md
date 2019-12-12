# ibm-watson-cs-prod
This chart contains the Common Service components for IBM Watson's NLU (Natural Language Understanding) service.

## Introduction
Common Service enables features for Watson Natural Language Processing.

## Chart Details
This chart creates one pod and an associated service, called `ibm-watson-cs-common-service`.

Common Service directly depends on the the model-uploader job, which must run to completion before the Common Service pods become ready. The model-uploader job populates the MinIO database with all the required models that enable Watson Natural Language Processing functionality.

## Prerequisites
See parent [README](../../README.md)

## Resources Required
See parent [README](../../README.md)

## Installing the Chart
N/A; this chart should not be released in isolation.

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart
N/A; this chart should not be released in isolation.

## Configuration
The configuration parameters for the Model Management API chart should be set by the Umbrella chart including it. This chart should not exist in isolation.

## Storage
See parent [README](../../README.md)

## Limitations
See parent [README](../../README.md)

## PodSecurityPolicy Requirements
See parent [README](../../README.md)

## Documentation
See parent [README](../../README.md)

## PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP4D user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

    - From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

        - Custom PodSecurityPolicy definition:
        ```
        apiVersion: extensions/v1beta1
        kind: PodSecurityPolicy
        metadata:
          name: ibm-watson-cs-psp
        spec:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: false
          allowedCapabilities:
          - CHOWN
          - DAC_OVERRIDE
          - SETGID
          - SETUID
          - NET_BIND_SERVICE
          seLinux:
            rule: RunAsAny
          supplementalGroups:
            rule: RunAsAny
          runAsUser:
            rule: RunAsAny
          fsGroup:
            rule: RunAsAny
          volumes:
          - configMap
          - secret
        ```

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints name: [`restricted`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart.

    - From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints

        - Custom SecurityContextConstraints definition:
        ```
        apiVersion: security.openshift.io/v1
        kind: SecurityContextConstraints
        metadata:
          name: ibm-watson-cs-scc
        readOnlyRootFilesystem: false
        allowedCapabilities:
        - CHOWN
        - DAC_OVERRIDE
        - SETGID
        - SETUID
        - NET_BIND_SERVICE
        seLinux:
          type: RunAsAny
        supplementalGroups:
          type: RunAsAny
        runAsUser:
          type: RunAsAny
        fsGroup:
          rule: RunAsAny
        volumes:
        - configMap
        - secret
        ```
