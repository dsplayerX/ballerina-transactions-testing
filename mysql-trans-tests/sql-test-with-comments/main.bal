import ballerina/io;
import ballerinax/mysql.driver as _; // Importing the MySQL driver.
import ballerinax/mysql; // Importing the MySQL module.
// import ballerina/lang.runtime;
import ballerina/sql; // Importing the SQL module.

// Configuring the MySQL client.
configurable string USER = ?;
configurable string PASSWORD = ?;
configurable string HOST = ?;
configurable int PORT = ?;
configurable string DATABASE = ?;

// Creating a record type to store the data retrieved from the database.
type Product record {
    int id;
    string product;
    string price;
};

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

        sql:ParameterizedQuery selectQuery = `UPDATE product_test SET price = '249.99' WHERE id = 1`;        
        sql:ExecutionResult|sql:Error e1 = dbClient1->execute(selectQuery);
        io:println(e1);
        io:println(" > e1 done");
        
        sql:ParameterizedQuery selectQuery2 = `INSERT INTO figurines (id, name, size) VALUES (10, "Bluelantern Figurine", 1)`;
        sql:ExecutionResult|sql:Error e2 = dbClient2->execute(selectQuery2);
        io:println(e2);
        if (e2 is sql:Error) {
            io:println(" > e2 is error");
            io:println("QUERY: " + selectQuery2.strings.toString());
        } else {
            io:println(" > e2 is not error");
        }
        io:println(" > e2 done");

        // io:println(" > sleeping");
        // runtime:sleep(10);
        // io:println(" > resumed");

        check commit;

        // if commitResult is () {
        //     io:println("nil - " + commitResult.toString());
        //     str += " -> transaction committed";
        // } else {
        //     io:println("not nil - " + commitResult.toString());
        //     str += " -> transaction failed";
        // }
        str += " -> transaction ended.";
    }
    // on fail var e {
    //     io:println(e.toString());
    // } 
    io:println(str);
    checkpanic dbClient1.close();
    checkpanic dbClient2.close();
}
