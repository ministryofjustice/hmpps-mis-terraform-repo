default: snapshot
.PHONY: snapshot

snapshot:
	scripts/restore-snapshots.sh $(ENV_TYPE) $(COMPONENT) '09/23/2020 02:13:16'
