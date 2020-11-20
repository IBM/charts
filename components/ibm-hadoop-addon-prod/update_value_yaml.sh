#!/bin/bash
list=$(ls ${WORKSPACE}/ws-v2-base-charts/charts/images | sed 's/.tar.gz//')

for item in $list; do
  repo=$(echo $item | sed 's/_/ /' | awk {'print $1'})
  tag=$(echo $item | sed 's/_/ /' | awk {'print $2'})
  if [[ $tag = *".tar.gz"* ]]; then
    echo "image has more than one \.tar\.gz"
    exit 1
  fi
  echo "Using "$repo":"$tag
  sed -i -e "/repository: $repo/{ n; s/\(.*tag:\s*\).*/\1$tag/ }" ${WORKSPACE}/ws-v2-base-charts/charts/ibm-hadoop-addon-prod/values.yaml
done

echo "values.yaml has been updated"
