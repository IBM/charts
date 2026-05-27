
# Install Process Mining

## Prerequisites
Install MonetDb and Postgres before Process MIning application


## Mandatory settigns
Mandatory settings are related to the databeses:
- postgres
- monetdb

## Configuration options
You can override following settings in the value file

```
database:
  postgres:
    host: "cluster-postgrespm-rw"
    user: "app"
    database: "app"
    credential:
      secretname: "cluster-postgrespm-app"
      passwordkey: "password"
  monet:
    host: "monetpm-monetdb-service.processmining.svc.cluster.local"
    credential:
      secretname: "monetpm-monetdb-secret"
      passwordkey: "password"

images: 
  registry: 'my.companyregistry.io'

```

## Run installation

`helm install  <RELEASE NAME> ./ibm-process-mining  --namespace <YOUR NAMESPACE> -f sample-pm.yml` 
