## Introduction
Event Processing incorporates Apache Flink to transform event streaming data in real time, helping you turn events into insights. You can take existing events and combine them through flows where you define the processing to be completed on the events. You connect to event sources to bring event data (messages) from Apache Kafka topics into your flow, and then set processing actions you want to take on your events.

## Chart Details
Event Processing features include:

- A user interface (UI) designed to provide a low-code experience.
- A free-form layout canvas to create flows, with drag-and-drop functionality to add and join nodes.
- The ability to test your event flow while constructing it.
- The option to import and export flows in JSON format to reuse across different deployment instances.
- The option to export the output of the flow processing to a CSV file.

### Prerequisites
Before installing IBM Event Processing, install the IBM Flink Helm chart from the IBM Helm repository following instructions in the [IBM Event Processing documentation](https://ibm.biz/ep-documentation).

You must also ensure you create a secret called `ibm-entitlement-key` in the namespace where you want to create an instance of IBM Event Processing
1. Obtain an entitlement key from https://myibm.ibm.com/products-services/containerlibrary
2. Create an image pull secret called `ibm-entitlement-key` using `cp` as the username, your entitlement key as the password, and `cp.icr.io` as the docker server:

`kubectl create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password=<your-entitlement-key> --docker-server=cp.icr.io -n <target-namespace>`

It is strongly recommended to install Cert Manager before the installation of IBM Event Processing. This will facilitate the handling of certificates for secure communication in the product.

### Resources Required
IBM Event Processing resource requirements depend on several factors. For information about minimum resource requirements, see the [IBM Event Processing documentation](https://ibm.biz/ep-documentation).

## Installing the Chart
For information about installing IBM Event Processing, see the [documentation](https://ibm.biz/ep-documentation).

## Configuration
IBM Event Processing provides sample configurations to help you get started with deployments. Choose one of the samples suited to your requirements to get started. You can modify the samples, save them, and apply custom configuration settings as well. For more information about the sample configurations and guidance about configuring your instances, see the [IBM Event Processing documentation](https://ibm.biz/ep-documentation).

## Limitations
Not applicable

*© Copyright IBM Corp. 2023*
