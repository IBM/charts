#!/bin/sh

    echo "Testing service   API."  
    HOST=$1
    FILE=scanned.signed-sqt.pdf
    CMD_FILE="file=@${FILE};type=application/pdf"
    CMD_FILE1="file1=@${FILE};type=application/pdf"
    CMD_FILE2="file2=@${FILE};type=application/pdf"
    sumOfReturnCodes=0 
    cd tests 
 
    if [ -f $FILE ]; then 
      code=0
      echo "$FILE exist"
       
    else 
      echo "$FILE not exist"
      exit 1
    fi
   
    URL="https://${HOST}:9443/api/v1/html_conversion?version=2018-09-02"    
    HTTP_CODE=$(curl -i -k -X POST -F  ${CMD_FILE}  $URL    --output /dev/null --write-out "%{http_code}")
    if [ "${HTTP_CODE}" = "200" ]; then code=0; else code=1; fi
    echo -e "\nURL  : $URL"
    echo -e "HTTP_CODE = ${HTTP_CODE}"
    sumOfReturnCodes=$((sumOfReturnCodes + ${code}))
    
    
     
    URL1="https://${HOST}:9443/api/v1/element_classification?version=2018-09-02"     
    HTTP_CODE1=$(curl -i  -k   -X POST -F  ${CMD_FILE}  $URL1   --output /dev/null --write-out "%{http_code}")
    if [ "${HTTP_CODE1}" = "200" ]; then code=0; else code=1; fi
    echo -e "\nURL1 : $URL1" 
    echo -e "\nHTTP_CODE1 = ${HTTP_CODE1}"
    sumOfReturnCodes=$((sumOfReturnCodes + ${code}))
    
    
    URL2="https://${HOST}:9443/api/v1/tables?version=2018-09-02"  
    HTTP_CODE2=$(curl -i  -k   -X POST -F  ${CMD_FILE}  $URL2   --output /dev/null --write-out "%{http_code}")
    if [ "${HTTP_CODE2}" = "200" ]; then code=0; else code=1; fi
    echo  -e "\nURL2 : $URL2"
    echo -e "\nHTTP_CODE2 = ${HTTP_CODE2}"
    sumOfReturnCodes=$((sumOfReturnCodes + ${code}))
     
   
    URL3="https://${HOST}:9443/api/v1/comparison?version=2018-09-02"   
    HTTP_CODE3=$(curl -i  -k   -X POST -F  ${CMD_FILE1} -F ${CMD_FILE2} $URL3   --output /dev/null --write-out "%{http_code}")
    if [ "${HTTP_CODE3}" = "200" ]; then code=0; else code=1; fi
    echo -e "\nURL3 : $URL3"
    echo  -e "\nHTTP_CODE3 = ${HTTP_CODE3}"
    sumOfReturnCodes=$((sumOfReturnCodes + ${code}))
   
   
    if [ $sumOfReturnCodes -gt 0 ]; then
      exit 1
    fi 
    exit 0
