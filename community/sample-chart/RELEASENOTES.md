# Breaking Changes
* SSL passthrough is disabled by default. To enable the feature use --enable-ssl-passthrough

# What’s new in Chart Version 1.2.0

With Product A on IBM Cloud Private 2.1.0.2, the following new
features are available:
* _Summary of new capability in the chart and / or image with links to product release information.  The level of detail provided is at discretion of product teams (see next bullets as example from CAM).
* For the terraform provider binaries, you can directly Bring Your Own (BYO)
providers into the terraform persistent volume. For more information, see Using an
external terraform and Creating Cloud Automation Manager persistent volumes.
* Support interpolation of input and output parameters for Templates, Rest Hooks,
Email notification activities in service configuration. For more information, see
Mapping input and output parameters.
* The composition tab interface of a service now includes search filters and output
parameters for the template component. The management of Header keys and values
for Resthook component is now redefined for ease of use.See Creating a service.


# Fixes
* list some fixes

# Prerequisites
1. IBM Cloud Private version 2.1.0.2.
2. 

# Documentation
For detailed upgrade instructions go to https://www.ibm.com/support/knowledgecenter/en/SS2L37_2.1.0.1/cam_upgrade_cam.html.

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
| 1.1.0 | Dec 15, 2017| >=1.9.1 | image-a: 7.7.0.0.* | SSL passthrough is disabled by default. To enable the feature use --enable-ssl-passthrough | Chart updated to generate certifications using HELM 2.7.2 function.  |
| 1.0.5 | Oct 13, 2017| >=1.8.3 | image-a: 7.6.0.1.* | None | Security fix for xyz <brief summary w/ link to product information>  Core() is deprecated use CoreV1() instead. |
| 1.0.4 | Aug 17, 2017| >=1.7.3 | image-a: 7.6.0.0.* | None  | New product release <brief summary w/ link to product information>  Known Issue: When ModSecurity is enabled a segfault could occur. |
