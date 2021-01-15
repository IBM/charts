#!/bin/bash
# Licensed Materials - Property of IBM
# IBM Order Management Software (5725-D10)
# (C) Copyright IBM Corp. 2019 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
# This will replace '$(env variable)' with 'env variable value' from the supplied source file as first argument.
# if the target file is not supplied as second argument, then the first argument file is overwritten with changes.
SRC_FILE=$1;
if [ $# -lt 1 ]; then
    echo "no arguments supplied. exiting with error";
    exit 1;
elif [ $# -gt 1 ]; then
    TARGET_FILE=$2;
    cp ${SRC_FILE} ${TARGET_FILE};
else
    TARGET_FILE=$1;
fi
echo "evaluating env variables from file $SRC_FILE into $TARGET_FILE";
for VARNAME in $(grep -P -o -e '\$\(\S+\)' ${SRC_FILE} | sed -e 's|^\$(||g' -e 's|)$||g' | sort -u);
do sed -i "s|\$($(echo $VARNAME))|${!VARNAME}|g" ${TARGET_FILE};
echo "done!";
done
