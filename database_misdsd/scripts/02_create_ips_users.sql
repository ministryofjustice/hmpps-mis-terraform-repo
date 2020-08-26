SET VERIFY OFF

ACCEPT ipscmspwd DEFAULT ipscms PROMPT 'Enter password for ipscms [ipscms] : '
ACCEPT ipsaudpwd DEFAULT ipsaud PROMPT 'Enter password for ipsaud [ipsaud] : '
ACCEPT bodslocalpwd DEFAULT bodslocal PROMPT 'Enter password for bodslocal [bodslocal] : '
ACCEPT bodscentralpwd DEFAULT bodscentral PROMPT 'Enter password for bodscentral [bodscentral] : '

CREATE USER ipscms IDENTIFIED BY &ipscmspwd
DEFAULT TABLESPACE ipscms
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON ipscms;

GRANT create session TO ipscms;
GRANT create table TO ipscms;
GRANT create sequence TO ipscms;
GRANT create procedure TO ipscms;
GRANT create view TO ipscms;

CREATE USER ipsaud IDENTIFIED BY &ipsaudpwd
DEFAULT TABLESPACE ipsaud
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON ipsaud;

GRANT create session TO ipsaud;
GRANT create table TO ipsaud;
GRANT create sequence TO ipsaud;
GRANT create procedure TO ipsaud;
GRANT create view TO ipsaud;

CREATE USER bodslocal IDENTIFIED BY &bodslocalpwd
DEFAULT TABLESPACE bodslocal
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON bodslocal;

GRANT create session TO bodslocal;
GRANT create table TO bodslocal;
GRANT create sequence TO bodslocal;
GRANT create procedure TO bodslocal;
GRANT create view TO bodslocal;

CREATE USER bodscentral IDENTIFIED BY &bodscentralpwd
DEFAULT TABLESPACE bodscentral
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON bodscentral;

GRANT create session TO bodscentral;
GRANT create table TO bodscentral;
GRANT create sequence TO bodscentral;
GRANT create procedure TO bodscentral;
GRANT create view TO bodscentral;