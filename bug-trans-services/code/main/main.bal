import ballerina/http;
import ballerina/io;

FooClient fooClient = new FooClient(9090);

service / on new http:Listener(8080) {

    resource function get doTransaction() returns error? {
        transaction {
            transaction:onCommit(commitDone);
            transaction:onRollback(rollbackDone);
            check callRemoteService();
            check commit;
        }
        string response = check fooClient->bar();
        io:println(response);

    }
}

public client class FooClient {

    public http:Client httpClient;

    public function init(int port) {
        self.httpClient = checkpanic new ("http://localhost:9090");
    }

    transactional remote function foo() returns @tainted http:Response|error {
        return self.httpClient->get("/updateDb", targetType = http:Response);
    }

    remote function bar() returns @tainted string|error {
        return self.httpClient->get("/getAllRecords", targetType = string);
    }
}

transactional function callRemoteService() returns error? {
    http:Response response = check fooClient->foo();
    io:println("Response from remote service: ", response.statusCode, " ", response.reasonPhrase);
    // http:Client httpClient = check new ("http://localhost:9090");
    // http:Response response = check httpClient->get("/updateDb");
    // io:println("Response from remote service: ", response.statusCode, " ", response.reasonPhrase);
}

isolated function commitDone('transaction:Info info) {
    io:println("> Initiator committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> Initiaor rollbacked.");
}
