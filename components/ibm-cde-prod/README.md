# IBM-Cognos-Dashboard-Embedded
*****


## Introduction
##### What is it?
IBM Cognos Dashboard Embedded (CDE) is an API-based solution that lets developers easily add end-to-end data visualization capabilities to their applications so users can create visualizations that feel like part of the app.

##### What can it do?
IBM Cognos Dashboard Embedded offers developers the ability to define the user workflow and control the options available to users – from a guided exploration of the analysis through authored fixed dashboards to a free-form analytic exploration environment in which end-users choose their own visualizations – and virtually anything in between.

More information about how to use IBM Cognos Dashboard Embedded can be found [here](https://docs-icpdata.mybluemix.net/docs/content/SSQNUZ_current/com.ibm.icpdata.doc/dashboard/c_parent_topic.html)


## Chart Details
This chart contains two deployments. The CDE deployment and an internal Redis deployment.
The CDE deployment is componsed of two containers: the proxy container and the server cotnainer.

The following endpoints are included:
* The health check endpoint for the proxy container ```/healthcheck/liveness```
* The health check endpoint for the server container ```/daas/v1/health```
* The root endpoint for CDE ```/daas```
* The session endpoint ```/daas/v1/session```

## Prerequisites
* CP4D Version: >= 2.1.0.2
* Kubernetes Version: >=1.11.0
* Helm Version: >=2.9.1

## Resources Required
* Total CPUs: 2.878m
* Total Memory: 6.381 Gi
* Total Storage: 30 Gi

### PodSecurityPolicy Requirements
This chart does not use any custom PSP

### Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

This chart uses a custom SCC provided by CP4D and is installed as part of the CP4D install. A sample of the custom SCC from CP4D has been provided below for reference.

Custom SecurityContextConstraints definition:
```yaml
apiVersion: security.openshift.io/v1
metadata:
  annotations: {}
  name: cpd-user-scc
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
  type: MustRunAs
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

### Configure proxy with TLS certificates (Optional)
By default, the proxy uses its own self-signed certificates. The following steps allows proxy to be configured with other certificates

1. Create a file name `cognos-secret.yaml` with the folling secret object definition
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cognos-tls-secret
type: Opaque
data:
  DAAS_INTERNAL_TLS_CERT: ""
  DAAS_INTERNAL_TLS_KEY: ""
```
2. Encode the tls cert and tls key using in base64
3. Set `DAAS_INTERNAL_TLS_CERT` with the base64 tls cert and `DAAS_INTERNAL_TLS_KEY` with the base64 tls key
4. Add the Secret
```yaml
kubectl create -f cognos-secret.yaml
```
5. Override the `image.proxy.tlsCert` configuration parameter when installing

### Installing the Chart
This chart is installed as part of the CP4D install

#### Installing the Chart on an AirGap System
To install the chart on an AirGap system, override the `image.server.airgap` configuration parameter and set to `true` when installing

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge
```

The command removes all the Kubernetes components associated with the
chart and deletes the release. If a delete can result in orphaned
components include instructions with additional commands required for
clean-up.

## Configuration
The following tables lists the configurable parameters of the `cde` chart and their default values.


| Parameter                                              | Description                                                                                               | Default                            |
|:-------------------------------------------------------|:----------------------------------------------------------------------------------------------------------|:-----------------------------------|
| `global.ibmProduct`                                    | The `ibmProduct` in scope when generating charts, used to add features (feature: zen)                     | `""`                               |
| `global.dockerRegistryPrefix`                          | The docker registry prefix                                                                                | `""`                               |
| `global.storageClassName`                              | The storage class name                                                                                    | `""`                               |
| `global.persistence.useDynamicProvisioning`            | The flag for dynamic provisioning of persistent                                                           | `false`                            |
| `arch`                                                 | Architecture scheduling preference                                                                        | `amd64`                            |
| `loggingLevel`                                         | Override logging level                                                                                    | `info`                             |
| `serviceAccount.name`                                  | Service Account Name                                                                                      | `cpd-viewer-sa`                    |
| `image.pullPolicy`                                     | When to pull the image                                                                                    | `IfNotPresent`                     |
| `image.pullSecret`                                     | The docker pull secret                                                                                    | `""`                               |
| `image.proxy.image`                                    | Proxy docker image                                                                                        | `cde-sb-proxy-cp4d`                |
| `image.proxy.tag`                                      | Proxy docker tag for amd64                                                                                | `11.1.2020092301`                  |
| `image.proxy.tagPPC`                                   | Proxy docker tag for ppc64le                                                                              | `11.1.2020092301`                  |
| `image.proxy.tlsSecret`                                | Secret name for tls                                                                                       | `""`                               |
| `image.server.image`                                   | Server docker image                                                                                       | `cde-backend-cp4d`                 |
| `image.server.tag`                                     | Server docker tag for amd64                                                                               | `11.1.2020100703`                  |
| `image.server.tagPPC`                                  | Server docker tag for ppc64le                                                                             | `11.1.2020100703`                  |
| `image.server.airgap`                                  | Is server running in an air gapped environment (true/false)                                               | `false`                            |
| `image.redisInit.image`                                | The `redis` image to use                                                                                  | `cde-redis-cp4d`                   |
| `image.redisInit.tag`                                  | The `redis` tag to use                                                                                    | `1.0.8`                            |
| `image.redisInit.port`                                 | The port number for redis service                                                                         | `6379`                             |
| `persistence.enabled`                                  | Enable use of persistent volumes                                                                          | `true`                             |
| `persistence.existingClaim`                            | Manually managed pvc to use                                                                               | `""`                               |
| `persistence.storageSize`                              | Storage size used to create pv                                                                            | `30Gi`                             |
| `cde.securityContext.fsGroup`                          | The fsGroup to run the containers with                                                                    | `""`                               |
| `runAsUser`                                            | User to run containers with                                                                               | `1000320999`                       |

## Limitations
* Cannot deploy more than once in the same namespace
* Cannot have more than one Redis pod
* Requires the Lite module from CP4D to be installed