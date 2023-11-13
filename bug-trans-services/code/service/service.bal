import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

sql:ConnectionPool pool = {
    maxOpenConnections: 5,
    maxConnectionLifeTime: 30,
    minIdleConnections: 0
};

service / on new http:Listener(9090) {
    private mysql:Client testDB;
    function init() returns error? {
        self.testDB = check new (host = "localhost", user = "root", password = "root", port = 3306, database = "test", connectionPool = pool, options = {useXADatasource: true});
    }
    transactional resource function get updatedb() returns string|error? {
        transaction:onCommit(commitDone);
        transaction:onRollback(rollbackDone);
        sql:ParameterizedQuery query1 = `INSERT INTO test.baltest (hello) VALUES ('4bal')`;
        sql:ExecutionResult|error? e1 = check self.testDB->execute(query1);
        io:println(e1);
        if (e1 is error) {
            return error("error" + e1.toString());
        } else {
            return "success";
        }
    }
}

isolated function commitDone('transaction:Info info) {
    io:println("> Successfully committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> Successfully rollbacked.");
}
