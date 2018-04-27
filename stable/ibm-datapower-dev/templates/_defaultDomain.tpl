{{/* DataPower Configuration for default domain */}}
{{- define "defaultDomainConfig" }}
auto-startup.cfg: |
    top; configure terminal;

{{- if .Values.datapower.gatewaySshState }}
{{- if eq .Values.datapower.gatewaySshState "enabled" }}
    ssh {{ .Values.datapower.gatewaySshLocalAddress }} {{ .Values.datapower.gatewaySshPort }}
{{- end }}
{{- end }}

{{- if .Values.datapower.xmlManagementState }}
{{- if eq .Values.datapower.xmlManagementState "enabled" }}
    xml-mgmt
      admin-state {{ .Values.datapower.xmlManagementState }}
      local-address {{ .Values.datapower.xmlManagementLocalAddress }} {{ .Values.datapower.xmlManagementPort }}
      ssl-config-type server
    exit
{{- end }}
{{- end }}

{{- if .Values.datapower.restManagementState }}
{{- if eq .Values.datapower.restManagementState "enabled" }}
    rest-mgmt
      admin-state {{ .Values.datapower.restManagementState }}
      local-address {{ .Values.datapower.restManagementLocalAddress }} 
      port {{ .Values.datapower.restManagementPort }}
      ssl-config-type server
    exit
{{- end }}
{{- end }}

{{- if .Values.datapower.webGuiManagementState }}
{{- if eq .Values.datapower.webGuiManagementState "enabled" }}
    web-mgmt
      admin-state {{ .Values.datapower.webGuiManagementState }}
      local-address {{ .Values.datapower.webGuiManagementLocalAddress }} 
      port {{ .Values.datapower.webGuiManagementPort }}
      save-config-overwrite 
      idle-timeout 9000
      ssl-config-type server
    exit
{{- end }}
{{- end }}

    domain "{{ .Values.patternName}}"
      base-dir local:
      base-dir {{ .Values.patternName }}:
      config-file {{ .Values.patternName }}.cfg
      visible-domain default
      url-permissions "http+https" 
      file-permissions "CopyFrom+CopyTo+Delete+Display+Exec+Subdir" 
      file-monitoring "Audit+Log" 
      config-mode local
      import-format ZIP
      local-ip-rewrite 
      maxchkpoints 3
    exit
auto-user.cfg: |
    top; configure terminal;

    %if% available "user"

    user "admin"
      summary "Administrator"
      password-hashed "$1$12345678$kbapHduhihjieYIUP66Xt/"
      access-level privileged
    exit

    %endif%
{{- end }}
