default: snapshot
.PHONY: snapshot

snapshot:
	scripts/restore-snapshots.sh $(ENV_TYPE) $(COMPONENT) 2020-09-21-23-51-59 $(ACCOUNT_ID)
