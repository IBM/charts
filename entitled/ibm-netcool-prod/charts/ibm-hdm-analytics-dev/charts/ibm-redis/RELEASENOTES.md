# Release Notes

## What's new in Chart Version 1.4.4

* Fix chart upgrade issue by removing `labelType: new` from `ibm-sch` chart config 

## Fixes

CVE fixes

## Prerequisites

No changes

## Breaking Changes

None

## Documentation

[Redis](https://redis.io) is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

## Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
|1.4.4 | September 3, 2019 | >=1.10 | None | Fix chart upgrade issue by removing `labelType: new` from `ibm-sch` chart config |
|1.4.3 | August 19, 2019 | >=1.10 | None | Adding Global.RBAC.Create parameter |
|1.4.2 | August 14, 2019 | >=1.10 | None | New images with CVE fixes and cv lint 1.4.5 fixes |
|1.4.0 | July 26, 2019 | >=1.10 | | Support for openshift restricted scc and cv lint 1.4.4 fixes |
|1.3.1 | June 11, 2019 | >=1.10 | | couple cv lint fixes, adding cv tests, fixing readme with latest code, known issues, encryption details, copyright consistent |
|1.3.0 |June 3, 2019   | >=1.10  | Values.yaml file changed | * New Image for secret generation </br> * New Image for Redis </br> * CV lint version 1.4.1 fixes </br> * Follow Hero Metadata </br> * Support Affinity Overriding </br> * Removed pre install helm hooks </br> * uses ibm-sch-1.2.10 </br> |
| 1.2.1 | March 29, 2019 | >= 1.10 | None | Persistence configuration
| 1.2.0 | Oct 31, 2018 | >= 1.10 | None | Fix chart linter issues |
| 1.1.0 | July 5, 2018 | >= 1.7 | None | Add probes. Fix service account name metadata type |
| 1.0.0 | March 21, 2018 | >= 1.7 | None | Initial version |
