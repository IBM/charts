# Release Notes

## What's new in Chart Version 1.3.0

* New Image for secret generation
* New Image for Redis 
* CV lint version 1.4.1 fixes
* Follow Hero Metadata
* Support Affinity Overriding
* Removed pre install helm hooks
* uses ibm-sch-1.2.10

## Fixes

* Previously the redis helm chart with sch integration, sets master role to serveral pods when the release name is too long, this bug has been fixed in this release. 
* Previoulsy non UBI image was used to generate secret, ubi based image is used in this release. 

## Prerequisites

No changes

## Breaking Changes

Values.yaml file has been restructured 

## Documentation

[Redis](https://redis.io) is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

## Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
|1.3.1 | June 11, 2019 | >=1.10 | | couple cv lint fixes, adding cv tests, fixing readme with latest code, known issues, encryption details, copyright consistent |
|1.3.0 |June 3, 2019   | >=1.10  | Values.yaml file changed | * New Image for secret generation </br> * New Image for Redis </br> * CV lint version 1.4.1 fixes </br> * Follow Hero Metadata </br> * Support Affinity Overriding </br> * Removed pre install helm hooks </br> * uses ibm-sch-1.2.10 </br> |
| 1.2.1 | March 29, 2019 | >= 1.10 | None | Persistence configuration
| 1.2.0 | Oct 31, 2018 | >= 1.10 | None | Fix chart linter issues |
| 1.1.0 | July 5, 2018 | >= 1.7 | None | Add probes. Fix service account name metadata type |
| 1.0.0 | March 21, 2018 | >= 1.7 | None | Initial version |
