import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

public function main() returns error? {

    mysql:Client localDB = check new (host = "localhost",
        user = "root", password = "root",
        port = 3306, database = "mA",
        options = {useXADatasource: true,
            ssl: {
                allowPublicKeyRetrieval: true
            }}
    );

    transaction {
        transaction:onCommit(commitDone);
        transaction:onRollback(rollbackDone);
        sql:ParameterizedQuery updateQuery1 = `UPDATE mA.test1 SET hello = 'rubirubi' WHERE id = 10`;
        sql:ExecutionResult execResult1 = check localDB->execute(updateQuery1);
        io:println("Affected row count: ", execResult1.affectedRowCount);
        if (execResult1.affectedRowCount == 0) {
            rollback;
        } else {
            check commit;
        }
    }
}

isolated function commitDone('transaction:Info info) {
    io:println("> Successfully committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> Successfully rollbacked.");
}

