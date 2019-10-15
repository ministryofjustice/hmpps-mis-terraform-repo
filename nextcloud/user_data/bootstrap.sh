#!/usr/bin/env bash

set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

yum install -y python-pip git wget unzip

cat << EOF >> /etc/environment
HMPPS_ROLE=${app_name}
HMPPS_FQDN=${app_name}.${private_domain}
HMPPS_STACKNAME=${env_identifier}
HMPPS_STACK="${short_env_identifier}"
HMPPS_ENVIRONMENT=${environment_name}
HMPPS_ACCOUNT_ID="${account_id}"
HMPPS_DOMAIN="${private_domain}"
INT_ZONE_ID="${private_zone_id}"
LDAP_PORT="${ldap_port}"
LDAP_HOST="${ldap_elb_name}"
EXTERNAL_DOMAIN="${external_domain}"
NEXTCLOUD_ADMIN="${nextcloud_admin_user}"
NEXTCLOUD_ADMIN_PASS_PARAM="${nextcloud_admin_pass_param}"
EFS_DNS_NAME="${efs_dns_name}"
NEXTCLOUD_DB_USER="${nextcloud_db_user}"
DB_PASS_PARAM="${nextcloud_db_user_pass_param}"
DB_DNS_NAME="${db_dns_name}"
LDAP_BIND_PASS_PARAM="${ldap_bind_param}"
LDAP_USER="${ldap_bind_user}"
BACKUP_BUCKET="${backup_bucket}"
REDIS_ADDRESS="${redis_address}"
INSTALLER_USER="${installer_user}"
CONFIG_PASSW="${config_passw}"
SAMBA_USER="${mis_user}"
MIS_USER_PASS_NAME="${mis_user_pass_name}"
REPORTS_PASS_NAME="${reports_pass_name}"

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
export INT_ZONE_ID="${private_zone_id}"
export LDAP_PORT="${ldap_port}"
export LDAP_HOST="${ldap_elb_name}"
export EXTERNAL_DOMAIN="${external_domain}"
export NEXTCLOUD_ADMIN="${nextcloud_admin_user}"
export NEXTCLOUD_ADMIN_PASS_PARAM="${nextcloud_admin_pass_param}"
export EFS_DNS_NAME="${efs_dns_name}"
export NEXTCLOUD_DB_USER="${nextcloud_db_user}"
export DB_PASS_PARAM="${nextcloud_db_user_pass_param}"
export DB_DNS_NAME="${db_dns_name}"
export LDAP_BIND_PASS_PARAM="${ldap_bind_param}"
export LDAP_USER="${ldap_bind_user}"
export BACKUP_BUCKET="${backup_bucket}"
export REDIS_ADDRESS="${redis_address}"
export INSTALLER_USER="${installer_user}"
export CONFIG_PASSW="${config_passw}"
export SAMBA_USER="${mis_user}"
export MIS_USER_PASS_NAME="${mis_user_pass_name}"
export REPORTS_PASS_NAME="${reports_pass_name}"


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

wget https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml -O users.yml

cat << EOF > ~/vars.yml
# For user_update cron
remote_user_filename: "${bastion_inventory}"
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
EOF

ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/bootstrap.yml

#vars
web_user="apache"
web_user_home="/usr/share/httpd"
occ_cmd="/var/www/html/nextcloud/occ"
NEXTCLOUD_ADMIN_PASSWORD=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_ADMIN_PASS_PARAM --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
NEXTCLOUD_DB_PASS=$(aws ssm get-parameters --with-decryption --names $DB_PASS_PARAM --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
LDAP_USER_PASS=$(aws ssm get-parameters --with-decryption --names $LDAP_BIND_PASS_PARAM --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
CONFIG_PASS=$(aws ssm get-parameters --with-decryption --names $CONFIG_PASSW --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
DATA_DIR="/var/nextcloud/data"
sudo_cmd="/usr/bin/sudo"
BASE_DN="cn=Users,dc=moj,dc=com"
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | cut -f3 -d"-")
CONFIG_DIR="/var/www/html/nextcloud/config"
PREFIX_DATE=$(date +%F)
CONFIG_EXPORT_FILE="$PREFIX_DATE-nextcloud-config.json.zip"
UNZIPPED_CONF_FILE="$PREFIX_DATE-nextcloud-config.json"
NEXT_CLOUD_DIR="/var/www/html/nextcloud"

#Nextcloud install
yum -y install epel-release yum-utils ;
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm ;
yum -y install unzip ;

#Enable PHP 7.3
yum-config-manager --disable remi-php54 ;
yum-config-manager --enable remi-php73 ;

#install Apache and PHP packages
yum -y install httpd php php-cli php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pdo php-pecl-apcu php-pecl-apcu-devel php-intl php71-php-pecl-imagick php-ldap redis php-pecl-redis zip mariadb ;
systemctl enable httpd ;

#Download and install nextcloud
aws s3 cp s3://$BACKUP_BUCKET/installer/nextcloud-16.0.3.zip .  ;
unzip nextcloud-16.0.3.zip       ;
rm -f *.zip ;

#move nextcloud folder to /var/www/html
mv nextcloud/ /var/www/html/ ;

#Create directory Store
mkdir -p $DATA_DIR ;

#Mount efs
yum -y install nfs-utils ;
echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).$EFS_DNS_NAME:/    $DATA_DIR  nfs4    defaults" >> /etc/fstab ;
mount -a ;
chown -R $web_user:$web_user $NEXT_CLOUD_DIR ;


#Configure Apache VirtualHost
cat << EOF > /etc/httpd/conf.d/nextcloud.conf
<VirtualHost *:80>
  ServerName nextcloud.$EXTERNAL_DOMAIN
  ServerAdmin admin@$EXTERNAL_DOMAIN
  DocumentRoot /var/www/html/nextcloud
  <directory /var/www/html/nextcloud>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    SetEnv HOME /var/www/html/nextcloud
    SetEnv HTTP_HOME /var/www/html/nextcloud
  </directory>
</VirtualHost>
EOF

#Start REDIS
systemctl start redis ;

chown -R $web_user:$web_user $DATA_DIR ;

fresh_next_cloud_install ()
{
#Install and configure nextcloud
echo "commencing -fresh_next_cloud_install"
cd $NEXT_CLOUD_DIR ;
$sudo_cmd -u $web_user php $occ_cmd maintenance:install --database "mysql" \
    --database-host "$DB_DNS_NAME"  \
    --database-name "nextcloud"  --database-user "$NEXTCLOUD_DB_USER" --database-pass "$NEXTCLOUD_DB_PASS" \
        --admin-user "$NEXTCLOUD_ADMIN" --admin-pass "$NEXTCLOUD_ADMIN_PASSWORD"   --data-dir "$DATA_DIR"          ;

$sudo_cmd -u $web_user php $occ_cmd config:system:set trusted_domains 0 --value=nextcloud.$EXTERNAL_DOMAIN         ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set overwritehost --value=nextcloud.$EXTERNAL_DOMAIN             ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set overwriteprotocol --value=https                              ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set overwrite.cli.url --value=https://$EXTERNAL_DOMAIN           ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set filesystem_check_changes --value="1"                         ;

$sudo_cmd -u $web_user php $occ_cmd app:enable twofactor_totp                                                      ; #Enable 2f app
$sudo_cmd -u $web_user php $occ_cmd app:enable user_ldap                                                           ; #Enable Ldap App
$sudo_cmd -u $web_user php $occ_cmd config:app:set files default_quota --value="5 GB"                              ; #Set default disk qouata

#Configure ldap authentication
$sudo_cmd -u $web_user php $occ_cmd ldap:delete-config s01                                                                  ;
$sudo_cmd -u $web_user php $occ_cmd ldap:create-empty-config                                                                ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapHost "$LDAP_HOST"                                               ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapPort "$LDAP_PORT"                                               ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapAgentName "$LDAP_USER"                                          ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapAgentPassword "$LDAP_USER_PASS"                                 ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapBase "ou=Fileshare,ou=Users,dc=moj,dc=com;ou=Users,dc=moj,dc=com"                            ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapUserFilter "(&(|(objectclass=inetOrgPerson)))"                                               ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapLoginFilter "(&(&(|(objectclass=inetOrgPerson)))(|(mailPrimaryAddress=%uid)(mail=%uid)))"    ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapBaseGroups  "ou=Fileshare,ou=Groups,dc=moj,dc=com"                                           ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapBaseUsers  "ou=Users,dc=moj,dc=com"                                             ;

#Configure Redis
$sudo_cmd -u $web_user php $occ_cmd config:system:set memcache.distributed --value="\\OC\\Memcache\\Redis"    ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set memcache.locking --value="\\OC\\Memcache\\Redis"        ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set filelocking.enabled --value="true"                      ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set redis host --value="$REDIS_ADDRESS"                     ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set redis port --value="6379"                               ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set redis timeout --value=1.5                               ;

$sudo_cmd -u $web_user php $occ_cmd config:system:set csrf.disabled --value="true"                            ;
echo "completed -fresh_next_cloud_install"
}

nextcloud_install_from_config ()
{
echo "commencing -nextcloud_install_from_config"
#Generate temp default config.php to allow import of config from s3
#Will be overwritten by config import
temp_data_dir="/var/tmp/nextcloud/data"
mkdir -p $temp_data_dir
chown $web_user:$web_user $temp_data_dir
cd $NEXT_CLOUD_DIR
$sudo_cmd -u $web_user php $occ_cmd maintenance:install --database "sqlite" --admin-user "$INSTALLER_USER" --admin-pass "$INSTALLER_USER" --data-dir "/var/tmp/nextcloud/data"

$sudo_cmd -u $web_user php $occ_cmd app:enable twofactor_totp  #Enable 2f app
$sudo_cmd -u $web_user php $occ_cmd app:enable user_ldap         #Enable Ldap App
echo "completed -nextcloud_install_from_config"
}

pull_config ()
{
echo "commencing -pull_config"
#Pull and import latest config from backup
cd $web_user_home
aws s3 cp s3://$BACKUP_BUCKET/nextcloud_config_backups/$CONFIG_EXPORT_FILE $web_user_home/
unzip -P "$CONFIG_PASS" $CONFIG_EXPORT_FILE
chown $web_user:$web_user $UNZIPPED_CONF_FILE
cd $NEXT_CLOUD_DIR
$sudo_cmd -u $web_user php $occ_cmd config:import $web_user_home/$UNZIPPED_CONF_FILE

#Reset admin user pass in case it is differennt to the one in the db
export OC_PASS="$NEXTCLOUD_ADMIN_PASSWORD"
su -s /bin/sh apache -c "php occ user:resetpassword --password-from-env $NEXTCLOUD_ADMIN"
echo "completed -pull_config"
}

#Install Nextcloud and import config
fresh_next_cloud_install
nextcloud_install_from_config
pull_config

#stop Redis
systemctl stop redis ;

#Configure php memory limit
sed -i 's/memory_limit = 128M/memory_limit = 513M/' /etc/php.ini

#create crontab for config backup
config_backup_script="/root/config_backup_script"

#create cron scripts
cat << 'EOF' > /root/config_backup_script
#!/bin/bash

#Vars
PREFIX_DATE=$(date +%F)
LOG_FILE="/var/log/efs_backup.log"
BACKUP_BUCKET=
CONFIG_EXPORT_FILE="$PREFIX_DATE-nextcloud-config.json"
CONFIG_DIR="/root"
NEXTCLOUD_CONFIGS_DIR="nextcloud_config_backups"
CONFIG_PASSW=
CONFIG_PASS=$(aws ssm get-parameters --with-decryption --names $CONFIG_PASSW --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')

#Create log file
test -f $LOG_FILE || touch $LOG_FILE

#Backup config
echo "Backing up Nextcloud config"
cd /var/www/html/nextcloud
sudo -u apache php occ config:list --private > $CONFIG_DIR/$CONFIG_EXPORT_FILE
cd $CONFIG_DIR
zip --encrypt -P "$CONFIG_PASS" $CONFIG_EXPORT_FILE.zip $CONFIG_EXPORT_FILE
aws s3 cp $CONFIG_EXPORT_FILE.zip s3://$BACKUP_BUCKET/$NEXTCLOUD_CONFIGS_DIR/  && echo "$(date) : Config Backup Success" >> $LOG_FILE || echo "$(date) : Config Backup Failure" >> $LOG_FILE
rm -f $CONFIG_DIR/$CONFIG_EXPORT_FILE $CONFIG_DIR/$CONFIG_EXPORT_FILE.zip
EOF

#Add s3 bucket_name
grep -q "BACKUP_BUCKET=$BACKUP_BUCKET" $config_backup_script || sed -i "s/BACKUP_BUCKET=/BACKUP_BUCKET=$BACKUP_BUCKET/" $config_backup_script
grep -q "CONFIG_PASSW=$CONFIG_PASSW"   $config_backup_script || sed -i "s/CONFIG_PASSW=/CONFIG_PASSW=$CONFIG_PASSW/"    $config_backup_script
chmod +x $config_backup_script

#Place cron job to backup config
temp_cron_file="/tmp/temp_cron_file" ;
crontab -l > $temp_cron_file ;
grep -q "$config_backup_script" $temp_cron_file || echo "00 01 * * * /usr/bin/sh $config_backup_script > /dev/null 2>&1" >> $temp_cron_file && crontab $temp_cron_file
rm -f $temp_cron_file

##Samba share
SAMBA_USER_PASS=$(aws ssm get-parameters --with-decryption --names $MIS_USER_PASS_NAME --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
REPORT_USER=$(aws ssm get-parameters --names $HMPPS_STACKNAME-reports-admin-user --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
REPORT_USER_PASSWD="$(aws ssm get-parameters --with-decryption --names $REPORTS_PASS_NAME --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')"
SAMBA_DIR="$DATA_DIR/$NEXTCLOUD_ADMIN/files/shared_files"

yum install samba samba-client samba-common -y ;
groupadd smbgrp ;
useradd $SAMBA_USER ;
useradd $REPORT_USER ;
usermod -a -G smbgrp $SAMBA_USER ;
usermod -a -G apache $SAMBA_USER ;
usermod -a -G smbgrp $web_user ;
usermod -a -G apache $web_user ;
usermod -a -G smbgrp $REPORT_USER ;
usermod -a -G apache $REPORT_USER ;

#configure samba pass
echo -ne "$SAMBA_USER_PASS\n$SAMBA_USER_PASS\n" | smbpasswd -a -s $SAMBA_USER ;
echo -ne "$REPORT_USER_PASSWD\n$REPORT_USER_PASSWD\n" | smbpasswd -a -s $REPORT_USER ;

chmod -R 0770  $SAMBA_DIR ;

cat << EOF > /etc/samba/samba-dfree
#!/bin/bash
echo "8000000000 8000000000"
EOF

chmod +x /etc/samba/samba-dfree

###Configure samba
cat << EOF > /etc/samba/smb.conf
[global]
        workgroup = WORKGROUP
        netbios name = mis-samba
        security = user
        passdb backend = tdbsam
        printing = cups
        printcap name = cups
        load printers = yes
        cups options = raw
        dfree command = /etc/samba/samba-dfree
        dfree cache time = 60
[Secure]
        comment = Secure File Server Share
        path =   $SAMBA_DIR
        valid users = @smbgrp
        guest ok = no
        writable = yes
        browsable = yes
EOF

#Cron job to change shared files ownership to apache every 5 mins in case of new files delivered out side of nextcloud
apache_ownership_script="/root/apache_ownership_script"
cat << EOF > /root/apache_ownership_script
#!/bin/bash
chown -R $web_user:$web_user $SAMBA_DIR
chmod -R 0770  $SAMBA_DIR
$sudo_cmd -u $web_user php $occ_cmd  files:scan $NEXTCLOUD_ADMIN
EOF

chmod +x $apache_ownership_script

#Place cron job to chown shared folders
temp_cron_file="/tmp/temp_cron_file" ;
crontab -l > $temp_cron_file ;
grep -q "$apache_ownership_script" $temp_cron_file || echo "*/5 * * * * /usr/bin/sh $apache_ownership_script > /dev/null 2>&1" >> $temp_cron_file && crontab $temp_cron_file
rm -f $temp_cron_file


#Start and enable  samba
systemctl start smb.service ;
systemctl enable smb.service ;
systemctl start httpd;
