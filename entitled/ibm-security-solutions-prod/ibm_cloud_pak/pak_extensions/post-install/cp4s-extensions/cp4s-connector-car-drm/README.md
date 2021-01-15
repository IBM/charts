# Configuring CP4S DRM Connector

"DRM" is referring to IBM&trade; Data Risk Manager.

## Configuring the connector
The DRM connector service requires following fields:

| Fields                      | Description                                     | Example                                                    |
|-----------------------------|-------------------------------------------------|------------------------------------------------------------|
| TENANT_URL                  | This is IBM DRM tenant URL          |                                   |
| USERNAME                    | Client id for IBM DRM tenant        | UUID                              |
| PASSWORD                    | Client Secret for IBM DRM tenant    |                                   |
| CAR_SERVICE_URL             | The API URI for IBM's CAR API.                  | https://\<CP4S URL\>/api/car/v2   |
| CAR_SERVICE_KEY             | The access key for IBM's CAR API.               |                                   |
| CAR_SERVICE_PASSWORD        | The api password for IBM's CAR API              |                                   |
| SOURCE                      | Unique data source name                         | drm                               |
| PAGE_SIZE                   | Records per page                         | 10                               |


## Create the CronJob by calling the CAR connector config service

```
curl --location --request POST 'https://<CP4S URL\>/api/car-connector-config/v1/connectorConfigs' \
--header 'Authorization: Basic <CAR_AUTH>' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "<cronJob-name>",
    "image": "cp.icr.io/cp/cp4s/solutions/isc-car-connector-drm:1.5.0.0-amd64",
    "frequency": <frequency>,
    "time": "<time>",
    "env_vars": {
         "SOURCE": "<source_id>",
         "PAGE_SIZE": "10"
    },
    "secret_env_vars": {
         "TENANT_URL": "<SERVER>",
         "USERNAME": "<USERNAME>",
         "PASSWORD": "<PASSWORD>"
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