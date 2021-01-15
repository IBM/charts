# Configuring CP4S Guardium Connector

"Guardium" is referring to IBM&trade; Guardium Data Protection.

## Configuring the connector
The Guardium connector service requires following fields:

| Fields                      | Description                                     | Example                                                    |
|-----------------------------|-------------------------------------------------|------------------------------------------------------------|
| SERVER                      | This is IBM Security Verify tenant URL          |                                   |
| USERNAME                    | Client id for IBM Security Verify tenant        | UUID                              |
| PASSWORD                    | Client Secret for IBM Security Verify tenant    |                                   |
| API_KEY                     | Client Secret for IBM Security Verify tenant    |                                   |
| CAR_SERVICE_URL             | The API URI for IBM's CAR API.                  | https://\<CP4S URL\>/api/car/v2   |
| CAR_SERVICE_KEY             | The access key for IBM's CAR API.               |                                   |
| CAR_SERVICE_PASSWORD        | The api password for IBM's CAR API              |                                   |
| SOURCE                      | Unique data source name                         | guardium                               |


## Create the CronJob by calling the CAR connector config service

```
curl --location --request POST 'https://<CP4S URL\>/api/car-connector-config/v1/connectorConfigs' \
--header 'Authorization: Basic <CAR_AUTH>' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "<cronJob-name>",
    "image": "cp.icr.io/cp/cp4s/solutions/isc-car-connector-guardium:1.4.0.0-amd64",
    "frequency": <frequency>,
    "time": "<time>",
    "env_vars": {
         "SOURCE": "<source_id>"
    },
    "secret_env_vars": {
         "SERVER": "<SERVER>",
         "USERNAME": "<USERNAME>",
         "PASSWORD": "<PASSWORD>",
         "API_KEY": "<API_KEY>"
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