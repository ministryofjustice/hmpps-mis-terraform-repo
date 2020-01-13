#!/bin/bash

#Temp script to be used until UMT can manage groups
###Vars
USER_UID=$1
GROUP=$2
dt=$(date '+%d_%m_%Y_%H_%M_%S')
LOG_TIME_STAMP=$(date '+%d-%m-%Y-%H-%M-%S')
BASE="ou=Users,dc=moj,dc=com"
object_class="objectClass: person"
TEMP_LDIF_FILE="NDmis_${dt}.ldif"
LOGFILE="LOGFILE.log"

usage ()
{
echo "Script to add user to LDAP Group"
echo "Example Usage: NDMIS     $0 UserID   GroupName,ou=Groups,dc=moj,dc=com  (Use quotes if there are spaces in group name)"
echo "Example Usage Nextcloud: $0 UserID   GroupName,ou=Fileshare,ou=Groups,dc=moj,dc=com"
exit 1
}

if [[ -z $USER_UID ]] || [[ -z $GROUP ]]; then
    usage
fi

clean_up_file ()
{
test -f $TEMP_LDIF_FILE && rm $TEMP_LDIF_FILE
exit 1
}

check_user_exist ()
{
user_present=$(ldapsearch -Q -Y EXTERNAL -H ldapi:// -b $BASE "(uid=$USER_UID)" "*" "+" | grep uid:)

if [[ -z $user_present ]]; then
    echo "$USER_UID Not Found! ..exiting"
    echo "${LOG_TIME_STAMP} $USER_UID Not Found! ..exiting" >> $LOGFILE
    clean_up_file
else
    echo "$USER_UID is present, proceeding"
fi
}

check_person_object_class ()
{
object_class_present=$(ldapsearch -Q -Y EXTERNAL -H ldapi:// -b $BASE "(uid=${USER_UID})" "*" "+" | grep "$object_class")
if [[ -z $object_class_present ]]; then
    echo "${object_class} is not present! for $USER_UID ... exiting"
    clean_up_file
else
    echo "${object_class} is present for $USER_UID ...proceeding"
fi
}

check_email_exists ()
{
mail_present=$(ldapsearch -Q -Y EXTERNAL -H ldapi:// -b $BASE "(uid=${USER_UID})" "*" "+" | grep "mail")
if [[ -z $mail_present ]]; then
    echo "Email is not present! for $USER_UID ... exiting"
    echo "${LOG_TIME_STAMP} Email is not present! for $USER_UID ... exiting" >> $LOGFILE
    clean_up_file
else
    echo "${mail_present} is present for $USER_UID ...proceeding"
fi
}



check_group_exists ()
{
group_exists=$(ldapsearch -Q -Y EXTERNAL -H ldapi:// -b "ou=Groups,dc=moj,dc=com" member | grep dn: | sed "s/dn: cn=//" | grep "^${GROUP}$")
if [[ -z $group_exists ]]; then
    echo "Group ${GROUP} does not exist! ...exiting"
    echo "${LOG_TIME_STAMP} Group ${GROUP} does not exist! ...exiting" >> $LOGFILE
    clean_up_file
else
   echo "Group ${GROUP} found ...proceeding"
fi
}

check_if_user_in_group ()
{
user_in_group=$(ldapsearch -Q -Y EXTERNAL -H ldapi:// -b "CN=${GROUP}" member | grep $USER_UID)
if [[ -z $user_in_group ]]; then
    echo "${USER_UID} not a member of ${GROUP} ...proceeding to add"
else
    echo "${USER_UID} is already a member of ${GROUP} ..exiting"
    echo "${LOG_TIME_STAMP} ${USER_UID} is already a member of ${GROUP} ..exiting" >> $LOGFILE
    clean_up_file
fi
}

add_user_to_group ()
{
echo "Creating ldif file...."
cat << EOF > $TEMP_LDIF_FILE
dn: CN=${GROUP}
changetype: modify
add: member
member: cn=${USER_UID},${BASE}
EOF

echo "LDIF FILE"
echo "----------------------------------------------------------------------"
cat $TEMP_LDIF_FILE
echo "----------------------------------------------------------------------"
echo
echo "Do you want to proceed? y/n"
read yes_no ;

case "$yes_no" in
	y) echo "Adding ${USER_UID} to ${GROUP}"
           echo "ldapmodify -H ldap:// -D cn=admin,dc=moj,dc=com -W -f $TEMP_LDIF_FILE"
           ldapmodify -H ldap:// -D cn=admin,dc=moj,dc=com -W -f $TEMP_LDIF_FILE
           echo "${USER_UID} added to ${GROUP}"
           echo "ldif file saved to $TEMP_LDIF_FILE"
	   ;;
	n) echo "User aborted ...exiting"
           clean_up_file
	   ;;
        *) echo "Invalid Selection"
           clean_up_file
           ;;
esac ;
}


test -f $LOGFILE || touch $LOGFILE
check_user_exist
check_email_exists
#check_group_exists
#check_person_object_class
check_if_user_in_group
add_user_to_group
echo
echo
#echo "Press Enter to continue to next user"
#read Continue
