# What's new..
- Integration with CP4D 3.5.0

### Deprecated
- N/A

### Breaking Changes
- The flag for AirGap is now set to false

# Fixes
- N/A

# Prerequisites
IBM Cloud Pak version 3.5.0

# Documentation
See README.md

# Version History
| Chart               | Date                   | Kubernetes Required | Breaking Changes                                                | Details                                                  |
| ------------------- | ---------------------- | ------------------- | --------------------------------------------------------------- | -------------------------------------------------------- |
| [3.5.0](#350)       | Sept. 27, 2020         | >=1.11.0            |                                                                 | Integration with CP4D 3.5.0                              |
| [3.0.0](#300)       | Sept. 27, 2019         | >=1.11.0            |                                                                 | Integration with CP4D 3.0.0                              |
| [1.13.28](#11328)   | Sept. 27, 2019         | >=1.11.0            |                                                                 | Integration with WSL                                     |
| [1.13.20](#11320)   | Sept. 10, 2019         | >=1.11.0            |                                                                 | Security upgrades for running on IBM Cloud Pak 2.5.0.0   |
| [0.13.19](#01319)   | Aug. 08, 2019          | >=1.11.0            | CDN pod and all associated endpoints have been removed          | Integration of redis charts, security upgrade            |
| [0.13.14](#01314)   | May 05, 2019           | >=1.10.0            |                                                                 | UBI refresh                                              |
| [0.13.11](#01311)   | Mar. 03, 2019          | >=1.10.0            |                                                                 | Removal of mongodb dependency and bug fixes              |
| [0.13.7](#0137)     | Feb. 20, 2019          | >=1.10.0            |                                                                 | Upgrade dependent mongodb charts to 4.0.6                |
| [0.13.6](#0136)     | Feb. 15, 2019          | >=1.10.0            |                                                                 | Helm annotations and vulnerability fixes                 |
| [0.13.4](#0134)     | Nov. 28, 2019          | >=1.10.0            |                                                                 | Image refresh and bug fixes                              |

## 3.5.0
### Notable features
- Integration with CP4D 3.5.0

## 3.0.0
### Notable features
- Integration with CP4D 3.0.0
- Archtecture changes to CDE backend and proxy images
- UI update

## 1.13.28
### Notable Features
- Integration with WSL

### Deprecated
- Ingress routes removed
- Removed daas-server service
- Changed daas-proxy service type to ClusterIP from NodePort
- Remove custom role, role binding, and service account creation
- Removed redundent cognos.json item from zen module config map

### Breaking Changes
- CDE now depends on WSL / WSL common-assembly to be installed prior CDE install

## 1.13.20
### Notable Features
- Added ability to provide tls certificates for communicating with the proxy
- Redis has been integrated as another deployment
- Pods run as non-root

# Fixes
- Removed unused CDN charts

## 0.13.19
### Notable Features
- Added https endpoint to all pods
- On all containers, base image refresh
- Removal of CDN pod from being deployed, charts still remain
- Removed dependency on redis charts

### Deprecated
- Non-https ports are deprecated

### Breaking Changes
- The CDN pod and all associated endpoints have been removed

### Notable Fixes
- Fix to certificates not being installed on default namespace

## 0.13.14
### Notable Features
- Change redis container to use UBI image as the base image
- Change proxy container to use UBI image as the base image
- Change server container to use UBI image as the base image
- Changed CDN base image to UBI based image
- Moved base chart version from 1.2.6 to 1.2.7

### Notable fixes
- Added limits and request for CPU and memory resources for all containers
- Fix to patch script for installing on non-zen namespace
- Serviceability fixes
- Fix to performance issues with loading 3rd party content

## 0.13.11
### Notable Features
- Removed mongodb pod

### Notable Fixes
- Fix to bug with redis pod running on a non-amd64 node
- Fix to bug with dde-proxy pod running on a non-amd64 node

## 0.13.7
### Notable Features
- Update mongodb charts to 4.0.6

## 0.13.6
### Notable Features
- Annotated helm charts

### Notable Fixes
- Vulnerablility fixes

## 0.13.4
### Notable Fixes
- Refreshed server image with the following fixes

```
Filter drop down from filter dock closes instantly when query service throws an error

The same data source name can be added multiple times to a dashboard

Dashboarding - Map box requires internet access - remove that dependancy

Dashboarding - mapbox empty
```

- Added patch script for authorization information to zen module
