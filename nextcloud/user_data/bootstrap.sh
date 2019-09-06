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
DATA_DIR="/var/www/html/nextcloud/data"
sudo_cmd="/usr/bin/sudo"
BASE_DN="cn=Users,dc=moj,dc=com"

#Nextcloud install
yum -y install epel-release yum-utils ;
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm ;
yum -y install unzip ;

#Enable PHP 7.3
yum-config-manager --disable remi-php54 ;
yum-config-manager --enable remi-php73 ;


#install Apache and PHP packages
yum -y install httpd php php-cli php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pdo php-pecl-apcu php-pecl-apcu-devel php-intl php71-php-pecl-imagick php-ldap ;

systemctl enable httpd && systemctl start httpd ;

#Download and install nextcloud
curl -s https://download.nextcloud.com/server/releases/nextcloud-16.0.3.zip --output nextcloud-16.0.3.zip ;
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


#Install and configure nextcloud
cd /var/www/html/nextcloud ;
$sudo_cmd -u $web_user php $occ_cmd maintenance:install --database "mysql" \
    --database-host "$DB_DNS_NAME"  \
    --database-name "nextcloud"  --database-user "$NEXTCLOUD_DB_USER" --database-pass "$NEXTCLOUD_DB_PASS" \
	--admin-user "$NEXTCLOUD_ADMIN" --admin-pass "$NEXTCLOUD_ADMIN_PASSWORD" ;

$sudo_cmd -u $web_user php $occ_cmd config:system:set trusted_domains 0 --value=nextcloud.$EXTERNAL_DOMAIN ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set overwritehost --value=nextcloud.$EXTERNAL_DOMAIN ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set overwriteprotocol --value=https ;
$sudo_cmd -u $web_user php $occ_cmd config:system:set overwrite.cli.url --value=https://$EXTERNAL_DOMAIN ;

#Enable Ldap App
$sudo_cmd -u $web_user php $occ_cmd app:enable user_ldap ;

#Configure ldap authentication
cd /var/www/html/nextcloud ;
$sudo_cmd -u $web_user php $occ_cmd ldap:delete-config s01;
$sudo_cmd -u $web_user php $occ_cmd ldap:create-empty-config;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapHost "$LDAP_HOST" ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapPort "$LDAP_PORT" ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapAgentName "$LDAP_USER" ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapAgentPassword "$LDAP_USER_PASS" ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapBase "$BASE_DN" ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapUserFilter "(&(|(memberOf=NEXTCLOUD-USER)))" ;
$sudo_cmd -u $web_user php $occ_cmd ldap:set-config s01 ldapLoginFilter "(&(&(|(memberOf=NEXTCLOUD-USER)))(|(cn=%uid)(memberOf=%uid)(objectClass=%uid)(sn=%uid)(userPassword=%uid)(userSector=%uid)))" ;


#Start httpd service
systemctl restart httpd ;
