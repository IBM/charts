# IBM Watson Natural Language Processing

This is a placeholder to avoid local cv lint errors.  Since this chart is a subchart of NLU, this file is not needed, but its nice to avoid the cv lint errors when running cv lint against textprocessing.

NLU Text Processing API

## Introduction

NLU Text Processing API is a stateless microservice, written in Java. API accepts a text, processes it to determine its morphological information like sentence, token, lemma, part of speech.., and returns in JSON format.

## Chart Details

This chart creates one pod and an associaged service:

- `ibm-watson-nlp-prod` - Tokenizes the incoming text.
  - Supported languages
    - English
    - Japanese
    - French
    - Portuguese
    - Italian
    - Spanish
    - German

All the requests are processed by one single service/deployment.

## Prerequisites
## Resources Required
## Installing the Chart

To install the chart with the release name `my-release`:

```bash
$ helm install --name my-release /path/to/chart
```

To verify an installation:

```bash
$ helm test my-release
```

Or with cleanup:

```bash
$ helm test --cleanup my-release
```

To delete an installation:

```bash
$ helm delete my-release
```

Or remove the release from the store and make its name free for later use:

```bash
$ helm delete --purge my-release
```

## Configuration

The following tables lists the configurable parameters of the `ibm-watson-nlp-prod` chart and their default values.

| Parameter                     | Description                                                                                                                                   | Default                                          |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| global.imagePullSecretName    | reference to an existing image pull secret that will be injected into pods, should not be required in ICP(4D), but helpful during development | `"regsecret"`                                    |
| global.icpDockerRepo          | docker registry and namespace where the images exist, should not be required in ICP(4D), but helpful during development                       | `"registry.ng.bluemix.net/nlu_text_processing/"` |
| global.textProcessing.port    | Text Processing API service port                                                                                                              | `19443`                                          |
| api.image                     | docker image repo name                                                                                                                        | `"api-ubi"`                                      |
| api.tag                       | docker image tag name                                                                                                                         | `"develop-24-f24ff53"`                           |
| api.replicaCount              | number of replicas deployed                                                                                                                   | `1`                                              |
| api.resources.requests.cpu    | the amount of CPU a Text Processing runtime requires to run                                                                                   | `"500m"`                                         |
| api.resources.requests.memory | the amount of memory a Text Processing runtime can maximally consume                                                                          | `"1000Mi"`                                       |
| api.resources.limits.cpu      | the amount of CPU a Text Processing runtime can maximally consume                                                                             | `"1000m"`                                        |
| api.resources.limits.memory   | the amount of memory a Text Processing runtime can maximally consume                                                                          | `"4000M1"`                                       |
| product.name                  | annotation value for `productName` for metering, should be provided from the parent chart                                                     | `"ibm-watson"`                                   |
| product.id                    | annotation value for `productID` for metering, should be provided from the parent chart                                                       | `"0"`                                            |
| product.version               | annotation value for `productVersion` for metering, should be provided from the parent chart                                                  | `"1.0"`                                          |
| tests.image.repository        | docker image repo name for curl used in helm test                                                                                             | `"dvt-ubi"`                                      |
| tests.image.tag               | docker image tag name for curl used in helm test                                                                                              | `"develop-24-f24ff53"`                           |

## Limitations
## PodSecurityPolicy Requirements
- Custom PodSecurityPolicy definition:

```
```

  _Copyright©  IBM Corporation 2018. All Rights Reserved._
