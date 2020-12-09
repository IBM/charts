# Release Notes

## What's new in Chart Version 2.4.0

Replaced `beta.kubernetes.io/arch` with `kubernetes.io/arch` due to being deprecated.

## Fixes

None

## Prerequisites

No changes

## Breaking Changes

Older versions of kubernetes 1.13 or less will no longer work

## Documentation

[Redis](https://redis.io) is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

## Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
| 2.4.1 | November 18, 2020 | >= 1.14 | None | None | Image update for security updates |
| 2.4.0 | November 4, 2020 | >= 1.14 | None | Older versions of kubernetes 1.13 or less will no longer work | Removed beta.kubernetes.io/arch |
| 2.3.4 | October 13, 2020 | >= 1.11 | None | Add global.networkpolicy.enabled to enable or disable the networkpolicy |
| 2.3.3 | September 02, 2020 | >= 1.11 | None | Added vmstat, pkill, and top tooling using procps-ng package on opencontent-redis-5 image |
| 2.3.2 | August 26, 2020 | >= 1.11 | None | Resolve security vulnerabilities contained within the opencontent-redis-5 image |
| 2.3.1 | June 01, 2020 | >= 1.11 | None | Resolve security vulnerabilities contained within the opencontent-redis-5 image |
| 2.3.0 | May 21, 2020 | >= 1.11 | None | Support helm v3 and enable digests |
| 2.2.4 | May 11, 2020 | >= 1.11 | None | Introduce global variables for upgrade and secret overrides |
| 2.2.3 | Apr 16, 2020 | >= 1.11 | None | Fix announce service selector and move away from default service account |
| 2.2.2 | Apr 08, 2020 | >= 1.11 | None | Chart fixes for service selector|
| 2.2.1 | Mar 02, 2020 | >= 1.11 | None | Minor chart fixes |
| 2.2.0 | Feb 26, 2020 | >= 1.11 | Removed redisPodSecurityContext/redisContainerSecurityContext | Support for Openshift 4.x arbitrary UIDs |
| 2.1.0 | Feb 10, 2020 | >= 1.11 | None | Add network policy to limit access to the redis endpoint |
| 2.0.2 | Feb 4, 2020 | >= 1.11 | Resolve ibm-redis@1.x upgrade issue | Added new property (upgradeFromV1) |
| 2.0.1 | Jan 21, 2020 | >= 1.11 | Kubernetes resource name changes | Bring over updates from the 1.4.9 and under releases |
| 2.0.0 | Nov 13, 2019 | >= 1.11 | Values.yaml file changed | Uplift to redis-ha version of the chart and server to 5.0.5 |
| 1.4.9 | January 21, 2020 | >=1.11 | None | Additional environment sizes for ppc64le, ibm-sch update for helm3 support |
| 1.4.8 | December 20, 2019 | >=1.11 | None | Images with Vunlerability fixes |
| 1.4.7 | November 12, 2019 | >=1.11 | Changing required kube version to 1.11 | new sch 1.2.14, good with cv lint 2.0.7, Add s390x architecture support, images with Vunlerability fixes |
| 1.4.4 | September 3, 2019 | >=1.10 | None | Fix chart upgrade issue by removing `labelType: new` from `ibm-sch` chart config |
| 1.4.3 | August 19, 2019 | >=1.10 | None | Adding Global.RBAC.Create parameter |
| 1.4.2 | August 14, 2019 | >=1.10 | None | New images with CVE fixes and cv lint 1.4.5 fixes |
| 1.4.0 | July 26, 2019 | >=1.10 | | Support for openshift restricted scc and cv lint 1.4.4 fixes |
| 1.3.1 | June 11, 2019 | >= 1.10 | Values.yaml file changed | couple cv lint fixes, adding cv tests, fixing readme with latest code, known issues, encryption details, copyright consistent |
| 1.3.0 |June 3, 2019   | >= 1.10  | Values.yaml file changed | * New Image for secret generation </br> * New Image for Redis </br> * CV lint version 1.4.1 fixes </br> * Follow Hero Metadata </br> * Support Affinity Overriding </br> * Removed pre install helm hooks </br> * uses ibm-sch-1.2.10 </br> |
| 1.2.1 | March 29, 2019 | >= 1.10 | None | Persistence configuration
| 1.2.0 | Oct 31, 2018 | >= 1.10 | None | Fix chart linter issues |
| 1.1.0 | July 5, 2018 | >= 1.7 | None | Add probes. Fix service account name metadata type |
| 1.0.0 | March 21, 2018 | >= 1.7 | None | Initial version |
