# © Copyright IBM Corporation 2019
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.

*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "sch.chart.config.values" -}}
sch:
  chart:
    appName: "icp4i-asset-repo"
    nodeAffinity:
      nodeAffinityRequiredDuringScheduling:
        operator: In
        values:
        - amd64
      nodeAffinityPreferredDuringScheduling:
        amd64:
          weight: 2
          operator: In
          key: beta.kubernetes.io/arch
    metering:
      productName: IBM Cloud Pak for Integration Asset Repository
      productID: c8b82d189e7545f0892db9ef2731b90d
      productVersion: 2019.4.1
      productMetric: VIRTUAL_PROCESSOR_CORE
      productChargedContainers: ''
      cloudpakName: IBM Cloud Pak for Integration
      cloudpakId: c8b82d189e7545f0892db9ef2731b90d
      cloudpakVersion: 2019.4.1
    components:
      cloudant:
        statefulSet:
          name: "ctl-sts"
  names:
    volumeClaimTemplateName:
      maxLength: 45
      possiblePrefix: "glusterfs-dynamic-"
    persistentVolumeClaimName:
      maxLength: 45
      possiblePrefix: "glusterfs-dynamic-"
{{- end -}}
