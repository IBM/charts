# What's new in Chart Version 7.1.1

* Support for UCD 7.1.1.1
* Default service type is no longer NodePort, now set to ClusterIP

## Breaking Changes
* Rollback to previous versions of UCD server is not supported without manual intervention because database schema changes are present.  Manual steps can be found [here](https://www.urbancode.com/resource/running-urbancode-deploy-as-a-container-with-kubernetes/#upgrading-ucd-chart).
* Helm 3 is now used for deploying the UCD Server.  Direct upgrade for UCD server deployed via Helm 2 is not supported. Please use the Helm 2to3 Plugin for to perform migration (https://github.com/helm/helm-2to3/blob/master/README.md)

# Fixes

# Prerequisites
* See README for prerequisites

# Version History

| Chart | Date | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------------ | ---------------- | ------- |
| 7.1.1 | November 24th, 2020 | ucds: sha256:73130abeae856d2c3d08320d21ef3b677809419136c5880625206579ddb4af2c | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.1.1.1 |
| 7.1.0 | November 3rd, 2020 | ucds: sha256:4f1fdc20a2cb4eb789188428d89652681a6299beb0b665ff910182dc82c5ee60 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.1.1.0 |
| 7.0.4 | September 15th, 2020 | ucds: 7.1.0.3.1069281 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.1.0.3 |
| 7.0.3 | August 18th, 2020 | ucds: 7.1.0.2.1063225 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.1.0.2 |
| 7.0.2 | July 21st, 2020 | ucds: 7.1.0.1.ifix01.1062130 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.1.0.1.ifix01 |
| 7.0.1 | June 23rd, 2020 | ucds: 7.1.0.0.1058690 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.1.0.0 |
| 6.0.8 | March 24th, 2020 | ucds: 7.0.5.2.1050384 | Rollback of previous versions of UCD server not supported | Support for UCD Server 7.0.5.2 |
| 6.0.7 | February 11th, 2020 | ucds: 7.0.5.1.1044461 | Rollback of previous versions of UCD server not supported | Support for UCD Server 7.0.5.1 |
| 6.0.6 | January 14th, 2020 | ucds: 7.0.5.0.1041488 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.0.5.0 |
| 6.0.5 | December 4th, 2019 | ucds: 7.0.4.2.1038002 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.0.4.2 |
| 6.0.4 | November 5th, 2019 | ucds: 7.0.4.1.1036185 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.0.4.1 |
| 5.0.3 | October 1st, 2019 | ucds: 7.0.4.0.1034011 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.0.4.0 |
| 5.0.1 | September 3rd, 2019 | ucds: 7.0.3.3.1031820 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.0.3.3 |
| 5.0.0 | August 6th, 2019 | ucds: 7.0.3.2.1028848 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.0.3.2 |
| 4.1.2 | July 2nd, 2019 | ucds: 7.0.3.1.1026877 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.0.3.1 |
| 4.1.1 | June 11th, 2019 | ucds: 7.0.3.0.1025086 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.0.3.0 |
| 4.0.1 | May 7th, 2019 | ucds: 7.0.2.3.1021487 | Rollback to previous versions of UCD server not supported | Support for UCD Server 7.0.2.3 |
| 3.1.2 | February 5th, 2019 | ucds: 7.0.2.0.1011801, 7.0.1.2.1008304, 7.0.1.0.997822 | None | Support for UCD 7.0.2.0 |
| 3.1.1 | December 18th, 2018 | ucds: 7.0.1.2.1008304, 7.0.1.0.997822 | None | Run as non-root, allow non-secure connections to UCD Server, defect fixes |
| 3.0.0 | September 25, 2018 | ucds: 7.0.1.0.997822, 7.0.0.0.982083, 6.2.7.1.ifix02.973221 | None | Add support for HA clusters |
| 2.0.0 | June 19, 2018| ucds: 7.0.0.0.982083, 6.2.7.1.ifix02.973221 | None | Adds support for persisting log files, Adds support for Power LE platforms (UrbanCode Deploy 7.0.0.0 and later), Enables port 7919 for web agent communication (UrbanCode Deploy 7.0.0.0 and later)   |
| 1.0.0 | March 18, 2018| ucds: 6.2.7.1.ifix02.973221 | None | Initial Release  |

## Documentation

-   UrbanCode Deploy Installing the server in a Kubernetes cluster [page](https://www.ibm.com/support/knowledgecenter/en/SS4GSP_7.1.0/com.ibm.udeploy.install.doc/topics/docker_cloud_over.html)
