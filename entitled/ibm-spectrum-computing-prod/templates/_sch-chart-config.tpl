{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.

*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibm-spectrum-computing.sch.chart.config.values" -}}
sch:
  chart:
    metering:
      productVersion: "1.0.0"
      productName: "IBM Spectrum Computing"
      productID: "IBM Spectrum Computing---9999K99"
    podsecurity:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        fsGroup: {{ .Values.pvc.fsGroup }}
        supplementalGroups:
          - {{ .Values.pvc.supplementalGroups }}
        runAsNonRoot: false
    podsecurity2:
      hostNetwork: false
      hostPID: false
      hostIPC: false
      securityContext:
        runAsNonRoot: false
    containerSecurity:
      securityContext:
        privileged: false
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: true
        capabilities:
          drop:
            - ALL
          add:
            - KILL
            - SETUID
            - SETGID
            - CHOWN
            - SETPCAP
            - NET_BIND_SERVICE
            # Needed for CICD
            - DAC_OVERRIDE
            # Needed for GPU mode control
            - SYS_ADMIN
    privcontainerSecurity:
      securityContext:
        privileged: true
        readOnlyRootFilesystem: false
        allowPrivilegeEscalation: true
        capabilities:
          drop:
            - ALL
          add:
            - KILL
            - SETUID
            - SETGID
            - CHOWN
            - SETPCAP
            - NET_BIND_SERVICE
            # Needed for CICD
            - DAC_OVERRIDE
            # Needed for GPU mode control
            - SYS_ADMIN
    labelType: prefixed
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: beta.kubernetes.io/arch
              operator: In
              values:
              - "amd64"
              - "ppc64le"
    env:
      - name: NVIDIA_VISIBLE_DEVICES
        value: all
{{- if .Values.gpu.nvidiapath }}
      - name: LD_LIBRARY_PATH
        value: /usr/local/nvidia/lib:/usr/local/nvidia/lib64
      - name: PATH
        value: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin
{{- end }}

{{- end -}}
