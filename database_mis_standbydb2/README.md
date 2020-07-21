The MIS database

Instances will not be terminated when a newer AMI is availible. To update instance with new AMI the taint command needs to be run.

For instance in modules

```
terragrunt taint -module="mis_db_1" aws_instance.oracle_db
terragrunt taint -module="mis_db_2" aws_instance.oracle_db
terragrunt taint -module="mis_db_3" aws_instance.oracle_db
```
