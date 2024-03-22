import ballerina/http;
import ballerina/io;
import ballerina/sql;
// import ballerinax/java.jdbc;
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

service / on new http:Listener(9090) {
    private mysql:Client testDB;
    // private  ;
    function init() returns error? {
        self.testDB = check new (host = "localhost",
            user = "root", password = "my-secret-pw",
            port = 3308, database = "test",
            connectionPool = pool,
            options = {useXADatasource: true}
        );

        // self.testDB = check new jdbc:Client("jdbc:h2:./h2/test.db;AUTOCOMMIT=OFF", connectionPool = pool);
        // sql:ExecutionResult _ = check self.testDB->execute(`CREATE DATABASE IF NOT EXISTS test`);
        sql:ExecutionResult _ = check self.testDB->execute(`CREATE TABLE IF NOT EXISTS test.test (id INTEGER PRIMARY KEY AUTO_INCREMENT, hello VARCHAR(255) NOT NULL)`);

        io:println("Database initialized.");
    }

    transactional resource function get updateDb() returns error? {
        transaction:onCommit(commitDone);
        transaction:onRollback(rollbackDone);
        sql:ParameterizedQuery query = `INSERT INTO test (hello) VALUES ('world')`;
        // sql:ParameterizedQuery query2 = `UPDATE test SET hello = 'goodbye' WHERE id = 9`;
        sql:ExecutionResult execResult = check self.testDB->execute(query);
        io:println("Affected row count: ", execResult.affectedRowCount);
        io:println("Inserted ID: ", execResult.lastInsertId);
    }

    resource function get getAllRecords() returns string|error? {
        //Q: turn this stream of worldrecords to a string array 
        stream<WorldRecord, error?> result = self.testDB->query(`SELECT * FROM test;`);
        string[] worldArray = check from var number in result
            select number.hello;
        check result.close();

        return worldArray.toString();

        // stream<WorldRecord, error?> result = self.testDB->query(`SELECT world FROM hello;`);
        // check result.close();
    }
}

isolated function commitDone('transaction:Info info) {
    io:println("> Particiapnt committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> Participant rollbacked.");
}
