[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # (\(C\) Copyright IBM Corporation 2016-2019 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)

# Cloud Automation Manager Helm Chart

IBM Cloud Automation Manager is a cloud management solution for deploying cloud infrastructure in multiple clouds with an optimized user experience.

## Introduction

IBM Cloud Automation Manager uses open source Terraform to manage and deliver cloud infrastructure as code. Cloud infrastructure delivered as code is reusable, able to be placed under version control, shared across distributed teams, and it can be used to easily replicate environments.

The IBM Cloud Automation Manager content library comes pre-populated with sample templates to help you get started quickly. Use the sample templates as is or customize them as needed.  A Chef runtime environment can also be deployed using IBM Cloud Automation Manager for more advanced application configuration and deployment.

With IBM Cloud Automation Manager, you can provision cloud infrastructure and accelerate application delivery into IBM Cloud, Amazon EC2, VMware vSphere, VMware NSXv, VMware NSX-T, Google Cloud, Microsoft Azure, IBM PureApplication, OpenStack and Huawei cloud environments with a single user experience.

You can spend more time building applications and less time building environments when cloud infrastructure is delivered with automation. You are able to get started fast with pre-built infrastructure from the IBM Cloud Automation Manager library.

## Chart Details

This chart deploys IBM Cloud Automation Manager as a number of deployments, services and a security policy.  Images are based on the Universal Base Image (UBI) and are supported to run on Red Hat OpenShift Container Platform.  

## Prerequisites

IBM Cloud Automation Manager is supported to run in IBM Cloud Private or Red Hat OpenShift Container Platform. 

The following IBM Cloud Private platform services are required (inculding when running on Red Hat OpenShift Container Platform) - `auth-idp`, `catalog-ui`, `cert-manager`, `helm-api`, `helm-repo`, `icp-management-ingress`, `logging`, `metering`, `monitoring`, `nginx-ingress`, `platform-ui`, `service-catalog`, `tiller`

### PodSecurityPolicy Requirements

This chart defines a custom PodSecurityPolicy (on IBM Cloud Private) which is used to finely control the permissions/capabilities needed to deploy this chart.  It is based on the predefined PodSecurityPolicy name: [`ibm-anyuid-hostpath-psp`](https://ibm.biz/cpkspec-psp) with additional restrictions. 

During installation of the chart, the chart itself will install the following PodSecurityPolicy:

- Custom PodSecurityPolicy definition:
```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  labels:
    name: cam-services-ps-{{ .Release.Namespace }}
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
  name: cam-services-psp-{{ .Release.Namespace }}
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

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart defines a custom SecurityContextConstraints (on Red Hat OpenShift Container Platform) which is used to finely control the permissions/capabilities needed to deploy this chart.  It is based on the predefined SecurityContextConstraint name: [`ibm-anyuid-hostpath-scc`](https://ibm.biz/cpkspec-scc) with additional restrictions. 

During installation of the chart, the chart itself will install the following SecurityContextConstraint:

- Custom SecurityContextConstraints definition:
```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: "This policy is requiring pods to run with a non-root UID, and allow host path access."
  name: cam-services-scc-{{ .Release.Namespace }}
allowHostDirVolumePlugin: true
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: true
allowedCapabilities:
- SETPCAP
- AUDIT_WRITE
- CHOWN
- NET_RAW
- DAC_OVERRIDE
- FOWNER
- FSETID
- KILL
- SETUID
- SETGID
- NET_BIND_SERVICE
- SYS_CHROOT
- SETFCAP
allowedFlexVolumes: []
allowedUnsafeSysctls: []
defaultAddCapabilities: []
defaultPrivilegeEscalation: true
forbiddenSysctls:
  - "*"
fsGroup:
  type: MustRunAs
  ranges:
  - max: 1111
    min: 999
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
runAsUser:
  type: MustRunAsNonRoot
seccompProfiles:
- docker/default
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 1111
    min: 999
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
- nfs
groups:
- system:serviceaccounts:{{ .Release.Namespace }}
priority: 0
```
## Resources Required

* The minimum hardware requirements for IBM Cloud Automation Manager is a single worker node with at least 12 vCPU and 30GB of memory.
For a full list of hardware requirements see: https://www.ibm.com/support/knowledgecenter/SS2L37_3.2.1.0/cam_requirements.html

* Persistent Volumes are required to be pre-created. For details see: https://www.ibm.com/support/knowledgecenter/SS2L37_3.2.1.0/cam_create_pv.html

* This chart requires elevated privileges to run. For details see: https://www.ibm.com/support/knowledgecenter/SS2L37_3.2.1.0/cam_requirements.html

## Installing the Chart

This chart is normally deployed to the `services` namespace but can be deployed to multiple namespaces and supports various installation options. For complete details please see: https://www.ibm.com/support/knowledgecenter/SS2L37_3.2.1.0/cam_planning.html

## Configuration

For the full list of configuration options supported by this chart see: https://www.ibm.com/support/knowledgecenter/SS2L37_3.2.1.0/cam_installation_parameters.html

## Limitations

* IBM Cloud Automation Manager is only supported to run on an IBM Cloud Private or Red Hat OpenShift Container Platform

## Documentation

For version-wise installation instructions and detailed documentation of IBM Cloud Automation Manager (CAM), go to its Knowledge Center at https://www.ibm.com/support/knowledgecenter/SS2L37/product_welcome_cloud_automation_manager.html.

Select your version from the drop-down list and search for your topics from within the version.
