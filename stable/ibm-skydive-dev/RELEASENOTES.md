# What's new in Chart Version 1.1.1

* Expose ports of Skydive; ElasticSearch; ETCD 
* ICP: support docker image repo skydive/skydive 
* IKS: add runC container runtime probe 
* IKS: fix k8s on IKS with default RBAC
* IKS versions 1.11, 1.12, 1.13 are supported

## Breaking Changes

None

# What's new in Chart Version 1.1.0

* New skydive image 0.21.0
* PowerPC 64-bit LE support
* s390x zLinux architecture support

## Breaking Changes

None

# What's new in Chart Version 1.0.3

* Add support for ICP managed glusterfs

# What's new in Chart Version 1.0.2

* Minor fixes to README file
* App version updated to 0.18 

# What's new in Chart Version 1.0.1

* Light theme 
* Persistent storage  
* Filtered Kubernetes exploration
* App version updated to 0.17.1 

# Fixes
* Persistent Volume on GlusterFS


# Prerequisites
* IBM Cloud Private version 2.1.0.3

# Documentation
* [Skydive documentation](http://skydive.network/documentation/)


### - Skydive change log is available @ [Skydive changelog](https://github.com/skydive-project/skydive/blob/master/CHANGELOG.md)

# Version History

| Chart | Date | ICP Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
| 1.1.1 | Mar 29, 2019| >= 2.1.0.3 | ibmcom/skydive:0.21.0 | None | +ppc64le, +s390x |
| 1.1.0 | Jan 24, 2019| >= 2.1.0.3 | ibmcom/skydive:0.21.0 | None | +ppc64le, +s390x |
| 1.0.3 | Jul 23, 2018| >=2.1.0.3 | ibmcom/skydive:0.18 | None | |
| 1.0.2 | Jun 17, 2018| >=2.1.0.1 | ibmcom/skydive:0.18 | None | |
| 1.0.1 | Apr 22, 2018| >=2.1.0.1 | ibmcom/skydive:0.17.1 | None | |
| 1.0.0 | Feb 1, 2018| >=2.1.0.1 | ibmcom/skydive:0.15 | None | |
