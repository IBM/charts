# What's new in Chart Version 3.1.1

* Support for UCD 7.1.1.1
* Added support to specify password for keystores
* Persist entire var/log directory

## Breaking Changes
* Helm 3 is now used for deploying the UCD Agent.  Direct upgrade for UCD agent deployed via Helm 2 is not supported. Please use the Helm 2to3 Plugin for to perform migration (https://github.com/helm/helm-2to3/blob/master/README.md)

# Fixes/Updates

# Prerequisites
* See README for prerequisites

# Documentation
* See README for documentation

# Version History

| Chart | Date | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------------ | ---------------- | ------- | 
| 3.1.1 | Nov 24th, 2020 | ucda: sha256:8a3c5815cdfc7852a74fb62ba5c4a954246a17a6947cefc561f29de2181081ae | None | Version 7.1.1.1 |
| 3.1.0 | Nov 3rd, 2020 | ucda: sha256:6b34cf4a0ce9b2f6398ea2bb41e8d614bba7befe8f5cbdce6d06d78c9207042d | None | Version 7.1.1.0 |
| 3.0.4 | September 15th, 2020 | ucda: 7.1.0.3.1069281 | None | Version 7.1.0.3 |
| 3.0.3 | August 18th, 2020 | ucda: 7.1.0.2.1063225 | None | Version 7.1.0.2 |
| 3.0.2 | July 21st, 2020 | ucda: 7.1.0.1.ifix01.1062130 | None | Version 7.1.0.1.ifix01 |
| 3.0.1 | June 23rd, 2020 | ucda: 7.1.0.0.1058690 | None | Version 7.1.0.0 |
| 2.1.9 | March 24th, 2020 | ucda: 7.0.5.2.1050384 | None | Version 7.0.5.2 added user specified PVC containing additional utilties programs the agent can execute |
| 2.1.8 | February 11th, 2020 | ucda: 7.0.5.1.1044461 | None | Version 7.0.5.1 added oc and git CLI utilities |
| 2.1.7 | January 14th, 2020 | ucda: 7.0.5.0.1041488 | None | Version 7.0.5.0  |
| 2.1.6 | December 4th, 2019| ucda: 7.0.4.2.1038002 | None | Version 7.0.4.2  |
| 2.1.5 | November 5th, 2019| ucda: 7.0.4.1.1036185 | None | Support for latest UCD Server Release  |
| 2.1.0 | October 1st, 2019 | ucda: 7.0.4.0.1034011 | None | Support for latest UCD Server Release |
| 2.0.0 | September 3rd, 2019 | ucda: 7.0.3.3.1031820 | None | Support for latest UCD Server Release |
| 1.0.8 | August 6th, 2019 | ucda: 7.0.3.2.1028848 | None | Support for latest UCD Server Release |
| 1.0.7 | July 2nd, 2019 | ucda: 7.0.3.1.1026877 | None | Support for latest UCD Server Release |
| 1.0.6 | June 11th, 2019 | ucda: 7.0.3.0.1025086 | None | Support for latest UCD Server Release |
| 1.0.5 | May 7th, 2019 | ucda: 7.0.2.3.1021487 | None | Support for latest UCD Server Release |
| 1.0.4 | March 12th, 2019| ucda: 7.0.2.2.1017795 | None | Initial Release  |
