#!/usr/bin/env bash

yum install -y python-pip git wget

cat << EOF >> /etc/environment
HMPPS_ROLE=${app_name}
HMPPS_FQDN=${app_name}.${private_domain}
HMPPS_STACKNAME=${env_identifier}
HMPPS_STACK="${short_env_identifier}"
HMPPS_ENVIRONMENT=${route53_sub_domain}
HMPPS_ACCOUNT_ID="${account_id}"
HMPPS_DOMAIN="${private_domain}"
EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="${app_name}.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT=${route53_sub_domain}
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"

cd ~
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

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${environment}.yml -O users.yml

cat << EOF > ~/bootstrap.yml
---

- hosts: localhost
  vars_files:
   - "{{ playbook_dir }}/users.yml"
  roles:
     - bootstrap
     - rsyslog
     - elasticbeats
     - users

EOF

# ansible-galaxy install -f -r ~/requirements.yml
# ansible-playbook ~/bootstrap.yml -e monitoring_host="monitoring.${private_domain}"

# IPA Server

hostnamectl set-hostname ${hostname}

yum install ipa-server -y 

# certs
mkdir -p /root/ipa-certs
aws --region eu-west-2 ssm get-parameter --with-decryption --name  ${common_name}-self-signed-ca-crt --query Parameter.Value > /root/ipa-certs/ca.crt

chmod 600 /root/ipa-certs

# sysctl for ipv6
sysctl net.ipv6.conf.all.disable_ipv6=0
sysctl net.ipv6.conf.lo.disable_ipv6=0

# Edit hosts file
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

$(hostname -i | cut -d ' ' -f2) $(hostname)
" > /etc/hosts

echo "net.ipv6.conf.eth0.disable_ipv6=1" > /etc/sysctl.d/ipa-sysctl.conf

