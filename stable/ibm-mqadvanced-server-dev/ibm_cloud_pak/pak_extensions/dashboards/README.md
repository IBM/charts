# Sample MQ Dashboards

## Grafana

### Using the Dashboard

There are 4 Grafana dashboards included in this directory, all of which should be imported into your Grafana workspace:

- **`mq_grafana_dashboard`** - This is the main dashboard and contains metrics for *all* Queue Managers
- **`mq_fdc_grafana_dashboard`** - Accessed as a drilldown from the FDC panel of the main dashboard, this dashboard contains FDC metrics for each Queue Manager
- **`mq_usage_grafana_dashboard`** - Accessed as a drilldown from the Usage panels of the main dashboard, this dashboard contains system usage metrics for each Queue Manager
- **`mq_qm_grafana_dashboard`** - Accessed as a drilldown from the FDC/Usage dashboards, this dashboard is a Queue Manager specific version of the main `mq_grafana_dashboard`

___

## Kibana

### Pre-requisites

- For the Visualizations to be successfully imported into Kibana, ensure that you already have an active Queue Manager with JSON logging enabled. You will need to refresh the index field list to pick up MQ's log fields, as per the [Kibana docs](https://www.elastic.co/guide/en/kibana/5.5/index-patterns.html#reload-fields)

### Importing the dashboard

To import the dashboard, open Kibana and go to:

`Management -> Kibana -> Saved Objects -> Import`

Import the `mq_kibana_dashboard.json` file. You can then view the dashboard by clicking the 'view' icon next to the dashboard name
