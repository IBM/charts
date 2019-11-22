# Release Notes

## What's new in Chart Version 2.0.0

* Based on the redis-ha version of the publicly available chart
* Update Redis server from 3.x to 5.0.5
* Service account, role, and role binding is optionally used for credential creation/cleanup
* CV lint version 1.4.4 fixes
* Retain similar configuration for adding persistence, node affinity, and resource sizing
* Retain optional credential creation and cleanup job with similar authentication configuration

## Fixes

* Fixes Redis master selection during startup and recovery failures

## Prerequisites

No changes

## Breaking Changes

* Values.yaml file has been restructured
* Selection of master redis server is done via Sentinels rather than service that uses selectors. Clients should use sentinel to check which redis server is the master
* Can only scale up to the maxReplicas size that is specified during the installation

## Documentation

[Redis](https://redis.io) is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

## Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
| 2.0.0 | Nov 13, 2019 | >= 1.10 | Values.yaml file changed | Uplift to redis-ha version of the chart and server to 5.0.5 |
| 1.3.1 | June 11, 2019 | >= 1.10 | Values.yaml file changed | couple cv lint fixes, adding cv tests, fixing readme with latest code, known issues, encryption details, copyright consistent |
| 1.3.0 |June 3, 2019   | >= 1.10  | Values.yaml file changed | * New Image for secret generation </br> * New Image for Redis </br> * CV lint version 1.4.1 fixes </br> * Follow Hero Metadata </br> * Support Affinity Overriding </br> * Removed pre install helm hooks </br> * uses ibm-sch-1.2.10 </br> |
| 1.2.1 | March 29, 2019 | >= 1.10 | None | Persistence configuration
| 1.2.0 | Oct 31, 2018 | >= 1.10 | None | Fix chart linter issues |
| 1.1.0 | July 5, 2018 | >= 1.7 | None | Add probes. Fix service account name metadata type |
| 1.0.0 | March 21, 2018 | >= 1.7 | None | Initial version |
