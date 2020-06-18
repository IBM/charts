## What's new...
2.3.0
  Chart now supported on Red Hat OpenShift

2.2.5
  runTest.sh fixed to make executable.

2.2.4
  Update image paths pointing to new images with red hat cve fixes

2.2.3
  Contains new files for cloud pak certification
  Updated security contexts
  Add preinstall and application tests
  cv-linter fixes

2.2.2
  ibm-sch subchart updated to version 1.2.10

1.0.2
  Changed names of role,role binding and service account.
    Notice that if the helm deployment is updated from prior version and you
       either enabled tls or authentication and do not provide the auth.existingRootSecret
    Then the `helm delete --tls` command will hang for 3 minutes.

1.0.1
  Clean-up. Removed helper templates that were not used.

1.0.0
  Labels of the components has changed to follow the new labeling standard.



## Fixes
TLS certificate auto-generation.

## Prerequisites
TODO

## Version History


| Chart | Date              | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ----------------- | --------------------------- | ---------------- | ------- |
| 2.3.10| March 11, 2020    | >=1.9                       | None             | New configuration values, bug fixes |
| 2.3.9 | February 21, 2020 | >=1.9                       | None             | New configuration values |
| 2.3.8 | January 16, 2019  | >=1.9                       | None             | Image updates, new configuration values |
| 2.3.7 | December 23, 2019 | >=1.9                       | None             | Add auto compaction configurations |
| 2.3.6 | November 7, 2019  | >=1.9                       | None             | Bug fixes |
| 2.3.5 | October 31, 2019  | >=1.9                       | None             | Support for CP4D and update sch version |
| 2.3.4 | October 22, 2019  | >=1.9                       | None             | Bug fixes |
| 2.3.2 | August 14, 2019   | >=1.9                       | None             | Update chart to new images with recent CVE fixes
| 2.3.1 | August 5, 2019    | >=1.9                       | None             | Authentication bug fixed
| 2.3.0 | August 1, 2019    | >=1.9                       | None             | Adding OpenShift support
| 2.2.6 | July 8th, 2019    | >=1.9                       | None             | Updates to application test
| 2.2.5 | June 17, 2019     | >=1.9                       | None             | Executable application test
| 2.2.4 | June 14, 2019     | >=1.9                       | None             | New Images with Red Hat CVE fixes
| 2.2.3 | June 11, 2019     | >=1.9                       | None             | Final revisions for cloud pak certification
| 2.2.2 | May 30, 2019      | >=1.9                       | None             | Update to sch version 1.2.10
| 2.0.3 | April 10, 2019    | >= 1.9                      | None             | RHEL support
| 2.0.1 | January 23, 2019  | >= 1.9                      | None             | Update sch subchart to 1.2.6
| 2.0.0 | December 13, 2018 | >= 1.9                      | None             | Fix auth enable
| 1.0.2 | November 22, 2018 | >= 1.9                      | None             | Renamed automatically created role,role binding and service account to include chart name.
| 1.0.1 | November 08, 2018 | >= 1.9                      | None             | Chart clean-up.
| 1.0.0 | November 07, 2018 | >= 1.9                      | Labels changed   | This version is not upgradable from previous versions.
| 0.2.3 | October 30, 2018  | >= 1.9                      | None             | Initial version |
