{{- define "ibm-datapower-icp4i.healthCheckConfig" }}

health-check.cfg: |
    top; configure terminal;

    action "HealthCheck_rule_0_gatewayscript_0"
      reset
      type gatewayscript
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      gatewayscript-location "local:///health/health.js"
      output "OUTPUT"
      named-inouts default
      ssl-client-type proxy
      no transactional
      soap-validation body
      sql-source-type static
      strip-signature
      no asynchronous
      results-mode first-available
      retry-count 0
      retry-interval 1000
      no multiple-outputs
      iterator-type XPATH
      timeout 0
      http-method GET
      http-method-limited POST
      http-method-limited2 POST
    exit

    action "HealthCheck_rule_0_setvar_0"
      reset
      type setvar
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      named-inouts default
      variable "var://service/mpgw/skip-backside"
      value "1"
      ssl-client-type proxy
      no transactional
      soap-validation body
      sql-source-type static
      strip-signature
      no asynchronous
      results-mode first-available
      retry-count 0
      retry-interval 1000
      no multiple-outputs
      iterator-type XPATH
      timeout 0
      http-method GET
      http-method-limited POST
      http-method-limited2 POST
    exit

    rule "HealthCheck_rule_0"
      reset
        action "HealthCheck_rule_0_setvar_0"
        action "HealthCheck_rule_0_gatewayscript_0"
      type request-rule
      input-filter none
      output-filter none
      no non-xml-processing
      no unprocessed
    exit

    matching "Health"
      urlmatch "/health"
      no match-with-pcre
      no combine-with-or
    exit

    stylepolicy "HealthCheck"
      reset
      filter "store:///filter-reject-all.xsl"
      xsldefault "store:///identity.xsl"
      xquerydefault "store:///reject-all-json.xq"
      match "Health" "HealthCheck_rule_0"
    exit

    %if% available "source-http"

    source-http "HTTPHealth"
      local-address 0.0.0.0
      port {{ .Values.health.readinessPort }}
      http-client-version HTTP/1.1
      allowed-features "HTTP-1.0+HTTP-1.1+GET"
      persistent-connections
      max-persistent-reuse 0
      no compression
      no websocket-upgrade
      websocket-idle-timeout 0
      max-url-len 16384
      max-total-header-len 128000
      max-header-count 0
      max-header-name-len 0
      max-header-value-len 0
      max-querystring-len 0
      credential-charset protocol
      http2-max-streams 100
      http2-max-frame 16384
      no http2-stream-header
      chunked-encoding
    exit

    %endif%

    %if% available "policy-attachments"

    policy-attachments "HealthCheck"
      enforcement-mode enforce
      policy-references
      sla-enforcement-mode allow-if-no-sla
    exit

    %endif%

    %if% available "mpgw"

    mpgw "HealthCheck"
      no policy-parameters
      summary "Health check endpoint"
      priority normal
      front-protocol HTTPHealth
      xml-manager default
      ssl-client-type proxy
      default-param-namespace "http://www.datapower.com/param/config"
      query-param-namespace "http://www.datapower.com/param/query"
      backend-url "http://httpbin.org/get"
      propagate-uri
      monitor-processing-policy terminate-at-first-throttle
      request-attachments strip
      response-attachments strip
      no request-attachments-flow-control
      no response-attachments-flow-control
      root-part-not-first-action process-in-order
      front-attachment-format dynamic
      back-attachment-format dynamic
      mime-front-headers
      mime-back-headers
      stream-output-to-back buffer-until-verification
      stream-output-to-front buffer-until-verification
      max-message-size 0
      no gateway-parser-limits
      element-depth 512
      attribute-count 128
      max-node-size 33554432
      forbid-external-references
      external-references forbid
      max-prefixes 1024
      max-namespaces 1024
      max-local-names 60000
      attachment-byte-count 2000000000
      attachment-package-byte-count 0
      debugger-type internal
      debug-history 25
      no flowcontrol
      soap-schema-url "store:///schemas/soap-envelope.xsd"
      front-timeout 120
      back-timeout 120
      front-persistent-timeout 180
      back-persistent-timeout 180
      no include-content-type-encoding
      http-server-version HTTP/1.1
      persistent-connections
      no loop-detection
      host-rewriting
      no chunked-uploads
      process-http-errors
      http-client-ip-label "X-Client-IP"
      http-global-tranID-label "X-Global-Transaction-ID"
      inorder-mode ""
      wsa-mode sync2sync
      wsa-require-aaa
      wsa-strip-headers
      wsa-default-replyto "http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous"
      wsa-default-faultto "http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous"
      no wsa-force
      wsa-genstyle sync
      wsa-http-async-response-code 204
      wsa-timeout 120
      no wsrm
      wsrm-sequence-expiration 3600
      wsrm-destination-accept-create-sequence
      wsrm-destination-maximum-sequences 400
      no wsrm-destination-inorder
      wsrm-destination-maximum-inorder-queue-length 10
      no wsrm-destination-accept-offers
      no wsrm-request-force
      no wsrm-response-force
      no wsrm-source-request-create-sequence
      no wsrm-source-response-create-sequence
      no wsrm-source-make-offer
      no wsrm-source-sequence-ssl
      wsrm-source-maximum-sequences 400
      wsrm-source-retransmission-interval 10
      wsrm-source-exponential-backoff
      wsrm-source-retransmit-count 4
      wsrm-source-maximum-queue-length 30
      wsrm-source-request-ack-count 1
      wsrm-source-inactivity-close-interval 360
      force-policy-exec
      rewrite-errors
      delay-errors
      delay-errors-duration 1000
      request-type json
      response-type json
      follow-redirects
      no rewrite-location-header
      stylepolicy HealthCheck
      type static-backend
      no compression
      no allow-cache-control
      policy-attachments HealthCheck
      no wsmagent-monitor
      wsmagent-monitor-capture-mode all-messages
      no proxy-http-response
      transaction-timeout 0
    exit

    %endif%
{{- end }}
