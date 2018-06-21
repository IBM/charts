# What's new in Chart Version 1.0.0

The IBM PowerVC FlexVolume Driver 1.0.0 is the initial release and provides the following features:

* A Kubernetes FlexVolume Driver and Provisioner for dynamically creating and attaching volumes through PowerVC and mounting volumes for containers
* A pre-defined Kubernetes storage class to use the IBM PowerVC FlexVolume driver as the default provisioner

# Prerequisites
* IBM Cloud Private 2.1.0.2 or later (or Kubernetes 1.9.1 or later)
* PowerVC 1.4.1 or later (PowerVC 1.4.0 may be used if using Fibre Channel attached storage)

# Fixes

# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details |
| ----- | ---- | ------------ | ------------------ | ---------------- | ------- | 
| 1.0.0 | June 2018| >=1.9.1 | ibmcom/ibm-powervc-k8s-volume-flex:1.0.0 ibmcom/ibm-powervc-k8s-volume-provisioner:1.0.0 | None | Initial Release |
