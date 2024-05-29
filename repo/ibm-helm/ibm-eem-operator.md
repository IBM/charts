## Introduction
IBM Event Endpoint Management provides the capability to describe and catalog your Kafka topics as event sources, and to share the details of the topics with application developers.

## Chart Details
Application developers can discover the event source and configure their applications to subscribe to the stream of events, providing self-service access to the message content from the event stream.
Access to event sources is managed by the Event Gateway, which handles the incoming requests from applications to consume from a topic's stream of events.

### Prerequisites
Before installing IBM Event Endpoint Management, ensure you create a secret called `ibm-entitlement-key` in the namespace where you want to create an instance of IBM Event Endpoint Management
1. Obtain an entitlement key from https://myibm.ibm.com/products-services/containerlibrary
2. Create an image pull secret called `ibm-entitlement-key` using `cp` as the username, your entitlement key as the password, and `cp.icr.io` as the docker server:

`kubectl create secret docker-registry ibm-entitlement-key --docker-username=cp --docker-password=<your-entitlement-key> --docker-server=cp.icr.io -n <target-namespace>`

It is strongly recommended to install the IBM Certificate Manager before the installation of IBM Event Endpoint Management. This will facilitate the handling of certificates for secure communication in the product.

### Resources Required
IBM Event Endpoint Management resource requirements depend on several factors. For information about minimum resource requirements, see the [IBM Event Endpoint Management documentation](https://ibm.biz/eem-documentation).

## Installing the Chart
For information about installing IBM Event Endpoint Management, see the [documentation](https://ibm.biz/eem-documentation).

## Configuration
IBM Event Endpoint Management provides sample configurations to help you get started with deployments. Choose one of the samples suited to your requirements to get started. You can modify the samples, save them, and apply custom configuration settings as well. For more information about the sample configurations and guidance about configuring your instances, see the [IBM Event Endpoint Management documentation](https://ibm.biz/eem-documentation).

## Limitations
Not applicable

*© Copyright IBM Corp. 2023*
