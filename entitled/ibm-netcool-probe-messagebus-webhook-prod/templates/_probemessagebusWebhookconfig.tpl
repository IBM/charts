{{- /* messagebus probe configuration for webhook  */ -}}
{{- define "ibm-netcool-probe-messagebus-webhook-prod.probeMessagebusConfig" }}
message_bus.props: |
  Manager           : '{{ .Release.Name }}-message_bus-wh'
{{- if .Values.netcool.backupServer }}
  Server            : 'AGG_V'
  {{ else }}
  Server            : '{{ .Values.netcool.primaryServer }}'
  {{- end }}
  MessageLog        : 'stdout'
  MessageLevel      : '{{ default "warn" .Values.probe.messageLevel }}'
  TransportType     : 'Webhook'
  TransportFile     : '/opt/IBM/tivoli/netcool/omnibus/java/conf/Transport.properties'
  TransformerFile   : '/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/message_bus_parser_config.json'
  Host              : '{{ .Values.probe.host }}'
  Port              : {{ .Values.probe.port }}
  Username          : '{{ .Values.probe.username }}'
  Password          : '{{ .Values.probe.password }}'
  HeartbeatInterval : {{ .Values.probe.heartbeatInterval }}
  InitialResync     : '{{ .Values.probe.initialResync }}'
  ResyncInterval    : {{ .Values.probe.resyncInterval }}
  {{ if .Values.probe.sslSecretName }}
  EnableSSL         : 'true'
  {{ else }}
  ## Secret Name is unset. To connect to a remote target using HTTPS,
  ## a secret containing the server.crt and keystorepassword.txt must be specified.
  EnableSSL         : 'false'
  {{ end }}

  ## Enable HTTP API
  NHttpd.EnableHTTP : TRUE
  NHttpd.ListeningPort : 8080

message_bus_parser_config.json: |
 {
    "eventSources" : [ {
      "endpoint" : "{{ include  "ibm-netcool-probe-messagebus-webhook-prod.getFinalURI"  . }}",
      "name" : "NotificationAlarmParser",
      "config" : {
        "dataToRecord" : [ ],
        "messagePayload" : "{{ .Values.probe.jsonParserConfig.notification.messagePayload }}",
        "messageHeader" : "{{ .Values.probe.jsonParserConfig.notification.messageHeader }}",
        "jsonNestedPayload" : "{{ .Values.probe.jsonParserConfig.notification.jsonNestedPayload }}",
        "jsonNestedHeader" : "{{ .Values.probe.jsonParserConfig.notification.jsonNestedHeader }}",
        "messageDepth" : {{ .Values.probe.jsonParserConfig.notification.messageDepth }}
      }
    }
    {{- if .Values.webhook.resyncRequest.uri -}},{
      "endpoint" : "resync",
      "name" : "ResyncAlarmParser",
      "config" : {
        "dataToRecord" : [ ],
        "messagePayload" : "{{ .Values.probe.jsonParserConfig.resync.messagePayload }}",
        "messageHeader" : "{{ .Values.probe.jsonParserConfig.resync.messageHeader }}",
        "jsonNestedPayload" : "{{ .Values.probe.jsonParserConfig.resync.jsonNestedPayload }}",
        "jsonNestedHeader" : "{{ .Values.probe.jsonParserConfig.resync.jsonNestedHeader }}",
        "messageDepth" : {{ .Values.probe.jsonParserConfig.resync.messageDepth }}
      }
    }
    {{- end -}}
    , {
      "name" : "OtherAlarmParser",
      "type" : "ANY",
      "config" : {
        "dataToRecord" : [ ],
        "messagePayload" : "json",
        "messageHeader" : "",
        "jsonNestedPayload" : "",
        "jsonNestedHeader" : "",
        "messageDepth" : 5
      }
    }]
  }

Transport.properties: |
  #################################################
  ####### restWebHookTransport.properties #########
  #################################################
  
  webhookURI=http://localhost:4080{{ include "ibm-netcool-probe-messagebus-webhook-prod.getFinalURI" . }}
  httpVersion={{ .Values.webhook.httpVersion }}
  responseTimeout={{ .Values.webhook.responseTimeout }}
  idleTimeout={{ .Values.webhook.idleTimeout }}
  httpHeaders={{ .Values.webhook.httpHeaders }}
  autoReconnect={{ include "ibm-netcool-probe-messagebus-webhook-prod.toOnOff" ( .Values.webhook.autoReconnect | toString ) }}
  loginRequestURI={{ .Values.webhook.loginRequest.uri }}
  loginRequestMethod={{ .Values.webhook.loginRequest.method }}
  loginRequestContent={{ .Values.webhook.loginRequest.content }}
  loginRequestHeaders={{ .Values.webhook.loginRequest.headers }}
  loginRefreshURI={{ .Values.webhook.loginRefresh.uri }}
  loginRefreshMethod={{ .Values.webhook.loginRefresh.method }}
  loginRefreshContent={{ .Values.webhook.loginRefresh.content }}
  loginRefreshHeaders={{ .Values.webhook.loginRefresh.headers }}
  loginRefreshInterval={{ .Values.webhook.loginRefresh.interval }}
  logoutRequestURI={{ .Values.webhook.logoutRequest.uri }}
  logoutRequestMethod={{ .Values.webhook.logoutRequest.method }}
  logoutRequestContent={{ .Values.webhook.logoutRequest.content }}
  logoutRequestHeaders={{ .Values.webhook.logoutRequest.headers }}
  resyncRequestURI={{ .Values.webhook.resyncRequest.uri }}
  resyncRequestMethod={{ .Values.webhook.resyncRequest.method }}
  resyncRequestContent={{ .Values.webhook.resyncRequest.content }}
  resyncRequestHeaders={{ .Values.webhook.resyncRequest.headers }}
  subscribeRequestURI={{ .Values.webhook.subscribeRequest.uri }}
  subscribeRequestMethod={{ .Values.webhook.subscribeRequest.method }}
  subscribeRequestContent={{ .Values.webhook.subscribeRequest.content }}
  subscribeRequestHeaders={{ .Values.webhook.subscribeRequest.headers }}
  subscribeRefreshURI={{ .Values.webhook.subscribeRefresh.uri }}
  subscribeRefreshMethod={{ .Values.webhook.subscribeRefresh.method }}
  subscribeRefreshContent={{ .Values.webhook.subscribeRefresh.content }}
  subscribeRefreshHeaders={{ .Values.webhook.subscribeRefresh.headers }}
  subscribeRefreshInterval={{ .Values.webhook.subscribeRefresh.interval }}
  keepTokens={{ .Values.webhook.keepTokens }}
  refreshRetryCount={{ .Values.webhook.refreshRetryCount }}
  securityProtocol={{ .Values.webhook.securityProtocol | default "TLSv1.2" }}
  respondWithContent={{ include "ibm-netcool-probe-messagebus-webhook-prod.toOnOff" ( .Values.webhook.respondWithContent | toString ) }}
  validateBodySyntax={{ include "ibm-netcool-probe-messagebus-webhook-prod.toOnOff" ( .Values.webhook.validateBodySyntax | toString ) }}
  validateRequestURI={{ include "ibm-netcool-probe-messagebus-webhook-prod.toOnOff" ( .Values.webhook.validateRequestURI | toString ) }}


omni.dat: |
  [{{ .Values.netcool.primaryServer }}]
  {
    Primary: {{ .Values.netcool.primaryHost }} {{ .Values.netcool.primaryPort }}
  }
  {{ if .Values.netcool.backupServer -}}
  [{{ .Values.netcool.backupServer }}]
  {
    Primary: {{ .Values.netcool.backupHost }} {{ .Values.netcool.backupPort }}
  }
  [AGG_V]
  {
    Primary: {{ .Values.netcool.primaryHost }} {{ .Values.netcool.primaryPort }}
    Backup: {{ .Values.netcool.backupHost }} {{ .Values.netcool.backupPort }}
  }
  {{- end -}}
{{- end }}
