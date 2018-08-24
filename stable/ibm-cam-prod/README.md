[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # (\(C\) Copyright IBM Corporation 2016-2018 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)

# Cloud Automation Manager Helm Chart - Deprecated

IBM Cloud Automation Manager is a cloud management solution on IBM Cloud Private (ICP) for deploying cloud infrastructure in multiple clouds with an optimized user experience.

## Introduction

IBM Cloud Automation Manager uses open source Terraform to manage and deliver cloud infrastructure as code. Cloud infrastructure delivered as code is reusable, able to be placed under version control, shared across distributed teams, and it can be used to easily replicate environments.

The Cloud Automation Manager content library comes pre-populated with sample templates to help you get started quickly. Use the sample templates as is or customize them as needed.  A Chef runtime environment can also be deployed using CAM for more advanced application configuration and deployment.

With Cloud Automation Manager, you can provision cloud infrastructure and accelerate application delivery into IBM Cloud, Amazon EC2, VMware vSphere, and VMware NSXv cloud environments with a single user experience.

You can spend more time building applications and less time building environments when cloud infrastructure is delivered with automation. You are able to get started fast with pre-built infrastructure from the Cloud Automation Manager library.

## Documentation

For version-wise installation instructions and detailed documentation of IBM Cloud Automation Manager (CAM), go to its Knowledge Center at https://www.ibm.com/support/knowledgecenter/SS2L37/product_welcome_cloud_automation_manager.html. 

Select your version from the drop-down list and search for your topics from within the version.

## Deprecation
THIS CHART IS NOW DEPRECATED. Here’s what you need to know: On September 28th, 2018 the helm chart for IBM Cloud Automation Manager named "ibm-cam-prod" will be removed from IBM's public helm repository on github.com in favor of the updated chart named "ibm-cam". This will result in the "ibm-cam-prod" chart no longer being displayed in the catalog. This will not impact existing deployments of the helm chart. For new deploymenets please use the "ibm-cam" helm chart in the IBM Cloud Private catalog.