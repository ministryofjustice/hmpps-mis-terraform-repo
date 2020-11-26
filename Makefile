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

get_configs:
	aws ssm get-parameters --names $CONFIGS_VERSION_PARAM --region $TF_VAR_region --query "Parameters[0]"."Value" | sed 's:^.\(.*\).$:\1:'
	rm -rf env_configs
	git config --global advice.detachedHead false
	git clone -b $(ENV_CONFIGS_VERSION) $(ENV_CONFIGS_REPO) env_configs
