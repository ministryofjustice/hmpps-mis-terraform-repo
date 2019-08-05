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
EFS_DNS_NAME="${efs_dns_name}"
SAMBA_USER="${mis_user}"
SAMBA_USER_PASS="${mis_user_pass}"
FS_FQDN="${fs_fqdn}"


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
export EFS_DNS_NAME="${efs_dns_name}"
export SAMBA_USER="${mis_user}"
export SAMBA_USER_PASS="${mis_user_pass}"
export FS_FQDN="${fs_fqdn}"

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



###Install and configure http and Samba###

#vars
WEB_DIR="/var/www/html"
HTML_FILE="index.html"
URL="https://$FS_FQDN"
TEMP_OUT_FILE="/tmp/temp_out_file"
HTTPD_CONF_FILE="/etc/httpd/conf/httpd.conf"

##Install httpd and modules
yum -y install httpd  mod_ldap;


###Mount EFS
yum -y install nfs-utils ;
echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).$EFS_DNS_NAME:/    $WEB_DIR  nfs4    defaults" >> /etc/fstab ;
test -d $WEB_DIR || mkdir $WEB_DIR ;
mount -a ;

#Configure httpd

#Start httpd
systemctl start httpd  ;
systemctl enable httpd ;


####Create html file
echo "<html>"                      > $WEB_DIR/$HTML_FILE ;
echo "    <h1>MIS Share</h1>"     >> $WEB_DIR/$HTML_FILE ;
echo "    <p>"                    >> $WEB_DIR/$HTML_FILE ;
find $WEB_DIR/* -type d            > $TEMP_OUT_FILE ;
sort $TEMP_OUT_FILE -o $TEMP_OUT_FILE ;
for directory in $(cat $TEMP_OUT_FILE) ; do echo "    <br> <a href=$URL/$(basename $directory)/>$(basename $directory)</a>" >> $WEB_DIR/$HTML_FILE ; done
echo "    </p>"                   >> $WEB_DIR/$HTML_FILE ;
echo "</html>"                    >> $WEB_DIR/$HTML_FILE ;

##Samba share
yum install samba samba-client samba-common -y ;
groupadd smbgrp ;
useradd $SAMBA_USER ;
usermod $SAMBA_USER -aG smbgrp ;

#smbpasswd -a mismis-test ;       #pass is owncloud
###maybe create a small script for this one
echo -ne "$SAMBA_USER_PASS\n$SAMBA_USER_PASS\n" | smbpasswd -a -s $SAMBA_USER ;

chmod -R 0770  $WEB_DIR ;
chown -R apache:smbgrp   $WEB_DIR ;
chcon -t samba_share_t   $WEB_DIR ;




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
        path =   /var/www/html
        valid users = @smbgrp
        guest ok = no
        writable = yes
        browsable = yes
EOF

#Start and enable  samba
systemctl start smb.service ;
systemctl enable smb.service ;



####Configure httpd
cat << 'EOF' > /etc/httpd/conf/httpd.conf
ServerRoot "/etc/httpd"
Listen 80
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost

<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"

<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>

<Directory "/var/www/html">
    Options Indexes FollowSymLinks MultiViews
    AllowOverride ALL
    Require all granted
</Directory>

<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>

<Files ".ht*">
    Require all denied
</Files>

ErrorLog "logs/error_log"
LogLevel warn

<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>

<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>

<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>

AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>

EnableSendfile on
IncludeOptional conf.d/*.conf

EOF

##Configure access to directories
for directory in $(cat $TEMP_OUT_FILE) ;
    do cat << EOF >> /etc/httpd/conf/httpd.conf

<Directory /var/www/html/$(basename $directory)>
   AuthType Basic
   AuthName "Restricted"
   AuthBasicProvider ldap
   AuthLDAPBindAuthoritative on
   AuthLDAPUrl "ldap://ENTERIP/ou=People,dc=field,dc=linuxhostsupport,dc=com"
   AuthLDAPBindDN "cn=ldapadm,dc=field,dc=linuxhostsupport,dc=com"
   AuthLDAPBindPassword enterpasshere
   <RequireAny>
   require ldap-group cn=londongrp,ou=Group,dc=field,dc=linuxhostsupport,dc=com
   </RequireAny>
   AuthLDAPGroupAttributeIsDN off
   AuthLDAPGroupAttribute memberUid
   Options Indexes
 </Directory>
EOF
done

rm -f $TEMP_OUT_FILE
