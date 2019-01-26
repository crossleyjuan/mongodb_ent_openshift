# New systems by default use only python3, so select python on runtime
PYTHON=python3
command -v $PYTHON &>/dev/null || PYTHON=python

# setup_wiredtiger_cache checks amount of available RAM (it has to use cgroups in container)
# and if there are any memory restrictions set storage.wiredTiger.engineConfig.configString: cache_size=
# in MONGODB_CONFIG_PATH to upstream default size
# it is intended to update mongod.conf.template, with custom config file it might create conflict
function setup_wiredtiger_cache() {
  if [[ -v WIREDTIGER_CACHE_SIZE ]]; then
    export CACHE_SIZE=${WIREDTIGER_CACHE_SIZE}
  else
    declare $($PYTHON /usr/libexec/available_memory)

	export CACHE_SIZE=$($PYTHON -c "min=1; limit=int(($MEMORY_AVAILABLE * 0.6 - 1)); print( min if limit < min else limit)")
  fi

  info "wiredTiger cache_size set to ${CACHE_SIZE}"
}

setup_wiredtiger_cache
