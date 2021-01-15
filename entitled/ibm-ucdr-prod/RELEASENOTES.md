# What's new in Chart Version 3.1.1

* Support for UCD 7.1.1.1
* Default service type is no longer NodePort, now set to ClusterIP

## Breaking Changes
* Helm 3 is now used for deploying the UCD Agent Relay.  Direct upgrade for UCD Agent Relay deployed via Helm 2 is not supported. Please use the Helm 2to3 Plugin for to perform migration (https://github.com/helm/helm-2to3/blob/master/README.md)

# Fixes

# Prerequisites
* See README for prerequisites

# Documentation
* See README for documentation

# Version History

| Chart | Date | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------------ | ---------------- | ------- | 
| 3.1.1 | November 24th, 2020 | ucdr: sha256:5bb36c060520dab8d639539a305525caffcba4a9c7e34c60110269a32bcecd33 | None | Version 7.1.1.1  |
| 3.1.0 | November 3rd, 2020 | ucdr: sha256:f498ca39413807cdef9d74422cd0e6dcc2f63be4d5434c486f1acad3e64e7e4b | None | Version 7.1.1.0  |
| 3.0.4 | September 15th, 2020 | ucdr: 7.1.0.3.1069218 | None | Version 7.1.0.3  |
| 3.0.3 | August 18th, 2020 | ucdr: 7.1.0.2.1063225 | None | Version 7.1.0.2  |
| 3.0.2 | July 21st, 2020 | ucdr: 7.1.0.1.ifix01.1062130 | None | Version 7.1.0.1.ifix01  |
| 3.0.1 | June 23rd, 2020 | ucdr: 7.1.0.0.1058690 | None | Version 7.1.0.0  |
| 2.0.9 | March 24th, 2020 | ucdr: 7.0.5.2.1050384 | None | Version 7.0.5.2 |
| 2.0.8 | February 11th, 2020 | ucdr: 7.0.5.1.1044461 | None | Version 7.0.5.1 |
| 2.0.7 | January 14th, 2020 | ucdr: 7.0.5.0.1041488 | None | Version 7.0.5.0  |
| 2.0.6 | December 4th, 2019| ucdr: 7.0.4.2.1038002 | None | Version 7.0.4.2  |
| 2.0.5 | November 5th, 2019| ucdr: 7.0.4.1.1036185 | None | Support for latest UCD Server Release |
| 2.0.0 | October 1st, 2019 | ucdr: 7.0.4.0.1034011 | None | Support for latest UCD Server Release |
| 1.0.8 | September 3rd, 2019 | ucdr: 7.0.3.3.1031820 | None | Support for latest UCD Server Release |
| 1.0.7 | August 6th, 2019 | ucdr: 7.0.3.2.1028848 | None | Support for latest UCD Server Release |
| 1.0.6 | July 2nd, 2019 | ucdr: 7.0.3.1.1026877 | None | Support for latest UCD Server Release |
| 1.0.5 | June 11th, 2019 | ucdr: 7.0.3.0.1025086 | None | Support for latest UCD Server Release |
| 1.0.4 | May 7th, 2019 | ucdr: 7.0.2.3.1021487 | None | Support for latest UCD Server Release |
| 1.0.3 | March 12th, 2019| ucdr: 7.0.2.2.1017795 | None | Initial Release  |
