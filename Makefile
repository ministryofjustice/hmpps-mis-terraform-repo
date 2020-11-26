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
	rm -rf env_configs
	git config --global advice.detachedHead false
	git clone -b $(ENV_CONFIGS_VERSION) $(ENV_CONFIGS_REPO) env_configs
	cd env_configs
	git describe --tags && cd CODEBUILD_SRC_DIR
