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
FS_FQDN="${fs_fqdn}"
LDAP_ELB_NAME="${ldap_elb_name}"
LDAP_PORT="${ldap_port}"
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
export EFS_DNS_NAME="${efs_dns_name}"
export SAMBA_USER="${mis_user}"
export FS_FQDN="${fs_fqdn}"
export LDAP_ELB_NAME="${ldap_elb_name}"
export LDAP_PORT="${ldap_port}"
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



###Install and configure http and Samba###

#vars
WEB_DIR="/var/www/html"
HTML_FILE="index.html"
URL="https://$FS_FQDN"
TEMP_OUT_FILE="/tmp/temp_out_file"
HTTPD_CONF_FILE="/etc/httpd/conf/httpd.conf"
GRP_DIR_MAP_FILE="/tmp/grp_dir_map_file"

##Install httpd and modules
yum -y install httpd  mod_ldap;


###Mount EFS
yum -y install nfs-utils ;
echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).$EFS_DNS_NAME:/    $WEB_DIR  nfs4    defaults" >> /etc/fstab ;
test -d $WEB_DIR || mkdir $WEB_DIR ;
mount -a ;

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
SAMBA_USER_PASS=$(aws ssm get-parameters --with-decryption --names $MIS_USER_PASS_NAME --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')
yum install samba samba-client samba-common -y ;
groupadd smbgrp ;
useradd $SAMBA_USER ;
usermod $SAMBA_USER -aG smbgrp ;

#configure samba pass
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

#Create group to directory mapping temp file
cat << EOF >> /tmp/grp_dir_map_file
BENCH:RES-FS-BENCH-DEBS-RW:RES-FS-BENCH-DEBS-R
BGSW:RES-FS-BGSW-DEBS-R:RES-FS-BGSW-DEBS-RW
CGM:RES-FS-CGM-DEBS-RW
CL:RES-FS-CL-DEBS-R:RES-FS-CL-DEBS-RW
DDC:RES-FS-DDC-DEBS-RW
DLNR:RES-FS-DLNR-DEBS-R:RES-FS-DLNR-DEBS-RW
DTV:RES-FS-DTV-DEBS-RW:RES-FS-DTV-DEBS-R
Essex:RES-FS-Essex-DEBS-RW:RES-FS-Essex-DEBS-RW
Hampshire:RES-FS-Hampshire-DEBS-RW
HLNY:RES-FS-HLNY-DEBS-R:RES-FS-HLNY-DEBS-RW
KSS:RES-FS-KSS-DEBS-RW
LONDON:RES-FS-LONDON-DEBS-RW:RES-FS-LONDON-DEBS-R
Merseyside:RES-FS-Merseyside-DEBS-RW
Northumbria:RES-FS-Northumbria-DEBS-RW
NS:RES-FS-NS-DEBS-RW:RES-FS-NS-DEBS-R
South-Yorkshire:RES-FS-South-Yorkshire-DEBS-RW:RES-FS-South-Yorkshire-DEBS-R
SWM:RES-FS-SWM-DEBS-RW:RES-FS-SWM-DEBS-R
Thames:RES-FS-Thames-DEBS-RW:RES-FS-Thames-DEBS-R
Wales:RES-FS-Wales-DEBS-R
West-Yorkshire:RES-FS-WestYorkshire-DEBS-RW:RES-FS-WestYorkshire-DEBS-R
WWM:RES-FS-WWM-DEBS-RW
EOF

#get Auth LDAP Bind Password
AuthLDAPBindPassword=$(aws ssm get-parameters --with-decryption --names /${environment_name}/delius/apacheds/apacheds/ldap_admin_password --region eu-west-2 --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:')

#Prepare directory access control
for directory in $(cat $TEMP_OUT_FILE) ;
    do multiple_groups=$(grep -wi $(basename $directory) $GRP_DIR_MAP_FILE  | grep -o ":" | wc -l) ;
    groups1=$(grep -wi $(basename $directory) $GRP_DIR_MAP_FILE | cut -f2 -d ":");
    groups2=$(grep -wi $(basename $directory) $GRP_DIR_MAP_FILE | cut -f3 -d ":");
    if [[ $multiple_groups -gt "1" ]]; then
        filter="(|(memberOf=$groups1)(memberOf=$groups2))"
    else
        filter="(memberOf=$groups1)"
    fi ;

    cat << EOF >> /etc/httpd/conf/httpd.conf
<Directory /var/www/html/$(basename $directory)>
   AuthType Basic
   AuthName "Restricted"
   AuthBasicProvider ldap
   AuthLDAPBindAuthoritative on
   AuthLDAPUrl "ldap://$LDAP_ELB_NAME:$LDAP_PORT/cn=Users,dc=moj,dc=com?cn?sub?$filter"
   AuthLDAPBindDN "uid=admin,ou=system"
   AuthLDAPBindPassword $AuthLDAPBindPassword
   require valid-user
   Options Indexes
 </Directory>
EOF
done

#Start httpd
systemctl start httpd  ;
systemctl enable httpd ;

#remove temp files
rm -f $TEMP_OUT_FILE
rm -f $GRP_DIR_MAP_FILE
