
# IBM Open Source Management Chart

## Introduction
Open source enables businesses to modernize their offerings quickly and with lower costs. But if your enterprise relies on open source software packages, you know how difficult it can be to ensure that users are working with approved packages.

With the Open Source Management service, you can manage access to open source software packages at the scale of your enterprise, so that you can optimize the benefits of open source while minimizing potential risks.

## Chart Details
IBM Open Source Management chart provides an interface to create, retrieve, update, or validate open source packages. This charts creates services and pods related to OSG service.

## Prerequisites
- Kubernetes 1.11.0 or later / Openshift 3.11, with beta APIs enabled.
- Shared Storage (GlusteFS or NFS)
- 3 Worker Nodes (Minimum 8 Cores/32 GB)


### PodSecurityPolicy Requirements
- Cluster administrator role is required for installation.

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined SecurityContextConstraints [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart. If your target namespace is not bound to this SecurityContextConstraints resource you can bind it with the following command:

`oc adm policy add-scc-to-group ibm-anyuid-scc system:serviceaccounts:<namespace>` For example, for release into the `default` namespace:
``` 
$ oc adm policy add-scc-to-group ibm-anyuid-scc system:serviceaccounts:default
```

* Custom SecurityContextConstraints definition:

```
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-osg-scc
spec:
  allowPrivilegeEscalation: true
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
  - MKNOD
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
  runAsUser:
    rule: RunAsAny
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - persistentVolumeClaim
  forbiddenSysctls:
  - '*'
```


## Resources Required

This chart has the following resource requirements per pod by default:

- 250m CPU core
- 2Gi memory

## Installing the Chart

To install the chart with the release name `ibm-osg-prod`:

```
$ helm install ibm-osg-prod-1.0.0.tgz --name=osg --tls
```

The command deploys ibm-osg-prod on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.


### Verifying the Chart
See the instruction (from NOTES.txt within chart) after the helm installation completes for chart verification. The instruction can also be viewed by running the command: 
```
$ helm status my-release --tls.
```

### Uninstalling the Chart

To uninstall/delete the `ibm-osg-prod` deployment:

```bash
$ helm delete ibm-osg-prod --purge --tls
```

The command removes all the Kubernetes components associated with the chart and deletes the release.  

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  
Do the following after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=ibm-osg-prod
```

## Configuration

The following tables lists the configurable parameters of the `ibm-osg-prod`  chart and their default values.

| Parameter                  | Description                                     | Default                                                    |
| -----------------------    | ---------------------------------------------   | ---------------------------------------------------------- |
| `replicaCount`             | Number of deployment replicas                   | `1`                                                        |
| `image.pullPolicy`         | Image pull policy                               | `Always` if `tag` is `latest`, else `IfNotPresent`    |
| `image.tag`                | `OSG` image tag                         | `stable`                                                   |
| `architecture`                                    | Architecture scheduling preference for worker node (only amd64 supported) - readonly. | `amd64`               |
| `resources.requests.memory`| Memory resource requests                        | `2Gi`                                                    |
| `resources.requests.cpu`   | CPU resource requests                           | `250m`                                                     |
| `resources.limits.memory`  | Memory resource limits                          | `2Gi`                                                    |
| `resources.limits.cpu`     | CPU resource limits                             | `1`                                                     |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,


## Storage
The IBM Open Source Management requires a persistent volume to store runtime artefacts used by an IBM Open Source Management API and DB services. The default size of the persistent volume claim is 10Gi. Configure the size with the `persistence.size` option to scale with the number and size of runtime artefacts that are expected to be uploaded to IBM Open Source Management.

The persistent volume claim must have an access mode of ReadWriteMany (RWX), and must not use "hostPath" or "local" volumes.

For volumes that support ownership management, specify the group ID of the group owning the persistent volumes' file systems using the `security.fsGroupGid` parameter.

## Limitations
Installation of this chart using the default RBAC and Service Account values requires a cluster admin role.

## Documentation
Further guidance can be found in the [Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/svc/opensource/opensource-get-started.html).


