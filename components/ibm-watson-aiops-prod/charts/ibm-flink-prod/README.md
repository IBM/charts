# ibm-flink-prod

IMPORTANT NOTE: This chart should only be deployed as a subchart, with Watson AIOps.

## Introduction

This chart provides Apache Flink support to Watson AIOps.
​

## Chart Details
​
This chart creates several pods, deployments, services, and secrets to create the Watson AIOps offering.
​
#### Pods:

* `ibm-flink-job-manager-*` : Pods for managing the Apache Flink jobs.
* `ibm-flink-task-manager-*` : Pods for data ingestion and pre-processing for logs, alerts and events.

#### Deployments:

* `ibm-flink-job-manager` : Deployment for managing the Apache Flink jobs.
* `ibm-flink-task-manager` : Deployment for data ingestion and pre-processing for logs, alerts and events.

#### Services:

* `ibm-flink-job-manager` : Service for managing the Apache Flink jobs.

#### Secrets:

* `flink-config-secret` : Credentials for connecting to Flink

## Prerequisites

See parent chart for details.

## Red Hat OpenShift SecurityContextConstraints Requirements
​
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster-scoped as well as namespace-scoped pre- and post-actions that need to be taken.
​
The predefined SecurityContextConstraints name: [`restricted`](https://ibm.biz/cpkspec-scc), has been verified for this chart with one exception. S3FS requires adding `flexVolume` to the `volumes` section. This is detailed in the following custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart.
​
  - From the user interface, you can copy and paste the following snippets to enable the custom SecurityContextConstraints
    - Custom SecurityContextConstraints definition:
      ```
      apiVersion: security.openshift.io/v1
      kind: SecurityContextConstraints
      metadata:
        name: ibm-watson-zeno-scc
      priority: null
      allowHostDirVolumePlugin: false
      allowHostIPC: false
      allowHostNetwork: false
      allowHostPID: false
      allowHostPorts: false
      allowPrivilegeEscalation: true
      allowPrivilegedContainer: false
      allowedCapabilities: null
      apiVersion: security.openshift.io/v1
      defaultAddCapabilities: null
      fsGroup:
        type: MustRunAs
      groups:
      - system:authenticated
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
      users:
      - system:serviceaccount:zeno
      volumes:
      - configMap
      - downwardAPI
      - emptyDir
      - hostPath
      - persistentVolumeClaim
      - projected
      - secret
      - flexVolume
      ```
​
## Resources Required

See parent chart for details.

## Installing the Chart

See parent chart for details.

### Uninstalling the Chart

See parent chart for details.

## Configuration

See parent chart for details.

## Limitations

See parent chart for details.

## Documentation
[IBM Watson™ AIOps](https://www.ibm.com/products/watson-aiops) is documented in more detail in the [IBM Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/svc-aiops).
