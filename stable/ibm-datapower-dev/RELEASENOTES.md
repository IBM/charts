## What's new...
DataPower 2018.4.1.4 \
Improved healthcheck no longer relies on backend. \
Enabling SSH raises permissions to work properly.

## Fixes
Pull secrets now work.
SSH now works.

## Prerequisites
None

## Breaking Changes
Helm upgrade from 2.0.5 to 3.0.0 broken due to new label scheme. To upgrade:
- Redeploy with identical values.yaml.
- Shift downstream services to point at new ibm-datapower-dev service.
- Deprecate 2.0.5 deployment.
- Ultimately delete 2.0.5 deployment after move is complete.

## Documentation
See README.md

## Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ------------ | ------- | ---------------------------------- | ---- | -------------------------------------------------------------- |
| 3.0.0 | Apr 19, 2019 | >=1.9.3 | ibmcom/datapower:2018.4.1.4.307525 | Changed label scheme | 2018.4.1.4, pull secrets, health check, ssh permissions |
| 2.0.5 | Mar 08, 2019 | >=1.9.3 | ibmcom/datapower:2018.4.1.3.306649 | None | 2018.4.1.3, use secret for https keys/certs, ILMT annotations |
| 2.0.4 | Feb 08, 2019 | >=1.9.3 | ibmcom/datapower:2018.4.1.2:306098 | None | Continuous delivery update for 2018.4.1.2 FixPack |
| 2.0.3 | Dec 14, 2018 | >=1.9.3 | ibmcom/datapower:2018.4.1.1:305192 | None | DataPower ICP refresh for 2018.4.1.1. Contains updates to align with ICP standards |
| 2.0.2 | Jul 22, 2018 | >=1.9.3 | ibmcom/datapower:7.7.1.1.300826 | None | Add required identification annotations.  |
| 2.0.1 | Jul 16, 2018 | >=1.9.3 | ibmcom/datapower:7.7.1.1.300826 | None | Add Prometheus metrics monitoring support via the SNMP Exporter. |
| 2.0.0 | Apr 27, 2018 | >=1.9.3 | ibmcom/datapower:7.7.0.2.298364 | None  |v2.0.0 Release of the ibm-datapower-prod Chart version 2.0.0. Updated DataPower image to 7.7.0.2.298364. Added RESTProxy pattern. Removed webApplicationProxy pattern. Made certificates optional |
| 1.0.4 | Jan 15, 2018 | >=1.9.3 | ibmcom/datapower:7.6.0.4.294196 | None | Update DataPower image to 7.6.0.4.294196 |
