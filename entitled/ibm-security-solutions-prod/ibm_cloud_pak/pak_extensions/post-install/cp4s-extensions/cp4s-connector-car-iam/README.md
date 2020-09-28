# Configuring CP4S IAM Connector

"IAM" is referring to IBM&trade; Identity and Access Management.

## Setting up the IBM Security Verify Analytics bridge and Security Verify tenant for IAM data
1. Create a tenant in IBM Security Verify tenant with 'CIA' plan
2. Setup IBM Security Verify Analytics bridge - Refer to https://hub.docker.com/r/ibmcom/ciabridge
3. While setting up ciabridge we need to pass 'CLOUD_PAK_SECURITY="true"' flag as an environment variable to generate data required for CP4S IAM CAR Connector to run.
4. Do tenant binding from IBM Security Verify bridge to IBM Security Verify tenant and enable replication
5. Configure the ISIM/IGI Data Source and Run analysis
6. Once analysis is done, Tenant Data is replicated in IBM Security Verify tenant - Analytics tab dashboard.
7. Create an API ClientId & secret from IBM Security Verify tenant by navigating to `Configuration -> API Access` under the Admin settings and selecting `Manage API Clients`
**This clientId and secret would be used to run the IAM CAR Connector along with tenant url**


## Configuring the connector
The IAM connector service requires following fields:

| Fields                         | Description                          | Example                                                    |
|------------------------------  |--------------------------------------|------------------------------------------------------------|
| TENANT_URL                     | This is IBM Security Verify tenant URL                        |                                   |
| CLIENT_ID                      | Client id for IBM Security Verify tenant                      | UUID                              |
| CLIENT_SECRET                  | Client Secret for IBM Security Verify tenant                  |                                   |
| CAR_SERVICE_URL                | The API URI for IBM's CAR API.                                | https://\<CP4S URL\>/api/car/v2   |
| CAR_SERVICE_KEY                | The access key for IBM's CAR API.               |                                   |
| CAR_SERVICE_PASSWORD           | The api password for IBM's CAR API              |                                   |
| SOURCE                         | Unique data source name                                              | iam                               |
| forceFullImport (optional)     | pass this flag only when we want to attempt force full import |                                   |

## Create the CronJob by calling the CAR connector config service

```
curl --location --request POST 'https://cp4s35.ite1.isc.ibmcloudsecurity.com/api/car-connector-config/v1/connectorConfigs' \
--header 'Authorization: Basic <CAR_AUTH>' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "<cronJob-name>",
    "image": "scp.icr.io/cp/cp4s/solutions/isc-car-connector-iam:1.4.0.0-amd64",
    "frequency": <frequency>,
    "time": "<time>",
    "env_vars": {
         "SOURCE": "<source_id>"
    },
    "secret_env_vars": {
         "TENANT_URL": "<TENANT_URL>",
         "CLIENT_ID": "<CLIENT_ID>",
         "CLIENT_SECRET": "<CLIENT_SECRET>"
    }
}
'
```
`source_id` is the unique id to identify a data source
`time` is the time the cronJob will first run 
`frequency` is the frequency in minutes that the cronJob will run. For example if the value is "5", the cronJob will run every 5 minutes
`CAR_AUTH` is `CAR_SERVICE_KEY:CAR_SERVICE_PASSWORD`  base64 encoded.

## Deleting the cronJob
```
curl --location --request DELETE 'https://<CP4S URL\>/api/car-connector-config/v1/connectorConfigs/<cronJob-name>' \
--header 'Authorization: Basic <CAR_AUTH>'
```
