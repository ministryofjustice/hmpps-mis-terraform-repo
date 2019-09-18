#!/usr/bin/env bash

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
occ_cmd="/var/www/html/nextcloud/occ"
NEXTCLOUD_ADMIN_PASSWORD=$(aws ssm get-parameters --with-decryption --names $NEXTCLOUD_ADMIN_PASS_PARAM --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
NEXTCLOUD_DB_PASS=$(aws ssm get-parameters --with-decryption --names $DB_PASS_PARAM --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
LDAP_USER_PASS=$(aws ssm get-parameters --with-decryption --names $LDAP_BIND_PASS_PARAM --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
CONFIG_PASS=$(aws ssm get-parameters --with-decryption --names $CONFIG_PASSW --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
DATA_DIR="/var/www/html/nextcloud/data"
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
yum -y install httpd php php-cli php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pdo php-pecl-apcu php-pecl-apcu-devel php-intl php71-php-pecl-imagick php-ldap redis php-pecl-redis zip ;

systemctl enable httpd && systemctl start httpd ;

#Download and install nextcloud
aws s3 cp s3://$BACKUP_BUCKET/installer/nextcloud-16.0.3.zip . ;
unzip nextcloud-16.0.3.zip ;
rm -f *.zip ;

#move nextcloud folder to /var/www/html
mv nextcloud/ /var/www/html/ ;

#Create directory Store
mkdir -p $DATA_DIR ;
#Mount efs
yum -y install nfs-utils ;
echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).$EFS_DNS_NAME:/    $DATA_DIR  nfs4    defaults" >> /etc/fstab ;
mount -a ;
chown $web_user:$web_user -R /var/www/html/nextcloud ;


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
#Install and configure nextcloud
cd $NEXT_CLOUD_DIR ;

if [[ $AZ != "2a" ]] ; then
    systemctl stop httpd
    sleep 300
fi


if [[ $AZ == "2a" ]] ; then
    $sudo_cmd -u $web_user php $occ_cmd maintenance:install --database "mysql" \
        --database-host "$DB_DNS_NAME"  \
        --database-name "nextcloud"  --database-user "$NEXTCLOUD_DB_USER" --database-pass "$NEXTCLOUD_DB_PASS" \
	    --admin-user "$NEXTCLOUD_ADMIN" --admin-pass "$NEXTCLOUD_ADMIN_PASSWORD" ;

    $sudo_cmd -u $web_user php $occ_cmd config:system:set trusted_domains 0 --value=nextcloud.$EXTERNAL_DOMAIN ;
    $sudo_cmd -u $web_user php $occ_cmd config:system:set overwritehost --value=nextcloud.$EXTERNAL_DOMAIN ;
    $sudo_cmd -u $web_user php $occ_cmd config:system:set overwriteprotocol --value=https ;
    $sudo_cmd -u $web_user php $occ_cmd config:system:set overwrite.cli.url --value=https://$EXTERNAL_DOMAIN ;

    $sudo_cmd -u $web_user php $occ_cmd app:enable twofactor_totp ; #Enable 2f app
    $sudo_cmd -u $web_user php $occ_cmd app:enable user_ldap ;     #Enable Ldap App

    #Configure ldap authentication
    $sudo_cmd -u $web_user php $occ_cmd ldap:delete-config s01;
    $sudo_cmd -u $web_user php $occ_cmd ldap:create-empty-config;
    $sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapHost "$LDAP_HOST" ;
    $sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapPort "$LDAP_PORT" ;
    $sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapAgentName "$LDAP_USER" ;
    $sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapAgentPassword "$LDAP_USER_PASS" ;
    $sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapBase "$BASE_DN" ;
    $sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapUserFilter "(&(|(memberOf=NEXTCLOUD-USER)))" ;
    $sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapLoginFilter "(&(&(|(memberOf=NEXTCLOUD-USER)))(|(cn=%uid)))" ;
    $sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapLoginFilterAttributes "cn" ;

    #Configure Redis
    $sudo_cmd -u $web_user php $occ_cmd config:system:set memcache.distributed --value="\\OC\\Memcache\\Redis" ;
    $sudo_cmd -u $web_user php $occ_cmd config:system:set memcache.locking --value="\\OC\\Memcache\\Redis" ;
    $sudo_cmd -u $web_user php $occ_cmd config:system:set filelocking.enabled --value="true" ;
    $sudo_cmd -u $web_user php $occ_cmd config:system:set redis host --value="$REDIS_ADDRESS" ;
    $sudo_cmd -u $web_user php $occ_cmd config:system:set redis port --value="6379" ;
    $sudo_cmd -u $web_user php $occ_cmd config:system:set redis timeout --value=1.5 ;

    $sudo_cmd -u $web_user php $occ_cmd config:system:set csrf.disabled --value="true" ;

    #create config template_file
    $sudo_cmd -u $web_user php $occ_cmd config:list --private > $CONFIG_DIR/config_export.json
    cd $CONFIG_DIR
    zip --encrypt -P "$CONFIG_PASS" config_export.json.zip config_export.json
    aws s3 cp config_export.json.zip s3://$BACKUP_BUCKET/installer/ ;
    rm -f $CONFIG_DIR/*.json*
else
    #Generate temp default config.php to allow import of config from s3
    #Will be overwritten by config import
    temp_data_dir="/var/tmp/nextcloud/data"
    mkdir -p $temp_data_dir
    chown $web_user:$web_user $temp_data_dir
    cd $NEXT_CLOUD_DIR
    $sudo_cmd -u $web_user php $occ_cmd maintenance:install --database "sqlite" --admin-user "$INSTALLER_USER" --admin-pass "$INSTALLER_USER" --data-dir "/var/tmp/nextcloud/data"

    #pull base config file from s3
    $sudo_cmd -u $web_user php $occ_cmd app:enable user_ldap     #Enable Ldap App
    $sudo_cmd -u $web_user php $occ_cmd app:enable twofactor_totp #Enable 2f app
    aws s3 cp s3://$BACKUP_BUCKET/installer/config_export.json.zip $CONFIG_DIR/
    cd $CONFIG_DIR
    unzip -P "$CONFIG_PASS" config_export.json.zip
    chown $web_user:$web_user config_export.json.zip
    cd $NEXT_CLOUD_DIR
    $sudo_cmd -u $web_user php $occ_cmd config:import $CONFIG_DIR/config_export.json
    rm -f $CONFIG_DIR/*.json*
fi

#stop Redis
systemctl stop redis ;

#Configure php memory limit
sed -i 's/memory_limit = 128M/memory_limit = 513M/' /etc/php.ini

#Start httpd service
systemctl restart httpd ;

#create crontab for efs backup
efs_backup_script="/root/efs_backup_script"

#create cron script
cat << 'EOF' > /root/efs_backup_script
#!/bin/bash

#Vars
PREFIX_DATE=$(date +%F)
NEXTCLOUD_EFS_DIR="nextcloud_efs_backups"
LOG_FILE="/var/log/efs_backup.log"
DATA_DIR="/var/www/html/nextcloud/data"
BACKUP_FILE="nextcloud_efs_backup.tar.gz"
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

#zip efs dir and push to s3
echo "Backing up EFS Share"
tar cfz - $DATA_DIR | aws s3 cp - s3://$BACKUP_BUCKET/$NEXTCLOUD_EFS_DIR/$PREFIX_DATE/$BACKUP_FILE && echo "$(date) : EFS Backup Success" >> $LOG_FILE || echo "$(date) : EFS Backup Failure" >> $LOG_FILE
EOF

#Add s3 bucket_name
grep -q "BACKUP_BUCKET=$BACKUP_BUCKET" $${efs_backup_script} || sed -i "s/BACKUP_BUCKET=/BACKUP_BUCKET=$BACKUP_BUCKET/" $${efs_backup_script}
grep -q "CONFIG_PASSW=$CONFIG_PASSW"   $${efs_backup_script} || sed -i "s/CONFIG_PASSW=/CONFIG_PASSW=$CONFIG_PASSW/"    $${efs_backup_script}
chmod +x $${efs_backup_script}

#Place cron job to backup efs
if [[ $AZ == "2a" ]] ; then
    temp_cron_file="/tmp/temp_cron_file" ;
    crontab -l > $temp_cron_file ;
    grep -q "$efs_backup_script" $temp_cron_file || echo "00 01 * * * /usr/bin/sh $efs_backup_script > /dev/null 2>&1" >> $temp_cron_file && crontab $temp_cron_file
    rm -f $temp_cron_file
else
    rm -f $efs_backup_script
fi

#Pull and import latest config from backup
if [[ "aws s3 ls s3://$BACKUP_BUCKET/nextcloud_config_backups/$CONFIG_EXPORT_FILE" ]]; then
    cd /root/
    aws s3 cp s3://$BACKUP_BUCKET/nextcloud_config_backups/$CONFIG_EXPORT_FILE /root/
    unzip -P "$CONFIG_PASS" $CONFIG_EXPORT_FILE
    chown $web_user:$web_user $UNZIPPED_CONF_FILE
    cd $NEXT_CLOUD_DIR
    $sudo_cmd -u $web_user php $occ_cmd config:import /root/$UNZIPPED_CONF_FILE
    systemctl restart httpd
    rm -f /root/*.json*
fi

##Samba share
SAMBA_USER_PASS=$(aws ssm get-parameters --with-decryption --names $MIS_USER_PASS_NAME --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
SAMBA_DIR="/var/www/html/nextcloud/data/$NEXTCLOUD_ADMIN/files/shared_files"
yum install samba samba-client samba-common -y ;
groupadd smbgrp ;
useradd $SAMBA_USER ;
usermod -a -G smbgrp $SAMBA_USER ;
usermod -a -G apache $SAMBA_USER ;
usermod -a -G smbgrp $web_user ;
usermod -a -G apache $web_user ;

#configure samba pass
echo -ne "$SAMBA_USER_PASS\n$SAMBA_USER_PASS\n" | smbpasswd -a -s $SAMBA_USER ;

chmod -R 0770  $SAMBA_DIR ;

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
[Secure]
        comment = Secure File Server Share
        path =   $SAMBA_DIR
        valid users = @smbgrp
        guest ok = no
        writable = yes
        browsable = yes
EOF

#Start and enable  samba
systemctl start smb.service ;
systemctl enable smb.service ;
