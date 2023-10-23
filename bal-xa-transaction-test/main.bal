import ballerina/io;
import ballerinax/java.jdbc;

string xaDatasourceName = "org.h2.jdbcx.JdbcDataSource";

public function main() returns error? {
    string str = "";

    jdbc:Client dbClient1 = check new (url = "jdbc:h2:file:./xa-transactions/testdb1",
        user = "test", password = "test", options = {datasourceName: xaDatasourceName}
    );

    jdbc:Client dbClient2 = check new (url = "jdbc:h2:file:./xa-transactions/testdb2",
        user = "test", password = "test", options = {datasourceName: xaDatasourceName}
    );

    _ = check dbClient1->execute(`CREATE TABLE IF NOT EXISTS EMPLOYEE (ID INT, NAME VARCHAR(30))`);
    _ = check dbClient2->execute(`CREATE TABLE IF NOT EXISTS SALARY (ID INT, SALARY DECIMAL(10,2))`);

    transaction {
        str += "transaction started";

        var e1 = check dbClient1->execute(`INSERT INTO EMPLOYEE(NAME) VALUES ('John')`);

        var e2 = check dbClient2->execute(`INSERT INTO SALARY VALUES (1, 1000.00)`);

        var commitResult = commit;
        if commitResult is () {
            str += " -> transaction committed";
        } else {
            str += " -> transaction failed";
        }
        str += " -> transaction ended.";
    }

    if ("transaction started -> transaction committed -> transaction ended." == str) {
        io:println("test passed");
    } else {
        io:println("test failed");
    }

    checkpanic dbClient1.close();
    checkpanic dbClient2.close();
}
