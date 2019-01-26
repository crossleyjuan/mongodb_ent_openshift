# New systems by default use only python3, so select python on runtime
PYTHON=python3
command -v $PYTHON &>/dev/null || PYTHON=python

# setup_wiredtiger_cache checks amount of available RAM (it has to use cgroups in container)
# and if there are any memory restrictions set storage.wiredTiger.engineConfig.configString: cache_size=
# in MONGODB_CONFIG_PATH to upstream default size
# it is intended to update mongod.conf.template, with custom config file it might create conflict
function setup_oplog_size() {
  if [[ -v MONGODB_OPLOGSIZE ]]; then
    export OPLOG_SIZE=${MONGODB_OPLOGSIZE}
  else
    declare $($PYTHON /usr/libexec/diskinfo ${MONGODB_DATADIR})

	export OPLOG_SIZE=$($PYTHON -c "min=1024; limit=int(($DISK_FREE * 0.05)); print( min if limit < min else limit)")
  fi

  info "oplogSizeMB set to ${OPLOG_SIZE}"
}

setup_oplog_size
