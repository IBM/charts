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

exportVars() {
    vname=$1
    vals=$2

    let "idx=0"
    for v in $vals; do
        export $(echo $vname$idx)=$v
        let "idx=idx+1"
    done
}

echo "The contents of /etc/resolv.conf are:"
cat /etc/resolv.conf

nameservers=$(grep -e ^nameserver /etc/resolv.conf | sed 's/nameserver //')
search=$(grep -e ^search /etc/resolv.conf | sed 's/search //')
options=$(grep -e ^option /etc/resolv.conf | sed 's/option //')

exportVars "CONFIG_whisk_containerFactory_containerArgs_dnsServers_" "$nameservers"
exportVars "CONFIG_whisk_containerFactory_containerArgs_dnsSearch_" "$search"
exportVars "CONFIG_whisk_containerFactory_containerArgs_dnsOptions_" "$options"
