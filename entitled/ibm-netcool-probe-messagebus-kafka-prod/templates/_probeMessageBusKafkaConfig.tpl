{{/* Message Bus Probe for configuration */}}
{{- define "ibm-netcool-probe-messagebus-kafka-prod.probeMessageBusKafkaConfig" }}
{{- $netcoolSslEnabled := include "ibm-netcool-probe-messagebus-kafka-prod.secobj.netcoolConnectionSslEnabled" ( . ) -}}
{{- $netcoolAuthEnabled := include "ibm-netcool-probe-messagebus-kafka-prod.secobj.netcoolConnectionAuthEnabled" ( . ) -}}

message_bus.props: |
  ## OMNIbus Properties
  Manager         : '{{ .Release.Name }}-message_bus-kfk'
  MessageLevel    : '{{ default "warn" .Values.messagebus.probe.messageLevel }}'
  MessageLog      : 'stdout'
  PropsFile       : '/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/message_bus.props'
  RulesFile       : '/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/message_bus.rules'
  {{- if .Values.messagebus.netcool.backupServer }}
  Server          : 'AGG_V'
  {{ else }}
  Server          : '{{ .Values.messagebus.netcool.primaryServer }}'
  {{- end }}

  # Probe Framework Properties
  HeartbeatInterval: {{ default "10" .Values.messagebus.probe.heartbeatInterval }}

  ## Probe Specific Properties
  MessagePayload  : 'JSON'
  TransformerFile : '/opt/IBM/tivoli/netcool/omnibus/probes/linux2x86/message_bus_parser_config.json'
  TransportFile   : '/opt/IBM/tivoli/netcool/omnibus/java/conf/Transport.properties'
  TransportType   : '{{ default "KAFKA" .Values.messagebus.probe.transportType }}'

  ##======================================================================
  ## SETTING CREDENTIALS WHEN KAFKA TRANSPORT ALSO NEEDS A HTTP TRANSPORT 
  ##======================================================================

  #======================================================================
  # SETTING SSL & KEYSTORE
  #======================================================================
  {{- if .Values.messagebus.kafka.client.ssl.keyStoreSecretName }}
  EnableSSL        : 'true'
  {{ else }}
  {{- if .Values.messagebus.probe.secretName }}
  {{ if or (eq .Values.messagebus.kafka.client.securityProtocol "SASL_SSL") (eq .Values.messagebus.kafka.client.securityProtocol "SSL") }}
  EnableSSL        : 'true'
  {{- end }}
  {{- end }}
  {{- end }}

  {{ if or (eq $netcoolSslEnabled "true") (eq $netcoolAuthEnabled "true") }}
  # Secure connection to Object Server
  {{- if (eq $netcoolSslEnabled "true") }}
  # SSL connection enabled
  {{- if .Values.messagebus.probe.sslServerCommonName }}
  SSLServerCommonName: '{{ .Values.probe.sslServerCommonName }}'
  {{- end }}
  {{- end }}
  ConfigCryptoAlg: 'AES_FIPS'
  {{- if (eq $netcoolAuthEnabled "true") }}
  # Authentication enabled. AuthUserName and AuthPassword properties are 
  # intentionally not shown in this Config Map and will be set by the probe during 
  # initialization. 
  # AuthUserName: '<AuthUserName from {{ .Values.messagebus.netcool.secretName }} secret>'
  # AuthPassword: '<AuthPassword from {{ .Values.messagebus.netcool.secretName }} secret>'
  ConfigKeyFile: '/opt/IBM/tivoli/netcool/etc/security/keys/encryption.keyfile'
  {{- end }}
  {{- end }}

  ## Enable HTTP API
  NHttpd.EnableHTTP : TRUE
  NHttpd.ListeningPort : 8080


omni.dat: |
  [{{ .Values.messagebus.netcool.primaryServer }}]
  {
    Primary: {{ .Values.messagebus.netcool.primaryHost }}{{ if (eq $netcoolSslEnabled "true") }} ssl{{ end }} {{ .Values.messagebus.netcool.primaryPort }}
  }
  {{ if .Values.messagebus.netcool.backupServer -}}
  [{{ .Values.messagebus.netcool.backupServer }}]
  {
    Primary: {{ .Values.messagebus.netcool.backupHost }}{{ if (eq $netcoolSslEnabled "true") }} ssl{{ end }} {{ .Values.messagebus.netcool.backupPort }}
  }
  [AGG_V]
  {
    Primary: {{ .Values.messagebus.netcool.primaryHost }}{{ if (eq $netcoolSslEnabled "true") }} ssl{{ end }} {{ .Values.messagebus.netcool.primaryPort }}
    Backup: {{ .Values.messagebus.netcool.backupHost }}{{ if (eq $netcoolSslEnabled "true") }} ssl{{ end }} {{ .Values.messagebus.netcool.backupPort }}
  }
  {{- end }}


transformer-file: |
  {
    "eventSources" : [ 
    {{- if .Values.messagebus.kafka.connection.topics }}
    {{- $topicList := ( .Values.messagebus.kafka.connection.topics | splitList ",") }}
    {{- range $topic := $topicList }}
    {{- if $topic }}
    {
      "endpoint" : "{{ $topic }}",
      "name" : "{{ $topic }} Topic Alarm Parser",
      "config" : 
      {
        "dataToRecord" : [ ],
        "messagePayload" : "{{ default "json" $.Values.messagebus.probe.jsonParserConfig.messagePayload }}",
        "messageHeader" : "{{ $.Values.messagebus.probe.jsonParserConfig.messageHeader }}",
        "jsonNestedPayload" : "{{ $.Values.messagebus.probe.jsonParserConfig.jsonNestedPayload }}",
        "jsonNestedHeader" : "{{ $.Values.messagebus.probe.jsonParserConfig.jsonNestedHeader }}",
        "messageDepth" : {{ $.Values.messagebus.probe.jsonParserConfig.messageDepth | default 4 }}
      }
    },
    {{- end -}}
    {{- end -}}
    {{- end -}}
    {
      "name" : "OtherAlarmParser",
      "type" : "ANY",
      "config" : 
      {
        "dataToRecord" : [ ],
        "messagePayload" : "json",
        "messageHeader" : "",
        "jsonNestedPayload" : "",
        "jsonNestedHeader" : "",
        "messageDepth" : 5
      }
    }
    ]
  }


transport-file: |
  ##==============================================================================
  ## KAFKA CLIENT MODE AS CONSUMER  OR PRODUCER TO KAFKA SYSTEM 
  ## VALID VALUES = CONSUMER | PRODUCER
  ##==============================================================================
  KafkaClientMode=CONSUMER
  ##
  ##==============================================================================
  ## LOCATION OF JSON FILE CONTAINING KAFKA & ZOOKEEPER CONNECTION PROPERTIES
  ##==============================================================================
  ConnectionPropertiesFile=/opt/IBM/tivoli/netcool/omnibus/java/conf/kafkaConnectionProperties.json

  ##==============================================================================
  ## LOCATION OF FILE CONTAINING REST CONNECTION PROPERTIES
  ##==============================================================================
  #httpConnectionPropertiesFile=$OMNIHOME/java/conf/restMultiChannelHttpTransport.json


kafka-trans-conn-props: |-
  {
    "zookeeper_client" : 
        {
            "target" : "{{ .Values.messagebus.kafka.connection.zookeeperClient.target | default "" }}",
            "properties" : "",
            "java_sys_props" : "",
            "topic_watch": {{ .Values.messagebus.kafka.connection.zookeeperClient.topicWatch | default "false" }},
            "broker_watch": {{ .Values.messagebus.kafka.connection.zookeeperClient.brokerWatch | default "false" }}
        },
    "brokers" : "{{ .Values.messagebus.kafka.connection.brokers | default "" }}",
    "topics": "{{ .Values.messagebus.kafka.connection.topics | default "" }}",
    "kafka_client" : 
        {
            "properties" : "/opt/IBM/tivoli/netcool/omnibus/java/conf/kafkaClient.properties",
            {{- if or (eq .Values.messagebus.kafka.client.securityProtocol "SASL_PLAINTEXT") (eq .Values.messagebus.kafka.client.securityProtocol "SASL_SSL") }}
            "java_sys_props" : "/opt/IBM/tivoli/netcool/omnibus/java/conf/kafkaClient_javaSys.properties"
            {{- else }}
            "java_sys_props" : ""
            {{- end }}
        }
  }


kafka-client-props: |
  ##==============================================================================
  ## THIS FILE CONTAINS CONFIGURATIONS FOR KAFKA CLIENT USED VIA MESSAGE BUS PROBE
  ## THERE ARE 2 TYPES OF CLIENT. CONSUMER & PRODUCER CLIENT ENABLE PROPERTY SETS
  ## AS REQUIRED.
  ##==============================================================================

  ##==============================================================================
  ##1. COMMON KAFKA CLIENT PROPERTIES
  ##==============================================================================

  ###########################################################
  ## SECURITY PROTOCOLS CONFIGURATIONS
  ###########################################################
  ## SUPPORTED SECURITY PROTOCOL (SASL_PLAINTEXT | SASL_SSL)
  {{- if .Values.messagebus.kafka.client.securityProtocol }}
  security.protocol={{ .Values.messagebus.kafka.client.securityProtocol }}
  {{ else }}
  ##security.protocol=SASL_PLAINTEXT
  {{- end }}


  ###########################################################
  ## SSL CONFIGURATIONS
  ###########################################################
  {{ if (eq .Values.messagebus.kafka.client.securityProtocol "SSL") or (eq .Values.messagebus.kafka.client.securityProtocol "SASL_SSL") }}
  ## SUPPORTED SSL PROTOCOLS (TLSv1.2,TLSv1.1,TLSv1)
  ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1
  {{ else }}
  ##ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1
  {{ end }}

  ## KAFKA CLIENT'S SSL - KEYSTORE CONFIGURATION
  {{- if .Values.messagebus.kafka.client.ssl.keyStoreSecretName }}
  ssl.keystore.location=
  ssl.keystore.password=
  ssl.keystore.type=JKS
  {{ else }}
  ##ssl.keystore.location=
  ##ssl.keystore.password=
  ##ssl.keystore.type=JKS
  {{- end }}

  ## KAFKA CLIENT'S SSL - TRUSTSTORE CONFIGURATION
  {{- if .Values.messagebus.kafka.client.ssl.trustStoreSecretName }}
  ssl.truststore.location=
  ssl.truststore.password=
  ssl.truststore.type=JKS
  {{ else }}
  ##ssl.truststore.location=
  ##ssl.truststore.password=
  ##ssl.truststore.type=JKS
  {{- end }}


  ###########################################################
  ## SASL AUTHENTICATION CONFIGURATIONS
  ###########################################################
  {{- if .Values.messagebus.kafka.client.saslPlainMechanism }}
  sasl.mechanism=PLAIN
  {{ else }}
  ##sasl.mechanism=PLAIN
  {{- end }}

  ##==============================================================================



  ##==============================================================================
  ##2. KAFKA CONSUMER SPECIFIC PROPERTIES
  ##==============================================================================
  ###########################################################
  ## A CONSUMER BELONGS TO A GROUP. MULTIPLE CONSUMERS CAN BE LONG SAME GROUP.
  ## MULTIPLE CONSUMERS EACH WITH A UNIQUE GROUP WILL EACH RECEIVE EVENTS SEPARATELY
  ## MULTIPLE CONSUMERS IN 1 GROUP CAUSES EVENTS TO LOAD BALANCE BETWWEN CONSUMERS
  ###########################################################
  {{- if .Values.messagebus.kafka.client.consumer.groupId }}
  group.id={{ .Values.messagebus.kafka.client.consumer.groupId | default "test-consumer-group" }}
  {{ else }}
  ##group.id=KafkaConsumerGroupName
  {{- end }}

  ###########################################################
  ## CONSUMER'S EVENT POOLING INTERVAL
  ###########################################################
  ##pollInterval=1000

  ###########################################################
  ## MAXIMUM NUMBER OF RECORDS TO RECEIVE ON EACH POLL
  ###########################################################
  ##max.poll.records=10

  ###########################################################
  ## AUTO COMMITS. ON INTERNAL, USES INTERVAL BELOW
  ###########################################################
  ##enable.auto.commit=false

  ###########################################################
  ## COMMITS EVERY 5 SECONDS
  ###########################################################
  ##auto.commit.interval.ms=5000

  ###########################################################
  ## STARTING OFFSET
  ###########################################################
  ##auto.offset.reset=latest

  ###########################################################
  ##KEY & VALUE OBJECT DESERIALIZER
  ###########################################################
  ##key.deserializer=org.apache.kafka.common.serialization.LongDeserializer
  ##value.deserializer=org.apache.kafka.common.serialization.StringDeserializer
  ##
  ##==============================================================================



  ##==============================================================================
  ##3. KAFKA PRODUCER PROPERTIES
  ##==============================================================================
  ###########################################################
  ## CLIENT ID IS PASSED TO SERVER WHEN MAKING REQUEST SO SERVER CAN TRACKS SOURCE 
  ## OF REQUEST BEYOND IP/PORT FOR LOGGING
  ###########################################################
  ##client.id=KafkaExampleProducer

  ###########################################################
  ## ACKNOWLEDGEMENTS EXPECTED FROM BROKER AFTER RECORD HAS BEEN SENT BY PRODUCER TO BE CONSIDERD SUCCESSFUL
  ## SUPPORTED VALUE 
  ## 0- NO ACKNOWLEDGEMENT REQUIRED
  ## 1 - EXPEECTS ACK FROM LEAD BROKER 
  ## ALL - EXPECTS FROM EAD BROKER & FOLLOWER (REPLICATES)
  ###########################################################
  ##ack=all

  ###########################################################
  ## DETERMINES TIME KafkaProducer.send() AND KafkaProducer.partitionsFor() 
  ## WILL BLOCK WHEN SENDING A PRODOCER RECORD
  ###########################################################
  ##max.block.ms=60000

  ###########################################################
  ## PRODUCER RETRIES SENDING RECORDS IF FAILS
  ## 0 - DISABLE RETRY
  ## 1 - ENABLE RETRY
  ###########################################################
  ##retries=0

  ###########################################################
  ## PRODUCER ATTEMPTS TO BATCH MULTIPLE RECORDS HEADING TO SAME PARTITION
  ###########################################################
  ##batch.size=16384

  ###########################################################
  ## TOTAL BYTES OF MEMORY PRODUCER CAN USE TO BUFFER RECORDS WAITING TO BE SENT TO SERVER
  ###########################################################
  ##buffer.memory=33554432

  ###########################################################
  ##KEY & VALUE STRING SERIALIZER
  ###########################################################
  ##key.serializer=org.apache.kafka.common.serialization.StringSerializer
  ##value.serializer=org.apache.kafka.common.serialization.StringSerializer   
  ##==============================================================================


kafka-client-javasys-props: |
  java.security.auth.login.config=/opt/IBM/tivoli/netcool/omnibus/java/conf/kafka_client_jaas.conf


kafka-client-jaas: |
  KafkaClient {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    serviceName="kafka"
    username=""
    password="";
  };

{{- end }}
