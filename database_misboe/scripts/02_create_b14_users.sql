SET VERIFY OFF

ACCEPT b14cmspwd DEFAULT b14cms PROMPT 'Enter password for b14cms [b14cms] : '
ACCEPT b14audpwd DEFAULT b14aud PROMPT 'Enter password for b14aud [b14aud] : '

CREATE USER b14cms IDENTIFIED BY &b14cmspwd
DEFAULT TABLESPACE b14cms
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON b14cms;

GRANT create session TO b14cms;
GRANT create table TO b14cms;
GRANT create sequence TO b14cms;
GRANT create procedure TO b14cms;
GRANT create view TO b14cms;

CREATE USER b14aud IDENTIFIED BY &b14audpwd
DEFAULT TABLESPACE b14aud
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON b14aud;

GRANT create session TO b14aud;
GRANT create table TO b14aud;
GRANT create sequence TO b14aud;
GRANT create procedure TO b14aud;
GRANT create view TO b14aud;