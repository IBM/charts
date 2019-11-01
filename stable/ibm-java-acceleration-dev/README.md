# Java Acceleration Helm Chart



## Introduction 
IBM Java Acceleration is a set of JVM enhancements and technologies offered as a service to provide 
 * increased performance under constrained resources
 * cloud optimization
 * enhance resource consumption, scaling
 
Java Acceleration integrates with Liberty and allows for better resource management on OpenShift or any other Kubernetes deployment.

# Resources Required

## System
```yaml
requests:
  memory: 512Mi
  cpu: 1
```

## Storage
```yaml
capacity:
  storage: 1Gi
```

# Chart Details
* Install one `deployment` named `ibm-java-acceleration-server`
* Install one `service` named `ibm-java-acceleration-server`
* Install one `replicaset` named `ibm-java-acceleration-server`
* Install one `pod` named `ibm-java-acceleration-server`

# Prerequisites

## Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. 

* Predefined SecurityContextConstraints name: [`ibm-restricted-scc`](https://ibm.biz/cpkspec-scc)

* Custom SecurityContextConstraints definition:

```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
  name: ibm-java-acceleration-scc
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowPrivilegeEscalation: false
allowedCapabilities: null
allowedFlexVolumes: null
allowedUnsafeSysctls: null
defaultAddCapabilities: null
defaultAllowPrivilegeEscalation: false
fsGroup:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seccompProfiles:
- docker/default
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: MustRunAs
  ranges:
  - max: 65535
    min: 1
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
```

## PodSecurityPolicy Requirements 
This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. 

* Predefined PodSecurityPolicy name: [`ibm-restricted-psp`](https://ibm.biz/cpkspec-psp)

* Custom PodSecurityPolicy definition:

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy is the most restrictive, 
      requiring pods to run with a non-root UID, and preventing pods from accessing the host." 
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
    cloudpak.ibm.com/version: "1.1.0"
  name: ibm-java-acceleration-psp
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
  runAsGroup:
    rule: MustRunAs
    ranges:
    - min: 1
      max: 65535
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

* Custom ClusterRole for the custom PodSecurityPolicy:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ibm-java-acceleration-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - ibm-java-acceleration-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

# Installing the Chart
```
helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
helm install --name my-release ibm-charts/ibm-java-acceleration-dev
```

# Verifying the Chart
```
helm test my-release
helm status my-release
```

# Uninstalling the Chart
```
helm delete --purge my-release
```

### Configuration 

| Qualifier      | Parameter                               | Definition                                                                  | Allowed Value                                             |
|----------------|-----------------------------------------|-----------------------------------------------------------------------------|-----------------------------------------------------------|
|name            |                                         |Name of service, deployment, replicaset, should be unique inside cluster     |                                                           |
|arch            |                                         |CPU architecture preference                                                  |`amd64`, `power`, or `z`                                   |
|image           |repository                               |Name of image, including repository prefix (if required)                     |                                                           |
|                |tag                                      |Docker image tag                                                             |                                                           |
|                |pullPolicy                               |Image Pull Policy                                                            |`Always`, `Never`, or `IfNotPresent`. Defaults to Always   |
|container       |limits.memory                            |Maximum memory allocated for container                                       |Defaults to `8 Gi`                                         |
|                |limits.cpu                               |Maximum CPU allocated for container                                          |Defaults to `8`                                            |
|                |requests.memory                          |Minimum memory allocated for container                                       |Defaults to `512 Mi`                                       |
|                |requests.cpu                             |Minimum CPU allocated for container                                          |Defaults to `2`                                            |
|service         |port                                     |Port number that java acceleration listens to                                |Defaults to `38400`                                        |
|replicaCount    |                                         |Number of replica to be deployed                                             |                                                           |

## Documentation
* See openj9 repo: https://github.com/eclipse/openj9/tree/jitaas
* See openj9 docs: https://github.com/eclipse/openj9-docs
* See openj9 website: https://www.eclipse.org/openj9/index.html 

## Limitations
* Deploys on x86 architecture only, it is intended to support other architectures in future releases.
* Supports Java 8 only, it is intended to support other Java versions in future releases.