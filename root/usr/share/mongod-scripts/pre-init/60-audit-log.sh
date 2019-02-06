#!/bin/bash

if [[ -v MONGODB_AUDITLOG_ENABLED || -v MONGODB_AUDITLOG_FILTER ]]; 
then
	info "Setting audit log into the config file"
fi

