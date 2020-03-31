# IBM APP CONNECT ENTERPRISE 

![IBM App Connect Logo](https://raw.githubusercontent.com/ot4i/ace-docker/master/app_connect_light_256x256.png)

## Introduction

IBM® App Connect Enterprise is a market-leading lightweight, enterprise integration engine that offers a fast, simple way for systems and applications to communicate with each other. As a result, it can help you achieve business value, reduce IT complexity, and save money. IBM App Connect Enterprise supports a range of integration choices, skills, and interfaces to optimize the value of existing technology investments.

The IBM® App Connect Designer dashboard allows you to create flows which can be tested locally and then exported and run within the IBM® App Connect (Cloud) service and also on your own IBM® App Connect Enterprise integration server with designer flows enabled.


## Chart Details

This chart deploys an instance of IBM® App Connect Designer authoring tool, this allows you to create flows that you can then test locally by using the running App Connect Enterprise integration server and, if you choose to enable it, your IBM® App Connect (Cloud) service.

When a flow is started, the flow is run locally. If you have chosen to enable only local connectors, all connections to connector endpoints are performed by the App Connect Enterprise integration server. If you have chosen to enable cloud-managed and local connectors, the connections to connector endpoints can also be performed in the IBM App Connect on IBM Cloud instance that you associate with your authoring tool.

## Prerequisites

* Red Hat OpenShift 4.2
* IBM Cloud Pak Foundation 3.2.3
* A user with administrator role is required to install the chart
* CouchDB requires a persistent volume with ReadWriteOnce access mode (persistence can be disabled using values). If using IBM Cloud please use storage class ibmc-block-gold.

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart requires a SecurityContextConstraints to be bound to the target namespace prior to installation. To meet this requirement, there may be cluster-scoped as well as namespace-scoped pre- and post- actions that need to occur.

The predefined SecurityContextConstraints name: [`ibm-anyuid-scc`](https://ibm.biz/cpkspec-scc) has been verified for this chart, if your target namespace is bound to this SecurityContextConstraints resource, you can proceed to install the chart.

`oc adm policy add-scc-to-group ibm-anyuid-scc system:serviceaccounts:<namespace>` For example, for release into the `default` namespace:

```code
oc adm policy add-scc-to-group ibm-anyuid-scc system:serviceaccounts:default
```

* Custom SecurityContextConstraints definition:

```yaml
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: ibm-ace-scc
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


## Installing the Chart

**Important:** If you are using a private Docker registry, an image pull secret needs to be created before installing the chart. Supply the name of the secret as the value for `image.pullSecret`.

Before installing the chart, you must create a secret which includes the IBM Cloud API key to access your App Connect instance in the IBM Cloud. The secret can be created using a command such as the following;

```bash
kubectl create secret generic <secretName> --from-literal=apikey=<YourIBMCloudAPIKey>
```

To install the chart with the release name `dashboard`:

```
helm install --name dashboard ibm-app-connect-designer --tls --set global.appConnectSecret=<secretName> --set global.appConnectInstanceID=<AppConnectInstanceID> --set global.appConnectURL=<AppConnectURL>
```

## Verifying the Chart

Run the following command to view the status of your deployment and instructions on how to access the App Connect Designer UI:
```
helm status dashboard --tls.
```

## Uninstalling the Chart

To uninstall/ delete the `dashboard` release:

```
helm delete dashboard --purge --tls
```

The command removes all the Kubernetes components associated with the chart.

## Configuration
The following table lists the configurable parameters of the `ibm-app-connect-designer` chart and their default values.

| Parameter                                 | Description                                     | Default                                                    |
| ----------------------------------------- | ----------------------------------------------- | ---------------------------------------------------------- |
| `image.fireflyFlowdocAuthoring`           | Image for flow document authoring.               | `cp.icr.io/ibm-app-connect-flowdoc-authoring-prod:11.0.0.8-r1`          |
| `image.fireflyFlowTestManager`            | Image for flow test manager.                     | `cp.icr.io/ibm-app-connect-flow-test-manager-prod:11.0.0.8-r1`          |
| `image.fireflyRuntime`                    | Image for runtime.                               | `cp.icr.io/ibm-app-connect-runtime-prod:11.0.0.8-r1`                    |
| `image.fireflyUi`                         | Image for Dashboard UI.                          | `cp.icr.io/ibm-app-connect-ui-prod:11.0.0.8-r1`                         |
| `image.connectorAuthService`              | Image for connector auth service.                | `cp.icr.io/ibm-app-connect-connector-auth-service-prod:11.0.0.8-r1`     |
| `image.proxy`                             | Image for proxy.                                 | `cp.icr.io/ibm-app-connect-proxy-prod:11.0.0.8-r1`                      |
| `image.configurator`                      | Image for configurator.                          | `cp.icr.io/ibm-acecc-configurator-prod:11.0.0.8-r1`                   |
| `image.pullPolicy`                        | Image pull policy.                               | `IfNotPresent`                                           |
| `image.pullSecret`                        | Image pull secret, if you are using a private Docker registry. | `nil`                                      |
| `arch`                                    | Architecture scheduling preference for worker node (only amd64 supported) - readonly. | `amd64`             |
| `ssoEnabled`                              | Whether to signon with external security manager eg IBM Identity and Access Management (IAM) | `true`       |
| `fireflyFlowdocAuthoring.resources.limits.cpu`      | Kubernetes CPU limit for the flow document authoring container. | `1`                                      |
| `fireflyFlowdocAuthoring.resources.limits.memory`   | Kubernetes memory limit for the flow document authoring container. | `1024Mi`                              |
| `fireflyFlowdocAuthoring.resources.requests.cpu`    | Kubernetes CPU request for the flow document authoring container. | `100m`                                 |
| `fireflyFlowdocAuthoring.resources.requests.memory` | Kubernetes memory request for the flow document authoring container. | `256Mi`                             |
| `fireflyFlowTestManager.resources.limits.cpu`      | Kubernetes CPU limit for the flow test manager container. | `1`                                      |
| `fireflyFlowTestManager.resources.limits.memory`   | Kubernetes memory limit for the flow test manager container. | `1024Mi`                              |
| `fireflyFlowTestManager.resources.requests.cpu`    | Kubernetes CPU request for the flow test manager container. | `100m`                                 |
| `fireflyFlowTestManager.resources.requests.memory` | Kubernetes memory request for the flow test manager container. | `256Mi`                             |
| `fireflyRuntime.resources.limits.cpu`          | Kubernetes CPU limit for the runtime container. | `1`                                                  |
| `fireflyRuntime.resources.limits.memory`       | Kubernetes memory limit for the runtime container. | `1024Mi`                                          |
| `fireflyRuntime.resources.requests.cpu`        | Kubernetes CPU request for the runtime container. | `100m`                                             |
| `fireflyRuntime.resources.requests.memory`     | Kubernetes memory request for the runtime container. | `256Mi`                                         |
| `fireflyUi.resources.limits.cpu`          | Kubernetes CPU limit for the UI container. | `1`                                                  |
| `fireflyUi.resources.limits.memory`       | Kubernetes memory limit for the UI container. | `1024Mi`                                          |
| `fireflyUi.resources.requests.cpu`        | Kubernetes CPU request for the UI container. | `100m`                                             |
| `fireflyUi.resources.requests.memory`     | Kubernetes memory request for the UI container | `256Mi`                                          |
| `connectorAuthService.resources.limits.cpu`          | Kubernetes CPU limit for the connector auth service container. | `1`                                         |
| `connectorAuthService.resources.limits.memory`       | Kubernetes memory limit for the connector auth service container. | `1024Mi`                                 |
| `connectorAuthService.resources.requests.cpu`        | Kubernetes CPU request for the connector auth service container. | `100m`                                    |
| `connectorAuthService.resources.requests.memory`     | Kubernetes memory request for the connector auth service container | `256Mi`                                 |
| `proxy.resources.limits.cpu`          | Kubernetes CPU limit for the proxy container. | `1`                                                  |
| `proxy.resources.limits.memory`       | Kubernetes memory limit for the proxy container. | `1024Mi`                                          |
| `proxy.resources.requests.cpu`        | Kubernetes CPU request for the proxy container. | `100m`                                             |
| `proxy.resources.requests.memory`     | Kubernetes memory request for the proxy container. | `256Mi`                                         |
| `configurator.resources.limits.cpu`          | Kubernetes CPU limit for the configurator container. | `1`                                                  |
| `configurator.resources.limits.memory`       | Kubernetes memory limit for the configurator container. | `1024Mi`                                          |
| `configurator.resources.requests.cpu`        | Kubernetes CPU request for the configurator container. | `100m`                                             |
| `configurator.resources.requests.memory`     | Kubernetes memory request for the configurator container. | `256Mi`                                         |
| `log.format`                              | Output log format on container's console. Either `json` or `basic`. | `json`                                |
| `global.replicaCount`                            | Set how many replicas of the each microservice to run | `3`  
| `couchdb.persistentVolume.enabled`        | Use a persistent volume with CouchDB to provide extra resiliance. | `true`                                |
| `couchdb.persistentVolume.size`           | Size of persistence volume for CouchDB. | `10Gi` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.

## Resources Required

This chart has the following resource requirements per pod by default:

- 200m CPU core
- 512 Mi memory

See the [configuration](#configuration) section above for how to configure these values.

## Logging

The `log.format` value controls whether the format of the output logs is:
- basic: Human-readable format intended for use in development, such as when viewing through `kubectl logs`
- json: Provide JSON-formatted messages

## Limitations

This chart can run only on amd64 architecture type.

The dashboard is not supported on Safari 12 running on macOS 10.14 (Mojave) or iOS 12.

## Documentation

[Using Designer ](https://ibm.biz/acdeploydesignerflow-ace)
