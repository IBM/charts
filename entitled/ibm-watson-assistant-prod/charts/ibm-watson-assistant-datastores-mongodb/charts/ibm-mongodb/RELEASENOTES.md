### What's new in v1.5.0

* New images, 
* metrics support, 
* Updated Readme, 
* cv test, 
* chart clean up, 
* cv lint fixes

### Fixes

* Mongodb metrics is exported, bugs in metrics part has been fixed. 

### Breaking Changes

* New images 

### Prerequisites

* tiller 2.9.1

### Documentation
* [Mongodb](https://www.mongodb.com/what-is-mongodb) stores data in flexible, JSON-like documents

* The document model maps to the objects in your application code, making data easy to work with

* Ad hoc queries, indexing, and real time aggregation provide powerful ways to access and analyze your data

* MongoDB is a distributed database at its core, so high availability, horizontal scaling, and geographic distribution are built in and easy to use

### Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
| 1.5.1 | June 26, 2019 | >=1.10.1 | none | Fixes hanging pods on start-up |
| 1.5.0 | June 20, 2019 | >=1.12 | New images | New images, metrics support, Updated Readme, cv test, chart clean up, cv lint fixes |
| 1.4.0 | June 13, 2019 |  >= 1.12 | yes | changes to statefulset name, all images are ubi, images with cve fixes, metrics has bugs, needs to be used as disabled. |
| 1.3.2 | May 23, 2019 | >= 1.12 | yes | cv 1.4.1 lint fixes, dependency on ibm-sch chart is made configurable, .Values.affinity overrides the default affinity (not an addition any more) The settings applies to all pods (creds jobs and test pods), adding support for exisiting secretname, using global image repo, secret, pullpolicy, existing secret name includes release name prefix |
| 1.3.1 | May 17, 2019 | >= 1.12 | none | few more cv lint fixes |
| 1.3.0 | May 16, 2019 | >= 1.12 | yes | Base image changed to UBI, Running as Non root user, SCH integration, CV lint fixes, ICP 3.1.2 support with ibm-restricted-psp, Supports local volume and not hostpath |
