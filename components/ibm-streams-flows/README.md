# IBM Streams Flows Add-On

## Introduction

IBM Streams Flows provides a user-friendly, productive graphical environment for developing IBM Streams applications.

## Chart Details

After installing the add-on, streams flows can be added to a project's assets.

Doucmentation can be found in the [Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/wsj/streaming-pipelines/running-monitoring-streaming-pipeline.html).

## Prerequisites

IBM Streams Flows requires the IBM Streams add-on.

## Resources Required

- **CPU:** 500m
- **Memory:** 128Mb
- **Replicas:** 1

## Red Hat OpenShift SecurityContextConstraints Requirements

The add-on runs in the [`restricted`](https://ibm.biz/cpkspec-scc) security context.

## Configuration

Streams Flows does not require any configuration.

## Installing the Chart

Installation instructions can be found in the [Knowledge Center](https://www.ibm.com/support/producthub/icpdata/docs/content/SSQNUZ_current/cpd/svc/streams/installing-streams-flows.html).

## Limitations

- Requires IBM Streams, which supports Linux x86_64.