default: snapshot
.PHONY: snapshot

snapshot:
	scripts/restore-snapshots.sh $(ENV_TYPE) $(COMPONENT)
