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
      "version": "4.6.3"
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
  "id": null,
  "links": [],
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 24,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "sum(process_resident_memory_bytes{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"})",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "Total resident memory",
              "refId": "B"
            },
            {
              "expr": "sum(go_memstats_alloc_bytes{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"})",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "Total allocated bytes",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Memory Usage",
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
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 25,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "sum(process_cpu_seconds_total{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"})",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "CPU usage",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "CPU Usage",
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
      "title": "System Metrics",
      "titleSize": "h6"
    },
    {
      "collapse": true,
      "height": 250,
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 8,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "rate(cnc_frontend_service_api_PDF_total_requests{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "PDF Conversion Request Rate",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "PDF Conversion Request Rate",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 9,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_api_EC_total_requests{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}\t",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "Element Classification Request Rate",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Element Classification Request Rate",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 10,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_api_Tables_total_requests{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}\t",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "Tables Request Rate",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Tables Request Rate",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 11,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_api_Compare_total_requests{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}\t",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "Comparison Request Rate",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Comparison Request Rate",
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
      "title": "Request Rate",
      "titleSize": "h6"
    },
    {
      "collapse": true,
      "height": 250,
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 12,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "rate(cnc_frontend_service_api_PDF_response_status_2xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "2xx",
              "refId": "A"
            },
            {
              "expr": "rate(cnc_frontend_service_api_PDF_response_status_4xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "4xx",
              "refId": "B"
            },
            {
              "expr": "rate(cnc_frontend_service_api_PDF_response_status_5xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "5xx",
              "refId": "C"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "PDF Conversion Response Rate",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 13,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "rate(cnc_frontend_service_api_EC_response_status_2xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "2xx",
              "refId": "A"
            },
            {
              "expr": "rate(cnc_frontend_service_api_EC_response_status_4xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "4xx",
              "refId": "B"
            },
            {
              "expr": "rate(cnc_frontend_service_api_EC_response_status_5xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "5xx",
              "refId": "C"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Element Classification Response Rate",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 14,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "rate(cnc_frontend_service_api_Tables_response_status_2xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "2xx",
              "refId": "A"
            },
            {
              "expr": "rate(cnc_frontend_service_api_Tables_response_status_4xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "4xx",
              "refId": "B"
            },
            {
              "expr": "rate(cnc_frontend_service_api_Tables_response_status_5xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "5xx",
              "refId": "C"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Tables Response Rate",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 15,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "rate(cnc_frontend_service_api_Compare_response_status_2xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "2xx",
              "refId": "A"
            },
            {
              "expr": "rate(cnc_frontend_service_api_Compare_response_status_4xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "4xx",
              "refId": "B"
            },
            {
              "expr": "rate(cnc_frontend_service_api_Compare_response_status_5xx{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}[2m])",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "5xx",
              "refId": "C"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Comparison Response Rate",
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
      "title": "Response Rate",
      "titleSize": "h6"
    },
    {
      "collapse": true,
      "height": 250,
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 16,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_api_PDF_end2end_time_msec{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "{{quantile}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "PDF Conversion API End-to-End Execution Time",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 17,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_api_EC_end2end_time_msec{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "{{quantile}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Element Classification API End-to-End Execution Time",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 18,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_api_Tables_end2end_time_msec{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "{{quantile}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Tables API End-to-End Execution Time",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 19,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_api_Compare_end2end_time_msec{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "{{quantile}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Comparison API End-to-End Execution Time",
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
      "title": "API End-to-End Execution Time",
      "titleSize": "h6"
    },
    {
      "collapse": true,
      "height": 250,
      "panels": [
        {
          "aliasColors": {},
          "bars": false,
          "dashLength": 10,
          "dashes": false,
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 20,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_step_PDF_end2end_time_msec{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "{{quantile}}",
              "refId": "A"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "PDF Conversion Step Execution Time",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 21,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_step_EC_end2end_time_msec{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "{{quantile}}",
              "refId": "B"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Element-Classification Step Execution Time",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 22,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_step_Tables_end2end_time_msec{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "{{quantile}}",
              "refId": "C"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Tables Step Execution Time",
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
          "datasource": "${DS_PROMETHEUS}",
          "fill": 1,
          "id": 23,
          "legend": {
            "avg": false,
            "current": false,
            "max": false,
            "min": false,
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
          "span": 6,
          "stack": false,
          "steppedLine": false,
          "targets": [
            {
              "expr": "cnc_frontend_service_step_Compare_end2end_time_msec{app=\"ibm-watson-compare-comply-prod\",chart=\"ibm-watson-compare-comply-prod-@@CHART_VERSION@@\",job=\"kubernetes-service-endpoints\",kubernetes_name=\"@@RELEASE_NAME@@-ibm-watson-compare-comply-prod-metrics\",kubernetes_namespace=\"@@NAMESPACE@@\",release=\"@@RELEASE_NAME@@\"}",
              "format": "time_series",
              "intervalFactor": 2,
              "legendFormat": "{{quantile}}",
              "refId": "D"
            }
          ],
          "thresholds": [],
          "timeFrom": null,
          "timeShift": null,
          "title": "Comparison Step Execution Time",
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
      "title": "Step Execution Time",
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
  "title": "Watson Compare and Comply - @@RELEASE_NAME@@",
  "version": 1
}