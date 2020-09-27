default: snapshot
.PHONY: snapshot

snapshot:
	scripts/restore-snapshots.sh $(ENV_TYPE) $(COMPONENT)

backup:
	scripts/ebs-on-demand-backup.sh $(ENV_TYPE) $(COMPONENT)
