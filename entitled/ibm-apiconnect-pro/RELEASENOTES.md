## What's new...
This release has been updated to contain IBM API Connect v2018.4.1.7.

This chart now supports Red Hat OpenShift 3.11.

For more details, refer to the [API Connect v2018 release notes](https://www.ibm.com/support/knowledgecenter/en/SSMNED_2018/com.ibm.apic.overview.doc/overview_whatsnew.html).

## Documentation
For detailed installation and upgrade instructions, refer to the [API Connect Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSMNED_2018/com.ibm.apic.overview.doc/api_management_overview.html).

## Fixes

## Breaking Changes

1. Upgrading from a release prior to v2018.4.1.2 requires a new installation of the analytics subsystem.

   Run `helm delete --purge <analytics subsystem release> --tls` after upgrading this chart to allow the apiconnect-operator to install the new release.

   To keep existing data, an analytics backup should be taken before the upgrade. The backup can be restored after the subsystem is reinstalled. Refer to the API Connect Knowledge Center for the backup and restore procedures.

2. Credentials for backup and restore must be configured after installation or upgrade. Refer to the API Connect Knowledge Center for further details.

## Prerequisites

1. IBM Cloud Private version 3.1.1 or later

2. IBM platform core services: `auth-idp`, `catalog-ui`, `helm-api`, `icp-management-ingress`, `nginx-ingress`, `platform-ui`, `tiller`

3. Kubernetes version >= 1.10.0

4. Tiller version >= 2.9.1

## Version History

| Chart | Date            | Kubernetes Required | Breaking Changes                                               | Details                                         |
| ----- | --------------- | ------------------- | -------------------------------------------------------------- | ----------------------------------------------- |
| 2.2.3 | August 16, 2019 | >=1.10.0            |                                                                | API Connect v2018.4.1.7; OpenShift 3.11 support |
| 2.2.2 | June 21, 2019   | >=1.11.5            |                                                                | API Connect v2018.4.1.6                         |
| 2.2.1 | Apr 30, 2019    | >=1.11.5            |                                                                | API Connect v2018.4.1.5                         |
| 2.2.0 | Mar 28, 2019    | >=1.11.5            | Credentials for backup and restore must be configured manually | API Connect v2018.4.1.4                         |
| 2.1.3 | Feb 28, 2019    | >=1.10.0            |                                                                | API Connect v2018.4.1.3                         |
| 2.1.2 | Jan 31, 2019    | >=1.10.0            | Analytics subsystem cannot be upgraded from previous release   | API Connect v2018.4.1.2                         |
| 2.1.1 | Dec 7, 2018     | >=1.10.0            |                                                                | API Connect v2018.4.1.1                         |
| 2.1.0 | Nov 15, 2018    | >=1.10.0            |                                                                | API Connect v2018.4.1.0                         |
