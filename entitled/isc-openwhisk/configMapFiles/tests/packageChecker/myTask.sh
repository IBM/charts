#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This test verifies that the catalog of system packages has been properly
# installed and is accessible using the guest auth.

packageListingCheck() {
  echo "Looking for package $1"
  if [ -z "$1" ]; then
    echo "Error, package listing check called without a package name"
    exit 1
  fi

  # Try several times to accommodate eventual consistency of CouchDB
  PACKAGE_LIST_PASSED=false
  PACKAGE_LIST_ATTEMPTS=0
  until $PACKAGE_LIST_PASSED; do
      RESULT=$(wsk package list /whisk.system -i | grep "$1")
      if [ -z "$RESULT" ]; then
          let PACKAGE_LIST_ATTEMPTS=PACKAGE_LIST_ATTEMPTS+1
          if [ $PACKAGE_LIST_ATTEMPTS -gt 5 ]; then
              echo "FAILED! Could not list package $1"
              exit 1
          fi
          echo "wsk package list did not find $1; sleep 5 seconds and try again"
          sleep 5
      else
          echo "success: wsk package list included $1"
          PACKAGE_LIST_PASSED=true
      fi
  done
}

# Configure wsk CLI
wsk property set --auth $WSK_AUTH --apihost $WSK_API_HOST_URL


# Check for the standard catalog of packages
packageListingCheck "combinators"
packageListingCheck "github"
packageListingCheck "slack"
packageListingCheck "utils"
packageListingCheck "samples"
packageListingCheck "weather"
packageListingCheck "websocket"

# Check packages for installed event providers
if [ "$OW_INSTALL_ALARM_PROVIDER" == "yes" ]; then
    packageListingCheck "alarms"
fi
if [ "$OW_INSTALL_CLOUDANT_PROVIDER" == "yes" ]; then
    packageListingCheck "cloudant"
fi
if [ "$OW_INSTALL_KAFKA_PROVIDER" == "yes" ]; then
    packageListingCheck "messaging"
fi

# Invoke /whisk.system/utils.echo as a smoketest of the installed actions
RESULT=$(wsk -i action invoke --blocking /whisk.system/utils/echo -p msg HelloWhisker | grep "\"msg\": \"HelloWhisker\"")
if [ -z "$RESULT" ]; then
    echo "FAILED! Did not get expected result from invoking /whisk.system/utils/echo"
    echo $RESULT
    exit 1
fi

echo "PASSED! Listed all expected packages and successfully invoked echo action"



