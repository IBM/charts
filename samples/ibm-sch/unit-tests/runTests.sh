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

ISHELM3=0

if helm version | awk -F\" '{print $2}' | grep "v3" ; then
  echo "Running with Helm 3"
  ISHELM3=1
else
  echo "Running with Helm 2"
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
  helm template $TESTDIR/chart -f $TESTDIR/chart/values.yaml | sed '/---/d' | sed '/^$/d' | sed '/# Source/d' | sed 's/"release-name"/"RELEASE-NAME"/g' > $TESTDIR/output.yaml
  if [ $ISHELM3 == 1 ]; then
    if [ ! -f $TESTDIR/expected_helm3.yaml ]; then
      sed 's/"Tiller"/"Helm"/g' $TESTDIR/expected.yaml > $TESTDIR/expected_helm3.yaml
      $SCRIPTDIR/compareyaml -expected=$TESTDIR/expected_helm3.yaml -actual=$TESTDIR/output.yaml
      rm $TESTDIR/expected_helm3.yaml
    else
      $SCRIPTDIR/compareyaml -expected=$TESTDIR/expected_helm3.yaml -actual=$TESTDIR/output.yaml
    fi
  else
    $SCRIPTDIR/compareyaml -expected=$TESTDIR/expected.yaml -actual=$TESTDIR/output.yaml
  fi
  if [ $? != 0 ]; then
    FAIL=true
  else
    rm $TESTDIR/output.yaml
  fi
  rm -rf $TESTDIR/chart/charts
done

rm $SCRIPTDIR/compareyaml

if [ $FAIL = true ]; then
  echo "One or more test failed."
  exit 1
fi
