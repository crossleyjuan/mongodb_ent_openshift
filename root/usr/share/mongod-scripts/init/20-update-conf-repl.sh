#!/bin/bash

function update_replica_conf() {
	if [ -v MONGODB_CONFIG_PATH ] || [ ! -s MONGODB_CONFIG_PATH ];
	then
		echo "MONGODB_CONFIG_PATH not set"
		MONGODB_CONFIG_PATH=/etc/mongod.conf
	fi

	#tmp_file="/tmp/a$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 16).conf"
	tmp_file="/tmp/mongod.conf"
	echo "${MONGODB_CONFIG_PATH} ${tmp_file}"
	cp ${MONGODB_CONFIG_PATH} ${tmp_file}

	sed -e "s/#replication/replication/g" -e "s/#\([ ]*\)replSetName/\1replSetName/g" -e "s/#\([ ]*\)oplogSizeMB/\1oplogSizeMB/g" -i ${tmp_file}
	cat ${tmp_file} > ${MONGODB_CONFIG_PATH}

	info "updated the replication configuration"
}

if [ "${MONGODB_DEPLOYMENT}" = "replicaset" ]; then
  update_replica_conf
fi
