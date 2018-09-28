# Breaking Changes
* Removed single-tenant support. Now you can use the JSON configuration to deploy a single-tenant or multi-tenant deployment of IBM Voice Gateway.
* Containers now do not run as root.

# What's new in 2.0.0
* Added support for for JSON based configuration.
* Added node selector feature.
* Added metering support.
* Added RBAC components in readme and ibm_cloud_pak/pak_extensions/prereqs directory of the chart, which are needed when running in non-default namespace.
* Updated images to ibmcom/voice-gateway-so:1.0.0.7 and ibmcom/voice-gateway-mr:1.0.0.7

# Prerequisites
- IBM Cloud Private 3.1.0
- Watson Speech To Text, Watson Text to Speech and Watson Assistant services are required prior to installing the Voice Gateway Helm Chart.

# Fixes
None

# Version History

| Chart | Date        | Kubernetes Required | Image(s) Supported | Details |
| ----- | ----------- | ----------- | ------------------ | ------- |
| 1.3.0 | Aug 24, 2018 | >= 1.9.1    | ibmcom/voice-gateway-so:1.0.0.6b and ibmcom/voice-gateway-mr:1.0.0.6b | Updated images to version 1.0.0.6b |
| 1.2.0 | Jul 09, 2018 | >= 1.9.1    | ibmcom/voice-gateway-so:1.0.0.6 and ibmcom/voice-gateway-mr:1.0.0.6 | Updated images to version 1.0.0.6 |
| 1.1.0 | Apr 25, 2018 | >= 1.9.1    | ibmcom/voice-gateway-so:1.0.0.5d and ibmcom/voice-gateway-mr:1.0.0.5d | Added support for call quiescing feature of Voice Gateway |
| 1.0.0 | Mar 16, 2018 | >= 1.9.1    | ibmcom/voice-gateway-so:1.0.0.5 and ibmcom/voice-gateway-mr:1.0.0.5 | Initial release |
