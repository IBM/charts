if [[ -f /opt/ibm/datapower/init/admin-user-secret/password-hashed ]] ; then
  ADMIN_USER_PASSWORD_HASHED="$(cat /opt/ibm/datapower/init/admin-user-secret/password-hashed)"
else
  ADMIN_USER_PASSWORD="$(cat /opt/ibm/datapower/init/admin-user-secret/password)"
  ADMIN_USER_METHOD="$([[ -f /opt/ibm/datapower/init/admin-user-secret/method ]] && cat /opt/ibm/datapower/init/admin-user-secret/method || echo md5)"
  ADMIN_USER_SALT="$([[ -f /opt/ibm/datapower/init/admin-user-secret/salt ]] && cat /opt/ibm/datapower/init/admin-user-secret/salt || echo 12345678)"
  ADMIN_USER_PASSWORD_HASHED="$(cryptpw --method $ADMIN_USER_METHOD $ADMIN_USER_PASSWORD $ADMIN_USER_SALT)"
fi

if [[ -n "$ADMIN_USER_PASSWORD_HASHED" ]] ; then
cat << EOF >> /opt/ibm/datapower/drouter/config/auto-user.cfg
top; configure terminal;

%if% available "user"

user "admin"
  summary "Administrator"
  password-hashed "$ADMIN_USER_PASSWORD_HASHED"
  access-level privileged
  suppress-password-change on
exit

%endif%
EOF
else
  echo "No admin password provided!"
fi
