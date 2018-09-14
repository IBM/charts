{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* Docker Monitoring Dashboard File */}}
{{/* origin: https://grafana.com/dashboards/3681 */}}
{{- define "dockerMonitoring" }}
docker-host-container-monitoring.json: |-
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
          "id": "graph",
          "name": "Graph",
          "version": ""
        },
        {
          "type": "panel",
          "id": "table",
          "name": "Table",
          "version": ""
        },
        {
          "type": "grafana",
          "id": "grafana",
          "name": "Grafana",
          "version": "3.1.1"
        },
        {
          "type": "datasource",
          "id": "prometheus",
          "name": "Prometheus",
          "version": "1.0.0"
        }
      ],
      "id": null,
      "title": "Docker Host & Container Overview",
      "tags": [
        "docker"
      ],
      "style": "dark",
      "timezone": "browser",
      "editable": true,
      "hideControls": false,
      "sharedCrosshair": true,
      "rows": [
        {
          "collapse": false,
          "editable": true,
          "height": 143.625,
          "panels": [
            {
              "aliasColors": {
                "SENT": "#BF1B00"
              },
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 5,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 19,
              "isNew": true,
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
              "nullPointMode": "null as zero",
              "percentage": false,
              "pointradius": 1,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "span": 2,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(rate(container_network_receive_bytes_total{id=\"/\"}[$interval])) by (id)",
                  "intervalFactor": 2,
                  "legendFormat": "RECEIVED",
                  "refId": "A",
                  "step": 4
                },
                {
                  "expr": "- sum(rate(container_network_transmit_bytes_total{id=\"/\"}[$interval])) by (id)",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "SENT",
                  "refId": "B",
                  "step": 4
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "Network Traffic on Node",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "show": false
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
              "aliasColors": {
                "Ops-Infrastructure": "#447EBC",
                "{}": "#DEDAF7"
              },
              "bars": true,
              "datasource": "prometheus",
              "decimals": 0,
              "editable": true,
              "error": false,
              "fill": 3,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 7,
              "isNew": true,
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": false,
                "total": false,
                "values": false
              },
              "lines": false,
              "linewidth": 3,
              "links": [],
              "nullPointMode": "null as zero",
              "percentage": false,
              "pointradius": 10,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "span": 1.9899973849372385,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "count(rate(container_last_seen{name=~\".+\",container_group=\"monitoring\"}[$interval]))",
                  "intervalFactor": 2,
                  "legendFormat": "Monitoring",
                  "metric": "container_last_seen",
                  "refId": "A",
                  "step": 4
                },
                {
                  "expr": "count(rate(container_last_seen{name=~\".+\",container_group=\"ops-infrastructure\"}[$interval]))",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "Backend-Infrastructure",
                  "refId": "B",
                  "step": 4
                },
                {
                  "expr": "count(rate(container_last_seen{name=~\".+\",container_group=\"backend-infrastructure\"}[$interval]))",
                  "hide": false,
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "Backend-Workers",
                  "refId": "C",
                  "step": 4
                },
                {
                  "expr": "count(rate(container_last_seen{name=~\".+\",container_group=\"backend-workers\"}[$interval]))",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "Ops-Infrastructure",
                  "refId": "D",
                  "step": 4
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "Running Containers (by Container Group)",
              "tooltip": {
                "msResolution": false,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "show": false
              },
              "yaxes": [
                {
                  "format": "none",
                  "label": "",
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
              "aliasColors": {
                "{id=\"/\",instance=\"cadvisor:8080\",job=\"prometheus\"}": "#BA43A9"
              },
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 3,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 5,
              "isNew": true,
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
              "linewidth": 2,
              "links": [],
              "nullPointMode": "null as zero",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "span": 2.0707047594142263,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(rate(container_cpu_system_seconds_total[2m]))",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "a",
                  "refId": "B",
                  "step": 120
                },
                {
                  "expr": "sum(rate(container_cpu_system_seconds_total{name=~\".+\"}[2m]))",
                  "hide": true,
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "nur container",
                  "refId": "F",
                  "step": 10
                },
                {
                  "expr": "sum(rate(container_cpu_system_seconds_total{id=\"/\"}[2m]))",
                  "hide": true,
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "nur docker host",
                  "metric": "",
                  "refId": "A",
                  "step": 20
                },
                {
                  "expr": "sum(rate(process_cpu_seconds_total[$interval])) * 100",
                  "hide": false,
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "host",
                  "metric": "",
                  "refId": "C",
                  "step": 4
                },
                {
                  "expr": "sum(rate(container_cpu_system_seconds_total{name=~\".+\"}[2m])) + sum(rate(container_cpu_system_seconds_total{id=\"/\"}[2m])) + sum(rate(process_cpu_seconds_total[2m]))",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "D",
                  "step": 120
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "CPU Usage on Node",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "type": "graph",
              "xaxis": {
                "show": false
              },
              "yaxes": [
                {
                  "format": "percent",
                  "label": "",
                  "logBase": 1,
                  "max": 120,
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
              "aliasColors": {
                "Belegete Festplatte": "#BF1B00",
                "Free Disk Space": "#7EB26D",
                "Used Disk Space": "#BF1B00",
                "{}": "#BF1B00"
              },
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 4,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 13,
              "isNew": true,
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
              "linewidth": 3,
              "links": [],
              "nullPointMode": "null as zero",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "span": 2,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "node_filesystem_free_bytes{fstype=\"aufs\"}",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "Free Disk Space",
                  "refId": "A",
                  "step": 4
                },
                {
                  "expr": "node_filesystem_size_bytes{fstype=\"aufs\"} - node_filesystem_free_bytes{fstype=\"aufs\"}",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "Used Disk Space",
                  "refId": "B",
                  "step": 4
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "Free and Used Disk Space on Node",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "show": false
              },
              "yaxes": [
                {
                  "format": "bytes",
                  "label": "",
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
              "aliasColors": {
                "Available Memory": "#7EB26D",
                "Unavailable Memory": "#BF1B00"
              },
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 4,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 20,
              "isNew": true,
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
              "linewidth": 3,
              "links": [],
              "nullPointMode": "null as zero",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "span": 2,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "container_memory_rss{name=~\".+\"}",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "refId": "D",
                  "step": 30
                },
                {
                  "expr": "sum(container_memory_rss{name=~\".+\"})",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "refId": "A",
                  "step": 20
                },
                {
                  "expr": "container_memory_usage_bytes{name=~\".+\"}",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name}}",
                  "refId": "B",
                  "step": 20
                },
                {
                  "expr": "container_memory_rss{id=\"/\"}",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "refId": "C",
                  "step": 30
                },
                {
                  "expr": "sum(container_memory_rss)",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "refId": "E",
                  "step": 30
                },
                {
                  "expr": "node_memory_Buffers_bytes",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "node_memory_Dirty_bytes",
                  "refId": "N",
                  "step": 30
                },
                {
                  "expr": "node_memory_MemFree_bytes",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "refId": "F",
                  "step": 30
                },
                {
                  "expr": "node_memory_MemAvailable_bytes",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "Available Memory",
                  "refId": "H",
                  "step": 4
                },
                {
                  "expr": "node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "Unavailable Memory",
                  "refId": "G",
                  "step": 4
                },
                {
                  "expr": "node_memory_Inactive_bytes",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "refId": "I",
                  "step": 30
                },
                {
                  "expr": "node_memory_KernelStack_bytes",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "refId": "J",
                  "step": 30
                },
                {
                  "expr": "node_memory_Active_bytes",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "refId": "K",
                  "step": 30
                },
                {
                  "expr": "node_memory_MemTotal_bytes - (node_memory_Active_bytes + node_memory_MemFree_bytes + node_memory_Inactive_bytes)",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "Unknown",
                  "refId": "L",
                  "step": 40
                },
                {
                  "expr": "node_memory_MemFree_bytes + node_memory_Inactive_bytes ",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "refId": "M",
                  "step": 30
                },
                {
                  "expr": "container_memory_rss{name=~\".+\"}",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "refId": "O",
                  "step": 30
                },
                {
                  "expr": "node_memory_Inactive_bytes + node_memory_MemFree_bytes + node_memory_MemAvailable_bytes",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "P",
                  "step": 40
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "Available Memory on Node",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "show": false
              },
              "yaxes": [
                {
                  "format": "bytes",
                  "label": "",
                  "logBase": 1,
                  "max": 4200000000,
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
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 3,
              "isNew": true,
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
              "linewidth": 2,
              "links": [],
              "nullPointMode": "null as zero",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "span": 1.939297855648535,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(rate(node_disk_read_bytes_total[$interval])) by (device)",
                  "intervalFactor": 2,
                  "legendFormat": "OUT on /{{ "{{" }}device}}",
                  "metric": "node_disk_read_bytes_total",
                  "refId": "A",
                  "step": 4
                },
                {
                  "expr": "sum(rate(node_disk_written_bytes_total[$interval])) by (device)",
                  "intervalFactor": 2,
                  "legendFormat": "IN on /{{ "{{" }}device}}",
                  "metric": "",
                  "refId": "B",
                  "step": 4
                },
                {
                  "expr": "",
                  "intervalFactor": 2,
                  "refId": "C"
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "Disk I/O on Node",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "type": "graph",
              "xaxis": {
                "show": false
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
          "title": "New row"
        },
        {
          "collapse": false,
          "editable": true,
          "height": 284.609375,
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 5,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 1,
              "isNew": true,
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
              "nullPointMode": "null as zero",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "span": 6.0790694124949285,
              "stack": true,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "sum(rate(container_cpu_usage_seconds_total{name=~\".+\"}[$interval])) by (name) * 100",
                  "hide": false,
                  "interval": "",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name}}",
                  "metric": "container_cp",
                  "refId": "F",
                  "step": 2
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "CPU Usage per Container (Stacked)",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "show": true
              },
              "yaxes": [
                {
                  "format": "percent",
                  "label": "",
                  "logBase": 1,
                  "max": null,
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
              "aliasColors": {
                "node_load15": "#CCA300"
              },
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 0,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 4,
              "isNew": true,
              "legend": {
                "avg": false,
                "current": true,
                "max": false,
                "min": false,
                "show": true,
                "total": false,
                "values": true
              },
              "lines": true,
              "linewidth": 2,
              "links": [],
              "nullPointMode": "null as zero",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "span": 5.920930587505071,
              "stack": false,
              "steppedLine": false,
              "targets": [
                {
                  "expr": "{__name__=~\"^node_load.*\"}",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}__name__}}",
                  "metric": "node",
                  "refId": "A",
                  "step": 2
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "System Load on Node",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "type": "graph",
              "xaxis": {
                "show": true
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
          "title": "Row"
        },
        {
          "collapse": false,
          "editable": true,
          "height": 203.515625,
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(247, 226, 2, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(244, 0, 0, 0.22)",
                "thresholdLine": false
              },
              "id": 9,
              "isNew": true,
              "legend": {
                "avg": false,
                "current": false,
                "hideEmpty": false,
                "hideZero": false,
                "max": false,
                "min": false,
                "show": true,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 2,
              "links": [],
              "nullPointMode": "null as zero",
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
                  "expr": "sum(rate(container_network_transmit_bytes_total{name=~\".+\"}[$interval])) by (name)",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name}}",
                  "refId": "A",
                  "step": 2
                },
                {
                  "expr": "rate(container_network_transmit_bytes_total{id=\"/\"}[$interval])",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "",
                  "refId": "B",
                  "step": 10
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "Sent Network Traffic per Container",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "show": true
              },
              "yaxes": [
                {
                  "format": "Bps",
                  "label": "",
                  "logBase": 1,
                  "max": null,
                  "min": null,
                  "show": true
                },
                {
                  "format": "short",
                  "label": "",
                  "logBase": 10,
                  "max": 8,
                  "min": 0,
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
              "fill": 3,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 10,
              "isNew": true,
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
              "linewidth": 2,
              "links": [],
              "nullPointMode": "null as zero",
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
                  "expr": "sum(container_memory_rss{name=~\".+\"}) by (name)",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name}}",
                  "refId": "A",
                  "step": 2
                },
                {
                  "expr": "container_memory_usage_bytes{name=~\".+\"}",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name}}",
                  "refId": "B",
                  "step": 240
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "Memory Usage per Container (Stacked)",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "show": true
              },
              "yaxes": [
                {
                  "format": "bytes",
                  "label": "",
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
          "title": "New row"
        },
        {
          "collapse": false,
          "editable": true,
          "height": 222.703125,
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 8,
              "isNew": true,
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
              "linewidth": 2,
              "links": [],
              "nullPointMode": "null as zero",
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
                  "expr": "sum(rate(container_network_receive_bytes_total{name=~\".+\"}[$interval])) by (name)",
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name{{ "}}" }}",
                  "refId": "A",
                  "step": 2
                },
                {
                  "expr": "- rate(container_network_transmit_bytes_total{name=~\".+\"}[$interval])",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name{{ "}}" }}",
                  "refId": "B",
                  "step": 10
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "Received Network Traffic per Container",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "cumulative"
              },
              "transparent": false,
              "type": "graph",
              "xaxis": {
                "show": true
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
              "fill": 3,
              "grid": {
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "id": 11,
              "isNew": true,
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
              "linewidth": 2,
              "links": [],
              "nullPointMode": "null as zero",
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
                  "expr": "container_memory_rss{name=~\".+\"}",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name{{ "}}" }}",
                  "refId": "A",
                  "step": 20
                },
                {
                  "expr": "container_memory_usage_bytes{name=~\".+\"}",
                  "hide": true,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name{{ "}}" }}",
                  "refId": "B",
                  "step": 20
                },
                {
                  "expr": "sum(container_memory_cache{name=~\".+\"}) by (name)",
                  "hide": false,
                  "intervalFactor": 2,
                  "legendFormat": "{{ "{{" }}name{{ "}}" }}",
                  "refId": "C",
                  "step": 2
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "Cached Memory per Container (Stacked)",
              "tooltip": {
                "msResolution": true,
                "shared": true,
                "sort": 0,
                "value_type": "individual"
              },
              "type": "graph",
              "xaxis": {
                "show": true
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
          "title": "New row"
        },
        {
          "collapse": false,
          "editable": true,
          "height": "250px",
          "panels": [
            {
              "columns": [
                {
                  "text": "Avg",
                  "value": "avg"
                }
              ],
              "datasource": "prometheus",
              "editable": true,
              "error": false,
              "fontSize": "100%",
              "hideTimeOverride": false,
              "id": 18,
              "isNew": true,
              "links": [],
              "pageSize": 100,
              "scroll": true,
              "showHeader": true,
              "sort": {
                "col": 0,
                "desc": true
              },
              "span": 6,
              "styles": [
                {
                  "dateFormat": "YYYY-MM-DD HH:mm:ss",
                  "pattern": "Time",
                  "type": "date"
                },
                {
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
                  "expr": "cadvisor_version_info",
                  "intervalFactor": 2,
                  "legendFormat": "cAdvisor Version: {{ "{{" }}cadvisorVersion{{ "}}" }}",
                  "refId": "A",
                  "step": 2
                },
                {
                  "expr": "prometheus_build_info",
                  "intervalFactor": 2,
                  "legendFormat": "Prometheus Version: {{ "{{" }}version{{ "}}" }}",
                  "refId": "B",
                  "step": 2
                },
                {
                  "expr": "node_exporter_build_info",
                  "intervalFactor": 2,
                  "legendFormat": "Node-Exporter Version: {{ "{{" }}version{{ "}}" }}",
                  "refId": "C",
                  "step": 2
                },
                {
                  "expr": "cadvisor_version_info",
                  "intervalFactor": 2,
                  "legendFormat": "Docker Version: {{ "{{" }}dockerVersion{{ "}}" }}",
                  "refId": "D",
                  "step": 2
                },
                {
                  "expr": "cadvisor_version_info",
                  "intervalFactor": 2,
                  "legendFormat": "Host OS Version: {{ "{{" }}osVersion{{ "}}" }}",
                  "refId": "E",
                  "step": 2
                },
                {
                  "expr": "cadvisor_version_info",
                  "intervalFactor": 2,
                  "legendFormat": "Host Kernel Version: {{ "{{" }}kernelVersion{{ "}}" }}",
                  "refId": "F",
                  "step": 2
                }
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "",
              "transform": "timeseries_aggregations",
              "type": "table"
            }
          ],
          "showTitle": false,
          "title": "Check this out"
        },
        {
          "collapse": false,
          "editable": true,
          "height": 290.98582985381427,
          "panels": [],
          "title": "New row"
        },
        {
          "collapse": false,
          "editable": true,
          "height": 127,
          "panels": [],
          "title": "New row"
        }
      ],
      "time": {
        "from": "now-15m",
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
            "allValue": ".+",
            "current": {},
            "datasource": "prometheus",
            "hide": 0,
            "includeAll": true,
            "label": "Container Group",
            "multi": true,
            "name": "containergroup",
            "options": [],
            "query": "label_values(container_group)",
            "refresh": 1,
            "regex": "",
            "type": "query"
          },
          {
            "auto": true,
            "auto_count": 50,
            "auto_min": "50s",
            "current": {
              "tags": [],
              "text": "auto",
              "value": "$__auto_interval"
            },
            "datasource": null,
            "hide": 0,
            "includeAll": false,
            "label": "Interval",
            "multi": false,
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
            "refresh": 0,
            "type": "interval"
          }
        ]
      },
      "annotations": {
        "list": []
      },
      "refresh": "10s",
      "schemaVersion": 12,
      "version": 0,
      "links": [],
      "gnetId": 395,
      "description": "A simple overview of the most important Docker host and container metrics. (cAdvisor/Prometheus)"
    }
{{- end }}
