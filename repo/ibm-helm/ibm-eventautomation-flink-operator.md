## Introduction
Built on the open-source [Apache Flink](https://flink.apache.org), IBM Operator for Apache Flink acts
as a control plane to manage the complete deployment lifecycle of Flink applications.

## Chart Details
This chart can be used to install IBM Operator for Apache Flink, which has the following key features:

- Deploy and monitor a Flink cluster in Session or Application mode.
- Upgrade, suspend and delete deployments.
- Logging and metrics integration.
- Flexible deployments and native integration with Kubernetes tooling.

### Prerequisites
When enabling High Availability (HA), you need to have a Kubernetes Persistent Volume Claim (PVC) for
holding Flink checkpoints, savepoints and HA data.

    See [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes) for more details.

### Resources Required
IBM Operator for Apache Flink resource requirements depend on several factors. For information about minimum
resource requirements, see the [documentation](https://ibm.biz/event-automation).

## Installing the Chart
For information about installing the IBM Operator for Apache Flink, see the [documentation](https://ibm.biz/ep-installing-flink).
To create an instance, read the [license agreement](https://ibm.biz/ea-license) and accept it by adding
the license-related parameters to the `FlinkDeployment` custom resource as described in the [documentation](https://ibm.biz/ep-installing-flink).
If these parameters are not present, the deployment fails.

## Configuration
IBM Operator for Apache Flink provides sample configurations to help you get started with deployments.
To get started, choose one of the samples suited to your requirements.
You can modify the samples, save them, and apply custom configuration settings as well.

For details about the `FlinkDeployment` custom resource, refer
to [Flink custom resources](https://nightlies.apache.org/flink/flink-kubernetes-operator-docs-release-1.5/docs/custom-resource/overview).
Note that the fields `image` and `flinkVersion` should not be set, as they are controlled by the IBM Operator for Apache Flink.

For more information about the sample configurations and guidance about configuring your instances,
see the [documentation](https://ibm.biz/event-automation).

## Limitations
- Supported only on the Linux&reg; x86_64 platform.

See also the [documentation](https://ibm.biz/event-automation).

*© Copyright IBM Corp. 2023*
