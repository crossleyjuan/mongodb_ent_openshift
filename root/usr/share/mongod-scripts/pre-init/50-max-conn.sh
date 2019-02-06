# add --maxConns argument to mongo_common_args if the MONGODB_MAX_CONNECTIONS is defined
if [ -v MONGODB_MAX_CONNECTIONS ];
then
  info "Adding --maxConns using ${MONGODB_MAX_CONNECTIONS}"
  mongo_common_args+=" --maxConns ${MONGODB_MAX_CONNECTIONS}"
fi

