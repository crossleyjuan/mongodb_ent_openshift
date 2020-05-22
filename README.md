MongoDB container images
=====================

This repository contains Dockerfiles to build an OpenShift image using MongoDB 3.6 Enterprise.
Users can choose between RHEL and CentOS based images.

For more information about using these images with OpenShift, please see the
official [OpenShift Documentation](https://docs.okd.io/latest/using_images/db_images/mongodb.html).

Build the image
================

To build the image you can execute the following:

docker build . --tag mongodb

Run using docker
===============

To run an instance you will need to pass the following parameters:

MONGODB_ADMIN_PASSWORD: admin user password
MONGODB_REPLICA_NAME: Name of the replicaset
MONGODB_KEYFILE_VALUE: Value to be used in the key file

optional parameters:
MONGODB_MAX_CONNECTIONS: configures the --maxConns parameter

Use the following variables to define a readWrite user:
MONGODB_USER
MONGODB_PASSWORD
MONGODB_DATABASE

Example:

export KV=$(openssl rand -base64 32)
docker run -e MONGODB_ADMIN_PASSWORD=123 -e MONGODB_REPLICA_NAME=testrepl -e MONGODB_KEYFILE_VALUE=${KV} --name=mongodb mongodb


Run using K8s
===============

To run in environment like openshift you will need to perform the following steps:

1. Create a secret named keyfile-secret with the key "internal-auth-mongodb-keyfile" with the keyfile contents that will be shared across the replicaset, here is an example of a bash script to generate this:

```bash
TMPFILE=$(mktemp)
/usr/bin/openssl rand -base64 741 > $TMPFILE
microk8s kubectl create secret generic keyfile-secret --from-file=internal-auth-mongodb-keyfile=$TMPFILE
rm $TMPFILE
```

openssl can be installed in Windows, Linux, OSX, but if you prefer there are online services that provide random base64 strings, be sure to give at least 256 length

2. Create a yaml with the definition of the service, and example is provided in the folder examples, be sure to provide values to the following environment variables:
  
```
- name: MONGODB_ADMIN_PASSWORD
  value: mongodb123
- name: MONGODB_REPLICA_NAME
  value: MainRepSet
- name: MONGODB_KEYFILE_VALUE
  valueFrom:
	  secretKeyRef:
		  name: keyfile-secret
		  key: internal-auth-mongodb-keyfile
- name: MONGODB_USER
  value: mongodb
- name: MONGODB_PASSWORD
  value: mongodb123
- name: MONGODB_DATABASE
  value: testperformance
- name: MONGODB_SERVICE_NAME
  value: mongodb
```

3. Apply the yaml to create the replica set:

```bash
# using kubectrl:
kubectl apply -f mongodb.yaml
# using oc:
oc apply -f mongodb.yaml
```

Audit log
=========

To enable the audit log you can use the template provided in the root/usr/share/mongod-scripts/mongod.conf.template just 
removing the comments and changing to the values you want, keep in mind that the $$ will be used to escape the dollar sign 
used to replace the environment variables.


auditLog:
    destination: file
    format: JSON
    path: ${MONGODB_LOGPATH}/audit.json
    filter: "{ atype: { $$in: [ 'authenticate', 'createDatabase', 'dropCollection', 'createUser', 'dropUser', 'dropAllUsersFromDatabase', 'updateUser' ] }}"

