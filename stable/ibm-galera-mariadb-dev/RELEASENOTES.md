# Release Notes

## What's new in Chart Version 1.1.0

- Updated the version of MariaDB to 10.2.14
- Added liveness probes
- Added a helm test

## Fixes

- Fixed the error installing the chart when enabling persistent storage that produced a `Not found: "datadir"` error

## Prerequisites

- Changed Kubernetes version to 1.7+

## Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
| 1.1.0 | July 11, 2018 | >= 1.7 | None | Fixed persistent storage. Updated to MariaDB 10.2.14 |
| 1.0.1 | March 16, 2018 | not set | None | Fixed architecture selection |
| 1.0.0 | March 15, 2018 | not set | None | Initial version |