###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2017. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
FROM nginx:1.13.1-alpine

ARG VCS_REF
ARG VCS_URL
ARG IMAGE_NAME
ARG IMAGE_DESCRIPTION

# http://label-schema.org/rc1/
LABEL org.label-schema.vendor="IBM" \
      org.label-schema.name="$IMAGE_NAME" \
      org.label-schema.description="$IMAGE_DESCRIPTION" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.license="Licensed Materials - Property of IBM" \
      org.label-schema.schema-version="1.0"

RUN mkdir -p /usr/share/nginx/html/stable && \
    mkdir -p /usr/share/nginx/html/incubating

ADD repo/incubating /usr/share/nginx/html/incubating
ADD repo/stable /usr/share/nginx/html/stable