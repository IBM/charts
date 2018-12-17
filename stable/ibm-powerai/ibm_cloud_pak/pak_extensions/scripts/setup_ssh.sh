#!/bin/bash
KEY_MOUNT=/powerai/sshkeys

if [[ "$INFINIBAND" == "1" ]]; then
  echo -e "* soft memlock unlimited\n* hard memlock unlimited\nroot soft memlock unlimited\nroot hard memlock unlimited" >> /etc/security/limits.conf
fi

if [[ -f ${KEY_MOUNT}/id_rsa ]] && [[ ! -f ${HOME}/.ssh/id_rsa ]] ; then
  # Set up ssh
  mkdir -p ${HOME}/.ssh
  cp ${KEY_MOUNT}/id_rsa ${HOME}/.ssh
  chmod 400 ${HOME}/.ssh/id_rsa
  cp ${KEY_MOUNT}/id_rsa.pub ${HOME}/.ssh
  cp ${KEY_MOUNT}/id_rsa.pub ${HOME}/.ssh/authorized_keys
  cat << EOS > ${HOME}/.ssh/config
StrictHostKeyChecking no
UserKnownHostsFile=/dev/null
Port $SSH_PORT
EOS
  if grep -q "^Port " /etc/ssh/sshd_config; then
    sed -i "s/^Port .*/Port $SSH_PORT/g" /etc/ssh/sshd_config
  else
    echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
  fi
  curr_user=${SUDO_USER}
  [ -z $curr_user ] && curr_user=${USER}
  chown -R ${curr_user} ${HOME}/.ssh
fi
# Start sshd in daemon mode
mkdir -p /var/run/sshd
/usr/sbin/sshd

host=$(hostname)
if [ ${host: -2} = "-0" ]; then
  # Wait for all other workers
  while IFS= read -r host; do
    for n in {1..60}; do
      ssh -o ConnectTimeout=3 -n -q $host exit
      [ $? -eq 0 ] && break
      echo "Retrying ssh connection for host $host..."
      sleep 1
    done
  done < "/powerai/config/hostfile"
fi
