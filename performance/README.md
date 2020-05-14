# Performance Test

The performance test is based in the good work of John Page here: https://github.com/johnlpage/POCDriver

## Build Image

To build the image you can run the following command:

```bash
docker build app -t performance
```

Then you can push it to your local repository like this:
```bash
docker tag performance localhost:32000/performance
docker push localhost:32000/performance
```

## Job

To create a job you can use the example provided in the examples folder. The following variables are provided for your convinience:

```yaml
env:
    - name: TEST_TIME_IN_SECS
    value: "60"
    - name: REPLICASET_NAME
    value: MainRepSet
    - name: MONGO_URI
    value: mongodb://admin:mongodb123@mongod-0.mongodb.testmongodb.svc.cluster.local:27017/admin?replicaSet=MainRepSet
    - name: PARAMS
    value: -k 70 -u 5
```

Be sure to update the MONGO_URI accordingly to your mongodb pods. If you need to send extra parameters you can use the PARAMS, to check the parameters please refer to the POCDriver documentation or use --help to check the options like this:

```bash
java -jar POCDriver.jara --help
```

## Example of execution

This is a an example of the steps to execute a job test using the example job.yaml

```bash
cross@cross:~/workspace/mongodb/k8s/testproject/manual/performance$ kubectl apply -f examples/job.yaml 
job.batch/mongodb-job created
cross@cross:~/workspace/mongodb/k8s/testproject/manual/performance$ kubectl get jobs
NAME          COMPLETIONS   DURATION   AGE
mongodb-job   0/1           6s         6s
cross@cross:~/workspace/mongodb/k8s/testproject/manual/performance$ kubectl get pods |grep job
mongodb-job-gbnqg   1/1     Running   0          16s
cross@cross:~/workspace/mongodb/k8s/testproject/manual/performance$ kubectl logs -f mongodb-job-gbnqg
MongoDB Proof Of Concept - Load Generator version 0.1.2
Creating worker 0
Creating worker 1
Creating worker 2
Creating worker 3
Worker thread 0 Started.
Worker thread 1 Started.
Worker thread 2 Started.
Worker thread 3 Started.
------------------------
After 10 seconds (08:54:32), 17,640 new documents inserted - collection has 311,183 in total 
1,663 inserts per second since last report 
	18.33 % in under 50 milliseconds
1,187 keyqueries per second since last report 
	99.93 % in under 50 milliseconds
82 updates per second since last report 
	19.61 % in under 50 milliseconds
0 rangequeries per second since last report 
	100.00 % in under 50 milliseconds

------------------------
After 20 seconds (08:54:42), 57,306 new documents inserted - collection has 350,849 in total 
3,966 inserts per second since last report 
	40.49 % in under 50 milliseconds
2,753 keyqueries per second since last report 
	99.97 % in under 50 milliseconds
195 updates per second since last report 
	39.12 % in under 50 milliseconds
0 rangequeries per second since last report 
	100.00 % in under 50 milliseconds
```
