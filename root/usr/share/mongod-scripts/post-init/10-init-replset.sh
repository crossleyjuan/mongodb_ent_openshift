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
  local host="$1"
  if [[ $(mongo_cmd ${mongo_cmd_opts} --quiet <<<'db.isMaster().setName') == "${MONGODB_REPLICA_NAME}" ]]; then
	  info "Replica set '${MONGODB_REPLICA_NAME}' already exists, skipping initialization"
	  >/tmp/rpl_initialized
	  exit 0
  fi

  mongo_cmd "$(replset_addr admin)" <<<"quit(rs.initiate({ _id: '${MONGODB_REPLICA_NAME}', members: [ { _id: 0, host: '${host}' }]}).ok ? 0: 1)"

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
  info "Auth:  $(replset_addr admin)"

  if ! mongo_cmd "$(replset_addr admin)" --quiet <<<"while (!rs.add('${host}').ok) { sleep(100); }"; then
    info "ERROR: couldn't add host to replica set!"
    return 1
  fi

  info "Successfully joined replica set"
}

function setup_replica() {
	echo "5: ${MONGODB_CONFIG_PATH}"
	# Initialize replica set only if we're the first member
	if [ "${MEMBER_ID}" = '0' ]; then
	  initiate "${MEMBER_HOST}"
	else
	  add_member "${MEMBER_HOST}"
	fi
}

if [ ! -f "/tmp/initialized" ];
then
   setup_replica
   >/tmp/initialized
fi

