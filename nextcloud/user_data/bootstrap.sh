#!/usr/bin/env bash

set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
yum install -y python-pip git wget unzip
systemctl stop httpd smb

HMPPS_ENVIRONMENT=${environment_name}
HMPPS_ROLE=${app_name}
NEXTCLOUD_SSM_PATH="/$HMPPS_ENVIRONMENT/delius/$HMPPS_ROLE/$HMPPS_ROLE"
SMTP_FQDN=smtp.${private_domain}
EXTERNAL_DOMAIN="${external_domain}"

cat << EOF >> /etc/environment
HMPPS_ROLE=${app_name}
MIS_APP_NAME="${mis_app_name}"
SMTP_FQDN="smtp.${private_domain}"
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
NEXTCLOUD_SSM_PATH="/$HMPPS_ENVIRONMENT/delius/$HMPPS_ROLE/$HMPPS_ROLE"
EFS_DNS_NAME="${efs_dns_name}"
EXTERNAL_DOMAIN="${external_domain}"
REPORTS_PASS_NAME="${reports_pass_name}"
NEXTCLOUD_ADMIN="${nextcloud_admin_user}"
NEXTCLOUD_DB_USER="${nextcloud_db_user}"
DB_PASS_PARAM="${nextcloud_db_user_pass_param}"
INSTALLER_USER="${installer_user}"
CONFIG_PASSW="${config_passw}"
DB_DNS_NAME="${db_dns_name}"
NEXTCLOUD_ADMIN_PASS_PARAM="${nextcloud_admin_pass_param}"
LDAP_BIND_PASS_PARAM="${ldap_bind_param}"
LDAP_PORT="${ldap_port}"
PWM_URL="${pwm_url}"
STRATEGIC_PWM_URL="${strategic_pwm_url}"
ENV_TYPE="${environment_type}"
region="${region}"
MIS_USER_PASS_NAME="${mis_user_pass_name}"
BOSSO_SVC_PASSNAME="${bosso_svc_passname}"
CIDR_BLOCK_A="${cidr_block_a_subnet}"
CIDR_BLOCK_B="${cidr_block_b_subnet}"
CIDR_BLOCK_C="${cidr_block_c_subnet}"
WMT_PROD_BUCKET="${wmt_bucket_name_prod}"
WMT_PRE_PROD_BUCKET="${wmt_bucket_name_pre_prod}"
EOF

## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export MIS_APP_NAME="${mis_app_name}"
export SMTP_FQDN="smtp.${private_domain}"
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
export NEXTCLOUD_SSM_PATH="/$HMPPS_ENVIRONMENT/delius/$HMPPS_ROLE/$HMPPS_ROLE"
export EFS_DNS_NAME="${efs_dns_name}"
export EXTERNAL_DOMAIN="${external_domain}"
export REPORTS_PASS_NAME="${reports_pass_name}"
export NEXTCLOUD_ADMIN="${nextcloud_admin_user}"
export DB_DNS_NAME="${db_dns_name}"
export DB_PASS_PARAM="${nextcloud_db_user_pass_param}"
export INSTALLER_USER="${installer_user}"
export CONFIG_PASSW="${config_passw}"
export NEXTCLOUD_DB_USER="${nextcloud_db_user}"
export NEXTCLOUD_ADMIN_PASS_PARAM="${nextcloud_admin_pass_param}"
export LDAP_BIND_PASS_PARAM="${ldap_bind_param}"
export LDAP_PORT="${ldap_port}"
export PWM_URL="${pwm_url}"
export STRATEGIC_PWM_URL="${strategic_pwm_url}"
export ENV_TYPE="${environment_type}"
export region="${region}"
export MIS_USER_PASS_NAME="${mis_user_pass_name}"
export BOSSO_SVC_PASSNAME="${bosso_svc_passname}"
export CIDR_BLOCK_A="${cidr_block_a_subnet}"
export CIDR_BLOCK_B="${cidr_block_b_subnet}"
export CIDR_BLOCK_C="${cidr_block_c_subnet}"
export WMT_PROD_BUCKET="${wmt_bucket_name_prod}"
export WMT_PRE_PROD_BUCKET="${wmt_bucket_name_pre_prod}"

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
  src: https://github.com/singleplatform-eng/ansible-users
- name: nextcloud
  src: https://github.com/ministryofjustice/hmpps-nextcloud-installer
  version: 1.6.0
EOF

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml -O users.yml
##IMPORT CONFIG
cat << EOF > ~/vars.yml
remote_user_filename: "${bastion_inventory}"
internal_domain: $HMPPS_DOMAIN
nextcloud_dir: $NEXT_CLOUD_DIR
data_dir: $DATA_DIR/
nextcloud_admin: $NEXTCLOUD_ADMIN
nextcloud_user_param: $NEXTCLOUD_ADMIN_PASS_PARAM
app_name: $HMPPS_ROLE
ldap_host: $LDAP_HOST
redis_host: $REDIS_HOST
redis_port: "6379"
standard_user_base: "ou=Users,dc=moj,dc=com"
fileshare_user_base: "ou=Fileshare,ou=Users,dc=moj,dc=com"
fileshare_base_groups: "ou=Fileshare,ou=Groups,dc=moj,dc=com"
fs_group_prefix: "RES-FS"
ldap_user: $LDAP_USER
web_user: $WEB_USER
NEXTCLOUD_CONF: $NEXTCLOUD_CONF
samba_group: "smbgrp"
samba_group_gid: "10667"
web_group: "apache"
nc_conf_destination: "/etc/httpd/conf.d/nextcloud.conf"
config_sh_script: "/root/import-config.sh"
share_files_root: "files/shared_files"
reports_pass_name: $REPORTS_PASS_NAME
samba_pass_sh_script: "/root/samba-pass.sh"
dfree_value: "8000000000 8000000000"
dfree_destination: "/etc/samba/samba-dfree"
smb_conf_file: "/etc/samba/smb.conf"
passdb_backend: "tdbsam"
import_config_file: "/usr/share/httpd/nextcloud-conf.json"
config_passw: $CONFIG_PASSW
backup_sh_script: "/root/backup.sh"
fileowner_sh_script: "/root/file-owner.sh"
OCS_API: "ocs/v2.php/apps/files_sharing/api/v1"
local_url: "http://localhost"
shares_script: "/root/configure-shares.sh"
input_file: "/root/input_file"
ocs_share_root: "/shared_files"
nextcloud_ssm_path: $NEXTCLOUD_SSM_PATH
installer_user: $INSTALLER_USER
db_dns_name: $DB_DNS_NAME
nextcloud_rds_db_user: $NEXTCLOUD_DB_USER
nextcloud_rds_db_param: $DB_PASS_PARAM
ldap_port: $LDAP_PORT
ldap_bind_param: $LDAP_BIND_PASS_PARAM
base_install_script: /root/base-install.sh
key_id: "alias/aws/ssm"
hmpps_stack_name: $HMPPS_STACKNAME
pwm_url: $PWM_URL
strategic_pwm_url: $STRATEGIC_PWM_URL
httpd_conf_file: "/etc/httpd/conf/httpd.conf"
cw_installer: "/root/awslogs-agent-setup.py"
cw_conf_template: "/root/cw_conf_template"
env_type: $ENV_TYPE
external_domain: $EXTERNAL_DOMAIN
mail_server: $SMTP_FQDN
from_address: "no-reply.$HMPPS_ROLE"
region: $region
mis_user_pass_name: $MIS_USER_PASS_NAME
bosso_svc_passname: $BOSSO_SVC_PASSNAME
mis_app_name: $MIS_APP_NAME
hmpps_environment: $HMPPS_ENVIRONMENT
globignore: "CRC:nart:National:NPS"
cidr_block_a: $CIDR_BLOCK_A
cidr_block_b: $CIDR_BLOCK_B
cidr_block_c: $CIDR_BLOCK_C
wmt_prod_bucket: $WMT_PROD_BUCKET
wmt_pre_prod_bucket: $WMT_PRE_PROD_BUCKET
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
