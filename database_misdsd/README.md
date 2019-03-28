The MIS DSD database

Instances will not be terminated when a newer AMI is availible. To update instance with new AMI the taint command needs to be run.

For instance in modules

```
terragrunt taint -module="misdsd_db_1" aws_instance.oracle_db
terragrunt taint -module="misdsd_db_2" aws_instance.oracle_db
terragrunt taint -module="misdsd_db_3" aws_instance.oracle_db
```
