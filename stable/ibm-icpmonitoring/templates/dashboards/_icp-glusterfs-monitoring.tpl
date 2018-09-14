{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* ICP GlusterFS Monitoring Dashboard File */}}
{{- define "ICPGlusterFSMonitoring" }}
icp-glusterfs-monitoring.json: |-
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
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 0
          },
          "id": 20,
          "panels": [],
          "repeat": null,
          "title": "Status",
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
            "h": 4,
            "w": 6,
            "x": 0,
            "y": 1
          },
          "hideTimeOverride": true,
          "id": 1,
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
              "expr": "heketi_up",
              "format": "time_series",
              "intervalFactor": 2,
              "refId": "A"
            }
          ],
          "thresholds": "50",
          "timeFrom": "10s",
          "title": "Heketi Status",
          "type": "singlestat",
          "valueFontSize": "150%",
          "valueMaps": [
            {
              "op": "=",
              "text": "N/A",
              "value": "null"
            },
            {
              "op": "=",
              "text": "UP",
              "value": "1"
            }
          ],
          "valueName": "first"
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
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 6,
            "y": 1
          },
          "hideTimeOverride": true,
          "id": 3,
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
              "expr": "heketi_volumes_count",
              "format": "time_series",
              "intervalFactor": 2,
              "refId": "A"
            }
          ],
          "thresholds": "",
          "timeFrom": "10s",
          "title": "Volumes",
          "type": "singlestat",
          "valueFontSize": "150%",
          "valueMaps": [
            {
              "op": "=",
              "text": "N/A",
              "value": "null"
            }
          ],
          "valueName": "first"
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
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 12,
            "y": 1
          },
          "hideTimeOverride": true,
          "id": 4,
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
              "expr": "heketi_cluster_count",
              "format": "time_series",
              "intervalFactor": 2,
              "refId": "A"
            }
          ],
          "thresholds": "",
          "timeFrom": "10s",
          "title": "Cluster",
          "type": "singlestat",
          "valueFontSize": "150%",
          "valueMaps": [
            {
              "op": "=",
              "text": "N/A",
              "value": "null"
            }
          ],
          "valueName": "first"
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
          "gridPos": {
            "h": 4,
            "w": 6,
            "x": 18,
            "y": 1
          },
          "hideTimeOverride": true,
          "id": 5,
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
              "expr": "sum(heketi_device_brick_count)",
              "format": "time_series",
              "intervalFactor": 2,
              "refId": "A"
            }
          ],
          "thresholds": "",
          "timeFrom": "10s",
          "title": "Bricks",
          "type": "singlestat",
          "valueFontSize": "150%",
          "valueMaps": [
            {
              "op": "=",
              "text": "N/A",
              "value": "null"
            }
          ],
          "valueName": "first"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 5
          },
          "id": 21,
          "panels": [],
          "repeat": null,
          "title": "Storage",
          "type": "row"
        },
        {
          "cacheTimeout": null,
          "colorBackground": true,
          "colorValue": false,
          "colors": [
            "#614d93",
            "#cffaff",
            "#508642"
          ],
          "datasource": "prometheus",
          "decimals": 2,
          "format": "none",
              "gauge": {
            "maxValue": 100,
            "minValue": 0,
            "show": false,
            "thresholdLabels": true,
            "thresholdMarkers": true
          },
          "gridPos": {
            "h": 6,
            "w": 8,
            "x": 0,
            "y": 6
          },
          "hideTimeOverride": true,
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
          "postfix": " GB",
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
          "repeat": null,
          "sparkline": {
            "fillColor": "rgba(31, 118, 189, 0.18)",
            "full": false,
            "lineColor": "rgb(31, 120, 193)",
            "show": false
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "(sum(heketi_device_size))/(2^20)",
              "format": "time_series",
              "hide": false,
              "intervalFactor": 2,
              "refId": "A"
            }
          ],
          "thresholds": "50",
          "timeFrom": "10s",
          "title": "Total Storage",
          "transparent": false,
          "type": "singlestat",
          "valueFontSize": "110%",
          "valueMaps": [
            {
              "op": "=",
              "text": "N/A",
              "value": "null"
            }
          ],
          "valueName": "first"
        },
        {
          "cacheTimeout": null,
          "colorBackground": false,
          "colorValue": false,
          "colors": [
            "#b7dbab",
            "rgba(237, 129, 40, 0.89)",
            "#508642"
          ],
          "datasource": "prometheus",
          "decimals": 2,
          "format": "none",
          "gauge": {
            "maxValue": 100,
            "minValue": 0,
            "show": false,
            "thresholdLabels": true,
            "thresholdMarkers": true
          },
          "gridPos": {
            "h": 5,
            "w": 8,
            "x": 8,
            "y": 6
          },
          "height": "200px",
          "hideTimeOverride": true,
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
          "postfix": " GB",
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
            "fillColor": "#9ac48a",
            "full": true,
            "lineColor": "rgb(31, 120, 193)",
            "show": false
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "(sum(heketi_device_used))/(2^20)",
              "format": "time_series",
              "intervalFactor": 2,
              "refId": "A"
            }
          ],
          "thresholds": "50",
          "timeFrom": "10s",
          "title": "Storage Used",
          "type": "singlestat",
          "valueFontSize": "110%",
          "valueMaps": [
            {
              "op": "=",
              "text": "N/A",
              "value": "null"
            }
          ],
          "valueName": "first"
        },
        {
          "cacheTimeout": null,
          "colorBackground": false,
          "colorValue": false,
          "colors": [
            "#e24d42",
            "#f29191",
            "#629e51"
          ],
          "datasource": "prometheus",
          "decimals": 2,
          "format": "none",
          "gauge": {
            "maxValue": 100,
            "minValue": 0,
            "show": false,
            "thresholdLabels": true,
            "thresholdMarkers": true
          },
          "gridPos": {
            "h": 5,
            "w": 8,
            "x": 16,
            "y": 6
          },
          "height": "200px",
          "hideTimeOverride": true,
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
          "postfix": " GB",
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
              "expr": "(sum(heketi_device_free))/(2^20)",
              "format": "time_series",
              "intervalFactor": 2,
              "refId": "A"
            }
          ],
          "thresholds": "50",
          "timeFrom": "10s",
          "title": "Storage Free",
          "type": "singlestat",
          "valueFontSize": "110%",
          "valueMaps": [
            {
              "op": "=",
              "text": "N/A",
              "value": "null"
            }
          ],
          "valueName": "first"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 12
          },
          "id": 22,
          "panels": [],
          "repeat": null,
          "title": "Node Information",
          "type": "row"
        },
        {
          "columns": [],
          "datasource": "prometheus",
          "fontSize": "100%",
          "gridPos": {
            "h": 6,
            "w": 24,
            "x": 0,
            "y": 13
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
              "alias": "Nodes And Disks",
              "colorMode": null,
              "colors": [
                "#1f78c1",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "pattern": "Metric",
              "thresholds": [],
              "type": "number",
              "unit": "short"
            },
            {
              "alias": "Bricks",
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
              "unit": "short"
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
              "expr": "heketi_device_brick_count",
              "format": "time_series",
              "hide": false,
              "instant": true,
              "intervalFactor": 2,
              "legendFormat": "hostname: [{{ "{{" }} hostname {{ "}}" }}], device: [{{ "{{" }} device {{ "}}" }}]",
              "refId": "A"
            }
          ],
          "timeFrom": "5s",
          "title": "Bricks",
          "transform": "timeseries_to_rows",
          "type": "table"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 19
          },
          "id": 23,
          "panels": [],
          "repeat": null,
          "title": "Total Storage",
          "type": "row"
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
            "y": 20
          },
          "hideTimeOverride": true,
          "id": 17,
          "links": [],
          "pageSize": null,
          "scroll": true,
          "showHeader": true,
          "sort": {
            "col": 0,
            "desc": false
          },
          "styles": [
            {
              "alias": "Time",
              "dateFormat": "MMMM D, YYYY LT",
              "pattern": "Time",
              "type": "date"
            },
            {
              "alias": "Nodes And Disks",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "pattern": "Metric",
              "thresholds": [],
              "type": "number",
              "unit": "short"
            },
            {
              "alias": "Total Storage (GB)",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "pattern": "Value",
              "thresholds": [],
              "type": "number",
              "unit": "none"
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
              "expr": "(heketi_device_size)/(2^20)",
              "format": "time_series",
              "instant": true,
              "intervalFactor": 2,
              "legendFormat": "hostname: [{{ "{{" }} hostname {{ "}}" }}], device: [{{ "{{" }} device {{ "}}" }}]",
              "refId": "A"
            }
          ],
          "timeFrom": "5s",
          "title": "Total Storage",
          "transform": "timeseries_to_rows",
          "type": "table"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 27
          },
          "id": 24,
          "panels": [],
          "repeat": null,
          "title": "Storage Used",
          "type": "row"
        },
        {
          "columns": [],
          "datasource": "prometheus",
          "fontSize": "100%",
          "gridPos": {
            "h": 6,
            "w": 24,
            "x": 0,
            "y": 28
          },
          "hideTimeOverride": true,
          "id": 19,
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
              "alias": "Time",
              "dateFormat": "MMMM D, YYYY LT",
              "pattern": "Time",
              "type": "date"
            },
            {
              "alias": "Nodes And Disks",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "pattern": "Metric",
              "thresholds": [],
              "type": "number",
              "unit": "short"
            },
            {
              "alias": "Used Storage (GB)",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "pattern": "Value",
              "thresholds": [],
              "type": "number",
              "unit": "none"
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
              "expr": "(heketi_device_used)/(2^20)",
              "format": "time_series",
              "instant": true,
              "intervalFactor": 2,
              "legendFormat": "hostname: [{{ "{{" }} hostname {{ "}}" }}], device: [{{ "{{" }} device {{ "}}" }}]",
              "refId": "A"
            }
          ],
          "timeFrom": "5s",
          "title": "Storage Used",
          "transform": "timeseries_to_rows",
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
      "title": "Storage GlusterFS Health",
      "version": 1
    }
{{- end }}
