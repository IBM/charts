# Sample MQ Dashboards

## Grafana

### Using the Dashboard

There are 4 Grafana dashboards included in this directory, all of which should be imported into your Grafana workspace:

- **mq_grafana_dashboard** - This is the main dashboard and contains metrics for *all* Queue Managers
- **mq_fdc_grafana_dashboard** - Accessed as a drilldown from the FDC panel of the main dashboard, this dashboard contains FDC metrics for each Queue Manager
- **mq_usage_grafana_dashboard** - Accessed as a drilldown from the Usage panels of the main dashboard, this dashboard contains system usage metrics for each Queue Manager
- **mq_qm_grafana_dashboard** - Accessed as a drilldown from the FDC/Usage dashboards, this dashboard is a Queue Manager specific version of the main mq_grafana_dashboard

___

## Kibana

### Using the Dashboard

There is 1 Kibana dashboard included in this directory which should be imported into your Kibana workspace:

- **mq_kibana_dashboard** - This is the main dashboard containing log metrics for *all* Queue Managers. The dashboard data can be filtered down to specific queue manager by using the example query given on the dashboard
