# Release Notes

## What's new in Chart Version 1.1.0

- Added liveness and readiness probes
- Added a helm test

## Fixes

- Fixed the metadata type of the service account name that may cause errors deploying to IBM Cloud Private.

## Prerequisites

- No changes

## Version History

| Chart | Date | Kubernetes Version Required | Breaking Changes | Details |
| ----- | ---- | --------------------------- | ---------------- | ------- |
| 1.1.0 | July 5, 2018 | >= 1.7 | None | Add probes. Fix service account name metadata type |
| 1.0.0 | March 21, 2018 | >= 1.7 | None | Initial version |