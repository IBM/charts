# Configuring the CAR CP4S Connectors

## **Pre-Requisites**

1. Log into the CP4S cluster as follows

```
cloudctl login -a <ICP CLUSTER URL> -u <USERNAME> -p <PASSWORD> -n <NAMESPACE>
```

2. Obtain IBM_CAR_API_URI value:
```
kubectl get route
```
"CP4S URL" is `HOST/PORT` of the route `isc-route-default`. `IBM_CAR_API_URI` is `\<CLUSTER_URL\>/api/car/v2`

3. Steps to install each CAR connector are in following docs:
    * [CAR-Azure connector](./cp4s-connector-car-azure/README.md)
    * [CAR-ATP connector](./cp4s-connector-car-atp/README.md)
    * [CAR-Tenable connector](./cp4s-connector-car-tenable/README.md)
    * [CAR-AWS connector](./cp4s-connector-car-aws/README.md)
    * [CAR-IAM connector](./cp4s-connector-car-iam/README.md)
    * [CAR-QRadar connector](./cp4s-connector-car-qradar/README.md)