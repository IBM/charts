[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # (\(C\) Copyright IBM Corporation 2016-2019 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)

# Cloud Automation Manager Helm Chart

IBM Cloud Automation Manager is a cloud management solution on IBM Cloud Private (ICP) for deploying cloud infrastructure in multiple clouds with an optimized user experience.

## Introduction

IBM Cloud Automation Manager uses open source Terraform to manage and deliver cloud infrastructure as code. Cloud infrastructure delivered as code is reusable, able to be placed under version control, shared across distributed teams, and it can be used to easily replicate environments.

The Cloud Automation Manager content library comes pre-populated with sample templates to help you get started quickly. Use the sample templates as is or customize them as needed.  A Chef runtime environment can also be deployed using CAM for more advanced application configuration and deployment.

With Cloud Automation Manager, you can provision cloud infrastructure and accelerate application delivery into IBM Cloud, Amazon EC2, VMware vSphere, VMware NSXv, VMware NSX-T, Google Cloud, Microsoft Azure, IBM PureApplication, OpenStack and Huawei cloud environments with a single user experience.

You can spend more time building applications and less time building environments when cloud infrastructure is delivered with automation. You are able to get started fast with pre-built infrastructure from the Cloud Automation Manager library.

## Chart Details

This chart deploys IBM Cloud Automation Manager as a number of deployments, services and an ingress.

## Prerequisites

IBM Cloud Automation Manager is only supported to run in IBM Cloud Private.

### PodSecurityPolicy Requirements

This chart must be deployed to the `services` namespace and requires a PodSecurityPolicy to be bound to that namespace.

The predefined PodSecurityPolicy name: [`ibm-anyuid-hostpath-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart. This policy is bound to the `services` namespace by default in IBM Cloud Private.

This chart also defines a custom PodSecurityPolicy which is used to finely control the permissions/capabilities needed to deploy this chart.

- Custom PodSecurityPolicy definition:
```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  labels:
    name: cam-services-ps
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
  name: cam-services-psp
spec:
  privileged: false
  allowPrivilegeEscalation: false
  hostPID: false
  hostIPC: false
  hostNetwork: false
  allowedCapabilities:
  - SETPCAP
  - AUDIT_WRITE
  - CHOWN
  - NET_RAW
  - DAC_OVERRIDE
  - FOWNER
  - FSETID
  - KILL
  - SETGID
  - SETUID
  - NET_BIND_SERVICE
  - SYS_CHROOT
  - SETFCAP
  requiredDropCapabilities:
  - MKNOD
  readOnlyRootFilesystem: false
{{- if .Values.global.audit }}
  allowedHostPaths:
    - pathPrefix: {{ .Values.auditService.config.journalPath }}
      readOnly: false
  runAsUser:
    rule: RunAsAny
{{- else }}
  runAsUser:
    ranges:
    - max: 1111
      min: 999
    rule: MustRunAs
{{- end }}
  fsGroup:
    ranges:
    - max: 1111
      min: 999
    rule: MustRunAs
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    ranges:
      - max: 1111
        min: 999
    rule: MustRunAs
  volumes:
    - configMap
    - emptyDir
    - secret
    - persistentVolumeClaim
    - nfs
    - downwardAPI
    - projected
  ```

## Resources Required

* The minimum hardware requirements for IBM Cloud Automation Manager is a single worker node with at least 12 vCPU and 30GB of memory.
For a full list of hardware requirements see: https://www.ibm.com/support/knowledgecenter/SS2L37_3.1.2.0/cam_requirements.html

* Persistent Volumes are required to be pre-created. For details see: https://www.ibm.com/support/knowledgecenter/SS2L37_3.1.2.0/cam_create_pv.html

* This chart requires elevated privileges to run. For details see: https://www.ibm.com/support/knowledgecenter/SS2L37_3.1.2.0/cam_requirements.html

## Installing the Chart

This chart supports various installation options. For complete details please see: https://www.ibm.com/support/knowledgecenter/SS2L37_3.1.2.0/cam_planning.html

## Configuration

For the full list of configuration options supported by this chart see: https://www.ibm.com/support/knowledgecenter/SS2L37_3.1.2.0/cam_installation_parameters.html

## Limitations

* IBM Cloud Automation Manager is only supported to run on an IBM Cloud Private cluster
* Only one instance of Cloud Automation Manager may be running in the cluster
* This chart must be deployed in the 'services' namespace.

## Documentation

For version-wise installation instructions and detailed documentation of IBM Cloud Automation Manager (CAM), go to its Knowledge Center at https://www.ibm.com/support/knowledgecenter/SS2L37/product_welcome_cloud_automation_manager.html.

Select your version from the drop-down list and search for your topics from within the version.
