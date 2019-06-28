{{ define "couchdb.sidecar.probes" }}
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/cluster-configured
  initialDelaySeconds: 30
  periodSeconds: 30
readinessProbe:
  exec:
    command:
    - cat
    - /tmp/cluster-configured
  initialDelaySeconds: 30
  periodSeconds: 30
{{ end }}
