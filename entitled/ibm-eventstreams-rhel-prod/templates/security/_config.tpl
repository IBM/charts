{{- define "security.sch.chart.config.values" -}}
sch:
  config:

    #
    # Security-specific settings not intended for overriding
    #
    security:

      iamPAPSuffix: "iam-pap"
      iamPDPSuffix: "iam-pdp"
      iamTokenSuffix: "iam-token"

      accesscontroller:
        # Number of replicas for the access controller server
        replicas: 2

{{- end -}}
