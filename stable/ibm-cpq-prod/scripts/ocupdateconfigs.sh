#!/bin/bash

sed -i "s/@httpPort@/${httpPort}/g"  /config/server.xml && \
sed -i "s/@httpsPort@/${httpsPort}/g"  /config/server.xml

sed -i "s/@POD_HOSTNAME@/${HOSTNAME}/g" /omscommonfile/configrepo/omniconfigurator/properties/log4j.properties

cp /home/default/server1.xml /config/server.xml

sed -i "s/@POD_HOSTNAME@/${HOSTNAME}/g" /config/server.xml

#copy the configmapped jvm init file into /config/jvm.options
cp /config/jvm.options.init /config/jvm.options.txt
echo "" >> /config/jvm.options.txt
echo "" >> /config/jvm.options.txt
while IFS= read -r line
do
  echo "$line" >> /config/jvm.options.txt
done < "/config/jvm.options"
echo "" >> /config/jvm.options.txt
mv -f /config/jvm.options.txt /config/jvm.options

echo "" >> /config/server.env && echo "JVM_ARGS=-Dhttps.protocols=TLSv1.2" >> /config/server.env
