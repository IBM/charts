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

# Deploying OpenWhisk

## Overview

You will use Helm to deploy OpenWhisk to your Kubernetes cluster.
There are four deployment steps that are described in more
detail below in the rest of this section.
1. [Initial cluster setup](#initial-setup). You will create a
Kubernetes namespace into which to deploy OpenWhisk and label the
Kubernetes worker nodes to be used to execute user actions.
2. [Customize the deployment](#customize-the-deployment). You will
create a `mycluster.yaml` that specifies key facts about your
Kubernetes cluster and the OpenWhisk configuration you wish to
deploy.
3. [Deploy OpenWhisk with Helm](#deploy-with-helm). You will use Helm and
`mycluster.yaml` to deploy OpenWhisk to your Kubernetes cluster.
4. [Configure the `wsk` CLI](#configure-the-wsk-cli). You need to
tell the `wsk` CLI how to connect to your OpenWhisk deployment.

## Initial setup

1. Resources in Kubernetes are organized into namespaces. You can use
any name for the namespace you want, but we suggest using
`openwhisk`. Create one by issuing the command:
```shell
kubectl create namespace openwhisk
```

2. Identify the Kubernetes worker nodes that should be used to execute
user containers.  Do this by labeling each node with
`openwhisk-role=invoker`.  For a single node cluster, simply do
```shell
kubectl label nodes --all openwhisk-role=invoker
```
If you have a multi-node cluster, for each node <INVOKER_NODE_NAME>
you want to be an invoker, execute
```shell
$ kubectl label nodes <INVOKER_NODE_NAME> openwhisk-role=invoker
```


Beyond specifying the ingress, the `mycluster.yaml` file is also used
to customize your OpenWhisk deployment by enabling optional features
and controlling the replication factor of the various micro-services
that make up the OpenWhisk implementation. See the [configuration
choices documentation](./docs/configurationChoices.md) for a
discussion of the primary options.

## Deploy With Helm

Deployment can be done by using the following single command:
```shell
helm install ./helm/openwhisk --namespace=openwhisk --name=owdev -f mycluster.yaml
```
For simplicity, in this README, we have used `owdev` as the release name.
You can use a different name, or not specify a name at all and let
Helm auto-generate one for you.

You can use the command `helm status owdev` to get a summary
of the various Kubernetes artifacts that make up your OpenWhisk
deployment. Once all the pods shown by the status command are in
either the `Running` or `Completed` state, your OpenWhisk deployment
is ready to be used.

## Configure the wsk CLI

Configure the OpenWhisk CLI, wsk, by setting the auth and apihost
properties (if you don't already have the wsk cli, follow the
instructions [here](https://github.com/apache/incubator-openwhisk-cli)
to get it). Replace `whisk.ingress.api_host_name` and `whisk.ingress.api_host_port`
with the actual values from your mycluster.yaml.
```shell
wsk property set --apihost whisk.ingress.api_host_name:whisk.ingress.api_host_port
wsk property set --auth 23bc46b1-71f6-4ed5-8c54-816aa4f8c502:123zO3xZCLrMN6v2BKK1dXYFpXlPkccOFqm12CdAsMgRU4VrNZ9lyGVCGuMDGIwP
```

## Verify your OpenWhisk Deployment

Your OpenWhisk installation should now be usable.  You can test it by following
[these instructions](https://github.com/apache/incubator-openwhisk/blob/master/docs/actions.md)
to define and invoke a sample OpenWhisk action in your favorite programming language.

Note: if you installed self-signed certificates, which is the default
for the OpenWhisk Helm chart, you will need to use `wsk -i` to
suppress certificate checking.  This works around `cannot validate
certificate` errors from the `wsk` CLI.

If your deployment is not working, check our
[troubleshooting guide](./docs/troubleshooting.md) for ideas.


# Cleanup

Use the following command to remove all the deployed OpenWhisk components:
```shell
helm delete owdev
```
Helm does keep a history of previous deployments.  If you want to
completely remove the deployment from helm, for example so you can
reuse owdev to deploy OpenWhisk again, use the command:
```shell
helm delete owdev --purge
```

# Disclaimer

Apache OpenWhisk Deployment on Kubernetes is an effort undergoing incubation at The Apache Software Foundation (ASF), sponsored by the Apache Incubator. Incubation is required of all newly accepted projects until a further review indicates that the infrastructure, communications, and decision making process have stabilized in a manner consistent with other successful ASF projects. While incubation status is not necessarily a reflection of the completeness or stability of the code, it does indicate that the project has yet to be fully endorsed by the ASF.

