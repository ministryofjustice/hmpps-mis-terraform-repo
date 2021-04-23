# delius-stage

## AWS Parameter Store

#### Credentials:

```
admin user - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-stage-mis-admin-user?region=eu-west-2

admin user password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-stage-mis-admin-password?region=eu-west-2

SMTP User - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-del-stage-ses-smtp-user-access-key-id/description?region=eu-west-2

SMTP User password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-del-stage-ses-smtp-user-ses-password/description?region=eu-west-2
```

# Instances

## BCS

#### Internal DNS


```
ndl-bcs-411.delius-stage.internal
ndl-bcs-412.delius-stage.internal
ndl-bcs-413.delius-stage.internal
```

#### External DNS

```
ndl-bcs-411.stage.delius.probation.hmpps.dsd.io
ndl-bcs-412.stage.delius.probation.hmpps.dsd.io
ndl-bcs-413.stage.delius.probation.hmpps.dsd.io
```
## BFS

#### Internal DNS

```
ndl-bfs-411.delius-stage.internal
```

#### External DNS

```
ndl-bfs-411.stage.delius.probation.hmpps.dsd.io
```
## BPS
#### Internal DNS


```
ndl-bps-411.delius-stage.internal
ndl-bps-412.delius-stage.internal
ndl-bps-413.delius-stage.internal
```

#### External DNS

```
ndl-bps-411.stage.delius.probation.hmpps.dsd.io
ndl-bps-412.stage.delius.probation.hmpps.dsd.io
ndl-bps-413.stage.delius.probation.hmpps.dsd.io

```
## BWS
BWS Endpoint [https://ndl-bws.stage.delius.probation.hmpps.dsd.io/BOE/BI](https://ndl-bws.stage.delius.probation.hmpps.dsd.io/BOE/BI)

#### Internal DNS


```
ndl-bws-411.delius-stage.internal
ndl-bws-412.delius-stage.internal
```

#### External DNS

```
ndl-bws-411.stage.delius.probation.hmpps.dsd.io
ndl-bws-412.stage.delius.probation.hmpps.dsd.io
```
## DIS
DIS Endpoint [https://ndl-dis.stage.delius.probation.hmpps.dsd.io/DataServices](https://ndl-dis.stage.delius.probation.hmpps.dsd.io/DataServices/)

#### Internal DNS


```
ndl-dis-411.delius-stage.internal
```

#### External DNS

```
ndl-dis-411.stage.delius.probation.hmpps.dsd.io
```

## DFI
DFI Endpoint [https://ndl-dfi.stage.delius.probation.hmpps.dsd.io/DataServices](https://ndl-dfi.stage.delius.probation.hmpps.dsd.io/DataServices/)

#### Internal DNS


```
ndl-dfi-411.delius-stage.internal
```

#### External DNS

```
ndl-dfi-411.stage.delius.probation.hmpps.dsd.io
```

## SMTP Relay/SES
An SMTP relay EC2 instance is in place to forward email notifications from SAP on ndl-dis-411 to AWS SES. The SAP SMTP client is currently unable to authenticate to AWS SES, therefore an SMTP Server running Postfix is in place between ndl-dis-411 and AWS SES to enable authentication and connection.

### SMTP Relay/Postfix
#### Internal DNS
```
smtp.delius-stage.internal
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
stage.delius.probation.hmpps.dsd.io
```
