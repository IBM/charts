# Breaking Changes

None

# What's new

This is the first edition of IBM Business Automation Application Engine.

# Fixes

None

# Prerequisites

See README.md

# Documentation

See README.md

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| --- | --- | --- | --- | --- | --- |
| v1.0.0 | Sep 2019 | >=v1.11.0 | dba-etcd:19.0.2 solution-server:19.0.2 dba-keytool-initcontainer:19.0.2 dba-umsregistration-initjob:19.0.2 dba-dbcompatibility-initcontainer:19.0.2 solution-server-helmjob-db:19.0.2 | None | Initial chart of Business Automation Application Engine |

# Limitation

The solution server image only trusts CA due to the limitation of the Node.js server. For example, if external UMS is used and signed with another root CA, you must add the root CA as trusted instead of the UMS certificate.

  * The certificate can be self-signed, or signed by a well-known CA.
  * If you're using a depth zero self-signed certificate, it must be listed as a trusted certificate.
  * If you're using a certificate signed by a self-signed CA, the self-signed CA must be in the trusted list. Using a leaf certificate in the trusted list is not supported.
