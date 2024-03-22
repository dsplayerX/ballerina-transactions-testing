import ballerina/http;
import ballerina/log;

service / on new http:Listener(9710) {
    resource function get startTransaction(int id) returns error? {
        http:Client chain1Client = check new ("http://localhost:9712");
        transaction {
            transaction:onCommit(commitHanlder);
            transaction:onRollback(rollbackHandler);
            http:Response response = check chain1Client->get(string`/doTransactionalWork?id=${id}`);
            log:printInfo(response.statusCode.toString());

            if (response.statusCode != 200) { // force rollback transaction
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
