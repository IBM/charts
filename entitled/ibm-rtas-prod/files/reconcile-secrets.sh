#!/bin/bash -e

check-pre-reqs() {
  echo "Checking dependencies are available:"
  for u in ${kubectl:-kubectl} curl jq
  do
    if command -v "$u" >/dev/null; then
      echo "  $u found in PATH"
    else
      >&2 echo "ERROR: \"$u\" not foun in PATH. Please install it."
      >&2 echo "       sudo apt-get install $u"
      exit 1
    fi
  done
  echo
}

gateway-get-clientid() {
  ${kubectl:-kubectl} get deployment "$release-gateway" -n "$namespace" \
    -o jsonpath="{.spec.template.spec.containers[0].env[?(@.name == 'SECURITY_OAUTH2_CLIENT_CLIENT_ID')].value}"
}

gateway-get-realm() {
  ${kubectl:-kubectl} get deployment "$release-gateway" -n "$namespace" \
    -o jsonpath="{.spec.template.spec.containers[0].env[?(@.name == 'SECURITY_OAUTH2_CLIENT_USER_AUTHORIZATION_URI')].value}" \
    | sed -n -r 's#.*/realms/([^/]*).*#\1#p'
}

keycloak-get-password() {
  secret-get -s "$release-keycloak-postgresql" -k password
}

keycloak-get-token() {
  local OPTIND user pass
  while getopts "u:p:" flag; do
  case "$flag" in
      u) user=$OPTARG;;
      p) pass=$OPTARG;;
      *) exit 1;;
  esac
  done

  local -r tokens="$($curl -s -X POST "$keycloak_url/realms/master/protocol/openid-connect/token" \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "username=$keycloak_user" \
    --data-urlencode "password=$pass" \
    -d grant_type=password \
    -d client_id=admin-cli)"
  local -r token=$(sed -r -n 's/.*"access_token":"([^"]*)".*/\1/p' <<< "$tokens")

  if [[ -z "$token" ]]; then
    >&2 echo "ERROR: Keycloak returned no access token. Is $keycloak_url self-signed? If it is, try again with option --insecure"
    exit 1
  fi

  echo -n "$token"
}

keycloak-get-user() {
  ${kubectl:-kubectl} get statefulset "$release-ssocloak" -n "$namespace" \
    -o jsonpath="{.spec.template.spec.containers[0].env[?(@.name == 'KEYCLOAK_USER')].value}"
}

keycloak-script-delete-user() {
  local OPTIND user
  while getopts "u:" flag; do
  case "$flag" in
      u) user=$OPTARG;;
      *) exit 1;;
  esac
  done

  echo "\c keycloak;
DELETE FROM user_role_mapping WHERE user_id IN (SELECT id FROM user_entity WHERE username='$user' AND realm_id='master');
DELETE FROM credential WHERE user_id IN (SELECT id FROM user_entity WHERE username='$user' AND realm_id='master');
DELETE FROM user_entity WHERE username='$user' AND realm_id='master';"
}

pod-status-ready() {
  ${kubectl:-kubectl} get pod -ojsonpath='{.status.containerStatuses[0].ready}' "$@"
}

postgres-set-password() {
  local OPTIND username secret pod extra
  while getopts "u:s:p:e:" flag; do
  case "$flag" in
      u) username=$OPTARG;;
      s) secret=$OPTARG;;
      p) pod=$OPTARG;;
      e) extra=$OPTARG;;
      *) exit 1;;
  esac
  done

  echo "Setting Postgresql password for \"$username\""

  local -r postgres_secret="${secret:-$release-$username}"
  local -r postgres_pod="${pod:-$release-$username-postgresql-0}"
  local -r postgres_password="$(secret-get -s "$postgres_secret" -k postgresql-password)"

  ${kubectl:-kubectl} exec -n "$namespace" "$postgres_pod" -- bash -c \
    "sed -i 's/^\([^#]*\)md5/\1trust/g' /opt/bitnami/postgresql/conf/pg_hba.conf && \
     pg_ctl reload >/dev/null && \
     echo \"ALTER ROLE $username WITH PASSWORD '${postgres_password//\'/\'\'}';$extra\" | psql -U \"$username\" && \
     sed -i 's/^\([^#]*\)trust/\1md5/g' /opt/bitnami/postgresql/conf/pg_hba.conf && \
     pg_ctl reload >/dev/null"

  echo
}

rabbitmq-get-password() {
  secret-get -s "$release-rabbitmq-custom" -k rabbitmq-password
}

rabbitmq-set-password() {
  local OPTIND username password
  while getopts "u:p:" flag; do
  case "$flag" in
      u) username=$OPTARG;;
      p) password=$OPTARG;;
      *) exit 1;;
  esac
  done

  echo "Setting RabbitMQ password for \"$username\""

  ${kubectl:-kubectl} exec -n "$namespace" "$release-rabbitmq-0" -- rabbitmqctl change_password "$username" "$password"

  echo
}

secret-get() {
  local OPTIND secret key
  while getopts "s:k:" flag; do
  case "$flag" in
      s) secret=$OPTARG;;
      k) key=$OPTARG;;
      *) exit 1;;
  esac
  done

  ${kubectl:-kubectl} get secret -n "$namespace" "$secret" -o jsonpath="{.data.$key}" | base64 --decode
}

usage() {
  echo "Usage: $0 [-k] -n <namespace> <helm-release>"
  echo
  echo "This script will replace persisted passwords with those defined in secrets."
  echo
  echo "Options:"
  echo "-k | --insecure"
  echo "  Allow insecure https connections to the ingress domain."
  echo "-n | --namespace <namespace>"
  echo "  The namespace where the product is installed."
  echo "helm-release"
  echo "  The release name used in helm when installing the product."
  exit 1
}

if ! parsed=$(getopt -o n:k \
 -l namespace:,insecure \
 -n "$(basename "$0")" -- "$@"); then
  usage
fi
eval set -- "$parsed"

curl=curl
while true; do
  case "$1" in
    -n|--namespace) namespace="$2"; shift;;
    -k|--insecure) curl="curl -k";;
    --) shift; release="$1"; break;;
     *) exit 1;;
  esac
  shift
done

if [ -z "$namespace" ] || [ -z "$release" ]; then
  usage
fi

if [ -z "$kubectl" ] && command -v oc >/dev/null; then
  kubectl=oc
fi

echo "Reseting passwords for release \"$release\" in namespace \"$namespace\""
echo

check-pre-reqs

rabbitmq-set-password -u user -p "$(rabbitmq-get-password)"

keycloak_user=$(keycloak-get-user)
keycloak_pod="$release-ssocloak-0"

postgres-set-password -u keycloak -s "$release-keycloak-postgresql" -e "$(keycloak-script-delete-user -u "$keycloak_user")"

echo "Restarting Keycloak to create new \"$keycloak_user\" user"
${kubectl:-kubectl} delete pod "$keycloak_pod" -n "$namespace"
echo

postgres-set-password -u datasets
postgres-set-password -u execution
postgres-set-password -u gateway
postgres-set-password -u results
postgres-set-password -u rm
postgres-set-password -u testassets -s "$release-tam" -p "$release-tam-postgresql-0"

echo -n "Waiting for pod \"$keycloak_pod\" to be ready"
until [ "true" = "$(pod-status-ready -n "$namespace" "$keycloak_pod")" ]
do
  echo -n '.'
  sleep 3
done
echo
echo "pod \"$keycloak_pod\" is ready"
echo

keycloak_clientid="$(gateway-get-clientid)"
keycloak_realm="$(gateway-get-realm)"
keycloak_url=$(${kubectl:-kubectl} exec -n "$namespace" "$keycloak_pod" -- sh -c 'echo $KEYCLOAK_FRONTEND_URL')
keycloak_token="$(keycloak-get-token -u "$keycloak_user" -p "$(keycloak-get-password)")"

echo "Setting Keycloak client secret for \"$keycloak_clientid\" (used by gateway) at \"$keycloak_url/admin/realms/$keycloak_realm\""

client="$($curl -s "$keycloak_url/admin/realms/$keycloak_realm/clients?clientId=$keycloak_clientid" \
  -H "Authorization: Bearer $keycloak_token" \
  | jq ".[0] + {secret:\"$(secret-get -s "$release-gateway" -k oauth-client-secret)\"}")"

$curl -sw '%{http_code}' -X PUT "$keycloak_url/admin/realms/$keycloak_realm/clients/$(jq -r .id <<< "$client")" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $keycloak_token" --data-binary @- <<< "$client"; echo

server_host=$(${kubectl:-kubectl} exec -n "$namespace" "$keycloak_pod" -- sh -c 'echo $INGRESS_DOMAIN')
echo
echo "Password reconciliation completed successfully, wait for pods to become ready:"
echo "  ${kubectl:-kubectl} get pods -n $namespace"
echo
echo "Next Steps"
echo "User secrets stored in the product have not been checked. This may mean they are currently inaccessible having been encrypted with a different key. To make them accessible you must re-encrypt them providing the old key."
echo
echo "To perform this action an offline token belonging to a user with the Administrator role is required along with the PasswordAutoGenSeed used in the previous install."
echo
echo "OFFLINE_TOKEN=eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo"
echo "OLD_HELM_SEED=MyR3t!redSeed"
echo
echo "$curl -si -X POST https://$server_host/rest/secrets/re-encrypt/ \\"
echo "      -H \"Authorization: Bearer \$( \\"
echo "         $curl -s -X POST https://$server_host/rest/tokens/ \\"
echo "               -H 'Accept: application/json' \\"
echo "               -d \"refresh_token=\$OFFLINE_TOKEN\" | jq -r .access_token)\" \\"
echo "      -H 'Content-Type: application/json' \\"
echo "      -d '{\"type\":\"helm\",\"password_auto_gen_seed\":\"'\$OLD_HELM_SEED'\"}'"
echo
echo "If you have overridden the storage key specifically (for example having migrated the product from before 10.1) use this format instead."
echo "      -d '{\"type\":\"kube\",\"storage_key\":\"'\$OLD_EXISTING_SECRETS_STORAGE_KEY'\"}'"
echo
echo "This should return '202 Accepted' and progress can be seen in the log"
echo "${kubectl:-kubectl} logs -n $namespace -lapp.kubernetes.io/name=gateway -f"