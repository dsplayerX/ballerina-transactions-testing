import ballerina/http;
import ballerina/io;
import ballerina/log;

service / on new http:Listener(9711) {

    transactional resource function get chain1() returns http:Response|error {
        transaction:onCommit(commitHanlder);
            transaction:onRollback(rollbackHandler);
        http:Response respe = new;
        http:Client chain2 = check new ("http://localhost:9712");
        http:Response res = check chain2->get("/chain2");
        io:println("Chain1 response: ", res.statusCode);
        if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode != 202) {
                        io:println("Chain1 completed!");
            respe.statusCode = 200;
            respe.setPayload("Chain1 completed!");
            return respe;
        } else {
            io:println("Error in chain2");
            return error("Error in chain2");
        }
    }
}


isolated function commitHanlder('transaction:Info info) {
    log:printDebug("Commit Handler: Decision Commit!");
}

isolated function rollbackHandler(transaction:Info info, error? cause, boolean willRetry = true) {
    log:printDebug("Rollback Handler: Decision Rollback!");
}