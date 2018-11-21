#!/bin/bash
#
# This will take a branch from github.ibm.com and promote it to github.com
# a PR will be opened, on the github.com side
# The main reason for this additional step is the missing github.com PAT
# in the travis build of the chart promoting the tgz
#
#
set -o errexit
set -o nounset
set -o pipefail

dsthost=github.com
dstorg=IBM
dstrepo=charts

[[ `dirname $0 | cut -c1` = '/' ]] && localtoolpath=`dirname $0`/ || localtoolpath=`pwd`/`dirname $0`/

#. $localtoolpath/../../../library/pullRequest.sh

commitmessage="Update previous published version tgz"
commitstring="{  \"title\": \"$commitmessage\", \"body\": \"$commitmessage\", \"head\": \"$TRAVIS_BRANCH\", \"base\": \"master\" }"
#	curl -H "Content-Type: application/json" -X POST -d "$json" https://$GITHUBCOM_TOKEN@api.$dsthost/repos/$dstorg/$dstrepo/pulls | egrep "message|pull request already exists|  .html_url.: " | head -n2

# The branch is ready, we just need to add a remote conntection
git remote add $dsthost https://$GITHUBCOM_TOKEN@$dsthost/$dstorg/$dstrepo
git push $dsthost $TRAVIS_BRANCH
set -x
echo $GITHUBCOM_TOKEN | base64
echo "curl -H \"Content-Type: application/json\" -X POST -d \"$commitstring\" https://$GITHUBCOM_TOKEN@api.$dsthost/repos/$dstorg/$dstrepo/pulls"
curl -H "Content-Type: application/json" -X POST -d "$commitstring" https://$GITHUBCOM_TOKEN@api.$dsthost/repos/$dstorg/$dstrepo/pulls 
