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
  src: https://github.com/singleplatform-eng/ansible-users
EOF

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml -O users.yml

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

ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/bootstrap.yml -e monitoring_host="monitoring.${private_domain}"

# enable ipv6
sed -i '/net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf

# sysctl for ipv6
sysctl net.ipv6.conf.all.disable_ipv6=0
sysctl net.ipv6.conf.lo.disable_ipv6=0
sysctl net.ipv6.conf.eth0.disable_ipv6=1

echo "net.ipv6.conf.eth0.disable_ipv6=1
sysctl net.ipv6.conf.all.disable_ipv6=0
sysctl net.ipv6.conf.lo.disable_ipv6=0" > /etc/sysctl.d/ipa-sysctl.conf

# DNS
# Edit hosts file
echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

$(hostname -i | cut -d ' ' -f2) ${hostname}
" > /etc/hosts

hostnamectl set-hostname ${hostname}

# Install awslogs and the jq JSON parser
current_dir=$(pwd)
region=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

mkdir -p /tmp/awslogs-install
cd /tmp/awslogs-install
curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O

# Inject the CloudWatch Logs configuration file contents
cat > awslogs.conf <<- EOF
[general]
state_file = /var/awslogs/state/agent-state

[/var/log/messages]
datetime_format = %b %d %H:%M:%S
file = /var/log/messages
buffer_duration = 5000
log_stream_name = {instance_id}/messages
initial_position = start_of_file
log_group_name = ${log_group_name}

[/var/log/audit/audit.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/audit/audit.log
buffer_duration = 5000
log_stream_name = {instance_id}/audit
initial_position = start_of_file
log_group_name = ${log_group_name}

[/var/log/secure]
datetime_format = %b %d %H:%M:%S
file = /var/log/secure
buffer_duration = 5000
log_stream_name = {instance_id}/secure
initial_position = start_of_file
log_group_name = ${log_group_name}

[/var/log/cloud-init.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/cloud-init.log
buffer_duration = 5000
log_stream_name = {instance_id}/cloud-init.log
initial_position = start_of_file
log_group_name = ${log_group_name}

EOF

python ./awslogs-agent-setup.py --region $region --non-interactive --configfile=awslogs.conf

systemctl daemon-reload
systemctl enable awslogs
systemctl start awslogs
# end script

cd $current_dir

rm -rf /tmp/awslogs-install

# cloudwatch complete

# IPA Server

yum install ipa-server -y

# certs
mkdir -p /root/ipa-certs
aws --region eu-west-2 ssm get-parameter --with-decryption --name ${common_name}-ldap-self-signed-ca-key | jq -r '.Parameter.Value' > /root/ipa-certs/ca.key
aws --region eu-west-2 ssm get-parameter --with-decryption --name  ${common_name}-ldap-self-signed-ca-crt | jq -r '.Parameter.Value' > /root/ipa-certs/ca.crt

chmod 600 /root/ipa-certs
chmod 400 /root/ipa-certs/ca.key

export ds_password=$(aws --region eu-west-2 ssm get-parameter --with-decryption --name ${common_name}-ldap-manager-password | jq -r '.Parameter.Value')
export admin_password=$(aws --region eu-west-2 ssm get-parameter --with-decryption --name ${common_name}-ldap-admin-password | jq -r '.Parameter.Value')
export realm=$(echo ${private_domain} | tr '[:lower:]' '[:upper:]')

# install ldap
ipa-server-install --unattended \
    --external-ca \
    --external-ca-type generic \
    --ds-password $ds_password \
    --admin-password $admin_password \
    --realm $realm \
    --no-host-dns \
    --ip-address=$(hostname -i | cut -d ' ' -f2) \
    --log-file /root/bootstrap-ipa-install.log

#The next step is to get /root/ipa.csr signed by your CA and re-run /sbin/ipa-server-install as:
#/sbin/ipa-server-install --external-cert-file=/path/to/signed_certificate --external-cert-file=/path/to/external_ca_certificate

mkdir /root/ca
cd /root/ca
mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

echo '# OpenSSL root CA configuration file.
# Copy to `/root/ca/openssl.cnf`.

[ ca ]
# `man ca`
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = /root/ca
certs             = $dir/certs
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
RANDFILE          = $dir/private/.rand

# The root key and root certificate.
private_key       = /root/ipa-certs/ca.key
certificate       = /root/ipa-certs/ca.crt

# For certificate revocation lists.
crlnumber         = $dir/crlnumber
crl               = $dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of `man ca`.
countryName             = optional
stateOrProvinceName     = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
# See the POLICY FORMAT section of the `ca` man page.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
# Options for the `req` tool (`man req`).
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ v3_ca ]
# Extensions for a typical CA (`man x509v3_config`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA (`man x509v3_config`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign' > openssl.cnf

# sign ca file
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in /root/ipa.csr -out /root/ipa.crt -batch

cp newcerts/*.pem /root/ipa.crt
cd /root

# load cert
/sbin/ipa-server-install --external-cert-file=/root/ipa.crt --external-cert-file=/root/ipa-certs/ca.crt \
    --unattended -p $ds_password -a $admin_password -r $realm --log-file /root/postca-ipa-install.log

# backup node and upload to s3 bucket
ipa-backup

mkdir /tmp/backups/

tar cvf /tmp/backups/ipa-backup-$(hostname)-$(date +%Y-%m-%d).tar \
    /root/*.p12 \
    /root/*-ipa-install.log \
    /root/ipa* \
    /root/ca \
    /var/lib/ipa/backup \
    /etc/ipa

aws s3 sync /tmp/backups s3://${s3bucket}/backups/

rm -rf /tmp/backups/* /root/ca