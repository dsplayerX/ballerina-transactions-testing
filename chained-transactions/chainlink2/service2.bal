import ballerina/http;
import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

service / on new http:Listener(9712) {
    final mysql:Client db1;
    final mysql:Client db2;

    function init() returns error? {
        self.db1 = check new (host = "localhost",
            user = "root", password = "root",
            port = 3306, database = "test",
            options = {
                useXADatasource: true
            }
        );

        self.db2 = check new (
            host = "localhost", user = "root", password = "my-secret-pw", port = 3308, database = "techtalk", options = {useXADatasource: true}
        );
        log:printInfo("DBs inited!");
    }

    transactional resource function get chain2() returns http:Response|error {
        transaction:onCommit(commitHanlder);
        transaction:onRollback(rollbackHandler);
        http:Response res = new;

        sql:ParameterizedQuery testquery = `INSERT INTO test.test(hello) VALUES ('New World');`;
        sql:ExecutionResult|sql:Error updateResult = self.db1->execute(testquery);

        sql:ParameterizedQuery updateQuery = `UPDATE Payments SET amount = amount - 10 WHERE cardNo = "card1"`;
        sql:ExecutionResult|sql:Error result2 = self.db2->execute(updateQuery);
        if result2 is sql:Error {
            log:printInfo("Payment update failed!");
            return error("Payment update failed!");
        }
        if updateResult is sql:Error {
            log:printError("Error while updating stock: ", updateResult);
            return error("Error while updating stock: ", updateResult);
        } else {
            log:printInfo("Stock updated successfully");
            res.statusCode = 200;
            res.setPayload("Stock updated successfully");
            return res;
        }
    }
}

isolated function commitHanlder('transaction:Info info) {
    log:printDebug("Commit Handler: Decision Commit!");
}

isolated function rollbackHandler(transaction:Info info, error? cause, boolean willRetry = true) {
    log:printDebug("Rollback Handler: Decision Rollback!");
}
