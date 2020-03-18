#!/bin/bash

#replace tokens in prefs xml
sed -i "s/@dbHostIp@/${dbHostIp}/g"  /config/prefs.xml && \
sed -i "s/@dbPort@/${dbPort}/g"  /config/prefs.xml && \
sed -i "s/@databaseName@/${databaseName}/g"  /config/prefs.xml && \
sed -i "s/@dbUser@/${dbUser}/g"  /config/prefs.xml && \
sed -i "s/@dbPassword@/${dbPassword}/g"  /config/prefs.xml

sed -i "s/@configuratorServerURL@/${configuratorServerURL}/g" /config/dropins/VisualModeler.war/WEB-INF/properties/Comergent.xml && \
sed -i "s/@configuratorUIURL@/${configuratorUIURL}/g" /config/dropins/VisualModeler.war/WEB-INF/properties/Comergent.xml

sed -i "s/@POD_HOSTNAME@/${HOSTNAME}/g" /config/dropins/VisualModeler.war/WEB-INF/classes/log4j.properties

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
