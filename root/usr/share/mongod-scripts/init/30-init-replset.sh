# This is a full hostname that will be added to replica set
# (for example, "replica-2.mongodb.myproject.svc.cluster.local")
readonly MEMBER_HOST="$(hostname -f)"

mongo_cmd_opts="--host localhost --authenticationDatabase admin -u admin -p ${MONGODB_ADMIN_PASSWORD}"
# StatefulSet pods are named with a predictable name, following the pattern:
#   $(statefulset name)-$(zero-based index)
# MEMBER_ID is computed by removing the prefix matching "*-", i.e.:
#  "mongodb-0" -> "0"
#  "mongodb-1" -> "1"
#  "mongodb-2" -> "2"
export readonly MEMBER_ID="${HOSTNAME##*-}"

# Initializes the replica set configuration.
#
# Arguments:
# - $1: host address[:port]
#
# Uses the following global variables:
# - MONGODB_REPLICA_NAME
# - MONGODB_ADMIN_PASSWORD
function initiate() {
  mongo_cmd $mongo_cmd_opts --quiet <<<"quit(rs.initiate().ok ? 0 : 1)"

  info "Waiting for PRIMARY status ..."
  mongo_cmd $mongo_cmd_opts --quiet <<<"while (!rs.isMaster().ismaster) { sleep(100); }"

  info "Successfully initialized replica set"
}

# Adds a host to the replica set configuration.
#
# Arguments:
# - $1: host address[:port]
#
# Global variables:
# - MONGODB_REPLICA_NAME
# - MONGODB_ADMIN_PASSWORD
function add_member() {
  local host="$1"
  info "Adding ${host} to replica set ..."

  if ! mongo_cmd "$(replset_addr admin)" $mongo_cmd_opts --quiet <<<"while (!rs.add('${host}').ok) { sleep(100); }"; then
    info "ERROR: couldn't add host to replica set!"
    return 1
  fi

  info "Waiting for PRIMARY/SECONDARY status ..."
  mongo_cmd ${mongo_cmd_opts} --quiet <<<"while (!rs.isMaster().ismaster && !rs.isMaster().secondary) { sleep(100); }"

  info "Successfully joined replica set"
}

function setup_replica() {
	# Must bring up MongoDB on localhost only until it has an admin password set.
	mongod $mongo_common_args  --bind_ip localhost &

	info "Waiting for local MongoDB to accept connections  ..."
	wait_for_mongo_up &>/dev/null

	if [[ $(mongo_cmd --host localhost --quiet <<<'db.isMaster().setName') == "${MONGODB_REPLICA_NAME}" ]]; then
	  info "Replica set '${MONGODB_REPLICA_NAME}' already exists, skipping initialization"
	  >/tmp/rpl_initialized
	  exit 0
	fi

	echo "5: ${MONGODB_CONFIG_PATH} ${MONGODB_ADMIN_PASSWORD}"
	# Initialize replica set only if we're the first member
	if [ "${MEMBER_ID}" = '0' ]; then
	  initiate "${MEMBER_HOST}"
	else
	  add_member "${MEMBER_HOST}"
	fi

	# Restart the MongoDB daemon to bind on all interfaces
	mongod $mongo_common_args --shutdown
	wait_for_mongo_down
}

if [ -v MONGODB_INITIATE_REPLICA ] && [ ! -f "/tmp/initialized" ];
then
   setup_replica
   >/tmp/initialized
fi
