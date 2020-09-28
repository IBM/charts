# Configuring Amazon&trade; AWS  Connector
"AWS" is referring to Amazon&trade; AWS.

## Configuring the connector
The aws connector service requires following fields: 

| Fields          | Description                          | Example                                    |
|-----------------|--------------------------------------|--------------------------------------------|
| ACCOUNT_ID      | AWS account id.                      | 974738500502                               |
| CLIENT_ID       | AWS client id.                       | 45g56k24-56f3-485c-9e42-c52ed9h3b3de       |
| CLIENT_SECRET   | AWS client secret.                   | gdujS%6sd/-w                               |
| REGION          | AWS region.                          | us-east-1                                  |
| CAR_SERVICE_URL | The API URI for IBM's CAR API.       | https://\<CP4S URL\>/api/car/v2            |
| CAR_SERVICE_KEY         | The access key for IBM's CAR API.     |                                            |
| CAR_SERVICE_PASSWORD        | The api password for IBM's CAR API    |                                            |
| SOURCE          | The source id for the data source.   | aws                                        |

## Create the CronJob by calling the CAR connector config service

```
curl --location --request POST 'https://<CP4S URL\>/api/car-connector-config/v1/connectorConfigs' \
--header 'Authorization: Basic <CAR_AUTH>' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "<cronJob-name>",
    "image": "cp.icr.io/cp/cp4s/solutions/isc-car-connector-aws:1.4.0.0-amd64",
    "frequency": <frequency>,
    "time": "<time>",
    "env_vars": {
         "SOURCE": "<source_id>"
    },
    "secret_env_vars": {
         "ACCOUNT_ID": "<ACCOUNT_ID>",
         "CLIENT_ID": "<CLIENT_ID>",
         "CLIENT_SECRET": "<CLIENT_SECRET>",
         "REGION": "<REGION>"
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
