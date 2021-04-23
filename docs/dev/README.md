# MIS-DEV

## AWS Parameter Store

#### Credentials:

```
admin user - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-mis-dev-mis-admin-user?region=eu-west-2

admin user password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-mis-dev-mis-admin-password?region=eu-west-2

SMTP User - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-dmd-mis-dev-ses-smtp-user-access-key-id/description?region=eu-west-2

SMTP User password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-dmd-mis-dev-ses-smtp-user-ses-password/description?region=eu-west-2
```

# Instances

## BCS

#### Internal DNS


```
ndl-bcs-101.delius-mis-dev.internal
```

#### External DNS

```
ndl-bcs-101.mis-dev.delius.probation.hmpps.dsd.io
```
## BFS

#### Internal DNS

```
ndl-bfs-101.delius-mis-dev.internal
```

#### External DNS

```
ndl-bfs-101.mis-dev.delius.probation.hmpps.dsd.io
```
## BPS
#### Internal DNS


```
ndl-bps-101.delius-mis-dev.internal

```

#### External DNS

```
ndl-bps-101.mis-dev.delius.probation.hmpps.dsd.io
```
## BWS
BWS Endpoint [https://ndl-bws.mis-dev.delius.probation.hmpps.dsd.io/BOE/BI](https://ndl-bws.mis-dev.delius.probation.hmpps.dsd.io/BOE/BI)

#### Internal DNS


```
ndl-bws-101.delius-mis-dev.internal
```

#### External DNS

```
ndl-bws-101.mis-dev.delius.probation.hmpps.dsd.io
```
## DIS
DIS Endpoint [https://ndl-dis.mis-dev.delius.probation.hmpps.dsd.io/DataServices/(https://ndl-dis.mis-dev.delius.probation.hmpps.dsd.io/DataServices/)

#### Internal DNS


```
ndl-dis-101.delius-mis-dev.internal
```

#### External DNS

```
ndl-dis-101.mis-dev.delius.probation.hmpps.dsd.io
```

## DFI
DFI Endpoint [https://ndl-dfi.mis-dev.delius.probation.hmpps.dsd.io/DataServices/(https://ndl-dfi.mis-dev.delius.probation.hmpps.dsd.io/DataServices/)

#### Internal DNS


```
ndl-dfi-101.delius-mis-dev.internal
```

#### External DNS

```
ndl-dfi-101.mis-dev.delius.probation.hmpps.dsd.io
```

## SMTP Relay/SES
An SMTP relay EC2 instance is in place to forward email notifications from SAP on ndl-dis-101 to AWS SES. The SAP SMTP client is currently unable to authenticate to AWS SES, therefore an SMTP Server running Postfix is in place between ndl-dis-101 and AWS SES to enable authentication and connection.

### SMTP Relay/Postfix
#### Internal DNS
```
smtp.delius-mis-dev.internal
```
#### Port
```
TCP: 25
```


### SES
#### Server Name
```
email-smtp.eu-west-2.amazonaws.com
```
#### Port
```
TCP: 587
```

#### Domain Identities
```
mis-dev.delius.probation.hmpps.dsd.io
```
