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
        
        # resource limits to apply to the AccessController pods
        # ref: http://kubernetes.io/docs/user-guide/compute-resources/
        resources:
          limits:
            cpu: 100m
            memory: 250Mi
          requests:
            cpu: 100m
            memory: 250Mi

        # Number of replicas for the access controller server
        replicas: 2

{{- end -}}
