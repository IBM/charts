#!/bin/bash
#
# Copyright IBM Corporation 2018. All Rights Reserved
#
# There is a need to determine the file change in the repo
# The old index will be save, new index generated
# The list of changed sha/digests will found
# The old files will be removed, and new tgz merges with the old
#
#set -x
set -o errexit
set -o nounset
set -o pipefail

# This is the link to the repo, if there is more that on build, then we would use
# a variable to describte the link, but for now this works.
[[ -z "${1:-}" ]] && repodir=community || repodir=$1
: "${MASTER_BRANCH:=`git branch | grep -v master | egrep "^\*" | tr -s ' '| cut -f2 -d' '`}"
: "${PAT:=""}"

[[ -z "${MASTER_BRANCH}" ]] && { echo "[ERROR] unable to set branch, you may be on master" ; exit 1 ; }

URL="https://raw.githubusercontent.com/IBM/charts/master/repo/$repodir/" # TODO Update

R='\033[0;31m'
G='\033[0;32m'
N='\033[0m'

# set context of the directory structure
[[ `dirname $0 | cut -c1` = '/' ]] && localtoolpath=`dirname $0`/ || localtoolpath=`pwd`/`dirname $0`/
repositoryroot=$localtoolpath/../../

function buildtable() 
{
	begin "Generate table with helm repo names"
	# simpy build a file with the link and digest to see if something changes
	local indexname=$1
	local indexout=$1.digest
	local digest=""
	local image=""

	rm $indexout 2> /dev/null|| true
	[[ ! -f "$1" ]] && { touch $indexout ; return ; }
	set `cat $1 | egrep "https.*tgz|digest" | tr -d ' '`
	while test $# -gt 0
	do
		digest=`cut -f2 -d: <<< $1`; shift
		image=`echo $1 | rev | cut -f1 -d/ | rev`; shift
		echo "$image:$digest" >> $indexout
	done
	sort -o $indexout $indexout # sort for latest usage, this is alpha by chart name
	end
}

function findnew() {
	# Use the generated table to get a list of new files which have appear
 	# if this is a new file, we will leave it as part of the directory
	begin "Locate new images"
	local old=$1.digest
	local new=$2.digest
	local list="GUARD"
	local chartlist=`grep -v -f $old $new | cut -f1 -d':'`
	
	[[ -z "$chartlist" ]] && { pushd `dirname $new`;  ls -1 | egrep tgz | xargs -i rm {} ; popd ; end "No charts NEW found" ;  return 0 ; } # there were no charts found
	set $chartlist # These are the new files
	while test $# -gt 0
	do
		list="$list|$1"
		info "${G}New Image: $1${N}"
		shift
	done
	# we have a list of new charts, now remove all the other chart
	pushd `dirname $new`
	ls -1 | egrep tgz | egrep -v "$list" | xargs -i -r rm {} || true
	popd
	end
}

function finddeleted() {
	begin "Find charts which have been deleted"
        local old=$1.digest
	local index=$1
        local new=$2.digest
	local basechart=""

	cat $new | cut -f1 -d':' > $new.delete
	local chartlist=`grep -v -f $new.delete $old | cut -f1 -d':'`
	[[ -z "$chartlist" ]] && { end "No Deleted charts" ; return 0 ; } # there were no charts found
        set $chartlist # These are the deleted files.
	while test $# -gt 0
	do
		
		info "${R}Deleted charts: $1${N}"
		basechart=`cut -f1 -d'.' <<< $1 | rev | cut -f2- -d'-' | rev`
		removechart $basechart $index
		# There may be some charts which are not deleted
		info "cp `dirname $index`/${basechart}-[0-9]*.[0-9]*.[0-9].tgz `dirname $new`/"
		cp `dirname $index`/${basechart}-[0-9]*.[0-9]*.[0-9].tgz `dirname $new`/ || true 
		shift
	done
	end
}

function removechart()
{
	begin "Remove deleted chart from index"
	local chartname=$1
	local index=$2
	info "Remove chart : $chartname"
	range=`egrep -n "^  [[:alnum:]]" $index | egrep -A1 ":  $chartname:" | cut -f1 -d':' | xargs echo` || return 0 # We may have removed the chart already
	start=`cut -f1 -d' ' <<< $range`
	let end=`cut -f2 -d' ' <<< $range`-1
	sed -i "${start},${end}d" $index
	end
}

function helmpackage()
{
	begin "Merge the changed repo with the old index"
	[[ -f "$2/index.yaml" ]] ||  helm repo index $2 --url $URL  # This is the case it does not exist
	info "helm repo index $1 --merge $2/../index.yaml --url $URL"
	mv $2/index.yaml $2/../
	helm repo index $1 --merge $2/../index.yaml --url $URL	

	diff -q -I "^generated:" $2/index.yaml.master $2/../index.yaml && { info "Index not changed" ; mv $2/../index.yaml $2/index.yaml ; }   || { info "Index has been updated" ; cp $1/index.yaml $2 ; }
	rm $1/index.yaml.* rm $2/index.yaml.* || true

	# cp $1/* $2/ || true
	end
}

function setup()
{
	begin "create directory structure"
	# this will create the process
	[[ ! -d "`dirname $1`" ]] && { echo "There is no directory to build against: `dirname $1`" ; exit ; } 
	rm -rf `dirname $2` 2>/dev/null || true
	mkdir -p `dirname $2` 
	cp `dirname $1`/* `dirname $2`
	pushd `dirname $2`
	rm index.yaml || true
	info "Build a helm repo to see if there are changes"
	helm repo index . --url $URL 
	popd
	cp $1 $1.master # save a copy of the master index for later comparison
	end

}

function commitchange()
{
	begin "Commit the changes"
	sed -i "s#https://github.com/IBM/charts#https://$PAT@github.com/IBM/charts#g" .git/config
	git branch
	git checkout $MASTER_BRANCH 
	git fetch
	git stage repo/$repodir/
	git commit -m"[skip ci] - Master branch update with index" && git push origin $MASTER_BRANCH || info "No changes to push" # TODO, no changes will also appear if push fails, need to fix
	end
}

function begin() { trace begin ${FUNCNAME[1]} $@ ; }

function end() { trace end ${FUNCNAME[1]} $@ ; }

function error() { trace ERROR ${FUNCNAME[1]} $@ ; }

function info() { trace INFO  ${FUNCNAME[1]} $@ ; }

function trace()
{
        local type=$1 ; shift ;
        local function=$1 ; shift
        echo -e "[ `tr '[:lower:]' '[:upper:]' <<< $type` $function ]\t $@"
}

begin "#################### Rebuild helm repo ################################"
oldindex=$repositoryroot/repo/$repodir/index.yaml
newindex=$repositoryroot/repo/build/index.yaml
setup $oldindex $newindex 
buildtable $oldindex
buildtable $newindex
findnew $oldindex $newindex 
finddeleted $oldindex $newindex
helmpackage `dirname $newindex` `dirname $oldindex`
commitchange
end "#########################################################################"

