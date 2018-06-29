[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # (\(C\) Copyright IBM Corporation 2016-2018 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)

# Cloud Automation Manager Helm Chart

IBM Cloud Automation Manager is a cloud management solution on IBM Cloud Private (ICP) for deploying cloud infrastructure in multiple clouds with an optimized user experience.

## Introduction

IBM Cloud Automation Manager uses open source Terraform to manage and deliver cloud infrastructure as code. Cloud infrastructure delivered as code is reusable, able to be placed under version control, shared across distributed teams, and it can be used to easily replicate environments.

The Cloud Automation Manager content library comes pre-populated with sample templates to help you get started quickly. Use the sample templates as is or customize them as needed.  A Chef runtime environment can also be deployed using CAM for more advanced application configuration and deployment.

With Cloud Automation Manager, you can provision cloud infrastructure and accelerate application delivery into IBM Cloud, Amazon EC2, VMware vSphere, VMware NSXv, Google Cloud, Microsoft Azure, IBM PureApplication and OpenStack cloud environments with a single user experience.

You can spend more time building applications and less time building environments when cloud infrastructure is delivered with automation. You are able to get started fast with pre-built infrastructure from the Cloud Automation Manager library.

## Chart Details

This chart deploys IBM Cloud Automation Manager as a number of deployments, services and an ingress.

## Prerequisites

IBM Cloud Automation Manager is only supported to run in IBM Cloud Private.

## Resources Required

* The minimum hardware requirements for IBM Cloud Automation Manager is a single worker node with at least 4 vCPU and 16GB of memory.
For a full list of hardware requirements go to: https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.3/cam_requirements.html

* Persistent Volumes are required to be pre-created.  For details see: https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.3/cam_create_pv.html

## Installing the Chart

This chart supports various installation options.  For complete details please see: https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.3/cam_planning.html

## Configuration

For the full list of configuration options supporte by this chart see: https://www.ibm.com/support/knowledgecenter/SS2L37_2.1.0.3/cam_installation_parameters.html

## Limitations

* IBM Cloud Automation Manager is only supported to run on an IBM Cloud Private cluster
* Only one instance of Cloud Automation Manager may be running in the cluster
* This chart must be deployed in the 'services' namespace.

## Documentation

For version-wise installation instructions and detailed documentation of IBM Cloud Automation Manager (CAM), go to its Knowledge Center at https://www.ibm.com/support/knowledgecenter/SS2L37/product_welcome_cloud_automation_manager.html.

Select your version from the drop-down list and search for your topics from within the version.
