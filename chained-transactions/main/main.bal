import ballerina/http;
import ballerina/log;
import ballerina/io;

service / on new http:Listener(9710) {

    resource function get startchain() returns error? {
        http:Client chain1Client = check new ("http://localhost:9711");
        transaction {
            transaction:onCommit(commitHanlder);
            transaction:onRollback(rollbackHandler);
            http:Response response = check chain1Client->get("/chain1");
            io:println("Chain1 response: ", response.statusCode);

            if !(response.statusCode == 200 || response.statusCode == 201 || response.statusCode != 202) {
                rollback;
            } else {
                check commit;
            }
        }
    }

}

isolated function commitHanlder('transaction:Info info) {
    log:printDebug("Commit Handler: Decision Commit!");
}

isolated function rollbackHandler(transaction:Info info, error? cause, boolean willRetry = true) {
    log:printDebug("Rollback Handler: Decision Rollback!");
}
