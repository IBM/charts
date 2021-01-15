#!/bin/bash

export pref_file_location=/config/prefs.xml
echo "Database : "${dbType}

#logic to pick oracle or db2 prefs.xml
if [ -f /omscommonfile/configrepo/prefs.xml ]; then
   echo "File is present in repo"
else
    if [ "${dbType}" == "DB2" ]; then
		cp /config/prefs.xml /omscommonfile/configrepo/prefs.xml
	else
	    pref_file_location=/deployables/prefs.xml
		cp /deployables/prefs.xml /omscommonfile/configrepo/prefs.xml
	fi
fi

echo "Pref File Location : "$pref_file_location

#grep oob db value from prefs.xml and copy it into mounted prefs.xml
default_value=$(grep "<SrvcSubType" $pref_file_location|head -1 )
sed -i "/Database type/c\ $default_value" /omscommonfile/configrepo/prefs.xml

default_value=$(grep "<ConnectString" $pref_file_location|head -1 )
sed -i "/<ConnectString/c\ $default_value" /omscommonfile/configrepo/prefs.xml
echo "ConnectString : "$default_value

default_value=$(grep "<UserId" $pref_file_location|head -1 )
sed -i "/Database UserId/c\ $default_value" /omscommonfile/configrepo/prefs.xml

default_value=$(grep "<Password" $pref_file_location|head -1 )
sed -i "/Database Password/c\ $default_value" /omscommonfile/configrepo/prefs.xml

default_value=$(grep "<JdbcDriver1" $pref_file_location|head -1 )
sed -i "/<JdbcDriver1/c\ $default_value" /omscommonfile/configrepo/prefs.xml

default_value=$(grep "<DsKeyGenerators" $pref_file_location|head -1 )
sed -i "/<DsKeyGenerators/c\ $default_value" /omscommonfile/configrepo/prefs.xml

default_value=$(grep "<DsDataSources" $pref_file_location|head -1 )
sed -i "/<DsDataSources/c\ $default_value" /omscommonfile/configrepo/prefs.xml

#replace tokens in prefs xml
sed -i "s/@dbHostIp@/${dbHostIp}/g"  /omscommonfile/configrepo/prefs.xml && \
sed -i "s/@dbPort@/${dbPort}/g"  /omscommonfile/configrepo/prefs.xml && \
sed -i "s/@databaseName@/${databaseName}/g"  /omscommonfile/configrepo/prefs.xml && \
sed -i "s/@dbUser@/${dbUser}/g"  /omscommonfile/configrepo/prefs.xml && \
sed -i "s/@dbPassword@/${dbPassword}/g"  /omscommonfile/configrepo/prefs.xml

# Find and replace token of VM Sterling FulFillment ConfiguratorServerURL and VM ConfiguratorUIURL
sed -i "s/@configuratorServerURL@/${configuratorServerURL}/g" /config/dropins/VisualModeler.war/WEB-INF/properties/Comergent.xml && \
sed -i "s/@configuratorUIURL@/${configuratorUIURL}/g" /config/dropins/VisualModeler.war/WEB-INF/properties/Comergent.xml && \

# Find and replace token of VM Sterling FulFillment Field Sales UserName and Password
sed -i "s/@ifsAppUserName@/${appUserName}/g" /config/dropins/VisualModeler.war/WEB-INF/properties/Comergent.xml && \
sed -i "s/@ifsAppPassword@/${appPassword}/g" /config/dropins/VisualModeler.war/WEB-INF/properties/Comergent.xml && \

# Find and replace token of VM Visual Modeler Custom Function Handler and Custom UI Control
sed -i "s/@customFunctionHandler@/${functionHandler}/g" /config/dropins/VisualModeler.war/WEB-INF/properties/Comergent.xml && \
sed -i "s/@customUIControl@/${uiControl}/g" /config/dropins/VisualModeler.war/WEB-INF/properties/Comergent.xml

#Copy extensions.jar,property files and ui files in VisualModeler.war
export extensionsFilePath=/omscommonfile/configrepo/VM/extensions/
export propertyFilePath=/omscommonfile/configrepo/VM/properties/
export uiFilePath=/omscommonfile/configrepo/VM/web/

export schemaFilePath=/omscommonfile/configrepo/VM/schema/
export messageFilePath=/omscommonfile/configrepo/VM/messages/
export log4jFilePath=/omscommonfile/configrepo/VM/classes/log4j.properties

export repoPath=/omscommonfile/configrepo/VM/
export vmPath=/config/dropins/VisualModeler.war/WEB-INF
export vmlog4jFilePath=/config/dropins/VisualModeler.war/WEB-INF/classes/log4j.properties

for extensionFile in $(find $extensionsFilePath -name '*.jar' -type f -exec basename {} \;); 
do
    echo "Extension File : " $extensionFile
	\cp $extensionsFilePath/$extensionFile $vmPath/lib/$extensionFile
done 

for propertyFile in $(find $propertyFilePath -name '*.properties' -o -name '*.xml');
do
	search="properties"
	prefix=${propertyFile%%$search*}
	echo ${propertyFile:${#prefix}}
	\cp $repoPath/${propertyFile:${#prefix}} $vmPath/${propertyFile:${#prefix}}
done 

for uiFile in $(find $uiFilePath -name '*.*');
do
	search="web"
	prefix=${uiFile%%$search*}
	echo ${uiFile:${#prefix}}
	\cp $repoPath/${uiFile:${#prefix}} $vmPath/${uiFile:${#prefix}}
done

for schemaFile in $(find $schemaFilePath -name '*.*');
do
	search="schema"
	prefix=${schemaFile%%$search*}
	echo ${schemaFile:${#prefix}}
	\cp $repoPath/${schemaFile:${#prefix}} $vmPath/${schemaFile:${#prefix}}
done

for messageFile in $(find $messageFilePath -name '*.*'); 
do
	search="messages"
	prefix=${messageFile%%$search*}
	echo ${messageFile:${#prefix}}
	\cp $repoPath/${messageFile:${#prefix}} $vmPath/${messageFile:${#prefix}}
done 

\cp $log4jFilePath $vmlog4jFilePath


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

echo "-Djavax.net.ssl.trustStorePassword=${tlskeystorepassword}" >> /config/jvm.options.txt
echo "-Djavax.net.ssl.keyStorePassword=${tlskeystorepassword}" >> /config/jvm.options.txt

echo "" >> /config/jvm.options.txt
mv -f /config/jvm.options.txt /config/jvm.options

echo "" >> /config/server.env && echo "JVM_ARGS=-Dhttps.protocols=TLSv1.2" >> /config/server.env
