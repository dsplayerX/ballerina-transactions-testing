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

type WorldRecord record {|
    string|() world;
|};

service / on new http:Listener(9090) {
    // private mysql:Client testDB;
    // function init() returns error? {
    //     self.testDB = check new (host = "localhost", user = "root", password = "root", port = 3306, database = "test", connectionPool = pool, options = {useXADatasource: true});
    // }
    // transactional resource function get transaldb() returns string|error? {
    //     mysql:Client testDB;
    //     testDB = check new (host = "localhost", user = "root", password = "root", port = 3306, database = "test", connectionPool = pool, options = {useXADatasource: true});
    //     sql:ParameterizedQuery query1 = `INSERT INTO test.baltest (hello) VALUES ('4bal')`;
    //     sql:ExecutionResult|sql:Error e1 = check testDB->execute(query1);
    //     io:println(e1);
    //     if (e1 is sql:Error) {
    //         return e1;
    //     } else {
    //         return "success";
    //     }
    // }

    transactional resource function get transaldb(http:Caller caller) returns error? {
        
            transaction:onCommit(commitDone);
            transaction:onRollback(rollbackDone);
        mysql:Client testDB;
        testDB = check new (host = "localhost", user = "root", password = "root", port = 3306, database = "test", connectionPool = pool, options = {useXADatasource: true});
        sql:ParameterizedQuery query1 = `INSERT INTO test.baltest (hello) VALUES ('4bal')`;
        sql:ExecutionResult|sql:Error e1 = check testDB->execute(query1);
        io:println(e1);
        // check testDB.close();
        if (e1 is sql:Error) {
            checkpanic caller->respond(e1);
        } else {
            checkpanic caller->respond("success");
        }
    }
}

isolated function commitDone('transaction:Info info) {
    io:println("> Successfully committed.");
}

isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry) {
    io:println("> Successfully rollbacked.");
}