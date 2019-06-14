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
MAIL_HOSTNAME="${mail_hostname}"
MAIL_DOMAIN="${mail_domain}"
MAIL_NETWORK="${mail_network}"
MAIL_USER_NAME="${mail_user_name}"
MAIL_PASSWD="${mail_passwd}"


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
export MAIL_HOSTNAME="${mail_hostname}"
export MAIL_DOMAIN="${mail_domain}"
export MAIL_NETWORK="${mail_network}"
export MAIL_USER_NAME="${mail_user_name}"
export MAIL_PASSWD="${mail_passwd}"

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

cat << EOF > ~/bootstrap.yml
---
- hosts: localhost
  vars_files:
   - "{{ playbook_dir }}/users.yml"
  roles:
     - bootstrap
     - rsyslog
     - users
EOF

ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/bootstrap.yml



###Install and configure postfix###

#vars
app="postfix"
main_cf_file="/etc/postfix/main.cf"
ses_host="email-smtp.eu-west-1.amazonaws.com"
sasl_passwd_file="/etc/postfix/sasl_passwd"
sasl_passwd_db="/etc/postfix/sasl_passwd.db"
master_cf_file="/etc/postfix/master.cf"
ses_port="587"

#Remove Sendmail
yum remove sendmail -y

#Enable postfix service
systemctl enable $${app} ;

#Install cyrus-sasl-plain
yum install cyrus-sasl-plain -y ;

#Stop postfix
systemctl stop $${app}  ;


#Clean master cf file and restore defaults
> $${main_cf_file} ;
postconf -e  "queue_directory = /var/spool/postfix"                     \
    "command_directory = /usr/sbin"                                     \
    "daemon_directory = /usr/libexec/postfix"                           \
    "data_directory = /var/lib/postfix"                                 \
    "mail_owner = postfix"                                              \
    "unknown_local_recipient_reject_code = 550"                         \
    "alias_maps = hash:/etc/aliases"                                    \
    "alias_database = hash:/etc/aliases"                                \
    "debug_peer_level = 2"                                              \
    "sendmail_path = /usr/sbin/sendmail.postfix"                        \
    "newaliases_path = /usr/bin/newaliases.postfix"                     \
    "mailq_path = /usr/bin/mailq.postfix"                               \
    "setgid_group = postdrop"                                           \
    "html_directory = no"                                               \
    "manpage_directory = /usr/share/man"                                \
    "sample_directory = /usr/share/doc/postfix-2.10.1/samples"          \
    "readme_directory = /usr/share/doc/postfix-2.10.1/README_FILES" ;

echo     'debugger_command =
     PATH=/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
     ddd $daemon_directory/$process_name $process_id & sleep 5' >> $${main_cf_file} ;

#start postfix
systemctl start $${app}  ;

#Configure SES opts
postconf -e "relayhost = [$${ses_host}]:$${ses_port}" "smtp_sasl_auth_enable = yes"     \
     "smtp_sasl_security_options = noanonymous" "smtp_sasl_password_maps = hash:$${sasl_passwd_file}" \
	 "smtp_use_tls = yes" "smtp_tls_security_level = encrypt" "smtp_tls_note_starttls_offer = yes" ;

#Remove/Comment out -o smtp_fallback_relay= fro master.cf file
grep -q "\-o smtp_fallback_relay=" $${master_cf_file} && sed -e '/\-o smtp_fallback_relay=/s/^#*/#/' -i $${master_cf_file} ;


#Configure sasl_passwd vars_file
echo "[$${ses_host}]:$${ses_port} $MAIL_USER_NAME:$MAIL_PASSWD" > $${sasl_passwd_file} ;
postmap hash:$${sasl_passwd_file} ;
chown root:root $${sasl_passwd_file} $${sasl_passwd_db} ;
chmod 0600      $${sasl_passwd_file} $${sasl_passwd_db} ;

#Cert
postconf -e 'smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt' ;

#Configure relay opts
postconf -e "myhostname = $MAIL_HOSTNAME" \
            "mydomain = $MAIL_DOMAIN"     \
            "mynetworks = $MAIL_NETWORK"  ;

postconf -e 'myorigin = $mydomain' \
  'inet_interfaces = all'          \
  'inet_protocols = all'           \
  'local_recipient_maps ='         \
  'relay_domains = $mydestination' \
  'home_mailbox = Maildir/'        \
  'mydestination = $myhostname, localhost.$mydomain, localhost' ;

#Restart postfix service
systemctl restart $${app}
