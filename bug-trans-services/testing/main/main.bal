import ballerina/http;
import ballerina/io;

service / on new http:Listener(8080) {
    resource function get testing() returns error? {
        http:Client httpClient = check new ("http://localhost:9090");
        transaction {
            http:Response|error response;
            transaction:onCommit(commitDone);
            transaction:onRollback(rollbackDone);
            response = httpClient->get("/transaldb");
            if (response is http:Response) {
                var x = response.getTextPayload();
                io:println("> ", response.statusCode, " ", response.reasonPhrase);
                io:println("> Response: ", x);
                check commit;
            } else {
                io:println("> Found unexpected output type: " + response.message());
                rollback;
            }
        }
    }
}

isolated function commitDone('transaction:Info info) {
    io:println("> Successfully committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> Successfully rollbacked.");
}
