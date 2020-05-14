#!/bin/bash

java -jar POCDriver.jar --host ${MONGO_URI} -d ${TEST_TIME_IN_SECS} ${PARAMS}
