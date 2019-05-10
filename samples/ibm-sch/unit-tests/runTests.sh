#!/bin/bash
# Exit when failures occur (including unset variables)
#set -o errexit
#set -o nounset
#set -o pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ "$OSTYPE" == "darwin"* ]]; then
  cp $SCRIPTDIR/tools/compareyaml/compareyaml_darwin $SCRIPTDIR/compareyaml
else
  cp $SCRIPTDIR/tools/compareyaml/compareyaml_linux $SCRIPTDIR/compareyaml
fi

FAIL=false
TESTDIRS=($SCRIPTDIR/test-*)
for TESTDIR in "${TESTDIRS[@]}"
do
  echo "Executing:" $(basename $TESTDIR)
  mkdir -p $TESTDIR/chart/charts/ibm-sch/templates
  cp -R $TESTDIR/../../templates/* $TESTDIR/chart/charts/ibm-sch/templates
  cp -R $TESTDIR/../../Chart.yaml $TESTDIR/chart/charts/ibm-sch/Chart.yaml
  cp -R $TESTDIR/../../values.yaml $TESTDIR/chart/charts/ibm-sch/values.yaml
  helm template $TESTDIR/chart -f $TESTDIR/chart/values.yaml | sed '/---/d' | sed '/^$/d' | sed '/# Source/d' > $TESTDIR/output.yaml
  $SCRIPTDIR/compareyaml -expected=$TESTDIR/expected.yaml -actual=$TESTDIR/output.yaml
  if [ $? != 0 ]; then
    FAIL=true
  fi
  rm -rf $TESTDIR/chart/charts
done

rm compareyaml

if [ $FAIL = true ]; then
  echo "One or more test failed."
  exit 1
fi
