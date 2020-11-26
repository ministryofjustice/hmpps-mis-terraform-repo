default: snapshot
.PHONY: snapshot

snapshot:
	scripts/restore-snapshots.sh $(ENV_TYPE) $(COMPONENT)

backup:
	scripts/ebs-on-demand-backup.sh $(ENV_TYPE) $(COMPONENT)

terraform_plan:
	./run.sh $(ENVIRONMENT_NAME) plan $(component)   || (exit $$?)

terraform_apply: terraform_plan
	./run.sh $(ENVIRONMENT_NAME) apply $(component)  || (exit $$?)
