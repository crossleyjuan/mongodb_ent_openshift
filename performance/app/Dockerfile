FROM openjdk:7
COPY . /app
WORKDIR /app
ENV TEST_TIME_IN_SECS=60
ENV REPLICASET_NAME=MainRepSet
ENV MONGO_URI=mongodb://mongod-0.mongodb-service.testmongodb.svc.cluster.local:27017/?replicaSet=MainRepSet
ENV PARAMS=

RUN apt-get update && \
    apt-get install -y dos2unix && \
    dos2unix /app/entry-point.sh && \
    dos2unix /app/execute.sh && \
    chmod a+x /app/*

ENTRYPOINT ["/app/entry-point.sh"]
CMD ["/app/execute.sh"]
