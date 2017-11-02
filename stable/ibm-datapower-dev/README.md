# IBM Datapower Gateway 

![IDG Logo](https://avatars1.githubusercontent.com/u/8836442?v=4&s=200)

[IBM® DataPower Gateway](http://www-03.ibm.com/software/products/en/datapower-gateway) is a purpose-built security and integration gateway that addresses the business needs for mobile, API, web, SOA, B2B, and cloud workloads. It is designed to provide a consistent configuration-based approach to security, governance, integration and routing.


## Introduction

This chart deploys a single IBM DataPower Gateway node with a default pattern into an IBM Cloud Private or other Kubernetes environment. The default pattern,  the `webApplicationProxy` pattern, configures the DataPower node to act as a reverse proxy, directing client requests to the appropriate backend server.

 ## Installing the Chart
 To install the chart with the release name `my-release` and default pattern (See .Values.patternName below):
 ```bash
$ helm install --name my-release -f <mycrypto.yaml> stable/ibm-datapower-dev
```

Where `<mycrypto.yaml>` is a yaml file that contains the required parameters `crypto.frontsideCert` and `crypto.frontsideKey` and their respective base64-encoded values.

> **Tip**: List all releases using `helm list`
## Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

 ## Uninstalling the Chart
To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```



## Configuration
The helm chart has the following Values that can be overriden using the install `--set` parameter or by providing your own values file. For example:

`helm install --set image.repository=<myimage> stable/datapower`

| Value                              | Description                                   | Default             |
|------------------------------------|-----------------------------------------------|---------------------|
| `replicaCount`                     | The replicaCount for the deployment           | 1                   |
| `image.repository`                 | The image to use for this deployment          | ibmcom/datapower    |
| `image.tag`                        | The image tag to use for this deployment      | latest              |
| `image.pullPolicy`                 | Determines when the image should be pulled    | IfNotPresent        |
| `service.name`                     | Name to add to service                        | datapower           |
| `env.acceptLicense`                | License Acceptance                            | true                |
| `env.workerThreads`                | Number of DataPower worker threads            | 4                   |
| `resources.limits.cpu`             | Container CPU limit                           | 8                   |
| `resources.limits.memory`          | Container memory limit                        | 64Gi                |
| `resources.requests.cpu`           | Container CPU requested                       | 4                   |
| `resources.requests.memory`        | Container Memory requested                    | 8Gi                 |
| `patternName`                      | The name of the datapower pattern to load     | webApplicationProxy |
| `webApplicationProxy.backendURL`   | The backend URL datapower will proxy          | https://www.ibm.com |
| `webApplicationProxy.containerPort`| The backend URL datapower will proxy          | 8443                |
| `crypto.frontsideCert`             | base64 encoded certificate (required)         | N/A (required)      | 
| `crypto.frontsideKey`              | base64 encoded key (required)                 | N/A (required)      | 


Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install --name my-release -f values.yaml stable/datapower
```

The `patternName` specifies the configuration included with the deployment. Pattern-specific options are prefixed by the `patternName` in values.yaml.
The available patterns are: 

`webApplicationProxy` : Configures the DataPower Gateway as a reverse proxy, the service is available over HTTPS at the `webApplicationProxy.containerPort` and proxies `webApplicationProxy.backendURL`.
`none` : Does not include any configuration. You may only interact with the gateway using `kubectl attach`.


> **Tip**: You can use the default [values.yaml](values.yaml)

[View the official IBM DataPower Gateway for Developers Docker Image in Docker Hub](https://hub.docker.com/r/ibmcom/datapower/)

[View the IBM DataPower Gateway Product Page](http://www-03.ibm.com/software/products/en/datapower-gateway)

[View the IBM DataPower Gateway Documentation](https://www.ibm.com/support/knowledgecenter/SS9H2Y)


_Copyright©  IBM Corporation 2017. All Rights Reserved._

_The IBM DataPower Gateway logo is copyright IBM and is provided for use for the purposes of IBM Cloud Private. You will not use the IBM DataPower Gateway logo in any way that would diminish the IBM or IBM DataPower Gateway image. IBM reserves the right to end your privilege to use the logo at any time in the future at our sole discretion. Any use of the IBM DataPower Gateway logo affirms that you agree to adhere to these conditions._