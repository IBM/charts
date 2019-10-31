# IBM Cloud Pak for Integration Operations Dashboard Add On

## Introduction
This chart deploys IBM Cloud Pak for Integration (ICP4I) Operations Dashboard.
The Operations Dashboard will enable IBM Integration products to provide tracing information displayed on a central console.
The Operations Dashboard console will be available through the ICP4I Navigator.

## Chart Details
This Helm chart will:

* Create an Operations Dashboard instance which includes several components using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/).
* Create a Big Data, ElasticSearch based store using a [StatefulSet](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/).

## Prerequisites
* Kubernetes 1.11 or greater, with beta APIs enabled.
* Cloud Pak Foundation fix pack 3.2.0.1907.
* A user with Operator role is required to install the chart.

### Red Hat OpenShift SecurityContextConstraints Requirements
This chart requires a SecurityContextConstraint to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.	

The predefined SecurityContextConstraint name: [`anyuid`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource you can proceed to install the chart.

This chart also defines a custom SecurityContextConstraints which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom SecurityContextConstraints resource using the supplied instructions/scripts in the pak_extension pre-install directory.

From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy
        Custom PodSecurityPolicy definition:    

        apiVersion: security.openshift.io/v1
        kind: SecurityContextConstraints
        metadata:
          name: ibm-icp4i-od-anyuid-scc
          annotations:
            kubernetes.io/description: "This policy allows pods to run with any UID and GID, but preventing access to the host."
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
          - downwardAPI
          - persistentVolumeClaim
        forbiddenSysctls: []

## Resources Required
This chart has the following resource requirements by default:

| Storage | CPU | Memory |
| --- | --- | --- |
| `17 Gi` persistent volume (minimum) | minimum of `2.0` up to `8.0` | minimum of `12 Gi` up to `18 Gi` |

## Installing the Chart

**Only one Operations Dashboard can be installed per namespace.**

Install the chart, specifying the release name (for example `my-release`) and Helm repository name (for example `local-charts`) with the following command:


```bash
helm install --name my-release local-charts/ibm-icp4i-tracing-prod --set ingress.odUiHost="icp4i-od" --tls
```

The command deploys `ibm-icp4i-tracing-prod` on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

### Verifying the Chart

See the instructions after the helm installation completes for chart verification. The instructions can also be viewed by running the command: `helm status my-release --tls`.

### Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release --purge --tls
```

The command removes all the Kubernetes components associated with the chart, except any Persistent Volume Claims (PVCs).  This is the default behavior of Kubernetes, and ensures that valuable data is not deleted.

## Configuration

The following table lists the configurable parameters of the `ibm-icp4i-tracing-prod` chart and their default values.

| Parameter                       | Description                                                     | Default                                    |
| ------------------------------- | --------------------------------------------------------------- | ------------------------------------------ |
| `images.registry`               | Registry containing `IBM ICP4I Operations Dashboard` images     | `nil`                                      |
| `image.pullSecret`              | Image pull secret, if you are using a private Docker registry   | `nil`                                      |
| `image.pullPolicy`              | Image pull policy                                               | `IfNotPresent`                             |
| `ingress.odUiHost`              | Hostname of the ingress proxy to be configured                  | `nil`                                      |
| `ingress.odURI`                 | Path used by the ingress for the service. support only one level| `op`                                       |
| `platformNavigatorHost`         | Hostname of the icp4i Platform Navigator                        | `nil`                                      |
| `configdb.storageClassName`     | Storage class for the config DB persistent volumes              | `nil`                                      |
| `configdb.storage`              | Size of volume for the config DB                                | `2Gi`                                      |
| `elasticsearch.volumeClaimTemplate.storageClassName`     | Storage class for the elasticsearch persistent volumes              | `nil`                                      |
| `elasticsearch.volumeClaimTemplate.resources.requests.storage`     | Size of volume for the elasticsearch              | `10Gi`                                      |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

> **Tip**: You can use the default [values.yaml](values.yaml)

## Storage
The chart mounts a two [Persistent Volumes](http://kubernetes.io/docs/user-guide/persistent-volumes/) for the storage of the internal configuration database and for the Big Data Store. Read product's documentation for further storage information and limitations .

## Limitations
* Chart can only run on amd64 architecture type.

## Documentation
 [`IBM Cloud Pak for Integration Knowledge Center`](https://www.ibm.com/support/knowledgecenter/SSGT7J_19.3/op_dashboard.html)

_Copyright IBM Corporation 2019. All Rights Reserved._

