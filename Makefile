default: snapshot
.PHONY: snapshot

snapshot:
	scripts/ebs-restore-snapshots.sh $(ENV_TYPE) $(COMPONENT) $(HOST_SUFFIX)

backup:
	scripts/ebs-backup-snapshots.sh $(ENV_TYPE) $(COMPONENT) $(HOST_SUFFIX)

terraform_plan:
	./run.sh $(ENVIRONMENT_NAME) plan $(component)   || (exit $$?)

terraform_apply: terraform_plan
	./run.sh $(ENVIRONMENT_NAME) apply $(component)  || (exit $$?)

get_configs:
	rm -rf env_configs
	git config --global advice.detachedHead false
	git clone -b $(ENV_CONFIGS_VERSION) $(ENV_CONFIGS_REPO) env_configs

db-backup:
	scripts/nextcloud-db-backup.sh $(TASK) $(ENV_TYPE)
