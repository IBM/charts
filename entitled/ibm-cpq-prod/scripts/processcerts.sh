#!/bin/bash
# Licensed Materials - Property of IBM
# IBM Sterling Configure Price Quote Software (5725-D11)
# (C) Copyright IBM Corp. 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# This will replace '$(env variable)' with 'env variable value' from the supplied source file as first argument.
# if the target file is not supplied as second argument, then the first argument file is overwritten with changes.

keytool -genkeypair  -dname "cn=localhost, ou=ISL,o=IBM,l=PQ,S=Maharastra c=IN" -alias auto-gen -keyalg RSA -keysize 2048 -validity 3650 \
--keystore /home/default/trustStore.p12 -storepass "${tlskeystorepassword}" -keypass "${tlskeystorepassword}" -storetype pkcs12

if [ -f "/config/security/self/tls.crt" ]
then
    echo "Self tls.crt found. creating truststore .."
    keytool -importcert -noprompt -file /config/security/self/tls.crt -alias self-cert -keystore /home/default/trustStore.p12 -storepass "${tlskeystorepassword}" -storetype pkcs12
else
    echo "No self tls.crt found."
fi    

if [ -f "/config/security/tls.crt" ]
then
    echo "tls.crt found."
    keytool -importcert -noprompt -file /config/security/tls.crt -alias app-cert -keystore /home/default/trustStore.p12 -storepass "${tlskeystorepassword}" -storetype pkcs12
else
    echo "No tls.crt found."
fi    

if [ -f "/config/security/importedcert/cert" ]
then 
    echo "found certs to be imported."
    cnt=1
    filename="/home/default/cert$cnt.crt"
    certend=0
    echo "first filename = $filename"

    while IFS= read -r line
    do

      if [ $certend -eq 1 ]
      then
        ((cnt=cnt+1))
        certend=0
        filename="/home/default/cert$cnt.crt"
      fi

      if [ ${#line} -gt 1 ]
      then
        echo $line >> $filename
      fi

      if [[ "$line" = *"END CERTIFICATE"* ]]
      then
        certend=1
      fi

    done < "/config/security/importedcert/cert"

    echo "files created."
    
    cnt=1
    for f in /home/default/*.crt
    do
      echo "importing cert file $f .."
      keytool -import -noprompt -file $f -alias cert$cnt -keystore /home/default/trustStore.p12 -storepass "${tlskeystorepassword}" -storetype pkcs12
      ((cnt=cnt+1))
    done

else
    echo "No importcert found."
fi
