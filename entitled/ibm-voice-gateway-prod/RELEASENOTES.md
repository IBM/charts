# Breaking Changes

- None

# What's new in 2.0.1
- Minor updates
- Updated voice gateway images to 1.0.4.0
- [What's new](https://www.ibm.com/support/knowledgecenter/SS4U29/whatsnew.html)

# Fixes

None

# Prerequisites

- IBM Cloud Private 3.1.0 or greater
- Watson Speech To Text, Watson Text to Speech and Watson Assistant services are required prior to installing the Voice Gateway Helm Chart.

# Documentation

- [Deploying Voice Gateway in IBM Cloud Private](https://www.ibm.com/support/knowledgecenter/SS4U29/deployicp.html)

## Upgrade

- Upgradable from version 1.0.0 and above
- If upgrading from version 1.0.0 or 1.0.1 to 1.1.0 and above, you will need to recreate the tenant configuration secret before upgrading:
  - Delete old tenant configuration secret:
    ```
    kubectl delete secret vgw-tenantconfig-secret -n <namespace>
    ```
  - Create new tenant configuration secret:
    ```
    kubectl create secret generic vgw-tenantconfig-secret --from-file=tenantConfig=tenantConfig.json -n <namespace>
    ```
- If upgrading from version 1.0.0 or 1.0.1 to 1.1.0 and above, you will need to create the metering API Key secret before upgrading:
  - Add the metering API Key in a text file `metering-api-key.txt` (Make sure there are no extra spaces or new lines in the text file)
  - Create secret for the metering API Key:
    ```
    kubectl create secret generic metering-api-key-secret --from-file=meteringApiKey=metering-api-key.txt -n <namespace>
    ```

# Version History
| Chart | Date        | Kubernetes Required | Image(s) Supported | Details |
| ----- | ----------- | ----------- | ------------------ | ------- |
| 2.0.1 | Nov 22, 2019 | >= 1.11             | ibmcom/voice-gateway-so:1.0.4.0, ibmcom/voice-gateway-mr:1.0.4.0, ibmcom/voice-gateway-codec-g729:1.0.4.0, ibmcom/voice-gateway-sms:1.0.4.0   | Minor updates, updated voice gateway images to 1.0.4.0                                                                |
| 2.0.0 | Sep 27, 2019 | >= 1.11             | ibmcom/voice-gateway-so:1.0.3.0, ibmcom/voice-gateway-mr:1.0.3.0, ibmcom/voice-gateway-codec-g729:1.0.3.0, ibmcom/voice-gateway-sms:1.0.3.0   | Added SMS Gateway microservice, added G729AB microservice, added support for Cloud Pak for Data with OpenShift platform, enhancements to the helm chart, updated voice gateway images to 1.0.3.0                                                                |
| 1.2.1 | Jun 28, 2019 | >= 1.11    | ibmcom/voice-gateway-so:1.0.2.0 and ibmcom/voice-gateway-mr:1.0.2.0 | Updated images to version 1.0.2.0, added support for monitoring metrics |
| 1.1.1 | Mar 29, 2019 | >=1.11    | ibmcom/voice-gateway-so:1.0.1.0 and ibmcom/voice-gateway-mr:1.0.1.0 | Updated images to version 1.0.1.0 |
| 1.1.0 | Mar 01, 2019 | >=1.11    | ibmcom/voice-gateway-so:1.0.0.8d and ibmcom/voice-gateway-mr:1.0.0.8d | Updated images to version 1.0.0.8d, added support for storing persistent logs, configuring SSL, mutual authentication and MRCPv2 |
| 1.0.1 | Oct 26, 2018 | >=1.11    | ibmcom/voice-gateway-so:1.0.0.7a and ibmcom/voice-gateway-mr:1.0.0.7a | Updated voice gateway images to 1.0.0.7a |
| 1.0.0 | Oct 08, 2018 | >=1.11    | ibmcom/voice-gateway-so:1.0.0.7 and ibmcom/voice-gateway-mr:1.0.0.7 | Initial release |