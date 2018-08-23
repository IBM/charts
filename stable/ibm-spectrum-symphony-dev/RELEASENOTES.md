# Breaking Changes
None for chart version 1.0.0

# What’s new in Chart Version 1.0.0

With IBM Spectrum Symphony 7.2.1 on IBM Cloud Private 2.1.0.3, you can take advantage of the following capabilities: 
* An Apache Derby demonstration database is enabled by default to store reporting data. Reports enable you to analyze and improve the performance of your cluster, to perform capacity planning, and for troubleshooting. While a commercial database is required for reports in a production cluster, the derbydb database provides a ready-to-use option for testing purposes.
* A client deployment for SSH access to the cluster - while enabled by default - is optional. The standard configuration deploys a single client and starts the SSH daemon by default on port 2222. 
* Key system processes run as the built-in cluster administrator. As a result, access to the client host requires cluster administrator credentials (user name 'egoadmin', default password 'Admin'). Optionally, you can enable a random password to be generated for the 'egoadmin' user on each host during cluster startup and printed to the container logs.  
* Component logs can be saved to a shared volume mount (/share/logs/) so that logs can be shared by containers across multiple worker nodes.

# Prerequisites
IBM Cloud Private version 2.1.0.2 or higher.

# Fixes
None for chart version 1.0.0

# Documentation
For detailed instructions, go to the [online IBM Knowledge Center](https://www.ibm.com/support/knowledgecenter/SSZUMP_7.2.1/install_grid_sym/symphony_icp.html).

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
| 1.0.0 | Aug 10, 2018 | >=1.9.1 | ibmcom/spectrum-symphony:latest | None | Release with Symphony 7.2.1  |

