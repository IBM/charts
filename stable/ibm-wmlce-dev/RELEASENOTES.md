[//]: # (Licensed Materials - Property of IBM)
[//]: # (5737-E67)
[//]: # (\(C\) Copyright IBM Corporation 2018,2019 All Rights Reserved.)
[//]: # (US Government Users Restricted Rights - Use, duplication or)
[//]: # (disclosure restricted by GSA ADP Schedule Contract with IBM Corp.)

# What’s new in Chart Version 2.0.2

- X86 support added
- Charts renamed from ibm-powerai to ibm-wmlce-dev

# Prerequisites

- Kubernetes v1.11.3 or later with GPU scheduling enabled, and Tiller v2.7.2 or later
- The application must run on nodes with *supported GPUs* [see IBM WML CE V1.6.1 release notes](https://developer.ibm.com/linuxonpower/deep-learning-powerai/releases/).  
- Helm 2.7.2 and later version


# Breaking Changes

  Helm upgrade from 2.0.1 to 2.0.2 broken due to rename of charts. To upgrade:

  - Redeploy with identical values.yaml
  - Deprecate 2.0.1 deployment.
  - Ultimately delete 2.0.1 deployment after move is complete.

# Documentation
Refer (https://developer.ibm.com/linuxonpower/deep-learning-powerai/)


# Fixes
- Changes for ibm cloud pak certification
- Fixes for vulnerability found in base image

## Version History
| Chart | Date | Details |
| ----- | ---- | ------- |
| 2.0.2 | June 2019 | X86 support added|
| 2.0.1 | March 2019 | Release update|
| 2.0.0 | December 2018 | Snapml Option enabled|
| 1.5.3 | September 2018 | DDL Option enabled|
| 1.5.2 | June 2018 | |
