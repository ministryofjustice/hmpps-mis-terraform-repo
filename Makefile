default: snapshot
.PHONY: snapshot

snapshot:
	scripts/restore-snapshots.sh $(ENV_TYPE) $(HOST_TYPE) 2020-09-21-23-51-59 $(ACCOUNT_ID)
