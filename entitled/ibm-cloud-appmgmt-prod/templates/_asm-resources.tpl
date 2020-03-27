{{- define "ibm-cloud-appmgmt-prod.asm.sizeData" -}}
elasticsearch:
  size0:
    jvmArgs: "-Xms64M -Xmx512M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.2"
      limits:
        memory: "800Mi"
        cpu: "1.0"
  size1:
    jvmArgs: "-Xms1024M -Xmx1024M"
    resources:
      requests:
        memory: "2048Mi"
        cpu: "1.0"
      limits:
        memory: "2048Mi"
        cpu: "2.0"
  size0_amd64:
    jvmArgs: "-Xms64M -Xmx512M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.2"
      limits:
        memory: "800Mi"
        cpu: "1.0"
  size1_amd64:
    jvmArgs: "-Xms1024M -Xmx1024M"
    resources:
      requests:
        memory: "2048Mi"
        cpu: "1.0"
      limits:
        memory: "2048Mi"
        cpu: "2.0"
  size0_ppc64le:
    jvmArgs: "-Xms64M -Xmx512M"
    resources:
      requests:
        memory: "800Mi"
        cpu: "0.1"
      limits:
        memory: "800Mi"
        cpu: "0.5"
  size1_ppc64le:
    jvmArgs: "-Xms1024M -Xmx1024M"
    resources:
      requests:
        memory: "2048Mi"
        cpu: "0.5"
      limits:
        memory: "2048Mi"
        cpu: "1.0"
event-observer:
  size0:
    enableHPA: false
    jvmArgs: "-Xms64M -Xmx128M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.05"
      limits:
        memory: "350Mi"
        cpu: "0.8"
  size1:
    enableHPA: true
    jvmArgs: "-Xms64M -Xmx128M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "350Mi"
        cpu: "1.0"
  size0_amd64:
    enableHPA: false
    jvmArgs: "-Xms64M -Xmx128M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.05"
      limits:
        memory: "350Mi"
        cpu: "0.8"
  size1_amd64:
    enableHPA: true
    jvmArgs: "-Xms64M -Xmx128M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "350Mi"
        cpu: "1.0"
  size0_ppc64le:
    enableHPA: false
    jvmArgs: "-Xms64M -Xmx128M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.025"
      limits:
        memory: "350Mi"
        cpu: "0.4"
  size1_ppc64le:
    enableHPA: true
    jvmArgs: "-Xms64M -Xmx128M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "350Mi"
        cpu: "0.5"
layout:
  size0:
    enableHPA: false
    jvmArgs: "-Xms64M -Xmx256M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    enableHPA: true
    jvmArgs: "-Xms512M -Xmx512M"
    resources:
      requests:
        memory: "600Mi"
        cpu: "0.5"
      limits:
        memory: "800Mi"
        cpu: "1.0"
  size0_amd64:
    enableHPA: false
    jvmArgs: "-Xms64M -Xmx256M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    enableHPA: true
    jvmArgs: "-Xms512M -Xmx512M"
    resources:
      requests:
        memory: "600Mi"
        cpu: "0.5"
      limits:
        memory: "800Mi"
        cpu: "1.0"
  size0_ppc64le:
    enableHPA: false
    jvmArgs: "-Xms64M -Xmx256M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    enableHPA: true
    jvmArgs: "-Xms512M -Xmx512M"
    resources:
      requests:
        memory: "600Mi"
        cpu: "0.25"
      limits:
        memory: "800Mi"
        cpu: "0.5"
search:
  size0:
    enableHPA: false
    jvmArgs: "-Xms64M -Xmx256M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1:
    enableHPA: true
    jvmArgs: "-Xms64M -Xmx384M"
    resources:
      requests:
        memory: "500Mi"
        cpu: "0.5"
      limits:
        memory: "600Mi"
        cpu: "1.0"
  size0_amd64:
    enableHPA: false
    jvmArgs: "-Xms64M -Xmx256M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    enableHPA: true
    jvmArgs: "-Xms64M -Xmx384M"
    resources:
      requests:
        memory: "500Mi"
        cpu: "0.5"
      limits:
        memory: "600Mi"
        cpu: "1.0"
  size0_ppc64le:
    enableHPA: false
    jvmArgs: "-Xms64M -Xmx256M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    enableHPA: true
    jvmArgs: "-Xms64M -Xmx384M"
    resources:
      requests:
        memory: "500Mi"
        cpu: "0.25"
      limits:
        memory: "600Mi"
        cpu: "0.5"
topology:
  size0:
    enableHPA: false
    jvmArgs: "-Xms128M -Xmx768M"
    resources:
      requests:
        memory: "900Mi"
        cpu: "0.5"
      limits:
        memory: "1100Mi"
        cpu: "1.0"
  size1:
    enableHPA: true
    jvmArgs: "-Xms128M -Xmx1024M"
    resources:
      requests:
        memory: "1200Mi"
        cpu: "1.0"
      limits:
        memory: "1500Mi"
        cpu: "2.0"
  size0_amd64:
    enableHPA: false
    jvmArgs: "-Xms128M -Xmx768M"
    resources:
      requests:
        memory: "900Mi"
        cpu: "0.5"
      limits:
        memory: "1100Mi"
        cpu: "1.0"
  size1_amd64:
    enableHPA: true
    jvmArgs: "-Xms128M -Xmx1024M"
    resources:
      requests:
        memory: "1200Mi"
        cpu: "1.0"
      limits:
        memory: "1500Mi"
        cpu: "2.0"
  size0_ppc64le:
    enableHPA: false
    jvmArgs: "-Xms128M -Xmx768M"
    resources:
      requests:
        memory: "900Mi"
        cpu: "0.25"
      limits:
        memory: "1100Mi"
        cpu: "0.5"
  size1_ppc64le:
    enableHPA: true
    jvmArgs: "-Xms128M -Xmx1024M"
    resources:
      requests:
        memory: "1200Mi"
        cpu: "0.5"
      limits:
        memory: "1500Mi"
        cpu: "1.0"
ui-api:
  size0:
    enableHPA: false
    resources:
      requests:
        memory: "50Mi"
        cpu: "0.1"
      limits:
        memory: "100Mi"
        cpu: "0.8"
  size1:
    enableHPA: true
    resources:
      requests:
        memory: "100Mi"
        cpu: "0.2"
      limits:
        memory: "150Mi"
        cpu: "1.0"
  size0_amd64:
    enableHPA: false
    resources:
      requests:
        memory: "50Mi"
        cpu: "0.1"
      limits:
        memory: "100Mi"
        cpu: "0.8"
  size1_amd64:
    enableHPA: true
    resources:
      requests:
        memory: "100Mi"
        cpu: "0.2"
      limits:
        memory: "150Mi"
        cpu: "1.0"
  size0_ppc64le:
    enableHPA: false
    resources:
      requests:
        memory: "50Mi"
        cpu: "0.05"
      limits:
        memory: "100Mi"
        cpu: "0.4"
  size1_ppc64le:
    enableHPA: true
    resources:
      requests:
        memory: "100Mi"
        cpu: "0.1"
      limits:
        memory: "150Mi"
        cpu: "0.5"
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
  size0_amd64:
    enableHPA: false
    jvmArgs: "-Xms256M -Xmx350M"
    resources:
      requests:
        memory: "450Mi"
        cpu: "0.4"
      limits:
        memory: "550Mi"
        cpu: "0.8"
  size1_amd64:
    enableHPA: false
    jvmArgs: "-Xms512M -Xmx1G"
    resources:
      requests:
        memory: "1250Mi"
        cpu: "1.0"
      limits:
        memory: "1500Mi"
        cpu: "1.5"
  size0_ppc64le:
    enableHPA: false
    jvmArgs: "-Xms256M -Xmx350M"
    resources:
      requests:
        memory: "450Mi"
        cpu: "0.2"
      limits:
        memory: "550Mi"
        cpu: "0.4"
  size1_ppc64le:
    enableHPA: false
    jvmArgs: "-Xms512M -Xmx1G"
    resources:
      requests:
        memory: "1250Mi"
        cpu: "0.5"
      limits:
        memory: "1500Mi"
        cpu: "0.75"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
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
  size0_amd64:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.2"
      limits:
        memory: "450Mi"
        cpu: "0.8"
  size1_amd64:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.5"
      limits:
        memory: "750Mi"
        cpu: "1.0"
  size0_ppc64le:
    jvmArgs: "-Xms128M -Xmx256M"
    resources:
      requests:
        memory: "200Mi"
        cpu: "0.1"
      limits:
        memory: "450Mi"
        cpu: "0.4"
  size1_ppc64le:
    jvmArgs: "-Xms256M -Xmx400M"
    resources:
      requests:
        memory: "350Mi"
        cpu: "0.25"
      limits:
        memory: "750Mi"
        cpu: "0.5"
{{- end -}}
