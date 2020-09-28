# Configuring CP4S Tenable Connector
"Tenable" is referring to Tenable&trade;.

## Configuring the connector
The tenable connector service requires some mandatory fields and other optional. 

| Fields            | Description                              | Required | Example                                                    |
|-------------------|------------------------------------------|----------|------------------------------------------------------------|
| TIO_ACCESS_KEY    | Tenable.io Access Key.                   | Y        |                                                            |
| TIO_SECRET_KEY    | Tenable.io Secret Key.                   | Y        |                                                            |
| CAR_SERVICE_URL   | The API URI for IBM's CAR API.           | Y        | https://\<CP4S URL\>/api/car/v2   |
| CAR_SERVICE_KEY    | The access key for IBM's CAR API.         | Y        |                                                            |
| CAR_SERVICE_PASSWORD  | The password key for IBM's CAR API.       | Y        |                                                            |
| BATCH_SIZE        | Export/Import Batch Sizing.              | N        | 100                                                        |
| VERBOSITY         | Logging Verbosity.                       | N        | 1                                                          |
| SINCE             | The unix timestamp of the age threshold. | N        | 0                                                          |

## Create the CronJob by calling the CAR connector config service

```
curl --location --request POST 'https://<CP4S URL\>/api/car-connector-config/v1/connectorConfigs' \
--header 'Authorization: Basic <CAR_AUTH>' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "<cronJob-name>",
    "image": "cp.icr.io/cp/cp4s/solutions/isc-car-connector-tenable:1.4.0.0-amd64",
    "frequency": <frequency>,
    "time": "<time>",
    "env_vars": {
         "SOURCE": "<source_id>"
         "BATCH_SIZE": "<BATCH_SIZE>",
         "VERBOSITY": "<VERBOSITY>",
         "SINCE": "<SINCE>"
    },
    "secret_env_vars": {
         "TIO_ACCESS_KEY": "<TIO_ACCESS_KEY>",
         "TIO_SECRET_KEY": "<TIO_SECRET_KEY>",
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
