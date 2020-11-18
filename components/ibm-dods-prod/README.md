# ibm-dods-prod

IBM Decision Optimization for Data Science (DODS) is an add-on to Cloud Pack for Data that provides
advanced decision capabilities.

## Introduction

This chart is an add-on to Cloud Pack for Data that provides advanced decision capabilities.

## Chart Details

This chart contains following components:
- dd-init: initialization job on install/uninstall. This setup libraries in user-home PV.
- dd-scenario-api: backend APIs for the decision optimization features
- dd-scenario-ui: user interface of the decision optimization features
- dd-cognitive: backend APIs for the modeling assistant

## Prerequisites

This add-on pre-reqs Cloud Pack for Data, and the Watson Studio and WML add-ons. 

For information on prerequisites see [Planning installation] (https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_3.0.1/cpd/plan/planning.html)

## PodSecurityPolicy Requirements

Custom PodSecurityPolicy definition: 
```
none
```

## SecurityContextConstraints Requirements
This chart requires the same SecurityContentConstraints that are set up when Cloud Pak for Data is installed. 

The predefined SecurityContextConstraints name: `cpd-user-scc` provided by CP4D has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart. This shall be the case as CP4D installation is a prerequisite.

This predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has also been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

You can also define a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. For example, from the user interface you can copy and paste the following snippets to setup the custom SecurityContextConstraints
Custom SecurityContextConstraints definition: 
```
apiVersion: security.openshift.io/v1
metadata:
  annotations: {}
  name: ibm-dods-prod-scc
kind: SecurityContextConstraints
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
  type: RunAsAny
groups: []
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities:
- KILL
- MKNOD
- SETUID
- SETGID
runAsUser:
  type: MustRunAsRange
  uidRangeMin: 1000320900
  uidRangeMax: 1000361000
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## Resources Required

For information on resources required see [System requirements for services] (https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_3.0.1/sys-reqs/services_prereqs.html)

## Installing the Chart

The recommended way to install this product is using the cpd install utility shipped with Cloudpak for Data.

For information on installation see [Decision Optimization installation](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_3.0.1/do/cpd_svc/do-install.html)

### Uninstalling the Chart

For information on uninstallation see [Decision Optimization uninstall](https://www.ibm.com/support/knowledgecenter/en/SSQNUZ_3.0.1/do/cpd_svc/do-uninstall.html)

## Configuration

The following tables lists the configurable parameters of the chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `userHomePVC.persistence.existingClaimName` | Existing PVC Name for User Home | `user-home-pvc` |
| `architecture` | Architecture scheduling preferences | `amd64` |
| `serviceAccount` | Service account to run the services | `cpd-viewer-sa` |
| `dockerRegistryPrefix` | Docker registry prefix where our image are stored | `docker-registry.default.svc:5000/zen` |
| `image.pullPolicy` | Default pull policy for images | `IfNotPresent` |
| `ddScenarioApi.replicas` | Number of replicas for the backend APIs service | `1` |
| `ddScenarioApi.resources.limits.cpu` | Maximum cpu for the backend APIs service | `1000m` |
| `ddScenarioApi.resources.limits.cpu` | Maximum memory for the backend APIs service | `1024Mi` |
| `ddScenarioApi.resources.requests.cpu` | Initial cpu request for the backend APIs service | `200m` |
| `ddScenarioApi.resources.requests.cpu` | Initial cpu request for the backend APIs service | `512Mi` |
| `ddScenarioUi.replicas` | Number of replicas for the user interface service | `1` |
| `ddScenarioUi.resources.limits.cpu` | Maximum cpu for the user interface service | `500m` |
| `ddScenarioUi.resources.limits.cpu` | Maximum memory for the user interface service | `1024Mi` |
| `ddScenarioUi.resources.requests.cpu` | Initial cpu request for the user interface service | `200m` |
| `ddScenarioUi.resources.requests.cpu` | Initial cpu request for the user interface service | `512Mi` |
| `ddCognitive.replicas` | Number of replicas for the modeling assistant service | `1` |
| `ddCognitive.resources.limits.cpu` | Maximum cpu for the modeling assistant service | `1000m` |
| `ddCognitive.resources.limits.cpu` | Maximum memory for the modeling assistant service | `2048Mi` |
| `ddCognitive.resources.requests.cpu` | Initial cpu request for the modeling assistant service | `500m` |
| `ddCognitive.resources.requests.cpu` | Initial cpu request for the modeling assistant service | `512Mi` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. 

In most cases, the default values are correct and shall not be changed.

## Storage

The chart stores some info in the pre-existing user-home PV created by CP4D. It does not create or require any other storage.

## Limitations

This chart is not self sufficient. It has dependency on other charts. 

