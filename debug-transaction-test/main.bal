import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/jballerina.java;

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
        port = 3306, database = "m1",
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

    sql:ParameterizedQuery insertQuery1 = `INSERT INTO m1.test1 (hello) VALUES ('world')`;
    sql:ParameterizedQuery insertQuery2 = `INSERT INTO m2.test3 (hello) VALUES ('world')`;
    sql:ParameterizedQuery updateQuery = `UPDATE m1.test1 SET hello = 'goodbye' WHERE id = 1`;

    transaction {
        transaction:onCommit(commitDone);
        transaction:onRollback(rollbackDone);
        sql:ExecutionResult execResult1 = check localDB->execute(insertQuery1);
        io:println("Affected row count: ", execResult1.affectedRowCount);
        io:println("Inserted ID: ", execResult1.lastInsertId);

        sql:ExecutionResult execResult2 = check dockerDB->execute(insertQuery2);
        io:println("Affected row count: ", execResult2.affectedRowCount);
        io:println("Inserted ID: ", execResult2.lastInsertId);

        sql:ExecutionResult execResult3 = check localDB->execute(updateQuery);
        io:println("Affected row count: ", execResult3.affectedRowCount);

        panicAll();
        check commit;

        // if (execResult1.affectedRowCount == 0 || execResult2.affectedRowCount == 0 || execResult3.affectedRowCount == 0) {
        //     io:println("Rolling back...");
        //     rollback;
        // } else {
        // }
    }

}

transactional function panicAll() {
    // panic "Panic!";
    divideByZero();
}

isolated function commitDone('transaction:Info info) {
    io:println("> TM committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> TM rollbacked.");
}

function divideByZero() = @java:Method {
	name: "divideByZero",
	'class: "a.b.c.Foo"
} external;