# Breaking Changes
* None

# What's new in 2.2.1
* Added support for a monitoring metrics
* Updated voice gateway images to 1.0.2.0
* [What's new](https://www.ibm.com/support/knowledgecenter/SS4U29/whatsnew.html)


# Fixes
None

# Prerequisites
* IBM Cloud Private 3.1.0 or greater
* Watson Speech To Text, Watson Text to Speech and Watson Assistant services are required prior to installing the Voice Gateway Helm Chart.

# Documentation
* [Deploying Voice Gateway in IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SS4U29/deployicp.html)

## Upgrade

- Upgradable from version 2.0.0 and above
- If upgrading from version 2.0.0 or 2.0.1 to 2.1.0 and above, you will need to recreate the tenant configuration secret before upgrading:
  - Delete old tenant configuration secret:
    ```
    kubectl delete secret vgw-tenantconfig-secret -n <namespace>
    ```
  - Create new tenant configuration secret:
    ```
    kubectl create secret generic vgw-tenantconfig-secret --from-file=tenantConfig=tenantConfig.json -n <namespace>
    ```
- If upgrading from version 2.0.0 or 2.0.1 to 2.1.0 and above, you will need to create the metering API Key secret before upgrading:
  - Add the metering API Key in a text file `metering-api-key.txt` (Make sure there are no extra spaces or new lines in the text file)
  - Create secret for the metering API Key:
    ```
    kubectl create secret generic metering-api-key-secret --from-file=meteringApiKey=metering-api-key.txt -n <namespace>
    ```

# Version History

| Chart | Date        | Kubernetes Required | Image(s) Supported | Details |
| ----- | ----------- | ----------- | ------------------ | ------- |
| 2.2.1 | Jun 28, 2019 | >= 1.11    | ibmcom/voice-gateway-so:1.0.2.0 and ibmcom/voice-gateway-mr:1.0.2.0 | Updated images to version 1.0.2.0, added support for monitoring metrics |
| 2.1.1 | Mar 29, 2019 | >= 1.11    | ibmcom/voice-gateway-so:1.0.1.0 and ibmcom/voice-gateway-mr:1.0.1.0 | Updated images to version 1.0.1.0 |
| 2.1.0 | Mar 01, 2019 | >= 1.11    | ibmcom/voice-gateway-so:1.0.0.8d and ibmcom/voice-gateway-mr:1.0.0.8d | Updated images to version 1.0.0.8d, added support for storing persistent logs, configuring SSL, mutual authentication and MRCPv2 |
| 2.0.1 | Oct 26, 2018 | >= 1.11    | ibmcom/voice-gateway-so:1.0.0.7a and ibmcom/voice-gateway-mr:1.0.0.7a | Updated images to version 1.0.0.7a |
| 2.0.0 | Sep 28, 2018 | >= 1.11    | ibmcom/voice-gateway-so:1.0.0.7 and ibmcom/voice-gateway-mr:1.0.0.7 | Updated images to version 1.0.0.7, added support for for JSON based configuration, added node selector feature, added metering support |
| 1.3.0 | Aug 24, 2018 | >= 1.9.1    | ibmcom/voice-gateway-so:1.0.0.6b and ibmcom/voice-gateway-mr:1.0.0.6b | Updated images to version 1.0.0.6b |
| 1.2.0 | Jul 09, 2018 | >= 1.9.1    | ibmcom/voice-gateway-so:1.0.0.6 and ibmcom/voice-gateway-mr:1.0.0.6 | Updated images to version 1.0.0.6 |
| 1.1.0 | Apr 25, 2018 | >= 1.9.1    | ibmcom/voice-gateway-so:1.0.0.5d and ibmcom/voice-gateway-mr:1.0.0.5d | Added support for call quiescing feature of Voice Gateway |
| 1.0.0 | Mar 16, 2018 | >= 1.9.1    | ibmcom/voice-gateway-so:1.0.0.5 and ibmcom/voice-gateway-mr:1.0.0.5 | Initial release |
