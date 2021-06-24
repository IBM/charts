#!/bin/sh

echo "Register the provided redirect Uris list with the provided or generated Client Id"
/oidc/registration.sh
echo "List the redirect Uris of the provided or generated Client Id"
/oidc/list.sh
