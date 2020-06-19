# Breaking Changes

- IBM Private Cloud is not supported starting this release

# What's new in 3.0.0
- Updated voice gateway images to 1.0.6.0
- [What's new](https://www.ibm.com/support/knowledgecenter/SS4U29/whatsnew.html)
- Added support to install using Assembly on Cloud Pak for Data
- Images available on Entitled Registry
- Added DVT which uses SIP OPTIONS to check for application availability

# Fixes

None

# Prerequisites
- IBM Cloud Pak for Data V2.5.0.0 or V3.0.1
- Watson Speech To Text, Watson Text to Speech and Watson Assistant services are required prior to installing the Voice Gateway Helm Chart.
- Entitlement to entitled registry is required to pull product images

# Documentation

- [Deploying Voice Gateway Addon on Cloud Pak for Data](https://www.ibm.com/support/knowledgecenter/SSQNUZ_current/svc-wavi/wavi-addon-install.html)

# Version History
| Chart | Date        | Kubernetes Required | Image(s) Supported | Details |
| ----- | ----------- | ----------- | ------------------ | ------- |
| 3.0.0 | Jun 18, 2020 | >= 1.11             | cp.icr.io/cp/voice-gateway-so:1.0.6.0, cp.icr.io/cp/voice-gateway-mr:1.0.6.0, cp.icr.io/cp/voice-gateway-codec-g729:1.0.6.0, cp.icr.io/cp/voice-gateway-sms:1.0.6.0, cp.icr.io/cp/voice-gateway-dvt:1.0.6.0   | Updated voice gateway images to 1.0.6.0, Remove support for ICP, add support for CP4D 3.0.1, added helm test DVT which uses SIP OPTIONS to check for application availability                                                            |
| 2.1.0 | Feb 28, 2020 | >= 1.11             | ibmcom/voice-gateway-so:1.0.5.0, ibmcom/voice-gateway-mr:1.0.5.0, ibmcom/voice-gateway-codec-g729:1.0.5.0, ibmcom/voice-gateway-sms:1.0.5.0   | Bug fixes, updated voice gateway images to 1.0.5.0                                                                |
| 2.0.1 | Nov 22, 2019 | >= 1.11             | ibmcom/voice-gateway-so:1.0.4.0, ibmcom/voice-gateway-mr:1.0.4.0, ibmcom/voice-gateway-codec-g729:1.0.4.0, ibmcom/voice-gateway-sms:1.0.4.0   | Minor updates, updated voice gateway images to 1.0.4.0                                                                |
| 2.0.0 | Sep 27, 2019 | >= 1.11             | ibmcom/voice-gateway-so:1.0.3.0, ibmcom/voice-gateway-mr:1.0.3.0, ibmcom/voice-gateway-codec-g729:1.0.3.0, ibmcom/voice-gateway-sms:1.0.3.0   | Added SMS Gateway microservice, added G729AB microservice, added support for Cloud Pak for Data with OpenShift platform, enhancements to the helm chart, updated voice gateway images to 1.0.3.0                                                                |
| 1.2.1 | Jun 28, 2019 | >= 1.11    | ibmcom/voice-gateway-so:1.0.2.0 and ibmcom/voice-gateway-mr:1.0.2.0 | Updated images to version 1.0.2.0, added support for monitoring metrics |
| 1.1.1 | Mar 29, 2019 | >=1.11    | ibmcom/voice-gateway-so:1.0.1.0 and ibmcom/voice-gateway-mr:1.0.1.0 | Updated images to version 1.0.1.0 |
| 1.1.0 | Mar 01, 2019 | >=1.11    | ibmcom/voice-gateway-so:1.0.0.8d and ibmcom/voice-gateway-mr:1.0.0.8d | Updated images to version 1.0.0.8d, added support for storing persistent logs, configuring SSL, mutual authentication and MRCPv2 |
| 1.0.1 | Oct 26, 2018 | >=1.11    | ibmcom/voice-gateway-so:1.0.0.7a and ibmcom/voice-gateway-mr:1.0.0.7a | Updated voice gateway images to 1.0.0.7a |
| 1.0.0 | Oct 08, 2018 | >=1.11    | ibmcom/voice-gateway-so:1.0.0.7 and ibmcom/voice-gateway-mr:1.0.0.7 | Initial release |