# ibm-watson-mma-prod
This chart contains the custom model management API for IBM Watson's NLU (Natural Language Understanding) service.

## Introduction
MMA is the primary stateful component of the Watson Natural Language Understanding stack. It is also use in Watson Knowledge Studio. Please see documentation about those products for more information.

## Chart Details
This chart creates one pod and an associated service:
* `ibm-watson-mma-prod-model-management-api` - Model management API.

This chart is only intended to be used as a subchart. It is important to note that both MMA and v1 & v2 of MMA are included in this chart and accessible on ports 4000 and 4001, respectively.

<ins>chart status notes</ins>
- MMA v2 is a stub server only (no functionality)
- Secret is directly rendered by Helm (not recommended - should be replaced with an init container or something similar)
- Due to the prior point, not linked to Postgres at creation time; can only be tested if Postgres is already set up in Kubernetes
    - IMPORTANT: when testing, make sure to override the secret values with those matching your current Postgres deployment, otherwise things will fail!

## Prerequisites
See parent [README](../../README.md)

## Resources Required
See parent [README](../../README.md)

## Installing the Chart
N/A; this chart should not be released in isolation.

### Verifying the Chart
See NOTES.txt associated with this chart for verification instructions

### Uninstalling the Chart
N/A; this chart should not be released in isolation.

## Configuration
The configuration parameters for the Model Management API chart should be set by the Umbrella chart including it. This chart should not exist in isolation.

## Storage
See parent [README](../../README.md)

## Limitations
See parent [README](../../README.md)

## PodSecurityPolicy Requirements
See parent [README](../../README.md)

## Documentation
See parent [README](../../README.md)
