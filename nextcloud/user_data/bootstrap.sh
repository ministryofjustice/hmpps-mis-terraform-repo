#!/usr/bin/env bash

set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
yum install -y python-pip git wget unzip
systemctl stop httpd smb

cat << EOF >> /etc/environment
HMPPS_ROLE=${app_name}
HMPPS_FQDN=${app_name}.${private_domain}
HMPPS_STACKNAME=${env_identifier}
HMPPS_STACK="${short_env_identifier}"
HMPPS_ENVIRONMENT=${environment_name}
HMPPS_ACCOUNT_ID="${account_id}"
HMPPS_DOMAIN="${private_domain}"
NEXT_CLOUD_DIR="/var/www/html/nextcloud"
DATA_DIR="/var/nextcloud/data"
WEB_USER="apache"
OCC_CMD="/var/www/html/nextcloud/occ"
WEB_USER_HOME="/usr/share/httpd"
NEXTCLOUD_CONF=nextcloud-conf.json
LDAP_HOST="${ldap_elb_name}"
REDIS_HOST="${redis_address}"
LDAP_USER="${ldap_bind_user}"
WHITELISTA="${cidr_block_a_subnet}"
WHITELISTB="${cidr_block_b_subnet}"
WHITELISTC="${cidr_block_c_subnet}"
NEXTCLOUD_SSM_PATH="/$HMPPS_ENVIRONMENT/delius/$HMPPS_ROLE/$HMPPS_ROLE"
nextcloud_passwordsalt=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud_passwordsalt --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
nextcloud_secret=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud_secret --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
nextcloud_dbuser=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud_dbuser --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
nextcloud_dbpassword=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud_dbpassword --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
nextcloud_s01ldap_agent_password=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud_s01ldap_agent_password --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
nextcloud_instance_id=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud-id --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
EFS_DNS_NAME="${efs_dns_name}"
EXTERNAL_DOMAIN="${external_domain}"
REPORTS_PASS_NAME="${reports_pass_name}"
REPORT_USER=$(aws ssm get-parameters --names $HMPPS_STACKNAME-reports-admin-user --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
REPORT_USER_PASSWD="$(aws ssm get-parameters --with-decryption --names $REPORTS_PASS_NAME --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')"
NEXTCLOUD_ADMIN="${nextcloud_admin_user}"


INT_ZONE_ID="${private_zone_id}"
LDAP_PORT="${ldap_port}"
NEXTCLOUD_ADMIN_PASS_PARAM="${nextcloud_admin_pass_param}"
NEXTCLOUD_DB_USER="${nextcloud_db_user}"
DB_PASS_PARAM="${nextcloud_db_user_pass_param}"
DB_DNS_NAME="${db_dns_name}"
LDAP_BIND_PASS_PARAM="${ldap_bind_param}"
BACKUP_BUCKET="${backup_bucket}"
INSTALLER_USER="${installer_user}"
CONFIG_PASSW="${config_passw}"
SAMBA_USER="${mis_user}"
MIS_USER_PASS_NAME="${mis_user_pass_name}"




EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="${app_name}.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT=${environment_name}
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export NEXT_CLOUD_DIR="/var/www/html/nextcloud"
export DATA_DIR="/var/nextcloud/data"
export WEB_USER="apache"
export OCC_CMD="/var/www/html/nextcloud/occ"
export WEB_USER_HOME="/usr/share/httpd"
export NEXTCLOUD_CONF=nextcloud-conf.json
export LDAP_HOST="${ldap_elb_name}"
export REDIS_HOST="${redis_address}"
export LDAP_USER="${ldap_bind_user}"
export WHITELISTA="${cidr_block_a_subnet}"
export WHITELISTB="${cidr_block_b_subnet}"
export WHITELISTC="${cidr_block_c_subnet}"
export NEXTCLOUD_SSM_PATH="/$HMPPS_ENVIRONMENT/delius/$HMPPS_ROLE/$HMPPS_ROLE"
export nextcloud_passwordsalt=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud_passwordsalt --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
export nextcloud_secret=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud_secret --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
export nextcloud_dbuser=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud_dbuser --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
export nextcloud_dbpassword=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud_dbpassword --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
export nextcloud_s01ldap_agent_password=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud_s01ldap_agent_password --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
export nextcloud_instance_id=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_SSM_PATH/nextcloud-id --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
export EFS_DNS_NAME="${efs_dns_name}"
export EXTERNAL_DOMAIN="${external_domain}"
export REPORTS_PASS_NAME="${reports_pass_name}"
export REPORT_USER=$(aws ssm get-parameters --names $HMPPS_STACKNAME-reports-admin-user --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
export REPORT_USER_PASSWD="$(aws ssm get-parameters --with-decryption --names $REPORTS_PASS_NAME --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')"
export NEXTCLOUD_ADMIN="${nextcloud_admin_user}"

export INT_ZONE_ID="${private_zone_id}"
export LDAP_PORT="${ldap_port}"
export NEXTCLOUD_ADMIN_PASS_PARAM="${nextcloud_admin_pass_param}"
export NEXTCLOUD_DB_USER="${nextcloud_db_user}"
export DB_PASS_PARAM="${nextcloud_db_user_pass_param}"
export DB_DNS_NAME="${db_dns_name}"
export LDAP_BIND_PASS_PARAM="${ldap_bind_param}"
export BACKUP_BUCKET="${backup_bucket}"
export INSTALLER_USER="${installer_user}"
export CONFIG_PASSW="${config_passw}"
export SAMBA_USER="${mis_user}"
export MIS_USER_PASS_NAME="${mis_user_pass_name}"


#Mount EFS
echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).$EFS_DNS_NAME:/    $DATA_DIR  nfs4    defaults" >> /etc/fstab
mount -a

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
- name: nextcloud
  src: https://github.com/ministryofjustice/hmpps-nextcloud-installer
  version: ALS_307_nextcloud_ansible
EOF

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml -O users.yml
##IMPORT CONFIG

cat << EOF > ~/vars.yml
remote_user_filename: "${bastion_inventory}"
external_domain: $EXTERNAL_DOMAIN
internal_domain: $HMPPS_DOMAIN
nextcloud_dir: $NEXT_CLOUD_DIR
data_dir: $DATA_DIR/
nextcloud_admin: $NEXTCLOUD_ADMIN
app_name: $HMPPS_ROLE
ldap_host: $LDAP_HOST
redis_host: $REDIS_HOST
redis_port: "6379"
standard_user_base: "ou=Users,dc=moj,dc=com"
fileshare_user_base: "ou=Fileshare,ou=Users,dc=moj,dc=com"
fileshare_base_groups: "ou=Fileshare,ou=Groups,dc=moj,dc=com"
fs_group_prefix: "RES-FS"
ldap_user: $LDAP_USER
whitelist_1: $WHITELISTA
whitelist_2: $WHITELISTB
whitelist_3: $WHITELISTC
nextcloud_passwordsalt: $nextcloud_passwordsalt
nextcloud_secret: $nextcloud_secret
nextcloud_dbuser: $nextcloud_dbuser
nextcloud_dbpassword: $nextcloud_dbpassword
nextcloud_s01ldap_agent_password: $nextcloud_s01ldap_agent_password
web_user: $WEB_USER
NEXTCLOUD_CONF: $NEXTCLOUD_CONF
instance_id: $nextcloud_instance_id
samba_group: "smbgrp"
samba_group_gid: "10667"
web_group: "apache"
report_user: $REPORT_USER
nc_conf_destination: "/etc/httpd/conf.d/nextcloud.conf"
config_sh_script: "/root/import-config.sh"
share_files_root: "files/shared_files"
EOF

cat << EOF > ~/bootstrap.yml
---
- hosts: localhost
  vars_files:
   - "~/vars.yml"
   - "~/users.yml"
  roles:
     - bootstrap
     - rsyslog
     - users
     - nextcloud
EOF

ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/bootstrap.yml

systemctl start httpd smb
