# IBM Datapower Gateway (Beta Version)

## Introduction
[IBM DataPower Gateway](http://www-03.ibm.com/software/products/en/datapower-gateway) is a market leading extensible gateway platform for developers & enterprises. It helps you quickly secure, control, connect and accelerate the delivery of APIs, applications and data across digital business channels in the cloud and on premise to enable digital innovation and transformation.

## Prerequisites

- Kubernetes Level `v1beta1`

Learn more about IBM DataPower Gateway at the following link: [https://www.ibm.com/support/knowledgecenter/SS9H2Y](https://www.ibm.com/support/knowledgecenter/SS9H2Y).

 ## Installing the Chart
 To install the chart with the release name `my-release` and default pattern (See .Values.patternName below):
 ```bash
$ helm install --name my-release -f <mycrypto.yaml> stable/ibm-datapower-dev
```

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

> **Tip**: You can use the default [values.yaml](values.yaml)
