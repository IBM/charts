{{/* DataPower Configuration for the restProxy Pattern */}}
{{- define "ibm-datapower-icp4i.restProxyConfig" }}
restProxy.cfg: |
    top; configure terminal;
    
    # configuration generated Thu Apr 19 10:19:12 2018; firmware version 298100
    
    %if% available "domain-settings"
    
    domain-settings
      admin-state enabled
      password-treatment masked
    exit
    
    %endif%
    logging event default-log "all" "error"
    logging event default-log "mgmt" "notice"
    
    user-agent "default"
      summary "Default User Agent"
      max-redirects 8
      timeout 300
    exit
    
    %if% available "urlmap"
    
    urlmap "default-attempt-stream-all"
      match "*"
    exit
    
    %endif%
    
    %if% available "compile-options"
    
    compile-options "default-attempt-stream"
      xslt-version XSLT10
      no strict 
      try-stream default-attempt-stream-all
      stack-size 524288
      wsi-validate ignore
      wsdl-validate-body strict
      wsdl-validate-headers lax
      wsdl-validate-faults strict
      no wsdl-wrapped-faults 
      no wsdl-strict-soap-version 
      no xacml-debug 
    exit
    
    %endif%
    
    action "restProxy_rest-gw-policy_rule_error_fetch_0"
      reset
      type fetch
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      output "PIPE"
      named-inouts default
      destination "store:///ErrorPage.htm"
      ssl-client-type proxy
      output-type default
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
    
    action "restProxy_rest-gw-policy_rule_error_results_output_0"
      reset
      type results
      input "PIPE"
      parse-settings-result-type none
      transform-language none
      named-inouts default
      ssl-client-type proxy
      output-type default
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
    
    action "restProxy_rest-gw-policy_rule_client_convert-http_0"
      reset
      type convert-http
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      tx-mode default
      output dp_var
      named-inouts default
      ssl-client-type proxy
      output-type default
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
    
    action "restProxy_rest-gw-policy_rule_client_results_output_0"
      reset
      type results
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      named-inouts default
      ssl-client-type proxy
      output-type default
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

    action "restProxy_rest-gw-policy_rule_server_results_output_0"
      reset
      type results
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      named-inouts default
      ssl-client-type proxy
      output-type default
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
    
    rule "restProxy_rest-gw-policy_rule_error"
      reset
        action "restProxy_rest-gw-policy_rule_error_fetch_0"
        action "restProxy_rest-gw-policy_rule_error_results_output_0"
      type error-rule
      input-filter none
      output-filter none
      no non-xml-processing 
      no unprocessed 
    exit
    
    rule "restProxy_rest-gw-policy_rule_client"
      reset
        action "restProxy_rest-gw-policy_rule_client_convert-http_0"
        action "restProxy_rest-gw-policy_rule_client_results_output_0"
      type request-rule
      input-filter none
      output-filter none
      no non-xml-processing 
      no unprocessed 
    exit
    
    rule "restProxy_rest-gw-policy_rule_server"
      reset
        action "restProxy_rest-gw-policy_rule_server_results_output_0"
      type response-rule
      input-filter none
      output-filter none
      no non-xml-processing 
      no unprocessed 
    exit
    
    matching "restProxy_ALL"
      urlmatch "*"
      no match-with-pcre 
      no combine-with-or 
    exit
    
    
    stylepolicy "default"
      reset
      summary "Default Processing Policy"
      filter "store:///filter-reject-all.xsl"
      xsldefault "store:///identity.xsl"
      xquerydefault "store:///reject-all-json.xq"
    exit
    
    stylepolicy "restProxy_rest-gw-policy"
      reset
      filter "store:///filter-reject-all.xsl"
      xsldefault "store:///identity.xsl"
      xquerydefault "store:///reject-all-json.xq"
      match "restProxy_ALL" "restProxy_rest-gw-policy_rule_client"
      match "restProxy_ALL" "restProxy_rest-gw-policy_rule_server"
      match "restProxy_ALL" "restProxy_rest-gw-policy_rule_error"
    exit
    
    %if% available "metadata"
    
    metadata "ftp-usercert-metadata"
      meta-item "variable" "dn" "var://context/INPUT/ftp/tls/client-subject-dn"
      meta-item "variable" "issuer" "var://context/INPUT/ftp/tls/client-issuer-dn"
      meta-item "variable" "serial" "var://context/INPUT/ftp/tls/client-serial-number"
    exit
    
    metadata "ftp-username-metadata"
      meta-item "variable" "dn" "var://context/INPUT/ftp/tls/client-subject-dn"
      meta-item "variable" "issuer" "var://context/INPUT/ftp/tls/client-issuer-dn"
      meta-item "variable" "password" "var://context/INPUT/ftp/password"
      meta-item "variable" "serial" "var://context/INPUT/ftp/tls/client-serial-number"
      meta-item "variable" "username" "var://context/INPUT/ftp/username"
    exit
    
    metadata "oauth-scope-metadata"
      meta-item "variable" "scope" "var://context/INPUT/oauth/verified-scope"
    exit
    
    metadata "ssh-password-metadata"
      meta-item "variable" "password" "var://context/INPUT/ssh/password"
      meta-item "variable" "publickey" "var://context/INPUT/ssh/publickey"
      meta-item "variable" "username" "var://context/INPUT/ssh/username"
    exit
    
    %endif%
    
    xmlmgr "default"
    xsl cache size "default" "256"
    xsl checksummed cache default
    no tx-warn "default"
    memoization "default"
    
    xml parser limits "default"
     bytes-scanned 4194304
     element-depth 512
     attribute-count 128
     max-node-size 33554432
     forbid-external-references 
     external-references forbid
     max-prefixes 1024
     max-namespaces 1024
     max-local-names 60000
    exit
    
    documentcache "default"
     no policy
     maxdocs "5000"
     size "0"
     max-writes "32768"
    exit
    no xml validate "default" *
    
    xml-manager "default"
      summary "Default XML-Manager"
      user-agent "default"
    exit
    
    xmlmgr "default-attempt-stream"
    xslconfig "default-attempt-stream" "default-attempt-stream"
    xsl cache size "default-attempt-stream" "256"
    xsl checksummed cache default-attempt-stream
    no tx-warn "default-attempt-stream"
    memoization "default-attempt-stream"
    
    xml parser limits "default-attempt-stream"
     bytes-scanned 268435456
     element-depth 512
     attribute-count 128
     max-node-size 268435456
     forbid-external-references 
     external-references forbid
     max-prefixes 1024
     max-namespaces 1024
     max-local-names 60000
    exit
    
    documentcache "default-attempt-stream"
     no policy
     maxdocs "5000"
     size "0"
     max-writes "32768"
    exit
    no xml validate "default-attempt-stream" *
    
    xml-manager "default-attempt-stream"
      summary "Default Streaming XML-Manager"
      user-agent "default"
    exit
    
    xmlmgr "default-wsrr"
    xsl cache size "default-wsrr" "256"
    xsl checksummed cache default-wsrr
    no tx-warn "default-wsrr"
    memoization "default-wsrr"
    
    xml parser limits "default-wsrr"
     bytes-scanned 4194304
     element-depth 512
     attribute-count 128
     max-node-size 33554432
     forbid-external-references 
     external-references forbid
     max-prefixes 1024
     max-namespaces 1024
     max-local-names 60000
    exit
    
    documentcache "default-wsrr"
     no policy
     maxdocs "5000"
     size "0"
     max-writes "32768"
    exit
    no xml validate "default-wsrr" *
    
    xml-manager "default-wsrr"
      summary "WSRR XML-Manager"
      user-agent "default"
    exit

    %if% available "wsm-stylepolicy"
    
    wsm-stylepolicy "default"
      summary "Default Processing Policy"
      filter "store:///filter-reject-all.xsl"
      xsldefault "store:///identity.xsl"
    exit
    
    %endif%
    
    no statistics
    
    %if% available "apic-gw-service"
    
    apic-gw-service
      admin-state disabled
      local-address 0.0.0.0
      local-port 3000
      api-gw-address 0.0.0.0
      api-gw-port 9443
      no database-mode 
    exit
    
    %endif%
    
    %if% available "smtp-server-connection"
    
    smtp-server-connection "default"
      summary "Default SMTP Server Connection"
      server-host smtp
      server-port 25
      auth plain
      ssl-client-type proxy
    exit
    
    %endif%
{{ if .Values.crypto.frontsideSecret }}
    crypto
      certificate "restProxy_cert" "cert:///cert.pem"
    exit

    crypto
      key "restProxy_key" "cert:///key.pem"
    exit

    crypto
      idcred "restProxy_ident_cred" "restProxy_key" "restProxy_cert"
    exit

    crypto
      
    %if% available "ssl-server"

    ssl-server "restProxy_server_profile"
      protocols "TLSv1d1+TLSv1d2" 
    ciphers ECDHE_RSA_WITH_AES_256_GCM_SHA384
     ciphers ECDHE_RSA_WITH_AES_256_CBC_SHA384
     ciphers ECDHE_RSA_WITH_AES_256_CBC_SHA
     ciphers DHE_DSS_WITH_AES_256_GCM_SHA384
     ciphers DHE_RSA_WITH_AES_256_GCM_SHA384
     ciphers DHE_RSA_WITH_AES_256_CBC_SHA256
     ciphers DHE_DSS_WITH_AES_256_CBC_SHA256
     ciphers DHE_RSA_WITH_AES_256_CBC_SHA
     ciphers DHE_DSS_WITH_AES_256_CBC_SHA
     ciphers RSA_WITH_AES_256_GCM_SHA384
     ciphers RSA_WITH_AES_256_CBC_SHA256
     ciphers RSA_WITH_AES_256_CBC_SHA
     ciphers ECDHE_RSA_WITH_AES_128_GCM_SHA256
     ciphers ECDHE_RSA_WITH_AES_128_CBC_SHA256
     ciphers ECDHE_RSA_WITH_AES_128_CBC_SHA
     ciphers DHE_DSS_WITH_AES_128_GCM_SHA256
     ciphers DHE_RSA_WITH_AES_128_GCM_SHA256
     ciphers DHE_RSA_WITH_AES_128_CBC_SHA256
     ciphers DHE_DSS_WITH_AES_128_CBC_SHA256
     ciphers DHE_RSA_WITH_AES_128_CBC_SHA
     ciphers DHE_DSS_WITH_AES_128_CBC_SHA
     ciphers RSA_WITH_AES_128_GCM_SHA256
     ciphers RSA_WITH_AES_128_CBC_SHA256
     ciphers RSA_WITH_AES_128_CBC_SHA 
      idcred restProxy_ident_cred
      no request-client-auth 
      require-client-auth 
      validate-client-cert 
      send-client-auth-ca-list 
      caching 
      cache-timeout 300
      cache-size 20
      ssl-options "" 
      max-duration 60
      max-renegotiation-allowed 0
      no prohibit-resume-on-reneg 
      no compression 
      no allow-legacy-renegotiation 
      prefer-server-ciphers 
    exit

    %endif%

    exit

    %if% available "source-https"

    source-https "restProxy_rest-gw-fsh"
      local-address 0.0.0.0
      port {{ .Values.restProxy.containerPort }} 
      http-client-version HTTP/1.1
      allowed-features "HTTP-1.0+HTTP-1.1+POST+GET+PUT+HEAD+DELETE+QueryString+FragmentIdentifiers" 
      persistent-connections 
      max-persistent-reuse 0
      no compression 
      websocket-upgrade 
      websocket-idle-timeout 0
      max-url-len 8190
      max-total-header-len 65536
      max-header-count 100
      max-header-name-len 256
      max-header-value-len 8190
      max-querystring-len 8190
      credential-charset protocol
      ssl-config-type server
      ssl-server restProxy_server_profile
      http2-max-streams 100
      http2-max-frame 16384
      no http2-stream-header 
    exit

    %endif%
{{ else }}    
    %if% available "source-http"
    
    source-http "restProxy_rest-gw-fsh"
      local-address 0.0.0.0
      port {{ .Values.restProxy.containerPort }}
      http-client-version HTTP/1.1
      allowed-features "HTTP-1.0+HTTP-1.1+POST+GET+PUT+DELETE+QueryString+FragmentIdentifiers" 
      persistent-connections 
      max-persistent-reuse 0
      no compression 
      websocket-upgrade 
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
    exit
    
    %endif%
{{- end }}
    
    crypto
      valcred "restProxy_valcred"
        cert-validation-mode "legacy"
        use-crl "off"
        require-crl "off"
        crldp "ignore"
        initial-policy-set "2.5.29.32.0"
        explicit-policy "off"
        check-dates "off"
      exit
    exit

    crypto
      
    %if% available "ssl-client"

    ssl-client "restProxy_ssl_client"
      protocols "TLSv1d1+TLSv1d2" 
      ciphers ECDHE_RSA_WITH_AES_256_GCM_SHA384
     ciphers ECDHE_RSA_WITH_AES_256_CBC_SHA384
     ciphers ECDHE_RSA_WITH_AES_256_CBC_SHA
     ciphers DHE_DSS_WITH_AES_256_GCM_SHA384
     ciphers DHE_RSA_WITH_AES_256_GCM_SHA384
     ciphers DHE_RSA_WITH_AES_256_CBC_SHA256
     ciphers DHE_DSS_WITH_AES_256_CBC_SHA256
     ciphers DHE_RSA_WITH_AES_256_CBC_SHA
     ciphers DHE_DSS_WITH_AES_256_CBC_SHA
     ciphers RSA_WITH_AES_256_GCM_SHA384
     ciphers RSA_WITH_AES_256_CBC_SHA256
     ciphers RSA_WITH_AES_256_CBC_SHA
     ciphers ECDHE_RSA_WITH_AES_128_GCM_SHA256
     ciphers ECDHE_RSA_WITH_AES_128_CBC_SHA256
     ciphers ECDHE_RSA_WITH_AES_128_CBC_SHA
     ciphers DHE_DSS_WITH_AES_128_GCM_SHA256
     ciphers DHE_RSA_WITH_AES_128_GCM_SHA256
     ciphers DHE_RSA_WITH_AES_128_CBC_SHA256
     ciphers DHE_DSS_WITH_AES_128_CBC_SHA256
     ciphers DHE_RSA_WITH_AES_128_CBC_SHA
     ciphers DHE_DSS_WITH_AES_128_CBC_SHA
     ciphers RSA_WITH_AES_128_GCM_SHA256
     ciphers RSA_WITH_AES_128_CBC_SHA256
     ciphers RSA_WITH_AES_128_CBC_SHA
      no validate-server-cert 
      valcred restProxy_valcred
      caching 
      cache-timeout 300
      cache-size 100
      ssl-client-features "use-sni" 
      use-custom-sni-hostname no
    exit

    %endif%

    exit
    
    crypto
      
    %if% available "sshdomainclientprofile"
    
    sshdomainclientprofile
      no ciphers
      admin-state enabled
      ciphers CHACHA20-POLY1305_AT_OPENSSH.COM
      ciphers AES128-CTR
      ciphers AES192-CTR
      ciphers AES256-CTR
      ciphers AES128-GCM_AT_OPENSSH.COM
      ciphers AES256-GCM_AT_OPENSSH.COM
      ciphers ARCFOUR256
      ciphers ARCFOUR128
      ciphers AES128-CBC
      ciphers 3DES-CBC
      ciphers BLOWFISH-CBC
      ciphers CAST128-CBC
      ciphers AES192-CBC
      ciphers AES256-CBC
      ciphers ARCFOUR
      ciphers RIJNDAEL-CBC_AT_LYSATOR.LIU.SE
      enable-legacy-kex no
    exit
    
    %endif%
    
    exit
    
    crypto
      
    %if% available "sshserverprofile"
    
    sshserverprofile
      no ciphers
      admin-state enabled
      ciphers CHACHA20-POLY1305_AT_OPENSSH.COM
      ciphers AES128-CTR
      ciphers AES192-CTR
      ciphers AES256-CTR
      ciphers AES128-GCM_AT_OPENSSH.COM
      ciphers AES256-GCM_AT_OPENSSH.COM
      ciphers ARCFOUR256
      ciphers ARCFOUR128
      ciphers AES128-CBC
      ciphers 3DES-CBC
      ciphers BLOWFISH-CBC
      ciphers CAST128-CBC
      ciphers AES192-CBC
      ciphers AES256-CBC
      ciphers ARCFOUR
      ciphers RIJNDAEL-CBC_AT_LYSATOR.LIU.SE
      enable-legacy-kex no
      send-preauth-msg no
    exit
    
    %endif%
    
    exit
    
    %if% available "policy-attachments"
    
    policy-attachments "restProxy_rest-gw"
      enforcement-mode enforce
      policy-references 
      sla-enforcement-mode allow-if-no-sla
    exit
    
    %endif%
    
    %if% available "mpgw"
    
    mpgw "restProxy"
      no policy-parameters
      priority normal
      front-protocol restProxy_rest-gw-fsh
      xml-manager default
      ssl-client-type client
      ssl-client restProxy_ssl_client
      default-param-namespace "http://www.datapower.com/param/config"
      query-param-namespace "http://www.datapower.com/param/query"
      backend-url "{{ .Values.restProxy.backendURL }}"
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
      max-prefixes 0
      max-namespaces 0
      max-local-names 0
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
      request-type preprocessed
      response-type preprocessed
      no follow-redirects 
      rewrite-location-header 
      stylepolicy restProxy_rest-gw-policy
      type static-backend
      no compression 
      no allow-cache-control 
      policy-attachments restProxy_rest-gw
      no wsmagent-monitor 
      wsmagent-monitor-capture-mode all-messages
      proxy-http-response 
      transaction-timeout 0
    exit
    
    %endif%
    
    %if% available "domain-availability"
    
    domain-availability
      admin-state disabled
    exit
    
    %endif%
    
    %if% available "nfs-dynamic-mounts"
    
    nfs-dynamic-mounts
      admin-state disabled
      version 3
      transport tcp
      mount-type hard
      no read-only 
      rsize 4096
      wsize 4096
      timeo 7
      retrans 3
      inactivity-timeout 900
      mount-timeout 30
    exit
    
    %endif%
    
    %if% available "slm-action"
    
    slm-action "notify"
      type log-only
      log-priority warn
    exit
    
    slm-action "shape"
      type shape
      log-priority debug
    exit
    
    slm-action "throttle"
      type reject
      log-priority debug
    exit
    
    %endif%
    
    %if% available "slm-policy"
    
    slm-policy "restProxy_rest-gw-slm"
      eval-method execute-all-statements
      no api-mgmt 
    exit
    
    %endif%
    
    %if% available "wsm-agent"
    
    wsm-agent
      admin-state disabled
      max-records 3000
      max-memory 64000
      capture-mode faults
      buffer-mode discard
      no mediation-enforcement-metrics 
      max-payload-size 0
      push-interval 100
      push-priority normal
    exit
    
    %endif%
{{- end }}
