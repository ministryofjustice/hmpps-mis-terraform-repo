#!/usr/bin/env bash

yum install -y git wget python-pip
pip install -U pip
pip install ansible

cat << EOF >> /etc/environment
HMPPS_ROLE=${app_name}
HMPPS_FQDN="`curl http://169.254.169.254/latest/meta-data/instance-id`.${internal_domain}"
HMPPS_STACKNAME=${env_identifier}
HMPPS_STACK="${short_env_identifier}"
HMPPS_ENVIRONMENT=${route53_sub_domain}
HMPPS_ACCOUNT_ID="${account_id}"
HMPPS_DOMAIN="${internal_domain}"
EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="`curl http://169.254.169.254/latest/meta-data/instance-id`.${internal_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT=${route53_sub_domain}
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${internal_domain}"

cat << EOF > ~/requirements.yml
---

- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: centos
- name: users
  src: singleplatform-eng.users

EOF

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml -O ~/users.yml

cat << EOF > ~/bootstrap.yml
---

- hosts: localhost
  vars_files:
    - "{{ playbook_dir }}/users.yml"
  roles:
    - bootstrap
    - users
EOF

ansible-galaxy install -f -r ~/requirements.yml
SELF_REGISTER=true ansible-playbook ~/bootstrap.yml

# Install awslogs and the jq JSON parser
current_dir=$(pwd)
region=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

mkdir -p /tmp/awslogs-install
cd /tmp/awslogs-install
curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O

mkdir -p /var/log/${container_name}

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

# Set the region to send CloudWatch Logs data to (the region where the container instance is located)
region=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

# log into AWS ECR
aws ecr get-login --no-include-email --region $region

systemctl daemon-reload
systemctl enable awslogs
systemctl start awslogs
# end script

cd $current_dir

rm -rf /tmp/awslogs-install

cp /usr/share/zoneinfo/Europe/London /etc/localtime

mkdir -p ${keys_dir}

# GET SECRETS FROM PARAMETER STORE
${ssm_get_command} "${self_signed_ca_cert}" \
    | jq -r '.Parameters[0].Value' > ${keys_dir}/ca.crt

${ssm_get_command} "${self_signed_key}" \
    --with-decryption | jq -r '.Parameters[0].Value' > ${keys_dir}/server.key

${ssm_get_command} "${self_signed_cert}" \
    --with-decryption | jq -r '.Parameters[0].Value' > ${keys_dir}/server.crt

cat ${keys_dir}/ca.crt >> ${keys_dir}/server.crt

chmod 600 ${keys_dir}

chmod 400 ${keys_dir}/server.key

chmod 600 ${keys_dir}/*crt

# httpd setup

yum install -y httpd mod_ssl

# SSL VHOST
echo '<VirtualHost *:80>
   ServerName ${application_endpoint}.${external_domain}
   Redirect / https://${application_endpoint}.${external_domain}
</VirtualHost>

Listen 443 https

SSLPassPhraseDialog exec:/usr/libexec/httpd-ssl-pass-dialog
SSLSessionCache         shmcb:/run/httpd/sslcache(512000)
SSLSessionCacheTimeout  300
SSLRandomSeed startup file:/dev/urandom  256
SSLRandomSeed connect builtin
SSLCryptoDevice builtin

<VirtualHost _default_:443>
ErrorLog logs/ssl_error_log
TransferLog logs/ssl_access_log
LogLevel warn
SSLEngine on
SSLProtocol all -SSLv2 -SSLv3
SSLCipherSuite HIGH:3DES:!aNULL:!MD5:!SEED:!IDEA
SSLCertificateFile /etc/pki/tls/certs/localhost.crt
SSLCertificateKeyFile /etc/pki/tls/private/localhost.key
SSLProxyEngine on
ProxyPass / https://ldap-primary.${internal_domain}/
ProxyPassReverse / https://ldap-primary.${internal_domain}/
ProxyPassReverseCookieDomain ldap-primary.${internal_domain} ${application_endpoint}.${external_domain}
RequestHeader edit Referer ^https://${application_endpoint}.${external_domain}/  https://ldap-primary.${internal_domain}/

<Files ~ "\.(cgi|shtml|phtml|php3?)$">
    SSLOptions +StdEnvVars
</Files>
<Directory "/var/www/cgi-bin">
    SSLOptions +StdEnvVars
</Directory>
BrowserMatch "MSIE [2-5]" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0
</VirtualHost>' > /etc/httpd/conf.d/ssl.conf

echo '#' > /etc/httpd/conf.d/welcome.conf

systemctl enable httpd

systemctl restart httpd