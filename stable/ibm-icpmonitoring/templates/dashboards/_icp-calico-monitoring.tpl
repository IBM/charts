{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* ICP Calico Monitoring Dashboard File */}}
{{- define "ICPCalicoMonitoring" }}
icp-calico-monitoring.json: |-
    {
      "__inputs": [
        {
          "name": "DS_PROMETHEUS",
          "label": "Prometheus",
          "description": "Prometheus data source",
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
          "version": "3.1.1"
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
      "hideControls": false,
      "id": 5,
      "links": [],
      "refresh": false,
      "rows": [
        {
          "collapse": false,
          "height": 142,
          "panels": [
            {
              "cacheTimeout": null,
              "colorBackground": false,
              "colorValue": true,
              "colors": [
                "#64b0c8",
                "#64b0c8",
                "#64b0c8"
              ],
              "datasource": null,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "hideTimeOverride": true,
              "id": 2,
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
              "span": 6,
              "sparkline": {
                "fillColor": "rgba(100, 176, 200, 0.14)",
                "full": true,
                "lineColor": "#64b0c8",
                "show": false
              },
              "tableColumn": "",
              "targets": [
                {
                  "expr": "max(felix_cluster_num_hosts)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "A"
                }
              ],
              "thresholds": "0",
              "timeFrom": "5m",
              "timeShift": null,
              "title": "Total Calico Hosts",
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
                "#ef843c",
                "#ef843c",
                "#ef843c"
              ],
              "datasource": null,
              "format": "none",
              "gauge": {
                "maxValue": 100,
                "minValue": 0,
                "show": false,
                "thresholdLabels": false,
                "thresholdMarkers": true
              },
              "hideTimeOverride": false,
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
              "span": 6,
              "sparkline": {
                "fillColor": "rgba(239, 132, 60, 0.13)",
                "full": false,
                "lineColor": "#ef843c",
                "show": false
              },
              "tableColumn": "",
              "targets": [
                {
                  "expr": "sum(felix_active_local_endpoints)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "A"
                }
              ],
              "thresholds": "0",
              "timeFrom": null,
              "timeShift": null,
              "title": "Total Workload Endpoints",
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
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Dashboard Row",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 257,
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "decimals": 3,
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "",
              "id": 17,
              "legend": {
                "alignAsTable": false,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "rightSide": false,
                "show": true,
                "sort": "current",
                "sortDesc": true,
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
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum (rate (container_cpu_usage_seconds_total{pod_name=~\"^calico-node.*\"}[5m])) by (pod_name)",
                  "format": "time_series",
                  "interval": "10s",
                  "intervalFactor": 1,
                  "legendFormat": "{{ "{{" }} pod_name {{ "}}" }}",
                  "metric": "container_cpu",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "calico-node  pod CPU usage (5m avg)",
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
              "decimals": 3,
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {},
              "height": "",
              "id": 18,
              "legend": {
                "alignAsTable": false,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "rightSide": false,
                "show": true,
                "sort": "current",
                "sortDesc": true,
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
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum (rate (container_cpu_usage_seconds_total{pod_name=~\"^calico-kube-.*\"}[5m])) by (pod_name)",
                  "format": "time_series",
                  "interval": "10s",
                  "intervalFactor": 1,
                  "legendFormat": "{{ "{{" }} pod_name {{ "}}" }}",
                  "metric": "container_cpu",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "calico-kube-controller pod CPU usage (5m avg)",
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
                  "show": false
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Pods CPU usage",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 278,
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
              "fill": 1,
              "grid": {},
              "id": 25,
              "legend": {
                "alignAsTable": false,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "rightSide": false,
                "show": true,
                "sideWidth": 200,
                "sort": "current",
                "sortDesc": true,
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
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum (container_memory_working_set_bytes{pod_name=~\"^calico-node-.*\"}) by (pod_name)",
                  "format": "time_series",
                  "interval": "10s",
                  "intervalFactor": 1,
                  "legendFormat": "{{ "{{" }} pod_name {{ "}}" }}",
                  "metric": "container_memory_usage:sort_desc",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "calico-node pod memory usage",
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
              "grid": {},
              "id": 26,
              "legend": {
                "alignAsTable": false,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "rightSide": false,
                "show": true,
                "sideWidth": 200,
                "sort": "current",
                "sortDesc": true,
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
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum (container_memory_working_set_bytes{pod_name=~\"^calico-kube-.*\"}) by (pod_name)",
                  "format": "time_series",
                  "interval": "10s",
                  "intervalFactor": 1,
                  "legendFormat": "{{ "{{" }} pod_name {{ "}}" }}",
                  "metric": "container_memory_usage:sort_desc",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "calico-kube-controller pod memory usage",
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
              ]
            },
            {
              "aliasColors": {},
              "bars": false,
              "dashLength": 10,
              "dashes": false,
              "datasource": "prometheus",
              "fill": 1,
              "id": 8,
              "legend": {
                "alignAsTable": false,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
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
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "felix_ipsets_calico",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
                  "refId": "A",
                  "step": 20
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Active IP Sets",
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
              "fill": 1,
              "id": 10,
              "legend": {
                "alignAsTable": false,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
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
              "span": 6,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "felix_ipset_errors",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
                  "refId": "A",
                  "step": 20
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "IP Set Command Failures",
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
              "fill": 1,
              "id": 9,
              "legend": {
                "alignAsTable": false,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
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
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum (felix_iptables_chains{table=~\"filter\"}) by (table)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} table {{ "}}" }}-table",
                  "refId": "A",
                  "step": 20
                },
                {
                  "expr": "sum (felix_iptables_chains{table=~\"mangle\"}) by (table)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} table {{ "}}" }}-table",
                  "refId": "B"
                },
                {
                  "expr": "sum (felix_iptables_chains{table=~\"nat\"}) by (table)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} table {{ "}}" }}-table",
                  "refId": "C"
                },
                {
                  "expr": "sum (felix_iptables_chains{table=~\"raw\"}) by (table)",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} table {{ "}}" }}-table",
                  "refId": "D"
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Active IP Tables Chains",
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
              "fill": 1,
              "id": 11,
              "legend": {
                "alignAsTable": false,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
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
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "felix_iptables_save_errors",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
                  "refId": "A",
                  "step": 20
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "IP Tables Save Errors",
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
              "fill": 1,
              "id": 12,
              "legend": {
                "alignAsTable": false,
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
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
              "span": 4,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "felix_iptables_restore_errors",
                  "format": "time_series",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
                  "refId": "A",
                  "step": 20
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "IP Tables Restore Errors",
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
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Dashboard Row",
          "titleSize": "h6"
        }
      ],
      "schemaVersion": 14,
      "style": "dark",
      "tags": [],
      "templating": {
        "list": []
      },
      "time": {
        "from": "now-6h",
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
      "title": "Cluster Network Health (Calico)",
      "version": 1
    }
{{- end }}
