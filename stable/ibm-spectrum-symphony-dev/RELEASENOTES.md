# Breaking Changes
None - Upgrading or rolling back IBM Spectrum Symphony Helm release versions is not supported.

# What’s new in Chart Version 3.0.0

With IBM Spectrum Symphony 7.3.0.0 on RedHat Openshift 4.2 or higher, the following new features are available:
* Communication secured with TLS
* There is no SSH access to the cluster
* There is no client deployment anymore
* Service Account Name could be specified

# Documentation

# Fixes

# Prerequisites
RedHat Openshift 4.2 or higher.

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
|3.0.0 | Mar 6, 2020 | >=1.11.0 |  | None | See 'What's New' section. |
|2.0.0 | Mar 22, 2019 | >=1.9.1 | ibmcom/spectrum-symphony:7.2.1.1 | None | See 'What's New' section. |
|1.0.0 	| Aug 10, 2018 	| >=1.9.1 | ibmcom/spectrum-symphony:latest |	None | Changed key system processes to run as cluster admin, made client deployment optional,  added support for Derby DB and logs on shared mount.|

