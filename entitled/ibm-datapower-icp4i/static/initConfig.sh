#!/bin/bash

# This script handles initializing config in an unobtrusive way, applying
# the config associated with the chart while not overwritting the baked in
# config of the image.

# Directories/files
initDir="/opt/ibm/datapower/init"
initConfig="$initDir/config"
initLocal="$initDir/local"
initUsrcert="$initDir/usrcerts"
initSharedcert="$initDir/sharedcerts"
initOverrides="$initDir/chart-overrides"
drouterConfig="$DATAPOWER_BASE_DIR/drouter/config"
drouterLocal="$DATAPOWER_BASE_DIR/drouter/local"
drouterUsrcert="$DATAPOWER_BASE_DIR/root/secure/usrcerts"
drouterSharedcert="$DATAPOWER_BASE_DIR/root/secure/sharedcerts"

generate_domain_config() {
cat <<EOF
domain $1
  visible-domain default
exit

%if% available "include-config"

include-config "$1-cfg"
  config-url "config:///$1/$1.cfg"
  auto-execute
  no interface-detection
exit

%endif%
EOF
}

# In this merge, the order of precedence will be:
#   1. Tuneables set in chart values        (highest)
#   2. Config given through configmaps
#   3. Config built into the image          (lowest)

# Append all configmap files over top of existing config
(
if [ ! -d $initConfig ]; then
    exit # From sub-shell
fi

# Domains need to be in the configure terminal context to be configured
echo "top; configure terminal;" >> ${drouterConfig}/auto-startup.cfg

cd $initConfig
for dir in $(ls); do
    # domain is top level dir
    domain=$dir

    # Domain is a special case, all config should appended to auto-startup.
    if [ "$domain" = "default" ]; then
        for config in $(find $domain -type f); do
            cat $config >> ${drouterConfig}/auto-startup.cfg
        done
        continue
    fi

    # Check if domain doesn't exist
    if [ ! -d "$drouterConfig/$domain" ]; then
        generate_domain_config $domain >> $drouterConfig/auto-startup.cfg
    fi

    # Ensure domain directory exists
    mkdir -p $drouterConfig/$domain

    # Append config
    echo "top; configure terminal" >> $drouterConfig/$domain/$domain.cfg
    for config in $(find $domain -type f); do
        cat $config >> $drouterConfig/$domain/$domain.cfg
    done
done
) # FIN config


( # Unpack and copy the contents of the local tar file

if [ ! -d $initLocal ]; then
    exit # the subshell
fi

# unpack tar file
mkdir -p /opt/ibm/datapower/unpack-tmp
for targz in $(find $initLocal -type f); do
    tar xf $targz -C /opt/ibm/datapower/unpack-tmp
done
# copy unpacked contents to local
if [ -d "/opt/ibm/datapower/unpack-tmp/local" ]; then
    cp -r /opt/ibm/datapower/unpack-tmp/local/* $drouterLocal
else
    cp -r /opt/ibm/datapower/unpack-tmp/* $drouterLocal
fi
rm -rf /opt/ibm/datapower/unpack-tmp

) # FIN local


( # Copy certs

if [ ! -d $initUsrcert ]; then
    exit # the subshell
fi

cd $initUsrcert

for dir in $(find . -maxdepth 1 -type d); do
    domain=$(basename $dir)

    # skip the current dir result from find
    if [ "$domain" = "." ]; then
        continue
    fi

    [ "$domain" != "default" ] && mkdir -p $drouterUsrcert/$domain
    for cert in $(find $domain -type f); do
        if [ "$domain" = "default" ]; then
            cp $cert $drouterUsrcert
        else
            cp $cert $drouterUsrcert/$domain
        fi
    done
done

)

(
if [ ! -d $initSharedcert ]; then
    exit # the subshell
fi

cd $initSharedcert
mkdir -p $drouterSharedcert

for cert in $(find . -type f); do
    cp $cert $drouterSharedcert
done

) # FIN certs


# Begin chart specific config

# Append values-specified config
for file in $initOverrides/*; do
    if [ -d $file ]; then
        continue
    fi
    cat $file >> $drouterConfig/$(basename $file)
done

# Overwrite local files
for file in $initOverrides/local/*; do
    cp -r $file $drouterLocal/$(basename $file)
done

# FIN chart specific config
