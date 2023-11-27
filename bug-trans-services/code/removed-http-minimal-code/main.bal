import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final sql:ConnectionPool pool = {
    maxOpenConnections: 5,
    maxConnectionLifeTime: 30,
    minIdleConnections: 0
};

final mysql:Client testDB = check new (host = "localhost",
    user = "root",
    password = "root",
    port = 3306, database = "test",
    connectionPool = pool,
    options = {useXADatasource: true}
);

public function main() returns error? {
    transaction {
        transaction:onCommit(commitDone);
        transaction:onRollback(rollbackDone);
        future<error?> result = start callRemoteService();
        check wait result;
        check commit;
    }
}

transactional function callRemoteService() returns error? {
    sql:ExecutionResult execResult = check testDB->execute(`INSERT INTO test (hello) VALUES ('world')`);
    io:println("Affected row count: ", execResult.affectedRowCount);
    io:println("Inserted ID: ", execResult.lastInsertId);
}

isolated function commitDone('transaction:Info info) {
    io:println("> Initiator committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> Initiaor rollbacked.");
}
