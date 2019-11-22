## Introduction

This chart contains one of the components that is an integral part of the Bootstrap module for services within IBM Cloud Pak for Data.

## Prerequisites

This chart pre-reqs the bootstrap chart: 0010-infra. These charts sets up the PV and brings in essential services like user management, metastoredb etc.

[`cpd-user-scc`](https://ibm.biz/cpkspec-scc)

## Resources Required

Cumulatively the minimum CPU required by all deployments is 500m and the minimum memory is 256Mi.

| Component                   	| Replicas 	| Max CPU | Max Memory 	| Min CPU | Min Memory 	|
|-----------------------------	|----------	|---------|-------------|---------|-------------|
| Nginx deployment          	  | 3        	| 1000m   | 512Mi 	    | 200m    | 256Mi	      |
| Setup Nginx Job               | 1        	| 1000m   | 512Mi 	    | 500m    | 256Mi 	    |



## Chart Details

This chart mainly contains the nginx component that sets up the proxy for Cloud Pak for Data.

## Installing the Chart

Section 5 in this document goes into detail of install procedure for ICPD lite https://ibm.box.com/s/4u08mmazirl9vwo7hha736xuv3ps1qow

## Configuration

All the default values are set in the charts. However the docker_registry_prefix, existing claim name needs to be input to the charts.

Additionally the project also needs to be setup with tiller, scc, sa, rolebindings etc.

## Limitations

This chart is not self sufficient. It has dependency on other charts. Installing this alone will not be sufficient.

## Red Hat OpenShift SecurityContextConstraints Requirements

See this for more details
https://ibm.box.com/s/4u08mmazirl9vwo7hha736xuv3ps1qow

