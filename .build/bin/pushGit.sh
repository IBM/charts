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

commitmessage="[skip ci]Update version tgz fix"
commitstring="{  \"title\": \"$commitmessage\", \"body\": \"$commitmessage\", \"head\": \"$TRAVIS_BRANCH\", \"base\": \"master\" }"

# The branch is ready, we just need to add a remote conntection
git remote add $dsthost https://$GITHUBCOM_TOKEN@$dsthost/$dstorg/$dstrepo
git push $dsthost $TRAVIS_BRANCH
curl -H "Content-Type: application/json" -X POST -d "$commitstring" https://$GITHUBCOM_TOKEN@api.$dsthost/repos/$dstorg/$dstrepo/pulls 
curl -H "Authorization: token $GITHUB_TOKEN" https://github.$(rev <<< $TRAVIS_APP_HOST | cut -f1-2 -d'.'| rev)/api/v3/repos/$(cut -f1 -d'/' <<< $TRAVIS_SLUG_REPO)/content-tools/contents/travis-tools/build/bin/populateArtifactory.sh | egrep  '"download_url":' | cut -f2- -d':' | tr -d ' ",' | xargs -i curl -H "Authorization: token $GITHUB_TOKEN" {} | bash || true
