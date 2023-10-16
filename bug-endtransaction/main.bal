import ballerina/http;
import ballerina/io;
import ballerina/sql;
// import ballerinax/java.jdbc;
import ballerina/task;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

sql:ConnectionPool pool = {
    maxOpenConnections: 1,
    maxConnectionLifeTime: 30,
    minIdleConnections: 0
};

// final jdbc:Client testDB = check new jdbc:Client("jdbc:sqlite:test.db", connectionPool = pool);

final mysql:Client testDB = check new (
    host = "localhost", user = "root", password = "root", port = 3306, database = "test", connectionPool = pool
);

type WorldRecord record {|
    string|() world;
|};
e
// set simulationError to true to get different stacktrace
public isolated function dbTest(boolean simulateError = false) returns error? {
    transaction {
        stream<WorldRecord, error?> result = testDB->query(`SELECT world FROM hello;`);
        check result.close();
        var _ = check testDB->execute(`INSERT INTO hello VALUES ('test')`);
        result = testDB->query(`SELECT world FROM hello;`);
        check result.close();
        if (simulateError) {
            rollback;
        } else {
            check commit;
        }
    }
    transaction {
        var _ = check testDB->execute(`DELETE FROM hello WHERE world='test'`);
        check commit;
    }
}

public isolated class TestTask {

    *task:Job;
    private int counter = 0;
    private final string name;

    function init(string name) {
        self.name = name;
    }

    public isolated function execute() {
        int count = 0;
        lock {
            count = self.counter.cloneReadOnly();
            self.counter += 1;
        }
        io:println(string `Task: ${self.name},  Invocation:  ${count}`);

        var err = trap dbTest();

        if !(err is ()) {
            io:println("Error in task " + self.name);
            io:println(err);
            io:println(err.stackTrace());
            panic err; // remove task after first error
        }
    }

    public isolated function schedule(decimal interval) {
        do {
            var _ = check task:scheduleJobRecurByFrequency(self, interval);
        } on fail error err {
            io:println(err);
        }
    }
}

service / on new http:Listener(9096) {
    resource function get .() returns json {
        return {
            hello: "world"
        };
    }
}

public function main() returns error? {
    var task1 = new TestTask("a    ");
    var task2 = new TestTask(" b   ");
    var task3 = new TestTask("  c  ");
    var task4 = new TestTask("   d ");
    var task5 = new TestTask("    e");
    TestTask[] tasks = [task1, task2, task3, task4, task5];

    decimal interval = 0.1; // adjust to change error occurrence speed
    // task1.schedule(interval);
    // task2.schedule(interval);
    // task3.schedule(interval);
    // task4.schedule(interval);
    // task5.schedule(interval);

    future<()>[] futures = [];

    foreach var item in tasks {
        var x = start item.schedule(interval);
        futures.push(x);
    }

    foreach int item in 0 ..< futures.length() {
        error? x = wait futures[item];
        check x;
    }
}
