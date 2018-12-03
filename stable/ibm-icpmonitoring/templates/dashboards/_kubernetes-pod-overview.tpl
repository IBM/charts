{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* Kubernetes Pod Overview Dashboard File */}}
{{/* origin: https://grafana.com/dashboards/6781 */}}
{{- define "kubernetesPodOverview" }}
kubernetes-pod-overview.json: |-
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
          "version": "5.0.4"
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
      "description": "Kubernetes: POD Overview",
      "editable": true,
      "gnetId": 6781,
      "graphTooltip": 1,
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
          "id": 34,
          "panels": [],
          "repeat": null,
          "title": "POD Dashborad",
          "type": "row"
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
            "h": 5,
            "w": 8,
            "x": 0,
            "y": 1
          },
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
          "sparkline": {
            "fillColor": "rgba(31, 118, 189, 0.18)",
            "full": false,
            "lineColor": "rgb(31, 120, 193)",
            "show": false
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "sum(kube_pod_info{namespace=~\"$namespace\"})",
              "format": "time_series",
              "intervalFactor": 2,
              "refId": "A",
              "step": 20
            }
          ],
          "thresholds": "",
          "title": "POD Count (Namespace)",
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
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "prometheus",
          "decimals": 0,
          "fill": 1,
          "gridPos": {
            "h": 5,
            "w": 16,
            "x": 8,
            "y": 1
          },
          "id": 8,
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
              "expr": "sum(avg(kube_pod_status_phase{namespace=~\"$namespace\",pod=~\"$pod\"}) by(namespace, pod, phase)) by(phase)",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "{{ "{{" }} phase {{ "}}" }}",
              "refId": "A",
              "step": 2
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Pod Status",
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
          "decimals": 0,
          "fill": 1,
          "gridPos": {
            "h": 5,
            "w": 24,
            "x": 0,
            "y": 6
          },
          "id": 12,
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
              "expr": "kube_pod_container_status_restarts{namespace=~\"$namespace\", pod=~\"$pod\"} or kube_pod_container_status_restarts_total{namespace=~\"$namespace\", pod=~\"$pod\"}",
              "format": "time_series",
              "hide": false,
              "intervalFactor": 2,
              "legendFormat": "{{ "{{" }} pod {{ "}}" }}",
              "refId": "A",
              "step": 2
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Pod Restart",
          "tooltip": {
            "shared": false,
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
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 11
          },
          "id": 35,
          "panels": [],
          "repeat": null,
          "title": "POD Resource",
          "type": "row"
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
          "decimals": 3,
          "format": "none",
          "gauge": {
            "maxValue": 100,
            "minValue": 0,
            "show": false,
            "thresholdLabels": false,
            "thresholdMarkers": true
          },
          "gridPos": {
            "h": 5,
            "w": 6,
            "x": 0,
            "y": 12
          },
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
          "postfix": " Core",
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
            "show": true
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "sum(rate(container_cpu_usage_seconds_total{namespace=~\"$namespace\",pod_name=~\"$pod\",container_name!=\"POD\"}[2m])) ",
              "format": "time_series",
              "intervalFactor": 2,
              "refId": "A",
              "step": 20
            }
          ],
          "thresholds": "",
          "title": "CPU",
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
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "prometheus",
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {},
          "gridPos": {
            "h": 5,
            "w": 18,
            "x": 6,
            "y": 12
          },
          "id": 2,
          "legend": {
            "alignAsTable": true,
            "avg": true,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": false,
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
              "expr": "sum by (container_name)( rate(container_cpu_usage_seconds_total{image!=\"\",container_name=~\"$container\",container_name!=\"POD\",pod_name=~\"$pod\"}[2m] ) )",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "Current: {{ "{{" }} container_name {{ "}}" }}",
              "refId": "A",
              "step": 2
            },
            {
              "expr": "kube_pod_container_resource_requests_cpu_cores{pod=~\"$pod\", container!=\"POD\"}",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "Requested: {{ "{{" }} container {{ "}}" }}",
              "refId": "B",
              "step": 2
            },
            {
              "expr": "kube_pod_container_resource_limits_cpu_cores{pod=~\"$pod\", container!=\"POD\"}",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "Limit: {{ "{{" }} container {{ "}}" }}",
              "refId": "C",
              "step": 2
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "CPU Usage",
          "tooltip": {
            "msResolution": true,
            "shared": true,
            "sort": 0,
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
          "cacheTimeout": null,
          "colorBackground": false,
          "colorValue": false,
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "datasource": "prometheus",
          "format": "bytes",
          "gauge": {
            "maxValue": 100,
            "minValue": 0,
            "show": false,
            "thresholdLabels": false,
            "thresholdMarkers": true
          },
          "gridPos": {
            "h": 5,
            "w": 6,
            "x": 0,
            "y": 17
          },
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
            "show": true
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "sum(container_memory_working_set_bytes{namespace=~\"$namespace\", pod_name=~\"$pod\",container_name!=\"POD\"})",
              "format": "time_series",
              "hide": false,
              "intervalFactor": 2,
              "refId": "A",
              "step": 20
            }
          ],
          "thresholds": "",
          "title": "Memory",
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
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "prometheus",
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {},
          "gridPos": {
            "h": 5,
            "w": 18,
            "x": 6,
            "y": 17
          },
          "id": 1,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": false,
            "total": false,
            "values": false
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
              "expr": "avg by(container_name) (container_memory_working_set_bytes{pod_name=~\"$pod\", container_name=~\"$container\", container_name!=\"POD\"})",
              "format": "time_series",
              "interval": "10s",
              "intervalFactor": 1,
              "legendFormat": "Current: {{ "{{" }} container_name {{ "}}" }}",
              "metric": "container_memory_usage_bytes",
              "refId": "A",
              "step": 10
            },
            {
              "expr": "kube_pod_container_resource_requests_memory_bytes{pod=~\"$pod\", container=~\"$container\"}",
              "format": "time_series",
              "interval": "10s",
              "intervalFactor": 2,
              "legendFormat": "Requested: {{ "{{" }} container {{ "}}" }}",
              "metric": "kube_pod_container_resource_requests_memory_bytes",
              "refId": "B",
              "step": 20
            },
            {
              "expr": "kube_pod_container_resource_limits_memory_bytes{pod=~\"$pod\", container=~\"$container\"}",
              "format": "time_series",
              "interval": "10s",
              "intervalFactor": 2,
              "legendFormat": "Limit: {{ "{{" }} container {{ "}}" }}",
              "metric": "kube_pod_container_resource_limits_memory_bytes",
              "refId": "C",
              "step": 20
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Memory Usage",
          "tooltip": {
            "msResolution": true,
            "shared": true,
            "sort": 0,
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
              "show": true
            }
          ]
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
          "decimals": 2,
          "format": "Bps",
          "gauge": {
            "maxValue": 100,
            "minValue": 0,
            "show": false,
            "thresholdLabels": false,
            "thresholdMarkers": true
          },
          "gridPos": {
            "h": 5,
            "w": 6,
            "x": 0,
            "y": 22
          },
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
          "sparkline": {
            "fillColor": "rgba(31, 118, 189, 0.18)",
            "full": false,
            "lineColor": "rgb(31, 120, 193)",
            "show": true
          },
          "tableColumn": "",
          "targets": [
            {
              "expr": "sum(rate(container_network_transmit_bytes_total{namespace=~\"$namespace\",pod_name=~\"$pod\"}[5m])) + sum(rate(container_network_receive_bytes_total{namespace=~\"$namespace\",pod_name=~\"$pod\"}[5m])) ",
              "format": "time_series",
              "intervalFactor": 2,
              "refId": "A",
              "step": 20
            }
          ],
          "thresholds": "",
          "title": "Network RX/TX Total (bytes/sec)",
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
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "prometheus",
          "editable": true,
          "error": false,
          "fill": 1,
          "grid": {},
          "gridPos": {
            "h": 5,
            "w": 18,
            "x": 6,
            "y": 22
          },
          "id": 3,
          "legend": {
            "alignAsTable": true,
            "avg": false,
            "current": true,
            "max": false,
            "min": false,
            "rightSide": true,
            "show": false,
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
              "expr": "rate (container_network_transmit_bytes_total{pod_name=~\"$pod\",interface=\"eth0\"}[5m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "TX : {{ "{{" }} pod_name {{ "}}" }}",
              "refId": "A",
              "step": 2
            },
            {
              "expr": "rate (container_network_receive_bytes_total{pod_name=~\"$pod\",interface=\"eth0\"}[5m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "RX : {{ "{{" }} pod_name {{ "}}" }}",
              "refId": "B",
              "step": 2
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "POD Network",
          "tooltip": {
            "msResolution": true,
            "shared": true,
            "sort": 0,
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
              "decimals": null,
              "format": "Bps",
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
      "refresh": "10s",
      "schemaVersion": 16,
      "style": "dark",
      "tags": [
        "kubernetes",
        "pods"
      ],
      "templating": {
        "list": [
          {
            "allValue": "",
            "current": {},
            "datasource": "prometheus",
            "hide": 0,
            "includeAll": false,
            "label": "Namespace",
            "multi": false,
            "name": "namespace",
            "options": [],
            "query": "label_values(kube_pod_info, namespace)",
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
            "allValue": null,
            "current": {},
            "datasource": "prometheus",
            "hide": 0,
            "includeAll": false,
            "label": "Pod",
            "multi": false,
            "name": "pod",
            "options": [],
            "query": "label_values(kube_pod_info{namespace=~\"$namespace\"}, pod)",
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
            "current": {},
            "datasource": "prometheus",
            "hide": 0,
            "includeAll": true,
            "label": "Container",
            "multi": false,
            "name": "container",
            "options": [],
            "query": "label_values(kube_pod_container_info{namespace=\"$namespace\", pod=~\"$pod\"}, container)",
            "refresh": 1,
            "regex": "",
            "sort": 0,
            "tagValuesQuery": "",
            "tags": [],
            "tagsQuery": "",
            "type": "query",
            "useTags": false
          }
        ]
      },
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
      "timezone": "browser",
      "title": "Kubernetes: POD Overview",
      "uid":"pod-metrics",
      "version": 3
    }
{{- end }}
