<!--
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
-->

# OpenWhisk

Apache OpenWhisk is an open source, distributed serverless platform that executes functions in response to events at any scale.

## Introduction

The [Apache OpenWhisk](https://openwhisk.apache.org/) serverless platform supports a programming model in which developers write functional logic (called Actions), in any supported programming language, that can be dynamically scheduled and run in response to associated events (via Triggers) from external sources (Feeds) or from HTTP requests.

This chart will deploy the core OpenWhisk platform to your Kubernetes cluster.  In its default configuration, the chart enables runtime support for executing actions written in NodeJS, Python, Swift, Java, PHP, Ruby, Go, and "blackbox" docker containers.  The main components of the OpenWhisk platform are a front-end that provides a REST API to the user and the `wsk` CLI, a CouchDB instance that stores user and system data, and a control plane that is responsible for scheduling incoming invocations of user actions onto dedicated Kubernetes worker nodes that have been labeled as "invoker nodes".

Further documentation of the OpenWhisk system architecture, programming model, tutorials, and sample programs can all be found at on the [Apache OpenWhisk project website](https://openwhisk.apache.org/).

## Chart Details

In its default configuration, this chart will create the following Kubernetes resources:
* Externally exposed Services
   * nginx -- used to access the deployed OpenWhisk via its REST API.  By default, exposed as a NodePort on port 31001.
* Internal Services
   * apigateway, controller, couchdb, kafka, nginx, redis, zookeeper
* OpenWhisk control plane Pods:
   * DaemonSet: invoker (on all nodes with label `openwhisk-role=invoker`)
   * Deployments: apigateway, couchdb, nginx, redis
   * SatefulSets: controller, kafka, zookeeper
* Persistent Volume Claims
   * couchdb-pvc
   * kafka-pvc
   * redis-pvc
   * zookeeper-pvc-data
   * zookeeper-pvc-datalog

All user interaction with OpenWhisk uses the REST API exposed by the nginx service via its NodePort ingress.

The chart requires one or more Kubernetes worker nodes to be designated to be used by OpenWhisk's invokers to execute user actions.  These nodes are designated by being labeled with `openwhisk-role=invoker` (see below for the `kubectl` command).  In its default configuration, the invokers will schedule the containers to execute the user actions on these nodes *without* interacting with the Kubernetes scheduler.

## Resources Required

* A Kubernetes cluster with at least 1 worker node with at least 4GB of memory.

## Prerequisites

* Kubernetes 1.10 - 1.12.*

### Image Policy Requirements

If Container Image Security is enabled, you will not be able to download non-trusted container images. If this is the case, please add the following to the trusted registries so that these container images can be pulled during chart installation:

* docker.io/openwhisk/*
* docker.io/apache/couchdb:*

### Persistent Volume Requirements

This chart requires 5 Persistent Volumes to be created to avoid loss of data.  One of the following must be true to satisfy the Persistent Volume requirements for this chart:

* When the chart is deployed, the value `k8s.persistence.enabled` is set to false to disable usage of Persistent Volumes (for development and test activities).
* The Kubernetes cluster supports Dynamic Volume Provisioning and has a default StorageClass defined with an associated provisioner.
* The Kubernetes cluster supports Dynamic Volume Provisioning and when the chart is deployed, the value `k8s.persistence.hasDefaultStorageClass` is set to `false` and `k8s.persistence.explicitStorageClass` is set to a StorageClass which has an associated provisioner.

### PodSecurityPolicy Requirements

OpenWhisk's Invokers need elevated security permissions to be able to create the containers that execute the user actions. Therefore, this chart requires a PodSecurityPolicy that permits host access to be bound to the target namespace prior to installation.  If the default Pod security policy on your cluster is not restrictive then this step is not needed. If the default is restrictive, please create a new namespace with either a predefined PodSecurityPolicy `ibm-anyuid-hostpath-psp`:

* Predefined PodSecurityPolicy name: [`ibm-anyuid-hostpath-psp`](https://ibm.biz/cpkspec-psp)

Alternatively, you can have your cluster administrator setup a custom PodSecurityPolicy for you using the below definition:

* Custom PodSecurityPolicy definition:

    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
        name: ibm-anyuid-hostpath-psp
    annotations:
        kubernetes.io/description: "This policy allows pods to run with
        any UID and GID and any volume, including the host path.
        WARNING:  This policy allows hostPath volumes.
        Use with caution."
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
        - '*'
    ```

## Initial setup

Identify the Kubernetes worker nodes that should be used to execute
user containers.  Do this by labeling each node with
`openwhisk-role=invoker`.  If you have a multi-node cluster, for each node <INVOKER_NODE_NAME>
you want to be an invoker, execute
```shell
kubectl label nodes <INVOKER_NODE_NAME> openwhisk-role=invoker
```
For a single node cluster, simply do
```shell
kubectl label nodes --all openwhisk-role=invoker
```

## Installing the Chart

Please ensure that you have reviewed the [prerequisites](#prerequisites) and the [initial setup](#initial-setup) instructions.

To install the chart using helm cli:

```bash
$ helm install [--tls] openwhisk --namespace <my-namespace> --name <my-release> --set whisk.ingress.apiHostName=<cluster-ip-address>
```

The command deploys OpenWhisk on the Kubernetes cluster in the default configuration.  The [configuration](#configuration) section lists the parameters that can be configured during installation.

You can use the command ```helm status <my-release> [--tls]``` to get a summary of the various Kubernetes artifacts that make up your OpenWhisk deployment. Once the ```<my-release>-install-packages``` Pod is in the Completed state, your OpenWhisk deployment is ready to be used.

### Configuration

[Values.yaml](./values.yaml) outlines the configuration options that are supported by this chart.

### Verifying the Chart

To verify your deployment was successful, simply run:
```bash
helm test <my-release> [--tls] --cleanup
```

## Uninstalling the Chart

To uninstall/delete the deployment:

```bash
$ helm delete <my-release> --purge [--tls]
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Limitations

* Deployment limitation - only one instance of the chart can be deployed within a namespace.
* Platform limitation - only supports amd64.

## Documentation

Documentation of the OpenWhisk system architecture, programming model, tutorials, and sample programs can all be found at on the [Apache OpenWhisk project website](https://openwhisk.apache.org/).

# Disclaimer

Apache OpenWhisk Deployment on Kubernetes is an effort undergoing incubation at The Apache Software Foundation (ASF), sponsored by the Apache Incubator.  Incubation is required of all newly accepted projects until a further review indicates that the infrastructure, communications, and decision making process have stabilized in a manner consistent with other successful ASF projects.  While incubation status is not necessarily a reflection of the completeness or stability of the code, it does indicate that the project has yet to be fully endorsed by the ASF.

# Support

For questions, hints, and tips for developing in Apache OpenWhisk:

* [Join the Dev Mailing List](https://openwhisk.apache.org/community.html#mailing-lists)

* [Join the OpenWhisk Slack](http://slack.openwhisk.org/)

* [Follow OpenWhisk Media](https://openwhisk.apache.org/community.html#social)
