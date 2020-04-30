echo "Start to check swid tag"
if [ ! -f "/usr/src/app/swidtag/ibm.com_IBM_Maximo_Equipment_Maintenance_Assistant_Add-On-1.1.1.swidtag" ];then
    echo "file addon not exist"
else
    rm -f /usr/src/app/swidtag/ibm.com_IBM_Maximo_Equipment_Maintenance_Assistant_Add-On-1.1.1.swidtag
    echo "file addon delete success"
fi