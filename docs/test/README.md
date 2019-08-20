# MIS-TEST


## AWS Parameter Store

#### Credentials:

```
admin user - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-mis-test-mis-admin-user?region=eu-west-2

admin user password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-mis-test-mis-admin-password?region=eu-west-2

SMTP User - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-dmt-mis-test-ses-smtp-user-access-key-id?region=eu-west-2

SMTP User password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-dmt-mis-test-ses-smtp-user-ses-password?region=eu-west-2
```

# Instances

## BCS

#### Internal DNS  


```
ndl-bcs-300.delius-mis-test.internal
```

#### External DNS  

```
ndl-bcs-300.mis-test.delius.probation.hmpps.dsd.io
```
## BFS

#### Internal DNS  

```
ndl-bfs-300.delius-mis-test.internal
```

#### External DNS  

```
ndl-bfs-300.mis-test.delius.probation.hmpps.dsd.io
```
## BPS
#### Internal DNS  


```
ndl-bps-300.delius-mis-test.internal

```

#### External DNS  

```
ndl-bps-300.mis-test.delius.probation.hmpps.dsd.io
```
## BWS
BWS Endpoint [https://ndl-bws.mis-test.delius.probation.hmpps.dsd.io](https://ndl-bws.mis-test.delius.probation.hmpps.dsd.io)

#### Internal DNS  


```
ndl-bws-300.delius-mis-test.internal
```

#### External DNS  

```
ndl-bws-300.mis-test.delius.probation.hmpps.dsd.io
```
## DIS
#### Internal DNS  


```
ndl-dis-300.delius-mis-test.internal
```

#### External DNS  

```
ndl-dis-300.mis-test.delius.probation.hmpps.dsd.io
```

## SMTP Relay/SES
An SMTP relay EC2 instance is in place to forward email notifications from SAP on ndl-dis-300 to AWS SES. The SAP SMTP client is currently unable to authenticate to AWS SES, therefore an SMTP Server running Postfix is in place between ndl-dis-300 and AWS SES to enable authentication and connection.

### SMTP Relay/Postfix
#### Internal DNS
```
smtp.delius-mis-test.internal
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
mis-test.delius.probation.hmpps.dsd.io
```
