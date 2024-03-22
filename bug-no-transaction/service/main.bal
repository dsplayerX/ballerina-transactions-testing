import ballerina/http;
import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

service / on new http:Listener(9712) {
    final mysql:Client db1;

    function init() returns error? {
        self.db1 = check new (host = "localhost",
            user = "root", password = "root",
            port = 3306, database = "test",
            options = {
                useXADatasource: true
            }
        );
        log:printInfo("DB initialized");
    }

    transactional resource function get doTransactionalWork(int id) returns http:Response {
        transaction:onCommit(commitHanlder);
        transaction:onRollback(rollbackHandler);
        http:Response res = new;

        sql:ParameterizedQuery updateQuery = `UPDATE test.test SET hello = 'Updated' WHERE id = ${id};`;
        sql:ExecutionResult|sql:Error updateResult = self.db1->execute(updateQuery);

        if updateResult is sql:Error {
            log:printError("Update failed: SQL Error");
            res.statusCode = 500;
            res.setPayload("Update failed: SQL Error");
            return res;
        } else {
            if (updateResult.affectedRowCount == 0) {
                log:printError("Update failed: No rows updated");
                res.statusCode = 500;
                res.setPayload("Update failed: No rows updated");
                return res;
            }
            log:printInfo("Updated successfully");
            res.statusCode = 200;
            res.setPayload("Updated successfully");
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
