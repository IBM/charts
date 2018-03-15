{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* ICP Performance Monitoring Dashboard File */}}
{{- define "ICPPerformanceMonitoring" }}
ICP2.1-Performance.json: |-
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
          "version": "4.4.3"
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
          "id": "table",
          "name": "Table",
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
      "description": "Monitors ICP cluster using Prometheus. Shows overall Metrics Summary (High Level KPIs , Container, Pod CPU and Memory.",
      "editable": true,
      "gnetId": 315,
      "graphTooltip": 0,
      "hideControls": false,
      "id": null,
      "links": [
        {
          "icon": "external link",
          "tags": [],
          "targetBlank": true,
          "title": "Kibana",
          "type": "link",
          "url": "https://<icp_IP_address>:8443/kibana"
        },
        {
          "asDropdown": true,
          "icon": "external link",
          "includeVars": false,
          "keepTime": true,
          "tags": [],
          "targetBlank": true,
          "title": "DashBoards",
          "type": "dashboards"
        }
      ],
      "refresh": false,
      "rows": [
        {
          "collapse": false,
          "height": 98,
          "panels": [
            {
              "cacheTimeout": null,
              "colorBackground": false,
              "colorValue": false,
              "colors": [
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": null,
              "editable": true,
              "error": false,
              "format": "s",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "1px",
              "id": 33,
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
              "postfixFontSize": "20%",
              "prefix": "",
              "prefixFontSize": "20%",
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
                  "expr": "time() - max(node_boot_time{instance=~\".*\"})",
                  "format": "time_series",
                  "hide": false,
                  "interval": "15m",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": "",
              "title": "Youngest Node Uptime",
              "type": "singlestat",
              "valueFontSize": "50%",
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
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": 2,
              "editable": true,
              "error": false,
              "format": "bytes",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "1px",
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
              "postfixFontSize": "20%",
              "prefix": "",
              "prefixFontSize": "20%",
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
                  "expr": "sum(node_memory_MemTotal)",
                  "format": "time_series",
                  "hide": false,
                  "interval": "10s",
                  "intervalFactor": 1,
                  "legendFormat": "",
                  "refId": "A",
                  "step": 30
                }
              ],
              "thresholds": "",
              "title": "Total memory",
              "type": "singlestat",
              "valueFontSize": "50%",
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
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": 2,
              "editable": true,
              "error": false,
              "format": "bytes",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "1px",
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
              "tableColumn": "",
              "targets": [
                {
                  "expr": "sum(node_memory_MemAvailable)",
                  "format": "time_series",
                  "hide": false,
                  "interval": "10s",
                  "intervalFactor": 1,
                  "refId": "A",
                  "step": 30
                }
              ],
              "thresholds": "",
              "title": "Available Memory",
              "type": "singlestat",
              "valueFontSize": "50%",
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
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "datasource": "prometheus",
              "format": "percent",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
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
                  "expr": " sum(node_memory_MemAvailable) / sum(node_memory_MemTotal) * 100",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "refId": "A",
                  "step": 60
                }
              ],
              "thresholds": "10,20",
              "title": "Memory Free",
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
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": null,
              "format": "percent",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "id": 46,
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
                  "expr": "sum (rate (container_cpu_usage_seconds_total{id=\"/\"}[15m])) / sum (machine_cpu_cores) * 100",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "refId": "A",
                  "step": 60
                }
              ],
              "thresholds": "75,90",
              "title": "ICP Total CPU 15 Minute Average",
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
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": null,
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
              "height": "1px",
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
              "nullPointMode": "connected",
              "nullText": null,
              "postfix": "",
              "postfixFontSize": "30%",
              "prefix": "",
              "prefixFontSize": "50%",
              "rangeMaps": [
                {
                  "from": "null",
                  "text": "N/A",
                  "to": "null"
                }
              ],
              "span": 1,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": false,
                "lineColor": "rgb(31, 120, 193)",
                "show": false
              },
              "tableColumn": "",
              "targets": [
                {
                  "expr": "avg(machine_cpu_cores)",
                  "format": "time_series",
                  "hide": false,
                  "interval": "1s",
                  "intervalFactor": 1,
                  "legendFormat": "",
                  "metric": "machine_cpu_cores",
                  "refId": "A",
                  "step": 30
                }
              ],
              "thresholds": "",
              "title": "Avg. Machine Cores",
              "type": "singlestat",
              "valueFontSize": "50%",
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
              "content": "#####   Visit the CSMO-ICP  Git Hub Page.      ",
              "id": 43,
              "links": [
                {
                  "targetBlank": true,
                  "title": "CSMO-ICP",
                  "type": "absolute",
                  "url": "https://ibm.biz/BdjCrN"
                }
              ],
              "mode": "markdown",
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
          "title": "ICP Usage Summary One",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 127,
          "panels": [
            {
              "cacheTimeout": null,
              "colorBackground": false,
              "colorValue": false,
              "colors": [
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": null,
              "editable": true,
              "error": false,
              "format": "s",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "1px",
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
              "nullPointMode": "connected",
              "nullText": null,
              "postfix": "",
              "postfixFontSize": "20%",
              "prefix": "",
              "prefixFontSize": "20%",
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
                  "expr": "time() - min(node_boot_time{instance=~\".*\"})",
                  "format": "time_series",
                  "hide": false,
                  "interval": "15m",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": "",
              "title": "Oldest Node Uptime",
              "type": "singlestat",
              "valueFontSize": "50%",
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
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": 2,
              "editable": true,
              "error": false,
              "format": "bytes",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "1px",
              "id": 14,
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
                  "expr": "sum(node_filesystem_size)",
                  "format": "time_series",
                  "hide": false,
                  "interval": "10s",
                  "intervalFactor": 1,
                  "legendFormat": "",
                  "metric": "container_fs_limit_bytes",
                  "refId": "A",
                  "step": 30
                }
              ],
              "thresholds": "",
              "title": "Total Disk Space",
              "type": "singlestat",
              "valueFontSize": "50%",
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
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": 2,
              "editable": true,
              "error": false,
              "format": "bytes",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "1px",
              "id": 13,
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
                  "expr": "sum(node_filesystem_free)",
                  "format": "time_series",
                  "hide": false,
                  "interval": "10s",
                  "intervalFactor": 1,
                  "refId": "A",
                  "step": 30
                }
              ],
              "thresholds": "",
              "title": "Disk Space Available",
              "type": "singlestat",
              "valueFontSize": "50%",
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
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": 1,
              "editable": true,
              "error": false,
              "format": "percentunit",
              "gauge": {
                "maxValue": 1,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "height": "100px",
              "hideTimeOverride": false,
              "id": 7,
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
                  "expr": "min((node_filesystem_size{fstype=~\"xfs|ext4\"} - node_filesystem_free{fstype=~\"xfs|ext4\"} )/ node_filesystem_size{fstype=~\"xfs|ext4\"})",
                  "format": "time_series",
                  "hide": false,
                  "interval": "15m",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "metric": "",
                  "refId": "A",
                  "step": 1800
                }
              ],
              "thresholds": "0.75, 0.90",
              "title": "Disk Space Used",
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
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": null,
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
              "height": "1px",
              "id": 32,
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
              "postfixFontSize": "30%",
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
                  "expr": "count(rate(container_last_seen{name=~\".+\"}[5m]))",
                  "format": "time_series",
                  "hide": false,
                  "interval": "10s",
                  "intervalFactor": 1,
                  "metric": "kubelet_running_pod_count",
                  "refId": "A",
                  "step": 30
                }
              ],
              "thresholds": "",
              "title": "Active Containers Last 5 min",
              "type": "singlestat",
              "valueFontSize": "50%",
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
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": null,
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
              "height": "1px",
              "id": 12,
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
              "postfixFontSize": "30%",
              "prefix": "",
              "prefixFontSize": "50%",
              "rangeMaps": [
                {
                  "from": "null",
                  "text": "N/A",
                  "to": "null"
                }
              ],
              "span": 1,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": false,
                "lineColor": "rgb(31, 120, 193)",
                "show": false
              },
              "tableColumn": "",
              "targets": [
                {
                  "expr": "sum(kubelet_running_pod_count) ",
                  "format": "time_series",
                  "hide": false,
                  "interval": "10s",
                  "intervalFactor": 1,
                  "metric": "kubelet_running_pod_count",
                  "refId": "A",
                  "step": 30
                }
              ],
              "thresholds": "",
              "title": "Active Pods",
              "type": "singlestat",
              "valueFontSize": "50%",
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
                "rgba(50, 172, 45, 0.97)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(245, 54, 54, 0.9)"
              ],
              "datasource": "prometheus",
              "decimals": null,
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
              "height": "1px",
              "id": 31,
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
              "postfixFontSize": "30%",
              "prefix": "",
              "prefixFontSize": "50%",
              "rangeMaps": [
                {
                  "from": "null",
                  "text": "N/A",
                  "to": "null"
                }
              ],
              "span": 1,
              "sparkline": {
                "fillColor": "rgba(31, 118, 189, 0.18)",
                "full": false,
                "lineColor": "rgb(31, 120, 193)",
                "show": false
              },
              "tableColumn": "",
              "targets": [
                {
                  "expr": "sum(kube_node_info)",
                  "format": "time_series",
                  "hide": false,
                  "interval": "10s",
                  "intervalFactor": 1,
                  "legendFormat": "",
                  "metric": "machine_cpu_cores",
                  "refId": "A",
                  "step": 30
                }
              ],
              "thresholds": "",
              "title": "ICP Node Count",
              "type": "singlestat",
              "valueFontSize": "50%",
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
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "ICP Usage Summary Two",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 354,
          "panels": [
            {
              "columns": [],
              "datasource": "prometheus",
              "fontSize": "100%",
              "hideTimeOverride": true,
              "id": 35,
              "links": [],
              "minSpan": 1,
              "pageSize": 5,
              "scroll": true,
              "showHeader": true,
              "sort": {
                "col": 3,
                "desc": false
              },
              "span": 2,
              "styles": [
                {
                  "alias": "Time",
                  "dateFormat": "YYYY-MM-DD HH:mm:ss",
                  "pattern": "Time",
                  "type": "hidden"
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
                  "pattern": "app",
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
                  "pattern": "component",
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
                  "pattern": "job",
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
                  "pattern": "kubernetes_namespace",
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
                  "pattern": "kubernetes_name",
                  "thresholds": [],
                  "type": "hidden",
                  "unit": "short"
                },
                {
                  "alias": "Percent",
                  "colorMode": "cell",
                  "colors": [
                    "rgba(50, 172, 45, 0.97)",
                    "rgba(237, 129, 40, 0.89)",
                    "rgba(245, 54, 54, 0.9)"
                  ],
                  "dateFormat": "YYYY-MM-DD HH:mm:ss",
                  "decimals": 2,
                  "pattern": "Value",
                  "thresholds": [
                    "70",
                    "90"
                  ],
                  "type": "number",
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
                  "decimals": 2,
                  "pattern": "/.*/",
                  "thresholds": [],
                  "type": "number",
                  "unit": "short"
                }
              ],
              "targets": [
                {
                  "expr": "((node_memory_MemTotal - node_memory_MemAvailable) / node_memory_MemTotal) * 100",
                  "format": "table",
                  "hide": false,
                  "interval": "1s",
                  "intervalFactor": 2,
                  "refId": "A",
                  "step": 2
                }
              ],
              "timeFrom": "1s",
              "title": "Memory by node",
              "transform": "table",
              "transparent": false,
              "type": "table"
            },
            {
              "columns": [],
              "fontSize": "100%",
              "hideTimeOverride": true,
              "id": 37,
              "links": [],
              "minSpan": 5,
              "pageSize": 5,
              "scroll": true,
              "showHeader": true,
              "sort": {
                "col": 3,
                "desc": true
              },
              "span": 5,
              "styles": [
                {
                  "alias": "Time",
                  "dateFormat": "YYYY-MM-DD HH:mm:ss",
                  "pattern": "Time",
                  "type": "hidden"
                },
                {
                  "alias": "",
                  "colorMode": null,
                  "colors": [
                    "rgba(50, 172, 45, 0.97)",
                    "rgba(237, 129, 40, 0.89)",
                    "rgba(245, 54, 54, 0.9)"
                  ],
                  "dateFormat": "YYYY-MM-DD HH:mm:ss",
                  "decimals": 2,
                  "pattern": "",
                  "thresholds": [
                    ""
                  ],
                  "type": "number",
                  "unit": "short"
                },
                {
                  "alias": "utilization",
                  "colorMode": "cell",
                  "colors": [
                    "rgba(50, 172, 45, 0.97)",
                    "rgba(237, 129, 40, 0.89)",
                    "rgba(245, 54, 54, 0.9)"
                  ],
                  "dateFormat": "YYYY-MM-DD HH:mm:ss",
                  "decimals": 2,
                  "pattern": "Value",
                  "thresholds": [
                    "70",
                    "80"
                  ],
                  "type": "number",
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
                  "decimals": 2,
                  "pattern": "/.*/",
                  "thresholds": [],
                  "type": "number",
                  "unit": "short"
                }
              ],
              "targets": [
                {
                  "expr": "topk(5,  sum(rate(container_cpu_usage_seconds_total{name=~\".+\"}[5m])) by (name,namespace)) * 100",
                  "format": "table",
                  "hide": false,
                  "interval": "1s",
                  "intervalFactor": 5,
                  "legendFormat": " ",
                  "metric": "",
                  "refId": "A",
                  "step": 5
                }
              ],
              "timeFrom": "1s",
              "timeShift": null,
              "title": "Top 5 Containers by CPU",
              "transform": "table",
              "type": "table"
            },
            {
              "columns": [],
              "fontSize": "100%",
              "hideTimeOverride": true,
              "id": 38,
              "links": [],
              "pageSize": 5,
              "scroll": true,
              "showHeader": true,
              "sort": {
                "col": 2,
                "desc": true
              },
              "span": 5,
              "styles": [
                {
                  "alias": "Time",
                  "dateFormat": "YYYY-MM-DD HH:mm:ss",
                  "pattern": "Time",
                  "type": "hidden"
                },
                {
                  "alias": "memory",
                  "colorMode": "cell",
                  "colors": [
                    "rgba(245, 54, 54, 0.9)",
                    "rgba(237, 129, 40, 0.89)",
                    "rgba(50, 172, 45, 0.97)"
                  ],
                  "dateFormat": "YYYY-MM-DD HH:mm:ss",
                  "decimals": 2,
                  "pattern": "Value",
                  "thresholds": [
                    "15",
                    "20"
                  ],
                  "type": "number",
                  "unit": "decbytes"
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
                  "pattern": "image",
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
                  "decimals": 2,
                  "pattern": "/.*/",
                  "thresholds": [],
                  "type": "number",
                  "unit": "short"
                }
              ],
              "targets": [
                {
                  "expr": "topk (5, (sum(container_memory_usage_bytes{image!=\"\"}) by (name, namespace)))",
                  "format": "table",
                  "hide": false,
                  "interval": "1s",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "A",
                  "step": 2
                }
              ],
              "timeFrom": "1s",
              "title": "Top 5 Container by Memory",
              "transform": "table",
              "transparent": true,
              "type": "table"
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Top Five",
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
              "decimals": null,
              "editable": true,
              "error": false,
              "fill": 0,
              "grid": {},
              "height": "",
              "hideTimeOverride": false,
              "id": 17,
              "legend": {
                "alignAsTable": true,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "rightSide": true,
                "show": true,
                "sideWidth": 6,
                "sort": "current",
                "sortDesc": true,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 2,
              "links": [],
              "nullPointMode": "connected",
              "percentage": true,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 12,
              "stack": false,
              "steppedLine": true,
              "targets": [
                {
                  "expr": "sum(rate(container_cpu_usage_seconds_total{name=~\".+\"}[$interval])) by (name) * 100",
                  "format": "time_series",
                  "hide": false,
                  "interval": "1m",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name{{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 120
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Container CPU Utilization",
              "tooltip": {
                "msResolution": true,
                "shared": false,
                "sort": 2,
                "value_type": "cumulative"
              },
              "transparent": false,
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
                  "label": "CPU Percentage",
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
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Dashboard Row",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 217,
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "decimals": 2,
              "editable": true,
              "error": false,
              "fill": 2,
              "grid": {},
              "id": 25,
              "legend": {
                "alignAsTable": true,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "rightSide": true,
                "show": true,
                "sideWidth": 200,
                "sortDesc": true,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 3,
              "links": [],
              "nullPointMode": "connected",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 12,
              "stack": false,
              "steppedLine": true,
              "targets": [
                {
                  "expr": "sort_desc(sum(container_memory_usage_bytes{image!=\"\"}) by (name, image))",
                  "format": "time_series",
                  "hide": false,
                  "interval": "10s",
                  "intervalFactor": 1,
                  "legendFormat": "{{ "{{" }} name {{ "}}" }}",
                  "metric": "container_memory_usage:sort_desc",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Container Memory Usage",
              "tooltip": {
                "msResolution": false,
                "shared": false,
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
                  "format": "bytes",
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
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Pods memory usage",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 272,
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "decimals": null,
              "editable": true,
              "error": false,
              "fill": 0,
              "grid": {},
              "height": "",
              "hideTimeOverride": false,
              "id": 44,
              "legend": {
                "alignAsTable": true,
                "avg": false,
                "current": true,
                "max": false,
                "min": false,
                "rightSide": true,
                "show": true,
                "sort": "current",
                "sortDesc": true,
                "total": false,
                "values": true
              },
              "lines": true,
              "linewidth": 2,
              "links": [],
              "nullPointMode": "connected",
              "percentage": true,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 6,
              "stack": false,
              "steppedLine": true,
              "targets": [
                {
                  "expr": "sum (rate (container_cpu_usage_seconds_total{image!=\"\",name=~\"^k8s_.*\"}[$interval])) by (pod_name)",
                  "format": "time_series",
                  "hide": false,
                  "interval": "1m",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} pod_name {{ "}}" }}",
                  "metric": "",
                  "refId": "A",
                  "step": 120
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Pod CPU Utilization",
              "tooltip": {
                "msResolution": true,
                "shared": false,
                "sort": 2,
                "value_type": "cumulative"
              },
              "transparent": false,
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
                  "label": "CPU Second Second Avg by Interval",
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
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "fill": 2,
              "id": 47,
              "legend": {
                "alignAsTable": true,
                "avg": false,
                "current": true,
                "max": false,
                "min": false,
                "rightSide": true,
                "show": true,
                "total": false,
                "values": true
              },
              "lines": true,
              "linewidth": 3,
              "links": [],
              "nullPointMode": "null",
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
                  "expr": "sum (container_memory_working_set_bytes{image!=\"\",name=~\"^k8s_.*\"}) by (pod_name)",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} pod_name {{ "}}" }}",
                  "metric": "container_memory_usage:sort_desc",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Pods Memory Usage",
              "tooltip": {
                "shared": false,
                "sort": 1,
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
                  "show": true
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Pods",
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
              "fill": 2,
              "id": 34,
              "legend": {
                "alignAsTable": true,
                "avg": false,
                "current": true,
                "hideEmpty": false,
                "hideZero": false,
                "max": false,
                "min": false,
                "rightSide": true,
                "show": true,
                "total": false,
                "values": true
              },
              "lines": true,
              "linewidth": 3,
              "links": [],
              "nullPointMode": "null",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "spaceLength": 10,
              "span": 12,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "node_load15",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }} 15min",
                  "refId": "A",
                  "step": 4
                },
                {
                  "expr": "node_load5",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }} 5min",
                  "refId": "B",
                  "step": 4
                },
                {
                  "expr": "node_load1",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}instance{{ "}}" }} 1min",
                  "metric": "",
                  "refId": "C",
                  "step": 4
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Worker Nodes 15, 5, 1 Load Average",
              "tooltip": {
                "shared": false,
                "sort": 1,
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
                  "show": false
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Load Avg.",
          "titleSize": "h6"
        }
      ],
      "schemaVersion": 14,
      "style": "dark",
      "tags": [],
      "templating": {
        "list": [
          {
            "auto": false,
            "auto_count": 50,
            "auto_min": "50s",
            "current": {
              "text": "5m",
              "value": "5m"
            },
            "hide": 0,
            "label": "interval",
            "name": "interval",
            "options": [
              {
                "selected": true,
                "text": "5m",
                "value": "5m"
              },
              {
                "selected": false,
                "text": "10m",
                "value": "10m"
              },
              {
                "selected": false,
                "text": "15m",
                "value": "15m"
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
              },
              {
                "selected": false,
                "text": "7d",
                "value": "7d"
              },
              {
                "selected": false,
                "text": "14d",
                "value": "14d"
              },
              {
                "selected": false,
                "text": "30d",
                "value": "30d"
              }
            ],
            "query": "5m,10m,15m,30m,1h,6h,12h,1d,7d,14d,30d",
            "refresh": 2,
            "type": "interval"
          }
        ]
      },
      "time": {
        "from": "now-1h",
        "to": "now"
      },
      "timepicker": {
        "nowDelay": "",
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
      "timezone": "browser",
      "title": "ICP 2.1 Performance IBM Provided 2.5",
      "version": 6
    }
{{- end }}
