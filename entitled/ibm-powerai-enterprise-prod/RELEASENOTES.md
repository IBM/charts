[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # (\(C\) Copyright IBM Corporation 2018 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)

# What’s new in IBM PowerAI Enterprise Version 1.1.2

* Added Spectrum conductor v2.3.0 and DLI v1.2.1 support with PowerAI v1.5.4


# Prerequisites
1. Kubernetes v1.11.3 or later with GPU scheduling enabled, and Tiller v2.7.2 or later
2. The application must run on *Power System ppc64le* nodes with *supported GPUs* (see PowerAI v1.5.4 release notes).
3. Helm v2.7.2 or later.
4. IBM Cloud Private v3.1.1 or later.

# Breaking Changes
  None
  
# Rolling Upgrade
  Rolling upgrades from IBM PowerAI Enterprise Version v1.1.1 to IBM PowerAI Enterprise Version v1.1.2 are not supported.

# Documentation
  PowerAI Enterprise Knowledge Center: https://www.ibm.com/support/knowledgecenter/SSFHA8_1.1.2/powerai_enterprise_overview.html
  Developer portal: https://developer.ibm.com/linuxonpower/deep-learning-powerai/

# Fixes
1. IBM PowerAI v1.5.4 APAR 20855 fix for 'Pytorch LMS training sigint error for Imagenet Dataset'
2. IBM Spectrum Conductor v2.3.0 APAR IT27172 fix for 'Pytorch deep learning workload sigint error with Spark versions v1.6.1, v2.1.1, v2.2.0, or v2.3.1' 

## Version history
| Chart | Date | Details |
| ----- | ---- | ------- |
| 1.1.2 | December 2018 | Added IBM Specturm Conductor v2.3.0 and IBM Spectrum Conductor Deep Learning Impact v1.2.1 support with PowerAI v1.5.4 |
| 1.1.1 | October 2018 | Added IBM Specturm Conductor v2.3.0 and IBM Spectrum Conductor Deep Learning Impact v1.2.0 support with PowerAI v1.5.3 |
