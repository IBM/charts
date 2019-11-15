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

# A short smoketest to verify basic functionality of an OpenWhisk deployment

# Configure wsk CLI
wsk property set --auth $WSK_AUTH --apihost $WSK_API_HOST_URL

# create wsk action
cat > /tmp/hello.js << EOL
function main() {
  return {body: 'Hello world'}
}
EOL

echo "Creating action"
wsk -i action create hello /tmp/hello.js --web true || (echo "FAILED! Could not create a hello action!"; exit 1)

# first list actions and expect to see hello
# Try several times to accommodate eventual consistency of CouchDB
echo "Listing action"
ACTION_LIST_PASSED=false
ACTION_LIST_ATTEMPTS=0
until $ACTION_LIST_PASSED; do
  RESULT=$(wsk -i action list | grep hello)
  if [ -z "$RESULT" ]; then
    let ACTION_LIST_ATTEMPTS=ACTION_LIST_ATTEMPTS+1
    if [ $ACTION_LIST_ATTEMPTS -gt 5 ]; then
      echo "FAILED! Could not list hello action via CLI"
      exit 1
    fi
    echo "wsk action list did not include hello; sleep 5 seconds and try again"
    sleep 5
  else
      echo "success: wsk action list included hello"
      ACTION_LIST_PASSED=true
  fi
done

# next invoke the new hello world action via the CLI
echo "Inoking action via CLI"
RESULT=$(wsk -i action invoke --blocking hello | grep "\"status\": \"success\"")
if [ -z "$RESULT" ]; then
  echo "FAILED! Could not invoke hello action via CLI"
  exit 1
fi

# now run it as a web action
echo "Invoking as web action"
HELLO_URL=$(wsk -i action get hello --url | grep "https://")
RESULT=$(wget --no-check-certificate -qO- $HELLO_URL | grep 'Hello world')
if [ -z "$RESULT" ]; then
  echo "FAILED! Could not invoke hello as a web action"
  exit 1
fi

# now define it as an api and invoke it that way
echo "Registering as an api"
wsk -i api create /demo /hello get hello || (echo "FAILED: unable to create API"; exit 1)
echo "Invoking action via the api"
API_URL=$(wsk -i api list | grep hello | awk '{print $4}')
RESULT=$(wget --no-check-certificate -qO- "$API_URL" | grep 'Hello world')
if [ -z "$RESULT" ]; then
  echo "FAILED! Could not invoke hello via apigateway"
  exit 1
fi

# now delete the resouces so the test could be run again
wsk -i api delete /demo || (echo "FAILED! failed to delete API"; exit 1)
wsk -i action delete hello || (echo "FAILED! failed to delete action"; exit 1)

echo "PASSED! Created Hello action and invoked via cli, web and apigateway"



