# What's new...

# Fixes

# Prerequisites

# Version History

# IIS Chart Upgrade Process

## Minor upgrades (involving only image upgrades and no data/volume upgrades)

Rolling upgrades can be performed for minor upgrades via Helm

Helm chart version is bumped in a release. And using the Helm upgrade command, the rollover will happen.

`helm upgrade <release name> <chart name>`

Check the rollout status of each deployment/statefulset

`kubectl rollout status deployment <name>`