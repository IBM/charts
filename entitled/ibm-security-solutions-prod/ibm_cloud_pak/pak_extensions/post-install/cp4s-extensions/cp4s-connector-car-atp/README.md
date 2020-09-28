# Configuring CP4S ATP Connector

"ATP" is referring to Microsoft&trade; Defender Advanced Threat Protection technology.

## Configuring the connector
The ATP connector service requires following fields: 

| Fields          | Description                        | Example                                                  |
|-----------------|------------------------------------|----------------------------------------------------------|
| SUBSCRIPTION_ID | ATP subscription id.               | 083de1fb-c52d-4b7c-895a-2b5ad7fg91e8                     |
| TENANT_ID       | ATP tenant id.                     | b73d5h78-34d5-495a-9901-06bd6h4ff13e                     |
| CLIENT_ID       | ATP client id.                     | 45g56k24-56f3-485c-9e42-c52ed9h3b3de                     |
| CLIENT_SECRET   | ATP client secret.                 | gdujS%6sd/-w                                             |
| CAR_SERVICE_URL | The API URI for IBM's CAR API.     | https://\<CP4S URL\>/api/car/v2                            |
| CAR_SERVICE_KEY         | The access key for IBM's CAR API.   |                                                          |
| CAR_SERVICE_PASSWORD        | The api password for IBM's CAR API  |                                                          |
| SOURCE          | The source id for the data source. | microsoft-atp                                            |

## Create the CronJob by calling the CAR connector config service

```
curl --location --request POST 'https://<CP4S URL\>/api/car-connector-config/v1/connectorConfigs' \
--header 'Authorization: Basic <CAR_AUTH>' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "<cronJob-name>",
    "image": "cp.icr.io/cp/cp4s/solutions/isc-car-connector-atp:1.4.0.0-amd64",
    "frequency": <frequency>,
    "time": "<time>",
    "env_vars": {
         "SOURCE": "<source_id>"
    },
    "secret_env_vars": {
         "SUBSCRIPTION_ID": "<SUBSCRIPTION_ID>",
         "TENANT_ID": "<TENANT_ID>",
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
