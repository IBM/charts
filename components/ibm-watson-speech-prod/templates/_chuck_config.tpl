{{- define "chuck.chuckResourceRequirements" -}}
{{- $params := . -}}
{{- $threads := index $params 0 -}}
{{- $ttsMarginalCPU := index $params 1 -}}
class RapidResourceRequirement:
    resourceRequirement = {
        'marginalMem': 900 * 2 ** 20,
        'marginalCpu': 60
    }
class LMTrainingResourceRequirement:
    resourceRequirement = {
        'marginalMem': 2.4 * 2 ** 30,  # 2.4GB
        'marginalCpu': 100  # 1CPU
    }

class AMTrainingResourceRequirement:
    num_threads = {{ $threads }}
    resourceRequirement = {
        'marginalMem': num_threads * 1.2 * 2 ** 30,
        'marginalCpu': num_threads * 100
    }

class AMTrainInnerResourceRequirement:
    resourceRequirement = {
        'marginalMem': 0,
        'marginalCpu': 0
    }

class WTTSDnnResourceRequirement:
    resourceRequirement = {
        'marginalMem' : 250*2**20, # 130 MB
        'marginalCpu' : {{ div $ttsMarginalCPU 10 }}
    }

class WTTSLargeVoiceResourceRequirement:
    resourceRequirement = {
        'marginalMem' : 600*2**20, # 600 MB
        'marginalCpu': 20
    }

class ValidateAudioResourceRequirement:
    resourceRequirement = {
        'marginalMem': 0.1 * 2 ** 30,  # 100MB
        'marginalCpu': 10  # 0.1CPU
    }

class RnntResourceRequirement:
        resourceRequirement = {
            'marginalMem': 0.06 * 2 ** 30,  # 60MB
            'marginalCpu': 15  # 0.15CPU
        }
{{- end -}}

{{- define "chuck.chuckSessionPoolsPy" -}}
class PreWarmingPolicy:
    sessionPool = {
        'minWarmSessions': 1,
        'maxUseCount': 1000
    }

class NoPreWarmingPolicy:
    sessionPool = {
        'maxUseCount': 1000
    }

class DefaultPolicy:
    sessionPool = {}

class RealtimeResourceRequirement:
    resourceRequirement = {
        'marginalMem' : 900*2**20,
        'marginalCpu': 100
    }
{{- end -}}

{{- define "chuck.chuckSessionPoolsYaml" -}}
{{- $models := . -}}
defaultPolicy: DefaultPolicy
sessionPoolPolicies:
  NoPreWarmingPolicy:
  - name: TrainAMModel
  - name: TrainAMModelInner
{{- if $models }}
  PreWarmingPolicy:
  {{/* FIXME: remove thiw when generic-model is handled elsewhere */}}
  {{- range $name, $model := $models -}}
  {{- if include "chuck.isModelEnabledAndNonGeneric" $model -}}
  - name: {{ $model.catalogName }}
  {{ end -}}
  {{- end -}}
{{- end -}}
{{- end -}}
