{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* NGINX Ingress Controller Dashboard File */}}
{{/* origin: https://github.com/kubernetes/ingress-nginx/blob/master/deploy/grafana/dashboards/nginx.yaml*/}}
{{- define "nginxIngressController" }}
nginx_ingress_controller.json: |-
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
          "type": "grafana",
          "id": "grafana",
          "name": "Grafana",
          "version": "5.2.1"
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
          },
          {
            "datasource": "prometheus",
            "enable": true,
            "expr": "sum(changes(nginx_ingress_controller_config_last_reload_successful_timestamp_seconds{instance!=\"unknown\",controller_class=~\"$controller_class\",namespace=~\"$namespace\"}[30s])) by (controller_class)",
            "hide": false,
            "iconColor": "rgba(255, 96, 96, 1)",
            "limit": 100,
            "name": "Config Reloads",
            "showIn": 0,
            "step": "30s",
            "tagKeys": "controller_class",
            "tags": [],
            "titleFormat": "Config Reloaded",
            "type": "tags"
          }
        ]
      },
      "editable": true,
      "gnetId": null,
      "graphTooltip": 0,
      "iteration": 1534359654832,
      "links": [],
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
          "format": "ops",
          "gauge": {
            "maxValue": 100,
            "minValue": 0,
            "show": false,
            "thresholdLabels": false,
            "thresholdMarkers": true
          },
          "gridPos": {
            "h": 3,
            "w": 6,
            "x": 0,
            "y": 0
          },
          "id": 20,
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
            "full": true,
            "lineColor": "rgb(31, 120, 193)",
            "show": true
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "round(sum(irate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",namespace=~\"$namespace\"}[2m])), 0.001)",
              "format": "time_series",
              "intervalFactor": 1,
              "refId": "A",
              "step": 4
            }
          ],
          "thresholds": "",
          "title": "Controller Request Volume",
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
          "valueName": "avg"
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
          "format": "none",
          "gauge": {
            "maxValue": 100,
            "minValue": 0,
            "show": false,
            "thresholdLabels": false,
            "thresholdMarkers": true
          },
          "gridPos": {
            "h": 3,
            "w": 6,
            "x": 6,
            "y": 0
          },
          "id": 82,
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
            "full": true,
            "lineColor": "rgb(31, 120, 193)",
            "show": true
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "sum(avg_over_time(nginx_ingress_controller_nginx_process_connections{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"}[2m]))",
              "format": "time_series",
              "instant": false,
              "intervalFactor": 1,
              "refId": "A",
              "step": 4
            }
          ],
          "thresholds": "",
          "title": "Controller Connections",
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
          "valueName": "avg"
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
          "format": "percentunit",
          "gauge": {
            "maxValue": 100,
            "minValue": 80,
            "show": false,
            "thresholdLabels": false,
            "thresholdMarkers": false
          },
          "gridPos": {
            "h": 3,
            "w": 6,
            "x": 12,
            "y": 0
          },
          "id": 21,
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
            "full": true,
            "lineColor": "rgb(31, 120, 193)",
            "show": true
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "sum(rate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",namespace=~\"$namespace\",status!~\"[4-5].*\"}[2m])) / sum(rate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",namespace=~\"$namespace\"}[2m]))",
              "format": "time_series",
              "intervalFactor": 1,
              "refId": "A",
              "step": 4
            }
          ],
          "thresholds": "95, 99, 99.5",
          "title": "Controller Success Rate (non-4|5xx responses)",
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
          "valueName": "avg"
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
          "decimals": 0,
          "format": "none",
          "gauge": {
            "maxValue": 100,
            "minValue": 0,
            "show": false,
            "thresholdLabels": false,
            "thresholdMarkers": true
          },
          "gridPos": {
            "h": 3,
            "w": 3,
            "x": 18,
            "y": 0
          },
          "id": 81,
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
            "full": true,
            "lineColor": "rgb(31, 120, 193)",
            "show": true
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "avg(nginx_ingress_controller_success{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"})",
              "format": "time_series",
              "instant": true,
              "intervalFactor": 1,
              "refId": "A",
              "step": 4
            }
          ],
          "thresholds": "",
          "title": "Config Reloads",
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
          "valueName": "avg"
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
          "decimals": 0,
          "format": "none",
          "gauge": {
            "maxValue": 100,
            "minValue": 0,
            "show": false,
            "thresholdLabels": false,
            "thresholdMarkers": true
          },
          "gridPos": {
            "h": 3,
            "w": 3,
            "x": 21,
            "y": 0
          },
          "id": 83,
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
            "full": true,
            "lineColor": "rgb(31, 120, 193)",
            "show": true
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "count(nginx_ingress_controller_config_last_reload_successful{controller_pod=~\"$controller\",controller_namespace=~\"$namespace\"} == 0)",
              "format": "time_series",
              "instant": true,
              "intervalFactor": 1,
              "refId": "A",
              "step": 4
            }
          ],
          "thresholds": "",
          "title": "Last Config Failed",
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
          "valueName": "avg"
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
          "grid": {},
          "gridPos": {
            "h": 7,
            "w": 12,
            "x": 0,
            "y": 3
          },
          "height": "200px",
          "id": 86,
          "isNew": true,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": false,
            "hideEmpty": false,
            "hideZero": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "sideWidth": 300,
            "sort": "current",
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
          "repeat": null,
          "repeatDirection": "h",
          "seriesOverrides": [],
          "spaceLength": 10,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "round(sum(irate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\"}[2m])) by (ingress), 0.001)",
              "format": "time_series",
              "hide": false,
              "instant": false,
              "interval": "",
              "intervalFactor": 1,
              "legendFormat": "{{ "{{" }}ingress{{ "}}" }}",
              "metric": "network",
              "refId": "A",
              "step": 10
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Ingress Request Volume",
          "tooltip": {
            "msResolution": false,
            "shared": true,
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
              "format": "reqps",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            },
            {
              "format": "Bps",
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
          "aliasColors": {
            "max - istio-proxy": "#890f02",
            "max - master": "#bf1b00",
            "max - prometheus": "#bf1b00"
          },
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "prometheus",
          "decimals": 2,
          "editable": false,
          "error": false,
          "fill": 0,
          "grid": {},
          "gridPos": {
            "h": 7,
            "w": 12,
            "x": 12,
            "y": 3
          },
          "id": 87,
          "isNew": true,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": false,
            "hideEmpty": true,
            "hideZero": false,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": true,
            "sideWidth": 300,
            "sort": "avg",
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
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "sum(rate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",namespace=~\"$namespace\",ingress=~\"$ingress\",status!~\"[4-5].*\"}[2m])) by (ingress) / sum(rate(nginx_ingress_controller_requests{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",namespace=~\"$namespace\",ingress=~\"$ingress\"}[2m])) by (ingress)",
              "format": "time_series",
              "instant": false,
              "interval": "10s",
              "intervalFactor": 1,
              "legendFormat": "{{ "{{" }}ingress{{ "}}" }}",
              "metric": "container_memory_usage:sort_desc",
              "refId": "A",
              "step": 10
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Ingress Success Rate (non-4|5xx responses)",
          "tooltip": {
            "msResolution": false,
            "shared": true,
            "sort": 1,
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
              "format": "percentunit",
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
          "decimals": 2,
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {},
          "gridPos": {
            "h": 6,
            "w": 8,
            "x": 0,
            "y": 10
          },
          "height": "200px",
          "id": 32,
          "isNew": true,
          "legend": {
            "alignAsTable": false,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": false,
            "show": false,
            "sideWidth": 200,
            "sort": "current",
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
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "sum (irate (nginx_ingress_controller_request_size_sum{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"}[2m]))",
              "format": "time_series",
              "instant": false,
              "interval": "10s",
              "intervalFactor": 1,
              "legendFormat": "Received",
              "metric": "network",
              "refId": "A",
              "step": 10
            },
            {
              "expr": "- sum (irate (nginx_ingress_controller_response_size_sum{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"}[2m]))",
              "format": "time_series",
              "hide": false,
              "interval": "10s",
              "intervalFactor": 1,
              "legendFormat": "Sent",
              "metric": "network",
              "refId": "B",
              "step": 10
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Network I/O pressure",
          "tooltip": {
            "msResolution": false,
            "shared": true,
            "sort": 0,
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
              "format": "Bps",
              "label": null,
              "logBase": 1,
              "max": null,
              "min": null,
              "show": true
            },
            {
              "format": "Bps",
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
          "aliasColors": {
            "max - istio-proxy": "#890f02",
            "max - master": "#bf1b00",
            "max - prometheus": "#bf1b00"
          },
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "prometheus",
          "decimals": 2,
          "editable": false,
          "error": false,
          "fill": 0,
          "grid": {},
          "gridPos": {
            "h": 6,
            "w": 8,
            "x": 8,
            "y": 10
          },
          "id": 77,
          "isNew": true,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": false,
            "show": false,
            "sideWidth": 200,
            "sort": "current",
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
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "avg(nginx_ingress_controller_nginx_process_resident_memory_bytes{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"}) ",
              "format": "time_series",
              "instant": false,
              "interval": "10s",
              "intervalFactor": 1,
              "legendFormat": "nginx",
              "metric": "container_memory_usage:sort_desc",
              "refId": "A",
              "step": 10
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Average Memory Usage",
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
          ],
          "yaxis": {
            "align": false,
            "alignLevel": null
          }
        },
        {
          "aliasColors": {
            "max - istio-proxy": "#890f02",
            "max - master": "#bf1b00"
          },
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "prometheus",
          "decimals": 3,
          "editable": false,
          "error": false,
          "fill": 0,
          "grid": {},
          "gridPos": {
            "h": 6,
            "w": 8,
            "x": 16,
            "y": 10
          },
          "height": "",
          "id": 79,
          "isNew": true,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": false,
            "show": false,
            "sort": null,
            "sortDesc": null,
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
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "sum (rate (nginx_ingress_controller_nginx_process_cpu_seconds_total{controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\"}[2m])) ",
              "format": "time_series",
              "interval": "10s",
              "intervalFactor": 1,
              "legendFormat": "nginx",
              "metric": "container_cpu",
              "refId": "A",
              "step": 10
            }
          ],
          "thresholds": [
            {
              "colorMode": "critical",
              "fill": true,
              "line": true,
              "op": "gt"
            }
          ],
          "timeFrom": null,
          "timeShift": null,
          "title": "Average CPU Usage",
          "tooltip": {
            "msResolution": true,
            "shared": true,
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
              "label": "cores",
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
            "h": 8,
            "w": 24,
            "x": 0,
            "y": 16
          },
          "hideTimeOverride": false,
          "id": 75,
          "links": [],
          "pageSize": 7,
          "repeat": null,
          "repeatDirection": "h",
          "scroll": true,
          "showHeader": true,
          "sort": {
            "col": 1,
            "desc": true
          },
          "styles": [
            {
              "alias": "Ingress",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "pattern": "ingress",
              "preserveFormat": false,
              "sanitize": false,
              "thresholds": [],
              "type": "string",
              "unit": "short"
            },
            {
              "alias": "Requests",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "pattern": "Value #A",
              "thresholds": [
                ""
              ],
              "type": "number",
              "unit": "ops"
            },
            {
              "alias": "Errors",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "pattern": "Value #B",
              "thresholds": [],
              "type": "number",
              "unit": "ops"
            },
            {
              "alias": "P50 Latency",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 0,
              "link": false,
              "pattern": "Value #C",
              "thresholds": [],
              "type": "number",
              "unit": "dtdurations"
            },
            {
              "alias": "P90 Latency",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 0,
              "pattern": "Value #D",
              "thresholds": [],
              "type": "number",
              "unit": "dtdurations"
            },
            {
              "alias": "P99 Latency",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 0,
              "pattern": "Value #E",
              "thresholds": [],
              "type": "number",
              "unit": "dtdurations"
            },
            {
              "alias": "IN",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "pattern": "Value #F",
              "thresholds": [
                ""
              ],
              "type": "number",
              "unit": "Bps"
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
              "pattern": "Time",
              "thresholds": [],
              "type": "hidden",
              "unit": "short"
            },
            {
              "alias": "OUT",
              "colorMode": null,
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 2,
              "mappingType": 1,
              "pattern": "Value #G",
              "thresholds": [],
              "type": "number",
              "unit": "Bps"
            }
          ],
          "targets": [
            {
              "expr": "histogram_quantile(0.50, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\"}[2m])) by (le, ingress))",
              "format": "table",
              "hide": false,
              "instant": true,
              "intervalFactor": 1,
              "legendFormat": "{{ "{{" }}ingress{{ "}}" }}",
              "refId": "C"
            },
            {
              "expr": "histogram_quantile(0.90, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\"}[2m])) by (le, ingress))",
              "format": "table",
              "hide": false,
              "instant": true,
              "intervalFactor": 1,
              "legendFormat": "{{ "{{" }}ingress{{ "}}" }}",
              "refId": "D"
            },
            {
              "expr": "histogram_quantile(0.99, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\"}[2m])) by (le, ingress))",
              "format": "table",
              "hide": false,
              "instant": true,
              "intervalFactor": 1,
              "legendFormat": "{{ "{{" }}destination_service{{ "}}" }}",
              "refId": "E"
            },
            {
              "expr": "sum(irate(nginx_ingress_controller_request_size_sum{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\"}[2m])) by (ingress)",
              "format": "table",
              "hide": false,
              "instant": true,
              "interval": "",
              "intervalFactor": 1,
              "legendFormat": "{{ "{{" }}ingress{{ "}}" }}",
              "refId": "F"
            },
            {
              "expr": "sum(irate(nginx_ingress_controller_response_size_sum{ingress!=\"\",controller_pod=~\"$controller\",controller_class=~\"$controller_class\",controller_namespace=~\"$namespace\",ingress=~\"$ingress\"}[2m])) by (ingress)",
              "format": "table",
              "instant": true,
              "intervalFactor": 1,
              "legendFormat": "{{ "{{" }}ingress{{ "}}" }}",
              "refId": "G"
            }
          ],
          "timeFrom": null,
          "title": "Ingress Percentile Response Times and Transfer Rates",
          "transform": "table",
          "transparent": false,
          "type": "table"
        },
        {
          "columns": [
            {
              "text": "Current",
              "value": "current"
            }
          ],
          "datasource": "prometheus",
          "fontSize": "100%",
          "gridPos": {
            "h": 8,
            "w": 24,
            "x": 0,
            "y": 24
          },
          "height": "1024",
          "id": 85,
          "links": [],
          "pageSize": 7,
          "scroll": true,
          "showHeader": true,
          "sort": {
            "col": 1,
            "desc": false
          },
          "styles": [
            {
              "alias": "Time",
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "pattern": "Time",
              "type": "date"
            },
            {
              "alias": "TTL",
              "colorMode": "cell",
              "colors": [
                "rgba(245, 54, 54, 0.9)",
                "rgba(237, 129, 40, 0.89)",
                "rgba(50, 172, 45, 0.97)"
              ],
              "dateFormat": "YYYY-MM-DD HH:mm:ss",
              "decimals": 0,
              "pattern": "Current",
              "thresholds": [
                "0",
                "691200"
              ],
              "type": "number",
              "unit": "s"
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
              "expr": "avg(nginx_ingress_controller_ssl_expire_time_seconds{kubernetes_pod_name=~\"$controller\",namespace=~\"$namespace\",ingress=~\"$ingress\"}) by (host) - time()",
              "format": "time_series",
              "intervalFactor": 1,
              "legendFormat": "{{ "{{" }}host{{ "}}" }}",
              "metric": "gke_letsencrypt_cert_expiration",
              "refId": "A",
              "step": 1
            }
          ],
          "title": "Ingress Certificate Expiry",
          "transform": "timeseries_aggregations",
          "type": "table"
        }
      ],
      "refresh": "5s",
      "schemaVersion": 16,
      "style": "dark",
      "tags": [
        "nginx"
      ],
      "templating": {
        "list": [
          {
            "allValue": ".*",
            "current": {
              "text": "All",
              "value": "$__all"
            },
            "datasource": "prometheus",
            "hide": 0,
            "includeAll": true,
            "label": "Namespace",
            "multi": false,
            "name": "namespace",
            "options": [],
            "query": "label_values(nginx_ingress_controller_config_hash, controller_namespace)",
            "refresh": 1,
            "regex": "",
            "sort": 0,
            "tagValuesQuery": "",
            "tags": [],
            "tagsQuery": "",
            "type": "query",
            "useTags": false
          },
          {
            "allValue": ".*",
            "current": {
              "text": "All",
              "value": "$__all"
            },
            "datasource": "prometheus",
            "hide": 0,
            "includeAll": true,
            "label": "Controller Class",
            "multi": false,
            "name": "controller_class",
            "options": [],
            "query": "label_values(nginx_ingress_controller_config_hash{namespace=~\"$namespace\"}, controller_class) ",
            "refresh": 1,
            "regex": "",
            "sort": 0,
            "tagValuesQuery": "",
            "tags": [],
            "tagsQuery": "",
            "type": "query",
            "useTags": false
          },
          {
            "allValue": ".*",
            "current": {
              "text": "All",
              "value": "$__all"
            },
            "datasource": "prometheus",
            "hide": 0,
            "includeAll": true,
            "label": "Controller",
            "multi": false,
            "name": "controller",
            "options": [],
            "query": "label_values(nginx_ingress_controller_config_hash{namespace=~\"$namespace\",controller_class=~\"$controller_class\"}, controller_pod) ",
            "refresh": 1,
            "regex": "",
            "sort": 0,
            "tagValuesQuery": "",
            "tags": [],
            "tagsQuery": "",
            "type": "query",
            "useTags": false
          },
          {
            "allValue": ".*",
            "current": {
              "tags": [],
              "text": "All",
              "value": "$__all"
            },
            "datasource": "prometheus",
            "hide": 0,
            "includeAll": true,
            "label": "Ingress",
            "multi": false,
            "name": "ingress",
            "options": [],
            "query": "label_values(nginx_ingress_controller_requests{namespace=~\"$namespace\",controller_class=~\"$controller_class\",controller=~\"$controller\"}, ingress) ",
            "refresh": 1,
            "regex": "",
            "sort": 2,
            "tagValuesQuery": "",
            "tags": [],
            "tagsQuery": "",
            "type": "query",
            "useTags": false
          }
        ]
      },
      "time": {
        "from": "now-1h",
        "to": "now"
      },
      "timepicker": {
        "refresh_intervals": [
          "5s",
          "10s",
          "30s",
          "2m",
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
      "title": "NGINX Ingress controller",
      "version": 1
    }
{{- end }}
