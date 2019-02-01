# Breaking Changes
* None

# What’s new in Chart Version 1.1.0

With IBM App Connect Enterprise Chart for Kubernetes environments, the following new features
are available:

* Secrets are managed outside of helm for increased security
* Updated to use the App Connect Enterprise v11 FP3 runtime

# Fixes
* REST APIs now show the correct host and port

# Prerequisites
1. IBM Cloud Private version 3.1.1

# Documentation
For more information go to https://www.ibm.com/support/knowledgecenter/en/SSTTDS_11.0.0/com.ibm.etools.mft.doc/bz91410_.htm

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------------- | ------------------ | ---------------- | ------- |
| 1.1.0 | Jan 31, 2019  | >=v1.11.1  | ibmcom/ace-dev:11.0.0.3, ibmcom/ace-mq-dev:11.0.0.3, | 11.0.0.3 FP Update |
| 1.0.0 | Nov 14, 2018 | >=v1.11.1   | ibmcom/ace-dev:11.0.0.2, ibmcom/ace-mq-dev:11.0.0.2, | Initial Chart |
