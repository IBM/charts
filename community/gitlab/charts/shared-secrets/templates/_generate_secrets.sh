namespace={{ .Release.Namespace }}
release={{ .Release.Name }}
env={{ .Values.env }}

pushd $(mktemp -d)

# Args pattern, length
function gen_random(){
  head -c 4096 /dev/urandom | LC_CTYPE=C tr -cd $1 | head -c $2
}

# Args: secretname, args
function generate_secret_if_needed(){
  secret_args=( "${@:2}")
  secret_name=$1
  if ! $(kubectl --namespace=$namespace get secret $secret_name > /dev/null 2>&1); then
    kubectl --namespace=$namespace create secret generic $secret_name ${secret_args[@]}
  else
    echo "secret \"$secret_name\" already exists"
  fi;
{{- if not .Values.global.application.create }}
  # Remove application labels if they exist
  kubectl --namespace=$namespace label \
    secret $secret_name $(echo '{{ include "gitlab.application.labels" . | replace ": " "=" | replace "\n" " " }}' | sed -E 's/=[^ ]*/-/g')
{{- end }}
  kubectl --namespace=$namespace label \
    --overwrite \
    secret $secret_name {{ include "gitlab.standardLabels" . | replace ": " "=" | replace "\n" " " }}
}

# Initial root password
generate_secret_if_needed {{ template "gitlab.migrations.initialRootPassword.secret" . }} --from-literal={{ template "gitlab.migrations.initialRootPassword.key" . }}=$(gen_random 'a-zA-Z0-9' 64)

# Redis password
{{if .Values.global.redis.password.enabled -}}
generate_secret_if_needed {{ template "gitlab.redis.password.secret" . }} --from-literal={{ template "gitlab.redis.password.key" . }}=$(gen_random 'a-zA-Z0-9' 64)
{{ end }}

{{if not .Values.global.psql.host -}}
# Postgres password
generate_secret_if_needed {{ template "gitlab.psql.password.secret" . }} --from-literal=postgres-password=$(gen_random 'a-zA-Z0-9' 64)
{{ end }}

# Gitlab shell
generate_secret_if_needed {{ template "gitlab.gitlab-shell.authToken.secret" . }} --from-literal={{ template "gitlab.gitlab-shell.authToken.key" . }}=$(gen_random 'a-zA-Z0-9' 64)

# Gitaly secret
generate_secret_if_needed {{ template "gitlab.gitaly.authToken.secret" . }} --from-literal={{ template "gitlab.gitaly.authToken.key" . }}=$(gen_random 'a-zA-Z0-9' 64)

{{- if .Values.global.minio.enabled -}}
# Minio secret
generate_secret_if_needed {{ template "gitlab.minio.credentials.secret" . }} --from-literal=accesskey=$(gen_random 'a-zA-Z0-9' 64) --from-literal=secretkey=$(gen_random 'a-zA-Z0-9' 64)
{{- end -}}

# Gitlab runner secret
generate_secret_if_needed {{ template "gitlab.gitlab-runner.registrationToken.secret" . }} --from-literal=runner-registration-token=$(gen_random 'a-zA-Z0-9' 64) --from-literal=runner-token=""

# Registry certificates
mkdir -p certs
openssl req -new -newkey rsa:4096 -subj "/CN=gitlab-issuer" -nodes -x509 -keyout certs/registry-example-com.key -out certs/registry-example-com.crt -days 3650
generate_secret_if_needed {{ template "gitlab.registry.certificate.secret" . }} --from-file=registry-auth.key=certs/registry-example-com.key --from-file=registry-auth.crt=certs/registry-example-com.crt

# config/secrets.yaml
if [ -n "$env" ]; then
  secret_key_base=$(gen_random 'a-f0-9' 128) # equavilent to secureRandom.hex(64)
  otp_key_base=$(gen_random 'a-f0-9' 128) # equavilent to secureRandom.hex(64)
  db_key_base=$(gen_random 'a-f0-9' 128) # equavilent to secureRandom.hex(64)
  openid_connect_signing_key=$(openssl genrsa 2048);

  cat << EOF > secrets.yml
$env:
  secret_key_base: $secret_key_base
  otp_key_base: $otp_key_base
  db_key_base: $db_key_base
  openid_connect_signing_key: |
$(openssl genrsa 2048 | awk '{print "    " $0}')
EOF
  generate_secret_if_needed {{ template "gitlab.rails-secrets.secret" . }} --from-file secrets.yml
fi

# Shell ssh host keys
ssh-keygen -A
mkdir -p host_keys
cp /etc/ssh/ssh_host_* host_keys/
generate_secret_if_needed {{ template "gitlab.gitlab-shell.hostKeys.secret" . }} --from-file host_keys

# Gitlab-workhorse secret
generate_secret_if_needed {{ template "gitlab.workhorse.secret" . }} --from-literal={{ template "gitlab.workhorse.key" . }}=$(gen_random 'a-zA-Z0-9' 32 | base64)

# Registry http.secret secret
generate_secret_if_needed {{ template "gitlab.registry.httpSecret.secret" . }} --from-literal={{ template "gitlab.registry.httpSecret.key" . }}=$(gen_random 'a-z0-9' 128 | base64)
