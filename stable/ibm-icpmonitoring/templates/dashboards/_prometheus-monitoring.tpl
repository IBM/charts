{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* Prometheus Monitoring Dashboard File */}}
{{/* origin: https://grafana.com/dashboards/3681 */}}
{{- define "prometheusMonitoring" }}
prometheus-monitoring.json: |-
    {
      "__inputs": [
        {
          "name": "DS_PROMETHEUS",
          "label": "Prometheus",
          "description": "Prometheus which you want to monitor",
          "type": "datasource",
          "pluginId": "prometheus",
          "pluginName": "Prometheus"
        }
      ],
      "__requires": [
        {
          "type": "grafana",
          "id": "grafana",
          "name": "Grafana",
          "version": "4.6.0"
        },
        {
          "type": "panel",
          "id": "graph",
          "name": "Graph",
          "version": ""
        },
        {
          "type": "datasource",
          "id": "prometheus",
          "name": "Prometheus",
          "version": "1.0.0"
        },
        {
          "type": "panel",
          "id": "singlestat",
          "name": "Singlestat",
          "version": ""
        },
        {
          "type": "panel",
          "id": "text",
          "name": "Text",
          "version": ""
        }
      ],
      "annotations": {
        "list": []
      },
      "description": "Dashboard for monitoring of Prometheus v2.x.x",
      "editable": true,
      "gnetId": 3681,
      "graphTooltip": 1,
      "hideControls": false,
      "id": null,
      "links": [
        {
          "icon": "doc",
          "tags": [],
          "targetBlank": true,
          "title": "Prometheus Docs",
          "tooltip": "",
          "type": "link",
          "url": "http://prometheus.io/docs/introduction/overview/"
        }
      ],
      "refresh": "5m",
      "rows": [
        {
          "collapse": false,
          "height": 161,
          "panels": [
            {
              "cacheTimeout": null,
              "colorBackground": false,
              "colorValue": false,
              "colors": [
                "#299c46",
                "rgba(237, 129, 40, 0.89)",
                "#bf1b00"
              ],
              "datasource": "prometheus",
              "decimals": 1,
              "format": "s",
              "gauge": {
                "maxValue": 1000000,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "id": 41,
              "interval": null,
              "links": [],
              "mappingType": 1,
              "mappingTypes": [
                {
                  "name": "value to text",
                  "value": 1
                },
                {
                  "name": "range to text",
                  "value": 2
                }
              ],
              "maxDataPoints": 100,
              "nullPointMode": "connected",
              "nullText": null,
              "postfix": "",
              "postfixFontSize": "50%",
              "prefix": "",
              "prefixFontSize": "50%",
              "rangeMaps": [
                {
                  "from": "null",
                  "text": "N/A",
                  "to": "null"
                }
              ],
              "span": 2,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": false,
                "lineColor": "rgb(31, 120, 193)",
                "show": false
              },
              "tableColumn": "",
              "targets": [
                {
                  "expr": "time() - process_start_time_seconds{instance=\"$instance\"}",
                  "format": "time_series",
                  "instant": false,
                  "intervalFactor": 2,
                  "refId": "A"
                }
              ],
              "thresholds": "",
              "title": "Uptime",
              "type": "singlestat",
              "valueFontSize": "80%",
              "valueMaps": [
                {
                  "op": "=",
                  "text": "N/A",
                  "value": "null"
                }
              ],
              "valueName": "current"
            },
            {
              "cacheTimeout": null,
              "colorBackground": false,
              "colorValue": true,
              "colors": [
                "#299c46",
                "rgba(237, 129, 40, 0.89)",
                "#bf1b00"
              ],
              "datasource": "prometheus",
              "format": "short",
              "gauge": {
                "maxValue": 1000000,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "id": 42,
              "interval": null,
              "links": [],
              "mappingType": 1,
              "mappingTypes": [
                {
                  "name": "value to text",
                  "value": 1
                },
                {
                  "name": "range to text",
                  "value": 2
                }
              ],
              "maxDataPoints": 100,
              "nullPointMode": "connected",
              "nullText": null,
              "postfix": "",
              "postfixFontSize": "50%",
              "prefix": "",
              "prefixFontSize": "50%",
              "rangeMaps": [
                {
                  "from": "null",
                  "text": "N/A",
                  "to": "null"
                }
              ],
              "span": 4,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": false,
                "lineColor": "rgb(31, 120, 193)",
                "show": true
              },
              "tableColumn": "",
              "targets": [
                {
                  "expr": "prometheus_tsdb_head_series{instance=\"$instance\"}",
                  "format": "time_series",
                  "instant": false,
                  "intervalFactor": 2,
                  "refId": "A"
                }
              ],
              "thresholds": "500000,800000,1000000",
              "title": "Total count of time series",
              "type": "singlestat",
              "valueFontSize": "150%",
              "valueMaps": [
                {
                  "op": "=",
                  "text": "N/A",
                  "value": "null"
                }
              ],
              "valueName": "current"
            },
            {
              "cacheTimeout": null,
              "colorBackground": false,
              "colorValue": false,
              "colors": [
                "#299c46",
                "rgba(237, 129, 40, 0.89)",
                "#d44a3a"
              ],
              "datasource": "prometheus",
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "id": 48,
              "interval": null,
              "links": [],
              "mappingType": 1,
              "mappingTypes": [
                {
                  "name": "value to text",
                  "value": 1
                },
                {
                  "name": "range to text",
                  "value": 2
                }
              ],
              "maxDataPoints": 100,
              "nullPointMode": "connected",
              "nullText": null,
              "postfix": "",
              "postfixFontSize": "50%",
              "prefix": "",
              "prefixFontSize": "50%",
              "rangeMaps": [
                {
                  "from": "null",
                  "text": "N/A",
                  "to": "null"
                }
              ],
              "span": 2,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": false,
                "lineColor": "rgb(31, 120, 193)",
                "show": false
              },
              "tableColumn": "version",
              "targets": [
                {
                  "expr": "prometheus_build_info{instance=\"$instance\"}",
                  "format": "table",
                  "instant": true,
                  "intervalFactor": 2,
                  "refId": "A"
                }
              ],
              "thresholds": "",
              "title": "Version",
              "type": "singlestat",
              "valueFontSize": "80%",
              "valueMaps": [
                {
                  "op": "=",
                  "text": "N/A",
                  "value": "null"
                }
              ],
              "valueName": "avg"
            },
            {
              "cacheTimeout": null,
              "colorBackground": false,
              "colorValue": false,
              "colors": [
                "#299c46",
                "rgba(237, 129, 40, 0.89)",
                "#d44a3a"
              ],
              "datasource": "prometheus",
              "decimals": 2,
              "format": "ms",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "id": 49,
              "interval": null,
              "links": [],
              "mappingType": 1,
              "mappingTypes": [
                {
                  "name": "value to text",
                  "value": 1
                },
                {
                  "name": "range to text",
                  "value": 2
                }
              ],
              "maxDataPoints": 100,
              "nullPointMode": "connected",
              "nullText": null,
              "postfix": "",
              "postfixFontSize": "50%",
              "prefix": "",
              "prefixFontSize": "50%",
              "rangeMaps": [
                {
                  "from": "null",
                  "text": "N/A",
                  "to": "null"
                }
              ],
              "span": 2,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": false,
                "lineColor": "rgb(31, 120, 193)",
                "show": false
              },
              "tableColumn": "",
              "targets": [
                {
                  "expr": "prometheus_tsdb_head_max_time{instance=\"$instance\"} - prometheus_tsdb_head_min_time{instance=\"$instance\"}",
                  "format": "time_series",
                  "instant": true,
                  "intervalFactor": 2,
                  "refId": "A"
                }
              ],
              "thresholds": "",
              "title": "Actual head block length",
              "type": "singlestat",
              "valueFontSize": "80%",
              "valueMaps": [
                {
                  "op": "=",
                  "text": "N/A",
                  "value": "null"
                }
              ],
              "valueName": "current"
            },
            {
              "content": "<img src=\"https://cdn.worldvectorlogo.com/logos/prometheus.svg\"/ height=\"140px\">",
              "height": "",
              "id": 50,
              "links": [],
              "mode": "html",
              "span": 1,
              "title": "",
              "transparent": true,
              "type": "text"
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Header instance info",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": "250",
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 15,
              "legend": {
                "avg": true,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": true
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 4,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "max(prometheus_engine_query_duration_seconds{instance=\"$instance\"}) by (instance, slice)",
                  "format": "time_series",
                  "intervalFactor": 1,
                  "legendFormat": "max duration for {{ "{{" }}slice{{ "}}" }}",
                  "metric": "prometheus_local_storage_rushed_mode",
                  "refId": "A",
                  "step": 900
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Query elapsed time",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "label": "",
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 17,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(increase(prometheus_tsdb_head_series_created_total{instance=\"$instance\"}[$aggregation_interval])) by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "created on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_maintain_series_duration_seconds_count",
                  "refId": "A",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_tsdb_head_series_removed_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) * -1",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "removed on {{ "{{" }} instance {{ "}}" }}",
                  "refId": "B"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Head series created/deleted",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 13,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(increase(prometheus_target_scrapes_exceeded_sample_limit_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "exceeded_sample_limit on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "A",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_target_scrapes_sample_duplicate_timestamp_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "duplicate_timestamp on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "B",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_target_scrapes_sample_out_of_bounds_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "out_of_bounds on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "C",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_target_scrapes_sample_out_of_order_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "out_of_order on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "D",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_rule_evaluation_failures_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "rule_evaluation_failure on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "G",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_tsdb_compactions_failed_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "tsdb_compactions_failed on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "K",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_tsdb_reloads_failures_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "tsdb_reloads_failures on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "L",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_tsdb_head_series_not_found{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "head_series_not_found on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "N",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_evaluator_iterations_missed_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "evaluator_iterations_missed on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "O",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_evaluator_iterations_skipped_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "evaluator_iterations_skipped on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "P",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Prometheus errors",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Main info",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 250,
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "description": "",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "id": 25,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "max": true,
                "min": false,
                "show": false,
                "sort": "max",
                "sortDesc": true,
                "total": false,
                "values": true
              },
              "lines": true,
              "linewidth": 2,
              "links": [],
              "nullPointMode": "connected",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "prometheus_target_interval_length_seconds{instance=\"$instance\",quantile=\"0.99\"} - $scrape_interval",
                  "format": "time_series",
                  "interval": "2m",
                  "intervalFactor": 1,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 300
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Scrape delay (counts with 1m scrape interval)",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "cumulative"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 14,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [
                {
                  "alias": "Queue length",
                  "yaxis": 2
                }
              ],
              "spaceLength": 10,
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(prometheus_evaluator_duration_seconds{instance=\"$instance\"}) by (instance, quantile)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "Queue length",
                  "metric": "prometheus_local_storage_indexing_queue_length",
                  "refId": "B",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Rule evaulation duration",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": true,
          "title": "Scrape & rule duration",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 250,
          "panels": [
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 18,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(increase(http_requests_total{instance=\"$instance\"}[$aggregation_interval])) by (instance, handler) > 0",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} handler {{ "}}" }} on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Request count",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "none",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 16,
              "legend": {
                "avg": false,
                "current": false,
                "hideEmpty": true,
                "hideZero": true,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "max(sum(http_request_duration_microseconds{instance=\"$instance\"}) by (instance, handler, quantile)) by (instance, handler) > 0",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} handler {{ "}}" }} on {{ "{{" }} instance {{ "}}" }}",
                  "refId": "B"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Request duration per handler",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "µs",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 19,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(increase(http_request_size_bytes{instance=\"$instance\", quantile=\"0.99\"}[$aggregation_interval])) by (instance, handler) > 0",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} handler {{ "}}" }} in {{ "{{" }} instance {{ "}}" }}",
                  "refId": "B"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Request size by handler",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "bytes",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Allocated bytes": "#F9BA8F",
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max count collector": "#bf1b00",
                "Max count harvester": "#bf1b00",
                "Max to persist": "#3F6833",
                "RSS": "#890F02"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 8,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [
                {
                  "alias": "/Max.*/",
                  "fill": 0,
                  "linewidth": 2
                }
              ],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(prometheus_engine_queries{instance=\"$instance\"}) by (instance, handler)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "Current count ",
                  "metric": "last",
                  "refId": "A",
                  "step": 1800
                },
                {
                  "expr": "sum(prometheus_engine_queries_concurrent_max{instance=\"$instance\"}) by (instance, handler)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "Max count",
                  "metric": "last",
                  "refId": "B",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Cont of concurent queries",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": true,
          "title": "Requests & queries",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 250,
          "panels": [
            {
              "aliasColors": {
                "Alert queue capacity on o collector": "#bf1b00",
                "Alert queue capacity on o harvester": "#bf1b00",
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 20,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [
                {
                  "alias": "/.*capacity.*/",
                  "fill": 0,
                  "linewidth": 2
                }
              ],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(prometheus_notifications_queue_capacity{instance=\"$instance\"})by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "Alert queue capacity ",
                  "metric": "prometheus_local_storage_checkpoint_last_size_bytes",
                  "refId": "A",
                  "step": 1800
                },
                {
                  "expr": "sum(prometheus_notifications_queue_length{instance=\"$instance\"})by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "Alert queue size on ",
                  "metric": "prometheus_local_storage_checkpoint_last_size_bytes",
                  "refId": "B",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Alert queue size",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "bytes",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 21,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(prometheus_notifications_alertmanagers_discovered{instance=\"$instance\"}) by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "Checkpoint chunks written/s",
                  "metric": "prometheus_local_storage_checkpoint_series_chunks_written_sum",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Count of discovered alertmanagers",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "none",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 39,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(increase(prometheus_notifications_dropped_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "notifications_dropped on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "F",
                  "step": 1800
                },
                {
                  "expr": "sum(increase(prometheus_rule_evaluation_failures_total{rule_type=\"alerting\",instance=\"$instance\"}[$aggregation_interval])) by (rule_type,instance) > 0",
                  "format": "time_series",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "rule_evaluation_failures on {{ "{{" }} instance {{ "}}" }}",
                  "metric": "prometheus_local_storage_chunk_ops_total",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Alerting errors",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": true,
          "title": "Alerting",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 250,
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "fill": 1,
              "id": 36,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(increase(prometheus_tsdb_reloads_total{instance=\"$instance\"}[30m])) by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
                  "refId": "A"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Reloaded block from disk",
              "tooltip": {
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 5,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(prometheus_tsdb_blocks_loaded{instance=\"$instance\"}) by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "Loaded data blocks",
                  "metric": "prometheus_local_storage_memory_chunkdescs",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Loaded data blocks",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 3,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "prometheus_tsdb_head_series{instance=\"$instance\"}",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "Time series count",
                  "metric": "prometheus_local_storage_memory_series",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Time series total count",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 1,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(rate(prometheus_tsdb_head_samples_appended_total{instance=\"$instance\"}[$aggregation_interval])) by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "samples/s {{ "{{" }}instance{{ "}}" }}",
                  "metric": "prometheus_local_storage_ingested_samples_total",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Samples Appended per second",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": "",
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": true,
          "title": "TSDB stats",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 250,
          "panels": [
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833",
                "To persist": "#9AC48A"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 2,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [
                {
                  "alias": "/Max.*/",
                  "fill": 0
                }
              ],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(prometheus_tsdb_head_chunks{instance=\"$instance\"}) by (instance)",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "Head chunk count",
                  "metric": "prometheus_local_storage_memory_chunks",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Head chunks count",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "fill": 1,
              "id": 35,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "max(prometheus_tsdb_head_max_time{instance=\"$instance\"}) by (instance) - min(prometheus_tsdb_head_min_time{instance=\"$instance\"}) by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
                  "refId": "A"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Length of head block",
              "tooltip": {
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "ms",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 4,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(rate(prometheus_tsdb_head_chunks_created_total{instance=\"$instance\"}[$aggregation_interval])) by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "created on {{ "{{" }} instance {{ "}}" }}",
                  "refId": "B"
                },
                {
                  "expr": "sum(rate(prometheus_tsdb_head_chunks_removed_total{instance=\"$instance\"}[$aggregation_interval])) by (instance) * -1",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "deleted on {{ "{{" }} instance {{ "}}" }}",
                  "refId": "C"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Head Chunks Created/Deleted per second",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": true,
          "title": "Head block stats",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 250,
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "fill": 1,
              "id": 33,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "connected",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(increase(prometheus_tsdb_compaction_duration_sum{instance=\"$instance\"}[30m]) / increase(prometheus_tsdb_compaction_duration_count{instance=\"$instance\"}[30m])) by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
                  "refId": "B"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Compaction duration",
              "tooltip": {
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "fill": 1,
              "id": 34,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "connected",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(prometheus_tsdb_head_gc_duration_seconds{instance=\"$instance\"}) by (instance, quantile)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} quantile {{ "}}" }} on {{ "{{" }} instance {{ "}}" }}",
                  "refId": "A"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Go Garbage collection duration",
              "tooltip": {
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "fill": 1,
              "id": 37,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "connected",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(prometheus_tsdb_wal_truncate_duration_seconds{instance=\"$instance\"}) by (instance, quantile)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} quantile {{ "}}" }} on {{ "{{" }} instance {{ "}}" }}",
                  "refId": "A"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "WAL truncate duration seconds",
              "tooltip": {
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "fill": 1,
              "id": 38,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "connected",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(tsdb_wal_fsync_duration_seconds{instance=\"$instance\"}) by (instance, quantile)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} quantile {{ "}}" }} {{ "{{" }} instance {{ "}}" }}",
                  "refId": "A"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "WAL fsync duration seconds",
              "tooltip": {
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": true,
          "title": "Data maintenance",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 250,
          "panels": [
            {
              "aliasColors": {
                "Allocated bytes": "#7EB26D",
                "Allocated bytes - 1m max": "#BF1B00",
                "Allocated bytes - 1m min": "#BF1B00",
                "Allocated bytes - 5m max": "#BF1B00",
                "Allocated bytes - 5m min": "#BF1B00",
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833",
                "RSS": "#447EBC"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "decimals": null,
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 6,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [
                {
                  "alias": "/-/",
                  "fill": 0
                },
                {
                  "alias": "collector heap size",
                  "color": "#E0752D",
                  "fill": 0,
                  "linewidth": 2
                },
                {
                  "alias": "collector kubernetes memory limit",
                  "color": "#BF1B00",
                  "fill": 0,
                  "linewidth": 3
                }
              ],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(process_resident_memory_bytes{instance=\"$instance\"}) by (instance)",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "Total resident memory - {{ "{{" }}instance{{ "}}" }}",
                  "metric": "process_resident_memory_bytes",
                  "refId": "B",
                  "step": 1800
                },
                {
                  "expr": "sum(go_memstats_alloc_bytes{instance=\"$instance\"}) by (instance)",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "Total llocated bytes - {{ "{{" }}instance{{ "}}" }}",
                  "metric": "go_memstats_alloc_bytes",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Memory",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "bytes",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {
                "Allocated bytes": "#F9BA8F",
                "Chunks": "#1F78C1",
                "Chunks to persist": "#508642",
                "Max chunks": "#052B51",
                "Max to persist": "#3F6833",
                "RSS": "#890F02"
              },
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 7,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "rate(go_memstats_alloc_bytes_total{instance=\"$instance\"}[$aggregation_interval])",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "Allocated Bytes/s",
                  "metric": "go_memstats_alloc_bytes",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Allocations per second",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "bytes",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "decimals": 2,
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 9,
              "legend": {
                "alignAsTable": false,
                "avg": false,
                "current": false,
                "hideEmpty": false,
                "max": false,
                "min": false,
                "rightSide": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(rate(process_cpu_seconds_total{instance=\"$instance\"}[$aggregation_interval])) by (instance)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "CPU/s",
                  "metric": "prometheus_local_storage_ingested_samples_total",
                  "refId": "B",
                  "step": 1800
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "CPU per second",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "buckets": null,
                "mode": "time",
                "name": null,
                "show": true,
                "values": [
                  "avg"
                ]
              },
              "yaxes": [
                {
                  "format": "none",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": "0",
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": true,
          "title": "RAM&CPU",
          "titleSize": "h6"
        }
      ],
      "schemaVersion": 14,
      "style": "dark",
      "tags": [
        "prometheus"
      ],
      "templating": {
        "list": [
          {
            "auto": true,
            "auto_count": 30,
            "auto_min": "2m",
            "current": {
              "text": "auto",
              "value": "$__auto_interval"
            },
            "hide": 0,
            "label": "aggregation interval",
            "name": "aggregation_interval",
            "options": [
              {
                "selected": true,
                "text": "auto",
                "value": "$__auto_interval"
              },
              {
                "selected": false,
                "text": "1m",
                "value": "1m"
              },
              {
                "selected": false,
                "text": "10m",
                "value": "10m"
              },
              {
                "selected": false,
                "text": "30m",
                "value": "30m"
              },
              {
                "selected": false,
                "text": "1h",
                "value": "1h"
              },
              {
                "selected": false,
                "text": "6h",
                "value": "6h"
              },
              {
                "selected": false,
                "text": "12h",
                "value": "12h"
              },
              {
                "selected": false,
                "text": "1d",
                "value": "1d"
              }
            ],
            "query": "1m,10m,30m,1h,6h,12h,1d",
            "refresh": 2,
            "type": "interval"
          },
          {
            "allValue": null,
            "current": {},
            "datasource": "prometheus",
            "hide": 0,
            "includeAll": false,
            "label": "Instance",
            "multi": false,
            "name": "instance",
            "options": [],
            "query": "label_values(prometheus_build_info, instance)",
            "refresh": 2,
            "regex": "",
            "sort": 2,
            "tagValuesQuery": "",
            "tags": [],
            "tagsQuery": "",
            "type": "query",
            "useTags": false
          },
          {
            "current": {
              "value": "60",
              "text": "60"
            },
            "hide": 0,
            "label": "Scrape interval seconds",
            "name": "scrape_interval",
            "options": [
              {
                "value": "60",
                "text": "60"
              }
            ],
            "query": "60",
            "type": "constant"
          }
        ]
      },
      "time": {
        "from": "now-1d",
        "to": "now"
      },
      "timepicker": {
        "refresh_intervals": [
          "5s",
          "10s",
          "30s",
          "1m",
          "5m",
          "15m",
          "30m",
          "1h",
          "2h"
        ],
        "time_options": [
          "5m",
          "15m",
          "1h",
          "6h",
          "12h",
          "24h"
        ]
      },
      "timezone": "browser",
      "title": "Prometheus Stats",
      "version": 8
    }
{{- end }}
