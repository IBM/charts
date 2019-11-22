## Introduction  

This chart contains one of the component that is an integral part of the Bootstrap module for services within IBM Cloud Pak for Data.

## Prerequisites

This chart pre-reqs 2 other bootstrap charts: 0010-infra and 0015-setup in that order. These chart sets up the PV and brings in essential services like user management, nginx, metastoredb etc.

[`restricted`](https://ibm.biz/cpkspec-scc)

## Resources Required

Cumulatively the minimum CPU required by all deployments is 1060m.

| Component                   	| Replicas 	| Max CPU | Max Memory 	| Min CPU | Min Memory 	|
|-------------------------------|-----------|---------|-------------|---------|-------------|
| CP4D open api        	        | 1        	| 500m    | 512Mi 	    | 100m    | 128Mi	      |
| zen admin                    	| 2        	| 300m    | 512Mi 	    | 30m     | 128Mi 	    |
| zen content      	            | 2        	| 500m    | 512Mi  	    | 100m    | 128Mi  	    |
| zen core api            	    | 1        	| 2000m   | 1024Mi  	  | 100m    | 256Mi 	    |
| zen core ui          	        | 3        	| 2000m   | 1024Mi  	  | 100m    | 256Mi  	    |
| zen data sorcerer             | 1        	| 300m    | 512Mi  	    | 30m     | 128Mi  	    |
| zen requisite job   	        | 1        	| 500m    | 128Mi 	    | 100m    | 64Mi	      |
| zen watchdog  	              | 1        	| 500m    | 512Mi 	    | 100m    | 128Mi 	    |
| zen watcher           	      | 1        	| 2000m   | 1024Mi  	  | 100m    | 256Mi 	    |

## Chart Details

This chart contains following components:

- zen-core: UI service for core components within CP4D
- zen-core-api: Rest layer to provide add-on apis
- zen-watchdog: Rest server to provide serviceability component to CP4DD
- zen-admin: Provide admin UX for CP4D
- zen-content: static server to serve up large files
- icp4d-open-api: server to provide platform apis 
- zen-watcher: Watcher to watch for new add-ons appearing in the platform

user-home PV is used by most of the deployments within chart. That is a pre-req for this chart. The common storage values that are supported are `glusterfs`, `nfs-client` etc.

## Installing the Chart

Section 5 in this document goes into detail of install procedure for ICPD lite https://ibm.box.com/s/4u08mmazirl9vwo7hha736xuv3ps1qow

## Configuration

All the default values are set in the charts. However the docker_registry_prefix, storageclass needs to be input to the charts.

Additionally the project also need to setup with tiller, scc, sa, rolebindings etc.

## Limitations

This chart is not self sufficient. It has dependency on other charts. Installing this alone will not be sufficient.

## Red Hat OpenShift SecurityContextConstraints Requirements

See this for more details
https://ibm.box.com/s/4u08mmazirl9vwo7hha736xuv3ps1qow
