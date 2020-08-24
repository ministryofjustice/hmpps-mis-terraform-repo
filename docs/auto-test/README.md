# delius-auto-test

## AWS Parameter Store

#### Credentials:

```
admin user - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-auto-test-mis-admin-user/description?region=eu-west-2&tab=Table

admin user password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-auto-test-mis-admin-password/description?region=eu-west-2&tab=Table

SMTP User - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-dat-auto-test-ses-smtp-user-access-key-id/description?region=eu-west-2&tab=Table

SMTP User password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-dat-auto-test-ses-smtp-user-ses-password/description?region=eu-west-2&tab=Table

Reports User Bosso - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-auto-test-reports-admin-user/description?region=eu-west-2&tab=Table

Reports User Password Bosso - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-auto-test-reports-admin-password/description?region=eu-west-2&tab=Table
```

# Instances

## BCS

#### Internal DNS


```
ndl-bcs-801.delius-auto-test.internal
```

#### External DNS

```
ndl-bcs-801.auto-test.delius.probation.hmpps.dsd.io
```
## BFS

#### Internal DNS

```
ndl-bfs-801.delius-auto-test.internal
```

#### External DNS

```
ndl-bfs-801.auto-test.delius.probation.hmpps.dsd.io
```
## BPS
#### Internal DNS


```
ndl-bps-801.delius-auto-test.internal
```

#### External DNS

```
ndl-bps-801.auto-test.delius.probation.hmpps.dsd.io
```
## BWS
BWS Endpoint [https://ndl-bws.auto-test.delius.probation.hmpps.dsd.io/BOE/BI](https://ndl-bws.auto-test.delius.probation.hmpps.dsd.io/BOE/BI)

#### Internal DNS


```
ndl-bws-801.delius-auto-test.internal
```

#### External DNS

```
ndl-bws-801.auto-test.delius.probation.hmpps.dsd.io
```
## DIS
DIS Endpoint [https://ndl-dis.auto-test.delius.probation.hmpps.dsd.io/DataServices](https://ndl-dis.auto-test.delius.probation.hmpps.dsd.io/DataServices/)

#### Internal DNS


```
ndl-dis-801.delius-auto-test.internal
```

#### External DNS

```
ndl-dis-801.auto-test.delius.probation.hmpps.dsd.io
```

## SMTP Relay/SES
An SMTP relay EC2 instance is in place to forward email notifications from SAP on ndl-dis-801 to AWS SES. The SAP SMTP client is currently unable to authenticate to AWS SES, therefore an SMTP Server running Postfix is in place between ndl-dis-801 and AWS SES to enable authentication and connection.

### SMTP Relay/Postfix
#### Internal DNS
```
smtp.delius-auto-test.internal
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
auto-test.delius.probation.hmpps.dsd.io
```
