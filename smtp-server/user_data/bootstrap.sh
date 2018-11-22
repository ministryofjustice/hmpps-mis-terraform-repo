#!/usr/bin/env bash

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
     - rsyslog
     - elasticbeats
     - users

EOF

ansible-galaxy install -r ~/requirements.txt
SELF_REGISTER=true ansible-playbook ~/bootstrap.yml

mkdir -p /srv/service-postix

cat << EOF > /etc/service-postfix/docker-compose.yml

version: '3'
services:
  smtp:
    image: namshi/smtp
    container_name: smtp_server
    restart: always
    ports:
     - "25:25"
    environment:
     #  # MUST start with : e.g RELAY_NETWORKS: :192.168.0.0/24:10.0.0.0/16
     #  # if acting as a relay this or RELAY_DOMAINS must be filled out or incoming mail will be rejected
     #  RELAY_NETWORKS: :192.168.0.0/24
     #  # what domains should be accepted to forward to lower distance MX server.
     #  RELAY_DOMAINS: <domain1> : <domain2> : <domain3>
     #  # To act as a Gmail relay
     #  GMAIL_USER:
     #  GMAIL_PASSWORD:
     #  # For use with Amazon SES relay
     #  SES_USER:
     #  SES_PASSWORD:
     #  SES_REGION:
     #  # if provided will enable TLS support
     #  KEY_PATH:
     #  CERTIFICATE_PATH:
     #  # the outgoing mail hostname
       MAILNAME: ${mail_hostname}
     #  # set this to any value to disable ipv6
     #  DISABLE_IPV6:
     # # Generic SMTP Relay
     # SMARTHOST_ADDRESS:
     # SMARTHOST_PORT:
     # SMARTHOST_USER:
     # SMARTHOST_PASSWORD:
     # SMARTHOST_ALIASES:

EOF

docker-compose up -f /srv/service-postix/docker-compose.yml -d
