# hmpps-mis-terraform-dev
hmpps-mis-terraform-dev


## AWS Parameter Store

#### Credentials:

```
admin user - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-mis-nart-dev-mis-admin-user/description?region=eu-west-2

admin user password - https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/tf-eu-west-2-hmpps-mis-nart-dev-mis-admin-password/description?region=eu-west-2
```

# Instances

#### Jumphost

```
jumphost.dev.mis.probation.hmpps.dsd.io
```

#### LDAP

```
ldap-primary.mis-nart-dev.internal
ldap-replica.mis-nart-dev.internal - Not deployed for POC
```

#### LDAP Credentials

```
username - admin
password - SSM entry - tf-eu-west-2-hmpps-mis-nart-dev-mis-ldap-admin-password
directory manager password - SSM entry - tf-eu-west-2-hmpps-mis-nart-dev-mis-ldap-manager-password
```

#### BCS

```
ndl-bcs-001.mis-nart-dev.internal
ndl-bcs-002.mis-nart-dev.internal
```

#### BFS

```
ndl-bfs-001.mis-nart-dev.internal
```

#### BPS

```
ndl-bps-001.mis-nart-dev.internal
ndl-bps-002.mis-nart-dev.internal
ndl-bps-003.mis-nart-dev.internal
```

#### BWS

```
ndl-bws-001.mis-nart-dev.internal
ndl-bws-002.mis-nart-dev.internal
```

#### DIS

```
ndl-dis-001.mis-nart-dev.internal
```

#### DIS Automation

DIS host 

```
ndl-dis-auto-001.mis-nart-dev.internal
```