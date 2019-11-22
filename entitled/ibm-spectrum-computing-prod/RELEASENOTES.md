# What’s new in IBM Spectrum Computing - Cloud Pak for IBM Cloud Private

With IBM Spectrum Computing the following new features are available for jobs:
1. Pod Queues    - Multiple queues with different capabilities are available
2. Pod Priority  - Jobs can have priority.  High priority jobs will be given preference
3. Fairshare     - Policies that allow users and groups to fairly share the resources
4. Parallel Jobs - Jobs that need to run across a large number of pods in parallel
5. Advance Reservation - Reserve the resources in advance of scheduling
6. Pod Workflows - Pods can have dependencies on other completed job pods

Other capabilities that can be enabled are:
1. GPU Zero configuration
2. GPU Mode switching
3. GPU Scheduling

# Prerequisites
1. IBM Cloud Private version 3.1.1 or later
2. A persistant volume
3. (Optional) Nvidia docker

# Fixes

# Breaking Changes
It is not possible to upgrade from the Tech Preview to this edition.  Some of the job annotations have changed.  The old 
chart should be deleted, and replaces with this one.
It is expected that upgrading from the current edition to the next edition will also require removal of the current jobs before starting the upgrade otherwise running job state could be lost.

# Encryption
No encryption of the data at rest or in motion is provided by this chart.  It is up to the administrator to configure storage encryption and IPSEC to secure the data.
 
# Documentation
Additional documentation and examples are available [here.](https://github.com/IBMSpectrumComputing/lsf-kubernetes)

# Version History
| Chart  | Date          | K8s Required | Image(s) Supported | Details      |
| ------ | ------------- | ------------ | ------------------ | ------------ |
| 0.2.0  | June 30, 2019 | >= 1.11.0    | lsf-master-amd64:10.1.0.7m31, lsf-master-ppc64le:10.1.0.7m31, lsf-comp-amd64:10.1.0.7m31, lsf-comp-ppc64le:10.1.0.7m31 | Tech Preview 2 |
| 0.1.0  | Mar 31, 2019  | >= 1.11.1    | lsf-master-amd64:10.2, lsf-master-ppc64le:10.2, lsf-comp-amd64:10.2, lsf-comp-ppc64le:10.2  | Tech Preview |
