FROM openjdk:7
COPY . /app
WORKDIR /app
ENV TEST_TIME_IN_SECS=60
ENV REPLICASET_NAME=MainRepSet
ENV MONGO_URI=mongodb://mongod-0.mongodb-service.testmongodb.svc.cluster.local:27017/?replicaSet=MainRepSet
ENV PARAMS=

ENTRYPOINT ["/app/entry-point.sh"]
CMD ["/app/execute.sh"]
