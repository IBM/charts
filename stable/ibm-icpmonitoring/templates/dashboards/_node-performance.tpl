{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2018. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* Node Performance Summary Dashboard File */}}
{{- define "nodePerformance" }}
node-performance.json: |-
  {
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
    "graphTooltip": 1,
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
        "id": 56,
        "panels": [],
        "title": "CPU",
        "type": "row"
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
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 1
        },
        "id": 36,
        "isNew": true,
        "legend": {
          "alignAsTable": true,
          "avg": false,
          "current": true,
          "max": false,
          "min": false,
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
        "spaceLength": 10,
        "stack": false,
        "steppedLine": false,
        "targets": [
          {
            "expr": "sum(avg without (cpu)(irate(node_cpu_seconds_total{instance=~\"$Node.+\",mode!=\"idle\"}[5m]))) by(instance)",
            "format": "time_series",
            "instant": false,
            "interval": "",
            "intervalFactor": 1,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
            "metric": "node_cpu",
            "refId": "A",
            "step": 60
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeShift": null,
        "title": "CPU Usage",
        "tooltip": {
          "msResolution": false,
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
            "format": "percentunit",
            "logBase": 2,
            "max": "1",
            "min": null,
            "show": true
          },
          {
            "format": "short",
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
        "editable": true,
        "error": false,
        "fill": 0,
        "grid": {},
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 1
        },
        "id": 48,
        "isNew": true,
        "legend": {
          "alignAsTable": true,
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
        "spaceLength": 10,
        "stack": false,
        "steppedLine": false,
        "targets": [
          {
            "expr": "sum({__name__=~\"^node_load.*\",instance=~\"$Node.+\"})by(instance)",
            "format": "time_series",
            "intervalFactor": 2,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
            "metric": "node",
            "refId": "A",
            "step": 2
          }
        ],
        "thresholds": [],
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
        ],
        "yaxis": {
          "align": false,
          "alignLevel": null
        }
      },
      {
        "collapsed": false,
        "gridPos": {
          "h": 1,
          "w": 24,
          "x": 0,
          "y": 9
        },
        "id": 54,
        "panels": [],
        "title": "Memory",
        "type": "row"
      },
      {
        "aliasColors": {},
        "bars": false,
        "dashLength": 10,
        "dashes": false,
        "datasource": "prometheus",
        "fill": 1,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 10
        },
        "id": 46,
        "legend": {
          "alignAsTable": true,
          "avg": false,
          "current": true,
          "max": false,
          "min": false,
          "rightSide": false,
          "show": true,
          "sort": "current",
          "sortDesc": true,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "links": [],
        "minSpan": 12,
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
            "expr": "node_memory_Active_anon_bytes{instance=~\"$Node.+\"}",
            "format": "time_series",
            "interval": "",
            "intervalFactor": 1,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }} Used",
            "refId": "A"
          },
          {
            "expr": "node_memory_MemTotal_bytes{instance=~\"$Node.+\"}",
            "format": "time_series",
            "intervalFactor": 1,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }} Total",
            "refId": "B"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeShift": null,
        "title": "Memory Usage",
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
            "format": "decbytes",
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
        "fill": 1,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 10
        },
        "id": 41,
        "legend": {
          "alignAsTable": true,
          "avg": false,
          "current": true,
          "max": false,
          "min": false,
          "rightSide": false,
          "show": true,
          "sort": "current",
          "sortDesc": true,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "links": [],
        "minSpan": 12,
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
            "expr": "node_memory_MemAvailable_bytes{instance=~\"$Node.+\"}",
            "format": "time_series",
            "interval": "",
            "intervalFactor": 2,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
            "refId": "A"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeShift": null,
        "title": "Available Memory",
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
            "format": "decbytes",
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
        "fill": 1,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 18
        },
        "id": 40,
        "legend": {
          "alignAsTable": true,
          "avg": false,
          "current": true,
          "max": false,
          "min": false,
          "rightSide": false,
          "show": true,
          "sort": "current",
          "sortDesc": true,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "links": [],
        "minSpan": 8,
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
            "expr": "node_memory_SwapTotal_bytes{instance=~\"$Node.+\"}",
            "format": "time_series",
            "intervalFactor": 2,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
            "refId": "A"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeShift": null,
        "title": "Memory Swap Total",
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
        ],
        "yaxis": {
          "align": false,
          "alignLevel": null
        }
      },
      {
        "collapsed": false,
        "gridPos": {
          "h": 1,
          "w": 24,
          "x": 0,
          "y": 26
        },
        "id": 52,
        "panels": [],
        "title": "Disk",
        "type": "row"
      },
      {
        "aliasColors": {},
        "bars": false,
        "dashLength": 10,
        "dashes": false,
        "datasource": "prometheus",
        "decimals": 3,
        "description": "",
        "fill": 2,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 27
        },
        "height": "",
        "id": 47,
        "legend": {
          "alignAsTable": true,
          "avg": false,
          "current": true,
          "max": true,
          "min": true,
          "rightSide": false,
          "show": true,
          "sort": "current",
          "sortDesc": false,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "links": [],
        "minSpan": 4,
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
            "expr": "node_filesystem_size_bytes{instance=~\"$Node.+\",device!~'rootfs'} - node_filesystem_avail_bytes{instance=~\"$Node.+\",device!~'rootfs'}",
            "format": "time_series",
            "intervalFactor": 2,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }} {{ "{{" }} mountpoint {{ "}}" }}",
            "refId": "A",
            "step": 1800
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeShift": null,
        "title": "Disk Space Used",
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
            "label": "Bytes",
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
        "fill": 1,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 27
        },
        "id": 38,
        "legend": {
          "alignAsTable": true,
          "avg": false,
          "current": true,
          "max": false,
          "min": false,
          "rightSide": false,
          "show": true,
          "sort": "current",
          "sortDesc": true,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "links": [],
        "minSpan": 8,
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
            "expr": "sum (irate(node_disk_read_bytes_total{instance=~\"$Node.+\", mode!=\"idle\"}[5m])) by (instance)",
            "format": "time_series",
            "intervalFactor": 2,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }} R",
            "refId": "A"
          },
          {
            "expr": "sum (irate(node_disk_written_bytes_total{instance=~\"$Node.+\", mode!=\"idle\"}[5m])) by (instance)",
            "format": "time_series",
            "intervalFactor": 2,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }} W",
            "refId": "B"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeShift": null,
        "title": "Disk I/O",
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
        ],
        "yaxis": {
          "align": false,
          "alignLevel": null
        }
      },
      {
        "collapsed": false,
        "gridPos": {
          "h": 1,
          "w": 24,
          "x": 0,
          "y": 35
        },
        "id": 50,
        "panels": [],
        "title": "Network",
        "type": "row"
      },
      {
        "aliasColors": {},
        "bars": false,
        "dashLength": 10,
        "dashes": false,
        "datasource": "prometheus",
        "fill": 1,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 36
        },
        "id": 39,
        "legend": {
          "alignAsTable": true,
          "avg": false,
          "current": true,
          "max": false,
          "min": false,
          "rightSide": false,
          "show": true,
          "sort": "current",
          "sortDesc": true,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "links": [],
        "minSpan": 8,
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
            "expr": "node_sockstat_TCP_tw{instance=~\"$Node.+\"}",
            "format": "time_series",
            "intervalFactor": 2,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }}",
            "refId": "A"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeShift": null,
        "title": "TCP Socket TIME_WAIT",
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
        "fill": 1,
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 36
        },
        "id": 37,
        "legend": {
          "alignAsTable": true,
          "avg": false,
          "current": true,
          "max": false,
          "min": false,
          "rightSide": false,
          "show": true,
          "sort": "current",
          "sortDesc": true,
          "total": false,
          "values": true
        },
        "lines": true,
        "linewidth": 1,
        "links": [],
        "minSpan": 8,
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
            "expr": "sum (irate (node_network_receive_bytes_total{instance=~\"$Node.+\", mode!=\"idle\"}[5m])) by (instance)",
            "format": "time_series",
            "hide": false,
            "instant": false,
            "intervalFactor": 1,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }} RX",
            "refId": "A"
          },
          {
            "expr": "- sum(irate (node_network_transmit_bytes_total{instance=~\"$Node.+\", mode!=\"idle\"}[5m])) by (instance)",
            "format": "time_series",
            "intervalFactor": 1,
            "legendFormat": "{{ "{{" }} instance {{ "}}" }}  TX",
            "refId": "B"
          }
        ],
        "thresholds": [],
        "timeFrom": null,
        "timeShift": null,
        "title": "Network RX/TX",
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
        ],
        "yaxis": {
          "align": false,
          "alignLevel": null
        }
      }
    ],
    "refresh": false,
    "schemaVersion": 16,
    "style": "dark",
    "tags": [
      "nodes"
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
          "label": "Node Name",
          "multi": false,
          "name": "Node",
          "options": [],
          "query": "container_memory_usage_bytes",
          "refresh": 1,
          "regex": "/.*instance=\"([^\"]*).*/",
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
    "title": "Node Performance Summary",
    "version": 1
  }
{{- end }}
