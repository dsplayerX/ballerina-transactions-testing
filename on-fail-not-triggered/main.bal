import ballerina/io;
import ballerina/lang.runtime;
import ballerina/sql; // Importing the SQL module.
import ballerinax/mysql; // Importing the MySQL module.
import ballerinax/mysql.driver as _; // Importing the MySQL driver.

final mysql:Client dbClient = check new (
    host = "localhost", user = "root", password = "root", port = 3306, database = "test1", options = {useXADatasource: true}
);

public function main() returns error? {

    string str = "";
    do {
        transaction {
            str += "transaction started";

            // 2 queries that will execute without any errors
            sql:ParameterizedQuery query1 = `UPDATE product_test SET price = 250.00 WHERE id = 1`;
            sql:ParameterizedQuery query2 = `UPDATE product_test SET price = 1500.00 WHERE id = 2`;

            // execute the queries
            _ = check dbClient->execute(query1);
            _ = check dbClient->execute(query2);

            // sleep to stop the sql server
            io:println(" > sleeping");
            runtime:sleep(10);
            // > Manually stop the sql server service
            io:println(" > resumed");

            check trap commit;

            str += " -> transaction ended.";
        }
    } on fail var e {
        io:println("failed - " + e.toString());
    }
    io:println(str);
}
