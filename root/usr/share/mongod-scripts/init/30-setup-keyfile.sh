# setup_keyfile fixes the bug in mounting the Kubernetes 'Secret' volume that
# mounts the secret files with 'too open' permissions.
# add --keyFile argument to mongo_common_args
function setup_keyfile() {
  # If user specify keyFile in config file do not use generated keyFile
  if grep -q "^\s*keyFile" ${MONGODB_CONFIG_PATH}; then
    return 0
  fi
  if [ -z "${MONGODB_KEYFILE_VALUE-}" ]; then
    echo >&2 "ERROR: You have to provide the 'keyfile' value in MONGODB_KEYFILE_VALUE"
    exit 1
  fi
#  local keyfile_dir
#  keyfile_dir="$(dirname "$MONGODB_KEYFILE_PATH")"
#  if [ ! -w "$keyfile_dir" ]; then
#    echo >&2 "ERROR: Couldn't create ${MONGODB_KEYFILE_PATH}"
#    echo >&2 "CAUSE: current user doesn't have permissions for writing to ${keyfile_dir} directory"
#    echo >&2 "DETAILS: current user id = $(id -u), user groups: $(id -G)"
#    echo >&2 "DETAILS: directory permissions: $(stat -c '%A owned by %u:%g' "${keyfile_dir}")"
#    exit 1
#  fi
  echo ${MONGODB_KEYFILE_VALUE} > ${MONGODB_KEYFILE_PATH}
  chmod 0600 ${MONGODB_KEYFILE_PATH}

  TEMP_CONFIG=/tmp/mongod.conf
  cp ${MONGODB_CONFIG_PATH} ${TEMP_CONFIG}

  sed -e "s/#\([ ]*\)keyFile/\1keyFile/g" -e "s/#\([ ]*\)security/\1security/g" -e "s/#\([ ]*\)authorization/\1authorization/g" -i ${TEMP_CONFIG}
  cat ${TEMP_CONFIG} > ${MONGODB_CONFIG_PATH}
#  mongo_common_args+=" --keyFile ${MONGODB_KEYFILE_PATH}"
}

# Attention: setup_keyfile may modify value of mongo_common_args!
if [ "${MONGODB_DEPLOYMENT}" = "replicaset" ]; then
  setup_keyfile
fi
