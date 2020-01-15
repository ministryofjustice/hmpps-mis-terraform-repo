# MIS-PRE-PROD


## AWS Parameter Store

#### Credentials:

```
admin user - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-pre-prod-mis-admin-user?region=eu-west-2

admin user password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-pre-prod-mis-admin-password?region=eu-west-2

SMTP User - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-del-pre-prod-ses-smtp-user-access-key-id?region=eu-west-2

SMTP User password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-del-pre-prod-ses-smtp-user-ses-password?region=eu-west-2
```

# Instances

## BCS

#### Internal DNS  


```
ndl-bcs-501.delius-pre-prod.internal
ndl-bcs-502.delius-pre-prod.internal
ndl-bcs-503.delius-pre-prod.internal
```

#### External DNS  

```
ndl-bcs-501.pre-prod.delius.probation.hmpps.dsd.io
ndl-bcs-502.pre-prod.delius.probation.hmpps.dsd.io
ndl-bcs-503.pre-prod.delius.probation.hmpps.dsd.io
```
## BFS

#### Internal DNS  

```
ndl-bfs-501.delius-pre-prod.internal
```

#### External DNS  

```
ndl-bfs-501.pre-prod.delius.probation.hmpps.dsd.io
```
## BPS
#### Internal DNS  


```
ndl-bps-501.delius-pre-prod.internal
ndl-bps-502.delius-pre-prod.internal
ndl-bps-503.delius-pre-prod.internal

```

#### External DNS  

```
ndl-bps-501.pre-prod.delius.probation.hmpps.dsd.io
ndl-bps-502.pre-prod.delius.probation.hmpps.dsd.io
ndl-bps-503.pre-prod.delius.probation.hmpps.dsd.io
```
## BWS
BWS Endpoint [https://ndl-bws.pre-prod.delius.probation.hmpps.dsd.io/BOE/BI](https://ndl-bws.pre-prod.delius.probation.hmpps.dsd.io/BOE/BI)

#### Internal DNS  


```
ndl-bws-501.delius-pre-prod.internal
ndl-bws-502.delius-pre-prod.internal
```

#### External DNS  

```
ndl-bws-501.pre-prod.delius.probation.hmpps.dsd.io
ndl-bws-502.pre-prod.delius.probation.hmpps.dsd.io
```
## DIS
DIS Endpoint [https://ndl-dis.pre-prod.delius.probation.hmpps.dsd.io/DataServices/](https://ndl-dis.pre-prod.delius.probation.hmpps.dsd.io/DataServices/)

#### Internal DNS  


```
ndl-dis-501.delius-pre-prod.internal
```

#### External DNS  

```
ndl-dis-501.pre-prod.delius.probation.hmpps.dsd.io
```

## SMTP Relay/SES
An SMTP relay EC2 instance is in place to forward email notifications from SAP on ndl-dis-501 to AWS SES. The SAP SMTP client is currently unable to authenticate to AWS SES, therefore an SMTP Server running Postfix is in place between ndl-dis-501 and AWS SES to enable authentication and connection.

### SMTP Relay/Postfix
#### Internal DNS
```
smtp.delius-pre-prod.internal
```
#### Port
```
TCP: 25
```


### SES
#### Server Name
```
email-smtp.eu-west-1.amazonaws.com
```
#### Port
```
TCP: 587
```

#### Domain Identities
```
pre-prod.delius.probation.hmpps.dsd.io
```
