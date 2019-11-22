#!/bin/bash
list=$(ls ${WORKSPACE}/icp4data-base-charts/charts/images | sed 's/.tar.gz//')

for item in $list; do
  repo=$(echo $item | sed 's/_/ /' | awk {'print $1'})
  tag=$(echo $item | sed 's/_/ /' | awk {'print $2'})
  if [[ $tag = *".tar.gz"* ]]; then
    echo "image has more than one \.tar\.gz"
    exit 1
  fi
  echo "Using "$repo":"$tag
  sed -i -e "/repository: $repo/{ n; s/\(.*tag:\s*\).*/\1$tag/ }" ${WORKSPACE}/icp4data-base-charts/charts/0010-infra/values.yaml
done

#temporary fix for the alipine tag issue
alpineTag=$(grep  'tag: alpine_*' ${WORKSPACE}/icp4data-base-charts/charts/0010-infra/values.yaml)
finaltag=${alpineTag/alpine_/}
sed -i -e "s/${alpineTag}/${finaltag}/g" ${WORKSPACE}/icp4data-base-charts/charts/0010-infra/values.yaml
echo "values.yaml has been updated"
