# What's new in IBM Security Access Manager Chart v1.1.0

The IBM Security Access Manager Chart provides the following new features:

* The ability to deploy an IBM Security Access Manager environment which can be used to simplify your users' access while more securely adopting web, mobile and cloud technologies.

# Fixes
Information on the fixes contained within a particular version of the chart can be found in the official release notes for IBM Security Access Manager.

# Prerequisites
No change.

# Breaking Changes

* The docker images for ISAM 9.0.7.0 have been updated so that they no longer require the container to be run as the root user;
* The chart has been modified so that you can now specify the name of the WRP instances to be created, rather than just specifying the number of instances to create;
* You now have the option of specifying a server certificate when deploying the isam-postgresql service;


# Documentation
For detailed documentation instructions go to [https://www.ibm.com/support/knowledgecenter/en/SSPREK/welcome.html](https://www.ibm.com/support/knowledgecenter/en/SSPREK/welcome.html).


# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details
| ----- | ---- | ------------------- | ------------------ | ---------------- | -------
| 1.1.0 | June 2019 | >= 1.11.x | store/ibmcorp/isam:9.0.7.0; ibmcom/isam-postgresql:9.0.7.0 | None | The ISAM 9.0.7.0 docker image has been updated so that we no longer require the container to be run as root.
| 1.0.0 | February 2019 | >= 1.11.x | store/ibmcorp/isam:9.0.6.0; ibmcom/isam-postgresql:9.0.6.0 | None | Initial Chart

