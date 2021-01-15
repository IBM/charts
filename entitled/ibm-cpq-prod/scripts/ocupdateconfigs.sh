#!/bin/bash

if [ ${swaggerEnabled} = false ]; then
  echo "Turning Swagger off"
  rm -rf /configurator/configurator.war/javadoc
  rm -rf /configurator/configurator.war/swagger
  rm  /configurator/configurator.war/index.html
fi

sed -i "s/@httpPort@/${httpPort}/g"  /config/server.xml && \
sed -i "s/@httpsPort@/${httpsPort}/g"  /config/server.xml
sed -i "s/http:\/\/configurator.in.ibm.com:9080/${ocHostName}/g" /configurator/configurator.war/WEB-INF/web.xml

echo "Pod HOSTNAME=${HOSTNAME}"

grep '@POD_HOSTNAME@' /omscommonfile/configrepo/omniconfigurator/properties/log4j.properties
if [ $? == 1 ]
then
  echo "POD_HOSTNAME not found in log file."
  for ele in `grep '\.File' /omscommonfile/configrepo/omniconfigurator/properties/log4j.properties`; do
  echo "element = $ele"
  fullpath=`echo $ele | cut -d "=" -f 2`
  fullpath=`basename $fullpath`
  logfilename=`echo $fullpath | cut -d "." -f 1`
  
  echo $logfilename | grep '_'
  if [ $? == 0 ]
  then
    echo 'found _'
    logfilename=`echo $logfilename | cut -d "_" -f 1`
  fi
  echo "looking for - $logfilename"

  sed -i "s/${logfilename}/${HOSTNAME}/g" /omscommonfile/configrepo/omniconfigurator/properties/log4j.properties
  done
else
  echo "POD_HOSTNAME found in log file."
  sed -i "s/@POD_HOSTNAME@/${HOSTNAME}/g" /omscommonfile/configrepo/omniconfigurator/properties/log4j.properties
fi

cp /home/default/server1.xml /config/server.xml

sed -i "s/@POD_HOSTNAME@/${HOSTNAME}/g" /config/server.xml

#copy the configmapped jvm init file into /config/jvm.options
cp /config/jvm.options.init /config/jvm.options.txt
echo "" >> /config/jvm.options.txt
echo "-Djava.rmi.server.hostname=${APP_POD_IP}" >> /config/jvm.options.txt
echo "" >> /config/jvm.options.txt
while IFS= read -r line
do
  echo "$line" >> /config/jvm.options.txt
done < "/config/jvm.options"

echo "-Djavax.net.ssl.trustStorePassword=${tlskeystorepassword}" >> /config/jvm.options.txt
echo "-Djavax.net.ssl.keyStorePassword=${tlskeystorepassword}" >> /config/jvm.options.txt

echo "" >> /config/jvm.options.txt
mv -f /config/jvm.options.txt /config/jvm.options

echo "" >> /config/server.env && echo "JVM_ARGS=-Dhttps.protocols=TLSv1.2" >> /config/server.env
