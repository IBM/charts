# IBM Reactive Platform Lagom Sample

![Lagom logo](https://raw.githubusercontent.com/IBM/charts/master/logo/lagom-logo.png)

THIS CHART IS NOW DEPRECATED. On June 19th the helm chart for the Reactive Platfrom Lagon Sample will be removed from IBM's public helm repository on github.com

The Reactive Platform Lagom Sample showcases the Lagom Framework within the Reactive Platform using a simple microblogging application.

## Introduction

Reactive Platform from [IBM](https://developer.ibm.com/code/partners/reactive-platform/) and [Lightbend](http://www.lightbend.com) is a JVM-based application development framework and runtime solution for building and deploying Reactive applications. Reactive Platform provides Java and Scala developers with the tools they need to easily build reactive applications that are responsive, resilient and elastic, underpinned by message-driven non-blocking communication. The [Reactive Manifesto](https://www.reactivemanifesto.org/) describes this in more detail.

The [Lagom Framework](https://www.lagomframework.com/) is an open source framework for building reactive microservice systems in Java or Scala and is a supported part of the Reactive Platformn. Lagom builds on [Akka](http://akka.io) for highly concurrent, distributed and resilient message-driven applications and the [Play](https://www.playframework.com/) Web Application Framework. These are also available within the Reactive Platform.

[Lightbend Orchestration](https://developer.lightbend.com/docs/lightbend-orchestration/current/overview.html) is "... a developer-centric suite of tools that helps you deploy Reactive Platform applications to Kubernetes”.

## Chart Details
The Helm chart provided here deploys the [Chirper](https://github.com/lagom/lagom-java-chirper-example) application to IBM Cloud Private. It makes use of Docker images built from the [Chirper source](https://github.com/lagom/lagom-java-sbt-chirper-example/) by the [Reactive App SBT plugin](https://github.com/lightbend/sbt-reactive-app). A [plugin for the Apache Maven build tool](https://github.com/lightbend/reactive-app-maven-plugin) is also available.

Two of the microservices in the application - the Chirp Serivce and the Friend Service - are implemented as [Akka Clusters](https://doc.akka.io/docs/akka/2.5/common/cluster.html) and are deployed with three replicas to create a minimum sized Akka cluster. An Akka cluster member runs as a Kubernetes Replicas with Akka handling the addition and removal of members as underlying Kubernetes Replicas are scaled up and down. 

As well as deploying the Chirper microservices, the Helm chart:
* deploys a Cassandra database instance to store the 'Chirps' created by a user,
* creates [Play Application Secrets](https://www.playframework.com/documentation/2.6.x/ApplicationSecret) for each service and deployed as opaque [Kubernetes secrets](https://kubernetes.io/docs/concepts/configuration/secret/),
* configures the ingress controller to route inbound requests to Chirper's web interface: the `front-end` service.

## Prerequisites
* Helm 2.9.1 or later
* Kubernetes 1.11 or later
* A dedicated "Kubernetes" namespace


### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation. To meet this requirement there may be cluster scoped as well as namespace scoped pre and post actions that need to occur.

The predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp) has been verified for this chart, if your target namespace is bound to this PodSecurityPolicy you can proceed to install the chart.

You can also define a custom PodSecurityPolicy for use with this chart, which can be used to finely control the permissions/capabilities needed to deploy this chart. You can enable a custom PodSecurityPolicy using the ICP user interface. From the user interface, you can copy and paste the following snippets to enable a custom PodSecurityPolicy:

  - Custom PodSecurityPolicy definition:
    ```
    apiVersion: extensions/v1beta1
    kind: PodSecurityPolicy
    metadata:
      name: ibm-chart-dev-psp
    spec:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: false
      allowedCapabilities:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
      - NET_BIND_SERVICE
      seLinux:
        rule: RunAsAny
      supplementalGroups:
        rule: RunAsAny
      runAsUser:
        rule: RunAsAny
      fsGroup:
        rule: RunAsAny
      volumes:
      - configMap
      - secret
    ```
  - Custom ClusterRole for the custom PodSecurityPolicy:
    ```
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: ibm-chart-dev-clusterrole
    rules:
    - apiGroups:
      - extensions
      resourceNames:
      - ibm-chart-dev-psp
      resources:
      - podsecuritypolicies
      verbs:
      - use
    ```


## Resources Required
* CPU: 1 core
* RAM: 6GB

## Installing the Chart
### Installing from the command line
To install the chart from the command line with the release name `my-release` into the namespace `my-namespace`:

    helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/ --tls
    helm install --name my-release --set hostname=chirper.<icp proxy node address>.nip.io --namespace my-namespace ibm-charts/ibm-reactive-platform-lagom-sample --tls

Note that the hostname is a required value and needs to be set as part of the helm install.
This command deploys the Chirper Reactive_platform Lagom Sample on the Kubernetes cluster in the default configuration. The configuration section lists the parameters that can be configured during installation.
### Installing with IBM Cloud Private
To install the chart with the release name `my-release`:

* Select configure
* Configure the release name
* Select the target namespace
* Accept the license agreement
* Enter the hostname used to access the Chirper Sample Application via Kubernetes Ingress (e.g. chirper.<icp proxy node address>.nip.io)
* Select Install


## Verifying the Chart
Instructions are displayed after you install the chart. Alternatively, see NOTES.txt associated with this chart for verification instructions.


## Uninstalling the Chart
To uninstall/delete the `my-release` deployment:

    helm delete my-release --purge

The command removes all the Kubernetes components associated with the chart and deletes the release.  
You can find the deployment with ```helm list --all``` and searching for an entry with the chart name "ibm-reactive-platform-lagom-sample".


## Testing the Chart with Helm
You can programmatically run the test in the following way:

    helm test my-release

replacing `my-release` with whatever you named your deployment.

## Upgrading the chart
First, ensure that the repo has been added to the helm list via the command (if not previously done - see "Installing from the command line" instructions):

    helm repo add ibm-charts https://raw.githubusercontent.com/IBM/charts/master/repo/stable/ --tls

Then run the following command to upgrade your deployed chart to the latest version, replacing `my-release` with whatever you named your deployment:

    helm upgrade `my-release` ibm-charts/ibm-reactive-platform-lagom-sample --recreate-pods --tls


## Configuration

The following table lists the configurable parameters of the ibm-reactive-platform-lagom-sample chart and their default values.

| Parameter                  | Description                                     | Default |
| -----------------------    | ---------------------------------------------   | -------------- |
| `hostname`                 | Hostname for Chirper application                |  |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

> **Tip**: You can use the default values.yaml

## Limitations

amd64 only
