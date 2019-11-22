## What's new 

1.5.0


* Postgres Image can be run as arbitrary UID and suports openshift restricted scc
* postgres version has been upgraded to 9.6.14

* CV lint fixes for 1.4.4


* Replaced old Helm test with new helm test

## Fixes
* CVE fixes on the images

## Prerequisites
* TODO

## Documentation

## Breaking Changes

* service account name values changes
* Affinities. Architecure based affinities

## Version History


| Chart | Date              | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ----------------- | --------------------------- | ---------------- | ------- |
| 1.1.6 | March  29, 2019   | >= 1.10                     | None             | Improved persistent storage configuration
| 1.2.0 | May 21, 2019   | >= 1.10                     |     Changed to UBI image and run as non root         |  Changed to UBI image and run as non root, Using SCH and cv lint fixes |
| 1.2.1 | May 21, 2019   | >= 1.10                     |        changed to UBI 7 image and set encoding format utf-8     |  changed to UBI 7 image and set encoding format utf-8| 
| 1.2.2 | May 22, 2019   | >= 1.10                     |            |  adding postgresql-contrib package | 
| 1.3.0 | May 31, 2019   | >= 1.12                     |            |  Satisfying CV Lint 1.4.1 | 
| 1.4.0 | June 13, 2019 | >=1.12 | service account name values changes,  Affinities. Architecure based affinities | Uses new images with cve fixes, Improvements for sub-charting |
| 1.5.0 | August 5, 2019 | >=1.11 |   |supports arbitrary uid and openshift restricted scc, postgres version has been upgraded to 9.6.14, cv lint fixes for 1.4.4, Replaced old Helm test with new helm test|
