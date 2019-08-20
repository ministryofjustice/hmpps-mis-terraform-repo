# MIS-PROD


## AWS Parameter Store

#### Credentials:

```
admin user - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-prod-mis-admin-user?region=eu-west-2

admin user password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-delius-prod-mis-admin-password?region=eu-west-2

SMTP User - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-del-prod-ses-smtp-user-access-key-id?region=eu-west-2

SMTP User password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-del-prod-ses-smtp-user-ses-password?region=eu-west-2
```

# Instances

## BCS

#### Internal DNS  


```
ndl-bcs-001.delius-prod.internal
ndl-bcs-002.delius-prod.internal
ndl-bcs-003.delius-prod.internal
```

#### External DNS  

```
ndl-bcs-001.probation.service.justice.gov.uk
ndl-bcs-002.probation.service.justice.gov.uk
ndl-bcs-003.probation.service.justice.gov.uk
```
## BFS

#### Internal DNS  

```
ndl-bfs-001.delius-prod.internal
```

#### External DNS  

```
ndl-bfs-001.probation.service.justice.gov.uk
```
## BPS
#### Internal DNS  


```
ndl-bps-001.delius-prod.internal
ndl-bps-002.delius-prod.internal
ndl-bps-003.delius-prod.internal
```

#### External DNS  

```
ndl-bps-001.probation.service.justice.gov.uk
ndl-bps-002.probation.service.justice.gov.uk
ndl-bps-003.probation.service.justice.gov.uk
```
## BWS
BWS Endpoint [https://ndl-bws.probation.service.justice.gov.uk](https://ndl-bws.probation.service.justice.gov.uk)

#### Internal DNS  


```
ndl-bws-001.delius-prod.internal
ndl-bws-002.delius-prod.internal
```

#### External DNS  

```
ndl-bws-001.probation.service.justice.gov.uk
ndl-bws-002.probation.service.justice.gov.uk
```
## DIS
#### Internal DNS  


```
ndl-dis-001.delius-prod.internal
```

#### External DNS  

```
ndl-dis-001.probation.service.justice.gov.uk
```

## SMTP Relay/SES
An SMTP relay EC2 instance is in place to forward email notifications from SAP on ndl-dis-001 to AWS SES. The SAP SMTP client is currently unable to authenticate to AWS SES, therefore an SMTP Server running Postfix is in place between ndl-dis-001 and AWS SES to enable authentication and connection.

### SMTP Relay/Postfix
#### Internal DNS
```
smtp.delius-prod.internal
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
probation.service.justice.gov.uk
```
