
# Install Process Mining

## Prerequisites
Install MonetDb and Postgres before Process MIning application


## Mandatory settigns
Mandatory settings are related to the databeses:
- postgres
- monetdb

```
database:
  postgres:
    host: "<POSTGRES HOST>"
    user: "<POSTGRES USERNAME>"
    database: "<POSTGRES DB NAME>"
    credential:
      secretname: "<SECRET NAME WITH PASSWORD>"
      passwordkey: "<SECRET KEY WITH PASSWORD VALUE>"
  monet:
    host: "<MONETDB RELEASE NAME>-monetdb-service.<YOUR NAMESPACE>.svc.cluster.local"
    credential:
      secretname: "<MONETDB RELEASE NAME>-monetdb-secret"
      passwordkey: "password"
```

## Configuration options (optional)

### Docker images (for airgap env)

If you are using mirrored images you need change the registry url.
You can also change image digest (i.e. replace it with a tag)
```
images: 
  registry: 'my.companyregistry.io'
  processmining:
    nginx: processmining-nginx:211
    usermanagement: processmining-usermanagement:211
    discovery: processmining-discovery:211
    analytics: processmining-analytics:211
    bpa: processmining-bpa:211
    dr: processmining-dr:211
    ssl: processmining-ssl:211
    monitoring: processmining-monitoring:211
    acf_custom_process_app: processmining-acf-custom:211
    monetdb: processmining-monet:211
    db_utils: processmining-db-utils:211
    dr_ml: processmining-dr-ml:211
```

### Additional settings
You can optionally override following settings in the value file

- Email server (used in the "forgot password" feature)
- Storage size and Pvc
- Single sign on (ldap or oauth)
- Log level (for debugging)

## Run installation

`helm install  <RELEASE NAME> ./ibm-process-mining  --namespace <YOUR NAMESPACE> -f sample-pm.yml` 


# Login to the application

## Find the url
You can access the login page by accessing the url exposed by the `Route` named `<RELEASE NAME>-pm`

## First login
See documentation https://www.ibm.com/docs/en/process-mining/2.1.1?topic=environments-validating-installation#accessing-sitedatakeywordpm_notm-in-a-linux-non-containerized-environment__title__1
