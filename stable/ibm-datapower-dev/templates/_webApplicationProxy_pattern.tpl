{{/* DataPower Configuration for the webApplicationProxy Pattern */}}
{{- define "webApplicationProxyConfig" }}
auto-startup.cfg: |
    top; configure terminal;

    # configuration generated Wed Sep 20 11:00:05 2017; firmware version 291101

    %if% available "domain-settings"

    domain-settings
      admin-state enabled
      password-treatment masked
    exit

    %endif%

    %if% available "radius"

    radius
      admin-state disabled
      timeout 1000
      retries 3
    exit

    %endif%

    %if% available "timezone"

    timezone "EST5EDT"

    %endif%

    %if% available "throttle"

    throttle
      admin-state disabled
      memory-throttle 20
      memory-terminate 5
      temp-fs-throttle 0
      temp-fs-terminate 0
      qcode-warn 10
      timeout 30
      no status-log 
      status-loglevel debug
      sensors-log 
      backlog-size 0
      backlog-timeout 30
    exit

    %endif%

    %if% available "snmp"

    snmp
      admin-state disabled
      version 2c
      ip-address 0.0.0.0
      port 161
      security-level authPriv
      access-level read-only
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

    sslproxy "system-wsgw-management-loopback" "forward" "system-default" client-cache "on" client-sess-timeout "300" client-cache-size "100"

    crypto
      
    %if% available "cert-monitor"

    cert-monitor
      admin-state enabled
      poll 1
      reminder 30
      log-level warn
      no disable-expired-certs 
    exit

    %endif%

    exit

    crypto
      no crl

    exit

    %if% available "raid-volume"

    raid-volume "raid0"
      admin-state disabled
      no read-only 
    exit

    %endif%

    %if% available "language"

    language "de"
      admin-state disabled
    exit

    language "en"
      admin-state enabled
    exit

    language "es"
      admin-state disabled
    exit

    language "fr"
      admin-state disabled
    exit

    language "it"
      admin-state disabled
    exit

    language "ja"
      admin-state disabled
    exit

    language "ko"
      admin-state disabled
    exit

    language "pt_BR"
      admin-state disabled
    exit

    language "ru"
      admin-state disabled
    exit

    language "zh_CN"
      admin-state disabled
    exit

    language "zh_TW"
      admin-state disabled
    exit

    %endif%

    %if% available "system"

    system
      admin-state enabled
      entitlement "0000001"
      audit-reserve 40
      no system-log-fixed-format 
    exit

    %endif%
    logging event default-log "all" "error"
    logging event default-log "mgmt" "notice"
    logging event default-log "system" "notice"

    %if% available "rbm"

    rbm
      admin-state enabled
      au-method local
      no au-ldap-search 
      ldap-prefix "cn="
      no au-force-dn-ldap-order 
      au-cache-mode absolute
      au-cache-ttl 600
      au-ldap-readtimeout 60
      mc-method local
      no mc-ldap-search 
      mc-ldap-readtimeout 60
      fallback-login disabled
      no apply-cli 
      no restrict-admin 
      pwd-minimum-length 6
      no pwd-mixed-case 
      no pwd-digit 
      no pwd-nonalphanumeric 
      no pwd-username 
      no pwd-aging 
      pwd-max-age 30
      no pwd-history 
      pwd-max-history 5
      cli-timeout 0
      max-login-failure 0
      lockout-duration 1
      no mc-force-dn-ldap-order 
      password-hash-algorithm md5crypt
      ssl-client-type proxy
      mc-ssl-client-type proxy
    exit

    %endif%

    acl "rest-mgmt"
    exit

    acl "ssh"
    exit

    acl "web-b2b-viewer"
    exit

    acl "web-mgmt"
    exit

    acl "xml-mgmt"
    exit

    no ssh

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

    action "template_rest-gw-policy_rule_delete_convert-http_0"
      reset
      type convert-http
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      tx-mode default
      output "PIPE"
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

    action "template_rest-gw-policy_rule_delete_results_output_0"
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

    action "template_rest-gw-policy_rule_delete_slm_0"
      reset
      type slm
      input "PIPE"
      parse-settings-result-type none
      transform-language none
      tx-mode default
      output "NULL"
      named-inouts default
      ssl-client-type proxy
      output-type default
      no transactional 
      slm "template_rest-gw-slm"
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

    action "template_rest-gw-policy_rule_error_fetch_0"
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

    action "template_rest-gw-policy_rule_error_results_output_0"
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

    action "template_rest-gw-policy_rule_get_convert-http_0"
      reset
      type convert-http
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      tx-mode default
      output "PIPE"
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

    action "template_rest-gw-policy_rule_get_results_output_0"
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

    action "template_rest-gw-policy_rule_get_slm_0"
      reset
      type slm
      input "PIPE"
      parse-settings-result-type none
      transform-language none
      tx-mode default
      output "NULL"
      named-inouts default
      ssl-client-type proxy
      output-type default
      no transactional 
      slm "template_rest-gw-slm"
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

    action "template_rest-gw-policy_rule_post_convert-http_0"
      reset
      type convert-http
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      tx-mode default
      output "dpvar_4"
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

    action "template_rest-gw-policy_rule_post_gatewayscript_4"
      reset
      type gatewayscript
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      gatewayscript-location "store:///identity.js"
      output "PIPE"
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

    action "template_rest-gw-policy_rule_post_results_output_0"
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

    action "template_rest-gw-policy_rule_post_slm_0"
      reset
      type slm
      input "dpvar_4"
      parse-settings-result-type none
      transform-language none
      tx-mode default
      output "NULL"
      named-inouts default
      ssl-client-type proxy
      output-type default
      no transactional 
      slm "template_rest-gw-slm"
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

    action "template_rest-gw-policy_rule_put_convert-http_0"
      reset
      type convert-http
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      tx-mode default
      output "dpvar_3"
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

    action "template_rest-gw-policy_rule_put_gatewayscript_3"
      reset
      type gatewayscript
      input "INPUT"
      parse-settings-result-type none
      transform-language none
      gatewayscript-location "store:///identity.js"
      output "PIPE"
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

    action "template_rest-gw-policy_rule_put_results_output_0"
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

    action "template_rest-gw-policy_rule_put_slm_0"
      reset
      type slm
      input "dpvar_3"
      parse-settings-result-type none
      transform-language none
      tx-mode default
      output "NULL"
      named-inouts default
      ssl-client-type proxy
      output-type default
      no transactional 
      slm "template_rest-gw-slm"
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

    action "template_rest-gw-policy_rule_server_results_output_0"
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

    rule "template_rest-gw-policy_rule_delete"
      reset
      type request-rule
      input-filter none
      output-filter none
      no non-xml-processing 
      no unprocessed 
        action "template_rest-gw-policy_rule_delete_convert-http_0"
        action "template_rest-gw-policy_rule_delete_slm_0"
        action "template_rest-gw-policy_rule_delete_results_output_0"
    exit

    rule "template_rest-gw-policy_rule_error"
      reset
      type error-rule
      input-filter none
      output-filter none
      no non-xml-processing 
      no unprocessed 
        action "template_rest-gw-policy_rule_error_fetch_0"
        action "template_rest-gw-policy_rule_error_results_output_0"
    exit

    rule "template_rest-gw-policy_rule_get"
      reset
      type request-rule
      input-filter none
      output-filter none
      no non-xml-processing 
      no unprocessed 
        action "template_rest-gw-policy_rule_get_convert-http_0"
        action "template_rest-gw-policy_rule_get_slm_0"
        action "template_rest-gw-policy_rule_get_results_output_0"
    exit

    rule "template_rest-gw-policy_rule_post"
      reset
      type request-rule
      input-filter none
      output-filter none
      no non-xml-processing 
      no unprocessed 
        action "template_rest-gw-policy_rule_post_convert-http_0"
        action "template_rest-gw-policy_rule_post_slm_0"
        action "template_rest-gw-policy_rule_post_gatewayscript_4"
        action "template_rest-gw-policy_rule_post_results_output_0"
    exit

    rule "template_rest-gw-policy_rule_put"
      reset
      type request-rule
      input-filter none
      output-filter none
      no non-xml-processing 
      no unprocessed 
        action "template_rest-gw-policy_rule_put_convert-http_0"
        action "template_rest-gw-policy_rule_put_slm_0"
        action "template_rest-gw-policy_rule_put_gatewayscript_3"
        action "template_rest-gw-policy_rule_put_results_output_0"
    exit

    rule "template_rest-gw-policy_rule_server"
      reset
      type response-rule
      input-filter none
      output-filter none
      no non-xml-processing 
      no unprocessed 
        action "template_rest-gw-policy_rule_server_results_output_0"
    exit

    matching "template_ALL"
      urlmatch "*"
      no match-with-pcre 
      no combine-with-or 
    exit

    matching "template_http-delete"
      methodmatch "DELETE"
      no match-with-pcre 
      no combine-with-or 
    exit

    matching "template_http-get"
      methodmatch "GET"
      no match-with-pcre 
      no combine-with-or 
    exit

    matching "template_http-post"
      methodmatch "POST"
      no match-with-pcre 
      no combine-with-or 
    exit

    matching "template_http-put"
      methodmatch "PUT"
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

    %if% available "aaapolicy"

    aaapolicy "iop-mgmt-aaa"
     extract-identity  "http-basic-auth+client-ssl" "" "" "" "" "login" "off" "" "off" "" "xmlfile" "" "" "" "" "" "proxy" "" "" "" ""
     authenticate xmlfile "store:///iop-mgmt-aaa.xml" "" "" "" "absolute" "3" "" "" "" "" "" "on" "" "" "1.1" "cn=" "" "" "" "" "" "" "" "" "" "" "" "userPassword" "LTPA2" "" "" "" "" "" "off" "" "1.2" "off" "" "off" "32" "off" "32" "off" "off" "" "" "" "" "0" "off" "60" "proxy" "" "" "" "webagent" "" "" "" "default"
     map-credentials xmlfile "store:///iop-mgmt-aaa.xml" "" ""
     extract-resource  "request-uri+request-opname" "" ""
     map-resource xmlfile "store:///iop-mgmt-aaa.xml" "" "WebSEAL" "" ""
     authorize xmlfile "store:///iop-mgmt-aaa.xml" "" "" "" "" "" "any" "" "" "absolute" "3" "" "" "" "1.1" "" "" "" "member" "" "" "subtree" "(objectClass=*)" "2.0" "deny-biased" "on" "" "" "custom" "" "" "" "off" "" "T" "" "off" "" "r" "" "0" "tfim" "" "off" "on" "off" "off" "60" "proxy" "" "" "webagent" "" "" "" "default"
     post-process  "off" "" "off" "XS" "" "off" "" "" "" "off" "on" "0" "off" "2.0" "off" "" "" "off" "Digest" "0" "0" "on" "off" "LTPA2" "600" "" "" "" "off" "http://docs.oasis-open.org/wss/oasis-wss-kerberos-token-profile-1.1#GSS_Kerberosv5_AP_REQ" "off" "" "off" "" "off" "" "off" "1000" "off" "all" "CallTFIM" "hmac-sha1" "sha1" "off" "random" "" "0" "off" "off" "off" "off" "" "off" "assertion" "" "wssec-replace" "authentication+attribute" "bearer" "on" "" "" "" "off" "off" "off" "" "0" "AllHTTP" "" "on" "off" "iv-creds" "0" "off" "" "off" "mc-output" "" "" "" "" "as-is-string" "" "" "proxy" "" "" "off" ""
      log-allowed 
      log-allowed-level info
      log-rejected 
      log-rejected-level warn
      no ping-identity-compatibility 
      dos-valve 3
      ldap-version v2
      enforce-actor-role 
      dyn-config none
    exit

    %endif%

    %if% available "wsm-stylepolicy"

    wsm-stylepolicy "default"
      summary "Default Processing Policy"
      filter "store:///filter-reject-all.xsl"
      xsldefault "store:///identity.xsl"
    exit

    %endif%

    %if% available "audit-log-settings"

    audit-log-settings
      admin-state enabled
      size 1000
      rotate 3
      audit-level standard
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

    %if% available "b2b-persistence"

    b2b-persistence
      admin-state disabled
      raid-volume raid0
      storage-size 1024
      no ha-enabled 
      ha-other-hosts "" "1320"
      ha-local-ip 0.0.0.0
      ha-local-port 1320
    exit

    %endif%

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

    policy-attachments "template_rest-gw"
      enforcement-mode enforce
      policy-references 
      sla-enforcement-mode allow-if-no-sla
    exit

    %endif%

    %if% available "domain-availability"

    domain-availability
      admin-state disabled
    exit

    %endif%

    %if% available "gatewayscript-settings"

    gatewayscript-settings
      admin-state enabled
      freeze-prototype 
      max-processing-duration 0
    exit

    %endif%

    %if% available "iop-mgmt"

    iop-mgmt
      admin-state disabled
      http-service 
      http-ip-address 0.0.0.0
      http-port 9990
      no https-service 
      https-ip-address 0.0.0.0
      https-port 9991
      ssl-config-type server
    exit

    %endif%

    %if% available "nfs-client"

    nfs-client
      admin-state disabled
      mount-refresh-time 10
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

    %if% available "odr"

    odr
      admin-state disabled
      odr-server-name "dp_set"
    exit

    %endif%

    %if% available "product-insights"

    product-insights
      admin-state disabled
      host "example.ibm.com"
      credentials "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    exit

    %endif%

    %if% available "quota-enforcement-server"

    quota-enforcement-server
      admin-state enabled
      server-port 16379
      monitor-port 26379
      no enable-peer-group 
      enable-ssl 
      priority 100
      strict-mode 
    exit

    %endif%

    %if% available "secure-mode"

    secure-mode
      admin-state enabled
    exit

    %endif%

    xml-mgmt
      admin-state "disabled"
      local-address "0.0.0.0" "5550"
      no ws-management 
      slm-peering 10
      mode "any+soma+v2004+amp+slm+wsrr-subscription" 
      ssl-config-type server
    exit

    rest-mgmt
      admin-state "disabled"
      local-address "0.0.0.0" "5554"
      ssl-config-type server
    exit

    %if% available "b2b-viewer-mgmt"

    b2b-viewer-mgmt
      admin-state "disabled"
      local-address "0.0.0.0" "9091"
      idle-timeout 600
      ssl-config-type proxy
    exit

    %endif%

    %if% available "save-config overwrite"

    save-config overwrite

    %endif%

    web-mgmt
      admin-state "enabled"
      local-address "0.0.0.0" "9090"
      save-config-overwrite 
      idle-timeout 0
      ssl-config-type server
    exit

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

    slm-policy "template_rest-gw-slm"
      eval-method execute-all-statements
      no api-mgmt 
    exit

    %endif%

    no statistics

    exec config:///auto-user.cfg

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

    domain "webApplicationProxy"
      base-dir local:
      base-dir webApplicationProxy:
      config-file webApplicationProxy.cfg
      visible-domain default
      url-permissions "http+https" 
      file-permissions "CopyFrom+CopyTo+Delete+Display+Exec+Subdir" 
      file-monitoring "Audit+Log" 
      config-mode local
      import-format ZIP
      local-ip-rewrite 
      maxchkpoints 3
    exit

    %endif%

    failure-notification
      admin-state "enabled"
      no upload-report 
      no use-smtp 
      internal-state 
      no ffdc packet-capture 
      no ffdc event-log 
      no ffdc memory-trace 
      no always-on-startup 
      always-on-shutdown 
      protocol ftp
      report-history 5
    exit

    %if% isfile temporary:///backtrace
    save error-report
    %endif%

auto-user.cfg: |

    top; configure terminal;

    # configuration generated Wed Sep 20 11:00:05 2017; firmware version 291101

    %if% available "user"

    user "admin"
      summary "Administrator"
      password-hashed "$1$12345678$kbapHduhihjieYIUP66Xt/"
      access-level privileged
    exit

    %endif%

webApplicationProxy.cfg: |

    top; configure terminal;

    # configuration generated Tue Sep 12 14:46:12 2017; firmware version 289749

    %if% available "domain-settings"

    domain-settings
      admin-state enabled
      password-treatment masked
    exit

    %endif%

    crypto
      certificate "webApplicationProxy_cert" "cert:///cert.pem"
    exit

    crypto
      key "webApplicationProxy_key" "cert:///key.pem"
    exit

    crypto
      idcred "webApplicationProxy_ident_cred" "webApplicationProxy_key" "webApplicationProxy_cert"
    exit

    crypto
      valcred "webApplicationProxy_valcred"
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

    ssl-client "webApplicationProxy_ssl_client"
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
      valcred webApplicationProxy_valcred
      caching 
      cache-timeout 300
      cache-size 100
      ssl-client-features "use-sni" 
      use-custom-sni-hostname no
    exit

    %endif%

    exit

    crypto
      
    %if% available "ssl-server"

    ssl-server "webApplicationProxy_server_profile"
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
      idcred webApplicationProxy_ident_cred
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

    action "webApplicationProxy_Web_HTTPS_rule_0_results_0"
      reset
      type results
      input "INPUT"
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

    rule "webApplicationProxy_Web_HTTPS_rule_0"
      reset
      type rule
      input-filter none
      output-filter none
      non-xml-processing 
      no unprocessed 
        action "webApplicationProxy_Web_HTTPS_rule_0_results_0"
    exit

    matching "webApplicationProxy_Web_HTTPS_match_all"
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

    stylepolicy "webApplicationProxy_Web_HTTPS"
      reset
      filter "store:///filter-reject-all.xsl"
      xsldefault "store:///identity.xsl"
      xquerydefault "store:///reject-all-json.xq"
      match "webApplicationProxy_Web_HTTPS_match_all" "webApplicationProxy_Web_HTTPS_rule_0"
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

    xmlmgr "webApplicationProxy_Web_HTTPS"
    xsl cache size "webApplicationProxy_Web_HTTPS" "256"
    xsl checksummed cache webApplicationProxy_Web_HTTPS
    no tx-warn "webApplicationProxy_Web_HTTPS"
    memoization "webApplicationProxy_Web_HTTPS"

    xml parser limits "webApplicationProxy_Web_HTTPS"
     bytes-scanned 4194304
     element-depth 512
     attribute-count 128
     max-node-size 33554432
     forbid-external-references 
     external-references forbid
     max-prefixes 0
     max-namespaces 0
     max-local-names 0
    exit

    documentcache "webApplicationProxy_Web_HTTPS"
     no policy
     maxdocs "5000"
     size "10485760"
     max-writes "32768"
     policy "http://*" "128" protocol "" on on on on off
     policy "https://*" "128" protocol "" on on on on off
    exit
    no xml validate "webApplicationProxy_Web_HTTPS" *

    xml-manager "webApplicationProxy_Web_HTTPS"
      user-agent "default"
    exit

    %if% available "source-https"

    source-https "webApplicationProxy_Web_HTTPS"
      local-address 0.0.0.0
      port {{ .Values.webApplicationProxy.containerPort }} 
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
      ssl-server webApplicationProxy_server_profile
      http2-max-streams 100
      http2-max-frame 16384
      no http2-stream-header 
    exit

    %endif%

    %if% available "wsm-stylepolicy"

    wsm-stylepolicy "default"
      summary "Default Processing Policy"
      filter "store:///filter-reject-all.xsl"
      xsldefault "store:///identity.xsl"
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
    exit

    %endif%

    exit

    %if% available "mpgw-error-action"

    mpgw-error-action "webApplicationProxy_Web_HTTPS"
      type static
      local-url local:///Patterns-Error-Policy.html
      status-code 500
      header-inject "Content-type" "text/html"
    exit

    %endif%

    %if% available "mpgw-error-handling"

    mpgw-error-handling "webApplicationProxy_Web_HTTPS"
      match "webApplicationProxy_Web_HTTPS_match_all" "webApplicationProxy_Web_HTTPS"
    exit

    %endif%

    %if% available "policy-attachments"

    policy-attachments "webApplicationProxy_Web_HTTPS"
      enforcement-mode enforce
      policy-references 
      sla-enforcement-mode allow-if-no-sla
    exit

    %endif%

    %if% available "mpgw"

    mpgw "webApplicationProxy"
      no policy-parameters
      priority normal
      front-protocol webApplicationProxy_Web_HTTPS
      xml-manager webApplicationProxy_Web_HTTPS
      ssl-client-type client
      ssl-client webApplicationProxy_ssl_client
      default-param-namespace "http://www.datapower.com/param/config"
      query-param-namespace "http://www.datapower.com/param/query"
      backend-url {{ .Values.webApplicationProxy.backendURL }}
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
      chunked-uploads 
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
      stylepolicy webApplicationProxy_Web_HTTPS
      type static-backend
      no compression 
      allow-cache-control 
      policy-attachments webApplicationProxy_Web_HTTPS
      no wsmagent-monitor 
      wsmagent-monitor-capture-mode all-messages
      proxy-http-response 
      error-policy webApplicationProxy_Web_HTTPS
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

    no statistics

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
