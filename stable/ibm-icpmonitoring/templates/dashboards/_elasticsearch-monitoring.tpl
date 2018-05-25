{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* Elasticsearch Monitoring Dashboard File */}}
{{- define "elasticsearchMonitoring" }}
elasticsearch-metrics.json: |-
    {
      "__inputs": [
        {
          "name": "DS_PROMETHEUS",
          "label": "Prometheus",
          "description": "",
          "type": "datasource",
          "pluginId": "prometheus",
          "pluginName": "Prometheus"
        }
      ],
      "__requires": [
        {
          "type": "panel",
          "id": "singlestat",
          "name": "Singlestat",
          "version": ""
        },
        {
          "type": "panel",
          "id": "graph",
          "name": "Graph",
          "version": ""
        },
        {
          "type": "grafana",
          "id": "grafana",
          "name": "Grafana",
          "version": "4.0.2"
        },
        {
          "type": "datasource",
          "id": "prometheus",
          "name": "Prometheus",
          "version": "1.0.0"
        }
      ],
      "id": null,
      "title": "ElasticSearch",
      "tags": [
        "elasticsearch"
      ],
      "style": "dark",
      "timezone": "browser",
      "editable": true,
      "sharedCrosshair": true,
      "hideControls": true,
      "time": {
        "from": "now-30m",
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
          "2h",
          "1d"
        ],
        "time_options": [
          "5m",
          "15m",
          "1h",
          "6h",
          "12h",
          "24h",
          "2d",
          "7d",
          "30d"
        ]
      },
      "templating": {
        "list": [
          {
            "auto": true,
            "auto_count": 30,
            "auto_min": "10s",
            "current": {
              "text": "auto",
              "value": "$__auto_interval"
            },
            "hide": 0,
            "label": "Interval",
            "name": "interval",
            "options": [
              {
                "text": "auto",
                "value": "$__auto_interval",
                "selected": true
              },
              {
                "text": "1m",
                "value": "1m",
                "selected": false
              },
              {
                "text": "5m",
                "value": "5m",
                "selected": false
              },
              {
                "text": "10m",
                "value": "10m",
                "selected": false
              },
              {
                "text": "30m",
                "value": "30m",
                "selected": false
              },
              {
                "text": "1h",
                "value": "1h",
                "selected": false
              },
              {
                "text": "6h",
                "value": "6h",
                "selected": false
              },
              {
                "text": "12h",
                "value": "12h",
                "selected": false
              },
              {
                "text": "1d",
                "value": "1d",
                "selected": false
              }
            ],
            "query": "1m,5m,10m,30m,1h,6h,12h,1d",
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
            "query": "label_values(elasticsearch_node_stats_up,instance)",
            "refresh": 1,
            "regex": "",
            "sort": 1,
            "tagValuesQuery": null,
            "tagsQuery": null,
            "type": "query"
          }
        ]
      },
      "annotations": {
        "list": []
      },
      "refresh": "1m",
      "schemaVersion": 13,
      "version": 90,
      "links": [],
      "gnetId": 2322,
      "rows": [
        {
          "title": "Cluster",
          "panels": [
            {
              "cacheTimeout": null,
              "colorBackground": true,
              "colorValue": false,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(178, 49, 13, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "50",
              "id": 8,
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
              "span": 5,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": true,
                "lineColor": "rgb(31, 120, 193)",
                "show": true
              },
              "targets": [
                {
                  "expr": "elasticsearch_cluster_health_up{instance=\"$instance\"}",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "metric": "",
                  "refId": "A",
                  "step": 40
                }
              ],
              "thresholds": "0,1",
              "title": "Cluster health status",
              "transparent": false,
              "type": "singlestat",
              "valueFontSize": "80%",
              "valueMaps": [
                {
                  "op": "=",
                  "text": "GREEN",
                  "value": "1"
                },
                {
                  "op": "=",
                  "text": "RED",
                  "value": "0"
                }
              ],
              "valueName": "current"
            },
            {
              "cacheTimeout": null,
              "colorBackground": false,
              "colorValue": false,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "50",
              "id": 10,
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
              "targets": [
                {
                  "expr": "elasticsearch_cluster_health_number_of_data_nodes{instance=\"$instance\"}",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "metric": "",
                  "refId": "A",
                  "step": 40
                }
              ],
              "thresholds": "",
              "title": "Nodes",
              "transparent": false,
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
              "colorValue": false,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "50",
              "id": 9,
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
              "targets": [
                {
                  "expr": "elasticsearch_cluster_health_number_of_data_nodes{instance=\"$instance\"}",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "metric": "",
                  "refId": "A",
                  "step": 40
                }
              ],
              "thresholds": "",
              "title": "Data nodes",
              "transparent": false,
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
              "colorValue": false,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "50",
              "hideTimeOverride": true,
              "id": 16,
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
              "span": 3,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": false,
                "lineColor": "rgb(31, 120, 193)",
                "show": true
              },
              "targets": [
                {
                  "expr": "elasticsearch_cluster_health_number_of_pending_tasks{instance=\"$instance\"}",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "metric": "",
                  "refId": "A",
                  "step": 40
                }
              ],
              "thresholds": "",
              "title": "Pending tasks",
              "transparent": false,
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
            }
          ],
          "showTitle": true,
          "titleSize": "h6",
          "height": null,
          "repeat": null,
          "repeatRowId": null,
          "repeatIteration": null,
          "collapse": false
        },
        {
          "title": "Shards",
          "panels": [
            {
              "cacheTimeout": null,
              "colorBackground": false,
              "colorValue": false,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "50",
              "id": 11,
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
              "minSpan": 2,
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
              "repeat": "shard_type",
              "span": 2.4,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": true,
                "lineColor": "rgb(31, 120, 193)",
                "show": true
              },
              "targets": [
                {
                  "expr": "elasticsearch_cluster_health_active_primary_shards{instance=\"$instance\"}",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "A",
                  "step": 40
                }
              ],
              "thresholds": "",
              "title": "active primary shards",
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
              "colorValue": false,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "50",
              "id": 39,
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
              "minSpan": 2,
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
              "span": 2.4,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": true,
                "lineColor": "rgb(31, 120, 193)",
                "show": true
              },
              "targets": [
                {
                  "expr": "elasticsearch_cluster_health_active_shards{instance=\"$instance\"}",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "A",
                  "step": 40
                }
              ],
              "thresholds": "",
              "title": "active shards",
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
              "colorValue": false,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "50",
              "id": 40,
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
              "minSpan": 2,
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
              "span": 2.4,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": true,
                "lineColor": "rgb(31, 120, 193)",
                "show": true
              },
              "targets": [
                {
                  "expr": "elasticsearch_cluster_health_initializing_shards{instance=\"$instance\"}",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "A",
                  "step": 40
                }
              ],
              "thresholds": "",
              "title": "initializing shards",
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
              "colorValue": false,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "50",
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
              "minSpan": 2,
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
              "span": 2.4,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": true,
                "lineColor": "rgb(31, 120, 193)",
                "show": true
              },
              "targets": [
                {
                  "expr": "elasticsearch_cluster_health_relocating_shards{instance=\"$instance\"}",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "A",
                  "step": 40
                }
              ],
              "thresholds": "",
              "title": "relocating shards",
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
              "colorValue": false,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "50",
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
              "minSpan": 2,
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
              "span": 2.4,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": true,
                "lineColor": "rgb(31, 120, 193)",
                "show": true
              },
              "targets": [
                {
                  "expr": "elasticsearch_cluster_health_delayed_unassigned_shards{instance=\"$instance\"}",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "A",
                  "step": 40
                }
              ],
              "thresholds": "",
              "title": "unassigned shards",
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
            }
          ],
          "showTitle": true,
          "titleSize": "h6",
          "height": "",
          "repeat": null,
          "repeatRowId": null,
          "repeatIteration": null,
          "collapse": false
        },
        {
          "title": "System",
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 30,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "elasticsearch_process_cpu_percent{instance=\"$instance\"}",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "CPU usage",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "percent",
                  "label": "CPU usage",
                  "logBase": 1,
                  "max": 100,
                  "min": 0,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 0,
              "grid": {},
              "height": "400",
              "id": 31,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "sortDesc": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "elasticsearch_jvm_memory_used_bytes{instance=\"$instance\",job=\"elasticsearch\"}",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "used: {{ "{{" }}area{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                },
                {
                  "expr": "elasticsearch_jvm_memory_committed_bytes{instance=\"$instance\",job=\"elasticsearch\"}",
                  "intervalFactor": 2,
                  "legendFormat": "committed: {{ "{{" }}area{{ "}}" }}",
                  "refId": "B",
                  "step": 10
                },
                {
                  "expr": "elasticsearch_jvm_memory_max_bytes{instance=\"$instance\"}",
                  "intervalFactor": 2,
                  "legendFormat": "max: {{ "{{" }}area{{ "}}" }}",
                  "refId": "C",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "JVM memory usage",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "bytes",
                  "label": "Memory",
                  "logBase": 1,
                  "max": null,
                  "min": 0,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 32,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "1-(elasticsearch_filesystem_data_available_bytes{instance=\"$instance\"}/elasticsearch_filesystem_data_size_bytes{instance=\"$instance\"})",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}path{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [
                {
                  "colorMode": "custom",
                  "fill": true,
                  "fillColor": "rgba(216, 200, 27, 0.27)",
                  "op": "gt",
                  "value": 0.8
                },
                {
                  "colorMode": "custom",
                  "fill": true,
                  "fillColor": "rgba(234, 112, 112, 0.22)",
                  "op": "gt",
                  "value": 0.9
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "Disk usage",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "percentunit",
                  "label": "Disk Usage %",
                  "logBase": 1,
                  "max": 1,
                  "min": 0,
                  "show": true
                },
                {
                  "format": "short",
                  "label": null,
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 47,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "sort": "max",
                "sortDesc": true,
                "total": false,
                "values": true
              },
              "lines": true,
              "linewidth": 1,
              "links": [],
              "nullPointMode": "connected",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [
                {
                  "alias": "sent",
                  "transform": "negative-Y"
                }
              ],
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "irate(elasticsearch_transport_tx_size_bytes_total{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "legendFormat": "sent",
                  "refId": "D",
                  "step": 10
                },
                {
                  "expr": "irate(elasticsearch_transport_rx_size_bytes_total{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "legendFormat": "received",
                  "refId": "C",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Network usage",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "Bps",
                  "label": "Bytes/sec",
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "pps",
                  "label": "",
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": false
                }
              ]
            }
          ],
          "showTitle": true,
          "titleSize": "h6",
          "height": null,
          "repeat": null,
          "repeatRowId": null,
          "repeatIteration": null,
          "collapse": false
        },
        {
          "title": "Documents",
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 1,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "elasticsearch_indices_docs{instance=\"$instance\"}",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Documents count",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": "Documents",
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
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 24,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "irate(elasticsearch_indices_indexing_index_total{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Documents indexed rate",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": "index calls/s",
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
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 25,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "rate(elasticsearch_indices_docs_deleted{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Documents deleted rate",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": "Documents/s",
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
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 26,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "rate(elasticsearch_indices_merges_total{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Documents merged rate",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": "Documents/s",
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
                  "show": false
                }
              ]
            }
          ],
          "showTitle": true,
          "titleSize": "h6",
          "height": "",
          "repeat": null,
          "repeatRowId": null,
          "repeatIteration": null,
          "collapse": false
        },
        {
          "title": "Total Operations stats",
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 48,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true,
                "sortDesc": true,
                "sort": "avg"
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
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "irate(elasticsearch_indices_indexing_index_total{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "indexing",
                  "metric": "",
                  "refId": "A",
                  "step": 4
                },
                {
                  "expr": "irate(elasticsearch_indices_search_query_total{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "refId": "B",
                  "step": 4,
                  "legendFormat": "query"
                },
                {
                  "expr": "irate(elasticsearch_indices_search_fetch_total{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "refId": "C",
                  "step": 4,
                  "legendFormat": "fetch"
                },
                {
                  "expr": "irate(elasticsearch_indices_merges_total{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "refId": "D",
                  "step": 4,
                  "legendFormat": "merges"
                },
                {
                  "expr": "irate(elasticsearch_indices_refresh_total{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "refId": "E",
                  "step": 4,
                  "legendFormat": "refresh"
                },
                {
                  "expr": "irate(elasticsearch_indices_flush_total{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "refId": "F",
                  "step": 4,
                  "legendFormat": "flush"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Total Operations  rate",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": "Operations/s",
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
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 49,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true,
                "sortDesc": true,
                "sort": "avg"
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
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "irate(elasticsearch_indices_indexing_index_time_seconds_total{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "indexing",
                  "metric": "",
                  "refId": "A",
                  "step": 4
                },
                {
                  "expr": "irate(elasticsearch_indices_search_query_time_seconds{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "refId": "B",
                  "step": 4,
                  "legendFormat": "query"
                },
                {
                  "expr": "irate(elasticsearch_indices_search_fetch_time_seconds{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "refId": "C",
                  "step": 4,
                  "legendFormat": "fetch"
                },
                {
                  "expr": "irate(elasticsearch_indices_merges_total_time_seconds_total{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "refId": "D",
                  "step": 4,
                  "legendFormat": "merges"
                },
                {
                  "expr": "irate(elasticsearch_indices_refresh_time_seconds_total{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "refId": "E",
                  "step": 4,
                  "legendFormat": "refresh"
                },
                {
                  "expr": "irate(elasticsearch_indices_flush_time_seconds{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "refId": "F",
                  "step": 4,
                  "legendFormat": "flush"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Total Operations  time",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "label": "Time",
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
                  "show": false
                }
              ]
            }
          ],
          "showTitle": true,
          "titleSize": "h6",
          "height": 250,
          "repeat": null,
          "repeatRowId": null,
          "repeatIteration": null,
          "collapse": false
        },
        {
          "title": "Times",
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 33,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "rate(elasticsearch_indices_search_query_time_seconds{instance=\"$instance\"}[$interval]) ",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 4
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Query time",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "label": "Time",
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
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 5,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "rate(elasticsearch_indices_indexing_index_time_seconds_total{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 4
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Indexing time",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "label": "Time",
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
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 3,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "rate(elasticsearch_indices_merges_total_time_seconds_total{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 4
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Merging time",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "label": "Time",
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
                  "show": false
                }
              ]
            }
          ],
          "showTitle": true,
          "titleSize": "h6",
          "height": "",
          "repeat": null,
          "repeatRowId": null,
          "repeatIteration": null,
          "collapse": false
        },
        {
          "title": "Caches",
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 4,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "elasticsearch_indices_fielddata_memory_size_bytes{instance=\"$instance\"}",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Field data memory size",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "bytes",
                  "label": "Memory",
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
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 34,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "rate(elasticsearch_indices_fielddata_evictions{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Field data evictions",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": "Evictions/s",
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
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 35,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "elasticsearch_indices_query_cache_memory_size_bytes{instance=\"$instance\"}",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Query cache size",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "bytes",
                  "label": "Size",
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
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 36,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "rate(elasticsearch_indices_query_cache_evictions{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Query cache evictions",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": "Evictions/s",
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
                  "show": false
                }
              ]
            }
          ],
          "showTitle": true,
          "titleSize": "h6",
          "height": null,
          "repeat": null,
          "repeatRowId": null,
          "repeatIteration": null,
          "collapse": false
        },
        {
          "title": "Thread Pool",
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 45,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": false,
                "max": true,
                "min": true,
                "show": true,
                "sort": "avg",
                "sortDesc": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "irate(elasticsearch_thread_pool_rejected_count{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} type {{ "}}" }}",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Thread Pool operations rejected",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
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
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 46,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": false,
                "max": true,
                "min": true,
                "show": true,
                "sort": "avg",
                "sortDesc": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "elasticsearch_thread_pool_active_count{instance=\"$instance\"}",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} type {{ "}}" }}",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Thread Pool operations queued",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
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
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "height": "",
              "id": 43,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": false,
                "max": true,
                "min": true,
                "show": true,
                "sort": "avg",
                "sortDesc": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "elasticsearch_thread_pool_active_count{instance=\"$instance\"}",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} type {{ "}}" }}",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Thread Pool threads active",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
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
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "id": 44,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": false,
                "max": true,
                "min": true,
                "show": true,
                "sort": "avg",
                "sortDesc": true,
                "total": false,
                "values": true
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
              "span": 3,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "irate(elasticsearch_thread_pool_completed_count{instance=\"$instance\"}[$interval])",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} type {{ "}}" }}",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Thread Pool operations completed",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 2,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
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
          "showTitle": true,
          "titleSize": "h6",
          "height": 728,
          "repeat": null,
          "repeatRowId": null,
          "repeatIteration": null,
          "collapse": false
        },
        {
          "title": "JVM Garbage Collection",
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 7,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 6,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "rate(elasticsearch_jvm_gc_collection_seconds_count{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }} - {{ "{{" }}gc{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 4
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "GC count",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "short",
                  "label": "GCs",
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
                  "show": false
                }
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "400",
              "id": 27,
              "legend": {
                "alignAsTable": true,
                "avg": true,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": true,
                "min": true,
                "rightSide": false,
                "show": true,
                "total": false,
                "values": true
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
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "rate(elasticsearch_jvm_gc_collection_seconds_count{instance=\"$instance\"}[$interval])",
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }} - {{ "{{" }}gc{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 4
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "GC time",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "mode": "time",
                "name": null,
                "show": true,
                "values": []
              },
              "yaxes": [
                {
                  "format": "s",
                  "label": "Time",
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
                  "show": false
                }
              ]
            }
          ],
          "showTitle": true,
          "titleSize": "h6",
          "height": null,
          "repeat": null,
          "repeatRowId": null,
          "repeatIteration": null,
          "collapse": false
        }
      ],
      "description": "ElasticSearch metrics"
    }
{{- end }}
