{{/* TEMPLATE TO FIND THE PARENT CHART */}}
{{- define "asm.getParentChart" -}}
{{ $chartList := (splitList "/charts/" .Template.Name) }}
{{ $rootChartName := (index (splitList "/" (index $chartList 0)) 0) | trim }}
{{ printf "%s" $rootChartName | trim }}
{{- end -}}

{{/* FIND THE SIZE DATA BASED ON THE PARENT CHART */}}
{{- define "asm.sizeData" -}}
{{- $root := (index . 0) -}}
{{- $keyName := (index . 1) -}}
{{- $component := (include "sch.names.appName" (list $root)) -}}
{{- $parent := (include "asm.getParentChart" $root) | trim -}}
{{- $parentSizeKey := printf "%s.%s" $parent "asm.sizeData"}}
{{- $childSizeKey := printf "%s.%s" "ibm-netcool-asm-prod" "asm.sizeData" -}}
{{- $parentSizeData := fromYaml (include $parentSizeKey . ) -}}
{{- $childSizeData := fromYaml (include $childSizeKey . ) -}}
{{- $sizeData := merge $parentSizeData $childSizeData -}}
{{- $result := index $sizeData $component $root.Values.global.environmentSize $keyName -}}
{{- toYaml $result | trimSuffix "\n" -}}
{{- end -}}

{{/* DEFINITION OF ASM RESOURCE SIZING */}}
{{- define "ibm-netcool-asm-prod.asm.sizeData" -}}
alm-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
appdynamics-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
aws-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
azure-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
bigfixinventory-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
cienablueplanet-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
ciscoaci-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
contrail-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
docker-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
dns-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
dynatrace-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
docker-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
event-observer:
  size0:
    enableHPA: false
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    enableHPA: false
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "6.0"
file-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
googlecloud-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
ibmcloud-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
itnm-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
junipercso-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
kubernetes-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
newrelic-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
openstack-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
rest-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
sdk-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
servicenow-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
taddm-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
vmvcenter-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
vmwarensx-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
zabbix-observer:
  size0:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
layout:
  size0:
    enableHPA: false
    jvmArgs: "-Xms256M -Xmx750M"
    resources:
      requests:
        memory: "450Mi"
        cpu: "0.4"
      limits:
        memory: "1050Mi"
        cpu: "0.8"
  size1:
    enableHPA: false
    jvmArgs: "-Xms512M -Xmx2G"
    resources:
      requests:
        memory: "700Mi"
        cpu: "2.0"
      limits:
        memory: "2500Mi"
        cpu: "4.0"
merge:
  size0:
    enableHPA: false
    jvmArgs: "-Xms256M -Xmx350M"
    resources:
      requests:
        memory: "450Mi"
        cpu: "0.4"
      limits:
        memory: "550Mi"
        cpu: "0.8"
  size1:
    enableHPA: false
    jvmArgs: "-Xms512M -Xmx1G"
    resources:
      requests:
        memory: "1250Mi"
        cpu: "1.0"
      limits:
        memory: "1500Mi"
        cpu: "1.5"
search:
  size0:
    enableHPA: false
    jvmArgs: "-Xms256M -Xmx350M"
    resources:
      requests:
        memory: "450Mi"
        cpu: "0.4"
      limits:
        memory: "550Mi"
        cpu: "0.8"
  size1:
    enableHPA: false
    jvmArgs: "-Xms512M -Xmx512M"
    resources:
      requests:
        memory: "600Mi"
        cpu: "1.0"
      limits:
        memory: "800Mi"
        cpu: "1.5"
topology:
  size0:
    enableHPA: false
    jvmArgs: "-Dcom.ibm.jsse2.overrideDefaultTLS=true -Xms256M -Xmx400M"
    resources:
      requests:
        memory: "450Mi"
        cpu: "2.5"
      limits:
        memory: "700Mi"
        cpu: "4.0"
  size1:
    enableHPA: false
    jvmArgs: "-Dcom.ibm.jsse2.overrideDefaultTLS=true -Xms1G -Xmx3G"
    resources:
      requests:
        memory: "1200Mi"
        cpu: "3.0"
      limits:
        memory: "3600Mi"
        cpu: "6.0"
elasticsearch:
  size0:
    enableHPA: false
    jvmArgs: "-Xms1024M -Xmx2048M"
    resources:
      requests:
        memory: "1200Mi"
        cpu: "0.2"
      limits:
        memory: "2800Mi"
        cpu: "1.0"
  size1:
    enableHPA: true
    jvmArgs: "-Xms2048M -Xmx3072M"
    resources:
      requests:
        memory: "2400Mi"
        cpu: "1.0"
      limits:
        memory: "4000Mi"
        cpu: "2.5"
ui-api:
  size0:
    enableHPA: false
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    enableHPA: false
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
{{- end -}}
