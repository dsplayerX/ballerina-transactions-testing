import ballerina/http;
import ballerina/io;

service / on new http:Listener(8080) {
    resource function get testing() returns error? {
        transaction {
            transaction:onCommit(commitDone);
            transaction:onRollback(rollbackDone);
            boolean successful = callRemoteService();
            if (successful) {
                rollback;
            } else {
                check commit;
            }
        }
    }
}

function callRemoteService() returns boolean {
    http:Client|error httpClient;

    do {
        httpClient = check new ("http://localhost:9090");
    } on fail {
        return false;
    }

    if (httpClient is error) {
        io:println("> Found unexpected output type: " + httpClient.toString());
        return false;
    }

    http:Response|error response = httpClient->get("/updatedb");
    if (response is error) {
        io:println("> Found unexpected output type: " + response.toString());
        return false;
    } else {
        var x = response.getTextPayload();
        io:println("> ", response.statusCode, " ", response.reasonPhrase);
        io:println("> Response: ", x);
        return true;
    }
}

isolated function commitDone('transaction:Info info) {
    io:println("> Successfully committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> Successfully rollbacked.");
}
