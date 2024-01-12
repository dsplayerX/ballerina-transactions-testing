// import ballerina/http;
// import ballerina/io;
// import ballerina/jballerina.java;
// import ballerina/sql;
// import ballerinax/mysql;
// import ballerinax/mysql.driver as _;

// sql:ConnectionPool pool = {
//     maxOpenConnections: 5,
//     maxConnectionLifeTime: 300,
//     minIdleConnections: 0
// };

// type WorldRecord record {|
//     int id;
//     string hello;
// |};

// boolean crashBeforeCommit = false;
// boolean stopSqlServer = false;

// service / on new http:Listener(9090) {
//     final mysql:Client localDB;
//     final mysql:Client dockerDB;

//     function init() returns error? {
//         _ = check startServ();
//         io:print("> Started SQL server.");

//         self.localDB = check new (host = "localhost",
//             user = "root", password = "root",
//             port = 3306, database = "mA",
//             connectionPool = pool,
//             options = {useXADatasource: true,
//             ssl: {
//                 allowPublicKeyRetrieval: true
//             }}
//         );
//         io:println("Database 1 initialized.");

//         self.dockerDB = check new (host = "localhost",
//             user = "root", password = "my-secret-pw",
//             port = 3308, database = "m2",
//             connectionPool = pool,
//             options = {useXADatasource: true,
//             ssl: {
//             allowPublicKeyRetrieval: true
//             }}
//         );
//         io:println("Database 2 initialized.");
//     }

//     resource function get trans(boolean crashIt, boolean stopSql, boolean rollIt) returns string|error {
//         stopSqlServer = stopSql;
//         if (!stopSqlServer) {
//             _ = check startServ();
//             io:println("Started SQL server...");
//         }
//         crashBeforeCommit = crashIt;
//         io:println("Crash before commit: ", crashBeforeCommit);
//         io:println("Stop SQL server: ", stopSqlServer);

//         sql:ParameterizedQuery insertQuery1 = `INSERT INTO ${"`"}mA.test1${"`"} (hello) VALUES ('world')`;
//         sql:ParameterizedQuery insertQuery2 = `INSERT INTO ${"`"}m2.test3${"`"} (hello) VALUES ('world')`;

//         io:println("Running transaction...");
//         transaction {
//             transaction:onCommit(commitDone);
//             transaction:onRollback(rollbackDone);
//             sql:ExecutionResult execResult1 = check self.localDB->execute(insertQuery1);
//             io:println("Affected row count: ", execResult1.affectedRowCount);
//             io:println("Inserted ID: ", execResult1.lastInsertId);

//             // sql:ParameterizedQuery deleteQuery1 = `DELETE FROM mA.test1 WHERE id = ${execResult1.lastInsertId}`;
//             // sql:ExecutionResult deleteResult = check self.localDB->execute(deleteQuery1);
//             // io:println("Affected row count: ", deleteResult.affectedRowCount);

//             sql:ExecutionResult execResult2 = check self.dockerDB->execute(insertQuery2);
//             io:println("Affected row count: ", execResult2.affectedRowCount);
//             io:println("Inserted ID: ", execResult2.lastInsertId);

//             sql:ParameterizedQuery updateQuery = `UPDATE m2.test3 SET hello = 'potter' WHERE id = ${execResult2.lastInsertId}`;

//             sql:ExecutionResult execResult3 = check self.dockerDB->execute(updateQuery);
//             io:println("Affected row count: ", execResult3.affectedRowCount);

//             // if (execResult1.affectedRowCount == 0 || execResult2.affectedRowCount == 0 || execResult3.affectedRowCount == 0 || rollIt == true) {
//             //     io:println("Rolling back...");
//             //     rollback;
//             // } else {
//             check commit;
//             // }

//         }
//         io:println("Transaction done.");
//         io:println("Starting SQL again...");
//         _ = check startServ();
//         io:println("SQL started.");
//         io:println("Done.");

//         return "transaction done";
//     }

//     resource function get getCrash() returns boolean|error {
//         return crashBeforeCommit;
//     }

//     resource function get stopSql() returns boolean|error {
//         return stopSqlServer;
//     }

// }

// isolated function commitDone('transaction:Info info) {
//     http:Client crasherClient = checkpanic new ("http://localhost:9090");
//     boolean crasher = checkpanic crasherClient->get("/getCrash");
//     io:println("Crasher value: ", crasher);

//     http:Client stopperClient = checkpanic new ("http://localhost:9090");
//     boolean stopper = checkpanic stopperClient->get("/stopSql");
//     io:println("Stopper value: ", stopper);

//     if (crasher) {
//         io:println("Crash. no stop.");
//         panicAll();
//     }
//     if (stopper) {
//         io:println("No crash. Stop Sql.");
//         _ = checkpanic stopServ();
//     }
//     io:println("No crash. No Stop.");

//     io:println("> TM committed.");
// }

// isolated function rollbackDone(transaction:Info info, error? cause, boolean willRetry = false) {
//     http:Client crasherClient = checkpanic new ("http://localhost:9090");
//     boolean crasher = checkpanic crasherClient->get("/getCrash");
//     io:println("Crasher value: ", crasher);

//     http:Client stopperClient = checkpanic new ("http://localhost:9090");
//     boolean stopper = checkpanic stopperClient->get("/stopSql");
//     io:println("Stopper value: ", stopper);

//     if (crasher) {
//         io:println("Crash. no stop.");
//         panicAll();
//     }
//     if (stopper) {
//         io:println("No crash. Stop Sql.");
//         _ = checkpanic stopServ();
//     }
//     io:println("No crash. No Stop.");

//     io:println("> TM rollbacked.");
// }

// isolated function stopServ() returns boolean|error {
//     io:println("Stopping SQL...");
//     http:Client stopClient = check new ("http://localhost:9292");
//     boolean stopped = check stopClient->get("/stopSql");
//     return stopped;
// }

// isolated function startServ() returns boolean|error {
//     io:println("Starting SQL...");
//     http:Client startClient = check new ("http://localhost:9292");
//     boolean started = check startClient->get("/startSql");
//     return started;
// }

// isolated function panicAll() {
//     divideByZero();
// }

// isolated function divideByZero() = @java:Method {
//     name: "divideByZero",
//     'class: "a.b.c.Foo"
// } external;
