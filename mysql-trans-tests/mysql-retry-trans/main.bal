import ballerina/io;
import ballerinax/mysql.driver as _; // Importing the MySQL driver.
import ballerinax/mysql; // Importing the MySQL module.
import ballerina/sql; // Importing the SQL module.
import ballerina/lang.runtime;

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
final mysql:Client dbClient = check new (
        host=HOST, user=USER, password=PASSWORD, port=PORT, database=DATABASE
    );

public function main() returns error? {
    if transactional {
        io:println("1 - Transactional");
    } else {
        io:println("1 - Not transactional");
    }
    // Short for `retry<DefaultRetryManager>(3)`.
    // If any of the `doStage1` and `doStage2` returns `error:Retriable`, the program will retry execution
    // until execution succeeds without an `error:Retriable` error.
    // By default, it will retry 3 times with the `DefaultRetryManager`.
    retry transaction {
        check doStage1();
        io:println("Sleeping for 10 seconds");
        runtime:sleep(1);
        io:println("Woke up");
        check doStage2();
        if transactional {
        io:println("2 - Transactional");
        } else {
        io:println("2 - Not transactional");
        }
        check commit;
    }

    return;
}

function doStage1() returns error? {
    sql:ParameterizedQuery query2 =`UPDATE product_test SET price = '169.99' WHERE id = 001`; // Query to update data in the table.
    sql:ExecutionResult|sql:Error result2 = dbClient->execute(query2); // Updating data in the table.

    if (result2 is sql:Error) {
        return error 'error:Retriable("Stage1 failed");
    }
    io:println("Data updated successfully."); 
    io:println("Stage1 completed");
}

function doStage2() returns error? {
    sql:ExecutionResult|sql:Error result = dbClient->execute(`
        INSERT INTO product_test (id, product, price)
        VALUES (29, "Test Figurine", 29.99)
    `); // Inserting data into the table.

    if transactional {
        io:println("3 - Transactional");
    } else {
        io:println("3 - Not transactional");
    }

    if (result is sql:Error) {
        return error 'error:Retriable("Stage2 failed");
    }
    // io:println( result.toString());
    io:println("Data inserted successfully");
    io:println("Stage2 completed");
}