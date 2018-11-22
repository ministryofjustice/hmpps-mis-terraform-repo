#!/usr/bin/env bash

set +x

yum install -y python-pip git wget

cat << EOF >> /etc/environment
HMPPS_ROLE=${app_name}
HMPPS_FQDN=${app_name}.${private_domain}
HMPPS_STACKNAME=${env_identifier}
HMPPS_STACK="${short_env_identifier}"
HMPPS_ACCOUNT_ID="${account_id}"
HMPPS_DOMAIN="${private_domain}"
EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="${app_name}.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"

pip install --upgrade pip
pip install ansible

cat << EOF > ~/requirements.yml
- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: centos
- name: rsyslog
  src: https://github.com/ministryofjustice/hmpps-rsyslog-role
- name: elasticbeats
  src: https://github.com/ministryofjustice/hmpps-beats-monitoring
- name: users
  src: singleplatform-eng.users
EOF

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml -O ~/users.yml

cat << EOF > ~/bootstrap.yml
---

- hosts: localhost
  vars_files:
    - "~/users.yml"
  roles:
     - bootstrap
     - users

EOF

ansible-galaxy install -r ~/requirements.yml
SELF_REGISTER=true ansible-playbook ~/bootstrap.yml

mkdir -p /srv/service-postfix

cat << EOF > /srv/service-postfix/docker-compose.yml

version: '3'
services:
  smtp:
    image: namshi/smtp
    container_name: smtp_server
    restart: always
    ports:
     - "25:25"
    environment:
       MAILNAME: ${mail_hostname}

EOF

docker-compose up -f /srv/service-postfix/docker-compose.yml -d
