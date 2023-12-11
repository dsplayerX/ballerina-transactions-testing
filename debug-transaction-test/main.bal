import ballerina/io;
import ballerina/jballerina.java;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

sql:ConnectionPool pool = {
    maxOpenConnections: 5,
    maxConnectionLifeTime: 60,
    minIdleConnections: 0
};

type WorldRecord record {|
    int id;
    string hello;
|};

public function main() returns error? {
    // Initialize the MySQL Database Clients.
    mysql:Client localDB = check new (host = "localhost",
        user = "root", password = "root",
        port = 3306, database = "mA",
        connectionPool = pool,
        options = {useXADatasource: true}
    );

    io:println("Database 1 initialized.");

    mysql:Client dockerDB = check new (host = "localhost",
        user = "root", password = "my-secret-pw",
        port = 3308, database = "m2",
        connectionPool = pool,
        options = {useXADatasource: true}
    );

    io:println("Database 2 initialized.");

    sql:ParameterizedQuery insertQuery1 = `INSERT INTO mA.test1 (hello) VALUES ('world')`;

    sql:ParameterizedQuery insertQuery2 = `INSERT INTO m2.test3 (hello) VALUES ('world')`;

    transaction {
        transaction:onCommit(commitDone);
        transaction:onRollback(rollbackDone);
        sql:ExecutionResult execResult1 = check localDB->execute(insertQuery1);
        io:println("Affected row count: ", execResult1.affectedRowCount);
        io:println("Inserted ID: ", execResult1.lastInsertId);

        // sql:ParameterizedQuery deleteQuery1 = `DELETE FROM mA.test1 WHERE id = ${execResult1.lastInsertId}`;
        // sql:ExecutionResult deleteResult = check localDB->execute(deleteQuery1);
        // io:println("Affected row count: ", deleteResult.affectedRowCount);

        sql:ExecutionResult execResult2 = check dockerDB->execute(insertQuery2);
        io:println("Affected row count: ", execResult2.affectedRowCount);
        io:println("Inserted ID: ", execResult2.lastInsertId);

        sql:ParameterizedQuery updateQuery = `UPDATE m2.test3 SET hello = 'potter' WHERE id = ${execResult2.lastInsertId}`;

        sql:ExecutionResult execResult3 = check dockerDB->execute(updateQuery);
        io:println("Affected row count: ", execResult3.affectedRowCount);

        // panicAll();

        check commit;

        // if (execResult1.affectedRowCount == 0 || execResult2.affectedRowCount == 0 || execResult3.affectedRowCount == 0) {
        //     io:println("Rolling back...");
        //     rollback;
        // } else {
        // }
    }

}

isolated function panicAll() {
    // panic "Panic!";
    divideByZero();
}

isolated function commitDone('transaction:Info info) {
    // panicAll();
    io:println("> TM committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> TM rollbacked.");
}

isolated function divideByZero() = @java:Method {
name: "divideByZero",
'class: "a.b.c.Foo"
} external;
