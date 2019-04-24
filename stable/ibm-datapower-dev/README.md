# IBM DataPower Gateway

![IDG Logo](https://avatars1.githubusercontent.com/u/8836442?v=4&s=200)

[IBM® DataPower Gateway](http://www-03.ibm.com/software/products/en/datapower-gateway) is a purpose-built security and integration gateway that addresses the business needs for mobile, API, web, SOA, B2B, and cloud workloads. It is designed to provide a consistent configuration-based approach to security, governance, integration and routing.

[//]: # (Chart Name Start)
## Chart Name
IBM DataPower Gateway Virtual Edition for Developers

[//]: # (Chart Name End)

## Introduction
This chart deploys a single IBM DataPower Gateway node with a default pattern into a Kubernetes environment. The default pattern,  the `restProxy` pattern, configures the DataPower node to act as a reverse proxy, directing client requests to the appropriate backend server.

## Chart Details
Deploys IBM DataPower Gateway Virtual Edition for Developers.
Only works with DataPower version 2018.4.1.3 and above.

## Prerequisites
helm and kubectl must be installed and configured on your system.

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. Choose either a predefined PodSecurityPolicy or have your cluster administrator create a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)

The predefined PodSecurityPolicy name: ibm-anyuid-psp has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

This chart also defines a custom PodSecurityPolicy which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable this custom PodSecurityPolicy using the ICP user interface or the supplied instructions/scripts in the pak_extension pre-install directory.

- From the user interface, you can copy and paste the following snippets to enable the custom PodSecurityPolicy

  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      annotations:
        kubernetes.io/description: "This policy allows pods to run with 
          any UID and GID, but preventing access to the host."
      name: ibm-datapower-psp
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
      - downwardAPI
      - persistentVolumeClaim
      forbiddenSysctls: 
      - '*' 
    ```

[//]: # (Resources Required Start)
## Resources Required
Minimum resources per pod: 2 CPU and 4 GB RAM

[//]: # (Resources Required End)

## Installing the Chart
To install the chart with the release name `my-release` and default pattern (See .Values.patternName below):
 ```bash
$ helm install --name my-release -f <myvalues.yaml> stable/ibm-datapower-dev --tls
```

Where `<myvalues.yaml>` is a yaml file that contains all values you want to override.

To deploy with HTTPS you must define `crypto.frontsideSecret`, which is the name of the Kubernetes secret containing data key.pem and cert.pem. These files are in the standard key and cert format. Create this secret prior to deploying. Create secret using `kubectl create secret generic <mycryptosecret> --from-file=key.pem --from-file=cert.pem`. Without `crypto.frontsideSecret` defined, the gateway will use HTTP.

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart
To uninstall/delete the `my-release` deployment:
```bash
$ helm delete my-release --tls
```  

To completely uninstall/delete the `my-release` deployment:
```bash
$ helm delete --purge my-release --tls
```

## Configuration
The helm chart has the following Values that can be overriden using the install `--set` parameter or by providing your own values file. For example:

`helm install --set image.repository=<myimage> stable/ibm-datapower-dev --tls`

| Value                                 | Description                                   | Default             |
|---------------------------------------|-----------------------------------------------|---------------------|
| `datapower.replicaCount`              | The replicaCount for the deployment           | 1                   |
| `datapower.image.repository`          | The image to use for this deployment          | ibmcom/datapower    |
| `datapower.image.tag`                 | The image tag to use for this deployment      | latest              |
| `datapower.image.pullPolicy`          | Determines when the image should be pulled    | IfNotPresent        |
| `datapower.image.pullSecret`          | Secret used for pulling images                | N/A                 |
| `datapower.env.workerThreads`         | Number of DataPower worker threads            | 4                   |
| `datapower.resources.limits.cpu`      | Container CPU limit                           | 8                   |
| `datapower.resources.limits.memory`   | Container memory limit                        | 64Gi                |
| `datapower.resources.requests.cpu`    | Container CPU requested                       | 4                   |
| `datapower.resources.requests.memory` | Container Memory requested                    | 8Gi                 |
| `datapower.webGuiManagementState`     | WebGUI Management admin state                 | disabled            |
| `datapower.webGuiManagementPort`      | WebGUI Management port                        | 9090                |
| `datapower.gatewaySshState`           | SSH admin state                               | disabled            |
| `datapower.gatewaySshPort`            | SSH Port                                      | 9022                |
| `datapower.restManagementState`       | REST Management admin state                   | disabled            |
| `datapower.restManagementPort`        | REST Management port                          | 5554                |
| `datapower.xmlManagementState`        | XML Management admin state                    | disabled            |
| `datapower.xmlManagementPort`         | XML Management port                           | 5550                |
| `datapower.snmpState`                 | SNMP admin state                              | enabled             |
| `datapower.snmpPort`                  | SNMP interface port                           | 1161                |
| `datapower.flexpointBundle`           | ILMT Flexpoint Bundle type                    | N/A                 |
| `service.name`                        | Name to add to service                        | datapower           |
| `patternName`                         | The name of the datapower pattern to load     | restProxy           |
| `restProxy.backendURL`                | The backend URL datapower will proxy          | https://www.ibm.com |
| `restProxy.containerPort`             | The backend URL datapower will proxy          | 8443                |
| `crypto.frontsideSecret`              | Secret containing key and cert data           | N/A                 |


Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/ibm-datapower-dev --tls
```

The `patternName` specifies the configuration included with the deployment. Pattern-specific options are prefixed by the `patternName` in values.yaml.
The available patterns are:

- `restProxy` : Configures the DataPower Gateway as a proxy for RESTful services, the service is available over HTTP or HTTPS(if crypto parameters are set) at `restProxy.containerPort` and proxies to `restProxy.backendURL`.
- `none` : Does not include any configuration. You may only interact with the gateway using `kubectl attach`.
> **Tip**: List all releases using `helm list --tls`

[//]: # (Limitations Start)
## Limitations
- This chart is for developer purposes only. No support is provided. Not eligible for production use.
- No limit on number of deployments.
- No limit on number of deployments per namespace.
- Limited to amd64 architectures.

[//]: # (Limitations End)

## Documentation
See NOTES.txt associated with this chart for verification instructions


> **Tip**: You can use the default [values.yaml](values.yaml)

[View the official IBM DataPower Gateway for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/datapower/)

[View the IBM DataPower Gateway Product Page](https://www.ibm.com/products/datapower-gateway/resources)

[View the IBM DataPower Gateway Documentation](https://www.ibm.com/support/knowledgecenter/SS9H2Y)


_Copyright©  IBM Corporation 2017. All Rights Reserved._

_The IBM DataPower Gateway logo is copyright IBM and is provided for use for the purposes of IBM Cloud Private. You will not use the IBM DataPower Gateway logo in any way that would diminish the IBM or IBM DataPower Gateway image. IBM reserves the right to end your privilege to use the logo at any time in the future at our sole discretion. Any use of the IBM DataPower Gateway logo affirms that you agree to adhere to these conditions._
