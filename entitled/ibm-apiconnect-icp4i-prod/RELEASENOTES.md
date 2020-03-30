## What's new...
This release contains IBM API Connect v2018.4.1.10.

For more details, refer to the [API Connect v2018 release notes](https://www.ibm.com/support/knowledgecenter/en/SSMNED_2018/com.ibm.apic.overview.doc/overview_whatsnew.html).

## Documentation
For detailed installation and upgrade instructions, refer to the [API Connect Knowledge Center](https://www.ibm.com/support/knowledgecenter/en/SSMNED_2018/com.ibm.apic.install.doc/installing_icp.html).

## Fixes

## Breaking Changes

1. Credentials for backup and restore must be configured after installation or upgrade. Refer to the API Connect Knowledge Center for further details.

## Prerequisites

1. IBM Cloud Private version 3.2.0.1906 fix pack or later or IBM Common Services 3.2.4

2. IBM platform core services: `auth-idp`, `catalog-ui`, `helm-api`, `icp-management-ingress`, `nginx-ingress`, `platform-ui`, `tiller`

3. Kubernetes version >= 1.10.0

4. Tiller version >= 2.9.1

## Version History

| Chart | Date                | Kubernetes Required | Breaking Changes                                                                    | Details                                                           |
| ----- | ------------------- | ------------------- | ----------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| 1.0.5 | March 31,2020       | >=1.10.0            |                                                                                     | API Connect v2018.4.1.10                                          |
| 1.0.4 | November 30, 2019   | >=1.10.0            |                                                                                     | API Connect v2018.4.1.8-iFix1.0                                   |
| 1.0.3 | October 4, 2019     | >=1.10.0            |                                                                                     | API Connect v2018.4.1.7-iFix3.0; Operations Dashboard integration |
| 1.0.2 | September 27, 2019  | >=1.10.0            |                                                                                     | API Connect v2018.4.1.7-iFix2.0                                   |
| 1.0.1 | August 16, 2019     | >=1.10.0            |                                                                                     | API Connect v2018.4.1.7                                           |
| 1.0.0 | June 30, 2019       | >=1.10.0            | Credentials must be configured manually; upgrade from former chart is not supported | API Connect v2018.4.1.6                                           |