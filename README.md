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
