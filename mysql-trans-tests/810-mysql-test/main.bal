import ballerina/io;
import ballerinax/mysql.driver as _; // Importing the MySQL driver.
import ballerinax/mysql; // Importing the MySQL module.
import ballerina/lang.runtime;
import ballerina/sql; // Importing the SQL module.

// Configuring the MySQL client.
configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;

final mysql:Client dbClient1 = check new (
        host=HOST, user=USER, password=PASSWORD, port=PORT, database="test1"
    );

final mysql:Client dbClient2 = check new (
        host=HOST, user=USER, password=PASSWORD, port=PORT, database="test2"
    );

public function main() returns error? {
    string str = "";
    transaction {
        str += "transaction started";

        sql:ParameterizedQuery query1 = `UPDATE product_test SET price = 100.00 WHERE id = 1`;        
        sql:ExecutionResult|sql:Error e1 = check dbClient1->execute(query1);
        
        sql:ParameterizedQuery query2 = `INSERT INTO figurines (id, name, size) VALUES (20, "test", 5)`;
        sql:ExecutionResult|sql:Error e2 = check dbClient2->execute(query2);
        
        io:println(" > sleeping");
        runtime:sleep(10);
        // manually stop the sql service
        io:println(" > resumed");

        check trap commit;

        str += " -> transaction ended.";
    }
    on fail var e {
        io:println("failed - " + e.toString());
    }
    io:println(str);
}
