## What's new...
DataPower 2018.4.1.6 \
L2 certification \
Set admin password with adminUserSecret

## Fixes

## Prerequisites
None

## Breaking Changes

## Documentation
See README.md

## Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ------------ | ------- | ---------------------------------- | ---- | -------------------------------------------------------------- |
| 3.0.1 | Jun 28, 2019 | >=1.9.3 | ibmcom/datapower:2018.4.1.6.309660 | None | L2 cert, adminUserSecret |
| 3.0.0 | Apr 19, 2019 | >=1.9.3 | ibmcom/datapower:2018.4.1.4.307525 | Changed label scheme | 2018.4.1.4, pull secrets, health check, ssh permissions |
| 2.0.5 | Mar 08, 2019 | >=1.9.3 | ibmcom/datapower:2018.4.1.3.306649 | None | 2018.4.1.3, use secret for https keys/certs, ILMT annotations |
| 2.0.4 | Feb 08, 2019 | >=1.9.3 | ibmcom/datapower:2018.4.1.2:306098 | None | Continuous delivery update for 2018.4.1.2 FixPack |
| 2.0.3 | Dec 14, 2018 | >=1.9.3 | ibmcom/datapower:2018.4.1.1:305192 | None | DataPower ICP refresh for 2018.4.1.1. Contains updates to align with ICP standards |
| 2.0.2 | Jul 22, 2018 | >=1.9.3 | ibmcom/datapower:7.7.1.1.300826 | None | Add required identification annotations.  |
| 2.0.1 | Jul 16, 2018 | >=1.9.3 | ibmcom/datapower:7.7.1.1.300826 | None | Add Prometheus metrics monitoring support via the SNMP Exporter. |
| 2.0.0 | Apr 27, 2018 | >=1.9.3 | ibmcom/datapower:7.7.0.2.298364 | None  |v2.0.0 Release of the ibm-datapower-prod Chart version 2.0.0. Updated DataPower image to 7.7.0.2.298364. Added RESTProxy pattern. Removed webApplicationProxy pattern. Made certificates optional |
| 1.0.4 | Jan 15, 2018 | >=1.9.3 | ibmcom/datapower:7.6.0.4.294196 | None | Update DataPower image to 7.6.0.4.294196 |
