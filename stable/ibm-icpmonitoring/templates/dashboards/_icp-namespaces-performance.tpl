{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* ICP Namespaces Performance Monitoring Dashboard File */}}
{{- define "ICPNamespacesPerformanceMonitoring" }}
ICP2.1-Namespaces-Performance.json: |-
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
          "id": "table",
          "name": "Table",
          "version": ""
        }
      ],
      "annotations": {
        "list": []
      },
      "description": "Monitors Kubernetes cluster using Prometheus. Shows overall cluster CPU / Memory / Filesystem usage as well as individual pod, containers, systemd services statistics. Uses cAdvisor metrics only.",
      "editable": true,
      "gnetId": 315,
      "graphTooltip": 0,
      "hideControls": false,
      "id": null,
      "links": [
        {
          "asDropdown": true,
          "icon": "external link",
          "includeVars": true,
          "keepTime": true,
          "tags": [],
          "targetBlank": true,
          "title": "Dashboards",
          "type": "dashboards"
        }
      ],
      "refresh": false,
      "rows": [
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
              "id": 39,
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
              "span": 12,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(rate(container_cpu_usage_seconds_total{namespace=\"$namespace\"}[$interval])) by (pod_name) * 100",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} pod_name {{ "}}" }}",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Namespace \"$namespace\"  CPU by pod name",
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
          "title": "$namespace CPU",
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
              "id": 38,
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
              "span": 12,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": " sort_desc(sum(container_memory_usage_bytes{image!=\"\", namespace=\"$namespace\"}) by (pod_name, image))",
                  "format": "time_series",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }} pod_name {{ "}}" }}",
                  "refId": "A",
                  "step": 10
                }
              ],
              "thresholds": [],
              "timeFrom": null,
              "timeShift": null,
              "title": "Namespace  \"$namespace\"  Memory by pod name",
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
                  "show": true
                }
              ]
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "$namespace Memory",
          "titleSize": "h6"
        },
        {
          "collapse": false,
          "height": 250,
          "panels": [
            {
              "columns": [],
              "fontSize": "100%",
              "id": 40,
              "links": [],
              "pageSize": null,
              "scroll": true,
              "showHeader": true,
              "sort": {
                "col": null,
                "desc": false
              },
              "span": 12,
              "styles": [
                {
                  "alias": "Time",
                  "dateFormat": "YYYY-MM-DD HH:mm:ss",
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
                  "pattern": "chart",
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
                  "pattern": "release",
                  "thresholds": [],
                  "type": "hidden",
                  "unit": "short"
                },
                {
                  "alias": "",
                  "colorMode": "cell",
                  "colors": [
                    "rgba(245, 54, 54, 0.9)",
                    "rgba(237, 129, 40, 0.89)",
                    "rgba(50, 172, 45, 0.97)"
                  ],
                  "dateFormat": "YYYY-MM-DD HH:mm:ss",
                  "decimals": null,
                  "pattern": "Value",
                  "thresholds": [
                    "0",
                    "1"
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
                  "pattern": "__name__",
                  "thresholds": [],
                  "type": "hidden",
                  "unit": "short"
                }
              ],
              "targets": [
                {
                  "expr": "kube_pod_container_status_ready{namespace=\"$namespace\"}",
                  "format": "table",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}pod{{ "}}" }}",
                  "refId": "A",
                  "step": 2
                }
              ],
              "timeFrom": "1s",
              "title": "$namespace kube_pod_container_status_ready",
              "transform": "table",
              "transparent": false,
              "type": "table"
            }
          ],
          "repeat": null,
          "repeatIteration": null,
          "repeatRowId": null,
          "showTitle": false,
          "title": "Kube Metrics Status Ready",
          "titleSize": "h6"
        }
      ],
      "schemaVersion": 14,
      "style": "dark",
      "tags": [],
      "templating": {
        "list": [
          {
            "auto": true,
            "auto_count": 50,
            "auto_min": "50s",
            "current": {
              "text": "auto",
              "value": "$__auto_interval"
            },
            "hide": 0,
            "label": "interval",
            "name": "interval",
            "options": [
              {
                "selected": true,
                "text": "auto",
                "value": "$__auto_interval"
              },
              {
                "selected": false,
                "text": "30s",
                "value": "30s"
              },
              {
                "selected": false,
                "text": "1m",
                "value": "1m"
              },
              {
                "selected": false,
                "text": "2m",
                "value": "2m"
              },
              {
                "selected": false,
                "text": "3m",
                "value": "3m"
              },
              {
                "selected": false,
                "text": "5m",
                "value": "5m"
              },
              {
                "selected": false,
                "text": "7m",
                "value": "7m"
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
            "query": "30s,1m,2m,3m,5m,7m,10m,30m,1h,6h,12h,1d,7d,14d,30d",
            "refresh": 2,
            "type": "interval"
          },
          {
            "allValue": null,
            "current": {
              "text": "default",
              "value": "default"
            },
            "datasource": "prometheus",
            "hide": 0,
            "includeAll": false,
            "label": "Namespace",
            "multi": false,
            "name": "namespace",
            "options": [],
            "query": "label_values(namespace)",
            "refresh": 1,
            "regex": "",
            "sort": 1,
            "tagValuesQuery": "",
            "tags": [],
            "tagsQuery": "",
            "type": "query",
            "useTags": false
          }
        ]
      },
      "time": {
        "from": "now-3h",
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
      "title": "ICP 2.1 Namespaces Performance IBM Provided 2.5",
      "version": 3
    }
{{- end }}
