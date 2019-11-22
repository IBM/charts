{{- define "ui.sch.chart.config.values" -}}
sch:
  config:

    #
    # UI-specific settings not intended for overriding
    #
    ui:

      # Number of replicas for the UI server
      replicas: 1

      # Path to the mounted release config map
      releaseConfigMapMountPath: /etc/release-configmap

      # The mounted external rest proxy port key and file name
      restProxyExternalPort: restProxyExternalPort

      # The mounted external rest proxy port key and file name
      externalAddress: EXTERNAL_ENDPOINT

{{- end -}}
