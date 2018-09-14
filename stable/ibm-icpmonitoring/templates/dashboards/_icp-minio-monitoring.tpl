{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* ICP Minio Monitoring Dashboard File */}}
{{- define "ICPMinioMonitoring" }}
icp-minio-monitoring.json: |-
    {
      "__inputs": [
        {
          "name": "DS_PROMETHEUS",
          "label": "prometheus",
          "description": "",
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
          "version": "5.2.0"
        },
        {
          "type": "panel",
          "id": "graph",
          "name": "Graph",
          "version": "5.0.0"
        },
        {
          "type": "datasource",
          "id": "prometheus",
          "name": "Prometheus",
          "version": "5.0.0"
        },
        {
          "type": "panel",
          "id": "singlestat",
          "name": "Singlestat",
          "version": "5.0.0"
        },
        {
          "type": "panel",
          "id": "table",
          "name": "Table",
          "version": "5.0.0"
        }
      ],
      "annotations": {
        "list": [
          {
            "builtIn": 1,
            "datasource": "-- Grafana --",
            "enable": true,
            "hide": true,
            "iconColor": "rgba(0, 211, 255, 1)",
            "name": "Annotations & Alerts",
            "type": "dashboard"
          }
        ]
      },
      "editable": true,
      "gnetId": null,
      "graphTooltip": 0,
      "id": null,
      "links": [],
      "panels": [
        {
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 0
          },
          "id": 36,
          "title": "Availabilty Stats",
          "type": "row"
        },
        {
          "cacheTimeout": null,
          "colorBackground": true,
          "colorValue": false,
          "colors": [
            "#b7dbab",
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
          "gridPos": {
            "h": 6,
            "w": 24,
            "x": 0,
            "y": 1
          },
          "hideTimeOverride": true,
          "id": 34,
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
          "sparkline": {
            "fillColor": "rgba(31, 118, 189, 0.18)",
            "full": false,
            "lineColor": "rgb(31, 120, 193)",
            "show": false
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "count(minio_network_sent_bytes_total)",
              "format": "time_series",
              "intervalFactor": 1,
              "refId": "A"
            }
          ],
          "thresholds": "50",
          "timeFrom": "10s",
          "timeShift": "10s",
          "title": "Minio Servers Instances",
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
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 7
          },
          "id": 20,
          "panels": [],
          "repeat": null,
          "title": "Instance Details",
          "type": "row"
        },
        {
          "columns": [],
          "datasource": "prometheus",
          "fontSize": "100%",
          "gridPos": {
            "h": 5,
            "w": 12,
            "x": 0,
            "y": 8
          },
          "hideTimeOverride": true,
          "id": 38,
          "links": [],
          "pageSize": null,
          "scroll": true,
          "showHeader": true,
          "sort": {
            "col": 0,
            "desc": true
          },
          "styles": [
            {
              "alias": "Time",
              "dateFormat": "MMMM D, YYYY LT",
              "pattern": "Time",
              "type": "date"
            },
            {
              "alias": "",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "decimals": 2,
              "pattern": "__name__",
              "thresholds": [],
              "type": "hidden",
              "unit": "short"
            },
            {
              "alias": "",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "job",
              "thresholds": [],
              "type": "hidden",
              "unit": "short"
            },
            {
              "alias": "Server Mode",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 2,
              "pattern": "Value",
              "rangeMaps": [
                {
                  "from": "1",
                  "text": "Standalone",
                  "to": "1"
                },
                {
                  "from": "2",
                  "text": "Distributed",
                  "to": "1000"
                }
              ],
              "thresholds": [],
              "type": "string",
              "unit": "short",
              "valueMaps": [
                {
                  "text": "StandAlone",
                  "value": "1"
                },
                {
                  "text": "Distributed",
                  "value": ">2"
                }
              ]
            },
            {
              "alias": "Instance",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "instance",
              "thresholds": [],
              "type": "string",
              "unit": "short"
            }
          ],
          "targets": [
            {
              "expr": "minio_total_disks",
              "format": "time_series",
              "instant": true,
              "intervalFactor": 2,
              "legendFormat": "Instance: {{ "{{" }} instance {{ "}}" }}",
              "refId": "A"
            }
          ],
          "timeFrom": "10s",
          "timeShift": "10s",
          "title": "Instance mode (Distributed/Standalone)",
          "transform": "timeseries_to_rows",
          "type": "table"
        },
        {
          "columns": [],
          "datasource": "prometheus",
          "fontSize": "100%",
          "gridPos": {
            "h": 5,
            "w": 12,
            "x": 12,
            "y": 8
          },
          "hideTimeOverride": true,
          "id": 16,
          "links": [],
          "pageSize": null,
          "scroll": true,
          "showHeader": true,
          "sort": {
            "col": null,
            "desc": false
          },
          "styles": [
            {
              "alias": "Instance",
              "colorMode": null,
              "colors": [
                "#1f78c1",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "Metric",
              "preserveFormat": false,
              "sanitize": false,
              "thresholds": [],
              "type": "string",
              "unit": "short"
            },
            {
              "alias": "Disks",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": null,
              "pattern": "Value",
              "thresholds": [],
              "type": "number",
              "unit": "none"
            },
            {
              "alias": "Time",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "MMMM D, YYYY LT",
              "decimals": 2,
              "pattern": "Time",
              "thresholds": [],
              "type": "date",
              "unit": "dateTimeAsUS"
            }
          ],
          "targets": [
            {
              "expr": "minio_total_disks",
              "format": "time_series",
              "hide": false,
              "instant": true,
              "interval": "",
              "intervalFactor": 2,
              "legendFormat": "Instance: {{ "{{" }} instance {{ "}}" }}",
              "refId": "A"
            }
          ],
          "timeFrom": "5s",
          "title": "Disks Per Instance",
          "transform": "timeseries_to_rows",
          "type": "table"
        },
        {
          "columns": [],
          "datasource": "prometheus",
          "fontSize": "100%",
          "gridPos": {
            "h": 5,
            "w": 12,
            "x": 0,
            "y": 13
          },
          "hideTimeOverride": true,
          "id": 40,
          "links": [],
          "pageSize": null,
          "scroll": true,
          "showHeader": true,
          "sort": {
            "col": 0,
            "desc": true
          },
          "styles": [
            {
              "alias": "Time",
              "dateFormat": "MMMM D, YYYY LT",
              "pattern": "Time",
              "type": "date"
            },
            {
              "alias": "",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "decimals": 2,
              "pattern": "__name__",
              "thresholds": [],
              "type": "hidden",
              "unit": "short"
            },
            {
              "alias": "",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "job",
              "thresholds": [],
              "type": "hidden",
              "unit": "short"
            },
            {
              "alias": "Offline Disk",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": null,
              "mappingType": 1,
              "pattern": "Value",
              "thresholds": [],
              "type": "number",
              "unit": "none"
            }
          ],
          "targets": [
            {
              "expr": "minio_offline_disks",
              "format": "table",
              "instant": true,
              "intervalFactor": 1,
              "refId": "A"
            }
          ],
          "timeFrom": "10s",
          "timeShift": "10s",
          "title": "Offline Disks Per Instance",
          "transform": "table",
          "type": "table"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 18
          },
          "id": 22,
          "panels": [],
          "repeat": null,
          "title": "Storage And Network Details",
          "type": "row"
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "prometheus",
          "fill": 2,
          "gridPos": {
            "h": 6,
            "w": 24,
            "x": 0,
            "y": 19
          },
          "hideTimeOverride": true,
          "id": 24,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
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
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "minio_network_received_bytes_total",
              "format": "time_series",
              "hide": false,
              "intervalFactor": 1,
              "legendFormat": "Instance: {{ "{{" }} instance {{ "}}" }}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": "10s",
          "timeShift": "10s",
          "title": "Total number of bytes received by current server instance",
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
              "format": "decbytes",
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
              "show": false
            }
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "prometheus",
          "fill": 2,
          "gridPos": {
            "h": 6,
            "w": 24,
            "x": 0,
            "y": 25
          },
          "hideTimeOverride": true,
          "id": 28,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "null",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "minio_http_requests_duration_seconds_count",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "Instance: {{ "{{" }} instance {{ "}}" }}, Request: {{ "{{" }} request_type {{ "}}" }}", 
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": "10s",
          "timeShift": "10s",
          "title": "Count of current number of observations i.e. total HTTP requests",
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
            "show": false,
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
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "prometheus",
          "fill": 2,
          "gridPos": {
            "h": 6,
            "w": 24,
            "x": 0,
            "y": 31
          },
          "hideTimeOverride": true,
          "id": 30,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "total": false,
            "values": false
          },
          "lines": true,
          "linewidth": 2,
          "links": [],
          "nullPointMode": "null",
          "percentage": false,
          "pointradius": 5,
          "points": false,
          "renderer": "flot",
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "minio_network_sent_bytes_total",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "Instance: {{ "{{" }} instance {{ "}}" }}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": "10s",
          "timeShift": "10s",
          "title": "Total number of bytes sent by current server instance",
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
            "show": false,
            "values": []
          },
          "yaxes": [
            {
              "format": "decbytes",
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
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "columns": [],
          "datasource": "prometheus",
          "fontSize": "100%",
          "gridPos": {
            "h": 7,
            "w": 24,
            "x": 0,
            "y": 37
          },
          "hideTimeOverride": true,
          "id": 32,
          "links": [],
          "pageSize": 5,
          "scroll": true,
          "showHeader": true,
          "sort": {
            "col": 0,
            "desc": true
          },
          "styles": [
            {
              "alias": "Time",
              "dateFormat": "MMMM D, YYYY LT",
              "pattern": "Time",
              "type": "date"
            },
            {
              "alias": "",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "decimals": 2,
              "pattern": "__name__",
              "thresholds": [],
              "type": "hidden",
              "unit": "short"
            },
            {
              "alias": "Instance",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "instance",
              "thresholds": [],
              "type": "string",
              "unit": "short"
            },
            {
              "alias": "Request",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "request_type",
              "thresholds": [],
              "type": "string",
              "unit": "short"
            },
            {
              "alias": "",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "job",
              "thresholds": [],
              "type": "hidden",
              "unit": "s"
            },
            {
              "alias": "Time to Serve Request",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "Value",
              "thresholds": [],
              "type": "number",
              "unit": "dtdurations"
            }
          ],
          "targets": [
            {
              "expr": "minio_http_requests_duration_seconds_sum",
              "format": "table",
              "instant": true,
              "intervalFactor": 1,
              "legendFormat": "",
              "refId": "A"
            }
          ],
          "timeFrom": "10s",
          "timeShift": "10s",
          "title": "Current aggregate time spent servicing all HTTP requests",
          "transform": "table",
          "type": "table"
        },
        {
          "columns": [
            {
              "text": "Avg",
              "value": "avg"
            }
          ],
          "datasource": "prometheus",
          "fontSize": "100%",
          "gridPos": {
            "h": 7,
            "w": 24,
            "x": 0,
            "y": 44
          },
          "hideTimeOverride": true,
          "id": 26,
          "links": [],
          "pageSize": 5,
          "scroll": true,
          "showHeader": true,
          "sort": {
            "col": null,
            "desc": false
          },
          "styles": [
            {
              "alias": "Time",
              "dateFormat": "MMMM D, YYYY LT",
              "link": false,
              "pattern": "Time",
              "type": "date"
            },
            {
              "alias": "Metric",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "decimals": 2,
              "pattern": "__name__",
              "thresholds": [],
              "type": "hidden",
              "unit": "short"
            },
            {
              "alias": "",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "le",
              "thresholds": [],
              "type": "number",
              "unit": "short"
            },
            {
              "alias": "Request",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "request_type",
              "thresholds": [],
              "type": "string",
              "unit": "short"
            },
            {
              "alias": "Instance Name",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "instance",
              "preserveFormat": false,
              "thresholds": [],
              "type": "string",
              "unit": "short"
            },
            {
              "alias": "",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "job",
              "thresholds": [],
              "type": "hidden",
              "unit": "short"
            },
            {
              "alias": "Request Count",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": null,
              "mappingType": 1,
              "pattern": "Value",
              "thresholds": [],
              "type": "number",
              "unit": "none"
            }
          ],
          "targets": [
            {
              "expr": "minio_http_requests_duration_seconds_bucket",
              "format": "table",
              "instant": true,
              "intervalFactor": 1,
              "refId": "A"
            }
          ],
          "timeFrom": "10s",
          "timeShift": "10s",
          "title": "Cumulative counters for all the Request types in different Time Brackets",
          "transform": "table",
          "type": "table"
        }
      ],
      "refresh": "5s",
      "schemaVersion": 16,
      "style": "dark",
      "tags": [],
      "templating": {
        "list": []
      },
      "time": {
        "from": "now-5m",
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
      "timezone": "",
      "title": "Storage Minio Health",
      "version": 1
    }
{{- end }}
