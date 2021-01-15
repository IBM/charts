# IBM QRadar® Asset Exporter

The asset exporter script uploads your asset database into IBM Cloud Pak® for Security (CP4S) at regular intervals.

## Prerequisites

A QRadar connection must have already been set up in CP4S before running the assets script. On the data source connection configuration form, click **Generate API Key**. The API key is used to provide persistent access to push data into CP4S. 

**Note:** The QRadar Connected Asset and Risk connection that you implement by using the following procedure does not adhere to QRadar security models. It exports all of the asset information from a QRadar instance. For example, you might have a multi-tenant QRadar instance, a limited security profile, or multiple security profiles. When you set up this connection, the Connected Asset and Risk connector ignores all QRadar security profiles and the database is populated with all of the asset data from your QRadar instance.

## Steps to run the Assets script

1. Find the zip archive of the QRadar CAR connector (`UDA-ingestion-2.0.4.zip`) that is included in this folder.
2. Secure copy the archive over to the root of the QRadar box: `scp UDA-ingestion-2.0.4.zip root@<IP Address>:/root`
2. SSH into your QRadar box.
3. Create the following directory on your QRadar box: `/transient/car`: `mkdir -p /transient/car`
4. Unzip the archive into the `car` folder created in the previous step: `unzip -j -d /transient/car UDA-ingestion-2.0.4.zip`
5. Navigate to the new `car` directory: `cd /transient/car`.
6. The archive contains the `assets.py` script which uses the following arguments: 

| Argument     | Optional  | Default value if omitted | Description       |
| -----------  | --------- | -----------              | ------------       |
| url          |           |                          | URL for the CAR ingestion service |
| database     | *         | qradar                   | Database to extract assets from |
| dbuser       | *         | qradar                   | Database user                  |
| dbpassword   | *         |                          | Database password                  |
| key          |           |                          | CAR API key                 |
| pass         |           |                          | CAR Secret API key                   |
| u            | *         | false                    | option to enable incremental update |

The URL for the CAR ingestion service is a combination of the CP4S cluster and the API path of the CAR server: 

`https://<host name of CP4S cluster>/api/car/v2`

7. To run the initial import which is the full dump of the asset database, run the following command:
   ```
   python assets.py -url <'url'> -key <'api key'> -pass <'secret api key'> -database <'database'> -dbuser <'db user'> -dbpassword <'db password'>
   ```
8. To run the incremental update, run the following command:
   ```
   python assets.py -url <'url'> -key <'api key'> -pass <'secret api key'> -database <'database'> -dbuser <'db user'> -dbpassword <'db password'> -u true
   ```
   This will create a cronjob that runs every 15 minutes. Note that the command for incremental update is the same as the initial import, just with the added `-u true` argument.
