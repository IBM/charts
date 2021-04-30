# Chart Information

## Introduction

0010-infra chart lays down basic infrastructure components and microservices for the **Cloud Pak for Data** to be installed on top.

## Chart Details

This chart contains following components

1. Zen-metastoredb statefulset (cockroachdb)
2. Infuxdb deployment
3. User management deployment
4. user-home (shared PV) preparation job
5. User management preparation job
6. Set of configmaps to drive product behavior

## Prerequisites

1. This  chart expects two different SCCs to be present in RHOCP cluster. This chart is **not** meant to be installed on any kubernetes offering except RHOCP.

The SCCs are layed down by installer

* [`cpd-zensys-scc`](https://ibm.biz/cpkspec-scc)
* [`cpd-user-scc`](https://ibm.biz/cpkspec-scc)

This chart also requires a set of PVCs to be attached with PVs in your runtime.

1. *Dynamic Provisioning*

    If you are using a storage-class with dynamic provisioning enabled, the chart will PVs and PVCs bind correctly.

2. *Static Provisioning*
    In case of storage class with static provisioning, Kubernetes needs both PV and PVC to have common label for matching. In case of 0010 chart Cloud Pak for Data uses the following mechanism for label matching using `assign-to` as a common label in both YAML files.

## Resources Required

| Component                   	| Replicas 	| Max CPU | Max Memory 	| Min CPU | Min Memory 	|
|-----------------------------	|----------	|---------|-------------|---------|-------------|
| Influxdb                    	| 1        	| 1000m   | 2048Mi 	    | 100m    | 256Mi 	    |
| Influxdb-populate-job       	| 1        	| 1000m   | 512Mi  	    | 100m    | 512Mi  	    |
| User-home prep job          	| 1        	| 1000m   | 512Mi  	    | 500m    | 256Mi  	    |
| Usermgmt prep job          	| 1        	| 1000m   | 512Mi  	    | 500m    | 256Mi  	    |
| Usermgmt                    	| 2        	| 1000m   | 512Mi  	    | 200m    | 256Mi  	    |
| Zen-metastoredb-init job    	| 1        	| 500m    | 1024Mi 	    | 100m    | 512Mi	    |
| Zen-metastoredb statefulset 	| 3        	| 500m    | 1024Mi 	    | 100m    | 512Mi 	    |
| Createsecret Job          	| 1        	| 500m    | 128Mi 	    | 100m    | 64Mi 	    |

## Red Hat OpenShift SecurityContextConstraints Requirements

This chart needs two SCCs described in the section above.
Please visit this link for more information on SCCs.
<https://ibm.box.com/s/4u08mmazirl9vwo7hha736xuv3ps1qow>

## Installing the Chart

Section 5 in this document goes into detail of install procedure for CPD lite <https://ibm.box.com/s/4u08mmazirl9vwo7hha736xuv3ps1qow>

## Limitations

This chart is not self sufficient. It has dependency on other charts. Installing this alone will not be sufficient.

## Configuration

All the default values are set in the charts. However the docker_registry_prefix, storage-class needs to be input to the charts.

Additionally the project also need to setup with tiller, scc, sa, rolebindings etc.
