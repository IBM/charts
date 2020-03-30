{{/* DataPower Configuration for default domain */}}
{{- define "ibm-datapower-icp4i.defaultDomainConfig" }}
auto-startup.cfg: |
    top; configure terminal;

{{- if .Values.datapower.adminUserSecret }}
    %if% available "include-config"

    include-config "auto-user-cfg"
      config-url "config:///auto-user.cfg"
      auto-execute
      no interface-detection
    exit

    exec "config:///auto-user.cfg"

    %endif%
{{- end }}

    %if% available "include-config"

    include-config "healthCheck"
      config-url "config:///health-check.cfg
      auto-execute
      no interface-detection
    exit

    %endif%

    exec "config:///health-check.cfg"

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

{{- if .Values.datapower.snmpState }}
{{- if eq .Values.datapower.snmpState "enabled" }}
    %if% available "snmp"
    snmp
      admin-state {{ .Values.datapower.snmpState }}
      version 2c
      ip-address {{ .Values.datapower.snmpLocalAddress }}
      port {{ .Values.datapower.snmpPort }}
      community public default read-only 0.0.0.0/0
      trap-default-subscriptions
      trap-priority warn
      trap-code 0x00030002
      trap-code 0x00230003
      trap-code 0x00330002
      trap-code 0x00b30014
      trap-code 0x00e30001
      trap-code 0x00e40008
      trap-code 0x00f30008
      trap-code 0x01530001
      trap-code 0x01a2000e
      trap-code 0x01a40001
      trap-code 0x01a40005
      trap-code 0x01a40008
      trap-code 0x01b10006
      trap-code 0x01b10009
      trap-code 0x01b20002
      trap-code 0x01b20004
      trap-code 0x01b20008
      trap-code 0x02220001
      trap-code 0x02220003
      trap-code 0x02240002
    exit
    %endif%
{{- end }}
{{- end }}

{{- if ne .Values.patternName "none" }}
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
{{- end }}

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
