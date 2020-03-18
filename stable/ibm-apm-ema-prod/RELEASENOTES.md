# Breaking Changes
1.API query performance improvement. 
2.Update related helm charts for deployment.
3.Add error handler in crawler when get tenant failed.

# What’s new...

Deploy a single instance of the Equipment Maintenance Assistant On-Premises on on Red Hat OpenShift.


# Fixes
1.Fix listing data issue caused by couchdb query return limit to 25 records by default.
2.Fix monitor issue related to external api availability prom metric.
3.Fix nodejs express default timeout(2min) issue, increase to 10min, configurable

# Prerequisites
1. Red Hat OpenShift 3.11
2. Kubernetes 1.11 or later
3. Helm 2.9.1 or later

# Documentation
For additional instructions go to https://www.ibm.com/support/knowledgecenter/en/SSEMKY/com.ibm.ei.doc/welcome.html.

# Version History

| Chart | Date | Kubernetes Required | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- |
| 1.1.0+hotfix.1 | Jan 17, 2020 | >=1.11 | fix some bugs and improve perfomance |  |
| 1.1.0 | Dec 6, 2019 | >=1.11 | Add and remove some charts |  |
| 1.0.0 | Oct 10, 2019 | >=1.11 | None | New product release |
